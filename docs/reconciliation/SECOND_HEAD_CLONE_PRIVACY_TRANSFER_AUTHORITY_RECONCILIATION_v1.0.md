# SECOND HEAD — CLONE PRIVACY, TRANSFER POLICY & AUTHORITY RECONCILIATION
## v1.0 — Owner-Ratified Semantic Contract

**Status:** Owner-ratified semantic reconciliation  
**Branch:** `dev`  
**Scope:** Clone, privacy, transfer policy, authority/authorization, lifecycle semantics  
**Canonical Matrix:** `docs/SECOND_HEAD_CANONICAL_REAL_E2E_VERIFICATION_MATRIX_v1.0.md` remains the single persistent REAL E2E execution matrix.  
**Architecture:** `docs/SH_APP_ARCHITECTURE_BASELINE_v1.0.md` remains the architecture baseline.  

---

## 1. Purpose

Dokumen ini meresmikan hasil reconciliation atas boundary antara:

1. Scope / Visibility
2. Transfer Policy
3. Authority / Authorization
4. Clone eligibility

Dokumen ini tidak membuat competing verification matrix dan tidak menggantikan architecture baseline.

---

## 2. Model Dasar

```text
SCOPE / VISIBILITY
        ↓
siapa yang boleh melihat / mengakses
        ↓
PAGAR PRIVASI

TRANSFER POLICY
        ↓
record boleh ikut lifecycle transfer yang mana
        ↓
IZIN LIFECYCLE

AUTHORITY / AUTHORIZATION
        ↓
siapa yang sah melakukan operasi
        ↓
IZIN AKSI
```

Ketiga lapisan tersebut terpisah.

`PRIVATE` tidak otomatis berarti `NON_TRANSFERABLE`.

`OWNER_ONLY` tidak otomatis berarti `NON_TRANSFERABLE`.

Privacy menentukan access boundary. Transfer Policy menentukan lifecycle eligibility. Authority menentukan apakah actor sah menjalankan operasi.

---

## 3. Scope / Visibility

**Scope:**

- `PRIVATE`
- `GENERAL`

**Visibility:**

- `OWNER_ONLY`
- `SHARED`

Scope / Visibility menjawab:

> Siapa yang boleh melihat atau mengakses record ini?

Privacy boundary tetap berlaku walaupun sebuah record memiliki Transfer Policy yang memungkinkan lifecycle transfer.

---

## 4. Transfer Policy

Transfer Policy yang diratifikasi:

- `NON_TRANSFERABLE`
- `INHERITANCE`
- `SUCCESSION`
- `LEGACY`

Terminology `INHERITABLE` secara resmi diganti menjadi `INHERITANCE` agar selaras dengan nama lifecycle.

### NON_TRANSFERABLE

Record tidak eligible untuk:

- Inheritance
- Succession
- Legacy
- Clone transferable state

### INHERITANCE

Record dapat dipertimbangkan oleh lifecycle Inheritance, tetapi tetap membutuhkan authority, lifecycle validity, dan explicit selection.

`INHERITANCE` tidak memberikan akses otomatis kepada SH lain.

### SUCCESSION

Record dapat dipertimbangkan oleh lifecycle Succession, tetapi tetap membutuhkan authority, lifecycle validity, dan explicit selection.

### LEGACY

Record dapat dipertimbangkan oleh lifecycle Legacy, tetapi tetap membutuhkan authority, lifecycle validity, dan explicit selection.

---

## 5. Authority / Authorization

Authority adalah enforcement layer eksplisit di antara policy eligibility dan operation execution.

Urutan enforcement:

```text
record
  ↓
privacy / access check
  ↓
transfer-policy check
  ↓
authority / authorization check
  ↓
explicit selected-record check
  ↓
execute operation
```

Memiliki Transfer Policy tidak memberikan hak akses otomatis kepada SH lain.

Authorization untuk satu lifecycle operation tidak berarti authorization terhadap seluruh private data.

---

## 6. Clone Bukan Lifecycle Transfer

Clone tidak boleh diperlakukan sebagai sinonim dari:

- Inheritance
- Succession
- Legacy

Clone adalah mekanisme pembentukan SH baru berdasarkan Clone agreement dan state yang memang eligible untuk dibawa.

```text
SOURCE SH
    ↓
CLONE AGREEMENT
    ↓
CLONE ELIGIBILITY
    ↓
AUTHORITY / AGREEMENT CHECK
    ↓
SELECTIVE STATE
    ↓
TARGET ACCOUNT
    ↓
PRIMARY CLONE SH
```

