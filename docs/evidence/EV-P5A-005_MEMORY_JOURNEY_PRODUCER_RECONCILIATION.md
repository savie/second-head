# EV-P5A-005 — MEMORY Journey Producer Reconciliation

## Scope

This evidence records the P3B/P4A → P5A mapping for MEMORY Journey events.

## Source boundary

P4A already derives a structured `memory_candidate` from post-response model output. Ordinary model output is explicitly ignored by `createMemoryDecisionSink`; omitted fields default to PRIVATE / OWNER_ONLY / CANDIDATE. The persistence boundary resolves the authenticated SH identity and calls `runtime_record_memory` with that SH identity.

## Journey adaptation

`runtime/p5a/memory_journey_signal.ts` adapts only the existing structured `memory_candidate` signal into a canonical JourneyCandidate:

- `event_type = MEMORY`
- `source_ref = runtime:p4a:memory_candidate`
- payload preserves memory content and lifecycle/scope/visibility semantics

No keyword matching or inference from ordinary prose is introduced.

## Ownership boundary

The Journey candidate does not supply or mutate SH identity. The runtime caller supplies `sh_id`, consistent with the P4A memory persistence boundary and the canonical Journey recorder boundary.

## Current verification

- P4A memory candidate extraction tests: PASS in existing source.
- MEMORY Journey signal adapter unit test: added in `runtime/p5a/memory_journey_signal.test.ts`.
- Authenticated end-to-end MEMORY → Journey persistence: NOT YET CLAIMED. The current repository exposes the canonical runtime loop as dependency-injected infrastructure, but no production composition invoking `createRuntimeCoreLoop` was found in the source audit. Therefore this reconciliation does not claim an authenticated app-runtime PASS until that composition boundary is wired and exercised.

## Decision

No Owner decision is required for the event taxonomy or ownership boundary. The remaining work is technical: wire the new detector into the actual production Journey Decision composition, then run authenticated runtime verification.
