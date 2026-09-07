# SECOND HEAD — SH State Persistence Contract

## Status

**Approved working contract untuk semantic State, persistence, recovery, migration, dan runtime access SH State.**

Dokumen ini merupakan hasil keputusan kerja D8 → D1 dan RPC Contract. Dokumen ini **bukan Canonical** dan tidak mengubah Canonical.

Jika terdapat konflik dengan Canonical atau authority yang lebih tinggi, Canonical dan authority yang lebih tinggi tetap berlaku.

`dev_old` digunakan sebagai reference/evidence. Historical implementation tidak menjadi baseline implementation baru.

---

## 1. Tujuan dan Boundary

Contract ini mendefinisikan boundary SH State sebagai persistent operational state dari satu SH Instance, termasuk:

- semantic boundary;
- representation;
- versioning;
- revision dan concurrency;
- mutation;
- recovery;
- migration;
- physical persistence boundary;
- runtime/RPC access.

Contract ini tidak mendefinisikan ulang Identity, Ownership, Lifecycle, Memory, Knowledge, Experience, Conversation, Journey, Audit, atau Recovery sebagai State.

---

## 2. Authority dan Prinsip Kerja

Urutan authority tetap:

```text
Canonical
   ↓
Approved Contract
   ↓
Architecture / Design
   ↓
Implementation
```

Prinsip utama:

1. SH State bukan Canonical Identity.
2. SH State tidak menggantikan domain semantic lain.
3. State harus persistent dan authoritative.
4. State harus scoped terhadap satu SH Instance.
5. State harus dapat dipulihkan dan dimigrasikan tanpa membuat SH Identity baru.
6. Mutation tidak dilakukan langsung dari UI ke database.
7. Revision ditentukan oleh authoritative persistence/runtime layer, bukan caller.
8. Tidak boleh ada false success sebelum authoritative persistence berhasil.

---

## 3. D8 — State Semantic Boundary

### 3.1 Definisi

**Valid SH State** adalah *persistent operational condition* dari satu SH Instance yang diperlukan agar SH dapat melanjutkan operasi secara konsisten setelah runtime/session interruption, migration, atau recovery, tanpa kehilangan atau membuat ulang SH Identity.

### 3.2 Yang termasuk State

Hanya kondisi operasional persistent yang diperlukan untuk **resume / continue SH secara konsisten**.

### 3.3 Yang bukan State

| Domain | Boundary |
|---|---|
| SH Identity / SH_ID | Separate |
| Ownership | Separate |
| Lifecycle / status | Separate |
| Session | Separate |
| UI / frontend state | Separate |
| Runtime ephemeral state | Separate |
| Context | Separate |
| Memory | Separate |
| Knowledge | Separate |
| Experience | Separate |
| Conversation | Separate |
| Journey | Separate |
| Audit | Separate |
| Recovery | Separate |
| Personality / Directives | Separate |
| Preferences | Separate, kecuali ada keputusan eksplisit di kemudian hari |
| Capabilities / Tools / Actions | Separate |

State tidak boleh menjadi god-object yang menampung domain-domain tersebut.

---

## 4. D2 — State Representation

SH State direpresentasikan sebagai **explicit versioned State envelope/document** yang scoped terhadap tepat satu SH Instance.

Logical representation:

```text
SH_STATE
│
├── sh_id
├── state_version
├── revision
├── state_payload
├── created_at
└── updated_at
```

`state_payload` adalah structured State document dan bukan arbitrary metadata.

State menggunakan model **current valid State**, bukan event sourcing sebagai representation utama.

History perubahan, jika diperlukan, merupakan concern terpisah.

### 4.1 Boundary dengan `sh_instances.metadata`

`sh_instances.metadata` **bukan authoritative SH State**.

Metadata tidak boleh digunakan sebagai alasan untuk memasukkan Identity, Preferences, Personality, Context, Runtime, atau domain lain ke dalam State secara implisit.

---

## 5. D3 — State Version Model

State memiliki dua konsep versioning yang berbeda:

### 5.1 `state_version`

Menunjukkan **representation/schema version** dari State document.

```text
state_version = 1
```

menunjukkan representation versi 1.

Perubahan isi State tidak otomatis menaikkan `state_version`.

### 5.2 `revision`

