# SECOND HEAD — SH CORE INVENTORY & RECONCILIATION

**Project:** SECOND HEAD (SH)  
**Status:** Living Working Document — Active Reconciliation  
**Bahasa:** Indonesia  
**Scope:** Identity, Conversation, Memory, Knowledge, Experience, Journey, Lifecycle/EOL, Clone, Inheritance, Succession, Recovery, Governance/Runtime  
**Authority Level:** Working / Reconciliation — bukan Canonical  
**Source of Truth Database:** Supabase DEV  
**Historical Evidence:** `dev_old`  
**Current Code:** branch `dev`

---

## 1. Tujuan

Dokumen ini menjadi living document untuk melakukan inventory dan reconciliation terhadap kondisi aktual SH Core di DEV.

Tujuan utamanya bukan langsung menghapus legacy, mengganti arsitektur, atau melakukan implementation. Tujuannya adalah memisahkan secara eksplisit:

1. semantic foundation yang sudah benar dan tervalidasi;
2. implementation legacy yang masih valid sebagai fondasi;
3. legacy residue yang masih membawa semantics lama atau accidental complexity;
4. reconciliation/hardening yang sudah membentuk fondasi baru;
5. gap yang benar-benar terbukti;
6. open decision yang belum boleh diisi dengan asumsi;
7. evolution opportunity yang baru boleh menjadi pekerjaan setelah dependency dan authority jelas.

Dokumen ini tidak mengubah Canonical. Jika ditemukan konflik, konflik dicatat dan authority yang lebih tinggi diprioritaskan.

**Analisis Backend dan Frontend dilakukan paralel pada tahap inventory/reconciliation.** Ini dimaksudkan agar kondisi BE dan FE dapat dipetakan sejak awal dalam satu model, bukan agar implementation dilakukan paralel.

Implementation tetap **BE-first**: backend contract dan enforcement harus stabil sebelum FE adaptation menjadi execution scope.

---

## 2. Authority dan Classification

Authority hierarchy:

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

Classification yang digunakan:

| Label | Makna |
|---|---|
| **CANONICAL / VALIDATED** | Didukung Canonical atau sudah diverifikasi terhadap source of truth yang relevan. |
| **DERIVED / RECONSTRUCTED** | Hasil rekonstruksi/reconciliation dari artefact dan implementation yang ada. |
| **CURRENT IMPLEMENTATION** | Kondisi aktual yang ditemukan pada DEV/repository saat inventory. |
| **LEGACY RESIDUE** | Bagian yang masih membawa pola/semantics historical dan belum dinyatakan sebagai target baru. |
| **BE-ONLY** | Capability yang authoritative berada di backend/database/runtime dan tidak membutuhkan semantic authority dari FE. |
| **FE-ONLY** | Capability yang berada pada presentation, navigation, interaction, local UI state, atau application/device concern. |
| **BE ↔ FE** | Capability yang membutuhkan backend contract dan consumer frontend. |
| **GAP** | Kekurangan yang benar-benar terbukti terhadap contract/authority. |
| **OPEN / UNRESOLVED** | Belum cukup bukti atau memang belum diputuskan. |
| **PROPOSED / INTERPRETATION** | Usulan atau interpretasi baru; bukan keputusan. |

**Aturan:** keberadaan nama tabel/function lama tidak otomatis berarti semantics-nya legacy. Sebaliknya, nama baru tidak otomatis berarti semantics-nya sudah baru. Reconciliation harus melihat contract, dependency, source of truth, enforcement, dan verification.

---

## 3. DEV-First Evidence Rule

Untuk setiap domain, evidence current state diprioritaskan sebagai berikut:

```text
1. Supabase DEV actual state
2. DEV migration state / migration artifacts
3. DEV backend implementation
4. DEV frontend implementation
5. Current DEV docs/contracts
6. dev_old history sebagai historical evidence
```

`dev_old` dipakai untuk menjelaskan asal-usul, intent historis, legacy residue, atau capability yang mungkin hilang dari dokumentasi. Ia bukan pengganti current DEV evidence.

Jika DEV ternyata lebih maju daripada dokumentasi, current DEV dicatat sebagai **CURRENT IMPLEMENTATION** dan diverifikasi lebih lanjut. Tidak boleh menyimpulkan “belum ada” hanya karena tidak ditemukan di docs.

