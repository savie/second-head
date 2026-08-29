# WORKSTREAM E1 — CAPABILITY / TOOL / ACTION BOUNDED DESIGN

**Project:** SECOND HEAD V1.0  
**Workstream:** E1  
**Date:** 2026-08-29  
**Status:** BOUNDED DESIGN DRAFT / READY FOR RECONCILIATION  
**Implementation:** NOT AUTHORIZED

> This is a living evolution/design document. It is not Canonical, not a database schema, and not an implementation instruction.

---

## 22. E1 bounded design — Capability / Tool / Action vocabulary

### 22.1 Purpose

E1 establishes the minimum conceptual vocabulary required before designing registry, invocation, authorization, risk, confirmation, or execution contracts.

This is a **bounded design decision**, not a database schema and not an implementation instruction.

### 22.2 Source classification

- **CANON:** Canonical identifies Tools and Actions as SH Core components and states that they are subordinate to identity, authorization, and governance boundaries.
- **CONTRACT / EXISTING DEV:** Current DEV contains authority, ownership, runtime access, permission policy, confirmation, and audit foundations that E1 must integrate with rather than replace.
- **EVOLUTION DECISION:** The explicit three-level vocabulary below is introduced to remove ambiguity in the Hands design.
- **OPEN:** Exact registry fields, persistence model, provider metadata, versioning, and adapter mechanics remain outside E1 until E2+.

### 22.3 Capability

**Capability = a governed ability that SH may make available to perform a class of useful work.**

A Capability is descriptive and declarative.

A Capability:
- describes what SH can potentially do;
- does not itself execute anything;
- does not grant authority;
- does not grant private-data access;
- does not imply user permission;
- does not itself require confirmation;
- does not bypass Runtime governance.

Examples as conceptual categories only:
- calendar management;
- image generation;
- web retrieval;
- file processing.

These examples do not constitute the V1.0 Tool inventory.

### 22.4 Tool

**Tool = a controlled interface/adapter through which Runtime can access a capability.**

A Tool is operationally addressable by Runtime.

A Tool:
- declares or exposes one or more Actions;
- accepts a bounded invocation;
- passes execution through the Runtime governance boundary;
- returns result data to Runtime;
- is not an authority;
- cannot self-authorize;
- cannot grant itself private-data access.

A Tool is therefore not synonymous with Capability.

A Capability answers:
> What can SH potentially do?

A Tool answers:
> Through what governed interface can Runtime access that capability?

### 22.5 Action

**Action = a concrete operation exposed by a Tool.**

An Action has an explicit operation/effect.

Examples:
- Calendar Tool -> list events;
- Calendar Tool -> create event;
- Calendar Tool -> update event;
- Calendar Tool -> delete event.

These examples are vocabulary examples only.

The Action is the correct level at which authorization, risk, confirmation, and execution semantics may differ.

Therefore:

**Tool-level access must not be assumed to mean blanket permission for every Action exposed by that Tool.**

### 22.6 Relationship

The bounded relationship is:

Capability
  -> may be exposed through one or more Tools
      -> each Tool may expose one or more Actions

But the relationship does **not** imply:

Capability -> permission
Tool -> authority
Tool -> ownership
Action -> automatic authorization
Capability -> private-data access

### 22.7 Invocation

E1 establishes an important distinction:

**Intent is not execution.**

The Model/App may express an intended operation, but that intent becomes an executable Action request only after Runtime constructs a governed invocation context and evaluates the applicable boundaries.

Conceptually:

User / Model intent
    ↓
candidate Action
    ↓
Runtime invocation context
    ↓
authorization / risk / confirmation gates
    ↓
execution eligibility

This prevents a model-generated instruction from becoming an execution command merely because it names a Tool or Action.

### 22.8 Authority boundary

The following are explicit E1 guardrails:

1. Capability is not permission.
2. Capability is not ownership.
3. Tool is not authority.
4. Action is not automatically authorized.
5. Tool output is result data, not system authority.
6. App/UI is not the authorization authority.
7. Model intent is not authorization.
8. Runtime execution does not establish ownership.
9. Cross-SH/private-domain access remains subject to existing governance and access controls.

### 22.9 E1 minimum conceptual object map

No physical schema is implied.

| Object | Answers | Can execute? | Grants authority? |
|---|---|---:|---:|
| Capability | What ability exists? | No | No |
| Tool | Through what governed interface? | No, by itself | No |
| Action | What concrete operation/effect? | Only when Runtime executes it | No |
| Invocation | What operation is being requested, by whom, against what target/context? | No, it is a request | No |
| Authorization Decision | Is this invocation permitted? | No | No; it evaluates authority |
| Runtime Execution | Carry out an authorized Action | Yes | No |

The final two rows are included to prevent E1 vocabulary from being interpreted as a standalone Tool subsystem.

### 22.10 E1 acceptance criteria

E1 can be considered **bounded-design complete** when:

- Capability, Tool, and Action are distinguishable without overlap;
- Action is explicit enough to carry operation-specific authorization/risk semantics;
- no object in the vocabulary is treated as authority;
- intent is explicitly separated from execution;
- the vocabulary can map onto the existing permission/authority/access foundations without creating a second authority system;
- no requirement for a physical schema has been smuggled into E1.

### 22.11 E1 unresolved items

Remain OPEN until later bounded-design work:
- canonical/global identifiers;
- registry persistence;
- Tool versioning;
- provider metadata;
- adapter interface;
- capability discovery;
- enable/disable lifecycle;
- exact invocation envelope;
- authorization evaluator implementation;
- risk taxonomy;
- generic confirmation semantics.

### 22.12 E1 status

**E1 = BOUNDED DESIGN DRAFT / READY FOR RECONCILIATION**

Not yet implementation-authorized.
Not yet a database contract.
Not Canonical amendment.

