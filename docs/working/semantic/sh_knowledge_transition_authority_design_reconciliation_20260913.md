# SECOND HEAD — Rekonsiliasi Otoritas Desain Transisi Knowledge

## Status

**DESAIN / REKONSILIASI KONTRAK WORKING — IMPLEMENTATION RECONCILED / GATE OPEN**

Earlier statements that Knowledge transition implementation was still open are historical and superseded by current DEV evidence.

## 1. Reconciled Lifecycle

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE
ACTIVE → UPDATED + superseded_by successor
ACTIVE → DEPRECATED → ARCHIVED
```

`VALIDATION` remains a process boundary, not a lifecycle enum.

## 2. Current Runtime Authority

Implemented entry functions:

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
```

Central authority: `runtime_knowledge_transition`.

## 3. Confirmation

Dedicated Knowledge lifecycle confirmation is implemented and bound to actor/account/SH/Knowledge/transition/operation key/decision reference/expiry.

Required for:

```text
INDEXED → ACTIVE
ACTIVE → DEPRECATED
DEPRECATED → ARCHIVED
```

Recovery confirmation remains separate.

## 4. Operation / Atomicity

`knowledge_lifecycle_operations` is implemented with unique idempotency enforcement on `account_id + sh_id + operation_key`.

The central transition function locks the Knowledge row and performs Knowledge mutation, operation persistence, Journey `LIFECYCLE` projection, and Journey reference update in one PostgreSQL function transaction boundary.

## 5. Security / Error Contract

Lifecycle entry functions are `SECURITY DEFINER`, use `search_path = public`, deny anonymous EXECUTE, and grant EXECUTE to `authenticated`.

Stable application SQLSTATE-style error codes are implemented for the current rejection classes.

Direct semantic table mutation is revoked in the reconciled scope.

## 6. Authority Matrix

| Transition | Authority | Status |
|---|---|---|
| CANDIDATE → ACCEPTED | `runtime_accept_knowledge` | IMPLEMENTED |
| ACCEPTED → INDEXED | `runtime_index_knowledge` | IMPLEMENTED |
| INDEXED → ACTIVE | `runtime_activate_knowledge` | IMPLEMENTED |
| ACTIVE → UPDATED | `runtime_update_knowledge` | IMPLEMENTED |
| ACTIVE → DEPRECATED | `runtime_deprecate_knowledge` | IMPLEMENTED |
| DEPRECATED → ARCHIVED | `runtime_archive_knowledge` | IMPLEMENTED |

## 7. Gate

```text
Historical intent            = RECONCILED
Current authority            = VERIFIED
Confirmation                 = IMPLEMENTED
Operation identity           = IMPLEMENTED
Atomic Knowledge + Journey   = IMPLEMENTED
Security exposure            = VERIFIED
Error mapping                = IMPLEMENTED
IMPLEMENTATION GATE          = OPEN / VERIFIED
E2E VERIFICATION              = OPEN — E2E ONLY
```

## 8. Scope Boundary

Memory activation and Experience candidate lifecycle are separate domain decisions. They are not implied by this Knowledge implementation.

## 9. Change Boundary

```text
Supabase DEV schema = EXISTING / VERIFIED
Supabase DEV data   = UNCHANGED BY THIS DOC UPDATE
Migration history   = EXISTING / VERIFIED
GitHub DEV docs     = RECONCILED
Canonical           = UNCHANGED
```
