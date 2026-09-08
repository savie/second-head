# SECOND HEAD — Conversation Attachment Contract Reconciliation

## Status

**RECONCILIATION COMPLETE — PROMOTED TO APPROVED CONTRACT**

Dokumen ini adalah working reconciliation record untuk domain Conversation → Message → Attachment.

Final semantics dan contract sekarang berada di:

`docs/contract/sh_conversation_attachment_contract.md`

Dokumen ini **bukan Canonical** dan tidak mengubah Canonical.

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

## 1. Reconciliation Result

Attachment Conversation diputuskan sebagai **Message-owned resource/payload**, bukan domain SH lifecycle baru.

Model:

```text
Conversation
   ↓
Message
   ├── content
   └── Attachment[]
          ↓
     durable Storage Object
```

Semantics final:

- local file = UX/cache;
- backend-persisted attachment = durable source of truth;
- attachment memiliki stable `attachment_id` yang tidak bergantung pada local filesystem path;
- Attachment mengikuti semantic lifecycle Message;
- physical Storage Object memiliki retention dependency terpisah karena Recovery;
- Clear ≠ Delete;
- Delete Message/Conversation menghapus active attachment relationship;
- Storage Object tidak boleh blind-delete bila masih dibutuhkan Recovery;
- Recovery wajib mampu mempertahankan reference/descriptor yang cukup untuk reconstruction;
- Clone, Inheritance, dan Succession tidak otomatis mentransfer Attachment.

Final contract:

`docs/contract/sh_conversation_attachment_contract.md`

---

## 2. Owner Decisions / Locked Semantics

### Hybrid

```text
Local file
→ preview / UX / cache

Backend
→ durable source of truth
```

Local path bukan identity.

Attachment tidak dinyatakan durable sebelum backend persistence berhasil.

### Message ownership

Attachment secara semantic dimiliki Message.

Tidak ada Attachment lifecycle domain baru pada level SH.

### Clear

Approved Conversation Contract menetapkan:

```text
Clear ≠ Delete
```

Maka Clear tidak menghapus Message, Attachment, Storage Object, atau Recovery Snapshot.

Exact presentation/session scope Clear tetap berada pada design/implementation contract Clear dan tidak diubah oleh reconciliation attachment ini.

---

## 3. Lifecycle Reconciliation

Lifecycle semantic:

```text
Message Create
      ↓
Attachment persist
      ↓
Message references Attachment
```

Failure:

```text
Persistence failure
      ↓
not durable
      ↓
local cache boleh tetap tersedia
      ↓
retry
```

Retry untuk logical attachment yang sama mempertahankan identity yang sama dan tidak boleh menghasilkan duplicate durable attachment hanya karena upload diulang.

Delete:

```text
Delete Message
      ↓
Message removed
      ↓
active attachment relationship removed
      ↓
Storage cleanup jika tidak ada valid retention dependency
```

Conversation Delete mengikuti semantics yang sama setelah child Messages dihapus.

---

## 4. Recovery Reconciliation

Current DEV Recovery sudah menangkap dan restore Conversation Messages, tetapi belum menangani attachment persistence/reconstruction.

Final target:

```text
Recovery Snapshot
   ↓
Message
   ↓
Attachment reference / descriptor
   ↓
Durable Storage Object
```

Recovery Snapshot dapat menjadi retention dependency yang sah.

Karena itu:

```text
Message lifecycle
        ≠
Storage Object retention lifecycle
```

Jika Message aktif dihapus tetapi Recovery masih membutuhkan attachment, Storage Object dipertahankan.

Restore harus dapat mereconstruct Message + Attachment tanpa local filesystem path lama.

Jika durable Storage Object tidak tersedia saat restore, sistem harus menghasilkan explicit recovery gap/error dan tidak boleh mengklaim attachment recovered.

---

## 5. Orphan Reconciliation

Dibedakan:

```text
Storage Object tanpa Attachment Resource
→ ORPHAN OBJECT

Attachment Resource tanpa active Message
→ belum tentu orphan
→ dapat masih diperlukan Recovery/dependency sah

Attachment Resource tanpa Message dan tanpa dependency sah
→ candidate cleanup
```

Karena Storage upload dan PostgreSQL transaction tidak atomic, implementation harus menangani failure window antara object upload, descriptor persistence, dan Message association.

Required outcome:

- failed upload tidak menjadi durable success;
- database failure setelah upload mempunyai cleanup path;
- retry idempotent terhadap logical attachment;
- orphan object/resource dapat direkonsiliasi dan dibersihkan secara aman.

---

## 6. Cross-Domain Reconciliation

Hasil audit saat ini:

```text
Clone
→ Conversation / Attachment tidak termasuk transfer scope

Inheritance
→ Conversation / Attachment tidak termasuk transfer scope

Succession
→ Conversation / Attachment tidak termasuk transfer scope
```

Attachment tidak boleh dianggap transferable hanya karena terhubung ke Message.

Jika future domain membutuhkan transfer attachment, itu harus mendapat contract/authority tersendiri.

---

## 7. Security Reconciliation

Attachment harus mengikuti trusted Account / SH / Conversation / Message boundary.

Expected:

```text
Owner A → Attachment A     ALLOW
Owner A → Attachment B     DENY
Spoofed storage_ref         DENY
Unauthenticated             DENY
```

Filename, local path, UI state, storage reference, atau attachment ID saja bukan authority source.

Exact Storage policy/bucket/path belum ditetapkan pada reconciliation karena itu adalah Migration Design concern.

---

## 8. Current Implementation Gaps Carried Forward

Reconciliation final **tidak berarti implementation sudah selesai**.

Confirmed gaps yang tetap ada:

- backend attachment persistence belum ada;
- backend Message → Attachment reconstruction belum ada;
- current FE attachment representation masih local-path based;
- Recovery attachment persistence/reconstruction belum ada;
- Recovery snapshot cleanup/retention runtime saat ini belum lengkap;
- current attachment upload/retry/orphan handling belum diimplementasikan;
- current attachment security boundary belum tersedia karena backend attachment resource/storage belum ada.

Current DEV juga belum memiliki active attachment Storage bucket pada checkpoint audit.

DEV saat ini memiliki 29 public tables; tidak ada dedicated attachment resource table pada baseline audit tersebut.

---

## 9. Migration Design Gate

Attachment migration/design **baru boleh dimulai setelah contract ini locked**, dan sekarang condition tersebut terpenuhi.

Migration Design berikutnya wajib merekonsiliasi:

1. backend Attachment Resource schema;
2. Message ↔ Attachment relationship;
3. private durable Storage bucket/object boundary;
4. upload/idempotency flow;
5. orphan cleanup/reconciliation;
6. Message/Conversation delete behavior;
7. Recovery snapshot representation;
8. Recovery restore/reconstruction;
9. RLS/authorization boundary;
10. FE model/adapter reconstruction;
11. verification harness.

Tidak ada migration atau implementation attachment yang dilakukan dalam reconciliation step ini.
