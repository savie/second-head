# SECOND HEAD — Conversation Attachment FE Integration Status

## Status

**RECONCILIATED — HAPPY-PATH E2E VERIFIED / RETRY IDEMPOTENCY OPEN**

Dokumen ini adalah working reconciliation record untuk Backend ↔ Frontend Conversation Attachment.

Dokumen ini bukan Canonical dan tidak mengubah Approved Attachment Contract.

## 1. Contract

Attachment adalah **Message-owned resource/payload**, bukan Message mandiri.

```text
Message
├── non-empty content
└── Attachment[]
```

Backend Message tetap mensyaratkan content non-empty. Tidak ada attachment-only Message workaround.

## 2. Current FE Call Path

```text
Composer content (non-empty)
        ↓
recordUserWithAttachments(...)
        ↓
ConversationService.recordWithAttachments()
        ↓
Message created
        ↓
Attachment create
        ↓
Storage upload
        ↓
Finalize
        ↓
Attachment PERSISTED
        ↓
AI Runtime
        ↓
SH response
```

The previous `recordUser('')` mismatch is no longer the current path.

## 3. Backend Finalize

`runtime_finalize_conversation_attachment()` current DEV definition has the corrected qualified attachment lookup/update, ownership checks, storage-object existence check, and trusted execution boundary.

**Status: IMPLEMENTED / RUNTIME PRESENT.**

## 4. Device + DEV E2E Result

Current device test established:

1. photo selected;
2. preview visible;
3. composer remained available;
4. non-empty caption `Test attachment E2E` sent;
5. user Message persisted;
6. Attachment persisted and linked to the same Message ID;
7. Storage object existed;
8. finalize resulted in `PERSISTED`;
9. SH returned a response;
10. message/attachment remained after navigation;
11. attachment/message did not appear after switching to another account.

**Happy-path attachment E2E: VERIFIED.**

This is stronger than source-only evidence because the current result is supported by device behavior plus DEV database/runtime evidence.

## 5. Retry / Failure Semantics

Retry in this context means retrying a **failed attachment send/persistence path**, not Edit Message and not Regenerate Assistant.

```text
Edit       → update existing message content
Regenerate → replace/regenerate assistant response behavior
Retry      → recover a failed attachment/message send path
```

The current happy path does not require a retry test because no failure occurred.

### Open risk

A future failed/ambiguous upload must prove that retry of the same logical attachment preserves the same `attachment_id` and does not create duplicate durable Attachment resources/messages merely because orchestration is repeated.

**Status: OPEN RISK / NON-BLOCKING HARDENING.**

Do not claim retry/idempotency PASS without an actual failure/retry execution test.

## 6. Scope Boundary

This reconciliation does not change:

- Canonical architecture;
- Approved Attachment Contract;
- Message semantic contract;
- attachment schema;
- storage policy;
- recovery semantics;
- cleanup/reconciliation worker;
- retry architecture;
- unrelated domains.

## 7. Final Disposition

```text
Old FE call-path mismatch      CLOSED / RECONCILED
Backend finalize correction     IMPLEMENTED
Happy-path attachment E2E      VERIFIED
Navigation persistence         VERIFIED
Account isolation              VERIFIED
Retry identity/idempotency     OPEN RISK
Documentation reconciliation   COMPLETED
```

**Current attachment gate: HAPPY PATH CLOSED / VERIFIED.**
