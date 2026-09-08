# SECOND HEAD — ACTOR RESOLUTION & AUTHORITY CANONICAL ADDENDUM v1.0

**Project:** SECOND HEAD (SH)  
**Version:** SH v1.0  
**Status:** Canonical Addendum — Closed / Established Authority Boundary  
**Bahasa:** Indonesia  
**Scope:** Identity, Actor Classification, Authority Resolution, Runtime Context, Permission Policy, Enforcement  
**Parent Authority:** `docs/canonical/SECOND_HEAD_SH_CORE_CANONICAL_v1.0_BILINGUAL.md`

---

## 1. Tujuan

Addendum ini memperjelas siapa atau apa yang dimaksud dengan actor dalam SECOND HEAD dan bagaimana actor ditentukan dari identity atau execution context yang terpercaya.

Addendum ini memperjelas boundary yang menjadi dasar implementation dan verification. Ia tidak mengubah SH Core Canonical secara diam-diam.

Pipeline actor resolution:

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

Permission matrix bukan source of truth identity. Permission matrix hanya mengevaluasi policy setelah actor/context berhasil di-resolve.

---

## 2. Authority dan Boundary Fundamental

Addendum ini dibaca bersama SH Core Canonical dan dokumen authoritative lain yang lebih baru untuk area yang telah ditetapkan.

Boundary berikut tetap berlaku:

```text
1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH
Account_ID ≠ SH_ID
Runtime ≠ SH Identity
Model ≠ SH Identity
Creator Authority ≠ Private Data Access
SH-000 Core Authority ≠ Private Data Access
Runtime Access ≠ Ownership
System Governance ≠ Omniscient Data Access
```

Authority hierarchy untuk perubahan sistem tetap:

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
HISTORICAL / dev_old EVIDENCE
```

`dev_old` adalah historical evidence, bukan source of truth current state. Supabase DEV adalah source of truth untuk database dan migration state.

---

## 3. Model Identity, Ownership, Authority, dan SH Designation

Konsep-konsep berikut berada pada level semantik yang berbeda dan tidak boleh diperlakukan sebagai lima jenis identity yang setara.

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

Makna:

- `ACCOUNT` adalah identity/domain object.
- `ACCOUNT_ID` adalah identifier Account.
- `ACCOUNT_OWNER` adalah ownership role/context, bukan Account type baru.
- `CREATOR` adalah authority designation pada Account.
- `PRIMARY SH` adalah SH identity yang terkait dengan Account sesuai invariant Canonical.
- `SH_ID` adalah identifier SH.
- `SH-000` adalah designation konseptual untuk Creator's Primary SH yang memiliki Core Governance Authority sesuai boundary Canonical.
- `ORDINARY_SH` adalah designation/category untuk Primary SH milik Account yang tidak memiliki active Creator Authority.
- `SYSTEM_RUNTIME` adalah execution context yang terpisah dari Account dan SH identity.

Model di atas adalah semantic/contract boundary. Ia tidak dengan sendirinya menentukan schema atau detail implementasi teknis.

---

## 4. CREATOR

### 4.1 Makna

`CREATOR` adalah authority designation yang secara sah menetapkan Account sebagai Creator dalam boundary SH Canonical.

Creator tidak boleh ditentukan dari UI, `creator_ref`, ownership saja, atau input client yang tidak dipercaya.

### 4.2 Resolution

```text
Authenticated Identity
        ↓
ACCOUNT_ID
        ↓
Trusted Active Creator Authority Assignment
        ↓
CREATOR
```

Creator authority harus berasal dari authority assignment yang terpercaya dan aktif pada Account yang sudah ter-resolve.

### 4.3 Relasi dengan ACCOUNT_OWNER

```text
ACCOUNT
 ├── Ownership → ACCOUNT_OWNER
 └── Authority → CREATOR
