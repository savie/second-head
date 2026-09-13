# SECOND HEAD — Full Semantic Lifecycle Verification — 2026-09-13

## Status

**WORKING — VERIFICATION RESULT / PARTIAL PASS / FULL LIFECYCLE NOT CLOSED**

This document records verification of the current semantic lifecycle across Memory, Knowledge, Experience, Journey, and lifecycle policy boundaries. It does not modify Canonical or Approved Contract authority.

## Authority

```text
OWNER / USER DECISION
        ↓
CANONICAL
        ↓
APPROVED CONTRACT
        ↓
ARCHITECTURE / DESIGN
        ↓
CURRENT IMPLEMENTATION
        ↓
RUNTIME / DATABASE EVIDENCE
        ↓
DEVICE / E2E EVIDENCE
```

## Scope

Verify the current end-to-end semantic chain:

```text
User / Model signal
    ↓
Semantic decision
    ↓
Domain persistence
    ↓
Journey projection
    ↓
Lifecycle / policy metadata
    ↓
Retrieval / transfer eligibility boundary
```

The verification explicitly includes Journey because Journey is the continuity/projection boundary and carries lifecycle-related visibility/transfer metadata.

## Evidence

### 1. Explicit user capture

Current DEV contains positive records produced by `ai-runtime:explicit-user-request`:

- Memory: 1 record
- Knowledge: 1 record
- Experience: 1 record
- Journey: 3 corresponding events

The Knowledge and Experience records are correlated to persisted user messages and runtime request IDs through the Conversation/runtime path.

### 2. Current semantic record state

For the tested SH:

| Domain | Lifecycle | Scope | Visibility | Transfer policy | Source |
|---|---|---|---|---|---|
| Memory | CANDIDATE | PRIVATE | OWNER_ONLY | NON_TRANSFERABLE | ai-runtime:explicit-user-request |
| Knowledge | CANDIDATE | PRIVATE | OWNER_ONLY | NON_TRANSFERABLE | ai-runtime:explicit-user-request |
| Experience | ACTIVE | PRIVATE | OWNER_ONLY | NON_TRANSFERABLE | ai-runtime:explicit-user-request |

This proves persistence and policy metadata exist, but does not by itself prove the complete lifecycle transition model.

### 3. Journey projection

Current DEV Journey events:

| Event | Domain reference | Continuity | Visibility | Transfer policy |
|---|---|---|---|---|
| MEMORY | memory_id present | CONTINUOUS | PRIVATE | NON_TRANSFERABLE |
| LEARNING | knowledge_id present | CONTINUOUS | PRIVATE | NON_TRANSFERABLE |
| EXPERIENCE | experience_id present | CONTINUOUS | PRIVATE | NON_TRANSFERABLE |

Journey therefore has deterministic references back to the semantic domain records for the tested capture path.

### 4. Journey policy boundary

Current runtime function `runtime_get_journey_record_policy(event_id)` resolves the event only when the event belongs to the current account's active SH, then resolves the domain record and returns its scope, visibility, and transfer policy.

Current `runtime_classify_journey_event()` enforces authenticated ownership and validates Journey visibility/transfer-policy vocabulary.

Current transfer implementation requires lifecycle-specific authorization and rejects selections that are private, non-transferable, or incompatible with the required lifecycle policy.

### 5. Lifecycle policy boundary

Current policy vocabulary for semantic records is:

```text
NON_TRANSFERABLE
INHERITANCE
SUCCESSION
LEGACY
```

`INHERITABLE` is normalized to `INHERITANCE` by the current policy function.

Current lifecycle safeguards include:

- deactivated/terminal SH cannot mutate record policy;
- inherited records cannot have their policy rewritten by the target SH;
- Succession requires an end-of-life/deactivated source SH and an active succession rule;
- Inheritance requires an approved inheritance authorization;
- Journey transfer requires explicit event selection and matching lifecycle eligibility;
- transferred Journey records are materialized as PRIVATE / NON_TRANSFERABLE on the target and retain source provenance.

## Verification Matrix

| Claim | Evidence | Result |
|---|---|---|
| Explicit Knowledge capture persists | DEV Knowledge row + runtime audit + user message correlation | PASS |
| Explicit Experience capture persists | DEV Experience row + runtime audit + user message correlation | PASS |
| Semantic capture projects to Journey | Knowledge/Experience/Memory Journey events reference domain IDs | PASS |
| Journey continuity is preserved | All tested semantic events are CONTINUOUS | PASS |
| Journey policy can be resolved through domain boundary | `runtime_get_journey_record_policy()` implementation + active DB definition | PASS (static/runtime-state verification) |
| Journey classification enforces owner/auth boundary | `runtime_classify_journey_event()` active DB definition | PASS (static verification) |
| Lifecycle transfer policy is enforced | active `runtime_transfer_selected_journey_events()` definition | PASS (static verification) |
| Model-derived semantic signal is persisted according to decision | Current runtime records signals/decisions but marks persistence `not_performed` | **NOT CLOSED** |
| Candidate → active/review lifecycle is fully verified for all domains | Current positive evidence does not cover complete transition matrix | **OPEN** |
| Full Knowledge lifecycle semantics | Capture/projection verified only | **OPEN** |
| Full Experience lifecycle semantics | Capture/projection verified only | **OPEN** |
| Full Journey + Clone/Inheritance/Succession execution E2E | Source/policy boundary exists, execution harness evidence incomplete | **OPEN** |

## Critical Finding

The current runtime has two distinct semantic paths:

### Explicit user path

```text
explicit user request
    ↓
recordExplicitSemanticLifecycle()
    ↓
Memory / Knowledge / Experience persistence
    ↓
Journey projection
```

This path is verified for positive capture/projection evidence.

### Model-derived signal path

```text
provider output
    ↓
<semantic_signals>
    ↓
signals()
    ↓
evaluateSemanticSignal()
    ↓
RUNTIME_MEMORY_DECISION audit
    ↓
persistence = not_performed
```

The current `semantic_decision.ts` explicitly treats model output as a candidate and keeps persistence authority outside the decision function. Therefore model-derived semantic persistence is **not** proven by the current implementation.

This is an implementation boundary finding, not a permission to redesign semantics in this verification pass.

## Decision

**Full Semantic Lifecycle Verification: PARTIAL PASS — NOT CLOSED.**

Closed for current tested scope:

```text
Explicit semantic capture
Knowledge persistence
Experience persistence
Memory tested persistence
Journey projection
Journey continuity
Journey policy metadata
Journey retrieval policy boundary
Lifecycle transfer-policy validation (static)
```

Still open:

```text
Model-derived signal → policy decision → persistence
Candidate → Active / Confirm / Reject lifecycle transitions
Full Knowledge lifecycle
Full Experience lifecycle
Journey Clone / Inheritance / Succession execution E2E
Security/succession semantic harness
```

## Scope Boundary

No database migration, Canonical change, or speculative semantic redesign is introduced by this verification.

The next implementation decision, if requested, must first define the approved contract for model-derived persistence and the lifecycle transition matrix before adding runtime behavior.

## Verification Principle

```text
DB state proves state.
Runtime audit proves execution path.
Journey correlation proves projection linkage.
Policy function inspection proves enforcement logic exists.
Only authenticated execution E2E can close the full security/lifecycle claim.
```
