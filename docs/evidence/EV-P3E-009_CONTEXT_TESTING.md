# EV-P3E-009 — Context Testing

## Status

PASS / DEV

Backlog: `BL-P3E-009`
Acceptance Criteria: `AC-CTX-09`

## Scope

Verification of the existing `public.assemble_context(...)` integration after the Phase 3E context pipeline work.

## Live Verification

Supabase DEV project: `second-head`

### Test 1 — Explicit limits

Synthetic transaction created 5 matching memories and 5 matching shared knowledge rows.

Call:

`assemble_context(<SH-1>, 'P3E009 limited', 2, 2)`

Observed:

- memory_count = 2
- knowledge_count = 2
- total_count = 4

Result: PASS.

### Test 2 — Isolation and visibility

Synthetic transaction created:

- 3 matching memories for SH-1;
- 1 matching memory for SH-2;
- 2 matching shared knowledge rows;
- 1 matching OWNER_ONLY knowledge row.

Call:

`assemble_context(<SH-1>, 'P3E009 synthetic', 50, 50)`

Observed:

- memory_count = 3
- knowledge_count = 1
- wrong_sh_memory_count = 0
- non_shared_knowledge_count = 0

Result: PASS.

The OWNER_ONLY knowledge row was excluded by the knowledge retrieval path.
The SH-2 memory was excluded by the memory retrieval path.

### Test 3 — Combined context budget

Synthetic transaction created 60 matching memories and 60 matching shared knowledge rows.

Call:

`assemble_context(<SH-1>, 'P3E009 budget', 50, 50)`

Observed:

- memory_count = 49
- knowledge_count = 1
- total_count = 50

Result: PASS.

This verifies the P3E-008 combined context cap in the existing assembly function.

### Test 4 — Null query

Synthetic transaction created matching memory and shared knowledge rows.

Call:

`assemble_context(<SH-1>, null, 1, 1)`

Observed:

- `query = null`
- memory array returned within requested bound
- knowledge array returned within requested bound

Result: PASS.

### Test 5 — Residue check

All synthetic verification data was executed inside transactions and rolled back.

Final live residue check:

- `memory_test_residue = 0`
- `knowledge_test_residue = 0`

Result: PASS.

## Implementation Verification

The live function inventory confirms:

- `assemble_context(uuid, text, integer, integer)` exists;
- `retrieve_memories_bounded(uuid, text, integer)` exists;
- `retrieve_knowledge_bounded(text, integer)` exists;
- all three are `SECURITY INVOKER`.

No schema mutation was required for P3E-009.

## Assurance Limitation

`IMPLEMENTATION / DATABASE INTEGRATION = PASS`

`APPLICATION / API / UI E2E = DEFERRED`

`MODEL TOKEN-BUDGET RUNTIME ASSURANCE = DEFERRED`

No unsupported E2E claim is made.

## Final

`BL-P3E-009 = PASS / DEV`

Evidence is based on actual Supabase DEV verification and rollback-clean test execution.
