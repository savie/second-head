import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const headers = { "Content-Type": "application/json" };
const CALENDAR_SCOPE = "https://www.googleapis.com/auth/calendar.events.owned";
const ACTION_TTL_MS = 10 * 60 * 1000;

type Identity = { account_id: string; sh_id: string; ownership_role: string };

import { validateCreateEventInput, type CreateEventInput } from "./contract.ts";
import { connectorRegistry } from "../../runtime/p4g/connectors/google_calendar.ts";

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers });
}

function fail(code: string, status: number, extra: Record<string, unknown> = {}) {
  return json({ ok: false, code, ...extra }, status);
}

async function clients(req: Request) {
  const auth = req.headers.get("Authorization");
  if (!auth?.startsWith("Bearer ")) return { error: fail("UNAUTHENTICATED", 401) };

  const url = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !anonKey || !serviceKey) return { error: fail("RUNTIME_CONFIGURATION_ERROR", 500) };

  const userClient = createClient(url, anonKey, { global: { headers: { Authorization: auth } } });
  const admin = createClient(url, serviceKey);

  const { data, error } = await userClient.auth.getUser();
  if (error || !data.user) return { error: fail("UNAUTHENTICATED", 401) };

  const { data: identities, error: identityError } = await userClient.rpc("resolve_identity");
  if (identityError || !identities || identities.length !== 1) {
    return { error: fail("IDENTITY_NOT_RESOLVED", 403) };
  }

  return {
    userClient,
    admin,
    user: data.user,
    identity: (identities as Identity[])[0],
  };
}

function validateInput(value: unknown): value is CreateEventInput {
  if (!value || typeof value !== "object" || Array.isArray(value)) return false;
  const v = value as Record<string, unknown>;
  if (typeof v.summary !== "string" || !v.summary.trim() || v.summary.length > 500) return false;
  if (v.description !== undefined && (typeof v.description !== "string" || v.description.length > 5000)) return false;
  if (v.location !== undefined && (typeof v.location !== "string" || v.location.length > 1000)) return false;
  for (const key of ["start", "end"]) {
    const point = v[key];
    if (!point || typeof point !== "object" || Array.isArray(point)) return false;
    const p = point as Record<string, unknown>;
    if (typeof p.dateTime !== "string" || !p.dateTime.trim()) return false;
    if (p.timeZone !== undefined && typeof p.timeZone !== "string") return false;
    if (Number.isNaN(Date.parse(p.dateTime))) return false;
  }
  const start = new Date((v.start as { dateTime: string }).dateTime).getTime();
  const end = new Date((v.end as { dateTime: string }).dateTime).getTime();
  return end > start;
}

