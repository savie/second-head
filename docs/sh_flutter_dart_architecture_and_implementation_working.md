# SECOND HEAD — FLUTTER + DART ARCHITECTURE AND IMPLEMENTATION WORKING

Status: WORKING / NON-CANONICAL  
Branch: `dev`  
Basis sumber: Canonical SH Core, sumber authority SH yang relevan, Technology Boundaries yang telah difinalisasi, dan `dev_old` sebagai reference/evidence.  
Tujuan: menjadi working reference terpadu untuk rekonstruksi capability/subsystem, architecture, dan implementation planning SH dengan Flutter + Dart.

## 1. Purpose / Status / Source Authority

Dokumen ini adalah working reference terpadu untuk menurunkan capability dan subsystem yang ditemukan pada `dev_old` menjadi architecture dan implementation planning SH dengan Flutter + Dart.

Dokumen ini tidak mengubah Canonical, tidak menggantikan source authority SH, dan tidak menjadikan seluruh capability yang ditemukan sebagai scope V1.0 yang sudah disepakati.

Hierarki sumber:

1. Canonical SH Core.
2. Build Scope / Implementation Contract / Implementation Guide / Execution Strategy yang telah disepakati.
3. Roadmap V1.0 dan audit workstream.
4. Technology Boundaries yang telah difinalisasi.
5. Implementation dan evidence pada `dev_old`.
6. Materi resume dan brainstorming.

Implementasi pada `dev_old` diperlakukan sebagai reference/evidence, bukan authority dan bukan baseline implementation.

Technology bukan authority SH. Framework, library, provider, database, connector, MCP, native platform, model runtime, dan local runtime hanya merupakan implementation mechanism di bawah boundary yang ditetapkan.

## 2. Reconstruction Basis

### 2.1 Inventaris Workstream A–H

### A — Foundation Reconciliation & Stabilization

**Fokus**

- arsitektur aplikasi dan struktur current tree;
- contract antara App dan runtime;
- alur authentication → account → SH identity continuity;
- owner navigation;
- kesesuaian database source dengan state DEV;
- provider coupling;
- build, test, dan verification;
- blocker dan regression.

**Subsystem / evidence**

- App shell dan navigation;
- auth/account services;
- backend client boundary;
- runtime service dan deployment;
- database dan migration;
- CI, build, test, dan verification.

**Status**

Area ini sudah memiliki audit/reconciliation evidence dalam history. Tidak diperlakukan sebagai feature scope baru tanpa evidence tambahan.

### B — Owner UX Consolidation

**Fokus**

- pengalaman owner berbasis conversation-first;
- navigation dan history;
- composer;
- contextual continuity;
- penyajian Journey;
- Lifecycle dan technical surfaces;
- loading, empty, error, dan offline states yang konsisten.

**Subsystem / evidence**

- Chat;
- Journey;
- Lifecycle;
- More;
- authentication entry;
- attachment interaction;
- runtime confirmation dan error states.

**Boundary**

UX tidak memiliki authority atas identity, ownership, authorization, atau governance.

### C — Multimodal & File Intelligence

**Fokus**

- attachment lifecycle;
- multiple attachments;
- image input;
- file intelligence;
- camera;
- multimodal conversation;
- image understanding;
- image generation.

**Lifecycle yang wajib tercakup**

```
file / image / camera
        ↓
metadata
        ↓
local preview
        ↓
upload
        ↓
processing
        ↓
cancellation / retry / failure
        ↓
permission denial
        ↓
offline interruption
```

**Subsystem / evidence**

- attachment selection pada Chat;
- file-content service;
- image-generation tool/evidence;
- audit dan verification Workstream C.

**Boundary**

Provider dan runtime untuk image generation tetap berada di balik capability/provider boundary. Keduanya tidak menjadi authority SH.

### D — Continuity & Intelligence Surfaces

**Fokus**

Menjaga continuity antara Conversation, Experience, Memory/Knowledge, Journey, dan Search.

**Subsystem**

- Memory;
- Knowledge;
- bounded retrieval;
- relevance, ranking, filtering, dan context injection;
- Experience;
- Journey;
- Global Search.

**Evidence**

- persistence, isolation, relevance, dan retrieval untuk Memory;
- acquisition, validation, normalization, classification, storage, indexing, provenance, dan retrieval untuk Knowledge;
- assembly, composition, prioritization, layering, isolation, validation, disposal, dan budget untuk Context;
- Experience domain;
- Journey producers dan runtime composition;
- global search dan authorized-read path.

**Boundary**

Private memory ≠ shared/general knowledge. Search harus menggunakan authorized retrieval contracts.

### E — Hands / Tools / Authority

**Fokus**

Layer capability dan execution untuk tindakan yang dilakukan sistem.

**Alur target**

```
SH
 ↓
Capability / Tool
 ↓
Authority
 ↓
Authorization / Risk Gate
 ↓
Confirmation bila diperlukan
 ↓
Execution
 ↓
Result
 ↓
Audit / Event
 ↓
SH
```

**Subsystem / evidence**

- tool registry;
- tool invocation dan result boundary;
- schema validation;
- audit;
- action creation;
- risk classification;
- high-risk authorization dan confirmation;
- action execution;
- failure handling;
- observability;
- connector;
- MCP.

**GAP**

Reusable primitives sudah tersedia, tetapi generic Tool/Action authorization-execution bridge masih memerlukan bounded design yang eksplisit.

**Boundary**

MCP adalah integration boundary, bukan authority. Result dari tool atau external system juga tidak otomatis menjadi instruction atau authority SH.

### F — Provider & Infrastructure Boundary

**Fokus**

Mengisolasi implementation yang spesifik terhadap provider atau infrastructure agar semantics provider tidak bocor menjadi semantics SH.

**Subsystem / evidence**

- App backend provider boundary;
- Supabase Auth;
- Supabase Edge Functions;
- PostgreSQL;
- provider-specific runtime/database implementation;
- provider dependency audit.

**Boundary**

```
SH Contracts
     ↓
Data / Infrastructure Boundary
     ↓
Provider Implementation
```

