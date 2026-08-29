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

## E0 FINAL DOCUMENT RECONCILIATION — 2026-08-29

### Authority reconciliation

The final source hierarchy for Workstream E is:

1. `docs/canonical/SECOND_HEAD_SH_CORE_CANONICAL_v1.0_BILINGUAL.md` — Canonical conceptual authority.
2. `docs/canonical/SECOND_HEAD_SH_FULL_BUILD_SCOPE_v1.0.md` — approved/locked build scope.
3. `docs/canonical/SECOND_HEAD_SH_FULL_IMPLEMENTATION_CONTRACT_v1.0.md` — implementation contract.
4. `docs/canonical/SECOND_HEAD_SH_FULL_IMPLEMENTATION_GUIDE_v1.0.md` — implementation guidance.
5. `docs/canonical/SECOND_HEAD_SH_FULL_EXECUTION_STRATEGY_v1.0.md` — derived execution strategy.
6. `docs/evolution/V1.0/ROADMAP.md` — V1.0 working roadmap.
7. `docs/resume/SECOND_HEAD_SESSION_RESUME_69.md` — historical/brainstorming continuity input only.
8. Current DEV source/runtime/database — implementation evidence, not conceptual authority.

No evidence requires changing the Canonical documents.

### Roadmap reconciliation

The V1.0 roadmap explicitly defines Workstream E as **Hands / Tools / Authority** and describes it as a system capability layer, not merely UI.

The roadmap's minimum lifecycle requirements are:
- capability identity;
- invocation contract;
- actor/SH context;
- authorization;
- risk classification;
- confirmation when required;
- execution;
- result normalization;
- audit/event recording.

It also requires distinction among built-in Tools, Extensions/Plugins, and provider/model capabilities, while explicitly deferring a plugin marketplace/broad extension ecosystem until the execution/authority contract is stable.

The roadmap's V1.0 gate requires at least one meaningful tool/action to traverse the complete authorized lifecycle without placing authority decisions in the App.

### Contract reconciliation

The Implementation Contract confirms:
- Tools are external capabilities callable by Runtime;
- Tools are not authority;
- Tool results are external/untrusted results, not system instructions;
- Actions are operations that produce effects/changes outside internal reasoning;
- high-risk Actions require authorization, confirmation, execution, and audit;
- authorization remains distinct from ownership/private-data access;
- Runtime is the execution/orchestration layer.

The Build Scope explicitly includes Tools and Actions in SH Full and includes authorization matrix, action authorization, audit schema, and Tool/action execution architecture.

### Resume 69 reconciliation

Resume 69 supplies useful evolutionary design input:
`SH → capability/tool → authorization → execution → result → reasoning`,
the Hands/Authority framing, owner confirmation, tool/action examples, and references to external capability patterns.

Resume 69 remains brainstorming/history and does not override Canonical or contracts.

### Final E boundary

**E is allowed to evolve the missing generic capability/execution bridge on top of existing SH governance/runtime primitives.**

The first bounded design target should cover:
1. generic authorization decision semantics;
2. Capability / Tool / Action contracts;
3. invocation identity and actor/SH context;
4. risk classification and confirmation semantics;
5. runtime execution boundary;
6. normalized result contract;
7. lifecycle audit/traceability.

Existing identity, ownership, authority, audit, and recovery-specific confirmation mechanisms must be reused where semantically compatible, not duplicated blindly.

### Explicit non-scope / deferred

The following are not first-slice E requirements based on the reconciled evidence:
- plugin marketplace;
- broad third-party extension ecosystem;
- unrestricted arbitrary tool calling;
- full multi-provider abstraction;
- generic workflow/automation platform;
- provider migration;
- broad portability abstraction without a concrete need.

These are deferred/scope boundaries, not new Canonical prohibitions.

### E0 outcome

**E0 EXISTING-FOUNDATION AUDIT: READY TO CLOSE.**

Reason:
- Canonical constraints are reconciled;
- Roadmap requirements are identified;
- DEV foundation has been traced through DB, security, runtime, and privilege layers;
- genuine generic gaps are identified without inventing missing implementation;
- Resume 69 inputs are separated from authority;
- no unresolved evidence currently requires a Canonical change.

### Remaining prerequisite before implementation

The next stage is **BOUNDED DESIGN**, not implementation.

Bounded design must decide the minimum generic authorization/Tool/Action contracts and explicitly map them to existing DEV primitives before any code or migration is authorized.

### Proposed natural first sub-workstream

**E1 — Capability / Tool / Action + Authorization Contract**

Provisional only; this is not frozen until the bounded-design document is reviewed.

Likely sequence:

```
E1  Contract / authorization boundary
 ↓
E2  Execution + risk/confirmation integration
 ↓
E3  Result + audit lifecycle
 ↓
E4  First meaningful Tool/Action vertical slice
```

This sequence is a planning hypothesis, not a locked roadmap change.

### Audit rule going forward

If a previously 🟡 item becomes provably existing during bounded design, upgrade it to 🟢 rather than rebuilding it.

If a previously 🔴 item lacks sufficient Canonical evidence for prohibition, downgrade it to 🟡 boundary/scope review rather than inventing a rule.

No implementation is implied by E0 closure.

## E0 trace — PostgreSQL grants / function privileges — 2026-08-29

### Direct DEV finding

The audited governance tables are not granted to `anon`/generic `authenticated` roles in the same way as ordinary application data:
- `permission_matrix`: direct table privileges observed for `postgres` and `service_role`;
- `authority_assignments`: direct table privileges observed for `postgres`;
- `runtime_high_risk_confirmations`: direct table privileges observed for `postgres` and `service_role`;
- `audit_events`: direct table privileges observed for `anon`, `authenticated`, `service_role`, and `postgres`, with RLS/policies providing ownership restrictions.

A direct privilege search did not reveal a generic permission-evaluator function exposed through the audited public/private function surface.

### Interpretation

This strengthens the previous conclusion that `permission_matrix` is currently best treated as **policy data / governance configuration**, not as a verified generic runtime decision API.

The existing security-definer functions demonstrate a strong backend enforcement pattern, but the high-risk functions are recovery-specific and do not evaluate the permission matrix.

### E0 conclusion

