# SECOND HEAD — WORKSTREAM E BOUNDED DESIGN v0.1
## Capability / Tool / Action / Authority Boundary
Date: 2026-08-29
Status: WORKING / NOT FROZEN

> Living Workstream E design document. Does not modify Canonical. Converts E0 audit findings into bounded design questions before implementation.

## 0. Design rule
Canonical -> Contract -> Existing DEV evidence -> Roadmap -> Resume/history -> bounded design -> implementation.
If DEV already has a compatible primitive, reuse it. If a gap is genuine, design it in E. If evidence is insufficient, keep it unresolved.

## 1. Evidence set
### 1.1 DEV implementation/runtime evidence
- identity and SH context resolution;
- ownership enforcement;
- authority assignment foundation;
- permission_matrix as governance/policy data;
- runtime security-definer boundary;
- audit persistence/caller path;
- recovery-specific high-risk confirmation lifecycle;
- confirmation event shape in application runtime.

### 1.2 Visual evidence supplied in this session
UI/navigation sheet:
- conversation-first center;
- contextual right panel: Journey, Memory, Knowledge, Experience;
- left navigation/sidebar;
- responsive desktop/tablet/mobile behavior;
- explicit Tools entry in composer;
- framing of SH as a second brain and hands.

Brand/identity sheet:
- Hybrid Concept C2 evolution family;
- infinity + human-abstract visual language;
- Brand Essence connects SH with second brain, second identity, second body, second soul, and infinite companion;
- primary/app/mockup applications consistently use the human/infinity SH mark.

### 1.3 Visual evidence interpretation
The visual evidence is design evidence, not Canonical authority.
The useful Hands signal is: conversation -> capability/tool access -> controlled action.
Tool access should therefore remain a capability surface of Runtime, not become a UI-first subsystem or separate product ecosystem.

### 1.4 Provisional logo direction
The strongest visual direction is the Hybrid Concept C2 / Essence-style human + infinity mark because it aligns with the stated Brand Essence and is already used consistently in primary/application mockups.
This is a provisional design preference only, not a frozen Canonical brand decision.

## 1.5 E0 re-audit correction — DEV/Supabase evidence

A second DEV/Supabase pass changes several earlier 🟡 classifications.

### Generic runtime access boundary — 🟢 existing

Supabase DEV contains `private.runtime_access_boundary(target_domain, target_sh_id, actor_account_id)`.

Verified behavior:
- resolves trusted auth identity;
- resolves ACCOUNT_ID;
- rejects caller-supplied account mismatch;
- classifies target SH as SYSTEM / SELF / OTHER;
- fails closed for OTHER;
- explicitly states runtime execution does not grant or transfer ownership;
- private-memory/private-conversation/private-context access to another SH requires an explicit scoped authorization source, which is not implemented in this function.

Therefore the generic **runtime access boundary** is already a foundation primitive.

It is **not** the same thing as a complete Tool/Action authorization evaluator.

### Permission matrix — 🟢 existing policy source

Supabase DEV contains `public.permission_matrix` with:
- actor;
- authority_domain;
- action;
- target_domain;
- target_sh;
- scope_conditions;
- decision.

The table comment states that static authorization rules use default DENY when no valid ALLOW rule matches.

Therefore the earlier wording "permission_matrix exists but generic authorization is not verified" is refined:

**Policy source exists and is verified.**

What remains unverified is a generic runtime evaluator that maps a Tool/Action invocation context into this matrix and returns the effective authorization decision.

### High-risk confirmation infrastructure — 🟡 / stronger than previously classified

Supabase DEV contains `runtime_high_risk_confirmations` and these functions:
- `runtime_create_high_risk_confirmation`
- `runtime_confirm_high_risk_action`
- `runtime_execute_high_risk_action`

The lifecycle is explicitly:
PENDING -> CONFIRMED -> EXECUTED, with CANCELLED/EXPIRED states.

The important boundary is that creation currently accepts only:
`RECOVERY_RESTORE`
and validates a recovery snapshot target.

Therefore:

**Generic confirmation state machine = 🟢 existing foundation**

**Generic high-risk Tool/Action confirmation contract = 🟡 design gap**

Do not rebuild the state machine blindly. Generalize only where the existing contract is semantically compatible.

### Audit infrastructure — 🟢 existing and Tool-aware

`runtime_record_audit` already accepts `TOOL_INVOCATION` and `RUNTIME_ACTION` event types in addition to runtime request/response and memory decision events.

Therefore the earlier statement that Tool/Action audit vocabulary was entirely missing is too strong.

Current result:

**Audit transport/persistence = 🟢**

**Generic Tool/Action lifecycle semantics = 🟡**

### Runtime execution — 🟢 bounded security foundation / 🟡 generic Tool execution

The DEV database already has runtime functions for high-risk execution and a private runtime access boundary.

This proves an execution/security pattern exists.

It does not prove a generic:
Tool -> Action -> authorization -> execution adapter
contract exists.

That generic layer remains a design target.

## 2. E bounded model
Candidate lifecycle:
Capability -> Tool -> Action -> Authorization Decision -> Risk -> Confirmation (if required) -> Execution -> Result -> Audit
This is a bounded-design model, not yet an implementation contract.

## 3. Capability
Capability describes what SH can potentially do.
Capability is not authority, permission, private-data access, confirmation, or execution.
Candidate relationship: Capability -> one or more Tools -> one or more Actions.
Open questions: canonical capability identity; lifecycle/versioning; ownership/provider metadata; enabled/disabled state; relationship to tool identity.
Do not create a database schema yet.

