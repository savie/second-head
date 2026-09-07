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

Apakah designation ini disimpan secara eksplisit, diturunkan secara deterministic, atau menggunakan mekanisme lain harus ditetapkan dalam Technical Resolver Design setelah Addendum disetujui.

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

### 7.4 Agreed Working Rule

Untuk build saat ini telah disepakati sebagai working semantics:

```text
Primary SH + active Creator Authority
        ↓
      SH-000

Primary SH + no active Creator Authority
        ↓
    ORDINARY_SH
```

Dengan demikian, setiap Primary SH milik Account yang tidak memiliki active Creator Authority diklasifikasikan sebagai `ORDINARY_SH` dalam working model ini.

Hal yang masih terbuka hanya apakah pada masa depan SH memiliki kategori sah lain di luar dua designation tersebut; hal tersebut tidak boleh diasumsikan untuk implementation saat ini.

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

User-visible actor/status harus eksplisit sehingga user dapat mengetahui context yang sedang aktif.

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
6. Ownership tidak boleh di... 

---

# 15. 5D — MIGRATION DESIGN

## 15.1 Design Boundary

5D ini adalah **design only**. Tidak ada perubahan schema, function, grant, permission matrix, frontend, atau runtime enforcement yang diterapkan sebagai bagian dari section ini.

Migration hanya boleh dilakukan setelah design dikunci dan source migration dicatat di GitHub DEV. Urutan kerja yang berlaku:

```text
DESIGN LOCK
    ↓
Migration SQL recorded in GitHub DEV
    ↓
Apply to Supabase DEV
    ↓
Verify DB
    ↓
Verify GitHub ↔ Supabase
```

Migration source reconstruction untuk history lama tetap berada di luar scope.

## 15.2 Design Objective

Tujuan migration adalah menambahkan **trusted resolution boundary**, bukan membangun ulang governance subsystem.

Target:

```text
Authenticated Principal
        ↓
Unified Resolver
        ↓
Resolved Actor/Identity Context
        ↓
Governance / Runtime / Isolation Consumers
```

Existing foundations yang dipertahankan:

- `public.accounts`
- `public.sh_ownership`
- `private.authority_assignments`
- `public.sh_instances`
- `public.permission_matrix`
- `private.access_decision_gate`
- `private.governance_evaluator`
- `private.policy_enforcement_engine`
- `private.isolation_checker`
- `private.runtime_access_boundary`
- `private.system_governance_boundary`

Tidak ada alasan pada 5D untuk mengganti atau menghapus object-object tersebut hanya karena resolver belum unified.

## 15.3 Proposed Resolver Object

**Working design name:** `private.resolve_actor_identity_context()`.

Status: **PROPOSED — belum implementation contract final.**

Karakteristik yang diwajibkan:

- source caller identity dari `auth.uid()`;
- tidak menerima `account_id`, `sh_id`, actor, authority, designation, atau runtime actor sebagai caller-controlled identity input;
- resolve Account melalui trusted existing identity path;
- resolve ownership dari `sh_ownership`;
- resolve exactly one Primary SH;
- resolve active Creator Authority dari `authority_assignments`;
- derive `SH-000` apabila Account memiliki active Creator Authority dan Primary SH yang valid;
- derive `ORDINARY_SH` apabila Account tidak memiliki active Creator Authority dan Primary SH valid;
- tidak menggunakan `creator_ref` sebagai authority source;
- fail closed bila identity/ownership/Primary SH context tidak valid atau ambigu;
- tidak memberikan permission decision sendiri.

## 15.4 Proposed Context Shape

Working result contract:

```text
ResolvedActorIdentityContext
├── authenticated_principal
│   └── authenticated
├── account
│   └── account_id
├── ownership
│   └── role = ACCOUNT_OWNER
├── authority
│   └── creator = true / false
├── primary_sh
│   ├── sh_id
│   └── designation = SH-000 / ORDINARY_SH
└── runtime
    └── context = AUTHENTICATED_PRINCIPAL / SYSTEM_RUNTIME
```

Catatan: bentuk SQL return type final (TABLE vs composite type vs JSON contract) belum dikunci dalam 5D ini. Pemilihan bentuk harus mempertimbangkan konsumsi internal function dan frontend contract tanpa mengubah semantics di atas.

## 15.5 Function Dependency Changes

### A. `governance_evaluator`

**Target:** consume unified resolved context.

Current identity/actor resolution:

```text
current_account_id()
      ↓
Creator assignment?
      ├── yes → CREATOR
      └── no  → ACCOUNT_OWNER
```

Target:

