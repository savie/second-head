# EV-P5A-003 — Inheritance / Legacy → Journey Integration

Status: IMPLEMENTED / DEV VERIFICATION BOUNDARY
Phase: 5
Slice: P5A — Journey & Continuity Gap
Related slice: P5C — Inheritance, Legacy & Succession

## Purpose

Close two concrete Journey producer gaps where the canonical Journey event categories already have explicit domain operations:

- approved source-side inheritance execution → `INHERITANCE` Journey event;
- source-owner legacy recording → `LEGACY` Journey event.

## Source Basis

The canonical Journey model includes inheritance and legacy as Journey content. The P5C implementation already exposes concrete runtime operations for recording inheritance and legacy. Therefore these two integrations can be derived without introducing a new Owner decision.

The implementation intentionally records only on the source SH owned by the authenticated source owner. It does not silently write into the target SH's private Journey boundary.

## Implementation

Migration:

`supabase/migrations/20260815091000_p5a_003_inheritance_legacy_journey_integration.sql`

### Inheritance

After `runtime_record_inheritance()` creates the source-side `inheritance_events` row, it creates:

- `event_type = INHERITANCE`;
- `continuity_status = CONTINUOUS`;
- source/authorization/target references in payload;
- `source_ref = inheritance_event:<inheritance_id>`.

### Legacy

After `runtime_record_legacy()` creates the `legacy_records` row, it creates:

- `event_type = LEGACY`;
- `continuity_status = CONTINUOUS`;
- legacy type, retention, payload, and provenance in payload;
- `source_ref = legacy_record:<legacy_id>`.

## DEV Verification

Supabase DEV project: `pkhkgvsrqeupvwoqjwmd`

Both replacement runtime functions were applied successfully.

Authenticated producer E2E was not executed because the database connector has no authenticated account context (`current_account_id() = NULL`). No test rows were inserted.

## E2E Boundary

Source/static verification: PASS.

Authenticated application/API/UI producer E2E: DEFERRED until an authenticated runtime session/device flow is available.

No full product E2E PASS is claimed.
