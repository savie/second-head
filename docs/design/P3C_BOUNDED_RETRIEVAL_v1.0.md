# SECOND HEAD — P3C Bounded Retrieval v1.0

## Status
IMPLEMENTED — BL-P3C-006 / AC-MEM-18

## Scope
This document realizes **BL-P3C-006 — Bounded Retrieval** only.

It turns the existing P3C retrieval stages into a bounded, deterministic execution path without introducing a second retrieval architecture.

Existing pipeline:

`QUERY → RETRIEVE → FILTER → RANK → VALIDATE → CONTEXT`

P3C-006 provides the bounded execution at the retrieval boundary. It consumes the existing relevance scoring, ranking, and filtering contracts and does not redefine them.

## Authority / Reconciliation

The existing P3C artifacts establish separate responsibilities:

- P3C-001 — retrieval pipeline;
- P3C-002 — relevance scoring;
- P3C-003 — deterministic ranking;
- P3C-004 — candidate filtering;
- P3C-005 — Memory → request-scoped Context boundary.

The minimal realization for P3C-006 is therefore a single database retrieval function that composes those already-established rules and applies a hard result bound.

No new Memory model, Knowledge policy, sharing model, authorization model, or persistent Context architecture is introduced.

Where older planning material still records Memory/Knowledge OQs as formally open, this implementation does not silently close those OQs. It only realizes bounded retrieval using already-established semantics and existing ownership/RLS boundaries.

## Bounded Retrieval Contract

Function:

`public.retrieve_memories_bounded(p_sh_id, p_query_text, p_limit)`

Default bound:

`20` results.

Maximum bound:

`50` results.

Requested values are normalized to the safe range `1..50`.

This guarantees that one retrieval invocation cannot return an unbounded candidate set.

## Execution Order

The function composes the existing P3C rules in this order:

```text
AUTHORIZED SH SCOPE
        ↓
LIFECYCLE FILTER
        ↓
RELEVANCE SCORE
        ↓
DETERMINISTIC RANK
        ↓
BOUND / LIMIT
        ↓
RETRIEVAL OUTPUT
```

### 1. SH scope

The query is restricted to the requested `sh_id`.

The function is `SECURITY INVOKER`, so it executes with the caller's permissions. Existing owner-scoped RLS on `public.memories` remains an additional authorization boundary.

The function does not grant access to another SH.

### 2. Lifecycle filter

Only the retrieval-eligible lifecycle states established by P3C-004 are considered:

- `CANDIDATE`
- `ACTIVE`
- `UPDATED`

Excluded states remain excluded:

- `SUPERSEDED`
- `ARCHIVED`
- `DEACTIVATED`
- `DELETED`

### 3. Relevance

The existing `public.memory_relevance_score(text, text)` primitive is reused.

No second scoring system is introduced.

### 4. Deterministic ranking

The existing P3C-003 ordering is preserved exactly:

```sql
ORDER BY
  relevance_score DESC,
  updated_at DESC,
  occurrence_count DESC,
  memory_id ASC
```

The final `memory_id ASC` tie-breaker keeps the result deterministic.

### 5. Bound

The final result set is limited with:

```sql
LIMIT LEAST(GREATEST(COALESCE(p_limit, 20), 1), 50)
```

Therefore:

- omitted/null limit → 20;
- limit below 1 → 1;
- limit 1–50 → requested value;
- limit above 50 → 50.

The bound is applied after filtering and deterministic ordering, so the returned rows are the highest-ranked eligible candidates within the requested bound.

## Security / Governance Boundary

The realization preserves the existing security model:

- function uses `SECURITY INVOKER`;
- `anon` execution is revoked;
- `authenticated` execution is granted;
- existing `public.memories` owner-scoped RLS remains in force;
- the function does not use `SECURITY DEFINER`;
- no RLS policy is replaced or weakened;
- `GENERAL` is not treated as public authorization;
- `SHARED` does not create cross-SH authorization;
- no clone/inheritance behavior is introduced.

## Memory / Knowledge / Context Boundary

Retrieval does not:

- promote Memory to Knowledge;
- change occurrence count;
- change lifecycle;
- modify provenance;
- persist Context;
- modify SH Core.

The invariant remains:

`MEMORY ≠ KNOWLEDGE ≠ CONTEXT`

The function only returns existing Memory records plus their computed relevance score.

## Minimal Realization Decision

No new table, column, index, RLS policy, Knowledge store, or persistent Context store is required.

A bounded retrieval function is the smallest implementation that makes P3C-006 an actual executable retrieval boundary while reusing the already-established P3C-002/P3C-003/P3C-004 rules.

Creating another retrieval table, vector infrastructure, or separate ranking engine would be unnecessary architecture for this backlog item.

## Existing Preconditions Verified

The live development database contains:

- `public.memories`;
- owner-scoped RLS policies;
- lifecycle eligibility states;
- `(sh_id, lifecycle, updated_at DESC)` index;
- `(sh_id, occurrence_count DESC)` index;
- `public.memory_relevance_score(text,text)`;
- the existing P3C scoring/ranking/filtering contracts.

No persistent Memory rows remained after verification.

## Explicit Non-Goals

This item does NOT introduce:

- vector search;
- embeddings;
- semantic-search infrastructure;
- a new Knowledge system;
- a new Context persistence layer;
- cross-SH sharing;
- clone/inheritance behavior;
- a new ranking formula;
- a new filtering policy;
- automatic Knowledge promotion;
- application/model E2E assurance.
