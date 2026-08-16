# EV-P4D-003 — Provider-Neutral Semantic Candidate Formation

Status: IMPLEMENTED / SOURCE-LEVEL VERIFICATION
Phase: 4 — Runtime & Orchestration
Slice: P4D — Model Abstraction

## Purpose

Implement the semantic candidate formation boundary above the provider-neutral `ModelResponse.semantic_signals` envelope without selecting a model provider and without changing Memory or Knowledge policy/lifecycle.

## Source-derived placement

P4D already owns the provider-independent `ModelAdapter` / `ModelExecutor` boundary. Therefore candidate formation is implemented at the P4D model-output boundary, not inside Memory, Knowledge, or Journey.

Provider adapters may return either:

1. explicit `ModelResponse.semantic_signals`; or
2. model output containing an explicit JSON/object `semantic_signals` envelope.

`ModelExecutor` normalizes case (2) into `ModelResponse.semantic_signals`.

## Deliberate non-behavior

The formation layer does not infer candidates from ordinary prose. A plain response such as `User prefers concise replies.` remains ordinary output unless the model output explicitly contains the `semantic_signals` envelope.

The layer does not assign:

- SH/account ownership;
- persistence authority;
- trust/acceptance state;
- final Knowledge classification;
- sharing authority;
- Journey event authority;
- Core mutation authority.

## Implementation

Added:

- `runtime/p4d/semantic_candidate_formation.ts`
- `runtime/p4d/semantic_candidate_formation.test.ts`

Updated:

- `runtime/p4d/model_abstraction.ts`
- `runtime/p4d/semantic_signals.test.ts`

## Verification coverage

- explicit object semantic envelope is accepted;
- explicit JSON semantic envelope is accepted;
- ordinary prose does not become a candidate;
- malformed envelopes are rejected;
- existing direct `ModelResponse.semantic_signals` remains supported;
- ordinary model output remains valid without semantic signals;
- Memory and Knowledge remain downstream proposal/decision lifecycles.

## Provider boundary

No provider was selected or implemented. Groq, OpenRouter, HuggingFace, OpenAI, and Gemini remain candidate providers only.

This slice establishes the provider-neutral formation contract. A real authenticated model E2E still requires a concrete provider adapter/runtime model path.