## 4. Tool
A Tool is a controlled interface through which Runtime invokes an external or operational capability.
Tool is not an authority, permission grant, or direct App-side execution path.
Minimum conceptual contract candidate: stable tool identity; declared capability; invocation contract; input boundary; output/result boundary; execution target/adapter; trust classification; availability state.
Open questions remain intentionally unresolved.

## 5. Action
An Action is a concrete operation/effect exposed through a Tool.
Example: Calendar Tool -> list events / create event / update event / delete event.
Each Action may have different authorization requirements, risk level, confirmation requirements, and execution semantics.
Permission should not be attached only at coarse Tool level.

## 6. Authorization
permission_matrix exists. Authority and ownership primitives exist. A generic permission evaluator was not verified after DB, RLS, function-security, grants, and runtime tracing.
Bounded target: Invocation Context -> Authorization Decision -> ALLOW / DENY.
Candidate context: actor; SH; capability; tool; action; target/resource; relevant context; requested permission.
Fields are candidates, not frozen schema.
Hard boundary: authorization remains outside the Tool. Tool cannot self-authorize. App/UI cannot become the authority. Capability existence cannot imply private-data permission.

## 7. Risk
Risk is separate from authorization.
Candidate logic: NOT AUTHORIZED -> DENY; AUTHORIZED + low/moderate risk -> eligible for execution; AUTHORIZED + high risk -> confirmation gate.
Exact taxonomy is not frozen.

## 8. Confirmation
Existing DEV confirmation infrastructure is real but recovery-specific.
Reusable: confirmation state lifecycle, backend security pattern, auditability pattern.
Not reusable as-is: RECOVERY_RESTORE semantics, recovery snapshot targeting, recovery restore execution.
E should define a generic confirmation contract only after risk semantics are bounded.

## 9. Execution boundary
Candidate boundary: App / Model intent -> Runtime -> Authorization -> Risk/Confirmation -> Tool Adapter -> Action execution.
App is not authority. Tool is not authority. Runtime remains orchestration/execution boundary.
Unrestricted autonomous execution is not a first-slice requirement.

## 10. Result
Tool output is external/untrusted result data.
Candidate flow: Action execution -> raw result -> normalization -> Runtime.
Normalization should establish a predictable SH-facing contract without treating external tool output as system instructions.
Exact result schema remains open.

## 11. Audit / event recording
Existing audit infrastructure should be reused.
Candidate lifecycle events for review: invocation_requested; authorization_decided; confirmation_requested; confirmation_received; execution_started; execution_succeeded; execution_failed; result_normalized.
This is candidate vocabulary, not a frozen schema.

## 12. Built-in vs Extension / Plugin
E should define the boundary between built-in Tools, Extensions/Plugins, and provider/model capabilities.
First slice should establish the contract boundary, not build a marketplace/ecosystem.
Plugin marketplace and broad third-party ecosystem are deferred.

## 13. What E may touch
- generic capability semantics;
- Tool contract;
- Action contract;
- authorization decision bridge;
- risk semantics;
- generic confirmation integration;
- Runtime execution boundary;
- result normalization;
- Tool/Action lifecycle audit;
- one meaningful vertical slice.

## 14. What E must not touch in first slice
- rewrite Canonical;
- make Tool an authority;
- make Capability a private-data permission;
- move authorization into App/UI;
- create unrestricted autonomous execution;
- build plugin marketplace;
- build broad extension ecosystem;
- introduce generic workflow/automation platform scope;
- perform provider migration merely for abstraction;
- duplicate existing identity/ownership/audit infrastructure without evidence.

## 15. Existing foundation reuse map
| Need | Existing foundation | Status |
|---|---|---|
| Actor identity | Runtime identity resolution | 🟢 |
| SH ownership | Existing ownership enforcement | 🟢 |
| Authority | Authority assignment foundation | 🟢 |
| Policy data | permission_matrix | 🟢 |
| Generic permission evaluator | Policy source verified; generic invocation evaluator not verified | 🟡 |
| Audit | Existing audit infrastructure + TOOL_INVOCATION/RUNTIME_ACTION event types | 🟢 |
| Confirmation pattern | Generic state machine exists; creation/execution constrained to RECOVERY_RESTORE | 🟡 reusable foundation, generic contract not frozen |
| Generic Tool | Not verified | 🟡 |
| Generic Action | Not verified | 🟡 |
| Generic execution lifecycle | Runtime execution/security patterns exist; generic Tool execution contract not verified | 🟡 |
| Result normalization | Not verified | 🟡 |

## 16. Proposed design work packages — NOT YET FROZEN
Do not create E1/E2/E3 implementation branches until dependencies are reviewed.
### E1 — Capability / Tool / Action + Authorization Contract
Define identities, relationships, invocation context, authorization decision semantics, and hard boundaries.
### E2 — Risk / Confirmation / Execution Contract
Define risk classification, confirmation requirement, Runtime execution boundary, and interaction with existing recovery/security patterns.
### E3 — Result / Audit / Trace Contract
Define normalized result semantics and lifecycle traceability.
### E4 — First meaningful Tool/Action vertical slice
Implement one bounded end-to-end example only after E1-E3 are accepted.
These labels are provisional.

## 17. Next review gate
1. Reconcile bounded design against Canonical/Contract line-by-line.
2. Validate every 🟡 item against current DEV again if necessary.
3. Review supplied visual evidence for UX implications only.
4. Freeze the minimum E contract.
5. Split E into implementation workstreams only after dependency order is clear.
6. Then implement and verify one vertical slice.

## 18. Current status
E0 — Existing Foundation Audit: RE-AUDITED / READY TO CLOSE
Bounded Design: IN PROGRESS
Implementation: NOT AUTHORIZED YET

The objective is a small, governed Hands capability layer — not a general-purpose plugin ecosystem or autonomous execution platform.