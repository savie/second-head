# SECOND HEAD — Conversation Attachment Contract Reconciliation

## Status

**WORKING / DOMAIN RECONCILIATION — PROPOSED MINIMUM CONTRACT**

Dokumen ini adalah child working document dari:

`docs/working/conversation/sh_conversation_inventory_reconciliation.md`

Dokumen ini **bukan Canonical** dan **bukan Approved Contract**. Fungsinya merekonsiliasi model Message, attachment, local serialization, dan backend metadata sebelum implementation.

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

---

## 1. Owner Decision yang Sudah Locked

Attachment Conversation menggunakan **Hybrid model**:

```text
Local file
→ UX / preview / local cache

Backend-persisted attachment
→ durable source of truth
```

Konsekuensinya:

- local filesystem path bukan identity attachment;
- attachment yang berhasil dipersist backend harus dapat direconstruct tanpa bergantung pada local path lama;
- local copy boleh berubah lokasi atau hilang tanpa mengubah identity attachment backend;
- implementation tidak boleh menampilkan durable success bila backend persistence attachment belum berhasil.

Ini adalah **Owner Decision**, bukan Canonical change.

---

## 2. Current Message Model

### Backend

Current `public.conversations` menyimpan Message dengan:

```text
conversation_id
account_id
sh_id
role
content
created_at
metadata jsonb
thread_id
message_id
```

`metadata` sudah tersedia sebagai structured message-level storage dan `runtime_record_conversation_message` menerima metadata. `runtime_load_conversation_messages` mengembalikan metadata bersama Message.

### Frontend backend model

`ConversationRecord` saat ini membawa:

```text
messageId
threadId
role
content
createdAt
metadata
```

### Frontend local model

`ConversationMessage` saat ini membawa:

```text
text
assistant
 time
attachmentPath?
runtimeRecordId?
createdAt?
```

### Reconciliation

```text
Backend Message ID
        ↓
ConversationRecord.messageId
        ↓
ConversationMessage.runtimeRecordId
```

Message identity sudah dapat dipertahankan.

`runtimeRecordId` adalah Message ID walaupun adapter mutation saat ini masih memakai nama parameter `conversationId`. Itu tetap GAP-C01 terpisah.

---

## 3. Current Attachment Flow

Current FE:

```text
Camera / Photos / File
        ↓
Picker
        ↓
StorageService
        ↓
external local category directory
        ↓
local File path
        ↓
ConversationMessage.attachmentPath
        ↓
conversation_state.json
```

Image dan file disimpan melalui `StorageService.saveConversationImage()` / `saveConversationFile()`.

Current local categories:

```text
images
audio
video
documents
exports
```

Classification saat ini terutama berbasis extension.

Tidak ada attachment identity backend pada flow tersebut.

---

## 4. Local Serialization Reconciliation

`ConversationMessage.toJson()` saat ini menyimpan:

```text
text
assistant
time
attachmentPath
runtimeRecordId
createdAt
```

`fromJson()` dapat memulihkan `attachmentPath` dari local `conversation_state.json`.

Jadi local-only attachment persistence **bekerja secara struktural** selama file lokal masih ada.

Namun ini bukan durable attachment contract karena:

```text
attachmentPath
→ filesystem-specific reference
→ bukan portable identity
→ bukan backend source of truth
```

---

## 5. Backend ↔ FE Reconstruction Gap

Current backend load melakukan:

```text
RPC Message
 ↓
ConversationRecord
 ↓
_messageFromBackend()
 ↓
ConversationMessage
```

`_messageFromBackend()` saat ini memetakan Message ID, role, content, timestamp, tetapi tidak membawa attachment representation dari metadata ke `ConversationMessage`.

Akibatnya:

```text
Local attachment exists
        ↓
Backend Message load
        ↓
FE reconstructs Message
        ↓
No attachment representation
        ↓
Attachment preview disappears
```

**CONFIRMED GAP-C02:** backend persistence/reconstruction untuk attachment belum ada.

---

## 6. Metadata Reconciliation

Current concrete metadata usage yang telah teridentifikasi adalah:

```text
metadata['conversation_title']
```

Belum ada approved attachment schema di current contract/backend.

Karena `metadata` sudah menjadi part of Message contract, attachment descriptor **secara teknis dapat** ditempatkan di sana, tetapi itu adalah design decision yang harus dikunci sebelum implementation.

Tidak ditemukan evidence current DEV yang mengharuskan pembuatan table Message baru untuk attachment.

Tidak ditemukan evidence current DEV yang mengharuskan migration attachment khusus sebelum contract minimum ditetapkan.

---

## 7. Proposed Minimum Attachment Contract

**STATUS: PROPOSED — NEEDS OWNER LOCK**

Untuk menjaga scope tetap kecil, attachment minimum diusulkan sebagai typed descriptor yang direferensikan oleh Message:

```text
Message
 └── attachments[]
       └── Attachment Descriptor
             ├── attachment_id
             ├── filename
             ├── mime_type
             ├── size_bytes
             └── storage_ref
```

### Minimum semantics

1. `attachment_id`
   - stable identity attachment;
   - tidak boleh berasal dari local filesystem path.

2. `filename`
   - nama file untuk user-visible representation;
   - bukan identity.

3. `mime_type`
   - typed media/document representation;
   - renderer tidak hanya bergantung pada extension/path.

4. `size_bytes`
   - ukuran payload yang dipersist;
   - berguna untuk validation dan UI.

5. `storage_ref`
   - reference ke backend durable storage;
   - bukan raw local path.

6. `attachments[]`
   - Message harus mampu memiliki zero, one, atau multiple attachments secara extensible.
   - Current UI mungkin hanya membuat satu attachment per action, tetapi contract tidak perlu mengunci cardinality satu.

