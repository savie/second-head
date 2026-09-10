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

Scope audit meliputi Project ↔ Conversation hierarchy, lifecycle, Message model/ID, backend RPC/runtime boundary, frontend service/adapter, attachment/multimodal persistence, local/backend persistence, metadata, ordering/race/state consistency, context, AI/runtime boundary, security/isolation, recovery, UI/caller integration, dan verification gate.

---

## 2. Related Authority / Contract

Approved contract yang relevan:

- `docs/contract/sh_project_conversation_message_contract.md`
- `docs/contract/sh_conversation_attachment_contract.md`

Attachment contract sudah **APPROVED / LOCKED**. Migration design attachment juga sudah frozen/locked. Dokumen reconciliation tidak boleh mengubah keduanya tanpa conflict evidence atau instruksi eksplisit.

Contract utama menetapkan:

```text
Project
   ↓
Conversation
   ↓
Message
```

Mutation tetap melalui runtime/RPC boundary yang sesuai. Existing `public.conversations` tetap menjadi storage Message pada hierarchy berjalan saat ini.

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
ConversationAttachmentService / StorageService
      ↓
backendClient / Supabase Storage
      ↓
Supabase RPC
```

Current files:

```text
app/lib/features/conversation/
├── conversation_runtime_bridge.dart
├── conversation_service.dart
├── conversation_attachment_service.dart
└── conversation_view.dart
```

`ConversationService` menyediakan runtime call untuk Project, Conversation, Message, context, dan attachment hydration. `ConversationRecord` membawa Message identity, thread, role, content, timestamp, metadata, dan attachment descriptors.

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

`runtime_load_conversation_messages` mengembalikan Message identity dan metadata serta memvalidasi Account + SH dari trusted identity sebelum membaca message. `runtime_record_conversation_message` menerima `p_metadata jsonb` dan melakukan trusted identity/access check sebelum persistence.

**Implikasi:** `metadata` tetap tersedia sebagai message-level structured data. Namun attachment durable state sekarang **bukan lagi diasumsikan hanya berada di metadata**; resource attachment memiliki backend schema/storage/RPC sendiri sesuai approved attachment contract.

---

## 5. Message ID Reconciliation

### Contract / Backend

Mutation individual Message menggunakan:

```text
p_message_id uuid
```

Current RPC:

```text
runtime_update_conversation_message_v2(p_message_id uuid, ...)
runtime_delete_conversation_message_v2(p_message_id uuid)
```

### Service / Caller

`ConversationService.updateMessage()` dan `deleteMessage()` meneruskan Message ID sebagai `p_message_id`. `ConversationView` memetakan backend `messageId` menjadi `ConversationMessage.runtimeRecordId`, lalu caller mutation menggunakan value tersebut.

### Bridge

`ConversationRuntimeBridge.updateMessage()` dan `deleteMessage()` sekarang memakai nama parameter `messageId`, selaras dengan value yang memang diteruskan sebagai Message ID. Named call sites di `ConversationView` juga sudah menggunakan `messageId`.

### Classification

**PASS / ADAPTER CONTRACT ALIGNED**

Semantics caller dan backend tetap tidak berubah. Perubahan hanya memperjelas naming pada FE adapter boundary agar Conversation ID tidak tertukar dengan Message ID.

Fix yang diterapkan:

```text
Bridge updateMessage(messageId: ...)
Bridge deleteMessage(messageId: ...)
        ↓
Service p_message_id
        ↓
Backend Message ID
```

Tidak ada migration requirement dan tidak ada perubahan backend/schema.

---

## 6. Attachment / Multimodal Reconciliation — CHECKPOINT UPDATE

### Approved authority

Attachment sudah memiliki approved contract dan frozen migration design. Contract menetapkan:

```text
Message
  ↓
attachments[]
  ↓
Attachment resource
  ↓
