# SECOND HEAD — Knowledge Lifecycle Reconciliation + Confirmation Contract Integration — 2026-09-13

## Status

**WORKING RECONCILIATION RECORD — PARTIAL PASS — IMPLEMENTATION GATE CLOSED**

## 1. Objective

Reconcile the semantic transition contract with actual DEV Knowledge lifecycle evidence and integrate the existing confirmation pattern without treating recovery confirmation as generic lifecycle authority.

No runtime, migration, data, or Canonical change is authorized by this record.

## 2. Evidence Summary

Actual DEV `public.knowledge.lifecycle` constraint permits:

```text
CANDIDATE
ACCEPTED
INDEXED
ACTIVE
UPDATED
DEPRECATED
ARCHIVED
```

The current DEV data observed during this review contains only `CANDIDATE` rows.

The Knowledge candidate runtime functions currently persist `CANDIDATE`; no dedicated activation function is evidenced.

## 3. Retrieval Semantics

Existing `retrieve_knowledge_bounded` is SECURITY INVOKER and retrieves only Knowledge with:

```text
scope = GENERAL
visibility = SHARED
lifecycle IN ('INDEXED', 'ACTIVE')
```

Therefore `INDEXED` is an explicit retrieval eligibility state, but retrieval semantics alone do not prove that every Knowledge record must traverse `CANDIDATE → ACCEPTED → INDEXED → ACTIVE`.

## 4. Historical Transition Evidence

The indexing verification migration demonstrated a synthetic direct SQL update:

```text
ACCEPTED → INDEXED
```

This is verification of storage/lifecycle vocabulary, not proof of a production authorization API or complete transition workflow.

No current evidence establishes a production transition function for:

- `CANDIDATE → ACCEPTED`;
- `INDEXED → ACTIVE`;
- `CANDIDATE → ACTIVE`;
- `ACTIVE → UPDATED`;
- `ACTIVE → DEPRECATED`;
- `ACTIVE → ARCHIVED`.

## 5. Reconciliation Decision

The prior contract's direct:

```text
CANDIDATE → ACTIVE
```

must NOT be silently promoted to an implemented or canonical Knowledge transition.

Current status:

```text
Knowledge lifecycle vocabulary = EXISTING
Knowledge retrieval gate       = INDEXED / ACTIVE
Candidate capture              = EXISTING
Candidate activation API       = MISSING
Full transition authority      = UNKNOWN
Direct CANDIDATE → ACTIVE      = NOT PROVEN
Intermediate chain mandatory   = NOT PROVEN
```

Therefore Knowledge activation remains blocked pending an explicit domain decision and evidence reconciliation covering transition authority and indexing semantics.

## 6. Confirmation Integration

A durable confirmation system already exists in DEV through `runtime_high_risk_confirmations` with unique `action_id` and statuses including `PENDING`, `CONFIRMED`, `EXECUTED`, `CANCELLED`, and `EXPIRED`.

Current execution semantics are domain-limited to `RECOVERY_RESTORE`.

Decision:

```text
Recovery confirmation = EXISTING
Semantic lifecycle confirmation = NOT CONTRACTED
```

A lifecycle transition must not accept a recovery confirmation reference as if it were generic authorization.

If semantic activation requires `CONFIRM`, a separate semantic confirmation operation contract must bind at minimum:

- actor/account;
- SH;
- target record;
- operation type;
- decision reference;
- expiration;
- confirmation status;
- operation identity;
- audit/provenance;
- execution authority.

## 7. Security Boundary

The transition contract remains:

```text
auth.uid()
→ current_account_id()
→ active SH ownership
→ record ownership
→ domain
→ expected lifecycle
→ legal transition
→ scope/visibility/transfer policy
→ decision/confirmation authority
→ operation identity
→ atomic mutation
```

Model output and confidence are not authority. Journey is projection/history, not authority.

## 8. Database Implementation Constraint

When implementation becomes authorized, the preferred activation boundary is one PostgreSQL transaction that locks the target record, validates authority and expected lifecycle, resolves operation identity, mutates lifecycle, records provenance/audit, and emits the required Journey projection before commit.

Current evidence does not prove this activation transaction exists.

## 9. Required Evidence Before Implementation

1. explicit Knowledge domain decision for the transition path;
2. authoritative mapping for `ACCEPTED`, `INDEXED`, and `ACTIVE`;
3. production transition function/API or verified absence;
4. exact confirmation semantics for semantic lifecycle;
5. operation identity persistence;
6. Journey event contract;
7. SECURITY DEFINER exposure/grants;
8. SQLSTATE/error mapping;
9. positive/negative/concurrency E2E design.

## 10. Final Decision

**KNOWLEDGE LIFECYCLE RECONCILIATION = PARTIAL PASS / BLOCKED**

The database vocabulary and retrieval boundary are understood, and the previous confirmation finding is corrected: durable confirmation infrastructure exists but is recovery-specific.

The Knowledge lifecycle transition authority is not sufficiently evidenced to authorize implementation.

## 11. Change Boundary

```text
GitHub DEV docs          = CHANGED
Runtime code             = UNCHANGED
Supabase schema          = UNCHANGED
Supabase data            = UNCHANGED
Migration                = UNCHANGED
Canonical                = UNCHANGED
Runtime behavior         = UNCHANGED
```
