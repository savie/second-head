# SECOND HEAD — Semantic Lifecycle Policy Contract

## Status

**WORKING CONTRACT DRAFT — POLICY GATE — NOT CANONICAL**

This document defines the proposed policy boundary required before implementing or extending model-derived semantic persistence and lifecycle transitions.

It is a working engineering contract. It does **not** modify Canonical authority, Approved Contract authority, database schema, runtime behavior, or existing lifecycle semantics.

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
THIS WORKING POLICY CONTRACT
        ↓
IMPLEMENTATION
        ↓
RUNTIME / DATABASE EVIDENCE
        ↓
E2E VERIFICATION
```

If this document conflicts with Canonical or an Approved Contract, the higher-authority source wins and this document must be reconciled rather than silently merged.

## 1. Purpose

Close the policy-definition gap identified by the Full Semantic Lifecycle Verification checkpoint.

The contract establishes one explicit decision boundary for:

```text
MODEL SIGNAL
    ↓
CANDIDATE
    ↓
REJECT / CONFIRM / ACCEPT
    ↓
PERSISTENCE ELIGIBILITY
    ↓
LIFECYCLE STATE
    ↓
JOURNEY PROJECTION
    ↓
VISIBILITY / CONTINUITY / TRANSFER POLICY
    ↓
TRANSFER ELIGIBILITY
```

The contract deliberately separates:

- semantic inference from persistence authority;
- candidate creation from lifecycle activation;
- domain persistence from Journey projection;
- lifecycle state from transfer policy;
- policy eligibility from transfer execution.

## 2. Current Evidence Baseline

The current DEV implementation already has a separate semantic decision function. `evaluateSemanticSignal()` accepts a `SemanticSignal` and returns `ACCEPT`, `REJECT`, or `CONFIRM`; model output is explicitly treated as a candidate and persistence authority remains outside that function.

The explicit-user path currently persists Memory, Knowledge, and Experience through database runtime functions and projects the tested records into Journey. The existing verification record classifies that path as PASS while leaving model-derived persistence and full lifecycle transitions OPEN.

Current database state also contains lifecycle and transfer-policy fields on Memory, Knowledge, Experience, and Journey records. Existing transfer functions enforce lifecycle-specific eligibility, but full Clone / Inheritance / Succession execution remains an E2E verification gap.

Therefore this document defines policy before implementation rather than assuming the current implementation already satisfies the full contract.

## 3. Non-Goals

This contract does not:

- redesign semantic domain definitions;
- introduce a new semantic domain;
- create a new persistent table;
- create or alter a database migration;
- change existing Journey continuity semantics;
- authorize model output to write directly to durable memory;
- change Canonical documents;
- define provider-specific prompting;
- define UI confirmation mechanics;
- claim that model-derived persistence is currently implemented.

## 4. Core Principles

### 4.1 Model output is not persistence authority

A model-generated signal is an inference candidate. It cannot directly create, mutate, activate, transfer, or supersede durable semantic records.

```text
MODEL
  ≠
AUTHORITY
```

### 4.2 Decision is policy input, not proof of persistence

`ACCEPT`, `REJECT`, and `CONFIRM` are decision outcomes. A decision is not itself a durable state transition.

Persistence requires a separate authorized policy evaluation that considers identity, ownership, domain, lifecycle state, scope, visibility, transfer policy, provenance, and any required confirmation rule.

### 4.3 User explicitness has higher capture authority than model inference

An explicit user request to persist semantic information may enter the persistence path according to the applicable domain contract.

A model-derived signal may propose persistence, but cannot upgrade itself to explicit user authority.

### 4.4 Lifecycle and Journey remain coupled at the policy boundary

Every durable semantic record that is projected into Journey must preserve the domain-owned lifecycle and policy boundary. Journey must not become an alternate authority for semantic ownership or lifecycle state.

### 4.5 Transfer is a separate authorization boundary

A record being persistent, active, or represented in Journey does not imply transfer eligibility.

```text
PERSISTED
   ≠
TRANSFERABLE
```

## 5. Semantic Signal Contract

A semantic signal consists conceptually of:

| Field | Meaning | Authority |
|---|---|---|
| domain | MEMORY / KNOWLEDGE / EXPERIENCE / JOURNEY | classifier output; validated against supported domains |
| confidence | model/classifier confidence | evidence only; never sole authorization |
| evidence | supporting model evidence | provenance/audit input |
| source | MODEL or USER | security/policy discriminator |

### 5.1 MODEL source

`MODEL` means the signal originated from model/provider output or model-derived semantic extraction.

Required rule:

```text
MODEL signal
    ↓
