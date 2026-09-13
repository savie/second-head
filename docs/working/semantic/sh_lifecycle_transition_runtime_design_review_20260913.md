# SECOND HEAD — Lifecycle Transition Runtime Design Review — 2026-09-13

## Status

**WORKING DESIGN REVIEW — DESIGN DEFINED / IMPLEMENTATION GATE CLOSED**

Dokumen ini adalah hasil design review setelah `sh_semantic_lifecycle_policy_contract.md`, `sh_lifecycle_transition_contract_20260913.md`, dan audit capability runtime yang terkait direkonsiliasi.

Dokumen ini belum mengotorisasi migration atau perubahan runtime.

## Authority

Urutan authority yang berlaku:

```text
OWNER / USER DECISION
        ↓
CANONICAL
        ↓
APPROVED CONTRACT
        ↓
ARCHITECTURE / DESIGN
        ↓
WORKING DESIGN REVIEW INI
        ↓
IMPLEMENTASI
        ↓
RUNTIME / DATABASE EVIDENCE
        ↓
E2E VERIFICATION
```

Jika terdapat conflict dengan authority yang lebih tinggi, authority yang lebih tinggi menang dan dokumen ini harus direkonsiliasi.

---

## 1. Tujuan Review

Review ini menentukan **bentuk capability runtime yang paling kecil dan aman** untuk transition lifecycle semantik sebelum ada coding.

Fokus review:

- boundary API/function;
- identity dan ownership;
- lifecycle guard;
- policy dan confirmation authority;
- idempotency/correlation;
- provenance;
- transaction boundary Journey;
- failure semantics;
- security surface;
- verification plan.

Review ini bukan implementasi.

---

## 2. Evidence Baseline DEV

Evidence saat ini menunjukkan:

- Memory dan Knowledge sudah memiliki capability capture `CANDIDATE`;
- Experience saat ini dibuat langsung sebagai `ACTIVE`;
- `runtime_replace_memory` sudah menyediakan replacement Memory yang spesifik domain;
- Journey projection sudah tersedia;
- function runtime yang ada menggunakan authentication dan ownership guard;
- belum ditemukan generic `CANDIDATE → ACTIVE` transition API;
- belum ada request-level idempotency/correlation contract pada capability yang diaudit;
- atomicity domain + Journey belum terbukti untuk seluruh path semantic;
- Knowledge dan Experience belum memiliki transition update/supersede yang setara;
- transition dari model-derived signal belum terbukti aman untuk diaktifkan.

Inventory Supabase DEV juga menunjukkan bahwa capability yang ada masih berupa function domain-specific seperti `runtime_record_memory_with_journey`, `runtime_record_knowledge_with_journey`, `runtime_record_experience`, `runtime_replace_memory`, dan `runtime_record_journey_event`.

---

## 3. Design Principle

### 3.1 Jangan membuat generic lifecycle engine terlebih dahulu

Design ini **tidak** merekomendasikan satu function generik yang menerima arbitrary domain, lifecycle, dan mutation lalu mengubah semua domain melalui satu jalur.

Alasannya:

- Memory, Knowledge, dan Experience memiliki semantics berbeda;
- Experience saat ini tidak memiliki candidate workflow yang sama;
- policy dan transition authority dapat berbeda per domain;
- generic mutation surface memperbesar security dan failure boundary.

Pendekatan yang dipilih adalah **domain-specific transition capability dengan contract yang konsisten**.

### 3.2 Capture bukan transition

Function capture yang membuat atau memperbarui candidate tidak boleh diperlakukan sebagai function activation.

```text
CAPTURE
≠
TRANSITION
```

Dengan demikian `runtime_record_memory*` dan `runtime_record_knowledge*` tidak dijadikan activation API hanya dengan mengubah parameter lifecycle.

### 3.3 Journey bukan authority

Journey hanya mencatat projection/history yang diwajibkan.

```text
DOMAIN TRANSITION
        ↓
JOURNEY PROJECTION
```

Replay atau edit Journey tidak boleh menghasilkan lifecycle transition.

