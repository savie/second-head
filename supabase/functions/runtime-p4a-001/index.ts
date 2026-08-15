import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { createJourneyRuntimeDecisionSink, type JourneyEventRecorder } from "../../../runtime/p5a/journey_decision.ts";
import { createMemoryJourneySignalDetector } from "../../../runtime/p5a/memory_journey_signal.ts";

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

  return { identity: rows[0], supabase };
}

async function recordConversation(
  supabase: ReturnType<typeof createClient>,
  shId: string,
  role: "user" | "assistant",
  content: string,
) {
  const { error } = await supabase.rpc("runtime_record_conversation", {
    p_sh_id: shId,
    p_role: role,
    p_content: content,
    p_metadata: {
      source: "runtime-p4a-001",
      persistence: "P4A-005",
    },
  });

  if (error) throw new Error(`RUNTIME_CONVERSATION_PERSIST_FAILED: ${error.message}`);
}

async function recordAudit(
  supabase: ReturnType<typeof createClient>,
  shId: string,
  eventType: "RUNTIME_REQUEST" | "RUNTIME_RESPONSE",
  metadata: Record<string, unknown>,
) {
  const { error } = await supabase.rpc("runtime_record_audit", {
    p_sh_id: shId,
    p_event_type: eventType,
    p_status: "SUCCESS",
    p_metadata: {
      source: "runtime-p4a-001",
      ...metadata,
    },
  });

  if (error) throw new Error(`RUNTIME_AUDIT_PERSIST_FAILED: ${error.message}`);
}

function createJourneyRecorder(supabase: ReturnType<typeof createClient>): JourneyEventRecorder {
  return {
    async record(input) {
      const { data, error } = await supabase.rpc("runtime_record_journey_event", {
        p_sh_id: input.sh_id,
        p_event_type: input.event_type,
        p_occurred_at: input.occurred_at ?? null,
        p_continuity_status: input.continuity_status ?? null,
        p_gap_code: input.gap_code ?? null,
        p_payload: input.payload,
        p_source_ref: input.source_ref ?? null,
      });

      if (error) throw new Error(`JOURNEY_RECORD_FAILED: ${error.message}`);
      if (typeof data !== "string") throw new Error("JOURNEY_RECORD_FAILED: recorder returned no event id");
      return data;
    },
  };
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return new Response(JSON.stringify({ error: "METHOD_NOT_ALLOWED" }), { status: 405, headers: jsonHeaders });

  const resolved = await resolveIdentity(req);
  if (resolved.error) return resolved.error;

  let body: { user_message?: string; stream?: boolean; response?: unknown };
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "RUNTIME_REJECTED: invalid JSON" }), { status: 400, headers: jsonHeaders });
  }

  const userMessage = body.user_message?.trim();
  if (!userMessage) return new Response(JSON.stringify({ error: "RUNTIME_REJECTED: user_message is required" }), { status: 400, headers: jsonHeaders });

  const identity = resolved.identity;
  const supabase = resolved.supabase;
  const output: unknown = body.response ?? userMessage;
  const responseText = typeof output === "string" ? output : JSON.stringify(output);

  try {
    await recordAudit(supabase, identity.sh_id, "RUNTIME_REQUEST", {
      stream: body.stream === true,
      user_message_length: userMessage.length,
    });
    await recordConversation(supabase, identity.sh_id, "user", userMessage);
    await recordConversation(supabase, identity.sh_id, "assistant", responseText);

    const journeyDecision = createJourneyRuntimeDecisionSink(
      createMemoryJourneySignalDetector(),
      createJourneyRecorder(supabase),
    );
    await journeyDecision.decideAndRecord({
      sh_id: identity.sh_id,
      user_message: userMessage,
      response: output,
    });

    await recordAudit(supabase, identity.sh_id, "RUNTIME_RESPONSE", {
      stream: body.stream === true,
      response_length: responseText.length,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "RUNTIME_PERSISTENCE_FAILED";
    return new Response(JSON.stringify({ error: message }), { status: 500, headers: jsonHeaders });
  }

  if (!body.stream) {
    return new Response(JSON.stringify({
      sh_id: identity.sh_id,
      response: responseText,
      meta: { phase: "P4A-001", model_provider: "mock", context_entries: 0, memory_decision: "deferred", journey_decision: "post-response", persistence: "verified-path", audit: "verified-path" },
    }), { status: 200, headers: jsonHeaders });
  }

  const encoder = new TextEncoder();
  const chunks = responseText.match(/.{1,12}/g) ?? [responseText];
  const stream = new ReadableStream<Uint8Array>({
    async start(controller) {
      const send = (event: string, payload: unknown) => {
        controller.enqueue(encoder.encode(`event: ${event}\ndata: ${JSON.stringify(payload)}\n\n`));
      };
      send("response", { sh_id: identity.sh_id, text: "", meta: { phase: "P4A-001", model_provider: "mock", context_entries: 0, memory_decision: "deferred", journey_decision: "post-response", streaming: true, persistence: "verified-path", audit: "verified-path" } });
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
