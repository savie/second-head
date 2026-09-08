# SECOND HEAD — Conversation Attachment Contract Reconciliation

## Status

**RECONCILIATION COMPLETE — APPROVED CONTRACT + IMPLEMENTATION CHECKPOINT UPDATED**

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

## 4. Recovery Reconciliation — CURRENT CHECKPOINT

Current DEV Recovery **sudah menangkap dan restore** Conversation Messages dengan explicit attachment relationship support.

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

Restore hanya mereconnect attachment relationship jika durable attachment resource, Storage Object, dan target Message dependency tersedia. Missing dependency dihitung sebagai recovery gap dan tidak boleh diklaim sebagai successful attachment recovery.

Binary object tidak di-embed ke JSON manifest; Recovery mempertahankan descriptor/reference yang diperlukan untuk reconstruction dan retention.

**Status: BACKEND IMPLEMENTATION PRESENT / SEMANTIC + E2E VERIFICATION OPEN.**

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

Current implementation sudah menyediakan PENDING / PERSISTED / FAILED resource lifecycle dan mempertahankan attachment identity untuk retry. Yang belum boleh dianggap PASS tanpa verification adalah full cleanup/reconciliation behavior untuk orphan object/resource dan ambiguous failure windows.

Required outcome:

- failed upload tidak menjadi durable success;
- database failure setelah upload mempunyai cleanup path;
- retry idempotent terhadap logical attachment;
- orphan object/resource dapat direkonsiliasi dan dibersihkan secara aman.

**Status: IMPLEMENTATION PRESENT / CLEANUP VERIFICATION OPEN.**

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

Current migration already applies private Storage bucket and trusted attachment RPC boundary. Full authenticated semantic harness tetap harus dijalankan untuk membuktikan isolation aktual.

**Status: DESIGN/IMPLEMENTATION PRESENT / SEMANTIC VERIFICATION OPEN.**

---

## 8. Current Implementation Reconciliation

Attachment implementation saat ini sudah tersedia pada BE dan FE.

### Backend

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

### Frontend

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

Current FE sudah mencakup local cache, durable attachment creation/upload/finalize, persisted attachment hydration saat reload, download fallback, failed-state retry, dan descriptor serialization.

**Status: IMPLEMENTED / BACKEND + FE WIRED.**

Implementation presence bukan E2E PASS. Verification tetap mencakup upload, reload, retry, isolation, delete/cleanup, recovery, dan APK behavior.

---

## 9. Migration Design Gate

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
Semantic verification     OPEN
Authenticated E2E         OPEN
```

Tidak ada migration/schema alternatif yang boleh dibuat tanpa conflict evidence atau perubahan authority.

---

## 10. Verification Queue

Remaining verification:

1. authenticated upload → persisted;
2. reload/reopen → attachment reconstructed;
3. private storage download dengan identity yang benar;
4. failed/ambiguous upload → retry memakai attachment identity yang sama;
5. wrong Account/SH access denied;
6. Message Delete / Conversation Delete → active relationship removal dan cleanup/retention behavior;
7. Clear → tidak ada destructive attachment mutation;
8. recovery snapshot → restore relationship/object dependency;
9. missing object/resource → explicit recovery gap;
10. real APK E2E.

**Overall attachment status: IMPLEMENTED / CONTRACT PASS / VERIFICATION OPEN.**
