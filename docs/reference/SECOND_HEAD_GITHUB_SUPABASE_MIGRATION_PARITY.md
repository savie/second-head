# SECOND HEAD — GITHUB ↔ SUPABASE MIGRATION PARITY

## Canonical rule

```text
database/migrations/  = only canonical application migration source
Supabase DEV catalog  = immutable applied-state evidence
supabase/migrations/  = historical/non-canonical artifacts
```

## Current DEV reconciliation

Supabase DEV is the applied-state authority. The current remote tail is:

```text
20260824134827  finalize_memory_relevance_token_filter
20260824134839  fix_memory_relevance_token_split
20260824134925  reconcile_recovery_experience_restore
20260824201714  20260824140000_reconcile_dev_db_functional_state
```

`20260824201714` is the remote migration version generated when the current DEV functional-state reconciliation was applied. Its migration name records the originating reconciliation name `20260824140000_reconcile_dev_db_functional_state`.

## Canonical Git representation

The current functional-state reconciliation is now represented in the canonical location:

```text
database/migrations/20260824201714_reconcile_current_dev_functional_state.sql
```

That file contains the current verified implementations for:

- `memory_relevance_score(text,text)` — current token filtering and OR-style term construction;
- `runtime_create_recovery_snapshot(uuid)` — owner-scoped recovery snapshot including Experience;
- `runtime_restore_recovery_snapshot(uuid)` — idempotent owner-scoped restore including Experience and recovery Journey recording;
- required anonymous execute revocations.

The remote migration was applied before this canonical replay artifact was committed. No historical Supabase migration was rewritten or replayed.

## Migration-history disposition

Historical timestamp aliases, non-canonical `supabase/migrations/` artifacts, and unrecovered historical source gaps remain immutable historical facts. They are not rewritten merely for cosmetic timestamp equality.

The canonical repository source is `database/migrations/`; Supabase DEV is the applied runtime state. New forward changes must be represented in `database/migrations/` first and then applied through the controlled migration workflow.

## Current status

```text
Canonical migration source        🟢
Current remote functional state   🟢
Current reconciliation represented 🟢
Historical aliases                🟢 documented/accepted
Historical source gaps            🟡 documented; no fabrication
Clean-room replay                 🟡 separate evidence gate
Device/UI regression              🟡 separate evidence gate
```

No Phase 1–5 migration replay is required merely to normalize historical timestamps or locations.