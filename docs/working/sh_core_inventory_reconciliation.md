# SECOND HEAD — SH CORE INVENTORY & RECONCILIATION

**Project:** SECOND HEAD (SH)  
**Status:** Living Working Document — Active Reconciliation  
**Bahasa:** Indonesia  
**Scope:** Identity, State, Conversation, Memory, Knowledge, Experience, Journey, Lifecycle/EOL, Clone, Inheritance, Succession, Recovery, Governance/Runtime, serta capability/application evidence yang relevan  
**Authority Level:** Working / Reconciliation — bukan Canonical  
**Database Source of Truth:** Supabase DEV  
**Current Code:** branch `dev`  
**Historical Evidence:** `dev_old`

---

## 1. Tujuan

Dokumen ini menjadi living inventory untuk merekonsiliasi **seluruh evidence dokumentasi di `docs/` dan implementation Flutter/Dart aktual di `app/`** sebelum menarik kesimpulan baru atau melakukan implementation berikutnya.

Dokumen ini bukan pengganti Canonical, bukan pengganti Approved Contract, dan bukan daftar feature wish-list.

Tujuan reconciliation:

1. mengetahui apa yang benar-benar ditetapkan oleh source authority;
2. mengetahui apa yang benar-benar ada di Supabase DEV;
3. mengetahui apa yang benar-benar ada di backend DEV;
4. mengetahui apa yang benar-benar ada di frontend Flutter/Dart DEV;
5. membedakan historical evidence dari current implementation;
6. menemukan drift antar-dokumen dan antar-layer;
7. memisahkan **VALIDATED / CURRENT IMPLEMENTATION / LEGACY / GAP / OPEN / DEFERRED**;
8. memastikan dependency sebelum execution berikutnya.

**Tidak ada coding pada tahap inventory/reconciliation kecuali user memberikan instruksi implementation setelah confirmed gap dan prerequisite dinyatakan.**

---

## 2. Evidence Set yang Wajib Dibaca

Reconciliation ini tidak boleh hanya berdasarkan Supabase.

### 2.1 Dokumentasi current `dev`

Folder `docs/` saat audit terdiri dari:

```text
docs/
├── README.md
├── canonical/
│   ├── README.md
│   ├── sh_actor_resolution_canonical_addendum_v1.0.md
│   ├── sh_architecture_map.md
│   ├── sh_canonical_map.md
│   ├── sh_foundation_blueprint.md
│   └── sh_supabase_map.md
├── technology/
│   ├── README.md
│   └── sh_technology_boundaries.md
├── architecture/
│   ├── README.md
│   └── sh_flutter_dart_architecture_and_implementation_working.md
├── contract/
│   ├── sh_backend_frontend_reconciliation_status.md
│   ├── sh_project_conversation_message_contract.md
│   └── sh_state_persistence_contract.md
└── working/
    └── sh_core_inventory_reconciliation.md
```

Seluruh dokumen current yang ditemukan di struktur tersebut menjadi evidence untuk reconciliation ini.

Catatan penting: beberapa dokumen canonical map/README merujuk source Canonical atau dokumen historical yang tidak berada di tree `docs/` current. Referensi tersebut tidak boleh dianggap sebagai file current yang tersedia di repository hanya karena disebutkan di dalam dokumen.

### 2.2 Current implementation

Frontend current yang harus diperiksa adalah `app/`, bukan struktur `dev_old`.

Evidence current yang telah diperiksa mencakup antara lain:

- `app/lib/core/identity/sh_identity.dart`;
- `app/lib/core/backend/auth/auth_backend.dart`;
- `app/lib/features/auth/auth_service.dart`;
- `app/lib/features/conversation/conversation_service.dart`;
- `app/lib/features/conversation/conversation_runtime_bridge.dart`;
- `app/lib/features/conversation/conversation_view.dart`;
- `app/lib/features/project_conversation/project_conversation_management_view.dart`;
- `app/lib/features/journey/*`;
- `app/lib/features/lifecycle/*`;
- core storage/recovery/profile/navigation surfaces;
- current Flutter project structure dan CI/build evidence.

Inventory `app/` harus diperlakukan sebagai **CURRENT IMPLEMENTATION evidence**, bukan otomatis sebagai contract authority.

### 2.3 Supabase DEV

