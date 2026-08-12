# EV-P4E-003 — TOOL SCHEMA VALIDATION

Project: SECOND HEAD — SYSTEM BUILD
Phase: Phase 4 — Runtime & Orchestration
Backlog: P4E-003
Status: IMPLEMENTATION / DEV

## Scope

Validate tool inputs before invocation and validate/contain tool outputs before downstream use.

## Reconciliation

P4E-003 is an accepted execution decomposition in `SECOND_HEAD_PHASE_4_EXECUTION_RECONCILIATION_v1.0.md`.
The reconciliation explicitly leaves the exact schema format as an implementation-level decision.

## Minimal realization

`runtime/p4e/tool_registry.ts` now requires each registered tool to provide:

- `input_schema.validate()` before `execute()`;
- `output_schema.validate()` after `execute()` and before the result is returned downstream.

Invalid input is rejected before the tool executes.
Invalid output is rejected before downstream use.

No identity, ownership, authorization, or canonical boundary is mutated by schema validation.

## Test coverage added

`runtime/p4e/tool_registry.test.ts` covers:

1. invalid input is rejected before execution;
2. invalid output is rejected before downstream use;
3. existing DEFAULT DENY authorization behavior remains covered;
4. registered authorized tool invocation remains covered;
5. unregistered tools remain denied.

## Assurance boundary

This evidence records implementation and test coverage present in DEV.
It does not claim application/UI E2E or external-tool integration assurance.

END OF EVIDENCE