Keberadaan adapter saja tidak cukup untuk menyatakan bahwa provider atau database sudah portable.

### G — Local Storage & Offline

**Fokus**

Bounded local/offline capability.

**Subsystem yang harus dipetakan**

- bounded local state;
- local data scope;
- secure storage;
- privacy;
- offline reads;
- queued mutations;
- synchronization dan reconciliation;
- conflict policy;
- auth/session behavior saat offline;
- recovery setelah synchronization terputus;
- offline/error semantics;
- data ownership.

**Boundary**

Local/offline capability harus tetap bounded. Full offline parity tidak boleh diasumsikan hanya karena local state atau reconciliation sudah tersedia.

### H — Local GGUF Runtime

**Fokus**

Jalur local inference tanpa mengambil alih SH semantics.

**Subsystem yang perlu dieksplorasi**

- local inference runtime;
- kompatibilitas model GGUF;
- lifecycle storage, download, update, dan delete model;
- batas resource perangkat;
- fallback local/remote;
- UX untuk ketersediaan dan failure model;
- privacy;
- runtime compatibility.

**Status**

Roadmap menempatkan area ini sebagai late/dependent exploration. Ini bukan automatic implementation commitment.

### 2.2 Inventaris Capability Lintas Workstream

#### Identity / Governance

- authentication;
- account;
- SH identity;
- ownership;
- authorization;
- privacy;
- governance;
- authority;
- audit.

#### Conversation / Continuity

- conversation;
- history;
- streaming;
- cancellation;
- context;
- memory;
- knowledge;
- experience;
- journey;
- search.

#### Intelligence / Runtime

- runtime core loop;
- identity state resolution;
- memory decision/state update;
- reasoning;
- workflow/state machine;
- model abstraction;
- model selection;
- model fallback;
- semantic signals/candidate formation.

#### Capability Execution

- tool registry;
- tool invocation;
- tool schema validation;
- result boundary;
- action creation;
- risk classification;
- confirmation;
- action execution;
- failure handling/compensation;
- observability/audit.

#### External Integration

- connector/adapter boundary;
- Google Calendar authorization/create-event;
- MCP client/server boundary;
- YouTube MCP representative path;
- file content;
- image generation;
- global search;
- task reminder.

#### Lifecycle

- clone;
- inheritance;
- succession;
- recovery;
- end-of-life;
- portability;
- lifecycle/Journey integration.

#### Delivery / Verification

- migration;
- Edge Functions;
- runtime tests;
- App verification;
- Android build;
- CI workflows;
- evidence records;
- migration/repository parity.

## 3. Capability → Subsystem Trace

### 3.1 Foundation Reconciliation & Stabilization

| Capability | Subsystem | Evidence | Status |
|---|---|---|---|
| Application foundation | App shell, navigation, owner surfaces | App routes dan shell pada `dev_old` | EXISTING |
| Authentication/account continuity | auth, account, SH instance, ownership services | audit A + service layer | RECONCILED |
| Runtime access | runtime client/service + server execution unit | runtime service + runtime-p4a-001 | EXISTING / PROVIDER-COUPLED |
| Database foundation | migration source + PostgreSQL/Supabase | database artifacts + DEV audit | EXISTING |
| CI/build verification | GitHub Actions + Android build | workflow evidence | EXISTING / VERIFIED WITH LIMITATIONS |
| Provider boundary | backend client + server/provider implementation | provider audit | PARTIAL |
| Regression control | typecheck/build/runtime verification | Workstream A evidence | RECONCILED |

**Kesimpulan A:** foundation yang ditemukan pada `dev_old` menjadi reference/evidence, bukan baseline implementation untuk pembangunan baru. Boundary yang masih partial harus menjadi input architecture baru.

### 3.2 Owner UX Consolidation

| Capability | Subsystem | Evidence | Status |
|---|---|---|---|
| Conversation-first owner flow | Chat + authenticated entry | Workstream B audit | EXISTING |
| Conversation continuity | history, rename, edit/delete, streaming, cancellation | Chat implementation evidence | EXISTING |
| Journey continuity surface | Journey UI + journey service | B audit + journey service | PARTIAL / REFINEMENT |
| Lifecycle action surface | Lifecycle routes + clone/inheritance/succession/recovery/eol | B audit + feature services | EXISTING |
| Technical/account surface | More + authorization/runtime verification | B audit | EXISTING |
| Memory/Knowledge/Experience presentation | runtime/context surfaces + Experience | B audit | GAP / REFINEMENT |
| State quality | loading/empty/error/offline states | B audit | PARTIAL |

**Kesimpulan B:** tidak perlu membuat navigation baru hanya untuk Memory, Knowledge, atau Experience. Fokus architecture baru adalah consolidation dan contextual entry.

### 3.3 Multimodal & File Intelligence

| Capability | Subsystem | Evidence | Status |
|---|---|---|---|
| Attachment | Chat attachment interaction | C audit + Chat implementation | EXISTING |
| Multiple attachments | attachment state/processing | C audit | PARTIAL / TARGET |
| File intelligence | file-content capability | E tool evidence + file service | EXISTING / BOUNDED |
| Image input | attachment/image path | C audit | PARTIAL / TARGET |
| Camera | native/platform capture boundary | Technology Boundaries | GAP |
| Multimodal conversation | Chat + runtime/model contract | C target + runtime boundary | PARTIAL |
| Image understanding | model/runtime capability | C target | GAP / DEPENDENT |
| Image generation | image-generation tool/provider boundary | C/R5 evidence | IMPLEMENTED / VERIFICATION-BOUND |
| Operational lifecycle | metadata, preview, upload, processing, cancellation, retry, failure, permission, offline | Technology Boundaries | CONTRACT REQUIREMENT |

**Kesimpulan C:** file/multimodal harus dibangun sebagai satu lifecycle capability, bukan kumpulan attachment UI.

### 3.4 Continuity & Intelligence Surfaces

