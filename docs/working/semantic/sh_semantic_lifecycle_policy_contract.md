# SECOND HEAD — Kontrak Kebijakan Siklus Hidup Semantik

## Status

**DRAF KONTRAK KERJA — GATE KEBIJAKAN — BUKAN CANONICAL**

Dokumen ini mendefinisikan batas kebijakan yang diusulkan dan diperlukan sebelum mengimplementasikan atau memperluas persistence semantik yang berasal dari model serta transition siklus hidup.

Dokumen ini adalah kontrak kerja engineering. Dokumen ini **tidak** mengubah otoritas Canonical, otoritas Approved Contract, skema database, perilaku runtime, maupun semantik siklus hidup yang sudah ada.

## Otoritas

```text
KEPUTUSAN OWNER / USER
        ↓
CANONICAL
        ↓
APPROVED CONTRACT
        ↓
ARSITEKTUR / DESAIN
        ↓
KONTRAK KEBIJAKAN KERJA INI
        ↓
IMPLEMENTASI
        ↓
BUKTI RUNTIME / DATABASE
        ↓
VERIFIKASI E2E
```

Jika dokumen ini bertentangan dengan Canonical atau Approved Contract, sumber dengan otoritas lebih tinggi yang berlaku dan dokumen ini harus direkonsiliasi, bukan digabung secara diam-diam.

## 1. Tujuan

Menutup gap definisi kebijakan yang ditemukan pada checkpoint Full Semantic Lifecycle Verification.

Kontrak ini menetapkan satu batas keputusan eksplisit untuk:

```text
MODEL SIGNAL
    ↓
CANDIDATE
    ↓
REJECT / CONFIRM / ACCEPT
    ↓
KELAYAKAN PERSISTENCE
    ↓
STATE SIKLUS HIDUP
    ↓
PROYEKSI JOURNEY
    ↓
KEBIJAKAN VISIBILITAS / KONTINUITAS / TRANSFER
    ↓
KELAYAKAN TRANSFER
```

Kontrak ini sengaja memisahkan:

- inferensi semantik dari otoritas persistence;
- pembuatan candidate dari aktivasi siklus hidup;
- persistence domain dari proyeksi Journey;
- state siklus hidup dari kebijakan transfer;
- kelayakan kebijakan dari eksekusi transfer.

## 2. Baseline Bukti Saat Ini

Implementasi DEV saat ini sudah memiliki fungsi keputusan semantik yang terpisah. `evaluateSemanticSignal()` menerima `SemanticSignal` dan mengembalikan `ACCEPT`, `REJECT`, atau `CONFIRM`; output model secara eksplisit diperlakukan sebagai candidate dan otoritas persistence berada di luar fungsi tersebut.

Path explicit-user saat ini melakukan persistence Memory, Knowledge, dan Experience melalui fungsi runtime database dan memproyeksikan record yang diuji ke Journey. Record verifikasi yang ada mengklasifikasikan path tersebut sebagai PASS, sementara persistence yang berasal dari model dan transition siklus hidup lengkap masih OPEN.

State database saat ini juga memiliki field siklus hidup dan transfer-policy pada record Memory, Knowledge, Experience, dan Journey. Fungsi transfer yang ada menerapkan kelayakan yang spesifik terhadap siklus hidup, tetapi eksekusi Clone / Inheritance / Succession secara lengkap masih menjadi gap verifikasi E2E.

Karena itu dokumen ini mendefinisikan kebijakan sebelum implementasi, bukan mengasumsikan bahwa implementasi saat ini sudah memenuhi kontrak penuh.

## 3. Bukan Tujuan Dokumen Ini

Kontrak ini tidak:

- mendesain ulang definisi domain semantik;
- memperkenalkan domain semantik baru;
- membuat tabel persistent baru;
- membuat atau mengubah migration database;
- mengubah semantik continuity Journey yang sudah ada;
- memberi otorisasi kepada output model untuk menulis langsung ke memory durable;
- mengubah dokumen Canonical;
- mendefinisikan prompting spesifik provider;
- mendefinisikan mekanisme konfirmasi UI;
- menyatakan bahwa persistence yang berasal dari model saat ini sudah terimplementasi.

