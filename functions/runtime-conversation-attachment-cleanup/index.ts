import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" };

function legacyServiceRole(authHeader: string | null): boolean {
  if (!authHeader?.startsWith("Bearer ")) return false;
  const parts = authHeader.slice(7).split(".");
  if (parts.length !== 3) return false;
  try {
    const payload = JSON.parse(atob(parts[1].replace(/-/g, "+").replace(/_/g, "/")));
    return payload?.role === "service_role";
  } catch (_) {
    return false;
  }
}

function configuredSecretKeys(): string[] {
  const raw = Deno.env.get("SUPABASE_SECRET_KEYS");
  if (!raw) return [];
  try {
    const parsed = JSON.parse(raw) as Record<string, unknown>;
    return Object.values(parsed).filter((value): value is string => typeof value === "string");
  } catch (_) {
    return [];
  }
}

function isServiceWorker(req: Request): boolean {
  const apiKey = req.headers.get("apikey");
  return legacyServiceRole(req.headers.get("Authorization")) || (!!apiKey && configuredSecretKeys().includes(apiKey));
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return new Response(JSON.stringify({ error: "METHOD_NOT_ALLOWED" }), { status: 405, headers: corsHeaders });

  const authHeader = req.headers.get("Authorization");
  const serviceWorker = isServiceWorker(req);
  if (!authHeader && !req.headers.get("apikey")) {
    return new Response(JSON.stringify({ error: "CONVERSATION_ATTACHMENT_CLEANUP_UNAUTHENTICATED" }), { status: 401, headers: corsHeaders });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? (() => {
    const raw = Deno.env.get("SUPABASE_SECRET_KEYS");
    if (!raw) return null;
    try {
      const keys = JSON.parse(raw) as Record<string, string>;
      return keys.default ?? Object.values(keys)[0] ?? null;
    } catch (_) {
      return null;
    }
  })();
  if (!supabaseUrl || !serviceKey || (!serviceWorker && !anonKey)) {
    return new Response(JSON.stringify({ error: "RUNTIME_CONFIGURATION_ERROR" }), { status: 500, headers: corsHeaders });
  }

  const adminClient = createClient(supabaseUrl, serviceKey);
  const userClient = !serviceWorker
    ? createClient(supabaseUrl, anonKey!, { global: { headers: { Authorization: authHeader! } } })
    : null;

  let userId: string | null = null;
  if (!serviceWorker) {
    const { data: userData, error: userError } = await userClient!.auth.getUser();
    if (userError || !userData.user) return new Response(JSON.stringify({ error: "CONVERSATION_ATTACHMENT_CLEANUP_UNAUTHENTICATED" }), { status: 401, headers: corsHeaders });
    userId = userData.user.id;
  }

  const rpcClient = serviceWorker ? adminClient : userClient!;
  const { data: claimed, error: claimError } = await rpcClient.rpc("runtime_claim_conversation_attachment_cleanup", { p_limit: 25 });
  if (claimError) return new Response(JSON.stringify({ error: claimError.message }), { status: 500, headers: corsHeaders });

  const results: Array<Record<string, unknown>> = [];
  for (const item of claimed ?? []) {
    const cleanupId = item.cleanup_id as string;
    const storageRef = item.storage_ref as string;
    const { error: removeError } = await adminClient.storage.from("second-head-conversation").remove([storageRef]);
    if (removeError) {
      await rpcClient.rpc("runtime_fail_conversation_attachment_cleanup", { p_cleanup_id: cleanupId, p_error: removeError.message });
      results.push({ cleanup_id: cleanupId, status: "FAILED", error: removeError.message });
      continue;
    }
    const { error: completeError } = await rpcClient.rpc("runtime_complete_conversation_attachment_cleanup", { p_cleanup_id: cleanupId });
    if (completeError) {
      results.push({ cleanup_id: cleanupId, status: "STORAGE_REMOVED_DB_FINALIZE_FAILED", error: completeError.message });
      continue;
    }
    results.push({ cleanup_id: cleanupId, status: "COMPLETED" });
  }

  return new Response(JSON.stringify({ ok: true, claimed: (claimed ?? []).length, results, ...(userId ? { user_id: userId } : {}) }), { status: 200, headers: corsHeaders });
});