Jika DEV dan `dev_old` berbeda:

```text
DEV current reality → primary
 dev_old → historical evidence
```

Jika DEV bertentangan dengan Canonical/approved contract, konflik dicatat; implementation tidak diam-diam dijadikan authority.

---

## 4. SH Core Dependency Order

Reconciliation mengikuti dependency order berikut:

```text
Identity
   ↓
Conversation
   ↓
Memory
   ↓
Knowledge
   ↓
Experience
   ↓
Journey
   ↓
Lifecycle / EOL
   ↓
Clone
   ↓
Inheritance
   ↓
Succession
   ↓
Recovery
   ↓
Governance / Runtime
```

Urutan ini adalah **working reconciliation sequence**, bukan perubahan Canonical baru. Domain berikutnya tidak dianggap siap hanya karena domain sebelumnya memiliki implementation.

Cross-domain dependency tetap harus diperiksa sebelum menyatakan suatu domain closed.

---

## 5. Analisis Paralel BE / FE

Setiap domain di-inventory dari dua sisi sejak awal:

```text
                 SH CORE DOMAIN
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
     BACKEND / DEV              FRONTEND / DEV
          │                         │
          └────────────┬────────────┘
                       ▼
                RECONCILIATION
                       │
          ┌────────────┼────────────┐
          ▼            ▼            ▼
       BE-ONLY       FE-ONLY      BE ↔ FE
          │            │            │
          └────────────┼────────────┘
                       ▼
                CONFIRMED GAP
                       ↓
                BACKEND CONTRACT
                       ↓
                 IMPLEMENTATION
                       ↓
                  FE ADAPTATION
                       ↓
                    E2E
```

Format minimum yang harus terlihat pada hasil inventory:

| SH Core | Backend / Supabase DEV | Frontend / DEV | Relasi | BE-only / FE-only | Legacy / History | Gap / Open | Status |
|---|---|---|---|---|---|---|---|
| Identity | Resolver, account/SH/ownership, actor context, enforcement | Auth/session, identity model, actor representation | BE → FE | — | Identity lineage | `SYSTEM_RUNTIME` technical mechanism open | Actor scope closed |
| Conversation | Thread/message/project hierarchy, runtime CRUD/read, recovery integration | Conversation surfaces, sidebar, rename, project interaction, state | BE ↔ FE | — | Compatibility/retired runtime lineage | Semantic hierarchy reconciliation | Open |
| Memory | Storage/retrieval/relevance/lifecycle/policy | Memory surfaces bila ada | BE ↔ FE / possible BE-only | — | Long historical lineage | Source-of-truth/boundary verification | Open |
| Knowledge | Storage, indexing/retrieval, SH linkage/integrity | Knowledge surfaces bila ada | BE ↔ FE / possible BE-only | — | Historical retrieval assumptions | Privacy/authorization/retrieval boundary | Open |
| Experience | Experience persistence/scoping | Experience surface bila ada | BE ↔ FE | — | Historical semantics | Relation Memory/Journey | Open |
| Journey | Journey events/continuity/provenance | Journey surfaces bila ada | BE ↔ FE | — | Historical continuity lineage | Experience/Journey/Recovery boundary | Open |
| Lifecycle / EOL | Lifecycle state/guards/transfer boundaries | Lifecycle/EOL UX | BE ↔ FE | — | Historical EOL paths | Terminal/recovery/transfer semantics | Open |
| Clone | Agreement, clone identity/materialization/privacy | Clone flow/UI | BE ↔ FE | — | Historical clone paths | Verify no bypass | Open |
| Inheritance | Authorization/events/transfer semantics | Inheritance flow/UI | BE ↔ FE | — | Historical transfer paths | Exact inheritance semantics | Open |
| Succession | Rules/events/validation/execution | Succession flow/UI bila ada | BE ↔ FE | — | Historical succession lineage | `runtime_execute_succession()` audit | Open / blocker |
| Recovery | Snapshots/events/restore/continuity | Recovery flow/UI | BE ↔ FE | — | Historical restore paths | Recovery ≠ clone/new identity | Open |
| Governance / Runtime | Authority/policy/isolation/runtime boundary | Capability/status representation | BE → FE | — | Historical governance/runtime | `SYSTEM_RUNTIME` technical decision | Open |
| FE-only | — | Navigation, presentation, interaction, local UI state, device/app concerns | FE | **FE-ONLY** | Historical UI evidence | Must not create semantic authority | Inventory as found |
| BE-only | RLS, constraints, resolver, enforcement, audit internals, trusted runtime mechanisms | — | BE | **BE-ONLY** | Historical backend evidence | Expose stable contract only where needed | Inventory as found |

