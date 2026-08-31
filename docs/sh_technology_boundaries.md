# SECOND HEAD — Technology Boundaries

Project: SECOND HEAD  
Version: SH v1.0  
Status: NON-CANONICAL  
Branch: dev  
Authority: Technology Boundary  
Scope: Technology foundation, application architecture boundaries, infrastructure boundaries, integration boundaries, dan technology constraints SH.

> Dokumen ini menetapkan batas teknologi yang berlaku untuk implementasi SECOND HEAD.  
> Dokumen ini tidak mengubah SH Canonical.

---

## 1. Tujuan

Technology Boundaries menetapkan teknologi, tools, dan batas penggunaan teknologi yang menjadi foundation SECOND HEAD.

Tujuannya adalah memastikan SH dapat dibangun dan berevolusi sebagai aplikasi yang:

- modern;
- distinctive;
- indah dan konsisten secara visual;
- responsive;
- maintainable;
- modular;
- secure;
- privacy-aware;
- dapat diverifikasi;
- memiliki dependency yang terkontrol;
- dapat berkembang tanpa efek domino antar-capability;
- tetap memiliki batas yang jelas antara aplikasi, SH Runtime, capability, authority, provider, dan platform.

Technology tidak boleh menjadi sumber kebenaran SH.

Framework, library, provider, backend, connector, MCP, native platform, maupun model runtime hanya merupakan implementation technology di bawah contract dan boundary SH.

Prinsip utama:

> Perubahan pada satu capability harus tetap terisolasi sejauh tidak terdapat dependency contract yang memang mengharuskan perubahan lintas-capability.

---

## 2. Boundaries

### 2.1 Application Foundation

Application foundation SH adalah:

**Flutter**

Flutter digunakan sebagai framework utama untuk application layer SH.

Bahasa utama:

**Dart**

Flutter menjadi foundation untuk:

- UI;
- application shell;
- navigation;
- presentation;
- application state;
- feature composition;
- platform integration boundary.

Flutter application bukan authority untuk:

- identity;
- ownership;
- authorization;
- privacy;
- governance;
- audit authority;
- provider credentials;
- SH semantics.

---

### 2.2 UI / UX

UI SH dibangun dengan Flutter dan wajib mendukung:

- modern visual language;
- distinctive SH identity;
- clean interaction;
- responsive layout;
- mobile-first;
- tablet adaptation;
- accessibility;
- loading state;
- empty state;
- error state;
- retry;
- cancellation;
- progress;
- progressive disclosure;
- conversation-first interaction;
- capability surface yang tidak membebani pengguna.

UI historical tidak menjadi design authority.

UI harus menjadi presentation layer, bukan tempat menyimpan business authority atau SH semantics.

---

### 2.3 Application Architecture

Boundary utama:

```
SH Semantics
      ↓
SH Contracts
      ↓
Application / Runtime
      ↓
Capability
      ↓
Adapter / Connector
      ↓
Provider / Platform
```

Feature tidak boleh secara langsung menjadi dependency terhadap implementation provider apabila boundary contract dapat digunakan.

Feature tidak boleh menjadi authority bagi feature lain.

Shared infrastructure tidak boleh menjadi tempat mencampurkan seluruh state dan semantics aplikasi.

---

### 2.4 Feature Isolation

Capability harus dapat dikembangkan secara modular.

Secara konseptual:

- Chat
- Journey
- Memory
- Knowledge
- Experience
- Search
- Files
- Tools
- Tasks
- Connectors
- MCP

masing-masing memiliki boundary sendiri.

Perubahan pada satu feature tidak boleh secara default memerlukan perubahan pada feature lain.

Jika dependency lintas-feature memang diperlukan:

```
Feature A
    ↓
Explicit Contract
    ↓
Feature B
```

Dependency tersebut harus eksplisit dan dapat diverifikasi.

---

### 2.5 SH Identity Boundary

Identity SH tetap mengikuti Canonical.

Technology layer wajib mempertahankan pemisahan:

- Account_ID
- SH_ID
- Session_ID

dan invariant:

**1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH**

Authentication identity tidak boleh disamakan dengan SH identity.

UI authentication state tidak boleh menjadi authority identity.

---

