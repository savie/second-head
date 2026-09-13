# SECOND HEAD — Lifecycle Transition Capability Contract

## Status
WORKING CONTRACT — DESIGN GATE — NOT CANONICAL

## Purpose

Define the runtime/database capability contract required before implementing model-derived semantic lifecycle transitions.

This document does not change Canonical, Approved Contracts, schema, runtime behavior, grants, or migrations.

## Authority

Higher authority wins:

```text
OWNER / USER DECISION
→ CANONICAL
→ APPROVED CONTRACT
→ ARCHITECTURE / DESIGN
→ THIS WORKING CONTRACT
→ IMPLEMENTATION
→ RUNTIME / DATABASE EVIDENCE
→ E2E VERIFICATION
```

## 1. Core Rule

A semantic lifecycle transition is an **authorized state transition**, not a field update.

```text
REQUEST
→ AUTHENTICATE
→ RESOLVE ACTOR / ACCOUNT / SH
→ RESOLVE RECORD
→ VERIFY OWNERSHIP
→ VERIFY CURRENT LIFECYCLE
→ VERIFY POLICY
→ VERIFY TRANSITION AUTHORITY
→ APPLY ATOMIC CHANGE
→ PROJECT JOURNEY IF REQUIRED
→ RETURN OBSERVABLE RESULT
```

Model output never supplies transition authority by itself.

## 2. Transition Matrix

| Domain | CANDIDATE→ACTIVE | ACTIVE→UPDATE | ACTIVE→SUPERSEDE | Current evidence |
|---|---|---|---|---|
| Memory | dedicated transition required | domain-specific replacement exists | replacement exists via `superseded_by` | PARTIAL |
| Knowledge | dedicated transition required | not established | not established | OPEN |
| Experience | candidate state not established | not established | not established | OPEN |

`runtime_replace_memory` is a concrete Memory replacement operation, not a generic lifecycle engine.

## 3. CANDIDATE → ACTIVE

### Preconditions

All must pass:

- authenticated actor;
- current account resolved;
- target SH belongs to current account and is active;
- record belongs to target SH/account;
- record is currently `CANDIDATE`;
- semantic domain matches the requested transition;
- source authority is valid;
- decision outcome permits activation;
- confirmation authority is satisfied where required;
- scope/visibility are valid;
- transfer policy is valid;
- provenance is sufficient;
- idempotency key/correlation semantics are satisfied.

### Prohibited

- direct activation from model output;
- activation through Journey replay;
- activation by guessed record ID from another actor;
- activation of an already terminal/superseded record;
- activation merely because confidence is high;
- activation without required confirmation.

## 4. ACTIVE → UPDATE

An update must preserve:

- identity;
- account/SH ownership;
- domain type;
- lifecycle legality;
- provenance/history;
- scope/visibility policy;
- transfer policy unless an approved policy explicitly allows mutation;
- Journey linkage where required.

A mutation that destroys the historical value of the previous state should use versioning/supersession rather than silent overwrite where the domain contract requires history.

## 5. ACTIVE → SUPERSEDE

Supersession must:

1. authenticate and authorize the actor;
2. resolve exactly one valid current source record;
3. create or identify the successor;
4. preserve the old record as historical state;
5. establish `old.superseded_by = successor` or the domain-equivalent relationship;
6. preserve provenance;
7. prevent the old record from remaining falsely active/current;
8. project the lifecycle relationship to Journey where required;
9. be atomic or explicitly observable as incomplete.

## 6. Domain-Specific Rules

### Memory

Existing `runtime_replace_memory` is the current reference capability:

```text
current CANDIDATE/ACTIVE
→ new CANDIDATE
→ old UPDATED + superseded_by(new)
→ MEMORY Journey event
```

It must not be generalized into automatic activation of the new candidate.

### Knowledge

Existing candidate capture is supported. A future activation/update/supersession capability must be explicitly designed and authorized rather than implemented by direct table mutation.

### Experience

Current `runtime_record_experience` creates `ACTIVE`. A future candidate workflow requires an explicit contract decision first; do not infer candidate semantics from Memory/Knowledge.

## 7. Journey Contract

Journey is a projection/history boundary, not lifecycle authority.

A Journey event may reference a domain record, but replaying or editing the event must not manufacture lifecycle authority.

Where domain persistence and Journey projection are required to represent one logical operation, the transaction boundary must be explicit and verified.

## 8. Security Contract

Every transition must enforce:

```text
auth.uid()
→ current_account_id()
→ SH ownership
→ record ownership
→ lifecycle guard
→ policy guard
→ operation authority
```

Required negative tests:

- unauthenticated actor rejected;
- cross-account SH rejected;
- cross-actor record ID rejected;
- wrong lifecycle rejected;
- superseded record rejected;
- terminal SH rejected where applicable;
- invalid scope/visibility rejected;
- invalid transfer policy rejected;
- model-only authority rejected;
- Journey-only replay rejected.

## 9. Idempotency Contract

Before model-derived transitions are enabled, every externally retryable transition must define a stable logical operation key.

Minimum conceptual identity:

```text
actor/account + SH + domain + source_record + transition + decision/request correlation
```

Repeated execution of the same logical operation must not create duplicate successor records or duplicate lifecycle Journey events when the contract requires one operation.

Content matching alone is not sufficient proof of request-level idempotency.

## 10. Provenance Contract

A transition must be auditable to:

- actor/account;
- SH;
- source record;
- source signal;
- model/provider when applicable;
- decision;
- confirmation/authorization;
- transition;
- timestamp;
- resulting record;
- Journey event when applicable.

## 11. Failure Contract

No false success.

```text
DB mutation fails
→ operation fails
→ required Journey success is not claimed
```

If the domain write and Journey write are not transactionally atomic, the system must expose the intermediate state and recovery/reconciliation path.

## 12. Implementation Gate

Runtime/database implementation remains **CLOSED** until the following are evidenced on DEV:

1. confirmation authority;
2. candidate retrieval semantics;
3. transition API/function per domain;
4. idempotency/correlation mechanism;
5. provenance contract;
6. Journey transaction boundary;
7. authenticated positive E2E;
8. authenticated negative/cross-actor E2E;
9. transfer E2E where transition interacts with transfer policy.

## 13. Required Next Audit

Next engineering action is **Transition Capability Evidence Audit**, focused on actual callable behavior and grants for any proposed transition mechanism. No speculative migration or runtime implementation should be created until this audit closes the capability contract.

## 14. Decision

Current result:

```text
POLICY CONTRACT       = RECONCILED
RUNTIME CAPABILITY    = PARTIAL
TRANSITION CONTRACT   = DEFINED
IMPLEMENTATION GATE   = CLOSED
```
