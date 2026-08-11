# EV-P3A-006 — Memory Storage Testing

**Backlog:** BL-P3A-006  
**Acceptance Criterion:** AC-MEM-06  
**Phase:** 3A — Memory Storage  
**Status:** PASS  
**Verification Date:** 2026-08-11

## Objective

Verify that the Phase 3A memory storage implementation accepts valid memory records, enforces the defined storage integrity constraints, and leaves no persistent verification residue.

## GitHub Verification

Branch: `dev`

The Phase 3A migration source `database/migrations/20260811034535_create_memory_storage_and_knowledge_eligibility.sql` defines `public.memories` with:

- mandatory `memory_id` and `sh_id`;
- `sh_id` foreign key to `public.sh_instances(sh_id)`;
- constrained `memory_type`, `scope`, `visibility`, and `lifecycle` values;
- confidence constrained to `0..1` when present;
- occurrence count constrained to `>= 1`;
- timestamps and `superseded_by` self-reference;
- RLS and owner-scoped policies;
- indexes for SH/lifecycle and SH/occurrence access.

The migration source is present in `dev` and is the implementation under test.

## Actual Supabase Verification

Project: `pkhkgvsrqeupvwoqjwmd`

Verified actual `public.memories` state:

- table exists with the expected Phase 3A storage columns;
- RLS is enabled;
- four owner-scoped policies are present: SELECT, INSERT, UPDATE, DELETE;
- migration versions `20260811034535` and `20260811051355` are applied;
- final memory row count is `0` after verification cleanup.

## Storage Tests

### Valid record

Inserted a temporary valid memory using an existing SH:

- `scope = GENERAL`
- `visibility = OWNER_ONLY`
- `lifecycle = ACTIVE`
- `occurrence_count = 5`
- `confidence = 0.75`

The insert succeeded and the generated UUID plus stored values were read back successfully. The temporary row was then deleted.

### Integrity rejection

The database rejected invalid records as expected:

- `confidence = 1.5` → `memories_confidence_check`
- `occurrence_count = 0` → `memories_occurrence_count_check`
- `scope = NOT_A_SCOPE` → `memories_scope_check`

No invalid row persisted.

## Result

**AC-MEM-06: PASS**

No realization was required. The existing Phase 3A storage implementation already satisfies the tested storage integrity requirements.

## Boundary

This evidence verifies storage integrity only. It does not finalize OQ-02, OQ-03, or OQ-04 and does not claim completion of memory decision/scoring, knowledge ingestion, trust promotion, semantic memory, or runtime memory orchestration.

## Evidence Integrity

- No persistent test rows remain.
- No schema or policy mutation was required for BL-P3A-006.
- Verification was performed against actual Supabase state and the corresponding GitHub `dev` migration source.
