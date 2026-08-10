# EV-P2-009 — Runtime Access Boundary

**BL:** BL-P2-009 — Runtime Access Boundary  
**Phase:** Phase 2  
**Status:** VERIFIED  
**Verification mode:** Actual-state verification against Supabase project `pkhkgvsrqeupvwoqjwmd` and GitHub `dev`

## 1. Audit result

BL-P2-009 was implemented using the minimal realization required to enforce the frozen invariant:

`Runtime Access ≠ Ownership`

No new ownership model, identity type, SH-000 identity, or private-data sharing mechanism was introduced.

## 2. Implementation result

The runtime boundary is implemented as:

`private.runtime_access_boundary(target_domain, target_sh_id, actor_account_id)`

The boundary:

- derives trusted identity from `auth.uid()` and `current_account_id()`;
- fails closed when trusted identity is absent or ACCOUNT_ID cannot be resolved;
- rejects a caller-supplied ACCOUNT_ID that does not match trusted identity;
- classifies the target SH as `SYSTEM`, `SELF`, or `OTHER` using `sh_ownership`;
- permits runtime execution only within `SELF` or `SYSTEM` scope;
- rejects `OTHER` by default;
- explicitly prevents runtime execution from implying, granting, or transferring ownership;
- requires a future explicit scoped-authorization mechanism before runtime access to another SH is permitted;
- does not create or modify ownership rows.

## 3. Security boundary

The function is:

- `SECURITY DEFINER`;
- configured with locked `search_path`;
- not executable by `anon`;
- executable by `authenticated`;
- not granted directly to `service_role`.

The function is a boundary/checker and does not replace the governance evaluator, policy enforcement engine, isolation checker, or access decision gate.

## 4. Supabase verification

Applied migration:

`20260810160700_p2_009_runtime_access_boundary`

Live function verification confirmed:

- function exists in schema `private`;
- signature is `(text, uuid, uuid)`;
- `SECURITY DEFINER = true`;
- `anon EXECUTE = false`;
- `authenticated EXECUTE = true`;
- `service_role EXECUTE = false`.

Negative-path execution with no trusted identity returned:

`REJECT — trusted identity context is absent; runtime access fails closed`

This verifies that runtime access is not granted merely because the function is invoked.

The live `sh_ownership` foundation remains unchanged by this BL. The active Creator authority assignment remains unchanged and no new ownership/authority row was introduced by BL-P2-009.

## 5. Repository verification

GitHub repository: `savie/second-head`  
Target branch: `dev`

Repository migration artifact:

`database/migrations/20260810160700_p2_009_runtime_access_boundary.sql`

The artifact contains the same runtime boundary definition and privilege boundary applied to Supabase.

## 6. Scope boundary

BL-P2-009 does not implement:

- explicit cross-SH sharing authorization;
- ownership transfer;
- SH-000 technical identity resolution;
- system-wide omniscient access;
- Phase 2 governance closure.

Those remain governed by downstream scope and frozen authority.

## 7. Result

**BL-P2-009 — COMPLETE / VERIFIED.**