No additional hidden PostgreSQL grant/function layer was found that closes the generic authorization-evaluation gap.

Therefore the current evidence supports:

```
Policy data / Permission Matrix      🟢
Identity + ownership enforcement     🟢
Generic permission evaluator         🟡 GAP
Generic Tool/Action authorization    🟡 GAP
Generic execution contract           🟡 GAP
```

This is an **audit finding**, not yet an implementation decision. The missing evaluator and its relationship to the existing permission matrix must be defined in bounded design before any implementation begins.

### E0 exit candidate

The audit can now move toward closure of the **existing-foundation trace**, subject to a final document-level reconciliation of Canonical / Contract / Roadmap / Resume 69. No code implementation is authorized by this finding alone.

## E0 trace — RLS / function security / enforcement semantics — 2026-08-29

### Direct DEV database finding

RLS is enabled on all four audited tables:
- `private.authority_assignments`
- `public.permission_matrix`
- `public.audit_events`
- `public.runtime_high_risk_confirmations`

However, `pg_policies` returns **no explicit policy rows** for `permission_matrix`, `authority_assignments`, or `runtime_high_risk_confirmations`. Therefore their RLS configuration does not, by itself, establish an authenticated-user policy/evaluator path.

`audit_events` does have explicit ownership-scoped INSERT/SELECT policies using `current_account_id()` and SH ownership.

### Function-security finding

The audited runtime security functions are `SECURITY DEFINER`, owned by `postgres`, with controlled `search_path='public'`.

The high-risk functions enforce identity/SH ownership boundaries internally. However, their semantics are explicitly **recovery-specific** today:
- creation accepts only `RECOVERY_RESTORE`;
- target validation is against `recovery_snapshots`;
- execution calls `runtime_restore_recovery_snapshot`.

Therefore the existing high-risk confirmation infrastructure is **not a generic Tool/Action confirmation engine**. It is a reusable governance/security pattern with a recovery-specific implementation.

### Permission enforcement conclusion

The audit still has **no verified generic path**:

```
permission_matrix
      🟢 policy data
          ↓
generic evaluator / decision function
      🟡 NOT VERIFIED
          ↓
generic Tool/Action authorization
      🟡 NOT VERIFIED
```

Do not treat RLS alone as the missing evaluator, and do not treat recovery high-risk functions as generic E infrastructure.

### Stronger E0 implication

There is now enough evidence to distinguish two things:

1. **Reusable primitives/patterns already exist:** identity resolution, ownership checks, SECURITY DEFINER runtime boundaries, audit recording, confirmation state lifecycle.
2. **The generic Hands authorization/execution contract does not yet have verified implementation:** permission evaluation, Tool/Action authorization bridge, generic risk/confirmation semantics, and generic execution/result lifecycle remain bounded-design candidates.

## E0 trace result — DB → runtime → caller → enforcement

### What is verified

**Database objects exist in DEV:**
- `private.authority_assignments`
- `public.permission_matrix`
- `public.audit_events`
- `public.runtime_high_risk_confirmations`

**High-risk runtime primitives exist:**
- `runtime_create_high_risk_confirmation`
- `runtime_confirm_high_risk_action`
- `runtime_execute_high_risk_action`
- `runtime_record_audit`

The confirmation API currently accepts an `action_id`, operation, target, title and description; confirmation and execution are addressed by `confirmation_id`. Audit accepts SH, event type, status and JSON metadata.

### Actual application/runtime caller found

`functions/runtime-p4a-001/index.ts` directly calls `runtime_record_audit` for runtime request/response events and uses runtime identity resolution plus existing semantic lifecycle recorders.

The same function does **not** call the high-risk confirmation functions in its normal conversation/model path.

Therefore:

> The audit primitive is demonstrably wired into an application runtime path. The generic high-risk confirmation primitive is demonstrably present in the database/runtime surface, but its integration into a generic Tool/Action invocation path has **not** been verified.

### Enforcement conclusion

Current evidence is sufficient to classify:
- audit persistence: **🟢 verified runtime path**;
- identity resolution: **🟢 verified runtime path**;
- high-risk confirmation primitive: **🟢 verified database/runtime primitive**;
- generic Tool authorization enforcement: **🟡 not yet evidenced**;
- generic Tool execution enforcement: **🟡 not yet evidenced**;
- generic Tool caller/adapter: **🟡 not yet evidenced**.

Do not infer a generic Tool system merely from the existence of these primitives.

### Important boundary finding

The existing `runtime-p4a-001` path is primarily conversation/model/semantic-lifecycle runtime. It is evidence for reusable runtime infrastructure, **not evidence that Workstream E Tool execution already exists**.

## E0 trace — Permission Matrix enforcement — 2026-08-29

### Audit finding

The DEV database contains `public.permission_matrix`, including an `EXECUTE` action domain and ALLOW/DENY decisions.

However, direct inspection of the DEV PostgreSQL routine catalog found **no public routine whose name indicates a generic permission evaluator**, and no public routine definition was found that directly references `permission_matrix`.

GitHub source search likewise did not identify a generic runtime permission-evaluator function or an application caller that demonstrably evaluates `permission_matrix` for Tool/Action execution.

### Consequence

The following must be separated:

- **Permission Matrix exists:** 🟢 verified.
- **Permission Matrix semantics are documented:** 🟢 verified.
- **Generic permission evaluation/enforcement path is runtime-verified:** 🟡 NOT VERIFIED.
- **Generic Tool/Action authorization bridge:** 🟡 NOT VERIFIED.

This does **not** prove that permission enforcement is absent everywhere. It proves only that the audited evidence set does not establish a generic evaluator/caller path.

### E dependency implication

Before E implements a generic Tool/Action authorization bridge, the project must either:

1. locate and verify the existing evaluator/enforcement path; or
2. explicitly define the missing evaluator as part of bounded E design.

E must not silently duplicate or bypass the existing permission model.

### Current boundary conclusion

The strongest current evidence is:

```
Permission policy / matrix
        🟢
          │
          ▼
Generic evaluator
        🟡
          │
          ▼
Tool/Action authorization bridge
        🟡
          │
          ▼
Execution
        🟡
```

This is now an explicit E0 blocker/question, not an implementation assumption.

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

