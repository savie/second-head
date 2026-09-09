# SECOND HEAD — Conversation Attachment FE Integration Deferred Item

## Status

**DEFERRED — FE CALL-PATH CONTRACT MISMATCH / NO SOURCE CHANGE APPLIED**

Dokumen ini mencatat satu integration item yang ditemukan saat reconciliation Backend ↔ Frontend untuk Conversation Attachment.

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

Tidak ada perubahan Backend/contract yang dilakukan untuk mengakomodasi attachment-only Message.

---

## 2. Confirmed FE Issue

Current `ConversationView._persistPickedAttachment()` memiliki call path yang membuat Message dengan:

```text
recordUser('')
```

Call tersebut tidak kompatibel dengan current Backend Message contract dan akan ditolak oleh backend karena content kosong.

`ConversationService.recordWithAttachments()` sudah tersedia sebagai orchestration path untuk Message dengan content + attachments, tetapi current `ConversationView` attachment path belum menggunakannya.

---

## 3. Disposition

**Tidak diaplikasikan pada scope sesi ini.**

Alasan:

- user meminta scope minimal dan tidak membuat/mengubah frontend;
- perubahan ini berada pada FE call path;
- Backend tidak boleh dilonggarkan hanya untuk mengakomodasi call path FE yang salah;
- attachment-only Message belum menjadi semantic contract yang disetujui.

Tidak ada perubahan pada:

- Backend schema/RPC;
- Attachment service;
- Storage policy;
- Recovery semantics;
- Cleanup/reconciliation worker;
- Canonical/Approved Contract.

---

## 4. Recommended Repair — NOT APPLIED

Jika FE repair nanti di-authorize dan contract tetap menggunakan Backend sebagai authority, arah perbaikan minimal adalah:

```text
Composer content (non-empty)
        ↓
existing recordWithAttachments()
        ↓
Message created with valid content
        ↓
Attachment create
        ↓
upload/finalize
        ↓
Message + Attachment[]
```

Alternatif attachment-only flow **tidak boleh dibuat sebagai workaround Backend**. Jika SH memang membutuhkan attachment-only Message, itu harus menjadi explicit contract/architecture decision terlebih dahulu.

### Repair boundary

Perubahan nanti dibatasi pada existing FE call path yang salah.

Tidak perlu:

- membuat UI baru;
- membuat Attachment domain baru;
- mengubah Message contract;
- mengubah Attachment schema;
- mengubah Storage policy;
- mengubah retry identity;
- mengubah cleanup/reconciliation;
- mengubah Recovery semantics.

---

## 5. Verification Gate Setelah Repair

Setelah FE repair benar-benar di-authorize dan diterapkan, verification minimum:

1. Message dibuat dengan non-empty content.
2. Attachment menggunakan Message ID yang sama.
3. Upload/finalize menghasilkan `PERSISTED`.
4. Reload/reopen merekonstruksi Message + Attachment.
5. Failed upload tetap dapat retry menggunakan `attachment_id` yang sama.
6. Wrong Account/SH tetap ditolak.

**Current disposition: DEFERRED / READY FOR TARGETED FE REPAIR WHEN FE SCOPE IS OPENED.**
