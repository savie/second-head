# SECOND HEAD — Conversation Attachment Contract Reconciliation

## Status

**WORKING / DOMAIN RECONCILIATION — PROPOSED MINIMUM CONTRACT**

Dokumen ini adalah child working document dari:

`docs/working/conversation/sh_conversation_inventory_reconciliation.md`

Dokumen ini **bukan Canonical** dan **bukan Approved Contract**. Fungsinya merekonsiliasi model Message, attachment, local serialization, backend metadata, Recovery, deletion/retention, dan Clear semantics sebelum implementation.

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

### 13.1 Current Recovery snapshot

Current `runtime_create_recovery_snapshot(p_sh_id)` membentuk manifest yang mencakup:

```text
identity_root
ownership_root
state
projects
conversation_threads
memories
conversations
journey_events
knowledge (PRIVATE)
experiences
legacy_records
captured_at
```

Jadi **Conversation Message memang merupakan bagian dari Recovery snapshot**.

Namun snapshot saat ini menyimpan row Message, bukan attachment resource/storage object.

Tidak ditemukan field/struktur attachment identity atau storage reference pada manifest current.

### 13.2 Current Recovery restore

`runtime_restore_recovery_snapshot(p_snapshot_id)` memulihkan `conversation_threads` dan `conversations`, tetapi tidak melakukan operasi terhadap Storage dan tidak memiliki attachment reconstruction.

Dengan demikian:

```text
Recovery Message       CURRENT
Recovery Attachment    GAP
Storage reconstruction GAP
```

Tidak boleh mengklaim attachment recovery selesai hanya karena local file ikut dikumpulkan oleh FE recovery collector.

### 13.3 Recovery dependencies

Current database dependency menunjukkan:

```text
recovery_events.snapshot_id
        → recovery_snapshots.snapshot_id
        ON DELETE RESTRICT

portability_exports.snapshot_id
        → recovery_snapshots.snapshot_id
        ON DELETE RESTRICT

recovery_snapshots.sh_id
        → sh_instances.sh_id
        ON DELETE RESTRICT

recovery_snapshots.account_id
        → accounts.account_id
        ON DELETE RESTRICT
```

Artinya Recovery snapshot adalah historical persistence object dengan dependency yang memang harus dihormati. Snapshot tidak boleh diperlakukan sebagai cache sementara yang bebas dihapus.

### 13.4 Recovery retention / cleanup

Audit function current menemukan create/restore recovery, tetapi **tidak menemukan runtime cleanup/delete recovery snapshot**.

Jadi lifecycle retention Recovery saat ini belum lengkap:

```text
Create Snapshot
      ↓
Persist
      ↓
Restore
```

belum menjadi lifecycle penuh:

```text
Create
 ↓
Use / Restore
 ↓
Retention decision
 ↓
Expire
 ↓
Cleanup / Delete
```

Ini adalah **Recovery lifecycle gap**, tetapi bukan alasan untuk mengubah Canonical.

### 13.5 Attachment consequence

Dengan hybrid attachment model, lifecycle harus dipisahkan:

```text
Message lifecycle
      ≠
Attachment Resource lifecycle
      ≠
Storage Object lifecycle
      ≠
Recovery Snapshot lifecycle
```

Jika Message dihapus tetapi snapshot masih mereferensikan attachment resource pada desain final, storage object tidak boleh diasumsikan aman untuk langsung dihapus.

Sebaliknya, storage object yang sudah tidak memiliki Attachment Resource juga tidak boleh dibiarkan menjadi orphan tanpa cleanup policy.

---

## 14. Delete / Clear Reconciliation

### 14.1 Delete

Current Message Delete dan Conversation Delete memang merupakan operasi delete pada backend.

Current `conversations.thread_id` memiliki FK ke `conversation_threads.conversation_id` dengan `ON DELETE CASCADE`. `conversation_threads.sh_id` juga memiliki `ON DELETE CASCADE` ke `sh_instances`.

Tidak ada current attachment resource/storage object yang ikut dibersihkan karena attachment persistence belum ada.

Maka future attachment delete semantics harus **secara eksplisit** menentukan:

```text
Delete Message
 ↓
remove Message reference
 ↓
check Attachment references
 ↓
check Recovery / lifecycle references
 ↓
retention / cleanup decision
 ↓
possible Storage Object cleanup
```

Direct hard-delete Storage Object pada setiap Message Delete **belum disetujui**.

### 14.2 Clear

Approved Conversation contract sudah menetapkan:

```text
Clear ≠ Delete
```

Namun exact Clear semantics belum terkunci pada Canonical maupun Approved Contract.

**OWNER PROPOSAL / OPEN:** Clear diperlakukan sebagai keadaan temporary pada presentation/session tertentu, bukan sebagai penghapusan data backend.

Candidate behavior:

```text
CLEAR
 ↓
Conversation tidak ditampilkan pada current cleared view/session
 ↓
Message tetap ada di backend
 ↓
Attachment tetap ada
 ↓
Tidak ada destructive storage operation
```

