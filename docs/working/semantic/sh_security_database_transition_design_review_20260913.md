# SECOND HEAD — Security + Database Transition Design Review — 2026-09-13

## Status

**WORKING AUDIT / DESIGN REVIEW — PARTIAL PASS — IMPLEMENTATION GATE CLOSED**

This record captures the current DEV evidence for the semantic lifecycle transition boundary. It does not authorize runtime implementation, migration, or Canonical change.

## Authority

```text
CANONICAL → APPROVED CONTRACT → ARCHITECTURE/DESIGN → THIS WORKING REVIEW → IMPLEMENTATION → RUNTIME/DB EVIDENCE → E2E VERIFICATION
```

## 1. Scope

Review target:

- `runtime_activate_memory_candidate`
- `runtime_activate_knowledge_candidate`
- authorization and ownership boundary;
- Knowledge lifecycle vocabulary;
- confirmation authority;
- operation identity/idempotency;
- transaction boundary with Journey;
- provenance/audit;
- SECURITY DEFINER/INVOKER and grants;
- concurrency and error mapping.

No implementation changes were made by this review.

## 2. Current DEV Database Evidence

### Knowledge

Current `public.knowledge` columns include:

- `knowledge_id`
- `content`
- `knowledge_class`
- `scope`
- `visibility`
- `source`
- `provenance`
- `confidence`
- `version`
- `lifecycle`
- `superseded_by`
- `sh_id`
- `transfer_policy`
- timestamps

Current database constraint permits lifecycle values:

```text
CANDIDATE
ACCEPTED
INDEXED
ACTIVE
UPDATED
DEPRECATED
ARCHIVED
```

Current DEV data contains only `CANDIDATE` Knowledge rows at the time of review. This does not prove that the complete lifecycle transition chain is implemented.

### Confirmation

`public.runtime_high_risk_confirmations` exists with durable action identity and status fields. `action_id` is unique. The current confirmation mechanism is domain-limited: existing runtime confirmation execution is for `RECOVERY_RESTORE`; it is not evidence of generic semantic lifecycle confirmation authority.

### Audit

`public.audit_events` exists with `account_id`, `sh_id`, `event_type`, `status`, `metadata`, and timestamps. It is suitable as an audit boundary, but current evidence does not establish a complete semantic transition operation ledger.

## 3. Current Knowledge Runtime Functions

DEV exposes:

- `retrieve_knowledge_bounded` — SECURITY INVOKER;
- `runtime_record_knowledge_candidate` — SECURITY DEFINER;
- `runtime_record_knowledge_with_journey` — SECURITY DEFINER.

Both candidate-write functions explicitly require authenticated identity and active SH ownership through `current_account_id()`, validate content/source/origin/scope/visibility/confidence, and persist `CANDIDATE` lifecycle.

No current dedicated `runtime_activate_knowledge_candidate` function was evidenced.

## 4. Critical Reconciliation — Knowledge Lifecycle

The earlier transition contract specified:

```text
CANDIDATE → ACTIVE
```

The actual DEV schema permits intermediate states:

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE
```

However, the current runtime evidence does not establish that this exact chain is the authoritative operational path, nor does it prove which function/actor is authorized for each transition.

Therefore the direct `CANDIDATE → ACTIVE` transition must be treated as **CONTRACT CONFLICT / RECONCILIATION REQUIRED**, not silently assumed legal.

No implementation should be created until the Knowledge lifecycle authority and transition chain are reconciled against migration/history and existing retrieval/indexing semantics.

## 5. Confirmation Authority

Correction to prior working-contract wording:

The system DOES have a durable confirmation mechanism.

Current evidence establishes:

```text
runtime_high_risk_confirmations
        ↓
action_id UNIQUE
        ↓
