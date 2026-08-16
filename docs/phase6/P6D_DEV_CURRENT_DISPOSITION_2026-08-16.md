# SECOND HEAD — P6D DEV Current Disposition — 2026-08-16

Status: CURRENT DEV RECONCILIATION

## Human-language meaning

P6D is the implementation-freeze step. In plain language: we identify exactly what is currently in `dev`, record the current DEV database/runtime evidence, and put that release candidate under explicit change control. It does not mean that `dev` is disabled or that the database is magically an immutable backup.

## Current working branch

- Repository: `savie/second-head`
- Working branch: `dev`
- Current source SHA at evidence refresh: `05ab64e342909d64de08f0646f4b42b877ae8fc2`
- `main` remains outside the working path.

## Current DEV database observation

- PostgreSQL: `17.6`
- Timezone: `UTC`
- Applied migrations: `60`
- Latest migration: `20260816164740`

The detailed current observed snapshot is recorded in `P6D_DEV_OBSERVED_SNAPSHOT_2026-08-16_CURRENT.md`.

The migration ledger contains historical same-purpose P5A/P6D records as well as their later reconciliation records. This is observed history, not normalized or rewritten history.

## Implementation disposition

The P6D security implementation delta has been ported to `dev` rather than merging the stale `phase6d-freeze-package` branch wholesale.

The ported implementation covers:

1. `private.authority_assignments` RLS enabled with deliberate default-deny/no client policy.
2. Sensitive runtime function EXECUTE privileges reconciled so `anon` does not retain EXECUTE while `authenticated` does.
3. Direct table privileges on `public.conversations` revoked from `public`, `anon`, and `authenticated`.

These boundaries were re-verified directly against Supabase DEV after the latest remediation migrations.

## Freeze/evidence boundary

Current DEV state is treated as observed database/runtime evidence. It is not represented as a provider-native immutable backup/export.

The current observed evidence is now refreshed against the latest DEV migration state and current `dev` source identity. The remaining freeze action is to bind this current state to the final release-candidate manifest and explicit change-control record.

## Deferred boundary

`DEFERRED` means: implementation/evidence work exists and every boundary currently observable in the available environment has been verified, but a stronger proof requiring an authenticated application/session/device boundary has not yet been obtained. Deferred is not equivalent to unimplemented or abandoned.

## Current disposition

P6D implementation reconciliation on `dev`: GREEN.

Current DEV evidence refresh: GREEN.

Final release-candidate freeze/change-control binding: PENDING.

No claim of immutable provider-native database backup is made.
