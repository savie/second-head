# EV-P3A-005 — Memory Ownership Boundary

**Backlog:** BL-P3A-005  
**Acceptance Criterion:** AC-MEM-05  
**Phase:** 3A — Memory Storage  
**Status:** PASS  
**Verification Date:** 2026-08-11

## Objective

Verify that each stored memory has an explicit SH ownership anchor and that the database authorization boundary prevents a memory from being owned or written outside the authenticated account's SH domain.

## GitHub Verification

The current `dev` migration `database/migrations/20260811034535_create_memory_storage_and_knowledge_eligibility.sql` defines:

- `memories.sh_id` as `NOT NULL` with a foreign key to `sh_instances(sh_id)`.
- `scope` with allowed values `PRIVATE` / `GENERAL` and default `PRIVATE`.
- `visibility` with allowed values `OWNER_ONLY` / `SHARED` and default `OWNER_ONLY`.
- INSERT, SELECT, UPDATE, and DELETE RLS policies resolving ownership through `sh_instances.account_id` and `account_auth_links.subject_ref = auth.uid()`.

Therefore a memory cannot exist without an owning SH reference, and authenticated database access is constrained to the account owning that SH.

## Actual Supabase Verification

Project: `pkhkgvsrqeupvwoqjwmd`

Verified actual `public.memories` state:

- RLS enabled: `true`.
- `sh_id` is `NOT NULL` and references `public.sh_instances(sh_id)` with `ON DELETE CASCADE`.
- `scope` is constrained to `PRIVATE` / `GENERAL`; default `PRIVATE`.
- `visibility` is constrained to `OWNER_ONLY` / `SHARED`; default `OWNER_ONLY`.
- `memories` currently contains no persistent rows after prior verification cleanup.

## Ownership Boundary Result

The ownership model is explicit at storage level (`sh_id`) and authorization level (account-to-SH ownership through `account_auth_links`).

BL-P3A-004 already verified both directions of cross-account isolation using the two existing active account/auth subjects. That verification established that Account A can access SH-A memory but not SH-B memory, and Account B can access SH-B memory but not SH-A memory.

BL-P3A-005 therefore does not require a new schema, policy, or migration. The ownership boundary is already realized and independently verified at the database authorization boundary.

## Result

**AC-MEM-05: PASS**

No realization was required.

## Evidence Integrity

- No persistent test rows were created for this completion check.
- No migration was created or modified for BL-P3A-005.
- Existing ownership/isolation mechanisms were verified against the actual Supabase state.
- GitHub `dev` contains the corresponding migration source.
