# SECOND HEAD — Knowledge Transition Implementation Contract + Full-Write Plan — 2026-09-13

## Status

**WORKING IMPLEMENTATION CONTRACT — PARTIAL PASS — IMPLEMENTATION GATE CLOSED**

This document converts the reconciled Knowledge lifecycle design into an implementation contract and full-write plan. It does not authorize database mutation by itself.

## 1. Operating Rules

- Supabase DEV is the database/runtime authority.
- For database implementation: **Supabase DEV → verify actual state → migration history → GitHub reconciliation**.
- Migration names are descriptive history names only; do not use P3/P4/P5 program labels.
- No speculative, empty, duplicate, placeholder, or destructive migration.
- Full-write means the implementation is complete across all required layers in one controlled change: schema/constraints/indexes, authorization/RLS, functions, grants/exposure, runtime dependency, provenance/audit, Journey, idempotency, error contract, tests, and verification as required by the final design.
- If a safe full-write cannot be completed, preserve the last known baseline. Do not push a partial implementation. Provide a precise chat patch and proposed commit name for manual push if necessary.
- New files are **baseline + narrowly scoped patch** and must not silently alter unrelated content.
- Canonical is untouched unless explicitly authorized.

## 2. Authority Baseline

Historical Knowledge lifecycle intent is reconciled as:

```text
ACQUISITION
  ↓
CANDIDATE
  ↓
VALIDATION PROCESS
  ↓
ACCEPTED
  ↓
INDEXING
  ↓
INDEXED
  ↓
AUTHORIZED ACTIVATION
  ↓
ACTIVE
  ├──→ UPDATED + superseded_by successor
  ↓
DEPRECATED
  ↓
ARCHIVED
```

`VALIDATION` is a process boundary, not a new database lifecycle enum.

Current DEV lifecycle vocabulary is:

```text
CANDIDATE
ACCEPTED
INDEXED
ACTIVE
UPDATED
DEPRECATED
ARCHIVED
```

No `SUPERSEDED` enum is introduced by this contract.

## 3. Supported Transition Matrix

| Transition | Runtime capability | Current authority | Implementation status |
|---|---|---|---|
| CANDIDATE → ACCEPTED | `runtime_accept_knowledge` | authorized validation/acceptance decision | CONTRACTED / NOT IMPLEMENTED |
| ACCEPTED → INDEXED | `runtime_index_knowledge` | authorized indexing operation | CONTRACTED / NOT IMPLEMENTED |
| INDEXED → ACTIVE | `runtime_activate_knowledge` | authorized activation decision | CONTRACTED / NOT IMPLEMENTED |
| ACTIVE → UPDATED + successor | `runtime_update_knowledge` | authorized version/update operation | CONTRACTED / NOT IMPLEMENTED |
| ACTIVE → DEPRECATED | `runtime_deprecate_knowledge` | authorized deprecation operation | CONTRACTED / NOT IMPLEMENTED |
| DEPRECATED → ARCHIVED | `runtime_archive_knowledge` | authorized archive operation | CONTRACTED / NOT IMPLEMENTED |

These names are contract targets only. Their database existence must not be assumed until implemented and verified in Supabase DEV.

## 4. General Function Boundary

Every transition function must derive authority server-side. Caller-supplied account IDs, actor IDs, ownership claims, or lifecycle authority are not trusted.

Required sequence:

```text
AUTHENTICATE
→ RESOLVE ACTOR / ACCOUNT
→ RESOLVE ACTIVE SH
→ LOCK TARGET RECORD
→ VERIFY OWNERSHIP
→ VERIFY DOMAIN
→ VERIFY EXPECTED CURRENT LIFECYCLE
→ VERIFY LEGAL TRANSITION
→ VERIFY SCOPE / VISIBILITY / TRANSFER POLICY
→ VERIFY DECISION / VALIDATION / CONFIRMATION AUTHORITY
→ VERIFY OPERATION IDENTITY
→ MUTATE
→ WRITE PROVENANCE / AUDIT
→ WRITE REQUIRED JOURNEY PROJECTION
→ RETURN OBSERVABLE RESULT
```

## 5. Exact Input Direction

