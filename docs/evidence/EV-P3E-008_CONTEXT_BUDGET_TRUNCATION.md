# EV-P3E-008 — Context Budget & Truncation

## Backlog

`BL-P3E-008`

## Acceptance Criteria

`AC-CTX-08`

## Verification Date

2026-08-12

## Result

`PASS / DEV`

## Reconciliation

Audit of existing P3E context assembly and P3C bounded retrieval found that each source was already bounded, but the existing assembly point accepted independent Memory and Knowledge limits. Two requests of 50 could therefore theoretically produce up to 100 context records.

The minimal realization was to retain the existing `public.assemble_context(...)` function and add a deterministic combined Context budget of 50 records maximum.

No new Context table, storage layer, retrieval engine, ranking engine, schema, RLS policy, ownership boundary, or privacy mechanism was introduced.

## Budget Policy Verified

- default Memory limit: 10
- default Knowledge limit: 10
- default combined Context budget: 20
- requested per-source limits normalized to 1..50
- combined assembly budget capped at 50
- Memory receives budget first according to P3E-003 prioritization
- Knowledge receives the remaining budget
- Memory is capped at 49 so the Knowledge retrieval function's existing minimum limit of 1 cannot exceed the combined 50-record bound

## Truncation Behavior

Truncation is performed by the existing bounded retrieval functions after their established filtering, scoring, and deterministic ordering.

The P3E-008 layer does not mutate source records. Records not selected for the current Context invocation remain intact in Memory/Knowledge storage.

## Supabase DEV Verification

Live `public.assemble_context(uuid,text,integer,integer)` definition was inspected and confirmed to contain the combined budget allocation logic.

Invocation verification on the live DEV database returned valid Context envelopes for default and maximum requested limits. The current DEV database contains no matching test data for the verification query, so array counts were `0` for those invocations. This confirms callable behavior but does not claim a populated-data truncation stress test.

## Security / Boundary

`assemble_context(...)` remains `SECURITY INVOKER` and `STABLE`.

Existing P3C bounded retrieval and existing Memory/Knowledge authorization boundaries remain in force.

Invariant preserved:

`MEMORY ≠ KNOWLEDGE ≠ CONTEXT`

## Deferred Assurance

No application/model-level tokenizer or end-to-end token-budget test was performed.

`IMPLEMENTATION / DATABASE = PASS`

`APPLICATION / MODEL TOKEN-BUDGET ASSURANCE = DEFERRED`

## GitHub Artifacts

Design:

`docs/design/P3E_CONTEXT_BUDGET_TRUNCATION_v1.0.md`

Migration:

`supabase/migrations/20260812190000_p3e_008_context_budget_truncation.sql`

## Final State

`BL-P3E-008 = PASS / DEV`
