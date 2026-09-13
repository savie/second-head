# SECOND HEAD — Semantic Lifecycle Policy Reconciliation — 2026-09-13

## Status

**WORKING — HASIL REKONSILIASI POLICY / PARTIAL PASS / IMPLEMENTATION GATE BELUM DITUTUP**

Catatan ini merekonsiliasi Semantic Lifecycle Policy Contract yang sedang digunakan dengan baseline Canonical DEV saat ini, implementasi runtime, riwayat migration, serta permukaan function/schema Supabase yang sedang berjalan.

Tidak ada dokumen Canonical, approved contract, runtime code, atau database migration yang diubah oleh catatan ini.

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

Otoritas yang lebih tinggi selalu berlaku. Tidak ada conflict yang digabung secara diam-diam.

## 1. Reconciliation Scope

Rantai policy yang diperiksa:

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

Sumber yang diperiksa:

- `docs/working/semantic/sh_semantic_lifecycle_policy_contract.md`
- `docs/working/semantic/sh_full_semantic_lifecycle_verification_20260913.md`
- `docs/canonical/sh_foundation_blueprint.md`
- `functions/ai-runtime/semantic_decision.ts`
- `functions/ai-runtime/semantic_lifecycle.ts`
- riwayat migration lifecycle/transfer
- function dan schema surface Supabase DEV saat ini

## 2. Reconciliation Findings

### 2.1 Model is not authority

**Status: RECONCILED / PASS**

Canonical foundation secara eksplisit memisahkan Model dari SH Identity dan menyatakan `Model ≠ Authority`. Canonical juga menetapkan privacy default-deny dan authorization eksplisit untuk sharing.

Implementasi semantic decision saat ini mengikuti batas yang sama: output model diperlakukan sebagai candidate dan `evaluateSemanticSignal()` hanya mengembalikan `ACCEPT`, `REJECT`, atau `CONFIRM`.

Tidak ditemukan evidence bahwa output model dimaksudkan untuk langsung menjadi authority semantik durable.

### 2.2 Explicit user capture authority

**Status: RECONCILED / PASS untuk path yang sudah diuji**

Runtime explicit capture yang ada menggunakan function persistence spesifik domain untuk Memory, Knowledge, dan Experience serta proyeksi Journey.

Hal ini konsisten dengan prinsip policy kerja bahwa explicit user capture memiliki capture authority lebih tinggi daripada model inference, sementara ownership dan domain authorization tetap berlaku.

### 2.3 Candidate semantics

**Status: PARTIAL / OPEN**

`CANDIDATE` ada dalam vocabulary lifecycle database saat ini dan digunakan oleh code semantic capture serta transfer.

Namun implementasi transfer saat ini dapat mematerialisasi source `CANDIDATE` menjadi `ACTIVE` pada operasi target yang terotorisasi. Karena itu `CANDIDATE → ACTIVE` bukan generic universal transition contract; transition tersebut bergantung pada operasi dan domain.

Policy contract tidak boleh ditafsirkan sebagai otorisasi untuk membuat universal activation function baru.

### 2.4 Existing transfer lifecycle semantics

**Status: EXISTING / PARTIALLY VERIFIED**

Riwayat migration menunjukkan perilaku lifecycle eksplisit untuk Clone, Inheritance, dan Succession. Implementasi yang ada mempromosikan row candidate hasil transfer menjadi active pada target untuk operasi transfer yang relevan dan mempertahankan provenance.

Ini membuktikan bahwa lifecycle transfer sudah menjadi perilaku database nyata, bukan hanya desain konseptual.

Full authenticated E2E execution masih OPEN.

### 2.5 Journey as projection boundary

**Status: RECONCILED / PASS untuk path yang diuji**

Journey record saat ini berisi domain linkage dan policy metadata. Policy resolver saat ini me-resolve domain record melalui batas ownership account/SH saat ini.

Dengan demikian Journey tetap menjadi batas projection/continuity, bukan authority ownership semantik yang berdiri sendiri.

