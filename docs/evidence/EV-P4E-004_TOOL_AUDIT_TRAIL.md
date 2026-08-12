# EV-P4E-004 — Tool Audit Trail

Status: PASS / DEV
Phase: Phase 4 — Runtime & Orchestration
Backlog: P4E-004

## Acceptance

Every tool invocation path is auditable without creating a new authority layer.

The audit record captures:

- `ACTOR_ID` via `metadata.actor_id`;
- `SH_ID` via `audit_events.sh_id`;
- `TOOL_ID` via `metadata.tool_id`;
- `RESULT_HASH` via `metadata.result_hash`;
- invocation status (`SUCCESS`, `REJECTED`, `FAILED`).

## GitHub implementation

- `runtime/p4e/tool_registry.ts` now requires an audit sink and records tool invocation outcomes.
- Successful tool output is hashed with SHA-256 before the audit event is written.
- Rejected invocations and tool execution failures are also recorded.
- `runtime/p4e/tool_registry.test.ts` contains verification for success, rejection, failure, actor/tool identity and 64-character SHA-256 result hashes.
- Existing `runtime/p4a/runtime_audit_persistence.ts` was minimally extended with the `TOOL_INVOCATION` event type; no new authority, identity, ownership or permission model was introduced.

## Supabase DEV verification

Existing `public.audit_events` was reused; no new audit table was created.

Migration applied:

`p4e_004_tool_invocation_audit_event`

The live `audit_events_event_type_check` now permits:

- `RUNTIME_REQUEST`
- `RUNTIME_RESPONSE`
- `RUNTIME_MEMORY_DECISION`
- `TOOL_INVOCATION`

A transactional DEV insert verified that `TOOL_INVOCATION` accepts the expected status and metadata fields including `tool_id` and `result_hash`. The verification transaction was rolled back; persistent test residue: NONE.

## Boundary verification

- `ToolRegistry` remains deny-by-default.
- Tool registration does not grant authority.
- Tool result remains data; it is only hashed for audit and is not promoted to system instruction.
- Audit persistence does not mutate SH identity or ownership.
- Existing ownership/RLS boundary on `audit_events` remains unchanged.

## Assurance note

Application/UI E2E execution of a real external tool is not part of this verification. The implementation contract for P4E-004 is satisfied at the runtime boundary and database persistence level; broader application/E2E assurance remains deferred.

## Result

P4E-004 = PASS / DEV
