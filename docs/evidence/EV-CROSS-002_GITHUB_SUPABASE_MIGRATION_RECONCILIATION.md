# EV-CROSS-002 — GitHub ↔ Supabase Migration Reconciliation

**Status:** DONE — RECONCILIATION CHECKPOINT
**Audit Scope:** Migration history and current migration-source representation
**Branch:** `dev`
**Supabase Project:** `pkhkgvsrqeupvwoqjwmd`
**Audit Date:** 2026-08-13
**Remote mutation:** NONE

## 1. Objective

Reconcile the actual applied migration history in Supabase DEV with the migration artifacts currently present in GitHub DEV.

This audit is read-only with respect to Supabase. It does not re-run, repair, rename, delete, or rewrite applied migrations.

## 2. Authority

`database/MIGRATION_FRAMEWORK.md` defines:

- `database/migrations/` as the only canonical location for application schema migrations;
- Git as the source-of-truth for application schema definitions;
- Supabase as the applied runtime state;
- committed migrations as immutable and forward-only;
- no fictional reconstruction of historical SQL.

## 3. Actual Supabase State

Supabase DEV currently reports **38 applied migrations**, ending with `20260812151652_p5d_001_recovery_backup_portability`.

The complete ordered remote list is recorded below.

| # | Supabase applied version | Repository representation | Disposition |
|---:|---|---|---|
| 1 | `20260810070725_create_identity_schema` | `database/migrations/20260810070725_create_identity_schema.sql` | VERIFIED — EXACT |
| 2 | `20260810080127_create_identity_creation_flow` | `database/migrations/20260810090000_create_identity_creation_flow.sql` | VERIFIED — HISTORICAL TIMESTAMP ALIAS |
| 3 | `20260810080214_backfill_existing_auth_users` | `database/migrations/20260810091000_backfill_existing_auth_users.sql` | VERIFIED — HISTORICAL TIMESTAMP ALIAS |
| 4 | `20260810083325_enable_identity_rls` | `database/migrations/20260810100000_enable_identity_rls.sql` | VERIFIED — HISTORICAL TIMESTAMP ALIAS |
| 5 | `20260810092541_create_identity_resolution` | `database/migrations/20260810092541_create_identity_resolution.sql` | VERIFIED — EXACT |
| 6 | `20260810095709_harden_identity_function_privileges` | `database/migrations/20260810095709_harden_identity_function_privileges.sql` | VERIFIED — EXACT |
| 7 | `20260810130620_create_permission_matrix` | `database/migrations/20260810130620_create_permission_matrix.sql` | VERIFIED — EXACT |
| 8 | `20260810131800_create_governance_evaluator` | `database/migrations/20260810131800_create_governance_evaluator.sql` | VERIFIED — EXACT |
| 9 | `20260810132413_create_policy_enforcement_engine` | `database/migrations/20260810132413_create_policy_enforcement_engine.sql` | VERIFIED — EXACT |
| 10 | `20260810132700_create_isolation_checker` | `database/migrations/20260810132700_create_isolation_checker.sql` | VERIFIED — EXACT |
| 11 | `20260810133755_create_access_decision_gate` | `database/migrations/2026081013_create_access_decision_gate.sql` | VERIFIED — REPOSITORY TIMESTAMP/NAME HYGIENE GAP |
| 12 | `20260810142641_p2_007_creator_authority_boundary` | `database/migrations/20260810142641_p2_007_creator_authority_boundary.sql` | VERIFIED — EXACT |
| 13 | `20260810160700_p2_009_runtime_access_boundary` | `database/migrations/20260810160700_p2_009_runtime_access_boundary.sql` | VERIFIED — EXACT |
| 14 | `20260810161457_create_system_governance_boundary` | `database/migrations/20260810231500_create_system_governance_boundary.sql` | VERIFIED — HISTORICAL TIMESTAMP ALIAS |
| 15 | `20260811034535_create_memory_storage_and_knowledge_eligibility` | `database/migrations/20260811034535_create_memory_storage_and_knowledge_eligibility.sql` | VERIFIED — EXACT |
| 16 | `20260811051355_reconcile_memories_rls_ownership_helper` | `database/migrations/20260811051355_reconcile_memories_rls_ownership_helper.sql` | VERIFIED — EXACT |
| 17 | `20260811103611_add_memory_relevance_scoring` | No original applied-version source found; later reconciliation source exists | HISTORICAL SOURCE GAP |
| 18 | `20260811114037_reconcile_memory_relevance_scoring_source` | `database/migrations/20260811120000_reconcile_memory_relevance_scoring_source.sql` | VERIFIED — RECONCILIATION TIMESTAMP ALIAS |
| 19 | `20260811114056_harden_memory_relevance_score_search_path` | `database/migrations/20260811121000_harden_memory_relevance_score_search_path.sql` | VERIFIED — RECONCILIATION TIMESTAMP ALIAS |
| 20 | `20260811170220_bounded_memory_retrieval` | `database/migrations/20260811170220_bounded_memory_retrieval.sql` | VERIFIED — EXACT |
| 21 | `20260811170253_harden_bounded_memory_retrieval_grants` | `database/migrations/20260811170253_harden_bounded_memory_retrieval_grants.sql` | VERIFIED — EXACT |
| 22 | `20260811175626_p3d_006_knowledge_storage` | `database/migrations/20260812000000_p3d_006_knowledge_storage.sql` | VERIFIED — HISTORICAL TIMESTAMP ALIAS |
| 23 | `20260811175637_p3d_006_knowledge_storage_constraints` | No matching canonical source verified | HISTORICAL SOURCE GAP |
| 24 | `20260811180150_p3d_007_knowledge_indexing` | `database/migrations/20260812010000_p3d_007_knowledge_indexing.sql` | VERIFIED — HISTORICAL TIMESTAMP ALIAS |
| 25 | `20260811180222_p3d_007_knowledge_indexing_verification` | No matching canonical source verified | HISTORICAL SOURCE GAP |
| 26 | `20260811181519_p3d_009_knowledge_retrieval` | `database/migrations/20260811181519_p3d_009_knowledge_retrieval.sql` | VERIFIED — EXACT |
| 27 | `20260811183239_p3e_001_context_assembly_engine` | `supabase/migrations/20260811183239_p3e_001_context_assembly_engine.sql` | VERIFIED — NON-CANONICAL LOCATION |
| 28 | `20260811183310_p3e_001_context_assembly_engine_grants` | `supabase/migrations/20260811183310_p3e_001_context_assembly_engine_grants.sql` | VERIFIED — NON-CANONICAL LOCATION |
| 29 | `20260811233033_p3e_008_context_budget_truncation` | `supabase/migrations/20260812190000_p3e_008_context_budget_truncation.sql` | VERIFIED — NON-CANONICAL + TIMESTAMP ALIAS |
| 30 | `20260811233100_p3e_008_context_budget_truncation_fix` | No matching canonical source verified | HISTORICAL SOURCE GAP |
| 31 | `20260812030934_p4a_003_runtime_memory_decision` | `supabase/migrations/20260812100000_p4a_003_runtime_memory_decision.sql` | VERIFIED — NON-CANONICAL LOCATION + TIMESTAMP ALIAS |
| 32 | `20260812032212_p4a_004_runtime_audit_persistence` | `database/migrations/20260812090000_p4a_004_runtime_audit_persistence.sql` | VERIFIED — HISTORICAL TIMESTAMP ALIAS |
| 33 | `20260812033452_p4a_005_conversation_continuity` | No matching canonical source verified | HISTORICAL SOURCE GAP |
| 34 | `20260812072950_p4e_004_tool_invocation_audit_event` | `database/migrations/20260812100000_p4e_004_tool_invocation_audit_event.sql` | VERIFIED — HISTORICAL TIMESTAMP ALIAS |
| 35 | `20260812151257_p5a_001_journey_continuity_gap` | `supabase/migrations/20260812110000_p5a_001_journey_continuity_gap.sql` | VERIFIED — NON-CANONICAL LOCATION + TIMESTAMP ALIAS |
| 36 | `20260812151504_p5b_001_clone_boundary_agreement` | `supabase/migrations/20260812112000_p5b_001_clone_boundary_agreement.sql` | VERIFIED — NON-CANONICAL LOCATION + TIMESTAMP ALIAS |
| 37 | `20260812151600_p5c_001_inheritance_legacy_succession` | `supabase/migrations/20260812114000_p5c_001_inheritance_legacy_succession.sql` | VERIFIED — NON-CANONICAL LOCATION + TIMESTAMP ALIAS |
| 38 | `20260812151652_p5d_001_recovery_backup_portability` | `supabase/migrations/20260812120000_p5d_001_recovery_backup_portability.sql` | VERIFIED — NON-CANONICAL LOCATION + TIMESTAMP ALIAS |

