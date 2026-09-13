# SECOND HEAD — Knowledge Transition Authority Capability Audit

## Status
WORKING AUDIT RECORD — PARTIAL PASS — IMPLEMENTATION GATE CLOSED

## Authority

This document is a working audit record only.

It does not modify or supersede Canonical architecture, approved contracts, or historical design authority.

Authority order applied:

```text
Canonical → Approved Contract → Architecture → Implementation → Runtime/Database Evidence → History → Inference → Proposal
```

## Audit Goal

Verify whether the current SECOND HEAD DEV system has an evidenced runtime authority for each Knowledge lifecycle transition defined by the historical Knowledge design:

```text
CANDIDATE
  → ACCEPTED
  → INDEXED
  → ACTIVE
  → UPDATED
  → DEPRECATED
  → ARCHIVED
```

The audit specifically distinguishes lifecycle vocabulary/schema support from an actual authorized runtime transition capability.

## Evidence Scope

- GitHub DEV branch: `dev`
- GitHub historical branch: `dev_old`
- Supabase DEV project: `pkhkgvsrqeupvwoqjwmd`
- Current database function definitions queried directly from Supabase DEV.
- Historical P3D Knowledge design inspected from `dev_old`.

## 1. Historical Lifecycle Authority

Historical `dev_old/docs/design/P3D_KNOWLEDGE_SCHEMA_v1.0.md` defines the intended Knowledge lifecycle as:

```text
Candidate
  → Validation
  → Accepted
  → Indexed
  → Active
  → Updated
  → Deprecated
  → Archived
```

The same artifact explicitly states that the schema design itself did not implement lifecycle behavior; lifecycle implementation remained a later backlog item. It also states that `knowledge_candidate = true` is not equivalent to automatic creation of a Knowledge record.

Therefore the historical design establishes lifecycle intent, but does not by itself prove current runtime transition authority.

## 2. Current DEV Schema Evidence

The current DEV `public.knowledge` lifecycle constraint permits exactly these lifecycle values:

```text
CANDIDATE
ACCEPTED
INDEXED
ACTIVE
UPDATED
DEPRECATED
ARCHIVED
```

The table also contains versioning and supersession fields:

```text
version
superseded_by
```

This proves storage vocabulary and representation support only. It does not prove that authorized runtime transitions exist.

## 3. Current DEV Knowledge Runtime Capability Inventory

Current public Knowledge-related functions observed in Supabase DEV include:

- `runtime_record_knowledge_candidate`
- `runtime_record_knowledge_with_journey`
- `retrieve_knowledge_bounded`
- `authorized_read_retrieve_bounded`
- `global_search_bounded`
- transfer/recovery functions that materialize Knowledge as part of another lifecycle operation.

No dedicated current function named:

```text
runtime_activate_knowledge_candidate
```

was evidenced.

No dedicated runtime transition function was evidenced for the full Knowledge lifecycle chain.

## 4. Transition-by-Transition Audit

### 4.1 CANDIDATE → ACCEPTED

**Status: OPEN / NOT EVIDENCED**

Evidence:

- `runtime_record_knowledge_candidate` creates or updates a record only in `CANDIDATE`.
- Current DEV function definition contains no authorized transition from `CANDIDATE` to `ACCEPTED`.
- Historical design identifies `Accepted` as the next lifecycle state after validation, but leaves lifecycle implementation outside the schema artifact.

Conclusion:

```text
Storage state: EXISTS
Historical intent: EXISTS
Runtime transition authority: NOT EVIDENCED
Authorization contract: OPEN
Journey projection: OPEN
Operation identity/idempotency: OPEN
```

### 4.2 ACCEPTED → INDEXED

**Status: HISTORICAL/TEST EVIDENCE ONLY — RUNTIME AUTHORITY OPEN**

Migration `20260811180222_p3d_007_knowledge_indexing_verification.sql` creates a synthetic `ACCEPTED` record and directly updates it to `INDEXED`, then verifies the resulting value.

This proves that the schema accepts the state transition at SQL level in a verification migration.

It does **not** prove an authorized production runtime transition API. The migration performs direct table mutation and is a verification artifact.

Conclusion:

```text
Storage state: EXISTS
Direct SQL verification: EXISTS
Runtime transition authority: NOT EVIDENCED
Authorization contract: OPEN
Journey projection: OPEN
Operation identity/idempotency: OPEN
```

### 4.3 INDEXED → ACTIVE

