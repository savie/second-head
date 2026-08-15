# EV-P5A-006 — MEMORY Journey Runtime Composition

Status: IMPLEMENTED; authenticated positive E2E pending semantic fixture
Branch: `dev`

## Actual production path

`app/features/chat/chat-service.ts`
→ `app/services/runtime.ts`
→ Supabase Edge Function `runtime-p4a-001`
→ authenticated SH identity resolution
→ post-response Journey Runtime Decision Sink
→ `createMemoryJourneySignalDetector()`
→ canonical `createJourneyRuntimeDecisionSink()`
→ `runtime_record_journey_event`
→ `journey_events`

## Important boundary

The production app path does not instantiate `runtime/p4a/runtime_core_loop.ts`; the deployed chat surface invokes `runtime-p4a-001` directly. Therefore the MEMORY detector was wired at the actual application runtime composition point rather than only at the abstract core-loop test seam.

## Semantic rule

The detector accepts only an already-derived structured `memory_candidate` object in the response. Ordinary user text and ordinary textual responses do not create a MEMORY Journey event. Client request fields are never treated as semantic memory signals.

## Ownership

The authenticated runtime resolves one SH identity before Journey recording. The recorder passes that resolved `sh_id` to the existing `runtime_record_journey_event` RPC, preserving the existing SH-scoped persistence boundary.

## Verification status

- Source composition: VERIFIED.
- Supabase DEV Edge Function version: deployed ACTIVE.
- Existing Journey Decision path: reused.
- Client-input-to-memory signal injection: rejected by design.
- Positive authenticated MEMORY E2E: pending until the actual model/semantic runtime can produce a structured `memory_candidate` in DEV. The current P4A app runtime uses a mock textual response, so a positive E2E fixture must not be simulated by a user-controlled request field or keyword.

END
