# SECOND HEAD — Kontrak Implementasi Transisi Knowledge — 2026-09-13

## Status

**KONTRAK IMPLEMENTASI WORKING — PARTIAL PASS — GATE IMPLEMENTASI TERTUTUP**

Dokumen ini menerjemahkan desain lifecycle Knowledge yang telah direkonsiliasi menjadi kontrak implementasi. Dokumen ini sendiri tidak mengotorisasi mutation database.

## 1. Aturan Dasar

- Supabase DEV adalah authority database/runtime.
- Urutan implementasi database: **Supabase DEV → verifikasi state aktual → migration history → rekonsiliasi GitHub**.
- Nama migration hanya nama deskriptif berdasarkan riwayat perubahan; jangan memakai label P3/P4/P5.
- Tidak boleh ada migration speculative, kosong, duplicate, placeholder, atau destructive.
- Full-write adalah **aturan teknis eksekusi perubahan**. Ketika implementasi diizinkan, seluruh dependency yang diperlukan harus ditangani dalam satu perubahan yang dapat diverifikasi secara utuh. Full-write bukan jenis dokumen dan bukan artefak tersendiri.
- Jika perubahan lengkap tidak dapat dilakukan dengan aman, baseline terakhir dipertahankan dan partial implementation tidak dipush.
- File baru/perbaikan harus berupa baseline + patch yang sempit dan tidak mengubah material yang tidak terkait.
- Canonical tidak disentuh tanpa otorisasi eksplisit.

## 2. Baseline Authority

Lifecycle Knowledge yang telah direkonsiliasi:

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
  ├──→ UPDATED + superseded_by successor
  ↓
DEPRECATED
  ↓
