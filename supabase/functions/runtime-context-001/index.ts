import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = { "Content-Type": "application/json" };

type Identity = { account_id: string; sh_id: string; ownership_role: string };

type RequestBody = {
  query?: unknown;
  memory_limit?: unknown;
  knowledge_limit?: unknown;
  journey_limit?: unknown;
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: corsHeaders });
}

function boundedLimit(value: unknown, fallback: number, max: number): number {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) return fallback;
  return Math.min(Math.max(Math.trunc(parsed), 1), max);
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return json({ error: "METHOD_NOT_ALLOWED" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return json({ error: "CONTEXT_REJECTED: authenticated identity is required" }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!supabaseUrl || !supabaseAnonKey) return json({ error: "RUNTIME_CONFIGURATION_ERROR" }, 500);

  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) {
    return json({ error: "CONTEXT_REJECTED: authenticated identity is required" }, 401);
  }

  let body: RequestBody = {};
  try {
    const parsed = await req.json();
    if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) body = parsed as RequestBody;
  } catch {
    return json({ error: "CONTEXT_REJECTED: invalid JSON" }, 400);
  }

  const query = typeof body.query === "string" ? body.query.trim() : "";
  if (query.length > 2_000) return json({ error: "CONTEXT_REJECTED: query too large" }, 400);

  const memoryLimit = boundedLimit(body.memory_limit, 10, 20);
  const knowledgeLimit = boundedLimit(body.knowledge_limit, 10, 20);
  const journeyLimit = boundedLimit(body.journey_limit, 20, 50);

  const { data: identities, error: identityError } = await supabase.rpc("resolve_identity");
  if (identityError) return json({ error: "RUNTIME_IDENTITY_RESOLUTION_FAILED" }, 403);

  const rows = (identities ?? []) as Identity[];
  if (rows.length !== 1) return json({ error: "CONTEXT_REJECTED: SH identity could not be resolved" }, 403);
  const identity = rows[0];

  const { data: context, error: contextError } = await supabase.rpc("assemble_context", {
    p_sh_id: identity.sh_id,
    p_query_text: query,
    p_memory_limit: memoryLimit,
    p_knowledge_limit: knowledgeLimit,
  });
  if (contextError) return json({ error: "CONTEXT_ASSEMBLY_FAILED" }, 500);

  const { data: journey, error: journeyError } = await supabase
    .from("journey_events")
    .select("event_id,event_type,occurred_at,continuity_status,gap_code,payload,source_ref,created_at")
    .eq("sh_id", identity.sh_id)
    .order("occurred_at", { ascending: false })
    .limit(journeyLimit);
  if (journeyError) return json({ error: "JOURNEY_RETRIEVAL_FAILED" }, 403);

  return json({
    sh_id: identity.sh_id,
    account_id: identity.account_id,
    ownership_role: identity.ownership_role,
    query,
    context: context ?? { query, memory: [], knowledge: [] },
    journey: journey ?? [],
    bounds: { memory_limit: memoryLimit, knowledge_limit: knowledgeLimit, journey_limit: journeyLimit },
  });
});