```

Account dapat sekaligus menjadi owner dan Creator. Account Owner tanpa active Creator Authority tetap `ACCOUNT_OWNER`, tetapi bukan `CREATOR`.

### 4.4 Boundary

```text
CREATOR ≠ Private Data Access
```

Creator Authority tidak otomatis memberikan akses ke seluruh private data.

---

## 5. ACCOUNT_OWNER

`ACCOUNT_OWNER` adalah ownership context yang menunjukkan Account/Primary SH yang terkait dengan authenticated principal berdasarkan trusted identity dan ownership resolution.

Model:

```text
Authenticated Identity
        ↓
ACCOUNT_ID
        ↓
Ownership / Primary SH Resolution
        ↓
ACCOUNT_OWNER
```

Ownership tidak boleh disimpulkan hanya dari UI atau field client.

`ACCOUNT_OWNER` bukan sinonim `CREATOR` dan bukan pengganti `ACCOUNT` atau `SH_ID`.

---

## 6. PRIMARY SH, SH_ID, dan SH-000

### 6.1 Primary SH

Invariant Canonical:

```text
EMAIL
  ↓
ACCOUNT
  ↓
PRIMARY SH
```

Tidak boleh dibuat Account kedua atau Primary SH kedua hanya untuk merepresentasikan SH-000.

### 6.2 SH_ID

`SH_ID` adalah identifier dari SH identity.

```text
PRIMARY SH
    ↓
  SH_ID
```

`SH_ID` bukan authority source dan bukan pengganti Account identity.

### 6.3 SH-000

`SH-000` adalah designation konseptual untuk Creator's Primary SH yang memiliki special Core Governance Authority dalam boundary SH Canonical.

```text
ACCOUNT
 ├── Ownership → ACCOUNT_OWNER
 ├── Authority → CREATOR
 └── PRIMARY SH
        ├── SH_ID
        └── SH-000 designation
```

SH-000 bukan Account kedua, bukan Primary SH kedua, bukan pengganti Creator, bukan owner seluruh SH, dan bukan omniscient system identity.

### 6.4 Technical Boundary

Semantics SH-000 sudah ditetapkan; bentuk teknis untuk menyatakan atau me-resolve designation tersebut mengikuti backend contract dan trusted Supabase source of truth yang telah diverifikasi.

Implementasi tidak boleh menjadikan `creator_ref`, UI state, reserved string pada client, atau client-supplied actor sebagai source of truth authority.

Jika technical mapping baru diperlukan di masa depan, keputusan tersebut harus ditetapkan dalam Technical Resolver Design sebelum implementation mengunci mekanismenya.

---

## 7. ORDINARY_SH

`ORDINARY_SH` adalah designation/category untuk Primary SH milik Account biasa yang tidak memiliki active Creator Authority.

Working rule yang berlaku untuk build saat ini:

```text
Primary SH + active Creator Authority
        ↓
      SH-000

Primary SH + no active Creator Authority
        ↓
    ORDINARY_SH
```

`ORDINARY_SH` tidak memiliki Core Governance Authority untuk mengubah SH Core dalam boundary policy yang berlaku.

Permission taxonomy yang memuat `ORDINARY_SH` adalah policy evidence; taxonomy tersebut bukan source of truth identity.

Designation tidak boleh menjadi authority source yang berdiri sendiri. Authority tetap berasal dari trusted resolution dan policy.

---

## 8. SYSTEM_RUNTIME

`SYSTEM_RUNTIME` adalah actor/execution context yang merepresentasikan operasi yang benar-benar berasal dari trusted system runtime dan telah melewati trusted runtime boundary.

```text
Trusted System Execution Context
        ↓