# MASTER CONSOLIDATION — E1–E20 RECONCILIATION
Date: 2026-08-29

## Consolidation decision

The separate E1–E20 documents are working decomposition artifacts, not a required permanent file structure. Their substantive decisions are consolidated here so this Audit document becomes the single living Master for Workstream E.

The Bounded Design document and dedicated E1–E20 files may be retired after this consolidation is verified. Git history remains the historical record.

## Consolidated bounded design

### 1. Capability / Tool / Action
- Capability describes a governed ability SH may make available.
- Tool is a controlled interface through which Runtime accesses a capability.
- Action is a concrete operation/effect exposed by a Tool.
- Invocation is a governed request, not execution.
- Intent is not execution.
- Tool is not authority.
- Capability is not permission.
- Action is not automatically authorized.
The Capability vocabulary is an evolution-level clarification; it does not amend Canonical semantics.

### 2. Invocation
Minimum semantic dimensions: actor, SH context, capability, tool, action, target/resource, scope/context, request provenance, request identity/correlation.
Actor, authority, ownership, and access relation remain distinct.

### 3. Authorization
Authorization is Runtime-owned and Action/invocation-specific.
Existing foundations to reuse: identity/account context, SH context and ownership, authority assignments, permission_matrix, runtime_access_boundary.
permission_matrix is verified policy data, not a verified generic evaluator API.
The generic evaluator / Tool-Action authorization bridge remains an implementation gap unless further DEV evidence closes it.
ALLOW may proceed to downstream gates; DENY must not execute; ESCALATE requires additional governed handling. Confirmation cannot override DENY.

### 4. Risk / Confirmation
Required high-risk sequence remains:
PLAN → AUTHORIZATION → CONFIRMATION → EXECUTE → AUDIT
Risk is Action + invocation-context dependent.
Existing runtime_high_risk_confirmations and create/confirm/execute functions are verified foundations but currently recovery-specific (RECOVERY_RESTORE). They are not silently generalized into a generic Tool confirmation engine.

### 5. Execution boundary
Runtime must establish execution eligibility before concrete Tool execution.
Eligibility binds, as applicable: Invocation/Action identity, actor/SH context, target, authorization outcome, required risk/confirmation state, freshness, and correlation.
Tool/plugin/provider does not decide whether execution is allowed. App and Model cannot directly perform privileged Tool execution.
Retries/replay and idempotency remain Action-specific.

### 6. Adapter boundary
Governed Execution Request → Adapter → Concrete Tool → Raw Outcome → Result Contract.
Adapter preserves approved identity/input/target/context/correlation and execution eligibility.
Adapter cannot authorize, grant private-data permission, substitute another Action, bypass confirmation, or become authority.

### 7. Result / error
Execution Result, Authorization Decision, Confirmation, and Audit Event are distinct.
Minimum outcome classes: SUCCEEDED, FAILED, REJECTED_BEFORE_EXECUTION, RESULT_UNAVAILABLE.
Tool-specific payload remains Tool-specific inside a governed envelope.
Governance failures remain distinguishable from Tool execution failures and result interpretation failures.
Tool output is untrusted result data, not system authority/instruction.

### 8. Audit / observability
Lifecycle correlation:
Invocation → Authorization → Risk → Confirmation → Execution → Result → Audit
Reuse existing Runtime audit infrastructure; do not create a competing audit authority. Audit observes/records; it does not authorize or retroactively approve.

### 9. Tool classes / extensibility
E may support Built-in/Internal Tools, Extensions, Plugin/provider-backed Tools, and future Tool classes not yet known.
All classes share the same SH Runtime governance boundary.
External implementation may provide capability/execution but never SH authority, permission, ownership, or confirmation authority.
No fixed V1.0 Tool inventory is declared.
No marketplace/ecosystem is required for V1.0 E.

### 10. Registry
A physical generic registry is not a prerequisite.
Static binding is acceptable for the first reference slice.
A registry becomes justified only if evidence demonstrates a real requirement such as dynamic discovery, enable/disable, lifecycle management, or version negotiation.
No registry implementation is authorized.

### 11. Reference slice
Global Search remains the strongest currently evidenced reference candidate because it is an existing bounded, read-oriented operation with explicit SH context and an inspectable result shape.
It is not the Workstream E architecture center and is not the fixed V1.0 Tool inventory.
The first concrete Tool/Action must validate the generic lifecycle, not dictate it.

### 12. Hard boundaries
Tool ≠ Authority
Capability ≠ Permission
Provider/Plugin ≠ Authority
Tool availability ≠ Authorization
Model intent ≠ Authorization
App/UI ≠ Authorization authority
Confirmation ≠ Authority
Ownership ≠ Blanket Action permission
Capability ≠ Private-data permission
External result ≠ System instruction
Unrestricted autonomous execution is outside the bounded E design.

### 13. Readiness
Before implementation:
- contracts reconciled against Canonical and approved technical documents;
- yellow items affecting the first slice re-audited or explicitly accepted as design gaps;
- prohibited/deferred boundaries recorded;
- at least one concrete Tool/Action traverses the complete governed lifecycle as a contract-complete vertical slice;
- implementation impact, tests, evidence, rollback/containment, and dependency order known;
- Owner explicitly authorizes implementation.

## E1–E20 reconciliation matrix

| Package | Reconciled outcome | Final role |
|---|---|---|
| E1 | 🟢 accepted | Capability/Tool/Action vocabulary |
| E2 | 🟢 accepted | Invocation + authorization boundary |
| E3 | 🟢 accepted | Risk + confirmation boundary |
| E4 | 🟡 accepted design / implementation gap | Execution boundary |
| E5 | 🟡 accepted design / implementation gap | Adapter + result |
| E6 | 🟢 closed | Registry deferred |
| E7 | 🟡 | Vertical slice design |
| E8 | 🟡 | Tool selection evidence-driven |
| E9 | 🟢 | Tool landscape / reusable foundations |
| E10 | 🟢 design principle | Common governance + extensibility |
| E11 | 🟢 design principle | Tool classes |
| E12 | 🟢 design principle | Action contract |
| E13 | 🟢 design principle | Authority/authorization binding |
| E14 | 🟢 design principle | Risk/confirmation matrix |
| E15 | 🟢 design principle | Execution eligibility |
| E16 | 🟢 design principle | Adapter contract |
| E17 | 🟢 design principle | Result/error contract |
| E18 | 🟢 design principle | Audit/observability |
| E19 | 🟢 design principle | Extensibility/registry lifecycle |
| E20 | 🟢 gate definition | Final readiness gate |

