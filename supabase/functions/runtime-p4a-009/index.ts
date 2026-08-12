import "jsr:@supabase/functions-js/edge-runtime.d.ts";

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ ok: false, error: "METHOD_NOT_ALLOWED" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  const body = await req.json().catch(() => null);
  if (!body?.request_id || !body?.sh_id) {
    return new Response(JSON.stringify({ ok: false, error: "INVALID_RUNTIME_RESPONSE_CONTEXT" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  return new Response(
    JSON.stringify({
      ok: true,
      request_id: body.request_id,
      sh_id: body.sh_id,
      response: body.response ?? null,
    }),
    { headers: { "Content-Type": "application/json" } },
  );
});
