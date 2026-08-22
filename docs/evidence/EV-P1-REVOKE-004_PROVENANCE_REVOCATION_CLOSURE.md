# EV-P1-REVOKE-004 — Transfer Provenance / Revocation Closure

## Scope
Audit the transfer-provenance boundary for Inheritance and Clone, with emphasis on removal of derived Memory, Knowledge, Experience, and Journey records from the target SH after authorization revocation while preserving source/original records.

## Findings

1. Inheritance revoke already removed derived Memory, Knowledge, Experience, and Journey records by `authorization_id` provenance.
2. The delete predicates were broadened to require the expected target SH and source SH in the transfer provenance, reducing accidental or cross-target deletion scope.
3. Clone revoke deletes derived Memory, Knowledge, and Experience records scoped to the cloned SH and agreement provenance. Clone materialization does not currently materialize Journey records, so no Journey revoke deletion was required.
4. Client-writable `provenance` could otherwise spoof reserved `inheritance_origin` / `clone_origin` markers. A system-managed provenance trigger now rejects those reserved markers for non-system sessions. Internal `SECURITY DEFINER` transfer functions remain able to write them.
5. Source records are not deleted by these revoke paths; deletion is constrained to derived records on the target/clone SH.

## Canonical Fix

Canonical migration:

`database/migrations/20260822190000_revoke_provenance_spoof_and_scope_cleanup.sql`

The DEV Supabase runtime was reconciled with the same semantics. Supabase migration history is not rewritten.

## Verification

- `runtime_revoke_inheritance_authorization(uuid)` requires authenticated source ownership.
- Inheritance revoke deletes only matching derived records on `target_sh_id` with matching `authorization_id` and `source_sh_id` provenance.
- Clone revoke remains scoped to `clone_sh_id` and `agreement_id` provenance.
- Reserved transfer provenance is system-managed and rejected for ordinary inserts.
- Original/source records are retained by the revoke functions.

## Remaining Evidence Gate

Authenticated cross-account runtime/E2E execution is still required for full black-box proof. This evidence file does not claim that runtime gate has been completed.
