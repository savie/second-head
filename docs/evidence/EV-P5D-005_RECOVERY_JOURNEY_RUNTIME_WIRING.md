# EV-P5D-005 — Recovery → Journey Runtime Wiring

## Status

Implemented on `dev`.

## Actual application path

`app/app/recovery.tsx` owns the Recovery UI action. Its `restore(snapshotId)` handler calls `restoreRecoverySnapshot(snapshotId)` from `app/features/recovery/recovery-service.ts`.

The Recovery service calls the canonical Supabase recovery restore RPC:

`runtime_restore_recovery_snapshot`

After the RPC returns the concrete `recovery_event_id`, the same application handler path invokes:

`recordRecoveryJourneyEvent(recovery_event_id)`

## Journey boundary

`recordRecoveryJourneyEvent()` loads the resulting `recovery_events` row and derives the Journey candidate from the authoritative recovery result.

Successful recovery produces:

- `event_type = RECOVERY`
- `continuity_status = RECOVERED`
- `source_ref = recovery:<recovery_event_id>`
- payload containing `recovery_event_id` and `outcome`

Non-restored outcomes do not create a RECOVERY Journey candidate.

The candidate is passed through the existing canonical `runtime/p5a/journey_decision.ts` decision boundary via `createJourneyRuntimeDecisionSink()`. The application does not directly insert a Journey event from the UI button.

## Recorder

The application-side Journey recorder calls the existing Supabase RPC:

`runtime_record_journey_event`

This preserves the existing Journey ownership/RLS boundary and writes to `public.journey_events`.

## Important boundary

Recovery persistence remains responsible for restoring SH state. Journey remains responsible for deciding/recording the significant Recovery event. The UI does not create Journey events directly.

## Verification state

The DEV project contains both runtime functions:

- `runtime_restore_recovery_snapshot`
- `runtime_record_journey_event`

At the time of this evidence capture, `public.journey_events` contains zero rows, so an authenticated real-data Recovery → Journey end-to-end PASS has not yet been claimed. The implementation and wiring are present; live execution remains a test prerequisite requiring valid authenticated test credentials and a Recovery snapshot.
