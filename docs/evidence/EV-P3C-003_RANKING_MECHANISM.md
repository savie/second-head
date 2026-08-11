# EV-P3C-003 — Ranking Mechanism Evidence

## Backlog Item
BL-P3C-003 — Ranking Mechanism

## Acceptance Criterion
AC-MEM-15

## Result
**PASS — REPOSITORY DESIGN + LIVE DATABASE RANKING PRIMITIVE VERIFIED**

## Audit Basis

Phase -1 remains the execution-control starting point.

Phase -1 defines:

- BL-P3C-003 = Ranking Mechanism;
- dependency = BL-P3C-002;
- retrieval pipeline = `QUERY → RETRIEVE → FILTER → RANK → VALIDATE → CONTEXT`;
- evidence is required before completion.

P3C-001 explicitly leaves ranking to BL-P3C-003.
P3C-002 explicitly produces the relevance score consumed by downstream ranking and does not implement ranking.

## GitHub Audit

Current `dev` state was checked before realization.

Relevant existing artifacts:

- `docs/design/P3C_RETRIEVAL_STRATEGY_v1.0.md`
- `docs/design/P3C_RELEVANCE_SCORING_v1.0.md`
- `docs/evidence/EV-P3C-002_RELEVANCE_SCORING.md`
- `docs/evidence/EV-P3C-002_REPOSITORY_RUNTIME_RECONCILIATION.md`
- current Phase -1 artifact

No pre-existing P3C-003 ranking implementation was found.

P3C-002 reconciliation explicitly states that ranking remains downstream and that no ranking logic was introduced by P3C-002.

## Reconciliation Finding

The existing Memory foundation already provides the fields required for the minimal ranking rule:

- `updated_at`
- `occurrence_count`
- `memory_id`

The existing P3C-002 primitive provides:

- `relevance_score`

No authority, ownership, privacy, or canonical contradiction was found for using these existing fields as a deterministic lexicographic ordering contract.

No new ranking-specific architecture is necessary.

## Ranking Rule Implemented

```sql
ORDER BY
  relevance_score DESC,
  updated_at DESC,
  occurrence_count DESC,
  memory_id ASC
```

Precedence:

1. relevance score;
2. recent update time;
3. occurrence count;
4. stable memory ID tie-breaker.

This is intentionally lexicographic rather than a weighted formula.

## Supabase Live Verification

Project: `second-head`

Development project ref: `pkhkgvsrqeupvwoqjwmd`

The live database was queried using synthetic candidate rows only. No persistent memory rows were created and no schema mutation was required.

### Test A — Relevance Dominates

Query:
`automotive engine maintenance`

Observed ranking:

| Candidate | Score | Updated | Occurrences | Rank |
|---|---:|---|---:|---:|
| synthetic-001 | 0.1 | 2026-08-11 10:00 UTC | 2 | 1 |
| synthetic-002 | 0.1 | 2026-08-10 10:00 UTC | 5 | 2 |
| synthetic-003 | 0 | 2026-08-11 11:00 UTC | 9 | 3 |
| synthetic-004 | 0 | 2026-08-11 09:00 UTC | 1 | 4 |

The irrelevant candidate with the newest timestamp did not outrank relevant candidates.

Among the two relevant candidates with equal score, the more recently updated candidate ranked first.

### Test B — Occurrence Breaks Remaining Tie

Three candidates had equal relevance and equal update time.

Observed ranking:

| Candidate | Score | Updated | Occurrences | Rank |
|---|---:|---|---:|---:|
| synthetic-012 | 0.1 | 2026-08-11 10:00 UTC | 5 | 1 |
| synthetic-013 | 0.1 | 2026-08-11 10:00 UTC | 5 | 2 |
| synthetic-011 | 0.1 | 2026-08-11 10:00 UTC | 2 | 3 |

The higher occurrence count correctly outranked the lower occurrence count after relevance and recency tied.

The two fully tied candidates were resolved by `memory_id ASC`, producing a stable deterministic order.

## Database Safety

The verification used only `WITH ... VALUES` synthetic rows.

Therefore:

- no persistent test memory rows were inserted;
- no existing Memory data was modified;
- no RLS policy was changed;
- no schema mutation was required.

## Security / Governance Boundary

The ranking mechanism does not:

- authorize access;
- bypass RLS;
- retrieve another SH's memory;
- filter candidates;
- inject context;
- promote Memory to Knowledge;
- alter ownership;
- alter visibility.

Filtering remains BL-P3C-004.
Context injection remains BL-P3C-005.
Bounded retrieval execution remains BL-P3C-006.
Full retrieval testing remains BL-P3C-007.

## OQ Boundary

This implementation does **not** resolve or silently close OQ-02, OQ-03, or OQ-04.

No new Memory policy, Knowledge ingestion policy, or Reference Material Trust Promotion policy was introduced.

## Verification Limitation

This evidence verifies the deterministic ranking mechanism and its live PostgreSQL execution shape using synthetic candidate data.

It does not claim full application/API end-to-end retrieval assurance. That remains downstream and is explicitly outside this backlog item's scope.

## Final Status

**BL-P3C-003 = PASS / DEV**
