# SECOND HEAD — Conversation Inventory & Reconciliation

## Status

**WORKING / DOMAIN LIVING AUDIT**

Dokumen ini adalah child working document dari:

`docs/working/sh_core_inventory_reconciliation.md`

Dokumen ini **bukan Canonical** dan **bukan Approved Contract**. Fungsinya mendokumentasikan inventory, reconciliation, confirmed gap, open item, dan verification untuk domain Conversation pada current `dev`.

Authority tetap:

```text
Owner / User Decision
        ↓
Canonical
        ↓
Approved Contract
        ↓
Architecture / Design
        ↓
Current Implementation
        ↓
Historical / dev_old evidence
```

Dokumen ini tidak boleh mengubah Canonical atau contract secara sepihak.

---

## 1. Scope

Domain yang diaudit:

```text
Identity / Actor Context
        ↓
Account / SH
        ↓
Project
        ↓
Conversation Thread
        ↓
Message
        ├── content
        ├── metadata
        ├── attachment
        └── future runtime / AI integration
```

Scope audit meliputi:

- Project ↔ Conversation hierarchy;
- Conversation lifecycle;
- Message model dan Message ID;
- backend RPC/runtime boundary;
- frontend service dan adapter;
- attachment / multimodal persistence;
- local persistence dan backend persistence;
- metadata;
- ordering/race/state consistency;
- context loading;
- AI/runtime integration boundary;
- security/isolation;
- recovery implications;
- UI rendering dan caller integration;
- confirmed gaps dan verification gate.

---

## 2. Related Authority / Contract

Approved working contract:

`docs/contract/sh_project_conversation_message_contract.md`

Contract utama menetapkan:

```text
Project
   ↓
Conversation
   ↓
Message
```

Mutation tetap melalui runtime/RPC boundary yang sesuai. Existing `public.conversations` tetap menjadi storage Message pada hierarchy berjalan saat ini. Message capability mencakup load, record, update, delete individual message, dan clear sesuai semantics yang masih harus divalidasi. fileciteturn173file0L2-L2

---

## 3. Current Architecture Evidence

Current FE boundary:

```text
ConversationView
      ↓
ConversationRuntimeBridge
      ↓
ConversationService
      ↓
backendClient
      ↓
Supabase RPC
```

Current files yang teridentifikasi:

```text
app/lib/features/conversation/
├── conversation_runtime_bridge.dart
├── conversation_service.dart
└── conversation_view.dart
```

Current `ConversationService` sudah menyediakan runtime call untuk Project, Conversation, Message, dan context. Model `ConversationRecord` sudah membawa `messageId`, `threadId`, `role`, `content`, `createdAt`, dan `metadata`. fileciteturn172file0L2-L2

---

## 4. Backend Message Storage

Current DEV `public.conversations` memiliki minimal:

```text
conversation_id uuid
account_id uuid
sh_id uuid
role text
content text
created_at timestamptz
metadata jsonb
thread_id uuid
message_id uuid
```

Current `public.conversation_threads` memiliki:

```text
conversation_id uuid
account_id uuid
sh_id uuid
project_id uuid nullable
title text
created_at timestamptz
updated_at timestamptz
```

Relationship berjalan:

```text
conversation_threads
        ↓
conversations
```

Backend `runtime_load_conversation_messages` mengembalikan `message_id`, `conversation_id`, `role`, `content`, `created_at`, dan `metadata`, serta memvalidasi Account + SH dari trusted identity sebelum membaca message.

Backend `runtime_record_conversation_message` menerima `p_metadata jsonb`, melakukan trusted identity/access check, lalu menyimpan metadata bersama message.

**Implikasi:** storage `metadata` sudah tersedia untuk message-level structured data. Belum berarti semantics attachment di metadata sudah disepakati atau lengkap.

---

## 5. Message ID Reconciliation

### Contract

Mutation backend menggunakan:

```text
p_message_id uuid
```

untuk update/delete individual Message.

### Backend

Current RPC:

```text
runtime_update_conversation_message_v2(p_message_id uuid, ...)
runtime_delete_conversation_message_v2(p_message_id uuid)
```

Backend contract menggunakan Message ID, bukan Conversation/Thread ID.

### Service

`ConversationService.updateMessage()` dan `deleteMessage()` sudah memanggil RPC dengan parameter `p_message_id`. fileciteturn172file0L2-L2

### FE model / caller

`ConversationView._messageFromBackend()` memetakan backend `record.messageId` menjadi `ConversationMessage.runtimeRecordId`. Caller action kemudian menggunakan `runtimeRecordId` untuk mutation.

### Bridge