Menunjukkan **mutation sequence** dari current State.

Contoh:

```text
state_version = 1
revision      = 17
```

berarti representation State masih versi 1 dan current State berada pada revision 17.

### 5.3 Separation

```text
state_version ≠ revision
state_version ≠ sh_instances.version
state_version ≠ knowledge.version
state_version ≠ recovery package version
```

Baseline State pertama yang valid menggunakan:

```text
state_version = 1
revision      = 1
```

Nilai tersebut adalah working baseline, bukan perubahan Canonical.

---

## 6. D4 — Revision / Concurrency

SH State menggunakan **optimistic concurrency control** berbasis `revision`.

Setiap mutation harus membawa:

```text
expected_revision
```

Logical flow:

```text
READ
  ↓
current revision = N
  ↓
MUTATE
  ↓
expected revision = N
  ↓
atomic conditional update
  │
  ├── revision masih N → SUCCESS → N+1
  └── revision ≠ N     → REVISION_CONFLICT
```

### 6.1 Stale writer

Writer yang membawa revision stale harus ditolak.

Tidak boleh:

- silent overwrite;
- force overwrite;
- silent merge;
- menaikkan revision dari caller;
- melaporkan success.

Setelah conflict, caller dapat membaca State terbaru dan membuat mutation baru berdasarkan revision terbaru.

### 6.2 Authority

Revision baru ditentukan oleh authoritative runtime/persistence layer.

Caller hanya menentukan `expected_revision`.

---

## 7. D5 — State Mutation

State hanya dapat diubah melalui **authorized runtime/state mutation path**.

Logical boundary:

```text
UI / Frontend
      ↓
State Service / Runtime
      ↓
Authorized State Mutation
      ↓
Persistent SH State
```

Mutation harus:

1. SH-scoped;
2. authenticated;
3. authorized terhadap SH;
4. explicit;
5. tervalidasi terhadap State representation;
6. menggunakan `expected_revision`;
7. atomic;
8. menghasilkan revision baru setelah berhasil.

Mutation tidak boleh digunakan untuk mengubah Memory, Knowledge, Experience, Conversation, Journey, atau domain lain melalui State payload.

### 7.1 Mutation model

Secara logical:

```text
mutation
├── operation
└── payload
```

Operation harus explicit dan targeted.

Contract ini tidak mengunci daftar operation teknis tertentu apabila belum ada evidence kebutuhan.

Blind full-document overwrite bukan mutation model yang ditargetkan.

### 7.2 Validation

Validasi mencakup:

```text
Semantic boundary
      ↓
Representation validity
      ↓
Revision validity
      ↓
Authorization
      ↓
Persistence
```

Tidak ada success sebelum authoritative persistence berhasil.

---

## 8. D6 — State Recovery

Recovery harus memulihkan valid SH State untuk **SH_ID yang sama**.

```text
Recovery
   ↓
restore valid State
   ↓
same SH_ID
```

Recovery tidak membuat SH baru.

### 8.1 Recovery Snapshot ≠ State

`recovery_snapshots.manifest` adalah **recovery container/package**, bukan State representation.

Recovery snapshot dapat membawa State bersama domain recovery lain, tetapi State tetap memiliki representation dan persistence boundary sendiri.

### 8.2 State validation

State dari snapshot harus:

1. memiliki representation yang dikenali;
2. valid terhadap `state_version`;
3. dapat dipulihkan ke SH yang sama;
4. tidak menghasilkan State partial/invalid.

Jika snapshot menggunakan representation lama dan masih didukung, representation harus dimigrasikan/ditransformasikan terlebih dahulu sebelum restore.

### 8.3 Revision

Recovery tidak boleh menghasilkan **silent revision rollback**.

Jika snapshot memiliki revision lama, restore harus menghasilkan current authoritative State dengan revision yang valid terhadap concurrency model.

Recovery tidak boleh menyebabkan revision collision.

### 8.4 Continuity

Recovery failure atau unresolved continuity gap harus dinyatakan secara eksplisit.

Recovery event/history tidak disimpan di `state_payload`; gunakan recovery/audit/Journey boundary yang sesuai.

---

## 9. D7 — State Migration

State Migration adalah proses terkontrol untuk mentransformasikan valid SH State dari satu representation version ke representation version lain, atau memindahkan persistent State ke runtime/infrastructure baru tanpa mengubah SH_ID.

