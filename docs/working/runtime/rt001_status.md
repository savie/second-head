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

## v8 Verification Gate

Supabase DEV `ai-runtime` is now ACTIVE at version 8 with `verify_jwt=true` after deployment of the persistence-ownership correction.

GitHub `dev` contains the corresponding runtime source change.

Required next verification:

1. User performs one fresh message test in the existing APK.
2. Assistant verifies runtime audit success and provider success.
3. Assistant verifies exactly one persisted user Message and exactly one persisted assistant Message for that test input.
4. Assistant verifies the persisted rows use the current `runtime_record_conversation_message_v2` path rather than `runtime_record_conversation`.
5. If the counts and path are clean, close the duplicate-persistence follow-up.

Until this fresh E2E passes, the duplicate-persistence correction is **IMPLEMENTED / READY FOR E2E**, not closed.

## Boundary Note

The current Flutter transport invokes `ai-runtime`; no current Flutter source invocation of `runtime-p4a-001` was found. The previous E2E evidence established the APK → `ai-runtime` path. The v8 E2E is specifically required to verify the corrected persistence ownership and absence of duplicate Message rows.

## Legacy Boundary

`runtime-p4a-001` remains legacy/reference-only for current architecture decisions. Current source inspection found no active consumer. Supabase audit evidence shows legacy `RUNTIME_REQUEST` traffic only through `2026-09-05 15:16:58.150014+00`. Retirement remains an operational action, not a prerequisite for the current `ai-runtime` path.

## Decision

RT-001 runtime/provider execution remains verified. The dual-write defect is now corrected at the current runtime boundary: `ConversationService` persists Conversation Messages, while `ai-runtime` executes the authenticated AI path and records runtime audit/semantic lifecycle state. Fresh APK E2E is the closure gate for the duplicate-persistence follow-up.

Do not use the legacy runtime as a dependency. Keep `runtime-p4a-001` reference-only pending its separate retirement gate and available Edge Function administrative operation.
