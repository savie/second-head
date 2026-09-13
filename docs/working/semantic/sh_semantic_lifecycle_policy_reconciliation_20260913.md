# SECOND HEAD — Semantic Lifecycle Policy Reconciliation — 2026-09-13

## Status

**WORKING — POLICY RECONCILIATION RESULT / PARTIAL PASS / IMPLEMENTATION GATE NOT CLOSED**

This record reconciles the working Semantic Lifecycle Policy Contract against the current DEV Canonical baseline, runtime implementation, migration history, and current Supabase database function/schema surface.

No Canonical document, approved contract, runtime code, or database migration is changed by this record.

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
WORKING POLICY CONTRACT
        ↓
CURRENT IMPLEMENTATION
        ↓
RUNTIME / DATABASE EVIDENCE
        ↓
E2E VERIFICATION
```

Higher authority wins. No conflict is silently merged.

## 1. Reconciliation Scope

Target policy chain:

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
POLICY
    ↓
TRANSFER ELIGIBILITY
```

Sources inspected:

- `docs/working/semantic/sh_semantic_lifecycle_policy_contract.md`
- `docs/working/semantic/sh_full_semantic_lifecycle_verification_20260913.md`
- `docs/canonical/sh_foundation_blueprint.md`
- `functions/ai-runtime/semantic_decision.ts`
- `functions/ai-runtime/semantic_lifecycle.ts`
- lifecycle/transfer migration history
- current DEV Supabase function and schema surface

## 2. Reconciliation Findings

### 2.1 Model is not authority

**Status: RECONCILED / PASS**

Canonical foundation explicitly separates Model from SH Identity and states `Model ≠ Authority`. It also establishes privacy default-deny and explicit authorization for sharing.

The current semantic decision implementation follows the same boundary: model output is a candidate and `evaluateSemanticSignal()` only returns `ACCEPT`, `REJECT`, or `CONFIRM`.

No evidence was found that model output is intended to directly become durable semantic authority.

### 2.2 Explicit user capture authority

**Status: RECONCILED / PASS for existing tested path**

The existing explicit capture runtime uses domain-specific persistence functions for Memory, Knowledge, and Experience and Journey projection.

This is consistent with the working policy principle that explicit user capture has higher capture authority than model inference, while ownership and domain authorization still apply.

### 2.3 Candidate semantics

**Status: PARTIAL / OPEN**

`CANDIDATE` exists in the current database lifecycle vocabulary and is used by current semantic capture and transfer code.

However, current transfer implementations may materialize a source `CANDIDATE` as `ACTIVE` on authorized target operations. Therefore `CANDIDATE → ACTIVE` is not a generic universal transition contract; it is operation/domain specific.

The policy contract must not be interpreted as authorizing a new universal activation function.

### 2.4 Existing transfer lifecycle semantics

**Status: EXISTING / PARTIALLY VERIFIED**

Migration history demonstrates explicit lifecycle behavior for Clone, Inheritance, and Succession. Existing implementation promotes transferred candidate rows to active target rows in relevant transfer operations and preserves provenance.

This confirms that lifecycle transfer is already a real database behavior, not merely a conceptual design.

Full authenticated E2E execution remains OPEN.

### 2.5 Journey as projection boundary

**Status: RECONCILED / PASS for tested path**

Current Journey records contain domain linkage and policy metadata. The current policy resolver resolves the domain record through the current account/SH ownership boundary.

Journey therefore remains a projection/continuity boundary rather than an independent semantic ownership authority.

### 2.6 Transfer policy vocabulary

**Status: RECONCILED / PASS**

Current DEV evidence supports:

```text
NON_TRANSFERABLE
INHERITANCE / INHERITABLE normalization
SUCCESSION
LEGACY
```

The working contract does not introduce a new transfer vocabulary.

### 2.7 Model-derived persistence

**Status: OPEN / IMPLEMENTATION GAP**

The current model-derived path reaches semantic decision/audit but current verification evidence does not prove durable persistence following `ACCEPT` or `CONFIRM`.

The policy contract correctly keeps this boundary closed pending an implementation decision.

### 2.8 Confirmation authority

**Status: UNKNOWN / EVIDENCE GAP**

The policy contract requires explicit confirmation for `CONFIRM` by default, but the current repository evidence inspected here does not establish the complete user/runtime confirmation mechanism.

No runtime implementation is authorized from this gap alone.

### 2.9 Idempotency

**Status: OPEN / EVIDENCE GAP**

The policy contract requires duplicate logical semantic capture to be controlled, but the current inspected evidence does not establish a complete model-signal idempotency key and enforcement path.

This must be resolved before model-derived persistence implementation.

### 2.10 Candidate retrieval semantics

**Status: OPEN / EVIDENCE GAP**

The policy contract states that candidates are not automatically authoritative durable context. Current repository/database evidence inspected in this gate does not yet prove the complete retrieval exclusion/inclusion behavior for every semantic domain.

A retrieval-specific verification gate is required before claiming this behavior.

## 3. Conflict Register

No direct Canonical-vs-policy conflict was identified in the inspected material.

One **semantic ambiguity** remains:

```text
Working policy model:
CANDIDATE → policy evaluation → ACTIVE

Existing transfer implementation:
CANDIDATE may become ACTIVE during authorized Clone/Inheritance/Succession materialization.
```

Resolution:

These are not treated as the same transition. Transfer materialization is an operation-specific lifecycle transition with its own authorization boundary. It must not be generalized into model-derived activation.

## 4. Implementation Authorization Result

The reconciliation gate does **not** authorize implementation of model-derived persistence yet.

Blocking items:

1. confirmation authority/runtime boundary;
2. model-signal idempotency/correlation key;
3. candidate retrieval semantics;
4. domain-specific lifecycle transition API/function availability for model-derived acceptance;
5. authenticated negative security tests;
6. complete Journey projection transaction boundary.

## 5. Required Next Gate

Next gate is **Runtime Lifecycle Transition Capability Audit**, not coding.

Audit each domain independently:

```text
MEMORY
  CANDIDATE → ACTIVE
  ACTIVE → UPDATE
  ACTIVE → SUPERSEDE

KNOWLEDGE
  CANDIDATE → ACTIVE
  ACTIVE → UPDATE
  ACTIVE → SUPERSEDE

EXPERIENCE
  CANDIDATE → ACTIVE
  ACTIVE → UPDATE
  ACTIVE → SUPERSEDE
```

For every transition identify:

```text
function / RPC
input contract
identity boundary
ownership check
lifecycle guard
policy guard
transaction boundary
Journey side effect
idempotency behavior
failure behavior
current DB existence
E2E verification status
```

## 6. Decision

**Semantic Lifecycle Policy Reconciliation: PARTIAL PASS.**

The working policy is materially aligned with the current foundation and implementation boundaries, but the implementation gate remains OPEN because several runtime capabilities required to safely realize model-derived persistence are not yet proven.

No migration is justified by this gate.

No runtime code change is justified by this gate.

## 7. Evidence Principle

```text
Existing function ≠ verified behavior
Migration ≠ current DB state
Policy definition ≠ implementation
Implementation ≠ E2E proof

Policy Gate:
CONTRACT → RECONCILE → CAPABILITY AUDIT → IMPLEMENT → TEST → VERIFY
```