private durable Storage object
```

Attachment lifecycle dibedakan dari Message reference dan Storage object. `local_path` hanya optional local reference/cache. Conversation/attachment dikecualikan dari Clone/Inherit/Succession dan Conversation termasuk recovery scope sehingga attachment durable harus dapat direconstruct melalui recovery relationship.

### Current backend implementation

Migration durable attachment sudah applied di DEV sebagai:

```text
20260908113655_conversation_attachments
20260908120543_revoke_conversation_attachment_truncate
```

Current backend resource:

```text
public.conversation_attachments
public.conversation_attachment_recovery_refs
```

Attachment resource memiliki `attachment_id`, Account/SH identity, optional `message_id`, filename, MIME type, size, durable `storage_ref`, status (`PENDING` / `PERSISTED` / `FAILED`), timestamps, dan persisted timestamp.

Private Storage bucket:

```text
second-head-conversation
```

`storage_ref` dibuat server-side dari attachment identity. Authenticated direct table mutation tidak menjadi public write path; create/finalize/fail/load/detach melalui trusted RPC boundary.

Recovery backend sudah direkonsiliasi agar persisted attachment descriptors masuk snapshot/recovery refs dan restore memulihkan relationship hanya jika durable resource/object/message tersedia, sambil menghitung attachment gaps.

### Current FE implementation

Current path:

```text
Camera / Photos / File
        ↓
ConversationView
        ↓
local file save
        ↓
record Message
        ↓
create durable Attachment
        ↓
Storage upload
        ↓
finalize Attachment
        ↓
PERSISTED
```

`ConversationService.recordWithAttachments()` mengorkestrasi record Message lalu attachment creation/upload/finalize. `ConversationAttachmentService` menangani create, upload/finalize, load, download, dan detach.

`ConversationView` sekarang:

- menyimpan local file untuk cache/UI;
- membuat durable attachment melalui runtime bridge;
- mempertahankan attachment identity saat retry;
- meng-hydrate persisted attachments saat conversation reload;
- mendownload attachment jika local cache tidak tersedia;
- mempertahankan local failed attachment state untuk retry;
- menyimpan attachment descriptors pada local message serialization.

### Reconstruction path

```text
Backend Message load
        ↓
ConversationRecord
        ↓
backend persisted attachments
        ↓
ConversationView._messageFromBackend()
        ↓
reuse local cache OR download durable object
        ↓
ConversationMessage attachments
```

Dengan demikian GAP lama bahwa attachment hanya local dan hilang saat reload **sudah tertutup pada layer implementation**.

### Remaining verification

Yang belum boleh dianggap PASS hanya berdasarkan code/schema:

- authenticated upload → persisted;
- reload/reopen → attachment reconstructed;
- download dari private storage dengan identity yang benar;
- failed/ambiguous upload → retry memakai attachment identity yang sama;
- wrong Account/SH access denied;
- recovery snapshot → restore relationship/object dependency;
- cleanup/delete semantics;
- real APK E2E.

### Classification

**IMPLEMENTED / BACKEND + FE WIRED / SEMANTIC & E2E VERIFICATION OPEN**

Ini menggantikan classification lama **CONFIRMED FE ↔ BACKEND PERSISTENCE / RECONSTRUCTION GAP**.

---

## 7. Attachment Contract / Lifecycle Status

Open questions lama mengenai schema dasar attachment tidak lagi open: approved attachment contract dan migration design sudah menjadi authority.

Yang tetap harus diverifikasi:

```text
Attachment resource
├── identity
├── Account / SH isolation
├── Message relationship
├── durable storage object
├── local cache/reference
├── PENDING → PERSISTED / FAILED
├── retry
├── detach / deletion semantics
└── recovery reconstruction
```

**Status: CONTRACT PASS / IMPLEMENTATION PRESENT / SEMANTIC VERIFICATION OPEN.**

Tidak boleh mendesain schema attachment alternatif tanpa conflict evidence.

---

## 8. Message Model / Serialization

Current `ConversationRecord` membawa:

```text
messageId
threadId
role
content
createdAt
metadata
attachments
```

Current `ConversationMessage` membawa runtime record identity, local attachment representation, dan attachment descriptors, serta mempertahankan semantic Message projection berikut untuk local durable state:

```text
messageId
threadId
role
content
createdAt
metadata
attachments
```

Reconciliation target:

```text
ConversationMessage
   ↕
toJson / fromJson
   ↕
local durable semantic projection
   ↕
ConversationRecord
   ↕