### 2.6 Backend Boundary

Current backend technology:

**Supabase + PostgreSQL**

Supabase digunakan sebagai implementation backend.

Namun:

> Supabase bukan SH identity dan bukan SH semantics.

Boundary:

```
SH Application
      ↓
SH Contract / Runtime Boundary
      ↓
Backend Boundary
      ↓
Supabase / PostgreSQL
```

Feature tidak boleh menyebarkan detail Supabase ke seluruh application layer tanpa boundary yang diperlukan.

Backend implementation harus dapat dikembangkan atau diganti tanpa mengubah semantics SH.

---

### 2.7 AI / Model Provider Boundary

AI provider bukan bagian dari identity maupun authority SH.

Boundary:

```
SH
 ↓
Model / Runtime Contract
 ↓
Model Orchestration / Selection
 ↓
Provider Adapter
 ↓
Remote Provider
       OR
Local Runtime
 ↓
Normalized Result
 ↓
SH
```

Model layer harus dapat menangani, sejauh scope dan dependency mengizinkan:

- text model;
- image generation;
- multimodal model;
- model routing;
- model selection;
- model fallback.

Model selection policy harus dapat mempertimbangkan:

- capability;
- cost;
- availability;
- privacy;
- latency;
- resource constraints.

Zero-budget model path tetap harus tersedia; paid model hanya optional enhancement.

Provider-specific API, credential, model identifier, maupun response format tidak boleh menjadi SH product semantics.

Provider dapat berubah tanpa mengubah identity, ownership, authorization, atau continuity SH.

Model/provider execution juga harus memiliki explicit operational handling untuk execution failure, timeout, dan fallback ketika tersedia. Failure tidak boleh mengubah SH identity atau authority.

---

### 2.8 File & Multimodal Boundary

File dan multimodal capability harus memiliki lifecycle yang terpisah dan dapat diverifikasi.

Minimum lifecycle:

```
Select / Capture
 ↓
Metadata
 ↓
Local Preview
 ↓
Upload
 ↓
Processing
 ↓
Result
 ↓
Failure / Retry / Cancel
```

Boundary harus mendukung:

- file;
- image;
- camera;
- metadata;
- local preview;
- upload;
- processing;
- cancellation;
- retry;
- failure;
- permission denial;
- offline interruption.

Permission denial, cancellation, failure, retry, dan offline interruption merupakan keadaan operasi yang harus dapat direpresentasikan dan ditangani secara eksplisit; tidak boleh diperlakukan sebagai happy-path exception yang hilang dari boundary.

Storage/provider tidak boleh menjadi bagian dari semantics capability.

---

### 2.9 Tools / Hands / Authority Boundary

Capability execution wajib mengikuti boundary:

```
SH
 ↓
Capability / Tool / Hand
 ↓
Authorization / Risk Gate
 ↓
Execution
 ↓
Connector / Adapter
 ↓
External Provider / Tool / MCP
 ↓
Normalized Result
 ↓
Audit
```

Invariant:

- Tool ≠ Authority
- Hand ≠ Authority
- Connector ≠ Authority
- MCP ≠ Authority
- Provider ≠ Authority
- UI Confirmation ≠ Authorization

Tool lifecycle harus dapat direpresentasikan secara eksplisit:

```
Register → Validate → Ready → Invoke → Complete → Log → Disable → Remove
```

Minimal failure handling untuk tool harus mencakup:

- invocation failure;
- output validation failure;
- timeout;
- fallback jika tersedia.

Action lifecycle harus dapat direpresentasikan secara eksplisit:

```
Planned → Queued → Running → Waiting → Completed → Cancelled → Failed → Archived
```

Action harus mendukung cancellation, failure handling, validation, logging, dan audit. High-risk action tetap:

```
PLAN → AUTHORIZATION → CONFIRMATION → EXECUTE → AUDIT
```

Tool result harus diperlakukan sebagai external/untrusted result dan tidak boleh menjadi system instruction.

Framework tidak boleh mengambil alih authority.

Plugin atau extension tidak boleh menjadi jalan pintas untuk melewati authorization dan governance SH.

---

### 2.10 Connector / Adapter Boundary

External integration wajib menggunakan boundary adapter/connector.

