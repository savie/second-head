# SECOND HEAD — Kontrak Capability Transition Siklus Hidup

## Status
**KONTRAK KERJA — GATE DESAIN — BUKAN CANONICAL**

## Tujuan

Mendefinisikan kontrak capability runtime/database yang diperlukan sebelum mengimplementasikan transition siklus hidup semantik yang berasal dari model.

Dokumen ini tidak mengubah Canonical, Approved Contracts, schema, perilaku runtime, grants, maupun migration.

## Otoritas

Otoritas yang lebih tinggi selalu berlaku:

```text
KEPUTUSAN OWNER / USER
→ CANONICAL
→ APPROVED CONTRACT
→ ARSITEKTUR / DESAIN
→ KONTRAK KERJA INI
→ IMPLEMENTASI
→ BUKTI RUNTIME / DATABASE
→ VERIFIKASI E2E
```

## 1. Aturan Inti

Transition siklus hidup semantik adalah **state transition yang terotorisasi**, bukan sekadar perubahan field.

```text
REQUEST
→ AUTHENTICATE
→ RESOLVE ACTOR / ACCOUNT / SH
→ RESOLVE RECORD
→ VERIFY OWNERSHIP
→ VERIFY CURRENT LIFECYCLE
→ VERIFY POLICY
→ VERIFY TRANSITION AUTHORITY
→ APPLY ATOMIC CHANGE
→ PROJECT JOURNEY IF REQUIRED
→ RETURN OBSERVABLE RESULT
```

Output model tidak pernah menyediakan otoritas transition dengan sendirinya.

## 2. Matriks Transition

| Domain | CANDIDATE→ACTIVE | ACTIVE→UPDATE | ACTIVE→SUPERSEDE | Bukti saat ini |
|---|---|---|---|---|
| Memory | transition khusus diperlukan | replacement spesifik domain tersedia | replacement tersedia melalui `superseded_by` | PARTIAL |
| Knowledge | transition khusus diperlukan | belum ditetapkan | belum ditetapkan | OPEN |
| Experience | state candidate belum ditetapkan | belum ditetapkan | belum ditetapkan | OPEN |

`runtime_replace_memory` adalah operasi replacement Memory yang konkret, bukan generic lifecycle engine.

## 3. CANDIDATE → ACTIVE

### Prasyarat

Semuanya harus berhasil:

- actor terautentikasi;
- account saat ini berhasil di-resolve;
- target SH milik account saat ini dan aktif;
- record milik target SH/account;
- record saat ini berstatus `CANDIDATE`;
- domain semantik sesuai dengan transition yang diminta;
- otoritas source valid;
- hasil decision mengizinkan aktivasi;
- otoritas konfirmasi terpenuhi jika diwajibkan;
- scope/visibility valid;
- transfer policy valid;
- provenance memadai;
- semantics idempotency key/correlation terpenuhi.

### Dilarang

- aktivasi langsung dari output model;
- aktivasi melalui replay Journey;
- aktivasi menggunakan record ID actor lain yang ditebak;
- aktivasi terhadap record yang sudah terminal/superseded;
- aktivasi hanya karena confidence tinggi;
- aktivasi tanpa confirmation yang diwajibkan.

## 4. ACTIVE → UPDATE

Update harus mempertahankan:

- identity;
- ownership account/SH;
- tipe domain;
- legalitas lifecycle;
- provenance/history;
- policy scope/visibility;
- transfer policy kecuali approved policy secara eksplisit mengizinkan mutation;
- linkage Journey jika diwajibkan.

Mutation yang menghancurkan nilai historis state sebelumnya seharusnya menggunakan versioning/supersession, bukan silent overwrite, jika kontrak domain mewajibkan history.

## 5. ACTIVE → SUPERSEDE

Supersession harus:

1. mengautentikasi dan mengotorisasi actor;
2. me-resolve tepat satu source record current yang valid;
3. membuat atau mengidentifikasi successor;
4. mempertahankan record lama sebagai state historis;
5. menetapkan `old.superseded_by = successor` atau hubungan ekuivalen pada domain;
6. mempertahankan provenance;
7. mencegah record lama tetap secara keliru dianggap active/current;
8. memproyeksikan hubungan lifecycle ke Journey jika diwajibkan;
9. bersifat atomic atau secara eksplisit observable sebagai incomplete.

