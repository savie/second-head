# SECOND HEAD — Conversation Attachment Contract Reconciliation

## Status

**RECONCILIATION ALIGNED — BACKEND SOURCE AUDIT COMPLETED / E2E REMAINS OPEN**

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

Exact presentation/session scope Clear berada pada design/implementation contract Clear dan tidak diubah oleh reconciliation attachment ini.

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

## 4. Recovery Reconciliation — CURRENT CHECKPOINT

Current DEV Recovery **sudah memiliki implementation path** untuk menangkap dan restore Conversation Messages dengan explicit attachment relationship support.

Current resources:

```text
public.conversation_attachments
public.conversation_attachment_recovery_refs
```

Current target/implementation path:

```text
Recovery Snapshot
   ↓
Message
   ↓
persisted attachment descriptor/reference
   ↓
conversation_attachment_recovery_refs
   ↓
existing durable Attachment / Storage Object
```

Snapshot source secara eksplisit memasukkan descriptor attachment yang persisted dan masih memiliki Message relationship; recovery refs juga dibuat untuk attachment tersebut. fileciteturn73file0L2-L2

Restore/recovery path tersedia di current DEV migration history dan sudah direkonsiliasi ke Conversation hierarchy. Namun keberhasilan restore terhadap object yang tersedia/hilang belum dibuktikan melalui authenticated execution.

Binary object tidak di-embed ke JSON manifest; Recovery mempertahankan descriptor/reference yang diperlukan untuk reconstruction dan retention.

**Status: BACKEND IMPLEMENTATION PRESENT / SOURCE RECONCILED / EXECUTION VERIFICATION OPEN.**

---

## 5. Delete / Retention Reconciliation — BACKEND AUDIT

Contract menetapkan bahwa Delete Message / Conversation menghapus active Attachment relationship, sementara physical Storage Object mengikuti retention rule dan tidak boleh blind-delete bila masih dibutuhkan Recovery. fileciteturn80file0L2-L2

Current backend source mengonfirmasi:

- `conversation_attachments.message_id` memakai `ON DELETE SET NULL` terhadap Message;
- Delete Message menghapus row pada `public.conversations`, sehingga relationship attachment menjadi `NULL`;
- Delete Conversation Thread memakai cascade ke child Messages;
- `runtime_detach_conversation_attachment` juga hanya memutus relationship dengan mengosongkan `message_id`.

Source untuk Delete Message / Conversation menunjukkan tidak ada physical Storage Object delete pada operasi tersebut; thread deletion cascade berasal dari FK `conversations.thread_id → conversation_threads.conversation_id ON DELETE CASCADE`. fileciteturn73file0L2-L2 fileciteturn78file1L50-L58

**Important finding:** current DEV source belum menunjukkan cleanup worker/RPC/path yang menghapus Storage Object atau menghapus Attachment Resource ketika sudah tidak memiliki active Message maupun valid Recovery dependency.

Jadi item cleanup **bukan sekadar verification-open**; pada source saat ini cleanup mechanism belum teridentifikasi/terimplementasi.

Relationship removal sendiri dapat dinyatakan **SOURCE-VERIFIED**. Physical retention/cleanup tetap **OPEN BACKEND GAP**.

---

## 6. Orphan Reconciliation

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

Current implementation menyediakan PENDING / PERSISTED / FAILED resource lifecycle dan mempertahankan attachment identity untuk retry.

Yang sudah dapat direkonsiliasi dari source:

- failed upload dapat direpresentasikan sebagai `FAILED`;
- retry logical attachment mempertahankan `attachment_id`;
- persisted attachment memakai stable `storage_ref`;
- Recovery refs mencegah Attachment Resource yang masih direferensikan snapshot dihapus secara sembarang karena FK `ON DELETE RESTRICT`. fileciteturn73file0L2-L2

Yang belum tersedia/terbukti:

- authoritative cleanup path untuk orphan Storage Object;
- cleanup path untuk Attachment Resource yang sudah tidak memiliki Message maupun Recovery dependency;
- runtime reconciliation untuk ambiguous upload failure window.

**Status: RESOURCE STATE / RETRY IMPLEMENTED / ORPHAN CLEANUP BACKEND GAP.**

---

## 7. Cross-Domain Reconciliation

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

## 8. Security Reconciliation

Attachment harus mengikuti trusted Account / SH / Conversation / Message boundary.

Expected:

```text
Owner A → Attachment A     ALLOW
Owner A → Attachment B     DENY
Spoofed storage_ref         DENY
Unauthenticated             DENY
```

Current migration menerapkan:

- private Storage bucket;
- RLS pada `conversation_attachments`;
- owner/account + active SH checks;
- trusted RPC boundary;
- create/finalize/fail/load/detach tidak menerima Account/SH sebagai client authority;
- Storage read hanya untuk persisted attachment milik current account/SH;
- Storage write hanya untuk PENDING/FAILED attachment milik current account/SH.

