# WORKSTREAM E5 — TOOL ADAPTER + RESULT CONTRACT

**Project:** SECOND HEAD V1.0  
**Workstream:** E5  
**Date:** 2026-08-29  
**Status:** BOUNDED DESIGN / RECONCILIATION COMPLETE  
**Implementation:** NOT AUTHORIZED

> Living evolution/design document. Not Canonical, not a migration/schema instruction, and not an implementation authorization.

## 1. Purpose
E5 audits the boundary between the governed Runtime execution request, a concrete Tool/adapter, and the result returned by that execution.
E5 does not build a Tool ecosystem, marketplace, plugin framework, or generic provider abstraction.

## 2. Authority and upstream dependency
E1: Capability / Tool / Action.
E2: Invocation / Authorization.
E3: Risk / Confirmation.
E4: Execution Boundary / Tool Invocation Runtime.
The existing governed sequence remains: PLAN → AUTHORIZATION → CONFIRMATION → EXECUTE → AUDIT.
E5 begins only after execution eligibility is established.

## 3. Evidence audit
GitHub: functions/runtime-p4a-001/sh_runtime_bundle.ts and the Runtime implementation establish an existing Runtime result path for model/conversation execution.
The repository contains no verified generic tool_result contract or generic Tool adapter implementation.
Supabase DEV runtime/high-risk/audit primitives provide governance and lifecycle evidence, but do not establish a generic Tool-result persistence contract.
Therefore existing infrastructure is foundation/evidence, not proof that E5 is already implemented.

## 4. Reclassification
| Area | Status | Finding |
|---|---|---|
| Runtime result path exists | 🟢 | Verified for existing model/runtime flow |
| Governed audit path exists | 🟢 | Existing foundation |
| Generic Tool adapter | 🔴 | Not evidenced |
| Generic Tool result contract | 🔴 | Not evidenced |
| Result normalization | 🟡 | Genuine design gap; scope must remain bounded |
| Provider abstraction | 🔴 | Not justified / out of scope |
| Plugin ecosystem | 🔴 | Out of scope |
| Result persistence as universal requirement | 🟡 | Depends on Action/result class |
| Error semantics | 🟡 | Needs bounded contract |
| Execution/result correlation | 🟡 | Required design gap |
| App-side Tool execution | 🔴 | Prohibited |

## 5. Core distinction
Execution Request ≠ Tool Execution ≠ Execution Result.
The request represents governed eligibility. The Tool/adapter performs the concrete operation. The result reports what happened.
A result cannot retroactively authorize an Action.

## 6. Tool adapter boundary
A Tool Adapter is the Runtime-controlled boundary that translates a governed execution request into the concrete invocation required by a specific Tool implementation.
Governed Execution Request → Tool Adapter → Concrete Tool → Raw Tool Outcome → Result Contract → Audit / downstream handling.
The adapter must not decide authorization, create authority, bypass confirmation, access unrelated SH-private data, or silently substitute another Action.

## 7. Adapter input contract
Semantic inputs retain execution/invocation identity, Tool identity, Action identity, actor/context, target, approved operation/input, execution eligibility, and correlation identity.
Exact envelope/field names remain implementation design.

## 8. Result contract
A governed result needs to distinguish execution status, result payload when available, failure/error information, execution/correlation identity, Tool/Action identity, and timing/lifecycle metadata sufficient for audit correlation.
The result is distinct from authorization, confirmation, and audit.

## 9. Result status
Minimum semantic outcome classes:
- SUCCEEDED
- FAILED
- REJECTED_BEFORE_EXECUTION
- RESULT_UNAVAILABLE
Exact enum names remain open.

## 10. Error boundary
Errors must preserve the distinction between authorization failure, confirmation failure/expiry, execution eligibility failure, Tool execution failure, and result interpretation/normalization failure.
The Tool adapter must not rewrite a governance failure as a Tool failure.

## 11. Normalization boundary
Result normalization is useful, but E5 does not freeze a universal schema for every Tool.
Bounded principle: Tool-specific outcome → governed result envelope → optional normalized representation.
Tool-specific payload may remain Tool-specific inside the governed envelope. This avoids forcing every future Tool into one premature data model.

## 12. Correlation
The lifecycle must permit: Invocation → Authorization → Risk → Confirmation → Execution → Result → Audit.
Execution and result require a stable correlation mechanism. Exact identifier/storage strategy remains open.

## 13. Retry / idempotency
The adapter boundary must not accidentally turn Runtime retries into duplicate side effects.
Concrete idempotency behavior is Action-specific. E5 therefore requires an explicit execution/correlation identity, while exact idempotency mechanism is deferred until concrete Action classes are audited.

## 14. Persistence boundary
Not every result must automatically become a permanent domain record.
Persistence depends on Action semantics, result sensitivity, audit requirements, and lifecycle needs.
The audit trail remains distinct from result storage. No migration is proposed by E5.

## 15. Built-in vs Extension/Plugin
Built-in Tools may use the same governed adapter boundary.
Extension/Plugin Tools, if later introduced, must enter through the same Runtime governance.
E5 does not define a plugin marketplace, discovery ecosystem, provider marketplace, or unrestricted extension runtime.

## 16. App / Model / Tool boundary
App and Model may request/propose work through governed Runtime.
Neither may directly invoke a privileged Tool.
Tool execution remains behind Runtime governance.
Tool output is untrusted result data until processed by governed Runtime.

## 17. Genuine gaps
1. Generic adapter interface.
2. Execution request envelope.
3. Result envelope.
4. Error taxonomy.
5. Execution/result correlation.
6. Bounded normalization rules.
7. Action-specific idempotency contract.

## 18. Out of scope
- Generic Tool registry.
- Plugin marketplace.
- Provider ecosystem.
- Autonomous unrestricted execution.
- App-side execution.
- Tool-side authorization.
- Universal result database schema.
- Migration.
- UI implementation.

## 19. Status
**E5 = 🟡 BOUNDED DESIGN ACCEPTED / IMPLEMENTATION BLOCKED**
The adapter/result boundary is sufficiently defined for downstream bounded design, but the generic physical contract is intentionally not frozen.
No implementation is authorized.

## 20. Next candidate
**E6 — Tool/Action Registry & Capability Binding**
E6 should be audited only after verifying whether registry/discovery/binding is actually required by the concrete V1.0 Tool slice. The earlier decision to defer registry remains in force until evidence proves the dependency.