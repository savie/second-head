# SECOND HEAD — P3C Context Injection v1.0

## Status
IMPLEMENTED — BL-P3C-005 / AC-MEM-17

## Scope
This document realizes **BL-P3C-005 — Context Injection** only.

It defines the minimal boundary between the validated, ranked Memory retrieval output and the request-scoped Context layer in the existing P3C pipeline:

`QUERY → RETRIEVE → FILTER → RANK → VALIDATE → CONTEXT`

It does not implement bounded retrieval execution, retrieval testing as a whole, persistent Context storage, a new Knowledge system, or a new authorization model.

## Authority / Reconciliation

P3C-001 already defines that validated retrieval output becomes input to the request-scoped Context layer and explicitly states that Context is not persistent Memory.

The canonical SH Core also defines Context as the mechanism that assembles relevant information for the current interaction and explicitly distinguishes Context from Memory.

P3C-002 supplies relevance scoring, P3C-003 supplies deterministic ranking, and P3C-004 supplies candidate filtering. P3C-005 therefore consumes their output rather than redefining those mechanisms.

No new architecture, table, column, authorization policy, sharing model, or canonical rule is introduced by this item.

Where older planning material still records Memory/Knowledge OQs as formally open, this realization does not silently close those OQs. It only defines the existing Memory → Context boundary required by the current P3C backlog using already-established semantics and security boundaries.

## Context Injection Contract

### 1. Input boundary

Context injection accepts only retrieval output that has already passed the upstream P3C stages:

- authorized SH scope;
- lifecycle / visibility / policy filtering;
- deterministic relevance ranking;
- downstream validation required by the retrieval strategy.

Context injection MUST NOT be used to retrieve additional Memory or to bypass any upstream authorization/filtering boundary.

### 2. Transformation

Validated Memory records are transformed into request-scoped Context input for the current interaction.

The transformation is non-destructive:

- Memory rows are not modified;
- Memory lifecycle is not changed;
- occurrence counts are not changed;
- Knowledge state is not changed;
- provenance is not rewritten;
- no persistent Context record is created by this backlog item.

### 3. Ordering preservation

The order produced by the upstream ranking stage is preserved when retrieval output is injected into Context.

P3C-005 therefore does not introduce a second ranking or weighting mechanism.

### 4. Memory / Context separation

Injected Context is request-scoped working input.

It is not a new persistent copy of Memory.

The invariant remains:

`MEMORY ≠ KNOWLEDGE ≠ CONTEXT`

Retrieving or injecting a Memory item into Context does not promote that Memory to Knowledge.

### 5. Ownership / privacy boundary

Context injection operates only on candidates already authorized for the current SH.

It MUST NOT:

- expose another SH's Memory;
- treat `GENERAL` as globally accessible;
- treat `SHARED` as permission to cross an ownership boundary;
- bypass existing owner-scoped RLS;
- create a new sharing or inheritance mechanism.

### 6. No automatic Core mutation

Context injection is an execution-time use of existing information.

It does not modify SH Core.

The existing invariant remains:

`Learning ≠ Automatic Core Modification`

## Minimal Context Contract

Conceptually:

```text
validated ranked Memory
        ↓
request-scoped Context items
        ↓
current interaction / model input
```

The exact runtime envelope and transport representation are intentionally left to the runtime/application layer. P3C-005 does not invent a new API contract or persistence schema merely to satisfy the backlog item.

At minimum, the Context layer must preserve enough identity/lineage to distinguish the injected item as originating from an authorized Memory record when such traceability is required by the downstream runtime.

## Existing Preconditions Verified

The current development repository already contains:

- P3C retrieval strategy;
- P3C relevance scoring;
- P3C deterministic ranking;
- P3C filtering;
- existing Memory ownership/RLS boundary;
- existing Memory lifecycle, scope, and visibility semantics.

The live development database contains `public.memories` and the existing Memory foundation. No Context table or Context-specific public database function is present.

That absence is consistent with the existing architecture because Context is request-scoped rather than persistent Memory.

## Minimal Realization Decision

No new database table, column, index, RLS policy, sharing mechanism, or persistent Context store is required for BL-P3C-005.

The minimal safe realization is a Context Injection contract at the retrieval/runtime boundary, consuming the output of P3C-004 without duplicating or mutating Memory state.

Creating a persistent Context table or a second retrieval mechanism would introduce unnecessary architecture and would blur the canonical distinction between Memory and Context.

## Explicit Non-Goals

This item does NOT introduce:

- a new Context database table;
- persistent Context storage;
- a new retrieval API;
- a new authorization model;
- cross-SH sharing;
- clone/inheritance behavior;
- Knowledge ingestion;
- Reference Material Trust Promotion;
- new relevance scoring;
- new ranking policy;
- bounded retrieval execution;
- application/API E2E retrieval assurance.
