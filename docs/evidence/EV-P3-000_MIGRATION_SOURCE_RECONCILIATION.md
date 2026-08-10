# EV-P3-000 — Migration Source Reconciliation

Status: VERIFIED WITH HISTORICAL SOURCE GAP
Date: 2026-08-11
Branch: `dev`

## Purpose

Merekonsiliasi migration source repository dengan applied migration state pada Supabase sebelum Phase 3 dimulai.

## Authority / Existing Repository Rule

`database/MIGRATION_FRAMEWORK.md` menetapkan:

- `database/migrations/` sebagai satu-satunya lokasi canonical migration schema aplikasi;
- Git repository sebagai source-of-truth definisi schema aplikasi;
- remote Supabase sebagai applied state;
- `supabase/` bukan lokasi canonical migration aplikasi.

## Actual Supabase Applied State

Supabase project `pkhkgvsrqeupvwoqjwmd` saat audit memiliki 14 applied migrations:

1. `20260810070725_create_identity_schema`
2. `20260810080127_create_identity_creation_flow`
3. `20260810080214_backfill_existing_auth_users`
4. `20260810083325_enable_identity_rls`
5. `20260810092541_create_identity_resolution`
6. `20260810095709_harden_identity_function_privileges`
7. `20260810130620_create_permission_matrix`
8. `20260810131800_create_governance_evaluator`
9. `20260810132413_create_policy_enforcement_engine`
10. `20260810132700_create_isolation_checker`
11. `20260810133755_create_access_decision_gate`
12. `20260810142641_p2_007_creator_authority_boundary`
13. `20260810160700_p2_009_runtime_access_boundary`
14. `20260810161457_create_system_governance_boundary`

## Repository State Before Reconciliation

Repository `dev` contained a non-canonical file:

`supabase/migrations/20260810135000_create_isolation_checker.sql`

Its content SHA was `d97f4a59d7cf13c21fbdc2d3b8bfbae6d74dbb1f`.

No corresponding historical source files for the other 13 applied migration versions were present in the inspected repository paths.

## Reconciliation Performed

The verified isolation-checker source was moved into the canonical migration location using the actual applied migration version:

`database/migrations/20260810132700_create_isolation_checker.sql`

The content SHA remained exactly:

`d97f4a59d7cf13c21fbdc2d3b8bfbae6d74dbb1f`

The non-canonical duplicate under `supabase/migrations/` was removed.

No SQL migration was applied to Supabase because the corresponding migration was already present in the applied state.

## Verification

- The canonical repository file content matches the previous non-canonical file byte-for-byte at the GitHub content level (same SHA).
- Supabase reports `20260810132700_create_isolation_checker` as applied.
- `private.isolation_checker(...)` exists in Supabase with `SECURITY DEFINER` and locked `search_path`.
- `anon` does not have EXECUTE privilege.
- `authenticated` has EXECUTE privilege.
- No Phase 3 database migration was created or applied.

## Source-of-Truth Decision

### CURRENT AGREED ENGINEERING REALIZATION

Going forward, `database/migrations/` is the canonical Git source-of-truth for application schema migrations, consistent with the existing Migration Framework.

Supabase remains the runtime/applied state and must be verified against the repository before new Phase 3 schema work is applied.

### HISTORICAL GAP — OPEN

The repository does not currently contain the complete source set corresponding to all 14 migrations already applied in Supabase. The missing historical SQL must NOT be fabricated or reconstructed as if it were authoritative.

This gap is therefore recorded as an open repository reconciliation item rather than silently treated as resolved.

## Mutation Boundary

No database schema mutation was performed during this reconciliation.

Repository mutations were limited to:
1. adding the verified canonical isolation-checker migration source;
2. removing its non-canonical duplicate;
3. adding this evidence record.

## Result

Migration source location is now structurally aligned with the repository's existing framework for the verified migration. The historical source set is **not yet complete**, and Phase 3 must not assume that all historical migrations can be replayed from GitHub until that gap is separately resolved.