`ConversationRuntimeBridge` saat ini menggunakan nama parameter `conversationId` pada method update/delete, tetapi nilai yang diteruskan ke service sebenarnya adalah `runtimeRecordId` / Message ID.

### Classification

**CONFIRMED ADAPTER CONTRACT / NAMING GAP**

Ini bukan bukti bahwa backend menerima Conversation ID secara aktual pada current caller path. Caller sudah menyediakan Message ID yang benar. Gap berada pada adapter API/naming yang misleading dan harus diselaraskan tanpa mengubah backend semantics.

### Implementation gate

Perubahan yang dibenarkan setelah audit caller selesai:

```text
Bridge updateMessage(messageId: ...)
Bridge deleteMessage(messageId: ...)
        ↓
Service p_message_id
        ↓
Backend Message ID
```

Tidak perlu migration berdasarkan evidence saat ini.

---

## 6. Attachment / Multimodal Reconciliation

### Current FE behavior

`ConversationView` menyediakan:

```text
Camera
Photos
File
```

Image/file dipilih melalui `image_picker` / `file_picker`, lalu disimpan melalui `StorageService` sebagai file lokal.

Setelah storage lokal berhasil, FE membuat:

```text
ConversationMessage(
    text: '',
    attachmentPath: stored.path
)
```

dan menyimpan local conversation state.

### Current persistence path

```text
Picker
  ↓
StorageService.saveConversationImage / saveConversationFile
  ↓
local path
  ↓
ConversationMessage.attachmentPath
  ↓
local conversation state
```

### Problem

Saat conversation berhasil dimuat dari backend, `_loadConversation()` mengganti `_messages` berdasarkan backend records. `_messageFromBackend()` saat ini hanya memetakan backend message fields dan tidak memulihkan `attachmentPath` dari metadata.

Akibatnya:

```text
Attachment local
     ↓
Backend conversation load berhasil
     ↓
_local messages reconstructed from backend
     ↓
attachmentPath tidak ikut direconstruct
     ↓
attachment tidak muncul di FE
```

Ini konsisten dengan gejala: attachment sempat terlihat secara local, tetapi hilang setelah conversation reload/reopen.

### Backend evidence

`public.conversations.metadata jsonb` sudah tersedia dan `runtime_record_conversation_message` sudah menerima metadata.

Namun belum ada evidence yang cukup untuk menyatakan bahwa `metadata` saat ini sudah memiliki **approved attachment schema**.

### Classification

**CONFIRMED FE ↔ BACKEND PERSISTENCE / RECONSTRUCTION GAP**

Belum boleh langsung membuat migration atau memilih schema baru sebelum inventory model, renderer, storage reference, dan metadata usage selesai.

---

## 7. Attachment Contract — Open Questions

Hal yang wajib diaudit sebelum implementation:

```text
Attachment
├── type
├── MIME type
├── filename
├── size
├── local reference
├── durable/backend reference
├── preview/reference
└── lifecycle / deletion semantics
```

Pertanyaan utama:

1. Apakah attachment descriptor memang menjadi bagian dari Message metadata?
2. Apakah local filesystem path boleh menjadi persistence reference, atau hanya local cache/reference?
3. Jika attachment perlu durable persistence, storage backend apa yang menjadi source of truth?
4. Bagaimana Account/SH isolation diterapkan pada attachment?
5. Bagaimana attachment direconstruct saat reload?
6. Bagaimana unsupported/broken attachment ditampilkan?
7. Apakah image/file/audio/video memiliki satu typed representation atau semantics berbeda?

**Status: OPEN.** Jangan mengarang schema sebelum evidence/contract mendukungnya.

---

## 8. Message Model / Serialization

Current `ConversationRecord` sudah memiliki:

```text
messageId
threadId
role
content
createdAt
metadata
```

Current `ConversationMessage` juga memiliki runtime record identity dan local attachment representation.

Audit berikutnya wajib memastikan secara utuh:

```text
ConversationMessage
   ↕
toJson / fromJson
   ↕
ConversationRecord
   ↕
backend metadata
```

Target reconciliation:

- Message ID;
- Thread ID;
- role;
- content;
- timestamp;
- metadata;
- attachment descriptor;
- local-only state;
- backend-persisted state.

**Status: AUDIT OPEN.**

---

## 9. Conversation Lifecycle

Contract lifecycle:

```text
Create
 ↓
Select / Open
 ↓
Load
 ↓
Active
 ↓
Rename
 ↓
Move / Remove Project
 ↓
Clear
 ↓
Delete
```

Current backend capability sudah tersedia untuk create/list/select-related FE state, rename, move/remove project, load, record, update/delete message, dan delete thread.

