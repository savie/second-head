import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const jsonHeaders = { "Content-Type": "application/json" };
const PROJECT_URL = Deno.env.get("SUPABASE_URL") ?? "";
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const GOOGLE_CLIENT_ID = Deno.env.get("R4_GOOGLE_CLIENT_ID") ?? "";
const GOOGLE_CLIENT_SECRET = Deno.env.get("R4_GOOGLE_CLIENT_SECRET") ?? "";
const GOOGLE_REDIRECT_URI = Deno.env.get("R4_GOOGLE_REDIRECT_URI") ?? "";
const APP_CALLBACK_URI = "secondhead://authorization?provider=google";

const CALENDAR_SCOPE = "https://www.googleapis.com/auth/calendar.events.owned";

function adminClient() {
  if (!PROJECT_URL || !SERVICE_ROLE_KEY) throw new Error("R4_CONFIGURATION_ERROR");
  return createClient(PROJECT_URL, SERVICE_ROLE_KEY);
}

async function resolveOwner(req: Request) {
  if (!ANON_KEY || !PROJECT_URL) throw new Error("R4_CONFIGURATION_ERROR");
  const authorization = req.headers.get("Authorization");
  if (!authorization) throw new Error("R4_AUTHENTICATION_REQUIRED");
  const userClient = createClient(PROJECT_URL, ANON_KEY, {
    global: { headers: { Authorization: authorization } },
  });
  const { data: userData, error: userError } = await userClient.auth.getUser();
  if (userError || !userData.user) throw new Error("R4_AUTHENTICATION_REQUIRED");
  const { data, error } = await userClient.rpc("resolve_identity");
  if (error) throw new Error("R4_IDENTITY_RESOLUTION_FAILED");
  const rows = Array.isArray(data) ? data as { account_id: string; sh_id: string; ownership_role: string }[] : [];
  if (rows.length !== 1) throw new Error("R4_SH_IDENTITY_REQUIRED");
  return { userClient, userId: userData.user.id, ...rows[0] };
}

function base64Url(bytes: Uint8Array) {
  let binary = "";
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
}

async function hashState(state: string) {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(state));
  return base64Url(new Uint8Array(digest));
}

function redirectToApp(params: Record<string, string>) {
  const query = new URLSearchParams(params);
  return Response.redirect(`${APP_CALLBACK_URI}&${query.toString()}`, 302);
}

async function start(req: Request) {
  if (!GOOGLE_CLIENT_ID || !GOOGLE_REDIRECT_URI) throw new Error("R4_GOOGLE_CONFIGURATION_REQUIRED");
  const owner = await resolveOwner(req);
  const admin = adminClient();
  await admin.rpc("r4_google_oauth_cleanup");

  const random = new Uint8Array(32);
  crypto.getRandomValues(random);
  const state = base64Url(random);
  const stateHash = await hashState(state);

  const { error: stateError } = await admin.from("r4_google_oauth_states").insert({
    state_hash: stateHash,
    account_id: owner.account_id,
    sh_id: owner.sh_id,
    expires_at: new Date(Date.now() + 10 * 60 * 1000).toISOString(),
  });
  if (stateError) throw new Error(`R4_OAUTH_STATE_CREATE_FAILED: ${stateError.message}`);

  const params = new URLSearchParams({
    client_id: GOOGLE_CLIENT_ID,
    redirect_uri: GOOGLE_REDIRECT_URI,
    response_type: "code",
    access_type: "offline",
    prompt: "consent",
    include_granted_scopes: "true",
    scope: CALENDAR_SCOPE,
    state,
  });

  return new Response(JSON.stringify({
    ok: true,
    provider: "GOOGLE",
    target: "GOOGLE_PRIMARY_CALENDAR",
    authorization_url: `https://accounts.google.com/o/oauth2/v2/auth?${params.toString()}`,
    expires_in_seconds: 600,
  }), { status: 200, headers: jsonHeaders });
}

