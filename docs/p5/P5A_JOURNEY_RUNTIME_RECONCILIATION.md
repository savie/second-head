# P5A Journey Runtime Reconciliation

## Scope

This note records the runtime reconciliation required to keep Journey semantic handling behind the existing provider-neutral candidate boundary.

## Current boundary

```text
Chat request
  -> authenticated runtime
  -> model/provider adapter
  -> structured semantic_signals (optional)
  -> P5A Journey decision
  -> canonical Journey recorder
  -> journey_events
```

## Rules

- `journey_candidate` is a structured semantic candidate, not a final Journey event.
- Journey must not infer semantic events from raw prose or keyword matching.
- If the model/provider returns no structured Journey candidate, the safe result is no Journey event.
- The Journey recorder remains the canonical persistence boundary.
- Knowledge eligibility thresholds (including the established occurrence >= 5 rule) must not be copied into Journey without a Journey-specific authority rule.

## Current DEV limitation

The current chat runtime still uses a mock response path rather than a real model/provider semantic envelope. Therefore automatic semantic Journey capture cannot be claimed PASS from the current APK/runtime evidence.

## Disposition

P5A domain implementation: implemented.
Runtime semantic-provider dependency: open / not proven.
No keyword-based workaround is authorized by this reconciliation.
