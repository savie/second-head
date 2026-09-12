# SECOND HEAD — AI Conversation Integration Contract

## Status

**WORKING CONTRACT DRAFT**

## Authority

Dokumen ini adalah supporting working contract.

Dokumen ini:

- tidak mengubah Canonical;
- tidak menggantikan `docs/contract/sh_context_runtime_package_contract.md`;
- tidak mengubah Project → Conversation → Message contract;
- tidak menganggap implementation saat ini sebagai semantic completion.

Jika terdapat konflik dengan Canonical atau authority yang lebih tinggi, authority yang lebih tinggi berlaku.

---

## 1. Tujuan

Mendefinisikan boundary antara Conversation Runtime dan AI Runtime agar respons AI benar-benar terikat pada Conversation aktif, tanpa memindahkan ownership persistence dari `ConversationService` atau menghapus security boundary identity resolution.

Target:

```text
Active Conversation
      ↓
Conversation Message
      ↓
AI Runtime Request
      ↓
Thread-scoped Context
      ↓
Provider Execution
      ↓
AI Runtime Response
      ↓
ConversationService Message Persistence
```

---

## 2. Current Evidence

Current frontend sudah memiliki `activeConversationId` dan `ConversationService` memiliki thread-scoped context loader melalui `runtime_load_conversation_context_for_thread`.

Namun `RuntimeRequest` saat ini hanya membawa `input`, sedangkan transport hanya mengirim `user_message` ke `ai-runtime`.

Current `ai-runtime` menerima `p_sh_id` melalui identity resolution dan meminta `runtime_get_context_package(p_sh_id, p_query_text)`. Context package tersebut menggunakan `runtime_load_conversation_context(p_sh_id)`, sehingga conversation context masih berada pada scope SH, bukan active conversation/thread.

Kesimpulan audit:

**Dynamic provider execution sudah verified, tetapi conversation-aware runtime context belum verified.**

---

## 3. Ownership Boundary

### ConversationService

Owner untuk:

- active Conversation selection/state;
- Message persistence;
- Message identity;
- thread identity pada Message persistence.

### AI Runtime

Owner untuk:

- authenticated AI execution;
- identity resolution;
- authorization boundary;
- thread-scoped context retrieval setelah target Conversation diberikan;
- provider execution/fallback;
- runtime audit;
- semantic runtime lifecycle;
- returning model response metadata.

### Context Runtime Package

Tetap menjadi orchestration boundary yang ada.

Perubahan consumer integration tidak boleh bypass `resolve_identity()` atau membuat Context Runtime membaca Conversation yang tidak dimiliki actor.

---

## 4. Required Request Correlation

AI Runtime request harus dapat mengidentifikasi minimal:

```text
user_message
conversation_id
user_message_id
```

`conversation_id` menjadi target thread untuk context retrieval.

`user_message_id` menjadi correlation reference antara Message persistence dan runtime audit.

Runtime-generated `request_id` tetap menjadi correlation ID eksekusi runtime.

Target correlation:

```text
user_message_id
      ↕
RUNTIME_REQUEST.request_id
      ↕
RUNTIME_RESPONSE.request_id
      ↕
assistant Message metadata.runtime_request_id
```

Nama field final masih implementation detail sampai contract ini disetujui/frozen.

---

## 5. Context Boundary

AI Runtime tidak boleh mengambil context Conversation secara global berdasarkan SH apabila request sudah memiliki target Conversation.

Target behavior:

```text
request.conversation_id
        ↓
ownership verification
        ↓
runtime_load_conversation_context_for_thread()
        ↓
thread context
```

`runtime_get_context_package(p_sh_id, p_query_text)` tetap dipertahankan sebagai existing Context Runtime contract sampai ada authority eksplisit untuk memperluas input-nya.

Untuk integrasi awal, AI Runtime dapat melakukan thread-scoped Conversation retrieval sebagai dependency tambahan dan menggabungkannya ke execution context, tanpa mengubah output contract Context Runtime Package.

Ini adalah proposed implementation direction, bukan perubahan Canonical.

---

## 6. Message Identity

User Message harus dipersist sebelum AI execution, sehingga AI Runtime menerima identity dari Message yang sudah durable.

Flow target:

```text
record user Message
      ↓
message_id + conversation_id
      ↓
AI Runtime Request
      ↓
provider
      ↓
assistant response
      ↓
record assistant Message
```

Tidak boleh menggunakan content string sebagai satu-satunya correlation mechanism.

---

## 7. Failure Semantics

AI Runtime failure bukan assistant success.

Target:

```text
AI Runtime SUCCESS
  → persist actual assistant output

AI Runtime FAILURE
  → no fabricated assistant output
  → surface runtime failure state
```

Fallback UI/content hanya boleh digunakan jika contract eksplisit mendefinisikan fallback tersebut sebagai valid system behavior. Saat ini tidak ada evidence yang cukup untuk menjadikan static assistant text sebagai successful AI response.

---

## 8. Security

`conversation_id` dari frontend adalah request target, bukan authority.

Runtime harus memverifikasi bahwa target Conversation dimiliki actor yang telah di-resolve:

```text
Authorization
 ↓
resolve_identity()
 ↓
resolved account + sh
 ↓
conversation ownership check
 ↓
thread context
```

Frontend tidak boleh menjadi source of truth untuk authority.

---

## 9. Non-Goals

Scope ini tidak mencakup:

- perubahan Canonical identity model;
- redesign Conversation hierarchy;
- migration Message storage baru;
- penghapusan `runtime_get_context_package`;
- provider redesign;
- semantic persistence redesign;
- legacy runtime activation;
- retirement `runtime-p4a-*`.

---

## 10. Verification Gate

Sebelum dynamic AI conversation integration dianggap selesai:

1. Request membawa active `conversation_id`.
2. Runtime memverifikasi ownership Conversation.
3. Context yang diberikan ke model berasal dari target Conversation/thread.
4. User Message dan assistant Message berada pada Conversation yang sama.
5. Runtime audit memiliki `request_id`.
6. Message ↔ runtime correlation dapat ditelusuri.
7. Runtime failure tidak menghasilkan fake assistant success.
8. Fresh E2E membuktikan conversation isolation dengan minimal dua Conversation.
9. Security test membuktikan actor tidak dapat menggunakan Conversation actor lain.

---

## 11. Current Status

```text
Request identity                 IMPLEMENTED
SH identity resolution            VERIFIED
Provider execution                VERIFIED
Message persistence ownership     VERIFIED
Duplicate persistence             CLOSED
Failure false-success correction IMPLEMENTED

conversation_id in AI request     OPEN
thread-scoped AI context          OPEN
Message ↔ request correlation     OPEN
cross-conversation isolation      OPEN
```

**Gate belum READY FOR FINAL E2E.**

---

## 12. Next Execution

Urutan implementation yang disarankan:

```text
Contract review
      ↓
RuntimeRequest extension
      ↓
Transport payload extension
      ↓
AI Runtime conversation ownership check
      ↓
Thread-scoped context injection
      ↓
Response correlation metadata
      ↓
ConversationService persistence metadata
      ↓
Fresh E2E isolation test
      ↓
Security verification
```

Tidak ada migration yang diperlukan pada tahap contract design ini.
