# EV-P4D-001 — MODEL ABSTRACTION LAYER

Project: SECOND HEAD — SYSTEM BUILD
Phase: 4 — Runtime & Orchestration
Backlog: P4D-001
Status: PASS / DEV
Owner DM Required: NO
Canonical Mutation: NONE
Supabase Mutation: NONE

## 1. Requirement

P4D-001 is the accepted execution decomposition for a provider-independent Model Abstraction Layer.

Required boundary:

- MODEL != SH IDENTITY
- Runtime depends on a model interface rather than a provider SDK.
- Future provider/model replacement must not require SH identity mutation.

The Phase 4 reconciliation explicitly leaves the concrete provider, routing algorithm, and secondary provider unfrozen. One provider/model path is sufficient for initial v1 execution and later expansion must remain possible.

## 2. Audit

Existing P4A runtime already accepted a model dependency through an adapter-shaped dependency, but that interface lived inside the Runtime domain and did not yet constitute an explicit P4D abstraction boundary.

P4D-001 therefore required a minimal structural realization rather than introducing a provider integration.

## 3. Minimal Realization

Added:

`runtime/p4d/model_abstraction.ts`

The abstraction defines:

- ModelCapability: text / vision / image
- ModelRequest
- ModelResponse
- ModelAdapter
- ModelExecutor
- createModelExecutor()

Provider-specific implementation remains outside the abstraction.

Runtime P4A was then routed through this P4D abstraction instead of owning the model execution contract itself.

## 4. Identity Boundary

The abstraction accepts model execution context but has no SH identity creation, mutation, or ownership capability.

Runtime continues to resolve the existing identity first and returns the resolved `sh_id` independently of model execution.

Therefore:

MODEL != SH IDENTITY

remains preserved.

## 5. Capability Boundary

The interface is capability-oriented rather than provider-oriented.

Initial supported capability vocabulary:

- text
- vision
- image

This does NOT freeze provider support or guarantee that every current provider implements every capability. It establishes the abstraction boundary needed for future model/provider replacement and modality expansion.

Tool use and consequential actions remain separate Phase 4 domains and are not introduced by P4D-001.

## 6. Verification

Static repository verification:

- P4D abstraction exists in `runtime/p4d/model_abstraction.ts`.
- P4A runtime imports and uses the abstraction.
- Provider SDK/provider name is not embedded in the abstraction.
- Model execution cannot create or mutate SH identity through the abstraction.
- Tests were added in `runtime/p4d/model_abstraction.test.ts` for adapter delegation, capability dispatch, and boundary rejection.

Execution-environment note:

The repository currently does not expose a Deno/package runner through the connected execution environment, so this session does not claim a locally executed Deno test result.

A GitHub check associated with the P4D test commit was `Supabase Preview` and failed for an unrelated repository-state reason: remote migration versions were not found in the local migrations directory. No P4D database migration was introduced and no Supabase schema mutation was required.

Therefore no E2E/runtime assurance is claimed from that check.

## 7. Supabase Cross-Check

Actual Supabase DEV inspection found the existing `audit_events` table but no model-specific table requiring mutation for P4D-001.

P4D-001 is intentionally application/runtime abstraction work and does not require a new database schema.

## 8. Reconciliation Result

RESULT: PASS / DEV

No material contradiction found.
No Owner decision required.
No canonical mutation.
No ownership/privacy/security boundary change.
No fundamental architecture redesign.
No mandatory paid provider introduced.

## 9. Next

P4D-002 — Model Selection Policy & Zero-Budget Path

This next item is where the already-decided v1 single-provider/minimal-realization policy is applied. P4D-001 deliberately does not select or hardcode that provider.

END OF EV-P4D-001
