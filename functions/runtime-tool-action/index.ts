import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type ToolRisk = "READ_ONLY" | "LOW";
type ToolDefinition = {
  id: string;
  version: string;
  description: string;
  risk: ToolRisk;
  requires_confirmation: boolean;
};

type Identity = { account_id: string; sh_id: string; ownership_role: string };

const headers = { "Content-Type": "application/json" };

const TOOLS: Record<string, ToolDefinition> = {
  R8_SEARCH_YOUTUBE: {
    id: "R8_SEARCH_YOUTUBE",
    version: "1",
    description: "Read-only YouTube search through the approved MCP boundary.",
    risk: "READ_ONLY",
    requires_confirmation: false,
  },
  R8_GET_YOUTUBE_VIDEO: {
    id: "R8_GET_YOUTUBE_VIDEO",
    version: "1",
    description: "Read-only YouTube video retrieval through the approved MCP boundary.",
    risk: "READ_ONLY",
    requires_confirmation: false,
  },
  R6_CREATE_TASK: {
    id: "R6_CREATE_TASK",
    version: "1",
    description: "Create an owner task/reminder through the existing R6 persistence boundary.",
    risk: "LOW",
    requires_confirmation: true,
  },
};

async function resolveIdentity(req: Request) {
  const authorization = req.headers.get("Authorization");
  if (!authorization) {
    return { error: new Response(JSON.stringify({ error: "TOOL_UNAUTHENTICATED" }), { status: 401, headers }) };
  }
  const url = Deno.env.get("SUPABASE_URL");
  const key = Deno.env.get("SUPABASE_ANON_KEY");
  if (!url || !key) {
    return { error: new Response(JSON.stringify({ error: "TOOL_CONFIGURATION_ERROR" }), { status: 500, headers }) };
  }
  const supabase = createClient(url, key, { global: { headers: { Authorization: authorization } } });
  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) {
    return { error: new Response(JSON.stringify({ error: "TOOL_UNAUTHENTICATED" }), { status: 401, headers }) };
  }
  const { data, error } = await supabase.rpc("resolve_identity");
  if (error) {
    return { error: new Response(JSON.stringify({ error: "TOOL_IDENTITY_RESOLUTION_FAILED" }), { status: 403, headers }) };
  }
  const rows = (data ?? []) as Identity[];
  if (rows.length !== 1) {
    return { error: new Response(JSON.stringify({ error: "TOOL_IDENTITY_UNRESOLVED" }), { status: 403, headers }) };
  }
  return { identity: rows[0], supabase };
}

async function audit(supabase: ReturnType<typeof createClient>, shId: string, type: "RUNTIME_REQUEST" | "RUNTIME_RESPONSE", metadata: Record<string, unknown>) {
  const { error } = await supabase.rpc("runtime_record_audit", {
    p_sh_id: shId,
    p_event_type: type,
    p_status: metadata.status ?? "SUCCESS",
    p_metadata: { source: "runtime-tool-action", ...metadata },
  });
  if (error) throw new Error(`TOOL_AUDIT_FAILED: ${error.message}`);
}

function normalizedError(code: string, message: string, actionId?: string) {
  return { status: "FAILED", tool_id: code, action_id: actionId ?? null, error: { code, message } };
}

