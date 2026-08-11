# P3E — Context Disposal v1.0

## Status

PASS / DEV

Backlog: `BL-P3E-007`
Acceptance Criteria: `AC-CTX-07`
Domain: Phase 3E — Context

## Purpose

Menetapkan bahwa Context hasil assembly diperlakukan sebagai hasil kerja sementara dan tidak dibuat menjadi persistent storage baru pada Phase 3E.

## Reconciliation

Audit terhadap implementation DEV dan Supabase menunjukkan bahwa existing `public.assemble_context(...)` menghasilkan `jsonb` secara langsung dari bounded Memory dan Knowledge retrieval.

Function tersebut berstatus SQL `STABLE`, tidak menggunakan tabel Context sebagai persistence layer, dan tidak melakukan INSERT/UPDATE/DELETE terhadap storage Context.

Karena tidak ada persistent Context storage yang dibutuhkan oleh backlog ini, disposal v1 direalisasikan sebagai **non-persistence / ephemeral handling** pada assembly layer yang sudah ada.

Tidak dibuat:

- tabel Context baru;
- Context persistence queue;
- cleanup job baru;
- storage layer baru;
- perubahan Memory/Knowledge lifecycle;
- perubahan retrieval engine.

## Disposal Contract

Context envelope:

```text
QUERY
  ↓
ASSEMBLE
  ↓
VALIDATE / USE
  ↓
DISPOSE BY NON-PERSISTENCE
```

Artinya hasil Context hanya tersedia sebagai return value dari assembly operation. Setelah caller selesai menggunakan return value, tidak ada record Context yang harus dipertahankan oleh database karena Phase 3E tidak membuat Context menjadi entity persistent.

Memory dan Knowledge tetap memiliki lifecycle/storage masing-masing. Disposal Context tidak menghapus atau mengubah source Memory/Knowledge.

## Live Verification

Supabase DEV diverifikasi bahwa:

1. `public.assemble_context(...)` tersedia.
2. Function menghasilkan Context envelope `jsonb`.
3. Function berstatus `STABLE`.
4. Function bukan `SECURITY DEFINER` (`prosecdef = false`).
5. Tidak ditemukan tabel public dengan nama yang mengindikasikan persistent Context storage.
6. Invocation menghasilkan envelope dengan `query`, `memory`, dan `knowledge` tanpa membuat Context record persistent.

## Security / Privacy Boundary

Context disposal tidak mengubah:

- ownership boundary;
- privacy boundary;
- RLS;
- Memory schema;
- Knowledge schema;
- canonical invariant `MEMORY ≠ KNOWLEDGE ≠ CONTEXT`.

Disposal Context juga tidak berarti deletion terhadap Memory atau Knowledge sumber.

## Deferred Assurance

Verification ini membuktikan implementation/database behavior untuk non-persistence Context.

Application-level assurance mengenai lifecycle object di caller/runtime layer belum dilakukan dan tetap dapat ditutup pada runtime/application testing stage.

## Non-goals

Item ini tidak menyelesaikan:

- Context Budget & Truncation (`BL-P3E-008`);
- Context Testing (`BL-P3E-009`);
- Memory deletion;
- Knowledge deletion;
- application-level cache/session eviction policy.

## Completion Statement

`BL-P3E-007 = PASS / DEV`

Context Disposal v1 is satisfied by the existing ephemeral, non-persistent assembly model. No schema or architectural mutation was required.
