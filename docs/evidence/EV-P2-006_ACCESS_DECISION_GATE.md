# EV-P2-006 — Access Decision Gate

**BL:** BL-P2-006 — Access Decision Gate  
**Phase:** Phase 2  
**Status:** VERIFIED  
**Verification mode:** Actual-state verification against Supabase project `second-head` and GitHub `dev`

## 1. Implementation result

The Phase 2 Access Decision Gate is implemented as:

`private.access_decision_gate(authority_domain, action, target_domain, target_sh_id, actor_account_id)`

The gate standardizes the downstream authorization result into:

- `PASS`
- `REJECT`
- `ESCALATE`

The gate does not replace the governance evaluator, policy enforcement engine, or isolation checker. It composes them in sequence and fails closed.

## 2. Decision flow

1. Governance evaluator is consulted first.
2. `ESCALATE` is propagated as `ESCALATE`.
3. Any non-`ALLOW` governance result becomes `REJECT`.
4. Policy enforcement must independently return `true`; otherwise `REJECT`.
5. Isolation checker must return `PASS`; otherwise `REJECT`.
6. Only when all required checks pass does the gate return `PASS`.

## 3. Security boundary

- Function is `SECURITY DEFINER` with locked `search_path` (`private, public, pg_temp`).
- `public` and `anon` do not retain EXECUTE privilege.
- `authenticated` has EXECUTE privilege.
- Missing trusted identity is fail-closed through the existing governance/isolation chain.
- No SH-000 technical identity was introduced.
- No private-data bypass or ownership transfer semantics were introduced.

## 4. Supabase verification

Applied migration:

`20260810133755_create_access_decision_gate`

Function verification confirmed:

- function exists in schema `private`;
- result type is `TABLE(decision text, reason text)`;
- `SECURITY DEFINER` is enabled;
- `anon` EXECUTE = false;
- `authenticated` EXECUTE = true.

Negative-path verification with absent trusted identity returned:

`REJECT — trusted identity context is absent; fail closed`

This confirms the gate does not grant access when the identity context is unavailable.

## 5. Repository verification

GitHub repository: `savie/second-head`  
Target branch: `dev`

Repository migration artifact:

`database/migrations/2026081013_create_access_decision_gate.sql`

The migration contains the same gate definition and privilege boundary applied to Supabase.

## 6. Phase boundary

BL-P2-006 does not implement:

- Creator Authority Boundary testing (BL-P2-007)
- SH-000 technical identity resolution (BL-P2-008)
- Runtime Access Boundary (BL-P2-009)
- System Governance Boundary (BL-P2-010)
- Governance Testing / Phase 2 closure (BL-P2-011)

## 7. Result

**BL-P2-006 — COMPLETE / VERIFIED.**
