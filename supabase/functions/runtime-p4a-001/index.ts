import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { createJourneySink, executeModel, journeyCandidateFromResponse } from "./sh_runtime_bundle.ts";

type Identity = { account_id: string; sh_id: string; ownership_role: string };
const jsonHeaders = { "Content-Type": "application/json" };
const streamHeaders = { "Content-Type": "text/event-stream; charset=utf-8", "Cache-Control": "no-cache", "Connection": "keep-alive" };

async function resolveIdentity(req: Request) {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return { error: new Response(JSON.stringify({ error: "RUNTIME_REJECTED: authenticated identity is required" }), { status: 401, headers: jsonHeaders }) };
  const supabaseUrl = Deno.env.get("SUPABASE_URL"); const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!supabaseUrl || !supabaseAnonKey) return { error: new Response(JSON.stringify({ error: "RUNTIME_CONFIGURATION_ERROR" }), { status: 500, headers: jsonHeaders }) };
  const supabase = createClient(supabaseUrl, supabaseAnonKey, { global: { headers: { Authorization: authHeader } } });
  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return { error: new Response(JSON.stringify({ error: "RUNTIME_REJECTED: authenticated identity is required" }), { status: 401, headers: jsonHeaders }) };
  const { data: identities, error: identityError } = await supabase.rpc("resolve_identity");
  if (identityError) return { error: new Response(JSON.stringify({ error: "RUNTIME_IDENTITY_RESOLUTION_FAILED" }), { status: 403, headers: jsonHeaders }) };
  const rows = (identities ?? []) as Identity[];
  if (rows.length !== 1) return { error: new Response(JSON.stringify({ error: "RUNTIME_REJECTED: SH identity could not be resolved" }), { status: 403, headers: jsonHeaders }) };
  return { identity: rows[0], supabase };
}