The implementation contract uses explicit transition-specific inputs rather than a generic `lifecycle` mutation endpoint.

### Acceptance

```text
runtime_accept_knowledge(
  p_knowledge_id uuid,
  p_expected_lifecycle text,
  p_operation_key text,
  p_decision_ref text,
  p_validation_ref text,
  p_provenance jsonb
)
```

Required expected lifecycle: `CANDIDATE`.

### Indexing

```text
runtime_index_knowledge(
  p_knowledge_id uuid,
  p_expected_lifecycle text,
  p_operation_key text,
  p_index_ref text,
  p_provenance jsonb
)
```

Required expected lifecycle: `ACCEPTED`.

### Activation

```text
runtime_activate_knowledge(
  p_knowledge_id uuid,
  p_expected_lifecycle text,
  p_operation_key text,
  p_decision_ref text,
  p_confirmation_ref text,
  p_provenance jsonb
)
```

Required expected lifecycle: `INDEXED`.

### Update / Supersession

```text
runtime_update_knowledge(
  p_knowledge_id uuid,
  p_expected_lifecycle text,
  p_operation_key text,
  p_update_ref text,
  p_provenance jsonb,
  p_successor_content text,
  p_successor_provenance jsonb
)
```

Required expected lifecycle: `ACTIVE`.

The old record remains historical with `lifecycle = UPDATED` and `superseded_by = successor_id` where the update is a superseding version.

### Deprecation

```text
runtime_deprecate_knowledge(
  p_knowledge_id uuid,
  p_expected_lifecycle text,
  p_operation_key text,
  p_decision_ref text,
  p_confirmation_ref text,
  p_provenance jsonb
)
```

Required expected lifecycle: `ACTIVE`.

### Archive

```text
runtime_archive_knowledge(
  p_knowledge_id uuid,
  p_expected_lifecycle text,
  p_operation_key text,
  p_decision_ref text,
  p_confirmation_ref text,
  p_provenance jsonb
)
```

Required expected lifecycle: `DEPRECATED`.

These signatures remain implementation targets and may only be adjusted after evidence-based DB/runtime review identifies a concrete incompatibility.

## 6. Output Contract

Each transition returns the resulting Knowledge record ID for a successful mutation.

The implementation must also expose machine-classifiable result semantics:

```text
SUCCESS
ALREADY_APPLIED
REJECTED
FAILED
```

`ALREADY_APPLIED` is valid only when the persisted operation identity matches the same account/SH/domain/source/transition/operation key.

A reused operation key against a different target or transition is a conflict and must be rejected.

## 7. Transition-Specific Authority

### CANDIDATE → ACCEPTED

Requires a validation/acceptance decision. Model output or confidence cannot itself authorize acceptance.

### ACCEPTED → INDEXED

Requires an indexing operation that has actually completed its required indexing/storage work. This transition must not silently activate the Knowledge record.

### INDEXED → ACTIVE

Requires an authorized activation decision. Retrieval, search ranking, model confidence, or Journey replay cannot activate Knowledge.

### ACTIVE → UPDATED

Requires an authorized version/update operation. Preferred behavior is successor creation plus old-record supersession metadata rather than destructive overwrite.

### ACTIVE → DEPRECATED

Requires explicit deprecation authority. Deprecation does not silently archive.

### DEPRECATED → ARCHIVED

Requires explicit archive authority. `ARCHIVED` is terminal for the normal lifecycle path.

## 8. Confirmation Contract

Current DEV confirmation infrastructure is recovery-specific (`RECOVERY_RESTORE`) and must not be reused implicitly.

Before any Knowledge transition requiring confirmation is implemented, semantic confirmation must have an explicit authority contract binding:

```text
actor
account
SH
Knowledge target
operation type
decision reference
expiry
confirmation status
operation identity
execution authority
audit/provenance
```

No Knowledge function may treat an arbitrary recovery confirmation reference as lifecycle authorization.

If no transition is classified as confirmation-required by the final approved policy, `p_confirmation_ref` must not become a bypass channel and may be rejected/ignored according to the final API decision.

## 9. Operation Identity / Idempotency

Every externally retryable transition requires a stable operation key.