`CLONE_SH != SOURCE_SH`.

Clone bukan salinan penuh kehidupan pribadi Source.

---

## 7. Clone Privacy Boundary

Clone tidak boleh otomatis membawa:

- private personal material;
- private conversations;
- private context;
- private Memory;
- credentials;
- source identity;
- source ownership;
- creator-only material;
- material yang secara privacy boundary hanya dimiliki Owner.

Contoh private personal / sensitive material:

- foto pribadi;
- chat curhat;
- percakapan sensitif;
- rahasia pribadi;
- konten yang Owner tidak bermaksud berikan kepada recipient.

Material tersebut tidak menjadi Clone state hanya karena material tersebut ada pada Source SH.

---

## 8. Clone dan NON_TRANSFERABLE

Owner meratifikasi rule:

```text
NON_TRANSFERABLE
        ↓
        ❌
     CLONE
```

Dengan demikian:

```text
GENERAL / SHARED + NON_TRANSFERABLE
        ↓
tidak menjadi Clone transferable state
```

```text
PRIVATE / OWNER_ONLY + NON_TRANSFERABLE
        ↓
tidak menjadi Clone transferable state
```

Jika implementasi Clone membawa record `NON_TRANSFERABLE` ke target, behavior tersebut merupakan violation terhadap Clone eligibility contract ini.

---

## 9. Clone State yang Boleh Dibawa

Clone dapat membawa state yang:

1. termasuk domain/state yang diizinkan untuk Clone;
2. tidak melanggar privacy boundary;
3. bukan `NON_TRANSFERABLE`;
4. memenuhi Clone eligibility;
5. memenuhi authority/agreement;
6. termasuk dalam selected scope transfer.

Clone tidak boleh diperlakukan sebagai:

> copy seluruh database Source SH.

---

## 10. Relationship antara Policy dan Clone

Transfer Policy tidak boleh disamakan dengan Clone.

Namun untuk Clone:

```text
NON_TRANSFERABLE
        ↓
hard exclusion
```

Policy selain `NON_TRANSFERABLE` tidak otomatis berarti Clone boleh.

```text
INHERITANCE
SUCCESSION
LEGACY
        ↓
tidak otomatis Cloneable
        ↓
harus melalui Clone eligibility
+ authority
+ agreement
+ selected state
```

---

## 11. Lifecycle Semantic Matrix

| Scope | Visibility | Policy | Inheritance | Succession | Legacy |
|---|---|---|---|---|---|
| PRIVATE | OWNER_ONLY | NON_TRANSFERABLE | ❌ | ❌ | ❌ |
| PRIVATE | OWNER_ONLY | INHERITANCE | ✅* | ❌ | ❌ |
| PRIVATE | OWNER_ONLY | SUCCESSION | ❌ | ✅* | ❌ |
| PRIVATE | OWNER_ONLY | LEGACY | ❌ | ❌ | ✅* |
| PRIVATE | SHARED | NON_TRANSFERABLE | ❌ | ❌ | ❌ |
| PRIVATE | SHARED | INHERITANCE | ✅* | ❌ | ❌ |
| PRIVATE | SHARED | SUCCESSION | ❌ | ✅* | ❌ |
| PRIVATE | SHARED | LEGACY | ❌ | ❌ | ✅* |
| GENERAL | OWNER_ONLY | NON_TRANSFERABLE | ❌ | ❌ | ❌ |
| GENERAL | OWNER_ONLY | INHERITANCE | ✅* | ❌ | ❌ |
| GENERAL | OWNER_ONLY | SUCCESSION | ❌ | ✅* | ❌ |
| GENERAL | OWNER_ONLY | LEGACY | ❌ | ❌ | ✅* |
| GENERAL | SHARED | NON_TRANSFERABLE | ❌ | ❌ | ❌ |
| GENERAL | SHARED | INHERITANCE | ✅* | ❌ | ❌ |
| GENERAL | SHARED | SUCCESSION | ❌ | ✅* | ❌ |
| GENERAL | SHARED | LEGACY | ❌ | ❌ | ✅* |

`*` Eligibility tetap membutuhkan authority, lifecycle validity, dan explicit selection.

Tabel ini adalah target semantic contract. Runtime verification tetap dilakukan melalui Canonical REAL E2E Verification Matrix.

---

## 12. Clone Semantic Matrix

