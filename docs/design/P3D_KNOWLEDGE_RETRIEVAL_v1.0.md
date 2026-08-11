# SECOND HEAD — P3D Knowledge Retrieval v1.0

## Status
IMPLEMENTED — BL-P3D-009 / AC-KNOW-09

## Purpose

Merealisasikan retrieval Knowledge secara minimal, bounded, deterministic, dan tetap berada di dalam boundary privacy/sharing yang sudah tersedia.

## Authority / Reconciliation

Rekonsiliasi menggunakan:

- Phase -1 backlog BL-P3D-009 / AC-KNOW-09;
- SH Core Canonical v1.0;
- SH Full Build Scope v1.0;
- SH Full Implementation Contract v1.0;
- SH Full Implementation Guide v1.0;
- P3D-001 Knowledge Schema Design;
- P3D-002..P3D-008 existing implementation/evidence;
- existing P3D indexing;
- Owner/DM decisions mengenai privacy/generalization, sharing, provenance, superseded, dan Knowledge boundary;
- current GitHub DEV;
- current Supabase DEV.

## Reconciliation Result

Existing Knowledge storage sudah memiliki field `scope`, `visibility`, `lifecycle`, `version`, `updated_at`, dan provenance. P3D-007 sudah menyediakan index untuk lifecycle, class, scope/visibility, dan updated_at.

Karena `public.knowledge` belum memiliki owner/SH foreign key, retrieval tidak boleh mengarang private-owner retrieval atau membuat ownership model baru. Retrieval yang aman untuk direalisasikan pada backlog ini adalah Knowledge yang memang telah ditandai `GENERAL` + `SHARED` dan berada pada lifecycle yang sudah siap diakses (`INDEXED` atau `ACTIVE`).

Dengan demikian tidak diperlukan perubahan fundamental pada schema Knowledge.

## Retrieval Contract

```text
QUERY
  ↓
AUTHORIZED KNOWLEDGE CANDIDATES
  ↓
GENERAL + SHARED
  ↓
INDEXED / ACTIVE
  ↓
TEXT MATCH (optional)
  ↓
DETERMINISTIC ORDER
  ↓
BOUNDED RESULT
```

### Query

`p_query_text` adalah query opsional. Jika kosong, retrieval dapat mengembalikan Knowledge yang memenuhi boundary tanpa text filtering.

### Access Boundary

Retrieval hanya mengekspos:

- `scope = GENERAL`;
- `visibility = SHARED`;
- `lifecycle IN ('INDEXED', 'ACTIVE')`.

Private Knowledge dan Owner-only Knowledge tidak ikut keluar dari retrieval path ini.

### Matching

Pencarian teks menggunakan matching PostgreSQL `ILIKE` terhadap `content`.

Ini merupakan deterministic text retrieval, bukan semantic/vector search.

### Ordering

Urutan deterministik:

1. `updated_at DESC`;
2. `version DESC`;
3. `knowledge_id ASC` sebagai tie-breaker.

Tidak ada trust score atau relevance formula baru yang diperkenalkan pada item ini.

### Bound

`p_limit` dibatasi minimum 1 dan maksimum 50, dengan default 20.

## Database Realization

Added:

- `public.retrieve_knowledge_bounded(text, integer)`;
- `knowledge_shared_retrieval_select` policy untuk authenticated users.

Function menggunakan `SECURITY INVOKER`, sehingga tetap tunduk pada RLS.

## Boundary / Non-Goals

Item ini tidak memperkenalkan:

- semantic/vector retrieval;
- embeddings;
- trust promotion;
- relevance model baru;
- Knowledge ranking model baru;
- private-owner retrieval tanpa owner linkage;
- sharing/inheritance model baru;
- Core modification;
- automatic trust promotion.

## OQ Reconciliation

OQ-03/OQ-04 dapat tetap tercatat OPEN pada dokumentasi formal yang belum direwrite.

Keputusan Owner/DM yang sudah ada memberikan direction yang cukup untuk retrieval terhadap Knowledge yang memang sudah ditandai general/shared dan tidak mengubah canonical architecture, ownership/privacy boundary, security boundary, atau fundamental flow.

Karena itu:

`FORMAL OQ CLOSURE = NOT CLAIMED`

`PRACTICAL IMPLEMENTATION = UNBLOCKED FOR THIS BACKLOG`

## Verification Boundary

Database implementation dan deterministic retrieval path diverifikasi pada Supabase DEV menggunakan synthetic rows.

Application/E2E authentication-context assurance tetap dapat dicatat sebagai deferred bila belum diuji melalui application runtime.

## Conclusion

BL-P3D-009 direalisasikan melalui perubahan minimum pada Knowledge retrieval path tanpa membuat model ownership baru atau memperluas scope menjadi semantic search/trust engine.
