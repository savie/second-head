import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const MAX_MESSAGE_LENGTH = 20_000;

type FailureCode =
  | "INVALID_REQUEST"
  | "UNAUTHENTICATED"
  | "IDENTITY_NOT_RESOLVED"
  | "DEPENDENCY_FAILURE"
  | "INTERNAL_ERROR";

function requestId(): string {
  return crypto.randomUUID();
}

function failure(id: string, code: FailureCode, status: number) {
  return new Response(
    JSON.stringify({
      ok: false,
      request_id: id,
      code,
      retryable: code === "DEPENDENCY_FAILURE" || code === "INTERNAL_ERROR",
    }),
    { status, headers: { "Content-Type": "application/json" } },
  );
}

Deno.serve(async (req: Request) => {
  const id = requestId();

  if (req.method !== "POST") return failure(id, "INVALID_REQUEST", 405);

  const auth = req.headers.get("authorization");
  if (!auth?.startsWith("Bearer ")) return failure(id, "UNAUTHENTICATED", 401);

  try {
    const body = await req.json();
    const message = typeof body?.user_message === "string"
      ? body.user_message.trim()
      : "";

    if (!message || message.length > MAX_MESSAGE_LENGTH) {
      return failure(id, "INVALID_REQUEST", 400);
    }

    // P4A-006 is a boundary component only. Identity resolution,
    // model execution, memory writes, and tool/action execution remain
    // owned by their respective runtime components.
    return new Response(
      JSON.stringify({
        ok: true,
        request_id: id,
        accepted: true,
        user_message_length: message.length,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch {
    return failure(id, "INVALID_REQUEST", 400);
  }
});