| Privacy | Policy | Clone |
|---|---|---|
| PRIVATE / OWNER_ONLY | NON_TRANSFERABLE | ❌ |
| PRIVATE / OWNER_ONLY | INHERITANCE | ⚠️ selective + authorized |
| PRIVATE / OWNER_ONLY | SUCCESSION | ⚠️ lifecycle-specific |
| PRIVATE / OWNER_ONLY | LEGACY | ⚠️ lifecycle-specific |
| PRIVATE / SHARED | NON_TRANSFERABLE | ❌ |
| PRIVATE / SHARED | applicable policy | ⚠️ selective + authorized |
| GENERAL / OWNER_ONLY | NON_TRANSFERABLE | ❌ |
| GENERAL / OWNER_ONLY | applicable policy | ⚠️ selective + authorized |
| GENERAL / SHARED | NON_TRANSFERABLE | ❌ |
| GENERAL / SHARED | applicable policy | ⚠️ selective + authorized |

`⚠️` berarti tidak otomatis boleh. Record tetap harus melewati Clone eligibility, authority/agreement, privacy boundary, dan selected scope.

---

## 13. BE Responsibility

BE adalah enforcement authority.

BE wajib memastikan:

1. privacy boundary;
2. transfer policy;
3. authority;
4. Clone agreement;
5. selected scope;
6. target identity;
7. provenance;
8. ownership boundary;
9. `NON_TRANSFERABLE` exclusion.

FE tidak boleh menjadi sumber kebenaran authorization.

---

## 14. FE Responsibility

FE bertugas:

- menampilkan Scope;
- menampilkan Visibility;
- menampilkan Transfer Policy;
- menampilkan eligible records;
- menyediakan selection;
- menampilkan authorization state;
- menampilkan result/error.

FE tidak boleh menyimpulkan:

```text
PRIVATE = tidak transferable
OWNER_ONLY = tidak transferable
```

Eligibility harus berasal dari BE contract.

---

## 15. Canonical Matrix

Canonical REAL E2E Verification Matrix tetap menjadi satu-satunya execution matrix.

Matrix tetap relevan dan tidak diganti.

TC-ID yang sudah ada tetap dipertahankan. Semantic reconciliation ini tidak membuat competing matrix.

Acceptance criteria TC yang terdampak oleh semantic contract ini harus menggunakan rule baru pada verification berikutnya.

Khusus Clone:

- `TC-CLONE-09` tetap mencakup private-content exclusion;
- `TC-CLONE-10` mencakup `NON_TRANSFERABLE` exclusion;
- `TC-CLONE-11` tetap mencakup source/recipient isolation dan authority boundary;
- `TC-CLONE-12` tetap mencakup unauthorized clone operation;
- `TC-CLONE-13` tetap mencakup current APK versus latest Clone contract.

---

## 16. Architecture Baseline

`SH_APP_ARCHITECTURE_BASELINE_v1.0.md` tetap menjadi architecture authority/baseline.

Reconciliation ini tidak mengganti architecture baseline.

Privacy boundary, ownership, RLS, authority boundary, SH isolation, dan distinction antara Source SH dan Clone SH tetap dipertahankan.

Jika implementasi membutuhkan perubahan arsitektur, perubahan tersebut harus melalui change control resmi dan tidak boleh dilakukan hanya berdasarkan asumsi.

---

## 17. Implementation Impact

Semantic decision ini berdampak pada seluruh representation dan enforcement layer yang menggunakan terminology atau policy value terkait, termasuk:

- database representation;
- BE;
- API/RPC;
- FE;
- tests;
- Canonical documentation;
- verification acceptance criteria;
- runtime evidence terminology.

Perubahan terminology `INHERITABLE → INHERITANCE` bukan FE-only rename.

Implementation dilakukan melalui change-controlled BE/DB/FE work dan kemudian diverifikasi melalui APK/runtime.

Dokumen ini sendiri tidak mengklaim bahwa implementation sudah selesai atau runtime sudah PASS.

---

## 18. Owner Ratification

Owner telah meratifikasi:

- `INHERITABLE → INHERITANCE`;
- `NON_TRANSFERABLE → Clone exclusion`;
- private personal/sensitive material tidak menjadi Clone state;
- Authority sebagai enforcement layer eksplisit antara policy eligibility dan operation execution.

Ratifikasi ini menjadi semantic basis untuk implementation dan verification berikutnya.

---

## 19. Status

```text
SEMANTIC DECISION
        ↓
OWNER RATIFIED
        ↓
THIS RECONCILIATION = OFFICIAL
        ↓
IMPLEMENTATION = PENDING
        ↓
RUNTIME VERIFICATION = PENDING / AS MATRIX STATUS
```

Tidak ada claim bahwa defect yang sudah ditemukan telah diperbaiki hanya karena semantic contract ini telah diratifikasi.
