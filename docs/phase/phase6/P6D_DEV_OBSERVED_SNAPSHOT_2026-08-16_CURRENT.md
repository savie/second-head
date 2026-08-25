# SECOND HEAD — P6D DEV Observed Snapshot — Current 2026-08-16

Status: CURRENT OBSERVED EVIDENCE

## Source

- Repository: `savie/second-head`
- Working branch: `dev`
- Current DEV source SHA: `05ab64e342909d64de08f0646f4b42b877ae8fc2`

## Database runtime

Observed directly from Supabase DEV:

- Database: `postgres`
- PostgreSQL: `17.6`
- Timezone: `UTC`
- Applied migrations: `60`
- Latest migration: `20260816164740`

## Latest migration sequence

The latest observed migration records include the P5A reconciliation followed by the P6D security remediation:

- `20260816164740` — `p6d_revoke_direct_conversation_table_access`
- `20260816164729` — `p6d_reconcile_runtime_function_execute_privileges`
- `20260816164715` — `p6d_enable_authority_assignments_rls_default_deny`
- `20260816164230` — `20260815091000_p5a_003_inheritance_legacy_journey_integration`
- `20260816164216` — `20260815090000_p5a_002_recovery_journey_event_integration`

Historical same-purpose migration names also remain in the migration ledger. This snapshot records the observed ledger; it does not rewrite or normalize migration history.

## Security observations

### Authority assignments

`private.authority_assignments` has RLS enabled. No client policy is asserted by this snapshot.

### Runtime function EXECUTE boundary

For the reconciled sensitive runtime functions:

- `anon` EXECUTE = `false`
- `authenticated` EXECUTE = `true`

Verified functions include recovery, inheritance, legacy, clone, portability, and high-risk runtime operations.

### Conversations direct table boundary

For `public.conversations`:

- `anon` SELECT/INSERT/UPDATE/DELETE = `false`
- `authenticated` SELECT/INSERT/UPDATE/DELETE = `false`

## Freeze semantics

This is an observed DEV database/runtime snapshot, not a provider-native immutable database backup/export.

The snapshot is tied to the current `dev` source SHA above. Any subsequent implementation change invalidates this exact release-candidate evidence and requires refresh under change control.

## Human-language disposition

The implementation is present and the observable DEV security/runtime boundaries are verified. The remaining release-freeze action is to bind this evidence to the final release-candidate/change-control record.