Supabase DEV tetap authoritative untuk database/runtime persistence state dan harus direkonsiliasi terhadap repository migration artifacts, backend implementation, dan contract.

### 2.4 `dev_old`

`dev_old` hanya historical evidence: lineage, capability intent, historical implementation, bug/lesson, dan asal-usul semantics. Ia tidak menggantikan current DEV.

---

## 3. Authority Hierarchy

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

Technology dan implementation tidak boleh mengambil alih SH semantics.

Jika dua sumber berbeda:

1. identifikasi konflik;
2. jangan diam-diam menggabungkan definisi;
3. authority lebih tinggi menang;
4. current implementation dicatat sebagai implementation state bila belum sesuai authority;
5. gap tidak boleh disamarkan sebagai keputusan baru.

---

## 4. Classification

| Label | Makna |
|---|---|
| **CANONICAL / VALIDATED** | Didukung authority Canonical/current authoritative addendum. |
| **APPROVED CONTRACT** | Working contract yang telah disetujui dan masih berlaku untuk scope-nya. |
| **CURRENT IMPLEMENTATION** | Benar-benar ditemukan pada current DEV repository/app/backend. |
| **DERIVED / RECONSTRUCTED** | Hasil reconciliation/evidence, bukan authority baru. |
| **LEGACY RESIDUE** | Historical/compatibility implementation yang belum menjadi target semantic baru. |
| **BE-ONLY** | Authority/capability berada di backend/database/runtime. |
| **FE-ONLY** | Presentation/navigation/interaction/local UI/device concern tanpa semantic authority SH. |
| **BE ↔ FE** | Contract membutuhkan backend dan frontend consumer/representation. |
| **GAP** | Kekurangan terbukti terhadap contract/authority/current dependency. |
| **OPEN / UNRESOLVED** | Evidence belum cukup atau keputusan belum ditetapkan. |
| **DEFERRED** | Sengaja belum dikerjakan/ditetapkan dan bukan otomatis blocker aktif. |
| **PROPOSED / INTERPRETATION** | Usulan baru, bukan keputusan. |

Keberadaan tabel, RPC, screen, atau folder tidak otomatis berarti capability tersebut selesai.

---

## 5. Reconciliation Method

Untuk setiap domain:

```text
1. Canonical / authority
        ↓
2. Semua current docs yang relevan
        ↓
3. Approved contract
        ↓
4. Architecture / Technology Boundary
        ↓
5. Supabase DEV schema/data/constraints/RLS/functions
        ↓
6. Backend DEV implementation
        ↓
7. Frontend DEV implementation
        ↓
8. dev_old historical evidence
        ↓
9. Reconcile semantic + dependency
        ↓
10. VALIDATED / CURRENT / LEGACY / GAP / OPEN / DEFERRED
        ↓
11. Verification requirement
```

Analisis BE dan FE dilakukan **paralel** pada inventory. Implementation tetap **BE-first** ketika masuk execution.

---

# 6. CROSS-DOCUMENT RECONCILIATION

## 6.1 Canonical set

Current canonical/reference set menetapkan antara lain:

- `1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH`;
- Account_ID ≠ SH_ID;
- Session_ID ≠ SH_ID;
- Runtime ≠ SH Identity;
- Model ≠ SH Identity;
- Database ≠ SH Identity;
- Creator Authority ≠ Private Data Access;
- SH-000 Core Authority ≠ Private Data Access;
- Runtime Access ≠ Ownership;
- System Governance ≠ Omniscient Data Access;
- Memory ≠ Knowledge;
- Context ≠ Memory;
- Experience ≠ Conversation;
- Experience ≠ Journey;
- DECOMMISSION ≠ Immediate Permanent Delete;
- CLONE_SH ≠ SOURCE_SH;
- CREATOR_SH is NON-CLONABLE;
- INHERITANCE ≠ CLONE;
- INHERITANCE ≠ Identity Transfer;
- EVOLUTION ≠ Ownership Transfer;
- Evolution / Migration / Recovery ≠ New SH Identity;
- Core Evolution memerlukan Governance / Review;
- Privacy / Visibility ≠ Transfer Eligibility.

Actor Resolution Addendum merupakan current authoritative addendum untuk actor/authority scope. Scope Actor Resolution sudah closed; `SYSTEM_RUNTIME` technical mechanism tetap open.

## 6.2 Architecture / Technology

