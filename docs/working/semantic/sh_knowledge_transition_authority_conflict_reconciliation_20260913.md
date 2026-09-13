# SECOND HEAD — Rekonsiliasi Konflik Kontrak Otoritas Transisi Knowledge — 2026-09-13

## Status

**WORKING RECONCILIATION RECORD — AUTHORITY DECISION RECEIVED — STAGED LIFECYCLE SELECTED**

Dokumen ini mencatat conflict antar working contracts yang ditemukan saat finalisasi authority transisi Knowledge dan keputusan authority yang kemudian diberikan.

Dokumen ini tidak mengubah Canonical.

## 1. Evidence

Supabase DEV membuktikan vocabulary `public.knowledge`:

```text
CANDIDATE
ACCEPTED
INDEXED
ACTIVE
UPDATED
DEPRECATED
ARCHIVED
```

Sebelum keputusan ini tidak ditemukan RPC runtime khusus yang membuktikan acceptance, indexing, activation, update/supersession, deprecation, atau archive sebagai authority production.

## 2. Conflict Yang Direkonsiliasi

Dua working documents pada tanggal yang sama membawa kontrak berbeda:

### Contract A — Transition API Contract Finalization

`docs/working/semantic/sh_transition_api_contract_finalization_20260913.md`

Mendefinisikan activation langsung:

```text
CANDIDATE → ACTIVE
```

melalui target:

```text
runtime_activate_knowledge_candidate
```

### Contract B — Knowledge Transition Implementation Contract

`docs/working/semantic/sh_knowledge_transition_implementation_contract_20260913.md`

Mendefinisikan lifecycle bertahap:

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE → UPDATED / DEPRECATED → ARCHIVED
```

Dengan target:

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
```

## 3. Authority Decision

User authority decision pada 2026-09-13:

**STAGED LIFECYCLE = SELECTED.**

Authority lifecycle yang digunakan untuk implementation planning adalah:

```text
CANDIDATE
  ↓
ACCEPTED
  ↓
INDEXED
  ↓
ACTIVE
  ├──→ UPDATED + superseded_by successor
  ↓
DEPRECATED
  ↓
ARCHIVED
```

`VALIDATION` tetap process boundary, bukan lifecycle enum.

Acceptance dan indexing menjadi production lifecycle boundaries yang wajib dilewati sebelum activation.

Contract A tidak lagi menjadi lifecycle direction untuk implementation. Dokumen tersebut tetap historical/working material sampai direkonsiliasi secara eksplisit pada tahap berikutnya; tidak ada silent rewrite terhadap dokumen authority lain.

## 4. Impact Yang Sekarang Sudah Terselesaikan

Keputusan staged lifecycle menetapkan:

- lifecycle transition graph;
- acceptance sebagai transition authority;
- indexing sebagai transition authority;
- activation hanya dari `INDEXED`;
- target function naming untuk enam transition;
- operation ledger transition taxonomy dasar;
- E2E transition ordering.

Hal berikut masih membutuhkan engineering finalization sebelum runtime mutation:

- semantic confirmation authority;
- operation ledger schema/atomicity;
- exact Journey lifecycle event convention;
- per-function SECURITY INVOKER/DEFINER decision;
- SQLSTATE mapping berdasarkan implementation aktual;
- runtime caller integration;
- E2E positive/negative/concurrency verification.

## 5. Safe Boundary

Boundary yang tetap berlaku:

```text
AUTHENTICATE
→ RESOLVE ACCOUNT / SH
→ VERIFY OWNERSHIP
→ VERIFY CURRENT LIFECYCLE
→ VERIFY LEGAL TRANSITION
→ VERIFY DOMAIN AUTHORITY
→ VERIFY POLICY / CONFIRMATION
→ VERIFY OPERATION IDENTITY
→ ATOMIC MUTATION
→ OPERATION LEDGER
→ JOURNEY PROJECTION
→ OBSERVABLE RESULT
```

Tidak ada lifecycle authority dari model output, confidence, atau Journey replay.

## 6. Current Gate

```text
Lifecycle authority conflict = RESOLVED
Staged lifecycle decision = PASS
Transition graph = PASS
Function naming direction = PASS
Operation ledger architecture = OPEN
Confirmation authority = OPEN
Journey exact convention = OPEN
Security exposure review = OPEN
SQLSTATE mapping = OPEN
Runtime implementation = OPEN
E2E verification = OPEN

IMPLEMENTATION GATE = CLOSED
```

Gate tetap CLOSED hanya karena dependency engineering yang belum dibuktikan, bukan karena lifecycle decision masih ambigu.

## 7. Change Boundary

```text
Supabase DEV schema = UNCHANGED
Supabase DEV data   = UNCHANGED
Runtime code        = UNCHANGED
Migration           = UNCHANGED
Canonical           = UNCHANGED
GitHub              = RECONCILIATION RECORD UPDATED
```

## 8. Next Engineering Sequence

```text
SECURITY / CONFIRMATION DESIGN
        ↓
OPERATION LEDGER + ATOMICITY DESIGN
        ↓
JOURNEY CONTRACT FINALIZATION
        ↓
SQL CONTRACT / ERROR MAPPING
        ↓
SUPABASE-FIRST IMPLEMENTATION
        ↓
DATABASE TEST + SECURITY TEST
        ↓
MIGRATION HISTORY
        ↓
GITHUB RECONCILIATION
        ↓
RUNTIME INTEGRATION
        ↓
E2E VERIFICATION
```