### Local representation

Local state dapat menyimpan tambahan:

```text
local_path
```

tetapi statusnya **cache/local reference**, bukan durable identity.

Local path tidak wajib menjadi bagian dari backend Message contract.

---

## 8. Proposed State Model

Attachment minimum sebaiknya dapat dibedakan secara internal:

```text
LOCAL_ONLY
     ↓ upload
PERSISTING
     ↓ success
PERSISTED
     ↓ local cache missing
REMOTE_RECONSTRUCTABLE
```

Jika persistence gagal:

```text
LOCAL_ONLY / PERSIST_FAILED
```

dan UI tidak boleh menyamakan kondisi tersebut dengan attachment durable.

Status taxonomy ini adalah **design proposal**, bukan Owner Decision.

---

## 9. Storage Boundary

Current DEV belum memiliki bucket attachment yang aktif pada checkpoint audit ini.

Karena itu implementation berikutnya harus menentukan storage mechanism melalui approved backend design, bukan mengasumsikan bucket/path tertentu.

Target boundary:

```text
Account / SH trusted identity
        ↓
Attachment authorization
        ↓
Backend storage
        ↓
Attachment descriptor
        ↓
Message reference
```

Attachment tidak boleh memperoleh akses hanya karena client mengetahui `storage_ref`.

---

## 10. Renderer Reconciliation

Current renderer:

```text
attachmentPath
   ↓
StorageService.categoryFor(File(path))
   ↓
extension/path classification
```

Target setelah contract:

```text
Attachment Descriptor
   ↓
MIME/type
   ↓
renderer
   ↓
local cached file OR backend retrieval
```

Extension tetap boleh menjadi fallback untuk local files, tetapi tidak boleh menjadi satu-satunya durable attachment semantics.

---

## 11. Lifecycle Implications

Attachment lifecycle harus mengikuti Message lifecycle tetapi tidak boleh diasumsikan identik tanpa verification.

Minimal yang perlu diputuskan pada implementation/verification:

```text
Message Create
→ attachment persist/reference

Message Delete
→ attachment reference removed
→ durable object deletion semantics harus ditentukan

Conversation Clear
→ attachment handling harus mengikuti final Clear semantics

Conversation Delete
→ attachment cleanup harus mengikuti final Conversation deletion semantics
```

Recovery, Clone, Inheritance, dan Succession tidak boleh dianggap otomatis solved oleh attachment persistence.

Masing-masing domain harus merekonsiliasi attachment sebagai dependency ketika domain tersebut dikerjakan.

---

## 12. Security Requirements

Attachment durable harus mengikuti identity boundary Message:

```text
Account A / SH A
   ↓
own Conversation
   ↓
own Message
   ↓
own Attachment
```

Minimum verification:

```text
A → A attachment      ALLOW
A → B attachment      DENY
spoofed storage ref    DENY
unauthenticated       DENY
```

Jangan menggunakan filename, local path, attachment_id dari client, atau UI state sebagai authorization source.

---

## 13. Recovery / Continuity Boundary

Current local recovery collector dapat mengumpulkan file lokal, tetapi itu belum sama dengan backend attachment recovery/reconstruction.

Dengan hybrid contract:

```text
Backend attachment
→ durable source of truth

Local attachment
→ cache / local representation
```

Recovery domain berikutnya wajib menentukan apakah recovery snapshot menyimpan:

- attachment descriptor;
- durable storage reference;
- object copy atau re-fetch reference;
- local cache bila tersedia.

Tidak boleh mengklaim recovery attachment selesai hanya karena local file masuk recovery payload.

---

## 14. Reconciliation Result

### LOCKED

- Hybrid attachment model.
- Local path bukan durable identity.
- Backend persistence menjadi source of truth untuk attachment yang berhasil dipersist.
- Message tetap menjadi parent semantic object.
- Existing Message storage tetap `public.conversations` pada current hierarchy.

### CONFIRMED GAP

- GAP-C02: backend attachment persistence + Message reconstruction.
- Renderer saat ini hanya memahami local path.

### NO GAP

- Existing Message `metadata jsonb` tersedia.
- Existing local `ConversationMessage` dapat serialize/deserialize local attachment path.
- Existing local category directories sudah tersedia.
- Tidak ada evidence yang mengharuskan table Message baru.

### OPEN / OWNER LOCK NEEDED

- Apakah descriptor attachment disimpan sebagai `metadata.attachments[]` atau melalui struktur backend lain.
- Storage backend mechanism dan bucket/object boundary.
- Exact upload/persistence transaction boundary.
- Exact attachment deletion semantics.
- Final status taxonomy.

---

## 15. Implementation Gate

**NO CODING YET** untuk attachment persistence.

Implementation baru boleh dimulai setelah minimum contract berikut dikunci:

```text
Message
  ↓
Attachment Descriptor
  ├── stable attachment_id
  ├── filename
  ├── mime_type
  ├── size_bytes
  └── storage_ref
```

dan dipastikan:

```text
Account/SH isolation
        ↓
backend storage authorization
        ↓
Message reference
        ↓
FE reconstruction
        ↓
local cache/rendering
```

Setelah itu urutan implementasi:

```text
Backend storage design
 ↓
Backend schema/RPC
 ↓
FE Attachment model
 ↓
Message serialization/reconstruction
 ↓
Local cache/filter reconciliation
 ↓
Security verification
 ↓
Conversation E2E
 ↓
APK build
```

---

## 16. Relation to Approved Contract

Belum ada perubahan terhadap:

`docs/contract/sh_project_conversation_message_contract.md`

Attachment minimum di dokumen ini masih **PROPOSED** dan harus dipromosikan ke approved contract hanya setelah Owner mengunci bentuknya.

Tidak ada perubahan Canonical.