Architecture working reference menetapkan Flutter + Dart sebagai application foundation dan memisahkan Application, Runtime, Capability, Data, Storage, Platform, Provider, dan External Integration boundaries.

Technology Boundaries menetapkan Flutter, Dart, Supabase + PostgreSQL, GitHub Actions, provider-independent AI, adapter/connector boundary, MCP sebagai integration boundary, native/platform boundary, bounded offline, serta verification berlapis.

Ini adalah **direction/boundary**, bukan bukti bahwa seluruh architecture tersebut sudah implemented di `app/`.

## 6.3 State Contract

State contract menetapkan dedicated `public.sh_states`, explicit `state_version`, authoritative `revision`, optimistic concurrency, authorized RPC path, recovery/migration semantics, dan larangan menggunakan `sh_instances.metadata` sebagai State authority.

Current DEV telah memiliki `sh_states` dan State-related runtime/recovery lineage. Status implementation/verification harus dibaca dari current backend + app + Supabase, bukan dari bagian historical gap pada contract yang dibuat sebelum implementation.

## 6.4 Project / Conversation / Message Contract

Approved contract lama menetapkan:

```text
Project
  ↓
Conversation
  ↓
Message
```

serta capability create/list/rename/delete/move/remove/delete message dan management surface.

Namun dokumen contract tersebut secara eksplisit memiliki capability matrix yang sekarang **outdated terhadap current DEV** untuk beberapa operation.

Current Flutter `ConversationService` sekarang memanggil capability untuk:

- list/create/rename/delete Project;
- move/remove Conversation dari Project;
- create/list/select/rename/delete Conversation;
- load/record/update/delete Message;
- load conversation context.

Karena current implementation sudah lebih maju daripada matrix contract lama, **contract lama tidak boleh dipakai sebagai bukti bahwa capability tersebut belum ada**. Sebaliknya, current implementation juga tidak otomatis mengubah contract menjadi authority.

Disposition:

```text
Old Contract capability matrix
        ↓
STALE / SUPERSEDED AS CURRENT IMPLEMENTATION INVENTORY
        ↓
Current DEV capability evidence
        ↓
New Conversation contract required before final semantic closure
```

## 6.5 Backend / Frontend Reconciliation Status

`sh_backend_frontend_reconciliation_status.md` masih menyatakan Frontend Integration `PENDING` dan beberapa backend capability sebagai gap.

Current Flutter source membuktikan bahwa frontend sudah mempunyai integration untuk capability Project/Conversation yang sebelumnya disebut gap.

Maka status document tersebut **tidak boleh dibaca sebagai current implementation inventory**. Ia adalah checkpoint historical/working status yang belum direkonsiliasi setelah perkembangan FE/BE berikutnya.

Disposition:

- gunakan untuk lineage/status decision history;
- jangan gunakan status `Frontend integration PENDING` sebagai klaim current app kosong;
- jangan gunakan old capability-gap matrix sebagai klaim current RPC belum tersedia tanpa cross-check current backend.

---

# 7. CURRENT FRONTEND INVENTORY

## 7.1 Application Foundation

Current `app/` menggunakan Flutter + Dart sesuai Technology Direction.

Observed structure mencakup:

```text
core/
domain/
capabilities/
features/
data/
storage/
platform/
providers/
presentation/
```

Tetapi tidak seluruh folder architecture working sudah berisi implementation. Banyak capability folders masih `.gitkeep`.

**Kesimpulan:** Flutter foundation exists; architecture structure is partially scaffolded; capability implementation is selective, bukan complete A–I.

## 7.2 Identity / Auth

Current FE memiliki:

- auth service;
- backend auth boundary;
- `ShIdentity`;
- `ResolvedActorContext`;
- actor context lifecycle;
- Account/profile representation.

Actor context dikonsumsi dari backend; FE tidak menjadi authority actor.

**Status:** CURRENT IMPLEMENTATION + Actor Resolution integration verified untuk scope yang telah ditutup.

## 7.3 Conversation

Current FE memiliki real conversation implementation, bukan placeholder kosong:

- conversation service;
- runtime bridge;
- conversation view;
- project/conversation management view;
- create/list/select/rename/delete;
- project create/list/rename/delete;
- move/remove conversation;
- message load/record/update/delete;
- search;
- clear/delete/share/copy interaction;
- local conversation persistence/fallback;
- online/offline presentation.

