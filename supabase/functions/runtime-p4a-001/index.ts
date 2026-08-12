import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = { "Content-Type": "application/json" };

type Identity = {
  account_id: string;
  sh_id: string;
  ownership_role: string;
};

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "METHOD_NOT_ALLOWED" }), { status: 405, headers: corsHeaders });
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return new Response(JSON.stringify({ error: "RUNTIME_REJECTED: authenticated identity is required" }), { status: 401, headers: corsHeaders });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!supabaseUrl || !supabaseAnonKey) {
    return new Response(JSON.stringify({ error: "RUNTIME_CONFIGURATION_ERROR" }), { status: 500, headers: corsHeaders });
  }

  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) {
    return new Response(JSON.stringify({ error: "RUNTIME_REJECTED: authenticated identity is required" }), { status: 401, headers: corsHeaders });
  }

  let body: { user_message?: string };
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "RUNTIME_REJECTED: invalid JSON" }), { status: 400, headers: corsHeaders });
  }

  const userMessage = body.user_message?.trim();
  if (!userMessage) {
    return new Response(JSON.stringify({ error: "RUNTIME_REJECTED: user_message is required" }), { status: 400, headers: corsHeaders });
  }

  const { data: identities, error: identityError } = await supabase.rpc("resolve_identity");
  if (identityError) {
    return new Response(JSON.stringify({ error: "RUNTIME_IDENTITY_RESOLUTION_FAILED" }), { status: 403, headers: corsHeaders });
  }

  const rows = (identities ?? []) as Identity[];
  if (rows.length !== 1) {
    return new Response(JSON.stringify({ error: "RUNTIME_REJECTED: SH identity could not be resolved" }), { status: 403, headers: corsHeaders });
  }

  const identity = rows[0];

  // P4A-001 minimal realization: context assembly is read-only.
  const context = { identity, user_message: userMessage, entries: [] as readonly unknown[] };

  // Model Adapter placeholder: provider is intentionally not coupled to SH identity.
  const modelResponse = { output: userMessage, provider: "mock" };

  // Memory decision remains a post-response boundary. No write is performed by P4A-001.
  return new Response(JSON.stringify({
    sh_id: identity.sh_id,
    response: modelResponse.output,
    meta: { phase: "P4A-001", model_provider: modelResponse.provider, context_entries: context.entries.length, memory_decision: "deferred" },
  }), { status: 200, headers: corsHeaders });
});
