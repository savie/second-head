# EV-P3C-004 — Filtering Logic Evidence

## Backlog Item
`BL-P3C-004 — Filtering Logic`

## Acceptance Criterion
`AC-MEM-16`

## Result
**PASS — REPOSITORY DESIGN + LIVE DATABASE FILTERING PRIMITIVE VERIFIED**

## Audit Basis

Phase -1 remains the execution-control starting point.

P3C-001 established the pipeline:

`QUERY → RETRIEVE → FILTER → RANK → VALIDATE → CONTEXT`

P3C-002 supplies relevance scoring.

P3C-003 supplies deterministic ranking.

P3C-004 supplies candidate filtering before ranking.

No new Owner Decision was required for this realization because the filtering rule uses existing Memory lifecycle, scope, visibility, and ownership semantics without changing canonical invariants, privacy boundaries, ownership boundaries, or fundamental architecture.

## GitHub Audit

Current `dev` state was audited before realization.

Relevant existing artifacts:

- `docs/design/P3C_RETRIEVAL_STRATEGY_v1.0.md`
- `docs/design/P3C_RELEVANCE_SCORING_v1.0.md`
- `docs/design/P3C_RANKING_v1.0.md`
- `docs/evidence/EV-P3C-002_REPOSITORY_RUNTIME_RECONCILIATION.md`
- `docs/evidence/EV-P3C-003_RANKING_MECHANISM.md`
- current Phase -1 artifact
- existing Memory schema migration

No existing P3C-004 filtering artifact was present.

## Reconciliation Finding

The existing Memory foundation already contains all fields needed for a minimal filtering contract:

- `sh_id`
- `scope`
- `visibility`
- `lifecycle`

The existing owner-scoped RLS policies enforce the authorization boundary.

The P3C retrieval strategy explicitly assigns lifecycle, ownership/SH scope, and visibility/privacy constraints to the FILTER stage.

No new table, column, policy, function, index, or authorization architecture is necessary.

## Filtering Rule Implemented

For an already-authorized candidate set:

```sql
WHERE lifecycle IN ('CANDIDATE', 'ACTIVE', 'UPDATED')
```

Excluded terminal/ineligible states:

- `SUPERSEDED`
- `ARCHIVED`
- `DEACTIVATED`
- `DELETED`

`PRIVATE` and `GENERAL` remain valid memory scopes.

`OWNER_ONLY` and `SHARED` remain valid visibility values inside the authorized SH boundary.

The `SHARED` value does not create cross-SH access. The existing ownership/RLS boundary remains authoritative.

`GENERAL` does not mean globally accessible and is not treated as an authorization bypass.

## Supabase Live Verification

Project:
`second-head`

Project ref:
`pkhkgvsrqeupvwoqjwmd`

Branch:
`dev`

The live database was inspected for:

- `public.memories` schema;
- lifecycle CHECK constraint;
- scope CHECK constraint;
- visibility CHECK constraint;
- owner-scoped RLS policies;
- current persistent memory count.

Current persistent memory count at verification time:

`0`

### Synthetic Filtering Test

A non-persistent `WITH ... VALUES` candidate set was used so no database rows were inserted or mutated.

Synthetic lifecycle candidates covered all seven implemented lifecycle states.

Observed eligibility using:

`lifecycle IN ('CANDIDATE','ACTIVE','UPDATED')`

| Lifecycle | Candidate | Eligible |
|---|---:|---:|
| CANDIDATE | 1 | 1 |
| ACTIVE | 1 | 1 |
| UPDATED | 1 | 1 |
| SUPERSEDED | 1 | 0 |
| ARCHIVED | 1 | 0 |
| DEACTIVATED | 1 | 0 |
| DELETED | 1 | 0 |

The synthetic set also exercised both existing scope values and both existing visibility values without introducing any cross-owner access semantics.

No persistent test rows were created.

## Security / Governance Boundary

The filtering contract does not:

- authorize access;
- bypass RLS;
- retrieve another SH's memory;
- treat GENERAL as public;
- treat SHARED as cross-SH authorization;
- change ownership;
- change privacy boundaries;
- promote Memory to Knowledge;
- inject context;
- alter ranking;
- create clone/inheritance behavior.

## OQ Boundary

This implementation does not silently close OQ-02, OQ-03, or OQ-04.

It only realizes the current filtering backlog using already-established Memory semantics and existing ownership/security boundaries.

Formal document status for those OQs remains whatever the authority currently records; that documentation status is not treated as a blocker for this specific realization because no material contradiction was introduced.

## Verification Limitation

The filtering predicate and its database-level behavior were verified using synthetic SQL input.

This does not claim full application/API end-to-end retrieval assurance under a real authenticated client flow. That remains downstream assurance scope.

## Final Status

**BL-P3C-004 = PASS / DEV**

**RUNTIME / APPLICATION E2E RETRIEVAL ASSURANCE = DEFERRED**

No schema or policy mutation was required.