`ConversationView` juga memiliki attachment entry untuk:

- Camera;
- Photos;
- File.

Namun jalur `_send()` masih menggunakan static assistant reply dan secara eksplisit menyatakan dynamic AI response akan terhubung kemudian.

**Status:** CURRENT IMPLEMENTATION / PARTIAL — bukan empty scaffold dan bukan complete SH Runtime conversation.

## 7.4 Project / Conversation Management

Current `ProjectConversationManagementView` menyediakan:

- search;
- project list/create/rename/delete;
- conversation list/create/rename/move/remove/delete;
- empty states;
- loading/refresh/error states;
- confirmation untuk destructive actions.

Ini berarti old contract's backend-gap matrix tidak lagi mencerminkan current app surface.

**Status:** CURRENT IMPLEMENTATION; backend contract/semantic finalization dan verification tetap open.

## 7.5 Memory / Knowledge / Experience / Journey

Current FE memiliki Journey surface dan sub-surfaces untuk:

```text
Memory
Knowledge
Experience
```

serta Journey filters/cards/detail/editor/policy interaction.

Namun evidence source code yang diperiksa menunjukkan sebagian surface tersebut masih menggunakan local/in-memory `JourneyStore` semantics dan tidak dapat otomatis dianggap sebagai authorized backend Memory/Knowledge/Experience integration.

**Status:** FE SURFACE EXISTS; semantic/backend integration status OPEN.

## 7.6 Lifecycle / EOL / Clone / Inheritance / Legacy / Recovery / Succession

Current FE memiliki feature surfaces untuk:

- Lifecycle;
- EOL;
- Clone;
- Inheritance;
- Legacy;
- Recovery;
- Succession.

EOL mempunyai beberapa view/controller/service/state yang menunjukkan workflow yang lebih lengkap daripada placeholder sederhana.

Sebaliknya, beberapa Clone/Inheritance/Legacy/Recovery/Succession entry surfaces masih sangat tipis dan tidak boleh dianggap sebagai complete execution integration hanya karena route/view exists.

**Status:** CURRENT FE SURFACE / IMPLEMENTATION DEPTH VARIES; backend/semantic/E2E reconciliation OPEN.

## 7.7 Local Storage / Offline

Current conversation FE memiliki local persistence melalui `StorageService` dan fallback ketika backend conversation load gagal. Connectivity state juga direpresentasikan pada conversation UI.

Ini **bukan bukti full offline architecture**.

Yang terbukti:

- bounded local conversation persistence exists;
- connectivity detection exists;
- fallback/local-only state exists.

Yang belum otomatis terbukti:

- queued mutations;
- synchronization;
- conflict policy;
- authoritative reconciliation;
- offline auth/session semantics;
- full corruption/recovery model.

**Status:** PARTIAL CURRENT IMPLEMENTATION; full offline target remains OPEN.

## 7.8 Multimodal / File / Camera

Current conversation UI memiliki file picker, image picker, camera/gallery actions, local attachment storage, preview, dan external file open.

Ini membuktikan **FE interaction exists**, tetapi belum membuktikan seluruh Technology Boundary lifecycle:

```text
metadata → upload → processing → cancellation → retry → failure → permission → offline interruption
```

Current send path belum menjadi complete multimodal runtime/model pipeline.

**Status:** FE IMPLEMENTED / runtime lifecycle OPEN.

## 7.9 Tools / Actions / External Integration

Current app tree memiliki integration/profile surfaces dan capability scaffolding. Architecture/technology docs mendefinisikan Tool/Action, Connector, MCP, dan external integration boundaries.

Tidak boleh menyimpulkan generic Tool/Action bridge sudah complete hanya dari keberadaan representative integration code atau UI.

**Status:** PARTIAL / OPEN.

---

# 8. BACKEND ↔ FRONTEND RECONCILIATION MATRIX

