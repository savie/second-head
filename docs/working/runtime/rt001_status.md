# SECOND HEAD — RT-001 Runtime Status

## Status

E2E PROVIDER VERIFIED — WORKING VERIFICATION RECORD

## Verified Baseline

- Authenticated request reaches `ai-runtime`.
- Identity resolution succeeds for the authenticated runtime context.
- Runtime audit persistence succeeds.
- Context package and its inspected dependencies execute successfully under the runtime boundary.
- The original RT-001 HTTP 502 was caused by missing `EXECUTE` on `runtime_record_conversation(uuid,text,text,jsonb)` for `authenticated`.
- Supabase DEV migration `20260911233846_restore_authenticated_runtime_conversation_execute` restored that privilege and allowed the original provider-path verification.
- The corresponding migration source is reconciled into GitHub `dev`.
- E2E verification through the existing APK reached `ai-runtime` and produced a successful provider response; matching runtime audit and conversation evidence were observed.

## Persistence Ownership Reconciliation

The E2E evidence exposed a separate implementation defect: both the Flutter conversation path and `ai-runtime` were persisting the same user/assistant messages, producing duplicate Message rows.

Current approved Project → Conversation → Message contract already identifies `ConversationService` as the current frontend consumer of the conversation Message mutation capability, and requires mutations to pass through the appropriate runtime/RPC boundary. The current `ConversationService.record()` uses `runtime_record_conversation_message_v2`.

Therefore the current implementation correction is:

```text
ConversationService
  → owns Conversation Message persistence
  → runtime_record_conversation_message_v2

ai-runtime
  → owns authenticated AI execution
  → identity resolution
  → context retrieval
  → explicit semantic lifecycle
  → provider execution/fallback
  → runtime audit
  → returns model response
```

`ai-runtime` no longer calls the legacy `runtime_record_conversation(uuid,text,text,jsonb)` persistence path. This removes the observed dual-write without changing the Project → Conversation → Message contract or introducing a new Message storage path.

The existing `runtime_record_conversation` database function is not removed or revoked by this change because legacy/external consumers have not been exhaustively ruled out. Its current existence is therefore not evidence of current `ai-runtime` usage.

## v8 Verification Gate — CLOSED

Supabase DEV `ai-runtime` reached ACTIVE version 8 with `verify_jwt=true` after deployment of the persistence-ownership correction.

A fresh APK verification test (`RT-001 verification test ke 4`) passed with:

- one persisted user Message for the test input;
- one persisted assistant Message for the same conversation;
- matching `RUNTIME_REQUEST SUCCESS` and `RUNTIME_RESPONSE SUCCESS` audit events;
- the same runtime `request_id` across the request/response audit pair;
- provider `openrouter` succeeding on the first attempt;
- response metadata explicitly identifying `conversation_persistence=frontend-conversation-service`;
- no duplicate Message row for the fresh test input.

The previous duplicate rows from the earlier test are historical evidence and are not removed speculatively.

Therefore the duplicate-persistence follow-up is **CLOSED — E2E VERIFIED**.

## Follow-up: AI Conversation Integration Audit

The duplicate-persistence gate is closed, but broader dynamic AI conversation integration is not yet closed.

Current evidence identifies two separate gaps:

1. **Active-thread identity is not part of the AI runtime request.** `RuntimeRequest` currently carries only `input`, and the Flutter transport invokes `ai-runtime` with only `user_message`.
2. **Context Runtime currently assembles conversation context by `p_sh_id`, not by the active conversation/thread.** `runtime_get_context_package()` calls `runtime_load_conversation_context(p_sh_id)`, whose current implementation selects recent conversation rows for the authenticated account/SH. This is different from the frontend's explicit thread-scoped capability `runtime_load_conversation_context_for_thread(p_conversation_id, p_limit)`.

This is an architectural integration gap, not a reason to bypass identity/security boundaries. It requires an explicit contract/implementation decision before changing the runtime request or Context Runtime input shape.

A separate failure-semantics correction has been implemented in the Flutter bridge: runtime failure no longer falls back to persisting a static assistant response. The bridge now propagates `AppFailure<RuntimeResponse>` instead of converting it into an assistant Message. This addresses the approved conversation contract requirement that backend failure must not produce false success.

The current `ConversationView` catch path still requires focused verification because it can add a local user representation after the user Message has already been persisted. This is a UI-state issue and must not be mistaken for backend duplicate persistence.

## Boundary Note

The current Flutter transport invokes `ai-runtime`; no current Flutter source invocation of `runtime-p4a-001` was found. The fresh E2E evidence confirms the corrected APK → `ai-runtime` path.

## Legacy Boundary

`runtime-p4a-001` remains legacy/reference-only for current architecture decisions. Current source inspection found no active consumer. Supabase audit evidence shows legacy `RUNTIME_REQUEST` traffic only through `2026-09-05 15:16:58.150014+00`. Retirement remains an operational action, not a prerequisite for the current `ai-runtime` path.

## Decision

RT-001 runtime/provider execution remains verified. The dual-write defect is **CLOSED — E2E VERIFIED**. The current next gate is the **AI Conversation Integration Audit**, specifically active-thread correlation, thread-scoped context, runtime request ↔ Message correlation, and failure-state verification.

Do not use the legacy runtime as a dependency. Keep `runtime-p4a-001` reference-only pending its separate retirement gate and available Edge Function administrative operation.