Important: 🟢 means the design decision/boundary is reconciled, not that runtime implementation already exists.

## Consolidated dependency chain

E1 vocabulary
→ E2 invocation/authorization
→ E3 risk/confirmation
→ E4 execution boundary
→ E5 adapter/result
→ E6 registry decision
→ E7–E9 evidence + reference slice
→ E10–E19 cross-cutting governance/extensibility contracts
→ E20 readiness gate
→ implementation only after explicit authorization
→ verification/evidence

Packages may be merged, split, or reordered if future evidence shows redundancy or dependency changes.

## Final Workstream E boundary

E is a governed capability/execution layer, not a plugin marketplace and not an autonomous execution platform.
E may evolve beyond the currently known Tool set. Every future Tool/Extension/Plugin must enter through the same SH governance boundary.

## Consolidation status

MASTER E = AUDIT + BOUNDED DESIGN + E1–E20 RECONCILIATION

Implementation remains BLOCKED.

Next operational step is final verification of this consolidation, then retirement of redundant E design files if no unique information remains outside this Master.

# RECONCILIATION PASS — DEV CROSS-CHECK
Date: 2026-08-29

## Runtime evidence verified

### GitHub DEV
- `app/app/search.tsx` is a client UI for the existing Global Search vertical slice.
- `app/services/global-search.ts` defines a bounded client contract: SH_ID is required; query is required and capped at 2000 characters; limit is bounded to 1–50; offset to 0–200; calls `global_search_bounded`; returns a normalized page envelope.
- The UI explicitly presents Global Search as a bounded backend contract and states that Private Memory is not downloaded for client-side search.

### Supabase DEV
Read-only schema/function inspection confirms:
- `public.accounts`, `public.sh_instances`, and `public.sh_ownership` exist with RLS enabled.
- `public.permission_matrix` exists with 45 rows; its comment identifies it as a Phase 2 governance permission matrix with default DENY when no valid allow rule matches.
- `public.runtime_high_risk_confirmations` exists with 6 rows and HIGH-only risk, lifecycle states PENDING/CONFIRMED/EXECUTED/CANCELLED/EXPIRED, plus action/account/SH/actor/target correlation fields.
- `public.global_search_bounded` exists as SECURITY DEFINER with a public search_path limited to `public`.
- The function requires authenticated `auth.uid()`, resolves the current account, requires a supplied SH_ID owned by that account, validates query length and domain vocabulary, and scopes candidates by account/SH/access semantics.
- The search function exposes only five bounded domains: CONVERSATION, MEMORY, KNOWLEDGE, EXPERIENCE, JOURNEY.
- Search results are returned as a bounded result envelope containing result_id, domain, title, snippet, source_ref, provenance, occurred_at, relevance_score.

## Reconciliation outcome

### 🟢 Confirmed
1. A concrete bounded Tool-like capability already exists at the Global Search vertical slice.
2. SH_ID/account ownership is enforced server-side for that slice.
3. Private/general visibility constraints are represented in the data model and search function.
4. Result normalization already exists for Global Search.
5. The existing permission matrix is a real governance foundation and explicitly defaults to DENY.
6. RLS is present on the inspected identity/ownership/governance/search-related data surfaces.

### 🟡 Still design/implementation gap
1. No verified generic Tool/Action authorization evaluator was found in the inspected DEV evidence.
2. The Global Search RPC is a specialized bounded function, not evidence of a generic Tool execution framework.
3. The existing high-risk confirmation table is not evidence of a generic Tool confirmation engine; its current schema is specifically HIGH-risk oriented.
4. No verified generic Tool registry is required or evidenced yet.
5. A complete generic Invocation → Authorization → Risk/Confirmation → Execution → Result → Audit lifecycle is not yet evidenced by one generic runtime path.

### 🔴 Explicitly outside current E implementation boundary
- unrestricted autonomous execution;
- Tool/plugin/provider as authority;
- capability as private-data permission;
- app-side authorization;
- plugin marketplace/ecosystem implementation;
- direct privileged execution from the model/UI.

## Scope correction

Global Search is retained as a **reference vertical slice**, not as the definition of Workstream E.

The implementation target must therefore be the **smallest reusable governed Tool/Action runtime boundary** that can host Global Search and future Tools without granting Global Search special architectural authority.

## Implementation gate after this pass

E is **not yet implementation-ready**.

The next bounded-design task is to specify the generic contract for:
1. Invocation;
2. Authorization decision;
3. Risk/confirmation decision;
4. Execution eligibility;
5. Adapter invocation;
6. normalized result/error;
7. audit correlation.

Only after those contracts are reconciled against the existing DEV foundations should an implementation slice be authorized.

No Supabase mutation was performed in this reconciliation pass.


# BOUNDED GENERIC CONTRACT PASS — 2026-08-29

## Status

**DESIGN / RECONCILIATION — NOT IMPLEMENTATION**

This pass matures the seven generic contracts required by E. It does not create database schema, runtime code, UI, or a generic Tool framework.

## 1. Invocation Contract
An Invocation is a governed request to perform one specific Tool/Action operation.
Minimum semantic fields: invocation_id; actor/account identity; sh_id; capability identity; tool identity; action identity; target/resource where applicable; input/payload; request provenance/source; correlation/trace identity; requested-at timestamp.
Rules: Invocation ≠ authorization; Invocation ≠ execution; invalid identity or SH context fails before authorization; client request does not grant execution authority.
Status: 🟢 bounded design

## 2. Authorization Decision Contract
Authorization is evaluated by the SH Runtime for the concrete Action and invocation context.
Decision vocabulary: ALLOW; DENY; ESCALATE.
Context may include actor, account, SH, authority relationship, Action, target/resource, requested scope, relevant policy/rules, and invocation context.
Rules: ownership is not blanket Action permission; capability availability is not permission; confirmation cannot convert DENY into ALLOW; Tool/provider/plugin cannot make the authorization decision.
permission_matrix remains the existing policy foundation; a generic evaluator API is still not verified in DEV.
Status: 🟡 design complete / implementation gap

