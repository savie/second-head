# SECOND HEAD — Knowledge Transition Authority Design + Contract Reconciliation

## Status
WORKING DESIGN / CONTRACT RECONCILIATION — PARTIAL PASS — IMPLEMENTATION GATE CLOSED

## Authority

This document is a working design and reconciliation record.

It does not modify or supersede Canonical architecture, Approved Contracts, or historical design authority.

Authority order:

```text
OWNER / USER DECISION
→ CANONICAL
→ APPROVED CONTRACT
→ ARCHITECTURE / DESIGN
→ WORKING CONTRACT
→ IMPLEMENTATION
→ RUNTIME / DATABASE EVIDENCE
→ HISTORY
→ INFERENCE
→ PROPOSAL
```

## 1. Operating Rules

- Supabase DEV is the runtime/database authority for database state.
- Database implementation order is Supabase DEV first, verification second, migration history third, GitHub reconciliation fourth.
- Migration names are descriptive history names only; do not use historical P3/P4/P5 program labels as migration names.
- No speculative, empty, duplicate, placeholder, or baseline-destructive migration.
- Full-write is required when implementation starts: schema/constraints/indexes/RLS/authorization/functions/grants/runtime dependency/provenance/audit/Journey/idempotency/error contract/tests as required by the final design.
- If implementation is blocked and no safe path exists, preserve the last known baseline and provide a precise chat patch with a proposed commit name rather than pushing a risky partial change.
- A new file must be treated as baseline + narrowly scoped patch; it must not silently modify unrelated material.
- Canonical files are not changed by this gate.

## 2. Evidence Baseline

Current Supabase DEV Knowledge-related runtime functions include:

```text
runtime_record_knowledge_candidate
runtime_record_knowledge_with_journey
retrieve_knowledge_bounded
```

No dedicated current Knowledge lifecycle transition RPCs were evidenced for acceptance, indexing, activation, update/supersession, deprecation, or archive.

Current `public.knowledge` lifecycle vocabulary is:

```text
CANDIDATE
ACCEPTED
INDEXED
ACTIVE
UPDATED
DEPRECATED
ARCHIVED
```

Current schema also contains:

```text
version
superseded_by
provenance
transfer_policy
scope
visibility
```

Current Knowledge candidate capture is authenticated and SH-scoped. It is an acquisition capability, not lifecycle promotion authority.

Current confirmation infrastructure exists but is explicitly constrained to recovery execution (`RECOVERY_RESTORE`). It is not silently reused for Knowledge lifecycle authority.

Historical Knowledge design establishes:

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

Historical `Validation` is reconciled as a process boundary, not a persisted lifecycle enum.

## 3. Reconciled Knowledge Lifecycle

The authoritative design representation for this gate is:

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
    ├──────────────→ UPDATED + superseded_by successor
    ↓
DEPRECATED
    ↓
ARCHIVED
```

Rules:

1. `VALIDATION` is a process, not a new enum value.
2. `CANDIDATE` does not imply `ACCEPTED`.
3. `ACCEPTED` does not imply `INDEXED`.
4. `INDEXED` does not imply `ACTIVE`.
5. Retrieval does not activate Knowledge.
6. Model confidence does not provide lifecycle authority.
7. Journey does not provide lifecycle authority.
8. Transfer materialization is separate from generic source-record lifecycle transition.
9. `UPDATED + superseded_by` is the current schema representation for supersession; do not add a `SUPERSEDED` enum without explicit authority.
10. `ARCHIVED` is terminal for the normal lifecycle path.

## 4. Transition Authority Matrix

| Transition | Authority | Required state | Result | Status |
|---|---|---|---|---|
| CANDIDATE → ACCEPTED | authorized validation/acceptance decision | CANDIDATE | ACCEPTED | DESIGN DEFINED / IMPLEMENTATION OPEN |
| ACCEPTED → INDEXED | authorized indexing operation | ACCEPTED | INDEXED | DESIGN DEFINED / IMPLEMENTATION OPEN |
| INDEXED → ACTIVE | authorized activation decision | INDEXED | ACTIVE | DESIGN DEFINED / IMPLEMENTATION OPEN |
| ACTIVE → UPDATED | authorized version/update operation | ACTIVE | successor + old UPDATED | DESIGN DEFINED / IMPLEMENTATION OPEN |
| ACTIVE → DEPRECATED | authorized deprecation operation | ACTIVE | DEPRECATED | DESIGN DEFINED / IMPLEMENTATION OPEN |
| DEPRECATED → ARCHIVED | authorized archive operation | DEPRECATED | ARCHIVED | DESIGN DEFINED / IMPLEMENTATION OPEN |

No transition may be implemented as unrestricted direct field mutation from the application/model layer.

## 5. CANDIDATE → ACCEPTED

### Authority

Acceptance is a governance/validation boundary.

Required inputs/evidence:

- authenticated actor;
- current account;
- active SH owned by the current account;
- Knowledge record owned by that SH/account;
- expected lifecycle = `CANDIDATE`;
- validation result;
- explicit acceptance decision reference;
- provenance;
- stable operation identity;
- audit;
- Journey projection if contract requires it.

Prohibited:

```text
model output → ACCEPTED
confidence alone → ACCEPTED
occurrence count → ACCEPTED
Journey replay → ACCEPTED
direct table mutation → ACCEPTED
```

## 6. ACCEPTED → INDEXED

`INDEXED` represents successful indexing/storage readiness.

Authority is the indexing operation, not semantic trust promotion.

Required:

```text
AUTH
→ OWNERSHIP
→ CURRENT = ACCEPTED
→ INDEXING AUTHORITY
→ OPERATION IDENTITY
→ MUTATION
→ AUDIT / PROVENANCE
→ JOURNEY IF REQUIRED
```

The historical direct SQL verification proving that the schema accepts `ACCEPTED → INDEXED` is storage evidence only; it is not production runtime authority.

## 7. INDEXED → ACTIVE

Activation requires an explicit authorized decision.

Required:

- authenticated actor;
- account/SH ownership;
- Knowledge ownership;
- expected lifecycle = `INDEXED`;
- activation authority;
- decision reference;
- confirmation if the approved risk contract requires it;
- provenance;
- stable operation key;
- atomic domain + Journey behavior where required.

Prohibited:

```text
retrieval → ACTIVE
search hit → ACTIVE
model confidence → ACTIVE
Journey replay → ACTIVE
```

## 8. ACTIVE → UPDATED / SUPERSEDED

Current schema semantics are version-oriented.

Preferred operation:

```text
ACTIVE(old)
    ↓
