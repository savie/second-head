# SECOND HEAD — Domain Reconciliation Checkpoint — 2026-09-12

## Status

**WORKING — CURRENT CHECKPOINT / EVIDENCE RECONCILIATED**

Dokumen ini merupakan checkpoint continuity untuk domain:

`Conversation → Attachment → Memory → Knowledge → Experience → Journey`

Dokumen ini bukan Canonical dan tidak mengubah Approved Contract.

## Authority

```text
OWNER / USER DECISION
        ↓
CANONICAL
        ↓
APPROVED CONTRACT
        ↓
ARCHITECTURE / DESIGN
        ↓
CURRENT IMPLEMENTATION
        ↓
RUNTIME / DATABASE EVIDENCE
        ↓
DEVICE / E2E EVIDENCE
        ↓
HISTORICAL / dev_old
```

## Evidence checkpoint

- Repository: `savie/second-head`, branch `dev`.
- Database: Supabase DEV `pkhkgvsrqeupvwoqjwmd`.
- Evidence DEV saat ini diperiksa terhadap source repository dan state runtime/database.
- Jumlah row domain pada checkpoint: `conversations=37`, `conversation_threads=9`, `conversation_attachments=5`, `memories=1`, `knowledge=0`, `experiences=0`, `journey_events=1`.
- Jumlah row hanya merupakan evidence state saat ini; jumlah tersebut bukan bukti capability dengan sendirinya.

# 1. Conversation

## Current state

Runtime Conversation/Message dan integrasi Flutter sudah terimplementasi untuk path yang saat ini diuji.

Evidence current/verified mencakup:

- persistence user message;
- persistence assistant message;
- identifier conversation/thread yang aktif;
- runtime bridge yang meneruskan `conversation_id` dan `user_message_id`;
- path response AI runtime yang dinamis;
- provider fallback/runtime observability;
- persistence setelah tab-switch/reload yang diamati pada device untuk test conversation saat ini;
- account isolation yang diamati melalui account-switch testing.

## Important distinction

```text
Edit Message ≠ Retry Attachment ≠ Regenerate Assistant
```

`Edit` mengubah content message.
`Regenerate` berkaitan dengan response assistant.
`Retry` pada attachment UI saat ini dimaksudkan untuk path pengiriman attachment/message yang gagal.

## Open

Contract parameter adapter update/delete Conversation harus tetap menjadi item audit terpisah sampai diverifikasi secara eksplisit. Hasil tersebut tidak boleh ditandai PASS hanya karena hasil E2E attachment.

# 2. Conversation Attachment

## Current happy path

Path berikut sudah diverifikasi melalui evidence device + database/runtime DEV:

```text
Pick photo/file
    ↓
Preview remains visible
    ↓
Composer remains available
    ↓
Non-empty caption/message
    ↓
Send
    ↓
Conversation Message created
    ↓
Attachment Resource created
    ↓
Storage object uploaded
    ↓
Finalize
    ↓
Attachment = PERSISTED
    ↓
SH runtime response
    ↓
Assistant message persisted
    ↓
Tab switch / account switch verification
```

Attachment yang diuji memiliki:

- caption user: `Test attachment E2E`;
- attachment terhubung ke Message ID user yang sama dan sudah tersimpan;
- status attachment `PERSISTED`;
- private bucket object tersedia;
- response SH berhasil.

User juga memverifikasi bahwa attachment/message tetap ada setelah navigation dan tidak muncul ketika berpindah account.

## Status

```text
Happy-path send              VERIFIED
Persistence                  VERIFIED
Message ↔ Attachment link    VERIFIED
Storage                      VERIFIED
Finalize                     VERIFIED
SH response                  VERIFIED
Navigation persistence       VERIFIED (device)
Account isolation            VERIFIED (device)
```

## Open risk — retry identity

Hardening retry saat ini **bukan blocker** dan tidak diperlukan untuk membuka kembali happy path.

Risikonya adalah orchestration tingkat tinggi `recordWithAttachments()` saat ini membuat Message dan Attachment dalam orchestration pengiriman baru. Skenario failure/retry di masa depan harus membuktikan bahwa retry dari logical attachment yang gagal menggunakan kembali `attachment_id` yang sama dan tidak membuat resource durable duplicate.

Jangan menyatakan retry/idempotency PASS sampai tersedia execution nyata terhadap upload yang gagal/ambigu dan hasilnya telah diverifikasi.

# 3. Memory

## Current evidence

Explicit memory capture saat ini sebelumnya telah diverifikasi di DEV:

- `memories` berisi Memory yang dicapture;
- lifecycle bernilai `CANDIDATE`;
- scope/visibility bersifat owner-private;
- Journey event yang sesuai tersedia;
- runtime audit menunjukkan request, semantic capture, dan response berhasil.

Hydration Journey pada FE sekarang menggunakan backend Journey retrieval melalui trusted identity boundary, bukan menjadikan local Journey storage sebagai satu-satunya authority.

## Status

```text
Memory persistence                 VERIFIED for tested capture
Memory → Journey projection        VERIFIED for tested capture
Owner visibility                   VERIFIED for tested path
General Memory semantic coverage   NOT globally closed
```

