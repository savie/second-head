# SECOND HEAD — Rekonsiliasi Konflik Kontrak Otoritas Transisi Knowledge — 2026-09-13

## Status

**WORKING RECONCILIATION RECORD — AUTHORITY RESOLVED / IMPLEMENTATION RECONCILED**

## 1. Authority Decision

The selected lifecycle authority is the staged Knowledge lifecycle:

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE
ACTIVE → UPDATED + successor
ACTIVE → DEPRECATED → ARCHIVED
```

`VALIDATION` remains a process boundary, not a lifecycle enum.

## 2. Conflict Resolution

The earlier direct-activation contract:

```text
CANDIDATE → ACTIVE
runtime_activate_knowledge_candidate
```

is no longer the current implementation direction.

The staged contract is the current reconciled direction and is implemented by:

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
```

No silent conflict remains between the two working directions: the staged lifecycle is the active implementation boundary.

## 3. Engineering Dependencies — NOW CLOSED NON-E2E

The following dependencies are implemented and verified at source/DB level:

- semantic Knowledge confirmation authority;
- operation ledger and idempotency boundary;
- Knowledge row locking and lifecycle guard;
- atomic Knowledge mutation + operation ledger + Journey projection within one PostgreSQL function transaction;
- exact `LIFECYCLE` Journey projection convention;
- SECURITY DEFINER/search_path/grant exposure;
- stable application SQLSTATE-style error mapping.

## 4. Current Gate

```text
Lifecycle authority conflict   = RESOLVED
Staged lifecycle               = IMPLEMENTED
Confirmation authority         = IMPLEMENTED
Operation ledger               = IMPLEMENTED
Atomicity boundary             = IMPLEMENTED
Journey projection             = IMPLEMENTED
Security exposure              = VERIFIED
Error mapping                  = IMPLEMENTED
Implementation gate            = OPEN / VERIFIED
E2E verification               = OPEN — E2E ONLY
```

## 5. Remaining Boundary

The remaining proof is runtime/E2E execution of the implemented lifecycle, including positive, negative/cross-actor, retry/idempotency, and concurrency behavior.

This document must not be used to reopen the already-resolved non-E2E implementation blocker.

## 6. Change Boundary

```text
GitHub DEV docs          = RECONCILED
Supabase DEV schema      = EXISTING / VERIFIED
Supabase DEV data        = UNCHANGED BY THIS DOC UPDATE
Migration history        = EXISTING / VERIFIED
Canonical                = UNCHANGED
```