create successor
    ↓
ACTIVE(new)
    ↓
old.lifecycle = UPDATED
old.superseded_by = new
```

The old record remains historical evidence. Silent overwrite is prohibited where version history is required.

A separate `SUPERSEDED` lifecycle enum is not introduced by this reconciliation.

## 9. ACTIVE → DEPRECATED

Deprecation is explicit and independent from archival.

```text
ACTIVE
→ authorized deprecation
→ DEPRECATED
```

The operation must not silently archive the record unless a separate approved contract explicitly requires that behavior.

Retrieval eligibility of `DEPRECATED` is not changed by this document; current evidence only proves `INDEXED` and `ACTIVE` retrieval eligibility.

## 10. DEPRECATED → ARCHIVED

Archive is an explicit terminal transition:

```text
DEPRECATED
→ authorized archive
→ ARCHIVED
```

Normal lifecycle must reject:

```text
ARCHIVED → ACTIVE
ARCHIVED → UPDATED
ARCHIVED → DEPRECATED
```

Any restoration/resurrection behavior would require a separate recovery authority and contract.

## 11. Security Contract

Every transition must resolve authorization in this order:

```text
auth.uid()
→ current_account_id()
→ active SH ownership
→ Knowledge ownership
→ expected lifecycle guard
→ transition legality
→ scope / visibility / transfer policy
→ transition authority
→ confirmation authority if required
→ operation identity
→ mutation
```

Required negative verification:

- unauthenticated actor rejected;
- cross-account SH rejected;
- cross-actor/cross-account Knowledge ID rejected;
- wrong lifecycle rejected;
- superseded source rejected where applicable;
- terminal SH rejected where applicable;
- invalid scope/visibility rejected;
- invalid transfer policy rejected;
- model-only authority rejected;
- Journey-only replay rejected;
- duplicate logical operation handled idempotently.

For `SECURITY DEFINER` functions, implementation must explicitly verify:

- `auth.uid()` check;
- ownership checks;
- safe `search_path`;
- exact grants;
- anon rejection;
- authenticated exposure necessity;
- SQLSTATE/error contract.

## 12. Confirmation Contract

Existing high-risk confirmation infrastructure is recovery-specific:

```text
runtime_high_risk_confirmations
operation = RECOVERY_RESTORE
```

It is not a Knowledge lifecycle authority.

Knowledge transitions therefore require a separately defined confirmation/authorization policy if any transition is classified as confirmation-required.

This gate does not mutate the existing confirmation table or functions.

## 13. Operation Identity / Idempotency

Each externally retryable transition requires a stable logical operation identity.

Minimum conceptual identity:

```text
account
+ SH
+ knowledge_id
+ transition
+ operation_key
```

Provenance should additionally identify actor and decision/request correlation.

Required behavior:

```text
same operation + same target + same transition
→ SUCCESS or ALREADY_APPLIED