| Capability | Subsystem | Evidence | Status |
|---|---|---|---|
| Memory | persistence, isolation, relevance, retrieval | D audit / database | VERIFIED FOUNDATION |
| Knowledge | acquisition, validation, normalization, storage, provenance, retrieval | D audit / database | VERIFIED FOUNDATION |
| Context | assembly, composition, prioritization, layering, isolation, validation, disposal, budget | D evidence | VERIFIED FOUNDATION |
| Experience | Experience domain/service | D audit + route | VERIFIED FOUNDATION |
| Journey | events, producers, runtime composition | D audit + service | VERIFIED FOUNDATION |
| Global Search | authorized read/retrieval path | E global search evidence + D | VERIFIED FOUNDATION |

**Kesimpulan D:** domain foundation yang ditemukan menjadi reference/evidence. Risiko utama pada architecture baru adalah semantic leakage atau akses private state yang tidak terkontrol.

### 3.5 Hands / Tools / Authority

| Capability | Subsystem | Evidence | Status |
|---|---|---|---|
| Tool registry | registry | E tool evidence | PARTIAL / EXISTING PRIMITIVE |
| Invocation | runtime tool invocation | E evidence | EXISTING |
| Schema validation | tool contract validation | E evidence | EXISTING |
| Authorized read | runtime authorization + result | E authorized-read | EXISTING / VERIFIED BOUNDARY |
| External create/update | action + authorization + provider execution | R4 | IMPLEMENTED / LIVE VERIFICATION OPEN |
| File content | bounded tool | E file-content | IMPLEMENTED |
| Global Search | bounded tool | E global-search | IMPLEMENTED |
| Image generation | bounded tool | E image-generation | IMPLEMENTED / VERIFICATION BOUND |
| Task reminder | internal SH-owned task | R6 | IMPLEMENTED / VERIFICATION BOUND |
| Connector adapter | connector registry + provider adapter | R7 | IMPLEMENTED / VERIFICATION BOUND |
| MCP | client/server boundary | R8 | IMPLEMENTED / LIVE PROVIDER VERIFICATION BLOCKED |
| Generic Tool/Action bridge | common authorization/execution contract | audit evidence | GAP |

**Kesimpulan E:** representative capabilities memberikan primitives nyata sebagai reference. Gap utama bukan menambah tool sebanyak mungkin, tetapi menyelesaikan common Tool/Action authorization-execution contract.

### 3.6 Provider & Infrastructure Boundary

| Capability | Subsystem | Evidence | Status |
|---|---|---|---|
| App provider boundary | backend service | implementation map | PARTIAL |
| Auth provider boundary | Supabase Auth | A audit | PROVIDER-COUPLED |
| Runtime deployment | Edge Function | A audit | PROVIDER-COUPLED |
| Database boundary | PostgreSQL behind Supabase | Supabase map | PROVIDER-COUPLED |
| Provider dependency mapping | provider audit | provider dependency audit | MAPPED |
| True provider switching | alternate implementation | audit | GAP |

**Kesimpulan F:** target saat ini bukan membangun multi-provider abstraction penuh. Targetnya adalah containment dan explicit dependency mapping.

### 3.7 Local Storage & Offline

| Capability | Subsystem | Evidence / dependency | Status |
|---|---|---|---|
| Bounded local state | local state boundary | Technology Boundaries | GAP / DESIGN REQUIRED |
| Secure local storage | secure storage/platform boundary | Technology Boundaries | GAP / DESIGN REQUIRED |
| Encryption | local storage policy | Technology Boundaries | GAP / DESIGN REQUIRED |
| Migration | local schema/versioning | Technology Boundaries | GAP |
| Corruption recovery | recovery boundary | Technology Boundaries | GAP |
| Offline read | bounded cache/state | roadmap | GAP |
| Queued mutation | local queue | roadmap | GAP |
| Synchronization | reconciliation | roadmap | GAP |
| Conflict policy | reconciliation policy | roadmap | GAP |
| Offline auth/session | auth/session boundary | roadmap | GAP |
| Interrupted-sync recovery | recovery | roadmap | GAP |
| Data ownership | local/remote ownership | Canonical + Technology Boundaries | CONTRACT REQUIREMENT |

**Kesimpulan G:** belum boleh diperlakukan sebagai implemented hanya karena architecture mengantisipasi offline.

### 3.8 Local GGUF Runtime

| Capability | Subsystem | Evidence / dependency | Status |
|---|---|---|---|
| Local inference | runtime adapter | Technology Boundaries / roadmap | GAP |
| GGUF compatibility | model/runtime layer | roadmap | GAP |
| Model storage | local model lifecycle | roadmap | GAP |
| Download/update/delete | model lifecycle | roadmap | GAP |
| Resource constraints | device runtime | roadmap | GAP |
| Local/remote fallback | model orchestration | Technology Boundaries | GAP |
| Failure/availability UX | owner surface | roadmap | GAP |
| Privacy | local inference boundary | Technology Boundaries | CONTRACT REQUIREMENT |

**Kesimpulan H:** H belum implementation-ready dan bergantung pada boundary F dan G.

## 4. Dependency / Contract Mapping

### 4.1 Dependency Utama

```
Identity / Ownership / Authorization
              ↓
        Runtime Context
              ↓
Memory / Knowledge / Experience
              ↓
Conversation / Journey / Search
              ↓
Tools / Actions / Connectors / MCP
              ↓
Persistence / Audit / Continuity
```

### 4.2 Dependency Teknologi

```
SH Semantics
     ↓
Domain Contract
     ↓
Runtime / Orchestration
     ↓
Capability Boundary
     ↓
Adapter / Provider / Platform Boundary
     ↓
External System / Local Runtime
```

### 4.3 Kepemilikan Contract

**SH Core / Canonical**

Memiliki authority atas identity, ownership, authorization semantics, privacy, governance, continuity, lifecycle semantics, dan authority boundaries.

**Runtime**

Memiliki responsibility atas orchestration, context assembly, capability routing, authorization enforcement, risk handling, result normalization, dan audit/event integration.

**Capability**

Memiliki capability identity, input contract, output contract, error contract, execution boundary, dan verification contract.

**Adapter / Connector / MCP**

Memiliki provider protocol, credential handling, provider request/response translation, dan provider-specific failure normalization.

