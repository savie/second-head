# SECOND HEAD — Rekonsiliasi Otoritas Desain Transisi Knowledge

## Status

**DESAIN / REKONSILIASI KONTRAK WORKING — PARTIAL PASS — GATE IMPLEMENTASI TERTUTUP**

## Otoritas

Dokumen ini adalah catatan desain dan rekonsiliasi working. Dokumen ini tidak mengubah atau menggantikan Canonical, Approved Contract, atau otoritas desain historis.

Urutan otoritas:

```text
KEPUTUSAN OWNER / USER
→ CANONICAL
→ APPROVED CONTRACT
→ ARCHITECTURE / DESIGN
→ WORKING CONTRACT
→ IMPLEMENTATION
→ EVIDENCE RUNTIME / DATABASE
→ HISTORY
→ INFERENCE
→ PROPOSAL
```

## 1. Aturan Operasional yang Relevan

- Supabase DEV adalah authority untuk state database runtime.
- Implementasi database mengikuti urutan: Supabase DEV → verifikasi state aktual → migration history → rekonsiliasi GitHub.
- Nama migration hanya berupa nama deskriptif berdasarkan riwayat perubahan; jangan menggunakan label program historis P3/P4/P5.
- Tidak boleh ada migration speculative, kosong, duplicate, placeholder, atau yang merusak baseline.
- Aturan full-write adalah aturan **teknis eksekusi**: ketika implementasi benar-benar dimulai, perubahan harus mencakup seluruh dependency yang diperlukan agar satu perubahan dapat diverifikasi secara utuh. Aturan ini bukan artefak atau jenis dokumen tersendiri.
- Jika implementasi tidak dapat diselesaikan dengan aman, baseline terakhir dipertahankan dan perubahan tidak dipush sebagai partial/risky change.
- File baru atau file yang diperbaiki harus mempertahankan baseline dan hanya mengubah scope yang diperlukan.
- Canonical tidak diubah oleh gate ini.

## 2. Baseline Evidence

Fungsi Knowledge yang saat ini terbukti di Supabase DEV antara lain:

```text
runtime_record_knowledge_candidate
runtime_record_knowledge_with_journey
retrieve_knowledge_bounded
```

Belum terbukti adanya RPC khusus untuk acceptance, indexing, activation, update/supersession, deprecation, atau archive.

Vocabulary lifecycle `public.knowledge` saat ini:

```text
CANDIDATE
ACCEPTED
INDEXED
ACTIVE
UPDATED
DEPRECATED
ARCHIVED
```

Schema juga memiliki `version`, `superseded_by`, `provenance`, `transfer_policy`, `scope`, dan `visibility`.

Candidate capture ter-authenticated dan ter-scope ke SH. Itu adalah acquisition capability, bukan promotion authority.

Confirmation infrastructure tersedia, tetapi dibatasi untuk `RECOVERY_RESTORE`; tidak boleh dipakai diam-diam untuk Knowledge lifecycle.

Desain historis direkonsiliasi menjadi:

```text
Candidate → Validation → Accepted → Indexed → Active → Updated → Deprecated → Archived
```

`Validation` diperlakukan sebagai boundary proses, bukan enum lifecycle database baru.

## 3. Lifecycle Knowledge yang Direkonsiliasi

```text
ACQUISITION
    ↓
CANDIDATE
    ↓
VALIDATION PROCESS
    ↓
ACCEPTED
    ↓
INDEXING
    ↓
INDEXED
    ↓
AUTHORIZED ACTIVATION
    ↓
ACTIVE
    ├────────────→ UPDATED + superseded_by successor
    ↓
DEPRECATED
    ↓
ARCHIVED
```

Aturan:

1. `VALIDATION` adalah proses, bukan enum baru.
2. `CANDIDATE` tidak berarti `ACCEPTED`.
3. `ACCEPTED` tidak berarti `INDEXED`.
4. `INDEXED` tidak berarti `ACTIVE`.
5. Retrieval tidak mengaktifkan Knowledge.
6. Confidence model tidak memberikan lifecycle authority.
7. Journey tidak memberikan lifecycle authority.
8. Transfer materialization terpisah dari generic source-record lifecycle transition.
9. `UPDATED + superseded_by` adalah representasi supersession saat ini; jangan menambah enum `SUPERSEDED` tanpa otoritas eksplisit.
10. `ARCHIVED` adalah terminal untuk jalur lifecycle normal.

## 4. Matriks Otoritas Transisi

| Transisi | Otoritas | State yang disyaratkan | Hasil | Status |
|---|---|---|---|---|
| CANDIDATE → ACCEPTED | keputusan validation/acceptance yang berwenang | CANDIDATE | ACCEPTED | DESAIN DITETAPKAN / IMPLEMENTASI OPEN |
| ACCEPTED → INDEXED | operasi indexing yang berwenang | ACCEPTED | INDEXED | DESAIN DITETAPKAN / IMPLEMENTASI OPEN |
| INDEXED → ACTIVE | keputusan activation yang berwenang | INDEXED | ACTIVE | DESAIN DITETAPKAN / IMPLEMENTASI OPEN |
| ACTIVE → UPDATED | operasi version/update yang berwenang | ACTIVE | successor + old UPDATED | DESAIN DITETAPKAN / IMPLEMENTASI OPEN |
| ACTIVE → DEPRECATED | operasi deprecation yang berwenang | ACTIVE | DEPRECATED | DESAIN DITETAPKAN / IMPLEMENTASI OPEN |
| DEPRECATED → ARCHIVED | operasi archive yang berwenang | DEPRECATED | ARCHIVED | DESAIN DITETAPKAN / IMPLEMENTASI OPEN |

Tidak boleh ada aplikasi/model yang melakukan mutation lifecycle secara bebas melalui field `lifecycle`.

## 5. CANDIDATE → ACCEPTED

Acceptance adalah boundary governance/validation.

Evidence yang diperlukan:

- actor terautentikasi;
- account saat ini;
- SH aktif milik account;
- Knowledge milik SH/account tersebut;
- expected lifecycle `CANDIDATE`;
- hasil validation;
- referensi keputusan acceptance eksplisit;
- provenance;
- identitas operasi stabil;
- audit;
- Journey jika diwajibkan kontrak.

Tidak boleh:

```text
model output → ACCEPTED
confidence saja → ACCEPTED
occurrence count → ACCEPTED
Journey replay → ACCEPTED
direct table mutation → ACCEPTED
```

## 6. ACCEPTED → INDEXED

`INDEXED` merepresentasikan indexing/storage readiness yang berhasil. Authority-nya adalah operasi indexing, bukan promotion trust.

Urutan minimum:

```text
AUTH → OWNERSHIP → CURRENT = ACCEPTED → INDEXING AUTHORITY → OPERATION IDENTITY → MUTATION → AUDIT/PROVENANCE → JOURNEY JIKA DIPERLUKAN
```

Verifikasi SQL historis hanya membuktikan schema menerima transisi, bukan production runtime authority.

## 7. INDEXED → ACTIVE

Activation membutuhkan keputusan eksplisit yang berwenang.

Tidak boleh:

```text
retrieval → ACTIVE
search hit → ACTIVE
model confidence → ACTIVE
Journey replay → ACTIVE
```

## 8. ACTIVE → UPDATED / SUPERSEDED

Semantics saat ini berbasis versioning. Bentuk yang disukai:

```text
ACTIVE(old)
    ↓
create successor
    ↓
ACTIVE(new)
    ↓
old.lifecycle = UPDATED
old.superseded_by = new
```

Record lama tetap menjadi evidence historis. Silent overwrite dilarang ketika version history diperlukan.

Enum `SUPERSEDED` baru tidak diperkenalkan oleh rekonsiliasi ini.

## 9. ACTIVE → DEPRECATED