async function sha256(value: unknown): Promise<string> {
  const bytes = new TextEncoder().encode(JSON.stringify(value));
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

async function audit(admin: ReturnType<typeof createClient>, shId: string, status: string, metadata: Record<string, unknown>) {
  try {
    await admin.rpc("runtime_record_audit", {
      p_sh_id: shId,
      p_event_type: "RUNTIME_RESPONSE",
      p_status: status,
      p_metadata: {
        source: "workstream-e:r4:google-calendar-create-event",
        tool_id: "R4",
        capability: "EXTERNAL_CREATE_UPDATE",
        operation: "CREATE_EVENT",
        ...metadata,
      },
    });
  } catch (_) {}
}

async function prepare(req: Request, admin: ReturnType<typeof createClient>, identity: Identity, userId: string, body: Record<string, unknown>) {
  const input = body.input;
  if (!validateInput(input)) return fail("INVALID_CREATE_EVENT_INPUT", 400);

  const { data: connection, error: connectionError } = await admin
    .from("r4_google_connections")
    .select("status,scopes,target_type,target_id")
    .eq("account_id", identity.account_id)
    .eq("provider", "GOOGLE")
    .maybeSingle();

  if (connectionError) return fail("R4_AUTHORIZATION_LOOKUP_FAILED", 500);
  if (!connection || connection.status !== "CONNECTED") return fail("R4_GOOGLE_NOT_CONNECTED", 409);
  if (connection.target_type !== "GOOGLE_PRIMARY_CALENDAR" || connection.target_id !== "primary") {
    return fail("R4_TARGET_NOT_AUTHORIZED", 403);
  }
  if (!Array.isArray(connection.scopes) || !connection.scopes.includes(CALENDAR_SCOPE)) {
    return fail("R4_CALENDAR_SCOPE_NOT_AUTHORIZED", 403);
  }

  const actionId = crypto.randomUUID();
  const confirmationId = crypto.randomUUID();
  const expiresAt = new Date(Date.now() + ACTION_TTL_MS).toISOString();
  const inputHash = await sha256(input);

  const { error } = await admin.from("r4_google_calendar_actions").insert({
    action_id: actionId,
    account_id: identity.account_id,
    sh_id: identity.sh_id,
    actor_id: userId,
    operation: "CREATE_EVENT",
    target_id: "primary",
    risk: "HIGH",
    status: "PENDING",
    confirmation_id: confirmationId,
    confirmation_expires_at: expiresAt,
    input,
    input_hash: inputHash,
  });

  if (error) return fail("R4_ACTION_CREATE_FAILED", 500);
  await audit(admin, identity.sh_id, "SUCCESS", {
    action_id: actionId,
    actor_id: userId,
    authorization: "GOOGLE_CONNECTION_CONNECTED",
    risk: "HIGH",
    confirmation: "PENDING",
    input_hash: inputHash,
  });

  return json({
    ok: true,
    action_id: actionId,
    confirmation_id: confirmationId,
    status: "PENDING",
    expires_at: expiresAt,
    operation: "CREATE_EVENT",
    target: "GOOGLE_PRIMARY_CALENDAR",
    risk: "HIGH",
  });
}

async function confirm(req: Request, admin: ReturnType<typeof createClient>, identity: Identity, body: Record<string, unknown>) {
  const confirmationId = typeof body.confirmation_id === "string" ? body.confirmation_id : "";
  if (!confirmationId) return fail("CONFIRMATION_ID_REQUIRED", 400);

  const { data: action, error } = await admin
    .from("r4_google_calendar_actions")
    .select("action_id,status,confirmation_expires_at,input_hash")
    .eq("confirmation_id", confirmationId)
    .eq("account_id", identity.account_id)
    .maybeSingle();

  if (error || !action) return fail("R4_CONFIRMATION_NOT_FOUND", 404);
  if (action.status !== "PENDING") return fail("R4_CONFIRMATION_NOT_PENDING", 409);
  if (new Date(action.confirmation_expires_at).getTime() <= Date.now()) {
    await admin.from("r4_google_calendar_actions").update({ status: "EXPIRED", updated_at: new Date().toISOString() }).eq("action_id", action.action_id);
    return fail("R4_CONFIRMATION_EXPIRED", 409);
  }

  const { error: updateError } = await admin
    .from("r4_google_calendar_actions")
    .update({ status: "CONFIRMED", confirmed_at: new Date().toISOString(), updated_at: new Date().toISOString() })
    .eq("action_id", action.action_id)
    .eq("status", "PENDING");

  if (updateError) return fail("R4_CONFIRMATION_FAILED", 500);

  await audit(admin, identity.sh_id, "SUCCESS", {
    action_id: action.action_id,
    authorization: "CONFIRMED",
    confirmation: "CONFIRMED",
    input_hash: action.input_hash,
  });

  return json({ ok: true, action_id: action.action_id, confirmation_id: confirmationId, status: "CONFIRMED" });
}

async function refreshAccessToken(admin: ReturnType<typeof createClient>, accountId: string) {
  const { data: connection, error } = await admin
    .from("r4_google_connections")
    .select("vault_secret_name,status,scopes,target_type,target_id")
    .eq("account_id", accountId)
    .eq("provider", "GOOGLE")
    .maybeSingle();

  if (error || !connection) throw new Error("R4_GOOGLE_CONNECTION_NOT_FOUND");
  if (connection.status !== "CONNECTED") throw new Error("R4_GOOGLE_NOT_CONNECTED");
  if (connection.target_type !== "GOOGLE_PRIMARY_CALENDAR" || connection.target_id !== "primary") throw new Error("R4_TARGET_NOT_AUTHORIZED");
  if (!Array.isArray(connection.scopes) || !connection.scopes.includes(CALENDAR_SCOPE)) throw new Error("R4_CALENDAR_SCOPE_NOT_AUTHORIZED");

  const { data: refreshToken, error: vaultError } = await admin.rpc("r4_vault_get_google_refresh_token", {
    p_secret_name: connection.vault_secret_name,
  });
  if (vaultError || typeof refreshToken !== "string" || !refreshToken) throw new Error("R4_GOOGLE_CREDENTIAL_NOT_FOUND");

  const clientId = Deno.env.get("R4_GOOGLE_CLIENT_ID");
  const clientSecret = Deno.env.get("R4_GOOGLE_CLIENT_SECRET");
  if (!clientId || !clientSecret) throw new Error("R4_GOOGLE_CLIENT_CONFIGURATION_MISSING");

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: clientId,
      client_secret: clientSecret,
      refresh_token: refreshToken,
      grant_type: "refresh_token",
    }),
  });

  const body = await response.json().catch(() => ({}));
  if (!response.ok || typeof body.access_token !== "string") {
    throw new Error(response.status === 401 ? "R4_GOOGLE_REFRESH_REJECTED" : "R4_GOOGLE_TOKEN_REFRESH_FAILED");
  }

  return body.access_token as string;
}