Logical identity:

```text
account
+ SH
+ knowledge_id
+ transition
+ operation_key
```

The persisted operation record must make the result observable before a retry is treated as already applied.

Required concurrency semantics:

```text
request A → SUCCESS
request B same logical operation → ALREADY_APPLIED or equivalent safe idempotent result
```

A concurrent request with a different logical operation must re-evaluate the locked current state and cannot bypass lifecycle guards.

Content-based deduplication is not a substitute for operation identity.

## 10. Provenance / Audit

Every successful transition must retain enough information to trace:

```text
actor
account
SH
source Knowledge record
source signal/input
model/provider when applicable
validation result when applicable
decision
confirmation/authorization when applicable
transition
operation key
timestamp
resulting Knowledge record
Journey event when applicable
```

Existing `knowledge.provenance` and `audit_events` may be reused if their actual schema and security behavior can represent this information without weakening isolation.

No new audit table should be created merely because an existing structure has not yet been fully reviewed.

## 11. Journey Contract

Journey remains projection/history, never lifecycle authority.

For transitions requiring Journey projection, the event must reference the Knowledge transition and preserve at minimum:

```text
source Knowledge record
previous lifecycle
new lifecycle
transition
operation key
provenance reference
resulting record where applicable
```

The exact Journey event type/payload must be reconciled against current DEV conventions before implementation.

Replay or editing a Journey event must not cause lifecycle mutation.

## 12. Atomic Transaction Contract

Preferred single PostgreSQL transaction:

```text
BEGIN
  authenticate / authorize
  lock target Knowledge row
  verify expected lifecycle
  verify transition authority
  verify policy
  verify confirmation/decision
  resolve operation identity
  mutate Knowledge
  persist provenance/audit
  persist Journey projection
COMMIT
```

No false success.

If an atomic domain + Journey boundary cannot be implemented, the implementation must stop rather than silently ship a partially successful lifecycle operation, unless a separately approved intermediate-state/reconciliation design exists.

## 13. Security / Exposure Contract

Before creating any `SECURITY DEFINER` transition function, verify whether `SECURITY INVOKER` can satisfy the contract.

If `SECURITY DEFINER` is necessary, implementation must explicitly establish:

- owner;
- safe `search_path`;
- authentication guard;
- current-account resolution;
- active SH ownership;
- Knowledge ownership;
- lifecycle guard;
- transition legality;
- policy guard;
- operation identity guard;
- exact `EXECUTE` grants;
- anonymous rejection;
- RLS interaction;
- error leakage boundaries.

`SECURITY DEFINER` must never be added merely to bypass a permission error.

## 14. Error Contract

Minimum machine-classifiable categories:

```text
UNAUTHENTICATED
NOT_AUTHORIZED
SH_NOT_OWNED
KNOWLEDGE_NOT_FOUND
DOMAIN_MISMATCH
WRONG_LIFECYCLE
INVALID_TRANSITION
INVALID_POLICY
VALIDATION_REQUIRED
DECISION_REQUIRED
CONFIRMATION_REQUIRED
OPERATION_KEY_INVALID
OPERATION_CONFLICT
ALREADY_APPLIED
CONCURRENCY_CONFLICT
DOMAIN_MUTATION_FAILED
JOURNEY_PROJECTION_FAILED
INTERNAL_FAILURE
```

Exact SQLSTATE mapping must be finalized from the actual Postgres implementation and tested against Supabase DEV. No invented SQLSTATE values are authorized by this document.

## 15. Full-Write Scope

When implementation is authorized, the change must be assessed across all required layers before any partial push:

```text
1. Existing schema/state inspection
2. Required schema/constraints/indexes only
3. Authorization/RLS boundary
4. Transition functions/RPCs
5. Function ownership/search_path
6. EXECUTE grants/exposure
7. Operation identity persistence
8. Provenance/audit persistence
9. Journey projection
10. Runtime caller dependency
11. Error contract
12. Positive tests
13. Negative/cross-actor tests
14. Concurrency/idempotency tests
15. Actual Supabase verification
16. Migration history generation
17. GitHub reconciliation
```

No item is silently skipped if it is a dependency of the implemented transition.