### 2.6 Transfer policy vocabulary

**Status: RECONCILED / PASS**

Evidence DEV saat ini mendukung:

```text
NON_TRANSFERABLE
INHERITANCE / INHERITABLE normalization
SUCCESSION
LEGACY
```

Working contract tidak memperkenalkan vocabulary transfer baru.

### 2.7 Model-derived persistence

**Status: OPEN / IMPLEMENTATION GAP**

Path model-derived saat ini mencapai semantic decision/audit, tetapi evidence verifikasi saat ini belum membuktikan persistence durable setelah `ACCEPT` atau `CONFIRM`.

Policy contract memang sengaja menjaga boundary ini tetap tertutup sampai ada keputusan implementasi yang sah.

### 2.8 Confirmation authority

**Status: UNKNOWN / EVIDENCE GAP**

Policy contract secara default membutuhkan explicit confirmation untuk `CONFIRM`, tetapi evidence repository yang diperiksa pada gate ini belum menetapkan mekanisme confirmation user/runtime secara lengkap.

Tidak ada implementasi runtime yang diotorisasi hanya karena gap ini ditemukan.

### 2.9 Idempotency

**Status: OPEN / EVIDENCE GAP**

Policy contract mengharuskan duplicate logical semantic capture dikendalikan, tetapi evidence yang diperiksa belum menetapkan idempotency key dan enforcement path lengkap untuk model signal.

Hal ini harus diselesaikan sebelum model-derived persistence diimplementasikan.

### 2.10 Candidate retrieval semantics

**Status: OPEN / EVIDENCE GAP**

Policy contract menyatakan bahwa candidate tidak otomatis menjadi authoritative durable context. Evidence repository/database yang diperiksa pada gate ini belum membuktikan secara lengkap perilaku inclusion/exclusion retrieval untuk setiap semantic domain.

Verification gate khusus retrieval diperlukan sebelum perilaku tersebut dapat dinyatakan terverifikasi.

## 3. Conflict Register

Tidak ditemukan direct conflict antara Canonical dan policy pada material yang diperiksa.

Satu **semantic ambiguity** masih ada:

```text
Working policy model:
CANDIDATE → policy evaluation → ACTIVE

Existing transfer implementation:
CANDIDATE may become ACTIVE during authorized Clone/Inheritance/Succession materialization.
```

Resolution:

Keduanya tidak diperlakukan sebagai transition yang sama. Transfer materialization adalah lifecycle transition spesifik operasi dengan authorization boundary tersendiri. Transition tersebut tidak boleh digeneralisasi menjadi model-derived activation.

## 4. Implementation Authorization Result

Reconciliation gate ini **belum mengotorisasi** implementasi model-derived persistence.

Blocking items:

1. confirmation authority/runtime boundary;
2. model-signal idempotency/correlation key;
3. candidate retrieval semantics;
4. domain-specific lifecycle transition API/function untuk model-derived acceptance;
5. authenticated negative security tests;
6. complete Journey projection transaction boundary.

## 5. Required Next Gate

Gate berikutnya adalah **Runtime Lifecycle Transition Capability Audit**, bukan coding.

Audit setiap domain secara terpisah:

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

Untuk setiap transition identifikasi:

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

Working policy secara material selaras dengan foundation dan batas implementasi saat ini, tetapi implementation gate tetap OPEN karena beberapa capability runtime yang diperlukan untuk mewujudkan model-derived persistence secara aman belum terbukti.

Tidak ada migration yang dibenarkan oleh gate ini.

Tidak ada perubahan runtime code yang dibenarkan oleh gate ini.

## 7. Evidence Principle

```text
Existing function ≠ verified behavior
Migration ≠ current DB state
Policy definition ≠ implementation
Implementation ≠ E2E proof

Policy Gate:
CONTRACT → RECONCILE → CAPABILITY AUDIT → IMPLEMENT → TEST → VERIFY
```
