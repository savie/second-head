# SECOND HEAD — P3C Relevance Scoring v1.0

## Status
IMPLEMENTED — BL-P3C-002 / AC-MEM-14

## Scope
This document realizes **BL-P3C-002 — Relevance Scoring** only.

It does not implement ranking order, filtering policy, context injection, bounded retrieval execution, or retrieval testing beyond the direct scoring primitive verification documented in EV-P3C-002.

## Strategy Boundary
P3C-001 established:

`QUERY → RETRIEVE → FILTER → RANK → VALIDATE → CONTEXT`

P3C-002 supplies the **relevance score** consumed by downstream ranking. It does not decide final ordering.

## Scoring Primitive

The implementation uses a deterministic PostgreSQL full-text lexical score:

```text
score = min(1.0, ts_rank_cd(to_tsvector('simple', memory), plainto_tsquery('simple', query)))
```

Properties:

- deterministic for the same query/content inputs;
- normalized to `[0,1]`;
- empty query produces `0`;
- unrelated content produces `0` under the tested inputs;
- lexical overlap produces a positive score under the tested inputs.

## Security / Governance Boundary

The scoring function does NOT:

- authorize access;
- bypass RLS;
- retrieve another SH's memory;
- filter candidates;
- rank the candidate set;
- inject context;
- promote Memory to Knowledge;
- change ownership or visibility.

Authorization and privacy remain governed by the existing Memory/RLS layer.

## Runtime Primitive

Supabase function:

`public.memory_relevance_score(query_text text, memory_content text) -> numeric`

The function is `IMMUTABLE` and `PARALLEL SAFE`.

## Explicit Non-Goals

This item does NOT introduce:

- embeddings;
- vector search;
- a new Memory table;
- a new Knowledge table;
- a new authorization model;
- a new ownership model;
- a ranking algorithm;
- a filtering policy;
- context persistence.
