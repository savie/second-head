# SECOND HEAD V1.0 — WORKSTREAM E AUDIT

Status: **OPEN / AUDIT / NON-CANONICAL**
Date: 2026-08-29
Branch: `dev`

## Purpose

Living working document for **Workstream E — Hands / Tools / Authority**.

E is derived from Canonical SH Core, approved implementation contracts, V1.0 Roadmap, Resume 69, and verified DEV evidence. Resume 69 is brainstorming/history, not authority. This document does not modify Canonical.

## Authority hierarchy

1. Canonical SH Core — highest conceptual authority.
2. Approved architecture / implementation contracts — technical constraints.
3. `docs/evolution/V1.0/` — working development plan.
4. `docs/resume/` — continuity/history and candidate ideas.
5. Current DEV implementation — evidence; it does not silently redefine the documents above.

**Development rule:** Canonical is a guardrail. A missing Canonical detail may be developed in E as a formal evolution/design decision when it does not contradict Canonical invariants or silently redefine Canonical semantics.

## E objective

Build a system capability layer so SH can use meaningful capabilities and perform authorized operations.

```
SH
 ↓
Capability / Tool
 ↓
Authority
 ↓
Authorization / Risk Gate
 ↓
Confirmation when required
 ↓
Execution
 ↓
Result
 ↓
Audit / Event
 ↓
SH
```

## Resume 69 candidates

Resume 69 explicitly develops the “Hands” direction:

```
SH → capability/tool → authorization → execution → result → reasoning
```

and the “Authority / Will” flow:

```
SH wants to do X
 → Is SH allowed?
 → What authority?
 → Owner confirmation?
 → Execute
 → Record what happened
```

Candidate capability examples include search/web, files, image generation, external services, integrations, plugins/extensions, automation, and actions over SH data. These are candidates, not automatic E scope.

## Canonical / contract guardrails

E must preserve:

- Tool/capability is not authority.
- Runtime capability is not ownership.
- Tool/external result is untrusted data and must not become a system instruction.
- Creator Authority does not automatically grant private-data access.
- SH-000 Core Authority does not automatically grant private-data access.
- Private data remains subject to authorization.
- High-risk execution follows:
  `PLAN → AUTHORIZATION → CONFIRMATION → EXECUTE → AUDIT`.
- Authorization is not delegated to the App/UI.

## Current DEV foundation

### 🟢 Identity / ownership
Existing runtime identity resolution provides authenticated account/SH context and ownership information.

### 🟢 Permission
DEV contains `public.permission_matrix` with 45 current rules at audit time: 32 ALLOW / 13 DENY.

### 🟢 Authority assignment
DEV contains `private.authority_assignments`; an active CREATOR assignment is present.

### 🟢 Audit
DEV contains `public.audit_events` with 861 events at audit time and runtime audit recording via `runtime_record_audit`.

### 🟢 High-risk confirmation foundation
DEV contains `public.runtime_high_risk_confirmations` and runtime create/confirm/execute functions. Current verified operation is recovery-specific (`RECOVERY_RESTORE`).

**Finding:** this is an E foundation, not yet a generic Tool/Action confirmation framework.

### 🟢 Runtime boundary
App already uses a backend/runtime service boundary. The App is not treated as execution authority.

## E status matrix — PROVISIONAL