| Domain | Backend / Supabase evidence | Frontend DEV evidence | Relationship | Current status |
|---|---|---|---|---|
| Identity / Actor | trusted identity + actor context resolver | auth lifecycle + `ResolvedActorContext` + account representation | BE → FE | **CLOSED for Actor scope** |
| State | `sh_states` + State runtime/recovery lineage | storage/recovery support exists, dedicated State consumer must be distinguished | BE ↔ FE | **OPEN verification** |
| Conversation | projects/threads/messages + runtime CRUD/context | real service/bridge/view/management | BE ↔ FE | **ACTIVE / reconciliation open** |
| Memory | `memories` | Journey Memory surface exists | BE ↔ FE | **OPEN semantic integration** |
| Knowledge | `knowledge` + FK validation | Journey Knowledge surface exists | BE ↔ FE | **OPEN semantic integration** |
| Experience | `experiences` | Journey Experience surface exists | BE ↔ FE | **OPEN semantic integration** |
| Journey | `journey_events` | Journey cards/detail/filter/editor | BE ↔ FE | **OPEN cross-domain** |
| Lifecycle / EOL | lifecycle/terminal/transfer lineage | substantial EOL UI/controller/service | BE ↔ FE | **OPEN** |
| Clone | clone agreements/clones | Clone surface | BE ↔ FE | **OPEN** |
| Inheritance | authorization/events | Inheritance surface | BE ↔ FE | **OPEN** |
| Succession | rules/events/runtime wrapper | Succession surface | BE ↔ FE | **OPEN / blocker** |
| Recovery | snapshots/events + conversation continuity integration | recovery storage/view | BE ↔ FE | **OPEN E2E** |
| Governance / Runtime | authority/policy/RLS/runtime boundaries | status/interaction surfaces | BE → FE | **OPEN** |
| Multimodal | backend/provider capability boundary varies | file/image/camera interaction exists | BE ↔ FE | **PARTIAL** |
| Offline | backend remains remote authority | bounded local fallback/connectivity exists | BE ↔ FE | **PARTIAL** |
| Tools / Actions | representative runtime primitives | integration surfaces/scaffolding | BE ↔ FE | **OPEN generic bridge** |

---

# 9. IMPORTANT CURRENT DRIFT / CONFLICT REGISTER

## D1 — Contract lama vs current Project/Conversation implementation

**Evidence:** old contract still lists Rename Project, Delete Project, Move Conversation, Remove from Project as backend gaps, sementara current Flutter `ConversationService` already invokes those RPCs.

**Classification:** DOCUMENT DRIFT.

**Disposition:** jangan coding untuk "menutup gap" yang sudah tidak terbukti. Cross-check current backend, lalu buat/reconcile contract Conversation baru sebelum semantic closure.

## D2 — Backend/Frontend reconciliation status vs current Flutter

Old status document says FE integration pending. Current Flutter already contains substantial Conversation/Project management integration and Actor Resolution integration.

**Classification:** DOCUMENT DRIFT / STALE CHECKPOINT.

## D3 — Architecture working document vs current implementation

Architecture working document defines broad A–I slices and many future capabilities. Current app only implements selected slices; several capability folders remain scaffolds.

**Classification:** PLAN ≠ CURRENT IMPLEMENTATION.

## D4 — Supabase map vs current DEV

`sh_supabase_map.md` lists 26 public tables and does not include later additions such as `projects`, `conversation_threads`, dan `sh_states`.

**Classification:** CURRENT MAP DRIFT.

Disposition: Canonical/reference map is not silently modified in this living-doc pass. Current DEV state remains primary implementation evidence.

## D5 — Current docs reference source files not present in current `docs/`

Some architecture/canonical references point to older Canonical/build-scope documents not present in current repository tree.

**Classification:** DOCUMENTATION REFERENCE GAP.

Disposition: do not invent or recreate those documents merely to satisfy references.

## D6 — Conversation FE local fallback

Conversation FE has local-only fallback and persistence when backend sync is unavailable.

This is current implementation evidence, but it must not be interpreted as full offline authority.

**Classification:** CURRENT IMPLEMENTATION / BOUNDED LOCAL FALLBACK.

## D7 — Frontend semantic simulation / local Journey persistence

Current Journey implementation includes local `JourneyStore` editing/persistence and a semantic hook/simulator path.

It must not be promoted to backend-authoritative Memory/Knowledge/Experience semantics without reconciliation.

**Classification:** CURRENT FE IMPLEMENTATION / SEMANTIC INTEGRATION OPEN.

---

# 10. DOMAIN RECONCILIATION ORDER

Working sequence remains dependency-oriented, tetapi **domain sequence bukan satu-satunya execution gate**.