ARCHIVED
```

`VALIDATION` adalah process boundary, bukan enum lifecycle database baru.

Vocabulary DEV saat ini:

```text
CANDIDATE
ACCEPTED
INDEXED
ACTIVE
UPDATED
DEPRECATED
ARCHIVED
```

Tidak ada `SUPERSEDED` enum baru yang diotorisasi oleh kontrak ini.

## 3. Matriks Transisi

| Transisi | Kapabilitas runtime | Otoritas | Status implementasi |
|---|---|---|---|
| CANDIDATE → ACCEPTED | `runtime_accept_knowledge` | keputusan validation/acceptance yang berwenang | DIKONTRAKKAN / BELUM DIIMPLEMENTASIKAN |
| ACCEPTED → INDEXED | `runtime_index_knowledge` | operasi indexing yang berwenang | DIKONTRAKKAN / BELUM DIIMPLEMENTASIKAN |
| INDEXED → ACTIVE | `runtime_activate_knowledge` | keputusan activation yang berwenang | DIKONTRAKKAN / BELUM DIIMPLEMENTASIKAN |
| ACTIVE → UPDATED + successor | `runtime_update_knowledge` | operasi version/update yang berwenang | DIKONTRAKKAN / BELUM DIIMPLEMENTASIKAN |
| ACTIVE → DEPRECATED | `runtime_deprecate_knowledge` | operasi deprecation yang berwenang | DIKONTRAKKAN / BELUM DIIMPLEMENTASIKAN |
| DEPRECATED → ARCHIVED | `runtime_archive_knowledge` | operasi archive yang berwenang | DIKONTRAKKAN / BELUM DIIMPLEMENTASIKAN |

Nama tersebut adalah target kontrak. Keberadaan database object tidak boleh diasumsikan sebelum dibuat dan diverifikasi di Supabase DEV.

## 4. Boundary Fungsi Umum

Setiap fungsi transisi harus mengambil authority dari server. Caller-supplied account ID, actor ID, ownership claim, atau lifecycle authority tidak boleh dipercaya.

Urutan wajib:

```text
AUTHENTICATE
→ RESOLVE ACTOR / ACCOUNT
→ RESOLVE ACTIVE SH
→ LOCK TARGET RECORD
→ VERIFY OWNERSHIP
→ VERIFY DOMAIN
→ VERIFY EXPECTED CURRENT LIFECYCLE
→ VERIFY LEGAL TRANSITION
→ VERIFY SCOPE / VISIBILITY / TRANSFER POLICY
→ VERIFY DECISION / VALIDATION / CONFIRMATION AUTHORITY
→ VERIFY OPERATION IDENTITY
→ MUTATE
→ WRITE PROVENANCE / AUDIT
→ WRITE REQUIRED JOURNEY PROJECTION
→ RETURN OBSERVABLE RESULT
```

## 5. Arah Input API

Kontrak menggunakan input spesifik per transisi, bukan endpoint mutation `lifecycle` generik.

### Acceptance

```text
runtime_accept_knowledge(
  p_knowledge_id uuid,
  p_expected_lifecycle text,
  p_operation_key text,
  p_decision_ref text,
  p_validation_ref text,
  p_provenance jsonb
)
```

Expected lifecycle: `CANDIDATE`.

### Indexing

```text
runtime_index_knowledge(
  p_knowledge_id uuid,
  p_expected_lifecycle text,
  p_operation_key text,
  p_index_ref text,
  p_provenance jsonb
)
```

Expected lifecycle: `ACCEPTED`.

### Activation

```text
runtime_activate_knowledge(
  p_knowledge_id uuid,
  p_expected_lifecycle text,
  p_operation_key text,
  p_decision_ref text,
  p_confirmation_ref text,
  p_provenance jsonb
)
```

Expected lifecycle: `INDEXED`.

### Update / Supersession

```text
runtime_update_knowledge(
  p_knowledge_id uuid,
  p_expected_lifecycle text,
  p_operation_key text,
  p_update_ref text,
  p_provenance jsonb,
  p_successor_content text,
  p_successor_provenance jsonb
)
```

Expected lifecycle: `ACTIVE`.

Jika update merupakan superseding version, record lama menjadi `UPDATED` dan `superseded_by = successor_id`.

### Deprecation

```text
runtime_deprecate_knowledge(
  p_knowledge_id uuid,
  p_expected_lifecycle text,
  p_operation_key text,
  p_decision_ref text,
  p_confirmation_ref text,
  p_provenance jsonb
)
```

Expected lifecycle: `ACTIVE`.

### Archive

```text
runtime_archive_knowledge(
  p_knowledge_id uuid,
  p_expected_lifecycle text,
  p_operation_key text,
  p_decision_ref text,
  p_confirmation_ref text,
  p_provenance jsonb
)
```

Expected lifecycle: `DEPRECATED`.

Signature hanya dapat diubah jika review evidence DB/runtime menemukan incompatibility konkret.

## 6. Kontrak Output

Transition yang berhasil harus mengembalikan ID Knowledge hasil mutation dan semantics yang dapat diklasifikasikan mesin:

```text
SUCCESS
ALREADY_APPLIED
REJECTED
FAILED
```

`ALREADY_APPLIED` hanya valid jika operation identity tersimpan cocok dengan account/SH/domain/source/transition/operation key yang sama.

Operation key yang sama untuk target atau transisi berbeda adalah conflict dan harus ditolak.

## 7. Authority Per Transisi

### CANDIDATE → ACCEPTED

Memerlukan validation/acceptance decision. Model output atau confidence tidak dapat menjadi authority acceptance dengan sendirinya.

### ACCEPTED → INDEXED

Memerlukan operasi indexing yang benar-benar menyelesaikan pekerjaan indexing/storage yang diwajibkan. Tidak boleh sekaligus mengaktifkan Knowledge.

### INDEXED → ACTIVE

Memerlukan activation decision yang berwenang. Retrieval, search ranking, model confidence, atau Journey replay tidak dapat mengaktifkan Knowledge.

### ACTIVE → UPDATED

Memerlukan version/update operation. Preferred behavior adalah successor + metadata supersession, bukan overwrite destruktif.

### ACTIVE → DEPRECATED

Memerlukan deprecation authority eksplisit. Deprecation tidak otomatis archive.

### DEPRECATED → ARCHIVED

Memerlukan archive authority eksplisit. `ARCHIVED` terminal untuk jalur normal.

## 8. Kontrak Confirmation

Infrastructure DEV saat ini bersifat recovery-specific (`RECOVERY_RESTORE`) dan tidak boleh digunakan secara implisit.

Sebelum transition Knowledge yang membutuhkan confirmation diimplementasikan, authority confirmation semantic harus secara eksplisit mengikat:

```text
actor
account
SH
Knowledge target
operation type
decision reference
expiry
confirmation status
operation identity
execution authority
audit/provenance
```

Reference confirmation recovery tidak boleh dianggap sebagai lifecycle authorization Knowledge.

Jika final policy tidak mewajibkan confirmation untuk suatu transisi, `p_confirmation_ref` tidak boleh menjadi bypass channel.

## 9. Identitas Operasi / Idempotensi

Setiap transition yang dapat di-retry dari luar membutuhkan operation key stabil.

Identitas logis:

```text
account + SH + knowledge_id + transition + operation_key
```

Operation record harus membuat hasil dapat diamati sebelum retry dianggap sudah diterapkan.

Semantics concurrency:

```text
request A → SUCCESS
request B dengan logical operation sama → ALREADY_APPLIED atau hasil idempotent aman
```

Request bersamaan dengan logical operation berbeda harus mengevaluasi ulang current state yang terkunci dan tidak boleh melewati lifecycle guard.

Content deduplication bukan pengganti operation identity.

## 10. Provenance / Audit

Setiap transition sukses harus dapat ditelusuri melalui:

```text
actor
account
SH
source Knowledge record
source signal/input
model/provider bila relevan
validation result bila relevan
decision
confirmation/authorization bila relevan
transition
operation key
timestamp
resulting Knowledge record
Journey event bila relevan
```

`knowledge.provenance` dan `audit_events` boleh digunakan jika schema/security aktual benar-benar dapat menampung evidence tersebut tanpa melemahkan isolation.

Jangan membuat audit table baru hanya karena struktur yang ada belum diperiksa secara lengkap.

## 11. Kontrak Journey

Journey tetap projection/history, bukan lifecycle authority.

Untuk transition yang memerlukan Journey, event minimal mereferensikan:

```text
source Knowledge record
previous lifecycle
new lifecycle
transition
operation key
provenance reference
resulting record bila relevan
```

Event type/payload final harus direkonsiliasi dengan convention DEV sebelum implementasi.

Replay atau edit Journey tidak boleh menyebabkan lifecycle mutation.

## 12. Kontrak Transaksi Atomik

Preferred single PostgreSQL transaction:

```text
BEGIN
  authenticate / authorize
  lock target Knowledge row
  verify expected lifecycle
  verify transition authority
  verify policy
  verify confirmation/decision
  resolve operation identity
  mutate Knowledge
  persist provenance/audit
  persist Journey projection
