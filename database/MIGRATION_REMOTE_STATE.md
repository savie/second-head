# SECOND HEAD — Remote Migration State Reconciliation

**Document Type:** Read-only reconciliation ledger
**Status:** VERIFIED — PRE-PHASE-3 CHECKPOINT
**Branch:** `dev`
**Supabase Project:** `pkhkgvsrqeupvwoqjwmd`

## Purpose

This ledger records the Supabase migration history actually verified on the remote project and its relationship to the migration artifacts currently present in GitHub.

It does **not** execute, repair, revert, or re-apply any remote migration.

## Verified Remote Migration History

The Supabase project currently reports these applied migrations, in order:

| Version | Remote migration | Repository artifact status |
|---|---|---|
| 20260810070725 | create_identity_schema | PRESENT: `database/migrations/20260810070725_create_identity_schema.sql` |
| 20260810080127 | create_identity_creation_flow | REMOTE VERSION PRESENT; repository contains equivalent BL-P1-003 artifact under a different timestamp: `20260810090000_create_identity_creation_flow.sql` |
| 20260810080214 | backfill_existing_auth_users | REMOTE VERSION PRESENT; repository artifact requires historical reconciliation |
| 20260810083325 | enable_identity_rls | REMOTE VERSION PRESENT; repository artifact requires historical reconciliation |
| 20260810092541 | create_identity_resolution | PRESENT: `database/migrations/20260810092541_create_identity_resolution.sql` |
| 20260810095709 | harden_identity_function_privileges | PRESENT: `database/migrations/20260810095709_harden_identity_function_privileges.sql` |
| 20260810130620 | create_permission_matrix | PRESENT: `database/migrations/20260810130620_create_permission_matrix.sql` |
| 20260810131800 | create_governance_evaluator | PRESENT: `database/migrations/20260810131800_create_governance_evaluator.sql` |
| 20260810132413 | create_policy_enforcement_engine | PRESENT: `database/migrations/20260810132413_create_policy_enforcement_engine.sql` |
| 20260810132700 | create_isolation_checker | REMOTE VERSION PRESENT; repository has the same function under `supabase/migrations/20260810135000_create_isolation_checker.sql` rather than the canonical `database/migrations/` location |
| 20260810133755 | create_access_decision_gate | REMOTE VERSION PRESENT; repository artifact requires historical reconciliation |
| 20260810142641 | p2_007_creator_authority_boundary | PRESENT: `database/migrations/20260810142641_p2_007_creator_authority_boundary.sql` |
| 20260810160700 | p2_009_runtime_access_boundary | PRESENT: `database/migrations/20260810160700_p2_009_runtime_access_boundary.sql` |
| 20260810161457 | create_system_governance_boundary | REMOTE VERSION PRESENT; repository artifact requires historical reconciliation |

## Important Interpretation

The remote database is **already migrated** through the completed Phase 2 implementation. The current issue is repository/history representation, not an instruction to re-run Phase 1/2 schema mutations.

The repository migration framework states that `database/migrations/` is the canonical location for application schema migrations and that Git is the source of truth for schema definitions, while the remote database is the applied state that should converge to the repository through controlled workflow.

## Safety Decision for This Checkpoint

Historical migrations are immutable under the repository migration framework. Therefore this reconciliation does **not** rename, delete, or rewrite already-committed migration files, and it does **not** repair remote migration history merely to make timestamps cosmetically identical.

No fictional SQL migration is introduced for a remote version whose original SQL definition has not been recovered and verified.

## Current State

- Remote migration history: **VERIFIED**
- Existing application schema: **ALREADY APPLIED**
- Repository canonical migration set: **PARTIALLY SYNCHRONIZED**
- Timestamp/name discrepancies: **DOCUMENTED**
- Remote mutation performed by this reconciliation: **NONE**
- Re-run of existing Phase 1/2 migrations: **NONE**
- Historical migration reconstruction: **DEFERRED until source SQL can be recovered/verified**

## Boundary

This ledger is a synchronization checkpoint before Phase 3. It does not authorize Phase 3 implementation and does not resolve OQ-02, OQ-03, or OQ-04.
