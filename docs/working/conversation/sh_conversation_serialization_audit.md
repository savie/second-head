# SECOND HEAD — Conversation Serialization Audit

## Status

**AUDIT COMPLETE / IMPLEMENTATION CHANGE BLOCKED BY MODEL-CONTRACT DECISION**

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
ConversationMessage
   ↓
ConversationMessage.toJson()
   ↓
StorageService.saveConversationState()
   ↓
StorageService.readConversationState()
   ↓
ConversationMessage.fromJson()
```

Attachment flow juga diverifikasi:

```text
ConversationRecord.attachments
   ↓
ConversationMessage.attachments
   ↓
ConversationAttachment.toJson()
   ↓
ConversationAttachment.fromMap()
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

### 2.7 Metadata — GAP CONFIRMED

`ConversationRecord` memiliki:

```text
metadata
```

Namun `ConversationMessage` tidak memiliki field `metadata`, dan `ConversationMessage.toJson()/fromJson()` tidak menyimpan atau memulihkan metadata.

Akibatnya:

```text
backend metadata
   ↓
ConversationRecord.metadata
   ↓
ConversationMessage
   X  metadata tidak dibawa
   ↓
local JSON
```

Pada successful backend reload, metadata dapat diperoleh lagi dari backend. Pada local fallback, metadata tidak tersedia.

Ini adalah **serialization loss pada local projection**, bukan backend persistence loss.

### 2.8 Role — GAP CONFIRMED FOR FULL ROLE FIDELITY

Backend role contract menerima:

```text
user
assistant
system
```

`ConversationMessage` hanya menyimpan boolean:

```text
assistant
```

`_messageFromBackend()` melakukan:

```text
record.role == 'assistant'
```

Akibatnya role `system` tidak dapat dibedakan dari non-assistant role pada local representation.

Ini adalah **role-fidelity loss pada local projection** bila system Message masuk ke Conversation UI/cache.

Belum ada evidence bahwa `system` Message memang masuk ke user-visible ConversationView. Karena itu belum boleh langsung mengubah model tanpa reconciliation terhadap role semantics.

### 2.9 Thread ID — NOT REQUIRED FOR CURRENT UI PROJECTION

`ConversationRecord.threadId` tidak disimpan pada `ConversationMessage` local cache. Current local cache diikat ke active conversation dan Message ID, sementara thread identity tetap tersedia pada backend record.

Tidak ada evidence bahwa local UI membutuhkan `threadId` sebagai independent mutable state. Tidak diklasifikasikan sebagai confirmed bug pada audit ini.

---

## 3. Storage Semantics

`StorageService.saveConversationState()` menyimpan satu JSON document berisi title, messages, dan `savedAt`, menggunakan `writeAsString(..., flush: true)`.

`readConversationState()` melakukan JSON decode dan mengembalikan null bila file tidak ada atau decode gagal.

Ini memberikan durable local snapshot behavior, tetapi bukan transactional local/backend synchronization. Crash-consistency dan conflict resolution tetap berada di queue audit Local ↔ Backend Persistence.

---

## 4. Decision Boundary

Temuan metadata dan full-role fidelity tidak boleh langsung diubah sebagai refactor arbitrer karena perlu dipastikan apakah `ConversationMessage` dimaksudkan sebagai:

```text
A. full durable Message projection
```

atau:

```text
B. UI/cache projection yang hanya menyimpan state yang dibutuhkan UI
```

Current implementation evidence lebih dekat ke **B**, karena backend `ConversationRecord` tetap menjadi source untuk successful reload dan local `ConversationMessage` memiliki display-derived `time` serta local-only `attachmentPath`.

Namun local fallback membuat B memiliki semantic consequence: data yang tidak diproyeksikan hilang saat backend unavailable.

---

## 5. Required Resolution

Sebelum implementation change, owner/contract decision perlu menetapkan salah satu:

### Option A — Preserve full Message semantics locally

Tambahkan representasi yang diperlukan untuk mempertahankan:

```text
metadata
role
messageId
createdAt
content
attachments
```

sehingga local snapshot dapat mereconstruct semantic Message secara penuh.

### Option B — Keep UI projection intentionally lossy

Tetapkan secara eksplisit bahwa local conversation state hanya merupakan UI/cache projection, bukan semantic Message snapshot. Dalam model ini metadata dan system-role loss pada local fallback diterima, sementara backend tetap authoritative.

**Current audit tidak memilih A atau B secara sepihak.**

---

## 6. Execution Result

Tidak ada source mutation dilakukan untuk metadata/role pada audit ini.

Alasan: metadata loss terkonfirmasi, tetapi perubahan model `ConversationMessage` dapat mengubah boundary antara durable Message model dan UI projection; role `system` juga belum terbukti sebagai user-visible state.

Yang sudah dieksekusi:

- current `dev` source audit;
- attachment serialization verification;
- metadata/role loss identification;
- explicit decision boundary documentation.

Tidak ada Canonical atau Approved Contract yang diubah.

---

## 7. Classification

```text
Message ID                  PASS
Content                     PASS
CreatedAt                   PASS
Attachment descriptor       PASS
Attachment duplicate guard  PASS at code level
Failed attachment retry    PASS at code level
Metadata                    GAP — local projection loss
Role fidelity               GAP — system role not preserved locally
Thread ID                   ACCEPTED omission for current projection
Storage snapshot            PRESENT
Local/backend sync          OPEN
E2E serialization           OPEN
```

**Overall: SERIALIZATION IMPLEMENTATION PARTIALLY ALIGNED / METADATA + ROLE FIDELITY DECISION BLOCKER / E2E OPEN.**