## 16. Supabase-First Implementation Protocol

When the gate eventually opens:

```text
INSPECT CURRENT SUPABASE DEV
        ↓
PLAN MINIMAL SAFE CHANGE
        ↓
APPLY TO SUPABASE DEV
        ↓
RUN IMMEDIATE DB TESTS
        ↓
VERIFY ACTUAL DB STATE
        ↓
VERIFY FUNCTION SECURITY / GRANTS
        ↓
VERIFY POSITIVE + NEGATIVE + CONCURRENCY
        ↓
RECONCILE DB STATE
        ↓
GENERATE CLEAN DESCRIPTIVE MIGRATION HISTORY
        ↓
RECONCILE MIGRATION ↔ SUPABASE
        ↓
RECONCILE GITHUB DEV
```

The migration is a record of the verified DB change, not the authority that precedes the DB change.

## 17. Rollback / Recovery

Before applying implementation changes, define:

- exact affected objects;
- reversible schema/data behavior;
- function replacement/drop behavior;
- grant restoration;
- Journey consistency behavior;
- operation ledger consistency;
- recovery path if the transition is only partially applied.

A rollback plan must not claim safety if domain and Journey cannot be restored consistently.

## 18. Verification Matrix

### Positive

For every implemented transition:

```text
correct authenticated owner
+ correct SH
+ correct Knowledge record
+ expected lifecycle
+ valid authority
→ expected resulting lifecycle
```

Verify resulting row, provenance, audit, Journey, and operation identity.

### Negative

Verify rejection for:

```text
unauthenticated
cross-account SH
cross-account Knowledge ID
cross-actor Knowledge ID
wrong lifecycle
illegal transition
invalid policy
missing required decision
missing required confirmation
model-only authority
Journey-only replay
operation-key conflict
terminal lifecycle
terminal SH where applicable
```

### Concurrency

At minimum, two concurrent attempts against the same Knowledge record must not produce duplicate successors, inconsistent lifecycle, or duplicate logical Journey history.

## 19. Implementation Gate Result

```text
Lifecycle reconciliation       = PASS
Transition matrix              = PASS
Per-transition authority       = DEFINED
API direction                  = DEFINED
Security boundary              = DEFINED
Idempotency                    = DEFINED
Provenance                     = DEFINED
Journey boundary               = DEFINED / exact payload OPEN
Atomicity                      = REQUIRED / RUNTIME PROOF OPEN
Confirmation authority         = OPEN
Operation ledger implementation= OPEN
SECURITY DEFINER review        = OPEN
SQLSTATE mapping               = OPEN
Runtime implementation         = OPEN
E2E verification               = OPEN

IMPLEMENTATION GATE = CLOSED
```

## 20. Why Implementation Is Still Blocked

The contract is now specific enough to prevent speculative implementation, but current DEV evidence still lacks:

1. a semantic Knowledge confirmation authority;
2. a persisted lifecycle operation ledger/idempotency mechanism;
3. proven atomic Knowledge + Journey transition capability;
4. exact Journey lifecycle event vocabulary/payload;
5. final SECURITY DEFINER/INVOKER decision per function;
6. tested SQLSTATE mapping;
7. runtime caller integration and E2E proof.

Creating functions before these dependencies are resolved would produce a partial system and violate the full-write rule.

## 21. No-Change Record

```text
Supabase schema = UNCHANGED
Supabase data = UNCHANGED
Runtime = UNCHANGED
Migration = UNCHANGED
Canonical = UNCHANGED
Working documentation = CREATED
Baseline = PRESERVED
```

## 22. Next Gate

**Knowledge Transition Security / Operation Ledger / Atomicity Closure**

Focus:

1. determine whether existing `audit_events` can safely serve operation identity or whether a dedicated operation ledger is actually required;
2. inspect existing Journey event contract and transaction capabilities;
3. finalize semantic confirmation authority without coupling it to recovery;
4. decide SECURITY INVOKER vs SECURITY DEFINER per transition;
5. finalize exact SQLSTATE mapping from implementation constraints;
6. verify runtime caller dependency;
7. close implementation blockers before any Supabase mutation.
