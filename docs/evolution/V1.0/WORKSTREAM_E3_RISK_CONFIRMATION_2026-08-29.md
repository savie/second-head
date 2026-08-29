# WORKSTREAM E3 — RISK / CONFIRMATION BOUNDARY

**Project:** SECOND HEAD V1.0  
**Workstream:** E3  
**Date:** 2026-08-29  
**Status:** BOUNDED DESIGN DRAFT / AUDIT COMPLETE  
**Implementation:** NOT AUTHORIZED

> Living evolution/design document. Not Canonical, not a migration/schema instruction, and not an implementation authorization.

## 1. Purpose

E3 defines the boundary between an authorized Invocation and an Action that may require additional risk handling or explicit confirmation before execution.

The existing SH rule is:

PLAN → AUTHORIZATION → CONFIRMATION → EXECUTE → AUDIT

E3 does not implement execution.

## 2. Authority basis

The Implementation Contract explicitly states that Actions are operations producing effects/changes outside internal reasoning and that risk level must be considered. It specifies the high-risk sequence above.

Therefore E3 is not inventing the existence of risk/confirmation gating.

However, the source material does not fully define a generic V1.0 risk taxonomy or generic confirmation protocol. Those remain legitimate evolution gaps.

## 3. Existing DEV evidence

DEV already has a high-risk confirmation foundation:

- public.runtime_high_risk_confirmations
- runtime_create_high_risk_confirmation
- runtime_confirm_high_risk_action
- runtime_execute_high_risk_action

The current implementation is evidence and a foundation, but it must not automatically be generalized into the entire Tool ecosystem.

Existing confirmation UI in app/app/chat.tsx is also evidence of a high-risk confirmation surface. Its behavior explicitly separates user confirmation from Runtime authorization/execution. Therefore the App is not treated as the authority boundary.

## 4. Reclassification

| Area | Status | Finding |
|---|---|---|
| Risk must be considered for Actions | 🟢 | Contract-supported |
| High-risk Action requires confirmation | 🟢 | Contract-supported |
| Authorization precedes confirmation | 🟢 | Contract-supported |
| Confirmation precedes execution | 🟢 | Contract-supported |
| Execution must be auditable | 🟢 | Contract-supported |
| Existing high-risk confirmation runtime | 🟢 | Existing DEV evidence |
| Generic risk taxonomy | 🟡 | Not fully specified |
| Generic confirmation contract | 🟡 | Existing foundation, but generic scope not proven |
| Confirmation UX | 🟡 | Existing surface; not authority |
| Confirmation ≠ authorization | 🟢 | Hard boundary |
| Confirmation ≠ execution | 🟢 | Hard boundary |
| Tool/App as authority | 🔴 | Prohibited |
| Autonomous unrestricted execution | 🔴 | Prohibited |

## 5. Risk classification boundary

E3 defines a bounded risk classification contract, not a giant universal taxonomy.

At minimum, classification must distinguish:

- actions needing no explicit confirmation;
- actions requiring explicit confirmation;
- actions requiring additional governed handling before proceeding.

Exact labels, scoring model, and action catalogue remain OPEN until a concrete Tool/Action slice proves the need.

Risk is evaluated against the concrete Action and invocation context, not merely Capability or Tool.

Conceptually:

Capability → Tool → Action → Invocation context → Risk classification

## 6. Confirmation boundary

Confirmation is a gate, not authority.

Accepted sequence:

Invocation
↓
Authorization
↓
Risk classification
↓
Confirmation if required
↓
Execution eligibility
↓
Execution
↓
Audit

A confirmation event does not grant authority absent before confirmation.

A user pressing Confirm cannot override DENY.

App-side confirmation cannot bypass Runtime authorization.

A Tool cannot self-confirm.

The Model cannot self-confirm on behalf of the user under current V1.0 governance.

## 7. Confirmation state

Existing confirmation lifecycle demonstrates that confirmation needs an explicit lifecycle rather than a boolean.

Future generic semantics therefore need at least:

- association to invocation/action;
- actor/account context;
- requested operation;
- risk classification;
- target/context;
- status;
- creation/expiry information;
- confirmation evidence;
- execution linkage where applicable.

Exact storage schema is deferred.

## 8. Confirmation freshness

Confirmation must be bound to the operation/context it confirms.

A future contract must prevent:

Confirm Action A → execute unrelated Action B

Therefore confirmation needs sufficient operation, target, actor, and/or invocation correlation to prevent substitution or unintended replay.

Existing DEV expiry behavior supports this direction, but exact generic freshness semantics remain OPEN.

## 9. ESCALATE interaction

E2 established ALLOW / DENY / ESCALATE.

E3 clarifies only the boundary:

- DENY cannot be rescued by confirmation.
- ALLOW is not equivalent to confirmation.
- ESCALATE requires additional governed handling.
- If escalation resolves into a confirmation requirement, confirmation occurs only after applicable authorization conditions are satisfied.

Exact escalation workflow remains OPEN.

## 10. Existing confirmation infrastructure: reuse boundary

Existing high-risk confirmation infrastructure should be treated as a foundation, not copied into a parallel generic subsystem.

Before implementation, reconcile:

1. which existing fields are generic enough to reuse;
2. which semantics are recovery-specific;
3. whether existing functions can safely become generic;
4. whether generic confirmation needs a new contract layer;
5. how Invocation identity links to Confirmation identity.

No migration decision is made by E3.

## 11. App boundary

The App may:

- render confirmation;
- show operation/risk information;
- collect explicit user confirmation;
- display status.

The App may not:

- authorize a denied Action;
- create authority;
- execute a Tool directly;
- treat UI state as proof of Runtime authorization.

## 12. Runtime boundary

Runtime remains responsible for:

authorized Invocation
→ risk handling
→ confirmation when required
→ execution eligibility

E3 does not establish a new security authority.

## 13. Audit boundary

The eventual contract must allow correlation among:

Invocation → Authorization → Risk → Confirmation → Execution → Result/Audit

Exact event taxonomy is deferred to the later audit/result package if needed.

## 14. Out of scope

- Tool registry
- Tool provider ecosystem
- plugin marketplace
- unrestricted autonomy
- external Tool adapters
- result normalization
- physical schema/migration
- generic execution engine
- Canonical changes

## 15. Closure criteria

E3 can close at bounded-design level when:

- risk is tied to Action + invocation context;
- confirmation is a gate rather than authority;
- authorization precedes confirmation;
- confirmation precedes execution when required;
- DENY cannot be overridden by confirmation;
- App/UI cannot authorize or execute;
- existing confirmation infrastructure is mapped as foundation without premature generalization;
- generic risk taxonomy and exact confirmation schema remain explicitly open where evidence is insufficient.

## 16. Status

**E3 = 🟢 BOUNDED DESIGN ACCEPTED / CLOSED**

This is semantic/boundary closure only. No implementation is authorized.

## 17. Next candidate

**E4 — Execution Boundary / Tool Invocation Runtime**

Before E4 is frozen, audit whether execution, Tool adapter, and result lifecycle should be one package or separate bounded packages.

Registry remains deferred until its dependency is proven.
