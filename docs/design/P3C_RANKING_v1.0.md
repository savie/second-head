# SECOND HEAD — P3C Ranking Mechanism v1.0

## Status
IMPLEMENTED — BL-P3C-003 / AC-MEM-15

## Scope
This document realizes **BL-P3C-003 — Ranking Mechanism** only.

It consumes the relevance score produced by BL-P3C-002 and defines deterministic ordering of an already-available candidate set.

It does not implement retrieval, authorization/filtering, context injection, bounded retrieval execution, or retrieval testing as a whole.

## Pipeline Boundary

P3C-001 established:

`QUERY → RETRIEVE → FILTER → RANK → VALIDATE → CONTEXT`

P3C-002 supplies the relevance score.

P3C-003 supplies the ordering rule.

P3C-004 remains responsible for filtering.
P3C-005 remains responsible for Memory → Context injection.
P3C-006 remains responsible for bounded retrieval execution.
P3C-007 remains responsible for retrieval testing.

## Deterministic Ranking Rule

Eligible candidate rows are ordered lexicographically by:

```sql
ORDER BY
  relevance_score DESC,
  updated_at DESC,
  occurrence_count DESC,
  memory_id ASC
```

Meaning:

1. **Relevance first** — the candidate most relevant to the current query/context is preferred.
2. **Recency second** — when relevance is tied, the more recently updated memory is preferred.
3. **Occurrence third** — when relevance and recency are tied, the memory with higher occurrence count is preferred.
4. **Stable identity tie-breaker** — when all preceding values are tied, `memory_id ASC` provides a deterministic final order.

This is a lexicographic ranking rule, not a weighted composite score. No arbitrary weighting constant is introduced.

## Rationale / Owner Discussion Alignment

The ranking rule follows the current implementation discipline discussed for SH retrieval:

- current query/context relevance is the primary signal;
- nearby/recently updated memory is preferred when relevance is equal;
- older information remains available as a lower-ranked candidate;
- repeated occurrence can break a remaining tie without overriding relevance or recency;
- the mechanism does not attempt to infer specialist/generalist behavior or introduce a new memory architecture.

The broader conversational behavior around specialist knowledge, context-first recall, and deeper historical digging remains a higher-level runtime/context concern and is not silently converted into a new P3C-003 policy.

## Determinism

The ordering is fully specified. The final `memory_id ASC` tie-breaker prevents equal ranking keys from falling back to unspecified database row order.

PostgreSQL does not guarantee row order without an explicit `ORDER BY`; multiple sort expressions are applied lexicographically, with later expressions breaking ties from earlier expressions.

## Security / Governance Boundary

P3C-003 does not:

- authorize memory access;
- bypass RLS;
- change ownership;
- change visibility;
- decide filtering eligibility;
- promote Memory to Knowledge;
- inject context;
- persist request-scoped context;
- create a new sharing or inheritance model.

Owner isolation remains the responsibility of the existing Memory/RLS layer and the downstream retrieval implementation.

## Minimal Realization Decision

No new table, column, index, authorization policy, or ranking-specific database function is required for this backlog item.

The ranking mechanism is a query-level ordering contract that consumes the existing P3C-002 relevance primitive and existing Memory fields.

This avoids creating a parallel ranking architecture before the actual bounded retrieval execution item (BL-P3C-006).

## Live Verification Shape

The mechanism is verified against synthetic candidate rows using the live development database and the existing `public.memory_relevance_score(...)` primitive.

Expected precedence:

```text
relevance_score
      ↓ tie
updated_at
      ↓ tie
occurrence_count
      ↓ tie
memory_id
```

## Explicit Non-Goals

This item does NOT introduce:

- embeddings;
- vector search;
- a new Memory table;
- a new Knowledge table;
- a new retrieval API;
- a new filtering policy;
- a new context budget;
- a new authorization model;
- weighted relevance/ranking coefficients;
- specialist-mode or generalist-mode ranking policy;
- automatic Knowledge promotion.
