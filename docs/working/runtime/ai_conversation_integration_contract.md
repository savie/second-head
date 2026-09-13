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

Frontend saat ini memiliki `activeConversationId` dan `ConversationService` memiliki thread-scoped context loader melalui `runtime_load_conversation_context_for_thread`.

Implementation saat ini membawa:

```text
user_message
conversation_id
user_message_id
```

AI Runtime tetap menyelesaikan actor melalui `resolve_identity()`, kemudian mengambil Context Runtime Package yang sudah ada dan melakukan Conversation retrieval berbasis thread melalui `runtime_load_conversation_context_for_thread`.

Fresh client E2E pada build CI #637 telah memverifikasi:

- Conversation A mempertahankan context A;
- Conversation B mempertahankan context B;
- Account 2 tidak memperoleh secret Conversation A melalui conversation/context path;
- setelah session switch kembali ke Account 1, Conversation A tetap mengembalikan context A;
- correlation request/response runtime dan active-thread scope tercatat di Supabase.

Kesimpulan:

**Jalur runtime yang terikat pada Conversation telah melalui fresh client E2E verification untuk isolation dan continuity.**

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
- mengembalikan metadata respons model.

### Context Runtime Package

Tetap menjadi orchestration boundary yang sudah ada.

Perubahan consumer integration tidak boleh bypass `resolve_identity()` atau membuat Context Runtime membaca Conversation yang tidak dimiliki actor.

---

## 4. Required Request Correlation

AI Runtime request membawa:

```text
user_message
conversation_id
user_message_id
```

`conversation_id` menjadi target thread untuk context retrieval.

`user_message_id` menjadi correlation reference antara Message persistence dan runtime audit.

Runtime-generated `request_id` menjadi correlation ID untuk execution runtime.

Assistant Message menyimpan metadata correlation:

```text
runtime_request_id
runtime_provider
runtime_user_message_id
runtime_conversation_id
```

Verified correlation:

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

Implementation saat ini:

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

Ini merupakan implementation terhadap working contract, bukan perubahan Canonical.

Fresh E2E dan Supabase audit telah memverifikasi penggunaan `active-thread` pada runtime request yang diuji.

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

Fresh E2E dan Supabase audit telah memverifikasi bahwa user/assistant Message berada pada Conversation target dan dapat ditelusuri melalui runtime correlation metadata.

---

## 7. Failure Semantics

AI Runtime failure bukan assistant success.

Behavior saat ini:

```text
AI Runtime SUCCESS
  → persist actual assistant output

AI Runtime FAILURE
  → no fabricated assistant output
  → surface runtime failure state
```

Static fallback assistant response pada dynamic AI path telah dihapus.

Frontend sekarang mempertahankan typed backend/runtime failure classification sampai UI boundary, tanpa membuat fake assistant Message pada runtime failure path.

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

Frontend bukan source of truth untuk authority.

Cross-actor database negative execution telah diverifikasi: actor kedua tidak dapat membaca maupun menulis Conversation milik actor lain dan menerima `CONVERSATION_ACCESS_DENIED`.

Full authenticated HTTP/Edge execution dengan foreign `conversation_id` belum dilakukan karena belum tersedia second-session JWT yang dapat digunakan untuk direct request. Hal ini dicatat sebagai **OPTIONAL FINAL VERIFICATION**, bukan blocker terhadap current client/runtime integration evidence.

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

Status berdasarkan evidence yang telah tersedia:

1. Request membawa active `conversation_id`. **VERIFIED**
2. Runtime memverifikasi ownership Conversation. **VERIFIED — DB NEGATIVE + CLIENT E2E**
3. Context yang diberikan ke model berasal dari target Conversation/thread. **VERIFIED — FRESH CLIENT E2E + ACTIVE-THREAD AUDIT**
4. User Message dan assistant Message berada pada Conversation yang sama. **VERIFIED — SUPABASE CORRELATION EVIDENCE**
5. Runtime audit memiliki `request_id`. **VERIFIED**
6. Message ↔ runtime correlation dapat ditelusuri. **VERIFIED — SUPABASE CORRELATION EVIDENCE**
7. Runtime failure tidak menghasilkan fake assistant success. **VERIFIED — IMPLEMENTATION + CI**
8. Fresh E2E membuktikan conversation isolation dengan minimal dua Conversation. **PASS — CI #637 APK E2E**
9. Security test membuktikan actor tidak dapat menggunakan Conversation actor lain. **PASS — DIRECT DB NEGATIVE EXECUTION**

