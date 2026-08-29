# WORKSTREAM E7 — CONCRETE V1.0 TOOL/ACTION VERTICAL SLICE

**Project:** SECOND HEAD V1.0  
**Workstream:** E7  
**Date:** 2026-08-29  
**Status:** AUDIT → MAP → RECONCILE COMPLETE / BOUNDED DESIGN  
**Implementation:** NOT AUTHORIZED

> Living evolution/design document. Not Canonical, not a database schema, and not an implementation authorization.

## 1. Purpose

E7 tests E1–E6 against one concrete V1.0 Tool/Action vertical slice before any generic execution framework is implemented.

The purpose is to discover which contracts are genuinely required, not to invent a complete Tool ecosystem.

## 2. Source reconciliation

Canonical/contract material establishes Tools and Actions as a V1.0 system target and requires governed authorization, risk handling, execution, result handling, and audit.

E1–E6 establish the bounded vocabulary and boundaries:
Capability → Tool → Action → Invocation → Authorization → Risk/Confirmation → Execution → Result → Audit.

Resume 69 is useful historical/design input but does not identify an already-implemented concrete Tool in DEV.

## 3. Concrete implementation evidence audit

DEV repository searches were performed for existing Tool/Action implementations and callers.

Findings:
- No verified generic Tool/Action execution implementation.
- No verified generic Tool adapter.
- No verified generic Tool registry.
- No verified generic web-search Tool implementation.
- Existing Runtime is primarily conversation/model execution.
- Existing file/attachment and multimodal work is evidence of application capability, but not by itself proof of a governed Tool/Action executor.

Therefore E7 must not pretend an existing concrete Tool exists merely because a capability exists elsewhere in the product.

## 4. Candidate Tool classes from source material

Source material gives conceptual examples including:
- calendar management;
- image generation;
- web retrieval;
- file processing.

These are examples/capability directions, not an approved V1.0 Tool inventory.

Current evidence does not establish that any one of these already has the complete Tool/Action runtime path.

## 5. Selection criteria

The first concrete vertical slice should:

1. have a clear Capability;
2. expose a clearly bounded Tool;
3. expose one explicit Action;
4. have an unambiguous target/context;
5. be executable only through Runtime;
6. map to existing identity/ownership/authorization foundations;
7. have deterministic or inspectable result semantics;
8. support audit correlation;
9. make risk/confirmation behavior observable where applicable;
10. avoid requiring a plugin ecosystem or provider migration.

## 6. Preferred first-slice shape

Based on the current evidence, the first slice should preferably be a **bounded, read-oriented Action** rather than a destructive mutation.

Reason: the first slice is intended to validate the execution boundary and contracts with the smallest possible side-effect surface.

This is a design preference, not a Canonical requirement.

A final concrete Tool cannot be selected from current DEV evidence without inventing an implementation/provider dependency.

## 7. Required lifecycle test

The selected Action must be able to demonstrate:

Capability
↓
Tool
↓
Action
↓
Invocation
↓
Actor + SH context
↓
Authorization decision
↓
Risk classification
↓
Confirmation if required
↓
Execution eligibility
↓
Tool Adapter
↓
Concrete execution
↓
Result
↓
Audit

A governance failure must stop the lifecycle before execution.

## 8. What the vertical slice must prove

### Identity
The execution remains bound to the correct actor and SH.

### Authorization
Permission is evaluated for the concrete Action rather than inferred from Capability or Tool availability.

### Risk
Risk is associated with the concrete Action/effect.

### Confirmation
If the Action is high-risk, confirmation is required before execution. Confirmation is not authorization.

### Execution
Only the governed Runtime path can execute the Action.

### Result
The Tool outcome can be represented without turning Tool output into authority.

### Audit
The complete lifecycle can be correlated without conflating audit records with result storage.

## 9. Registry test

The vertical slice must explicitly test whether it needs:
- static binding/configuration only; or
- a physical registry.

E6 already established that registry is not required merely because Tools exist.

If one concrete Tool can be bound and invoked safely without a registry, registry remains deferred.

If the concrete Tool requires runtime discovery, enable/disable lifecycle, dynamic configuration, version negotiation, or equivalent functionality, that evidence may promote registry from deferred to required design.

## 10. Result normalization test

The slice must test whether the E5 result envelope is sufficient.

It must distinguish:
- execution status;
- result payload;
- failure;
- correlation;
- Tool/Action identity.

A universal domain schema is not required unless the concrete Tool demonstrates the need.

## 11. Risk/confirmation test

The first slice should deliberately identify its risk class.

If read-only/low-risk:
- confirmation may not be required;
- authorization still remains required.

If state-changing/high-risk:
- authorization;
- confirmation;
- execution;
- audit
must all be demonstrated.

The exact risk classification must be derived from the concrete Action, not from the Tool name.

## 12. Current candidate decision

**No concrete external Tool is promoted to implementation-ready status by E7 yet.**

The audit evidence is insufficient to select Calendar, Web, Image Generation, or File Processing as an already-existing concrete Tool implementation.

Therefore E7 remains a **selection/design gate**, not a fake implementation commitment.

## 13. E7 decision

**E7 = 🟡 BOUNDED DESIGN ACCEPTED / CONCRETE TOOL SELECTION OPEN**

What is closed:
- vertical-slice methodology;
- lifecycle to test;
- selection criteria;
- registry test;
- result test;
- governance boundaries.

What remains open:
- concrete first Tool;
- concrete Action;
- concrete provider/adapter;
- exact authorization mapping;
- exact risk classification;
- exact result shape.

No implementation is authorized.

## 14. Dependency rule

Do not proceed to generic Tool implementation until one concrete Action is selected and its full lifecycle can be specified without guessing.

Do not create a registry merely to make the selection problem disappear.

Do not select a provider first and then retrofit SH governance around it.

## 15. Next candidate

**E8 — Concrete Tool/Action Selection + Contract Freeze**

E8 should use the current DEV product capabilities and provider/runtime evidence to choose one concrete low-risk Action, then freeze only the minimum contracts required by that slice.

If existing evidence reveals a suitable internal/built-in Tool, that should be preferred over introducing an external ecosystem dependency for the first proof slice.

