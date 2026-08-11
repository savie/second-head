# EV-P3C-002 — Relevance Scoring Evidence

## Backlog Item
BL-P3C-002 — Relevance Scoring

## Acceptance Criterion
AC-MEM-14

## Result
**PASS — IMPLEMENTATION + LIVE DATABASE PRIMITIVE VERIFIED**

## Audit Basis
Phase -1 is the execution-control starting point. It requires the applicable backlog/AC to be satisfied, prohibits silent invention of missing decisions, and requires evidence for completion.

P3C-001 already established the retrieval pipeline:

`QUERY → RETRIEVE → FILTER → RANK → VALIDATE → CONTEXT`

P3C-002 is limited to producing the relevance score consumed by downstream ranking.

## GitHub Verification

Verified on `dev`:

- `docs/design/P3C_RETRIEVAL_STRATEGY_v1.0.md`
- `docs/design/P3C_RELEVANCE_SCORING_v1.0.md`
- current Phase -1 artifact
- existing P3C evidence

The P3C-001 strategy explicitly leaves scoring to BL-P3C-002 and ranking to BL-P3C-003.

## Supabase Live Verification

Project: `second-head`

The live `dev` database was verified before and after realization.

Existing Memory foundation remains intact:

- `public.memories` exists;
- Memory ownership is represented by `sh_id`;
- existing RLS/ownership policies remain in place;
- no persistent test memory rows were required for the scoring primitive.

Minimal realization added:

`public.memory_relevance_score(query_text text, memory_content text) -> numeric`

Implementation:

```text
least(1.0,
  ts_rank_cd(
    to_tsvector('simple', memory_content),
    plainto_tsquery('simple', query)
  )
)
```

Properties:

- immutable;
- parallel safe;
- deterministic;
- normalized to `[0,1]`.

## Live Test

The live function was invoked directly with synthetic text inputs.

| Query | Memory | Result |
|---|---|---:|
| automotive engine maintenance | Automotive engine maintenance basics and oil change | 0.1 |
| automotive engine maintenance | Gardening tips for indoor plants | 0 |
| empty query | Any memory text | 0 |

Observed behavior satisfies the intended primitive boundary:

- relevant lexical overlap → positive score;
- unrelated content → zero in the tested case;
- empty query → zero.

## Security Boundary

The scoring primitive does not:

- authorize memory access;
- bypass RLS;
- retrieve records;
- filter candidates;
- rank candidates;
- inject context;
- promote Memory to Knowledge;
- alter ownership or visibility.

## Verification Limitation

This evidence proves the live scoring primitive and its deterministic behavior for the tested inputs.

Full retrieval/ranking integration is intentionally deferred to downstream P3C items:

- P3C-003 — Ranking
- P3C-004 — Filtering
- P3C-005 — Context Injection
- P3C-006 — Bounded Retrieval
- P3C-007 — Retrieval Testing

## Final Status

**BL-P3C-002 = PASS / DEV**
