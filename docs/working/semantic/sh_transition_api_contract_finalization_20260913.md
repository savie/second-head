# SECOND HEAD — Transition API Contract Finalization — 2026-09-13

## Status

**WORKING CONTRACT — RECONCILED WITH CURRENT DEV IMPLEMENTATION**

This document records the transition API contract and its reconciliation against the current Supabase DEV implementation. The Knowledge staged lifecycle is now implemented; this document must not continue to describe that implementation gate as closed.

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
E2E VERIFICATION
```

This is a supporting working document. It does not change Canonical.

## 1. Current Scope

The current implemented Knowledge lifecycle is:

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE
ACTIVE → UPDATED
ACTIVE → DEPRECATED → ARCHIVED
```

`VALIDATION` remains a process boundary, not a database lifecycle enum.

Journey remains projection/history, not lifecycle authority.

Memory activation and Experience candidate lifecycle are outside the currently implemented Knowledge transition gate and are not to be inferred from the Knowledge implementation.

## 2. Implemented Knowledge API

Current DEV exposes:

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
```

The implementation is centralized through `runtime_knowledge_transition`.

## 3. Authorization Boundary — VERIFIED AT FUNCTION LEVEL

Current implementation resolves:

```text
auth.uid()
→ current_account_id()
→ active SH ownership
→ Knowledge ownership
→ expected lifecycle
→ legal transition
→ confirmation where required
→ operation identity
→ mutation
→ Journey projection
```

Model output and confidence are not authority sources.

## 4. Confirmation Authority — IMPLEMENTED

Dedicated semantic Knowledge confirmation is implemented through:

```text
knowledge_lifecycle_confirmations
runtime_create_knowledge_lifecycle_confirmation
runtime_confirm_knowledge_lifecycle
```

The confirmation is bound to actor/account/SH/Knowledge/transition/operation_key/decision_ref and expiry. Recovery confirmation is not reused as semantic lifecycle authority.

Required confirmation transitions are enforced for:

```text
INDEXED → ACTIVE
ACTIVE → DEPRECATED
DEPRECATED → ARCHIVED
```

## 5. Operation Identity / Idempotency — IMPLEMENTED

Dedicated operation persistence exists:

```text
knowledge_lifecycle_operations
```

Current DEV has a unique idempotency index on:

```text
account_id + sh_id + operation_key
```

Existing operation lookup returns `ALREADY_APPLIED` for the same operation and rejects a conflicting target/transition.

Concurrency-safe target mutation uses row locking.

## 6. Atomic Knowledge + Journey Boundary — IMPLEMENTED AT DB FUNCTION BOUNDARY

`runtime_knowledge_transition` performs Knowledge mutation, operation-ledger persistence, Journey projection, and operation-ledger update inside one PostgreSQL function transaction boundary.

The function does not return success before the Journey projection step completes.

This is implementation/static/DB-state evidence. Concurrent runtime execution remains an E2E verification item.

## 7. Provenance / Journey — IMPLEMENTED

Lifecycle Journey events use event type `LIFECYCLE` and persist transition metadata including Knowledge identity, transition, operation identity, lifecycle before/after, resulting record/version, and provenance reference.

The operation ledger stores the Journey event reference.

## 8. Security / Exposure — VERIFIED AT DB STATE

Current DEV inspection confirms for the Knowledge lifecycle functions:

```text
SECURITY DEFINER       = true
anon EXECUTE           = false
authenticated EXECUTE  = true
search_path             = public
```

Direct INSERT/UPDATE/DELETE/TRUNCATE is revoked for authenticated/anon on the Knowledge lifecycle tables and `journey_events` in the reconciled scope.

## 9. Error Contract — IMPLEMENTED

Current `runtime_knowledge_transition` uses stable SQLSTATE-style application codes, including:

```text
P2001 UNAUTHENTICATED
P2003 SH_NOT_OWNED
P2004 KNOWLEDGE_NOT_FOUND
P2006 WRONG_LIFECYCLE
P2007 INVALID_TRANSITION
P2011 CONFIRMATION_REQUIRED
P2012 OPERATION_KEY_INVALID
P2013 OPERATION_CONFLICT
```

These are current implementation evidence from DEV, not proposed codes.

## 10. Transition Coverage

| Transition | Current status |
|---|---|
| CANDIDATE → ACCEPTED | IMPLEMENTED |
| ACCEPTED → INDEXED | IMPLEMENTED |
| INDEXED → ACTIVE | IMPLEMENTED |
| ACTIVE → UPDATED + successor | IMPLEMENTED |
| ACTIVE → DEPRECATED | IMPLEMENTED |
| DEPRECATED → ARCHIVED | IMPLEMENTED |
| Semantic confirmation | IMPLEMENTED |
| Operation ledger/idempotency | IMPLEMENTED |
| Knowledge + Journey transaction boundary | IMPLEMENTED |
| Security exposure/grants | VERIFIED |
| Stable error codes | IMPLEMENTED |
| Positive/negative/concurrency E2E | **OPEN — E2E ONLY** |

## 11. Current Gate

```text
Knowledge lifecycle authority       = RECONCILED
Transition graph                    = IMPLEMENTED
Confirmation authority              = IMPLEMENTED
Operation ledger                    = IMPLEMENTED
Idempotency                         = IMPLEMENTED
Atomic Knowledge + Journey          = IMPLEMENTED
Journey lifecycle projection        = IMPLEMENTED
SECURITY DEFINER / grants           = VERIFIED
Error mapping                       = IMPLEMENTED
Implementation gate                 = OPEN / VERIFIED
Runtime/E2E semantic proof           = OPEN
```

`OPEN` in this document now refers only to the remaining runtime/E2E proof for this transition scope.

## 12. Change Boundary

```text
GitHub DEV docs          = RECONCILED
Supabase DEV schema      = EXISTING / VERIFIED
Supabase DEV data        = UNCHANGED BY THIS DOC UPDATE
Migration history        = EXISTING / VERIFIED
Runtime code             = EXISTING
Canonical                = UNCHANGED
```
