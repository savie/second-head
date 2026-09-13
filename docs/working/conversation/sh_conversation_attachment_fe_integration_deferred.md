# SECOND HEAD — Conversation Attachment FE Integration Status

## Status

**RECONCILIATED — HAPPY-PATH E2E VERIFIED / RETRY IDEMPOTENCY OPEN**

Dokumen ini adalah working reconciliation record untuk Backend ↔ Frontend Conversation Attachment.

Dokumen ini bukan Canonical dan tidak mengubah Approved Attachment Contract.

## 1. Contract

Attachment adalah **Message-owned resource/payload**, bukan Message mandiri.

```text
Message
├── non-empty content
└── Attachment[]
```

Backend Message tetap mensyaratkan content non-empty. Tidak ada attachment-only Message workaround.

## 2. Current FE Call Path

```text
Composer content (non-empty)
        ↓
recordUserWithAttachments(...)
        ↓
ConversationService.recordWithAttachments()
        ↓
Message created
        ↓
Attachment create
        ↓
Storage upload
        ↓
Finalize
        ↓
Attachment PERSISTED
        ↓
AI Runtime
        ↓
SH response
```

Mismatch `recordUser('')` yang sebelumnya ada sudah bukan path saat ini.

## 3. Backend Finalize

Definition DEV saat ini untuk `runtime_finalize_conversation_attachment()` sudah memiliki lookup/update attachment yang qualified dengan benar, ownership check, pemeriksaan keberadaan storage object, serta trusted execution boundary.

**Status: IMPLEMENTED / RUNTIME PRESENT.**

## 4. Device + DEV E2E Result

Pengujian device saat ini membuktikan:

1. foto dipilih;
2. preview terlihat;
3. composer tetap tersedia;
4. caption non-empty `Test attachment E2E` dikirim;
5. user Message tersimpan;
6. Attachment tersimpan dan terhubung ke Message ID yang sama;
7. Storage object ada;
8. finalize menghasilkan `PERSISTED`;
9. SH mengembalikan response;
10. message/attachment tetap ada setelah navigation;
11. attachment/message tidak muncul setelah berpindah ke account lain.

**Happy-path attachment E2E: VERIFIED.**

Evidence ini lebih kuat daripada source-only karena hasil saat ini didukung oleh perilaku device sekaligus evidence database/runtime DEV.

## 5. Retry / Failure Semantics

Retry dalam konteks ini berarti retry pada **failed attachment send/persistence path**, bukan Edit Message dan bukan Regenerate Assistant.

```text
Edit       → update existing message content
Regenerate → replace/regenerate assistant response behavior
Retry      → recover a failed attachment/message send path
```

Happy path saat ini tidak membutuhkan retry test karena tidak terjadi failure.

### Open risk

Upload yang gagal atau ambigu di masa depan harus membuktikan bahwa retry dari logical attachment yang sama mempertahankan `attachment_id` yang sama dan tidak membuat duplicate Attachment/Message durable hanya karena orchestration dijalankan ulang.

**Status: OPEN RISK / NON-BLOCKING HARDENING.**

Jangan menyatakan retry/idempotency PASS tanpa execution test nyata terhadap failure/retry.

## 6. Scope Boundary

Reconciliation ini tidak mengubah:

- Canonical architecture;
- Approved Attachment Contract;
- Message semantic contract;
- attachment schema;
- storage policy;
- recovery semantics;
- cleanup/reconciliation worker;
- retry architecture;
- unrelated domains.

## 7. Final Disposition

```text
Old FE call-path mismatch      CLOSED / RECONCILED
Backend finalize correction     IMPLEMENTED
Happy-path attachment E2E      VERIFIED
Navigation persistence         VERIFIED
Account isolation              VERIFIED
Retry identity/idempotency     OPEN RISK
Documentation reconciliation   COMPLETED
```

**Current attachment gate: HAPPY PATH CLOSED / VERIFIED.**