CANDIDATE
    ↓
policy evaluation
```

It must not bypass policy because confidence is high.

### 5.2 USER source

`USER` means the signal originated from an explicit user action/request recognized by the approved capture contract.

User source does not automatically authorize every operation. Ownership, authentication, domain rules, and lifecycle policy still apply.

## 6. Decision Contract

The current decision vocabulary remains:

```text
ACCEPT
REJECT
CONFIRM
```

This contract does not redefine their current function implementation; it defines their required downstream semantics.

### ACCEPT

Means the signal satisfies the applicable acceptance policy for the current authority context.

Required downstream interpretation:

```text
ACCEPT
  → eligible for persistence evaluation
  → does not by itself prove persistence
```

### REJECT

Means the candidate must not become a durable semantic record through this decision path.

Required downstream interpretation:

```text
REJECT
  → no semantic persistence
  → no lifecycle activation
  → no durable Journey projection for the rejected candidate
```

An audit record may still exist where the existing runtime audit contract permits it.

### CONFIRM

Means the candidate requires an explicit confirmation boundary before durable persistence, unless a higher-authority approved contract explicitly defines an equivalent authorization path.

Default working rule:

```text
CONFIRM
  → candidate remains non-active
  → no durable semantic activation
  → await explicit confirmation
```

No automatic persistence is implied by `CONFIRM`.

## 7. Persistence Eligibility

Durable semantic persistence requires all applicable gates to pass:

```text
Authenticated actor
      ↓
Resolved account / SH ownership
      ↓
Supported semantic domain
      ↓
Valid source authority
      ↓
Decision allows persistence
      ↓
Lifecycle transition is legal
      ↓
Scope / visibility are valid
      ↓
Transfer policy is valid
      ↓
Provenance is recorded
      ↓
Persist domain record
      ↓
Project Journey when contractually required
```

A failed gate is a real failure or rejection, not a successful persistence with degraded metadata.

## 8. Candidate State

`CANDIDATE` is a durable lifecycle state only where the domain implementation already supports it or an approved contract explicitly authorizes candidate persistence.

Candidate means:

- discovered or captured but not fully activated;
- not equivalent to trusted active semantic context;
- not automatically retrievable as authoritative durable context;
- not automatically transferable;
- not eligible to mutate lifecycle policy merely because it exists.

A candidate must preserve provenance sufficient to explain how it was created and why it has its current state.

## 9. Lifecycle State Model

The working lifecycle model is:

```text
                ┌──────────────┐
                │   CANDIDATE  │
                └──────┬───────┘
                       │
             ┌─────────┴─────────┐
             │                   │
          REJECT              ACCEPT / CONFIRM
             │                   │
             ▼                   ▼
         TERMINAL          policy evaluation
                                 │
                                 ▼
                              ACTIVE
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                 UPDATE                  SUPERSEDE
                    │                         │
                    └────────────┬────────────┘
                                 ▼
                         current / successor
                                 │
                                 ▼
                       LEGACY / EOL boundary
                                 │
                    ┌────────────┼────────────┐
                    ▼            ▼            ▼
                  CLONE      INHERITANCE   SUCCESSION
```

This is a policy model, not evidence that every transition is currently implemented.

### 9.1 CANDIDATE → ACTIVE

Allowed only through a domain-authorized transition.

A model `ACCEPT` must not be treated as an unconditional `ACTIVE` write.

A `CONFIRM` outcome requires the defined confirmation authority before activation.

### 9.2 CANDIDATE → REJECT / terminal

A rejected candidate must not become active through retry, Journey replay, or transfer.

### 9.3 ACTIVE → UPDATE

Updates must preserve ownership, provenance, lifecycle legality, and semantic domain integrity.

### 9.4 ACTIVE → SUPERSEDE

Supersession must preserve the relationship between old and new records and must not silently delete historical provenance.

Existing `superseded_by` fields are evidence that this concept exists in the current schema; complete cross-domain transition behavior remains a verification target.

### 9.5 LEGACY / EOL

Legacy/end-of-life is a lifecycle boundary, not merely a visibility flag.

A terminal source lifecycle may be a prerequisite for Succession according to the existing transfer policy.

## 10. Domain Policy Matrix

The following matrix is the minimum working policy boundary. Exact domain-specific values remain subject to the existing domain contracts and runtime implementation.

| Domain | Model signal may propose | Default model outcome | Durable activation requirement | Journey |
|---|---|---|---|---|
| MEMORY | yes | CONFIRM unless accepted by explicit policy | authorized persistence + lifecycle transition | when required by domain contract |
| KNOWLEDGE | yes | CONFIRM unless accepted by explicit policy | authorized persistence + lifecycle transition | when required by domain contract |
| EXPERIENCE | yes | CONFIRM | explicit confirmation or higher-authority equivalent | when required by domain contract |
| JOURNEY | no independent durable semantic authority | N/A | domain-owned projection only | projection/history boundary |

The table does not authorize implementation by itself.

## 11. Journey Projection Contract

Journey is a projection/continuity boundary for semantic lifecycle events.

For a durable semantic event that requires Journey projection:

```text
Domain record
   ↓
