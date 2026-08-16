# SECOND HEAD — P6D Release Candidate Manifest v1.0

Status: CURRENT DEV CANDIDATE

## Candidate identity

- Repository: `savie/second-head`
- Working branch: `dev`
- Current DEV source commit at reconciliation: `05ab64e342909d64de08f0646f4b42b877ae8fc2`
- Supabase DEV project: `pkhkgvsrqeupvwoqjwmd`
- DEV database observed state: 60 applied migrations
- Latest observed migration: `20260816164740`
- PostgreSQL: `17.6`
- Timezone: `UTC`

## Included implementation boundary

The candidate includes the P5A recovery/inheritance/legacy Journey integration restored to `dev` and the P6D security remediation ported to `dev`.

P6D security remediation includes:

1. `private.authority_assignments` RLS enabled with deliberate default-deny/no client policy.
2. Sensitive runtime function EXECUTE privileges reconciled so `anon` does not retain EXECUTE while `authenticated` does.
3. Direct privileges on `public.conversations` revoked from `public`, `anon`, and `authenticated`.

## Evidence semantics

The DEV database state is an observed current-state snapshot. It is not claimed to be a provider-native immutable backup/export.

The migration ledger is preserved as observed, including earlier and later reconciliation migrations. No historical migration history was rewritten merely to make the ledger appear linear.

## Deferred semantics

`DEFERRED` means that implementation/evidence exists and all boundaries observable in the available environment have been verified, while stronger proof requiring an authenticated application/session/device boundary has not yet been obtained. It does not mean unimplemented or abandoned.

## Freeze rule

Any subsequent implementation or configuration change to the candidate invalidates this manifest and requires a new candidate identity/update under change control.

## Disposition

P6D release-candidate manifest: CURRENT / RECONCILED.
