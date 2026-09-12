# SECOND HEAD — Conversation Attachment FE Integration Status

## Status

**IMPLEMENTED — FE CALL-PATH REPAIR APPLIED / FULL E2E VERIFICATION STILL OPEN**

Dokumen ini mencatat reconciliation Backend ↔ Frontend untuk Conversation Attachment.

Dokumen ini **bukan Canonical** dan tidak mengubah Approved Contract.

---

## 1. Confirmed Contract

Backend `runtime_record_conversation_message()` mensyaratkan `content` non-empty.

Attachment secara semantic adalah **Message-owned resource/payload** dan bukan Message mandiri.

Model yang berlaku:

```text
Message
├── non-empty content
└── Attachment[]
```

Tidak ada perubahan Backend/contract untuk mengakomodasi attachment-only Message.

---

## 2. FE Call-Path Repair

Temuan awal adalah call path attachment yang membuat Message dengan:

```text
recordUser('')
```

Call tersebut tidak kompatibel dengan current Backend Message contract.

Source DEV sekarang menggunakan existing orchestration path:

```text
Composer content (non-empty)
        ↓
recordUserWithAttachments(...)
        ↓
ConversationService.recordWithAttachments()
        ↓
Message created with valid content
        ↓
Attachment create
        ↓
Storage upload
        ↓
Finalize
        ↓
Message + Attachment[]
```

Dengan demikian, disposition `DEFERRED — FE CALL-PATH CONTRACT MISMATCH` pada dokumen versi sebelumnya sudah tidak sesuai dengan source aktual dan direkonsiliasi menjadi **IMPLEMENTED**.

---

## 3. Backend Finalize Correction

Backend `runtime_finalize_conversation_attachment()` telah diperbaiki untuk menghindari ambiguity antara output parameter/function variable dan kolom `conversation_attachments`.

Current runtime definition menggunakan alias tabel pada lookup dan update target.

Runtime DB inspection DEV saat reconciliation mengonfirmasi function berada pada:

- `SECURITY DEFINER`
- schema `public`
- qualified attachment lookup
- qualified update target
- storage object existence check
- valid message ownership check

Status backend correction: **IMPLEMENTED / RUNTIME DEFINITION PRESENT**.

Catatan: keberadaan function definition bukan bukti full device E2E. Device E2E tetap menjadi verification gate terpisah.

---

## 4. Current Verification State

### IMPLEMENTED / EVIDENCED

1. FE composer attachment path menggunakan `recordUserWithAttachments()`.
2. Attachment diperlakukan sebagai resource milik Message.
3. Backend Message tetap mensyaratkan non-empty content.
4. Backend finalize ambiguity correction sudah terdapat pada DEV database runtime.
5. Attachment storage bucket tetap private dan berada di domain Conversation Attachment.

### VERIFIED SEPARATELY

Journey/account-isolation verification tidak menjadi bagian dari attachment verification dan tidak mengubah status attachment.

### OPEN — FULL ATTACHMENT E2E

Verification minimum yang masih harus dibuktikan:

1. Foto/file dipilih dan preview tetap tampil.
2. Composer tetap tersedia untuk caption/pesan.
3. Send membuat Message dengan non-empty content.
4. Attachment menggunakan Message ID yang sama.
5. Storage upload berhasil.
6. Finalize menghasilkan status `PERSISTED`.
7. SH menerima message dan memberikan response.
8. Tab switch / reload tetap merekonstruksi Message + Attachment.
9. Wrong Account/SH tetap ditolak.
10. Retry setelah failure menggunakan identity attachment yang benar sesuai contract.

**Catatan retry:** current `recordWithAttachments()` membuat attachment baru ketika orchestration dijalankan ulang. Idempotent retry terhadap attachment ID yang sama belum diverifikasi/diimplementasikan sebagai FE orchestration behavior. Ini tetap **OPEN RISK**, bukan dianggap solved.

---

## 5. Scope Boundary

Reconciliation ini hanya mengubah status dokumentasi agar sesuai dengan implementation aktual.

Tidak ada perubahan pada:

- Canonical architecture;
- Approved Attachment Contract;
- Message semantic contract;
- Attachment schema;
- Storage policy;
- Recovery semantics;
- Cleanup/reconciliation worker;
- attachment retry architecture;
- unrelated frontend domains.

Temuan lain tetap diperlakukan sebagai `OPEN / OUT OF SCOPE` sampai ada authorization atau blocker nyata.

---

## 6. Disposition

```text
Old FE integration item       DEFERRED
Current FE call path          IMPLEMENTED
Backend finalize correction   IMPLEMENTED
Full attachment E2E           OPEN
Retry identity                OPEN RISK
Documentation reconciliation  COMPLETED
```

**Current disposition: FE integration repair is implemented; attachment feature must not be marked fully VERIFIED until the device/runtime E2E gate is completed.**
