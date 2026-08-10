# EV-P1-006 — Phase 1 Closure Audit / Evidence Reconciliation

**BL:** BL-P1-006  
**Phase:** Phase 1 — Constitution & Identity  
**Status:** AUDIT REQUIRES REVISION — Phase 1 closure not approved  
**Verification mode:** Actual GitHub + actual Supabase SQL verification  
**Canonical semantics:** UNCHANGED  
**OQ-02:** OPEN  

## 1. Audit scope

The submitted BL-P1-006 pre-closure package was audited against the live `dev` repository and live Supabase project `second-head` (`pkhkgvsrqeupvwoqjwmd`). The audit specifically checked the package's ACTUAL VERIFIED claims, BL-P1-005 `resolve_identity()`, identity-table RLS state, function privileges, live identity invariants, and migration-history alignment.

## 2. Audit result

The package is **not accepted as a Phase 1 closure record in its submitted form**.

The underlying Phase 1 identity/RLS state is substantially present and the canonical design remains consistent, but two engineering/evidence discrepancies were found:

1. Three BL-P1-003 `SECURITY DEFINER` functions in `public` were still executable by `anon`, `authenticated`, and `service_role`, despite the migration artifact containing `REVOKE EXECUTE ... FROM PUBLIC` statements and the package/evidence describing them as internal/non-client-facing functions.
2. The GitHub BL-P1-005 migration filename timestamp (`20260810110000`) did not match the actual Supabase applied migration version (`20260810092541`). Migration history is therefore not reproducibly aligned with the repository until reconciled.

Neither finding is a Frozen Baseline / Core Canonical / Implementation Contract contradiction. Both are engineering/evidence reconciliation issues.

## 3. Actual GitHub state

Repository: `savie/second-head`  
Branch: `dev`  
Default branch: `dev`

The latest pre-audit implementation commits included BL-P1-005 identity-resolution implementation and evidence.

The repository contained:
- BL-P1-003 identity creation/auth linkage migration;
- BL-P1-004 ownership/privacy RLS migration and evidence;
- BL-P1-005 identity-resolution migration and evidence.

The repository's original BL-P1-005 migration filename was:

`database/migrations/20260810110000_create_identity_resolution.sql`

This was found to be inconsistent with the live Supabase migration history.

## 4. Actual Supabase state before hardening

Project: `second-head` (`pkhkgvsrqeupvwoqjwmd`)  
Project ref: `pkhkgvsrqeupvwoqjwmd`  
PostgreSQL: 17.6

Applied migration history included:

- `20260810070725 create_identity_schema`
- `20260810080127 create_identity_creation_flow`
- `20260810080214 backfill_existing_auth_users`
- `20260810083325 enable_identity_rls`
- `20260810092541 create_identity_resolution`

The live identity state was:

- `auth.users`: 2
- `accounts`: 2
- `account_auth_links`: 2
- PRIMARY SHs: 2
- ownership rows: 2

Identity constraints/indexes included:

- unique normalized Account email;
- unique `(provider, subject_ref)` auth linkage;
- one PRIMARY SH per Account via partial unique index;
- `sh_id` primary key;
- explicit `(sh_id, account_id)` ownership foreign-key relationship.

All four identity tables had RLS enabled and `FORCE ROW LEVEL SECURITY = false`. Exactly four SELECT-own policies were present and no INSERT/UPDATE/DELETE policies were present.

## 5. Function privilege finding

Actual PostgreSQL catalog inspection showed the following pre-hardening ACL state:

- `public.provision_identity_for_auth_subject(text,text)` — executable by `anon`, `authenticated`, and `service_role`;
- `public.handle_new_auth_user()` — executable by `anon`, `authenticated`, and `service_role`;
- `public.backfill_existing_auth_users()` — executable by `anon`, `authenticated`, and `service_role`.

All three functions were `SECURITY DEFINER` with `search_path=public` and owned by `postgres`.