same operation + different target/transition
→ REJECTED
```

Content-based deduplication is not request-level lifecycle idempotency.

## 14. Provenance / Audit

A lifecycle transition must be traceable to:

```text
actor
account
SH
source Knowledge record
source signal/input
model/provider if applicable
decision
validation result if applicable
authorization/confirmation
transition
operation key
timestamp
resulting Knowledge record
Journey event if applicable
```

Existing `provenance` and `audit_events` infrastructure may be reused only after implementation verifies that it can represent the complete transition evidence without weakening authorization boundaries.

## 15. Atomicity / Journey

Preferred DB transaction boundary:

```text
AUTH
→ LOCK RECORD
→ VERIFY CURRENT STATE
→ VERIFY AUTHORITY
→ VERIFY POLICY
→ VERIFY OPERATION IDENTITY
→ MUTATE KNOWLEDGE
→ WRITE PROVENANCE / AUDIT
→ WRITE JOURNEY
→ COMMIT
```

No false success is permitted.

If domain mutation succeeds while required Journey projection fails, the operation must not report complete success. Prefer one DB transaction for the logical transition.

## 16. Transfer Reconciliation

Transfer-specific Knowledge materialization remains a separate contract.

```text
Transfer materialization
≠
Generic source Knowledge lifecycle transition
```

A transfer operation may materialize a target Knowledge record with transfer-specific lifecycle behavior, including target activation semantics where existing transfer contracts require it.

That behavior must not be reused to authorize source Knowledge lifecycle promotion.

## 17. Runtime API Direction

The previous generic activation proposal is rejected.

Preferred direction is domain-specific functions, for example:

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
```

Exact names/signatures remain implementation-contract work and are **not yet authorized as database objects**.

Each function must encode its expected current lifecycle and transition legality instead of exposing arbitrary `lifecycle` mutation.

## 18. Error Contract Direction

Implementation must distinguish at minimum:

```text
UNAUTHENTICATED
NOT_AUTHORIZED
SH_NOT_OWNED
RECORD_NOT_FOUND
WRONG_LIFECYCLE
INVALID_TRANSITION
INVALID_POLICY
DECISION_REQUIRED
CONFIRMATION_REQUIRED
OPERATION_CONFLICT
ALREADY_APPLIED
CONCURRENCY_CONFLICT
INTERNAL_FAILURE
```

Exact SQLSTATE mapping remains open until the implementation contract is finalized.

## 19. Verification Contract

Before the implementation gate can close, DEV evidence must prove:

### Positive

- each implemented transition succeeds from its expected state;
- resulting lifecycle is correct;
- provenance is recorded;
- audit is recorded;
- Journey projection is correct where required;
- retry returns the defined idempotent result.

### Negative

- unauthenticated rejected;
- cross-account rejected;
- cross-SH rejected;
- wrong lifecycle rejected;
- terminal state rejected;
- model-only authority rejected;
- Journey-only replay rejected.

### Concurrency

At least two concurrent attempts against the same source record must not create an invalid duplicate transition/successor or inconsistent Journey history.

### Reconciliation

After each implementation stage:

```text
Supabase actual state
↔ migration history
↔ GitHub source
```

must be reconciled.

## 20. Implementation Gate

Current result:

```text
Historical lifecycle intent       = RECONCILED
Current schema vocabulary         = VERIFIED
Validation process boundary       = RECONCILED
Transition matrix                 = DEFINED
Security model                    = DEFINED
Confirmation boundary             = RECONCILED
Operation identity                = DEFINED
Provenance requirements           = DEFINED
Journey atomicity target          = DEFINED
Transfer separation               = RECONCILED
Exact DB API implementation       = OPEN
SQLSTATE mapping                  = OPEN
Runtime implementation            = OPEN
Positive E2E                      = OPEN
Negative E2E                      = OPEN
Concurrency E2E                   = OPEN

IMPLEMENTATION GATE = CLOSED
```

## 21. Change Record

```text
Supabase schema changes = NONE
Supabase data changes   = NONE
Migration changes       = NONE
Runtime code changes    = NONE
Canonical changes       = NONE
Working documentation   = CREATED
Baseline                 = PRESERVED
```

## 22. Next Engineering Gate

**Knowledge Transition Implementation Contract + Full-Write Plan**

Before touching Supabase:

1. finalize exact per-transition API signatures;
2. finalize authority source for each transition;
3. finalize confirmation requirement per transition;
4. finalize operation ledger/idempotency representation;
5. finalize provenance/audit representation;
6. finalize atomic Knowledge + Journey transaction implementation;
7. finalize grants/exposure and `SECURITY DEFINER` policy;
8. finalize SQLSTATE mapping;
9. define exact positive/negative/concurrency E2E tests;
10. then implement in Supabase DEV first, verify actual state, generate clean migration history, and reconcile GitHub.

No database mutation is authorized by this document itself.
