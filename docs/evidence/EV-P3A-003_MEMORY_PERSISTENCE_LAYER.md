# EV-P3A-003 — Memory Persistence Layer

## Status
PASS / VERIFIED

## Scope
Verification of BL-P3A-003 / AC-MEM-03 against the existing Phase 3A memory storage realization.

## Audit Conclusion
No additional persistence function/RPC/service was required for this backlog item. The existing `public.memories` table is the persistence layer for the Phase 3A memory-storage slice, with the schema and ownership relationship already established by the Phase 3A migration.

## Source / Authority
- SH Core Canonical v1.0
- SH Full Build Scope v1.0
- SH Full Implementation Contract v1.0
- SH Full Implementation Guide v1.0
- SH Full Execution Strategy v1.0
- Phase -1 Artifact Map / Backlog
- EV-P3A-001 — Memory Storage Foundation

## Existing Realization Verified
Migration:
`database/migrations/20260811034535_create_memory_storage_and_knowledge_eligibility.sql`

The migration creates `public.memories` with:
- persistent `memory_id` UUID primary key;
- `sh_id` foreign key to `public.sh_instances`;
- memory content and source fields;
- confidence, scope, visibility, lifecycle and occurrence metadata;
- timestamps;
- `superseded_by` self-reference;
- lifecycle and data-integrity constraints;
- indexes supporting SH-scoped lifecycle and occurrence access.

The same migration enables RLS and defines owner-scoped SELECT/INSERT/UPDATE/DELETE policies. These controls are covered primarily by P3A-004/P3A-005; they are recorded here as part of the persistence boundary already present.

## Supabase Verification
Project: `pkhkgvsrqeupvwoqjwmd`

Verified:
- migration version `20260811034535` is applied;
- `public.memories` exists;
- `public.sh_instances` exists;
- four owner-scoped memory policies exist;
- no dedicated memory persistence RPC/function is required by the current P3A-003 realization;
- current memory row count was 0 before the verification test.

## Persistence Test
A temporary sentinel memory was inserted inside a transaction using an existing SH ID, immediately queried back from `public.memories`, and the transaction was rolled back.

Observed persisted-in-transaction record:
- `memory_id`: generated UUID
- `sh_id`: existing SH instance
- `content`: `P3A-003 persistence verification sentinel`
- `lifecycle`: `ACTIVE`

The transaction was rolled back, so no test data remained in the database.

## Boundary of This Evidence
This evidence verifies the Phase 3A database persistence layer itself.

It does NOT claim completion of:
- automated memory extraction;
- full memory decision/scoring policy;
- application/runtime memory orchestration;
- Knowledge ingestion (OQ-03);
- Reference Material trust promotion (OQ-04);
- semantic/vector memory.

Those remain outside BL-P3A-003.

## Result
BL-P3A-003 / AC-MEM-03: **PASS**.

No mutation to the memory schema or persistence architecture was required beyond the already-applied Phase 3A storage migration.
