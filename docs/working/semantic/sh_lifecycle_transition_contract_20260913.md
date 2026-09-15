# SECOND HEAD — Kontrak Capability Transition Siklus Hidup

## Status

**KONTRAK KERJA — CURRENT RECONCILIATION — KNOWLEDGE IMPLEMENTATION GATE OPEN / VERIFIED**

## Otoritas

```text
KEPUTUSAN OWNER / USER
→ CANONICAL
→ APPROVED CONTRACT
→ ARSITEKTUR / DESAIN
→ KONTRAK KERJA INI
→ IMPLEMENTASI
→ BUKTI RUNTIME / DATABASE
→ VERIFIKASI E2E
```

This is a supporting working contract and does not modify Canonical.

## 1. Core Rule

Lifecycle transition is an authorized state transition, not a raw field update.

```text
REQUEST
→ AUTHENTICATE
→ RESOLVE ACTOR / ACCOUNT / SH
→ RESOLVE RECORD
→ VERIFY OWNERSHIP
→ VERIFY CURRENT LIFECYCLE
→ VERIFY POLICY / CONFIRMATION
→ VERIFY OPERATION IDENTITY
→ APPLY ATOMIC CHANGE
→ PROJECT JOURNEY
→ RETURN OBSERVABLE RESULT
```

Model output is never transition authority by itself.

## 2. Current Implemented Knowledge Surface

The current Knowledge lifecycle is:

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE
ACTIVE → UPDATED + successor
ACTIVE → DEPRECATED → ARCHIVED
```

Implemented functions:

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
```

The central implementation is `runtime_knowledge_transition`.

## 3. Security / Ownership

The current transition authority resolves authentication, current account, active SH ownership, Knowledge ownership, expected lifecycle, legal transition, and operation identity server-side.

Anonymous execution is denied; authenticated execution is explicitly granted for the public transition entry functions.

## 4. Confirmation

Dedicated Knowledge lifecycle confirmation is implemented and is separate from recovery confirmation.

Confirmation is required for:

```text
INDEXED → ACTIVE
ACTIVE → DEPRECATED
DEPRECATED → ARCHIVED
```

## 5. Operation / Atomicity

`knowledge_lifecycle_operations` persists transition operations and has a unique idempotency index on `account_id + sh_id + operation_key`.

The central transition function locks the Knowledge row and performs domain mutation, operation persistence, Journey projection, and Journey reference update within one PostgreSQL function transaction boundary.

## 6. Journey

Journey is projection/history, not lifecycle authority.

Lifecycle events use `LIFECYCLE` and include transition and operation identity plus resulting lifecycle/record metadata.

## 7. Error / Security Contract

Stable application SQLSTATE-style codes are implemented for authentication, ownership, not-found, lifecycle mismatch, invalid transition, confirmation, operation-key, and operation-conflict classes.

Current DB state verifies `SECURITY DEFINER`, `search_path = public`, anonymous EXECUTE denied, and authenticated EXECUTE granted for the lifecycle entry functions.

## 8. Gate

```text
POLICY CONTRACT       = RECONCILED
RUNTIME CAPABILITY    = IMPLEMENTED
TRANSITION CONTRACT   = IMPLEMENTED / VERIFIED
IMPLEMENTATION GATE   = OPEN / VERIFIED
E2E VERIFICATION      = OPEN — E2E ONLY
```

## 9. Scope Boundary

Memory candidate activation and Experience candidate lifecycle remain separate domain scope and are not inferred from the Knowledge implementation.

## 10. Current Next Step

Proceed to the remaining E2E lifecycle/security verification. Do not reopen the non-E2E implementation gate without contradictory evidence.
