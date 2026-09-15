# SECOND HEAD — Kontrak Implementasi Transisi Knowledge — 2026-09-13

## Status

**KONTRAK IMPLEMENTASI WORKING — IMPLEMENTED / NON-E2E VERIFIED — E2E OPEN**

Supabase DEV now contains the implementation described by this contract. Earlier statements that the implementation gate was closed are stale.

## 1. Current Lifecycle

```text
ACQUISITION
  ↓
CANDIDATE
  ↓
VALIDATION PROCESS
  ↓
ACCEPTED
  ↓
INDEXING
  ↓
INDEXED
  ↓
AUTHORIZED ACTIVATION
  ↓
ACTIVE
  ├──→ UPDATED + superseded_by successor
  ↓
DEPRECATED
  ↓
ARCHIVED
```

`VALIDATION` is a process boundary, not a database lifecycle enum.

## 2. Implemented Transition RPCs

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
```

All delegate to `runtime_knowledge_transition`.

## 3. Security / Authority

The transition authority resolves authenticated identity, current account, active SH ownership, Knowledge ownership, expected lifecycle, legal transition, required confirmation, and operation identity server-side.

Model output and confidence are not authority.

## 4. Confirmation

Dedicated semantic confirmation is implemented through:

```text
knowledge_lifecycle_confirmations
runtime_create_knowledge_lifecycle_confirmation
runtime_confirm_knowledge_lifecycle
```

Confirmation is bound to actor/account/SH/Knowledge/transition/operation key/decision reference and expiry.

Required confirmation transitions are:

```text
INDEXED → ACTIVE
ACTIVE → DEPRECATED
DEPRECATED → ARCHIVED
```

Recovery confirmation remains a separate domain.

## 5. Operation Ledger / Idempotency

`knowledge_lifecycle_operations` is implemented with a unique idempotency index on:

```text
account_id + sh_id + operation_key
```

The transition authority resolves existing operations before mutation and rejects a conflicting target/transition for the same operation key.

## 6. Transaction / Journey

The centralized transition function locks the Knowledge target and performs Knowledge mutation, operation-ledger persistence, Journey `LIFECYCLE` projection, and operation-ledger Journey reference update within one PostgreSQL function transaction boundary.

Runtime concurrency behavior remains an E2E verification item.

## 7. Security Exposure

Current DEV verification confirms:

```text
SECURITY DEFINER = true
search_path       = public
anon EXECUTE      = false
authenticated     = true
```

Direct semantic mutation is revoked for the relevant Knowledge/Journey lifecycle tables for `public`, `anon`, and `authenticated`.

## 8. Error Contract

Stable application SQLSTATE-style codes are implemented for authentication, ownership, not-found, lifecycle mismatch, invalid transition, confirmation, operation-key, and operation-conflict failures.

## 9. Implementation Checklist

| Item | Status |
|---|---|
| Lifecycle graph | IMPLEMENTED |
| Transition RPCs | IMPLEMENTED |
| Confirmation authority | IMPLEMENTED |
| Operation ledger | IMPLEMENTED |
| Idempotency | IMPLEMENTED |
| Row locking | IMPLEMENTED |
| Knowledge + Journey transaction boundary | IMPLEMENTED |
| Journey lifecycle payload | IMPLEMENTED |
| SECURITY DEFINER/search_path | VERIFIED |
| EXECUTE grants | VERIFIED |
| Direct mutation exposure | HARDENED / VERIFIED |
| Error mapping | IMPLEMENTED |
| Runtime/E2E verification | **OPEN — E2E ONLY** |

## 10. Gate

```text
NON-E2E IMPLEMENTATION GATE = OPEN / VERIFIED
E2E LIFECYCLE VERIFICATION   = OPEN
```

This contract does not authorize Memory or Experience lifecycle changes.
