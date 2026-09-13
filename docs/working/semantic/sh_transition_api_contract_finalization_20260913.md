# SECOND HEAD — Transition API Contract Finalization — 2026-09-13

## Status

**WORKING CONTRACT — FINALIZATION REVIEW / PARTIAL PASS — IMPLEMENTATION GATE CLOSED**

Dokumen ini mengunci bentuk API transition yang dapat disepakati dari evidence dan design review saat ini. Dokumen ini belum mengotorisasi migration atau runtime implementation.

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
THIS WORKING CONTRACT
        ↓
IMPLEMENTATION
        ↓
RUNTIME / DATABASE EVIDENCE
        ↓
E2E VERIFICATION
```

Jika authority yang lebih tinggi bertentangan, authority yang lebih tinggi menang.

---

## 1. Scope

Scope transition semantik:

- Memory `CANDIDATE → ACTIVE`;
- Knowledge `CANDIDATE → ACTIVE`;
- Memory replacement tetap menggunakan capability domain-specific yang sudah ada;
- Knowledge update/supersede hanya setelah semantics disetujui;
- Experience candidate lifecycle belum diaktifkan oleh contract ini;
- Journey tetap projection/history, bukan lifecycle authority.

Tidak termasuk:

- generic lifecycle engine;
- direct table mutation dari AI runtime;
- perubahan Canonical;
- migration implementation;
- runtime implementation.

---

## 2. Contract Decision

Pendekatan final yang dipilih untuk API shape:

```text
DOMAIN-SPECIFIC TRANSITION FUNCTION
        ↓
AUTHENTICATED ACTOR
        ↓
SH + RECORD OWNERSHIP
        ↓
EXPECTED CURRENT LIFECYCLE
        ↓
TRANSITION AUTHORITY
        ↓
POLICY / CONFIRMATION
        ↓
OPERATION IDENTITY
        ↓
ATOMIC DOMAIN + JOURNEY
        ↓
PROVENANCE
```

Tidak ada arbitrary domain mutation endpoint.

---

## 3. Exact Transition API Names

Nama function yang dikunci sebagai **contract target**, bukan implementation evidence:

### Memory

`runtime_activate_memory_candidate`

### Knowledge

`runtime_activate_knowledge_candidate`

Nama tersebut harus diperlakukan sebagai API contract target. Function belum ada pada DEV dan belum boleh dianggap implemented.

Experience tidak memiliki activation API pada contract ini karena candidate lifecycle Experience belum ditetapkan.

---

## 4. Input Contract — Memory

Conceptual signature:

```text
runtime_activate_memory_candidate(
  p_memory_id uuid,
  p_expected_lifecycle text,
  p_operation_key text,
  p_decision_ref text,
  p_confirmation_ref text,
  p_provenance jsonb
) → uuid
```

Rules:

- `p_memory_id` adalah stable record identity;
- `p_expected_lifecycle` wajib `CANDIDATE` untuk activation;
- `p_operation_key` wajib stabil untuk retry-safe operation;
- `p_decision_ref` wajib menghubungkan semantic decision;
- `p_confirmation_ref` wajib bila policy/decision menghasilkan `CONFIRM`;
- `p_provenance` wajib membawa transition provenance.

Caller tidak boleh menentukan account authority melalui input account ID.

---

## 5. Input Contract — Knowledge

Conceptual signature:

```text
runtime_activate_knowledge_candidate(
  p_knowledge_id uuid,
  p_expected_lifecycle text,
  p_operation_key text,
  p_decision_ref text,
  p_confirmation_ref text,
  p_provenance jsonb
) → uuid
```

Rules identik pada boundary security dan idempotency, dengan domain-specific lifecycle/policy validation untuk Knowledge.

---

## 6. Output Contract

Successful transition:

```text
uuid = resulting record id
```

The resulting record must be verifiably `ACTIVE`.

Operational result categories:

```text
SUCCESS
ALREADY_APPLIED
REJECTED
FAILED
```

`ALREADY_APPLIED` hanya valid apabila operation identity dapat direkonsiliasi terhadap operasi yang sama.

Duplicate operation key dengan payload/target berbeda harus **REJECTED**, bukan dianggap idempotent.

---

## 7. Authorization Contract

Mandatory order:

```text
auth.uid()
    ↓
current_account_id()
    ↓
active SH ownership
    ↓
record ownership
    ↓
record domain
    ↓
expected lifecycle
    ↓
transition legality
    ↓
scope / visibility / transfer policy
    ↓
confirmation authority
    ↓
decision authority
    ↓
operation identity
    ↓
