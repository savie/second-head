# SECOND HEAD — Audit Bukti Capability Transition

## Status

**CATATAN AUDIT KERJA — NON-E2E IMPLEMENTATION GATE OPEN / VERIFIED**

This audit is reconciled against current Supabase DEV and current GitHub DEV migrations. Earlier findings that the Knowledge transition capability was missing are historical and no longer current.

## 1. Current Knowledge Transition Capability

Current DEV provides:

```text
CANDIDATE → ACCEPTED
ACCEPTED → INDEXED
INDEXED → ACTIVE
ACTIVE → UPDATED + successor
ACTIVE → DEPRECATED
DEPRECATED → ARCHIVED
```

Entry functions:

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
```

Central authority:

`runtime_knowledge_transition`

## 2. Authentication / Ownership — PASS

The transition authority requires authenticated identity, resolves the current account, requires an active SH owned by that account, and verifies the Knowledge record before mutation.

Model output and confidence are not authority sources.

## 3. Lifecycle Guards — PASS

The transition authority locks the Knowledge target and verifies:

```text
expected lifecycle
→ legal transition
→ SH ownership
→ required confirmation
→ operation identity
```

Invalid lifecycle/transition requests are rejected with stable application error codes.

## 4. Confirmation — PASS

Dedicated semantic confirmation is implemented via:

```text
knowledge_lifecycle_confirmations
runtime_create_knowledge_lifecycle_confirmation
runtime_confirm_knowledge_lifecycle
```

Recovery confirmation is not reused as semantic Knowledge authority.

## 5. Operation Identity / Idempotency — PASS

`knowledge_lifecycle_operations` is persisted in DEV and has a unique idempotency index on `account_id + sh_id + operation_key`.

Existing operations are resolved before mutation; conflicting target/transition use of the same operation key is rejected.

## 6. Journey Projection / Atomicity — PASS AT DB IMPLEMENTATION LEVEL

The transition authority mutates Knowledge, persists the operation record, emits a `LIFECYCLE` Journey event, and stores the resulting Journey event reference before returning success, all inside one PostgreSQL function transaction boundary.

Runtime concurrency and end-to-end behavior remain E2E verification items.

## 7. Security / Grants — VERIFIED

Current DEV inspection confirms:

```text
Knowledge lifecycle functions: SECURITY DEFINER
search_path: public
anon EXECUTE: false
authenticated EXECUTE: true
```

Direct semantic mutation is revoked on the relevant lifecycle tables for `public`, `anon`, and `authenticated`.

## 8. Error Mapping — PASS

Stable application SQLSTATE-style codes are implemented for authentication, ownership, not-found, lifecycle mismatch, invalid transition, confirmation, operation-key, and operation-conflict failures.

## 9. Capability Matrix

| Capability | Current status |
|---|---|
| Knowledge candidate capture | PASS |
| Knowledge CANDIDATE → ACCEPTED | IMPLEMENTED |
| Knowledge ACCEPTED → INDEXED | IMPLEMENTED |
| Knowledge INDEXED → ACTIVE | IMPLEMENTED |
| Knowledge ACTIVE → UPDATED | IMPLEMENTED |
| Knowledge ACTIVE → DEPRECATED | IMPLEMENTED |
| Knowledge DEPRECATED → ARCHIVED | IMPLEMENTED |
| Semantic confirmation | IMPLEMENTED |
| Operation ledger | IMPLEMENTED |
| Idempotency boundary | IMPLEMENTED |
| Atomic Knowledge + Journey | IMPLEMENTED |
| Security exposure | VERIFIED |
| Error mapping | IMPLEMENTED |
| Lifecycle positive/negative/concurrency E2E | **OPEN — E2E ONLY** |

## 10. Scope Boundary

Memory candidate activation and Experience candidate lifecycle are separate scope decisions and are not implied by the Knowledge transition implementation.

## 11. Gate Result

```text
TRANSITION CAPABILITY AUDIT = PASS
NON-E2E IMPLEMENTATION GATE = OPEN / VERIFIED
E2E VERIFICATION             = OPEN
```

No new migration or runtime change is made by this audit update.