async function callYoutube(endpoint: string, operation: string, args: Record<string, unknown>, authorization: string) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 10000);
  try {
    const requestHeaders: Record<string, string> = {
      "Content-Type": "application/json",
      "Accept": "application/json, text/event-stream",
      "MCP-Protocol-Version": "2025-11-25",
      Authorization: authorization,
    };
    const init = await fetch(endpoint, {
      method: "POST",
      headers: requestHeaders,
      body: JSON.stringify({
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: { protocolVersion: "2025-11-25", capabilities: {}, clientInfo: { name: "second-head-tool-action", version: "1" } },
      }),
      signal: controller.signal,
    });
    if (!init.ok) throw new Error(`MCP_INITIALIZE_HTTP_${init.status}`);
    const initBody = await init.json();
    if (initBody.error) throw new Error("MCP_INITIALIZE_FAILED");

    const toolName = operation === "R8_SEARCH_YOUTUBE" ? "youtube_search" : "youtube_get_video";
    const call = await fetch(endpoint, {
      method: "POST",
      headers: requestHeaders,
      body: JSON.stringify({ jsonrpc: "2.0", id: 2, method: "tools/call", params: { name: toolName, arguments: args } }),
      signal: controller.signal,
    });
    if (!call.ok) throw new Error(`MCP_CALL_HTTP_${call.status}`);
    const body = await call.json();
    if (body.error) throw new Error("MCP_CALL_FAILED");
    if (body.result?.isError === true) throw new Error(body.result?.content?.[0]?.text || "YOUTUBE_PROVIDER_ERROR");
    return body.result?.structuredContent ?? {};
  } finally {
    clearTimeout(timer);
  }
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return new Response(JSON.stringify({ error: "METHOD_NOT_ALLOWED" }), { status: 405, headers });
  const resolved = await resolveIdentity(req);
  if (resolved.error) return resolved.error;

  const { identity, supabase } = resolved;
  let body: { tool_id?: string; arguments?: Record<string, unknown>; confirmed?: boolean; idempotency_key?: string };
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "TOOL_INVALID_JSON" }), { status: 400, headers });
  }

  const toolId = body.tool_id?.trim().toUpperCase() ?? "";
  const tool = TOOLS[toolId];
  if (!tool) return new Response(JSON.stringify({ error: "TOOL_NOT_FOUND", tool_id: toolId }), { status: 404, headers });

  const actionId = crypto.randomUUID();
  const args = body.arguments ?? {};

  if (tool.requires_confirmation && body.confirmed !== true) {
    return new Response(JSON.stringify({
      status: "AWAITING_CONFIRMATION",
      tool: { ...tool },
      action: { action_id: actionId, status: "AWAITING_CONFIRMATION", arguments: args },
    }), { status: 200, headers });
  }

  try {
    await audit(supabase, identity.sh_id, "RUNTIME_REQUEST", {
      tool_id: tool.id,
      tool_version: tool.version,
      action_id: actionId,
      risk: tool.risk,
      authorization: "OWNER_AUTHENTICATED",
      confirmed: body.confirmed === true,
      idempotency_key: body.idempotency_key ?? null,
    });

    let output: Record<string, unknown>;
    if (toolId === "R6_CREATE_TASK") {
      const title = typeof args.title === "string" ? args.title.trim() : "";
      const dueAt = typeof args.due_at === "string" ? args.due_at.trim() : "";
      const parsed = Date.parse(dueAt);
      if (!title || !Number.isFinite(parsed) || parsed <= Date.now()) {
        throw new Error("R6_TASK_REJECTED: title and future ISO due time are required");
      }
      const { data: taskId, error } = await supabase.rpc("r6_create_task", {
        p_title: title,
        p_due_at: new Date(parsed).toISOString(),
      });
      if (error) throw new Error(`R6_TASK_FAILED: ${error.message}`);
      output = { task_id: taskId, title, due_at: new Date(parsed).toISOString(), status: "OPEN" };
    } else {
      const endpoint = Deno.env.get("R8_YOUTUBE_MCP_ENDPOINT");
      if (!endpoint) throw new Error("R8_MCP_CONFIGURATION_ERROR");
      if (toolId === "R8_SEARCH_YOUTUBE") {
        const query = typeof args.query === "string" ? args.query.trim() : "";
        if (!query) throw new Error("R8_INVALID_ARGUMENTS: query is required");
        output = await callYoutube(endpoint, toolId, { query, max_results: 5 }, req.headers.get("Authorization")!);
      } else {
        const videoId = typeof args.video_id === "string" ? args.video_id.trim() : "";
        if (!videoId) throw new Error("R8_INVALID_ARGUMENTS: video_id is required");
        output = await callYoutube(endpoint, toolId, { video_id: videoId }, req.headers.get("Authorization")!);
      }
    }

    await audit(supabase, identity.sh_id, "RUNTIME_RESPONSE", {
      status: "SUCCESS",
      tool_id: tool.id,
      tool_version: tool.version,
      action_id: actionId,
      risk: tool.risk,
      result_boundary: "NORMALIZED",
    });

    return new Response(JSON.stringify({
      status: "SUCCEEDED",
      tool: { ...tool },
      action: { action_id: actionId, status: "SUCCEEDED" },
      result: { output, audit_recorded: true },
    }), { status: 200, headers });
  } catch (error) {
    const message = error instanceof Error ? error.message : "TOOL_EXECUTION_FAILED";
    try {
      await audit(supabase, identity.sh_id, "RUNTIME_RESPONSE", {
        status: "FAILED",
        tool_id: tool.id,
        tool_version: tool.version,
        action_id: actionId,
        risk: tool.risk,
        error_code: message.split(":")[0],
      });
    } catch {
      // Preserve the primary execution error if audit itself fails.
    }
    return new Response(JSON.stringify({
      ...normalizedError(message.split(":")[0], message, actionId),
      tool: { ...tool },
      audit_recorded: true,
    }), { status: 502, headers });
  }
});
