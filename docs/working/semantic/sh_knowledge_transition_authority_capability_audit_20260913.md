# SECOND HEAD — Audit Otoritas Transisi Knowledge

## Status

**CATATAN AUDIT WORKING — KNOWLEDGE TRANSITION AUTHORITY IMPLEMENTED / NON-E2E VERIFIED / E2E OPEN**

Earlier findings that the individual Knowledge transition authorities were not evidenced are superseded by the current DEV implementation.

## 1. Current Authority

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE
ACTIVE → UPDATED + successor
ACTIVE → DEPRECATED → ARCHIVED
```

Current entry functions:

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
```

## 2. Per-Transition Capability

| Transition | Current evidence | Status |
|---|---|---|
| CANDIDATE → ACCEPTED | `runtime_accept_knowledge` | IMPLEMENTED |
| ACCEPTED → INDEXED | `runtime_index_knowledge` | IMPLEMENTED |
| INDEXED → ACTIVE | `runtime_activate_knowledge` | IMPLEMENTED |
| ACTIVE → UPDATED + successor | `runtime_update_knowledge` | IMPLEMENTED |
| ACTIVE → DEPRECATED | `runtime_deprecate_knowledge` | IMPLEMENTED |
| DEPRECATED → ARCHIVED | `runtime_archive_knowledge` | IMPLEMENTED |

## 3. Security / Ownership

The centralized authority requires authentication, resolves the current account and active SH, verifies Knowledge ownership, expected lifecycle, and legal transition before mutation.

Current DEV privilege state verifies anonymous EXECUTE is denied and authenticated EXECUTE is granted for the public lifecycle entry functions.

## 4. Confirmation

Dedicated semantic confirmation is implemented and is separate from recovery confirmation. Confirmation is bound to actor/account/SH/Knowledge/transition/operation key/decision reference/expiry.

## 5. Operation / Idempotency

`knowledge_lifecycle_operations` is implemented with a unique idempotency index on `account_id + sh_id + operation_key`. Existing matching operations return `ALREADY_APPLIED`; conflicting target/transition reuse is rejected.

## 6. Atomicity / Journey

`runtime_knowledge_transition` locks the Knowledge target and performs Knowledge mutation, operation-ledger persistence, Journey `LIFECYCLE` projection, and Journey-event reference update inside one PostgreSQL function transaction boundary.

## 7. Error / Exposure

Stable application SQLSTATE-style error codes are implemented. Lifecycle entry functions use `SECURITY DEFINER`, fixed `search_path = public`, and explicit grants. Direct semantic table mutation is revoked in the reconciled scope.

## 8. Current Gate

```text
Lifecycle authority       = VERIFIED
Confirmation              = IMPLEMENTED
Operation ledger          = IMPLEMENTED
Idempotency               = IMPLEMENTED
Atomicity boundary        = IMPLEMENTED
Journey projection        = IMPLEMENTED
Security exposure         = VERIFIED
Error mapping             = IMPLEMENTED
Implementation gate       = OPEN / VERIFIED
E2E behavioral proof      = OPEN — E2E ONLY
```

## 9. Scope Boundary

Memory activation and Experience candidate lifecycle are separate domain decisions and are not implied by this Knowledge implementation.

## 10. Final Decision

No non-E2E Knowledge lifecycle implementation blocker remains. The remaining lifecycle work is behavioral E2E verification only.
