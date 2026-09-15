# SECOND HEAD — Lifecycle Transition Runtime Design Review — 2026-09-13

## Status

**WORKING DESIGN REVIEW — DESIGN RECONCILED / KNOWLEDGE IMPLEMENTATION GATE OPEN**

This review is reconciled against the current Supabase DEV implementation. Earlier statements that the Knowledge lifecycle implementation was still blocked are stale.

## 1. Current Runtime Boundary

The implemented Knowledge lifecycle uses domain-specific entry functions and a centralized transition authority:

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
        ↓
runtime_knowledge_transition
```

No generic arbitrary-domain lifecycle mutation surface was introduced.

## 2. Current Security Order

The implementation resolves:

```text
auth.uid()
→ current_account_id()
→ active SH ownership
→ Knowledge ownership
→ expected lifecycle
→ legal transition
→ confirmation where required
→ operation identity
→ mutation
→ Journey projection
```

Model output and confidence are not authority.

## 3. Current Persistence Boundary

Implemented components:

```text
Knowledge mutation
      +
knowledge_lifecycle_operations
      +
Journey LIFECYCLE projection
```

These are executed inside the centralized PostgreSQL function transaction boundary.

## 4. Current Security Surface

DEV verification confirms:

```text
SECURITY DEFINER = true
search_path       = public
anon EXECUTE      = false
authenticated     = true
```

Relevant direct semantic mutation privileges are revoked.

## 5. Current Error Boundary

Stable application SQLSTATE-style codes are implemented for authentication, ownership, not-found, lifecycle mismatch, invalid transition, confirmation, operation-key, and operation-conflict failures.

## 6. Gate Result

```text
DESIGN = RECONCILED
IMPLEMENTATION = PRESENT
NON-E2E IMPLEMENTATION GATE = OPEN / VERIFIED
E2E VERIFICATION = OPEN — E2E ONLY
```

## 7. Scope Boundary

This document covers the implemented Knowledge lifecycle. Memory activation and Experience candidate lifecycle are separate scope decisions and are not implied by this implementation.

No new migration or runtime change is made by this reconciliation document.
