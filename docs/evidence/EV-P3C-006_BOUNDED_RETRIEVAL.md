# EV-P3C-006 — Bounded Retrieval Evidence

## Backlog Item
`BL-P3C-006 — Bounded Retrieval`

## Acceptance Criterion
`AC-MEM-18`

## Result
**PASS — BOUNDED + DETERMINISTIC RETRIEVAL EXECUTION**

## Audit Basis

Phase -1 was used as the execution-control starting point.

The current P3C implementation chain is:

`QUERY → RETRIEVE → FILTER → RANK → VALIDATE → CONTEXT`

Existing completed boundaries:

- P3C-001 — retrieval strategy;
- P3C-002 — relevance scoring;
- P3C-003 — deterministic ranking;
- P3C-004 — filtering;
- P3C-005 — Memory → request-scoped Context injection.

P3C-006 was reconciled as the smallest executable composition of those existing contracts with an explicit result bound.

No new Owner Decision was required for this realization because it does not change canonical invariants, ownership/privacy boundaries, or the fundamental P3C architecture.

## GitHub Audit

Relevant existing artifacts audited on `dev`:

- `docs/design/P3C_RETRIEVAL_STRATEGY_v1.0.md`
- `docs/design/P3C_RELEVANCE_SCORING_v1.0.md`
- `docs/design/P3C_RANKING_v1.0.md`
- `docs/design/P3C_FILTERING_v1.0.md`
- `docs/design/P3C_CONTEXT_INJECTION_v1.0.md`
- current Phase -1 document
- existing P3C evidence artifacts

The existing design artifacts explicitly reserve bounded retrieval execution for BL-P3C-006 and do not define a second retrieval architecture.

## Reconciliation Finding

The required behavior could be realized without:

- a new Memory table;
- a new Knowledge table;
- a new Context table;
- a new RLS model;
- a new sharing/inheritance model;
- a second relevance-scoring system;
- a second ranking system.

The minimal realization is one `SECURITY INVOKER` database function that:

1. restricts candidates to the requested SH scope;
2. applies the existing P3C-004 lifecycle filter;
3. reuses the existing P3C-002 relevance score;
4. applies the exact P3C-003 deterministic ordering;
5. applies a bounded result limit.

## Implemented Function

`public.retrieve_memories_bounded(uuid, text, integer)`

Behavior:

```text
SH SCOPE
  ↓
CANDIDATE / ACTIVE / UPDATED
  ↓
RELEVANCE SCORE
  ↓
UPDATED_AT / OCCURRENCE / MEMORY_ID TIE-BREAKS
  ↓
LIMIT 1..50
```

Default limit:

`20`

Maximum limit:

`50`

The requested limit is normalized into the safe range `1..50`.

## Deterministic Ordering Verification

Synthetic live-database rows were used.

For query `camera` and bound `2`, the function returned exactly two rows:

| Memory | Relevance |
|---|---:|
| `00000000-0000-0000-0000-000000000001` | `0.2` |
| `00000000-0000-0000-0000-000000000002` | `0.1` |

The synthetic `SUPERSEDED` row was not returned.

The candidate belonging to the other SH was not returned because the function explicitly restricts by `p_sh_id`.

The observed order matched the existing deterministic ranking contract.

## Bound Verification

A second live test inserted `55` synthetic eligible Memory rows and requested `p_limit = 100`.

Observed:

`returned_rows = 50`

Therefore the hard maximum bound is effective and the function cannot return more than 50 rows per invocation through this contract.

All synthetic rows were deleted after verification.

Final live Memory residue:

`memory_count = 0`

## Security Verification

Live database inspection confirmed:

- function is `SECURITY INVOKER`;
- `anon` does not have EXECUTE permission;
- `authenticated` has EXECUTE permission;
- `service_role` retains its existing administrative capability;
- existing owner-scoped RLS policies on `public.memories` remain unchanged.

The function does not use `SECURITY DEFINER` and does not weaken the existing ownership boundary.

## Supabase Migration State

Applied development migrations include:

- `20260811170220_bounded_memory_retrieval`
- `20260811170253_harden_bounded_memory_retrieval_grants`

These migrations are also committed to the repository under:

`database/migrations/`

## OQ Boundary

This realization does not silently close OQ-02, OQ-03, or OQ-04.

Those formal documentation statuses remain governed by the latest reconciled project authority/decision record.

P3C-006 only uses already-established Memory and retrieval semantics and therefore does not treat the historical OPEN wording as a practical blocker for this implementation.

## Verification Limitation

The bounded retrieval function and deterministic result behavior were verified against the live development database with synthetic data.

A full authenticated application/API E2E test demonstrating a real client invocation through the application runtime was not available in the current repository/runtime surface.

Therefore:

`IMPLEMENTATION = PASS`

`RUNTIME / APPLICATION E2E ASSURANCE = DEFERRED`

No runtime result is fabricated.

## Final Status

**BL-P3C-006 = PASS / DEV**

**RUNTIME / APPLICATION E2E RETRIEVAL ASSURANCE = DEFERRED**

**Persistent synthetic residue = NONE**
