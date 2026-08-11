# P3E — Context Isolation v1.0

## Status

PASS / DEV

Backlog: `BL-P3E-005`
Acceptance Criteria: `AC-CTX-05`
Domain: Phase 3E — Context

## Purpose

Memastikan context assembly tidak menjadi jalur untuk mencampurkan Memory milik SH lain ke context SH yang sedang digunakan, sementara General/Shared Knowledge tetap dapat masuk melalui boundary sharing yang memang sudah ditetapkan.

## Isolation Policy v1

Context isolation mengikuti boundary source yang sudah ada:

1. **Memory**
   - retrieval menerima `p_sh_id` secara eksplisit;
   - Memory tetap melalui `retrieve_memories_bounded(...)`;
   - akses Memory dibatasi oleh ownership/RLS `memories_owner_select`;
   - Memory dari SH lain tidak boleh masuk hanya karena query yang sama atau relevance yang tinggi.

2. **General / Shared Knowledge**
   - Knowledge bukan Memory SH tertentu;
   - retrieval hanya menerima Knowledge dengan `scope = GENERAL`, `visibility = SHARED`, dan lifecycle `INDEXED` atau `ACTIVE`;
   - provenance/source tetap dipertahankan.

Dengan demikian isolation bukan berarti seluruh context harus private. Isolation berarti setiap source tetap mengikuti boundary-nya sendiri.

## Existing Assembly Boundary

`public.assemble_context(...)` menerima `p_sh_id` untuk Memory dan memanggil existing bounded retrieval paths.

Function berstatus `SECURITY INVOKER` / `prosecdef = false`, sehingga tidak menjadi privileged bypass terhadap RLS.

Output tetap memisahkan:

```text
{
  query: <query>,
  memory: [ ...current SH memory... ],
  knowledge: [ ...eligible general/shared knowledge... ]
}
```

## Minimal Reconciliation

Audit terhadap DEV menunjukkan primitive isolation sudah tersedia pada layer yang lebih rendah:

- Memory ownership RLS;
- SH/account ownership relation;
- explicit `p_sh_id` pada Memory retrieval;
- General/Shared Knowledge retrieval policy;
- `SECURITY INVOKER` context assembly.

Karena itu tidak diperlukan:

- tabel context baru;
- context-specific ownership table;
- RLS policy baru;
- retrieval engine baru;
- duplicate isolation layer;
- perubahan schema Memory/Knowledge;
- perubahan ownership/privacy boundary.

P3E-005 direalisasikan sebagai isolation contract yang menggunakan boundary existing.

## Verification Boundary

Implementation/database boundary diverifikasi terhadap Supabase DEV.

Application-level adversarial cross-account E2E verification tidak diklaim sebagai PASS apabila runtime identity switching tidak tersedia dalam verification path ini.

Status tersebut dicatat sebagai deferred assurance, bukan alasan untuk membuat architecture baru.

## Invariants Preserved

- `MEMORY ≠ KNOWLEDGE ≠ CONTEXT`
- Memory ownership tetap terikat pada SH/account.
- General/shared Knowledge tetap mengikuti sharing boundary.
- Context assembly tidak memperoleh privilege baru.
- Tidak ada perubahan terhadap canonical architecture.

## Non-goals

Item ini tidak menyelesaikan:

- Context Validation (`BL-P3E-006`);
- Context Disposal (`BL-P3E-007`);
- Context Budget & Truncation (`BL-P3E-008`);
- Context Testing (`BL-P3E-009`).

## Completion Statement

`BL-P3E-005 = PASS / DEV`

Context Isolation v1 is realized through existing Memory ownership/RLS and General/Shared Knowledge boundaries, without architectural or schema mutation.