validated domain identity
   ↓
Journey event
```

The Journey event must retain or resolve:

- owning account;
- owning SH/context;
- domain;
- source record ID;
- continuity status;
- visibility;
- transfer policy;
- provenance;
- event type.

Journey must not be used to manufacture an active semantic record from a rejected or unconfirmed candidate.

## 12. Visibility / Scope Policy

Visibility and scope are independent from lifecycle state.

The minimum policy boundary remains:

```text
scope
visibility
lifecycle
transfer_policy
provenance
```

A record cannot gain transfer eligibility merely by changing visibility, and cannot gain ownership merely by being present in Journey.

## 13. Transfer Policy Contract

Existing policy vocabulary observed in DEV is:

```text
NON_TRANSFERABLE
INHERITANCE
SUCCESSION
LEGACY
```

`INHERITABLE` normalization to `INHERITANCE` is an implementation detail already observed in the current policy boundary; it is not expanded here into a new vocabulary.

### 13.1 NON_TRANSFERABLE

The record/event cannot be selected for lifecycle transfer.

### 13.2 INHERITANCE

Transfer is permitted only when the applicable inheritance authorization and source/target eligibility rules pass.

### 13.3 SUCCESSION

Transfer is permitted only when the applicable source end-of-life/deactivated and succession authorization requirements pass.

### 13.4 LEGACY

Indicates a lifecycle boundary requiring the applicable legacy semantics. It does not automatically mean transferable.

## 14. Transfer Operations

The existing conceptual operations are:

```text
CLONE
INHERITANCE
SUCCESSION
```

For every operation:

```text
authenticate
  ↓
resolve source / target identity
  ↓
verify ownership / authority
  ↓
resolve domain record from Journey event
  ↓
validate lifecycle
  ↓
validate visibility
  ↓
validate transfer policy
  ↓
validate operation-specific eligibility
  ↓
materialize target record/event
  ↓
retain source provenance
  ↓
