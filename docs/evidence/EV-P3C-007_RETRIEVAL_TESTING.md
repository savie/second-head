# SECOND HEAD — P3C-007 Retrieval Testing Evidence

## Status
PASS — BL-P3C-007 / AC-MEM-19

## Verification Scope
P3C retrieval testing was exercised against the live Supabase DEV database using synthetic memory rows.

The test covered the existing retrieval chain and its implemented database primitives:

`QUERY → RETRIEVE → FILTER → RANK → VALIDATE → CONTEXT`

P3C-007 validates the implemented retrieval behavior without introducing a new retrieval architecture.

## Reconciliation

Existing P3C artifacts already provide the required upstream behavior:

- P3C-001 — retrieval strategy;
- P3C-002 — relevance scoring;
- P3C-003 — deterministic ranking;
- P3C-004 — lifecycle / scope / visibility filtering;
- P3C-005 — Memory → request-scoped Context boundary;
- P3C-006 — bounded retrieval.

The live database also contains the bounded retrieval function `public.retrieve_memories_bounded(...)` as a SECURITY INVOKER function, with execution granted to `authenticated` and revoked from `anon`.

No new schema, table, authorization model, sharing mechanism, or canonical rule was required for P3C-007.

Older planning material may still record Memory/Knowledge OQs as formally open. This test does not silently close those OQs; it verifies the already-realized P3C retrieval implementation.

## Test Environment

Repository:

`savie/second-head`

Branch:

`dev`

Supabase project:

`second-head`

Supabase project ref:

`pkhkgvsrqeupvwoqjwmd`

## Synthetic Test Data

Seven synthetic rows were inserted for one SH, covering:

- ACTIVE eligible memory;
- UPDATED eligible memory;
- CANDIDATE eligible memory;
- SUPERSEDED excluded memory;
- ARCHIVED excluded memory;
- DELETED excluded memory;
- unrelated ACTIVE memory.

One additional synthetic row was inserted under a second SH to verify SH scoping.

All synthetic rows were removed after verification.

Final persistent memory count:

`0`

Final P3C007 synthetic residue:

`0`

## Test Results

### T1 — Lifecycle filtering

Querying `retrieve_memories_bounded(...)` returned only:

- CANDIDATE;
- ACTIVE;
- UPDATED.

Terminal lifecycle states SUPERSEDED, ARCHIVED, DEACTIVATED, and DELETED were not returned.

Result:

`PASS`

### T2 — Relevance scoring is present

Returned rows contained `relevance_score` values produced by the existing `memory_relevance_score(...)` primitive.

Result:

`PASS`

### T3 — Deterministic ranking / tie-break behavior

The retrieval output was ordered by:

1. relevance score descending;
2. updated_at descending;
3. occurrence_count descending;
4. memory_id ascending.

The exercised synthetic set produced deterministic ordering under equal relevance scores.

Result:

`PASS`

### T4 — Bounded result count

The bounded retrieval limit was exercised with:

- `p_limit = 0` → 1 row returned;
- `p_limit = 2` → 2 rows returned;
- `p_limit = 100` → result remained bounded to the available eligible set (4 rows in the synthetic dataset).

The implementation clamps the requested limit to the range 1–50.

Result:

`PASS`

### T5 — SH scoping

A synthetic memory belonging to a second SH was inserted.

Retrieval for the first SH did not return the second SH's synthetic memory.

Result:

`PASS`

Note: this test verifies the retrieval function's explicit `m.sh_id = p_sh_id` boundary. Full adversarial application-level authorization assurance remains a separate runtime/security assurance concern.

### T6 — Function execution boundary

Live database verification confirmed:

- `SECURITY INVOKER = true`;
- `anon` cannot execute the bounded retrieval function;
- `authenticated` can execute the bounded retrieval function.

Result:

`PASS`

### T7 — Test cleanup / residue

All P3C007 synthetic rows were deleted after testing.

Live database verification after cleanup:

`public.memories persistent row count = 0`

Result:

`PASS`

## Overall Result

`BL-P3C-007 = PASS`

`IMPLEMENTATION / DATABASE FUNCTIONAL ASSURANCE = PASS`

`APPLICATION / API E2E ASSURANCE = DEFERRED`

The deferred status is not a failure and does not block completion of this backlog item because the implemented retrieval behavior was directly exercised and verified at the database boundary.

## Non-Goals

This evidence does not claim:

- full application/API E2E retrieval assurance;
- adversarial authorization testing through the application stack;
- production performance baseline;
- Knowledge ingestion or trust promotion;
- clone/inheritance behavior;
- a new retrieval architecture.

## Conclusion

P3C retrieval testing is complete for the implemented DEV database retrieval path. No additional schema or architecture realization is required for BL-P3C-007.
