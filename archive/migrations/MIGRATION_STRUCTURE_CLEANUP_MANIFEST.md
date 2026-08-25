# Migration Structure Cleanup Manifest

Baseline: `3f0a718435140d1628b85afa08d73c45b9d01ec2`

Scope: `supabase/migrations/` only. SQL content is preserved byte-for-byte. Supabase remote state is not modified.

## Disposition counts

- IDENTICAL: 0
- ALIAS: 15
- HISTORICAL-UNIQUE: 53
- UNVERIFIED: 0

Exact-content duplicate detection uses Git blob identity. No `supabase/migrations/` blob SHA is identical to a `database/migrations/` blob SHA in the baseline tree.

## ALIAS

These have a verified canonical counterpart in `database/migrations/`; the historical copy is preserved because it is non-canonical and/or represents a different remote timestamp/source location.

- `20260814050000_p4a_005_conversation_identity_write_fix.sql` → `database/migrations/20260814050000_p4a_005_conversation_identity_write_fix.sql`
- `20260814070000_p4a_004_runtime_audit_identity_fix.sql` → `database/migrations/20260814070000_p4a_004_runtime_audit_identity_fix.sql`
- `20260814090000_p4a_005_conversation_read.sql` → `database/migrations/20260814090000_p4a_005_conversation_read.sql`
- `20260814103000_p4f_006_high_risk_runtime_confirmation.sql` → `database/migrations/20260814103000_p4f_006_high_risk_runtime_confirmation.sql`
- `20260814110000_p4a_004_audit_identity_policy_fix.sql` → `database/migrations/20260814110000_p4a_004_audit_identity_policy_fix.sql`
- `20260815090000_p5a_002_recovery_journey_event_integration.sql` → `database/migrations/20260815090000_p5a_002_recovery_journey_event_integration.sql`
- `20260815091000_p5a_003_inheritance_legacy_journey_integration.sql` → `database/migrations/20260815091000_p5a_003_inheritance_legacy_journey_integration.sql`
- `20260815100000_p5d_002_recovery_ownership_restore.sql` → `database/migrations/20260815100000_p5d_002_recovery_ownership_restore.sql`
- `20260815120000_p3d_010_knowledge_private_owner_linkage.sql` → `database/migrations/20260815120000_p3d_010_knowledge_private_owner_linkage.sql`
- `20260815170000_p5d_003_recovery_sh_identity_state.sql` → `database/migrations/20260815170000_p5d_003_recovery_sh_identity_state.sql`
- `20260815180000_p5d_004_recovery_legacy_records.sql` → `database/migrations/20260815180000_p5d_004_recovery_legacy_records.sql`
- `20260816150000_p6d_reconcile_runtime_function_execute_privileges.sql` → `database/migrations/20260816150000_p6d_reconcile_runtime_function_execute_privileges.sql`
- `20260816173000_p6e_reconcile_runtime_function_execute.sql` → `database/migrations/20260816173000_p6e_reconcile_runtime_function_execute.sql`
- `20260817090000_p5d_002_recovery_continuity_restore_completion.sql` → `database/migrations/20260817090000_p5d_002_recovery_continuity_restore_completion.sql`
- `20260824140000_reconcile_dev_db_functional_state.sql` → `database/migrations/20260824201714_reconcile_current_dev_functional_state.sql`

## HISTORICAL-UNIQUE

All other `supabase/migrations/*.sql` files are retained as historical source because no canonical counterpart in `database/migrations/` was verified at this baseline. This includes migrations that are confirmed as applied remotely but whose original source is not represented under the canonical directory.

## UNVERIFIED

None at this baseline: the current Supabase DEV migration ledger contains corresponding applied migration families for the archived source set. Historical source gaps in the remote ledger remain documented separately and are not reconstructed here.

## Safety

- No migration is replayed.
- No Supabase remote migration ledger is changed.
- No SQL is rewritten.
- `database/migrations/` remains the only canonical migration source.
- Historical source is preserved under vendor-neutral `archive/migrations/`.
