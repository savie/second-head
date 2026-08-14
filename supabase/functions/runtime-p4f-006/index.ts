import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "@supabase/supabase-js";

const headers = { "Content-Type": "application/json" };

async function getClient(req: Request) {
  const auth = req.headers.get("Authorization");
  if (!auth) return { error: new Response(JSON.stringify({ error: "HIGH_RISK_REJECTED: authenticated identity is required" }), { status: 401, headers }) };
  const url = Deno.env.get("SUPABASE_URL");
  const key = Deno.env.get("SUPABASE_ANON_KEY");
  if (!url || !key) return { error: new Response(JSON.stringify({ error: "RUNTIME_CONFIGURATION_ERROR" }), { status: 500, headers }) };
  const supabase = createClient(url, key, { global: { headers: { Authorization: auth } } });
  const { data, error } = await supabase.auth.getUser();
  if (error || !data.user) return { error: new Response(JSON.stringify({ error: "HIGH_RISK_REJECTED: authenticated identity is required" }), { status: 401, headers }) };
  return { supabase };
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return new Response(JSON.stringify({ error: "METHOD_NOT_ALLOWED" }), { status: 405, headers });
  const resolved = await getClient(req);
  if (resolved.error) return resolved.error;
  const supabase = resolved.supabase;

  let body: { mode?: string; action_id?: string; operation?: string; target_id?: string; title?: string; description?: string; confirmation_id?: string };
  try { body = await req.json(); } catch { return new Response(JSON.stringify({ error: "HIGH_RISK_REJECTED: invalid JSON" }), { status: 400, headers }); }

  if (body.mode === "prepare") {
    const { data, error } = await supabase.rpc("runtime_create_high_risk_confirmation", {
      p_action_id: body.action_id,
      p_operation: body.operation,
      p_target_id: body.target_id,
      p_title: body.title,
      p_description: body.description,
    });
    if (error) return new Response(JSON.stringify({ error: error.message }), { status: 403, headers });
    return new Response(JSON.stringify({ confirmation_id: data, status: "PENDING" }), { status: 200, headers });
  }

  if (body.mode === "confirm") {
    const { data, error } = await supabase.rpc("runtime_confirm_high_risk_action", { p_confirmation_id: body.confirmation_id });
    if (error) return new Response(JSON.stringify({ error: error.message }), { status: 403, headers });
    return new Response(JSON.stringify({ confirmation_id: data, status: "CONFIRMED" }), { status: 200, headers });
  }

  if (body.mode === "execute") {
    const { data, error } = await supabase.rpc("runtime_execute_high_risk_action", { p_confirmation_id: body.confirmation_id });
    if (error) return new Response(JSON.stringify({ error: error.message }), { status: 403, headers });
    return new Response(JSON.stringify({ confirmation_id: body.confirmation_id, recovery_event_id: data, status: "EXECUTED" }), { status: 200, headers });
  }

  return new Response(JSON.stringify({ error: "HIGH_RISK_REJECTED: mode must be prepare, confirm, or execute" }), { status: 400, headers });
});
