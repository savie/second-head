# SECOND HEAD — Conversation Serialization Audit

## Status

**DECISION RESOLVED / IMPLEMENTATION ALIGNED / SEMANTIC ROUND-TRIP VERIFICATION OPEN / RECOVERY E2E BLOCKED BY TEST FIXTURE**

Dokumen ini adalah child working audit untuk `ConversationMessage` ↔ `ConversationRecord` ↔ local conversation state.

Dokumen ini **bukan Canonical** dan **bukan Approved Contract**. Dokumen ini merekam keputusan yang sudah dibuat, reconciliation implementation, serta verification yang masih tersisa.

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

## 1. Decision — Local Message Projection

### 1.1 User decision

Keputusan yang sudah dibuat untuk Message Serialization adalah:

> **Local Conversation state menggunakan full durable Message projection.**

Artinya local state tidak diperlakukan hanya sebagai UI/cache projection yang boleh kehilangan semantic Message fields.

Local snapshot harus mempertahankan informasi yang diperlukan untuk merekonstruksi Message secara bermakna, minimal:

```text
messageId
threadId
role
content
createdAt
metadata
attachments
```

Keputusan ini **sudah disepakati sebelumnya oleh Owner/User** dan sekarang dirapikan secara eksplisit di working documentation. Ini bukan keputusan baru yang dibuat oleh audit ini.

### 1.2 Boundary keputusan

Keputusan ini **tidak berarti**:

```text
local = source of truth
local = backend replacement
local dapat override backend secara otomatis
local/backend conflict resolution sudah diputuskan
full offline sync sudah tersedia
```

Boundary yang benar:

```text
BACKEND
  = authoritative persistence

LOCAL
  = durable semantic projection

LOCAL ↔ BACKEND
  = synchronization/reconciliation concern terpisah
```

Strategi local-newer/backend-newer, queue/retry, conflict resolution, dan deletion synchronization **tetap berada pada workstream Local ↔ Backend Persistence dan belum diputuskan/ditutup oleh keputusan serialization ini**.

### 1.3 Rationale

Full durable Message projection dipilih karena Message dalam SH bukan sekadar teks yang ditampilkan UI. Identity, hierarchy, role, timestamp, metadata, dan attachment relationship dapat dibutuhkan untuk reconstruction, fallback, dan recovery.

Pendekatan ini mengurangi risiko semantic information loss ketika backend sementara tidak tersedia atau ketika local state digunakan untuk reconstruction.

Trade-off yang diterima:

- local snapshot lebih kaya dan lebih kompleks;
- backward compatibility local JSON perlu dijaga;
- durable/local-only fields harus dibedakan dengan jelas;
- synchronization dan conflict semantics menjadi concern lanjutan yang harus direkonsiliasi secara eksplisit.

Keputusan ini tidak mengubah backend Message contract atau Recovery contract.

---

## 2. Audit Scope

Flow yang direkonsiliasi pada current `dev`:

```text
backend Message
   ↓
ConversationRecord.fromMap()
   ↓
ConversationView._messageFromBackend()
   ↓
ConversationMessage
   ↓
conversationMessage.toJson()
   ↓
StorageService.saveConversationState()
   ↓
StorageService.readConversationState()
   ↓
conversationMessage.fromJson()
```

Attachment flow:

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

## 3. Findings

### 3.1 Message identity — PASS

`ConversationRecord.messageId` dipetakan ke `ConversationMessage.runtimeRecordId` dan dipertahankan pada local serialization. Local hydration menggunakan identity tersebut sebagai anchor reconstruction.

### 3.2 Content — PASS

`ConversationRecord.content` dipetakan ke `ConversationMessage.text` dan diserialisasi sebagai `text` tanpa transformasi semantic pada serialization boundary.

### 3.3 Timestamp — PASS WITH PRESENTATION DERIVATION

Authoritative `createdAt` dipertahankan sebagai ISO-8601 melalui `createdAt`. Field `time` adalah display projection (`HH:mm`) dan bukan authoritative timestamp.

### 3.4 Attachment descriptors — PASS

Attachment descriptor mempertahankan field backend yang diperlukan, termasuk:

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

`local_path` tetap local-only reference. Durable attachment resource/storage tetap authoritative untuk reconstruction.

### 3.5 Attachment ordering / duplicate hydration — PASS AT CODE LEVEL

Backend attachments di-load per Message. Hydration mencocokkan cached attachment berdasarkan `attachmentId`; failed cached attachments hanya dipertahankan bila ID tersebut belum hadir pada backend result. Tidak ditemukan duplicate append untuk ID yang sama pada path tersebut.

Backend Message load menggunakan deterministic ordering `created_at ASC, message_id ASC`.

### 3.6 Failed attachment persistence — PASS AT CODE LEVEL

Failed attachment descriptor dapat tetap berada di local state ketika belum menjadi persisted backend attachment. Retry mempertahankan attachment identity yang sama.