async function recordConversation(supabase: ReturnType<typeof createClient>, shId: string, role: "user" | "assistant", content: string) {
  const { error } = await supabase.rpc("runtime_record_conversation", { p_sh_id: shId, p_role: role, p_content: content, p_metadata: { source: "runtime-p4a-001", persistence: "P4A-005" } });
  if (error) throw new Error(`RUNTIME_CONVERSATION_PERSIST_FAILED: ${error.message}`);
}
async function recordAudit(supabase: ReturnType<typeof createClient>, shId: string, eventType: "RUNTIME_REQUEST" | "RUNTIME_RESPONSE", metadata: Record<string, unknown>) {
  const { error } = await supabase.rpc("runtime_record_audit", { p_sh_id: shId, p_event_type: eventType, p_status: "SUCCESS", p_metadata: { source: "runtime-p4a-001", ...metadata } });
  if (error) throw new Error(`RUNTIME_AUDIT_PERSIST_FAILED: ${error.message}`);
}
function createRecorder(supabase: ReturnType<typeof createClient>) { return { async record(input: { sh_id: string; event_type: string; occurred_at?: string | null; continuity_status?: string; gap_code?: string | null; payload: Record<string, unknown>; source_ref?: string | null }) {
  const { data, error } = await supabase.rpc("runtime_record_journey_event", { p_sh_id: input.sh_id, p_event_type: input.event_type, p_occurred_at: input.occurred_at ?? null, p_continuity_status: input.continuity_status ?? null, p_gap_code: input.gap_code ?? null, p_payload: input.payload, p_source_ref: input.source_ref ?? null });
  if (error) throw new Error(`JOURNEY_RECORD_FAILED: ${error.message}`); if (typeof data !== "string") throw new Error("JOURNEY_RECORD_FAILED: recorder returned no event id"); return data;
} }; }

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return new Response(JSON.stringify({ error: "METHOD_NOT_ALLOWED" }), { status: 405, headers: jsonHeaders });
  const resolved = await resolveIdentity(req); if (resolved.error) return resolved.error;
  let body: { user_message?: string; stream?: boolean; journey_only?: boolean; explicit_journey_capture?: boolean; journey_representation?: string };
  try { body = await req.json(); } catch { return new Response(JSON.stringify({ error: "RUNTIME_REJECTED: invalid JSON" }), { status: 400, headers: jsonHeaders }); }
  const identity = resolved.identity; const supabase = resolved.supabase;

  if (body.journey_only === true) {
    if (body.explicit_journey_capture !== true) return new Response(JSON.stringify({ error: "JOURNEY_REJECTED: explicit capture is required" }), { status: 400, headers: jsonHeaders });
    const representation = body.journey_representation?.trim(); if (!representation) return new Response(JSON.stringify({ error: "JOURNEY_REJECTED: representation is required" }), { status: 400, headers: jsonHeaders });
    try {
      const sink = createJourneySink(() => undefined, createRecorder(supabase));
      const decision = await sink.decideAndRecord({ sh_id: identity.sh_id, user_message: representation, response: null, explicit: true });
      await recordAudit(supabase, identity.sh_id, "RUNTIME_REQUEST", { journey_only: true, explicit_journey_capture: true });
      await recordAudit(supabase, identity.sh_id, "RUNTIME_RESPONSE", { journey_only: true, journey_decision: decision.reason });
      return new Response(JSON.stringify({ sh_id: identity.sh_id, journey_decision: decision.reason, event_id: decision.candidate ? "recorded" : null }), { status: 200, headers: jsonHeaders });
    } catch (error) { return new Response(JSON.stringify({ error: error instanceof Error ? error.message : "JOURNEY_CAPTURE_FAILED" }), { status: 500, headers: jsonHeaders }); }
  }

  const userMessage = body.user_message?.trim(); if (!userMessage) return new Response(JSON.stringify({ error: "RUNTIME_REJECTED: user_message is required" }), { status: 400, headers: jsonHeaders });
  let modelId = "unselected"; let modelProvider = "unselected"; let task = "unselected";
  try {
    await recordAudit(supabase, identity.sh_id, "RUNTIME_REQUEST", { stream: body.stream === true, user_message_length: userMessage.length, model_policy: "ZERO_BUDGET_AUTOMATIC_MULTI_MODEL" });
    const routed = await executeModel(userMessage); modelId = routed.model_id; modelProvider = routed.provider; task = routed.task;
    const modelResponse = routed.response; const output = typeof modelResponse.output === "string" ? modelResponse.output : JSON.stringify(modelResponse.output);
    await recordConversation(supabase, identity.sh_id, "user", userMessage); await recordConversation(supabase, identity.sh_id, "assistant", output);
    const candidate = journeyCandidateFromResponse(modelResponse);
    const sink = createJourneySink(() => candidate, createRecorder(supabase));
    const decision = await sink.decideAndRecord({ sh_id: identity.sh_id, user_message: userMessage, response: modelResponse, explicit: body.explicit_journey_capture === true });
    await recordAudit(supabase, identity.sh_id, "RUNTIME_RESPONSE", { stream: body.stream === true, response_length: output.length, journey_decision: decision.reason, model_provider: modelProvider, model_id: modelId, cost_tier: routed.cost_tier, task, semantic_signals_present: modelResponse.semantic_signals !== undefined });
    const meta = { phase: "P4A-001", model_provider: modelProvider, model_id: modelId, cost_tier: routed.cost_tier, task, context_entries: 0, memory_decision: "deferred", journey_decision: decision.reason, semantic_signals: modelResponse.semantic_signals ?? null, persistence: "verified-path", audit: "verified-path" };
    if (!body.stream) return new Response(JSON.stringify({ sh_id: identity.sh_id, response: output, meta }), { status: 200, headers: jsonHeaders });
    const encoder = new TextEncoder(); const chunks = output.match(/.{1,12}/g) ?? [output];
    const stream = new ReadableStream<Uint8Array>({ async start(controller) { const send = (event: string, payload: unknown) => controller.enqueue(encoder.encode(`event: ${event}\ndata: ${JSON.stringify(payload)}\n\n`)); send("response", { sh_id: identity.sh_id, text: "", meta: { ...meta, streaming: true } }); for (const chunk of chunks) { send("token", { text: chunk }); await new Promise(resolve => setTimeout(resolve, 20)); } send("complete", { sh_id: identity.sh_id }); controller.close(); } });
    return new Response(stream, { status: 200, headers: streamHeaders });
  } catch (error) {
    const message = error instanceof Error ? error.message : "RUNTIME_MODEL_EXECUTION_FAILED";
    try { await recordAudit(supabase, identity.sh_id, "RUNTIME_RESPONSE", { status: "FAILED", model_provider: modelProvider, model_id: modelId, task, error: message }); } catch { /* preserve original failure */ }
    return new Response(JSON.stringify({ error: message }), { status: 502, headers: jsonHeaders });
  }
});
