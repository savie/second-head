# P3E — Context Layering v1.0

## Status

PASS / DEV

Backlog: `BL-P3E-004`
Acceptance Criteria: `AC-CTX-04`
Domain: Phase 3E — Context

## Purpose

Menetapkan layering konteks secara eksplisit pada hasil Context Assembly/Composition/Prioritization yang sudah tersedia, tanpa membuat retrieval path, storage, atau arsitektur konteks baru.

## Source Basis

P3E-001 menyediakan assembly point `public.assemble_context(...)`.

P3E-002 menetapkan composition envelope dengan section terpisah:

```text
{
  query: <query>,
  memory: [ ... ],
  knowledge: [ ... ]
}
```

P3E-003 menetapkan prioritas pemanfaatan source:

```text
CURRENT SH MEMORY
      ↓
GENERAL / SHARED KNOWLEDGE
```

## Layering Policy v1

Context v1 dipahami sebagai tiga lapisan fungsional yang tetap terpisah:

1. **Query / Current Interaction Layer**
   - mewakili kebutuhan atau input saat ini;
   - menjadi acuan relevansi untuk source di bawahnya;
   - bukan Memory dan bukan Knowledge.

2. **SH Memory Layer**
   - berisi Memory yang sudah lolos retrieval boundary untuk SH yang sedang digunakan;
   - ordering mengikuti hasil P3C;
   - tetap tunduk pada ownership/RLS boundary.

3. **General / Shared Knowledge Layer**
   - berisi Knowledge yang sudah eligible melalui existing bounded general/shared retrieval path;
   - provenance/source tetap dipertahankan;
   - tidak memperoleh akses baru hanya karena menjadi bagian Context.

Layer tidak berarti source digabung menjadi satu record type. Setiap layer mempertahankan identitas dan boundary source-nya.

## Layer Order

Urutan fungsional v1:

```text
CURRENT QUERY
      ↓
CURRENT SH MEMORY
      ↓
GENERAL / SHARED KNOWLEDGE
```

Urutan ini konsisten dengan P3E-003. Layering tidak membuat ranking baru dan tidak menggantikan relevance/ranking P3C.

## Boundary Rules

Context layering tidak boleh:

- mengubah ownership;
- mengubah privacy/visibility;
- bypass RLS;
- mempromosikan Memory menjadi Knowledge;
- mempromosikan Knowledge menjadi Memory;
- mengubah Context menjadi persistent Memory;
- memberikan source yang sebelumnya tidak eligible akses baru.

Invariant tetap:

`MEMORY ≠ KNOWLEDGE ≠ CONTEXT`

## Minimal Reconciliation

Audit DEV menunjukkan primitive yang diperlukan sudah tersedia melalui assembly/composition/prioritization yang telah selesai.

Karena itu tidak diperlukan:

- tabel context baru;
- schema mutation;
- retrieval engine baru;
- ranking engine baru;
- RLS/policy baru;
- persistence layer baru;
- perubahan ownership/privacy boundary.

P3E-004 direalisasikan sebagai policy/design layer yang memperjelas struktur fungsional dari context envelope yang sudah ada.

## Non-Goals

Item ini tidak menyelesaikan:

- Context Isolation (`BL-P3E-005`);
- Context Validation (`BL-P3E-006`);
- Context Disposal (`BL-P3E-007`);
- Context Budget & Truncation (`BL-P3E-008`);
- Context Testing (`BL-P3E-009`).

## Completion Statement

`BL-P3E-004 = PASS / DEV`

Context Layering v1 is realized as an explicit, deterministic separation of current query, SH Memory, and General/Shared Knowledge using existing context primitives, without architectural or schema mutation.
