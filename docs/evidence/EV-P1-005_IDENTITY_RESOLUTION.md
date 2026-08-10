# EV-P1-005 — Identity Resolution & Verification Foundation

**BL:** BL-P1-005  
**Phase:** Phase 1B/1C — Identity Resolution Foundation  
**Status:** VERIFIED — implementation + database verification  
**Verification mode:** Actual GitHub + actual Supabase SQL verification  
**Canonical semantics:** UNCHANGED  
**OQ-02:** OPEN  

## 1. Audit finding before mutation

The BL-P1-005 package was audited against the live `dev` repository and live Supabase project `second-head` (`pkhkgvsrqeupvwoqjwmd`). No Frozen Baseline / Implementation Contract contradiction was identified.

One engineering hardening revision was made before mutation: `resolve_identity()` is not a public RPC. EXECUTE was revoked from `PUBLIC` and `anon`, and granted only to `authenticated`, matching the established BL-P1-004 security posture for `current_account_id()`.

This was an implementation-hardening correction, not a canonical contradiction.

## 2. Actual preflight

### GitHub — ACTUAL VERIFIED

Repository: `savie/second-head`  
Branch: `dev`  
Default branch: `dev`

Existing BL-P1-004 migration and evidence were present before BL-P1-005 mutation. The BL-P1-004 evidence records actual RLS verification and owner-isolated reads/default-deny writes.

### Supabase — ACTUAL VERIFIED

Project: `second-head` (`pkhkgvsrqeupvwoqjwmd`)

Applied migrations before BL-P1-005 included:
- `create_identity_schema`
- `create_identity_creation_flow`
- `backfill_existing_auth_users`
- `enable_identity_rls`

Live identity state before BL-P1-005:
- `auth.users`: 2
- `accounts`: 2
- `account_auth_links`: 2
- primary SHs: 2
- OWNER rows: 2
- duplicate normalized emails: 0
- accounts without a PRIMARY SH: 0
- PRIMARY SHs without OWNER row: 0
- auth subjects mapped to multiple accounts: 0

Live RLS state:
- all four identity tables have RLS enabled;
- `FORCE ROW LEVEL SECURITY` is false on all four;
- exactly four identity SELECT policies are present;
- no INSERT/UPDATE/DELETE policy is present for the identity tables.

Live BL-P1-003 functions remain present with SECURITY DEFINER and locked `search_path=public`.

## 3. Mutation executed

Created on GitHub `dev`:

`database/migrations/20260810110000_create_identity_resolution.sql`

Applied to Supabase as migration:

`create_identity_resolution`

The migration creates `public.resolve_identity()` with:
- no parameters;
- `RETURNS TABLE(account_id, sh_id, ownership_role)`;
- `STABLE`;
- `SECURITY DEFINER`;
- locked `search_path=public`;
- current-principal resolution via `auth.uid()` only;
- explicit traversal through `account_auth_links -> accounts -> PRIMARY sh_instances -> sh_ownership`;
- fail-closed empty result when no valid identity exists;
- deterministic `IDENTITY_CONFLICT` exception if more than one resolution row is found;
- no identity creation, merge, auto-selection, or authorization logic.

Execution privileges:
- `PUBLIC`: denied
- `anon`: denied
- `authenticated`: granted

## 4. Actual post-mutation verification

### Function catalog — ACTUAL VERIFIED

`public.resolve_identity()` exists with:
- SECURITY DEFINER = true
- volatility = STABLE
- no parameters
- `SET search_path TO 'public'`

Privilege inspection confirmed:
- `anon_exec = false`
- `authenticated_exec = true`

### Existing linked identity resolution — ACTUAL VERIFIED

Under PostgreSQL role `authenticated`, with a database request-JWT subject claim set to one of the existing linked auth subjects, `resolve_identity()` returned exactly one matching tuple:

`ACCOUNT_ID -> PRIMARY SH_ID -> OWNER`

The returned identity matched the existing ownership graph. This verifies database-level current-principal resolution against an existing linked identity.

### Unauthenticated resolution — ACTUAL VERIFIED

With no request JWT subject claim, `resolve_identity()` returned an empty result set.

### Authenticated but unlinked principal — ACTUAL VERIFIED

Under PostgreSQL role `authenticated`, with a non-existent subject claim, `resolve_identity()` returned no rows.

This confirms fail-closed behavior and no identity creation on resolution failure.

### Cross-account parameter spoofing — ACTUAL VERIFIED BY DESIGN + EXECUTION

`resolve_identity()` accepts no identity parameter and derives the subject exclusively from `auth.uid()`. Therefore a caller cannot request another account by supplying an arbitrary ACCOUNT_ID or SH_ID parameter. The executed linked-principal test resolved only the principal represented by its request subject claim.

### Phase 1 identity invariants — ACTUAL VERIFIED

Live counts and constraint/index inspection confirm:
- 2 auth users;
- 2 Accounts;
- 2 auth links;
- 2 PRIMARY SHs;
- 2 OWNER rows;
- zero duplicate normalized emails;
- zero Accounts without PRIMARY SH;
- zero PRIMARY SHs without OWNER row;
- zero auth subjects mapped to multiple Accounts;
- unique `(provider, subject_ref)` constraint present;
- unique normalized email index present;
- one-primary-per-account partial unique index present.

### BL-P1-004 regression boundary — ACTUAL VERIFIED

Live Supabase catalog inspection after BL-P1-005 confirms all four identity tables remain RLS-enabled, not FORCE-RLS, with the four established SELECT-own policies and no write policies.

The BL-P1-004 evidence artifact remains present on `dev` and records the prior actual verification of owner isolation and write default-deny.

## 5. Fresh GoTrue signup boundary

**NOT YET VERIFIED — REAL SUPABASE AUTH LIFECYCLE.**

The verification above uses existing `auth.users` identities and controlled database request-JWT claim simulation. It does **not** constitute a fresh signup through the Supabase Auth / GoTrue client/API lifecycle.

No manual INSERT into `auth.users` was used as a substitute for a real signup lifecycle test. A future Auth API/client-level test is required before this residual can be promoted to ACTUAL VERIFIED.

This residual does not block BL-P1-005 identity-resolution foundation verification.

## 6. Registry / authority impact

`docs/constitution/registry.md` was not modified. Existing implementation-status values remain unchanged. OQ-02 remains OPEN. Canonical semantics are unchanged.

No authorization engine, governance evaluator, permission matrix, memory/context RLS, runtime identity service, ownership transfer, clone, recovery, or Creator-superuser implementation was introduced.

## 7. Conclusion

**BL-P1-005 PASS.**

The live implementation was audited before mutation, one security hardening adjustment was applied to the proposed design, the migration was applied successfully, and the identity-resolution foundation was actually verified against the live Supabase identity state.

Phase 1 closure is **not declared by this evidence artifact**; the Owner may now review the complete Phase 1 DoD and decide whether Phase 1 should be closed, with the fresh GoTrue lifecycle residual explicitly remaining NOT YET VERIFIED.