Tidak memiliki authority atas SH.

**Application**

Memiliki presentation, interaction, local UI state, dan user-facing confirmation surface.

Tidak memiliki authority atas identity, ownership, governance, atau authorization.

## 5. Gap / Existing / Partial / Deferred Analysis

### 5.1 EXISTING / FOUNDATION

- App shell dan owner navigation;
- authentication/account/SH continuity foundation;
- runtime service;
- PostgreSQL/Supabase data foundation;
- Memory;
- Knowledge;
- Experience;
- Journey;
- Global Search bounded path;
- representative Tools;
- connector boundary;
- MCP representative boundary;
- CI/build verification surface.

Catatan: item di atas adalah evidence/reference dari `dev_old`, bukan pernyataan bahwa implementasi baru Flutter + Dart sudah tersedia.

### 5.2 PARTIAL / REFINEMENT

- provider containment;
- owner UX consolidation;
- Journey ↔ Conversation continuity;
- Memory/Knowledge/Experience owner-facing presentation;
- multimodal interaction;
- multiple attachment handling;
- generic Tool/Action bridge;
- image generation verification lifecycle.

### 5.3 GAP

- camera capability boundary implementation;
- complete multimodal lifecycle;
- image understanding implementation;
- generic Tool/Action authorization-execution bridge;
- bounded local storage architecture;
- offline queue/reconciliation/conflict model;
- local auth/session behavior;
- local corruption/recovery model;
- local GGUF runtime;
- GGUF model lifecycle;
- local/remote model fallback implementation.

### 5.4 DEFERRED / LATE

- broad plugin marketplace/ecosystem;
- arbitrary extension loading;
- complete multi-provider/database portability;
- full offline parity;
- final local inference runtime;
- broad Project semantics;
- any unapproved expansion of V1.0 feature inventory.

### 5.5 PROHIBITED AS AUTHORITY

- Model as SH authority;
- Runtime as ownership authority;
- Database as SH identity authority;
- Tool as authority;
- MCP as authority;
- Provider as authority;
- UI confirmation as authorization;
- platform permission as SH authorization;
- local state as automatic authoritative state.

## 6. Architecture

### 6.1 Posisi Arsitektur

Dokumen ini mendefinisikan architecture untuk pembangunan SH dengan **Flutter + Dart**.

Implementation pada `dev_old` menggunakan **Expo + bare React Native** dan diperlakukan sebagai reference implementation / historical evidence untuk memahami capability, subsystem, behavior, dependency, dan pelajaran implementasi.

Technology foundation untuk pembangunan:

- Application foundation: Flutter;
- Language: Dart;
- Backend: Supabase + PostgreSQL;
- CI/build: GitHub Actions;
- AI: provider-independent architecture;
- Remote AI: adapter/provider boundary;
- Local AI: runtime boundary, termasuk GGUF/local inference bila digunakan;
- External integration: adapter/connector boundary;
- MCP: integration boundary, bukan authority;
- Native platform: melalui Flutter ↔ native/platform boundary;
- Local/offline: bounded local state + reconciliation;
- Security/privacy: explicit boundary;
- Verification: layered verification.

### 6.2 Authority

Urutan authority:

1. SH Canonical.
2. Approved Build Scope.
3. Implementation Contract.
4. Implementation Guide.
5. Execution Strategy.
6. Final Technology Boundaries.
7. Working capability/subsystem reconstruction dan implementation planning.
8. `dev_old` sebagai reference/evidence.

Technology tidak menjadi authority atas SH.

Tidak ada framework, library, provider, database, connector, MCP server, native platform, model runtime, atau local runtime yang boleh menentukan SH semantics, identity, ownership, authorization, privacy, governance, atau audit authority.

### 6.3 Arsitektur Tingkat Tinggi

```
                    SH CANON / SEMANTICS
                           │
                           ↓
                  DOMAIN / CORE CONTRACTS
                           │
                           ↓
                RUNTIME / ORCHESTRATION
                           │
          ┌────────────────┼────────────────┐
          ↓                ↓                ↓
   Conversation      Intelligence      Capability
   / Journey         / Context         / Tool / Action
          │                │                │
          └────────────────┼────────────────┘
                           ↓
                 DATA / PERSISTENCE BOUNDARY
                           │
              ┌────────────┼────────────┐
              ↓            ↓            ↓
           Remote        Local        Audit
           State         State        / Event
              │            │
              ↓            ↓
        Supabase /       Secure Local
        PostgreSQL       Storage
              │            │
              └──────┬─────┘
                     ↓
             RECONCILIATION BOUNDARY
```

Hubungan technology dan external system:

```
SH Contracts
     ↓
Capability / Runtime Boundary
     ↓
Adapter / Provider / Platform Boundary
     ↓
External Provider / Native Platform / Local Runtime
```

### 6.4 Tanggung Jawab Lapisan

**Core**

Primitif aplikasi lintas fitur saja:

- configuration;
- result/error primitives;
- logging abstraction;
- dependency wiring;
- common contract utilities.

Core tidak boleh menjadi tempat penampungan semantics feature.

**Domain**

Mewakili contract dan domain model yang dibutuhkan aplikasi untuk berinteraksi dengan SH.

Domain tidak memiliki provider implementation dan tidak memiliki UI.

**Runtime**

Menjadi client-side runtime adapter/orchestration surface.

Tanggung jawab:

- request construction;
- event consumption;
- normalized runtime state;
- capability invocation melalui contract;
- session/runtime status.

SH Runtime yang authoritative tetap merupakan system/runtime boundary, bukan bagian dari widget tree Flutter.

**Capabilities**

Setiap capability diisolasi melalui contract yang eksplisit.

Contoh:

- conversation;
- search;
- memory;
- journey;
- actions;
- file;
- multimodal;
- clone;
- inheritance;
- recovery.

Satu capability tidak boleh mengakses internal implementation capability lain secara langsung.

**Features / Presentation**

Memiliki:

- screens;
- widgets;
- view state;
- user interaction;
- user-facing confirmation;
- loading/empty/error/offline presentation.

