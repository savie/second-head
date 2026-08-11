# EV-P3A-004 — Memory Isolation per SH

**Backlog:** BL-P3A-004  
**Acceptance Criterion:** AC-MEM-04  
**Phase:** 3A — Memory Storage  
**Status:** PASS  
**Verification Date:** 2026-08-11

## Objective

Verify that memory belonging to one SH is isolated from another SH at the database authorization boundary.

## Actual Supabase State

Project: `pkhkgvsrqeupvwoqjwmd`

The `public.memories` table has RLS policies for SELECT, INSERT, UPDATE, and DELETE. Each policy resolves ownership through the relationship:

`memories.sh_id → sh_instances.account_id → account_auth_links.subject_ref → auth.uid()`

This means the authenticated subject must own the account associated with the target `sh_id`.

## Cross-Account Verification

Two existing active account/auth subjects were used as the verification identities. No new persistent account or test infrastructure was created.

Test data was created inside a transaction and rolled back after verification.

| Test | Expected | Actual |
|---|---:|---:|
| Account A sees memory of SH-A | 1 | 1 |
| Account A sees memory of SH-B | 0 | 0 |
| Account B sees memory of SH-A | 0 | 0 |
| Account B sees memory of SH-B | 1 | 1 |

The test therefore proves both directions of cross-account read isolation.

## Write Boundary

The same RLS ownership predicate is applied to INSERT, UPDATE, and DELETE policies. Cross-account write access is therefore denied by the same authorization boundary. No persistent mutation was left behind by the verification run.

## Result

**AC-MEM-04: PASS**

No schema or policy realization was required because the isolation mechanism already existed and the actual Supabase verification confirmed the intended cross-account boundary.

## Evidence Integrity

- No persistent test rows remain.
- No migration was created or modified.
- No production schema mutation was required.
- Evidence corresponds to the actual `dev` implementation and actual Supabase project state at verification time.