---

## 4. Proposed Runtime Surface

Capability minimum yang direkomendasikan:

```text
Memory
  transition candidate → active
  update/supersede melalui operation yang eksplisit

Knowledge
  transition candidate → active
  update/supersede melalui operation yang eksplisit

Experience
  candidate workflow hanya jika contract domain terlebih dahulu menyetujuinya
  update/supersede hanya jika semantics domain ditetapkan
```

Nama function final **belum dikunci** pada review ini. Naming harus mengikuti naming convention repository setelah contract disetujui.

Setiap function transition harus menerima setidaknya konsep berikut:

```text
source_record_id
expected_current_lifecycle
operation_key / correlation_id
transition_reason / decision reference
provenance
```

`sh_id` tetap menjadi boundary ownership bila contract runtime membutuhkannya, tetapi record identity harus menjadi target transition utama. Content matching tidak boleh menjadi identity transition.

---

## 5. Transition Request Contract

Secara konseptual:

```text
Transition Request
├── actor context
├── account context
├── SH identity
├── domain
├── source_record_id
├── expected_current_lifecycle
├── requested transition
├── operation_key
├── decision reference
├── confirmation reference (jika diwajibkan)
└── provenance
```

Runtime harus melakukan resolusi identity sendiri. Caller tidak boleh menentukan account authority hanya dengan mengirim account ID.

---

## 6. Authorization Boundary

Urutan pemeriksaan yang direkomendasikan:

```text
auth.uid()
    ↓
current_account_id()
    ↓
active SH ownership
    ↓
record ownership
    ↓
expected lifecycle
    ↓
transition legality
    ↓
policy / visibility / scope
    ↓
confirmation authority
    ↓
decision authority
    ↓
operation idempotency
    ↓
mutation
```

Model output tidak boleh mengisi authorization secara implisit.

`confidence` juga tidak boleh dianggap sebagai authorization.

---

## 7. Confirmation Authority

Untuk hasil semantic decision `CONFIRM`, transition tidak boleh berjalan hanya karena model menghasilkan signal.

Design requirement:

```text
MODEL SIGNAL
    ↓
DECISION = CONFIRM
    ↓
USER / AUTHORIZED ACTOR CONFIRMATION
    ↓
TRANSITION AUTHORITY
```

Untuk `ACCEPT`, source authority dan policy tetap harus memenuhi contract. `ACCEPT` bukan bypass terhadap ownership, policy, lifecycle, atau security guard.

Mechanism confirmation aktual belum tersedia sebagai evidence lengkap. Karena itu implementation tetap blocked sampai mekanisme tersebut ditetapkan.

---

## 8. Lifecycle Guard

Setiap transition harus memeriksa kondisi current state di dalam boundary mutation.

Contoh:

```text
expected_current_lifecycle = CANDIDATE
requested_transition = ACTIVATE
```

Jika row sudah berubah sebelum mutation:

```text
CANDIDATE → ACTIVE
```

maka request berikutnya dengan expected `CANDIDATE` harus ditolak atau dikembalikan sebagai hasil idempotent yang sesuai contract.

Tidak boleh menggunakan read-then-write terpisah tanpa guard pada mutation boundary.

---

## 9. Idempotency / Correlation

Transition yang dapat di-retry harus memiliki stable logical operation identity.

Minimum conceptual identity:

```text
actor/account
+ SH
+ domain
+ source_record_id
+ transition
+ operation_key
```

`decision_id` atau correlation reference dapat menjadi bagian dari operation identity bila contract membutuhkannya.

Requirement:

- retry request yang sama tidak membuat successor duplicate;
- retry tidak menggandakan Journey event jika operasi yang sama sudah committed;
- operation yang sama menghasilkan hasil yang dapat direkonsiliasi;
- operation yang berbeda tidak boleh dianggap sama hanya karena content sama.

Content deduplication yang sudah ada **bukan** pengganti operation-level idempotency.

---

## 10. Provenance Contract

Transition harus mempertahankan rantai:

```text
source signal
    ↓
decision
    ↓
authorization / confirmation
    ↓
transition operation
    ↓
resulting record
    ↓
Journey projection
```

Minimum metadata yang harus dapat ditelusuri:

- actor/account;
- SH;
- source record;
- source signal atau source reference;
- model/provider jika memang digunakan;
- decision;
- confirmation/authorization;
- transition;
- operation/correlation key;
- timestamp;
- resulting record;
- Journey event.

Provenance tidak boleh bergantung hanya pada free-form text.

---

## 11. Journey Transaction Boundary

Design yang dipilih:

```text
BEGIN
  validate transition
  mutate domain record
  write required Journey projection
  persist operation/provenance
COMMIT
```

Jika platform/runtime boundary tidak memungkinkan domain mutation dan Journey projection berada dalam satu transaction, contract harus secara eksplisit mendefinisikan intermediate state dan recovery/reconciliation.

Karena evidence saat ini belum membuktikan atomicity seluruh semantic path, implementation tidak boleh mengklaim atomic sebelum diuji.

---

## 12. Domain Design

### 12.1 Memory

Current `runtime_replace_memory` tetap dianggap capability referensi untuk semantics replacement.

Namun model-derived activation membutuhkan capability terpisah:

```text
existing Memory CANDIDATE
        ↓
validate ownership + policy + authorization
        ↓
activate
        ↓
Journey projection
```

Replacement tetap diperlakukan sebagai operation khusus domain, bukan generic transition engine.

### 12.2 Knowledge

Current capture membuat atau menggunakan kembali `CANDIDATE`.

Design yang direkomendasikan:

```text
Knowledge CANDIDATE
        ↓
explicit transition authorization
        ↓
ACTIVE
        ↓
Journey projection
```

Update/supersede harus mempunyai semantics eksplisit sebelum implementasi.

### 12.3 Experience

Current runtime langsung membuat `ACTIVE`.

Review ini **tidak** memaksakan candidate lifecycle untuk Experience.

Sebelum membuat candidate transition Experience, harus ada keputusan domain yang menetapkan apakah Experience memang membutuhkan:

```text
CANDIDATE → ACTIVE
```

atau lifecycle lain.

Update/supersede juga tetap OPEN sampai semantics domain disetujui.

---

## 13. Security Design

Function transition yang membutuhkan privilege database tinggi harus diperlakukan sebagai security-sensitive surface.

Jika `SECURITY DEFINER` digunakan, review wajib mencakup:

- `search_path` yang aman;
- owner function;
- EXECUTE grant;
- anonymous rejection;
- `auth.uid()` check;
- account/SH ownership;
- record ownership;
- lifecycle guard;
- policy guard;
- cross-actor behavior;
- input validation;
- error behavior.

Tidak boleh menggunakan `SECURITY DEFINER` hanya untuk melewati masalah permission/RLS.

Exposure function di `public` harus dianggap API surface dan direview sebelum release.

---

## 14. Failure Semantics

Transition hanya boleh menghasilkan salah satu hasil yang dapat dibuktikan:

```text
SUCCESS
REJECTED
ALREADY_APPLIED / IDEMPOTENT_RESULT
FAILED
```

Tidak boleh:

```text
Domain mutation = failed
Journey = success
overall response = success
```

Jika partial failure memang dimungkinkan, intermediate state harus observable dan memiliki recovery/reconciliation path.

---

## 15. Verification Design

Sebelum implementation gate dibuka, test matrix minimum:

### Positive

- authenticated actor melakukan transition terhadap record miliknya;
- current lifecycle sesuai expected lifecycle;
- policy valid;
- confirmation valid bila diwajibkan;
- transition menghasilkan state yang benar;
- Journey projection benar;
- provenance lengkap;
- retry operation yang sama menghasilkan hasil idempotent.

### Negative

- unauthenticated;
- SH account lain;
- record actor lain;
- expected lifecycle salah;
- record terminal/superseded;
- policy tidak sesuai;
- confirmation tidak ada;
- model-only authority;
- operation key tidak valid/duplicate conflict;
- Journey replay sebagai transition.