mutation
```

Model output tidak pernah menjadi authorization source.

`confidence` bukan authorization.

Journey event bukan authorization.

Record ID saja tidak membuktikan ownership.

---

## 8. Lifecycle Contract

### Memory

```text
CANDIDATE → ACTIVE
```

Allowed only when all transition preconditions pass.

`UPDATED`, superseded, terminal, atau state lain yang tidak legal untuk activation harus ditolak.

Existing `runtime_replace_memory` tetap merupakan replacement operation dan tidak diubah menjadi activation API.

### Knowledge

```text
CANDIDATE → ACTIVE
```

Same transition boundary, tetapi Knowledge-specific policy validation tetap wajib.

### Experience

```text
CANDIDATE → ACTIVE
```

**NOT CONTRACTED.**

Current runtime creates Experience as `ACTIVE`; contract ini tidak mengubah semantics tersebut.

---

## 9. Decision / Confirmation Contract

Existing semantic decision vocabulary:

```text
ACCEPT
REJECT
CONFIRM
```

Evidence runtime saat ini menunjukkan USER signal dapat menghasilkan `ACCEPT`, sedangkan model-derived signal dapat menghasilkan `REJECT` atau `CONFIRM`; tidak ada evidence bahwa `CONFIRM` sudah memiliki durable confirmation mechanism. fileciteturn28file0L1-L6

Contract rule:

```text
REJECT
  → transition forbidden

CONFIRM
  → explicit authorized confirmation required

ACCEPT
  → still subject to ownership, lifecycle, policy, idempotency, and transition authority
```

**Confirmation authority remains an implementation blocker.**

No function may infer confirmation merely from confidence or model output.

---

## 10. Idempotency Contract

Every activation request requires:

```text
operation_key
```

Logical identity:

```text
actor/account
+ SH
+ domain
+ source_record_id
+ transition
+ operation_key
```

Required behavior:

- same operation + same target → `SUCCESS` or `ALREADY_APPLIED` according to persisted operation state;
- same operation key + different target/transition → `REJECTED`;
- different operation keys → independently evaluated;
- content equality does not establish operation identity.

A transition must not depend on content-based deduplication for retry safety.

---

## 11. Provenance Contract

Transition provenance must preserve:

```text
actor/account
SH
source_record_id
source_signal/source_ref
model/provider (when applicable)
decision
authorization/confirmation
transition
operation_key
timestamp
resulting_record_id
journey_event_id
```

Free-form source text alone is insufficient for transition auditability.

---

## 12. Transaction Contract

Preferred atomic boundary:

```text
BEGIN
  authenticate / authorize
  resolve source record
  verify expected lifecycle
  verify policy / confirmation
  resolve operation identity
  mutate domain lifecycle
  persist transition provenance
  persist required Journey projection
