# SECOND HEAD — GITHUB ↔ SUPABASE MIGRATION PARITY

## Purpose

This document records migration-history reconciliation without fabricating historical Supabase migration versions.

## Canonical repository rule

```text
database/migrations/
    = ONLY canonical application migration source

Supabase DEV migration catalog
    = immutable evidence of what was actually applied

supabase/migrations/
    = historical/non-canonical artifacts only
```

New application migrations must be authored under `database/migrations/`. The repository must not create a second active migration source under `supabase/migrations/`.

## Current live state

Supabase DEV currently ends with:

```text
20260822091610 p1_normalize_inheritance_transfer_policy_alias
20260822092029 p1_hide_internal_active_sh_assertion
20260822092412 p1_hide_internal_journey_shared_helper
20260822092425 reconcile_journey_shared_helper_rls_execution
20260822092516 reconcile_journey_shared_helper_execution
20260822170000 p1_legacy_end_of_life_guard
```

The historical versions remain immutable evidence. They are not renamed or replayed merely to match repository filenames.

## Canonical replay reconciliation

The repository now records the current semantic end state through canonical migrations under `database/migrations/`:

```text
20260822170000_p1_legacy_end_of_life_guard.sql
20260822170001_p1_current_p1_tail_semantic_reconciliation.sql
```

These are **replay artifacts**, not fabricated copies of the historical Supabase migration versions.

The reconciliation migration captures the current live semantics for:

- `INHERITABLE` compatibility input → canonical persisted `INHERITANCE`;
- internal `runtime_assert_active_sh(uuid,text)` → no authenticated/anon/public execute;
- `runtime_journey_event_is_shared(uuid)` → authenticated execute retained because it is an RLS visibility dependency; anon/public denied;
- inheritance revoke provenance cleanup including Journey;
- clone revoke provenance cleanup and idempotent already-revoked response.

Legacy preservation now has an explicit End-of-Life guard and rejects active SHs.

## Important historical rule

The repository does **not** claim that historical migration timestamps and canonical replay filenames are identical. Historical Supabase migration history is immutable evidence; canonical GitHub migration files are the source used to reconstruct equivalent SH Core semantics.

## Remaining verification

A clean-room replay of the entire canonical GitHub migration chain is still an execution/evidence task. It is not claimed PASS from source inspection alone.

```text
Live Supabase runtime          PASS for audited live state
Canonical source               RECONCILED for audited P1 tail
Historical version identity    PRESERVED
Clean-room replay              OPEN EVIDENCE
Authenticated E2E              OPEN EVIDENCE
```
