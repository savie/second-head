# WORKSTREAM E — TOOL MCP YOUTUBE

Status: **IMPLEMENTED / CI VERIFICATION PENDING**
Workstream: E — Hands / Tools / Authority
Family: G — Integration & Extension
Representative: **R8**
Branch: `dev`

## 1. Purpose

R8 is the first SH-controlled Model Context Protocol (MCP) integration slice. It demonstrates an external, read-only capability without changing R4 Google Calendar semantics or duplicating Global SH Search.

User-facing intent:

> User asks SH to find a music/video item on YouTube → SH retrieves bounded public YouTube results through MCP → SH returns a YouTube link that the owner can open in the YouTube app/browser.

R8 is an integration capability, not a YouTube account-management feature.

## 2. Scope

### Included

- SH MCP Client boundary;
- SH-controlled YouTube MCP Server;
- Streamable HTTP transport;
- MCP JSON-RPC revision `2025-11-25`;
- deterministic tool discovery;
- `youtube_search`;
- `youtube_get_video`;
- public YouTube Data API access;
- normalized result model;
- YouTube deep link output;
- server-side API-key boundary;
- authenticated runtime → MCP server propagation;
- read-only tool annotations;
- MCP contract tests;
- R8 CI workflow.

### Explicitly excluded

- YouTube OAuth;
- private YouTube account data;
- upload/update/delete/comment/like operations;
- playlist mutation;
- subscriptions/account management;
- generic MCP marketplace/platform;
- dynamic remote code execution;
- changes to R4 Google Calendar OAuth or Calendar action semantics;
- replacement of Global Search.

## 3. Architecture

```
Owner
  ↓
SH Runtime
  ↓
SH MCP Client
  ↓  Streamable HTTP
R8 YouTube MCP Server
  ↓
YouTube Data API
  ↓
normalized read-only result
  ↓
SH Runtime / Chat
  ↓
YouTube link
```

Authority remains with SH. The MCP server is a provider boundary and does not decide identity, ownership, authorization, risk, confirmation, or SH lifecycle state.

## 4. MCP Contract

The server implements the stable MCP `2025-11-25` lifecycle and tool primitives:

1. `initialize`;
2. `tools/list`;
3. `tools/call`;
4. `notifications/initialized`.

Transport is Streamable HTTP. The server validates the `Origin` header when present, requires the MCP JSON response/content negotiation headers, and enforces the negotiated protocol version.

Reference: https://modelcontextprotocol.io/specification/2025-11-25/basic/transports

## 5. Tool Surface

### `youtube_search`

Searches public YouTube videos.

Input:
- `query` — required;
- `max_results` — bounded to 1–10.

Output fields:
- `video_id`;
- `title`;
- `channel_title`;
- `published_at`;
- `thumbnail_url`;
- `youtube_url`.

### `youtube_get_video`

Retrieves public metadata for a specific video ID.

Output includes:
- title/channel;
- publication time;
- description;
- duration;
- view/like counts when supplied by the provider;
- canonical YouTube URL.

Both tools are explicitly read-only. No write tool is exposed.

## 6. Anti-Duplication Rule

Global SH Search remains the generic SH search capability.

R8 is justified because its capability is provider-specific YouTube retrieval with a bounded YouTube result model and direct YouTube deep-link output. R8 must not become a second generic web/global search implementation.

R4 Google Calendar remains unchanged. Its Calendar OAuth scope and Calendar action contract are not reused as YouTube authorization.

## 7. Security / Authority

- YouTube API key is server-side only.
- The Android/client layer does not receive the provider key.
- The runtime forwards the authenticated owner token to the protected MCP Edge Function.
- The MCP server is deployed with JWT verification enabled.
- External YouTube content is treated as untrusted data, not SH instruction.
- Only the two read-only tools are exposed.
- Provider failures are normalized into R8-specific error classes.

## 8. Implementation Artifacts

- `runtime/p4g/mcp/youtube_mcp_client.ts`
- `runtime/p4g/r8_youtube_mcp_contract.test.ts`
- `functions/r8-youtube-mcp/index.ts`
- `functions/r8-youtube-mcp/index.test.ts`
- `.github/workflows/sh-r8-youtube-mcp-verification.yml`
- `functions/runtime-p4a-001/index.ts` — R8 runtime route

## 9. DEV Deployment

Supabase DEV function:

- name: `r8-youtube-mcp`
- status: ACTIVE
- JWT verification: enabled
- version: 1

Required runtime secret/configuration:

- `YOUTUBE_API_KEY`

Optional origin allowlist:

- `R8_MCP_ALLOWED_ORIGINS`

No provider secret is committed to Git.

## 10. Verification

CI contract coverage verifies:

- MCP JSON-RPC request shape;
- protocol version handling;
- tool discovery;
- tool invocation;
- protocol error propagation;
- bounded read-only tool surface.

Runtime verification requires the DEV function to have a valid `YOUTUBE_API_KEY`. CI green alone is not treated as proof of live YouTube provider execution.

## 11. Acceptance Boundary

R8 is **IMPLEMENTED** when the repository/runtime artifacts exist and the protected MCP endpoint is deployed.

R8 becomes **RUNTIME VERIFIED** only after:

```
Owner-authenticated runtime
  ↓
MCP initialize
  ↓
tools/list
  ↓
youtube_search / youtube_get_video
  ↓
YouTube Data API
  ↓
normalized result
  ↓
SH response with YouTube URL
```

The final device-level assertion “tap link opens the native YouTube app” is an app/device behavior check and is not substituted by backend CI.

## 12. External Protocol Reference

MCP 2025-11-25 is the implementation baseline for this slice. The later 2026 release candidate is not silently adopted as a Canonical or implementation dependency until it becomes the project-selected protocol baseline.

END OF WORKSTREAM E — TOOL MCP YOUTUBE
