# EV-P5A-007 — Journey Explicit Capture Runtime Composition

**Phase:** P5A — Journey & Continuity
**Status:** IMPLEMENTED / DEV DEPLOYED / AUTHENTICATED E2E PENDING
**Branch:** `dev`

## Scope

Complete the technical Journey producer work that remained after the P5A producer-boundary reconciliation, without introducing blanket transcript logging or brittle keyword matching.

## Implemented

1. Provider-neutral `SemanticJourneyCandidate` was added to the P4D semantic signal envelope.
2. `createSemanticJourneySignalDetector()` adapts only structured `journey_candidate` signals into the P5A Journey decision boundary.
3. The Journey runtime sink now accepts explicit user-directed Journey intent while preserving explicit-over-automatic precedence.
4. The production `runtime-p4a-001` composition now has both semantic and memory Journey detector paths.
5. The authenticated Chat surface exposes explicit `SAVE LAST MESSAGE TO JOURNEY` capture.
6. Explicit capture is routed through the authenticated Runtime and canonical `runtime_record_journey_event` recorder rather than writing Journey state directly from the client.
7. Unit coverage was extended for structured semantic Journey detection and explicit runtime capture.

## Boundary

Ordinary Chat/Runtime messages are not automatically recorded as Journey events.

Automatic Journey capture requires a structured semantic candidate supplied by the model/runtime machinery. The current DEV runtime still uses a mock textual response, so the model-dependent automatic positive path remains intentionally deferred until the AI model composition is available.

Explicit capture is user-directed and creates an `EXPERIENCE` Journey representation through the canonical decision/recorder path.

## Deployment

Supabase DEV `runtime-p4a-001` is deployed ACTIVE at version 8.

## Remaining assurance

- Authenticated explicit-capture E2E on the rebuilt APK: pending.
- Automatic semantic Journey positive E2E: pending the actual model/semantic runtime.
- No claim of final P5A PASS is made from deployment alone.