## 4. Prinsip Inti

### 4.1 Output model bukan otoritas persistence

Signal yang dihasilkan model adalah candidate hasil inferensi. Signal tersebut tidak boleh secara langsung membuat, mengubah, mengaktifkan, mentransfer, atau melakukan supersede terhadap record semantik durable.

```text
MODEL
  ≠
AUTHORITY
```

### 4.2 Decision adalah input kebijakan, bukan bukti persistence

`ACCEPT`, `REJECT`, dan `CONFIRM` adalah hasil keputusan. Decision itu sendiri bukan transition state durable.

Persistence membutuhkan evaluasi kebijakan terotorisasi yang terpisah dan mempertimbangkan identity, ownership, domain, state siklus hidup, scope, visibility, transfer policy, provenance, serta aturan confirmation yang diperlukan.

### 4.3 Explicitness dari user memiliki otoritas capture lebih tinggi daripada inferensi model

Permintaan eksplisit user untuk melakukan persistence informasi semantik dapat masuk ke path persistence sesuai kontrak domain yang berlaku.

Signal yang berasal dari model dapat mengusulkan persistence, tetapi tidak dapat menaikkan dirinya sendiri menjadi otoritas eksplisit user.

### 4.4 Siklus hidup dan Journey tetap terhubung pada batas kebijakan

Setiap record semantik durable yang diproyeksikan ke Journey harus mempertahankan batas siklus hidup dan kebijakan yang dimiliki domain. Journey tidak boleh menjadi otoritas alternatif untuk ownership semantik atau state siklus hidup.

### 4.5 Transfer adalah batas otorisasi yang terpisah

Record yang persistent, active, atau direpresentasikan di Journey tidak otomatis berarti memenuhi kelayakan transfer.

```text
PERSISTED
   ≠
TRANSFERABLE
```

## 5. Kontrak Semantic Signal

Secara konseptual, sebuah semantic signal terdiri dari:

| Field | Arti | Otoritas |
|---|---|---|
| domain | MEMORY / KNOWLEDGE / EXPERIENCE / JOURNEY | output classifier; divalidasi terhadap domain yang didukung |
| confidence | tingkat keyakinan model/classifier | hanya evidence; tidak pernah menjadi satu-satunya otorisasi |
| evidence | bukti pendukung dari model | input provenance/audit |
| source | MODEL atau USER | pembeda security/policy |

### 5.1 Source MODEL

`MODEL` berarti signal berasal dari output model/provider atau ekstraksi semantik yang diturunkan dari model.

Aturan wajib:

```text
MODEL signal
    ↓
CANDIDATE
    ↓
evaluasi kebijakan
```

Signal tidak boleh melewati policy hanya karena confidence tinggi.

### 5.2 Source USER

`USER` berarti signal berasal dari tindakan/permintaan eksplisit user yang dikenali oleh approved capture contract.

Source user tidak otomatis mengotorisasi semua operasi. Ownership, authentication, aturan domain, dan kebijakan siklus hidup tetap berlaku.

## 6. Kontrak Decision

Kosakata decision saat ini tetap:

```text
ACCEPT
REJECT
CONFIRM
```

Kontrak ini tidak mendefinisikan ulang implementasi fungsi saat ini; kontrak ini menetapkan semantik downstream yang diwajibkan.

### ACCEPT

Berarti signal memenuhi kebijakan acceptance yang berlaku untuk konteks otoritas saat ini.

Interpretasi downstream yang diwajibkan:

```text
ACCEPT
  → memenuhi syarat untuk evaluasi persistence
  → dengan sendirinya tidak membuktikan persistence
```

### REJECT

Berarti candidate tidak boleh menjadi record semantik durable melalui path decision tersebut.