**Matrix ini adalah baseline working map, bukan hasil final inventory.** Isi final harus berasal dari evidence aktual DEV.

---

## 6. Reconciliation Method

Setiap domain diperiksa dengan urutan:

```text
1. Canonical / Contract
        ↓
2. Supabase schema + data + constraints + RLS
        ↓
3. Backend functions / enforcement
        ↓
4. Current DEV frontend implementation
        ↓
5. Historical dev_old evidence
        ↓
6. Legacy vs new semantic reconciliation
        ↓
7. BE-only / FE-only / BE ↔ FE classification
        ↓
8. Confirmed gaps
        ↓
9. Open decisions
        ↓
10. Evolution opportunities
        ↓
11. Verification status
```

Tidak ada coding pada tahap inventory/reconciliation kecuali user memberikan instruksi implementation setelah gap dikonfirmasi.

Untuk setiap domain, catat minimal:

1. Canonical / approved contract;
2. actual Supabase DEV schema/data/constraints/RLS;
3. actual DEV backend implementation;
4. actual DEV frontend implementation;
5. dependency BE ↔ FE;
6. BE-only capability;
7. FE-only capability;
8. legacy residue dan historical evidence;
9. confirmed gap;
10. open decision;
11. evolution opportunity;
12. verification status.

---

# 7. DOMAIN INVENTORY

## 7.1 Identity

### Backend / Supabase DEV

DEV memiliki foundation identity:

```text
account_auth_links
        ↓
accounts
        ↓
sh_instances
        ↓
sh_ownership
```

Foundation diperkuat dengan:

- `public.resolve_identity()`;
- `public.current_account_id()`;
- trusted Creator Authority resolution;
- `public.resolve_actor_context()`;
- trusted SH-000 / ORDINARY_SH classification;
- backend runtime identity enforcement.

### Frontend / DEV

- authenticated session lifecycle;
- `ShIdentity`;
- `ResolvedActorContext`;
- actor context wired through auth lifecycle;
- Account screen representation.

### Relasi

BE-resolved identity/context → FE consumer/representation.

### Legacy / historical evidence

`dev_old` memiliki lineage identity/governance yang menjadi evidence atas evolusi foundation tersebut. Historical implementation tidak otomatis menjadi target current design.

### Gap / Open

Tidak ada confirmed Actor Resolution gap pada scope yang sudah ditutup. Technical `SYSTEM_RUNTIME` mechanism tetap open dan dipisahkan dari identity resolution.

### Status

**CANONICAL / VALIDATED + IMPLEMENTED + INTEGRATED + VERIFIED** untuk Actor Resolution scope yang sudah ditutup.

---

## 7.2 Conversation

### Backend / Supabase DEV

DEV saat ini memiliki:

- `projects`;
- `conversation_threads`;
- conversation message compatibility layer;
- thread foreign-key reconciliation;
- empty-thread creation;
- initial greeting;
- project/conversation management runtime;
- recovery ↔ conversation hierarchy integration.

Recent migration lineage menunjukkan conversation telah melalui beberapa tahap reconciliation/hardening, bukan sekadar historical carry-over.

### Frontend / DEV

Inventory mencakup conversation UI/surface, sidebar/thread interaction, rename flow, project interaction, dan state/lifecycle consumer. Detail implementation harus tetap diverifikasi dari current DEV source.

### Legacy residue

Migration `20260907054613_retire_legacy_conversation_runtime_execute` menunjukkan historical runtime tertentu sudah dipensiunkan. Compatibility layer harus dinilai apakah murni compatibility atau masih membawa semantics lama.

### Reconciliation