async function callback(url: URL) {
  const error = url.searchParams.get("error");
  if (error) return redirectToApp({ status: "error", code: "GOOGLE_OAUTH_DENIED", detail: error });

  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");
  if (!code || !state) return redirectToApp({ status: "error", code: "GOOGLE_OAUTH_INVALID_CALLBACK" });
  if (!GOOGLE_CLIENT_ID || !GOOGLE_CLIENT_SECRET || !GOOGLE_REDIRECT_URI) {
    return redirectToApp({ status: "error", code: "R4_GOOGLE_CONFIGURATION_REQUIRED" });
  }

  const admin = adminClient();
  const stateHash = await hashState(state);
  const { data: stateRow, error: stateError } = await admin
    .from("r4_google_oauth_states")
    .select("state_hash,account_id,sh_id,expires_at,consumed_at")
    .eq("state_hash", stateHash)
    .maybeSingle();

  if (stateError || !stateRow) return redirectToApp({ status: "error", code: "R4_OAUTH_STATE_INVALID" });
  if (stateRow.consumed_at || new Date(stateRow.expires_at).getTime() <= Date.now()) {
    return redirectToApp({ status: "error", code: "R4_OAUTH_STATE_EXPIRED" });
  }

  await admin.from("r4_google_oauth_states")
    .update({ consumed_at: new Date().toISOString() })
    .eq("state_hash", stateHash)
    .is("consumed_at", null);

  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      code,
      client_id: GOOGLE_CLIENT_ID,
      client_secret: GOOGLE_CLIENT_SECRET,
      redirect_uri: GOOGLE_REDIRECT_URI,
      grant_type: "authorization_code",
    }),
  });

  const tokenBody = await tokenResponse.json().catch(() => ({}));
  if (!tokenResponse.ok) {
    await admin.from("r4_google_connections").upsert({
      account_id: stateRow.account_id,
      sh_id: stateRow.sh_id,
      provider: "GOOGLE",
      target_type: "GOOGLE_PRIMARY_CALENDAR",
      target_id: "primary",
      scopes: [],
      status: "ERROR",
      vault_secret_name: `r4_google_refresh_${stateRow.account_id}`,
      updated_at: new Date().toISOString(),
    }, { onConflict: "account_id,provider" });
    return redirectToApp({ status: "error", code: "GOOGLE_TOKEN_EXCHANGE_FAILED" });
  }

  const grantedScopes = typeof tokenBody.scope === "string"
    ? tokenBody.scope.split(" ").filter(Boolean)
    : [];
  if (!grantedScopes.includes(CALENDAR_SCOPE)) {
    return redirectToApp({ status: "error", code: "GOOGLE_CALENDAR_SCOPE_NOT_GRANTED" });
  }

  const refreshToken = typeof tokenBody.refresh_token === "string" ? tokenBody.refresh_token : null;
  if (!refreshToken) {
    return redirectToApp({ status: "error", code: "GOOGLE_REFRESH_TOKEN_MISSING" });
  }

  const secretName = `r4_google_refresh_${stateRow.account_id}`;
  const { error: vaultError } = await admin.rpc("r4_vault_store_google_refresh_token", {
    p_secret_name: secretName,
    p_secret: refreshToken,
  });
  if (vaultError) {
    return redirectToApp({ status: "error", code: "R4_CREDENTIAL_STORAGE_FAILED" });
  }

  const now = new Date().toISOString();
  const { error: connectionError } = await admin.from("r4_google_connections").upsert({
    account_id: stateRow.account_id,
    sh_id: stateRow.sh_id,
    provider: "GOOGLE",
    target_type: "GOOGLE_PRIMARY_CALENDAR",
    target_id: "primary",
    scopes: grantedScopes,
    status: "CONNECTED",
    vault_secret_name: secretName,
    connected_at: now,
    revoked_at: null,
    last_verified_at: now,
    updated_at: now,
  }, { onConflict: "account_id,provider" });

  if (connectionError) return redirectToApp({ status: "error", code: "R4_CONNECTION_RECORD_FAILED" });

  try {
    await admin.rpc("runtime_record_audit", {
      p_sh_id: stateRow.sh_id,
      p_event_type: "RUNTIME_RESPONSE",
      p_status: "SUCCESS",
      p_metadata: {
        source: "workstream-e:r4:google-authorization",
        tool_id: "R4",
        capability: "EXTERNAL_CREATE_UPDATE",
        operation: "CONNECT_GOOGLE_CALENDAR",
        target: "GOOGLE_PRIMARY_CALENDAR",
        authorization: "GOOGLE_OAUTH_VERIFIED",
        scopes: grantedScopes,
      },
    });
  } catch (_) {}

  return redirectToApp({ status: "connected", provider: "google" });
}

async function disconnect(req: Request) {
  const owner = await resolveOwner(req);
  const admin = adminClient();
  const { data: connection } = await admin
    .from("r4_google_connections")
    .select("connection_id,sh_id,vault_secret_name,status")
    .eq("account_id", owner.account_id)
    .eq("provider", "GOOGLE")
    .maybeSingle();

  if (!connection) return new Response(JSON.stringify({ ok: true, status: "DISCONNECTED" }), { status: 200, headers: jsonHeaders });

  await admin.rpc("r4_vault_delete_google_refresh_token", {
    p_secret_name: connection.vault_secret_name,
  });

  const { error } = await admin.from("r4_google_connections")
    .update({
      status: "REVOKED",
      revoked_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq("connection_id", connection.connection_id)
    .eq("account_id", owner.account_id);

  if (error) throw new Error("R4_DISCONNECT_FAILED");

  try {
    await admin.rpc("runtime_record_audit", {
      p_sh_id: owner.sh_id,
      p_event_type: "RUNTIME_REQUEST",
      p_status: "SUCCESS",
      p_metadata: {
        source: "workstream-e:r4:google-authorization",
        tool_id: "R4",
        operation: "DISCONNECT_GOOGLE_CALENDAR",
        authorization: "REVOKED",
      },
    });
  } catch (_) {}

  return new Response(JSON.stringify({ ok: true, status: "DISCONNECTED" }), { status: 200, headers: jsonHeaders });
}

Deno.serve(async (req: Request) => {
  try {
    const url = new URL(req.url);
    const action = url.searchParams.get("action") ?? "start";

    if (req.method === "GET" && action === "callback") return await callback(url);
    if (req.method === "POST" && action === "start") return await start(req);
    if (req.method === "POST" && action === "disconnect") return await disconnect(req);

    return new Response(JSON.stringify({ error: "R4_METHOD_NOT_ALLOWED" }), { status: 405, headers: jsonHeaders });
  } catch (error) {
    const message = error instanceof Error ? error.message : "R4_GOOGLE_AUTH_FAILED";
    const status = message.includes("AUTHENTICATION_REQUIRED") || message.includes("IDENTITY_REQUIRED") ? 401 : 500;
    return new Response(JSON.stringify({ error: message }), { status, headers: jsonHeaders });
  }
});
