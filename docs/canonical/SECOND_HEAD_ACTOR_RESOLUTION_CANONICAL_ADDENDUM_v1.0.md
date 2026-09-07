# SECOND HEAD — ACTOR RESOLUTION & AUTHORITY CANONICAL ADDENDUM v1.0

**Project:** SECOND HEAD (SH)  
**Version:** SH v1.0  
**Status:** Draft — Canonical Addendum in Development  
**Bahasa:** Indonesia  
**Scope:** Identity, Actor Classification, Authority Resolution, Runtime Context, Permission Policy, Enforcement  
**Parent Authority:** `docs/canonical/SECOND_HEAD_SH_CORE_CANONICAL_v1.0_BILINGUAL.md`  

---

## 1. Tujuan

Addendum ini dibuat untuk memperjelas siapa atau apa yang dimaksud oleh actor dalam sistem SECOND HEAD dan bagaimana sistem menentukan actor tersebut dari sumber identitas atau execution context yang terpercaya.

Addendum ini merupakan pengembangan dari SH Core Canonical pada area semantik actor, authority, dan runtime context. Ia tidak dimaksudkan untuk mengubah boundary Canonical yang sudah ada secara diam-diam.

Tujuan utamanya adalah memisahkan dengan jelas:

```text
Identity
    ↓
Actor Classification
    ↓
Authority Resolution
    ↓
Runtime / Execution Context
    ↓
Permission Policy
    ↓
Enforcement
```

Permission matrix tidak menjadi sumber kebenaran identitas. Permission matrix hanya menentukan policy untuk actor yang sudah berhasil diidentifikasi dan diklasifikasikan.

---

## 2. Hubungan dengan SH Core Canonical

Addendum ini harus dibaca bersama SH Core Canonical dan Canonical Addendum yang lebih baru dan authoritative untuk area yang telah ditetapkan.

Boundary fundamental berikut tetap berlaku:

- `Account_ID ≠ SH_ID`
- `Runtime ≠ SH Identity`
- `Model ≠ SH Identity`
- `Creator Authority ≠ Private Data Access`
- `SH-000 Core Authority ≠ Private Data Access`
- `Runtime Access ≠ Ownership`
- `System Governance ≠ Omniscient Data Access`

Addendum ini tidak mengubah prinsip-prinsip tersebut.

---

## 3. Model Actor

Untuk kebutuhan sistem, actor dibedakan menjadi lima kategori yang saat ini sudah muncul dalam policy taxonomy SH:

```text
CREATOR
ACCOUNT_OWNER
SH-000
ORDINARY_SH
SYSTEM_RUNTIME
```

Kelima istilah tersebut tidak boleh dianggap otomatis setara.

Secara konseptual:

- `CREATOR` menunjuk authority pada level Creator.
- `ACCOUNT_OWNER` menunjuk pemilik Account/SH yang sedang ter-resolve.
- `SH-000` menunjuk SH khusus yang berhubungan dengan Creator dan memiliki Core Governance Authority dalam batas Canonical.
- `ORDINARY_SH` menunjuk kategori SH biasa, tetapi definisi final kategori ini harus ditetapkan secara eksplisit.
- `SYSTEM_RUNTIME` menunjuk execution context sistem dan bukan identitas SH.

---

## 4. CREATOR

### 4.1 Makna

`CREATOR` adalah actor yang secara sah ditetapkan sebagai Creator SH.

Creator authority berasal dari sumber authority yang terpercaya, bukan dari nilai UI, `creator_ref`, atau asumsi bahwa pemilik suatu SH otomatis adalah Creator.

### 4.2 Sumber Identitas / Authority

Sumber yang digunakan untuk menentukan Creator harus merupakan authority assignment yang terpercaya dan aktif pada Account yang telah ter-resolve.

Model konseptual saat ini:

```text
Authenticated Identity
        ↓
ACCOUNT_ID
        ↓
Active Creator Authority Assignment
        ↓
CREATOR
```

