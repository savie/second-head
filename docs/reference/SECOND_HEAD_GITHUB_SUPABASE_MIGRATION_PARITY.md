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

## Current live P1 tail

Supabase DEV currently ends with:

```text
20260822033444 p1_terminal_lifecycle_security_reconciliation
20260822033544 p1_close_public_security_definer_grants
20260822033920 p1_journey_lifecycle_and_internal_runtime_acl
20260822033930 p1_revoke_client_event_trigger_execute
20260822035431 20260822110000_scope_experience_context_by_sh
20260822050952 inheritance_authorization_consume_on_success
20260822051302 p1_transfer_lifecycle_reconciliation_20260822050000
20260822051357 p1_clone_terminal_account_guard_20260822053000
20260822051922 p1_revoke_client_event_trigger_execute_final
20260822052048 p1_recovery_restore_idempotency
20260822055203 p1_lifecycle_transfer_policy_and_recovery_reconciliation
20260822055238 fix_legacy_eol_transfer_guard_v2
20260822055314 p1_reconcile_transfer_policy_vocabulary_and_journey_eligibility
20260822065752 p1_inheritance_revoke_journey_provenance_cleanup
20260822070005 p1_clone_revoke_release_cleanup
20260822091610 p1_normalize_inheritance_transfer_policy_alias
20260822092029 p1_hide_internal_active_sh_assertion
20260822092412 p1_hide_internal_journey_shared_helper
20260822092425 reconcile_journey_shared_helper_rls_execution
20260822092516 reconcile_journey_shared_helper_execution
```

## Canonical GitHub reconciliation

The following current live semantics are now represented under `database/migrations/`:

```text
20260822142000_p1_inheritance_revoke_journey_provenance_cleanup.sql
20260822143000_p1_clone_revoke_release_cleanup.sql
20260822150000_p1_normalize_inheritance_transfer_policy_alias.sql
20260822151000_p1_hide_internal_active_sh_assertion.sql
20260822153000_reconcile_journey_shared_helper_execution.sql
```

The final Journey shared-helper ACL is intentionally:

```text
runtime_journey_event_is_shared(uuid)
    authenticated  = EXECUTE
    anon/public     = no EXECUTE
```

because the helper is a dependency of the authenticated `journey_events` visibility RLS policy.

The final internal active-SH assertion ACL is:

```text
runtime_assert_active_sh(uuid,text)
    authenticated  = no EXECUTE
    anon/public     = no EXECUTE
```

The `INHERITABLE` compatibility alias is normalized to canonical persisted `INHERITANCE` in `runtime_record_experience()`.

The non-canonical duplicate copies of the four individually represented P1 migrations were removed from `supabase/migrations/`. No Supabase migration was replayed or rewritten.

The three historical Journey shared-helper ACL migrations were not fabricated as separate historical GitHub migrations. Their final live semantics are represented by the canonical final-state reconciliation migration above.

## Reconciliation rule

Do NOT create duplicate historical migration versions merely to make timestamps look identical. Historical Supabase migration history is immutable evidence.

The authoritative requirement for the repository is:

```text
fresh GitHub migration replay
        ↓
reconstruct equivalent SH Core schema/runtime semantics
        ↓
without fabricating historical execution history
```

## Remaining verification

A clean-room replay of the entire GitHub migration chain is still an execution/evidence task. It is not claimed PASS from source inspection alone.

Until that replay exists, status is:

```text
Live Supabase runtime          PASS
GitHub source semantic parity  RECONCILED for current P1 tail
Historical version identity    INTENTIONALLY NOT FABRICATED
Clean-room replay              OPEN EVIDENCE
```