## 3. Risk / Confirmation Decision Contract
Risk is evaluated at concrete Action + invocation context.
Bounded vocabulary: LOW where policy permits without confirmation; HIGH where confirmation is required. Additional states require evidence.
For HIGH: PLAN → AUTHORIZATION → CONFIRMATION → EXECUTE → AUDIT.
Confirmation must bind to the approved operation/context sufficiently to prevent replay or substitution.
Existing runtime_high_risk_confirmations is a reusable foundation/pattern but currently implements RECOVERY_RESTORE; generic Tool confirmation is not verified.
Status: 🟡 design complete / generic implementation gap

## 4. Execution Eligibility Contract
Execution may start only after Runtime establishes eligibility.
Eligibility binds, as applicable: invocation_id; actor/account; sh_id; capability/tool/action; target; authorization decision; confirmation state when required; freshness/expiry; correlation identity.
Boundary: Caller → Runtime → Governance Gates → Adapter → Tool.
The concrete Tool cannot reinterpret authorization, bypass confirmation, or select a more privileged Action.
Status: 🟡 design complete / implementation gap

## 5. Adapter Contract
Adapter is the controlled bridge between the governed Runtime contract and a concrete Tool implementation.
Governed Execution Request → Adapter → Concrete Tool.
Adapter maps governed input, preserves approved identity/context/target/correlation, invokes only the approved Tool/Action, captures raw outcome, and returns it to the Runtime result boundary.
Adapter MUST NOT authorize, grant permissions, change actor/SH context, substitute Action, bypass risk/confirmation, or become authority.
Status: 🟡 design complete / implementation gap

## 6. Result / Error Contract
Runtime returns a normalized governed envelope around Tool-specific output.
Minimum conceptual envelope: execution_id; tool_id; action_id; status; data/result; error; metadata; timestamp/correlation.
Minimum status classes: SUCCEEDED; FAILED; REJECTED_BEFORE_EXECUTION; RESULT_UNAVAILABLE.
Errors distinguish governance rejection, confirmation/authorization failure, execution failure, timeout/unavailability, and result interpretation/normalization failure.
External Tool output remains untrusted data and cannot become a system instruction.
Global Search provides evidence for a bounded normalized result shape, but does not establish the generic envelope as implemented.
Status: 🟡 design complete / generic implementation gap

## 7. Audit / Trace Contract
Generic lifecycle: Invocation → Authorization → Risk → Confirmation → Execution → Result → Audit.
Candidate events: INVOCATION_REQUESTED; AUTHORIZATION_ALLOWED/DENIED/ESCALATED; CONFIRMATION_REQUIRED/CONFIRMED/REJECTED/EXPIRED; EXECUTION_STARTED/COMPLETED/FAILED; RESULT_RECORDED.
Final taxonomy must reuse existing audit infrastructure and actual runtime semantics.
runtime_record_audit and audit_events provide the persistence/runtime foundation. E must not create a competing audit authority.
Status: 🟢 foundation verified / 🟡 generic Tool event taxonomy still to be mapped

## Contract composition
The seven contracts form one governed lifecycle, not seven independent subsystems:
Invocation → Authorization Decision → Risk/Confirmation → Execution Eligibility → Adapter → Result/Error → Audit.
A failed governance gate terminates or diverts the lifecycle before execution.

## Explicit non-derivations
This design does NOT infer a generic registry, marketplace, arbitrary autonomous Tool calling, a new permission model, a new audit store, a generic confirmation table, provider/model authority, or client-side authorization.

## Current E implementation readiness
NOT READY FOR IMPLEMENTATION.
The next prerequisite is a concrete mapping from each contract to existing DEV primitives and one bounded reference Tool/Action.
Next pass: reconcile the exact Runtime caller/orchestration point; identity/authority/permission primitives; generic authorization evaluation placement; generic confirmation versus recovery-specific confirmation; execution/adapter location; normalized result boundary; audit event mapping.
Only then should implementation scope be frozen.

# DEV PRIMITIVE MAPPING — RECONCILIATION PASS 2026-08-29

## Mapping result

| E contract | Existing DEV foundation | Status | Gap |
|---|---|---|---|
| Invocation | Global Search RPC + existing runtime audit event type TOOL_INVOCATION | 🟡 | No generic invocation object/entry contract verified |
| Authorization | resolve_identity(), account/SH ownership checks, permission_matrix | 🟡 | Generic Action evaluator/bridge not verified |
| Risk / Confirmation | runtime_high_risk_confirmations, runtime_create_high_risk_confirmation(), runtime_confirm_high_risk_action() | 🟡 | Current implementation is explicitly limited to RECOVERY_RESTORE |
| Execution Eligibility | Global Search server-side ownership/input gates | 🟡 | No generic pre-execution eligibility gate verified |
| Adapter | global_search_bounded() is a concrete bounded RPC, not an adapter framework | 🟡 | Generic adapter boundary absent |
| Result / Error | Global Search normalized page/result types + bounded RPC return table | 🟡 | Generic execution result/error envelope absent |
| Audit / Trace | audit_events + runtime_record_audit() | 🟢 foundation / 🟡 E mapping | Existing event vocabulary supports TOOL_INVOCATION/RUNTIME_ACTION but no complete generic lifecycle correlation contract verified |

## Important correction

Foundation exists ≠ generic E contract exists.

Direct DEV inspection confirms:
- runtime_create_high_risk_confirmation() rejects any operation other than RECOVERY_RESTORE.
- runtime_confirm_high_risk_action() confirms an existing recovery-oriented confirmation row.
- runtime_record_audit() validates SH ownership and accepts TOOL_INVOCATION and RUNTIME_ACTION, useful evidence for E, but does not implement the seven-stage lifecycle.
- Global Search proves a bounded server-side capability/action pattern, but not a generic Tool runtime.

## Reconciled reuse strategy

E should reuse:
1. identity resolution;
2. SH/account ownership boundaries;
3. permission policy data;
4. existing audit persistence/function;
5. existing high-risk confirmation as a reference pattern;
6. Global Search as the first reference Tool/Action.

