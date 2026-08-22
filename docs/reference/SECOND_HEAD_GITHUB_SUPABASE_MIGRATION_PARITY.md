# SECOND HEAD — GITHUB ↔ SUPABASE MIGRATION PARITY

## Purpose

This document records migration-history reconciliation without fabricating historical Supabase migration versions.

## Current state

Supabase DEV migration history contains the live P1 tail through:

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
```

GitHub DEV intentionally contains later reconciliation filenames for the last two P1 implementations rather than pretending those exact historical filenames were present in GitHub at the time they ran:

```text
20260822142000_p1_inheritance_revoke_journey_provenance_cleanup.sql
20260822143000_p1_clone_revoke_release_cleanup.sql
```

The GitHub inheritance migration contains the same live Journey provenance and revoke cleanup behavior, including deletion by `authorization_id` and retention of source records. The live Supabase function definition was verified to contain the same Journey cleanup.

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
GitHub source semantic parity  RECONCILED
Historical version identity    INTENTIONALLY NOT FABRICATED
Clean-room replay              OPEN EVIDENCE
```
