# SECOND HEAD — Conversation Attachment Contract Reconciliation

## Status

**RECONCILIATION ALIGNED — BACKEND CLEANUP + ORPHAN RECONCILIATION IMPLEMENTED / E2E DEFERRED**

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
cleanup queue
      ↓
retention check
      ├── Recovery ref ada → defer/retry
      └── tidak ada ref + PERSISTED → Attachment Resource dihapus
                                      ↓
                              Storage API remove
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

Snapshot source secara eksplisit memasukkan descriptor attachment yang persisted dan masih memiliki Message relationship; recovery refs juga dibuat untuk attachment tersebut.

Restore/recovery path tersedia di current DEV migration history dan sudah direkonsiliasi ke Conversation hierarchy. Keberhasilan restore terhadap object yang tersedia/hilang belum dieksekusi dan tetap menjadi E2E/verification gate.

Binary object tidak di-embed ke JSON manifest; Recovery mempertahankan descriptor/reference yang diperlukan untuk reconstruction dan retention.

**Status: BACKEND IMPLEMENTATION PRESENT / SOURCE RECONCILED / E2E DEFERRED.**

---

## 5. Delete / Retention Reconciliation — BACKEND IMPLEMENTED

Contract menetapkan bahwa Delete Message / Conversation menghapus active Attachment relationship, sementara physical Storage Object mengikuti retention rule dan tidak boleh blind-delete bila masih dibutuhkan Recovery.

Current backend source mengonfirmasi:

- `conversation_attachments.message_id` memakai `ON DELETE SET NULL` terhadap Message;
- Delete Message menghapus row pada `public.conversations`, sehingga relationship attachment menjadi `NULL`;
- Delete Conversation Thread memakai cascade ke child Messages;
- `runtime_detach_conversation_attachment` juga hanya memutus relationship dengan mengosongkan `message_id`.

Backend cleanup sekarang sudah ditambahkan:

```text
Message relationship → NULL
        ↓
AFTER UPDATE trigger
        ↓
conversation_attachment_cleanup_queue
        ↓
retention check
        ├── Recovery ref ada → defer/retry
        └── tidak ada ref + PERSISTED → Attachment Resource dihapus
                                      ↓
                              Storage API remove
```

Physical Storage Object **tidak** dihapus melalui SQL `DELETE FROM storage.objects`. Worker `runtime-conversation-attachment-cleanup` memakai Supabase Storage API, sesuai Storage boundary platform.

Jika Storage API gagal, queue tetap retryable (`FAILED` → `available_at` berikutnya). Jika attachment sudah tidak ada, queue tetap dapat memproses Storage Object berdasarkan retained `storage_ref`.

**Status: DURABLE RETENTION / ATTACHMENT RESOURCE CLEANUP BACKEND IMPLEMENTED.**

---

## 6. Orphan / Ambiguous Upload Reconciliation — BACKEND IMPLEMENTED

Dibedakan:

```text
Storage Object tanpa Attachment Resource
→ ORPHAN OBJECT

Attachment Resource PENDING/FAILED + Storage Object ada
→ RETRYABLE ATTACHMENT RESOURCE

Attachment Resource PENDING/FAILED + Storage Object tidak ada
→ RETRYABLE UPLOAD

PERSISTED + Message/Recovery dependency
→ REFERENCED / RETAINED

PERSISTED + tidak ada Message + tidak ada Recovery dependency
→ cleanup candidate
```

Current implementation tetap menyediakan PENDING / PERSISTED / FAILED resource lifecycle dan mempertahankan attachment identity untuk retry.

Backend reconciliation sekarang menyediakan:

- service-only `runtime_reconcile_conversation_attachment_storage_refs_internal(text[])` untuk authoritative DB classification;
- authenticated-scoped reconciliation RPC `runtime_reconcile_conversation_attachment_storage_refs(text[])` untuk trusted runtime callers;
- `runtime-conversation-attachment-reconcile` Edge Function sebagai Storage ↔ DB reconciliation worker;
- Storage Object yang tidak memiliki Attachment Resource diklasifikasikan sebagai orphan dan dihapus hanya melalui Supabase Storage API;
- PENDING/FAILED resource dengan object **tidak dihapus** sehingga stable attachment identity tetap dapat dipakai untuk retry;
- PENDING/FAILED resource tanpa object tetap dipertahankan sebagai retryable upload state;
- PERSISTED resource tanpa Storage Object dilaporkan sebagai integrity gap dan tidak diam-diam dihapus;
- Recovery dependency tetap menjadi retention guard.

Reconciliation worker bersifat service-role-only. Ia tidak menggunakan Account/SH identity caller untuk menentukan ownership saat melakukan global orphan scan, sehingga object milik Account/SH lain tidak salah diklasifikasikan sebagai orphan hanya karena tidak terlihat dari caller.

Physical deletion tetap dilakukan melalui Storage API, bukan SQL, karena SQL deletion terhadap Storage metadata tidak menghapus physical object.

