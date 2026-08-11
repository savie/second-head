# P3E — Context Prioritization v1.0

## Status

PASS / DEV

Backlog: `BL-P3E-003`
Acceptance Criteria: `AC-CTX-03`
Domain: Phase 3E — Context

## Purpose

Menetapkan prioritas konteks yang sudah tersedia setelah Context Assembly dan Context Composition, tanpa membuat retrieval path, storage, atau arsitektur konteks baru.

## Source Basis

P3E-001 menyediakan `public.assemble_context(...)` sebagai assembly point.

P3E-002 menetapkan composition envelope:

```text
{
  query: <query>,
  memory: [ ... ],
  knowledge: [ ... ]
}
```

P3C sudah menyediakan relevance/ranking untuk Memory dan bounded retrieval untuk kedua source.

## Prioritization Policy v1

Prioritas konteks ditentukan secara deterministik berdasarkan sifat source yang sudah tersedia:

1. **Memory yang relevan terhadap query** menjadi prioritas pertama.
   - Memory berasal dari SH yang sedang digunakan.
   - Ordering internal mengikuti ranking P3C yang sudah ada.
   - `relevance_score` tetap menjadi sinyal utama.

2. **General/shared Knowledge yang relevan** menjadi prioritas berikutnya.
   - Knowledge berasal dari existing bounded general/shared retrieval path.
   - Ordering internal mengikuti ordering retrieval yang sudah ada.
   - Provenance/source information tetap dipertahankan.

3. **Tidak ada source yang dipromosikan melewati boundary-nya.**
   - Context prioritization tidak mengubah ownership.
   - Context prioritization tidak mengubah privacy.
   - Context prioritization tidak mengubah visibility atau RLS.
   - Knowledge tidak berubah menjadi Memory dan Memory tidak berubah menjadi Knowledge.

## Determinism

Prioritization tidak memperkenalkan weighted composite score baru.

Prioritas source bersifat eksplisit:

```text
CURRENT SH MEMORY
      ↓
GENERAL / SHARED KNOWLEDGE
```

Di dalam masing-masing source, ordering yang telah dibangun oleh P3C tetap dipakai.

Dengan demikian P3E-003 tidak membuat ranking kedua yang bertentangan dengan P3C.

## Minimal Reconciliation

Audit terhadap DEV menunjukkan bahwa seluruh primitive yang diperlukan sudah tersedia:

- Memory relevance score;
- deterministic Memory ranking;
- bounded Memory retrieval;
- bounded general/shared Knowledge retrieval;
- existing context assembly point;
- existing composition envelope.

Karena itu tidak diperlukan:

- tabel context baru;
- kolom priority baru;
- retrieval engine baru;
- ranking engine baru;
- policy/RLS baru;
- perubahan schema Memory atau Knowledge;
- perubahan ownership/privacy boundary.

P3E-003 direalisasikan sebagai policy layer yang menggunakan hasil retrieval/ranking yang sudah ada.

## Governance / Privacy Boundary

Context prioritization hanya menentukan urutan pemanfaatan hasil yang sudah eligible.

Ia tidak memberikan akses baru dan tidak boleh menjadi bypass terhadap RLS atau ownership boundary.

Invariant berikut tetap berlaku:

`MEMORY ≠ KNOWLEDGE ≠ CONTEXT`

## Non-Goals

Item ini tidak menyelesaikan:

- Context Layering (`BL-P3E-004`);
- Context Isolation (`BL-P3E-005`);
- Context Validation (`BL-P3E-006`);
- Context Disposal (`BL-P3E-007`);
- Context Budget & Truncation (`BL-P3E-008`);
- Context Testing (`BL-P3E-009`).

## Completion Statement

`BL-P3E-003 = PASS / DEV`

Context Prioritization v1 is realized using the existing Memory relevance/ranking and general/shared Knowledge retrieval paths, without architectural or schema mutation.