Interpretasi downstream yang diwajibkan:

```text
REJECT
  → tidak ada persistence semantik
  → tidak ada aktivasi siklus hidup
  → tidak ada proyeksi Journey durable untuk candidate yang ditolak
```

Record audit masih dapat ada jika kontrak audit runtime yang sudah ada mengizinkannya.

### CONFIRM

Berarti candidate memerlukan batas konfirmasi eksplisit sebelum persistence durable, kecuali Approved Contract dengan otoritas lebih tinggi secara eksplisit mendefinisikan jalur otorisasi ekuivalen.

Aturan kerja default:

```text
CONFIRM
  → candidate tetap non-active
  → tidak ada aktivasi semantik durable
  → menunggu konfirmasi eksplisit
```

`CONFIRM` tidak berarti persistence otomatis.

## 7. Kelayakan Persistence

Persistence semantik durable membutuhkan seluruh gate yang berlaku untuk berhasil:

```text
Actor terautentikasi
      ↓
Account / ownership SH ter-resolve
      ↓
Domain semantik didukung
      ↓
Otoritas source valid
      ↓
Decision mengizinkan persistence
      ↓
Transition siklus hidup legal
      ↓
Scope / visibility valid
      ↓
Transfer policy valid
      ↓
Provenance tercatat
      ↓
Persist record domain
      ↓
Proyeksikan Journey jika diwajibkan kontrak
```

Gate yang gagal adalah failure atau rejection yang nyata, bukan persistence sukses dengan metadata yang diturunkan kualitasnya.

## 8. State Candidate

`CANDIDATE` adalah state siklus hidup durable hanya jika implementasi domain memang sudah mendukungnya atau Approved Contract secara eksplisit mengizinkan persistence candidate.

Candidate berarti:

- ditemukan atau ditangkap tetapi belum sepenuhnya diaktifkan;
- tidak setara dengan konteks semantik active yang dipercaya;
- tidak otomatis dapat diambil sebagai konteks durable yang authoritative;
- tidak otomatis transferable;
- tidak berhak mengubah kebijakan siklus hidup hanya karena record tersebut ada.

Candidate harus mempertahankan provenance yang cukup untuk menjelaskan bagaimana record dibuat dan mengapa state saat ini dimilikinya.

## 9. Model State Siklus Hidup

Model siklus hidup kerja adalah:

```text
                ┌──────────────┐
                │   CANDIDATE  │
                └──────┬───────┘
                       │
             ┌─────────┴─────────┐
             │                   │
          REJECT              ACCEPT / CONFIRM
             │                   │
             ▼                   ▼
         TERMINAL          evaluasi kebijakan
                                 │
                                 ▼
                              ACTIVE
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                 UPDATE                  SUPERSEDE
                    │                         │
                    └────────────┬────────────┘
                                 ▼
                         current / successor
                                 │
                                 ▼
                       LEGACY / EOL boundary
                                 │
                    ┌────────────┼────────────┐
                    ▼            ▼            ▼
                  CLONE      INHERITANCE   SUCCESSION
```

Ini adalah model kebijakan, bukan bukti bahwa setiap transition saat ini sudah terimplementasi.

### 9.1 CANDIDATE → ACTIVE

Hanya diperbolehkan melalui transition yang diotorisasi oleh domain.

Model `ACCEPT` tidak boleh diperlakukan sebagai write `ACTIVE` tanpa syarat.

Hasil `CONFIRM` membutuhkan otoritas konfirmasi yang telah ditentukan sebelum aktivasi.

### 9.2 CANDIDATE → REJECT / terminal

Candidate yang ditolak tidak boleh menjadi active melalui retry, replay Journey, atau transfer.

### 9.3 ACTIVE → UPDATE

Update harus mempertahankan ownership, provenance, legalitas siklus hidup, dan integritas domain semantik.

### 9.4 ACTIVE → SUPERSEDE

Supersession harus mempertahankan hubungan antara record lama dan baru dan tidak boleh menghapus provenance historis secara diam-diam.