```
SH Capability
      ↓
Contract
      ↓
Adapter / Connector
      ↓
External System
```

Credential dan provider-specific implementation berada di sisi integration boundary.

Capability SH tidak boleh bergantung langsung pada semantics provider apabila adapter boundary dapat digunakan.

---

### 2.11 MCP Boundary

MCP digunakan sebagai integration protocol ketika capability SH memang membutuhkannya.

Boundary:

```
SH Runtime
 ↓
MCP Client Boundary
 ↓
MCP Server
 ↓
Tool
 ↓
Normalized Result
 ↓
SH
```

MCP tidak menjadi authority SH.

Tool result yang datang melalui MCP tetap merupakan external/untrusted result dan harus melalui validation serta governance SH sebelum digunakan.

MCP juga tidak disamakan dengan plugin system.

---

### 2.12 Plugin / Extension Boundary

Plugin atau extension merupakan implementation/integration mechanism, bukan authority SH.

Plugin/extension:

- tidak boleh menjadi sumber SH semantics;
- tidak boleh melewati authorization atau governance;
- tidak boleh menerima credential di luar boundary yang ditetapkan;
- tidak boleh membuat direct coupling dari capability ke provider apabila adapter/connector boundary tersedia;
- harus dapat diisolasi, diganti, atau dinonaktifkan tanpa merusak capability yang tidak bergantung padanya.

---

### 2.13 Native Platform Boundary

Native platform capability diperbolehkan ketika diperlukan oleh SH.

Contoh:

- Android API;
- iOS API;
- secure storage;
- filesystem;
- camera;
- notification;
- background capability;
- local inference;
- device capability.

Boundary:

```
Flutter
 ↓
Platform Boundary
 ↓
Android / iOS Native Implementation
```

Platform operation harus dapat merepresentasikan:

- permission denial;
- capability unavailable;
- cancellation;
- interruption;
- failure;
- background/platform constraint.

Native implementation tidak boleh memindahkan SH semantics ke platform layer.

---

### 2.14 Local Storage / Offline Boundary

SH harus memiliki architectural capability untuk local/offline operation.

Boundary:

```
Remote State
 ↓
Local State
 ↓
Offline Read / Operation
 ↓
Pending Mutation / Queue
 ↓
Reconnect
 ↓
Synchronization / Reconciliation
 ↓
Recovery
```

Local/offline behavior harus mempertimbangkan:

- local data scope;
- offline read;
- queued mutations;
- synchronization;
- conflict policy;
- authentication / session behavior offline;
- interrupted-sync recovery;
- offline/error semantics.

Local storage harus memperhatikan:

- privacy;
- secure storage;
- encryption bila diperlukan;
- migration;
- corruption;
- recovery;
- synchronization;
- data ownership.

Local state tidak boleh otomatis dianggap sebagai authoritative state hanya karena tersedia secara lokal.

Synchronization dan reconciliation harus mempertahankan ownership dan authority SH.

Full offline parity bukan prerequisite seluruh application.

Yang menjadi boundary adalah kemampuan untuk menambahkan bounded offline capability tanpa fundamental rewrite.

---

### 2.15 Local GGUF / Runtime Boundary

Local model/runtime merupakan runtime implementation, bukan authority SH.

Boundary:

```
SH
 ↓
Model / Runtime Contract
 ↓
Local Runtime Adapter
 ↓
GGUF / Local Inference Runtime
 ↓
Normalized Result
 ↓
SH
```

Feature SH tidak boleh bergantung langsung pada detail GGUF/runtime tertentu.

Local inference dapat menggunakan native/platform integration apabila diperlukan.

---

### 2.16 Security & Privacy Boundary

Technology implementation wajib mendukung:

- secure credential handling;
- session invalidation;
- authenticated/unauthenticated state;
- owner-scoped authorization;
- default deny;
- private-data isolation;
- secure local storage;
- least privilege;
- sensitive logging control;
- provider secret isolation;
- secure file handling;
- explicit platform permission handling.

Credential provider tidak boleh masuk ke SH semantics.

**Provider credential ≠ SH identity.**

Permission platform juga tidak sama dengan authorization SH.