- Apakah `conversation_threads` sudah menjadi semantic thread boundary yang konsisten di seluruh BE dan FE?
- Apakah `conversations` masih active semantic role atau compatibility residue?
- Apakah project → conversation → thread hierarchy konsisten dengan persistence dan recovery?
- Apakah message compatibility layer hanya compatibility atau masih membawa semantics lama?
- Apakah seluruh runtime read/write memakai trusted identity dan target ownership yang sama?
- Apakah FE mengikuti contract baru atau masih membawa assumptions lama?

### Status

**OPEN / RECONCILIATION IN PROGRESS**

---

## 7.3 Memory

### Backend / Supabase DEV

DEV memiliki domain `memories` dengan lineage storage, retrieval, relevance, lifecycle, dan transfer/privacy policy.

### Frontend / DEV

Actual memory surfaces/state belum dianggap final sebelum current source diperiksa. Jika tidak ada surface aktif, domain tetap dapat menjadi BE-only untuk capability tertentu; jangan mengarang FE surface dari `dev_old`.

### Semantic boundary

```text
Memory ≠ Context
Memory ≠ Knowledge
Memory ≠ Conversation
```

### Reconciliation

- source of truth memory;
- trusted SH/account scoping;
- retrieval authorization;
- memory lifecycle;
- privacy vs transfer eligibility;
- learning vs automatic Core modification;
- BE-only vs BE ↔ FE capability.

### Status

**OPEN / RECONCILIATION REQUIRED**

---

## 7.4 Knowledge

### Backend / Supabase DEV

DEV memiliki domain `knowledge`, indexing/retrieval lineage, serta validasi private `sh_id` foreign key. Migration `20260907044648_validate_knowledge_private_sh_id_fk` menunjukkan integrity boundary telah diperkuat.

### Frontend / DEV

Actual knowledge surfaces/state harus dibuktikan dari current code, bukan historical UI.

### Semantic boundary

```text
Knowledge ≠ Memory
Knowledge ≠ Context
```

### Reconciliation

- ownership/privacy boundary;
- private SH linkage enforcement;
- trusted retrieval context;
- mutation authorization;
- provider leakage;
- apakah capability tertentu BE-only atau membutuhkan FE.

### Status

**CURRENT FOUNDATION EXISTS / SEMANTIC RECONCILIATION OPEN**

---

## 7.5 Experience

### Backend / Supabase DEV

DEV memiliki domain `experiences` dengan account/SH scoping.

### Frontend / DEV

Actual experience surfaces/state harus di-inventory dari current DEV source. Historical surface tidak otomatis berarti active current capability.

### Semantic boundary

```text
Experience ≠ Conversation
Experience ≠ Journey
Experience ≠ Memory
```

### Reconciliation

- unit Experience;
- provenance;
- ownership;
- relation terhadap Memory/Journey;
- historical assumptions;
- BE-only vs BE ↔ FE capability.

### Status

**OPEN / RECONCILIATION REQUIRED**

---

## 7.6 Journey

### Backend / Supabase DEV

DEV memiliki `journey_events` dan lineage yang mencakup continuity/gap/transfer/lifecycle/provenance.

### Frontend / DEV

Actual Journey surfaces/state harus di-inventory dari current DEV source.

### Reconciliation

- unit Journey;
- boundary Experience/Journey;
- provenance;
- recovery continuity;
- transfer/inheritance leakage;
- apakah sebagian capability bersifat BE-only.

### Status

**OPEN / CROSS-DOMAIN RECONCILIATION REQUIRED**

---

## 7.7 Lifecycle / EOL

### Backend / Supabase DEV

DEV memiliki lifecycle/deactivation/terminal guard/transfer boundary lineage.

Canonical boundary:

```text
DECOMMISSION ≠ immediate permanent delete
```

Lifecycle harus tetap dipisahkan dari ownership transfer dan identity recreation.

### Frontend / DEV

Lifecycle/EOL representation dan flow harus direkonsiliasi terhadap backend state/guard. FE tidak boleh menjadi source of truth terminal state.

### Reconciliation

- terminal state authority;
- backend EOL guard;
- decommission/recovery relation;
- transfer prerequisite;
- lifecycle prerequisite untuk clone/inheritance/succession;
- historical EOL semantics.

### Status

**FOUNDATION EXISTS / VERIFICATION AND CROSS-DOMAIN RECONCILIATION OPEN**

---

## 7.8 Clone

