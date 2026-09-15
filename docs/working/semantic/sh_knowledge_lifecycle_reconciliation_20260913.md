# SECOND HEAD — Knowledge Lifecycle Reconciliation + Confirmation Contract Integration — 2026-09-13

## Status

**WORKING RECONCILIATION RECORD — IMPLEMENTATION RECONCILED / GATE OPEN**

This record has been reconciled against the current Supabase DEV state. Earlier statements that Knowledge lifecycle implementation was missing or blocked are stale and must not be used as current status.

## 1. Current Authority

The selected Knowledge lifecycle authority is the staged path:

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE
ACTIVE → UPDATED
ACTIVE → DEPRECATED → ARCHIVED
```

`VALIDATION` remains a process boundary, not a database lifecycle enum.

## 2. Current DEV Evidence

The current DEV database contains the Knowledge lifecycle vocabulary and the implemented lifecycle transition surface. The applied migrations include:

```text
20260913092434_knowledge_lifecycle_authority_and_operations
20260913092503_knowledge_lifecycle_authority_exposure_hardening
20260913092952_revoke_direct_semantic_mutation_access
20260913101106_knowledge_lifecycle_error_codes
```

The current implementation provides:

```text
runtime_create_knowledge_lifecycle_confirmation
runtime_confirm_knowledge_lifecycle
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
runtime_knowledge_transition
```

## 3. Confirmation

Semantic Knowledge confirmation is now a dedicated implementation boundary. It is separate from recovery confirmation and binds the confirmation to the Knowledge transition, operation key, actor/account/SH and expiry.

Confirmation is enforced for:

```text
INDEXED → ACTIVE
ACTIVE → DEPRECATED
DEPRECATED → ARCHIVED
```

## 4. Operation Identity / Atomicity

The implementation persists lifecycle operations in `knowledge_lifecycle_operations` with a unique operation identity boundary and resolves already-applied operations before mutation.

The transition function locks the target Knowledge row, performs lifecycle mutation, writes the operation record, creates the `LIFECYCLE` Journey projection, then records the Journey event reference before returning success. These operations occur within the same PostgreSQL function transaction boundary.

## 5. Security

Current DEV verification confirms the lifecycle functions are `SECURITY DEFINER`, have `search_path = public`, deny anonymous EXECUTE, and grant EXECUTE to `authenticated`.

Direct semantic mutation is revoked for `knowledge`, `journey_events`, `knowledge_lifecycle_confirmations`, and `knowledge_lifecycle_operations` for `public`, `anon`, and `authenticated` in the reconciled scope.

## 6. Error Contract

Stable implementation error codes are present in `runtime_knowledge_transition`, including authentication, ownership, not-found, lifecycle mismatch, invalid transition, confirmation, operation-key, and operation-conflict classes.

## 7. Current Gate

```text
Lifecycle authority            = RECONCILED
Confirmation authority         = IMPLEMENTED
Operation ledger               = IMPLEMENTED
Atomic Knowledge + Journey     = IMPLEMENTED
Security exposure              = VERIFIED
Error mapping                  = IMPLEMENTED
Implementation gate            = OPEN / VERIFIED
Runtime positive/negative/E2E   = OPEN — E2E ONLY
```

## 8. Remaining Verification

Only runtime/E2E execution remains for this lifecycle implementation scope. E2E must prove positive transitions, rejection boundaries, idempotency/concurrency behavior, and cross-actor isolation as defined by the master E2E matrix.

No non-E2E implementation blocker remains for the implemented Knowledge lifecycle surface.

## 9. Change Boundary

```text
GitHub DEV docs          = RECONCILED
Supabase DEV schema      = EXISTING / VERIFIED
Supabase DEV data        = NOT MUTATED BY THIS DOC UPDATE
Migration history        = EXISTING / VERIFIED
Canonical                = UNCHANGED
```