Deprecation adalah operasi eksplisit dan berbeda dari archive:

```text
ACTIVE → authorized deprecation → DEPRECATED
```

Tidak boleh otomatis archive kecuali ada kontrak terpisah yang memang menetapkannya.

## 10. DEPRECATED → ARCHIVED

Archive adalah transisi terminal eksplisit:

```text
DEPRECATED → authorized archive → ARCHIVED
```

Jalur lifecycle normal harus menolak:

```text
ARCHIVED → ACTIVE
ARCHIVED → UPDATED
ARCHIVED → DEPRECATED
```

Restoration/resurrection membutuhkan authority recovery dan kontrak terpisah.

## 11. Kontrak Security

Setiap transisi harus menyelesaikan authorization dengan urutan:

```text
auth.uid()
→ current_account_id()
→ active SH ownership
→ Knowledge ownership
→ expected lifecycle guard
→ transition legality
→ scope / visibility / transfer policy
→ transition authority
→ confirmation authority jika diperlukan
→ operation identity
→ mutation
```

Negative verification wajib mencakup unauthenticated, cross-account, cross-actor/cross-account Knowledge ID, wrong lifecycle, source superseded, terminal SH bila relevan, policy invalid, model-only authority, Journey replay, dan duplicate operation.

Untuk `SECURITY DEFINER`, wajib diverifikasi authentication, ownership, `search_path` aman, grant tepat, penolakan anon, kebutuhan exposure authenticated, dan kontrak SQLSTATE.

## 12. Kontrak Confirmation

Confirmation infrastructure yang ada adalah recovery-specific:

```text
runtime_high_risk_confirmations
operation = RECOVERY_RESTORE
```

Ia bukan Knowledge lifecycle authority.

Jika transisi Knowledge membutuhkan confirmation, harus ada authority terpisah yang mengikat actor, account, SH, target, operation, decision, expiry, status, operation identity, execution authority, serta audit/provenance.

Gate ini tidak mengubah tabel atau fungsi confirmation recovery.

## 13. Identitas Operasi / Idempotensi

Setiap transisi yang dapat di-retry dari luar membutuhkan identitas operasi stabil:

```text
account + SH + knowledge_id + transition + operation_key
```

Perilaku yang diharapkan:

```text
operasi sama + target sama + transisi sama
→ SUCCESS atau ALREADY_APPLIED

operasi sama + target/transisi berbeda
→ REJECTED
```

Deduplication berbasis content bukan pengganti idempotensi lifecycle request.

## 14. Provenance / Audit

Transisi harus dapat ditelusuri ke:

```text
actor
account
SH
source Knowledge record
source signal/input
model/provider bila relevan
decision
hasil validation bila relevan
authorization/confirmation bila relevan
transition
operation key
timestamp
resulting Knowledge record
Journey event bila relevan
```

`knowledge.provenance` dan `audit_events` hanya boleh dipakai jika schema dan security aktual dapat merepresentasikan evidence tersebut tanpa melemahkan isolation.

## 15. Atomicity / Journey

Boundary transaksi PostgreSQL yang diharapkan:

```text
AUTH
→ LOCK RECORD
→ VERIFY CURRENT STATE
→ VERIFY AUTHORITY
→ VERIFY POLICY
→ VERIFY OPERATION IDENTITY
→ MUTATE KNOWLEDGE
→ WRITE PROVENANCE / AUDIT
→ WRITE JOURNEY
→ COMMIT
```

Tidak boleh ada false success. Jika mutation domain berhasil tetapi Journey yang diwajibkan gagal, operasi tidak boleh dilaporkan sebagai sukses lengkap. Satu transaksi database lebih disukai untuk logical transition.

## 16. Rekonsiliasi Transfer

Materialisasi Knowledge melalui transfer tetap merupakan kontrak terpisah:

```text
Transfer materialization ≠ Generic source Knowledge lifecycle transition
```