**Status: OPEN / NOT EVIDENCED**

`retrieve_knowledge_bounded` treats both `INDEXED` and `ACTIVE` as retrieval-eligible states for GENERAL/SHARED Knowledge.

This proves retrieval semantics, not a required or authorized transition from `INDEXED` to `ACTIVE`.

No current dedicated transition function was evidenced.

Conclusion:

```text
Retrieval eligibility: EXISTS
Storage state: EXISTS
Runtime transition authority: NOT EVIDENCED
Authorization contract: OPEN
Journey projection: OPEN
Operation identity/idempotency: OPEN
```

### 4.4 ACTIVE → UPDATED / SUPERSEDED

**Status: OPEN / NOT EVIDENCED AS KNOWLEDGE LIFECYCLE TRANSITION**

`public.knowledge` contains both `UPDATED` lifecycle vocabulary and `superseded_by`.

Current DEV runtime functions inspected do not expose a dedicated Knowledge update/supersession transition authority.

Transfer functions can materialize Knowledge records on another SH and may preserve or transform lifecycle in transfer-specific behavior, but transfer materialization is not a generic Knowledge lifecycle update/supersede API.

Conclusion:

```text
Storage representation: EXISTS
Version/supersession fields: EXISTS
Generic runtime update authority: NOT EVIDENCED
Generic runtime supersede authority: NOT EVIDENCED
Atomic Journey linkage: OPEN
Operation identity/idempotency: OPEN
```

### 4.5 ACTIVE → DEPRECATED

**Status: OPEN / NOT EVIDENCED**

The lifecycle enum permits `DEPRECATED`, but no dedicated current runtime transition function was evidenced.

No verified authorization, transition guard, Journey projection, provenance contract, or idempotency contract for this transition was found.

Conclusion:

```text
Storage state: EXISTS
Runtime transition authority: NOT EVIDENCED
Authorization contract: OPEN
Journey projection: OPEN
Operation identity/idempotency: OPEN
```

### 4.6 DEPRECATED → ARCHIVED

**Status: OPEN / NOT EVIDENCED**

The lifecycle enum permits `ARCHIVED`, but no dedicated current runtime transition function was evidenced.

No verified authorization, terminal-state semantics, Journey projection, provenance contract, or idempotency contract for this transition was found.

Conclusion:

```text
Storage state: EXISTS
Runtime transition authority: NOT EVIDENCED
Authorization contract: OPEN
Journey projection: OPEN
Operation identity/idempotency: OPEN
```

## 5. Candidate Capture Boundary

Current `runtime_record_knowledge_candidate` is a candidate acquisition capability, not an activation capability.

Current DEV definition verifies:

- authentication is required;
- the supplied SH must belong to the current account and be active;
- content/source/origin are validated;
- scope/visibility combinations are validated;
- confidence is range-checked;
- existing candidate content can be updated in place;
- new Knowledge is inserted as `CANDIDATE`.

This is consistent with the historical acquisition boundary and does not establish lifecycle promotion authority.

## 6. Journey Boundary

`runtime_record_knowledge_with_journey` creates/updates a Knowledge candidate and emits a `LEARNING` Journey event.

The Journey event references the Knowledge record, but Journey is not an activation authority.

No evidence was found that replaying or editing a Journey event can legitimately promote Knowledge through the lifecycle.

However, no complete atomic transition transaction exists because no generic Knowledge transition API was evidenced.

## 7. Confirmation Authority

Current DEV has `runtime_high_risk_confirmations` and related confirmation functions.

The current confirmation infrastructure is explicitly domain-limited to `RECOVERY_RESTORE` execution.

Therefore:

```text
Confirmation infrastructure: EXISTS
Knowledge lifecycle confirmation authority: NOT CONTRACTED / NOT EVIDENCED
```

The existing recovery confirmation mechanism must not be silently reused as Knowledge lifecycle authority.

## 8. Security / Exposure

Current Knowledge candidate write functions are `SECURITY DEFINER` and exposed to the `authenticated` role with explicit authentication and SH ownership checks in the current definitions.

No dedicated lifecycle transition function exists whose SECURITY DEFINER exposure, grants, search_path, ownership checks, lifecycle guards, and SQLSTATE contract can be audited.

Therefore the security gate for lifecycle transitions remains OPEN.

## 9. Operation Identity / Idempotency

No dedicated Knowledge lifecycle operation ledger or stable transition operation key was evidenced for these transitions.

Content-based candidate deduplication is not equivalent to request-level transition idempotency.