Verification yang belum final:

- delete active conversation;
- delete non-active conversation;
- project deletion dengan child conversation;
- active conversation consistency;
- reload setelah mutation;
- empty conversation;
- backend failure versus local fallback.

**Status: IMPLEMENTATION PRESENT / SEMANTIC VERIFICATION OPEN.**

---

## 10. Clear vs Delete

Canonical/contract distinction:

```text
Clear
→ membersihkan message/content sesuai semantics yang ditetapkan
→ Conversation tetap ada

Delete Conversation
→ menghapus Conversation thread
→ child Messages mengikuti lifecycle deletion
```

Current FE clear implementation melakukan delete individual messages berdasarkan `runtimeRecordId`. Ini harus direkonsiliasi dengan final Clear semantics dan persistence behavior.

Current contract menyatakan Clear behavior masih perlu divalidasi.

**Status: OPEN / DO NOT MARK PASS.**

---

## 11. Local Persistence / Backend Persistence

Current FE memiliki local conversation state dan backend conversation persistence.

Current fallback pattern:

```text
Backend load succeeds
    ↓
backend records become current FE state

Backend load fails
    ↓
local conversation state fallback
```

Ini belum boleh disebut sebagai full offline synchronization architecture.

Open questions:

- local-newer-than-backend;
- backend-newer-than-local;
- retry;
- queue;
- duplicate prevention;
- conflict resolution;
- attachment synchronization;
- deletion synchronization.

Approved contract masih menempatkan full offline synchronization/conflict behavior sebagai open item.

**Status: OPEN.**

---

## 12. Ordering / Race / State Consistency

Belum final diverifikasi:

```text
send A
send B
→ network ordering

edit
→ delete
→ reload

switch conversation
→ in-flight request

create
→ select
→ load
```

Current backend load ordering menggunakan:

```text
created_at ASC
message_id ASC
```

sehingga tie-breaker Message ID tersedia di backend load.

FE state/race behavior tetap perlu diuji.

**Status: AUDIT OPEN.**

---

## 13. Conversation Context

Current backend capability:

```text
runtime_load_conversation_context_for_thread
```

Current FE `ConversationService.loadContext()` sudah memanggil capability tersebut.

Belum terbukti bahwa capability tersebut sudah menjadi input aktif untuk AI/runtime response.

Target boundary:

```text
Conversation
   ↓
Conversation Context
   ↓
AI / SH Runtime
   ↓
Model
   ↓
Assistant Message
```

**Status: CAPABILITY PRESENT / RUNTIME USAGE OPEN.**

---

## 14. AI / Runtime Response

Current FE masih memiliki static assistant response setelah user message.

Current flow secara semantic:

```text
User Message
   ↓
recordUser
   ↓
static delay
   ↓
static assistant reply
   ↓
recordAssistant
```

Dynamic AI/model integration belum selesai dan memang tercatat sebagai open item pada approved contract.

Actor Resolution yang sudah diselesaikan harus menjadi boundary identity/actor untuk runtime berikutnya; Model tidak boleh menjadi sumber SH identity/authority.

**Status: OPEN — separate from basic Conversation persistence.**

---

## 15. Security / Isolation

Minimum semantic verification:

```text
Account A → own Conversation → ALLOW
Account A → Account B Conversation → DENY
Account A → Account B Message → DENY
spoofed identity → DENY
unauthenticated → DENY
```

Attachment, jika menjadi durable backend resource, harus mengikuti isolation boundary yang sama.

Backend current message load/record sudah menggunakan trusted resolved identity dan Account + SH ownership checks.

**Status: BASELINE PRESENT / FULL SEMANTIC HARNESS OPEN.**

---

## 16. Recovery Implications

Recovery domain sudah ada di current SH backend, tetapi belum boleh diasumsikan otomatis mencakup:

- Conversation thread;
- Messages;
- Message metadata;
- Attachments;
- Project relation.

Attachment khususnya perlu ditentukan apakah local-only atau durable resource sebelum recovery semantics dapat dinyatakan.

**Status: OPEN.**

---

## 17. Search Boundary

Current Project/Conversation management search adalah local filtering terhadap loaded summaries.

Belum ada evidence bahwa current architecture memiliki backend Message Search capability terpisah.

Bedakan:

```text
Project/Conversation local filtering
≠
Message search
≠
Semantic search
```

Jangan menambah backend search capability hanya karena UI membutuhkan pencarian sebelum contract/domain audit membuktikannya.

**Status: CURRENT LOCAL FILTER / BROADER SEARCH OPEN.**

---

## 18. Error Semantics

Current FE masih memiliki beberapa broad catch/fallback behavior.

