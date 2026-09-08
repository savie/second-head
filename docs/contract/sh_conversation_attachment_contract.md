# SECOND HEAD — Conversation Attachment Contract

## Status

**APPROVED / LOCKED — Conversation Attachment Contract**

Dokumen ini adalah Approved Contract untuk attachment pada domain Conversation → Message.

Dokumen ini **bukan Canonical** dan tidak mengubah Canonical. Jika terdapat konflik dengan Canonical atau authority yang lebih tinggi, authority yang lebih tinggi tetap berlaku.

Contract ini diturunkan dari:

- Owner Decision: Hybrid attachment model.
- Approved Conversation / Message Contract: `docs/contract/sh_project_conversation_message_contract.md`.
- Working reconciliation: `docs/working/conversation/sh_conversation_attachment_contract_reconciliation.md`.

Authority:

```text
Owner / User Decision
        ↓
Canonical
        ↓
Approved Contract
        ↓
Architecture / Design
        ↓
Implementation
        ↓
Historical / dev_old evidence
```

---

## 1. Scope

Contract ini mengatur attachment yang melekat pada Message dalam Conversation.

Model semantic:

```text
Conversation
   ↓
Message
   ├── content
   └── Attachment[]
          ↓
     durable Storage Object
```

Attachment **bukan domain SH lifecycle baru** seperti Memory, Knowledge, Experience, Journey, atau Lifecycle.

Attachment adalah resource/payload yang secara semantic dimiliki oleh Message.

---

## 2. Owner Decisions yang Locked

### 2.1 Hybrid persistence

Attachment menggunakan model hybrid:

```text
Local file
→ UX / preview / local cache

Backend-persisted attachment
→ durable source of truth
```

Konsekuensi:

- local filesystem path bukan identity attachment;
- local copy boleh hilang, berpindah, atau dihapus tanpa mengubah identity attachment yang sudah durable;
- attachment yang dinyatakan durable harus sudah berhasil dipersist ke backend;
- backend attachment harus dapat direconstruct tanpa bergantung pada local filesystem path lama.

### 2.2 Message ownership

Attachment mengikuti semantic ownership Message.

```text
Conversation
   ↓
Message
   ↓
Attachment
```

Tidak dibuat konsep bahwa Attachment adalah owner atau authority baru.

### 2.3 Clear

Contract Conversation yang sudah approved menetapkan:

```text
Clear ≠ Delete
```

Maka Clear:

- tidak menghapus Message;
- tidak menghapus Attachment;
- tidak menghapus Storage Object;
- tidak menghapus Recovery Snapshot;
- tidak mengubah ownership;
- tidak mengubah SH identity.

Exact scope presentation/session Clear tetap mengikuti contract/design Clear yang berlaku dan tidak dikunci oleh dokumen ini.

---

## 3. Attachment Identity

Setiap attachment durable memiliki stable `attachment_id`.

`attachment_id`:

- adalah identity attachment;
- tidak berasal dari local filesystem path;
- tidak sama dengan Message ID;
- tidak menjadi sumber authorization dengan sendirinya;
- harus dapat dipertahankan ketika local cache berubah atau hilang.

`filename` bukan identity.

`storage_ref` bukan identity; ia adalah reference ke physical durable storage.

---

## 4. Attachment Descriptor

Contract minimum:

```text
Attachment
├── attachment_id
├── filename
├── mime_type
├── size_bytes
└── storage_ref
```

Message mereferensikan zero, one, atau multiple attachments melalui `attachments[]`.

Local representation boleh menambahkan:

```text
local_path
```

tetapi `local_path` adalah cache/local reference dan bukan bagian dari durable identity.

`mime_type` menjadi typed representation untuk renderer dan retrieval; extension/path dapat menjadi fallback untuk local compatibility, tetapi bukan durable semantic source of truth.

---

## 5. Attachment Lifecycle

### 5.1 Semantic rule

Attachment lifecycle mengikuti Message lifecycle pada level semantic.

Artinya:

```text
Message exists
→ attachment dapat menjadi bagian dari Message

Message deleted
→ attachment tidak lagi menjadi bagian dari active Message
```

Namun physical Storage Object mempunyai retention dependency yang berbeda karena Recovery dapat masih membutuhkannya.

Karena itu:

```text
Message lifecycle
        ≠
Storage Object retention lifecycle
```

Ini **bukan** berarti Attachment menjadi independent SH lifecycle domain.

### 5.2 Create

Attachment baru dapat menjadi durable attachment Message setelah backend persistence berhasil.

Target semantic flow:

```text
Pick / Capture
      ↓
Local cache / preview
      ↓
Backend persistence
      ↓
Durable Attachment
      ↓
Message references Attachment
```

Implementation tidak boleh menampilkan atau menyatakan attachment sebagai durable bila backend persistence belum berhasil.

### 5.3 Failure

Jika backend persistence gagal:

- attachment tidak boleh dianggap durable;
- local copy boleh tetap tersedia sebagai cache/UX state;
- UI harus dapat membedakan failure dari durable success;
- retry boleh dilakukan tanpa mengubah logical identity attachment menjadi attachment baru secara tidak perlu.

Exact transport/error presentation adalah implementation concern selama tidak melanggar semantics ini.

### 5.4 Retry / idempotency

Retry untuk logical attachment yang sama harus mempertahankan identity attachment yang sama apabila payload yang diretry memang attachment yang sama.

Retry tidak boleh menghasilkan rangkaian attachment durable yang duplikatif hanya karena operasi upload diulang.

Implementation dapat menggunakan idempotency mechanism yang sesuai; exact mechanism bukan bagian dari contract ini.

---

## 6. Delete Semantics

### 6.1 Delete Message

```text
Delete Message
      ↓
Message removed
      ↓
Attachment relationship removed
```

Secara semantic attachment tersebut tidak lagi menjadi bagian dari active Conversation.

Physical Storage Object **tidak wajib dihapus secara synchronous pada saat yang sama** apabila masih memiliki retention dependency, terutama Recovery.

### 6.2 Delete Conversation

```text
Delete Conversation
      ↓
Messages removed
      ↓
Attachment relationships removed
```

Physical Storage Object mengikuti cleanup/retention rule yang sama.

### 6.3 Storage cleanup

Storage Object dapat di-cleanup ketika tidak lagi dibutuhkan oleh active Message maupun retention dependency yang sah.

Jangan menjadikan `Message DELETE → blind physical object DELETE` sebagai satu-satunya rule karena dapat merusak Recovery.

---

## 7. Recovery Semantics

Conversation Message termasuk bagian dari Recovery.

Attachment harus ikut menjadi dependency Recovery agar Message yang direstore tidak kehilangan attachment durable.

Target model:

```text
Recovery Snapshot
   ↓
Message
   ↓
Attachment reference / descriptor
   ↓
Durable Storage Object
```

### 7.1 Snapshot creation

Ketika Recovery Snapshot menangkap Conversation Message yang memiliki attachment durable, snapshot harus mempertahankan informasi/reference yang cukup untuk mengenali dan mereconstruct attachment tersebut.

Snapshot tidak diwajibkan menyimpan binary attachment di dalam JSON manifest.

### 7.2 Retention dependency

Recovery Snapshot dapat menjadi alasan sah untuk mempertahankan Storage Object setelah Message aktif dihapus.

Contoh:

```text
Message A
   ↓
Attachment X

Recovery Snapshot R
   ↓
Attachment X

Delete Message A
   ↓
active Message reference hilang
   ↓
Recovery reference masih ada
   ↓
Attachment X / Storage Object dipertahankan
```

Dengan demikian Recovery tidak menjadi broken hanya karena user menghapus Message aktif.

### 7.3 Restore

Restore Recovery harus dapat memulihkan Message beserta attachment reference yang menjadi bagian dari snapshot.

Jika Storage Object yang dibutuhkan masih tersedia, restore menggunakan durable attachment tersebut dan tidak bergantung pada local filesystem path lama.

Jika attachment object tidak tersedia, restore harus menghasilkan explicit recovery gap/error untuk attachment tersebut; sistem tidak boleh mengklaim recovery attachment berhasil bila object tidak dapat direconstruct.

### 7.4 Snapshot deletion / expiration

Attachment retention yang hanya dipertahankan karena Recovery Snapshot berakhir ketika dependency Recovery tersebut secara sah berakhir.

Mechanism untuk snapshot expiration/cleanup adalah bagian dari Recovery implementation lifecycle dan tidak didefinisikan ulang sebagai Attachment lifecycle baru di contract ini.

---

## 8. Orphan Semantics

Harus dibedakan:

```text
Storage Object tanpa Attachment Resource
→ ORPHAN OBJECT

Attachment Resource tanpa active Message
→ belum tentu orphan
→ dapat masih diperlukan Recovery / dependency sah lainnya

Attachment Resource tanpa Message dan tanpa dependency sah
→ candidate cleanup
```

Karena upload Storage dan transaction PostgreSQL bukan satu atomic transaction, implementation harus menyediakan mekanisme untuk menangani failure window antara upload object dan persistence/reference database.

Minimal outcome yang harus dicapai:

- failed upload tidak dianggap durable;
- failed database persistence tidak meninggalkan object tanpa cleanup path;
- retry tidak membuat duplicate logical attachments;
- cleanup dapat mengidentifikasi candidate orphan.

Exact cleanup mechanism, scheduler, TTL, atau reconciliation job adalah design/implementation detail yang harus mengikuti contract ini.

---

## 9. Clone / Inheritance / Succession Boundary

Attachment **tidak otomatis transferable** hanya karena terhubung ke Message.

Current audited domain boundaries:

```text
Clone
→ Conversation / Attachment tidak termasuk transfer scope

Inheritance
→ Conversation / Attachment tidak termasuk transfer scope

Succession
→ Conversation / Attachment tidak termasuk transfer scope
```

