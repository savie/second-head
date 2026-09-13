# SECOND HEAD — Security + Database Transition Design Review — 2026-09-13

## Status

**WORKING AUDIT / DESIGN REVIEW — PARTIAL PASS — IMPLEMENTATION GATE CLOSED**

Dokumen ini mencatat evidence DEV saat ini untuk semantic lifecycle transition boundary. Dokumen ini tidak mengotorisasi runtime implementation, migration, atau perubahan Canonical.

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

Tidak ada implementation changes yang dibuat oleh review ini.

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

Current DEV data contains only `CANDIDATE` Knowledge rows at the time of review. Ini tidak membuktikan bahwa complete lifecycle transition chain sudah implemented.

### Confirmation

`public.runtime_high_risk_confirmations` exists with durable action identity and status fields. `action_id` is unique. Current confirmation mechanism is domain-limited: existing runtime confirmation execution is for `RECOVERY_RESTORE`; ini bukan evidence generic semantic lifecycle confirmation authority.

### Audit

`public.audit_events` exists with `account_id`, `sh_id`, `event_type`, `status`, `metadata`, and timestamps. Ini dapat digunakan sebagai audit boundary, tetapi current evidence belum menetapkan complete semantic transition operation ledger.

## 3. Current Knowledge Runtime Functions

DEV exposes:

- `retrieve_knowledge_bounded` — SECURITY INVOKER;
- `runtime_record_knowledge_candidate` — SECURITY DEFINER;
- `runtime_record_knowledge_with_journey` — SECURITY DEFINER.

Kedua candidate-write functions secara eksplisit memerlukan authenticated identity dan active SH ownership melalui `current_account_id()`, memvalidasi content/source/origin/scope/visibility/confidence, dan menyimpan lifecycle `CANDIDATE`.

No current dedicated `runtime_activate_knowledge_candidate` function was evidenced.

## 4. Critical Reconciliation — Knowledge Lifecycle

Earlier transition contract specified:

```text
CANDIDATE → ACTIVE
```

Actual DEV schema permits intermediate states:

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE
```

Namun current runtime evidence belum menetapkan bahwa exact chain ini adalah authoritative operational path, dan belum membuktikan actor/function yang berwenang untuk setiap transition.

Karena itu direct `CANDIDATE → ACTIVE` harus diperlakukan sebagai **CONTRACT CONFLICT / RECONCILIATION REQUIRED**, bukan diasumsikan legal secara diam-diam.

Tidak boleh membuat implementation sampai Knowledge lifecycle authority dan transition chain direkonsiliasi terhadap migration/history dan existing retrieval/indexing semantics.

## 5. Confirmation Authority

Correction terhadap prior working-contract wording:

System memang memiliki durable confirmation mechanism.

Current evidence establishes:

```text
runtime_high_risk_confirmations
        ↓
action_id UNIQUE
        ↓
PENDING → CONFIRMED → EXECUTED / CANCELLED / EXPIRED
```

Namun current mechanism scoped to high-risk recovery execution. Mekanisme ini tidak boleh digunakan kembali untuk semantic activation hanya dengan memberikan confirmation reference. Semantic lifecycle confirmation contract harus secara eksplisit mendefinisikan:

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

Current semantic runtime contains separate domain and Journey RPC paths in existing capture flows; karena itu whole-path atomicity **NOT PROVEN**.

Untuk activation, satu DB transaction merupakan preferred correctness boundary. Jika Journey tidak dapat dimasukkan secara atomic, contract harus mendefinisikan intermediate state dan reconciliation, bukan mengembalikan false success.

## 8. Concurrency

Candidate write path menggunakan `FOR UPDATE` ketika me-resolve existing candidate, yang menjadi useful precedent untuk row locking, tetapi ini bukan proof activation concurrency safety.

Activation harus lock target candidate dan menetapkan operation identity sebelum mutation sehingga concurrent requests tidak menghasilkan duplicate activation history.

Required verification:

```text
A → SUCCESS
B → ALREADY_APPLIED or REJECTED
```

Tidak boleh ada duplicate unintended transition/Journey records.

## 9. Operation Identity

Existing confirmation infrastructure menyediakan unique `action_id` pattern. Ini merupakan useful precedent, tetapi belum menjadi semantic lifecycle operation ledger.

Transition activation tetap membutuhkan stable logical operation key yang terikat pada actor/account + SH + domain + source record + transition.

Content-based deduplication tidak cukup untuk retry safety.

## 10. Provenance / Audit

Knowledge already has mandatory `provenance` JSONB. Audit events menyediakan account/SH/event/status/metadata. Transition contract harus mengikatnya dengan:

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

Ini hanya reference pattern. Pattern tersebut tidak mengotorisasi copy tanpa review terhadap:

- function owner;
- exact `search_path`;
- EXECUTE grants;
- RLS interaction;
- arbitrary SQL/table access;
- identity resolution;
- input validation;
- error leakage.

`SECURITY DEFINER` tidak boleh diperkenalkan hanya untuk bypass permission problem.

## 12. Error Contract

Exact SQLSTATE/error-code mapping remains open. Implementation harus membedakan rejected authorization/policy/lifecycle requests dari runtime/database failures dan tidak boleh mengembalikan false success.

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

Security boundary dan database primitives sudah cukup dipahami untuk mendefinisikan implementation constraints, tetapi implementation tetap blocked.

Prioritas reconciliation tertinggi adalah Knowledge lifecycle authority. Existing confirmation mechanism juga harus secara eksplisit diperluas/dikontrakkan untuk semantic lifecycle jika confirmation memang diperlukan; recovery confirmation tidak boleh diperlakukan sebagai generic authorization.

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