Jangan menggeneralisasi satu capture Memory yang diuji menjadi bukti seluruh semantics lifecycle/retrieval Memory.

# 4. Knowledge

DEV saat ini memiliki domain `knowledge` dan reference source semantic/runtime tersedia. Database pada checkpoint saat ini memiliki zero `knowledge` rows.

Karena itu:

```text
Domain implementation/source       CURRENT / PRESENT
Positive data instance             NONE at checkpoint
Full semantic E2E                  OPEN
```

Tidak ada claim PASS untuk positive Knowledge capture/retrieval E2E karena tidak ada row/evidence Knowledge positif pada checkpoint saat ini.

# 5. Experience

DEV saat ini memiliki domain `experiences` dan lineage source semantic/migration. Database pada checkpoint saat ini memiliki zero `experiences` rows.

Karena itu:

```text
Domain implementation/source       CURRENT / PRESENT
Positive data instance             NONE at checkpoint
Full semantic E2E                  OPEN
```

Tidak ada claim PASS untuk positive Experience capture/retrieval E2E tanpa evidence runtime/data positif yang current.

# 6. Journey

## Current state

Runtime retrieval Journey dan integrasi Context Resolver sudah direkonsiliasi sebelumnya.

Evidence contract/source saat ini menetapkan:

```text
runtime_get_context_package()
        ↓
assemble_context()
        ↓
Memory
Knowledge
Experience
Journey
```

Journey retrieval tetap dibatasi oleh `runtime_get_journey_context()` dan trusted identity/ownership rules.

Journey UI saat ini memuat data Journey dari backend dan menggabungkannya dengan local presentation state menggunakan identity `event_id`. Local Journey storage bersifat account-scoped.

## Device verification

Journey Memory Account A terlihat.
Setelah berpindah ke Account B, Memory Account A menghilang.
Memory B dibuat.
Ketika kembali ke Account A, Memory A kembali terlihat tanpa mengekspos Memory B.

Dengan demikian account isolation Journey local pada path yang diuji adalah **PASS**.

## Status

```text
Journey persistence              VERIFIED
Journey backend retrieval        VERIFIED
Journey Context integration      IMPLEMENTED / VERIFIED
Journey FE hydration             VERIFIED
Local account isolation          VERIFIED (device)
Cross-account exposure           DENIED in tested path
```

Jangan membuka kembali integrasi Journey Context Resolver hanya karena inventory lama masih menyatakan OPEN; itu merupakan documentation drift, bukan state runtime saat ini.

# 7. Cross-domain Context

Context Resolver contract saat ini sudah diputuskan dan direkonsiliasi.
Ordering yang dimaksudkan tetap:

```text
actor
 → conversation
 → state
 → memory
 → knowledge
 → experience
 → journey
```

Resolver menghasilkan unified semantic context package dengan tetap mempertahankan domain boundary, ownership/visibility, dan relevance rules.

Checkpoint ini **tidak** menyatakan bahwa setiap semantic domain memiliki positive AI E2E yang membuktikan model menggunakan setiap domain. Bukti tersebut merupakan verification layer terpisah.

# 8. Documentation Reconciliation Result

Classification lama berikut dianggap stale ketika membaca state saat ini berdasarkan checkpoint ini:

| Previous stale claim | Current classification |
|---|---|
| Conversation dynamic AI not complete | Path runtime saat ini sudah terimplementasi dan terverifikasi untuk flow conversation/attachment yang diuji |
| Attachment APK E2E deferred | Happy-path attachment E2E sudah terverifikasi; failure-retry/idempotency masih open |
| Memory/Journey backend integration open | Memory persistence + Journey projection/retrieval pada path yang diuji sudah terverifikasi |
| Journey Context Resolver integration pending | Sudah implemented/reconciled/verified |
| Knowledge full semantic E2E | OPEN — tidak ada positive Knowledge instance pada checkpoint |
| Experience full semantic E2E | OPEN — tidak ada positive Experience instance pada checkpoint |

Tabel ini merupakan reconciliation statement, bukan perubahan authority.

# 9. Explicit Non-Claims

Checkpoint ini **tidak** menyatakan:

- retry/idempotency sudah terverifikasi;
- full Knowledge lifecycle sudah terverifikasi;
- full Experience lifecycle sudah terverifikasi;
- seluruh parameter Conversation CRUD adapter sudah terverifikasi;
- full Recovery restore E2E sudah terverifikasi;
- seluruh semantics Lifecycle/Clone/Inheritance/Succession sudah terverifikasi;
- setiap model/provider menggunakan setiap Context domain secara semantik dengan benar.

## 10. Next Gate

Jangan membuka kembali pekerjaan Conversation/Attachment/Journey yang sudah closed tanpa evidence baru.

Pekerjaan berikutnya harus menargetkan **confirmed OPEN dependency**, bukan dokumentasi archaeology.

Prioritas kandidat tetap:

1. Conversation adapter update/delete parameter audit;
2. Knowledge positive semantic/runtime verification;
3. Experience positive semantic/runtime verification;
4. Security/succession semantic harness;
5. gate lain yang sudah confirmed dari master inventory.

Daftar ini tidak secara otomatis mengotorisasi implementasi.
