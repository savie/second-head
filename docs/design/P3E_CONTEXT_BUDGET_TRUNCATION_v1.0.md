# P3E — Context Budget & Truncation v1.0

## Status

PASS / DEV

Backlog: `BL-P3E-008`
Acceptance Criteria: `AC-CTX-08`
Domain: Phase 3E — Context

## Purpose

Menetapkan batas maksimum Context yang dihasilkan oleh existing Context Assembly tanpa membuat Context storage, retrieval engine, atau arsitektur baru.

## Source Basis

P3E-001 menyediakan `public.assemble_context(...)` sebagai assembly point.

P3E-002 menetapkan composition envelope `query`, `memory`, dan `knowledge`.

P3E-003 menetapkan prioritas source:

```text
CURRENT SH MEMORY
      ↓
GENERAL / SHARED KNOWLEDGE
```

P3C-006 sudah menyediakan bounded retrieval dengan maksimum 50 hasil per retrieval invocation.

## Budget Policy v1

Context menggunakan satu hard upper bound pada assembly output: **maksimum 50 records total** untuk gabungan `memory` + `knowledge`.

Default caller budget tetap:

- Memory: 10
- Knowledge: 10
- Total default: 20

Requested per-source limits tetap dinormalisasi ke range aman `1..50`, kemudian assembly menerapkan total Context budget maksimum 50.

Memory mendapat prioritas budget lebih dahulu sesuai P3E-003. Knowledge menerima sisa budget yang tersedia.

Conceptually:

```text
requested memory budget
        ↓
allocate memory first
        ↓
remaining total budget
        ↓
allocate knowledge from remainder
        ↓
CONTEXT <= 50 records
```

## Truncation Policy

Truncation dilakukan melalui bounded retrieval yang sudah ada, setelah filtering, relevance scoring, dan deterministic ranking.

Tidak dilakukan random truncation.

Tidak dilakukan destructive mutation terhadap Memory atau Knowledge.

Record yang tidak masuk Context hanya tidak dipilih untuk invocation tersebut; source record tetap utuh.

Jika Memory menggunakan seluruh remaining budget, Knowledge dapat menerima `0` record untuk invocation tersebut. Ini merupakan konsekuensi deterministic dari source prioritization, bukan penghapusan Knowledge.

## Determinism

Budget allocation deterministic:

1. normalize requested Memory limit;
2. allocate Memory first;
3. calculate remaining total budget;
4. allocate Knowledge from the remaining budget;
5. preserve each source's existing retrieval ordering.

Dengan demikian P3E-008 tidak membuat ranking kedua dan tidak mengubah P3C scoring/ranking/filtering.

## Minimal Reconciliation

Existing implementation sudah memiliki:

- bounded Memory retrieval;
- bounded Knowledge retrieval;
- deterministic source prioritization;
- existing Context assembly point.

Gap aktual hanya pada **global Context bound**: dua per-source limit sebelumnya dapat secara teori menghasilkan hingga 100 records jika masing-masing diminta 50.

Minimal realization therefore is limited to updating the existing `assemble_context(...)` allocation logic so the combined Context cannot exceed 50 records.

Tidak dibuat:

- tabel Context baru;
- Context persistence layer;
- tokenizer/embedding subsystem;
- second retrieval engine;
- second ranking engine;
- schema Memory/Knowledge mutation;
- RLS or ownership change.

## Security / Privacy Boundary

Budgeting dan truncation tidak memberikan akses baru.

Existing `SECURITY INVOKER` behavior dan underlying Memory/Knowledge retrieval boundaries remain unchanged.

The invariant remains:

`MEMORY ≠ KNOWLEDGE ≠ CONTEXT`

## Non-Goals

Item ini tidak menyelesaikan:

- Context Testing (`BL-P3E-009`);
- application/model token-budget assurance;
- model-specific tokenizer accounting;
- dynamic model routing.

## Completion Statement

`BL-P3E-008 = PASS / DEV`

Context Budget & Truncation v1 is realized as a deterministic maximum-50-record assembly bound using the existing retrieval and prioritization primitives, with no new architecture or persistent Context storage.