SYSTEM_RUNTIME
```

`SYSTEM_RUNTIME` bukan:

- `SH_ID`;
- `ACCOUNT_OWNER`;
- `CREATOR`;
- pengganti authenticated user;
- client/UI flag.

Boundary:

```text
SYSTEM_RUNTIME ≠ SH_IDENTITY
SYSTEM_RUNTIME ≠ ACCOUNT_OWNER
SYSTEM_RUNTIME ≠ CREATOR
RUNTIME ACCESS ≠ OWNERSHIP
```

**Open implementation decision:** mekanisme teknis trusted runtime context yang menjadi source of truth masih harus ditetapkan. Ini adalah open technical boundary tersendiri dan bukan blocker terhadap semantic closure Actor Resolution.

---

## 9. Actor Resolution Pipeline

Target pipeline:

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

Menentukan authenticated principal.

### 9.2 Identity Resolution

Menentukan Account dan SH identity berdasarkan trusted backend resolution.

### 9.3 Actor Classification

Menentukan designation/category actor berdasarkan identity dan/atau trusted execution context.

### 9.4 Authority Resolution

Menentukan authority yang benar-benar dimiliki actor.

### 9.5 Runtime Context Resolution

Menentukan execution context dan apakah operasi berasal dari trusted system runtime.

### 9.6 Permission Policy

Permission policy mengevaluasi actor, target relation, scope, dan kondisi authorization yang relevan.

### 9.7 Enforcement

Backend/runtime enforcement menolak operasi yang tidak memenuhi policy.

---

## 10. Resolved Session / Actor Context

Hasil resolution harus tersedia sebagai context eksplisit agar consumer tidak menebak actor dari UI.

Model:

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

Contoh semantic, bukan final UI contract:

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

Frontend harus mengonsumsi resolved context/capability dari backend dan tidak melakukan actor inference lokal.

Istilah “login sebagai” harus digunakan hati-hati agar tidak menyamakan authentication identity, ownership, authority, SH designation, dan runtime context.

---

## 11. Source of Truth per Layer

| Layer | Menjawab | Bukan source of truth untuk |
|---|---|---|
| Authentication | Principal yang authenticated | Authority aplikasi secara langsung |
| Identity Resolution | Account/SH yang terkait | Permission policy |
| Actor Classification | Designation/category actor | Identity mentah |
| Authority Resolution | Authority yang dimiliki | UI state |
| Runtime Context | Execution context | SH identity |
| Permission Policy | Apa yang boleh dilakukan | Identity resolution |
| Enforcement | Apakah operasi diizinkan | UI indication |

Database/migration state tetap mengikuti Supabase DEV sebagai source of truth. File migration pada repository merepresentasikan artifact source yang harus konsisten dengan state tersebut; reconstruction history telah diselesaikan dan tidak dibuka ulang tanpa inconsistency aktual.

---

## 12. Frontend Boundary

Frontend tidak boleh menentukan actor berdasarkan tampilan atau asumsi lokal.

Tidak diperbolehkan:

```text
OWNER pada UI → otomatis CREATOR
SH_ID tertentu → otomatis Core Authority
creator_ref terisi → otomatis Creator
runtime flag di client → SYSTEM_RUNTIME
```

Frontend hanya merepresentasikan hasil trusted resolution dan authorization/capability yang diberikan backend.

---

## 13. Permission Matrix Boundary

`permission_matrix.actor` adalah policy taxonomy, bukan actor registry dan bukan actor resolver.

```text
Actor / Context Resolution
        ↓
Trusted Actor / Context
        ↓
Permission Matrix
        ↓
Policy Decision
        ↓
Enforcement
```

Bukan:

```text
Permission Matrix
        ↓