### Backend / Supabase DEV

DEV memiliki:

- `clone_agreements`;
- `sh_clones`;
- clone materialization lineage;
- privacy/authorization boundaries.

Canonical distinction:

```text
CLONE_SH ≠ SOURCE_SH
CLONE ≠ SOURCE IDENTITY
```

Creator SH non-clonable dan User SH Clone memerlukan Owner Approval + Agreement sesuai Canonical/approved contract.

### Frontend / DEV

Clone flow/UI harus direkonsiliasi terhadap agreement dan authorization contract. Historical clone UI bukan bukti active current implementation.

### Reconciliation

- clone identity;
- ownership;
- privacy;
- approval/agreement;
- historical bypass;
- BE-only enforcement vs FE representation.

### Status

**STRONG FOUNDATION / VERIFICATION OPEN**

---

## 7.9 Inheritance

### Backend / Supabase DEV

DEV memiliki:

- `inheritance_authorizations`;
- `inheritance_events`;
- transfer/eligibility lineage.

Canonical distinction:

```text
INHERITANCE ≠ CLONE
INHERITANCE ≠ automatic identity transfer
Privacy / Visibility ≠ Transfer Eligibility
```

### Frontend / DEV

Inheritance flow/UI harus direkonsiliasi terhadap authorization contract.

### Reconciliation

- authorization boundary;
- apa yang diwariskan;
- identity vs ownership;
- privacy/transfer distinction;
- historical transfer shortcuts;
- BE-only enforcement vs FE representation.

### Status

**FOUNDATION EXISTS / SEMANTIC RECONCILIATION OPEN**

---

## 7.10 Succession

### Backend / Supabase DEV

DEV memiliki:

- `succession_rules`;
- `succession_events`;
- succession validation/runtime lineage;
- explicit scope validation primitives.

Unchecked primitives terkait succession tidak exposed kepada authenticated caller secara langsung.

### Frontend / DEV

Succession surface/flow harus di-inventory dari current DEV. Tidak dianggap ada hanya karena `dev_old` memiliki UI.

### Confirmed open point

Authenticated `runtime_execute_succession(uuid)` perlu diaudit terhadap authoritative succession validation, trusted identity, ownership, authority, scope, successor semantics, dan EOL prerequisite.

### Status

**OPEN / SECURITY + SEMANTIC RECONCILIATION REQUIRED**

Ini dependency penting sebelum Security Harness dapat dinyatakan complete. Tidak ada coding sebelum validation layer selesai diaudit.

---

## 7.11 Recovery

### Backend / Supabase DEV

DEV memiliki:

- `recovery_snapshots`;
- `recovery_events`;
- recovery/restore lineage;
- recovery ↔ conversation hierarchy integration.

Canonical distinction:

```text
Recovery ≠ Clone Creation
Recovery ≠ new SH identity
```

### Frontend / DEV

Recovery flow/UI harus diverifikasi terhadap actual backend restore contract. Historical recovery UI bukan bukti current active capability.

### Reconciliation

- exact recovery unit;
- snapshot contents;
- Account/SH identity preservation;
- continuity restoration;
- authorization;
- audit evidence;
- boundary dengan clone/inheritance/succession.

### Status

**FOUNDATION EXISTS / CROSS-DOMAIN VERIFICATION OPEN**

---

## 7.12 Governance / Runtime

### Backend / Supabase DEV

Fondasi governance/runtime saat ini:

```text
resolve_identity()
        ↓
governance_evaluator()
        ↓
policy_enforcement_engine()
        ↓
isolation_checker()
        ↓
access_decision_gate()
        ↓
runtime_access_boundary()
        ↓
Runtime Entry Points
```

Actor context:

```text
resolve_actor_context()
        ↓
Resolved Actor / Identity Context
```

Security foundation yang telah diaudit:

- RLS pada domain tables yang diperiksa;
- authenticated runtime surface inventory;
- anon EXECUTE surface review;
- unchecked primitives succession/inheritance/legacy tidak exposed langsung kepada authenticated caller;
- SELF / OTHER / SPOOF / UNAUTH runtime boundary tests PASS pada representative runtime access boundary.

### Frontend / DEV

Capability/status representation harus mengonsumsi backend result dan tidak membuat authority inference lokal.

