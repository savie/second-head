# EV-P4B-002 — Reasoning Process Evidence Logging

Status: DEV IMPLEMENTED / ACCEPTANCE-LEVEL VERIFICATION
Phase: 4 — Runtime & Orchestration
Item: P4B-002

## Scope

P4B-002 adds bounded traceability for each reasoning cycle:

`isolated context → model input → model output / failure`

The evidence path records metadata and bounded hashes rather than raw user/context/model content.

## Reconciliation

- Reuses the P4A-004 audit persistence boundary.
- Reuses the existing `RUNTIME_RESPONSE` audit event type; no new audit schema/event type is required.
- Does not mutate SH identity, ownership, privacy, or security authority.
- Reasoning remains separate from Model and has no Memory/Knowledge mutation capability.
- Raw user message, raw context entries, raw model output, and raw provider error messages are not persisted by P4B-002.
- Account ownership remains resolved by the authenticated audit persistence layer rather than being synthesized by reasoning.

## DEV Implementation

GitHub:
- `runtime/p4b/reasoning_context.ts`
- `runtime/p4b/reasoning_evidence.test.ts`
- `docs/evidence/EV-P4B-002_REASONING_EVIDENCE_LOGGING.md`

The reasoning boundary emits two bounded evidence phases for a successful cycle:
- `MODEL_INPUT`
- `MODEL_OUTPUT`

A model failure emits:
- `MODEL_INPUT`
- `MODEL_OUTPUT` with `FAILED` status and error type only.

Evidence metadata includes:
- `evidence_version`
- `stage=reasoning`
- bounded `context_hash`
- context entry count
- bounded `output_hash` on successful output

## Acceptance-Level Verification

The test verifies:
- one reasoning cycle produces input/output evidence;
- SH identity is preserved;
- evidence contains hashes rather than raw context/output;
- model failure produces bounded failure evidence;
- raw error message is not persisted.

Supabase DEV already contains the P4A-004 `audit_events` persistence boundary and `runtime_record_audit(...)`; P4B-002 reuses that existing boundary rather than creating another audit table.

## Assurance Limitation

Application/API/UI E2E and real-provider runtime assurance are not claimed as PASS here. The P4B reasoning evidence contract is verified at the implementation/test boundary. This deferred assurance is not treated as implementation failure when the acceptance item is satisfied at the applicable verifiable level.