### 4.3 Boundary

Menjadi `CREATOR` tidak berarti otomatis memiliki akses ke seluruh private data.

Creator Authority tetap terpisah dari Private Data Access.

---

## 5. ACCOUNT_OWNER

### 5.1 Makna

`ACCOUNT_OWNER` adalah actor yang merupakan pemilik Account/SH yang sedang menjadi subject dari authenticated identity resolution dan tidak sedang diklasifikasikan sebagai Creator.

### 5.2 Sumber Identitas

Model konseptual:

```text
Authenticated Identity
        ↓
ACCOUNT_ID
        ↓
Ownership / Primary SH Resolution
        ↓
ACCOUNT_OWNER
```

### 5.3 Boundary

Ownership tidak boleh disimpulkan hanya dari UI atau field yang dikirim client.

Account ownership dan SH identity tetap merupakan konsep yang berbeda walaupun keduanya digunakan dalam satu application flow.

---

## 6. SH-000

### 6.1 Makna Canonical

`SH-000` adalah SH khusus yang berhubungan dengan Creator dan memiliki Core Governance Authority dalam boundary yang ditentukan SH Core Canonical.

SH-000 bukan pemilik seluruh SH instance dan bukan berarti memiliki akses omniscient terhadap private data.

### 6.2 Prinsip Identifikasi

SH-000 harus dikenali melalui hubungan identity yang terpercaya, bukan melalui tebakan frontend atau sekadar string yang dikirim client.

Model konseptual yang sedang dikembangkan:

```text
Authenticated Identity
        ↓
ACCOUNT_ID
        ↓
CREATOR AUTHORITY
        ↓
Creator-associated SH Identity
        ↓
SH-000
```

### 6.3 Technical Mapping

Cara teknis yang tepat untuk memetakan Creator-associated SH menjadi `SH-000` belum menjadi keputusan implementasi final pada saat draft ini dibuat.

Implementasi tidak boleh menganggap `creator_ref` sebagai source of truth untuk Creator authority.

### 6.4 Boundary

```text
SH-000 Core Authority ≠ Private Data Access
SH-000 ≠ All SH Owners
SH-000 ≠ Omniscient System Access
```

---

## 7. ORDINARY_SH

### 7.1 Makna yang Ditargetkan

`ORDINARY_SH` dimaksudkan sebagai kategori untuk SH yang bukan SH khusus seperti SH-000.

Namun, apakah seluruh SH non-SH-000 otomatis termasuk `ORDINARY_SH` belum ditetapkan sebagai semantic rule final.

### 7.2 Aturan Saat Ini

Sampai definisi final disetujui:

- jangan menganggap semua SH non-SH-000 otomatis `ORDINARY_SH`;
- jangan membuat actor resolution baru hanya berdasarkan nama actor pada permission matrix;
- jangan menggunakan `ORDINARY_SH` untuk menggantikan konsep ownership atau Account Owner;
- jangan menganggap `ORDINARY_SH` sebagai authority level yang lebih rendah tanpa definisi eksplisit.

### 7.3 Open Decision

Definisi final perlu menjawab:

1. Apakah setiap SH biasa selalu merupakan `ORDINARY_SH`?
2. Apakah `ORDINARY_SH` adalah klasifikasi berdasarkan identity, authority, atau keduanya?
3. Apakah ada SH lain di masa depan yang bukan SH-000 tetapi juga bukan `ORDINARY_SH`?
4. Apakah actor `ORDINARY_SH` diperlukan sebagai runtime actor atau hanya sebagai policy category?

---

## 8. SYSTEM_RUNTIME

### 8.1 Makna

`SYSTEM_RUNTIME` adalah actor yang merepresentasikan execution context sistem ketika runtime melakukan operasi yang memang berasal dari sistem dan telah melewati trusted runtime boundary.

`SYSTEM_RUNTIME` bukan:

- SH_ID;
- Account Owner;
- Creator;
- pengganti authenticated user;
- identitas yang boleh ditebak dari UI.