This contradicted the intended internal/non-client-facing posture represented by the migration comments and evidence discipline. In particular, a parameterized SECURITY DEFINER provisioning function should not be exposed through the public Data API surface.

`public.current_account_id()` and `public.resolve_identity()` were correctly restricted: `anon` could not execute them and `authenticated` could execute them.

## 6. Engineering correction executed

The following privilege hardening was applied to the live Supabase project:

- revoke EXECUTE from `PUBLIC`, `anon`, `authenticated`, and `service_role` for `provision_identity_for_auth_subject(text,text)`;
- revoke EXECUTE from `PUBLIC`, `anon`, `authenticated`, and `service_role` for `handle_new_auth_user()`;
- revoke EXECUTE from `PUBLIC`, `anon`, `authenticated`, and `service_role` for `backfill_existing_auth_users()`.

Post-change catalog verification confirmed all three functions now have only the `postgres` EXECUTE ACL, with `anon_exec=false`, `authenticated_exec=false`, and `service_exec=false`.

The trigger path remains valid because `handle_new_auth_user()` is a `SECURITY DEFINER` trigger function and invokes the provisioning helper as the privileged function owner.

A migration was applied to record the correction:

`20260810095709 harden_identity_function_privileges`

## 7. BL-P1-005 verification after correction

`public.resolve_identity()` remains:

- `SECURITY DEFINER`;
- `STABLE`;
- `SET search_path TO 'public'`;
- parameterless;
- executable by `authenticated`;
- not executable by `anon`.

With PostgreSQL role `authenticated` and a controlled request JWT subject claim corresponding to an existing linked Auth subject, `resolve_identity()` returned exactly one tuple containing the current Account, PRIMARY SH, and OWNER role.

The correction did not alter the identity-resolution semantics.

## 8. Migration-history reconciliation

The live Supabase migration version for BL-P1-005 is:

`20260810092541 create_identity_resolution`

The repository originally contained the same migration SQL under:

`20260810110000_create_identity_resolution.sql`

Because Supabase compares migration timestamps between repository files and remote migration history, this mismatch is material to reproducibility and deployment hygiene.

The repository was corrected by:

- adding `database/migrations/20260810092541_create_identity_resolution.sql` with the applied BL-P1-005 SQL;
- removing the mismatched `20260810110000_create_identity_resolution.sql` artifact.

No remote migration-history rewrite was performed; the repository now follows the actual applied version.

## 9. Phase 1 DoD interpretation

The audit did **not** find evidence of a canonical semantic contradiction.

The following remain substantively verified in the live database:

- SH_ID persistent identity anchor;
- ACCOUNT_ID identity anchor;
- explicit ownership relationship;
- identity-table RLS;
- owner-isolated SELECT boundary;
- default-deny writes through absence of write policies;
- one PRIMARY SH per Account;
- unique normalized Account email;
- unique auth-subject linkage;
- current-principal identity resolution;
- cross-account parameter spoofing prevented by parameterless `resolve_identity()`;
- OQ-02 remains OPEN;
- fresh GoTrue signup E2E remains NOT YET VERIFIED.

However, the submitted BL-P1-006 package's evidence discipline cannot remain marked `ACTUAL VERIFIED` without incorporating the function-privilege correction and migration-history reconciliation.

## 10. Closure status

**Phase 1 remains OPEN / NOT CLOSED at this checkpoint.**

The submitted BL-P1-006 package is superseded as a closure artifact by this audit reconciliation record. It must not be used to claim Phase 1 CLOSED or authorize Phase 2 by itself.

The next closure gate is a fresh read-only verification of:

1. GitHub `dev` migration/evidence state;
2. Supabase migration history;
3. function ACLs;
4. identity-table RLS/policies;
5. identity invariants;
6. `resolve_identity()` behavior;
7. absence of new canonical/contract contradiction.

If those checks pass, a revised Phase 1 closure package may be accepted by the Owner.

## 11. Canonical boundary

No canonical authority was changed.

No OQ-02 decision was made.

No Phase 2 implementation was authorized by this audit.