Transfer dapat membuat target Knowledge dengan lifecycle khusus sesuai kontraknya. Itu tidak boleh digunakan untuk mengotorisasi promotion source Knowledge.

## 17. Arah API Runtime

Proposal activation generik sebelumnya ditolak. Arah yang lebih tepat adalah fungsi domain-specific:

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
```

Nama/signature tersebut hanya target kontrak; belum merupakan database object yang berwenang.

Setiap fungsi harus mengunci expected lifecycle dan legal transition, bukan menyediakan mutation `lifecycle` arbitrer.

## 18. Arah Kontrak Error

Kategori minimum yang perlu dibedakan:

```text
UNAUTHENTICATED
NOT_AUTHORIZED
SH_NOT_OWNED
RECORD_NOT_FOUND
WRONG_LIFECYCLE
INVALID_TRANSITION
INVALID_POLICY
DECISION_REQUIRED
CONFIRMATION_REQUIRED
OPERATION_CONFLICT
ALREADY_APPLIED
CONCURRENCY_CONFLICT
INTERNAL_FAILURE
```

Mapping SQLSTATE final hanya boleh ditetapkan berdasarkan implementasi PostgreSQL aktual dan hasil test DEV.

## 19. Kontrak Verifikasi

Sebelum gate implementasi ditutup, evidence DEV harus membuktikan untuk setiap transisi yang diimplementasikan:

### Positive

- transisi berhasil dari state yang benar;
- lifecycle hasil benar;
- provenance tercatat;
- audit tercatat;
- Journey benar bila diwajibkan;
- retry menghasilkan semantics idempotensi yang ditentukan.

### Negative

- unauthenticated ditolak;
- cross-account ditolak;
- cross-SH ditolak;
- wrong lifecycle ditolak;
- terminal state ditolak;
- model-only authority ditolak;
- Journey-only replay ditolak.

### Concurrency

Minimal dua attempt bersamaan terhadap record yang sama tidak boleh menghasilkan duplicate transition/successor yang invalid atau Journey history yang inkonsisten.

### Rekonsiliasi

Setiap tahap implementasi harus dapat direkonsiliasi:

```text
Supabase actual state ↔ migration history ↔ GitHub source
```

## 20. Hasil Gate

```text
Historical lifecycle intent = RECONCILED
Current schema vocabulary = VERIFIED
Validation process boundary = RECONCILED
Transition matrix = DEFINED
Security model = DEFINED
Confirmation boundary = RECONCILED
Operation identity = DEFINED
Provenance requirements = DEFINED
Journey atomicity target = DEFINED
Transfer separation = RECONCILED
Exact DB API implementation = OPEN
SQLSTATE mapping = OPEN
Runtime implementation = OPEN
Positive E2E = OPEN
Negative E2E = OPEN
Concurrency E2E = OPEN

IMPLEMENTATION GATE = CLOSED
```

## 21. Catatan Perubahan

```text
Supabase schema changes = NONE
Supabase data changes = NONE
Migration changes = NONE
Runtime code changes = NONE
Canonical changes = NONE
Working documentation = UPDATED
Baseline = PRESERVED
```

## 22. Gate Berikutnya

**Kontrak Implementasi Transisi Knowledge**

Sebelum menyentuh Supabase:

1. finalisasi signature API per transisi;
2. finalisasi authority source tiap transisi;
3. finalisasi kebutuhan confirmation;
4. finalisasi representasi operation identity/idempotency;
5. finalisasi provenance/audit;
6. finalisasi atomic Knowledge + Journey transaction;
7. finalisasi exposure dan kebijakan `SECURITY DEFINER`;
8. finalisasi SQLSTATE berdasarkan implementasi aktual;
9. definisikan test positive/negative/concurrency;
10. setelah gate benar-benar terbuka, implementasikan di Supabase DEV terlebih dahulu, verifikasi state aktual, buat migration history deskriptif, lalu rekonsiliasi GitHub.

Dokumen ini sendiri tidak mengotorisasi mutation database.