### 8.2 Sumber Context

Model konseptual:

```text
Trusted System Execution Context
        ↓
SYSTEM_RUNTIME
```

### 8.3 Boundary Fundamental

```text
SYSTEM_RUNTIME ≠ SH_IDENTITY
SYSTEM_RUNTIME ≠ ACCOUNT_OWNER
SYSTEM_RUNTIME ≠ CREATOR
RUNTIME ACCESS ≠ OWNERSHIP
```

`SYSTEM_RUNTIME` tidak boleh diturunkan dari `SH_ID` hanya karena sebuah operasi dijalankan untuk suatu SH.

### 8.4 Open Decision

Mekanisme trusted runtime context yang menjadi source of truth masih harus ditetapkan sebelum implementasi actor resolution final.

---

## 9. Actor Resolution Pipeline

Arsitektur target:

```text
1. Authentication
        ↓
2. Identity Resolution
        ↓
3. Actor Classification
        ↓
4. Authority Resolution
        ↓
5. Runtime Context Resolution
        ↓
6. Permission Policy Evaluation
        ↓
7. Enforcement
```

### 9.1 Authentication

Menentukan authenticated principal yang masuk ke sistem.

### 9.2 Identity Resolution

Menentukan Account dan SH identity yang memang dimiliki / terkait dengan authenticated principal berdasarkan trusted backend resolution.

### 9.3 Actor Classification

Menentukan kategori actor berdasarkan identity dan/atau execution context yang telah dipercaya.

### 9.4 Authority Resolution

Menentukan authority yang benar-benar dimiliki actor.

### 9.5 Runtime Context Resolution

Menentukan apakah operasi berasal dari authenticated principal biasa atau trusted system runtime.

### 9.6 Permission Policy

Permission matrix mengevaluasi policy berdasarkan actor, target relation, scope, dan kondisi authorization yang relevan.

### 9.7 Enforcement

Access boundary dan runtime enforcement menolak operasi yang tidak memenuhi policy.

---

## 10. Pemisahan Source of Truth

Setiap layer memiliki tanggung jawab berbeda.

| Layer | Menjawab | Tidak boleh menjadi source of truth untuk |
|---|---|---|
| Authentication | Siapa principal yang authenticated? | Authority aplikasi secara langsung |
| Identity Resolution | Account/SH mana yang terkait? | Permission policy |
| Actor Classification | Actor ini termasuk kategori apa? | Identity mentah |
| Authority Resolution | Authority apa yang dimiliki? | UI state |
| Runtime Context | Siapa yang mengeksekusi proses? | SH identity |
| Permission Policy | Apa yang boleh dilakukan actor? | Identity resolution |
| Enforcement | Apakah operasi benar-benar diizinkan? | UI indication |

---

## 11. Frontend Boundary

Frontend tidak boleh menentukan actor berdasarkan tampilan atau asumsi lokal.

Contoh yang tidak diperbolehkan:

```text
OWNER pada UI → otomatis CREATOR
SH_ID tertentu → otomatis punya Core Authority
creator_ref terisi → otomatis Creator
runtime flag di client → SYSTEM_RUNTIME
```

Frontend harus mengikuti capability / authorization result yang diberikan oleh backend.

---

## 12. Permission Matrix Boundary

`permission_matrix.actor` adalah policy taxonomy.

Ia bukan registry identitas dan bukan mekanisme actor resolution.

Dengan demikian:

```text
Actor Resolution
        ↓
Actor yang terpercaya
        ↓
Permission Matrix
        ↓
Policy Decision
```

bukan:

```text
Permission Matrix
        ↓
Menebak siapa actor-nya
```

---

## 13. Security Principles

