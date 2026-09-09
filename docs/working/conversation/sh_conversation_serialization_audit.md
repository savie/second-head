# SECOND HEAD — Conversation Serialization Audit

## Status

**IMPLEMENTATION ALIGNED / SEMANTIC E2E STILL OPEN / RECOVERY E2E BLOCKED BY TEST FIXTURE**

Dokumen ini adalah child working audit untuk `ConversationMessage` ↔ `ConversationRecord` ↔ local conversation state.

Bukan Canonical dan bukan Approved Contract.

---

## 1. Audit Scope

Flow yang diverifikasi pada current `dev`:

```text
backend Message
   ↓
ConversationRecord.fromMap()
   ↓
ConversationView._messageFromBackend()
   ↓
conversationMessage
   ↓
conversationMessage.toJson()
   ↓
StorageService.saveConversationState()
   ↓
StorageService.readConversationState()
   ↓
conversationMessage.fromJson()
```

Attachment flow juga diverifikasi:

```text
ConversationRecord.attachments
   ↓
conversationMessage.attachments
   ↓
conversationAttachment.toJson()
   ↓
conversationAttachment.fromMap()
```

---

## 2. Findings

### 2.1 Message identity — PASS

`ConversationRecord.messageId` dipetakan ke `ConversationMessage.runtimeRecordId` dan diserialisasi kembali. Local hydration menggunakan `runtimeRecordId` sebagai key cache sehingga identity Message tetap menjadi anchor reconstruction.

### 2.2 Content — PASS

`ConversationRecord.content` dipetakan ke `ConversationMessage.text` dan diserialisasi sebagai `text`. Tidak ditemukan transformasi yang mengubah content pada serialization boundary.

### 2.3 Timestamp — PASS WITH PRESENTATION DERIVATION

Authoritative `createdAt` disimpan sebagai ISO-8601 melalui `createdAt`. Field `time` adalah display projection (`HH:mm`) dan bukan authoritative timestamp.

### 2.4 Attachment descriptors — PASS

`ConversationAttachment.toJson()` menyimpan descriptor backend yang diperlukan, termasuk:

```text
attachment_id
account_id
sh_id
message_id
filename
mime_type
size_bytes
storage_ref
status
created_at
updated_at
persisted_at
local_path
```

`fromMap()` membaca kembali descriptor tersebut. `local_path` diperlakukan sebagai local-only reference dan backend durable attachment tetap authoritative saat reconstruction.

### 2.5 Attachment ordering / duplicate hydration — PASS AT CODE LEVEL

Backend attachments di-load per Message. Hydration mencocokkan cached attachment berdasarkan `attachmentId`. Failed cached attachments hanya ditambahkan bila ID tersebut belum ada pada backend result. Tidak ditemukan duplicate append untuk ID yang sama pada path tersebut.

Backend Message load juga menggunakan deterministic ordering `created_at ASC, message_id ASC`.

### 2.6 Failed attachment persistence — PASS AT CODE LEVEL

Failed attachment descriptor dapat tetap berada di local state dan dipertahankan saat backend reload bila belum ada sebagai persisted backend attachment. Retry memakai attachment identity yang sama.

### 2.7 Metadata — RESOLVED

`ConversationRecord.metadata` sekarang diproyeksikan ke `ConversationMessage.metadata` dan disimpan pada local JSON.

```text
backend metadata
   ↓
ConversationRecord.metadata
   ↓
ConversationMessage.metadata
   ↓
local JSON
   ↓
ConversationMessage.fromJson()
```

Metadata tidak lagi hilang pada local fallback.

### 2.8 Role — RESOLVED FOR LOCAL FIDELITY

Backend role contract menerima:

```text
user
assistant
system
```

`ConversationMessage` sekarang mempertahankan exact `role` selain boolean `assistant` untuk compatibility UI.

`_messageFromBackend()` membawa `record.role` secara langsung. `fromJson()` juga memulihkan role. Untuk legacy local records yang belum memiliki field `role`, constructor melakukan fallback berdasarkan `assistant` (`assistant` → `assistant`, selain itu → `user`).

Dengan demikian role `system` tidak lagi dipaksa menjadi non-assistant pada local serialization apabila role tersebut masuk melalui backend projection.

### 2.9 Thread ID — RESOLVED FOR RECOVERY-ALIGNED LOCAL FIDELITY

`ConversationRecord.threadId` sekarang dipertahankan pada `ConversationMessage.threadId` dan diserialisasi ke local JSON.

Ini menghilangkan kehilangan hierarchy reference pada local snapshot dan menyelaraskan projection lokal dengan recovery model yang mempertahankan Conversation/Thread relationship.

---

## 3. Storage Semantics

`StorageService.saveConversationState()` menyimpan satu JSON document berisi title, messages, dan `savedAt`, menggunakan `writeAsString(..., flush: true)`.

`readConversationState()` melakukan JSON decode dan mengembalikan null bila file tidak ada atau decode gagal.

Ini memberikan durable local snapshot behavior, tetapi bukan transactional local/backend synchronization. Crash-consistency dan conflict resolution tetap berada di queue audit Local ↔ Backend Persistence.

---

## 4. Decision Boundary — RESOLVED