PENDING → CONFIRMED → EXECUTED / CANCELLED / EXPIRED
```

But the current mechanism is scoped to high-risk recovery execution. It cannot be reused for semantic activation merely by passing a confirmation reference. A semantic lifecycle confirmation contract must explicitly define:

- operation type;
- target domain/record;
- account + SH + actor binding;
- expiry;
- status transition;
- confirmation authority;
- execution authority;
- idempotency;
- audit/provenance linkage.

## 6. Authorization Design

Required transition order remains:

```text
auth.uid()
→ current_account_id()
→ active SH ownership
→ record ownership
→ domain
→ expected lifecycle
→ legal transition
→ scope/visibility/transfer policy
→ confirmation/decision authority
→ operation identity
→ mutation
```

Client-provided account IDs must not establish authority. Model output, confidence, Journey events, and record IDs are not authority sources.

## 7. Database Transaction Boundary

Preferred implementation boundary remains one PostgreSQL function transaction:

```text
AUTH
→ LOCK/RESOLVE RECORD
→ VERIFY LIFECYCLE/POLICY/AUTHORITY
→ RESOLVE OPERATION IDENTITY
→ MUTATE DOMAIN
→ WRITE PROVENANCE/AUDIT
→ WRITE JOURNEY PROJECTION
→ COMMIT
```

Current semantic runtime contains separate domain and Journey RPC paths in existing capture flows; therefore whole-path atomicity is **NOT PROVEN**.

For activation, a single DB transaction is the preferred correctness boundary. If Journey cannot be included atomically, the contract must define intermediate state and reconciliation rather than returning false success.

## 8. Concurrency

The candidate write path uses `FOR UPDATE` when resolving an existing candidate, which is useful precedent for row locking, but this is not proof of activation concurrency safety.

Activation must lock the target candidate and establish operation identity before mutation so that concurrent requests cannot create duplicate activation history.

Required verification:

```text
A → SUCCESS
B → ALREADY_APPLIED or REJECTED
```

No duplicate unintended transition/Journey records.

## 9. Operation Identity

Existing confirmation infrastructure provides a unique `action_id` pattern. This is useful precedent but is not yet a semantic lifecycle operation ledger.

Transition activation still requires a stable logical operation key bound to actor/account + SH + domain + source record + transition.

Content-based deduplication is not sufficient for retry safety.

## 10. Provenance / Audit

Knowledge already has mandatory `provenance` JSONB. Audit events provide account/SH/event/status/metadata. The transition contract must bind these to:

- source signal/ref;
- model/provider when applicable;
- semantic decision;
- confirmation/authorization;
- operation key;
- transition;
- resulting record;
- Journey event;
- timestamp.

## 11. SECURITY DEFINER / Exposure

Existing Knowledge write functions are SECURITY DEFINER with `search_path = public` and explicit authentication/ownership guards.

This is a reference pattern only. It does not authorize copying the pattern without reviewing:

- function owner;
- exact `search_path`;
- EXECUTE grants;
- RLS interaction;
- arbitrary SQL/table access;
- identity resolution;
- input validation;
- error leakage.

`SECURITY DEFINER` must never be introduced merely to bypass a permission problem.

## 12. Error Contract

Exact SQLSTATE/error-code mapping remains open. The implementation must distinguish rejected authorization/policy/lifecycle requests from runtime/database failures and must never return false success.

## 13. Decision Matrix

| Gate | Current status |
|---|---|
| Authorization model | DEFINED |
| Knowledge schema inspection | PASS |
| Knowledge lifecycle vocabulary | EXISTING / REQUIRES RECONCILIATION |
| Knowledge CANDIDATE→ACTIVE legality | UNKNOWN / CONFLICT |
| Confirmation infrastructure | EXISTING / DOMAIN-LIMITED |
| Semantic confirmation authority | OPEN |
| Operation identity pattern | PARTIAL — confirmation action_id precedent |
| Semantic transition ledger | OPEN |
| Provenance storage | EXISTING / PARTIAL |
| Audit storage | EXISTING / PARTIAL |
| Atomic domain + Journey | OPEN |
| Concurrency proof | OPEN |
| SECURITY DEFINER exposure review | OPEN |
| SQLSTATE mapping | OPEN |
| Positive E2E | OPEN |
| Negative/cross-actor E2E | OPEN |

## 14. Decision

**SECURITY + DATABASE TRANSITION DESIGN REVIEW = PARTIAL PASS**

The security boundary and database primitives are sufficiently understood to define the implementation constraints, but implementation remains blocked.

The highest-priority reconciliation is Knowledge lifecycle authority. The existing confirmation mechanism must also be explicitly extended/contracted for semantic lifecycle if confirmation is required; recovery confirmation cannot be treated as generic authorization.

## 15. Required Next Gate

**Knowledge Lifecycle Reconciliation + Confirmation Contract Integration**

Required evidence before implementation:

1. migration/history for every Knowledge lifecycle state;
2. existing transition functions or verified absence;
3. retrieval/indexing semantics and whether `INDEXED` is mandatory;
4. exact authority for `ACCEPTED`, `INDEXED`, and `ACTIVE`;
5. semantic confirmation operation contract;
6. transition operation identity persistence;
7. atomic domain + Journey strategy;
8. SECURITY DEFINER exposure/grants;
9. SQLSTATE/error contract;
10. positive, negative, and concurrency E2E plan.

## 16. Change Boundary

```text
GitHub DEV docs          = CHANGED
Runtime code             = UNCHANGED
Supabase schema          = UNCHANGED
Supabase data            = UNCHANGED
Migration                = UNCHANGED
Canonical                = UNCHANGED
Runtime behavior         = UNCHANGED
```