## 4. Reconciliation Findings

### 4.1 Remote state is ahead of the historical checkpoint documents

Earlier migration evidence recorded a 14-migration remote state. The actual Supabase DEV state now contains 38 applied migrations. Therefore the older 14-migration ledgers remain historical checkpoints and must not be treated as the current remote state.

### 4.2 The canonical repository rule is clear

`database/migrations/` remains the canonical application migration location. The presence of SQL under `supabase/migrations/` is therefore a repository-structure/source-location discrepancy, not a second canonical migration authority.

### 4.3 GitHub and Supabase are not currently 1:1

The mismatch has several forms:

1. **Historical timestamp aliases** — the applied Supabase version differs from the timestamp used by the repository artifact.
2. **Non-canonical location** — several applied migrations have their source only under `supabase/migrations/`.
3. **Historical source gaps** — several applied versions have no directly verified source artifact in the current repository.
4. **Repository naming hygiene gap** — `2026081013_create_access_decision_gate.sql` does not satisfy the repository's 12-digit timestamp convention.

### 4.4 This does not imply that the remote schema is missing

Supabase reports all 38 migrations as applied. The reconciliation problem is therefore primarily **source/history representation and repository hygiene**, not evidence that Phase 1–5 schema work needs to be re-applied.

## 5. Canonical Disposition

