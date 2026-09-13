# SECOND HEAD — RT-001 Runtime Status

## Status

E2E PROVIDER VERIFIED — WORKING VERIFICATION RECORD

## Verified Baseline

- Request terautentikasi berhasil mencapai `ai-runtime`.
- Resolusi identity berhasil untuk konteks runtime terautentikasi.
- Persistence audit runtime berhasil.
- Context package beserta dependency yang diperiksa berhasil dieksekusi melalui runtime boundary.
- RT-001 HTTP 502 sebelumnya disebabkan oleh tidak adanya `EXECUTE` pada `runtime_record_conversation(uuid,text,text,jsonb)` untuk `authenticated`.
- Supabase DEV migration `20260911233846_restore_authenticated_runtime_conversation_execute` memulihkan privilege tersebut dan memungkinkan verifikasi provider path yang sebelumnya gagal.
- Source migration yang sesuai telah direkonsiliasi ke GitHub `dev`.
- Verifikasi E2E melalui APK yang sudah ada berhasil mencapai `ai-runtime` dan menghasilkan provider response yang sukses; evidence runtime audit dan conversation yang sesuai juga teramati.

## Persistence Ownership Reconciliation

Evidence E2E menemukan defect implementation terpisah: Flutter conversation path dan `ai-runtime` sama-sama melakukan persistence terhadap user/assistant Message, sehingga menghasilkan duplicate Message rows.

Approved Project → Conversation → Message contract saat ini menetapkan `ConversationService` sebagai frontend consumer untuk capability mutation Message pada Conversation dan mengharuskan mutation melewati runtime/RPC boundary yang sesuai. `ConversationService.record()` saat ini menggunakan `runtime_record_conversation_message_v2`.

Karena itu, correction implementation saat ini adalah:

```text
ConversationService
  → owns Conversation Message persistence
  → runtime_record_conversation_message_v2

ai-runtime
  → owns authenticated AI execution
  → identity resolution
  → context retrieval
  → explicit semantic lifecycle
  → provider execution/fallback
  → runtime audit
  → returns model response
```

`ai-runtime` tidak lagi memanggil legacy `runtime_record_conversation(uuid,text,text,jsonb)` persistence path. Ini menghilangkan dual-write yang terobservasi tanpa mengubah Project → Conversation → Message contract atau membuat Message storage path baru.

Existing database function `runtime_record_conversation` tidak dihapus atau direvoke oleh perubahan ini karena consumer legacy/external belum dikesampingkan secara menyeluruh. Karena itu, keberadaannya saat ini bukan evidence bahwa `ai-runtime` masih menggunakannya.

## v8 Verification Gate — CLOSED

Supabase DEV `ai-runtime` mencapai ACTIVE version 8 dengan `verify_jwt=true` setelah deployment correction persistence ownership.

Fresh APK verification test (`RT-001 verification test ke 4`) PASS dengan:

- satu persisted user Message untuk input test;
- satu persisted assistant Message untuk conversation yang sama;
- matching `RUNTIME_REQUEST SUCCESS` dan `RUNTIME_RESPONSE SUCCESS` audit events;
- runtime `request_id` yang sama pada pasangan audit request/response;
- provider `openrouter` berhasil pada attempt pertama;
- response metadata secara eksplisit mengidentifikasi `conversation_persistence=frontend-conversation-service`;
- tidak ada duplicate Message row untuk input test baru.

Duplicate rows dari test sebelumnya merupakan historical evidence dan tidak dihapus secara spekulatif.

Dengan demikian follow-up duplicate-persistence berstatus **CLOSED — E2E VERIFIED**.

## Follow-up: AI Conversation Integration Audit

Duplicate-persistence gate sudah closed, tetapi dynamic AI conversation integration yang lebih luas belum closed.

Evidence saat ini menunjukkan dua gap terpisah:

1. **Active-thread identity belum menjadi bagian dari AI runtime request.** `RuntimeRequest` saat ini hanya membawa `input`, sedangkan Flutter transport memanggil `ai-runtime` hanya dengan `user_message`.
2. **Context Runtime saat ini menyusun conversation context berdasarkan `p_sh_id`, bukan berdasarkan active conversation/thread.** `runtime_get_context_package()` memanggil `runtime_load_conversation_context(p_sh_id)`, yang implementation saat ini memilih recent conversation rows untuk authenticated account/SH. Ini berbeda dengan frontend capability yang secara eksplisit thread-scoped, yaitu `runtime_load_conversation_context_for_thread(p_conversation_id, p_limit)`.

Ini adalah integration gap pada architecture, bukan alasan untuk melewati identity/security boundary. Gap ini membutuhkan keputusan contract/implementation eksplisit sebelum mengubah runtime request atau Context Runtime input shape.

Correction untuk failure semantics terpisah sudah diterapkan pada Flutter bridge: runtime failure tidak lagi fallback ke persistence static assistant response. Bridge sekarang meneruskan `AppFailure<RuntimeResponse>` alih-alih mengubahnya menjadi assistant Message. Ini memenuhi requirement approved conversation contract bahwa backend failure tidak boleh menghasilkan false success.

Catch path `ConversationView` saat ini masih memerlukan verification terfokus karena dapat menambahkan local user representation setelah user Message sudah dipersist. Ini adalah UI-state issue dan tidak boleh disamakan dengan backend duplicate persistence.

## Boundary Note

Flutter transport saat ini memanggil `ai-runtime`; tidak ditemukan invocation Flutter source saat ini terhadap `runtime-p4a-001`. Evidence E2E terbaru mengonfirmasi corrected APK → `ai-runtime` path.

## Legacy Boundary

`runtime-p4a-001` tetap legacy/reference-only untuk keputusan architecture saat ini. Source inspection saat ini tidak menemukan consumer aktif. Evidence audit Supabase menunjukkan traffic legacy `RUNTIME_REQUEST` hanya sampai `2026-09-05 15:16:58.150014+`. Retirement tetap merupakan operational action dan bukan prerequisite untuk current `ai-runtime` path.

## Decision

RT-001 runtime/provider execution tetap terverifikasi. Defect dual-write berstatus **CLOSED — E2E VERIFIED**. Gate berikutnya adalah **AI Conversation Integration Audit**, khususnya active-thread correlation, thread-scoped context, runtime request ↔ Message correlation, dan failure-state verification.

Jangan menggunakan legacy runtime sebagai dependency. Pertahankan `runtime-p4a-001` sebagai reference-only sampai retirement gate terpisah selesai dan administrative operation Edge Function tersedia.
