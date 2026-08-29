# SECOND HEAD V1.0 — WORKSTREAM E TOOL — R2 AUTHORIZED READ / RETRIEVE

Status: **IMPLEMENTED / CI VERIFIED / RUNTIME-SPECIFIC EVIDENCE PENDING**
Date: 2026-08-29
Branch: `dev`

## 1. Position

R2 is the selected representative Tool for:

- **Family:** B — Knowledge & Retrieval
- **Candidate:** Authorized Read / Retrieve
- **Selection:** R2
- **Role:** test the boundary between a connected capability and permission to access data
- **Strategy:** **REUSE / ADAPT** an existing valid source/connector

R2 does not define the whole Integration/Connector architecture and does not grant blanket access to connected sources.

## 2. Why R2

R1 tests governed search.

R2 tests the next distinct boundary:

> **Having a connection/capability does not itself mean SH is authorized to read the data behind it.**

This makes R2 useful as a representative slice because it exercises source binding, scope, authorization, data sensitivity, provenance, and audit without introducing write-side effects.

## 3. Basic Flow

```
request
  ↓
identify actor + SH/account
  ↓
identify exact source
  ↓
identify bounded scope
  ↓
authorization decision
  ↓
retrieve
  ↓
normalize + attach provenance
  ↓
audit
```

If the source, scope, or authorization cannot be established unambiguously, the operation does not proceed.

## 4. Existing Capability / Source Strategy

R2 should **not build a new connector ecosystem**.

Preferred order:

1. discover an existing valid connected source/connector;
2. verify that its capability can satisfy the bounded R2 contract;
3. adapt it through the SH Runtime boundary;
4. reuse existing SH identity, ownership, authorization, and audit primitives where compatible.

A concrete provider/source remains **open until verified**. This document therefore defines the contract and boundary, not an invented provider choice.

## 5. Boundary

### IN

- one explicitly bound source;
- one bounded retrieval scope;
- authenticated actor / SH context;
- authorization evaluation;
- retrieval of permitted data;
- normalized result;
- provenance/source information;
- audit correlation.

### OUT

- blanket access to all connected services;
- “connected = authorized” semantics;
- cross-SH private-data access by implication;
- unrestricted private-data retrieval;
- write/update/send/submit actions;
- provider-side authority overriding SH authority;
- new connector marketplace/ecosystem;
- arbitrary third-party code execution.

## 6. Tool vs Action

**Tool:** Authorized Read / Retrieve capability.

**Invocation/Action:** one concrete read request against one specifically bound source and scope.

The Tool provides capability; it does not provide authority.

A provider's own connection/permission state must not silently become SH authority.

## 7. Authorization & Ownership

Before retrieval, SH Runtime must be able to establish at minimum:

- **WHO** is requesting;
- **WHICH SH/account context** applies;
- **WHAT source** is targeted;
- **WHAT scope** is requested;
- **WHAT data sensitivity** applies;
- **WHETHER the request is authorized**.

Private data is not readable merely because a connector exists.

If ownership, scope, or authorization is ambiguous, R2 must deny/fail closed rather than guess.

## 8. Risk

Default operation is **read-oriented**, but risk is contextual.

Examples:

- public/non-sensitive bounded source → lower risk;
- private source → higher sensitivity;
- highly sensitive/private scope → potentially high-risk.

Risk classification must not be used as a shortcut around authorization.

## 9. Contract Coverage

| E requirement | R2 coverage |
|---|---|
| Capability identity | Covered |
| Tool identity | Covered |
| Actor / SH context | Required |
| Source binding | Required |
| Scope binding | Required |
| Authorization | Required |
| Ownership / private-data boundary | Explicit |
| Data sensitivity | Required input to decision |
| Result normalization | Required |
| Provenance | Required |
| Audit / traceability | Required |
| Write side effect | Out of scope |
| Confirmation | Not normally required for bounded read; depends on contextual risk policy |

R2 is a representative coverage slice. It does not imply that all generic E infrastructure is already implemented.

## 10. Result Boundary

The retrieved payload is **data, not authority**.

The SH Runtime should receive a bounded normalized result containing, conceptually:

- invocation identity;
- success/failure;
- bounded result payload;
- source/provenance;
- relevant metadata;
- error information when retrieval fails.

The exact generic result envelope belongs to the shared E contract; R2 should consume it rather than invent another envelope.

## 11. Audit

Each R2 invocation must remain traceable through the existing SH audit infrastructure.

The audit trail should be sufficient to establish:

- who/which SH context initiated the request;
- which Tool was invoked (R2);
- which source and bounded scope were targeted;
- authorization outcome;
- execution outcome;
- relevant provenance;
- execution timing/correlation.

R2 must reuse the existing audit primitive where semantically compatible.

## 12. Failure / Containment

R2 must fail closed when any required binding cannot be established, including:

- missing authorization;
- ambiguous actor/SH context;
- ambiguous source;
- ambiguous scope;
- invalid ownership/permission binding;
- unavailable source;
- provider failure;
- invalid result.

A provider failure must not be converted into an authorization success.

No failed R2 invocation may silently broaden scope or fall back to an unbounded source.

## 13. Dependencies / Open Gaps

R2 depends on:

1. a concrete existing source/connector selected through capability discovery;
2. generic authorization decision semantics;
3. source/adapter contract;
4. normalized result/error envelope;
5. Tool execution audit correlation.

These are shared E dependencies. R2 should not create parallel versions of them.

## 14. Non-Goals

R2 does not establish:

- universal access to every connected service;
- a generic connector marketplace;
- a new private-data permission model;
- a new identity/ownership system;
- provider authority as SH authority;
- write/action execution;
- autonomous retrieval across arbitrary sources;
- MCP as a required architecture.

## 15. Exit Condition

R2 bounded design is ready for later implementation when one **existing, verified source/connector** can be mapped end-to-end:

```
WHO?
  ↓
WHICH SH/account?
  ↓
WHAT source?
  ↓
WHAT scope?
  ↓
AUTHORIZED?
  ↓
RETRIEVE
  ↓
NORMALIZE + PROVENANCE
  ↓
AUDIT
```

No provider is locked by this document until that verification occurs.

---

**R2 conclusion:** Authorized Read / Retrieve is retained as the selected representative of Family B because it tests a boundary that Global Search alone does not: **capability/connection must remain separate from permission to access data**. The implementation strategy remains reuse/adapt, with SH Runtime retaining governance and authority boundaries.


## CURRENT DEV AUDIT — 2026-08-29

DEV contains the bounded Authorized Read service and R2 migration. Current DEV CI is GREEN. This establishes implementation and automated verification on the DEV line, but no provider-specific/runtime acceptance is claimed from CI alone. The concrete source/connector and shared generic E authorization bridge remain explicit dependencies where this document requires them.