Field `superseded_by` yang sudah ada merupakan evidence bahwa konsep ini ada di schema saat ini; perilaku transition lintas domain secara lengkap masih menjadi target verifikasi.

### 9.5 LEGACY / EOL

Legacy/end-of-life adalah batas siklus hidup, bukan sekadar flag visibility.

Lifecycle terminal pada source dapat menjadi prasyarat Succession sesuai transfer policy yang ada.

## 10. Matriks Kebijakan Domain

Matriks berikut adalah batas minimum kebijakan kerja. Nilai spesifik per domain tetap tunduk pada kontrak domain yang ada dan implementasi runtime.

| Domain | Signal model boleh mengusulkan | Hasil default model | Syarat aktivasi durable | Journey |
|---|---|---|---|---|
| MEMORY | ya | CONFIRM kecuali diterima oleh policy eksplisit | persistence terotorisasi + transition siklus hidup | jika diwajibkan kontrak domain |
| KNOWLEDGE | ya | CONFIRM kecuali diterima oleh policy eksplisit | persistence terotorisasi + transition siklus hidup | jika diwajibkan kontrak domain |
| EXPERIENCE | ya | CONFIRM | konfirmasi eksplisit atau ekuivalen dengan otoritas lebih tinggi | jika diwajibkan kontrak domain |
| JOURNEY | tidak memiliki otoritas semantik durable independen | N/A | hanya proyeksi yang dimiliki domain | batas proyeksi/history |

Tabel ini dengan sendirinya tidak mengotorisasi implementasi.

## 11. Kontrak Proyeksi Journey

Journey adalah batas proyeksi/continuity untuk event siklus hidup semantik.

Untuk event semantik durable yang memerlukan proyeksi Journey:

```text
Record domain
   ↓
identity domain tervalidasi
   ↓
Journey event
```

Journey event harus menyimpan atau dapat me-resolve:

- account pemilik;
- SH/context pemilik;
- domain;
- source record ID;
- status continuity;
- visibility;
- transfer policy;
- provenance;
- event type.

Journey tidak boleh digunakan untuk membuat record semantik active dari candidate yang ditolak atau belum dikonfirmasi.

## 12. Kebijakan Visibility / Scope

Visibility dan scope independen dari state siklus hidup.

Batas minimum kebijakan tetap:

```text
scope
visibility
lifecycle
transfer_policy
provenance
```

Record tidak dapat memperoleh kelayakan transfer hanya dengan mengubah visibility, dan tidak dapat memperoleh ownership hanya karena hadir di Journey.

## 13. Kontrak Transfer Policy

Kosakata policy yang teramati di DEV saat ini adalah:

```text
NON_TRANSFERABLE
INHERITANCE
SUCCESSION
LEGACY
```

Normalisasi `INHERITABLE` menjadi `INHERITANCE` adalah detail implementasi yang sudah teramati pada batas policy saat ini; dokumen ini tidak memperluasnya menjadi kosakata baru.

### 13.1 NON_TRANSFERABLE

Record/event tidak dapat dipilih untuk transfer siklus hidup.

### 13.2 INHERITANCE

Transfer hanya diizinkan jika otorisasi inheritance dan aturan kelayakan source/target yang berlaku semuanya terpenuhi.

### 13.3 SUCCESSION

Transfer hanya diizinkan jika persyaratan end-of-life/deactivated pada source dan persyaratan otorisasi succession yang berlaku terpenuhi.

### 13.4 LEGACY

Menunjukkan batas siklus hidup yang membutuhkan semantik legacy yang berlaku. Ini tidak otomatis berarti transferable.

## 14. Operasi Transfer

Operasi konseptual yang sudah ada adalah:

```text
CLONE
INHERITANCE
SUCCESSION
```

Untuk setiap operasi:

