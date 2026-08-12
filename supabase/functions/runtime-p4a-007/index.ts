import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const MAX_MESSAGE_LENGTH = 20_000;

type Stage = "IDENTITY" | "CONTEXT" | "MODEL";

function requestId(): string {
  return crypto.randomUUID();
}

function fail(id: string, code: string, status: number, stage?: Stage) {
  return new Response(JSON.stringify({
    ok: false,
    request_id: id,
    code,
    failure_stage: stage,
  }), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

Deno.serve(async (req: Request) => {
  const id = requestId();

  if (req.method !== "POST") return fail(id, "INVALID_REQUEST", 405);
  if (!req.headers.get("authorization")?.startsWith("Bearer ")) {
    return fail(id, "UNAUTHENTICATED", 401);
  }

  try {
    const body = await req.json();
    const message = typeof body?.user_message === "string"
      ? body.user_message.trim()
      : "";

    if (!message || message.length > MAX_MESSAGE_LENGTH) {
      return fail(id, "INVALID_REQUEST", 400);
    }

    // P4A-007 defines the orchestration envelope only. It does not create
    // identity, mutate context, select a provider, execute tools/actions,
    // or persist memory. Those authorities remain in their own boundaries.
    const stages = [
      { stage: "IDENTITY" as Stage, ok: true },
      { stage: "CONTEXT" as Stage, ok: true },
      { stage: "MODEL" as Stage, ok: true },
    ];

    return new Response(JSON.stringify({
      ok: true,
      request_id: id,
      stages,
      accepted: true,
      user_message_length: message.length,
    }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch {
    return fail(id, "INVALID_REQUEST", 400);
  }
});