Required logical identity remains:

```text
actor/account
+ SH
+ domain
+ source record
+ transition
+ operation key
```

This is not currently proven for Knowledge lifecycle transitions.

## 10. Provenance / Audit

Knowledge has `source` and `provenance` fields, and runtime audit infrastructure exists.

However, no dedicated lifecycle transition implementation was evidenced that atomically records:

```text
actor
account
SH
source record
source signal
model/provider
semantic decision
authorization/confirmation
transition
operation key
timestamp
resulting record
Journey event
```

Therefore lifecycle provenance/audit completeness is OPEN.

## 11. Concurrency / Atomicity

Current candidate acquisition uses row locking for an existing candidate during content-based deduplication.

That is not proof of lifecycle transition concurrency safety.

No current Knowledge transition function was evidenced that atomically performs:

```text
AUTH → LOCK → VERIFY CURRENT STATE → VERIFY AUTHORITY → MUTATE → PROVENANCE/AUDIT → JOURNEY → COMMIT
```

Therefore concurrency and domain+Journey atomicity remain OPEN.

## 12. Transfer-Specific Exception

Existing Clone / Inheritance / Succession paths can materialize Knowledge records and may convert a source `CANDIDATE` to target `ACTIVE` as part of transfer materialization.

This is an important domain-specific capability, but it must not be interpreted as evidence of a generic Knowledge lifecycle promotion API.

The distinction is:

```text
Transfer materialization → target record lifecycle behavior
Generic lifecycle transition → source Knowledge state authority
```

These are separate contracts.

## 13. Current DEV Data Evidence

Current Supabase DEV Knowledge data contains:

```text
CANDIDATE: 1
```

No current DEV rows were observed for `ACCEPTED`, `INDEXED`, `ACTIVE`, `UPDATED`, `DEPRECATED`, or `ARCHIVED` at audit time.

This is runtime-state evidence of current data, not proof that the states are impossible.

## 14. Gate Result

Overall result:

**PARTIAL PASS — IMPLEMENTATION GATE CLOSED**

What is proven:

- Knowledge lifecycle vocabulary exists in current storage.
- Historical lifecycle intent exists.
- Candidate acquisition exists and is authenticated/SH-scoped.
- Retrieval semantics distinguish `INDEXED` and `ACTIVE` as eligible states.
- Direct SQL verification demonstrated `ACCEPTED → INDEXED` at storage level.
- Transfer operations can materialize Knowledge with transfer-specific lifecycle behavior.

What is not proven:

- `CANDIDATE → ACCEPTED` runtime authority.
- `ACCEPTED → INDEXED` production runtime authority.
- `INDEXED → ACTIVE` runtime authority.
- `ACTIVE → UPDATED/SUPERSEDED` runtime authority.
- `ACTIVE → DEPRECATED` runtime authority.
- `DEPRECATED → ARCHIVED` runtime authority.
- Knowledge-specific confirmation authority.
- Stable lifecycle operation identity/idempotency.
- Atomic Knowledge + Journey transition transaction.
- Complete lifecycle provenance/audit contract.
- Lifecycle transition SECURITY DEFINER exposure and SQLSTATE contract.
- Positive/negative/cross-actor/concurrency E2E verification.

## 15. Required Next Gate

The implementation gate remains CLOSED.

Next gate:

**Knowledge Transition Authority Design + Contract Reconciliation**

Required before implementation:

1. Reconcile historical lifecycle intent with current DEV lifecycle vocabulary.
2. Decide which lifecycle states are actual persisted states versus process boundaries.
3. Establish authoritative transition rules for every supported transition.
4. Establish Knowledge-specific decision/validation/confirmation authority.
5. Define exact runtime transition APIs/functions.
6. Define stable operation identity and idempotency semantics.
7. Define atomic domain + Journey transaction boundary.
8. Define provenance/audit schema and required fields.
9. Define SECURITY DEFINER exposure, grants, search_path, ownership checks, and SQLSTATE.
10. Define positive, negative, cross-actor, terminal-state, and concurrency E2E verification.
11. Reconcile transfer materialization semantics with generic lifecycle semantics without silently merging the contracts.

## 16. Change Record

```text
Runtime code changes: NONE
Database schema changes: NONE
Database data changes: NONE
Migration changes: NONE
Canonical changes: NONE
Working documentation: CREATED
Implementation: BLOCKED
Verification: AUDIT-LEVEL ONLY
```
