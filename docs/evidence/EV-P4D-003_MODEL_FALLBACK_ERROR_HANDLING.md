# EV-P4D-003 — Model Fallback & Error Handling

## Status

PASS / DEV

## Scope

Phase 4 — Runtime & Orchestration

Backlog: P4D-003 — Model Fallback & Error Handling

## Acceptance

- Primary model is attempted first.
- Eligible secondary model can be used when primary execution fails.
- Zero-budget policy remains enforced by default.
- If all eligible candidates fail, runtime receives a structured model execution error rather than an unhandled provider failure.
- Model fallback remains independent from SH identity.

## Implementation

Artifact:

- `runtime/p4d/model_fallback.ts`
- `runtime/p4d/model_fallback.test.ts`

The fallback boundary executes candidates deterministically in the supplied order. Candidate eligibility is filtered by capability and, by default, `ZERO_BUDGET` cost tier. Provider failures are contained within the fallback loop. A successful secondary execution is returned with `fallback_used = true` and attempted model IDs. If no eligible candidate succeeds, a structured `MODEL_EXECUTION_FAILED` result is returned.

## Verification

The test suite covers:

1. primary failure followed by successful secondary fallback;
2. preservation of zero-budget policy during fallback;
3. structured failure when all eligible candidates fail;
4. absence of SH identity input or mutation from the fallback boundary.

## Reconciliation

P4D-001 provides the provider-independent model boundary.

P4D-002 provides deterministic model selection and the default zero-budget path.

P4D-003 extends those boundaries without changing SH identity, ownership, privacy, or the Phase 4 runtime architecture.

No Supabase schema mutation is required for this backlog item; fallback state is execution-local and the existing audit/runtime boundaries remain authoritative.

## Assurance Limitation

This evidence verifies the P4D-003 implementation contract at the model execution boundary. Full external-provider/application/UI E2E assurance remains deferred until a real provider integration and corresponding application-level test path are onboarded.