E should add only the smallest missing generic bridges required by evidence:
- invocation contract;
- generic authorization evaluation boundary;
- generic risk/confirmation decision boundary;
- execution eligibility;
- adapter contract;
- generic result/error envelope;
- lifecycle correlation.

No new registry, marketplace, or broad Tool ecosystem is justified by current evidence.

## First implementation candidate

Global Search remains the preferred first bounded reference slice, but implementation must wrap it behind the generic E contracts rather than modify its semantics to become the architecture.

Conceptual flow:

Caller → Invocation → Authorization → Risk/Confirmation → Eligibility → Global Search Adapter → Result/Error → Audit

For this read-oriented search Action, the risk/confirmation branch may be resolved by policy as non-confirmation-required; this is a design decision to be verified against the eventual Action policy, not an implementation assumption.

## Readiness change

The mapping pass closes a major ambiguity but does not authorize implementation.

E status:

**🟡 BOUNDED-DESIGN COMPLETE ENOUGH FOR CONTRACT FREEZE PREPARATION**

Implementation remains blocked until the next pass freezes:
- Action identity shape;
- authorization evaluator placement and inputs;
- risk/confirmation policy representation;
- execution eligibility record/contract;
- adapter interface;
- result/error envelope;
- audit correlation strategy.

No Supabase mutation was performed.

# CONTRACT FREEZE PREPARATION — 2026-08-29

## Purpose
Freeze the minimum generic contract boundary for Workstream E without implementing it.

## 1. Action Identity — proposed freeze
An Action is the atomic governed operation. It is identified by a stable, non-authoritative identifier:
action_id = <tool_id>.<action_name>
Optional versioning may be attached by the implementation contract, but versioning must not alter authority semantics.

An Action definition describes: action_id; human-readable name/description; input schema; output/result schema; declared risk class; required capability/context; target/resource semantics; execution mode; confirmation requirement policy reference.

A Tool groups Actions. A Capability describes what the Runtime may consider/request; it does not itself grant private-data access or execution permission.

## 2. Authorization evaluator — proposed freeze
Authorization belongs to the SH Runtime/governance boundary.

Input: authenticated actor/account; sh_id; Action identity; target/resource; requested scope; invocation context; applicable policy.

Output: ALLOW; DENY; ESCALATE; reason/code; policy reference; evaluation correlation.

Rules: server/runtime is authoritative; client only submits a request; Tool/adapter/provider never decides authorization; confirmation cannot override DENY; absence of a matching allow rule is DENY.

Existing permission_matrix is the policy foundation; E must not create a competing authority model.

## 3. Risk / confirmation policy — proposed freeze
Risk attaches to the Action, then is evaluated against context.
Minimum initial classes: LOW; HIGH.
Confirmation is required when resolved policy says so.
Generic conceptual state: NOT_REQUIRED | PENDING | CONFIRMED | REJECTED | EXPIRED.
Confirmation must bind to invocation/action/context and have freshness/expiry.
Existing recovery confirmation infrastructure is a reference implementation pattern, not the generic E contract.

## 4. Execution eligibility — proposed freeze
Runtime produces an execution-eligible request only after required gates pass.

Eligibility includes: invocation_id; actor/account; sh_id; action_id/tool_id; target; authorization decision; confirmation state when required; expiry/freshness; correlation id.

No eligible request may be produced from a DENY or an unmet required confirmation.

## 5. Adapter interface — proposed freeze
execute(eligible_request) -> raw_outcome

Adapter is the only controlled bridge to a concrete Tool implementation.
It may translate payloads and capture outcomes.
It may not authorize; change identity; change SH; broaden target/scope; select another Action; bypass confirmation; or become an authority.

## 6. Result / Error envelope — proposed freeze
Generic result: execution_id; invocation_id; tool_id; action_id; status; data; error; metadata; correlation_id; completed_at.
Statuses: SUCCEEDED | FAILED | REJECTED_BEFORE_EXECUTION | RESULT_UNAVAILABLE.
Errors are machine-classifiable and separate governance, confirmation/authorization, execution, availability, and normalization failures.
Tool output is untrusted data.

## 7. Audit correlation — proposed freeze
Every invocation carries one correlation identity through the lifecycle.
Minimum linkage: INVOCATION → AUTHORIZATION → RISK/CONFIRMATION → EXECUTION → RESULT.
Audit uses existing audit_events / runtime_record_audit() infrastructure.
E must not create a parallel audit authority.

## 8. Contract freeze conditions
The above is PROPOSED, not Canonical.
Freeze is blocked until reconciled against existing authority model; exact permission_matrix semantics; audit event schema; high-risk confirmation semantics; runtime entry points; and Global Search contract.

## 9. Hard boundary
E does not define plugin marketplace; autonomous unrestricted execution; Tool/provider authority; capability-as-private-data-permission; app-side authorization; or arbitrary model-to-tool execution.

## 10. Next reconciliation gate
Perform final source-level reconciliation of each proposed contract against actual DEV source/schema and SH Canonical.
Classify each as: FROZEN / REUSE-AS-IS / ADAPT / NEW-BRIDGE / BLOCKED.
No implementation is authorized by this document.

# FINAL SOURCE-LEVEL RECONCILIATION — 2026-08-29

## Authority reconciliation

Canonical review confirms the E boundary is compatible with the protected SH Core principles visible in the canonical architecture:
- Runtime access is not ownership.
- Creator/Core authority is not automatic private-data access.
- Private data is isolated by default.
- implementation-specific infrastructure may change without changing SH identity.
- governance and authority boundaries are protected; implementation mechanisms may evolve through controlled governance.

The Canonical documents do not define a generic Tool/Action execution contract. Therefore E may define an evolution-layer technical contract without claiming it is Canonical, provided it preserves those invariants.

Resume 69 is treated only as brainstorming/reference material. Its Tools/Plugins/Extensions discussion supports exploring a governed capability layer, but does not itself establish a requirement or authority.

ROADMAP defines E as Hands / Tools / Authority and explicitly requires capability identity, invocation, actor/SH context, authorization, risk classification, confirmation when required, execution, result normalization, and audit/event recording. It also explicitly requires separation of built-in Tools, Extensions/Plugins, and provider/model capabilities and forbids a broad plugin ecosystem before the authority/execution contract is stable.