### Concurrency

Minimal harus ada dua request terhadap source record yang sama.

Expected:

```text
request A → success
request B → reject / idempotent sesuai operation identity
```

Tidak boleh menghasilkan dua successor yang tidak diinginkan.

---

## 16. Verification Evidence Required

Implementation hanya boleh dimulai setelah evidence berikut tersedia atau dependency yang jelas disetujui:

| Requirement | Status sekarang |
|---|---|
| Domain transition API design | DEFINED pada review ini |
| Confirmation authority | OPEN |
| Stable operation key | DEFINED secara konseptual / implementation OPEN |
| Provenance contract | DEFINED |
| Atomic domain + Journey | OPEN |
| Memory activation semantics | DEFINED |
| Knowledge activation semantics | DEFINED |
| Knowledge update/supersede | OPEN |
| Experience candidate semantics | OPEN |
| Experience update/supersede | OPEN |
| Security review transition function | OPEN |
| Positive E2E plan | DEFINED |
| Negative/cross-actor E2E plan | DEFINED |
| Concurrency E2E plan | DEFINED |

---

## 17. Decision

**DESIGN REVIEW RESULT: PARTIAL PASS — IMPLEMENTATION GATE REMAINS CLOSED.**

Design direction yang dipilih:

```text
DOMAIN-SPECIFIC TRANSITION CAPABILITY
        ↓
EXPLICIT AUTHORIZATION
        ↓
EXPECTED-LIFECYCLE GUARD
        ↓
STABLE OPERATION IDENTITY
        ↓
ATOMIC DOMAIN + JOURNEY
        ↓
PROVENANCE
        ↓
POSITIVE + NEGATIVE + CONCURRENCY E2E
```

Tidak dipilih:

- generic lifecycle engine;
- direct table mutation dari runtime AI;
- activation melalui capture function;
- activation hanya berdasarkan confidence;
- Journey sebagai lifecycle authority;
- content matching sebagai request idempotency.

---

## 18. Implementation Gate

Gate tetap **CLOSED** sampai minimal blocker berikut selesai:

1. confirmation authority ditetapkan;
2. exact transition API/function contract per domain disetujui;
3. operation/correlation key contract ditetapkan;
4. transaction boundary domain + Journey dipastikan;
5. Knowledge update/supersede decision ditetapkan;
6. Experience lifecycle decision ditetapkan;
7. SECURITY DEFINER/exposure review selesai untuk function yang dipilih;
8. E2E harness siap untuk positive, negative, cross-actor, dan concurrency.

Tidak ada migration atau runtime implementation yang diotorisasi oleh dokumen ini.

---

## 19. Next Gate

Setelah blocker di atas ditutup, gate berikutnya adalah:

**Transition API Contract Finalization**

Pada gate tersebut setiap domain harus memiliki:

```text
function name
input schema
output schema
error contract
authorization source
confirmation source
lifecycle matrix
policy rules
idempotency rules
provenance schema
transaction boundary
Journey behavior
security grants
verification cases
```

Baru setelah gate tersebut PASS, migration/runtime implementation dapat dipertimbangkan.

---

## 20. Final State

```text
DOCUMENTATION CONSISTENCY       = RECONCILED
POLICY CONTRACT                 = RECONCILED
TRANSITION CONTRACT             = DEFINED
RUNTIME CAPABILITY              = PARTIAL
RUNTIME DESIGN REVIEW           = PARTIAL PASS
IMPLEMENTATION GATE             = CLOSED
NEXT GATE                       = TRANSITION API CONTRACT FINALIZATION
```

## Change Boundary

Perubahan pada review ini hanya dokumentasi.

```text
GitHub DEV docs                 = CHANGED
Runtime code                    = UNCHANGED
Supabase schema                 = UNCHANGED
Supabase data                   = UNCHANGED
Migration                       = UNCHANGED
Canonical                       = UNCHANGED
Approved Contract               = UNCHANGED
Runtime behavior                = UNCHANGED
```
