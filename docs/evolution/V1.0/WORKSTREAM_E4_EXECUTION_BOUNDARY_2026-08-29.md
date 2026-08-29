# WORKSTREAM E4 — EXECUTION BOUNDARY / TOOL INVOCATION RUNTIME

**Project:** SECOND HEAD V1.0  
**Workstream:** E4  
**Date:** 2026-08-29  
**Status:** BOUNDED DESIGN / RECONCILIATION COMPLETE  
**Implementation:** NOT AUTHORIZED

> Living evolution/design document. Not Canonical, not a migration/schema instruction, and not an implementation authorization.

## 1. Purpose

E4 defines the boundary at which an already-governed Action becomes eligible for actual execution through a Tool/runtime mechanism.

E4 is intentionally narrower than “build the Tool ecosystem”.

## 2. Authority basis

Canonical and implementation documents establish the governed sequence:

PLAN → AUTHORIZATION → CONFIRMATION → EXECUTE → AUDIT

E1 defines Capability / Tool / Action.
E2 defines Invocation / Authorization boundary.
E3 defines Risk / Confirmation boundary.

Therefore E4 begins only after those upstream gates.

## 3. Current DEV evidence

The existing functions/runtime-p4a-001/index.ts is a real Runtime implementation and is valuable evidence of the current execution boundary, but it is primarily a model/conversation runtime.

Verified behaviors include:

- authenticated identity resolution;
- SH identity resolution;
- Runtime-side RPC usage;
- Runtime-side audit recording;
- persistence through governed RPCs;
- model execution through executeModel;
- streamed response handling.

This implementation does not prove that a generic Tool/Action execution engine already exists.

The current source therefore establishes a Runtime orchestration foundation, not a completed E4 Tool executor.

## 4. Reclassification

| Area | Status | Finding |
|---|---|---|
| Runtime exists | 🟢 | Verified |
| Authenticated identity at Runtime | 🟢 | Verified |
| SH context resolution | 🟢 | Verified |
| Runtime-side governed RPCs | 🟢 | Verified |
| Runtime audit recording | 🟢 | Verified |
| Model execution path | 🟢 | Existing, but not generic Tool execution |
| Generic Tool invocation | 🔴 | Not evidenced |
| Generic Action executor | 🔴 | Not evidenced |
| Tool adapter contract | 🟡 | Design gap |
| Execution eligibility handoff | 🟡 | Needs explicit contract |
| Execution result contract | 🟡 | Needs bounded design |
| Result normalization | 🟡 | Not yet justified as separate subsystem |
| External provider/plugin ecosystem | 🔴 | Out of scope |
| Autonomous unrestricted execution | 🔴 | Prohibited |

## 5. E4 execution boundary

Accepted semantic sequence:

Invocation
↓
Authorization
↓
Risk / Confirmation
↓
Execution Eligibility
↓
Tool Invocation
↓
Action Execution
↓
Result
↓
Audit

The critical boundary is:

Authorization/confirmation establishes eligibility; it does not itself execute.

A Tool must not be callable merely because it is registered, available, or described by a Capability.

## 6. Execution eligibility

E4 requires an explicit execution-eligibility transition.

Conceptually, downstream execution must receive evidence that:

- the Invocation is identified;
- the Action is identified;
- authorization has succeeded;
- required risk handling is complete;
- required confirmation has succeeded;
- the target/context is still bound to the approved operation;
- the request has not expired or been substituted.

Exact token/record/schema remains OPEN.

## 7. Tool invocation contract

A future Tool invocation boundary needs, at minimum, semantic inputs for:

- Invocation identity;
- Tool identity;
- Action identity;
- actor/context;
- target;
- approved operation;
- execution eligibility;
- correlation identity.

It must return a governed result rather than arbitrary uncontrolled side effects.

Exact envelope and serialization are implementation design and remain OPEN.

## 8. Tool ≠ authority

Execution cannot be delegated in a way that lets the Tool decide whether the Action is allowed.

The Tool receives an already-governed execution request.

Therefore:

Tool availability ≠ permission  
Tool capability ≠ authorization  
Tool result ≠ authority

## 9. Execution isolation

E4 must keep external side effects behind Runtime governance.

The App must not directly execute privileged Tools.

The Model must not directly execute privileged Tools.

A Tool must not bypass Runtime governance to access SH-private state or perform a governed Action.

## 10. Result boundary

Execution produces a result that must remain distinguishable from:

- authorization decision;
- confirmation state;
- audit event.

Conceptually:

Execution Result
↓
Result interpretation / normalization
↓
Audit / persistence / presentation

E4 does not yet freeze a universal normalized result schema.

## 11. Failure boundary

Execution failures must not be represented as successful authorization.

At minimum, the eventual contract must distinguish:

- authorization denied;
- confirmation missing/expired;
- execution not eligible;
- execution attempted and failed;
- execution succeeded;
- result unavailable/invalid.

Exact error taxonomy remains OPEN.

## 12. Idempotency / replay boundary

Because Actions may produce effects, E4 must prevent an approved operation from unintentionally executing multiple times through retries/replay.

The eventual execution contract therefore needs an execution/correlation identity and explicit retry/idempotency semantics appropriate to the Action.

Exact mechanism remains OPEN until concrete Action classes are audited.

## 13. Existing Runtime foundation boundary

runtime-p4a-001 demonstrates that Runtime already owns:

- identity resolution;
- SH context;
- model invocation;
- persistence;
- audit.

E4 should build on this Runtime boundary rather than introducing an App-side executor.

However, the existing model execution path must not be silently reclassified as the generic Tool execution engine.

## 14. Registry decision

No generic Tool registry is required to define the E4 execution boundary.

Registry remains deferred until a concrete Tool discovery/invocation requirement proves it necessary.

## 15. What E4 does NOT include

- plugin marketplace/ecosystem;
- unrestricted autonomous execution;
- App-side privileged execution;
- Model-side privileged execution;
- Tool-side authorization;
- generic provider marketplace;
- forced universal result schema;
- migration/schema implementation.

## 16. Genuine gaps

E4 has real implementation/design gaps:

1. generic Tool invocation envelope;
2. execution eligibility contract;
3. Tool adapter boundary;
4. execution result contract;
5. failure/error semantics;
6. replay/idempotency semantics;
7. concrete Action execution lifecycle.

These are not assumed to be solved by existing Runtime code.

## 17. E4 status

**E4 = 🟡 BOUNDED DESIGN ACCEPTED, IMPLEMENTATION BLOCKED**

The boundary is sufficiently clear to proceed to the next bounded design, but the generic execution contract remains intentionally OPEN.

This is not implementation authorization.

## 18. Next candidate

**E5 — Tool Adapter + Result Contract**

E5 should determine whether adapter and result normalization belong together, using a concrete first Action as the test case rather than designing an abstract ecosystem prematurely.

