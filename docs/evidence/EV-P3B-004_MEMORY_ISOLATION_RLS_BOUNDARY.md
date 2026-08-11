# EV-P3B-004 — Memory Isolation / RLS Boundary

## Status

**PASS — IMPLEMENTATION VERIFIED / RUNTIME ASSURANCE DEFERRED**

Backlog item: `BL-P3B-004`
Domain: Phase 3B — Memory / Knowledge
Mutation type: Evidence-only; no new database/schema mutation required.

## Audit Scope

This completion audit verifies the existing memory-isolation realization against the established ownership boundary.

No new architecture, ownership model, privacy rule, or authorization rule is introduced by this evidence.

## GitHub Verification

The active `dev` branch contains the memory RLS reconciliation migration:

`database/migrations/20260811051355_reconcile_memories_rls_ownership_helper.sql`

The migration explicitly defines four policies on `public.memories`:

- `memories_owner_select`
- `memories_owner_insert`
- `memories_owner_update`
- `memories_owner_delete`

All policies apply to the `authenticated` role and resolve ownership through the existing SH → account boundary:

`memories.sh_id → sh_instances.account_id = current_account_id()`

SELECT, INSERT, UPDATE, and DELETE therefore use the same ownership boundary rather than introducing a second ownership model.

Source evidence:
`database/migrations/20260811051355_reconcile_memories_rls_ownership_helper.sql`

## Supabase Verification

Target project: `second-head`
Target branch: `dev`

Actual Supabase branch state was verified during this completion audit:

- branch `dev` exists and is active/healthy;
- `public.memories` exists;
- `public.memories` has RLS enabled;
- `public.memories` currently has zero rows in the dev branch;
- the active schema contains `memories.sh_id → sh_instances.sh_id`;
- the ownership chain contains `sh_instances.account_id → accounts.account_id`;
- the applied migration list includes `20260810161457_create_system_governance_boundary`, `20260811034535_create_memory_storage_and_knowledge_eligibility`, and `20260811051355_reconcile_memories_rls_ownership_helper`;
- the Dashboard policy view shows the four `memories_owner_*` policies on `public.memories`.

The Dashboard inspection also showed the effective SELECT policy condition using the existing helper:

```sql
exists (
  select 1
  from sh_instances s
  where s.sh_id = memories.sh_id
    and s.account_id = current_account_id()
)
```

No Supabase mutation was performed during this audit.

## Isolation Boundary Result

The implementation establishes the intended account/SH ownership boundary:

```text
authenticated actor
        ↓
current_account_id()
        ↓
sh_instances.account_id
        ↓
sh_instances.sh_id = memories.sh_id
        ↓
memory access allowed only inside the actor's account boundary
```

The same boundary is applied to read and write operations.

## Runtime Verification Limitation

A formal adversarial cross-account runtime test using two authenticated sessions was not executed in this completion checkpoint.

Therefore this evidence does **not** claim that an end-to-end behavioral test has been executed.

The outstanding assurance item is:

```text
Account A → Memory A   expected ALLOW
Account A → Memory B   expected DENY / invisible
Account B → Memory B   expected ALLOW
Account B → Memory A   expected DENY / invisible
```

This is deferred to the applicable security/assurance verification stage. It does not create a known implementation gap and does not require a new schema or policy mutation at this checkpoint.

## Boundary / Non-Decision

This completion does not introduce or claim:

- a new ownership model;
- cross-user sharing semantics;
- general-knowledge access policy;
- a semantic Knowledge engine;
- automatic private-to-general promotion;
- production adversarial assurance completion.

Those remain governed by their respective backlog items and later assurance stages.

## Completion Result

**BL-P3B-004 = PASS — implementation completion**

Reason: the required memory isolation realization already exists in the active `dev` environment, is backed by RLS, and consistently reuses the established SH → account ownership boundary for SELECT/INSERT/UPDATE/DELETE. No additional realization is required.

Formal runtime cross-account verification remains explicitly recorded as deferred rather than silently treated as completed.

Next backlog item may proceed through:

`AUDIT → REALIZATION MINIMAL (if needed) → VERIFY → EVIDENCE → DEV`
