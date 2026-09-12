# SECOND HEAD — RT-001 Runtime Status

## Status

E2E PROVIDER VERIFIED — WORKING VERIFICATION RECORD

## Verified

- Authenticated request reaches `ai-runtime`.
- Identity resolution succeeds for the authenticated runtime context.
- Runtime audit persistence succeeds.
- Context package and its inspected dependencies execute successfully under the runtime boundary.
- `runtime_record_conversation(uuid,text,text,jsonb)` required `EXECUTE` for `authenticated`; the missing privilege caused the observed `RUNTIME_CONVERSATION_PERSIST_FAILED` / HTTP 502 failure.
- Supabase DEV migration `20260911233846_restore_authenticated_runtime_conversation_execute` restores that privilege.
- The corresponding migration source is reconciled into GitHub `dev`.
- Post-fix live `ai-runtime` execution reached provider execution successfully; the latest `RUNTIME_RESPONSE` records `provider=openrouter` at `2026-09-11 23:57:27.829905+00`.
- The post-fix request was recorded at `2026-09-11 23:57:25.195992+00` with source `ai-runtime` and model policy `ZERO_BUDGET_AUTOMATIC_MULTI_MODEL`.

## Boundary Note

The current Flutter transport invokes `ai-runtime`; no current Flutter source invocation of `runtime-p4a-001` was found. The audit evidence verifies the live authenticated Edge Function → provider path. It does not by itself prove that the specific recorded request originated from the Flutter UI session.

## Legacy Boundary

`runtime-p4a-001` remains legacy/reference-only for current architecture decisions. Current source inspection found no active consumer. Supabase audit evidence shows legacy `RUNTIME_REQUEST` traffic only through `2026-09-05 15:16:58.150014+00`. Retirement remains an operational action, not a prerequisite for the current `ai-runtime` path.

## Decision

RT-001 runtime/provider execution is verified after the conversation persistence privilege fix. Do not use the legacy runtime as a dependency. Keep `runtime-p4a-001` reference-only pending its separate retirement gate and available Edge Function administrative operation.
