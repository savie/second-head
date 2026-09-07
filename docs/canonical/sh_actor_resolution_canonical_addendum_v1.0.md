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

- `1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH`
- `Account_ID ≠ SH_ID`
- `Runtime ≠ SH Identity`
- `Model ≠ SH Identity`
- `Creator Authority ≠ Private Data Access`
- `SH-000 Core Authority ≠ Private Data Access`
- `Runtime Access ≠ Ownership`
- `System Governance ≠ Omniscient Data Access`

Addendum ini tidak mengubah prinsip-prinsip tersebut.

---

## 3. Model Identity, Ownership, Authority, dan SH Designation

Actor taxonomy tidak boleh dibaca sebagai lima jenis identity yang setara. Konsep-konsep tersebut berada pada level semantik yang berbeda.

Model konseptual kerja saat ini:

```text
                         EMAIL
                           │
                           ▼
                        ACCOUNT
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
         ACCOUNT_ID   OWNERSHIP     AUTHORITY
                           │            │
                           ▼            ▼
                    ACCOUNT_OWNER     CREATOR
                           │            │
                           └─────┬──────┘
                                 │
                                 ▼
                            PRIMARY SH
                                 │
                         ┌───────┴────────┐
                         │                │
                       SH_ID       SH DESIGNATION
                                          │
                                  ┌───────┴───────┐
                                  │               │
                               SH-000        ORDINARY_SH


                 SYSTEM_RUNTIME
                       │
                       ▼
                EXECUTION CONTEXT
```

Boundary identity yang tidak boleh berubah:

```text
1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH
ACCOUNT_ID ≠ SH_ID
```

Interpretasi model:

- `ACCOUNT` adalah identity/domain object.
- `ACCOUNT_ID` adalah identifier dari Account.
- `ACCOUNT_OWNER` adalah ownership role/context, bukan jenis Account yang berbeda.
- `CREATOR` adalah authority designation pada Account, bukan pengganti Account dan bukan SH identity.
- `PRIMARY SH` adalah SH identity yang terkait dengan Account dalam invariant Canonical.
- `SH_ID` adalah identifier dari SH.
- `SH-000` adalah designation konseptual untuk Creator's Primary SH; ia tidak diperlakukan sebagai Account kedua atau Primary SH kedua.
- `ORDINARY_SH` adalah designation/category pada SH biasa milik user biasa; boundary governance-nya dijelaskan lebih lanjut di Section 7.
- `SYSTEM_RUNTIME` berada pada jalur execution context yang terpisah dari Account dan SH identity.

Model ini adalah **working conceptual model** dalam Addendum draft dan belum dengan sendirinya menjadi perubahan schema atau implementation contract.

---

## 4. CREATOR

### 4.1 Makna

`CREATOR` adalah authority designation yang secara sah menetapkan Account sebagai Creator dalam boundary SH Core Canonical.

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

### 4.3 Relasi dengan ACCOUNT_OWNER

`CREATOR` dan `ACCOUNT_OWNER` bukan dua jenis Account yang saling menggantikan.

Keduanya dapat berada pada Account yang sama tetapi berasal dari dimensi berbeda:

```text
ACCOUNT
 ├── Ownership → ACCOUNT_OWNER
 └── Authority → CREATOR
```

Dengan demikian, Creator Account dapat sekaligus merupakan Account Owner dan Creator. Account Owner yang tidak memiliki active Creator Authority tetap merupakan Account Owner tetapi bukan Creator.

### 4.4 Boundary

Menjadi `CREATOR` tidak berarti otomatis memiliki akses ke seluruh private data.

Creator Authority tetap terpisah dari Private Data Access.

---

## 5. ACCOUNT_OWNER

### 5.1 Makna

`ACCOUNT_OWNER` adalah ownership role/context yang menunjukkan Account/SH yang sedang menjadi milik authenticated principal berdasarkan identity dan ownership resolution yang terpercaya.

`ACCOUNT_OWNER` bukan tipe identity yang menggantikan `ACCOUNT`, dan bukan sinonim `CREATOR`.

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

### 5.3 Relasi dengan CREATOR