backend Message + attachment resources
```

Keputusan Owner/User yang sudah ada dan sudah didokumentasikan pada serialization audit adalah:

> **Local Conversation state menggunakan full durable Message projection.**

Artinya local state bukan sekadar UI/cache projection yang boleh kehilangan semantic Message fields. Keputusan ini tidak mengubah backend Message contract atau menjadikan local sebagai backend source of truth.

Boundary synchronization tetap terpisah:

```text
BACKEND = authoritative persistence
LOCAL   = durable semantic projection
LOCAL ↔ BACKEND = synchronization/reconciliation workstream terpisah
```

### Verification yang masih open

Yang belum boleh dianggap PASS hanya berdasarkan code/schema:

- metadata/role/threadId/messageId/createdAt/content round-trip;
- legacy local JSON fallback compatibility;
- attachment descriptor round-trip bersama Message semantic fields;
- local fallback reconstruction ketika backend unavailable.

Verification harus membuktikan:

```text
serialize → persist → read → deserialize
```

tetap mempertahankan semantic fields yang ditetapkan di atas.

**Status: DECISION RESOLVED / IMPLEMENTATION ALIGNED / SEMANTIC ROUND-TRIP VERIFICATION OPEN.**

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

Current backend/FE capability tersedia untuk create/list/select-related state, rename, move/remove project, load, record, update/delete message, dan delete thread.

Belum final diverifikasi:

- delete active/non-active conversation;
- project deletion dengan child conversation;
- active conversation consistency;
- reload setelah mutation;
- empty conversation;
- backend failure versus local fallback;
- attachment behavior sepanjang lifecycle.

**Status: IMPLEMENTATION PRESENT / SEMANTIC VERIFICATION OPEN.**

---

## 10. Clear vs Delete

Contract distinction:

```text
Clear
→ membersihkan message/content sesuai semantics yang ditetapkan
→ Conversation tetap ada

Delete Conversation
→ menghapus Conversation thread
→ child Messages mengikuti lifecycle deletion
```

Current FE clear implementation masih melakukan delete individual messages berdasarkan `runtimeRecordId`. Ini belum boleh dianggap sebagai final Clear implementation sebelum semantics dan persistence behavior direkonsiliasi.

Attachment relationship juga harus diverifikasi terhadap Clear versus Delete; jangan menganggap Clear = resource deletion.

**Status: OPEN / DO NOT MARK PASS.**

---

## 11. Local Persistence / Backend Persistence

Current architecture memiliki local conversation state dan backend persistence.

Local state mengikuti keputusan serialization sebagai **durable semantic Message projection**, bukan sekadar UI/cache projection. Namun backend tetap menjadi authoritative persistence.

Fallback:

```text
Backend load succeeds → backend records become current FE state
Backend load fails    → local conversation state fallback
```

Ini bukan full offline synchronization architecture.

Open:

- local-newer-than-backend;
- backend-newer-than-local;
- retry/queue;
- duplicate prevention;
- conflict resolution;
- attachment synchronization;
- deletion synchronization.

**Status: OPEN.**

---

## 12. Ordering / Race / State Consistency

Belum final diverifikasi:

```text
send A / send B
edit / delete / reload
switch conversation during in-flight request
create → select → load
attachment upload → retry → reload
```

Backend conversation load memiliki deterministic ordering `created_at ASC, message_id ASC`.

**Status: AUDIT OPEN.**

---

## 13. Conversation Context

Current backend capability:

```text
runtime_load_conversation_context_for_thread
```

`ConversationService.loadContext()` sudah memanggil capability tersebut.

Belum terbukti capability ini sudah menjadi input aktif untuk AI/runtime response.

Target:

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

Current FE masih menggunakan static assistant response setelah user message.

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

Dynamic AI/model integration belum selesai dan tetap separate dari basic Conversation persistence.

Actor Resolution yang sudah selesai harus menjadi identity/actor boundary untuk runtime berikutnya; Model tidak boleh menjadi sumber SH identity/authority.

**Status: OPEN.**

---

## 15. Security / Isolation

Minimum semantic harness:

```text
Account A → own Conversation → ALLOW
Account A → Account B Conversation → DENY
Account A → Account B Message → DENY
spoofed identity → DENY
unauthenticated → DENY
```

Attachment menambah:

```text
Account A → own persisted attachment → ALLOW
Account A → Account B attachment/storage object → DENY
unauthenticated → DENY
```

Backend message and attachment access uses trusted identity / Account + SH ownership boundaries. Full semantic harness remains open.

**Status: BASELINE PRESENT / FULL SEMANTIC HARNESS OPEN.**

---

## 16. Recovery Implications

Recovery backend sekarang memiliki explicit attachment relationship support:

```text
Recovery Snapshot
   ├── Conversation state
   ├── persisted attachment descriptors
   └── conversation_attachment_recovery_refs