### 9.1 Dua jenis migration

#### Representation Migration

```text
State v1
   ↓
transform
   ↓
State v2
```

`state_version` berubah.

#### Runtime / Infrastructure Migration

```text
Runtime A
   ↓
Runtime B
```

`state_version` tidak harus berubah jika representation tetap sama.

### 9.2 Migration requirements

Migration harus:

- memvalidasi source State;
- memiliki compatibility path yang eksplisit;
- mentransformasikan representation secara deterministik;
- memvalidasi target State;
- mempertahankan SH_ID;
- mempertahankan ownership boundary;
- tidak menyebabkan revision rollback/collision;
- tidak meninggalkan State partial/invalid.

Migration tanpa supported path harus gagal secara explicit.

### 9.3 Migration bukan

```text
Migration ≠ Ownership Transfer
Migration ≠ Clone
Migration ≠ Recovery
Migration ≠ New SH Creation
```

Migration history/evidence berada di luar State payload.

---

## 10. D1 — State Storage

SH State menggunakan dedicated persistent storage domain.

Logical target:

```text
public.sh_states
```

Dengan prinsip:

> **One authoritative current State per SH Instance.**

Logical structure:

```text
public.sh_instances
        │
        │ 1 : 1
        ▼
public.sh_states
        │
        ├── sh_id
        ├── state_version
        ├── revision
        ├── state_payload
        ├── created_at
        └── updated_at
```

### 10.1 `sh_id`

`sh_states.sh_id` harus mereferensikan `sh_instances.sh_id`.

State tidak dapat berdiri sendiri tanpa SH Instance.

### 10.2 One current State

Storage harus menjamin hanya terdapat satu authoritative current State untuk setiap SH Instance.

State history tidak menjadi requirement storage saat ini.

### 10.3 Account binding

Account binding tetap berasal dari SH Instance/identity boundary.

Tidak perlu membuat duplicate authoritative account binding pada State hanya untuk mengulang relasi yang sudah ada di `sh_instances`.

### 10.4 Lifecycle

Lifecycle tetap berada pada `sh_instances.status`.

State storage tidak menggunakan lifecycle status sebagai pengganti State.

---

## 11. Runtime / RPC Contract

Frontend tidak melakukan direct CRUD terhadap `sh_states`.

Boundary:

```text
Frontend
   ↓
State Service / Runtime
   ↓
SH State RPC
   ↓
Supabase
   ↓
sh_states
```

### 11.1 Read

Logical RPC:

```text
runtime_get_sh_state(
    p_sh_id
)
```

Flow:

```text
Authentication
      ↓
Account resolution
      ↓
SH authorization
      ↓
Read current State
      ↓
Return authoritative State
```

Logical response minimum:

```text
{
  sh_id,
  state_version,
  revision,
  state_payload,
  updated_at
}
```

`p_sh_id` tidak menjadi authorization bypass.

### 11.2 Mutation

Logical RPC:

```text
runtime_mutate_sh_state(
    p_sh_id,
    p_expected_revision,
    p_mutation
)
```

Flow:

```text
Authenticate
      ↓
Resolve account
      ↓
Resolve / authorize SH
      ↓
Load current State
      ↓
Check expected_revision
      ↓
Validate mutation
      ↓
Validate resulting State
      ↓
Atomic persistence
      ↓
revision + 1
      ↓
Return authoritative State
```

### 11.3 Revision conflict

Jika:

```text
expected_revision != current_revision
```

RPC harus menghasilkan normalized:

```text
REVISION_CONFLICT
```

Tanpa perubahan State.

### 11.4 `state_version`

Caller tidak boleh bebas menentukan `state_version` pada normal mutation.

Representation migration menggunakan migration boundary tersendiri.

---

## 12. Authorization Boundary

State access dan mutation mengikuti identity/ownership boundary yang sudah ada:

```text
authenticated user
      ↓
current_account_id()
      ↓
SH identity resolution
      ↓
ownership / authorization
      ↓
SH State
```

Prinsip:

```text
Account_ID ≠ SH_ID
Runtime Access ≠ Ownership
```

Mengetahui `sh_id` saja tidak cukup untuk memperoleh mutation authority.

---

## 13. Error Contract