COMMIT
```

Domain mutation and Journey projection must commit together where technically possible.

If implementation cannot provide one DB transaction, the implementation contract must explicitly define intermediate state and reconciliation. It must not return false success.

Atomicity is **not yet evidenced** in current runtime and therefore remains a blocker.

---

## 13. Journey Contract

Journey is downstream projection/history.

Activation should emit an appropriate lifecycle event containing at minimum:

```text
source_record_id
resulting_record_id
previous_lifecycle
new_lifecycle
transition
operation_key
provenance reference
```

Journey replay cannot activate a record.

Journey editing cannot authorize activation.

Journey must retain the same ownership/security boundary as the source SH.

Exact event payload vocabulary must be reconciled against existing Journey conventions during implementation review.

---

## 14. Error Contract

Errors must be machine-classifiable and must not imply success.

Minimum categories:

```text
TRANSITION_REJECTED: authentication required
TRANSITION_REJECTED: SH not owned by current active account
TRANSITION_REJECTED: record not owned by current actor
TRANSITION_REJECTED: invalid domain
TRANSITION_REJECTED: unexpected lifecycle
TRANSITION_REJECTED: illegal transition
TRANSITION_REJECTED: policy violation
TRANSITION_REJECTED: confirmation required
TRANSITION_REJECTED: invalid operation key
TRANSITION_REJECTED: operation conflict
TRANSITION_FAILED: domain mutation failed
TRANSITION_FAILED: journey projection failed
```

Exact SQLSTATE/error-code mapping remains an implementation-level security/DB review item and must be standardized before implementation.

---

## 15. Security / Grants Contract

Target function requirements:

- anonymous execution denied;
- authenticated execution only where appropriate;
- explicit `auth.uid()` validation;
- current-account resolution server-side;
- active SH ownership validation;
- record ownership validation;
- lifecycle validation inside mutation boundary;
- policy validation inside mutation boundary;
- no client-supplied authority bypass;
- no arbitrary table mutation;
- safe `search_path` if `SECURITY DEFINER` is required;
- function exposure reviewed before release.

`SECURITY DEFINER` is not permitted merely to bypass a permission/RLS error.

---

## 16. Knowledge Update / Supersede

**STATUS: OPEN.**

This finalization contract does not invent Knowledge update/supersede semantics.

Required before implementing Knowledge update/supersede:

- successor semantics;
- version behavior;
- `superseded_by` behavior;
- lifecycle vocabulary;
- Journey event semantics;
- provenance relationship.

Therefore only Knowledge `CANDIDATE → ACTIVE` is contracted here.

---

## 17. Experience Lifecycle

**STATUS: OPEN.**

Current runtime creates Experience as `ACTIVE`.

No candidate transition API is authorized until a domain decision establishes whether Experience requires candidate review at all.

---

## 18. Verification Contract

### Positive

1. authenticated owner activates owned Memory candidate;
2. authenticated owner activates owned Knowledge candidate;
3. expected lifecycle matches;
4. policy is valid;
5. confirmation is valid when required;
6. resulting record becomes `ACTIVE`;
7. Journey projection exists;
8. provenance is complete;
9. retry with same operation identity is idempotent.

### Negative

1. unauthenticated;
2. cross-account SH;
3. cross-actor record ID;
4. wrong expected lifecycle;
5. superseded/terminal record;
6. invalid policy;
7. missing confirmation;
8. model-only authority;
9. operation-key conflict;
10. Journey replay;
11. arbitrary account ID injection;
12. invalid domain/record pairing.

### Concurrency

Two requests against the same candidate must prove:

```text
A → SUCCESS
B → REJECTED or ALREADY_APPLIED
```

and must never produce two unintended activation results or duplicate transition history.

---

## 19. Implementation Preconditions

The following remain mandatory blockers:

| Gate item | Status |
|---|---|
| Memory activation API shape | DEFINED |
| Knowledge activation API shape | DEFINED |
| Exact function target names | DEFINED AS CONTRACT TARGET |
| Input/output contract | DEFINED |
| Authorization boundary | DEFINED |
| Lifecycle guard | DEFINED |
| Idempotency contract | DEFINED |
| Provenance contract | DEFINED |
| Journey behavior | DEFINED / exact payload OPEN |
| Confirmation authority | **OPEN / BLOCKER** |
| Atomic domain + Journey | **OPEN / BLOCKER** |
| Knowledge update/supersede | **OPEN / BLOCKER FOR THAT DOMAIN** |
| Experience lifecycle | **OPEN / BLOCKER FOR THAT DOMAIN** |
| Security/DEFiner exposure review | **OPEN / BLOCKER** |
| Exact SQLSTATE mapping | OPEN |
| Positive E2E | PLANNED |
| Negative/cross-actor E2E | PLANNED |
| Concurrency E2E | PLANNED |

---

## 20. Decision

**TRANSITION API CONTRACT FINALIZATION = PARTIAL PASS**

The API boundary and core security/lifecycle/idempotency/provenance design are sufficiently defined to prevent speculative implementation.

However, the contract cannot be promoted to an implementation-authorizing contract because confirmation authority, atomicity proof, and security exposure review remain unresolved.

```text
API SHAPE                    = DEFINED
AUTHORIZATION               = DEFINED
LIFECYCLE GUARD             = DEFINED
IDEMPOTENCY                 = DEFINED
PROVENANCE                  = DEFINED
JOURNEY CONTRACT            = DEFINED / PAYLOAD RECONCILIATION OPEN
CONFIRMATION AUTHORITY      = OPEN
ATOMICITY                   = OPEN
SECURITY EXPOSURE REVIEW    = OPEN
KNOWLEDGE UPDATE/SUPERSEDE = OPEN
EXPERIENCE LIFECYCLE        = OPEN
IMPLEMENTATION GATE         = CLOSED
```

---

## 21. Next Gate

**Security + Database Transition Design Review**

Fokus:

1. exact DB mutation strategy;
2. row-lock / concurrency strategy;
3. operation identity persistence;
4. transaction boundary with Journey;
5. provenance persistence;
6. SECURITY DEFINER vs INVOKER decision;
7. function ownership/search_path;
8. EXECUTE grants;
9. RLS interaction;
10. SQLSTATE/error mapping;
11. test harness feasibility;
12. confirmation authority integration point.

Only after this review closes may migration/runtime implementation be considered.

---

## 22. Change Boundary

```text
GitHub DEV docs          = CHANGED
Runtime code             = UNCHANGED
Supabase schema          = UNCHANGED
Supabase data            = UNCHANGED
Migration                = UNCHANGED
Canonical                = UNCHANGED
Runtime behavior         = UNCHANGED
```
