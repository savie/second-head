# SH Technology Boundaries & Decision Framework

**Project:** SECOND HEAD  
**Version:** SH v1.0  
**Status:** WORKING / NON-CANONICAL  
**Branch:** `dev_temp`  
**Purpose:** Technology boundary, evaluation, and decision framework for the fresh SH application implementation.

> Dokumen ini tidak mengubah Canonical. Ia menetapkan batas teknologi dan kriteria keputusan untuk implementation baru SH.

---

## 1. Tujuan

SH membutuhkan fondasi teknologi aplikasi yang cukup kuat untuk:

- Android sebagai target awal;
- APK/AAB yang dapat dibangun melalui GitHub Actions;
- UI modern, ringan, dan conversation-first;
- akses native bila capability membutuhkannya;
- kemungkinan pengembangan iOS dan platform lain tanpa mengunci architecture secara buruk;
- local / offline capability;
- local AI / GGUF pada tahap yang sesuai;
- file dan multimodal;
- Tools / Hands / Authority;
- connector / adapter;
- Extensions / Plugins;
- MCP;
- provider portability;
- security dan privacy;
- testing dan verification yang dapat direproduksi;
- zero-budget dan zero-hardware pada kondisi pembangunan saat ini.

Tujuan dokumen ini **bukan** memilih teknologi karena paling mudah membuat APK.

Prinsip utama:

> **Pilih technology foundation yang tidak mempersulit SH ketika capability dan platform berkembang.**

---

# 2. Technology Boundaries

Technology choice harus dievaluasi sebagai satu system boundary, bukan sebagai pilihan UI framework saja.

## 2.1 Application Framework

Candidate utama:

1. React Native CLI / bare React Native
2. Flutter
3. Native Kotlin + Jetpack Compose
4. Kotlin Multiplatform + Compose

Candidate sekunder:

- Expo;
- Capacitor + web framework;
- NativeScript;
- .NET MAUI;
- technology lain hanya bila memberikan capability yang material bagi SH.

### Boundary

Application framework:

- boleh menentukan application rendering dan platform integration;
- tidak boleh menentukan SH identity;
- tidak boleh menjadi authority layer;
- tidak boleh mengunci provider;
- tidak boleh mengubah Canonical semantics;
- harus memungkinkan native capability bila diperlukan;
- harus memungkinkan testing dan CI tanpa mandatory paid service.

Application framework ≠ SH Runtime ≠ SH Identity.

---

## 2.2 Build & CI

Primary repository / CI:

**GitHub + GitHub Actions**

Target:

- Android build;
- APK artifact;
- AAB bila diperlukan;
- automated tests;
- lint / typecheck / static checks sesuai stack;
- reproducible build workflow;
- artifact retention / inspection;
- iOS build path harus tetap mungkin secara architecture, meskipun iOS bukan target delivery awal.

### Boundary

CI tidak boleh menjadi bagian dari runtime SH.

Build service ≠ SH capability.

Zero-budget berarti core development tidak boleh mensyaratkan paid CI infrastructure.

---

## 2.3 Backend / Database

Current implementation reference:

**Supabase / PostgreSQL**

Tetapi SH tidak boleh menjadikan Supabase sebagai semantic identity.

Boundary:

```
SH domain / contracts
        ↓
backend boundary
        ↓
database / auth / functions / storage
        ↓
provider implementation
```

Database technology harus dapat diganti pada masa depan tanpa mengubah:

- SH_ID semantics;
- ownership;
- privacy;
- authorization;
- continuity;
- capability contracts.

### Database replacement criterion

Jika suatu saat Supabase perlu diganti, kandidat harus dinilai terhadap:

- PostgreSQL compatibility;
- schema portability;
- migration portability;
- transaction support;
- RLS / authorization strategy;
- authentication integration;
- server-side function capability;
- object/file storage boundary;
- backup / restore;
- observability;
- cost;
- self-hosting possibility;
- operational burden.

