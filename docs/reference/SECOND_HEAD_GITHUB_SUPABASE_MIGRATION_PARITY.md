# SECOND HEAD — GITHUB ↔ SUPABASE MIGRATION PARITY

## Canonical rule

```text
database/migrations/  = only canonical application migration source
Supabase DEV catalog  = immutable applied-state evidence
supabase/migrations/  = historical/non-canonical artifacts
```

## Audited live tail

Supabase DEV now contains the historical P1 tail through the two canonical replay reconciliations and the Legacy guards:

```text
20260822091610 p1_normalize_inheritance_transfer_policy_alias
20260822092029 p1_hide_internal_active_sh_assertion
20260822092412 p1_hide_internal_journey_shared_helper
20260822092425 reconcile_journey_shared_helper_rls_execution
20260822092516 reconcile_journey_shared_helper_execution
20260822170000 p1_legacy_end_of_life_guard
20260822170001 p1_current_p1_tail_semantic_reconciliation
20260822170002 p1_legacy_record_eol_guard
```

The historical migration versions remain immutable evidence. The later `170000`–`170002` migrations are new canonical reconciliation executions and are represented under `database/migrations/`.

## Canonical replay artifacts

```text
database/migrations/20260822170000_p1_legacy_end_of_life_guard.sql
database/migrations/20260822170001_p1_current_p1_tail_semantic_reconciliation.sql
database/migrations/20260822170002_p1_legacy_record_eol_guard.sql
```

These reconstruct the audited current semantics without fabricating historical migration IDs.

## Audited semantic state

- `INHERITABLE` compatibility input is normalized to persisted `INHERITANCE`.
- Internal `runtime_assert_active_sh(uuid,text)` has no client execute privilege.
- `runtime_journey_event_is_shared(uuid)` remains executable by authenticated because it is required by the authenticated Journey visibility RLS policy; anon/public are denied.
- Inheritance revoke removes provenance-linked Memory, Knowledge, Experience, and Journey derived records.
- Clone revoke is source-owner scoped and idempotent for already-revoked agreements.
- Selected Legacy preservation requires the source SH to be End-of-Life/deactivated.
- Generic `runtime_record_legacy()` now also requires the source SH to be End-of-Life/deactivated.

## Non-goals

No historical Supabase migration was renamed, rewritten, or replayed merely to match GitHub filenames. No canonical architecture/scope/contract decision was changed.

## Remaining evidence gates

```text
Full clean-room replay of canonical chain   🟡
Authenticated multi-account E2E               🟡
Device/UI regression                         🟡
```

These are evidence gates, not claimed defects.