```

Restore hanya boleh mereconnect relationship jika durable attachment resource, storage object, dan target Message dependency tersedia sesuai implementation boundary. Missing attachment dependencies harus tetap terdeteksi sebagai recovery gap, bukan dianggap silently restored.

Yang masih harus diverifikasi secara authenticated/E2E:

- snapshot dengan persisted attachment;
- restore;
- attachment object availability;
- relationship reconstruction;
- missing-object behavior;
- snapshot deletion / reference cleanup.

**Status: BACKEND IMPLEMENTATION PRESENT / RECOVERY SEMANTIC + E2E OPEN.**

---

## 17. Search Boundary

Current Project/Conversation management search adalah local filtering terhadap loaded summaries.

Belum ada evidence bahwa architecture memiliki backend Message Search capability terpisah.

```text
Project/Conversation local filtering
≠ Message search
≠ Semantic search
```

**Status: CURRENT LOCAL FILTER / BROADER SEARCH OPEN.**

---

## 18. Error Semantics

Current FE masih memiliki broad catch/fallback behavior.

Audit lanjutan harus membedakan secara internal:

```text
Unauthenticated
Authorization denied
Network unavailable
Backend contract/runtime error
Invalid message
Attachment error
Unknown error
```

Tujuan: UI tidak menghasilkan false success dan runtime tidak kehilangan semantic distinction.

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

**Status: CURRENT ROLE SET / SEMANTIC AUDIT OPEN.**

---

## 21. Confirmed Gaps / Resolved Gaps

### GAP-C01 — Bridge Message ID Naming

```text
Status: RESOLVED
Layer: FE adapter
Severity: maintainability / contract clarity
```

Caller sudah membawa Message ID melalui `runtimeRecordId`. Bridge parameter update/delete sekarang juga dinamai `messageId`, dan seluruh named call sites di `ConversationView` sudah aligned.

Perbaikan ini hanya menyelaraskan adapter naming dengan existing Message ID contract. Tidak ada migration requirement dan tidak ada perubahan backend/schema.

### GAP-C02 — Attachment Backend Persistence / Reconstruction

```text
Status: RESOLVED AT IMPLEMENTATION LAYER
Layer: FE ↔ backend Conversation attachment representation
```

Resolved by:

- approved durable attachment contract;
- applied backend migration + private storage bucket;
- trusted attachment RPC boundary;
- recovery relationship support;
- `ConversationAttachmentService`;
- `ConversationService.recordWithAttachments()`;
- runtime bridge attachment methods;
- ConversationView persistence, hydration, download, and retry wiring.

Remaining work is verification, not schema invention:

```text
BE READY
   ↓
FE minimal wiring
   ↓
Clone impact check
   ↓
Security semantic harness
   ↓
Authenticated attachment E2E
   ↓
Recovery E2E
```

### GAP-C03 — Message Serialization Semantic Model

```text
Status: RESOLVED — DECISION + IMPLEMENTATION ALIGNED
Layer: Conversation local state / Message serialization
```

Owner/User decision menetapkan **full durable Message projection** untuk local Conversation state.

Minimum semantic projection:

```text
messageId
threadId
role
content
createdAt
metadata
attachments
```

Current serialization implementation sudah mempertahankan field tersebut pada `ConversationMessage` dan `toJson/fromJson` path, dengan presentation/local-only fields tetap dibedakan dari semantic fields.

Remaining work adalah verification:

```text
semantic round-trip
legacy local JSON compatibility
attachment descriptor round-trip
local fallback reconstruction
```

Keputusan ini tidak mengubah backend authority dan tidak menutup workstream Local ↔ Backend synchronization.

### Migration gap

**NO CURRENT ATTACHMENT MIGRATION GAP.** DEV schema dan migration source telah direkonsiliasi untuk durable attachment implementation. Migration history sekarang mencakup dua attachment-related migrations di atas.

---

## 22. Execution / Verification Queue

Conversation child follows the parent execution gates. Analysis can be parallel; implementation is not considered ready merely because FE code exists.

Current sequence:

```text
1. Reconcile current backend attachment implementation
        ↓ PASS
2. Backend security / contract verification
        ↓ REQUIRED FOR BE READY
3. FE minimal user-visible attachment wiring
        ↓ PRESENT
4. FE verification
        ↓ REQUIRED
5. Clone impact / dependency check
        ↓ REQUIRED before E2E if capability affects Clone
