# SECOND HEAD — P3C Filtering Logic v1.0

## Status
IMPLEMENTED — BL-P3C-004 / AC-MEM-16

## Scope
This document realizes **BL-P3C-004 — Filtering Logic** only.

It defines the candidate-eligibility filter applied between retrieval and ranking in the existing P3C pipeline:

`QUERY → RETRIEVE → FILTER → RANK → VALIDATE → CONTEXT`

It does not implement ranking, context injection, bounded retrieval execution, or retrieval testing as a whole.

## Authority / Reconciliation

The existing P3C retrieval strategy already requires filtering as a separate stage and explicitly identifies these applicable constraints:

- ownership / SH scope;
- lifecycle eligibility;
- visibility / privacy boundary;
- other applicable policy constraints.

The existing Memory schema already contains the required fields and CHECK constraints for `scope`, `visibility`, and `lifecycle`. Existing owner-scoped RLS remains the authorization boundary.

No new architecture, table, column, authorization policy, sharing model, or canonical rule is introduced by this item.

Where older planning material still describes Memory/Knowledge OQs as formally open, this implementation does not silently close those OQs. It only realizes the filtering behavior required by the current backlog using already-established Memory semantics and existing security boundaries.

## Filtering Contract

### 1. Authorization boundary

Filtering MUST operate only on candidates already within the authorized SH scope.

The filter is not an authorization mechanism and must not weaken or replace the existing owner-scoped RLS boundary.

### 2. Lifecycle eligibility

The default retrieval-eligible lifecycle states are:

- `CANDIDATE`
- `ACTIVE`
- `UPDATED`

The following lifecycle states are excluded from retrieval candidates:

- `SUPERSEDED`
- `ARCHIVED`
- `DEACTIVATED`
- `DELETED`

Rationale: CANDIDATE, ACTIVE, and UPDATED represent non-terminal memory states that may still participate in the retrieval pipeline. The excluded states represent superseded, archived, deactivated, or deleted memory and therefore must not proceed as retrieval candidates.

Filtering does not promote a CANDIDATE to ACTIVE and does not validate it for context injection. Those concerns remain downstream.

### 3. Scope and visibility

Both existing scope values remain eligible within the authorized SH:

- `PRIVATE`
- `GENERAL`

Both existing visibility values remain representable within the authorized SH:

- `OWNER_ONLY`
- `SHARED`

Filtering does not reinterpret visibility as authorization. Cross-SH access is not created by the `SHARED` value; access remains constrained by the existing ownership/RLS boundary and any future sharing mechanism.

Likewise, `GENERAL` does not mean globally accessible. It is a memory classification, not an authorization bypass.

### 4. No implicit policy expansion

The filter MUST NOT:

- expose another SH's memory;
- treat GENERAL as public;
- treat SHARED as permission to cross an ownership boundary;
- promote Memory to Knowledge;
- change lifecycle state;
- create a new sharing/inheritance mechanism;
- add a new relevance or ranking policy.

## Minimal Query Shape

For an already-authorized candidate set, the lifecycle filter is:

```sql
WHERE lifecycle IN ('CANDIDATE', 'ACTIVE', 'UPDATED')
```

The authorized SH constraint remains enforced by the existing retrieval scope and `public.memories` owner-scoped RLS.

The ranking order remains the P3C-003 contract and is not duplicated here.

## Existing Preconditions Verified

The live development database contains:

- `public.memories`;
- `scope` with `PRIVATE` / `GENERAL` CHECK constraint;
- `visibility` with `OWNER_ONLY` / `SHARED` CHECK constraint;
- lifecycle CHECK constraint covering all seven implemented lifecycle states;
- owner-scoped SELECT/INSERT/UPDATE/DELETE RLS policies;
- existing P3C-002 relevance scoring primitive;
- existing P3C-003 deterministic ranking contract.

No schema mutation is required for BL-P3C-004.

## Explicit Non-Goals

This item does NOT introduce:

- a new retrieval API;
- a new database table;
- a new filtering function;
- a new authorization model;
- cross-SH sharing;
- clone/inheritance behavior;
- Knowledge ingestion;
- Reference Material Trust Promotion;
- context injection;
- bounded retrieval;
- application/API E2E retrieval assurance.
