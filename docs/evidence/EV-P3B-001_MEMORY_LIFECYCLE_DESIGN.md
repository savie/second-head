# EV-P3B-001 — Memory Lifecycle Design

## Status

**PASS — VERIFIED / DEV**

Backlog item: `BL-P3B-001`
Domain: Phase 3B — Memory Lifecycle
Mutation type: Evidence-only; no new database/schema mutation required.

## Audit Scope

This evidence records the completion audit for the Memory Lifecycle design after reconciliation of:

- SH Core / Build authority relevant to Memory lifecycle;
- Phase -1 execution-control constraints;
- current session Owner decision layer for Memory → Knowledge → General Knowledge → sharing → provenance → superseded;
- current GitHub implementation source;
- actual Supabase schema and applied migration state.

## Owner Decision Reconciliation

The current Owner discussion established that Memory may preserve experience/interactions for continuity, but Memory is not automatically exposed as speech. The discussion also established that Knowledge can evolve from information/experience and that Knowledge can be corrected/versioned rather than silently rewriting history. Earlier session material records the lifecycle model explicitly:

`Candidate → Active → Updated / Superseded / Archived / Deactivated / Deleted`

It also records that Memory has scope, ownership, permission, provenance, purpose, persistence, and lifecycle, and that Creator authority does not automatically grant access to another user's personal Memory.

These decisions are treated here as Owner-session decision evidence pending formal canonical/document reconciliation; this evidence does not modify canonical authority.

## GitHub Verification

The existing memory storage migration already defines the lifecycle representation without introducing a new architectural model:

- `lifecycle` column with states:
  - `CANDIDATE`
  - `ACTIVE`
  - `UPDATED`
  - `SUPERSEDED`
  - `ARCHIVED`
  - `DEACTIVATED`
  - `DELETED`
- `superseded_by` self-reference to `memories.memory_id`.
- `scope` supports `PRIVATE` and `GENERAL`.
- `visibility` supports `OWNER_ONLY` and `SHARED`.
- `occurrence_count` and the existing knowledge-eligibility view support the previously decided initial knowledge threshold without changing Memory identity semantics.

Source migration:
`database/migrations/20260811034535_create_memory_storage_and_knowledge_eligibility.sql`

## Supabase Verification

Actual Supabase project was inspected directly.

Applied migrations include:

- `20260811034535_create_memory_storage_and_knowledge_eligibility`
- `20260811051355_reconcile_memories_rls_ownership_helper`

Current `public.memories` actual schema contains:

- `lifecycle`
- `superseded_by`
- `scope`
- `visibility`
- `occurrence_count`
- `confidence`
- `source`
- `sh_id`

`public.memories` currently has **0 rows**, so this audit does not claim runtime lifecycle transition behavior has been exercised against live memory data.

RLS remains enabled on `public.memories` and ownership policies continue to resolve access through the existing SH → Account ownership boundary.

## Boundary / Non-Decision

This item does **not** decide or silently introduce:

- retention duration;
- automatic archival timing;
- automatic deletion timing;
- a new memory ownership model;
- a new knowledge trust model;
- a new knowledge ingestion mechanism;
- a new Core modification mechanism.

Those remain governed by their applicable requirements/Owner decisions.

## Completion Result

**BL-P3B-001 = PASS**

Reason: the lifecycle semantics required for the design are already represented consistently in the project decision/history and are already realized in the existing Memory schema. No additional architectural decision or minimal realization is required for this backlog item.

Next backlog item may proceed through the standard flow:

`AUDIT → REALIZATION MINIMAL (if needed) → VERIFY → EVIDENCE → DEV`
