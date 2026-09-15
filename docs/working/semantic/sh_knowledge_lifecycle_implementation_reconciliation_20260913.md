# SECOND HEAD — Knowledge Lifecycle Implementation Reconciliation — 2026-09-13

## Status

**WORKING VERIFICATION RECORD — IMPLEMENTATION PRESENT / NON-E2E VERIFIED / E2E OPEN**

This record is the current reconciliation of the Knowledge lifecycle implementation against Supabase DEV.

## 1. Implemented Objects

Current DEV contains:

```text
knowledge_lifecycle_confirmations
knowledge_lifecycle_operations
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

## 2. Security Verification

Current DB inspection confirms:

```text
lifecycle entry functions = SECURITY DEFINER
search_path = public
anon EXECUTE = false
authenticated EXECUTE = true
```

Internal `runtime_knowledge_transition` is not exposed to `public`, `anon`, or `authenticated`.

Direct mutation is revoked on the relevant Knowledge/Journey lifecycle tables.

## 3. Confirmation

Dedicated Knowledge lifecycle confirmation is implemented and bound to actor/account/SH/Knowledge/transition/operation key/decision reference/expiry.

Required confirmation transitions:

```text
INDEXED → ACTIVE
ACTIVE → DEPRECATED
DEPRECATED → ARCHIVED
```

Recovery confirmation remains separate.

## 4. Operation Ledger / Idempotency

`knowledge_lifecycle_operations` is persistent and has a unique idempotency index on:

```text
account_id + sh_id + operation_key
```

Existing matching operations are resolved before mutation; conflicting target/transition reuse is rejected.

## 5. Transaction Boundary

The central transition function locks the Knowledge row and executes:

```text
Knowledge mutation
→ operation ledger insert
→ Journey LIFECYCLE projection
→ operation ledger Journey reference
→ return
```

inside one PostgreSQL function transaction boundary.

## 6. Journey Projection

Lifecycle events use `LIFECYCLE` and persist Knowledge identity, transition, operation identity, previous/resulting lifecycle, resulting record/version, and provenance reference.

## 7. Error Mapping

Stable application SQLSTATE-style codes are implemented in the current transition authority, including authentication, ownership, not-found, lifecycle mismatch, invalid transition, confirmation, operation-key, and operation-conflict classes.

## 8. Current Gate

```text
Schema capability            = IMPLEMENTED
Confirmation authority       = IMPLEMENTED
Operation ledger             = IMPLEMENTED
Idempotency                  = IMPLEMENTED
Atomic Knowledge + Journey   = IMPLEMENTED
Journey projection           = IMPLEMENTED
Security exposure            = VERIFIED
Error mapping                = IMPLEMENTED
Implementation gate          = OPEN / VERIFIED
E2E behavioral verification  = OPEN — E2E ONLY
```

## 9. Verification Boundary

The following are intentionally not claimed as complete here because they require runtime/E2E execution:

```text
positive lifecycle execution
negative/cross-actor execution
idempotency behavior under runtime retry
concurrency behavior
full runtime caller integration
```

These are E2E verification items, not current non-E2E implementation blockers.

## 10. Migration / Source Reconciliation

The lifecycle migrations are part of the reconciled Supabase DEV ↔ GitHub DEV migration set. No migration cleanup or mutation is performed by this document update.

## 11. Change Boundary

```text
GitHub DEV docs      = RECONCILED
Supabase DEV schema  = EXISTING / VERIFIED
Supabase DEV data    = UNCHANGED BY THIS DOC UPDATE
Migration history    = EXISTING / VERIFIED
Canonical            = UNCHANGED
```