Presentation tidak memiliki authority atas authorization atau governance.

**Data**

Menangani translation antara application contract dengan persistence/provider boundary.

Code yang provider-specific harus tetap berada pada boundary yang sesuai.

**Storage**

Menangani bounded local persistence dan secure storage adapter.

Local state tidak otomatis menjadi authoritative state.

**Platform**

Menangani Flutter ↔ native/platform integration.

Native API hanya diakses melalui platform contract yang eksplisit.

### 6.5 Runtime Boundary

Alur target:

```
Flutter Application
       ↓
Runtime Client Contract
       ↓
Authenticated Runtime Request
       ↓
SH Runtime
       ↓
Identity / Ownership / Authorization
       ↓
Context Assembly
       ↓
Model / Capability Selection
       ↓
Tool / Action Execution bila diperlukan
       ↓
Normalized Result / Event
       ↓
Runtime Client
       ↓
Flutter Application
```

Application tidak boleh memanggil LLM provider secara langsung untuk behavior SH Runtime.

Application juga tidak boleh membuat ulang runtime authorization secara mandiri.

### 6.6 Identity / Ownership / Authorization Boundary

Ketiganya merupakan authority concern tingkat sistem.

```
Authenticated Actor
       ↓
Account Resolution
       ↓
SH Identity Resolution
       ↓
Ownership / Authority
       ↓
Authorization
       ↓
Capability Access
```

Konsep berikut tetap terpisah:

- Account_ID ≠ SH_ID;
- Session_ID ≠ SH_ID;
- Runtime Access ≠ Ownership;
- Creator Authority ≠ Private Data Access;
- UI confirmation ≠ authorization.

Flutter application hanya mengonsumsi authorization outcome; Flutter tidak menentukan authorization.

### 6.7 Conversation / Continuity Architecture

Conversation merupakan capability surface di atas runtime dan persistence.

```
Chat UI
  ↓
Conversation Contract
  ↓
Runtime
  ├── Identity
  ├── Context
  ├── Memory / Knowledge
  ├── Model
  └── Tools
  ↓
Normalized Events
  ↓
Conversation State
  ↓
Journey / Continuity
```

Streaming direpresentasikan melalui normalized runtime events.

Protocol streaming yang spesifik provider disembunyikan di bawah adapter/runtime boundary.

### 6.8 Memory / Knowledge / Experience / Journey

Keempatnya tetap merupakan concern yang berbeda.

```
Conversation
     ↕
Context
     ↕
Memory / Knowledge / Experience
     ↕
Journey
     ↕
Authorized Search
```

Aturan:

- Memory ≠ Knowledge;
- Private Memory ≠ Shared Knowledge;
- Context ≠ Memory;
- Experience tidak direduksi menjadi transcript storage;
- Journey merupakan continuity surface, bukan pengganti database untuk setiap domain.

Private state harus diakses melalui contract yang authorized.

### 6.9 Tool / Action / Authority Architecture

Alur execution target:

```
SH Runtime
     ↓
Capability / Tool
     ↓
Authority / Authorization
     ↓
Risk Gate
     ↓
Confirmation bila diperlukan
     ↓
Execution
     ↓
Adapter / Connector / MCP
     ↓
Normalized Result
     ↓
Audit / Event
     ↓
SH Runtime
```

Pembedaan penting:

- Tool mendeskripsikan capability interface;
- Action merepresentasikan executable state/mutation bila berlaku;
- Authorization menentukan apakah execution diizinkan;
- Confirmation merupakan interaksi user bila diperlukan;
- Adapter menerjemahkan contract SH ke external provider;
- MCP adalah mekanisme integration, bukan authority.

Common Tool/Action authorization-execution contract harus distabilkan sebelum perluasan tool secara luas.

### 6.10 AI Architecture

**Provider-independent model boundary**

```
SH Runtime
     ↓
Model Contract
     ↓
Model Selection / Fallback
     ↓
Remote Adapter
     ↓
Remote Provider
```

Provider semantics tidak boleh bocor ke lapisan di atasnya.

**Local AI**

```
SH Runtime
     ↓
Model Contract
     ↓
Local Runtime Adapter
     ↓
Local Inference Runtime
     ↓
GGUF Model
```

Local inference tetap interchangeable pada tingkat contract.

Lifecycle storage/download/update/delete model berada pada bounded local model lifecycle, bukan pada identity atau core semantics SH.

### 6.11 External Integration

Semua external system menggunakan adapter/connector boundary yang eksplisit.

```
SH Capability Contract
        ↓
Integration Contract
        ↓
Connector / Adapter
        ↓
External System
```

Contoh:

- Google Calendar;
- YouTube/MCP;
- external service lain yang disetujui kemudian.

Object milik external provider tidak otomatis menjadi SH-owned domain object hanya karena digunakan capability.

MCP tetap merupakan integration boundary.

### 6.12 Multimodal / File / Camera

Lifecycle target:

```
File / Image / Camera
        ↓
Metadata
        ↓
Local Preview
        ↓
Upload
        ↓
Processing
        ↓
Runtime / Model
        ↓
Result
```

Boundary ini harus secara eksplisit merepresentasikan:

- cancellation;
- retry;
- failure;
- permission denial;
- offline interruption.

Camera diakses melalui Flutter ↔ native/platform boundary.

File processing merupakan capability/runtime concern, bukan UI-only feature.

### 6.13 Data / Persistence Architecture

**Remote**

```
SH Domain Contract
       ↓
Data Contract
       ↓
Supabase Boundary
       ↓
PostgreSQL
```

**Local**

```
SH / Application Contract
       ↓
Bounded Local State
       ↓
Secure Storage / Local Database
```

Provider implementation tidak menjadi domain authority.

Local state tidak menjadi authoritative state hanya karena tersedia saat offline.

### 6.14 Local Storage / Offline

Alur target:

```
Remote Authoritative State
          ↕
Bounded Local State
          ↓
Offline Read / Allowed Mutation
          ↓
Queue
          ↓
Reconnect
          ↓
Synchronization
          ↓
Reconciliation
          ↓
Recovery
```

