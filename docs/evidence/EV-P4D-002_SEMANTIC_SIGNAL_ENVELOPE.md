# EV-P4D-002 — Provider-Neutral Semantic Signal Envelope

Status: IMPLEMENTED / SOURCE-LEVEL VERIFICATION
Phase: 4 — Runtime & Orchestration
Slice: P4D — Model Abstraction

## Purpose

Add the provider-neutral semantic output boundary required for automatic Memory/Knowledge candidate formation approved by Owner, without selecting a model provider and without changing Memory or Knowledge policy/lifecycle.

## Source basis

P4D already exposes a provider-independent `ModelAdapter` / `ModelExecutor` boundary. The existing `ModelResponse` previously contained only `output`.

P4A Memory already accepts a model-proposed `memory_candidate` and applies safe defaults before persistence. P3D Knowledge Acquisition defines Knowledge intake as a candidate boundary and explicitly separates acquisition from validation, classification, trust, storage, sharing, and Core modification.

## Implementation

Added:

- `runtime/p4d/semantic_signals.ts`
- optional `ModelResponse.semantic_signals`
- `SemanticMemoryCandidate`
- `SemanticKnowledgeCandidate`
- `SemanticSignals`
- structural envelope validation helper

Memory intake now accepts `semantic_signals.memory_candidate` while preserving the legacy top-level `memory_candidate` compatibility path.

## Boundary

P4D semantic signals are proposals only. They do not contain or grant:

- SH/account ownership authority;
- persistence authority;
- trust/acceptance state;
- Journey event authority;
- Core mutation authority.

Knowledge `origin` is retained as acquisition evidence; Knowledge classification remains downstream in P3D. The semantic layer does not assign final `knowledge_class` or promote private information to shared/general Knowledge.

## Provider neutrality

No provider or model was selected. Groq, OpenRouter, HuggingFace, OpenAI, and Gemini remain candidate providers only.

## Tests added

- semantic signals are preserved through `ModelExecutor`;
- ordinary model output remains valid without semantic signals;
- malformed signal envelopes are rejected;
- semantic signals do not carry persistence/authority fields;
- nested semantic Memory candidate is accepted by existing P4A Memory Decision intake;
- existing legacy Memory candidate path remains valid.

## E2E boundary

This slice does not claim authenticated semantic-model E2E. No real model provider has been selected or wired. The implementation establishes the stable provider-neutral contract so a future provider adapter can produce semantic proposals without changing downstream policy/lifecycle.