Saat scope temporary tersebut berakhir atau user melakukan mekanisme restore/reopen sesuai final contract, Conversation dapat kembali direkonstruksi dari backend.

Exact scope temporary masih OPEN:

```text
screen lifetime
      atau
app/session lifetime
      atau
explicit restore
```

Tidak boleh memilih salah satu sebagai rule final tanpa Owner lock.

### 14.3 UX truthfulness requirement

Jika Clear dipilih sebagai temporary presentation/session state, UI **tidak boleh menyatakan bahwa data telah terhapus**.

Sebaliknya, semantics harus membedakan:

```text
Cleared from current view
≠
Deleted from backend
```

Ini menghindari kondisi user melihat layar kosong tetapi sistem diam-diam memperlakukan data sebagai deleted.

---

## 15. Cross-Domain Transfer Boundary

Current audit Clone → Inheritance → Succession menunjukkan attachment **tidak otomatis ikut transfer**.

```text
Clone        → no Conversation/Attachment scope
Inheritance  → no Conversation/Attachment scope
Succession   → no Conversation/Attachment scope
```

Recovery berbeda: Conversation memang termasuk snapshot, sehingga attachment reconstruction menjadi dependency Recovery.

Kesimpulan:

> Attachment tidak boleh dianggap transferable hanya karena ia terhubung ke Message.

Privacy/visibility dan transfer eligibility tetap merupakan concern terpisah.

---

## 16. Proposed Orphan Prevention Model

Future implementation harus mampu membedakan setidaknya:

```text
Storage Object tanpa Attachment Resource
→ ORPHAN OBJECT

Attachment Resource tanpa Message reference
→ belum otomatis orphan
→ dapat tetap valid bila ada Recovery/lifecycle reference

Attachment Resource tanpa Message dan tanpa lifecycle reference
→ candidate cleanup
```

Karena Postgres transaction tidak dapat rollback object yang sudah berhasil di-upload ke Storage, upload flow tidak boleh bergantung pada satu database transaction saja untuk menjamin atomicity.

Target flow perlu mengantisipasi failure window:

```text
upload object success
        ↓
descriptor insert failure
        → orphan object risk

or

descriptor success
        ↓
Message reference failure
        → orphan resource risk
```

Retry/idempotency/cleanup semantics harus ditetapkan sebelum migration final.

---

## 17. Reconciliation Result

### LOCKED

- Hybrid attachment model.
- Local path bukan durable identity.
- Backend persistence menjadi source of truth untuk attachment yang berhasil dipersist.
- Message tetap menjadi parent semantic object.
- Existing Message storage tetap `public.conversations` pada current hierarchy.
- Clear ≠ Delete adalah existing approved distinction.

### CONFIRMED GAP

- GAP-C02: backend attachment persistence + Message reconstruction.
- Renderer saat ini hanya memahami local path.
- Recovery attachment persistence/reconstruction belum ada.
- Recovery cleanup/retention runtime belum tersedia dalam current audited surface.

### NO GAP

- Existing Message `metadata jsonb` tersedia.
- Existing local `ConversationMessage` dapat serialize/deserialize local attachment path.
- Existing local category directories sudah tersedia.
- Current Recovery snapshot memang mencakup Conversation Messages.
- Current Clone/Inheritance/Succession tidak otomatis memasukkan Conversation/Attachment.

### OPEN / OWNER LOCK NEEDED

- Apakah descriptor attachment disimpan sebagai `metadata.attachments[]` atau melalui struktur backend lain.
- Storage backend mechanism dan bucket/object boundary.
- Exact upload/persistence transaction boundary.
- Exact attachment deletion semantics.
- Exact status taxonomy.
- Recovery attachment reference/reconstruction semantics.
- Recovery snapshot retention/cleanup semantics.
- Exact Clear temporary scope.
- Apakah Clear memerlukan explicit restore action atau cukup kembali ke normal session/view boundary.

---

## 18. Implementation Gate

**NO CODING YET** untuk attachment persistence maupun Clear semantics.

Implementation attachment baru boleh dimulai setelah minimum contract berikut dikunci:

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
        ↓
Recovery reference/reconstruction
        ↓
Delete/retention semantics
```

Setelah itu urutan implementasi:

```text
Contract lock
 ↓
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
Recovery integration
 ↓
Delete/retention integration
 ↓
Security verification
 ↓
Conversation E2E
 ↓
APK build
```

Clear tidak boleh diimplementasikan sebagai destructive backend delete hanya berdasarkan working proposal ini.

---

## 19. Relation to Approved Contract

Belum ada perubahan terhadap:

`docs/contract/sh_project_conversation_message_contract.md`

Attachment minimum dan Clear temporary/session semantics di dokumen ini masih **PROPOSED / OPEN** dan harus dipromosikan ke approved contract hanya setelah Owner mengunci bentuknya.

Tidak ada perubahan Canonical.
