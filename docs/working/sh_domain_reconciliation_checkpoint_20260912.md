# SECOND HEAD — Domain Reconciliation Checkpoint — 2026-09-12

## Status

**WORKING — CURRENT CHECKPOINT / EVIDENCE RECONCILIATED**

Dokumen ini adalah checkpoint continuity untuk domain:

`Conversation → Attachment → Memory → Knowledge → Experience → Journey`

Dokumen ini bukan Canonical dan tidak mengubah Approved Contract.

## Authority

```text
OWNER / USER DECISION
        ↓
CANONICAL
        ↓
APPROVED CONTRACT
        ↓
ARCHITECTURE / DESIGN
        ↓
CURRENT IMPLEMENTATION
        ↓
RUNTIME / DATABASE EVIDENCE
        ↓
DEVICE / E2E EVIDENCE
        ↓
HISTORICAL / dev_old
```

## Evidence checkpoint

- Repository: `savie/second-head`, branch `dev`.
- Database: Supabase DEV `pkhkgvsrqeupvwoqjwmd`.
- Current DEV evidence inspected against repository source and runtime/database state.
- Domain row counts at checkpoint: `conversations=37`, `conversation_threads=9`, `conversation_attachments=5`, `memories=1`, `knowledge=0`, `experiences=0`, `journey_events=1`.
- Row counts are evidence of current state only; they are not capability proof by themselves.

# 1. Conversation

## Current state

Conversation/Message runtime and Flutter integration are implemented for the current tested path.

Verified/current evidence includes:

- user message persistence;
- assistant message persistence;
- active conversation/thread identifiers;
- runtime bridge passing `conversation_id` and `user_message_id`;
- dynamic AI runtime response path;
- provider fallback/runtime observability;
- tab-switch/reload persistence observed on device for the current conversation test;
- account isolation observed through account-switch testing.

## Important distinction

```text
Edit Message ≠ Retry Attachment ≠ Regenerate Assistant
```

`Edit` updates message content.
`Regenerate` concerns an assistant response.
`Retry` in the current attachment UI is intended for a failed attachment/message send path.

## Open

Conversation adapter update/delete parameter contract must remain a separate audit item until explicitly verified. It is not silently marked PASS by the attachment E2E result.

# 2. Conversation Attachment

## Current happy path

The following path is verified from device + DEV database/runtime evidence:

```text
Pick photo/file
    ↓
Preview remains visible
    ↓
Composer remains available
    ↓
Non-empty caption/message
    ↓
Send
    ↓
Conversation Message created
    ↓
Attachment Resource created
    ↓
Storage object uploaded
    ↓
Finalize
    ↓
Attachment = PERSISTED
    ↓
SH runtime response
    ↓
Assistant message persisted
    ↓
Tab switch / account switch verification
```

Current tested attachment had:

- user caption: `Test attachment E2E`;
- attachment linked to the same persisted user Message ID;
- attachment status `PERSISTED`;
- private bucket object present;
- SH response successful.

User also verified that the attachment/message remained after navigation and did not appear when switching accounts.

## Status

```text
Happy-path send              VERIFIED
Persistence                  VERIFIED
Message ↔ Attachment link    VERIFIED
Storage                      VERIFIED
Finalize                     VERIFIED
SH response                  VERIFIED
Navigation persistence       VERIFIED (device)
Account isolation            VERIFIED (device)
```

## Open risk — retry identity

Current retry hardening is **not a blocker** and is not required to reopen the happy path.

The risk is that the current high-level `recordWithAttachments()` orchestration creates a Message and Attachment during a new send orchestration. A future failure/retry scenario must prove that retry of a logical failed attachment reuses the same `attachment_id` and does not create duplicate durable resources.

Do not claim retry/idempotency PASS until a real failed/ambiguous upload execution is available and verified.

# 3. Memory

## Current evidence

A current explicit memory capture was previously verified in DEV:

- `memories` contains the captured Memory;
- lifecycle was `CANDIDATE`;
- scope/visibility were owner-private;
- corresponding Journey event existed;
- runtime audit showed request, semantic capture, and successful response.

Journey FE hydration now consumes backend Journey retrieval through the trusted identity boundary rather than treating local Journey storage as the sole authority.

## Status

