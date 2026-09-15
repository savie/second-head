# SECOND HEAD — Journey Manual `+` Backend Sync Reconciliation

## Status

**WORKING VERIFICATION RECORD — IMPLEMENTATION RECONCILED / BACKEND SYNC WIRED**

## Authority

Supporting working document only.

This document records the current UI/runtime boundary for the manual Journey `+` creation path. It does not redefine any Canonical contract.

## 1. Finding

The previous implementation created a local `JourneyItem` and persisted it only through `JourneyStore.persist()`. It did not call the canonical semantic creation runtime, so manual `+` records could exist locally without a corresponding Supabase semantic record/Journey event.

## 2. Current Implementation

The manual `+` path now:

1. selects Memory / Knowledge / Experience;
2. opens the Journey editor;
3. resolves the active `sh_id` from `profileShId`;
4. calls the existing `JourneyRuntimeService` canonical creation RPC for the selected domain;
5. uses `PRIVATE` + `OWNER_ONLY` for private drafts and `GENERAL` + `SHARED` for shared drafts;
6. reloads Journey from the backend after successful creation.

Implementation source: `app/lib/features/journey/journey_view.dart`.

The runtime adapter already delegates to:

- `runtime_record_memory_with_journey`
- `runtime_record_knowledge_with_journey`
- `runtime_record_experience_with_journey`

These existing runtime boundaries create the semantic record and linked Journey event; no new Journey RPC is introduced by this fix.

## 3. Synchronization Boundary

The corrected path is:

`Journey +` → type → editor → canonical runtime RPC → semantic record + Journey event → `_loadJourney()` → local projection

Therefore:

**Supabase/backend = canonical mutation authority**

**JourneyStore = local durable projection/cache**

A successful manual create is no longer reported as success merely because a local file was written.

## 4. Failure Behavior

If active SH identity is unavailable, the create is rejected before local persistence.

If the backend creation RPC fails, no local Journey item is inserted and the UI reports the backend failure.

After successful backend creation, `_loadJourney()` refreshes from the backend and persists the resulting canonical projection locally.

## 5. Security / Ownership Evidence

The manual path resolves the active `sh_id` from the profile identity state before invoking the runtime boundary.

Supabase DEV currently exposes the Memory and Knowledge creation RPCs to `authenticated`, not `anon`. The Experience creation RPC also requires `auth.uid()` and verifies that the supplied `sh_id` belongs to the current active account before inserting the Experience and linked Journey event.

Current direct privilege state therefore needs no new authorization mechanism for the manual path. The Experience RPC's `anon` EXECUTE privilege is an existing least-privilege hardening item because the function itself rejects unauthenticated callers; it is separate from the manual `+` synchronization fix.

## 6. Database / Migration Boundary

No schema change or new migration is required for the synchronization fix. Existing runtime RPCs already provide the required semantic record + Journey event creation boundary.

Migration 218 remains unchanged and locked.

## 7. Verification Classification

### Non-E2E

**IMPLEMENTATION FIX APPLIED / SOURCE RECONCILED**.

Verified by source inspection that manual `+` now uses the canonical runtime creation adapter and reloads the canonical backend projection after success.

Supabase DEV verification confirms the required creation RPCs exist and enforce authenticated/owned-SH behavior at runtime. This is not device E2E proof.

### E2E

Still requires device/runtime execution of the manual `+` path to prove:

`tap + → create → Supabase persistence → Journey reload → visible canonical item → reopen/edit/delete`

This document does not convert source inspection into E2E PASS.

## 8. Traceability

Changed source:

`app/lib/features/journey/journey_view.dart`

Runtime adapter:

`app/lib/features/journey/journey_runtime_service.dart`

Identity source:

`app/lib/core/state/sh_profile_state.dart`

Backend retrieval:

`app/lib/features/journey/journey_service.dart`

## 9. Final State

**MANUAL JOURNEY `+` = IMPLEMENTED / BACKEND-SYNCED / NON-E2E RECONCILED**

**LOCAL-ONLY MANUAL CREATE = FIXED**

**BACKEND CREATE FROM MANUAL `+` = WIRED THROUGH EXISTING CANONICAL RPCs**

**NEW DATABASE MIGRATION = NOT REQUIRED**

**DEVICE E2E = OPEN UNTIL EXECUTED**
