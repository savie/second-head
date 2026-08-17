import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { createJourneyRuntimeDecisionSink, type JourneyEventRecorder } from "../../../runtime/p5a/journey_decision.ts";
import { createMemoryJourneySignalDetector } from "../../../runtime/p5a/memory_journey_signal.ts";
import { createSemanticJourneySignalDetector } from "../../../runtime/p5a/semantic_journey_signal.ts";
import { createModelExecutor, type ModelAdapter } from "../../../runtime/p4d/model_abstraction.ts";
import { selectModel, type ModelCandidate } from "../../../runtime/p4d/model_selection.ts";
import { createOpenRouterFreeAdapter } from "../../../runtime/p4d/openrouter_free_adapter.ts";

type JourneyDecisionSignal = {
  automatic_candidate?: Awaited<ReturnType<ReturnType<typeof createMemoryJourneySignalDetector>["detect"]>>["automatic_candidate"];
};

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

function createZeroBudgetModelExecutor() {
  const adapter: ModelAdapter = createOpenRouterFreeAdapter();
  const candidate: ModelCandidate = {
    id: "openrouter/free",
    capability: "text",
    cost_tier: "ZERO_BUDGET",
    adapter,
  };
  const selected = selectModel([candidate], { capability: "text", require_zero_budget: true });
  return {
    executor: createModelExecutor(selected.adapter),
    model_id: selected.model_id,
    cost_tier: selected.cost_tier,
  };
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return new Response(JSON.stringify({ error: "METHOD_NOT_ALLOWED" }), { status: 405, headers: jsonHeaders });

  const resolved = await resolveIdentity(req);
  if (resolved.error) return resolved.error;

  let body: {
    user_message?: string;
    stream?: boolean;
    journey_only?: boolean;
    explicit_journey_capture?: boolean;
    journey_representation?: string;
  };
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "RUNTIME_REJECTED: invalid JSON" }), { status: 400, headers: jsonHeaders });
  }

  const identity = resolved.identity;
  const supabase = resolved.supabase;

  if (body.journey_only === true) {
    if (body.explicit_journey_capture !== true) {
      return new Response(JSON.stringify({ error: "JOURNEY_REJECTED: explicit capture is required" }), { status: 400, headers: jsonHeaders });
    }

    const representation = body.journey_representation?.trim();
    if (!representation) {
      return new Response(JSON.stringify({ error: "JOURNEY_REJECTED: representation is required" }), { status: 400, headers: jsonHeaders });
    }

    try {
      const journeyDecision = createJourneyRuntimeDecisionSink(
        { async detect() { return {}; } },
        createJourneyRecorder(supabase),
      );

      const decision = await journeyDecision.decideAndRecord({
        sh_id: identity.sh_id,
        user_message: representation,
        response: null,
        explicit_intent: {
          requested: true,
          candidate: {
            event_type: "EXPERIENCE",
            continuity_status: "CONTINUOUS",
            payload: { representation, capture_mode: "EXPLICIT_USER" },
            source_ref: "runtime:p5a:explicit_user_capture",
          },
        },
      });

      await recordAudit(supabase, identity.sh_id, "RUNTIME_REQUEST", { journey_only: true, explicit_journey_capture: true });
      await recordAudit(supabase, identity.sh_id, "RUNTIME_RESPONSE", { journey_only: true, journey_decision: decision.reason });

      return new Response(JSON.stringify({ sh_id: identity.sh_id, journey_decision: decision.reason, event_id: decision.candidate ? "recorded" : null }), { status: 200, headers: jsonHeaders });
    } catch (error) {
      const message = error instanceof Error ? error.message : "JOURNEY_CAPTURE_FAILED";
      return new Response(JSON.stringify({ error: message }), { status: 500, headers: jsonHeaders });
    }
  }

  const userMessage = body.user_message?.trim();
  if (!userMessage) return new Response(JSON.stringify({ error: "RUNTIME_REJECTED: user_message is required" }), { status: 400, headers: jsonHeaders });

  let modelResponse: Awaited<ReturnType<ReturnType<typeof createZeroBudgetModelExecutor>["executor"]["execute"]>>;
  let modelId = "openrouter/free";

  try {
    await recordAudit(supabase, identity.sh_id, "RUNTIME_REQUEST", {
      stream: body.stream === true,
      user_message_length: userMessage.length,
      model_policy: "ZERO_BUDGET",
    });

    const model = createZeroBudgetModelExecutor();
    modelId = model.model_id;
    modelResponse = await model.executor.execute({
      capability: "text",
      context: {
        user_message: userMessage,
      },
    });

    const output = typeof modelResponse.output === "string"
      ? modelResponse.output
      : JSON.stringify(modelResponse.output);

    await recordConversation(supabase, identity.sh_id, "user", userMessage);
    await recordConversation(supabase, identity.sh_id, "assistant", output);

    const memoryDetector = createMemoryJourneySignalDetector();
    const semanticDetector = createSemanticJourneySignalDetector();
    const journeyDecision = createJourneyRuntimeDecisionSink(
      {
        async detect(input) {
          const semantic = await semanticDetector.detect(input);
          if (semantic.automatic_candidate) return semantic;
          return memoryDetector.detect(input);
        },
      },
      createJourneyRecorder(supabase),
    );

    const decision = await journeyDecision.decideAndRecord({
      sh_id: identity.sh_id,
      user_message: userMessage,
      response: modelResponse.output,
      explicit_intent: body.explicit_journey_capture === true
        ? {
            requested: true,
            candidate: {
              event_type: "EXPERIENCE",
              continuity_status: "CONTINUOUS",
              payload: { representation: userMessage, capture_mode: "EXPLICIT_USER" },
              source_ref: "runtime:p5a:explicit_user_capture",
            },
          }
        : null,
    });

    await recordAudit(supabase, identity.sh_id, "RUNTIME_RESPONSE", {
      stream: body.stream === true,
      response_length: output.length,
      journey_decision: decision.reason,
      model_provider: "openrouter",
      model_id: modelId,
      cost_tier: "ZERO_BUDGET",
      semantic_signals_present: modelResponse.semantic_signals !== undefined,
    });

    if (!body.stream) {
      return new Response(JSON.stringify({
        sh_id: identity.sh_id,
        response: output,
        meta: {
          phase: "P4A-001",
          model_provider: "openrouter",
          model_id: modelId,
          cost_tier: "ZERO_BUDGET",
          context_entries: 0,
          memory_decision: "deferred",
          journey_decision: decision.reason,
          semantic_signals: modelResponse.semantic_signals ?? null,
          persistence: "verified-path",
          audit: "verified-path",
        },
      }), { status: 200, headers: jsonHeaders });
    }

    const encoder = new TextEncoder();
    const chunks = output.match(/.{1,12}/g) ?? [output];
    const stream = new ReadableStream<Uint8Array>({
      async start(controller) {
        const send = (event: string, payload: unknown) => {
          controller.enqueue(encoder.encode(`event: ${event}\ndata: ${JSON.stringify(payload)}\n\n`));
        };
        send("response", {
          sh_id: identity.sh_id,
          text: "",
          meta: {
            phase: "P4A-001",
            model_provider: "openrouter",
            model_id: modelId,
            cost_tier: "ZERO_BUDGET",
            context_entries: 0,
            memory_decision: "deferred",
            journey_decision: decision.reason,
            streaming: true,
            persistence: "verified-path",
            audit: "verified-path",
          },
        });
        for (const chunk of chunks) {
          send("token", { text: chunk });
          await new Promise((resolve) => setTimeout(resolve, 20));
        }
        send("complete", { sh_id: identity.sh_id });
        controller.close();
      },
    });

    return new Response(stream, { status: 200, headers: streamHeaders });
  } catch (error) {
    const message = error instanceof Error ? error.message : "RUNTIME_MODEL_EXECUTION_FAILED";
    try {
      await recordAudit(supabase, identity.sh_id, "RUNTIME_RESPONSE", {
        status: "FAILED",
        model_provider: "openrouter",
        model_id: modelId,
        error: message,
      });
    } catch {
      // Preserve the original runtime failure when audit persistence also fails.
    }
    return new Response(JSON.stringify({ error: message }), { status: 502, headers: jsonHeaders });
  }
});
