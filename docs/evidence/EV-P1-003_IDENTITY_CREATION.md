# EV-P1-003 — Identity Creation & Auth Linkage

**Status:** PASS — EXECUTED AND VERIFIED
**Phase:** Phase 1B — Identity
**Source commit at audit start:** `c249c48b47ce5e8c2be8280b1ae3c4b968f38d6f`
**Branch:** `dev`

## 1. Audit Result

BL-P1-003 PRE-MUTATION PACKAGE Revised v2 was audited against the actual GitHub repository state and the actual Supabase project state before mutation.

One implementation discrepancy was found and corrected before execution:

- Revised v2 proposed adding `UNIQUE(provider, subject_ref)` in BL-P1-003.
- The actual BL-P1-002 migration already defines this uniqueness constraint as `account_auth_links_provider_subject_unique`.
- Re-adding it in BL-P1-003 would have caused a migration failure.
- BL-P1-003 therefore preserves the existing BL-P1-002 constraint and does not recreate it.

No baseline/contract contradiction was found. This was an implementation-plan discrepancy, so no Owner mediation was required.

## 2. Actual Supabase Preflight

At pre-mutation audit time:

- Applied migration: `20260810070725_create_identity_schema`
- `auth.users`: 2 rows
- `public.accounts`: 0 rows
- `public.account_auth_links`: 0 rows
- `public.sh_instances`: 0 rows
- `public.sh_ownership`: 0 rows
- Existing auth subjects had usable email values.
- `account_auth_links_provider_subject_unique` already existed.
- No BL-P1-003 function existed.
- No `on_auth_user_created` trigger existed.

This satisfied the gated backfill preconditions.

## 3. Executed Changes

### GitHub

Created on `dev`:

- `database/migrations/20260810090000_create_identity_creation_flow.sql`
- `database/migrations/20260810091000_backfill_existing_auth_users.sql`
- `docs/evidence/EV-P1-003_IDENTITY_CREATION.md`

### Supabase

Applied:

- `create_identity_creation_flow`
- `backfill_existing_auth_users`

Created:

- `public.provision_identity_for_auth_subject(text, text)`
- `public.handle_new_auth_user()` returning `trigger`
- `public.backfill_existing_auth_users()` returning `void`
- `auth.users` AFTER INSERT trigger `on_auth_user_created`

The existing BL-P1-002 auth-subject uniqueness index was preserved, not recreated.

## 4. Post-Mutation Verification

Actual Supabase state after execution:

| Check | Result |
|---|---:|
| auth.users | 2 |
| Accounts | 2 |
| Auth links | 2 |
| PRIMARY SH | 2 |
| OWNER relationships | 2 |
| Fully joined auth→account→primary-SH→owner rows | 2 |
| account_auth_links(provider, subject_ref) uniqueness | VERIFIED |
| on_auth_user_created trigger | VERIFIED |
| handle_new_auth_user() RETURNS trigger | VERIFIED |
| SECURITY DEFINER | VERIFIED |
| search_path=public | VERIFIED |

All 2 existing auth users were backfilled exactly once into the SECOND HEAD identity domain.

## 5. Scope Verification

Not implemented by BL-P1-003:

- RLS / DEFAULT DENY / privacy policies
- cross-SH isolation enforcement
- identity resolution service
- end-to-end identity verification
- CLONE_SH
- ownership transfer
- account recovery
- OQ-02 resolution
- new conflict/audit logging surface

## 6. Registry / Governance

`docs/constitution/registry.md` was not modified by BL-P1-003 because the relevant implementation statuses remain `PARTIALLY_IMPLEMENTED` after this step.

`docs/constitution/change_log.md` was not modified for the same reason.

OQ-02 remains OPEN.

## 7. Important Verification Limitation

The migration and trigger definition were verified directly in PostgreSQL, and the gated backfill was executed successfully against the two existing auth users.

A fresh end-to-end signup through the external Supabase Auth/GoTrue service was not synthesized by directly inserting into `auth.users`; such direct manipulation would not represent a real platform authentication flow. Therefore this evidence verifies the trigger object, function contract, and backfill path, while live client-signup behavior remains a future verification item when a real auth signup is exercised.

## 8. Conclusion

**BL-P1-003 PASS.**

Identity creation and auth linkage foundation is implemented for the current two pre-existing auth users, with PRIMARY SH and explicit OWNER relationships established. The auth trigger is installed for future auth-user creation. No canonical semantics or OQ-02 state were changed.