### 3.7 Metadata — RESOLVED

`ConversationRecord.metadata` diproyeksikan ke `ConversationMessage.metadata` dan disimpan pada local JSON.

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

Dengan demikian metadata tidak lagi hilang pada local fallback.

### 3.8 Role — RESOLVED FOR LOCAL FIDELITY

Backend role set saat ini:

```text
user
assistant
system
```

`ConversationMessage` mempertahankan exact `role` selain boolean `assistant` sebagai compatibility/UI projection.

`_messageFromBackend()` membawa `record.role` secara langsung. `fromJson()` memulihkan role. Legacy local records yang belum memiliki `role` menggunakan fallback berdasarkan `assistant` (`assistant` → `assistant`, selain itu → `user`).

Role `system` yang datang dari backend projection tidak lagi hilang hanya karena compatibility boolean `assistant`.

### 3.9 Thread ID — RESOLVED FOR RECOVERY-ALIGNED LOCAL FIDELITY

`ConversationRecord.threadId` dipertahankan pada `ConversationMessage.threadId` dan local JSON sehingga hierarchy reference tidak hilang pada local snapshot.

---

## 4. Storage Semantics

`StorageService.saveConversationState()` menyimpan local snapshot yang berisi title, messages, dan `savedAt`, menggunakan durable local file write.

`readConversationState()` melakukan JSON decode dan mengembalikan null bila file tidak ada atau decode gagal.

Ini memberikan durable local snapshot behavior, tetapi **bukan** transactional local/backend synchronization. Crash consistency, retry/queue, conflict resolution, dan synchronization tetap merupakan workstream terpisah.

---

## 5. Semantic Field Boundary

Field yang diperlakukan sebagai semantic/durable Message projection:

```text
messageId
threadId
role
content
createdAt
metadata
attachments
```

Field yang tetap merupakan presentation/local concern:

```text
time           = display projection
attachmentPath = local filesystem/cache reference
assistant      = compatibility/UI projection derived from role
```

Khusus attachment:

```text
local JSON
  = attachment descriptor/reference

private durable Storage
  = attachment object

backend attachment resource
  = durable attachment identity/state
```

Serialization tidak memasukkan binary attachment object ke dalam Message JSON.

---

## 6. Verification Boundary

Decision dan implementation serialization sudah resolved/aligned. Yang masih terbuka adalah pembuktian runtime/round-trip.

Required verification:

```text
1. round-trip metadata/role/threadId/messageId/createdAt/content
2. legacy local JSON fallback compatibility
3. attachment descriptor round-trip bersama Message semantic fields
4. local fallback reconstruction ketika backend unavailable
```

Verification ini harus membuktikan bahwa local projection setelah:

```text
serialize → persist → read → deserialize
```

tetap mempertahankan semantic fields yang ditetapkan di Section 1.

**Tidak boleh mengubah decision Opsi B hanya karena verification belum dijalankan.** Verification menentukan apakah implementation memenuhi decision tersebut, bukan membuka kembali keputusan yang sudah dibuat.

---

## 7. Recovery Relation

Recovery implementation pada current `dev` dan live DEV sudah diverifikasi pada source/runtime level.

Snapshot backend mencakup Conversation/Thread/Message dan persisted attachment relationship. Restore memvalidasi identity, ownership, State version, Message/Thread dependencies, attachment resource, Storage object, dan relationship. Missing dependencies menghasilkan recovery gap dan tidak dianggap silently restored.

### Recovery E2E

Authenticated snapshot → restore belum dijalankan karena audit sebelumnya menemukan tidak tersedia fixture Conversation/Attachment/Snapshot yang terisolasi.

Required recovery verification tetap berada di gate Recovery, bukan menjadi alasan untuk mengubah Message Serialization decision.

---

## 8. Classification

```text
Message identity             PASS
Content                      PASS
CreatedAt                    PASS
Attachment descriptor        PASS
Attachment duplicate guard   PASS at code level
Failed attachment retry      PASS at code level
Metadata                     RESOLVED
Role fidelity                RESOLVED
Thread ID                    RESOLVED
Local projection decision    RESOLVED — FULL DURABLE MESSAGE PROJECTION
Storage snapshot             PRESENT
Semantic round-trip          VERIFICATION OPEN
Local/backend synchronization OPEN — SEPARATE WORKSTREAM
Recovery implementation      VERIFIED
Recovery E2E                  BLOCKED — TEST FIXTURE
```

**Overall:**

> **Message Serialization decision is RESOLVED as full durable Message projection. Current implementation is aligned. Remaining work is verification only; Local ↔ Backend synchronization and Recovery E2E remain separate gates.**

---

## 9. Change Control

Dokumen ini hanya merapikan dan mengangkat keputusan yang sudah dibuat sebelumnya ke working documentation.

Tidak ada perubahan pada:

- Canonical;
- Approved Contract;
- backend schema;
- migration;
- runtime semantics.
