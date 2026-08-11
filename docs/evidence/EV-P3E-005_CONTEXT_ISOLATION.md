# EV-P3E-005 — Context Isolation

## Backlog

`BL-P3E-005`

## Acceptance Criteria

`AC-CTX-05`

## Verification Date

2026-08-12

## Result

`PASS / DEV`

## Evidence Basis

Supabase DEV inspection verified:

1. `public.memories` has RLS enabled.
2. Memory SELECT policy `memories_owner_select` restricts access through `sh_instances.account_id = current_account_id()` for the requested `memories.sh_id`.
3. General/shared Knowledge SELECT policy `knowledge_shared_retrieval_select` restricts returned Knowledge to `scope = GENERAL`, `visibility = SHARED`, and lifecycle `INDEXED` or `ACTIVE`.
4. `public.assemble_context(...)` is `SECURITY INVOKER` (`prosecdef = false`).
5. `assemble_context(...)` passes the supplied `p_sh_id` into `retrieve_memories_bounded(...)` and separately retrieves General/Shared Knowledge through `retrieve_knowledge_bounded(...)`.
6. Context output keeps `memory` and `knowledge` as separate sections.

## Reconciliation

No schema, RLS, ownership, privacy, or retrieval mutation was required.

The existing lower-layer boundaries already provide the minimum realization for context isolation. P3E-005 therefore adds/records the context isolation contract rather than creating another isolation mechanism.

## Security Interpretation

Context isolation means source boundaries remain intact:

- SH Memory is isolated by SH/account ownership.
- General/Shared Knowledge may be reused because it is explicitly eligible for sharing.

Isolation therefore does not mean that every context item must be private; it means that private Memory cannot cross its ownership boundary merely by entering context assembly.

## Deferred Assurance

This evidence does not claim application-level adversarial cross-account E2E PASS because a full runtime identity-switching test was not executed through the available verification path.

`IMPLEMENTATION / DATABASE BOUNDARY = PASS`

`APPLICATION E2E ASSURANCE = DEFERRED`

## Final State

`BL-P3E-005 = PASS / DEV`