DEV saat reconciliation diimplementasikan berada dalam clean state:

```text
conversation_attachments = 0
cleanup_queue = 0
second-head-conversation objects = 0
```

Tidak ada existing orphan/pending/failed data yang perlu dimigrasikan atau direpair.

**Status: AMBIGUOUS-UPLOAD / ORPHAN RECONCILIATION BACKEND IMPLEMENTED / RUNTIME E2E DEFERRED.**

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
- Storage write hanya untuk PENDING/FAILED attachment milik current account/SH;
- cleanup queue tidak diekspos sebagai tabel langsung ke `anon`/`authenticated`;
- cleanup worker memakai service-level Storage API access;
- global orphan classification RPC hanya dapat dieksekusi oleh `service_role`;
- reconciliation Edge Function metadata `verify_jwt=false`; authentication/authorization service-level diverifikasi di function body.

Current source juga membatasi RPC execution sesuai trusted boundary dan mencabut PUBLIC/anon execution pada reconciliation internal.

**Status: SOURCE-VERIFIED DESIGN/IMPLEMENTATION / AUTHENTICATED RUNTIME TEST DEFERRED.**

---

## 9. Current Implementation Reconciliation

Current `dev` source menunjukkan backend dan frontend attachment path sudah wired.

### Backend checkpoint

```text
public.conversation_attachments
public.conversation_attachment_recovery_refs
public.conversation_attachment_cleanup_queue
private bucket: second-head-conversation
trusted create/finalize/fail/load/detach RPC boundary
cleanup claim/complete/fail RPC boundary
attachment storage reconciliation RPC boundary
service-only orphan reconciliation RPC boundary
Edge Function: runtime-conversation-attachment-cleanup
Edge Function: runtime-conversation-attachment-reconcile
```

Applied DEV migrations:

```text
20260908113655_conversation_attachments
20260908120543_revoke_conversation_attachment_truncate
20260909024233_conversation_attachment_cleanup
20260909024649_conversation_attachment_orphan_reconciliation
20260909024705_conversation_attachment_orphan_reconciliation_global
20260909040729_conversation_attachment_maintenance_scheduler_reconciliation
```

Repository migration sources are versioned under:

`database/migrations/`

The cleanup/reconciliation migrations are stored with the exact version/name reported by Supabase DEV migration history. No separate ad-hoc schema variant is treated as authoritative.

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

**Status: IMPLEMENTED / BACKEND + FE WIRED.**

Implementation presence bukan E2E PASS. E2E tetap sengaja ditunda sesuai scope sesi.

---

## 10. Migration Design Gate

Attachment migration/design **sudah frozen/locked dan sudah dieksekusi di DEV**.

Design authority:

`docs/working/conversation/sh_conversation_attachment_migration_design.md`

Execution checkpoint saat ini:

```text
Migration/schema                 IMPLEMENTED
Private storage boundary        IMPLEMENTED
RPC boundary                    IMPLEMENTED
Recovery relationship            IMPLEMENTED
FE integration                   IMPLEMENTED
Delete relationship              SOURCE-VERIFIED
Durable cleanup mechanism        IMPLEMENTED
Ambiguous-upload reconciliation  IMPLEMENTED
Authenticated E2E                DEFERRED
APK E2E                          DEFERRED
```

Tidak ada migration/schema alternatif yang dibuat.

---

## 11. Verification / Closure Queue

### Bisa ditutup dari source audit / implementation reconciliation

1. Attachment schema / durable identity.
2. Private storage boundary.
3. Trusted RPC boundary.
4. Message ↔ Attachment relationship.
5. Delete Message → active relationship removal.
6. Delete Conversation → child Message removal / attachment relationship removal.
7. Clear → tidak ada backend Clear mutation path; Clear tetap non-destructive sesuai locked semantics.
8. Recovery snapshot capture → persisted attachment descriptor + recovery reference path.
9. Cross-domain transfer exclusion.
10. Durable detached attachment cleanup queue.
11. Recovery-aware retention guard.
12. Storage API cleanup worker path.
13. Repository migration ↔ Supabase DEV migration history reconciliation.
14. Orphan Storage Object classification and service-only cleanup path.
15. PENDING/FAILED ambiguous upload reconciliation classification.

### Masih membutuhkan execution / runtime verification — sengaja ditunda

16. authenticated upload → persisted;
17. reload/reopen → attachment reconstructed;
18. private storage download dengan identity yang benar;
19. failed/ambiguous upload → retry memakai attachment identity yang sama;
20. wrong Account/SH access denied;
21. recovery restore terhadap object/resource yang tersedia;
22. missing object/resource → explicit recovery gap;
23. real APK E2E.

**Overall attachment status: CONTRACT PASS / BACKEND CLEANUP + ORPHAN RECONCILIATION IMPLEMENTED / E2E DEFERRED.**

No FE implementation was changed by this backend reconciliation update.