| Item | Status | Meaning |
|---|---|---|
| Capability concept | 🟢 | Strongly supported by Resume 69 + roadmap |
| Tool as runtime capability | 🟢 | Fits current architecture direction |
| Actor / SH context | 🟢 | Existing runtime foundation |
| Authorization reuse | 🟢 | Existing permission/authority foundation |
| Audit foundation | 🟢 | Existing runtime/database infrastructure |
| Minimum Tool contract | 🟡 | Required; exact design unresolved |
| Capability registry | 🟡 | Strong candidate; no generic registry verified in DEV |
| Invocation contract | 🟡 | Required; schema unresolved |
| Risk classification | 🟡 | Required direction; generic runtime model unresolved |
| Confirmation gate | 🟡 | Recovery foundation exists; generic contract unresolved |
| Execution boundary | 🟡 | Runtime exists; generic Tool executor unresolved |
| Result normalization | 🟡 | Required by roadmap; generic envelope unresolved |
| Tool lifecycle audit taxonomy | 🟡 | Audit primitive exists; Tool semantics unresolved |
| Execution ID / traceability | 🟡 | Candidate; must be evaluated |
| Tool vs Action | 🟢 conceptual / 🟡 implementation | Canonical + Implementation Contract explicitly distinguish Tools and Actions; generic implementation contract still unresolved |
| Built-in vs Extension/Plugin | 🟡 | Boundary requires reconciliation |
| Provider/model capability distinction | 🟡 | Direction exists; generic registry unresolved |
| Plugin marketplace/ecosystem | 🟡/🔴 scope review | Broad Extensions/Plugins are a candidate direction; marketplace specifically is not established as a V1.0 E requirement |
| Unrestricted autonomous execution | 🟡/🔴 boundary review | No unrestricted execution contract has been verified; must be reconciled against authorization/risk/confirmation rules before any implementation claim |
| Tool as authority | 🔴 prohibited | Conflicts with Canonical boundary |
| Capability = private-data permission | 🔴 prohibited | Capability does not replace authorization |
| App-side authorization | 🟡 boundary review | Runtime authorization is required by the contracts; exact client/server enforcement boundary must be verified from implementation before labeling this prohibited |

**Important:** 🟡 and 🔴 are audit labels, not final decisions. Yellow must be audited; red must have an explicit evidence-based reason for deferral or prohibition.

## E0 audit update — 2026-08-29

The first deeper reconcile changed several provisional labels based on direct source evidence.

### Tool vs Action is not an unresolved concept

Canonical section 6.10 and Implementation Contract sections 10–11 explicitly establish the distinction:

- **Tool** = external capability callable by runtime.
- **Action** = operation producing an effect/change outside internal reasoning.
- Tool is subordinate to identity, authorization, and governance.
- Action risk must be considered; high-risk actions require authorization and confirmation before execution and audit after execution.

Therefore the **conceptual distinction is GREEN**. What remains yellow is the exact generic runtime contract and lifecycle implementation.

### Tool system is explicitly a development target, not an invented E requirement

Canonical identifies the full Capability/Tool system as blueprint/deferred, while Build Scope and Execution Strategy put Tools and Actions into the broader SH Full target and define Tool Execution as registration, discovery, validation, invocation, monitoring, audit, default deny, and external-result handling.

Therefore E is not inventing the existence of Tools; E is the evolutionary implementation work needed to make that target concrete for the current V1.0 track.

### “Plugin marketplace” must not be treated as a Canonical prohibition

The source material supports Extensions/Plugins as a capability direction, but does not establish a marketplace as a required E deliverable. It is therefore **scope/dependency review**, not a Canonical prohibition.

### “Unrestricted autonomous execution” needs precise wording

The reviewed sources clearly require authorization for actions and a confirmation gate for high-risk actions. They do not, in the material audited so far, define a standalone formal rule named “unrestricted autonomous execution is prohibited.” Therefore the item remains a **boundary review** until the exact permitted autonomous execution model is derived.

### App-side authorization needs evidence before a hard prohibition label

The contracts require authorization and runtime execution orchestration, but this audit must distinguish the architectural principle from the exact current client implementation. Until the implementation enforcement path is fully mapped, the safe label is **boundary review**, not an invented prohibition.

## Yellow / red reconciliation protocol

For every unresolved item:

1. Check Canonical.
2. Check approved implementation contracts.
3. Check Roadmap.
4. Check Resume 69.
5. Check current DEV code/runtime/database.
6. Classify it as implemented, partial, valid new design, deferred, prohibited, or insufficiently audited.

Do not keep an item yellow/red merely because evidence was not yet found.

## Candidate minimum Tool contract

Roadmap requires:

- capability identity;
- invocation contract;
- actor/SH context;
- authorization;
- risk classification;
- confirmation when required;
- execution;
- result normalization;
- audit/event recording.

Before implementation, E must answer:

```
WHAT IS A CAPABILITY?
WHAT IS A TOOL?
WHAT IS AN ACTION?
WHAT IDENTIFIES ONE INVOCATION?
WHO MAY INVOKE?
WHO AUTHORIZES?
HOW IS RISK DETERMINED?
WHEN IS CONFIRMATION REQUIRED?
WHERE DOES EXECUTION OCCUR?
WHAT IS THE NORMALIZED RESULT?
WHAT MUST BE RECORDED?
```

## Tool vs Action