Residual optional verification:

```text
Authenticated HTTP/Edge foreign-conversation request
        ↓
second valid session JWT
        ↓
foreign conversation_id
        ↓
expected CONVERSATION_ACCESS_DENIED
```

Status: **OPTIONAL FINAL VERIFICATION — NON-BLOCKING**.

---

## 11. Current Status

```text
Request identity                  VERIFIED
SH identity resolution             VERIFIED
Provider execution                 VERIFIED
Message persistence ownership      VERIFIED
Duplicate persistence              CLOSED
Failure false-success correction  VERIFIED

conversation_id → runtime          VERIFIED
user_message_id → runtime          VERIFIED
thread-scoped AI context           VERIFIED
response correlation metadata      VERIFIED
conversation isolation             PASS
cross-actor DB authorization       PASS
cross-actor HTTP E2E               OPTIONAL / OPEN
```

**Current client/runtime integration gate: READY / VERIFIED.**

Pemeriksaan HTTP/Edge foreign-conversation yang tersisa sengaja dipertahankan sebagai optional final verification dan tidak memblokir status integration saat ini.

---

## 12. Implementation Record

Implementation DEV yang relevan saat ini:

- `5c94943f9326899975e93deeda12b2eaa78957b0` — frontend backend-error classification dan runtime failure presentation boundary.
- `f8d591578692a8ae5cbf46e19dd259fe4359a463` — mempertahankan typed runtime failures melalui Conversation bridge.
- `1516009fbc7ce067b618969110bba14dd58fccf6` — mengklasifikasikan AI transport failures.
- `3ea510f09f2b78bf66dbf54558ce06ac0f9bdd6f` — menghapus duplicate conversation persistence dari AI Runtime.
- `31e350b89397eb3540a65b5b77a5ee110e1dd548` — correction provider prompt/context saat ini.

Frontend CI #637 untuk `5c94943f9326899975e93deeda12b2eaa78957b0` selesai dengan sukses. Artifact yang dihasilkan adalah `second-head-debug-apk-637`.

Supabase DEV runtime:

- `ai-runtime` deployment version **11**;
- `verify_jwt=true`;
- authenticated runtime path aktif.

Relevant Supabase migrations:

- `20260911233846_restore_authenticated_runtime_conversation_execute` — memulihkan authenticated execution untuk `runtime_record_conversation`.
- `20260912033617_ensure_sh_state_on_sh_creation` — menegakkan invariant lifecycle SH bahwa setiap row `sh_instances` yang baru dimaterialisasi memperoleh initial `sh_states` row.

Sinkronisasi migration GitHub DEV untuk perubahan runtime ini telah diverifikasi.

---

## 13. Next Execution

Urutan fresh-E2E awal sudah selesai dan tidak boleh diulang.

Status saat ini:

```text
Implementation
      ↓
CI #637 GREEN
      ↓
Fresh APK E2E
      ↓
Conversation A isolation      PASS
      ↓
Conversation B isolation      PASS
      ↓
Session-switch continuity    PASS
      ↓
Message ↔ runtime correlation PASS
      ↓
Cross-actor DB authorization  PASS
      ↓
CURRENT GATE READY
```

Hanya optional:

```text
Second authenticated HTTP/Edge session
      ↓
foreign conversation_id
      ↓
CONVERSATION_ACCESS_DENIED
```

Tidak diperlukan pengulangan testing Conversation A/B yang sudah PASS, kecuali perubahan code, database, runtime, atau contract berikutnya membuat evidence tersebut tidak lagi berlaku.