Minimal semantic error set:

```text
UNAUTHORIZED
SH_NOT_FOUND
STATE_NOT_FOUND
INVALID_STATE
INVALID_MUTATION
REVISION_CONFLICT
UNSUPPORTED_STATE_VERSION
PERSISTENCE_ERROR
```

RPC/runtime harus menormalisasi error menjadi contract yang dapat dipahami caller.

Exact PostgreSQL error mapping ditentukan pada implementation.

---

## 14. Transaction Boundary

State mutation harus atomic secara logical:

```text
authorize
 + validate
 + revision check
 + mutation
 + revision increment
 + persistence
```

Jika gagal, State sebelumnya tetap authoritative.

Tidak boleh ada partial State.

Exact database transaction implementation ditentukan saat implementation.

---

## 15. Recovery dan Migration Boundary

State tetap menjadi domain tersendiri walaupun berinteraksi dengan Recovery dan Migration.

```text
Current State
     │
     ├── Recovery → restore valid State
     │
     └── Migration → transform valid representation
```

Recovery snapshot dan migration mechanism tidak boleh mengambil alih semantic State.

---

## 16. Current DEV Gap

Audit Supabase DEV menunjukkan saat contract ini dibuat:

- `public.sh_instances` tersedia sebagai SH Instance storage;
- `sh_instances.metadata` tersedia tetapi bukan authoritative State;
- `sh_instances.version` tersedia tetapi bukan `state_version`;
- `recovery_snapshots.manifest` tersedia sebagai recovery container;
- `recovery_events` tersedia sebagai recovery evidence;
- `audit_events` tersedia sebagai audit evidence;
- belum ada dedicated `public.sh_states`;
- belum ada explicit State read RPC;
- belum ada explicit State mutation RPC;
- belum ada explicit State migration RPC;
- recovery integration terhadap first-class State belum terimplementasi.

Dengan demikian implementation belum boleh dianggap selesai hanya karena storage/runtime capability lain sudah tersedia.

---

## 17. Implementation Boundary

Implementation berikutnya harus mengikuti urutan:

```text
Contract
   ↓
Database / Storage
   ↓
RLS / Authorization
   ↓
State RPC
   ↓
Runtime / Service Adapter
   ↓
Recovery Integration
   ↓
Migration Support
   ↓
Frontend Integration bila diperlukan
   ↓
Verification
```

Implementation tidak boleh mengubah semantic State yang sudah ditetapkan contract ini tanpa decision baru.

Tidak boleh langsung membuat workaround melalui `sh_instances.metadata`.

---

## 18. Definition of Done

State implementation hanya dapat dianggap selesai jika:

1. State memiliki dedicated authoritative persistence boundary.
2. Exactly one current State dapat ditentukan untuk setiap SH Instance.
3. State representation memiliki explicit `state_version`.
4. Mutation menggunakan authoritative `revision` dan optimistic concurrency.
5. Stale mutation menghasilkan `REVISION_CONFLICT` tanpa partial write.
6. State mutation melewati authorization/runtime boundary.
7. State tidak mencampur domain semantic lain.
8. Recovery dapat mempertahankan State untuk SH_ID yang sama.
9. Recovery tidak melakukan silent revision rollback.
10. Representation migration memiliki compatibility/validation boundary.
11. Runtime/infrastructure migration tidak membuat SH_ID baru.
12. RPC read/mutation memiliki normalized contract.
13. Failure tidak menghasilkan false success atau partial State.
14. Verification mencakup concurrency, recovery, migration, authorization, persistence, dan regression yang relevan.

---

## 19. Status Keputusan

```text
D8 Boundary                 LOCKED
D2 Representation           LOCKED
D3 Version                  LOCKED
D4 Revision / Concurrency   LOCKED
D5 Mutation                 LOCKED
D6 Recovery                 LOCKED
D7 Migration                LOCKED
D1 Storage                  LOCKED
RPC Contract                LOCKED
```

Semua status di atas adalah **working decisions dalam contract ini**, bukan perubahan Canonical.

---

## 20. Perubahan terhadap Canonical

Tidak ada.

Dokumen ini hanya memformalkan working contract hasil audit dan keputusan untuk SH State. Perubahan terhadap Canonical harus diproses melalui authority Canonical yang sesuai.
