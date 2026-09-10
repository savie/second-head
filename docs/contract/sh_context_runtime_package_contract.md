# SH Context Runtime Package Contract

## Status

Dokumen contract runtime.

## Tujuan

Dokumen ini mendefinisikan boundary contract untuk Context Runtime Package.

Contract ini menjadi acuan implementasi backend runtime dan tidak mengubah Canonical semantic yang sudah ada.

## Scope

Context Runtime Package adalah orchestration layer yang menggabungkan runtime boundary yang sudah tersedia.

Tidak membuat:

- tabel Context baru;
- storage Conversation baru;
- storage Memory baru;
- storage Knowledge baru;
- bypass security boundary.

## Logical RPC

```text
runtime_get_context_package(
    p_sh_id,
    p_query_text
)
```

## Input

| Parameter | Tipe | Deskripsi |
|---|---|---|
| p_sh_id | uuid | Identitas SH target |
| p_query_text | text | Query untuk semantic context assembly |

## Output Contract

```json
{
  "sh_id": "uuid",
  "conversation": [],
  "state": {},
  "semantic": {}
}
```

## Assembly Boundary

```text
Request
  |
  v
Context Runtime Package
  |
  +--> Actor Identity Resolver
  |
  +--> Conversation Context Runtime
  |
  +--> SH State Runtime
  |
  +--> Semantic Context Assembly
  |
  v
Context Package
```

## Dependency

Runtime ini menggunakan:

- `resolve_identity()`
- `runtime_load_conversation_context()`
- `runtime_get_sh_state()`
- `assemble_context()`

## Security Boundary

Runtime mengikuti pattern:

- SECURITY DEFINER;
- search_path public;
- identity validation;
- ownership validation;
- authenticated execution boundary.

## Non Goal

Implementasi ini tidak:

- menggantikan Conversation Runtime;
- menggantikan State Runtime;
- menggantikan Context Assembly Engine;
- mendefinisikan FE contract.

## Status Implementasi

Step 1:

- runtime entry point: selesai;
- migration: selesai;
- Supabase DEV: sinkron;
- consumer layer: belum masuk scope.