Jangan membuat multi-database abstraction sebelum ada kebutuhan nyata. Yang harus portable lebih dulu adalah **contract dan boundary**, bukan setiap SQL detail.

---

## 2.4 AI / Model Provider

SH tidak boleh mengunci dirinya ke satu AI provider.

Model / AI = brain capability.

SH = system, identity, continuity, governance, and capability environment.

Candidate provider category dapat mencakup, sesuai kebutuhan dan availability:

- OpenAI;
- xAI / Grok;
- OpenRouter;
- provider lain;
- local model/runtime;
- GGUF-based local inference.

### Boundary

```
SH
 ↓
model/runtime contract
 ↓
provider adapter
 ↓
model provider
```

Provider-specific API shape tidak boleh bocor menjadi SH product semantics.

Provider failure ≠ SH failure by definition.

Model ≠ SH Identity.

Model ≠ Authority.

---

## 2.5 File & Multimodal

Technology foundation harus mampu menangani:

- file upload;
- attachment lifecycle;
- multiple attachments;
- image input;
- image understanding;
- file analysis / intelligence;
- camera input bila justified;
- multimodal conversation;
- image generation;
- processing state;
- failure / retry state.

File/storage provider harus dapat diganti tanpa mengubah SH ownership/privacy semantics.

Image generation provider juga bukan bagian dari SH identity.

---

## 2.6 Tools / Hands / Authority

Ini adalah boundary yang sangat penting bagi SH.

Application technology harus mampu menjadi client dari capability system tanpa memindahkan authority ke UI.

Minimum conceptual flow:

```
SH
 ↓
Capability / Tool
 ↓
Authority
 ↓
Authorization / Risk Gate
 ↓
Execution
 ↓
Result
 ↓
SH
```

UI confirmation ≠ authorization.

Runtime access ≠ ownership.

Tool ≠ Authority.

---

## 2.7 Workstream E — Hands / Tools / Authority

Workstream E di `dev_old` menunjukkan bahwa Hands bukan sekadar tombol atau function call sederhana.

Historical evolution memperlihatkan progression:

```
Tool capability
      ↓
authorized read / retrieve
      ↓
external create / update
      ↓
connector / adapter
      ↓
MCP
      ↓
future extensions / plugins
```

Representative historical slices yang harus dipahami sebagai architectural evidence:

- R2 — Authorized Read / Retrieve;
- R4 — External Create / Update;
- R6 — Task / Reminder;
- R7 — Connector / Adapter;
- R8 — MCP YouTube.

### R6 — Task / Reminder

Historical R6 membuktikan bounded persistent SH-owned productivity capability:

```
owner request
→ authenticated SH runtime
→ task boundary
→ owner-scoped persistence
→ task result
→ audit trace
```

R6 secara eksplisit bukan:

- Google Tasks integration;
- generic workflow engine;
- recurring task engine;
- autonomous task execution;
- notification infrastructure;
- broad task-management platform.

Artinya technology foundation harus mendukung **persistent internal capabilities** selain external integrations.

### R7 — Connector / Adapter

Connector / adapter harus menjadi provider transport boundary.

```
SH Runtime / Action
        ↓
Connector / Adapter
        ↓
External Provider
        ↓
Normalized Result
        ↓
Action / Audit
```

Connector tidak memiliki:

- SH identity;
- ownership;
- authorization authority;
- risk decision;
- confirmation authority;
- lifecycle authority.

Technology selection harus memungkinkan boundary ini tetap eksplisit.

### R8 — MCP

Historical R8 menunjukkan bahwa SH perlu mempertimbangkan MCP sebagai salah satu integration protocol, bukan otomatis sebagai keseluruhan plugin architecture.

Bounded example:

```
SH Runtime
 ↓
SH MCP Client
 ↓
MCP Server
 ↓
External Provider
 ↓
Normalized Result
 ↓
SH
```

Technology foundation harus memungkinkan:

