# WORKSTREAM E2 — INVOCATION / AUTHORIZATION BOUNDARY

**Project:** SECOND HEAD V1.0  
**Workstream:** E2  
**Date:** 2026-08-29  
**Status:** BOUNDED DESIGN DRAFT / RECONCILIATION COMPLETE  
**Implementation:** NOT AUTHORIZED

> Living evolution/design document. Not Canonical, not a migration/schema instruction, and not an implementation authorization.

## 1. Purpose

E2 defines the semantic boundary between a candidate Tool/Action request and an authorization decision.

E2 answers:
> What information must Runtime have to evaluate a requested Action against the existing SH governance model?

E2 does not implement execution, generic confirmation, or a Tool registry.

## 2. Authority hierarchy

1. Canonical SH Core.
2. Approved Build Scope / Implementation Contract / Implementation Guide / Execution Strategy.
3. `docs/evolution/V1.0/`.
4. `docs/resume/`.
5. Current DEV runtime/database as implementation evidence.

A missing detail may be introduced as an evolution decision only when it does not contradict higher authority.

## 3. E1 dependency

E1 established Capability → Tool → Action and the guardrails Intent ≠ Execution, Tool ≠ Authority, Capability ≠ Permission, and Action ≠ Automatic Authorization.

E2 consumes that vocabulary and defines the governed Invocation boundary.

## 4. Current DEV evidence

Verified governance primitives:
- `public.accounts`
- `public.sh_instances`
- `public.sh_ownership`
- `private.authority_assignments`
- `public.permission_matrix`
- `private.runtime_access_boundary`
- `public.runtime_high_risk_confirmations`
- `public.audit_events`

`permission_matrix` contains actor, authority_domain, action, target_domain, target_sh, scope_conditions, and decision. It is verified policy data, not a verified generic evaluator API.

`runtime_access_boundary(p_target_domain text, p_target_sh_id uuid DEFAULT NULL, p_actor_account_id uuid DEFAULT NULL)` returns decision, account_id, target_sh_relation, and reason.

Verified high-risk functions: `runtime_create_high_risk_confirmation`, `runtime_confirm_high_risk_action`, `runtime_execute_high_risk_action`. Current infrastructure is recovery-specific and is not treated as a generic E2 authorization evaluator.

`runtime_record_audit(p_sh_id, p_event_type, p_status, p_metadata)` is verified. Audit is downstream of authorization/execution.

## 5. Invocation semantic contract

An Invocation is a governed request for an Action, not execution.

Minimum semantic dimensions:

| Dimension | Meaning |
|---|---|
| Actor | Principal on whose behalf the request is evaluated |
| SH context | SH instance/context in which the request occurs |
| Capability | Capability being accessed |
| Tool | Governed interface being invoked |
| Action | Concrete requested operation/effect |
| Target | Resource/domain/SH against which the Action is requested |
| Scope/context | Conditions relevant to policy evaluation |
| Request provenance | How the request originated (user/model/runtime/etc.) |
| Request identity | Correlation/trace identity sufficient for lifecycle continuity |

These are semantic dimensions only. Exact field names, identifiers, storage, and envelope format remain implementation design.

## 6. Actor ≠ Authority ≠ Ownership

E2 explicitly separates Actor, Authority, and Ownership. They must not be collapsed into one field or assumed interchangeable.

A user being the actor does not automatically mean every requested Action is authorized.

Ownership does not automatically grant unrelated authority.

Authority does not automatically grant private-data access outside applicable scope.

## 7. Authorization decision boundary

Conceptually:

    Invocation
       ↓
    establish actor + SH + target context
       ↓
    evaluate ownership/access boundary
       ↓
    evaluate applicable authority/policy
       ↓
    determine decision
       ↓
    ALLOW / DENY / ESCALATE

The decision is produced by the governed runtime authorization layer. E2 does not yet define the implementation of a generic evaluator.

## 8. Existing permission_matrix mapping