### SYSTEM_RUNTIME

```text
SYSTEM_RUNTIME ≠ SH Identity
```

Trusted PostgreSQL `SECURITY DEFINER` runtime infrastructure menjadi fondasi execution boundary, tetapi technical semantic mechanism untuk menyatakan `SYSTEM_RUNTIME` secara eksplisit tetap **OPEN**.

### Confirmed open point

`runtime_execute_succession(uuid)` memiliki authenticated EXECUTE tetapi tidak secara langsung memanggil trusted identity helper. Ia harus direkonsiliasi terhadap authoritative succession validation sebelum Security Harness ditutup.

### Status

**STRONG FOUNDATION / SECURITY HARNESS NOT YET CLOSED**

---

# 8. CROSS-DOMAIN RECONCILIATION MATRIX

| Domain | Backend / DEV Foundation | Frontend / DEV Surface | Legacy Residue | Confirmed Gap / Open | Status |
|---|---|---|---|---|---|
| Identity | Account/Auth/SH/Ownership + Actor Context + enforcement | Auth/session + identity/actor representation | Historical identity lineage | `SYSTEM_RUNTIME` mechanism open | VALIDATED / CLOSED for Actor scope |
| Conversation | Project + thread/message hierarchy + runtime + recovery integration | Conversation/sidebar/rename/project surfaces | Compatibility + retired runtime lineage | Semantic hierarchy reconciliation | OPEN |
| Memory | Domain + storage/retrieval/policy lineage | Surface belum final | Long historical lineage | Source-of-truth and boundary verification | OPEN |
| Knowledge | Domain + retrieval + private SH FK integrity | Surface belum final | Retrieval/indexing lineage | Privacy/authorization boundary | OPEN |
| Experience | Domain + account/SH scoping | Surface belum final | Historical semantics | Relation Memory/Journey | OPEN |
| Journey | Events + continuity/provenance lineage | Surface belum final | Cross-domain historical complexity | Experience/Journey/Recovery boundary | OPEN |
| Lifecycle/EOL | State/guards/transfer boundary lineage | Lifecycle/EOL UX | Historical EOL paths | Terminal/recovery/transfer semantics | OPEN |
| Clone | Agreement + clone model + privacy/authorization | Clone flow/UI | Historical clone paths | Verify no bypass | OPEN |
| Inheritance | Authorization + events + transfer lineage | Inheritance flow/UI | Historical transfer paths | Exact inheritance semantics | OPEN |
| Succession | Rules + events + validation/runtime | Surface belum final | Historical succession lineage | Wrapper validation | OPEN / BLOCKER |
| Recovery | Snapshots + events + restore/continuity | Recovery flow/UI | Historical restore paths | Identity/continuity preservation | OPEN |
| Governance/Runtime | Authority + policy + isolation + runtime boundary | Capability/status representation | Historical runtime lineage | Succession wrapper + `SYSTEM_RUNTIME` | OPEN |

Matrix ini adalah working inventory, bukan Canonical map.

---

# 9. LEGACY VS NEW FOUNDATION — WORKING MODEL

Working interpretation saat ini:

```text
LEGACY
  │
  ├── Historical UI / provider assumptions
  ├── Old runtime paths
  ├── Compatibility layers
  └── Historical semantics yang belum direkonsiliasi
             │
             ▼
      RECONCILIATION / HARDENING
             │
             ▼
NEW SH FOUNDATION
  │
  ├── Stable Identity
  ├── Explicit Ownership
  ├── Trusted Actor Resolution
  ├── Backend Governance
  ├── Runtime Boundary
  ├── Conversation Hierarchy
  ├── State / Recovery Foundation
  └── Explicit Lifecycle / Clone / Inheritance / Succession domains
```

Ini bukan keputusan bahwa seluruh legacy harus dihapus. Setiap historical component harus dinilai berdasarkan semantics dan dependency aktual.

---

# 10. BE / FE Boundary Rules

### Backend menjadi authority untuk

- identity resolution;
- ownership/authority resolution;
- authorization;
- policy enforcement;
- data integrity;
- RLS/privilege boundary;
- trusted runtime context;
- persistence dan audit;
- semantic state yang membutuhkan trusted source.

### Frontend menjadi authority untuk