Account dapat memiliki kedua dimensi sekaligus:

```text
ACCOUNT
 ├── Ownership → ACCOUNT_OWNER
 └── Authority → CREATOR
```

atau hanya ownership:

```text
ACCOUNT
 └── Ownership → ACCOUNT_OWNER
```

Apakah suatu Account juga Creator harus ditentukan oleh trusted Creator Authority Assignment.

### 5.4 Boundary

Ownership tidak boleh disimpulkan hanya dari UI atau field yang dikirim client.

Account ownership dan SH identity tetap merupakan konsep yang berbeda walaupun keduanya digunakan dalam satu application flow.

---

## 6. PRIMARY SH, SH_ID, dan SH-000

### 6.1 Primary SH

Canonical identity boundary:

```text
EMAIL
  ↓
ACCOUNT
  ↓
PRIMARY SH
```

Tidak boleh dibuat Account kedua atau Primary SH kedua hanya untuk merepresentasikan SH-000.

### 6.2 SH_ID

`SH_ID` adalah identifier dari Primary SH/SH identity.

```text
PRIMARY SH
    ↓
  SH_ID
```

`SH_ID` bukan authority source dan bukan pengganti Account identity.

### 6.3 SH-000 — Makna Canonical

`SH-000` adalah designation konseptual untuk **Creator's SH / Creator's Primary SH** yang memiliki special Core Governance Authority dalam boundary yang ditentukan SH Core Canonical.

SH-000 bukan Account kedua, bukan Primary SH kedua, bukan pengganti `CREATOR`, dan bukan pemilik seluruh SH instance.

Secara konseptual:

```text
ACCOUNT
 ├── Ownership → ACCOUNT_OWNER
 ├── Authority → CREATOR
 │
 └── PRIMARY SH
        │
        ├── SH_ID
        └── SH-000 designation
```

Untuk Account Owner biasa:

```text
ACCOUNT
 ├── Ownership → ACCOUNT_OWNER
 │
 └── PRIMARY SH
        │
        ├── SH_ID
        └── ORDINARY_SH designation
```

### 6.4 Source of Truth dan Technical Mapping

Makna konseptual SH-000 berasal dari relationship yang sudah dipercaya antara Account, Creator Authority, dan Creator's Primary SH. Namun, bentuk teknis final untuk menyatakan atau me-resolve designation `SH-000` belum menjadi keputusan implementasi final.

Implementasi tidak boleh menggunakan `creator_ref`, UI state, atau reserved string pada client sebagai source of truth authority.

Apakah designation ini disimpan secara eksplisit, diturunkan secara deterministic dari trusted relationships, atau menggunakan mekanisme lain harus ditetapkan dalam Technical Resolver Design setelah Addendum disetujui.

### 6.5 Boundary

```text
SH-000 Core Authority ≠ Private Data Access
SH-000 ≠ All SH Owners
SH-000 ≠ Omniscient System Access
SH-000 ≠ Account_ID
SH-000 ≠ SH_ID
```

---

## 7. ORDINARY_SH

### 7.1 Makna Konseptual

`ORDINARY_SH` adalah SH instance milik user biasa (bukan Creator), yang secara konseptual dikontraskan dengan `SH-000` dan `CREATOR`.

Ordinary SH tidak memiliki authority untuk mengubah SH Core. Boundary ini tidak berarti bahwa Ordinary SH tidak memiliki seluruh permission pada private domain miliknya; governance authority terhadap Core dan private-data access adalah concern yang berbeda.

### 7.2 Policy Evidence

Permission taxonomy DEV/DEV_old secara eksplisit memuat `ORDINARY_SH` dan memberikan `DENY` untuk operasi `GOVERN` terhadap `SYSTEM_CORE`.

Dengan demikian, `ORDINARY_SH` dapat diperlakukan sebagai SH-level designation/category dalam working model ini, dengan boundary governance yang jelas.

### 7.3 Classification Boundary

Untuk working model ini:

```text
PRIMARY SH
    ↓
SH DESIGNATION
    ├── SH-000
    └── ORDINARY_SH
```

