# EV-P4A-010 — Runtime Request Contract

Status: DEV IMPLEMENTED / ACCEPTANCE-LEVEL VERIFIED

Traceability note: The original Phase 4 Analysis Report explicitly defined P4A-001 through P4A-003. P4A-010 is an engineering slice added during execution to harden the Runtime Pipeline request boundary; it is not retroactively claimed as an item from the original report.

## Scope

Define the smallest safe request boundary before Runtime orchestration:

- request_id is required;
- authenticated auth_uid is required;
- user_message must be non-empty;
- user_message is bounded to 32,000 characters;
- malformed or unauthenticated requests fail closed.

## Reconciliation

PASS. No canonical, identity, ownership, privacy, security, model, tool, action, or core-governance invariant is changed.

This is minimal realization of the Runtime Pipeline input boundary. It does not create SH identity, select a model, invoke tools/actions, or persist memory.

## Assurance

Unit-testable acceptance is included in `runtime/p4a/runtime_request_contract.test.ts`.
Application/API/UI E2E and real-model assurance remain deferred and are not claimed as PASS here.

## DEV

GitHub DEV implementation committed across:
- `runtime/p4a/runtime_request_contract.ts`
- `runtime/p4a/runtime_request_contract.test.ts`

Supabase DEV function: `runtime-p4a-010`.