- HTTP-based integration;
- authentication propagation;
- server-side secret boundary;
- protocol/client implementation;
- deterministic tool discovery;
- normalized results;
- read-only dan future write capability dengan authorization yang tetap dimiliki SH.

MCP ≠ Authority.

MCP ≠ Plugin Marketplace.

MCP ≠ Automatic Remote Code Execution.

### Connector / Adapter / Extension / Plugin

Jangan menyamakan:

```
Tool
Connector / Adapter
MCP
Extension
Plugin
Provider
```

Mereka dapat berhubungan, tetapi memiliki boundary berbeda.

Fresh SH harus mempertahankan kemampuan untuk membangun layer tersebut secara bertahap tanpa memilih application framework yang menghalangi native/network/runtime integration.

---

## 2.8 Local / Offline

Local/offline harus diperlakukan sebagai architecture boundary, bukan UI feature.

Technology foundation harus memungkinkan:

- local storage;
- bounded offline read;
- queued mutation;
- synchronization;
- conflict handling;
- interrupted-sync recovery;
- local privacy/security;
- authentication/session semantics yang jelas;
- online ↔ offline transition;
- eventual local ↔ remote reconciliation.

Jangan memilih framework hanya karena mudah menyimpan cache.

Yang dinilai adalah apakah local state dapat menjadi bagian dari SH continuity tanpa mengaburkan ownership dan authorization.

---

## 2.9 Local GGUF

Local GGUF merupakan runtime path.

Technology foundation harus memungkinkan:

- local inference;
- GGUF model loading;
- model download/update/delete;
- model storage lifecycle;
- memory/resource constraints;
- CPU/GPU considerations;
- fallback local ↔ remote;
- offline execution;
- privacy boundary.

Local inference:

```
local model/runtime
        ≠
SH identity
        ≠
SH authority
```

Technology choice tidak boleh membuat local AI mustahil hanya karena architecture terlalu provider/cloud-centric.

---

## 2.10 Security & Privacy

Technology foundation harus mendukung:

- authenticated identity;
- server-side authorization;
- owner-scoped data;
- private-data isolation;
- secure credential storage;
- secure token handling;
- local secret protection;
- least privilege;
- auditable actions;
- safe provider boundary;
- secure file handling.

Credential tidak boleh menjadi application semantics.

Provider token ≠ SH identity.

Connected account ≠ SH authorization.

---

## 2.11 Testing & Verification

Technology must support verification at multiple levels:

```
unit
 ↓
contract
 ↓
integration
 ↓
runtime
 ↓
E2E
 ↓
artifact / build verification
```

Status harus tetap dibedakan:

```
specified
designed
implemented
integrated
persisted
verified
end-to-end verified
```

Code exists ≠ working.

Historical PASS ≠ current PASS.

Technology choice yang menyulitkan reproducible testing mendapat penalti.

---

## 2.12 Cost & Resource Boundary

Current constraints:

```
zero-budget
zero-hardware
```

Interpretasi:

- tidak membeli device baru untuk memulai;
- tidak mensyaratkan paid service untuk core development;
- external accounts boleh digunakan bila tersedia;
- free-tier dependency boleh digunakan bila tidak menjadi hidden hard dependency;
- architecture harus tetap dapat berkembang jika resource berubah.

Zero-budget / zero-hardware adalah current development constraint, bukan permanent SH identity.

---

# 3. Decision Criteria

Candidate technology dinilai dengan kriteria berikut.

## C1 — SH Architectural Fit

Apakah technology dapat menjaga:

- SH identity;
- runtime boundary;
- ownership;
- authorization;
- continuity;
- provider boundary?

**Weight: Critical**

## C2 — Native Capability Access

Apakah technology memungkinkan akses native Android/iOS ketika SH membutuhkan:

- local storage;
- background behavior;
- camera;
- notifications;
- secure credential storage;
- local inference;
- filesystem;
- networking?

