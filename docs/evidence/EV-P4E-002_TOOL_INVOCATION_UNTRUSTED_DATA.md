# EV-P4E-002 — Tool Invocation & Untrusted Data Boundary

Project: SECOND HEAD — SYSTEM BUILD
Phase: 4 — Runtime & Orchestration
Status: PASS / DEV

## Acceptance

P4E-002 requires authorized tool calls to be executed while treating returned tool content as untrusted external data. Tool output must not become system authority merely because a tool returned it.

## Realization

- `runtime/p4e/tool_registry.ts` remains the authorization/invocation boundary from P4E-001.
- `runtime/p4e/tool_result_boundary.ts` wraps an authorized tool result as:
  - `source = TOOL`
  - `trust = UNTRUSTED_EXTERNAL_DATA`
  - `tool_id = <registered tool>`
  - `data = returned content`
- No field in the wrapper promotes returned content to system/developer authority.
- The boundary does not interpret tool content as instructions.
- Empty/invalid tool identity is rejected.

## Verification

Test artifact:
`runtime/p4e/tool_result_boundary.test.ts`

Verified cases:
1. normal tool output remains explicitly untrusted;
2. malicious-looking instruction/authority fields remain data and do not change trust;
3. empty tool identity is rejected.

## Scope / Assurance

This is a boundary-level implementation verification. It does not claim full external-tool integration or application/UI E2E assurance.

No Supabase schema mutation is required for P4E-002.

## Result

P4E-002 = PASS / DEV

Commit:
`1bd244eb0696c042ae465f96d968ed5130aaf537`
