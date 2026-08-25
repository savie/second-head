# P4D Zero-Budget Provider Runtime Reconciliation

## Decision basis

P4D-002 requires the core execution path to remain zero-budget by default and keeps provider selection replaceable behind the P4D model abstraction.

## Current implementation candidate

The first concrete runtime provider is OpenRouter's `openrouter/free` router.

This is an implementation choice, not a Core identity or domain authority decision.

## Runtime boundary

```text
P4A runtime
  -> P4D Model Selection (require_zero_budget=true)
  -> P4D ModelAdapter
  -> OpenRouter free router
  -> structured response envelope
  -> P4D semantic_signals
  -> P5A Journey decision
```

## Constraints preserved

- no SH-owned AI hardware;
- no paid provider required by the initial runtime path;
- provider-specific code remains behind `ModelAdapter`;
- model selection does not participate in SH identity resolution;
- semantic candidates remain proposals; domain decision and persistence remain downstream;
- absence/invalidity of semantic signals does not create a Journey event;
- Knowledge's established occurrence >= 5 rule is not reused as a Journey rule.

## Multi-provider direction

The architecture remains capable of multiple interchangeable providers/models. The current runtime intentionally starts with one zero-budget candidate so the existing P4D selection policy can be exercised deterministically. Additional zero-budget adapters (for example Groq or Hugging Face) may be added without changing P5A/P5D domain boundaries.

## Current assurance

- GitHub source: OpenRouter adapter + runtime wiring committed to `dev`.
- Supabase DEV: `runtime-p4a-001` deployed as version 9.
- Provider credential presence and live semantic E2E are still runtime-test items; deployment alone is not evidence of successful inference.