Menebak actor
```

---

## 14. Security Principles

1. Actor tidak boleh ditentukan dari input client yang tidak dipercaya.
2. Account identity tidak boleh disamakan dengan SH identity.
3. `SH_ID` tidak boleh menjadi source of authority.
4. Runtime context tidak boleh disamakan dengan SH identity.
5. Creator Authority tidak otomatis memberikan private-data access.
6. SH-000 Core Governance Authority tidak berarti omniscient data access.
7. `SYSTEM_RUNTIME` harus berasal dari trusted runtime boundary.
8. Frontend tidak boleh menjadi source of truth actor/authority.
9. Permission taxonomy tidak boleh dipakai untuk menemukan identity.
10. Backend enforcement harus konsisten dengan resolved actor/context dan policy.

---

## 15. Current Implementation / Verification Position

### 15.1 Actor Resolution Status

**STATUS: CLOSED / VERIFIED**

Scope Actor Resolution telah melalui inventory, contract ↔ implementation comparison, gap resolution, backend verification, contract verification, dan frontend representation.

Yang telah dibuktikan:

- `public.resolve_identity()` tetap menjadi resolver identity Account/Primary SH berdasarkan trusted authenticated identity.
- Creator Authority berasal dari trusted active authority assignment pada backend.
- `public.resolve_actor_context()` menyediakan resolved context eksplisit yang mencakup Account, SH, ownership, actor, authority, dan SH designation.
- `SH-000` dan `ORDINARY_SH` telah diverifikasi pada branch classification backend.
- `ShIdentity` / `ResolvedActorContext` pada Flutter mengonsumsi hasil backend, bukan melakukan actor inference.
- Actor context telah di-wire ke auth/session lifecycle.
- CI Flutter/analyze/test/build berhasil pada implementation yang mengaktifkan actor context lifecycle.
- User-visible Account surface telah menggunakan resolved actor/SH designation.

### 15.2 SYSTEM_RUNTIME Status

**STATUS: OPEN TECHNICAL DECISION**

Semantic boundary `SYSTEM_RUNTIME ≠ SH Identity` sudah established. Mekanisme teknis trusted runtime context tetap merupakan keputusan teknis tersendiri dan tidak boleh diarang.

### 15.3 Scope Closure

Dengan status di atas, pekerjaan Actor Resolution Canonical Addendum dianggap **closed** untuk scope yang telah ditetapkan.

Dokumen ini tidak menjadi living inventory untuk seluruh SH Core. Temuan lintas-domain selanjutnya harus dicatat pada working/living reconciliation document terpisah.

---

## 16. Change / Implementation Boundary

Addendum ini adalah authority boundary dan contract guidance. Ia tidak mengizinkan implementasi untuk:

- mengarang source of truth baru;
- membuat client actor flag;
- mengubah migration history hanya untuk menyesuaikan dokumen;
- menjadikan `creator_ref` sebagai authority source;
- menganggap `SH_ID` sebagai authority;
- menganggap `dev_old` sebagai current source of truth;
- menganggap actor resolution yang telah closed sebagai alasan untuk melewati blocker pada domain SH Core lain.

Urutan kerja lintas SH Core setelah Actor Resolution tidak ditentukan oleh dokumen ini. Domain berikutnya mengikuti Canonical, contract, dependency, dan hasil reconciliation masing-masing.

---

## 17. Non-Goals

Addendum ini tidak:

- mengubah invariant `1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH`;
- mengubah Account/SH identity model;
- memberikan private-data access baru kepada Creator atau SH-000;
- menjadikan SH-000 sebagai Account baru;
- menjadikan `SYSTEM_RUNTIME` sebagai SH identity;
- menetapkan technical mechanism `SYSTEM_RUNTIME` yang belum diputuskan;
- menggantikan permission policy dengan actor taxonomy;
- menjadi inventory atau reconciliation document untuk seluruh SH Core.

---

## 18. Final Working Rule

Untuk build SH saat ini, actor harus diperlakukan sebagai **hasil trusted resolution**, bukan label yang dikirim atau ditebak oleh client.

```text
Authenticated Identity
        ↓
Trusted Identity / Ownership Resolution
        ↓
Authority Resolution
        ↓
Actor / SH Designation
        ↓
Runtime Context
        ↓
Permission Policy
        ↓
Backend Enforcement
```

Semantics Actor Resolution sudah menjadi boundary kerja yang **established dan verified**. Detail technical boundary yang memang masih OPEN, khususnya trusted `SYSTEM_RUNTIME`, harus diputuskan melalui proses technical design tersendiri dan tidak boleh diinferensikan dari implementation saat ini.