Audit lanjutan harus membedakan setidaknya secara internal:

```text
Unauthenticated
Authorization denied
Network unavailable
Backend contract/runtime error
Invalid message
Attachment error
Unknown error
```

Tidak berarti semua error harus ditampilkan verbatim kepada user.

Tujuannya adalah memastikan UI tidak menghasilkan false success dan runtime tidak kehilangan semantic distinction.

**Status: AUDIT OPEN.**

---

## 19. Title Lifecycle

Current Conversation memiliki title dan rename capability.

Belum final diverifikasi:

- default title semantics;
- automatic title generation;
- first-message behavior;
- rename persistence;
- race antara rename dan message mutation.

Jangan mengasumsikan auto-title sebelum evidence/contract ditemukan.

**Status: AUDIT OPEN.**

---

## 20. Assistant / Role Semantics

Current backend menerima role:

```text
user
assistant
system
```

Belum ada keputusan untuk memperluas role taxonomy.

Jangan menambahkan role baru untuk tool/model/runtime sebelum architecture/contract membutuhkan dan authority-nya jelas.

**Status: CURRENT ROLE SET / SEMANTIC AUDIT OPEN.**

---

## 21. Current Confirmed Gaps

### GAP-C01 — Bridge Message ID Naming

```text
Status: CONFIRMED
Layer: FE adapter
Severity: functional correctness / maintainability
```

Caller sudah membawa Message ID melalui `runtimeRecordId`, tetapi bridge menamainya `conversationId`.

Fix yang diharapkan minimal: align bridge parameter naming dengan Message ID semantics.

### GAP-C02 — Attachment Backend Persistence / Reconstruction

```text
Status: CONFIRMED
Layer: FE ↔ backend Message representation
Severity: functional persistence
```

Attachment saat ini tersimpan lokal dan dapat masuk local conversation state, tetapi backend Message reconstruction belum membawa attachment representation kembali ke FE.

Backend `metadata jsonb` sudah tersedia, tetapi attachment schema belum terbukti/approved.

### Tidak ada confirmed migration gap untuk attachment saat checkpoint ini.

Migration baru boleh dibuat jika audit membuktikan storage/contract memang membutuhkan schema/database change.

---

## 22. Open Audit Queue

Urutan eksplorasi berikutnya:

```text
1. ConversationMessage full model + toJson/fromJson
2. Attachment renderer / message widget
3. StorageService attachment semantics
4. All metadata usages
5. Bridge caller final trace
6. Clear/Delete semantic verification
7. Project ↔ Conversation lifecycle verification
8. Context usage trace
9. AI runtime boundary
10. Local ↔ backend synchronization
11. Ordering / race / state consistency
12. Error semantics
13. Security semantic harness
14. Recovery relationship
15. Title lifecycle
16. Role semantics
17. Final confirmed-gap consolidation
```

No coding before confirmed-gap inventory for the relevant audit scope is complete.

---

## 23. Implementation Gate

Setelah audit selesai:

```text
Audit
 ↓
Confirmed Gap List
 ↓
Contract / architecture impact check
 ↓
Minimal implementation
 ↓
Backend verification
 ↓
FE verification
 ↓
Security / isolation verification
 ↓
APK E2E
 ↓
Update parent living inventory
```

Tidak boleh mengubah Canonical untuk menyelesaikan implementation gap.

Tidak boleh membuat migration hanya karena ada local attachment bug tanpa membuktikan database/storage requirement.

---

## 24. Parent Living Inventory Relationship

Parent:

`docs/working/sh_core_inventory_reconciliation.md`

Parent tetap menjadi sumber status lintas domain.

Dokumen ini menjadi detail Conversation reconciliation dan tidak menggantikan parent.

Setelah domain audit memiliki confirmed status yang stabil, parent cukup memuat summary/status/pointer dan tidak perlu menyalin seluruh detail teknis Conversation.

---

## 25. Current Checkpoint

```text
Conversation Contract              PASS
Backend Message RPC               PASS
ConversationService               PASS
Caller Message ID                 PASS
Bridge Message ID naming          CONFIRMED GAP
Attachment local persistence      PRESENT
Attachment backend persistence    CONFIRMED GAP
Attachment typed contract         OPEN
Message serialization             OPEN
Clear semantics                   OPEN
Lifecycle semantics               OPEN
Context runtime usage             OPEN
AI runtime                        OPEN
Offline/conflict sync             OPEN
Security semantic harness         OPEN
Recovery semantics               OPEN
```

**Overall Conversation status: AUDIT IN PROGRESS.**

Belum ready untuk menyatakan Conversation domain selesai atau memulai broad UI refactor.