Concern yang wajib diperhatikan:

- privacy;
- secure storage;
- encryption bila diperlukan;
- migration;
- corruption;
- recovery;
- synchronization;
- conflict handling;
- data ownership;
- auth/session behavior saat offline.

Full offline parity tidak diasumsikan.

### 6.15 Native Platform Boundary

Code Flutter tidak boleh menyebarkan native API call ke seluruh feature.

Alur target:

```
Flutter Feature
      ↓
Platform Contract
      ↓
Flutter Platform Adapter
      ↓
Android / Native API
```

Boundary ini relevan untuk capability seperti:

- camera;
- secure storage;
- device/runtime information;
- local model execution;
- kebutuhan platform lain yang memang diperlukan.

Native capability tidak mengubah SH semantics.

### 6.16 Security / Privacy Architecture

Security merupakan concern lintas sistem, tetapi boundary-nya harus eksplisit.

```
Application
   ↓
Authenticated Contract
   ↓
Runtime Authorization
   ↓
Data / Capability Boundary
   ↓
Provider / Storage
```

Secret handling:

- provider secret tetap di server;
- privileged credential tidak masuk ke Flutter client state;
- data sensitif lokal menggunakan secure storage control;
- log tidak boleh mengekspos private data atau credential.

Privacy merupakan system invariant, bukan sekadar concern storage.

### 6.17 Verification Architecture

Verification dilakukan secara berlapis:

```
Contract
   ↓
Unit
   ↓
Integration
   ↓
Runtime
   ↓
Application
   ↓
Device / Platform
   ↓
E2E
```

Setiap capability harus memiliki verification path yang sesuai.

CI green tidak otomatis membuktikan:

- runtime provider availability;
- device behavior;
- manual UX acceptance;
- live external-provider behavior.

Evidence harus menunjukkan layer verification yang benar-benar telah lulus.

### 6.18 Aturan Dependency

Arah dependency yang diizinkan:

```
Presentation
     ↓
Feature / Capability Contract
     ↓
Domain / Runtime Contract
     ↓
Adapter / Data / Platform Boundary
     ↓
Provider / Platform
```

Pola yang tidak diizinkan:

- feature → provider implementation secara langsung;
- widget → database authority;
- UI → authorization decision;
- model → SH identity;
- provider → SH semantics;
- MCP → governance authority;
- local cache → ownership authority;
- capability A → internal implementation capability B.

Dependency lintas feature harus eksplisit melalui contract.

### 6.19 Architecture Slice A–I

Architecture slice menggunakan convention **Slice A–I**.

#### Slice A — Foundation

- Flutter + Dart application foundation;
- application configuration;
- dependency wiring;
- error/result primitives;
- logging abstraction;
- testing foundation;
- CI/build foundation.

#### Slice B — Core SH Client Contracts

- auth/session contract;
- account/SH identity bootstrap;
- runtime request/response contract;
- normalized runtime events;
- secure session storage boundary.

#### Slice C — Runtime Vertical Slice

- authenticated runtime request;
- identity/ownership context;
- satu bounded conversation path;
- normalized response;
- persistence verification.

#### Slice D — Continuity

- conversation history;
- context;
- akses Memory/Knowledge/Experience;
- Journey composition;
- authorized Search.

#### Slice E — Tool / Action

- Tool contract;
- Action lifecycle;
- authorization/risk gate;
- confirmation;
- execution;
- result;
- audit.

#### Slice F — Multimodal

- attachment;
- file lifecycle;
- image input;
- camera platform boundary;
- metadata/local preview;
- upload/processing;
- failure/retry/cancellation;
- multimodal runtime.

#### Slice G — External Integration

- connector adapter;
- MCP integration boundary;
- representative external capability;
- provider-specific verification.

#### Slice H — Local / Offline

- bounded local state;
- secure storage;
- queue;
- synchronization;
- reconciliation;
- recovery.

#### Slice I — Local GGUF

- local model runtime adapter;
- GGUF lifecycle;
- model storage;
- resource constraints;
- local/remote fallback;
- device verification.

**Catatan convention:** Slice A–I adalah **architecture slice**. Planning Step 1–11 pada bagian implementation planning adalah **planning step**. Keduanya berbeda dan tidak boleh dipertukarkan.

## 7. Flutter + Dart Foundation Architecture

### 7.1 Application Foundation — Flutter + Dart

Flutter adalah application foundation untuk pembangunan SH dengan Flutter + Dart, bukan authority SH.

Dart digunakan untuk concern implementasi aplikasi seperti:

- UI composition;
- presentation state;
- client-side orchestration;
- contract models;
- bounded local state;
- service/adapters;
- integrasi platform melalui boundary yang eksplisit.

Flutter tidak boleh memuat ulang governance logic SH secara terpisah dari authority yang semestinya.

Struktur aplikasi awal:

```
app/
├── lib/
│   ├── core/
│   ├── domain/
│   ├── runtime/
│   ├── capabilities/
│   ├── features/
│   ├── data/
│   ├── storage/
│   ├── platform/
│   ├── providers/
│   └── presentation/
├── test/
└── integration_test/
```

Struktur ini adalah working architectural shape, bukan folder contract yang sudah dibekukan.

## 8. Implementation Planning

Catatan penting: bagian ini adalah **planning untuk pembangunan SH dengan Flutter + Dart**, bukan daftar pekerjaan migrasi dari React Native/Expo.

**Convention:** `Implementation Planning` di dokumen ini adalah istilah untuk perencanaan teknis, bukan `Phase` SH. Terminologi `Phase -1` sampai `Phase 6` tetap reserved untuk SH project/execution phase.

Implementation Planning disusun mengikuti urutan berikut. Urutan ini bukan SH Phase dan bukan pengganti Phase -1 sampai Phase 6.

### 8.1 Planning Step 1 — Contract Stabilization

Sebelum capability besar dibangun:

1. pertahankan SH identity, ownership, dan authorization boundaries;
2. dokumentasikan generic Tool/Action contract;
3. tetapkan normalized result/error contract;
4. tetapkan provider adapter contract;
5. pastikan Application tidak mengambil alih authorization;
6. pertahankan Technology Boundaries yang sudah final.