```text
Identity
   ↓
State
   ↓
Conversation / Project / Message
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

State ditempatkan eksplisit setelah Identity karena State Contract sekarang merupakan domain locked yang telah memiliki dedicated storage/runtime lineage di DEV.

Cross-domain verification dapat membuka dependency lebih awal/lintas sequence.

---

# 11. CURRENT SECURITY / RUNTIME GATE

Security Harness Step 7 **belum PASS penuh**.

Yang sudah terbukti dari prior audit:

- runtime boundary tests SELF / OTHER / SPOOF / UNAUTH pass;
- authenticated public runtime surface hampir seluruhnya memakai trusted identity helpers;
- anonymous privileged execute surface sudah di-hardening;
- unchecked succession primitives tidak langsung exposed;
- `runtime_execute_succession(uuid)` tetap merupakan wrapper yang harus diaudit.

Exact next audit:

```text
runtime_validate_selected_transfer_scope()
        ↓
succession_rules data / ownership / authority semantics
        ↓
runtime_execute_succession()
        ↓
trusted identity / ownership / authority boundary
        ↓
Step 7 PASS or confirmed backend gap
```

Jangan melompat ke Step 7 closure hanya karena static/security baseline sudah clear.

---

# 12. IMPLEMENTATION GATE

Tidak ada implementation hanya berdasarkan item berikut:

```text
document says gap
        ✗

folder exists
        ✗

screen exists
        ✗

table exists
        ✗

historical implementation exists
        ✗
```

Implementation baru boleh masuk execution apabila:

```text
Authority / Contract
        ↓
Current DEV evidence
        ↓
Confirmed semantic / technical gap
        ↓
Dependency clear
        ↓
Verification plan
        ↓
User execution instruction
```

Jika current implementation lebih maju daripada document, **reconcile document/status dulu**, bukan menambah implementation duplicate.

---

# 13. CURRENT POSITION

### Closed / Strongly Validated

- Actor Resolution semantic/implementation scope yang telah ditutup;
- migration reconstruction disposition dan current migration baseline;
- Knowledge FK validation;
- broad runtime anon execute hardening;
- Recovery ↔ Conversation backend hierarchy integration;
- current Flutter Actor Context integration;
- current Project/Conversation FE integration exists.

### Current Implementation but Not Semantically Closed

- Project/Conversation/Message runtime + management;
- bounded local conversation persistence/fallback;
- Journey UI/domain surfaces;
- Lifecycle/EOL FE;
- Clone/Inheritance/Succession/Recovery FE surfaces;
- file/image/camera interaction;
- profile/account representation;
- current Flutter application architecture scaffold.

### Open / Requires Reconciliation

- new Conversation contract;
- Conversation backend ↔ FE semantic closure;
- Memory/Knowledge/Experience backend ↔ FE integration;
- Journey cross-domain semantics;
- Lifecycle/EOL backend ↔ FE;
- Clone/Inheritance semantics and execution;
- Succession wrapper security boundary;
- Recovery authenticated E2E;
- Governance/Runtime capability exposure;
- generic Tool/Action authorization-execution bridge;
- full multimodal lifecycle;
- full offline/synchronization/conflict model;
- `SYSTEM_RUNTIME` technical mechanism;
- documentation drift/reference cleanup.

### Deferred / Not Automatic Blocker

- broad multi-provider portability;
- full offline parity;
- final local GGUF runtime implementation;
- package/library choices not yet required by an active slice;
- historical migration source reconstruction beyond the current development strategy.

---

# 14. FINAL WORKING RULE

SH sekarang harus diperlakukan sebagai **system reconciliation**, bukan sekadar daftar feature.

Sebelum execution berikutnya:

```text
ALL CURRENT DOCS
      ↓
CURRENT APP / FE
      ↓
CURRENT BACKEND / SUPABASE
      ↓
HISTORICAL dev_old
      ↓
RECONCILIATION
      ↓
CONFIRMED GAP / OPEN / VALIDATED
      ↓
IMPLEMENTATION ONLY WHEN AUTHORIZED
```

**Tidak ada silent promotion dari implementation menjadi authority.**

**Tidak ada silent promotion dari document gap menjadi implementation gap.**

**Tidak ada silent promotion dari historical capability menjadi current feature.**

Dokumen ini adalah living reconciliation map dan harus diperbarui ketika evidence current berubah.