## Seven-contract classification

| Contract | Final classification | Rationale |
|---|---|---|
| Action Identity | **ADAPT** | Needed as E technical contract; no Canonical generic Action identity found. Must remain non-authoritative. |
| Invocation | **NEW-BRIDGE** | Existing TOOL_INVOCATION audit evidence is useful, but no generic invocation boundary was verified. |
| Authorization | **ADAPT** | Reuse identity/ownership/permission foundations; add only generic evaluator boundary. |
| Risk / Confirmation | **ADAPT** | Reuse existing high-risk pattern, but do not generalize recovery-specific semantics without a bounded contract. |
| Execution Eligibility | **NEW-BRIDGE** | Existing Global Search gates are specialized; generic eligibility boundary not verified. |
| Adapter | **NEW-BRIDGE** | No generic adapter abstraction verified; Global Search RPC remains the reference concrete execution path. |
| Result / Error | **ADAPT** | Reuse Global Search normalized result pattern and existing error conventions; define generic envelope. |
| Audit / Trace | **ADAPT** | Reuse audit_events/runtime_record_audit(); define E lifecycle correlation and event mapping without new audit authority. |

## Canonical compatibility decision

**COMPATIBLE — NOT CANONICAL.**

The proposed E contract does not modify Canonical identity, ownership, privacy, authority, or governance principles. It operationalizes a bounded technical layer beneath those principles.

No Canonical document is changed by this pass.

## Final E boundary

E may define:
- governed Tool/Action contracts;
- runtime-side authorization boundary;
- risk/confirmation decision boundary;
- execution eligibility;
- controlled adapters;
- normalized results/errors;
- audit correlation;
- a bounded reference Tool implementation.

E may not redefine:
- SH identity;
- ownership;
- Creator/Core authority;
- private-data access semantics;
- Canonical governance;
- the App as an authorization authority.

E also does not authorize:
- unrestricted autonomous execution;
- marketplace/ecosystem;
- arbitrary plugin installation;
- provider/model authority;
- capability-as-private-data permission.

## Contract-freeze readiness

**🟢 READY FOR CONTRACT FREEZE**

This means the design boundary can now be frozen as an Evolution/technical contract.

It does NOT yet mean:
- implementation is complete;
- a generic Tool framework must be built;
- all future Tools are specified;
- Supabase schema changes are authorized.

## Next stage

After this freeze, the normal SH execution pattern applies:

1. Freeze E technical contract.
2. Produce implementation checklist/scope from the frozen contract.
3. Select one bounded reference vertical slice (Global Search is the current candidate).
4. Implement only the required bridge components.
5. Verify GitHub + Supabase DEV.
6. Android/runtime verification.
7. Reconcile evidence.
8. Close E only when the complete governed lifecycle is verified.

Until step 1 is formally accepted, no implementation mutation is authorized.


# CONTRACT FREEZE + IMPLEMENTATION CHECKLIST — 2026-08-29

## Freeze decision

The Workstream E bounded technical contract is now FROZEN AS AN EVOLUTION/TECHNICAL CONTRACT, subject to the Canonical compatibility boundary already reconciled above.

This freeze does not modify Canonical and does not authorize unrestricted Tool infrastructure.

## Frozen contract

1. Action Identity
   - Action is the atomic governed operation.
   - Stable identity: tool_id.action_name.
   - Action metadata declares input/output, target semantics, risk class, capability/context requirement, execution mode, and confirmation policy reference.
   - Action identity is descriptive/governed metadata, never authority.

2. Invocation
   - Runtime-governed request carrying actor/account, SH, Action, target/resource, input, provenance, and correlation identity.
   - Invocation requests execution; it does not authorize or execute.

3. Authorization
   - Runtime/governance evaluates the concrete Action in context.
   - Output: ALLOW | DENY | ESCALATE.
   - Existing identity, ownership, and permission_matrix semantics remain the foundation.
   - Client, Tool, adapter, provider, and model cannot authorize.

4. Risk / Confirmation
   - Risk resolves at Action + context.
   - Initial classes: LOW | HIGH.
   - Confirmation state: NOT_REQUIRED | PENDING | CONFIRMED | REJECTED | EXPIRED.
   - Required confirmation is bound to the intended invocation/action/context and freshness.
   - Existing recovery confirmation remains a pattern, not a generic authority.

5. Execution Eligibility
   - Runtime creates the eligible execution request only after all required gates pass.
   - Eligibility binds invocation, identity, SH, Action/Tool, target, authorization, confirmation when required, freshness, and correlation.
   - No eligible request from DENY or unmet required confirmation.

6. Adapter
   - Controlled bridge: eligible_request → raw_outcome.
   - No authorization, identity/SH substitution, scope broadening, Action substitution, or governance bypass.

7. Result / Error
   - Normalized envelope carries execution/invocation/tool/action identity, status, data, error, metadata, correlation, and completion time.
   - Status: SUCCEEDED | FAILED | REJECTED_BEFORE_EXECUTION | RESULT_UNAVAILABLE.
   - Tool output is untrusted data.

8. Audit / Trace
   - One correlation identity through the governed lifecycle.
   - Reuse audit_events / runtime_record_audit().
   - No parallel audit authority.

## Implementation checklist

### Work Preparation — pre-implementation verification
- [ ] Re-read frozen E contract.
- [ ] Verify exact existing permission_matrix semantics before touching authorization code.
- [ ] Verify exact Runtime entry point/caller for the first bounded slice.
- [ ] Verify current Global Search contract and preserve its behavior.
- [ ] Verify audit event schema and existing event vocabulary.
- [ ] Verify recovery confirmation boundary remains isolated.

### Contract-to-Implementation Mapping — minimal governance bridge
- [ ] Define the concrete invocation object/contract.
- [ ] Define Action identity for the reference slice.
- [ ] Map authorization inputs to existing identity/ownership/permission primitives.
- [ ] Define the generic authorization decision boundary.
- [ ] Define risk/confirmation decision without assuming every Action is HIGH.
- [ ] Define execution eligibility object/contract.
- [ ] Define adapter boundary around the concrete reference Tool.
- [ ] Define normalized result/error envelope.
- [ ] Map lifecycle correlation to existing audit infrastructure.

