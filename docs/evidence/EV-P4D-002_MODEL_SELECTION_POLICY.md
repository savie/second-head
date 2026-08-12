# EV-P4D-002 — MODEL SELECTION POLICY & ZERO-BUDGET PATH

Project: SECOND HEAD — SYSTEM BUILD
Phase: 4 — Runtime & Orchestration
Backlog: P4D-002
Status: PASS / DEV
Owner DM Required: NO
Canonical Mutation: NONE
Supabase Mutation: NONE

## 1. Requirement

P4D-002 applies the accepted Phase 4 execution reconciliation:

- one provider/model path is sufficient for initial v1 execution;
- the P4D-001 abstraction must permit later provider/model expansion;
- core execution must not require a mandatory paid dependency;
- no permanent provider choice is frozen by this item.

The policy therefore treats model selection as an execution concern and keeps it independent from SH identity.

## 2. Audit

P4D-001 already established the provider-independent ModelAdapter boundary. The Phase 4 reconciliation explicitly states that P4D-002 is the point where the existing Owner decision is applied as minimal realization.

No authority requires a specific provider name, a second provider, a dynamic routing algorithm, or a paid dependency.

## 3. Minimal Realization

Added:

`runtime/p4d/model_selection.ts`

The policy defines:

- `ModelCostTier` with `ZERO_BUDGET` and `PAID`;
- `ModelCandidate` metadata;
- deterministic first-eligible selection;
- zero-budget as the default selection requirement;
- explicit opt-in to paid selection when `require_zero_budget: false`;
- structured failure when no eligible model exists.

The implementation does not hardcode a provider or provider name. A concrete provider can be supplied later through the P4D-001 `ModelAdapter` interface.

## 4. Zero-Budget Boundary

Default behavior is:

`require_zero_budget = true`

Therefore a paid-only candidate cannot silently become the core execution path.

If no zero-budget candidate exists for the requested capability, selection fails rather than introducing an implicit paid dependency.

## 5. Single-Provider v1 / Future Multi-Model

The policy does not require multiple providers. A single eligible zero-budget candidate is sufficient for v1.

The candidate list and P4D-001 abstraction permit later addition of additional models/providers without changing SH identity.

No secondary-provider fallback is implemented here; that remains P4D-003.

## 6. Identity Boundary

The selection request contains capability and budget policy only. It does not accept, create, mutate, or resolve `SH_ID`.

Therefore:

`MODEL != SH IDENTITY`

remains preserved.

## 7. Verification

Static repository verification:

- P4D selection policy exists in `runtime/p4d/model_selection.ts`.
- The default path requires a zero-budget candidate.
- Paid selection requires explicit opt-out from the zero-budget requirement.
- No provider name is hardcoded in the policy.
- The selection result returns an existing adapter dependency; it has no identity mutation capability.
- Tests were added in `runtime/p4d/model_selection.test.ts` covering deterministic zero-budget selection, paid-only rejection, explicit paid selection, and identity separation.

Execution-environment note:

This session does not claim a locally executed Deno test result because the connected execution environment does not expose a Deno/package runner. Static repository verification is therefore the claimed verification level for this item.

## 8. Supabase Cross-Check

P4D-002 requires no database schema or persistence mutation. Existing Supabase DEV structures remain sufficient. No model-specific table, identity mutation, or ownership mutation is introduced.

## 9. Reconciliation Result

RESULT: PASS / DEV

No material contradiction found.
No Owner decision required.
No canonical mutation.
No ownership/privacy/security boundary change.
No fundamental architecture redesign.
No mandatory paid provider introduced.

## 10. Deferred Assurance

- Actual provider/model performance is not asserted here because no concrete provider is frozen by P4D-002.
- Multi-provider fallback remains deferred to P4D-003 / later provider onboarding.
- Full application/E2E model execution assurance is not claimed.

## 11. Next

P4D-003 — Model Fallback & Error Handling

END OF EV-P4D-002