### 8.2 Planning Step 2 — Flutter + Dart Foundation

1. buat application foundation dengan Flutter + Dart;
2. tetapkan struktur project awal berdasarkan architecture boundary;
3. siapkan dependency wiring;
4. siapkan error/result primitives;
5. siapkan logging abstraction;
6. siapkan testing foundation;
7. siapkan CI/build foundation;
8. verifikasi foundation pada target Android yang disepakati.

### 8.3 Planning Step 3 — Core SH Client Contracts

1. auth/session contract;
2. account/SH identity bootstrap;
3. runtime request/response contract;
4. normalized runtime events;
5. secure session storage boundary;
6. verifikasi boundary antara Flutter application dan SH Runtime.

### 8.4 Planning Step 4 — Runtime Vertical Slice

1. authenticated runtime request;
2. identity/ownership context;
3. satu bounded conversation path;
4. normalized response;
5. persistence verification;
6. layered verification untuk vertical slice.

### 8.5 Planning Step 5 — Continuity

1. conversation history;
2. context;
3. Memory/Knowledge/Experience access;
4. Journey composition;
5. authorized Search;
6. verifikasi isolation dan authorization.

### 8.6 Planning Step 6 — Tool / Action Generalization

1. definisikan common Tool contract;
2. definisikan Action lifecycle;
3. satukan authorization/risk gate;
4. normalisasi result/error;
5. tetapkan audit/event contract;
6. implementasikan representative tools secara bertahap;
7. pertahankan connector/MCP sebagai integration boundary.

### 8.7 Planning Step 7 — Multimodal / File

1. attachment lifecycle;
2. multiple attachment;
3. image input;
4. camera melalui platform boundary;
5. metadata dan local preview;
6. upload dan processing;
7. cancellation/retry/failure;
8. permission denial;
9. offline interruption;
10. image understanding;
11. image generation sesuai contract dan verification gate.

### 8.8 Planning Step 8 — External Integration

1. connector adapter;
2. MCP integration boundary;
3. representative external capability;
4. credential handling;
5. provider-specific verification;
6. audit dan normalized result.

### 8.9 Planning Step 9 — Provider Containment

1. petakan provider-specific assumption;
2. tempatkan coupling pada boundary yang tepat;
3. jangan membuat abstraction kosong hanya demi portability;
4. definisikan alternate-provider contract hanya jika ada use case nyata;
5. verifikasi bahwa feature tidak mengakses provider secara langsung.

### 8.10 Planning Step 10 — Local Storage / Offline

1. definisikan local data scope;
2. pilih secure storage boundary;
3. definisikan local schema/migration;
4. definisikan queue;
5. definisikan synchronization;
6. definisikan conflict policy;
7. definisikan interrupted-sync recovery;
8. verifikasi ownership dan privacy selama reconciliation.

### 8.11 Planning Step 11 — Local GGUF

1. tetapkan runtime berdasarkan constraint perangkat;
2. tetapkan supported model class/size;
3. definisikan model lifecycle;
4. integrasikan local runtime melalui adapter;
5. definisikan fallback local/remote;
6. verifikasi resource dan failure behavior;
7. verifikasi privacy;
8. lakukan runtime/device verification.

### 8.12 Verification Plan

Setiap implementation slice harus menghasilkan evidence pada level yang sesuai:

```
Specified
   ↓
Designed
   ↓
Implemented
   ↓
Integrated
   ↓
Persisted
   ↓
Verified
   ↓
E2E Verified
```

Minimum verification:

- contract tests untuk boundary;
- unit tests untuk local logic;
- integration tests untuk provider/runtime;
- runtime verification untuk capability execution;
- App verification untuk owner-facing behavior;
- Android build/artifact verification;
- device/manual verification bila requirement memang memerlukannya.

CI green tidak otomatis menutup manual/device/runtime gate yang belum dilakukan.

### 8.13 Posisi Technology dan Implementation

Perbedaan technology harus dicatat secara eksplisit.

**Technology Direction FINAL menetapkan Flutter + Dart sebagai application foundation.**

Implementation pada `dev_old` menggunakan **React Native + Expo** dan diperlakukan sebagai historical implementation evidence/reference.

Keduanya tidak boleh dicampur menjadi klaim bahwa Flutter sudah implemented.

Klasifikasi:

- Flutter/Dart = FINAL TECHNOLOGY DIRECTION;
- React Native/Expo pada `dev_old` = HISTORICAL IMPLEMENTATION EVIDENCE;
- pembangunan Application dengan Flutter/Dart = IMPLEMENTATION WORK YANG AKAN DATANG;
- tidak ada migration requirement yang menyatakan code React Native/Expo harus dipindahkan satu per satu ke Flutter.

### 8.14 Finish Criteria

Tahap reconstruction → planning dianggap selesai ketika:

- seluruh Workstream A–H telah ditrace;
- capability utama telah dipetakan ke subsystem;
- dependency utama telah dinyatakan;
- contract ownership telah jelas;
- Existing/Partial/Gap/Deferred/Prohibited telah diklasifikasikan;
- architecture slices telah dibentuk;
- implementation order telah diturunkan untuk pembangunan SH dengan Flutter + Dart;
- verification gate telah ditentukan;
- Technology Direction vs historical implementation telah dicatat;
- tidak ada GAP yang diam-diam dipromosikan menjadi implementation commitment.

**Status tahap ini: FINISHED / READY FOR NEXT EXECUTION DECISION.**

Dokumen ini tetap WORKING / NON-CANONICAL sampai ada keputusan untuk mempromosikan hasil planning ke dokumen implementation yang lebih authoritative.

## 9. Architecture Review Findings + Decision Resolution

### 9.1 Finding 1 — Package dan library Flutter

**Finding:** package Flutter tertentu, state management, local database, secure storage, dan library streaming belum dipilih.

**Resolution:** **NOT A FREEZE BLOCKER.**

Architecture hanya membekukan boundary dan contract. Pemilihan package/library dilakukan pada implementation slice yang membutuhkan dan tidak boleh mengubah boundary yang telah dibekukan.