- presentation;
- navigation;
- interaction;
- local UI state;
- device/application concerns yang tidak mengubah semantic authority.

### Frontend tidak boleh menjadi authority untuk

- menentukan Creator;
- menentukan SH-000 dari ID/string lokal;
- menentukan ownership;
- menentukan SYSTEM_RUNTIME;
- bypass backend authorization;
- mengubah Canonical semantics.

### FE-only scope

FE-only capability tetap dicatat sejak inventory awal. Contohnya dapat berupa navigation, layout, interaction, local UI state, visual representation, loading/error presentation, dan device/application concerns. Keberadaan capability FE-only tidak membuatnya menjadi semantic authority atas SH Core.

---

# 11. CONFIRMED BLOCKERS

Saat dokumen ini dibuka, blocker yang masih jelas dari reconciliation/security sequence:

1. `runtime_execute_succession()` harus direkonsiliasi terhadap authoritative succession validation sebelum Security Harness dinyatakan complete.
2. Cross-domain semantic reconciliation belum selesai untuk Conversation → Memory → Knowledge → Experience → Journey.
3. Lifecycle/EOL → Clone → Inheritance → Succession → Recovery relationship masih membutuhkan verification.
4. `SYSTEM_RUNTIME` technical mechanism masih OPEN.

Tidak ada blocker baru yang boleh diciptakan hanya karena historical code terlihat berbeda dari current design.

---

# 12. Implementation Gate

Inventory/reconciliation **bukan implementation authorization**.

Sebelum coding pada domain apa pun:

```text
Inventory
   ↓
Confirmed gap
   ↓
Contract / design decision
   ↓
Dependency check
   ↓
Implementation approval
   ↓
Implementation
   ↓
Verification
```

Jika belum ada confirmed gap, jangan coding hanya karena ada implementation lama yang terlihat berbeda.

Analisis FE yang dilakukan paralel tidak mengubah gate ini. FE boleh sudah di-inventory dan dipetakan sejak awal, tetapi implementation FE mengikuti stable BE contract kecuali capability tersebut memang confirmed FE-only.

---

# 13. Verification Vocabulary

Gunakan istilah berikut secara ketat:

- **Specified** — requirement/contract sudah ditentukan.
- **Designed** — architecture/design sudah ditentukan.
- **Implemented** — code/schema/function sudah ada.
- **Integrated** — komponen sudah terhubung ke lifecycle/runtime yang relevan.
- **Persisted** — state/data benar-benar tersimpan pada source of truth.
- **Verified** — behaviour telah diuji terhadap contract.
- **E2E Verified** — behaviour telah dibuktikan melalui jalur end-to-end yang relevan.

Keberadaan migration atau function tidak sama dengan Verified.

---

# 14. Next Reconciliation Target

Target berikutnya adalah melanjutkan inventory secara evidence-driven, dimulai dari:

```text
Conversation
    ↓
Memory
    ↓
Knowledge
    ↓
Experience
    ↓
Journey
```

Untuk setiap domain, hasil final harus memisahkan:

```text
CANONICAL / VALIDATED
DERIVED / RECONSTRUCTED
CURRENT IMPLEMENTATION
BE-ONLY
FE-ONLY
BE ↔ FE
LEGACY RESIDUE
CONFIRMED GAP
OPEN / UNRESOLVED
PROPOSED / INTERPRETATION
```

Tidak ada implementation change yang dihasilkan dari dokumen ini sampai confirmed gap dan execution scope disetujui.

Actor Resolution Addendum tidak dibuka ulang kecuali ditemukan contradiction nyata terhadap Canonical/contract.

---

# 15. Final Working Rule

SH Core tidak boleh dinilai dengan binary:

```text
legacy = buruk
baru = benar
```

Model kerja yang digunakan adalah:

```text
Historical Evidence
        ↓
DEV-First Inventory
        ↓
BE / FE Parallel Reconciliation
        ↓
Semantic Reconciliation
        ↓
Validated Foundation
        ↓
Confirmed Gap
        ↓
Targeted Implementation
        ↓
Verification
        ↓
SH Core Evolution
```

Dokumen ini tetap living dan dapat diperbarui setelah evidence baru ditemukan. Ia bukan Canonical dan tidak boleh menjadi alasan untuk mengubah Canonical secara diam-diam.
