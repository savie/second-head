# P3E — Context Assembly Engine v1.0

## Status

PASS / DEV

Backlog: `BL-P3E-001`
Acceptance Criteria: `AC-CTX-01`
Domain: Phase 3E — Context

## Purpose

Menyediakan satu assembly point yang menggabungkan hasil retrieval yang sudah tersedia dari Phase 3B/3C/3D menjadi satu context envelope.

## Minimal realization

Engine menggunakan komponen yang sudah ada:

- `retrieve_memories_bounded(...)` untuk memory milik SH;
- `retrieve_knowledge_bounded(...)` untuk general/shared Knowledge;
- `memory_relevance_score(...)` yang sudah menjadi bagian dari retrieval memory.

Tidak membuat tabel context baru, tidak membuat semantic retrieval engine baru, dan tidak mengubah ownership/privacy boundary yang sudah ada.

## Contract

Function:

`public.assemble_context(p_sh_id, p_query_text, p_memory_limit, p_knowledge_limit)`

Output JSON:

```text
{
  query: <query>,
  memory: [ ...bounded memory results... ],
  knowledge: [ ...bounded knowledge results... ]
}
```

Limit masing-masing sumber dibatasi minimum 1 dan maksimum 50, dengan default 10.

## Boundary

Memory tetap diperoleh melalui existing memory retrieval path yang sudah memiliki SH ownership/RLS boundary.

Knowledge yang dirakit berasal dari existing bounded shared/general retrieval path.

Function menggunakan `SECURITY INVOKER` behavior (default PostgreSQL), sehingga tidak menjadi jalan pintas untuk melewati RLS.

Execution diberikan kepada `authenticated`; tidak diberikan kepada `anon`.

## Non-goals

Item ini tidak menyelesaikan:

- context composition policy;
- context prioritization;
- context layering;
- context isolation;
- context validation;
- context disposal;
- application/API E2E integration.

Item-item tersebut tetap berada pada backlog P3E berikutnya.

## Reconciliation

Existing retrieval primitives sudah cukup untuk memenuhi realization minimum. Tidak diperlukan redesign schema atau arsitektur baru.

Owner/DM decisions mengenai Memory, Knowledge, privacy, provenance, supersession, dan general/shared Knowledge tetap dihormati melalui pemakaian retrieval path yang sudah ada.

Formal OQ closure tidak diklaim oleh artifact ini.