The following disposition is now established for the next cleanup step:

- **Supabase applied history:** authoritative record of what actually happened remotely.
- **`database/migrations/`:** canonical Git source-of-truth for application migration definitions going forward.
- **`supabase/migrations/`:** non-canonical legacy/application migration location; must not be treated as a second source-of-truth.
- **Missing historical SQL:** remains a GAP/DEFERRED item unless the original source can be recovered and verified.
- **Applied migration timestamps:** are historical facts and must not be cosmetically rewritten in Supabase.
- **Committed migration files:** remain subject to the existing immutability rule; cleanup must use forward-only/repository-safe disposition rather than rewriting history.

## 6. Mutation Boundary

No Supabase mutation was performed.

No migration was re-applied.

No remote migration history was repaired or rewritten.

This evidence record is the only repository mutation performed by this reconciliation step.

## 7. Impact on Next Steps

This reconciliation is sufficient to proceed to repository-structure design, but it does **not** authorize automatic deletion or renaming of migration files.

Before any cleanup mutation, the next step must explicitly determine:

1. which repository artifacts are canonical retained sources;
2. which non-canonical artifacts are duplicate/relocated sources;
3. which historical source gaps must remain documented rather than reconstructed;
4. how future migration workflow prevents a second `database/migrations/` vs `supabase/migrations/` split.

## 8. Result

**GitHub ↔ Supabase reconciliation:** DONE.

**Remote schema re-application required:** NO.

**Supabase migration-history mutation required:** NO.

**Canonical source location:** `database/migrations/`.

**Repository cleanup required:** YES — separate controlled step.

**Historical source gaps:** DOCUMENTED — do not fabricate.

**Phase 1–5 reopening required:** NO based on migration-history discrepancy alone.

**P6 dependency:** Migration/source representation must be controlled before final integration/release assurance; no P1–P5 schema replay is required.
