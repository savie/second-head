# SECOND HEAD — Knowledge Lifecycle Security, Confirmation & Operation Ledger Design — 2026-09-13

## Status

**WORKING DESIGN — IMPLEMENTATION RECONCILED / NON-E2E GATES CLOSED / E2E OPEN**

The design described here has been implemented in Supabase DEV. Earlier statements that confirmation, operation ledger, atomicity, exposure hardening, or SQLSTATE mapping remained implementation blockers are stale.

## 1. Implemented Lifecycle

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE
ACTIVE → UPDATED + successor
ACTIVE → DEPRECATED → ARCHIVED
```

## 2. Confirmation Domain

Dedicated semantic confirmation exists:

```text
knowledge_lifecycle_confirmations
runtime_create_knowledge_lifecycle_confirmation
runtime_confirm_knowledge_lifecycle
```

It is bound to actor/account/SH/Knowledge/transition/operation_key/decision_ref and expiry.

Recovery confirmation remains domain-specific and is not reused as lifecycle authority.

## 3. Operation Ledger

Implemented table:

`knowledge_lifecycle_operations`

Current idempotency index:

```text
(account_id, sh_id, operation_key) UNIQUE
```

Existing operation lookup returns `ALREADY_APPLIED` for the same operation and rejects target/transition conflicts.

## 4. Atomic Transaction Boundary

Implemented central function:

`runtime_knowledge_transition`

Current execution order:

```text
AUTH
→ resolve active SH
→ resolve prior operation
→ lock Knowledge row
→ validate expected lifecycle / transition
→ validate confirmation where required
→ mutate Knowledge
→ write operation ledger
→ write Journey LIFECYCLE event
→ attach Journey event to operation ledger
→ return result
```

All occur inside the same PostgreSQL function transaction boundary.

## 5. Journey Projection

Lifecycle transitions emit `LIFECYCLE` Journey events with Knowledge identity, transition, operation identity, previous/resulting lifecycle, resulting record/version, and provenance reference.

Journey remains projection/history, not lifecycle authority.

## 6. Security / Exposure

Current DEV state verifies:

```text
Lifecycle functions: SECURITY DEFINER
search_path: public
anon EXECUTE: false
authenticated EXECUTE: true
```

Direct semantic mutation is revoked on the relevant Knowledge/Journey lifecycle tables for `public`, `anon`, and `authenticated`.

## 7. Error Contract

`runtime_knowledge_transition` implements stable application SQLSTATE-style codes for authentication, ownership, not-found, lifecycle mismatch, invalid transition, confirmation, operation-key, and operation-conflict classes.

## 8. Gate Result

| Gate | Status |
|---|---|
| Lifecycle authority | VERIFIED |
| Confirmation authority | IMPLEMENTED |
| Operation ledger | IMPLEMENTED |
| Idempotency | IMPLEMENTED |
| Atomic Knowledge + Journey | IMPLEMENTED |
| Journey lifecycle payload | IMPLEMENTED |
| Security exposure | VERIFIED |
| Error mapping | IMPLEMENTED |
| Implementation gate | **OPEN / VERIFIED** |
| Runtime positive/negative/concurrency proof | **OPEN — E2E ONLY** |

## 9. Change Boundary

```text
Supabase DEV schema = EXISTING / VERIFIED
Supabase DEV data   = UNCHANGED BY THIS DOC UPDATE
Migration history   = EXISTING / VERIFIED
GitHub DEV docs     = RECONCILED
Canonical           = UNCHANGED
```