Authorization harus tetap dipisahkan dari platform permission dan UI confirmation; keduanya tidak boleh menjadi shortcut untuk melewati SH authorization.

---

### 2.17 Lifecycle Boundary

Application harus dapat merepresentasikan lifecycle SH secara terpisah dari implementation storage.

Technology tidak boleh mengasumsikan:

**DECOMMISSION = IMMEDIATE PERMANENT DELETE**

Lifecycle, persistence, recovery, suspension, deactivation, deletion, dan decommission harus tetap mengikuti semantics SH.

---

### 2.18 Testing & Verification Boundary

Technology stack wajib mendukung verification bertingkat:

```
Unit
 ↓
Contract
 ↓
Integration
 ↓
Runtime / Application
 ↓
E2E
 ↓
Build / Artifact Verification
```

Status berikut harus dibedakan:

- Specified
- Designed
- Implemented
- Integrated
- Persisted
- Verified
- E2E Verified

Tidak boleh menyamakan:

- Code exists = Working
- Build PASS = Feature PASS
- Historical PASS = Current PASS
- UI terlihat benar = Behavior Verified

---

### 2.19 Build & CI Boundary

CI utama SH:

**GitHub Actions**

Minimum build path:

```
Clean Checkout
 ↓
Dependency Resolution
 ↓
Static Checks / Tests
 ↓
Android Build
 ↓
APK / AAB
 ↓
Artifact Verification
```

Android menjadi target delivery awal.

CI tidak boleh bergantung pada paid service sebagai prerequisite core development.

Development environment harus tetap dapat bekerja dengan constraint:

- zero-budget;
- zero-hardware.

iOS tetap menjadi architectural target, tetapi hardware iOS bukan prerequisite development saat ini.

---

### 2.20 Dependency Boundary

Dependency eksternal harus:

- memiliki tujuan jelas;
- berada pada layer yang tepat;
- tidak menyebarkan provider semantics;
- tidak menjadi global coupling tanpa alasan;
- dapat diganti bila diperlukan;
- tidak menjadi single point of failure bagi capability yang tidak terkait.

Library/framework/package bukan bagian dari SH semantics.

Dependency version dan transitive dependency harus tetap terkontrol agar perubahan dependency tidak menghasilkan propagation yang tidak terukur ke capability lain.

---

### 2.21 Portability Boundary

SH harus memisahkan secara wajar:

- SH Domain
- SH Contracts
- Capability Semantics
- Application
- Provider Adapter
- Platform Integration

Framework-specific implementation diperbolehkan.

Framework-specific coupling yang mengubah SH semantics menjadi dependency framework tidak diperbolehkan.

---

### 2.22 Change Isolation Boundary

Perubahan implementation harus dibatasi pada boundary yang terdampak.

Perubahan dependency, provider, platform implementation, atau capability tidak boleh secara default memaksa perubahan pada area yang tidak memiliki contract dependency.

Setiap propagation lintas-boundary harus dapat ditelusuri melalui dependency atau contract yang nyata.

Target:

```
Change X
   ↓
X Boundary
   ↓
X Implementation
   ↓
Explicitly affected contracts only
```

bukan:

```
Change X
 ↓
Global State
 ↓
Multiple Unrelated Features
 ↓
Regression
```

---

## 3. Decisions

### 3.1 Application Foundation

**FINAL: Flutter**

Flutter + Dart menjadi application foundation SH.

---

### 3.2 Backend

**FINAL: Supabase + PostgreSQL**

Digunakan sebagai current backend implementation di balik backend boundary SH.

Supabase tidak menjadi bagian dari SH identity atau SH semantics.

---

### 3.3 CI / Build

**FINAL: GitHub Actions**

Digunakan sebagai CI/build boundary utama SH.

Android adalah target delivery awal.

---

### 3.4 AI Architecture

**FINAL: Provider-independent architecture**

AI provider harus berada di belakang model/runtime contract dan adapter boundary.

Remote provider dan local runtime merupakan implementation path.

---

### 3.5 Local Runtime

**FINAL: Local runtime berada di belakang runtime boundary**

GGUF/local inference tidak boleh menjadi dependency langsung application feature.

---

### 3.6 External Integration

**FINAL: Adapter / Connector boundary**