```text
resolve_actor_identity_context()
      ↓
account + ownership + authority + SH designation
      ↓
policy selection
```

`p_actor_account_id` tetap hanya dapat dipakai sebagai consistency assertion terhadap trusted resolved Account, bukan sebagai source of authority.

### B. `policy_enforcement_engine`

Tidak menjadi resolver kedua.

Target dependency:

```text
resolved context / governance result
        ↓
policy enforcement
```

Apakah function signature perlu diubah atau cukup memusatkan resolution di `governance_evaluator` harus diputuskan setelah implementation-level dependency inspection. Jangan mengubah signature secara prematur.

### C. `isolation_checker`

Tetap bertanggung jawab atas target isolation.

Targetnya dapat menggunakan trusted Account context yang sama, tetapi tidak mengambil alih authority classification.

### D. `runtime_access_boundary`

Tetap merupakan runtime boundary terpisah.

Tidak boleh sekadar mengubah authenticated Account menjadi `SYSTEM_RUNTIME`.

Ia membutuhkan trusted runtime-context source yang berbeda dari user identity.

### E. `system_governance_boundary`

Tetap menggunakan `access_decision_gate` sebagai downstream governance gate.

Tidak perlu diganti menjadi direct permission-matrix lookup.

## 15.6 SYSTEM_RUNTIME Migration Boundary

`SYSTEM_RUNTIME` tidak boleh diaktifkan hanya karena policy row sudah ada.

Sebelum migration implementation, harus ada desain eksplisit mengenai:

```text
Trusted System Execution Context
        ↓
Proof / source of trust
        ↓
SYSTEM_RUNTIME
```

Sumber tersebut harus tidak dapat dipalsukan oleh authenticated client biasa.

Jika source of trust belum tersedia, migration **tidak boleh** membuat user request dapat memilih `SYSTEM_RUNTIME` melalui parameter.

Karena itu, 5D hanya mendefinisikan integration point; implementasi runtime resolver menjadi prerequisite tersendiri.

## 15.7 Permission Matrix Strategy

Tidak ada migration untuk mengganti taxonomy actor pada 5D.

Existing policy taxonomy dipertahankan:

```text
CREATOR
ACCOUNT_OWNER
SH-000
ORDINARY_SH
SYSTEM_RUNTIME
```

Yang diubah nanti adalah **jalur masuk actor terpercaya ke policy**, bukan arti rule secara diam-diam.

Special attention:

- `CREATOR` adalah Account authority dimension.
- `SH-000` adalah Primary SH designation.
- `ORDINARY_SH` adalah Primary SH designation.
- `SYSTEM_RUNTIME` adalah execution context.

## 15.8 Migration Sequence

Jika design ini disetujui, migration implementation sebaiknya dipecah agar mudah diverifikasi:

```text
M1 — Unified Actor Resolver
        ↓
M2 — Governance Integration
        ↓
M3 — Runtime Context Integration
        ↓
M4 — Downstream Consumer Alignment
        ↓
Verification
```

Tidak disarankan membuat satu migration besar yang sekaligus mengubah seluruh governance/runtime chain.

### M1 — Unified Actor Resolver

Deliver:

- trusted resolver function;
- deterministic SH designation;
- fail-closed validation;
- explicit result contract;
- controlled EXECUTE surface.

Verification:

- Creator account resolves `ACCOUNT_OWNER + CREATOR + SH-000`;
- non-Creator account resolves `ACCOUNT_OWNER + non-Creator + ORDINARY_SH`;
- no caller-supplied identity can override result;
- invalid/missing primary context rejects/fails closed.

### M2 — Governance Integration

Deliver:

- governance evaluator consumes resolver;
- existing policy matrix remains policy source;
- target relation remains separately evaluated;
- Creator governance still requires governance process where matrix requires it;
- SH-000 Core authority remains distinct from private-data access.

Verification:

- Creator/SH-000 governance path reaches correct policy subject;
- ordinary SH governance is denied;
- cross-SH private access remains isolated.

### M3 — Runtime Context Integration

Deliver only after trusted runtime source is specified.

Verification:

- ordinary authenticated request cannot self-identify as `SYSTEM_RUNTIME`;
- trusted system execution can resolve `SYSTEM_RUNTIME`;
- runtime execution does not grant ownership.

### M4 — Downstream Consumer Alignment

Review and align:

- `access_decision_gate`;
- `policy_enforcement_engine`;
- `isolation_checker`;
- `runtime_access_boundary`;
- `system_governance_boundary`.

No object is removed merely for duplication unless verification demonstrates that the new resolver makes the old path redundant and removal is safe.

