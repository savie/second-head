# EV-P4A-004 — Authenticated Semantic Candidate Runtime Wiring

Status: IMPLEMENTED / SOURCE-LEVEL VERIFICATION
Phase: 4 — Runtime & Orchestration
Slices: P4A / P4B / P4D / P3D intake boundary

## Purpose

Wire the provider-neutral semantic candidate envelope through the authenticated runtime path without selecting a model provider and without changing Memory or Knowledge policy/lifecycle.

## Actual runtime path

```text
runtime input (auth_uid + user_message)
        ↓
resolveRuntimeIdentityAndState
        ↓
existing SH identity
        ↓
read-only context assembly
        ↓
P4B reasoning security boundary
        ↓
P4B reasoning/model execution
        ↓
P4D semantic_signals
        ↓
P5A Journey decision/recording
        ↓
P4A Memory decision
        ↓
P3D Knowledge Acquisition intake (optional sink)
```

## Critical wiring correction

The runtime previously passed only `modelResponse.output` to the Memory Decision sink. That would silently discard `ModelResponse.semantic_signals`.

The runtime now passes the complete model response to Memory Decision so the existing P4A extractor can consume `semantic_signals.memory_candidate` while preserving the legacy top-level candidate path.

## P4B propagation

`ReasoningResult` now preserves optional provider-neutral `semantic_signals` from the injected reasoning/model executor. This prevents the existing P4B composition from stripping the semantic envelope before P4A/P3D intake.

## P3D boundary

Runtime exposes an optional `KnowledgeAcquisitionSink`. It is an acquisition/intake handoff only. It does not perform validation, classification, trust promotion, persistence, sharing, or Core modification.

This matches P3D-002, whose implementation boundary is acquisition contract/design and explicitly defers Knowledge storage to the later storage backlog.

## Deterministic authenticated E2E

A deterministic reasoning adapter is used in `runtime/p4a/runtime_core_loop.test.ts`.

The test supplies:

- `auth_uid = auth-user-1`;
- resolved SH identity `sh-001`;
- explicit Memory candidate;
- explicit Knowledge acquisition candidate.

The test verifies:

- authentication identity resolution occurs;
- Journey insertion point is reached exactly once;
- Memory Decision receives the semantic candidate with the same SH identity;
- Knowledge Acquisition receives the semantic candidate with the same SH identity;
- Knowledge origin is preserved;
- `OWNER_ONLY` visibility is preserved.

No real provider is required.

## Provider boundary

Groq, OpenRouter, HuggingFace, OpenAI, and Gemini remain candidate providers only. No provider was selected or wired.

## Security / authority boundary

Semantic signals remain proposals. They do not grant:

- SH/account ownership authority;
- persistence authority;
- trust/acceptance state;
- Journey event authority;
- Core mutation authority;
- automatic private-to-general Knowledge promotion.

## Verification status

Source-level deterministic E2E is implemented.

A real provider-backed authenticated E2E remains intentionally deferred until a provider is selected and an adapter is implemented.