Namun, implementasi final tetap harus memastikan bahwa designation tidak menjadi source of authority yang berdiri sendiri. Authority dan permission tetap harus berasal dari trusted identity/authority resolution dan policy.

### 7.4 Open Decision

Hal-hal berikut masih perlu dikunci sebelum resolver final:

1. Apakah setiap Primary SH milik Account tanpa Creator Authority selalu `ORDINARY_SH`?
2. Apakah ada kategori SH lain yang secara sah bukan `SH-000` tetapi juga bukan `ORDINARY_SH`?
3. Apakah `ORDINARY_SH` perlu diekspos sebagai actor dalam resolved session context atau cukup sebagai policy classification?

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

Menentukan kategori atau designation actor berdasarkan identity dan/atau execution context yang telah dipercaya.

### 9.4 Authority Resolution

Menentukan authority yang benar-benar dimiliki actor.

### 9.5 Runtime Context Resolution

Menentukan apakah operasi berasal dari authenticated principal biasa atau trusted system runtime.

### 9.6 Permission Policy

Permission matrix mengevaluasi policy berdasarkan actor, target relation, scope, dan kondisi authorization yang relevan.

### 9.7 Enforcement

Access boundary dan runtime enforcement menolak operasi yang tidak memenuhi policy.

---

## 10. Resolved Session / Actor Context

Actor resolution tidak hanya dibutuhkan untuk enforcement. Sistem juga perlu memiliki hasil resolution yang eksplisit agar frontend dan user dapat mengetahui context yang sedang aktif tanpa menebak dari UI.

Model konseptual:

```text
Authenticated Identity
        ↓
ACCOUNT
        ↓
Ownership + Authority
        ↓
PRIMARY SH + SH Designation
        ↓
Resolved Session / Actor Context
        ↓
User-visible Identity / Capability Status
```

Contoh konseptual, bukan final UI contract:

```text
Account: Owner
Authority: Creator
Primary SH: SH-000
```

atau:

```text
Account: Owner
Authority: —
Primary SH: ORDINARY_SH
```

Informasi tersebut harus berasal dari backend-resolved context, bukan hasil inferensi frontend.

Istilah “login sebagai” perlu dipakai hati-hati agar tidak menyamakan authentication identity, ownership, authority, SH designation, dan runtime context.

---

## 11. Pemisahan Source of Truth

Setiap layer memiliki tanggung jawab berbeda.

| Layer | Menjawab | Tidak boleh menjadi source of truth untuk |
|---|---|---|
| Authentication | Siapa principal yang authenticated? | Authority aplikasi secara langsung |
| Identity Resolution | Account/SH mana yang terkait? | Permission policy |
| Actor Classification | Actor/designation ini termasuk kategori apa? | Identity mentah |
| Authority Resolution | Authority apa yang dimiliki? | UI state |
| Runtime Context | Siapa yang mengeksekusi proses? | SH identity |
| Permission Policy | Apa yang boleh dilakukan actor? | Identity resolution |
| Enforcement | Apakah operasi benar-benar diizinkan? | UI indication |

---

## 12. Frontend Boundary

Frontend tidak boleh menentukan actor berdasarkan tampilan atau asumsi lokal.

Contoh yang tidak diperbolehkan:

```text
OWNER pada UI → otomatis CREATOR
SH_ID tertentu → otomatis punya Core Authority
creator_ref terisi → otomatis Creator
runtime flag di client → SYSTEM_RUNTIME
```

Frontend harus mengikuti resolved identity/actor context dan capability / authorization result yang diberikan oleh backend.

User-visible actor/status harus eksplisit sehingga user dapat mengetahui context yang sedang aktif tanpa perlu menebak.

---

## 13. Permission Matrix Boundary

`permission_matrix.actor` adalah policy taxonomy.

Ia bukan registry identitas dan bukan mekanisme actor resolution.

Dengan demikian:

```text
Actor / Context Resolution
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

## 14. Security Principles

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
11. User-visible actor/status harus berasal dari backend-resolved context, bukan inferensi frontend.

---

## 15. Status Keputusan

### CANONICAL / VALIDATED

- `1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH`.
- `Creator Authority ≠ Private Data Access`.
- `SH-000 Core Authority ≠ Private Data Access`.
- `Runtime ≠ SH Identity`.
- `Account_ID ≠ SH_ID`.
- SH-000 adalah konsep Canonical yang berhubungan dengan Creator's SH dan memiliki special Core Governance Authority dalam boundary yang ditentukan.
- Ordinary SH tidak memiliki authority untuk mengubah SH Core, sesuai definisi konseptual dan policy evidence yang telah diaudit.

### CURRENT IMPLEMENTATION EVIDENCE

- `CREATOR` dapat dikenali melalui active Creator authority assignment.
- `ACCOUNT_OWNER` digunakan sebagai fallback actor untuk account yang telah ter-resolve dan tidak memiliki active Creator assignment.
- Permission matrix saat ini memuat lima kategori actor.
- `ORDINARY_SH` memiliki explicit policy `DENY` untuk `GOVERN` terhadap `SYSTEM_CORE`.

### PROPOSED / WORKING MODEL

- Actor taxonomy tidak diperlakukan sebagai lima identity type yang setara.
- `ACCOUNT_OWNER` diposisikan sebagai ownership role/context pada Account.
- `CREATOR` diposisikan sebagai authority designation pada Account.
- `SH-000` diposisikan sebagai designation konseptual pada Creator's Primary SH, bukan Account kedua atau Primary SH kedua.
- `ORDINARY_SH` diposisikan sebagai SH-level designation/category untuk SH biasa, dengan governance boundary yang sudah terbukti.
- `SYSTEM_RUNTIME` diposisikan sebagai execution context terpisah.
- Resolved Session / Actor Context perlu diekspos secara eksplisit ke frontend agar user dapat mengetahui identity/authority/SH context yang aktif.

### OPEN / UNRESOLVED

- Technical source of truth dan mekanisme final untuk Creator's Primary SH → `SH-000` designation.
- Apakah `SH-000` designation disimpan atau diturunkan secara deterministic.
- Apakah setiap non-Creator Primary SH otomatis `ORDINARY_SH`.
- Apakah ada SH category lain di masa depan yang bukan `SH-000` maupun `ORDINARY_SH`.
- Apakah `ORDINARY_SH` perlu menjadi runtime actor atau cukup policy classification.
- Technical source of truth untuk trusted `SYSTEM_RUNTIME` context.
- Final contract untuk user-visible Resolved Session / Actor Context.
- Apakah actor taxonomy lima kategori ini final untuk seluruh domain SH atau dapat diperluas melalui addendum berikutnya.

---

## 16. Implementasi

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
Frontend Capability / Identity Alignment
        ↓
APK E2E
        ↓
Verification Evidence
```

Tidak ada tahap berikutnya yang dianggap siap apabila prerequisite di atas belum selesai.

---

## 17. Authority & Change Control

Dokumen ini berada di folder `docs/canonical` karena dimaksudkan menjadi Canonical Addendum.

Namun, selama statusnya masih `Draft — Canonical Addendum in Development`, dokumen ini **belum boleh dianggap sebagai authority final untuk mengubah implementation atau Canonical semantics**.

Perubahan menuju status authoritative dilakukan setelah isi dan boundary actor disetujui secara eksplisit.

Setelah authoritative, dokumen ini menjadi authority tambahan untuk area actor resolution yang diaturnya tanpa menggantikan SH Core Canonical secara keseluruhan.

---

## 18. Prinsip Penutup

SECOND HEAD berkembang melalui penambahan semantic layer yang terdokumentasi, bukan melalui perubahan diam-diam terhadap foundation.

Jika actor taxonomy berkembang di masa depan, perubahan harus dilakukan melalui addendum atau amendment yang memiliki authority dan change control yang jelas.

Prinsip dasarnya:

```text
Jangan menebak siapa actor-nya.
Jangan mencampur identity dengan authority.
Jangan mencampur runtime dengan SH identity.
Jangan menganggap policy sebagai source of truth identity.
Jangan membuat identity kedua hanya untuk merepresentasikan SH-000.

Resolve → Classify → Authorize → Evaluate → Enforce.
```
