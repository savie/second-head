# SECOND HEAD — Knowledge Lifecycle Authority Reconciliation — 2026-09-13

## Status

**WORKING AUTHORITY RECONCILIATION — STAGED LIFECYCLE IMPLEMENTED / IMPLEMENTATION GATE OPEN**

Earlier statements in this document that current runtime transition authority was missing are superseded by the current DEV implementation and must not be treated as current status.

## 1. Authority Order

```text
OWNER / USER DECISION
        ↓
CANONICAL
        ↓
APPROVED CONTRACT
        ↓
ARCHITECTURE / DESIGN
        ↓
WORKING RECONCILIATION
        ↓
IMPLEMENTATION
        ↓
RUNTIME / DATABASE EVIDENCE
        ↓
E2E VERIFICATION
```

Historical `dev_old` remains historical evidence, not current runtime authority.

## 2. Resolved Lifecycle Authority

The selected and implemented Knowledge lifecycle is:

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE
ACTIVE → UPDATED + successor
ACTIVE → DEPRECATED → ARCHIVED
```

`VALIDATION` remains a process boundary.

## 3. Current Implementation Evidence

Current DEV provides dedicated transition functions:

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
```

All delegate to the centralized `runtime_knowledge_transition` authority boundary.

## 4. Confirmation Authority — RESOLVED

Dedicated semantic Knowledge confirmation exists through:

```text
knowledge_lifecycle_confirmations
runtime_create_knowledge_lifecycle_confirmation
runtime_confirm_knowledge_lifecycle
```

The confirmation is actor/account/SH/Knowledge/transition/operation-key bound and time-limited. Recovery confirmation is not reused as lifecycle authority.

## 5. Operation Identity / Atomicity — RESOLVED

`knowledge_lifecycle_operations` persists transition operations with a unique idempotency index on `account_id + sh_id + operation_key`.

The transition function locks the Knowledge target and performs the domain mutation, operation-ledger write, Journey projection, and Journey-event reference update inside one PostgreSQL function transaction boundary.

## 6. Security Exposure — RESOLVED AT DB STATE

Current DEV inspection confirms lifecycle functions are `SECURITY DEFINER`, use `search_path = public`, deny anonymous EXECUTE, and grant EXECUTE to `authenticated`.

Direct semantic mutation is revoked for the relevant Knowledge/Journey lifecycle tables in the reconciled scope.

## 7. Error Mapping — RESOLVED AT IMPLEMENTATION LEVEL

Stable application SQLSTATE-style codes are implemented for authentication, ownership, not-found, lifecycle mismatch, invalid transition, confirmation, operation-key, and operation-conflict cases.

## 8. Transition Matrix

| Transition | Authority | Current status |
|---|---|---|
| CANDIDATE → ACCEPTED | `runtime_accept_knowledge` | IMPLEMENTED |
| ACCEPTED → INDEXED | `runtime_index_knowledge` | IMPLEMENTED |
| INDEXED → ACTIVE | `runtime_activate_knowledge` | IMPLEMENTED |
| ACTIVE → UPDATED | `runtime_update_knowledge` | IMPLEMENTED |
| ACTIVE → DEPRECATED | `runtime_deprecate_knowledge` | IMPLEMENTED |
| DEPRECATED → ARCHIVED | `runtime_archive_knowledge` | IMPLEMENTED |

## 9. Current Gate

```text
Lifecycle authority             = RESOLVED
Confirmation authority          = IMPLEMENTED
Operation ledger                = IMPLEMENTED
Atomic domain + Journey         = IMPLEMENTED
Security exposure               = VERIFIED
SQLSTATE/application errors     = IMPLEMENTED
Implementation gate             = OPEN / VERIFIED
E2E positive/negative/concurrent = OPEN — E2E ONLY
```

## 10. Boundary

This reconciliation closes the non-E2E authority/design blocker for the implemented Knowledge lifecycle. It does not claim E2E completion.

Memory activation and Experience candidate lifecycle are separate scope decisions and are not to be inferred from this Knowledge implementation.

## 11. Change Boundary

```text
GitHub DEV docs          = RECONCILED
Supabase DEV schema      = EXISTING / VERIFIED
Supabase DEV data        = UNCHANGED BY THIS DOC UPDATE
Migration history        = EXISTING / VERIFIED
Canonical                = UNCHANGED
```