Do not assume Tool = Action.

Candidate model for investigation only:

```
Capability
├── Tool
│    └── invoke capability
└── Action
     └── perform state-changing operation
```

This is **not yet a formal SH decision**.

## Built-in vs Extension / Plugin

Roadmap requires the distinction between:

- built-in Tools;
- Extensions/Plugins;
- provider/model capabilities.

First define the boundary. Do not build an ecosystem before the execution/authority contract is stable.

Plugin marketplace is therefore **deferred, not permanently rejected**.

## Execution boundary

Target:

```
Owner / App
 ↓
SH Runtime / contract
 ↓
Identity + authorization
 ↓
Risk / confirmation gate
 ↓
Tool executor
 ↓
External capability
 ↓
Normalized result
 ↓
Audit
```

UI confirmation is not equivalent to runtime authorization.

## Existing confirmation infrastructure

Before creating another confirmation system, audit whether the existing recovery confirmation mechanism can safely generalize.

Audit dimensions:

- data model;
- lifecycle;
- identity binding;
- SH binding;
- actor binding;
- target binding;
- expiry;
- revalidation;
- execution;
- audit;
- failure semantics.

## Result normalization

Candidate result envelope for bounded design:

```
execution_id
tool_id
status
data
error
metadata
timestamp
```

This is a candidate, not a committed schema. External Tool output remains untrusted data.

## Audit boundary

Candidate events to evaluate:

- invocation requested;
- authorization allowed/denied;
- confirmation requested;
- confirmation accepted/rejected/expired;
- execution started;
- execution completed;
- execution failed;
- execution timed out;
- result recorded.

Final taxonomy must follow the actual runtime contract.

## First E boundary — provisional non-scope

Do not assume the first E slice includes:

- plugin marketplace;
- broad third-party ecosystem;
- unrestricted autonomous execution;
- arbitrary tool calling;
- provider migration;
- full multi-provider infrastructure;
- full automation platform;
- generic workflow engine.

These remain future candidates unless later audit/design promotes them.

## Dependency baseline

```
A 🟢
↓
B 🟢
↓
C 🟢 CLOSED
↓
D 🟢 CLOSED / VERIFIED
↓
E ← CURRENT
```

E must not bypass a prerequisite that materially affects its contract.

## Working method

```
AUDIT
 ↓
MAP
 ↓
RECONCILE
 ↓
BOUNDED DESIGN
 ↓
DECISION
 ↓
E1 / E2 / E3 ... only after natural boundaries are proven
 ↓
IMPLEMENT
 ↓
VERIFY
 ↓
CLOSE
```

No E1/E2 split is frozen yet.

## E0 — next audit gate

E0 must produce:

- complete Resume 69 extraction relevant to Hands/Tools/Authority;
- Canonical constraint map;
- current DEV evidence map;
- Tool vs Action reconciliation;
- Built-in vs Extension/Plugin reconciliation;
- risk/confirmation reconciliation;
- execution boundary reconciliation;
- result normalization decision;
- audit taxonomy decision;
- explicit blockers;
- proposed first E sub-workstream boundary.

### E0 exit

E0 is complete only when:

- material 🟡 items have a resolution path;
- 🔴 items have documented evidence-based reasons;
- no unresolved prerequisite materially invalidates the first implementation slice;
- first E sub-workstream can be defined without guessing.

## Change log

### 2026-08-29 — E0 deeper source reconciliation

- Tool vs Action conceptual distinction upgraded from unresolved to conceptually confirmed.
- Plugin marketplace changed from hard red to scope/dependency review because the sources do not establish it as a Canonical prohibition.
- Unrestricted autonomous execution changed to boundary review because the sources require authorization/high-risk confirmation but do not define that exact prohibition as a named rule.
- App-side authorization changed to boundary review pending exact implementation enforcement evidence.
- Generic Tool/Capability implementation remains unresolved; E is the bounded evolutionary work to make the already-defined Tool/Action target concrete.

### 2026-08-29 — Initial living E audit baseline

- Established E as a non-Canonical living document.
- Resume 69 promoted only to candidate-source status.
- Existing DEV authority/permission/audit/runtime/confirmation foundations recorded.
- Generic Tool/Capability implementation not assumed.
- Yellow/red classifications explicitly marked provisional.
- No product-code implementation performed.

END OF WORKSTREAM E AUDIT
