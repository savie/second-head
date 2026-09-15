# SECOND HEAD — Audit Operation Ledger & Transaction Boundary Lifecycle Knowledge — 2026-09-13

## Status

**WORKING TRANSACTION AUDIT — IMPLEMENTED / NON-E2E VERIFIED / E2E OPEN**

Current Supabase DEV contains the operation ledger and centralized transaction boundary described by this audit. Earlier proposed/missing-state findings are historical and not current blockers.

## 1. Current Lifecycle

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE → UPDATED / DEPRECATED → ARCHIVED
```

## 2. Operation Ledger — IMPLEMENTED

Current table:

`knowledge_lifecycle_operations`

Current unique idempotency index:

```text
(account_id, sh_id, operation_key) UNIQUE
```

The transition authority resolves an existing operation before mutation and rejects conflicting target/transition reuse.

## 3. Transaction Boundary — IMPLEMENTED

`runtime_knowledge_transition` performs:

```text
AUTH
→ RESOLVE ACTIVE SH
→ RESOLVE EXISTING OPERATION
→ LOCK KNOWLEDGE ROW
→ VERIFY LIFECYCLE / TRANSITION
→ VERIFY CONFIRMATION WHEN REQUIRED
→ MUTATE KNOWLEDGE
→ WRITE OPERATION LEDGER
→ WRITE JOURNEY LIFECYCLE EVENT
→ STORE JOURNEY EVENT REFERENCE
→ RETURN RESULT
```

These writes execute inside one PostgreSQL function transaction boundary.

## 4. Journey Contract — IMPLEMENTED

Lifecycle Journey payload contains the Knowledge identity, transition, operation identity, previous/resulting lifecycle, resulting record/version, and provenance reference.

Journey remains projection/history, not authority.

## 5. Security — VERIFIED

Lifecycle entry functions are `SECURITY DEFINER`, use `search_path = public`, deny anonymous EXECUTE, and grant EXECUTE to `authenticated`. Direct semantic table mutation is revoked in the reconciled scope.

## 6. Error Contract — IMPLEMENTED

Stable application SQLSTATE-style error codes are present for authentication, ownership, not-found, lifecycle mismatch, invalid transition, confirmation, operation-key, and operation-conflict cases.

## 7. Gate Decision

```text
Operation ledger           = IMPLEMENTED
Idempotency boundary       = IMPLEMENTED
Row locking                = IMPLEMENTED
Atomic Knowledge + Journey = IMPLEMENTED
Journey payload            = IMPLEMENTED
Security exposure          = VERIFIED
Error mapping              = IMPLEMENTED
Implementation gate        = OPEN / VERIFIED
E2E behavioral proof       = OPEN — E2E ONLY
```

## 8. Remaining Verification

The following remain runtime/E2E tests only:

- positive lifecycle execution;
- negative/cross-actor rejection;
- exact retry/idempotency behavior under runtime execution;
- concurrent transition behavior;
- forced downstream failure/rollback behavior.

## 9. Change Boundary

```text
Supabase DEV schema = EXISTING / VERIFIED
Supabase DEV data   = UNCHANGED BY THIS DOC UPDATE
Migration history   = EXISTING / VERIFIED
GitHub DEV docs     = RECONCILED
Canonical           = UNCHANGED
```
