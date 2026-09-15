# SECOND HEAD — Security + Database Transition Design Review — 2026-09-13

## Status

**WORKING AUDIT / DESIGN REVIEW — NON-E2E GATES CLOSED / IMPLEMENTATION GATE OPEN**

This record is reconciled against current Supabase DEV implementation. Earlier statements that confirmation, operation ledger, atomicity design, exposure review, or SQLSTATE mapping were still blockers are stale.

## 1. Scope

Current implemented Knowledge transition surface:

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
```

Central authority:

```text
runtime_knowledge_transition
```

## 2. Confirmation Authority — PASS

Dedicated semantic lifecycle confirmation is implemented through:

```text
knowledge_lifecycle_confirmations
runtime_create_knowledge_lifecycle_confirmation
runtime_confirm_knowledge_lifecycle
```

It is bound to actor/account/SH/Knowledge/transition/operation_key/decision_ref and expiry. Recovery confirmation remains a separate domain boundary.

## 3. Operation Ledger / Idempotency — PASS

`knowledge_lifecycle_operations` is implemented and has a unique idempotency index on:

```text
account_id + sh_id + operation_key
```

The transition function resolves an existing operation before mutation and rejects a conflicting target/transition for the same operation key.

## 4. Atomicity — PASS AT IMPLEMENTATION BOUNDARY

The centralized transition function performs:

```text
AUTH
→ resolve active SH
→ resolve existing operation
→ lock Knowledge row
→ validate lifecycle/transition
→ validate confirmation when required
→ mutate Knowledge
→ write operation ledger
→ write Journey LIFECYCLE event
→ update operation ledger with Journey reference
→ return success
```

These writes occur within one PostgreSQL function transaction boundary.

Runtime concurrency behavior remains an E2E verification item.

## 5. Journey Contract — PASS AT IMPLEMENTATION LEVEL

Lifecycle transitions emit `LIFECYCLE` Journey events containing Knowledge identity, transition, operation identity, previous/resulting lifecycle, resulting record/version, and provenance reference.

Journey remains projection/history, not lifecycle authority.

## 6. SECURITY DEFINER / Grants — VERIFIED

Current DEV inspection confirms all public Knowledge lifecycle entry functions are:

```text
SECURITY DEFINER = true
search_path       = public
anon EXECUTE      = false
authenticated     = true
```

Direct semantic mutation is revoked for the relevant Knowledge/Journey lifecycle tables for `public`, `anon`, and `authenticated`.

## 7. Error Mapping — IMPLEMENTED

Stable application error codes are present in the transition authority, including:

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

## 8. Current Decision Matrix

| Gate | Current status |
|---|---|
| Authorization model | VERIFIED |
| Knowledge lifecycle authority | VERIFIED |
| Confirmation authority | IMPLEMENTED |
| Operation ledger | IMPLEMENTED |
| Idempotency boundary | IMPLEMENTED |
| Atomic Knowledge + Journey | IMPLEMENTED |
| Journey lifecycle projection | IMPLEMENTED |
| SECURITY DEFINER / search_path | VERIFIED |
| EXECUTE grants | VERIFIED |
| Direct semantic mutation exposure | HARDENED / VERIFIED |
| Stable error mapping | IMPLEMENTED |
| Runtime concurrency E2E | **OPEN — E2E ONLY** |
| Positive/negative lifecycle E2E | **OPEN — E2E ONLY** |

## 9. Gate Result

```text
SECURITY / DB DESIGN REVIEW = PASS
NON-E2E BLOCKERS            = CLOSED
IMPLEMENTATION GATE         = OPEN / VERIFIED
E2E VERIFICATION             = OPEN
```

## 10. Change Boundary

```text
GitHub DEV docs          = RECONCILED
Supabase DEV schema      = EXISTING / VERIFIED
Supabase DEV data        = UNCHANGED BY THIS DOC UPDATE
Migration history        = EXISTING / VERIFIED
Canonical                = UNCHANGED
```
