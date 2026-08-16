# SECOND HEAD — P6D Change-Control Record v1.0

Status: ACTIVE FREEZE CONTROL

## Candidate

- Repository: `savie/second-head`
- Branch: `dev`
- Candidate source commit recorded at manifest reconciliation: `05ab64e342909d64de08f0646f4b42b877ae8fc2`
- Supabase DEV project: `pkhkgvsrqeupvwoqjwmd`

## Controlled state

The P6D candidate is the current observed `dev` implementation plus the corresponding observed Supabase DEV database/runtime state. The candidate is not a provider-native immutable database backup/export.

## Change rule

After this record, any implementation, migration, security-boundary, or runtime/configuration change that materially changes the candidate requires the current candidate to be treated as invalid for freeze purposes and a new reconciliation/manifest update to be produced.

## Known non-blocking deferred boundary

Authenticated application/session/device E2E proof may remain `DEFERRED` where the available audit environment cannot establish that authenticated boundary. This status must not be interpreted as missing implementation.

## Security controls included

- `private.authority_assignments` RLS: enabled, deliberate default-deny/no client policy.
- Sensitive runtime functions: `anon` EXECUTE removed; `authenticated` EXECUTE retained.
- `public.conversations`: direct table privileges revoked from `public`, `anon`, and `authenticated`.

## Disposition

P6D change-control record: ACTIVE for the current `dev` candidate.