COMMIT
```

Tidak boleh false success.

Jika boundary domain + Journey tidak dapat dibuat atomik, implementasi harus berhenti daripada mengirim lifecycle operation yang hanya sebagian berhasil, kecuali ada desain intermediate/reconciliation yang telah disetujui terpisah.

## 13. Kontrak Security / Exposure

Sebelum membuat fungsi `SECURITY DEFINER`, verifikasi dahulu apakah `SECURITY INVOKER` sudah cukup.

Jika `SECURITY DEFINER` diperlukan, wajib menetapkan:

- owner;
- `search_path` aman;
- authentication guard;
- current-account resolution;
- active SH ownership;
- Knowledge ownership;
- lifecycle guard;
- transition legality;
- policy guard;
- operation identity guard;
- exact `EXECUTE` grants;
- anonymous rejection;
- interaksi RLS;
- batas kebocoran error.

`SECURITY DEFINER` tidak boleh ditambahkan sekadar untuk melewati permission error.

## 14. Kontrak Error

Kategori minimum:

```text
UNAUTHENTICATED
NOT_AUTHORIZED
SH_NOT_OWNED
KNOWLEDGE_NOT_FOUND
DOMAIN_MISMATCH
WRONG_LIFECYCLE
INVALID_TRANSITION
INVALID_POLICY
VALIDATION_REQUIRED
DECISION_REQUIRED
CONFIRMATION_REQUIRED
OPERATION_KEY_INVALID
OPERATION_CONFLICT
ALREADY_APPLIED
CONCURRENCY_CONFLICT
DOMAIN_MUTATION_FAILED
JOURNEY_PROJECTION_FAILED
INTERNAL_FAILURE
```

SQLSTATE final harus ditentukan dari implementasi PostgreSQL aktual dan diuji di Supabase DEV. Tidak boleh mengarang mapping SQLSTATE.

## 15. Scope Full-Write Teknis

Ketika implementasi diotorisasi, dependency harus dinilai sebelum partial push:

```text
1. Inspeksi schema/state yang ada
2. Schema/constraint/index yang benar-benar diperlukan
3. Boundary authorization/RLS
4. Transition functions/RPC
5. Function owner/search_path
6. EXECUTE grants/exposure
7. Persistence operation identity
8. Persistence provenance/audit
9. Journey projection
10. Dependency caller runtime
11. Error contract
12. Positive tests
13. Negative/cross-actor tests
14. Concurrency/idempotency tests
15. Verifikasi Supabase aktual
16. Migration history
17. Rekonsiliasi GitHub
```

Daftar ini adalah **checklist teknis execution**, bukan artefak dokumentasi tambahan.

## 16. Protokol Implementasi Supabase-First

Saat gate benar-benar dibuka:

```text
INSPEKSI SUPABASE DEV
        ↓