### 9.2 Finding 2 — Transport streaming

**Finding:** protocol/provider-specific streaming belum ditetapkan.

**Resolution:** **NOT A FREEZE BLOCKER.**

Normalized runtime events sudah menjadi contract. Transport konkret tetap menjadi implementation decision di bawah runtime/provider boundary.

### 9.3 Finding 3 — Tool / Action authorization-execution

**Finding:** generic Tool/Action authorization-execution bridge belum menjadi implementation primitive baru.

**Resolution:** **ARCHITECTURE CONTRACT REQUIRED; IMPLEMENTATION DEFERRED.**

Authority flow, risk gate, confirmation, execution, result, dan audit sudah ditetapkan pada architecture. Implementasi bridge dilakukan sebelum perluasan Tool/Action secara luas.

### 9.4 Finding 4 — Local Storage / Offline

**Finding:** teknologi local storage, queue, dan reconciliation implementation belum dipilih.

**Resolution:** **NOT A FREEZE BLOCKER.**

Boundary, ownership, privacy, secure storage, migration, corruption, recovery, synchronization, dan conflict handling sudah menjadi architectural requirements. Detail teknologi ditentukan pada Slice H.

### 9.5 Finding 5 — Local GGUF

**Finding:** runtime, model class/size, dan lifecycle implementation belum dipilih.

**Resolution:** **DEFERRED; NOT A FREEZE BLOCKER.**

Local GGUF tetap berada pada Slice I dan bergantung pada boundary local/offline serta model contract. Tidak boleh dipromosikan menjadi implementation commitment sebelum requirement dan constraint-nya cukup jelas.

### 9.6 Finding 6 — Provider / database portability

**Finding:** belum ada dasar untuk membekukan portability abstraction yang luas.

**Resolution:** **NOT A FREEZE BLOCKER.**

Tidak dibuat abstraction kosong. Provider containment dibekukan sebagai boundary; alternate-provider portability hanya dibuat jika use case nyata membutuhkannya.

### 9.7 Finding 7 — Native/platform implementation

**Finding:** detail API native tertentu belum dipilih.

**Resolution:** **NOT A FREEZE BLOCKER.**

Flutter ↔ native/platform boundary dibekukan. API/package konkret dipilih per capability yang memang membutuhkan native access.

### 9.8 Review Conclusion

Tidak ditemukan architectural finding yang mengharuskan perubahan terhadap:

- SH semantics dan Canonical authority;
- Technology Boundaries;
- identity, ownership, authorization, privacy, dan governance boundaries;
- dependency direction;
- capability isolation;
- provider containment;
- local/offline authority model;
- multimodal lifecycle boundary;
- Tool/Action authority flow;
- architecture slice A–I.

Keputusan yang belum dipilih di atas diklasifikasikan sebagai **implementation-time decisions**, **deferred decisions**, atau **bounded gaps**, bukan sebagai alasan untuk menunda architecture freeze.

**Architecture Review Result: GO / FREEZE-READY.**

## 10. Architecture Freeze Criteria / Handoff

### 10.1 Kriteria Architecture Freeze

Architecture baru siap untuk dibekukan apabila:

- Flutter + Dart foundation sudah eksplisit;
- application/runtime/domain boundary sudah eksplisit;
- identity dan ownership authority tetap berada di luar UI;
- provider dependency sudah tercontain;
- capability contract sudah eksplisit;
- dependency lintas feature sudah eksplisit;
- local/offline authority sudah bounded;
- multimodal lifecycle sudah direpresentasikan;
- tool/action authority flow sudah direpresentasikan;
- native platform access sudah bounded;
- security/privacy boundary sudah eksplisit;
- verification layer sudah didefinisikan;
- tidak ada keputusan architecture yang bergantung pada perlakuan `dev_old` sebagai source migration.

### 10.2 Handoff ke Implementation

Setelah architecture freeze:

```
Architecture Freeze
        ↓
Buat Flutter + Dart Foundation
        ↓
Foundation Verification
        ↓
First Runtime Vertical Slice
        ↓
Capability Slices
        ↓
Layered Verification
        ↓
Evidence
        ↓
Finalization
```

`dev_old` tetap tersedia sebagai reference/evidence sepanjang pembangunan.

`dev_old` bukan implementation baseline untuk aplikasi baru.

### 10.3 Keputusan yang Belum Dibekukan

Dokumen ini belum membekukan:

- package Flutter tertentu;
- library state management;
- package database/local storage tertentu;
- implementasi secure storage tertentu;
- model provider tertentu;
- local GGUF runtime tertentu;
- implementasi external connector tertentu;
- transport streaming tertentu;
- production deployment topology.

Keputusan tersebut dibuat hanya ketika implementation slice yang relevan membutuhkannya dan tetap berada di bawah boundary yang sudah ditetapkan.

### 10.4 Aturan Reconstruction

1. Evidence dari `dev_old` tidak otomatis menjadi requirement baru.
2. Contract yang lebih tinggi mengalahkan implementation evidence yang bertentangan.
3. Canonical tidak diubah atau ditafsirkan ulang diam-diam.
4. Capability yang muncul di beberapa workstream harus dipetakan sebagai hubungan, bukan dibuat menjadi beberapa authority.
5. Shared subsystem harus mempunyai boundary yang jelas sebelum digunakan lintas capability.
6. Technology, provider, dan platform hanya menjadi implementation mechanism sesuai boundary yang ditetapkan.
7. Jika evidence belum cukup, tandai sebagai GAP atau INFERENSI; jangan mengarang keputusan.
8. Jika suatu area memang belum waktunya dikerjakan, tandai DEFERRED dan jangan memperlakukannya sebagai implementation blocker tanpa dasar.

### 10.5 Status Handoff

Architecture menggunakan Flutter + Dart. Dokumen ini berada pada `dev_temp` sebagai working reference yang akan menjadi dasar setelah Architecture Freeze. `dev_old` tetap digunakan sebagai reference/evidence dan tidak menjadi baseline implementation.

END OF DOCUMENT