```text
autentikasi
  ↓
resolve identity source / target
  ↓
verifikasi ownership / authority
  ↓
resolve record domain dari Journey event
  ↓
validasi lifecycle
  ↓
validasi visibility
  ↓
validasi transfer policy
  ↓
validasi kelayakan spesifik operasi
  ↓
materialisasi record/event target
  ↓
pertahankan provenance source
  ↓
verifikasi isolasi target
```

Transfer yang ditolak tidak boleh menghasilkan record target yang hanya sebagian berhasil.

## 15. Persyaratan Security Negatif

Kontrak policy tidak lengkap kecuali kasus negatif berikut diverifikasi secara eksplisit:

1. Output model tidak dapat langsung melakukan persistence state semantik durable.
2. Candidate yang ditolak tidak dapat menjadi active melalui Journey.
3. Candidate yang belum dikonfirmasi tidak dapat menjadi active tanpa otoritas yang diwajibkan.
4. User tidak dapat mentransfer record semantik actor lain hanya dengan menebak record ID.
5. Target SH tidak dapat mengubah transfer policy record hasil inheritance kecuali Approved Contract secara eksplisit mengizinkannya.
6. Record/event private atau non-transferable ditolak saat pemilihan transfer.
7. SH yang deactivated/terminal tidak dapat mengubah policy siklus hidup jika policy saat ini melarangnya.
8. Succession tidak dapat terjadi tanpa end-of-life source dan kelayakan succession.
9. Journey event lintas account tidak dapat di-resolve sebagai record milik actor saat ini.
10. Persistence atau transfer yang gagal tidak boleh menghasilkan false success.

## 16. Kontrak Atomicity / Failure

Persistence semantik dan proyeksi Journey harus diperlakukan sebagai satu operasi logis ketika kontrak database yang ada menyediakan atomicity transaksional.

Jika record domain berhasil dipersist tetapi proyeksi Journey yang diwajibkan gagal, sistem harus menunjukkan operasi sebagai incomplete/failure sesuai transaction boundary aktual; sistem tidak boleh mengklaim full lifecycle success.

Jika pada desain approved di masa depan Journey memang asynchronous, state asynchronous tersebut harus eksplisit dan observable, bukan direpresentasikan sebagai lifecycle yang sudah selesai.

## 17. Kontrak Idempotency / Retry

Persistence yang berasal dari model harus mendefinisikan idempotency sebelum implementasi.

Pemrosesan berulang terhadap signal/request yang sama tidak boleh secara diam-diam membuat duplicate semantic record atau duplicate Journey event ketika kontrak mensyaratkan satu logical capture.

Keputusan implementasi harus mengidentifikasi idempotency key atau batas correlation yang ekuivalen sebelum runtime rollout.

## 18. Kontrak Provenance

Setiap record semantik durable yang berasal dari model harus mempertahankan provenance yang cukup untuk menjawab:

```text
Siapa / apa yang menghasilkan signal?
Request runtime mana yang menghasilkan signal?
Path model/provider mana yang menghasilkan signal?
Evidence apa yang mendukungnya?
Decision apa yang dibuat?
Otorisasi/konfirmasi apa yang mengizinkan persistence?
Kapan persistence terjadi?
Journey event mana yang merepresentasikannya?
```

Nama field yang tepat adalah urusan implementasi dan harus direkonsiliasi dengan schema yang ada sebelum coding.

## 19. Kontrak Audit

Audit decision dan persistence semantik adalah dua concern yang terpisah.

State audit konseptual minimum:

```text
SIGNAL_RECEIVED
DECISION_REJECT
DECISION_CONFIRM
DECISION_ACCEPT
PERSISTENCE_ELIGIBLE
PERSISTED
PERSISTENCE_REJECTED
JOURNEY_PROJECTED
JOURNEY_PROJECTION_FAILED
TRANSFER_ELIGIBLE
TRANSFER_REJECTED
TRANSFER_COMPLETED
```

Kosakata audit runtime yang sudah ada harus diinspeksi dan direkonsiliasi sebelum memperkenalkan nilai audit baru.

