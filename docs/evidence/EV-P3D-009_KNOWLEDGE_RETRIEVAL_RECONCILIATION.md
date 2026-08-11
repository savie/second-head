# EV-P3D-009 — Knowledge Retrieval Reconciliation

## Status

**PASS — VERIFIED / DEV**

Backlog item: `BL-P3D-009`
Acceptance Criteria: `AC-KNOW-09`
Domain: Phase 3D — Knowledge

## Audit Scope

Audit/reconciliation mencakup:

- Phase -1 backlog;
- SH Core Canonical v1.0;
- SH Full Build Scope v1.0;
- SH Full Implementation Contract v1.0;
- SH Full Implementation Guide v1.0;
- P3D-001 Knowledge Schema Design;
- P3D-002..P3D-008 existing artifacts/evidence;
- current GitHub DEV;
- current Supabase DEV;
- latest Owner/DM decisions mengenai privacy/generalization, sharing, provenance, superseded, dan Knowledge boundary.

## Reconciliation Result

Existing `public.knowledge` sudah memiliki:

- `scope`;
- `visibility`;
- `lifecycle`;
- `version`;
- `updated_at`;
- `provenance`.

P3D-007 sudah menyediakan index yang relevan untuk deterministic lookup/filtering.

Namun schema Knowledge tidak memiliki owner/SH foreign key. Karena itu retrieval private-owner tidak boleh diada-adakan pada backlog ini.

Boundary yang paling kecil dan aman adalah hanya mengambil Knowledge yang memang telah ditandai:

- `scope = GENERAL`;
- `visibility = SHARED`;
- `lifecycle IN ('INDEXED', 'ACTIVE')`.

Ini mempertahankan keputusan Owner bahwa private information tidak otomatis digeneralisasikan dan sharing tetap berada di dalam governance/authorization boundary.

## Minimal Realization

Supabase migration menambahkan:

1. `knowledge_shared_retrieval_select` RLS policy untuk authenticated users dengan boundary GENERAL + SHARED + INDEXED/ACTIVE.
2. `public.retrieve_knowledge_bounded(text, integer)` sebagai deterministic text retrieval function.

Function:

- `SECURITY INVOKER`;
- optional `ILIKE` text matching terhadap `content`;
- deterministic ordering `updated_at DESC`, `version DESC`, `knowledge_id ASC`;
- bounded result maksimum 50 dengan default 20.

Tidak ada semantic/vector search, embedding, trust-promotion, atau ownership model baru.

## Supabase Verification

Migration berhasil diterapkan pada Supabase DEV.

Verified:

- `public.retrieve_knowledge_bounded` exists;
- function security type = `INVOKER`;
- `knowledge_shared_retrieval_select` exists untuk role `authenticated`;
- policy membatasi hasil ke GENERAL + SHARED + INDEXED/ACTIVE.

Synthetic verification menggunakan empat row:

- GENERAL + SHARED + ACTIVE → retrieved;
- GENERAL + SHARED + INDEXED → retrieved;
- GENERAL + OWNER_ONLY + ACTIVE → tidak retrieved;
- PRIVATE + SHARED + ACTIVE → tidak retrieved.

Query terhadap `retrieve_knowledge_bounded('synthetic', 50)` menghasilkan tepat dua row yang memenuhi retrieval boundary.

Synthetic test rows kemudian dihapus.

Final persistent synthetic residue:

`0`

## GitHub DEV

Migration:

`database/migrations/20260812020000_p3d_009_knowledge_retrieval.sql`

Design:

`docs/design/P3D_KNOWLEDGE_RETRIEVAL_v1.0.md`

Commits:

- `0a8c9affb400843b11c2fb0ef80217acd8c2a981` — retrieval migration
- `67feaba8d6c4237e604fa2d4b1184d95081f16ae` — retrieval design

Evidence:

`docs/evidence/EV-P3D-009_KNOWLEDGE_RETRIEVAL_RECONCILIATION.md`

## Assurance Limitation

Database/function/policy behavior sudah diverifikasi pada Supabase DEV.

Application-level authenticated runtime/E2E assurance belum dilakukan pada item ini, sehingga tidak diklaim sebagai E2E PASS.

## OQ Reconciliation

OQ-03/OQ-04 tetap dapat berstatus OPEN secara formal pada dokumen lama.

Keputusan Owner/DM memberikan direction yang cukup untuk practical retrieval pada scope general/shared tanpa mengubah canonical architecture, ownership/privacy boundary, security boundary, atau fundamental flow.

`FORMAL OQ CLOSURE = NOT CLAIMED`

`PRACTICAL IMPLEMENTATION = UNBLOCKED`

## Completion

**BL-P3D-009 = PASS / DEV**

`KNOWLEDGE RETRIEVAL = IMPLEMENTED / VERIFIED`

`PERSISTENT TEST RESIDUE = NONE`

`APPLICATION/E2E ASSURANCE = DEFERRED`