6. Security semantic harness
        ↓ REQUIRED
7. Authenticated attachment E2E
        ↓ REQUIRED
8. Recovery E2E
        ↓ REQUIRED
9. Final Conversation domain consolidation
```

Message ID bridge naming reconciliation is no longer in the execution queue; it is resolved.

Message Serialization decision and implementation reconciliation are also no longer an unresolved decision queue item. Verification remains open and must prove the full durable projection through round-trip and fallback tests.

Other open audit queue remains:

```text
Message serialization semantic verification
Clear/Delete semantics
Project ↔ Conversation lifecycle
Context runtime usage
AI runtime boundary
Local ↔ backend synchronization
Ordering / race / state consistency
Error semantics
Security semantic harness
Recovery semantics
Title lifecycle
Role semantics
```

No broad UI refactor and no final E2E completion claim before the relevant gates pass.

---

## 23. BE READY / FE READY / E2E Gate

### BE READY

BE is not marked READY solely because migration exists. Required:

```text
Contract/design alignment             PASS
DEV schema/functions/storage          PASS
Privileges / isolation                PASS
Attachment lifecycle semantics        PASS
Recovery dependency mapping           PASS
Authenticated semantic verification  PENDING
```

Therefore current attachment backend is **IMPLEMENTED / VERIFICATION IN PROGRESS**, not final E2E PASS.

### FE minimal wiring

Current minimal wiring is **PRESENT**:

```text
picker
 ↓
local cache
 ↓
message + durable attachment
 ↓
upload/finalize
 ↓
reload hydration
 ↓
download fallback
 ↓
retry failed attachment
```

FE still requires verification against actual backend behavior and error paths.

### Clone gate

Conversation/attachment contract excludes conversation/attachments from Clone/Inherit/Succession. Therefore the capability has a known Clone boundary and must be reconciled before final E2E:

```text
Conversation attachment
        ↓
Clone impact
        ↓
excluded from clone payload
        ↓
verify no ownership/lineage transfer
```

No new Clone implementation is implied by this checkpoint; this is a dependency verification gate.

### E2E gate

Final Conversation E2E cannot be marked PASS until:

```text
BE READY
  +
FE READY
  +
Clone dependency check
  +
Security harness
  +
Authenticated attachment flow
  +
Recovery flow
```

---

## 24. Parent Living Inventory Relationship

Parent:

`docs/working/sh_core_inventory_reconciliation.md`

Parent tetap menjadi sumber status lintas domain.

Child ini menjadi detail Conversation reconciliation. Parent cukup memuat summary/status/pointer dan tidak perlu menyalin seluruh detail teknis.

Checkpoint ini harus dibaca bersama parent execution gate terbaru.

---

## 25. Current Checkpoint

```text
Conversation Contract                  PASS
Attachment Contract                   PASS / LOCKED
Backend Message RPC                   PASS
ConversationService                   PASS
Caller Message ID                     PASS
Bridge Message ID naming              RESOLVED
Attachment backend schema             IMPLEMENTED
Attachment private storage            IMPLEMENTED
Attachment RPC boundary               IMPLEMENTED
Attachment FE wiring                  IMPLEMENTED
Attachment reload reconstruction     IMPLEMENTED / VERIFY E2E
Attachment retry identity             IMPLEMENTED / VERIFY E2E
Message serialization decision        RESOLVED
Message serialization implementation  ALIGNED
Message serialization verification    OPEN
Clear semantics                       OPEN
Lifecycle semantics                   OPEN
Context runtime usage                 OPEN
AI runtime                            OPEN
Offline/conflict sync                 OPEN
Security semantic harness             OPEN
Recovery backend implementation       PRESENT / E2E OPEN
Recovery attachment semantics         OPEN
Clone dependency check                REQUIRED BEFORE E2E
```

**Overall Conversation status: AUDIT IN PROGRESS / ATTACHMENT IMPLEMENTATION RECONCILED / MESSAGE SERIALIZATION DECISION + IMPLEMENTATION ALIGNED / NOT FINAL E2E READY.**

The old attachment persistence/reconstruction gap is no longer the current implementation state. The Message ID bridge naming gap is resolved. Message Serialization is no longer an open semantic-model decision: the Owner/User decision is full durable Message projection and the current implementation is aligned. Remaining work is verification through the defined semantic round-trip/fallback checks plus the broader Conversation BE → FE → Clone dependency → Security → E2E → Recovery gates.
