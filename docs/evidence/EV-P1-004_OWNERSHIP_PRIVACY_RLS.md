# EV-P1-004 — Ownership & Privacy Boundary / Core RLS Identity

**BL:** BL-P1-004  
**Phase:** Phase 1C — Ownership & Privacy  
**Status:** VERIFIED  
**Verification mode:** Actual GitHub + actual Supabase SQL verification  
**Canonical semantics:** UNCHANGED  
**OQ-02:** OPEN  

## 1. Audit finding before mutation

The BL-P1-004 package proposed enabling RLS on the four identity tables and adding owner-isolated SELECT policies.

Actual Supabase preflight showed an intermediate state: RLS was already enabled on all four identity tables, but `pg_policies` returned no policies for those tables. Consequently authenticated principals could not read their own identity rows; the boundary was fail-closed but incomplete.

Actual GitHub preflight showed no BL-P1-004 migration/evidence artifact on `dev` at the time of audit. BL-P1-003 artifacts were present on `dev`.

This was an implementation-state gap, not a Frozen Baseline / Contract contradiction.

## 2. Mutation executed

Created and applied:

`database/migrations/20260810100000_enable_identity_rls.sql`

The migration:
- creates `public.current_account_id()` as `STABLE SECURITY DEFINER` with locked `search_path=public`;
- revokes helper execution from `PUBLIC` and `anon`, grants it to `authenticated`;
- enables RLS on `accounts`, `sh_instances`, `sh_ownership`, `account_auth_links`;
- creates one SELECT-own policy per identity table;
- creates no INSERT/UPDATE/DELETE policies;
- does not use `FORCE ROW LEVEL SECURITY`;
- does not add identity-resolution, governance, memory/context, clone, transfer, or recovery logic.

Supabase migration applied successfully as `enable_identity_rls`.

## 3. Actual verification

### RLS state

Actual query against project `second-head` (`pkhkgvsrqeupvwoqjwmd`) returned `rowsecurity=true` for all four identity tables:
- `account_auth_links`
- `accounts`
- `sh_instances`
- `sh_ownership`

### Policies

Actual `pg_policies` query returned exactly four SELECT policies:
- `account_auth_links_select_own`
- `accounts_select_own`
- `sh_instances_select_own`
- `sh_ownership_select_own`

No INSERT/UPDATE/DELETE policies were present for these tables.

### Helper security

Actual catalog inspection confirmed:
- `public.current_account_id()` exists;
- `SECURITY DEFINER = true`;
- `search_path=public` is locked;
- `authenticated` has EXECUTE privilege;
- `anon` does not have EXECUTE privilege.

### Owner isolation

Using PostgreSQL role `authenticated` with a real existing `auth.users` subject from the project:
- the authenticated principal could see exactly one Account row;
- the authenticated principal could not see another Account's SH row (`0` rows for the other SH).

### Unlinked principal

Using an unlinked test subject under role `authenticated`, reads returned no visible identity rows (fail-closed).

### Write default-deny

An authenticated INSERT attempt into `public.accounts` was rejected with PostgreSQL error `42501` (`new row violates row-level security policy`). The attempted row was not created.

### BL-P1-003 compatibility

Actual catalog inspection confirmed BL-P1-003 functions still exist with `SECURITY DEFINER` and locked `search_path=public`.

The existing identity provisioning function was invoked with the two already-linked subjects and returned the existing Account path without creating duplicate identities. The gated backfill function was re-run against the already-linked population and completed without creating duplicates.

This verifies compatibility with existing identity state, but does **not** constitute a fresh GoTrue signup E2E test.

## 4. Fresh GoTrue signup boundary

Fresh signup through the Supabase Auth / GoTrue lifecycle remains **NOT YET VERIFIED** in this evidence artifact.

The audit does not simulate that lifecycle by manually inserting into `auth.users`. A future Auth-API/client-level test is required if end-to-end signup behavior is to be promoted from NOT YET VERIFIED to ACTUAL VERIFIED.

## 5. Registry impact

`docs/constitution/registry.md` was not modified. Existing implementation-status values remain unchanged because BL-P1-004 establishes the identity-table RLS boundary but does not complete the broader privacy architecture for future memory/context domains or resolve OQ-02.

## 6. Conclusion

**BL-P1-004 PASS.**

The pre-mutation package contained no baseline/contract contradiction. The actual implementation gap (RLS enabled without policies) was corrected by the BL-P1-004 migration. Owner-isolated reads and default-deny writes are now verified on the four identity tables.
