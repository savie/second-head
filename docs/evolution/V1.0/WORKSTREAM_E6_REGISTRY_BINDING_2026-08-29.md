# WORKSTREAM E6 — TOOL / ACTION REGISTRY & CAPABILITY BINDING

**Project:** SECOND HEAD V1.0  
**Workstream:** E6  
**Date:** 2026-08-29  
**Status:** AUDIT → MAP → RECONCILE COMPLETE / BOUNDED DESIGN  
**Implementation:** NOT AUTHORIZED

> Living evolution/design document. Not Canonical, not a migration/schema instruction, and not an implementation authorization.

## 1. Purpose

E6 audits whether SECOND HEAD V1.0 actually requires a registry/binding layer for Capabilities, Tools, and Actions, and if so defines the smallest bounded contract.

The prior E4/E5 decision to defer a generic Tool registry remains the starting hypothesis. E6 must prove or reject that dependency rather than assume it.

## 2. Authority basis

Canonical SH Build Scope explicitly places Tools and Actions in SH Full scope and places the tool framework/action authorization in detailed implementation work.

The Workstream E audit establishes Capability / Tool / Action as a required conceptual layer.

E1 established the distinction:
- Capability = what SH can meaningfully do;
- Tool = runtime-callable external capability;
- Action = concrete operation/effect.

Neither Canonical nor the audited implementation evidence establishes a physical generic Tool Registry schema.

Resume 69 is historical/design input. It contains a Provider / Model Registry direction, but this is not evidence of a Tool Registry requirement and does not override Canonical/contract authority.

## 3. DEV evidence

### GitHub

Repository search on DEV found no verified generic:
- tool_registry;
- capability_registry;
- generic capability_id / tool_id / action_id registry implementation;
- generic Tool/Action binding implementation.

Existing E documents describe registry as deferred pending evidence.

### Supabase DEV

Direct table-name audit found no public/private table whose name indicates a Tool, Capability, or Action registry.

Therefore there is no verified running DEV registry foundation to reuse as-is.

## 4. Reclassification

| Area | Status | Finding |
|---|---|---|
| Capability / Tool / Action conceptual distinction | 🟢 | Established in E1 + contracts |
| Tools / Actions in SH Full scope | 🟢 | Canonical Build Scope |
| Generic Tool Registry in DEV | 🔴 | Not evidenced |
| Generic Capability Registry in DEV | 🔴 | Not evidenced |
| Generic Action Registry in DEV | 🔴 | Not evidenced |
| Capability → Tool binding concept | 🟡 | Design candidate |
| Tool → Action binding concept | 🟡 | Design candidate |
| Runtime needs stable Tool identity | 🟡 | Execution-contract dependency; exact mechanism unresolved |
| Discovery/catalogue requirement | 🟡 | Not yet proven |
| Registry as database table | 🟡 | Not justified by evidence |
| Provider/Model Registry | 🟢/🟡 | Separate historical/design direction; not Tool Registry evidence |
| Plugin marketplace/ecosystem | 🔴 | Not E6 scope |
| Registry as authority | 🔴 | Prohibited by SH governance boundary |

## 5. Critical finding

A registry is not automatically required just because Tools exist.

E4/E5 only require stable semantic identity and governed binding for an execution request.

That can initially be represented by a bounded contract/configuration without introducing a database-backed marketplace-style registry.

**E6 does NOT authorize building a generic registry yet.**

## 6. What binding actually needs

Minimum semantic relationship:

Capability
↓
Tool
↓
Action

with an execution-time binding:

Action
↓
Tool implementation / adapter

The binding must answer:
- which Tool can perform the Action;
- which Action belongs to the declared Capability;
- which Tool/Action identity is being invoked;
- which version/contract is applicable, if versioning becomes necessary;
- whether the binding is enabled/available in the current Runtime.

Exact storage mechanism remains OPEN.

## 7. Registry vs binding

These must not be conflated.

**Binding** is required conceptually for a governed execution system.

**Registry** is one possible implementation of binding/discovery.

Therefore:

Binding requirement ≠ Registry requirement

This is the central E6 conclusion.

## 8. Stable identity

E6 establishes a requirement for stable identifiers at semantic level:
- Capability identity;
- Tool identity;
- Action identity;
- execution/invocation correlation identity.

E6 does not freeze UUID/database schema/naming conventions.

Identity must remain stable enough for authorization, risk/confirmation, execution, result correlation, and audit.

## 9. Capability binding and authorization

Capability binding must not grant permission.

Correct relationship:

Capability
↓
Tool
↓
Action
↓
Authorization
↓
Risk / Confirmation
↓
Execution

Not:

Capability
↓
Permission

And not:

Registry entry
↓
Authority

A registered/available Tool is not automatically authorized for every SH.

## 10. Availability vs authority

E6 separates:

Tool exists
Tool is available
Tool is bound to Action
Action is authorized

These are different states.

A Tool may exist but be unavailable.
A Tool may be available but not authorized for a particular SH/action/context.
A binding may identify a valid implementation without granting private-data access.

## 11. Built-in vs Extension / Plugin

The registry question must not become an ecosystem project.

If later SH supports Extensions/Plugins, their binding must enter through the same Runtime governance and authorization boundary.

E6 does not define plugin marketplace, third-party ecosystem, provider marketplace, arbitrary code loading, or unrestricted extension execution.

## 12. Provider / Model Registry separation

Resume 69 contains a Provider / Model Registry direction.

That is separate from Tool/Action registry:

Provider / Model Registry ≠ Tool Registry

Model selection concerns model capability/provider routing.
Tool binding concerns executable Actions and governed Runtime execution.

No evidence found requires combining these registries.

## 13. Database decision

No generic Tool/Capability/Action registry table is justified by current evidence.

A database registry may become appropriate if later concrete requirements establish runtime discovery, enable/disable lifecycle, per-SH availability, versioned Tool contracts, dynamic Tool configuration, administrative management, or audit of registry changes.

These are future decision criteria, not current implementation requirements.

## 14. E6 dependency decision

E6 confirms:
1. Stable Tool/Action identity is required.
2. Capability/Tool/Action binding is required semantically.
3. A physical registry is not yet proven required.
4. Registry discovery is not required for the first bounded Tool slice unless the chosen Tool demonstrates that need.
5. Authorization remains outside the registry.
6. Risk/confirmation remains outside the registry.
7. Execution remains behind Runtime.
8. Audit remains separate from registry metadata.

## 15. Genuine gaps

1. Exact stable identity contract.
2. Binding contract.
3. Availability semantics.
4. Optional version compatibility.
5. When/if dynamic discovery becomes necessary.

Resolve these from the first concrete Tool/Action vertical slice.

## 16. Out of scope

- registry database migration;
- generic Tool marketplace;
- plugin ecosystem;
- dynamic arbitrary code loading;
- Tool-side authorization;
- capability-as-permission;
- provider/model registry redesign;
- UI registry management;
- unrestricted autonomous execution.

## 17. Status

**E6 = 🟢 AUDIT / BOUNDED DESIGN CLOSED — REGISTRY DEFERRED**

The audit proves that a generic physical registry is not currently evidenced and is not required merely by the existence of Tools.

The semantic binding requirement is accepted.

No implementation is authorized.

## 18. Next candidate

**E7 — Concrete V1.0 Tool/Action Vertical Slice**

E7 should choose one meaningful Tool/Action and use it to test the complete E contract:

Capability
→ Tool
→ Action
→ Invocation
→ Authorization
→ Risk
→ Confirmation (if required)
→ Execution
→ Result
→ Audit

The concrete slice should determine which previously-open generic contracts are actually necessary before any implementation begins.