1. Actor tidak boleh ditentukan dari input client yang tidak dipercaya.
2. Account identity tidak boleh disamakan dengan SH identity.
3. Runtime context tidak boleh disamakan dengan SH identity.
4. Creator authority tidak otomatis memberikan private-data access.
5. SH-000 Core Governance Authority tidak otomatis memberikan private-data access.
6. Ownership tidak boleh diinferensikan dari UI.
7. `SYSTEM_RUNTIME` tidak boleh diturunkan dari `SH_ID`.
8. Actor yang tidak dapat di-resolve secara terpercaya harus fail closed.
9. Permission policy harus tetap terpisah dari identity resolution.
10. Enforcement harus tetap berjalan di backend.

---

## 14. Status Keputusan

### CANONICAL / VALIDATED

- Creator Authority ≠ Private Data Access.
- SH-000 Core Authority ≠ Private Data Access.
- Runtime ≠ SH Identity.
- Account_ID ≠ SH_ID.
- SH-000 adalah entitas konseptual Canonical yang berhubungan dengan Creator dan memiliki Core Governance Authority dalam boundary yang ditentukan.

### CURRENT IMPLEMENTATION EVIDENCE

- `CREATOR` dapat dikenali melalui active Creator authority assignment.
- `ACCOUNT_OWNER` digunakan sebagai fallback actor untuk account yang telah ter-resolve dan tidak memiliki active Creator assignment.
- Permission matrix saat ini memuat lima kategori actor.

### PROPOSED BY THIS ADDENDUM

- Pemisahan formal Identity Resolution → Actor Classification → Authority Resolution → Runtime Context → Permission Policy → Enforcement.
- `SH-000` memiliki actor classification yang dapat di-resolve dari Creator-associated SH identity setelah mapping teknis disetujui.
- `SYSTEM_RUNTIME` di-resolve dari trusted execution context, bukan SH identity.

### OPEN / UNRESOLVED

- Definisi final `ORDINARY_SH`.
- Apakah `ORDINARY_SH` merupakan runtime actor atau policy-only category.
- Technical source of truth untuk Creator-associated SH → `SH-000`.
- Technical source of truth untuk trusted `SYSTEM_RUNTIME` context.
- Apakah actor taxonomy lima kategori ini final untuk seluruh domain SH atau dapat diperluas melalui addendum berikutnya.

---

## 15. Implementasi

Addendum ini pada tahap draft **tidak mengubah database, permission matrix, actor resolver, frontend, atau runtime enforcement**.

Urutan implementasi setelah addendum disetujui:

```text
Actor Resolution Addendum Final
        ↓
Technical Resolver Design
        ↓
Backend Implementation
        ↓
Security Harness
        ↓
Frontend Capability Alignment
        ↓
APK E2E
        ↓
Verification Evidence
```

Tidak ada tahap berikutnya yang dianggap siap apabila prerequisite di atas belum selesai.

---

## 16. Authority & Change Control

Dokumen ini berada di folder `docs/canonical` karena dimaksudkan menjadi Canonical Addendum.

Namun, selama statusnya masih `Draft — Canonical Addendum in Development`, dokumen ini **belum boleh dianggap sebagai authority final untuk mengubah implementation atau Canonical semantics**.

Perubahan menuju status authoritative dilakukan setelah isi dan boundary actor disetujui secara eksplisit.

Setelah authoritative, dokumen ini menjadi authority tambahan untuk area actor resolution yang diaturnya tanpa menggantikan SH Core Canonical secara keseluruhan.

---

## 17. Prinsip Penutup

SECOND HEAD berkembang melalui penambahan semantic layer yang terdokumentasi, bukan melalui perubahan diam-diam terhadap foundation.

Jika actor taxonomy berkembang di masa depan, perubahan harus dilakukan melalui addendum atau amendment yang memiliki authority dan change control yang jelas.

Prinsip dasarnya:

```text
Jangan menebak siapa actor-nya.
Jangan mencampur identity dengan authority.
Jangan mencampur runtime dengan SH identity.
Jangan menganggap policy sebagai source of truth identity.

Resolve → Classify → Authorize → Evaluate → Enforce.
```
