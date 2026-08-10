# EV-P2-007 — Creator Authority Boundary

**BL:** BL-P2-007 — Creator Authority Boundary  
**Phase:** Phase 2  
**Status:** VERIFIED  
**Verification mode:** Actual-state verification against Supabase project `second-head` and GitHub `dev`

## 1. Implementation result

Creator recognition is implemented through a minimal trusted authority assignment:

`private.authority_assignments(account_id, authority, active)`

The assignment is database-controlled and is not exposed to `anon` or `authenticated` table access. The existing identity chain remains authoritative:

`auth.uid()` → `account_auth_links` → `ACCOUNT_ID` → trusted Creator assignment.

The selected Creator account is:

`c0b99e98-6c75-4d11-9ec0-84e15e87c23d` (`banned.idn@gmail.com`)

No password, mailbox contents, Auth credentials, or email access was changed or accessed.

## 2. Governance evaluator integration

`private.governance_evaluator(...)` now resolves the actor as:

- `CREATOR` when the trusted ACCOUNT_ID has an active `CREATOR` authority assignment;
- otherwise `ACCOUNT_OWNER`.

Caller-supplied `p_actor_account_id` remains validated against the trusted identity context and cannot elevate an actor.

No SH-000 technical identity was introduced.

## 3. Supabase verification

Applied migration:

`20260810142641_p2_007_creator_authority_boundary`

Verified:

- exactly one active Creator authority assignment exists;
- the assignment belongs to `banned.idn@gmail.com`;
- `authenticated` has no SELECT privilege on `private.authority_assignments`;
- evaluator references the trusted authority assignment;
- Creator governance request reaches the existing governance-process boundary;
- Creator access to another SH's private memory is denied by the existing permission matrix;
- the other account resolves as `ACCOUNT_OWNER`, not `CREATOR`;
- the other account receives default-deny for system-core governance.

### Verified decision examples

Creator → `GOVERN / SYSTEM_CORE`:

`ESCALATE — permission exists but requires governance process`

Creator → `READ / PRIVATE_MEMORY / OTHER`:

`DENY — permission matrix rule is DENY`

Other owner → `GOVERN / SYSTEM_CORE`:

`DENY — no matching permission rule; default deny`

## 4. Security boundary

- Trusted identity continues to originate from `auth.uid()` and existing identity resolution.
- Creator authority is not inferred from email text or caller parameters.
- Creator authority does not grant private-data access.
- The authority assignment table is stored in the non-exposed `private` schema.
- No ownership semantics were changed.
- No SH-000 identity decision was introduced.

## 5. Repository verification

GitHub repository: `savie/second-head`  
Target branch: `dev`

Migration artifact:

`database/migrations/20260810142641_p2_007_creator_authority_boundary.sql`

Evidence artifact:

`docs/evidence/EV-P2-007_CREATOR_AUTHORITY_BOUNDARY.md`

The repository migration mirrors the migration applied to Supabase.

## 6. Phase boundary

BL-P2-007 does not implement:

- SH-000 technical identity resolution (BL-P2-008)
- Runtime Access Boundary (BL-P2-009)
- System Governance Boundary (BL-P2-010)
- Governance Testing / Phase 2 closure (BL-P2-011)

## 7. Result

**BL-P2-007 — COMPLETE / VERIFIED.**

Checkpoint commit/push remains a separate workflow decision after the current validated mutation set has been reviewed.
