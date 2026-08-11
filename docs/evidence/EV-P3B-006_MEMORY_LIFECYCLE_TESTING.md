# EV-P3B-006 — Memory Lifecycle Testing

## Requirement
- Backlog: `BL-P3B-006`
- Item: Memory Lifecycle Testing
- Priority: P0
- Dependency: `BL-P3B-005`
- Acceptance Criteria: `AC-MEM-12`

## Phase -1 / Decision Gate

No new Owner Decision was required for this checkpoint.

Phase -1 controls preserved:
- source-first audit;
- no silent canonical or architectural change;
- `UNVERIFIED` is not treated as `PASS`;
- actual GitHub/Supabase state is evidence of implementation/testing, not replacement for canonical authority.

## Scope Tested

The existing Phase 3B memory model was exercised at the database lifecycle level using temporary synthetic rows on the `dev` database.

Lifecycle operations exercised:

1. Memory creation as `CANDIDATE`.
2. Promotion to `ACTIVE` with `occurrence_count = 5`.
3. Knowledge eligibility view verification: `GENERAL` + occurrence threshold produced `knowledge_candidate = true`.
4. Transition to `UPDATED`.
5. Transition to `ARCHIVED`.
6. Creation of a replacement memory and transition of the predecessor to `SUPERSEDED` with `superseded_by` pointing to the replacement.
7. Physical deletion of both synthetic test rows.
8. Final residue check confirmed zero test rows remained.

## GitHub / Source Audit

Phase -1 backlog defines `BL-P3B-006` as Memory Lifecycle Testing and maps it to `AC-MEM-12`. The Phase 3 DoD requires memory lifecycle to be implemented and verified with evidence.

Existing Phase 3B evidence covers the individual lifecycle implementation slices, including update, archival, and deletion. This checkpoint adds the missing lifecycle-sequence verification evidence rather than introducing a new schema or lifecycle rule.

No minimal realization was required.

## Supabase Live Verification

Target project: `second-head`
Target branch: `dev`

Live database facts verified before/after testing:
- `public.memories` exists and RLS is enabled.
- `public.memories` lifecycle CHECK permits `CANDIDATE`, `ACTIVE`, `UPDATED`, `SUPERSEDED`, `ARCHIVED`, `DEACTIVATED`, and `DELETED`.
- `public.memory_knowledge_eligibility` exists as a view.
- The view exposes `knowledge_candidate` as `scope = 'GENERAL' AND occurrence_count >= 5` for `CANDIDATE` / `ACTIVE` memories.
- Four owner-scoped `authenticated` RLS policies exist on `public.memories`: SELECT, INSERT, UPDATE, DELETE.
- Live database currently contains 2 accounts, 2 SH instances, and 0 persistent memory rows after cleanup.

### Test evidence

Synthetic memory ID: `cf7ca417-ea1c-4b1a-9ef8-289eaaa94ca8`
Replacement synthetic memory ID: `1adf2fef-be14-40c7-a385-14974b1bb1a3`

Observed transitions:

`CANDIDATE → ACTIVE → UPDATED → ARCHIVED → SUPERSEDED`

The superseded predecessor correctly referenced the replacement through `superseded_by`.

The knowledge eligibility view returned `knowledge_candidate = true` when the temporary memory was `GENERAL`, `ACTIVE`, and `occurrence_count = 5`.

Both synthetic rows were subsequently deleted, and a final live query returned:

`memory_count = 0`

`test_residue = 0`

No test data remains in the database.

## Verification Limitation

The lifecycle sequence was verified through the Supabase SQL execution path, which is database-level verification and not application/API-level runtime verification under a real authenticated client session.

The RLS policy boundary itself was independently inspected in live Supabase, but this checkpoint does not claim a fresh two-account application-level end-to-end lifecycle test.

This is a deferred runtime/security assurance item and does not require architectural change for the current backlog slice.

## Verdict

**PASS — DATABASE LIFECYCLE TESTING VERIFIED**

**APPLICATION/API-LEVEL RUNTIME ASSURANCE — DEFERRED**

No minimal realization was necessary.

## Follow-up

Formal application/API-level lifecycle testing should be included in the applicable runtime/security assurance stage, while this evidence establishes that the implemented database memory lifecycle supports the required create/update/archive/supersede/delete sequence without leaving test residue.