### First Bounded Reference Slice
Reference candidate: Global Search.

- [ ] Wrap existing Global Search behind the E governance boundary.
- [ ] Do not redesign Global Search semantics.
- [ ] Keep search read-only and bounded.
- [ ] Prove authorization before execution.
- [ ] Prove eligibility before adapter invocation.
- [ ] Prove normalized result/error handling.
- [ ] Prove audit correlation.
- [ ] Prove failure paths do not execute the Tool.

### Verification & Closure
- [ ] GitHub source verification.
- [ ] Supabase schema/function/policy verification.
- [ ] Runtime/Android verification.
- [ ] Evidence capture.
- [ ] Reconcile implementation against frozen contract.
- [ ] Record discrepancies; do not silently repair them.
- [ ] Close only after governed lifecycle is demonstrated end-to-end.

## Explicit non-scope

This implementation checklist does not authorize plugin marketplace/ecosystem, arbitrary plugin installation, unrestricted autonomous execution, provider/model authority, capability-as-private-data permission, app-side authorization, migration of existing recovery confirmation into a generic system, replacement of existing audit authority, or broad multi-Tool rollout before the reference slice is verified.

## Dependency order

Canonical + frozen E contract
→ existing authority/permission semantics
→ Runtime entry point
→ invocation
→ authorization
→ risk/confirmation
→ eligibility
→ adapter
→ result/error
→ audit
→ DEV verification
→ Android verification
→ E close

## Implementation gate

READY TO START IMPLEMENTATION PLANNING, NOT YET AUTHORIZED TO MUTATE DEV.

The next execution step is to inspect and document the exact source-level insertion points for Work Preparation and Contract-to-Implementation Mapping. Only after that bounded implementation plan is accepted should code or Supabase mutation begin.

# TOOL CANDIDATE AUDIT — EXTERNAL / NON-GITHUB SOURCES — 2026-08-29

## Scope
This pass is intentionally narrow: only candidate Tool/Action patterns that materially relate to the frozen E contract are retained. External material is reference input only; it does not become SH authority.

## Candidate shortlist

### T1 — Global Search
Status: SELECTED — reference implementation candidate.

Already exists in SH DEV and is the lowest-risk first slice because it is read-oriented, bounded, and already has runtime/server-side controls.

Why it fits E:
- clear invocation;
- bounded input/output;
- server-side authorization/ownership boundary;
- normalized result pattern;
- audit evidence;
- no inherent external side effect.

Next document: WORKSTREAM_E_TOOL_GLOBAL_SEARCH.md

### T2 — Read / Retrieve from an explicitly authorized connected source
Status: CANDIDATE — retain for later.

Pattern: a Tool retrieves information from a connected source under explicit scope.

Why it fits E:
- exercises Action identity;
- authorization is materially important;
- capability and private-data permission must remain distinct;
- result normalization and provenance matter.

Important boundary: a connection/capability must never be treated as blanket permission to read all private data.

### T3 — Create / Update an external record
Status: CANDIDATE — HIGH-RISK REFERENCE.

Pattern: create/update a ticket, task, note, calendar item, or similar external record.

Why it fits E:
- exercises write-side execution eligibility;
- naturally tests risk classification;
- provides a meaningful confirmation-gate test;
- requires strong target/scope binding and audit.

Not selected as first implementation because it introduces side effects before the read-only reference slice is verified.

### T4 — Human-confirmed sensitive Action
Status: CANDIDATE PATTERN — not a standalone Tool.

External research consistently treats human approval as a useful control for sensitive tool calls. MCP's current specification recommends a human-in-the-loop ability to deny tool invocations and clear confirmation for operations. citeturn0search4turn0search16

This maps directly to E's risk/confirmation contract, but does not justify importing an external approval product or protocol as SH architecture.

### T5 — MCP-compatible Tool/Server boundary
Status: REFERENCE PATTERN — DO NOT ADOPT AS E ARCHITECTURE.

Current MCP material provides useful patterns for tool discovery/listing, explicit tool invocation, authorization scopes, human approval, and separating host/client/server concerns. citeturn0search4turn0search5turn0search0

Useful lesson: Tool protocol is not SH authority.

MCP can inform an adapter/transport boundary later, but E must retain SH Runtime authorization and governance as the authority.

## Deferred candidates

Deliberately not retained as active E Tool candidates yet:
- broad plugin marketplace/ecosystem;
- arbitrary autonomous agents;
- unrestricted agent-to-agent execution;
- generic task orchestration;
- broad external connector marketplace.

Reason: they expand the system surface before the core governed Tool lifecycle is proven.

## External-source design signals worth carrying forward

1. Tool metadata can describe risk characteristics such as read-only, destructive, idempotent, or external side effects, but annotations are hints and should not become the authorization authority. citeturn0search10
2. Modern MCP authorization work emphasizes centralized policy and audit rather than leaving authorization fragmented across individual tools/connectors. citeturn0search2
3. Tool integrations commonly fall into simple API/plugin, MCP-style dynamic tool, or more complex agent-to-agent patterns; E should start with the simplest bounded integration pattern and only expand when the governance contract remains intact. citeturn0search1

## Current shortlist for SH

Keep active:
1. Global Search — first reference Tool.
2. Authorized Read/Retrieve — second candidate family.
3. External Record Create/Update — later write-side candidate.

Keep as architecture references, not Tools:
- MCP-style Tool boundary;
- human confirmation/approval pattern;
- risk annotations.

Do not expand now:
- marketplace/ecosystem;
- unrestricted autonomy;
- broad A2A/task orchestration.

## Decision rule for new candidates

A future candidate enters E only if it can be mapped to the frozen contract:

Action Identity → Invocation → Authorization → Risk/Confirmation → Eligibility → Adapter → Result/Error → Audit

and remains compatible with Canonical.

If a candidate requires changing the E contract, that is a contract-revision proposal, not an implementation shortcut.

## Document rule

Selected Tool candidates get their own bounded document:
WORKSTREAM_E_TOOL_<NAME>.md

The E master retains only:
- candidate/selected Tool name;
- status;
- rationale;
- dependency/blocker;
- link to Tool-specific document.

No Tool-specific implementation detail should be copied into the master unless it changes an E-wide contract or boundary.
