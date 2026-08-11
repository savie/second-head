# EV-P3A-005 — Memory Ownership Boundary

**Backlog:** BL-P3A-005  
**Acceptance Criterion:** AC-MEM-05  
**Phase:** 3A — Memory Storage  
**Status:** PASS  
**Verification Date:** 2026-08-11

## Objective

Verify that each stored memory has an explicit SH ownership anchor and that the database authorization boundary prevents a memory from being owned or written outside the authenticated account's SH domain.

## Discrepancy Audit

An initial `pg_policies` inspection through the SQL tool returned no rows for `public.memories`, which appeared inconsistent with the existing P3A-004 evidence and the applied memory migration.

The discrepancy was checked directly against PostgreSQL's policy catalog (`pg_policy`). The four existing `memories_owner_*` policies were present. A duplicate-policy creation attempt also returned PostgreSQL `policy already exists`, confirming that the policies were not actually absent.

Therefore the apparent absence was an inspection visibility/result discrepancy, not a missing RLS implementation.

## Minimal Reconciliation

The ownership policies were normalized to reuse the existing Phase 1 ownership helper `public.current_account_id()` rather than repeating the auth-link lookup inside the memory policy.

This does **not** introduce a new ownership model. The authorization relationship remains:

`auth subject → account → SH → memory.sh_id`

The reconciliation migration is:

`database/migrations/20260811051355_reconcile_memories_rls_ownership_helper.sql`

Only the four `memories_owner_*` policies were replaced. No table, column, ownership relationship, or privacy boundary was changed.

## Actual Supabase Verification

Project: `pkhkgvsrqeupvwoqjwmd`

Verified actual `public.memories` state:

- RLS enabled: `true`.
- `memories.sh_id` is `NOT NULL` and references `public.sh_instances(sh_id)` with `ON DELETE CASCADE`.
- `scope` is constrained to `PRIVATE` / `GENERAL`; default `PRIVATE`.
- `visibility` is constrained to `OWNER_ONLY` / `SHARED`; default `OWNER_ONLY`.
- Four ownership policies are present in `pg_policy`: SELECT, INSERT, UPDATE, DELETE.
- UPDATE has both `USING` and `WITH CHECK` ownership predicates, preventing an authenticated principal from moving a memory outside its own SH domain through an update.
- `memories` contains no persistent test rows after verification.

## Cross-Account Evidence

BL-P3A-004 already verified both directions of cross-account isolation using the two existing active account/auth subjects: each account could access its own SH memory and not the other account's SH memory.

P3A-005 is satisfied by the combination of:

1. mandatory `memories.sh_id` ownership anchor;
2. existing account → SH ownership model;
3. SELECT/INSERT/DELETE ownership policies;
4. UPDATE `USING` + `WITH CHECK` ownership enforcement; and
5. prior two-direction cross-account verification from BL-P3A-004.

## Result

**AC-MEM-05: PASS**

The realization was limited to policy normalization against the existing Phase 1 ownership helper. No new architectural ownership model was introduced.

## Evidence Integrity

- No persistent test rows remain.
- No new table or column was created.
- No ownership model or privacy boundary was changed.
- The reconciliation migration is represented in GitHub `dev` and is applied in actual Supabase.
- Evidence reflects the final verified Supabase policy catalog and current GitHub migration source.
