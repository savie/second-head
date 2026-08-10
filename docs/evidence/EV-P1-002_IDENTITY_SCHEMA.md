# EV-P1-002 — Account & SH Identity Schema

**Backlog Item:** BL-P1-002
**Phase:** Phase 1B — Identity
**Status:** DONE / PASS — schema mutation verified
**Repository:** savie/second-head
**Branch:** dev
**Supabase Project:** second-head (`pkhkgvsrqeupvwoqjwmd`)

## Scope
Implemented the Phase 1B identity schema only:
- `public.accounts`
- `public.sh_instances`
- `public.sh_ownership`
- `public.account_auth_links`

No RLS policies, authentication trigger, identity-resolution service, clone semantics, continuity engine, or governance engine were introduced.

## Authority
- SH Full Execution Strategy §6.2, §6.4, §6.5
- SH Full Implementation Contract §4.1–§4.3
- SH Full Build Scope §9–§10.3
- SH Core Canonical §14 and §26
- SH Full Implementation Guide §8

## Verification
Supabase migration history contains:
- `20260810070725` — `create_identity_schema`

The `public` schema contains exactly four application tables after this mutation:
- `account_auth_links`
- `accounts`
- `sh_instances`
- `sh_ownership`

Relevant constraints/indexes verified:
- `accounts_email_lower_unique`: case-insensitive uniqueness of account email.
- `sh_instances_one_primary_per_account`: one primary SH per account.
- `sh_ownership_account_sh_fk`: ownership account/SH pair must match an existing SH instance relationship.
- `sh_ownership_one_role_per_sh`: prevents duplicate ownership role rows for the same SH.
- `account_auth_links_provider_subject_unique`: one authentication subject per provider maps to at most one account link.
- `account_id` and `sh_id` are distinct primary keys on separate identity tables.

## Existing Auth Boundary
Existing `auth.users` records were not converted into Accounts or SH instances. Population of `account_auth_links` and the identity creation flow remain BL-P1-003 scope.

## Governance Boundary
OQ-02 remains OPEN. No canonical invariant or canonical classification was changed by this implementation.

## Repository Artifact
Migration source of truth:
`database/migrations/20260810070725_create_identity_schema.sql`

The migration filename was aligned to the actual Supabase migration version after verification.

## Remaining Phase 1 Work
- BL-P1-003: identity creation/auth linkage flow.
- BL-P1-004: RLS/privacy enforcement.
- BL-P1-005: identity resolution service.
