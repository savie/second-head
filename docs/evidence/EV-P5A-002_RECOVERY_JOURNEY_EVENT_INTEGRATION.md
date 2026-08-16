# EV-P5A-002 — Recovery → Journey Event Integration

Status: IMPLEMENTED / DEV VERIFICATION BOUNDARY
Phase: 5
Slice: P5A — Journey & Continuity Gap
Related slice: P5D — Recovery, Backup & Portability

## Purpose

Close the concrete integration gap between the already-canonical Journey `RECOVERY` event category and the existing P5D restore operation.

This does not turn Journey into a raw activity log and does not create a new SH identity.

## Source Basis

P5A already defines:

- `RECOVERY` as a valid Journey event type;
- explicit continuity status;
- explicit gap-code handling;
- owner-scoped Journey persistence;
- `runtime_record_journey_event`.

P5D already defines:

- same-identity recovery validation;
- recovery event recording;
- restoration of persisted Journey events from the recovery snapshot.

The implementation gap was that a successful restore recorded a `recovery_events` row but did not also record the recovery operation itself as a Journey `RECOVERY` event.

## Implementation

Migration:

`supabase/migrations/20260815090000_p5a_002_recovery_journey_event_integration.sql`

The migration replaces `runtime_restore_recovery_snapshot` so that after a successful `RESTORED` recovery event it records a Journey event with:

- `event_type = RECOVERY`;
- `continuity_status = RECOVERED` when no recovery gap is present;
- the recovery event ID and snapshot ID in payload;
- `source_ref = recovery_event:<recovery_event_id>`;
- the existing SH identity and authenticated account boundary.

## DEV Verification

Supabase DEV project: `pkhkgvsrqeupvwoqjwmd`

Verified after migration:

- `runtime_restore_recovery_snapshot(uuid)` exists;
- function source contains the Recovery → Journey recording path;
- function source contains the `recovery_event:<id>` source reference;
- no Journey test rows were inserted by the verification itself.

Current DEV state observed during verification:

- `journey_events`: 0
- `recovery_events`: 15
- `recovery_snapshots`: 15

The existing 15 recovery records pre-date this integration verification; the SQL verification environment has no authenticated account context (`current_account_id() = NULL`), so an authenticated restore E2E could not be executed from the database connector.

## E2E Boundary

Static/source and DEV database verification: PASS.

Authenticated application/API/UI restore → Journey E2E: DEFERRED until an authenticated runtime session/device flow is available.

No claim of full product E2E PASS is made by this artifact.