async function execute(admin: ReturnType<typeof createClient>, identity: Identity, body: Record<string, unknown>) {
  const confirmationId = typeof body.confirmation_id === "string" ? body.confirmation_id : "";
  if (!confirmationId) return fail("CONFIRMATION_ID_REQUIRED", 400);

  const { data: action, error } = await admin
    .from("r4_google_calendar_actions")
    .select("*")
    .eq("confirmation_id", confirmationId)
    .eq("account_id", identity.account_id)
    .maybeSingle();

  if (error || !action) return fail("R4_ACTION_NOT_FOUND", 404);
  if (action.status !== "CONFIRMED") return fail("R4_ACTION_NOT_CONFIRMED", 409);
  if (new Date(action.confirmation_expires_at).getTime() <= Date.now()) {
    await admin.from("r4_google_calendar_actions").update({ status: "EXPIRED", updated_at: new Date().toISOString() }).eq("action_id", action.action_id);
    return fail("R4_ACTION_EXPIRED", 409);
  }

  const { data: claimed, error: claimError } = await admin
    .from("r4_google_calendar_actions")
    .update({ status: "EXECUTING", updated_at: new Date().toISOString() })
    .eq("action_id", action.action_id)
    .eq("status", "CONFIRMED")
    .select("action_id,input");

  if (claimError || !claimed?.length) return fail("R4_ACTION_ALREADY_EXECUTING_OR_COMPLETE", 409);

  try {
    const accessToken = await refreshAccessToken(admin, identity.account_id);
    const input = action.input as CreateEventInput;

    const eventId = action.action_id.replace(/-/g, "").replace(/[wxyz]/g, "a").toLowerCase();
    const event = {
      id: eventId,
      summary: input.summary.trim(),
      ...(input.description?.trim() ? { description: input.description.trim() } : {}),
      ...(input.location?.trim() ? { location: input.location.trim() } : {}),
      start: input.start,
      end: input.end,
    };

    const connector = connectorRegistry.google_calendar;
    const connectorResult = await connector.createEvent(accessToken, input, eventId);

    if (!connectorResult.result) {
      const code = connectorResult.errorCode ?? "R4_GOOGLE_CREATE_EVENT_FAILED";
      await admin.from("r4_google_calendar_actions").update({
        status: "FAILED",
        error_code: code,
        result: { http_status: connectorResult.httpStatus ?? null },
        updated_at: new Date().toISOString(),
      }).eq("action_id", action.action_id);

      await audit(admin, identity.sh_id, "FAILED", {
        action_id: action.action_id,
        authorization: "CONFIRMED",
        outcome: code,
        http_status: connectorResult.httpStatus ?? null,
      });

      return fail(code, (connectorResult.httpStatus ?? 500) >= 500 ? 502 : 409);
    }

    const result = connectorResult.result;
    await admin.from("r4_google_calendar_actions").update({
      status: "EXECUTED",
      external_event_id: result.event_id,
      external_event_html_link: result.html_link,
      result,
      executed_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    }).eq("action_id", action.action_id);

    await audit(admin, identity.sh_id, "SUCCESS", {
      action_id: action.action_id,
      authorization: "CONFIRMED",
      outcome: "EXECUTED",
      external_event_id: result.event_id,
      connector_id: connector.connector_id,
    });

    return json({
      ok: true,
      action_id: action.action_id,
      status: "EXECUTED",
      result,
      connector_id: connector.connector_id,
    });
  } catch (error) {
    const code = error instanceof Error ? error.message : "R4_GOOGLE_CREATE_EVENT_FAILED";
    await admin.from("r4_google_calendar_actions").update({
      status: "FAILED",
      error_code: code,
      updated_at: new Date().toISOString(),
    }).eq("action_id", action.action_id);

    await audit(admin, identity.sh_id, "FAILED", {
      action_id: action.action_id,
      authorization: "CONFIRMED",
      outcome: code,
    });

    return fail(code, 502);
  }
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return fail("METHOD_NOT_ALLOWED", 405);

  const resolved = await clients(req);
  if (resolved.error) return resolved.error;

  const body = await req.json().catch(() => null);
  if (!body || typeof body !== "object" || Array.isArray(body)) return fail("INVALID_JSON", 400);

  const mode = typeof (body as Record<string, unknown>).mode === "string"
    ? String((body as Record<string, unknown>).mode)
    : "";

  const { admin, identity, user } = resolved as {
    admin: ReturnType<typeof createClient>;
    identity: Identity;
    user: { id: string };
  };

  if (mode === "prepare") return await prepare(req, admin, identity, user.id, body as Record<string, unknown>);
  if (mode === "confirm") return await confirm(req, admin, identity, body as Record<string, unknown>);
  if (mode === "execute") return await execute(admin, identity, body as Record<string, unknown>);

  return fail("INVALID_MODE", 400);
});
