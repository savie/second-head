import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { recordExplicitSemanticLifecycle } from "./semantic_lifecycle.ts";
import { evaluateSemanticSignal, type SemanticSignal } from "./semantic_decision.ts";

type Identity = { account_id: string; sh_id: string; ownership_role: string };
type ContextPackage = Record<string, unknown>;
type ProviderResult = { output: string; provider: string };
type Provider = (input: string, context: ContextPackage) => Promise<ProviderResult>;

const jsonHeaders = { "Content-Type": "application/json" };
function json(body: Record<string, unknown>, status = 200) { return new Response(JSON.stringify(body), { status, headers: jsonHeaders }); }

async function resolveIdentity(req: Request) {
  const authorization = req.headers.get("Authorization");
  if (!authorization) return { error: json({ error: "RUNTIME_REJECTED: authenticated identity is required" }, 401) };
  const url = Deno.env.get("SUPABASE_URL"); const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!url || !anonKey) return { error: json({ error: "RUNTIME_CONFIGURATION_ERROR" }, 500) };
  const supabase = createClient(url, anonKey, { global: { headers: { Authorization: authorization } } });
  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return { error: json({ error: "RUNTIME_REJECTED: authenticated identity is required" }, 401) };
  const { data, error } = await supabase.rpc("resolve_identity");
  if (error) return { error: json({ error: "RUNTIME_IDENTITY_RESOLUTION_FAILED" }, 403) };
  const rows = (data ?? []) as Identity[];
  if (rows.length !== 1) return { error: json({ error: "RUNTIME_REJECTED: SH identity could not be resolved" }, 403) };
  return { identity: rows[0], supabase };
}

async function loadContext(supabase: ReturnType<typeof createClient>, shId: string, query: string): Promise<ContextPackage> {
  const { data, error } = await supabase.rpc("runtime_get_context_package", { p_sh_id: shId, p_query_text: query });
  if (error) throw new Error(`CONTEXT_PACKAGE_RETRIEVAL_FAILED: ${error.message}`);
  if (!data || typeof data !== "object" || Array.isArray(data)) throw new Error("CONTEXT_PACKAGE_INVALID");
  return data as ContextPackage;
}

async function recordConversation(supabase: ReturnType<typeof createClient>, shId: string, role: "user" | "assistant", content: string) {
  const { error } = await supabase.rpc("runtime_record_conversation", {
    p_sh_id: shId, p_role: role, p_content: content,
    p_metadata: { source: "ai-runtime", persistence: "runtime_record_conversation" },
  });
  if (error) throw new Error(`RUNTIME_CONVERSATION_PERSIST_FAILED: ${error.message}`);
}

async function recordAudit(supabase: ReturnType<typeof createClient>, shId: string, eventType: "RUNTIME_REQUEST" | "RUNTIME_RESPONSE" | "RUNTIME_MEMORY_DECISION", status: "SUCCESS" | "REJECTED" | "FAILED", metadata: Record<string, unknown> = {}) {
  const { error } = await supabase.rpc("runtime_record_audit", {
    p_sh_id: shId, p_event_type: eventType, p_status: status,
    p_metadata: { source: "ai-runtime", ...metadata },
  });
  if (error) throw new Error(`RUNTIME_AUDIT_PERSIST_FAILED: ${error.message}`);
}

function parseProviderResponse(raw: string) {
  let parsed: unknown;
  try { parsed = JSON.parse(raw); } catch { throw new Error("MODEL_PROVIDER_INVALID_OUTPUT: response was not JSON"); }
  if (!parsed || typeof parsed !== "object") throw new Error("MODEL_PROVIDER_INVALID_OUTPUT: response envelope is invalid");
  const choices = (parsed as Record<string, unknown>).choices; const first = Array.isArray(choices) ? choices[0] : undefined;
  const message = first && typeof first === "object" ? (first as Record<string, unknown>).message : undefined;
  const content = message && typeof message === "object" ? (message as Record<string, unknown>).content : undefined;
  if (typeof content !== "string" || !content.trim()) throw new Error("MODEL_PROVIDER_INVALID_OUTPUT: response content is empty");
  return content.trim();
}

