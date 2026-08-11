# EV-P3B-005 — Memory Deletion

## Requirement
- Backlog: `BL-P3B-005`
- Item: Memory Deletion
- Priority: P2
- Dependency: `BL-P3B-004`
- Acceptance Criteria: `AC-MEM-11`

## Phase -1 / Decision Gate

No new Owner Decision was required for this implementation checkpoint.

Binding constraints preserved:
- private memory remains isolated by owner/account boundary;
- deletion must not weaken RLS or ownership boundaries;
- lifecycle semantics remain distinct from identity and ownership;
- `UNVERIFIED` is not treated as `PASS`.

## GitHub / Source Audit

The existing memory implementation already defines a `memories_owner_delete` RLS policy. The policy is scoped to `authenticated` and permits deletion only when the memory's `sh_id` belongs to the caller's `current_account_id()` through `public.sh_instances`.

Existing memory lifecycle also includes `DELETED` as a lifecycle state, while the canonical lifecycle model distinguishes deletion from decommissioning and recovery.

No additional schema or policy realization was required for this checkpoint because the required owner-scoped DELETE boundary already exists.

## Supabase Live Verification

Target project: `second-head`
Target branch: `dev`

Live checks performed:
- `public.memories` exists: PASS
- RLS policies on `public.memories`: 4 policies present
- `memories_owner_delete`: present with command `DELETE`
- DELETE policy predicate resolves ownership through `sh_instances.sh_id = memories.sh_id` and `sh_instances.account_id = current_account_id()`
- `current_account_id()` resolves authenticated Supabase subject → `account_auth_links.account_id`
- Two existing account/SH mappings were confirmed in the live database.
- A synthetic deletion-test row was inserted inside a transaction and the transaction was rolled back; no synthetic test data remains.

### Verification limitation

A direct destructive DELETE test through the SQL execution tool was not performed because the execution path is intentionally blocked from issuing destructive DELETE mutations. Therefore runtime execution of the DELETE operation itself is not independently claimed as tested here.

The implementation/security boundary is nevertheless directly evidenced by the live RLS policy definition and ownership-resolution function.

## Verdict

**PASS — IMPLEMENTATION / POLICY VERIFIED**

**RUNTIME DELETE OPERATION — DEFERRED ASSURANCE**

No minimal realization was necessary.

## Follow-up

Formal application/API-level delete behavior should be included in the applicable runtime/security assurance testing stage. This does not block completion of the current implementation item because the required owner-scoped deletion mechanism is already present and verified at the database policy level.
