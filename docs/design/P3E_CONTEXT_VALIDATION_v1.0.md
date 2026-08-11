# P3E — Context Validation v1.0

## Status

PASS / DEV

Backlog: `BL-P3E-006`
Acceptance Criteria: `AC-CTX-06`
Domain: Phase 3E — Context

## Purpose

Memastikan context envelope yang dihasilkan oleh existing assembly point memiliki bentuk minimum yang valid sebelum dipakai oleh tahap berikutnya.

## Validation Policy

Context v1 divalidasi pada level envelope, bukan dengan membuat storage atau retrieval engine baru.

Minimum valid envelope:

```text
{
  query: <text|null>,
  memory: [ ... ],
  knowledge: [ ... ]
}
```

Validation checks:

1. envelope harus berupa JSON object;
2. key `query` harus tersedia;
3. key `memory` harus tersedia dan bertipe array;
4. key `knowledge` harus tersedia dan bertipe array;
5. source section tidak boleh berubah menjadi satu array campuran;
6. jumlah item per source tetap berada pada bounded retrieval contract (`1..50` ketika limit eksplisit digunakan; default `10`);
7. validasi tidak mengubah isi record atau provenance/source fields;
8. context validation tidak menjadi authorization bypass.

## Existing Implementation Basis

Validation menggunakan output dari existing:

`public.assemble_context(...)`

yang telah menggunakan:

- `retrieve_memories_bounded(...)`;
- `retrieve_knowledge_bounded(...)`.

Tidak dibuat tabel context baru dan tidak dibuat retrieval path baru.

## Security / Privacy Boundary

Validation hanya memeriksa struktur envelope dan bound hasil.

Ownership/RLS tetap ditangani oleh retrieval path yang sudah ada. `assemble_context(...)` berjalan sebagai `SECURITY INVOKER` dan tidak diberikan kepada `anon`.

Validation tidak mengubah:

- ownership boundary;
- privacy boundary;
- RLS;
- Memory schema;
- Knowledge schema;
- canonical invariant `MEMORY ≠ KNOWLEDGE ≠ CONTEXT`.

## Minimal Reconciliation

Actual DEV sudah menyediakan deterministic context envelope melalui P3E-001 dan composition melalui P3E-002. Karena itu validation cukup diwujudkan sebagai explicit validation contract dan verification terhadap existing output.

Tidak diperlukan schema mutation, tabel baru, atau function baru hanya untuk melakukan validasi envelope.

## Non-goals

Item ini tidak menyelesaikan:

- Context Disposal (`BL-P3E-007`);
- Context Budget & Truncation (`BL-P3E-008`);
- Context Testing (`BL-P3E-009`);
- application/API E2E assurance.

## Completion Statement

`BL-P3E-006 = PASS / DEV`

Context Validation v1 is satisfied by explicit envelope validation over the existing assembly contract without architectural or schema mutation.