RENCANAKAN PERUBAHAN MINIMAL YANG AMAN
        ↓
TERAPKAN KE SUPABASE DEV
        ↓
JALANKAN TEST DATABASE
        ↓
VERIFIKASI STATE DATABASE AKTUAL
        ↓
VERIFIKASI SECURITY / GRANTS FUNGSI
        ↓
VERIFIKASI POSITIVE + NEGATIVE + CONCURRENCY
        ↓
REKONSILIASI STATE DATABASE
        ↓
BUAT MIGRATION HISTORY DESKRIPTIF
        ↓
REKONSILIASI MIGRATION ↔ SUPABASE
        ↓
REKONSILIASI GITHUB DEV
```

Migration adalah catatan perubahan DB yang sudah diverifikasi, bukan authority yang mendahului perubahan DB.

## 17. Rollback / Recovery

Sebelum implementasi, definisikan object terdampak, behavior schema/data yang reversible, replacement/drop function, restoration grant, consistency Journey, consistency operation identity, dan recovery path jika transition hanya sebagian diterapkan.

Rollback tidak boleh diklaim aman jika domain dan Journey tidak dapat dipulihkan secara konsisten.

## 18. Matriks Verifikasi

### Positive

Untuk setiap transition:

```text
correct authenticated owner
+ correct SH
+ correct Knowledge record
+ expected lifecycle
+ valid authority
→ expected resulting lifecycle
```

Verifikasi row hasil, provenance, audit, Journey, dan operation identity.

### Negative

Uji penolakan untuk:

```text
unauthenticated
cross-account SH
cross-account Knowledge ID
cross-actor Knowledge ID
wrong lifecycle
illegal transition
invalid policy
missing required decision
missing required confirmation
model-only authority
Journey-only replay
operation-key conflict
terminal lifecycle
terminal SH bila relevan
```

### Concurrency

Minimal dua attempt bersamaan terhadap Knowledge record yang sama tidak boleh menghasilkan duplicate successor, lifecycle tidak konsisten, atau duplicate logical Journey history.

## 19. Hasil Gate Implementasi

```text
Lifecycle reconciliation = PASS
Transition matrix = PASS
Per-transition authority = DEFINED
API direction = DEFINED
Security boundary = DEFINED
Idempotency = DEFINED
Provenance = DEFINED
Journey boundary = DEFINED / exact payload OPEN
Atomicity = REQUIRED / runtime proof OPEN
Confirmation authority = OPEN
Operation ledger implementation = OPEN
SECURITY DEFINER review = OPEN
SQLSTATE mapping = OPEN
Runtime implementation = OPEN
E2E verification = OPEN

IMPLEMENTATION GATE = CLOSED
```

## 20. Mengapa Implementasi Masih Terblokir

Evidence DEV masih belum menutup:

1. authority confirmation semantic Knowledge;
2. persisted lifecycle operation ledger/idempotency;
3. proof atomic Knowledge + Journey transition;
4. exact Journey lifecycle event vocabulary/payload;
5. keputusan final `SECURITY DEFINER`/`INVOKER` per fungsi;
6. SQLSTATE mapping yang sudah diuji;
7. integrasi caller runtime dan E2E proof.

Membuat fungsi sebelum dependency tersebut selesai akan menghasilkan sistem partial.

## 21. Catatan Perubahan

```text
Supabase schema = UNCHANGED
Supabase data = UNCHANGED
Runtime = UNCHANGED
Migration = UNCHANGED
Canonical = UNCHANGED
Working documentation = UPDATED
Baseline = PRESERVED
```

## 22. Gate Berikutnya

**Penutupan Security / Operation Identity / Atomicity Transisi Knowledge**

Fokus:

1. tentukan apakah `audit_events` dapat secara aman melayani operation identity atau memang diperlukan ledger khusus;
2. inspeksi kontrak Journey dan kemampuan transaksi yang ada;
3. finalisasi confirmation authority semantic tanpa mengikatnya ke recovery;
4. putuskan `SECURITY INVOKER` vs `SECURITY DEFINER` per transition;
5. finalisasi SQLSTATE berdasarkan constraint implementasi aktual;
6. verifikasi dependency caller runtime;
7. tutup blocker sebelum mutation Supabase apa pun.