Contract ini tidak memperluas scope ketiga domain tersebut.

Jika suatu saat attachment perlu ikut transfer pada domain tertentu, itu membutuhkan contract/authority yang sesuai; tidak boleh disimpulkan otomatis dari attachment persistence.

Privacy/visibility dan transfer eligibility tetap merupakan concern yang berbeda.

---

## 10. Security Boundary

Attachment authorization harus mengikuti trusted Account/SH/Conversation/Message ownership boundary.

Minimum expected behavior:

```text
Owner Account A → Attachment A     ALLOW
Owner Account A → Attachment B     DENY
Spoofed storage_ref                 DENY
Unauthenticated                     DENY
```

Tidak boleh menggunakan:

- filename;
- local path;
- UI state;
- client-provided storage reference;
- attachment_id saja

sebagai sumber authority.

Physical storage harus berada pada access boundary yang sesuai dengan private durable data. Exact Supabase Storage policy/path mechanism ditetapkan pada migration/design stage.

---

## 11. Frontend Contract

Frontend harus memperlakukan:

```text
local_path
```

sebagai cache/reference lokal, bukan identity.

Reconstruction setelah reload harus menggunakan durable attachment identity/reference dari backend.

UI harus dapat membedakan sekurang-kurangnya:

```text
local preview/cache available
backend durable
backend persistence failed/unavailable
```

UI tidak boleh menyamakan attachment yang hanya tersimpan lokal dengan attachment yang sudah durable.

---

## 12. Backend Contract

Backend harus menyediakan boundary untuk:

1. create/persist attachment secara authorized;
2. associate attachment dengan Message;
3. retrieve/reconstruct attachment secara authorized;
4. delete/detach attachment relationship ketika Message/Conversation dihapus;
5. mempertahankan attachment yang masih diperlukan Recovery;
6. membersihkan orphan object/resource melalui mekanisme yang aman.

Mutation tidak boleh mengandalkan client sebagai authority untuk Account/SH ownership.

---

## 13. Verification Requirements

Sebelum implementation dinyatakan verified, minimum harus dibuktikan:

### Persistence

```text
Create Message + Attachment
→ attachment durable
→ reload Conversation
→ attachment dapat direconstruct
```

### Failure / retry

```text
Upload failure
→ not durable
→ retry
→ no duplicate logical attachment
```

### Delete

```text
Delete Message
→ Message gone
→ attachment relationship gone
→ Storage Object cleaned when no valid retention dependency exists
```

### Clear

```text
Clear
→ Message remains
→ Attachment remains
→ no destructive storage operation
```

### Recovery

```text
Create Recovery Snapshot
→ Message + Attachment dependency captured

Delete active Message
→ Recovery dependency preserved

Restore Snapshot
→ Message + Attachment reconstructed
```

### Security

```text
A → A attachment       ALLOW
A → B attachment       DENY
spoof                   DENY
unauthenticated         DENY
```

### Transfer

```text
Clone / Inheritance / Succession
→ attachment not implicitly transferred
```

---

## 14. Explicit Non-Goals

Contract ini tidak menetapkan:

- bucket name tertentu;
- storage folder/path tertentu;
- exact Supabase Storage policy implementation;
- exact attachment table schema;
- exact upload API/RPC shape;
- exact retry transport;
- exact cleanup scheduler/TTL;
- exact Recovery snapshot JSON field name;
- exact Clear presentation/session scope;
- automatic Clone/Inherit/Succession transfer;
- binary embedding ke Recovery JSON.

Semua itu baru boleh diputuskan pada Architecture / Design / Migration Design selama tidak bertentangan dengan contract ini.

---

## 15. Contract Lock Result

### LOCKED

- Hybrid local cache + backend durable source of truth.
- Attachment is a Message-owned resource/payload, not a new SH lifecycle domain.
- Stable attachment identity is independent of local path and Message ID.
- Message Delete removes the active attachment relationship.
- Physical storage may be retained when a valid Recovery dependency exists.
- Clear never deletes Attachment or Storage Object.
- Recovery must preserve enough attachment reference/descriptor to reconstruct durable attachment.
- Clone, Inheritance, and Succession do not implicitly transfer Attachment.
- Failed persistence is not durable success.
- Retry must preserve logical attachment identity and avoid duplicate durable attachment creation.
- Orphan object/resource cleanup is required by implementation design.

### OPEN FOR DESIGN ONLY

- exact backend schema;
- metadata versus dedicated attachment structure;
- storage bucket/path;
- upload orchestration;
- cleanup mechanism;
- exact Recovery manifest representation;
- exact Clear presentation/session behavior.

### IMPLEMENTATION GATE

No attachment migration or implementation may begin until Migration Design reconciles this contract with current DEV schema, Storage availability, RLS/security boundary, Recovery snapshot/restore functions, Message mutation functions, and existing FE adapter/model boundaries.
