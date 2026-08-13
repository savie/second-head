import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const jsonHeaders = { "Content-Type": "application/json" };
const streamHeaders = {
  "Content-Type": "text/event-stream; charset=utf-8",
  "Cache-Control": "no-cache",
  "Connection": "keep-alive",
};

type Identity = {
  account_id: string;
  sh_id: string;
  ownership_role: string;
};

async function resolveIdentity(req: Request) {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return { error: new Response(JSON.stringify({ error: "RUNTIME_REJECTED: authenticated identity is required" }), { status: 401, headers: jsonHeaders }) };

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!supabaseUrl || !supabaseAnonKey) return { error: new Response(JSON.stringify({ error: "RUNTIME_CONFIGURATION_ERROR" }), { status: 500, headers: jsonHeaders }) };

  const supabase = createClient(supabaseUrl, supabaseAnonKey, { global: { headers: { Authorization: authHeader } } });
  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return { error: new Response(JSON.stringify({ error: "RUNTIME_REJECTED: authenticated identity is required" }), { status: 401, headers: jsonHeaders }) };

  const { data: identities, error: identityError } = await supabase.rpc("resolve_identity");
  if (identityError) return { error: new Response(JSON.stringify({ error: "RUNTIME_IDENTITY_RESOLUTION_FAILED" }), { status: 403, headers: jsonHeaders }) };

  const rows = (identities ?? []) as Identity[];
  if (rows.length !== 1) return { error: new Response(JSON.stringify({ error: "RUNTIME_REJECTED: SH identity could not be resolved" }), { status: 403, headers: jsonHeaders }) };

  return { identity: rows[0] };
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return new Response(JSON.stringify({ error: "METHOD_NOT_ALLOWED" }), { status: 405, headers: jsonHeaders });

  const resolved = await resolveIdentity(req);
  if (resolved.error) return resolved.error;

  let body: { user_message?: string; stream?: boolean };
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "RUNTIME_REJECTED: invalid JSON" }), { status: 400, headers: jsonHeaders });
  }

  const userMessage = body.user_message?.trim();
  if (!userMessage) return new Response(JSON.stringify({ error: "RUNTIME_REJECTED: user_message is required" }), { status: 400, headers: jsonHeaders });

  const identity = resolved.identity;
  const output = userMessage;

  if (!body.stream) {
    return new Response(JSON.stringify({
      sh_id: identity.sh_id,
      response: output,
      meta: { phase: "P4A-001", model_provider: "mock", context_entries: 0, memory_decision: "deferred" },
    }), { status: 200, headers: jsonHeaders });
  }

  const encoder = new TextEncoder();
  const chunks = output.match(/.{1,12}/g) ?? [output];
  const stream = new ReadableStream<Uint8Array>({
    async start(controller) {
      const send = (event: string, payload: unknown) => {
        controller.enqueue(encoder.encode(`event: ${event}\ndata: ${JSON.stringify(payload)}\n\n`));
      };
      send("response", { sh_id: identity.sh_id, text: "", meta: { phase: "P4A-001", model_provider: "mock", streaming: true } });
      for (const chunk of chunks) {
        send("token", { text: chunk });
        await new Promise((resolve) => setTimeout(resolve, 20));
      }
      send("complete", { sh_id: identity.sh_id });
      controller.close();
    },
  });

  return new Response(stream, { status: 200, headers: streamHeaders });
});
