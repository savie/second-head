# P3E — Context Composition v1.0

## Status

PASS / DEV

Backlog: `BL-P3E-002`
Acceptance Criteria: `AC-CTX-02`
Domain: Phase 3E — Context

## Purpose

Menetapkan composition policy untuk menggabungkan lebih dari satu sumber konteks yang sudah tersedia tanpa membuat storage atau retrieval path baru.

## Source Basis

Phase -1 memetakan `BL-P3E-002` sebagai **Context Composition** dengan dependency `BL-P3E-001`.
Task breakdown mendefinisikan konteks ini sebagai **multi-source assembly**.

P3E-001 telah menyediakan assembly point `public.assemble_context(...)` yang menggabungkan hasil bounded memory retrieval dan bounded shared/general Knowledge retrieval.

## Composition Policy

Composition v1 menggunakan dua source yang sudah tersedia:

1. `memory`
   - berasal dari `retrieve_memories_bounded(...)`;
   - tetap terikat pada `p_sh_id` dan existing memory ownership/RLS boundary;
   - hasil mempertahankan field retrieval termasuk `relevance_score`.

2. `knowledge`
   - berasal dari `retrieve_knowledge_bounded(...)`;
   - hanya mengambil Knowledge dengan `scope = GENERAL`, `visibility = SHARED`, dan lifecycle `INDEXED` atau `ACTIVE`;
   - provenance/source fields tetap dibawa ke hasil.

Kedua source dipertahankan sebagai section terpisah di dalam satu context envelope:

```text
{
  query: <query>,
  memory: [ ... ],
  knowledge: [ ... ]
}
```

Composition tidak mencampur record Memory dan Knowledge menjadi satu tipe record dan tidak menghapus identitas source.

## Determinism / Bounds

Composition menggunakan bounded retrieval yang sudah tersedia.

Per-source limit:

- default `10`;
- minimum `1`;
- maksimum `50`.

Ordering source tidak diubah oleh composition layer:

- Memory mengikuti relevance score dan tie-breaker retrieval yang sudah ada.
- Knowledge mengikuti ordering retrieval yang sudah ada.

Context composition tidak melakukan prioritization, layering, truncation, validation, atau disposal. Item tersebut tetap menjadi backlog P3E berikutnya.

## Security / Privacy Boundary

Composition bukan jalur bypass authorization.

`assemble_context(...)` menggunakan `SECURITY INVOKER` behavior dan memory retrieval tetap melalui existing ownership/RLS boundary.

Knowledge yang masuk ke composition berasal dari bounded general/shared retrieval path.

Tidak ada perubahan terhadap:

- ownership boundary;
- privacy boundary;
- RLS;
- Memory schema;
- Knowledge schema;
- canonical invariant `MEMORY ≠ KNOWLEDGE ≠ CONTEXT`.

## Minimal Reconciliation

Reconcile terhadap actual DEV menunjukkan bahwa realization P3E-001 sudah menyediakan seluruh primitive yang diperlukan untuk Context Composition v1.

Karena itu tidak dibuat:

- tabel context baru;
- function composition baru hanya untuk membungkus function existing;
- retrieval engine baru;
- prioritization layer baru;
- layering mechanism baru.

P3E-002 ditutup dengan menetapkan dan memverifikasi policy composition pada existing assembly point.

## Non-goals

Item ini tidak menyelesaikan:

- Context Prioritization (`BL-P3E-003`);
- Context Layering (`BL-P3E-004`);
- Context Isolation (`BL-P3E-005`);
- Context Validation (`BL-P3E-006`);
- Context Disposal (`BL-P3E-007`);
- Context Budget & Truncation (`BL-P3E-008`);
- Context Testing (`BL-P3E-009`).

## Completion Statement

`BL-P3E-002 = PASS / DEV`

Context Composition v1 is implemented by the existing P3E-001 assembly point and verified without architectural or schema mutation.