## 6. Aturan Spesifik Domain

### Memory

`runtime_replace_memory` adalah capability referensi saat ini:

```text
current CANDIDATE/ACTIVE
→ new CANDIDATE
→ old UPDATED + superseded_by(new)
→ MEMORY Journey event
```

Capability ini tidak boleh digeneralisasi menjadi aktivasi otomatis terhadap candidate baru.

### Knowledge

Capture candidate yang ada sudah didukung. Capability activation/update/supersession di masa depan harus didesain dan diotorisasi secara eksplisit, bukan diimplementasikan melalui direct table mutation.

### Experience

`runtime_record_experience` saat ini membuat `ACTIVE`. Workflow candidate di masa depan membutuhkan keputusan kontrak eksplisit terlebih dahulu; jangan mengasumsikan semantik candidate dari Memory/Knowledge.

## 7. Kontrak Journey

Journey adalah batas projection/history, bukan otoritas lifecycle.

Journey event boleh mereferensikan record domain, tetapi replay atau edit event tidak boleh membuat otoritas lifecycle.

Jika persistence domain dan proyeksi Journey harus merepresentasikan satu operasi logis, transaction boundary harus eksplisit dan diverifikasi.

## 8. Kontrak Security

Setiap transition harus menerapkan:

```text
auth.uid()
→ current_account_id()
→ SH ownership
→ record ownership
→ lifecycle guard
→ policy guard
→ operation authority
```

Test negatif yang diwajibkan:

- actor unauthenticated ditolak;
- SH lintas account ditolak;
- record ID lintas actor ditolak;
- lifecycle yang salah ditolak;
- record superseded ditolak;
- SH terminal ditolak jika berlaku;
- scope/visibility tidak valid ditolak;
- transfer policy tidak valid ditolak;
- authority model-only ditolak;
- replay Journey-only ditolak.

## 9. Kontrak Idempotency

Sebelum transition yang berasal dari model diaktifkan, setiap transition yang dapat di-retry dari luar harus mendefinisikan stable logical operation key.

Identity konseptual minimum:

```text
actor/account + SH + domain + source_record + transition + decision/request correlation
```

Eksekusi berulang atas logical operation yang sama tidak boleh membuat duplicate successor record atau duplicate lifecycle Journey event ketika kontrak mensyaratkan satu operasi.

Content matching saja bukan bukti idempotency request-level.

## 10. Kontrak Provenance

Sebuah transition harus dapat diaudit sampai ke:

- actor/account;
- SH;
- source record;
- source signal;
- model/provider jika berlaku;
- decision;
- confirmation/authorization;
- transition;
- timestamp;
- resulting record;
- Journey event jika berlaku.

## 11. Kontrak Failure

Tidak boleh ada false success.

```text
DB mutation gagal
→ operasi gagal
→ keberhasilan Journey yang diwajibkan tidak boleh diklaim
```

Jika domain write dan Journey write tidak atomic secara transaksional, sistem harus mengekspos intermediate state serta jalur recovery/reconciliation.

## 12. Gate Implementasi

Implementasi runtime/database tetap **CLOSED** sampai hal berikut memiliki evidence di DEV:

1. otoritas confirmation;
2. semantik retrieval candidate;
3. API/function transition per domain;
4. mekanisme idempotency/correlation;
5. kontrak provenance;
6. transaction boundary Journey;
7. authenticated positive E2E;
8. authenticated negative/cross-actor E2E;
9. transfer E2E jika transition berinteraksi dengan transfer policy.

## 13. Audit Berikutnya

Langkah engineering berikutnya adalah **Transition Capability Evidence Audit**, dengan fokus pada perilaku callable aktual dan grants untuk mekanisme transition yang diusulkan. Tidak boleh dibuat migration atau implementasi runtime spekulatif sampai audit ini menutup capability contract.

## 14. Keputusan

Hasil saat ini:

```text
POLICY CONTRACT       = RECONCILED
RUNTIME CAPABILITY    = PARTIAL
TRANSITION CONTRACT   = DEFINED
IMPLEMENTATION GATE   = CLOSED
```
