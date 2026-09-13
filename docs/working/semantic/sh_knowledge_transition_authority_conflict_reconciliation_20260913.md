# SECOND HEAD — Rekonsiliasi Konflik Kontrak Otoritas Transisi Knowledge — 2026-09-13

## Status

**WORKING RECONCILIATION RECORD — CONFLICT IDENTIFIED — IMPLEMENTATION GATE CLOSED**

Dokumen ini mencatat conflict antar working contracts yang ditemukan saat finalisasi authority transisi Knowledge. Dokumen ini tidak mengubah Canonical, Approved Contract, database, atau runtime.

## 1. Evidence

Supabase DEV saat ini membuktikan vocabulary `public.knowledge`:

```text
CANDIDATE
ACCEPTED
INDEXED
ACTIVE
UPDATED
DEPRECATED
ARCHIVED
```

Tidak ditemukan RPC runtime khusus yang membuktikan acceptance, indexing, activation, update/supersession, deprecation, atau archive sebagai authority production.

## 2. Conflict

Dua working documents pada tanggal yang sama membawa kontrak yang berbeda:

### Contract A — Transition API Contract Finalization

`docs/working/semantic/sh_transition_api_contract_finalization_20260913.md`

Mendefinisikan Knowledge activation sebagai:

```text
CANDIDATE → ACTIVE
```

melalui target:

```text
runtime_activate_knowledge_candidate
```

Dokumen tersebut secara eksplisit menyebut target ini sebagai contract target dan implementation gate tetap tertutup.

### Contract B — Knowledge Transition Implementation Contract

`docs/working/semantic/sh_knowledge_transition_implementation_contract_20260913.md`

Mendefinisikan lifecycle bertahap:

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE → UPDATED / DEPRECATED → ARCHIVED
```

Dengan transition-specific targets:

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
```

Dokumen tersebut juga menyatakan `VALIDATION` sebagai process boundary dan bukan lifecycle enum.

## 3. Authority Assessment

Kedua dokumen adalah **WORKING** dan tidak ada evidence bahwa salah satunya telah dipromosikan menjadi Approved Contract atau Canonical.

Karena itu assistant tidak boleh silently memilih salah satu sebagai final authority.

Evidence database mendukung keberadaan seluruh enum lifecycle pada Contract B, tetapi keberadaan enum saja tidak membuktikan bahwa Contract B adalah approved runtime authority.

## 4. Impact

Conflict ini mempengaruhi:

- API/function naming;
- lifecycle transition graph;
- validation/acceptance authority;
- indexing boundary;
- activation authority;
- operation ledger transition values;
- Journey payload;
- SQLSTATE/error contract;
- E2E verification matrix;
- migration shape.

Implementing before reconciliation could create an incompatible transition API or an incorrect lifecycle authority boundary.

## 5. Current Safe Decision

Until higher-authority reconciliation exists:

```text
DO NOT implement lifecycle transition RPCs
DO NOT create lifecycle operation migration
DO NOT alter knowledge lifecycle constraints
DO NOT expose activation API
DO NOT invent SQLSTATE mapping
DO NOT reuse recovery confirmation as Knowledge authority
```

Existing Knowledge acquisition remains unchanged.

## 6. What Is Already Safe To Carry Forward

Independent of the conflict, the following boundary is consistent across the working material and runtime evidence:

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

Also consistent:

- model output is not lifecycle authority;
- confidence is not lifecycle authority;
- Journey is projection/history, not lifecycle authority;
- `audit_events` remains generic runtime audit;
- a dedicated Knowledge lifecycle operation ledger is required unless a higher-authority contract establishes another safe mechanism;
- idempotency must be database-enforced;
- concurrency requires target-row locking;
- successful domain mutation, operation ledger, and required Journey projection must share an atomic boundary where technically possible;
- duplicate operation identity must not be confused with semantic conflict.

## 7. SQLSTATE Status

No existing Knowledge transition implementation provides a standardized SQLSTATE mapping.

Existing runtime functions predominantly use ordinary `RAISE EXCEPTION` messages without an explicit transition-specific SQLSTATE contract.

Therefore exact SQLSTATE codes remain **OPEN** and must not be invented merely to close the gate.

## 8. Confirmation Status

Existing durable high-risk confirmation infrastructure is explicitly scoped to:

```text
RECOVERY_RESTORE
```

It cannot be treated as Knowledge lifecycle confirmation authority without a separate authorized contract.

## 9. Required Reconciliation

A higher-authority decision must resolve:

1. whether Knowledge uses staged lifecycle promotion:

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE
```

or a direct activation model:

```text
CANDIDATE → ACTIVE
```

2. authoritative function names;
3. whether acceptance and indexing are mandatory production boundaries;
4. confirmation requirements per transition;
5. operation ledger transition taxonomy;
6. Journey event semantics;
7. SQLSTATE mapping.

## 10. Gate Decision

**IMPLEMENTATION GATE = CLOSED**

Reason is not lack of technical feasibility. Reason is **authority conflict** combined with missing confirmation and SQLSTATE finalization.

No migration or runtime implementation should be created until the conflict is explicitly reconciled by the appropriate authority.

## 11. Change Boundary

```text
Supabase DEV schema = UNCHANGED
Supabase DEV data   = UNCHANGED
Runtime code        = UNCHANGED
Migration           = UNCHANGED
Canonical           = UNCHANGED
GitHub              = THIS WORKING RECONCILIATION RECORD ONLY
```