**Weight: High**

## C3 — Cross-Platform Expansion

Apakah architecture dapat berkembang menuju:

- Android;
- iOS;
- tablet;
- web bila dibutuhkan;
- platform lain bila justified?

**Weight: High**

## C4 — UI / UX Quality

Apakah technology memungkinkan:

- modern UI;
- responsive interaction;
- conversation-first flow;
- polished state handling;
- custom interaction tanpa framework fighting?

**Weight: High**

## C5 — Local / Offline / GGUF Fit

Apakah technology dapat mengakomodasi local data dan local inference tanpa architecture rewrite besar?

**Weight: Critical**

## C6 — Tools / Hands / Integration Fit

Apakah mudah membangun:

- runtime calls;
- connectors;
- adapters;
- MCP;
- external APIs;
- file processing;
- secure credential flow?

**Weight: Critical**

## C7 — Build / CI Fit

Apakah Android artifact dapat dibangun secara reproducible melalui GitHub Actions tanpa mandatory paid service?

**Weight: Critical**

## C8 — Verification Fit

Apakah unit, contract, integration, runtime, dan E2E testing dapat dilakukan secara konsisten?

**Weight: High**

## C9 — Operational Complexity

Berapa besar complexity yang ditambahkan oleh framework?

**Weight: High**

## C10 — Ecosystem / Maintainability

Pertimbangkan:

- maturity;
- documentation;
- library availability;
- native integration;
- long-term maintenance;
- community/tooling health.

**Weight: Medium**

## C11 — Existing SH Learning Transfer

Apakah pengalaman historical SH dapat dipakai sebagai lesson tanpa memaksa architecture lama ikut terbawa?

**Weight: Medium**

Ini bukan alasan mempertahankan technology lama.

## C12 — Zero-Budget / Zero-Hardware Feasibility

Apakah candidate dapat dieksplorasi dan dikembangkan dalam kondisi resource saat ini?

**Weight: Critical**

---

# 4. Candidate Evaluation

## A — React Native CLI / Bare React Native

### Strength

- React application model;
- mature Android/iOS ecosystem;
- native module access;
- GitHub Actions friendly;
- dapat menggunakan native Android/iOS APIs;
- relatif dekat dengan knowledge yang sudah diperoleh dari historical SH;
- cocok untuk API-heavy application;
- memungkinkan modern mobile UI.

### Risk

- JavaScript/TypeScript runtime layer tetap menambah abstraction;
- native modules dapat menambah complexity;
- architecture discipline harus dijaga agar provider/runtime tidak bocor ke UI;
- pengalaman lama dengan Expo/RN tidak boleh dijadikan bukti bahwa RN adalah pilihan terbaik.

### SH assessment

**STRONG CANDIDATE**

Tidak otomatis terpilih.

---

## B — Flutter

### Strength

- UI control sangat kuat;
- rendering konsisten;
- modern application experience cocok;
- Android/iOS dari satu application layer;
- native bridge tersedia;
- GitHub Actions friendly;
- cocok untuk fresh UI tanpa membawa historical React assumptions.

### Risk

- Dart menjadi ecosystem baru;
- local/native integration tetap membutuhkan platform bridge;
- local GGUF/runtime integration perlu proof-of-concept;
- knowledge transfer dari RN lebih kecil.

### SH assessment

**STRONG CANDIDATE**

Terutama kuat untuk fresh UI/UX.

---

## C — Native Kotlin + Jetpack Compose

### Strength

- native Android;
- akses platform paling langsung;
- Compose cocok untuk modern Android UI;
- local storage, background work, notifications, security, dan device APIs sangat kuat;
- tidak ada JS runtime/application bridge sebagai fondasi;
- sangat baik untuk Android-first SH.

### Risk

- iOS bukan shared application layer;
- cross-platform expansion membutuhkan architecture tambahan;
- jika SH kemudian membutuhkan shared application logic lintas platform, sebagian work dapat bertambah.