Current source juga membatasi RPC execution ke `authenticated` / `service_role` dan mencabut PUBLIC/anon execution. fileciteturn73file0L2-L2

**Status: SOURCE-VERIFIED DESIGN/IMPLEMENTATION / AUTHENTICATED RUNTIME ISOLATION TEST OPEN.**

---

## 9. Current Implementation Reconciliation

Current `dev` source menunjukkan backend dan frontend attachment path sudah wired.

### Backend checkpoint

```text
public.conversation_attachments
public.conversation_attachment_recovery_refs
private bucket: second-head-conversation
trusted create/finalize/fail/load/detach RPC boundary
```

Migration yang sudah applied di DEV:

```text
20260908113655_conversation_attachments
20260908120543_revoke_conversation_attachment_truncate
```

Backend contract checkpoint:

```text
create(filename, mime_type, size_bytes)
finalize(attachment_id, message_id)
fail(attachment_id)
load(message_id)
detach(attachment_id)
```

`runtime_finalize_conversation_attachment` menggunakan stable `attachment_id` + `message_id`; storage reference tidak dikirim ulang sebagai finalize authority. fileciteturn73file0L2-L2

### Frontend checkpoint

```text
ConversationView
      ↓
ConversationRuntimeBridge
      ↓
ConversationService
      ↓
ConversationAttachmentService
      ↓
Supabase RPC / Storage
```

Current FE implementation yang terkonfirmasi di source:

- local file disimpan sebagai UX/cache;
- filename digunakan untuk derivasi MIME type sebelum durable attachment creation pada file-picker path;
- durable attachment creation/upload/finalize sudah wired;
- stable `attachment_id` dipertahankan pada failed/retry path;
- persisted attachment di-hydrate kembali saat conversation reload;
- local cached attachment identity dicocokkan kembali dengan backend attachment identity;
- jika local file hilang, FE mencoba download dari durable backend storage;
- failed attachment yang belum persisted dapat dipertahankan di local state untuk retry;
- attachment descriptor diserialisasi ke local conversation state.

Source checkpoint juga menunjukkan upload transport error tetap mencoba finalize agar retry dapat mempertahankan identity/storage reference yang sama.

**Status: IMPLEMENTED / BACKEND + FE WIRED.**

Implementation presence bukan E2E PASS. Verification tetap mencakup upload, reload, retry, isolation, delete/cleanup, recovery, dan APK behavior.

---

## 10. Migration Design Gate

Attachment migration/design **sudah frozen/locked dan sudah dieksekusi di DEV**.

Design authority:

`docs/working/conversation/sh_conversation_attachment_migration_design.md`

Execution checkpoint saat ini:

```text
Migration/schema          IMPLEMENTED
Private storage boundary  IMPLEMENTED
RPC boundary              IMPLEMENTED
Recovery relationship     IMPLEMENTED
FE integration            IMPLEMENTED
Delete relationship       SOURCE-VERIFIED
Security boundary         SOURCE-VERIFIED
Cleanup mechanism         OPEN BACKEND GAP
Semantic execution        OPEN
Authenticated E2E         OPEN
APK E2E                    OPEN
```

Tidak ada migration/schema alternatif yang boleh dibuat tanpa conflict evidence atau perubahan authority.

---

## 11. Verification / Closure Queue

### Bisa ditutup dari source audit

1. Attachment schema / durable identity.
2. Private storage boundary.
3. Trusted RPC boundary.
4. Message ↔ Attachment relationship.
5. Delete Message → active relationship removal.
6. Delete Conversation → child Message removal / attachment relationship removal.
7. Clear → tidak ada backend Clear mutation path; Clear tetap non-destructive sesuai locked semantics.
8. Recovery snapshot capture → persisted attachment descriptor + recovery reference path.
9. Cross-domain transfer exclusion.

### Masih membutuhkan execution / runtime verification

10. authenticated upload → persisted;
11. reload/reopen → attachment reconstructed;
12. private storage download dengan identity yang benar;
13. failed/ambiguous upload → retry memakai attachment identity yang sama;
14. wrong Account/SH access denied;
15. recovery restore terhadap object/resource yang tersedia;
16. missing object/resource → explicit recovery gap;
17. real APK E2E.

### Backend gap yang nyata, bukan sekadar test

18. Storage Object cleanup / retention reconciler setelah active Message relationship hilang dan tidak ada valid Recovery dependency.
19. Attachment Resource cleanup setelah tidak ada active Message dan tidak ada valid Recovery dependency.
20. Authoritative orphan/ambiguous upload reconciliation path.

**Overall attachment status: CONTRACT PASS / BACKEND SOURCE AUDIT ALIGNED / E2E + CLEANUP GAP OPEN.**

No FE implementation was changed by this reconciliation update.