verify target isolation
```

A rejected transfer must not create a partial successful target record.

## 15. Negative Security Requirements

The policy contract is incomplete unless the following negative cases are explicitly verified:

1. Model output cannot directly persist durable semantic state.
2. Rejected candidates cannot become active through Journey.
3. Unconfirmed candidates cannot become active without the required authority.
4. A user cannot transfer another actor's semantic record by guessing a record ID.
5. A target SH cannot rewrite the lifecycle policy of an inherited record unless the approved contract explicitly permits it.
6. Private / non-transferable records are rejected by transfer selection.
7. A deactivated/terminal SH cannot mutate lifecycle policy where current policy forbids it.
8. Succession cannot occur without source end-of-life and succession eligibility.
9. Cross-account Journey events cannot be resolved as owned records.
10. Failed persistence or transfer must not emit false success.

## 16. Atomicity / Failure Contract

Semantic persistence and Journey projection should be treated as one logical operation where the existing database contract provides transactional atomicity.

If the domain record is persisted but required Journey projection fails, the system must surface the operation as incomplete/failure according to the actual transaction boundary; it must not claim full lifecycle success.

If Journey is intentionally asynchronous in a future approved design, that asynchronous state must be explicit and observable rather than represented as completed lifecycle state.

## 17. Idempotency / Retry Contract

Model-derived persistence must define idempotency before implementation.

Repeated processing of the same signal/request must not silently create duplicate semantic records or duplicate Journey events when the contract requires one logical capture.

The implementation decision must identify the idempotency key or equivalent correlation boundary before runtime rollout.

## 18. Provenance Contract

Every model-derived durable semantic record must preserve enough provenance to answer:

```text
Who / what produced the signal?
Which runtime request produced it?
Which model/provider path produced it?
What evidence supported it?
Which decision was made?
Which authorization/confirmation allowed persistence?
When was it persisted?
What Journey event represents it?
```

Exact field names are implementation concerns and must be reconciled with the existing schema before coding.

## 19. Audit Contract

Decision audit and semantic persistence are separate concerns.

Minimum conceptual audit states:

```text
SIGNAL_RECEIVED
DECISION_REJECT
DECISION_CONFIRM
DECISION_ACCEPT
PERSISTENCE_ELIGIBLE
PERSISTED
PERSISTENCE_REJECTED
JOURNEY_PROJECTED
JOURNEY_PROJECTION_FAILED
TRANSFER_ELIGIBLE
TRANSFER_REJECTED
TRANSFER_COMPLETED
```

The existing runtime audit vocabulary must be inspected and reconciled before introducing any new audit values.

## 20. Implementation Boundary

No runtime or database implementation should begin until the following are resolved against actual DEV state:

- whether candidate rows are intentionally durable for each domain;
- exact lifecycle transition functions available per domain;
- exact confirmation authority and UX/runtime boundary;
- idempotency/correlation mechanism;
- model/provider provenance fields;
- Journey projection transaction boundary;
- retrieval treatment of CANDIDATE records;
- exact transfer behavior for Clone / Inheritance / Succession;
- negative security test harness.

## 21. Verification Matrix

| Gate | Expected | Evidence required | Current status |
|---|---|---|---|
| Model signal classification | MODEL remains candidate | runtime unit/static evidence | EXISTING |
| REJECT | no durable activation | runtime + DB negative test | OPEN |
| CONFIRM | explicit confirmation boundary | runtime + E2E | OPEN |
| ACCEPT | persistence eligibility evaluated | runtime + DB | OPEN |
| Candidate persistence | only where domain contract permits | DB + contract reconciliation | OPEN |
| Candidate → Active | legal transition only | authenticated E2E | OPEN |
| Active update | ownership/lifecycle preserved | authenticated E2E | OPEN |
| Supersession | provenance preserved | DB + E2E | OPEN |
| Journey projection | domain linkage preserved | DB + runtime E2E | PARTIAL PASS |
| Journey visibility | enforced | negative E2E | PARTIAL PASS |
| Transfer eligibility | lifecycle/policy enforced | DB/static + E2E | PARTIAL PASS |
| Clone | authorized execution | authenticated E2E | OPEN |
| Inheritance | authorized execution | authenticated E2E | OPEN |
| Succession | authorized execution | authenticated E2E | OPEN |
| Cross-actor isolation | unauthorized access rejected | security E2E | OPEN |
| Idempotent retry | duplicate logical capture prevented | runtime + DB E2E | OPEN |

## 22. Definition of Done for This Policy Gate

This policy gate is considered closed only when:

1. The contract is reconciled against Canonical/Approved Contract authority.
2. Domain-specific lifecycle transition semantics are explicitly identified.
3. Model-derived persistence authority is explicitly defined.
4. `REJECT`, `CONFIRM`, and `ACCEPT` have unambiguous downstream behavior.
5. Candidate retrieval semantics are defined.
6. Journey projection semantics are defined for each durable domain transition.
7. Transfer eligibility remains separated from persistence eligibility.
8. Negative security requirements are mapped to executable tests.
9. Idempotency and failure/atomicity boundaries are defined.
10. No unresolved contradiction remains between policy, runtime, and current DB state.

## 23. Next Gate

Do **not** create a migration or change runtime behavior solely from this draft.

The next engineering step is **Policy Reconciliation Audit**:

```text
THIS WORKING POLICY
        ↓
CANONICAL / APPROVED CONTRACT CHECK
        ↓
CURRENT RUNTIME CHECK
        ↓
CURRENT DATABASE FUNCTION CHECK
        ↓
CURRENT DATA STATE CHECK
        ↓
CONFLICT / GAP REGISTER
        ↓
APPROVED IMPLEMENTATION PLAN
```

Only after that reconciliation should implementation be proposed.

## 24. Current Conclusion

```text
SEMANTIC LIFECYCLE POLICY
        │
        ├── Explicit user capture → EXISTING / VERIFIED PATH
        │
        ├── Model signal → candidate → decision → persistence → OPEN
        │
        ├── Candidate → Active → OPEN
        │
        ├── Journey projection → EXISTING / PARTIAL VERIFIED
        │
        └── Transfer eligibility → EXISTING POLICY / E2E OPEN
```

**Conclusion: POLICY GATE DRAFTED — IMPLEMENTATION NOT AUTHORIZED BY THIS DOCUMENT ALONE.**