## 20. Batas Implementasi

Implementasi runtime atau database tidak boleh dimulai sampai hal berikut diselesaikan terhadap state DEV aktual:

- apakah candidate row memang sengaja durable untuk setiap domain;
- fungsi transition siklus hidup yang tersedia secara tepat untuk setiap domain;
- otoritas konfirmasi yang tepat dan batas UX/runtime;
- mekanisme idempotency/correlation;
- field provenance model/provider;
- transaction boundary proyeksi Journey;
- perlakuan retrieval terhadap record `CANDIDATE`;
- perilaku transfer yang tepat untuk Clone / Inheritance / Succession;
- test harness security negatif.

## 21. Matriks Verifikasi

| Gate | Expected | Evidence yang diperlukan | Status saat ini |
|---|---|---|---|
| Klasifikasi model signal | MODEL tetap candidate | bukti runtime unit/static | EXISTING |
| REJECT | tidak ada aktivasi durable | runtime + DB negative test | OPEN |
| CONFIRM | batas konfirmasi eksplisit | runtime + E2E | OPEN |
| ACCEPT | kelayakan persistence dievaluasi | runtime + DB | OPEN |
| Candidate persistence | hanya jika kontrak domain mengizinkan | DB + rekonsiliasi kontrak | OPEN |
| Candidate → Active | hanya transition legal | authenticated E2E | OPEN |
| Active update | ownership/lifecycle dipertahankan | authenticated E2E | OPEN |
| Supersession | provenance dipertahankan | DB + E2E | OPEN |
| Proyeksi Journey | linkage domain dipertahankan | DB + runtime E2E | PARTIAL PASS |
| Visibility Journey | diberlakukan | negative E2E | PARTIAL PASS |
| Kelayakan transfer | lifecycle/policy diberlakukan | DB/static + E2E | PARTIAL PASS |
| Clone | eksekusi terotorisasi | authenticated E2E | OPEN |
| Inheritance | eksekusi terotorisasi | authenticated E2E | OPEN |
| Succession | eksekusi terotorisasi | authenticated E2E | OPEN |
| Isolasi cross-actor | akses tidak terotorisasi ditolak | security E2E | OPEN |
| Retry idempotent | duplicate logical capture dicegah | runtime + DB E2E | OPEN |

## 22. Definition of Done untuk Gate Policy Ini

Gate policy ini hanya dianggap tertutup jika:

1. Kontrak direkonsiliasi terhadap otoritas Canonical/Approved Contract.
2. Semantik transition siklus hidup spesifik domain diidentifikasi secara eksplisit.
3. Otoritas persistence yang berasal dari model didefinisikan secara eksplisit.
4. `REJECT`, `CONFIRM`, dan `ACCEPT` memiliki perilaku downstream yang tidak ambigu.
5. Semantik retrieval candidate didefinisikan.
6. Semantik proyeksi Journey didefinisikan untuk setiap transition domain durable.
7. Kelayakan transfer tetap dipisahkan dari kelayakan persistence.
8. Persyaratan security negatif dipetakan ke test yang dapat dieksekusi.
9. Batas idempotency dan failure/atomicity didefinisikan.
10. Tidak ada kontradiksi yang belum terselesaikan antara policy, runtime, dan state DB saat ini.

## 23. Gate Berikutnya

**Jangan** membuat migration atau mengubah perilaku runtime hanya berdasarkan draft ini.

Langkah engineering berikutnya adalah **Policy Reconciliation Audit**:

```text
KEBIJAKAN KERJA INI
        ↓
PEMERIKSAAN CANONICAL / APPROVED CONTRACT
        ↓
PEMERIKSAAN RUNTIME SAAT INI
        ↓
PEMERIKSAAN FUNCTION DATABASE SAAT INI
        ↓
PEMERIKSAAN STATE DATA SAAT INI
        ↓
REGISTER CONFLICT / GAP
        ↓
RENCANA IMPLEMENTASI YANG DISETUJUI
```