function extractSemanticSignals(output: string): SemanticSignal[] {
  const signals: SemanticSignal[] = [];
  const match = output.match(/<semantic_signals>\s*([\s\S]*?)\s*<\/semantic_signals>/i);
  if (!match) return signals;
  let parsed: unknown;
  try { parsed = JSON.parse(match[1]); } catch { return signals; }
  if (!Array.isArray(parsed)) return signals;
  for (const candidate of parsed) {
    if (!candidate || typeof candidate !== "object") continue;
    const item = candidate as Record<string, unknown>;
    if (!(["MEMORY", "KNOWLEDGE", "EXPERIENCE", "JOURNEY"] as string[]).includes(String(item.domain))) continue;
    if (typeof item.evidence !== "string" || !item.evidence.trim()) continue;
    const confidence = Number(item.confidence);
    if (!Number.isFinite(confidence) || confidence < 0 || confidence > 1) continue;
    signals.push({ domain: String(item.domain) as SemanticSignal["domain"], confidence, evidence: item.evidence.trim(), source: "MODEL" });
  }
  return signals;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return json({ error: "METHOD_NOT_ALLOWED" }, 405);
  const resolved = await resolveIdentity(req); if (resolved.error) return resolved.error;
  let body: { user_message?: string };
  try { body = await req.json(); } catch { return json({ error: "RUNTIME_REJECTED: invalid JSON" }, 400); }
  const userMessage = body.user_message?.trim(); if (!userMessage) return json({ error: "RUNTIME_REJECTED: user_message is required" }, 400);

  try {
    await recordAudit(resolved.supabase, resolved.identity.sh_id, "RUNTIME_REQUEST", "SUCCESS", { user_message_length: userMessage.length, model_policy: "ZERO_BUDGET_AUTOMATIC_MULTI_MODEL" });
    await recordConversation(resolved.supabase, resolved.identity.sh_id, "user", userMessage);

    const context = await loadContext(resolved.supabase, resolved.identity.sh_id, userMessage);
    const semantic = await recordExplicitSemanticLifecycle(resolved.supabase, resolved.identity.sh_id, userMessage);
    if (Object.keys(semantic).length > 0) await recordAudit(resolved.supabase, resolved.identity.sh_id, "RUNTIME_MEMORY_DECISION", "SUCCESS", { semantic_capture: Object.keys(semantic) });

    const result = await executeWithFallback(userMessage, context);
    const semanticSignals = extractSemanticSignals(result.output);
    const semanticDecisions = semanticSignals.map((signal) => ({ domain: signal.domain, confidence: signal.confidence, evidence: signal.evidence, decision: evaluateSemanticSignal(signal) }));
    if (semanticSignals.length > 0) {
      await recordAudit(resolved.supabase, resolved.identity.sh_id, "RUNTIME_MEMORY_DECISION", "SUCCESS", { candidate_detected: semanticSignals.length, decisions: semanticDecisions, persistence: "not_performed" });
    }
    await recordConversation(resolved.supabase, resolved.identity.sh_id, "assistant", result.output);
    await recordAudit(resolved.supabase, resolved.identity.sh_id, "RUNTIME_RESPONSE", "SUCCESS", { provider: result.provider, context: "runtime_get_context_package", semantic_capture: Object.keys(semantic).length > 0, semantic_candidate_count: semanticSignals.length });

    return json({ sh_id: resolved.identity.sh_id, response: result.output, meta: {
      runtime: "ai-runtime", provider: result.provider, context: "runtime_get_context_package",
      semantic_capture: Object.keys(semantic).length > 0, semantic_candidates: semanticDecisions,
      persistence: "verified-path", audit: "verified-path",
    } });
  } catch (error) {
    try { await recordAudit(resolved.supabase, resolved.identity.sh_id, "RUNTIME_RESPONSE", "FAILED", { error: error instanceof Error ? error.message : "AI_RUNTIME_EXECUTION_FAILED" }); } catch {}
    return json({ error: error instanceof Error ? error.message : "AI_RUNTIME_EXECUTION_FAILED" }, 502);
  }
});

async function executeWithFallback(input: string, context: ContextPackage) {
  const failures: string[] = [];
  for (const provider of providers) { try { return await provider(input, context); } catch (error) { failures.push(error instanceof Error ? error.message : "unknown provider failure"); } }
  throw new Error(`MODEL_EXECUTION_FAILED: ${failures.join(" | ")}`);
}