Decision yang digunakan untuk implementation ini:

```text
A. full durable Message projection
```

Local `ConversationMessage` diperlakukan sebagai recovery-aligned durable projection, bukan sekadar UI/cache projection yang boleh kehilangan semantic Message fields.

Minimum semantic fields yang dipertahankan lokal:

```text
metadata
role
threadId
messageId
createdAt
content
attachments
```

Field berikut tetap bersifat presentation/local:

```text
time           = display projection
attachmentPath = local filesystem reference
assistant      = UI compatibility projection derived from role at backend hydration
```

Decision ini tidak mengubah backend Message contract atau Recovery contract.

---

## 5. Implementation Result

Implementation change dieksekusi pada current `dev`.

Perubahan minimal:

- `ConversationMessage` menambahkan `role`, `threadId`, dan `metadata`.
- `ConversationMessage.toJson()/fromJson()` mempertahankan ketiga field tersebut.
- `_messageFromBackend()` membawa exact role, thread ID, dan metadata dari `ConversationRecord`.
- attachment message construction juga mempertahankan semantic fields dari backend record.
- constructor legacy tetap backward-compatible dengan fallback role berdasarkan `assistant`.
- tidak ada backend/schema/migration change.

Commit:

```text
4dafcf7109c85f33a7e039202f433aabd4802365
fix(conversation): preserve message semantics in local serialization
```

Verification:

- GitHub commit diff diperiksa.
- Diff hanya menyentuh `app/lib/features/conversation/conversation_view.dart`.
- Tidak ada full-file reconstruction dari truncated output.
- Tidak ada perubahan Canonical atau Approved Contract.

---

## 6. Recovery Semantic Verification

### 6.1 Source / live verification — COMPLETE

Recovery implementation pada current `dev` dan live DEV diverifikasi.

Snapshot backend mencakup `conversation_threads`, `conversations`, dan persisted `conversation_attachments`. Restore memvalidasi identity, ownership, State version, Message/Thread dependencies, attachment resource, Storage object, dan attachment relationship. Recovery juga menghitung missing dependencies dan menghasilkan `GAP_UNRESOLVED` bila dependency tetap hilang.

Attachment recovery refs juga tersedia untuk mempertahankan relationship snapshot → attachment.

### 6.2 Runtime E2E test — BLOCKED BY TEST FIXTURE

Live DEV saat audit memiliki:

```text
recovery_snapshots                         0
recovery_events                            0
conversation_attachments                   0
conversation_attachment_recovery_refs      0
```

Karena tidak ada fixture Conversation/Attachment/Snapshot yang dapat dipakai, authenticated snapshot → restore belum dapat dijalankan tanpa membuat test data baru.

Tidak ada destructive test atau synthetic production-like data yang dibuat selama audit ini.

### 6.3 Required semantic test matrix

Test berikut tetap required sebelum Recovery Conversation dinaikkan menjadi PASS:

```text
T1  create FULL recovery snapshot with Message + Thread
T2  restore intact snapshot → RECOVERED
T3  restore same snapshot twice → idempotent existing recovery event
T4  remove/missing Message dependency → GAP_UNRESOLVED
T5  missing persisted attachment resource → GAP_UNRESOLVED
T6  missing Storage object → GAP_UNRESOLVED
T7  attachment resource + Message + Storage object present → relationship restored
T8  attachment relationship conflict → gap detected, no false recovery
T9  unauthorized / wrong-account snapshot → RECOVERY_REJECTED
```

Test harus menggunakan authenticated identity dan fixture yang isolated/controlled; test tidak boleh mengubah atau menghapus production user data.

### 6.4 Verification classification

```text
Recovery implementation              VERIFIED
Recovery source contract              VERIFIED
Live DEV function presence             VERIFIED
Live DEV fixture availability          BLOCKED — no fixtures
Authenticated E2E                      OPEN
Destructive dependency-loss tests      OPEN
```

---

## 7. Remaining Verification

Serialization model decision dan implementation sudah resolved. Yang masih terbuka adalah verification, bukan model-contract decision.

Required next verification:

```text
1. round-trip test metadata/role/threadId/messageId/createdAt
2. legacy local JSON fallback compatibility
3. attachment round-trip bersama semantic fields
4. local fallback reconstruction with backend unavailable
5. recovery authenticated E2E menggunakan isolated fixture
```

Tidak boleh menganggap Recovery E2E PASS sebelum fixture tersedia dan matrix dijalankan.

---

## 8. Classification

```text
Message ID                  PASS
Content                     PASS
CreatedAt                   PASS
Attachment descriptor       PASS
Attachment duplicate guard  PASS at code level
Failed attachment retry    PASS at code level
Metadata                    RESOLVED
Role fidelity               RESOLVED
Thread ID                   RESOLVED
Storage snapshot            PRESENT
Local/backend sync          OPEN
Serialization E2E           OPEN
Recovery implementation     VERIFIED
Recovery E2E                BLOCKED BY TEST FIXTURE
```

**Overall: LOCAL SERIALIZATION ALIGNED WITH RECOVERY-STYLE FULL MESSAGE PROJECTION / SERIALIZATION E2E OPEN / RECOVERY E2E BLOCKED BY TEST FIXTURE.**
