import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = { "Content-Type": "application/json" };

type Identity = { account_id: string; sh_id: string; ownership_role: string };
type Candidate = {
  content?: string;
  memory_type?: "SHORT_TERM" | "LONG_TERM";
  source?: string;
  confidence?: number | null;
  scope?: "PRIVATE" | "GENERAL";
  visibility?: "OWNER_ONLY" | "SHARED";
  lifecycle?: "CANDIDATE" | "ACTIVE";
};

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return new Response(JSON.stringify({ error: "METHOD_NOT_ALLOWED" }), { status: 405, headers: corsHeaders });
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return new Response(JSON.stringify({ error: "MEMORY_REJECTED: authenticated identity is required" }), { status: 401, headers: corsHeaders });

  const url = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!url || !anonKey) return new Response(JSON.stringify({ error: "RUNTIME_CONFIGURATION_ERROR" }), { status: 500, headers: corsHeaders });
  const supabase = createClient(url, anonKey, { global: { headers: { Authorization: authHeader } } });

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return new Response(JSON.stringify({ error: "MEMORY_REJECTED: authenticated identity is required" }), { status: 401, headers: corsHeaders });

  let body: { response?: unknown };
  try { body = await req.json(); } catch { return new Response(JSON.stringify({ error: "MEMORY_REJECTED: invalid JSON" }), { status: 400, headers: corsHeaders }); }
  const response = body.response;
  if (!response || typeof response !== "object" || Array.isArray(response)) return new Response(JSON.stringify({ stored: false, reason: "NO_MEMORY_CANDIDATE" }), { status: 200, headers: corsHeaders });

  const candidate = (response as Record<string, unknown>).memory_candidate as Candidate | undefined;
  if (!candidate || typeof candidate !== "object" || typeof candidate.content !== "string" || !candidate.content.trim()) {
    return new Response(JSON.stringify({ stored: false, reason: "NO_MEMORY_CANDIDATE" }), { status: 200, headers: corsHeaders });
  }

  const { data: identities, error: identityError } = await supabase.rpc("resolve_identity");
  if (identityError || !identities || identities.length !== 1) return new Response(JSON.stringify({ error: "MEMORY_REJECTED: SH identity could not be resolved" }), { status: 403, headers: corsHeaders });
  const identity = (identities as Identity[])[0];

  const { data: memoryId, error: memoryError } = await supabase.rpc("runtime_record_memory", {
    p_sh_id: identity.sh_id,
    p_content: candidate.content.trim(),
    p_memory_type: candidate.memory_type ?? "LONG_TERM",
    p_source: candidate.source ?? "runtime_response",
    p_confidence: candidate.confidence ?? null,
    p_scope: candidate.scope ?? "PRIVATE",
    p_visibility: candidate.visibility ?? "OWNER_ONLY",
    p_lifecycle: candidate.lifecycle ?? "CANDIDATE",
  });
  if (memoryError) return new Response(JSON.stringify({ error: "MEMORY_PERSISTENCE_FAILED" }), { status: 403, headers: corsHeaders });

  return new Response(JSON.stringify({ stored: true, memory_id: memoryId, sh_id: identity.sh_id }), { status: 200, headers: corsHeaders });
});
