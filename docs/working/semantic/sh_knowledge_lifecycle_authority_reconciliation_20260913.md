# SECOND HEAD — Knowledge Lifecycle Authority Reconciliation — 2026-09-13

## Status

**WORKING AUTHORITY RECONCILIATION — PARTIAL PASS — IMPLEMENTATION GATE CLOSED**

## 1. Objective

Menentukan authority yang tersedia untuk Knowledge lifecycle berdasarkan Canonical DEV, historical design `dev_old`, current DEV implementation, Supabase DEV state, retrieval semantics, dan existing semantic policy.

Dokumen ini tidak mengubah Canonical, Approved Contract, runtime code, migration, atau data.

## 2. Authority Order

```text
OWNER / USER DECISION
        ↓
CANONICAL
        ↓
APPROVED CONTRACT
        ↓
ARCHITECTURE / DESIGN
        ↓
WORKING RECONCILIATION
        ↓
IMPLEMENTATION
        ↓
RUNTIME / DATABASE EVIDENCE
        ↓
E2E VERIFICATION
```

Historical `dev_old` design diperlakukan sebagai historical architecture/design evidence, bukan sebagai current implementation evidence.

## 3. Historical Knowledge Lifecycle Authority

`dev_old/docs/design/P3D_KNOWLEDGE_SCHEMA_v1.0.md` secara eksplisit merujuk lifecycle:

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

Dokumen tersebut juga menyatakan lifecycle implementation sebagai backlog berikutnya, sehingga lifecycle sequence adalah **design authority/history**, bukan bukti bahwa runtime transition function sudah ada.

## 4. Historical Acquisition / Validation / Classification Boundary

Historical P3D design memisahkan:

```text
SOURCE / MEMORY / EXPLICIT TEACHING / EXTERNAL REFERENCE
                         ↓
                    ACQUISITION
                         ↓
               KNOWLEDGE CANDIDATE
                         ↓
                    VALIDATION
                         ↓
                   NORMALIZATION
                         ↓
                  CLASSIFICATION
                         ↓
          TRUST / STORAGE / PROVENANCE / INDEXING
```

Validation outcome yang ditetapkan adalah:

```text
VALID
INVALID
NEEDS_REVIEW
```

Classification bukan truth adjudication dan bukan trust promotion.

Dengan demikian historical design mendukung pemisahan **candidate → validation → downstream governance/trust/storage/indexing**, tetapi tidak menyediakan current runtime authorization function untuk setiap state.

## 5. Current DEV Database Reconciliation

Current `public.knowledge.lifecycle` constraint mengizinkan:

```text
CANDIDATE
ACCEPTED
INDEXED
ACTIVE
UPDATED
DEPRECATED
ARCHIVED
```

Current DEV data pada review ini hanya menunjukkan `CANDIDATE` Knowledge rows.

Current runtime candidate functions juga menulis `CANDIDATE`.

Tidak ada dedicated current `runtime_activate_knowledge_candidate` yang terbukti.

## 6. Retrieval Authority Reconciliation

Current retrieval boundary hanya mengekspos:

```text
GENERAL
+
SHARED
+
INDEXED / ACTIVE
```

`retrieve_knowledge_bounded` adalah `SECURITY INVOKER`.

Kesimpulan:

```text
INDEXED = retrieval-eligible state
ACTIVE   = retrieval-eligible state
```

Tetapi retrieval eligibility tidak membuktikan bahwa `INDEXED` harus selalu menjadi mandatory predecessor untuk `ACTIVE` pada setiap acquisition path.

## 7. Lifecycle Decision

Berdasarkan evidence yang tersedia, lifecycle semantics yang paling authoritative saat ini adalah:

```text
CANDIDATE
    ↓
VALIDATION
    ↓
ACCEPTED
    ↓
INDEXED
    ↓
ACTIVE
    ↓
UPDATED / DEPRECATED / ARCHIVED
```

**Important:** `VALIDATION` adalah process boundary dalam historical design, bukan lifecycle enum pada current database.

Karena itu implementation tidak boleh mengarang function transition hanya berdasarkan nama enum.

### Direct CANDIDATE → ACTIVE

Status:

**NOT AUTHORIZED / NOT PROVEN**

Tidak ada evidence cukup untuk menjadikan direct `CANDIDATE → ACTIVE` sebagai universal Knowledge transition.

### CANDIDATE → ACCEPTED

Status:

**SEMANTICALLY REQUIRED AS HISTORICAL DESIGN STAGE; CURRENT RUNTIME AUTHORITY OPEN**

### ACCEPTED → INDEXED

Status:

**STORAGE/LIFECYCLE EVIDENCE EXISTS; PRODUCTION AUTHORITY OPEN**

Historical verification explicitly performs `ACCEPTED → INDEXED`, but this is not proof of a production authorization API.

### INDEXED → ACTIVE

Status:

**CURRENT AUTHORITY OPEN**

The state exists and is retrieval-eligible, but no current transition function/authorization path has been evidenced.

## 8. Confirmation Contract Reconciliation

Existing durable confirmation infrastructure is:

```text
runtime_high_risk_confirmations
        ↓
action_id UNIQUE
        ↓
PENDING → CONFIRMED → EXECUTED
```

Current execution is explicitly restricted to `RECOVERY_RESTORE`.

Therefore:

```text
Recovery confirmation          = EXISTING
Knowledge lifecycle confirmation = NOT YET CONTRACTED
```

Semantic activation must not reuse recovery confirmation implicitly.

## 9. Security Authority

Any future Knowledge transition must preserve:

```text
auth.uid()
→ current_account_id()
→ active SH ownership
→ record ownership
→ domain validation
→ expected lifecycle
→ legal transition
→ scope / visibility
→ decision / confirmation authority
→ operation identity
→ atomic mutation
```

Model output, confidence, Journey event, and record ID are not authority sources.

## 10. Final Reconciliation

The historical design resolves the major semantic ambiguity: Knowledge was intentionally designed as a staged pipeline rather than an unqualified direct candidate-to-active promotion.

However, it does **not** provide enough current runtime evidence to implement the transition functions safely.

Therefore the current contract must be interpreted as:

```text
ACQUISITION
   ↓
CANDIDATE
   ↓
VALIDATION
   ↓
ACCEPTED
   ↓
INDEXED
   ↓
ACTIVE
```

with the following caveat:

```text
Each state transition requires a separately evidenced authority/function.
```

No generic lifecycle engine is authorized.

## 11. Required Implementation Gates

Before any Knowledge transition implementation:

1. identify or establish the authority for `CANDIDATE → ACCEPTED`;
2. identify or establish the authority for `ACCEPTED → INDEXED`;
3. identify or establish the authority for `INDEXED → ACTIVE`;
4. define semantic confirmation if `CONFIRM` is used;
5. define operation identity persistence;
6. define atomic domain + Journey boundary;
7. define provenance/audit contract;
8. review SECURITY DEFINER/EXECUTE exposure;
9. define SQLSTATE/error contract;
10. execute authenticated positive, negative, and concurrency verification.

## 12. Decision

**KNOWLEDGE LIFECYCLE AUTHORITY RECONCILIATION = PARTIAL PASS**

Semantic lifecycle intent is now sufficiently resolved from historical design to reject the previous assumption that direct `CANDIDATE → ACTIVE` is the default universal path.

Implementation remains blocked because current runtime authorization for the individual lifecycle transitions is not yet evidenced.

## 13. Change Boundary

```text
GitHub DEV docs          = CHANGED
Runtime code             = UNCHANGED
Supabase schema          = UNCHANGED
Supabase data            = UNCHANGED
Migration                = UNCHANGED
Canonical                = UNCHANGED
Runtime behavior         = UNCHANGED
```

## 14. Next Gate

**Knowledge Transition Authority Capability Audit**

Audit separately:

```text
CANDIDATE → ACCEPTED
ACCEPTED  → INDEXED
INDEXED   → ACTIVE
ACTIVE    → UPDATED / SUPERSEDED
ACTIVE    → DEPRECATED
DEPRECATED → ARCHIVED
```

For each transition, prove function, actor authority, ownership, lifecycle guard, policy, transaction, Journey, provenance, idempotency, failure behavior, grants, and E2E capability before implementation.