### SH assessment

**STRONG CANDIDATE**

Sangat menarik jika Android-first tetap menjadi delivery priority.

---

## D — Kotlin Multiplatform + Compose

### Strength

- shared Kotlin/domain logic;
- Android + iOS;
- Compose Multiplatform untuk shared UI;
- native interoperability;
- cocok untuk shared domain/runtime abstractions.

### Risk

- engineering complexity lebih tinggi;
- ecosystem dan build complexity lebih besar;
- terlalu banyak abstraction jika kebutuhan lintas platform belum nyata;
- zero-budget / zero-hardware experimentation dapat lebih berat.

### SH assessment

**CANDIDATE**

Menarik untuk long-term multi-platform, tetapi harus dibuktikan tidak over-engineering untuk V1.0.

---

## Secondary Candidates

### Expo

**STATUS: SECONDARY / NOT DEFAULT**

Expo tetap valid technology, tetapi tidak boleh dipilih hanya karena kemudahan setup.

SH harus menghindari kembali ke abstraction yang ternyata membatasi capability yang membutuhkan native/runtime control.

### Capacitor

**STATUS: LOWER PRIORITY**

Web-first approach menarik untuk UI reuse, tetapi native/local/offline/local-GGUF requirements membuat bridge dependency lebih besar.

### NativeScript

**STATUS: LOWER PRIORITY**

Native access menarik, tetapi tidak memberikan advantage yang cukup jelas dibanding candidate utama.

### .NET MAUI

**STATUS: LOWER PRIORITY**

Cross-platform capability ada, tetapi tidak menunjukkan advantage material yang mengalahkan candidate utama untuk current SH constraints.

---

# 5. Candidate Comparison

| Criterion | RN CLI | Flutter | Kotlin + Compose | KMP + Compose |
|---|---|---|---|---|
| SH architectural fit | Strong | Strong | Strong | Strong |
| Native access | Strong | Strong | Excellent | Excellent |
| Modern mobile UI | Strong | Excellent | Excellent | Excellent |
| Android | Strong | Strong | Excellent | Excellent |
| iOS path | Strong | Strong | Separate architecture | Strong |
| Local / offline | Strong | Strong | Excellent | Excellent |
| Local GGUF potential | Strong | Strong | Excellent | Excellent |
| Tools / API / MCP | Strong | Strong | Excellent | Excellent |
| GitHub Actions | Strong | Strong | Excellent | Strong |
| Testing | Strong | Strong | Excellent | Strong |
| Complexity | Medium | Medium | Medium | High |
| Existing SH transfer | High | Low | Low | Low |
| Freshness / reset potential | Medium | High | High | High |
| Zero-budget exploration | Strong | Strong | Strong | Medium |
| Overall | **Strong** | **Strong** | **Strong** | **Candidate** |

Table ini adalah engineering assessment, bukan benchmark absolut.

---

# 6. Technology Decision

## 6.1 Decisions that can be locked now

### LOCKED

**Repository / CI**

```
GitHub
+
GitHub Actions
```

### LOCKED AS CURRENT REFERENCE, NOT PERMANENT

**Backend**

```
Supabase / PostgreSQL
```

Supabase tetap implementation provider saat ini. SH contracts harus tetap provider-boundary aware.

### LOCKED AS ARCHITECTURAL PRINCIPLE

**AI provider**

```
provider-independent
```

OpenAI, xAI/Grok, OpenRouter, other providers, dan local runtime dapat menjadi implementation choices sesuai capability.

### LOCKED AS ARCHITECTURAL REQUIREMENT

Application technology harus mendukung:

- native access;
- modern mobile UI;
- local/offline path;
- local inference path;
- Tools / Hands;
- Connector / Adapter;
- MCP;
- file/multimodal;
- secure credentials;
- CI;
- reproducible verification.

---

## 6.2 Decision that remains open

**Application framework is NOT YET LOCKED.**

