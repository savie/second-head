# EV-P5A-004 — Journey Producer Reconciliation

**Phase:** P5A — Journey & Continuity
**Status:** RECONCILED / PRODUCER PLUMBING IMPLEMENTED
**Baseline:** commit `6acbb156c6aff499914bf88f82d3237ab0090482`

## 1. Why this reconciliation exists

P5A already provided the `journey_events` persistence surface and the `runtime_record_journey_event(...)` recorder, but the v1.0 source did not contain an application-level producer path from the actual conversation/runtime flow into that recorder.

The missing question was not whether Journey is intended to represent significant events. The Owner clarified that Journey is intended to become the SH life-story/history and should capture significant events through both automatic and explicit paths.

## 2. Owner clarification

Journey v1.0 must support both:

1. **Automatic capture** — the system may semantically identify a significant event from an interaction and turn the relevant resume/representation into a Journey event.
2. **Explicit capture** — the user may explicitly indicate that an interaction or event should become part of Journey.

Automatic capture must not mean that every conversation/message is copied into Journey. Journey remains a significant-event representation, not a raw transcript or activity log.

## 3. Reconciled runtime boundary

The existing P4A runtime path is:

```text
auth.uid
  ↓
identity resolution
  ↓
read-only context assembly
  ↓
reasoning / model
  ↓
response
  ↓
post-response decisions
```

Context assembly remains read-only. Journey therefore enters as a post-response decision sibling rather than as a context mutation or reasoning capability.

The reconciled path is:

```text
response
  ↓
Journey Decision
  ├── automatic semantic candidate
  └── explicit user-directed candidate
  ↓
canonical Journey recorder
  ↓
public.journey_events
  ↓
Journey read/context surface
```

Memory decision remains a separate post-response operation.

## 4. Implementation boundary

`runtime/p5a/journey_decision.ts` defines the boundary between semantic/runtime signal production and canonical Journey recording.

The boundary deliberately does **not** invent semantic significance, event taxonomy, or model/provider behavior. It accepts an injected `JourneySignalDetector` and an injected `JourneyEventRecorder`.

Explicit intent takes precedence when both explicit and automatic candidates are present.

An explicit request without a concrete candidate is not converted into a guessed event; the boundary returns `NONE` rather than inventing an event type or payload.

## 5. Runtime insertion point

`runtime/p4a/runtime_core_loop.ts` now calls the Journey decision boundary after model response and before the existing post-response memory decision.

The actual deployed `runtime-p4a-001` composition now also uses the Journey decision boundary with structured semantic and memory detectors, and exposes an authenticated explicit-capture path.

This preserves:

- read-only context assembly;
- isolated reasoning;
- model/provider abstraction;
- separation of Journey from Memory;
- existing post-response decision structure.

## 6. What this reconciliation does not claim

This change does **not** claim that the concrete semantic/LLM Journey detector is already producing positive automatic events in DEV. The current DEV runtime still uses a mock textual response; automatic semantic capture therefore remains dependent on the future model/semantic composition.

It also does not claim that every P3/P4/P5 domain event is automatically a Journey event. A domain operation must still produce a significant Journey candidate through the semantic/runtime machinery.

## 7. Verification added

The runtime test locks the ordering:

```text
identity → context → model → journey → memory
```

`runtime/p5a/journey_decision.test.ts` covers:

- explicit Journey capture;
- automatic candidate capture;
- explicit-over-automatic precedence;
- no invented event when explicit intent lacks a candidate;
- detector → recorder flow;
- explicit capture supplied at the runtime sink.

`runtime/p5a/semantic_journey_signal.test.ts` covers:

- structured semantic Journey candidate adaptation;
- rejection of ordinary prose as an automatic Journey signal.

## 8. Current disposition

The previously open **technical producer-plumbing work is implemented**.

Remaining assurance is execution evidence:

- authenticated explicit Journey capture on the rebuilt APK;
- authenticated automatic semantic Journey capture once the actual model/semantic runtime can produce a structured Journey candidate.

No blanket transcript logging and no brittle keyword matching are introduced.
