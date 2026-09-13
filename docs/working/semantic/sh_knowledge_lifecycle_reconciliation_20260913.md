# SECOND HEAD — Knowledge Lifecycle Reconciliation + Confirmation Contract Integration — 2026-09-13

## Status

**WORKING RECONCILIATION RECORD — PARTIAL PASS — IMPLEMENTATION GATE CLOSED**

## 1. Objective

Mereconcile semantic transition contract dengan evidence lifecycle Knowledge yang aktual di DEV dan mengintegrasikan pola confirmation yang sudah ada tanpa memperlakukan recovery confirmation sebagai authority lifecycle generik.

Record ini tidak mengotorisasi perubahan runtime, migration, data, atau Canonical.

## 2. Evidence Summary

Constraint aktual `public.knowledge.lifecycle` di DEV mengizinkan:

```text
CANDIDATE
ACCEPTED
INDEXED
ACTIVE
UPDATED
DEPRECATED
ARCHIVED
```

Data DEV yang diamati selama review ini hanya berisi row dengan lifecycle `CANDIDATE`.

Function runtime untuk candidate Knowledge saat ini melakukan persistence pada `CANDIDATE`; belum ada evidence untuk function activation khusus.

## 3. Retrieval Semantics

`retrieve_knowledge_bounded` yang sudah ada menggunakan SECURITY INVOKER dan hanya mengambil Knowledge dengan:

```text
scope = GENERAL
visibility = SHARED
lifecycle IN ('INDEXED', 'ACTIVE')
```

Karena itu `INDEXED` merupakan state eligibility retrieval yang eksplisit, tetapi semantics retrieval saja tidak membuktikan bahwa setiap record Knowledge wajib melewati `CANDIDATE → ACCEPTED → INDEXED → ACTIVE`.

## 4. Historical Transition Evidence

Migration verification untuk indexing mendemonstrasikan update SQL langsung yang bersifat synthetic:

```text
ACCEPTED → INDEXED
```

Ini hanya merupakan verification terhadap vocabulary storage/lifecycle, bukan bukti adanya production authorization API atau workflow transition yang lengkap.

Belum ada evidence saat ini yang menetapkan production transition function untuk:

- `CANDIDATE → ACCEPTED`;
- `INDEXED → ACTIVE`;
- `CANDIDATE → ACTIVE`;
- `ACTIVE → UPDATED`;
- `ACTIVE → DEPRECATED`;
- `ACTIVE → ARCHIVED`.

## 5. Reconciliation Decision

Contract sebelumnya yang menetapkan direct:

```text
CANDIDATE → ACTIVE
```

TIDAK BOLEH diam-diam dianggap sebagai Knowledge transition yang sudah diimplementasikan atau canonical.

Status saat ini:

```text
Knowledge lifecycle vocabulary = EXISTING
Knowledge retrieval gate       = INDEXED / ACTIVE
Candidate capture              = EXISTING
Candidate activation API       = MISSING
Full transition authority      = UNKNOWN
Direct CANDIDATE → ACTIVE      = NOT PROVEN
Intermediate chain mandatory   = NOT PROVEN
```

Karena itu activation Knowledge tetap blocked sampai ada domain decision yang eksplisit dan reconciliation evidence yang mencakup transition authority serta indexing semantics.

## 6. Confirmation Integration

Sistem confirmation yang durable sudah ada di DEV melalui `runtime_high_risk_confirmations` dengan `action_id` yang unique dan status seperti `PENDING`, `CONFIRMED`, `EXECUTED`, `CANCELLED`, dan `EXPIRED`.

Execution semantics saat ini terbatas pada domain `RECOVERY_RESTORE`.

Decision:

```text
Recovery confirmation = EXISTING
Semantic lifecycle confirmation = NOT CONTRACTED
```

Transition lifecycle tidak boleh menerima reference recovery confirmation seolah-olah reference tersebut merupakan authorization generik.

Jika semantic activation memerlukan `CONFIRM`, contract semantic confirmation yang terpisah harus mengikat minimal:

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

Transition contract tetap:

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

Model output dan confidence bukan authority. Journey adalah projection/history, bukan authority.

## 8. Database Implementation Constraint

Jika implementation nantinya diotorisasi, activation boundary yang dipilih adalah satu PostgreSQL transaction yang melakukan lock pada target record, memvalidasi authority dan expected lifecycle, menyelesaikan operation identity, mengubah lifecycle, mencatat provenance/audit, serta menghasilkan Journey projection yang diperlukan sebelum commit.

Evidence saat ini tidak membuktikan bahwa activation transaction tersebut sudah ada.

## 9. Required Evidence Before Implementation

1. domain decision Knowledge yang eksplisit untuk transition path;
2. mapping authoritative untuk `ACCEPTED`, `INDEXED`, dan `ACTIVE`;
3. production transition function/API atau verification bahwa function tersebut memang tidak ada;
4. confirmation semantics yang tepat untuk semantic lifecycle;
5. persistence untuk operation identity;
6. Journey event contract;
7. exposure/grants SECURITY DEFINER;
8. SQLSTATE/error mapping;
9. desain positive/negative/concurrency E2E.

## 10. Final Decision

**KNOWLEDGE LIFECYCLE RECONCILIATION = PARTIAL PASS / BLOCKED**

Vocabulary database dan retrieval boundary sudah dipahami, dan finding terkait confirmation sebelumnya sudah dikoreksi: infrastructure confirmation yang durable memang ada, tetapi khusus untuk recovery.

Transition authority untuk Knowledge belum memiliki evidence yang cukup untuk mengotorisasi implementation.

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