Final selection harus dilakukan setelah focused proof-of-concept terhadap candidate utama:

```
React Native CLI / bare RN
Flutter
Native Kotlin + Compose
Kotlin Multiplatform + Compose
```

POC harus menguji **SH-relevant difficulty**, bukan sekadar membuat Hello World.

Minimum POC:

1. modern conversation UI;
2. authenticated API call;
3. secure credential boundary;
4. file/image input;
5. local persistence;
6. offline state;
7. background-capable behavior where relevant;
8. Tool invocation;
9. connector/API adapter;
10. MCP client integration feasibility;
11. test execution;
12. Android APK/AAB through GitHub Actions;
13. architecture path toward iOS;
14. feasibility of local inference integration.

---

# 7. Technology Decision Rule

Jangan memilih:

> yang paling mudah membuat APK.

Pilih:

> **yang paling sedikit mempersulit SH ketika seluruh capability boundary dijalankan secara nyata.**

Jika dua candidate memiliki capability fit yang setara, pilih yang:

1. lebih sederhana;
2. lebih mudah diverifikasi;
3. lebih portable;
4. lebih sedikit provider lock-in;
5. lebih sedikit mandatory paid dependency;
6. lebih mudah dipelihara;
7. tidak membutuhkan hardware tambahan untuk validasi awal.

---

# 8. Fresh Application Principle

Pemilihan technology ini sengaja memisahkan:

```
historical implementation
        ≠
current technology decision
```

Historical Expo/RN implementation dapat digunakan sebagai:

- evidence;
- lesson;
- failure analysis;
- UX reference.

Tetapi tidak otomatis menjadi technology authority.

Fresh SH application harus dapat menghasilkan:

- fresh architecture;
- fresh UI;
- fresh capability integration;
- fresh verification.

Tujuannya bukan mengulang aplikasi lama dengan framework berbeda.

---

# 9. Relationship to SH Canonical

Technology decisions may change.

SH Canonical semantics do not change because of technology selection.

```
SH Canonical
      ↓
SH architecture / contracts
      ↓
technology boundaries
      ↓
technology decision
      ↓
implementation
```

Not:

```
framework limitation
      ↓
change SH semantics
```

Jika framework tidak mampu memenuhi SH requirement, framework yang harus dipertimbangkan ulang.

---

# 10. Required Future Decisions

Sebelum application implementation dimulai, keputusan berikut perlu dibuat:

1. final application framework;
2. Android build strategy;
3. iOS build strategy;
4. backend replacement strategy / criteria;
5. file/storage boundary;
6. AI provider abstraction depth;
7. Tool contract implementation shape;
8. Connector / Adapter contract;
9. Extension / Plugin boundary;
10. MCP boundary;
11. local storage technology;
12. offline synchronization model;
13. local GGUF runtime candidate;
14. credential / secret storage strategy;
15. application testing stack;
16. E2E/device verification strategy;
17. release/artifact strategy.

Tidak semua keputusan harus dibuat sekaligus.

Keputusan harus dibuat ketika dependency-nya menjadi material.

---

# 11. Final Boundary Statement

SH technology foundation harus memungkinkan:

```
Modern Application
      ↓
SH Runtime
      ↓
Identity / Ownership / Governance
      ↓
Capabilities
      ├── Conversation
      ├── File / Multimodal
      ├── Memory / Knowledge / Experience / Journey
      ├── Tools / Hands
      ├── Connector / Adapter
      ├── MCP
      ├── External Providers
      ├── Local / Offline
      └── Local GGUF
```

dengan:

```
GitHub + GitHub Actions
+
zero-budget
+
zero-hardware
```

sebagai current development boundary.

Technology selection harus memperluas kemampuan SH tanpa mengubah SH menjadi:

- framework-specific product;
- provider-specific product;
- cloud-only product;
- online-only product;
- model-specific product;
- UI-only chatbot.

**End of SH Technology Boundaries & Decision Framework**