External provider, service, API, tool, dan integration tidak boleh menjadi SH authority.

---

### 3.7 MCP

**FINAL: MCP sebagai integration boundary ketika diperlukan**

MCP bukan authority dan bukan pengganti governance SH.

---

### 3.8 Plugin / Extension

**FINAL: Plugin / extension berada di belakang integration boundary**

Plugin atau extension tidak boleh mengambil alih SH authority, semantics, authorization, atau governance.

---

### 3.9 Native Integration

**FINAL: Native platform integration diperbolehkan**

Native Android/iOS implementation digunakan melalui boundary Flutter ↔ platform.

---

### 3.10 File & Multimodal

**FINAL: File & multimodal capability menggunakan explicit lifecycle boundary**

Boundary wajib mampu menangani:

- file;
- image;
- camera;
- metadata;
- local preview;
- upload;
- processing;
- cancellation;
- retry;
- failure;
- permission denial;
- offline interruption.

---

### 3.11 Local Storage / Offline

**FINAL: Offline-capable architecture**

Architecture harus memungkinkan bounded local/offline capability dan reconciliation tanpa fundamental rewrite.

Local storage wajib mempertahankan privacy, secure storage, encryption bila diperlukan, migration, corruption handling, recovery, synchronization, dan data ownership.

---

### 3.12 Security & Privacy

**FINAL: Security dan privacy berada pada explicit SH boundary**

Credential, permission, session, authorization, private data, local storage, file handling, dan provider secret harus dipisahkan dari SH semantics dan ditangani melalui boundary masing-masing.

---

### 3.13 UI / UX Direction

**FINAL: Modern, distinctive, clean SH experience**

Historical UI tidak menjadi template.

SH dibangun sebagai fresh application experience menggunakan capability dan semantics SH yang sudah ditetapkan.

---

### 3.14 Change Isolation

**FINAL: Local change by default**

Perubahan capability harus tetap lokal kecuali contract dependency yang nyata memang membutuhkan propagation.

Target architecture:

```
Change X
   ↓
X Boundary
   ↓
X Implementation
```

bukan:

```
Change X
 ↓
Global State
 ↓
Multiple Unrelated Features
 ↓
Regression
```

---

### 3.15 Technology Authority

Dokumen ini menjadi technology boundary authority untuk SH.

Technology implementation wajib tunduk pada:

```
SH Canonical
      ↓
Technology Boundaries
      ↓
Implementation Architecture
      ↓
Implementation
      ↓
Verification
```

Technology tidak boleh mengubah Canonical.

---

### 3.16 Final Technology Stack

| Area | Final Technology / Boundary |
|---|---|
| Application Foundation | Flutter |
| Application Language | Dart |
| UI / Rendering | Flutter |
| Backend | Supabase |
| Database | PostgreSQL |
| CI / Build | GitHub Actions |
| Android Delivery | APK / AAB |
| AI | Provider-independent |
| Remote AI | Provider Adapter Boundary |
| Local AI | Local Runtime / GGUF Boundary |
| External Integration | Adapter / Connector |
| MCP | MCP Integration Boundary |
| Plugin / Extension | Integration Boundary |
| Native Platform | Flutter ↔ Native Platform Boundary |
| File / Multimodal | Explicit Capability Lifecycle Boundary |
| Local / Offline | Local State + Reconciliation Boundary |
| Security | SH Authorization / Privacy Boundary |
| Verification | Unit → Contract → Integration → E2E → Artifact |

---

## FINAL

SECOND HEAD menggunakan **Flutter** sebagai application foundation.

Seluruh teknologi lain berada di belakang boundary masing-masing dan tidak boleh mengambil alih semantics, identity, authority, atau governance SH.

Target foundation:

```
SH CANONICAL
                      ↓
               SH CONTRACTS
                      ↓
          ┌─────────────────────┐
          │   FLUTTER + DART    │
          │   APPLICATION       │
          └─────────────────────┘
             ↓        ↓       ↓
          Backend   Runtime   UI
             ↓        ↓
         Supabase   Adapter
          /PGSQL      ↓
                   Provider
                   / Native
                   / Local
                   / MCP
```

**Status: NON-CANONICAL**

**Branch: dev**
