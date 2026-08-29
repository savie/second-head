# SECOND HEAD V1.0 — WORKSTREAM E — R1 GLOBAL SEARCH

Status: **SELECTED CANDIDATE / TOOL-SPECIFIC BOUNDED DESIGN**
Date: 2026-08-29
Branch: `dev`

## 1. Position

R1 is the first **selected representative Tool** from the current SH Tool Landscape.

Classification:

- **Family:** A — Search & Discovery
- **Candidate:** Global Search
- **Selection:** R1
- **Role:** first representative read-oriented Tool slice
- **Strategy:** **REUSE / ADAPT**, not rebuild

R1 does **not** define the whole Workstream E architecture.

## 2. Why R1

Global Search is selected because it can exercise the core governed Tool lifecycle with relatively low external side effect:

```
request
  ↓
Tool invocation
  ↓
SH / actor context
  ↓
authorization
  ↓
execution
  ↓
normalized result
  ↓
audit
```

It therefore gives E a concrete representative slice without prematurely introducing external write effects.

## 3. Existing Capability

DEV already contains a bounded Global Search capability/path.

The implementation should be treated as an **existing capability to be discovered and reused**, not as a reason to build a new search engine.

Discovery rule:

> If an existing DEV capability satisfies the required contract, reuse it. Do not duplicate it merely to fit a new E abstraction.

Any missing bridge belongs to the generic E design layer, not to a second independent search implementation.

## 4. Boundary

### IN

- bounded search query;
- authenticated SH/account context;
- runtime-side authorization;
- bounded execution;
- normalized search result;
- provenance/source identity where available;
- lifecycle audit/traceability.

### OUT

- unrestricted web crawling;
- arbitrary browsing automation;
- private-data access by implication;
- external write/update/send actions;
- autonomous workflow orchestration;
- plugin marketplace;
- arbitrary third-party code execution;
- a new search engine.

## 5. Tool vs Action

**Tool:** Global Search capability.

**Invocation/Action:** one concrete search execution requested through the runtime.

The existence of a Tool does not grant authority.

A search result is external/untrusted data. It must not become a system instruction or alter SH authority.

## 6. Authority & Authorization

R1 must execute through the SH Runtime boundary.

The App/UI is not the authority.

Required conceptual path:

```
SH / actor context
      ↓
authorization decision
      ↓
R1 eligibility
      ↓
execute
      ↓
result
      ↓
audit
```

R1 is read-oriented, but **read-oriented does not mean permissionless**.

Private-data permission must not be inferred merely because a search capability exists.

## 7. Risk

**Default classification: LOW / READ-ORIENTED.**

This classification describes expected side effect, not authorization.

Failure, invalid context, unauthorized invocation, malformed input, provider failure, or timeout must fail closed and must not mutate SH state.

## 8. Contract Coverage

| E requirement | R1 coverage |
|---|---|
| Capability identity | Covered |
| Tool identity | Covered |
| Actor / SH context | Required |
| Invocation contract | Required |
| Authorization | Required through generic E bridge |
| Risk classification | Low / read-oriented |
| Confirmation | Not required for normal bounded read |
| Execution boundary | SH Runtime |
| Result normalization | Required |
| Audit / traceability | Required; reuse existing audit primitive |
| External result trust boundary | Explicit |
| Ownership / private-data boundary | Preserved |

R1 therefore acts as a **representative coverage slice**, not proof that every generic E contract already exists.

## 9. Existing Primitive Reuse

Where semantically compatible, R1 should reuse:

- existing identity / SH context resolution;
- existing ownership enforcement;
- existing authorization/policy data;
- existing runtime boundary;
- existing audit recording.

Do not create parallel identity, authority, permission, or audit systems inside R1.

The current E audit has already identified generic authorization evaluation and generic Tool/Action execution bridging as design gaps. R1 therefore depends on those generic contracts being defined before implementation.

## 10. Confirmation

No Owner confirmation is required for the normal bounded read-only R1 path.

This does **not** weaken the general E rule for high-risk Actions.

If a future search capability introduces a side effect or materially different risk, it must be reclassified rather than silently inheriting R1's low-risk treatment.

## 11. Result Contract

R1 should expose a bounded normalized result to the SH Runtime.

Minimum conceptual properties:

- invocation identity;
- success/failure status;
- result items or bounded result payload;
- source/provenance information where available;
- error information when execution fails.

External content remains **data**, not authority.

The exact generic result envelope belongs to the shared E contract and should not be reinvented specifically for R1.

## 12. Audit

Every R1 invocation must remain traceable through the existing SH audit infrastructure.

At minimum the lifecycle must permit correlation of:

- invocation/action identity;
- SH/actor context;
- Tool identity = R1 / Global Search;
- outcome;
- execution time;
- relevant source/metadata.

The exact generic audit schema is an E-level design concern. R1 should consume it rather than invent a separate R1 audit taxonomy.

## 13. Dependencies / Open Gaps

R1 implementation remains blocked on the bounded generic contracts that E is defining:

1. generic authorization decision semantics;
2. generic Tool/Action invocation contract;
3. runtime execution bridge;
4. normalized result/error envelope;
5. generic Tool execution audit correlation.

These are **dependencies**, not reasons to abandon R1.

## 14. Non-Goals

R1 does not establish:

- a universal Search abstraction for every provider;
- a plugin/extension architecture;
- MCP architecture;
- unrestricted browsing;
- autonomous agents;
- generic workflow automation;
- a new authority system;
- a new permission system;
- a new audit system.

## 15. Exit Condition

R1 bounded design is ready to move toward implementation when the shared E contracts can answer, without ambiguity:

```
WHO?
  ↓
WHAT capability?
  ↓
WHAT exact invocation?
  ↓
IS IT AUTHORIZED?
  ↓
WHAT risk?
  ↓
EXECUTE WHERE?
  ↓
WHAT result?
  ↓
WHAT audit evidence?
```

Implementation itself is a later step.

---

**R1 conclusion:** Global Search remains the selected first representative Tool because it gives high E-contract coverage with low side effect while allowing SH to reuse existing capability and governance primitives. R1 is a concrete slice of Family A, not the definition of Workstream E.