Invocation.Action maps semantically to policy action; Invocation.Actor to policy actor/authority context; Invocation.Target to target domain/target SH; Invocation.Scope to policy scope conditions.

This is a mapping contract, not a statement that direct SQL matching is the final evaluator implementation.

The evaluator must account for the existing authority and access model rather than treating one permission row as sufficient authorization in isolation.

## 9. ALLOW / DENY / ESCALATE

Existing permission semantics include ALLOW, DENY, and ESCALATE.

- **ALLOW:** invocation may proceed to downstream gates; execution has not happened.
- **DENY:** invocation must not proceed to execution.
- **ESCALATE:** additional governed handling is required before execution eligibility can be established.

Exact ESCALATE relationship to generic risk/confirmation remains downstream design.

## 10. Runtime access boundary

E2 preserves a separate access boundary: Authorization policy ≠ SH ownership/access relation.

An invocation may satisfy one dimension while failing another. The authorization bridge must not bypass `runtime_access_boundary` because a permission rule appears to allow an Action.

Access-boundary approval must not be interpreted as blanket permission to perform arbitrary Actions.

## 11. App / Model / Tool boundaries

- **App:** may present intent, request confirmation, display decisions/results; it is not the authority decision-maker.
- **Model:** may propose an Action; model output is not authorization.
- **Tool:** performs/mediates an Action only after Runtime governance establishes execution eligibility; tool output is result data, not system authority.
- **Runtime:** orchestration/governance boundary carrying Invocation through authorization and downstream gates.

## 12. Registry decision

A generic Capability/Tool/Action registry is **not required to close E2**. Invocation semantics can be defined without deciding physical Tool persistence/discovery.

Registry remains OPEN for later bounded design.

## 13. Confirmation boundary

E2 does not define generic confirmation mechanics. Current DEV confirmation primitives are recovery-specific.

Semantic boundary:

    Authorization
        ↓
    risk/confirmation gate where required
        ↓
    execution

ALLOW must not be interpreted as confirmed.

## 14. Execution boundary

Execution is explicitly OUT OF E2. E2 ends at a governed authorization outcome / execution-eligibility transition.

No E2 design should directly call an external Tool or mutate business state.

## 15. Reconciliation findings

### 🟢 Existing
- identity/account context
- SH context
- ownership relation
- authority assignment foundation
- permission policy data
- runtime access boundary
- ALLOW/DENY/ESCALATE vocabulary
- audit primitive
- recovery-specific confirmation primitive

### 🟡 Genuine design/implementation gaps
- generic Invocation envelope
- generic authorization evaluator
- exact Action → permission mapping
- exact actor/authority resolution
- generic ESCALATE semantics
- correlation/trace contract

### 🟡 Not yet justified as E2 requirements
- physical Tool registry
- Tool versioning
- provider abstraction
- generic confirmation implementation
- execution adapter
- result normalization

### 🔴 Hard boundaries
- Tool as authority
- Capability as permission
- Model as authorization authority
- App-side authorization
- authorization bypass through Tool
- ownership treated as blanket Action permission

## 16. E2 acceptance criteria

E2 is bounded-design complete when:
- Invocation is distinct from Action and execution;
- actor, SH context, target, scope, and provenance are semantically defined;
- actor, authority, and ownership are separated;
- permission_matrix semantics are mapped without creating a competing policy source;
- runtime_access_boundary remains an independent access/governance boundary;
- ALLOW/DENY/ESCALATE are preserved;
- App/Model/Tool cannot become authorization authority;
- no physical schema or execution implementation is smuggled into E2.

## 17. E2 status

**E2 = 🟢 BOUNDED DESIGN ACCEPTED / CLOSED**

Closure means the semantic boundary is accepted. It does not authorize implementation.

## 18. Next dependency

Next package should audit/design the remaining generic execution gate:

**Candidate E3 — Risk + Confirmation Boundary**

Before freezing E3, audit whether risk classification, existing recovery confirmation infrastructure, and generic confirmation semantics should be one package or separate packages.

Registry remains intentionally deferred until its dependency is proven.