```text
Memory persistence                 VERIFIED for tested capture
Memory → Journey projection        VERIFIED for tested capture
Owner visibility                   VERIFIED for tested path
General Memory semantic coverage   NOT globally closed
```

Do not generalize the single tested Memory capture into proof of all Memory lifecycle/retrieval semantics.

# 4. Knowledge

Current DEV contains the `knowledge` domain and current semantic/runtime source references exist. The checkpoint database currently has zero `knowledge` rows.

Therefore:

```text
Domain implementation/source       CURRENT / PRESENT
Positive data instance             NONE at checkpoint
Full semantic E2E                  OPEN
```

No PASS claim is made for a positive Knowledge capture/retrieval E2E because there is no current positive Knowledge row/evidence in this checkpoint.

# 5. Experience

Current DEV contains the `experiences` domain and semantic source/migration lineage. The checkpoint database currently has zero `experiences` rows.

Therefore:

```text
Domain implementation/source       CURRENT / PRESENT
Positive data instance             NONE at checkpoint
Full semantic E2E                  OPEN
```

No PASS claim is made for a positive Experience capture/retrieval E2E without current positive runtime/data evidence.

# 6. Journey

## Current state

Journey runtime retrieval and Context Resolver integration have already been reconciled.

Current contract/source evidence establishes:

```text
runtime_get_context_package()
        ↓
assemble_context()
        ↓
Memory
Knowledge
Experience
Journey
```

Journey retrieval remains bounded by `runtime_get_journey_context()` and trusted identity/ownership rules.

Current Journey UI loads backend Journey data and merges it with local presentation state using `event_id` identity. Local Journey storage is account-scoped.

## Device verification

Account A Journey Memory was visible.
After switching to Account B, Account A Memory disappeared.
A B Memory was created.
Returning to Account A restored A's Memory without exposing B's Memory.

Therefore current tested Journey local account isolation is **PASS**.

## Status

```text
Journey persistence              VERIFIED
Journey backend retrieval        VERIFIED
Journey Context integration      IMPLEMENTED / VERIFIED
Journey FE hydration             VERIFIED
Local account isolation          VERIFIED (device)
Cross-account exposure           DENIED in tested path
```

Do not reopen Journey Context Resolver integration merely because older inventory text still says OPEN; that is documentation drift, not current runtime state.

# 7. Cross-domain Context

Current Context Resolver contract is already decided and reconciled.
The intended ordering remains:

```text
actor
 → conversation
 → state
 → memory
 → knowledge
 → experience
 → journey
```

The resolver produces a unified semantic context package while preserving domain boundaries, ownership/visibility, and relevance rules.

This checkpoint does **not** claim that every semantic domain has a positive AI E2E proving model consumption of every domain. Such proof is a separate verification layer.

# 8. Documentation Reconciliation Result

The following stale classifications are superseded by this checkpoint when interpreting current state:

| Previous stale claim | Current classification |
|---|---|
| Conversation dynamic AI not complete | Current runtime path is implemented and verified for tested conversation/attachment flow |
| Attachment APK E2E deferred | Happy-path attachment E2E is verified; failure-retry/idempotency remains open |
| Memory/Journey backend integration open | Tested Memory persistence + Journey projection/retrieval are verified |
| Journey Context Resolver integration pending | Already implemented/reconciled/verified |
| Knowledge full semantic E2E | OPEN — no positive Knowledge instance at checkpoint |
| Experience full semantic E2E | OPEN — no positive Experience instance at checkpoint |

This table is a reconciliation statement, not an authority change.

# 9. Explicit Non-Claims

This checkpoint does **not** claim:

- retry/idempotency is verified;
- full Knowledge lifecycle is verified;
- full Experience lifecycle is verified;
- all Conversation CRUD adapter parameters are verified;
- full Recovery restore E2E is verified;
- all Lifecycle/Clone/Inheritance/Succession semantics are verified;
- every model/provider semantically consumes every Context domain correctly.

## 10. Next Gate

Do not reopen closed Conversation/Attachment/Journey work without new evidence.

Next work should target a **confirmed OPEN dependency**, not documentation archaeology.

Priority candidates remain:

1. Conversation adapter update/delete parameter audit;
2. Knowledge positive semantic/runtime verification;
3. Experience positive semantic/runtime verification;
4. Security/succession semantic harness;
5. other confirmed gates from the master inventory.

No implementation is implied by this list.