## 15.9 Grants / Security Boundary

Resolver implementation must be treated as privileged identity infrastructure.

Design requirements:

- keep privileged resolver in `private` schema;
- no direct public/anonymous execution;
- authenticated execution only where a consumer requires it;
- explicit `auth.uid()` boundary inside the resolver;
- fixed `search_path` for SECURITY DEFINER implementation if SECURITY DEFINER remains necessary;
- no client-controlled actor/authority parameters;
- review EXECUTE grants after migration;
- verify no unintended `anon` execution path is introduced.

Exact GRANT/REVOKE SQL remains an implementation artifact of 5E after final signature is locked.

## 15.10 Migration Verification Matrix

| Test | Expected |
|---|---|
| Unauthenticated resolver | fail closed |
| Creator authenticated resolver | Owner + Creator + Primary SH + SH-000 |
| Ordinary account resolver | Owner + non-Creator + Primary SH + ORDINARY_SH |
| Caller supplies another Account_ID | ignored/rejected; trusted Account remains caller identity |
| Caller supplies another SH_ID | cannot change resolved Primary SH |
| `creator_ref` changed/filled | no effect on Creator resolution |
| Creator private OTHER read | denied unless separately authorized by valid scoped policy |
| Ordinary SH GOVERN SYSTEM_CORE | denied |
| SH-000 GOVERN SYSTEM_CORE | reaches governance-process boundary, not automatic unrestricted allow |
| Runtime client claims SYSTEM_RUNTIME | denied |
| Cross-SH private isolation | denied |

## 15.11 Migration Safety Rules

1. Do not create a second Account or Primary SH for SH-000.
2. Do not add a `creator_ref`-based authority path.
3. Do not make `SH_ID` itself an authority source.
4. Do not expose actor-selection parameters to clients.
5. Do not silently rewrite Canonical semantics.
6. Do not weaken existing private-data isolation while wiring governance actors.
7. Do not activate `SYSTEM_RUNTIME` without a trusted execution proof.
8. Do not apply migration before its SQL source is durably recorded in GitHub DEV.
9. Verify Supabase after every migration step.
10. If verification fails, stop and reconcile before proceeding to the next migration.

## 15.12 5D Exit Criteria

5D is considered design-complete only when the following are explicitly locked:

- resolver object/signature;
- exact SQL result contract;
- deterministic SH designation rules;
- governance integration point;
- runtime trust source;
- EXECUTE/grant boundary;
- migration split/order;
- verification matrix;
- rollback/recovery strategy appropriate to each migration step.

Until these are locked, **5E Implement + Verify must not start**.

---

## 16. Status Classification

### CANONICAL / VALIDATED

- `1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH`
- `Account_ID ≠ SH_ID`
- Creator Authority ≠ Private Data Access
- SH-000 Core Authority ≠ Private Data Access
- Runtime Access ≠ Ownership
- SH-000 is Creator's SH / Creator's Primary SH concept

### CURRENT IMPLEMENTATION EVIDENCE

- Creator authority is represented by active `private.authority_assignments`.
- Account ownership is represented by `public.sh_ownership`.
- Primary SH is represented by `public.sh_instances.is_primary`.
- Current governance evaluator resolves `CREATOR` or `ACCOUNT_OWNER` only.
- `permission_matrix` contains five policy taxonomy values.
- Current runtime boundary does not resolve `SYSTEM_RUNTIME` as an actor.

### AGREED WORKING SEMANTICS

- Every non-Creator Primary SH is classified as `ORDINARY_SH` for the current build.
- SH-000 is derived deterministically from active Creator Authority + the Account's Primary SH.
- These are working build semantics and do not silently rewrite the parent Canonical.

### PROPOSED / DESIGN ONLY

- Unified `private.resolve_actor_identity_context()` resolver.
- Unified context consumption across governance/runtime consumers.
- Migration split M1–M4.
- Exact SQL return shape and final runtime trust mechanism.

### OPEN / UNRESOLVED

- Exact resolver SQL return type/signature.
- Trusted `SYSTEM_RUNTIME` proof/source.
- Whether future SH categories beyond `SH-000` and `ORDINARY_SH` will exist.
- Final frontend representation contract.
- Security harness implementation.

---

## 17. Implementation Boundary

Addendum ini pada tahap draft tidak mengubah database, permission matrix, actor resolver, frontend, atau runtime enforcement.

Setelah Addendum dan 5D design dikunci, implementation sequence adalah:

```text
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
Verification
```

Clone integration tetap berada setelah seluruh identity/authority/enforcement path tervalidasi.
