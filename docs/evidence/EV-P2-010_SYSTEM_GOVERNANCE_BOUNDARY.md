# EV-P2-010 — System Governance Boundary

**Status:** PASS
**Phase:** 2
**Backlog:** BL-P2-010
**Mutation target:** Supabase + repository migration artifact

## Objective

Verify that System Governance authority remains bounded to governance/core targets and does not become omniscient private-data access.

## Minimal realization

Implemented `private.system_governance_boundary(...)` as a thin boundary over the existing Access Decision Gate.

The boundary:

- rejects `PRIVATE_MEMORY`, `PRIVATE_CONVERSATION`, and `PRIVATE_CONTEXT` before downstream governance evaluation;
- rejects non-system targets;
- accepts only `GOVERN` and `EVOLVE` actions;
- delegates eligible system governance/core decisions to `private.access_decision_gate(...)`;
- fails closed when the downstream gate returns no decision;
- is `SECURITY DEFINER` with an empty `search_path`;
- has direct grants revoked from `public`, `anon`, and `authenticated`.

No new authority semantics, ownership model, or private-data access path was introduced.

## Actual-state audit

Existing Phase 2 components were confirmed in Supabase before mutation:

- `public.permission_matrix`
- `private.governance_evaluator`
- `private.policy_enforcement_engine`
- `private.isolation_checker`
- `private.access_decision_gate`
- `private.runtime_access_boundary`

The existing permission matrix already distinguishes governance/core rules from private-data rules. The new boundary therefore adds only the missing explicit system-governance boundary wrapper.

## Verification

### 1. Private-data target

Input:

- action: `GOVERN`
- target: `PRIVATE_MEMORY`
- actor account: Creator account

Observed:

`REJECT — system governance authority does not grant omniscient private-data access`

### 2. System-core target without trusted runtime identity

Input:

- action: `GOVERN`
- target: `SYSTEM_CORE`
- actor account: Creator account supplied as parameter

Observed:

`REJECT — trusted identity context is absent; fail closed`

This confirms that a caller-supplied Creator account ID cannot bypass the trusted identity boundary.

### 3. Unsupported action

Input:

- action: `READ`
- target: `SYSTEM_CORE`

Observed:

`REJECT — system governance boundary accepts only governance actions`

## Result

**BL-P2-010 = PASS (technical boundary implemented and verified).**

The boundary now explicitly enforces:

`System Governance ≠ Omniscient Data Access`

No SH-000 technical identity was introduced or changed by this backlog item.

## Limitations

The current verification environment does not provide a fresh authenticated end-to-end GoTrue session for this evidence run. Therefore the positive Creator governance path is delegated to the already implemented Access Decision Gate and is not claimed as fresh GoTrue E2E evidence here. The negative boundary and fail-closed behavior were verified directly.
