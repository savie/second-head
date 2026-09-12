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

Current frontend memiliki `activeConversationId` dan `ConversationService` memiliki thread-scoped context loader melalui `runtime_load_conversation_context_for_thread`.

Sebelumnya `RuntimeRequest` hanya membawa `input`, sedangkan transport hanya mengirim `user_message` ke `ai-runtime`.

Current implementation sekarang telah memperluas request menjadi:

```text
user_message
conversation_id
user_message_id
```

AI Runtime tetap menyelesaikan actor melalui `resolve_identity()`, kemudian mengambil existing Context Runtime Package dan melakukan thread-scoped Conversation retrieval melalui `runtime_load_conversation_context_for_thread`.

Kesimpulan:

**Conversation-aware runtime path sudah diimplementasikan, tetapi belum dianggap verified sampai fresh E2E isolation dan security gate lulus.**

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

AI Runtime request sekarang membawa:

```text
user_message
conversation_id
user_message_id
```

`conversation_id` menjadi target thread untuk context retrieval.

`user_message_id` menjadi correlation reference antara Message persistence dan runtime audit.

Runtime-generated `request_id` menjadi correlation ID eksekusi runtime.

Assistant Message sekarang menyimpan metadata correlation:

```text
runtime_request_id
runtime_provider
runtime_user_message_id
runtime_conversation_id
```

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

---

## 5. Context Boundary

AI Runtime tidak menggunakan Conversation context global berdasarkan SH sebagai context utama apabila request memiliki target Conversation.

Current implementation:

```text
request.conversation_id
        ↓
resolve_identity()
        ↓
runtime_load_conversation_context_for_thread()
        ↓
thread context
        ↓
provider
```

`runtime_get_context_package(p_sh_id, p_query_text)` tetap dipertahankan sebagai existing Context Runtime contract dan tidak diperluas oleh implementation ini.

AI Runtime menggabungkan hasil thread-scoped Conversation retrieval ke execution context dengan marker:

```text
conversation_context_scope = active-thread
```

Ini adalah implementation terhadap working contract, bukan perubahan Canonical.

---

## 6. Message Identity

User Message dipersist sebelum AI execution, sehingga AI Runtime menerima identity dari Message yang sudah durable.

Current flow:

```text
record user Message
      ↓
message_id + conversation_id
      ↓
AI Runtime Request
      ↓
ownership + thread verification
      ↓
provider
      ↓
assistant response
      ↓
record assistant Message + runtime correlation metadata
```

Content string tidak digunakan sebagai satu-satunya correlation mechanism.

---

## 7. Failure Semantics

AI Runtime failure bukan assistant success.

Current behavior:

```text
AI Runtime SUCCESS
  → persist actual assistant output

AI Runtime FAILURE
  → no fabricated assistant output
  → surface runtime failure state
```

Static fallback assistant response pada dynamic AI path telah dihapus.

---

## 8. Security

`conversation_id` dari frontend adalah request target, bukan authority.

Runtime menggunakan authenticated identity lalu memanggil thread-scoped RPC yang melakukan ownership validation terhadap account + SH sebelum mengembalikan Conversation context.

Flow:

```text
Authorization
 ↓
resolve_identity()
 ↓
resolved account + sh
 ↓
runtime_load_conversation_context_for_thread()
 ↓
conversation ownership check
 ↓
thread context
```

Frontend tidak menjadi source of truth untuk authority.

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

1. Request membawa active `conversation_id`. **IMPLEMENTED**
2. Runtime memverifikasi ownership Conversation. **IMPLEMENTED — E2E PENDING**
3. Context yang diberikan ke model berasal dari target Conversation/thread. **IMPLEMENTED — E2E PENDING**
4. User Message dan assistant Message berada pada Conversation yang sama. **IMPLEMENTED — E2E PENDING**
5. Runtime audit memiliki `request_id`. **VERIFIED**
6. Message ↔ runtime correlation dapat ditelusuri. **IMPLEMENTED — E2E PENDING**
7. Runtime failure tidak menghasilkan fake assistant success. **IMPLEMENTED**
8. Fresh E2E membuktikan conversation isolation dengan minimal dua Conversation. **OPEN**
9. Security test membuktikan actor tidak dapat menggunakan Conversation actor lain. **OPEN**

---

## 11. Current Status

```text
Request identity                  IMPLEMENTED
SH identity resolution             VERIFIED
Provider execution                 VERIFIED
Message persistence ownership      VERIFIED
Duplicate persistence              CLOSED
Failure false-success correction  IMPLEMENTED

conversation_id → runtime          IMPLEMENTED
user_message_id → runtime          IMPLEMENTED
thread-scoped AI context           IMPLEMENTED
response correlation metadata      IMPLEMENTED
cross-conversation isolation       OPEN
security isolation E2E             OPEN
```

**Gate belum READY FOR FINAL E2E.**

---

## 12. Implementation Record

Current DEV implementation commits:

- Runtime contract correlation: `00c5b13cd7610fac7be584bd5de8c88fdece726f`
- Provider boundary correlation: `390421dedda580385d57f9a40959309cb819ce41`
- Transport payload correlation: `b9482b8adaf235a6746a7d71dc9592b8534bb43b`
- Conversation bridge correlation + failure semantics: `7358d0ca336f43a21b286c05db262a7dbf6b4a05`
- AI Runtime thread-scoped context: `7fa12dff5e4520597cf1a0a8a6eb6ba6d04019d0`

Supabase DEV `ai-runtime` is deployed at version **10**, `verify_jwt=true`.

Version 10 includes the conversation-aware runtime implementation and the existing semantic lifecycle dependency. No database migration was introduced for this integration step.

---

## 13. Next Execution

```text
Current implementation
      ↓
Fresh APK / client E2E
      ↓
Conversation A isolation
      ↓
Conversation B isolation
      ↓
request ↔ Message correlation verification
      ↓
cross-actor Conversation access rejection
      ↓
FINAL GATE
```
