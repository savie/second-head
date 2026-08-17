# P4D Automatic Multi-Model — Owner Decision

Status: ACCEPTED — OWNER DECISION

## Decision

SECOND HEAD shall use automatic multi-model selection internally. The user does not manually select the underlying LLM/provider during normal SH interaction.

## Boundary

Provider/model choice is implementation infrastructure, not SH identity. SH must not present itself as being a specific provider merely because a provider was selected for a request.

## Requirements

- Keep the existing provider-neutral ModelAdapter / ModelExecutor boundary.
- Selection is automatic.
- Provider/model may vary by capability, availability, policy, or fallback conditions.
- Zero-budget enforcement remains mandatory for the current execution policy.
- Paid-only candidates must not be silently selected under the zero-budget policy.
- Provider credentials remain server-side and must never be committed to GitHub or exposed to the client.
- Semantic consumers continue to receive the existing structured semantic contract; model/provider selection must not bypass Journey, Memory, Knowledge, privacy, identity, or Core boundaries.
- This decision does not grant the model authority over SH identity, ownership, privacy, promotion, or Core mutation.

## Initial provider pool

The current implementation candidates are OpenRouter, Groq, and Hugging Face. They remain interchangeable provider candidates under the provider-neutral architecture; this decision does not make any provider part of SH identity.

## Relationship to prior P4D-002 policy

This decision supersedes the earlier product limitation that initial execution only needs one provider/model path as a product-direction constraint. It does not remove the existing zero-budget enforcement or provider-neutral abstraction. The implementation may begin with one available zero-budget path while retaining automatic multi-model capability and interchangeable providers.

## Normal user experience

The user interacts with Second Head. The underlying provider/model is not a normal user-facing selector. Diagnostic/provider information, if exposed later, belongs to an authorized developer/diagnostic surface rather than SH identity.
