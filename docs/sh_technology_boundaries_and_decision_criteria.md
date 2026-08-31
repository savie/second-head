# SECOND HEAD — Technology Boundaries & Decision Criteria

Status: WORKING / NON-CANONICAL
Purpose: Menetapkan batas teknologi dan kriteria keputusan sebelum pemilihan application framework SH.
Scope: React Native CLI / bare RN, Flutter, Native Kotlin + Jetpack Compose, Kotlin Multiplatform + Compose.

> Dokumen ini tidak mengubah SH Canonical. Ia menerjemahkan kebutuhan dan boundary SH menjadi kriteria evaluasi teknologi.

## 1. Decision Principle

Teknologi dipilih bukan berdasarkan kemudahan membuat APK semata.

> Pilih application foundation yang paling sedikit mempersulit SH ketika boundary architecture, capability, security/privacy, local/offline, Workstream E, CI, cost, dan future platform expansion diuji bersama.

Historical implementation di dev_old adalah evidence/lesson, bukan technology authority.

## 2. Technology Boundaries

### 2.1 Application Framework
Application framework harus mendukung Android sebagai target awal, APK/AAB melalui reproducible CI, native access, modern UI/UX, local/offline capability, dan future iOS/tablet expansion tanpa fundamental rewrite.

Candidate:
- React Native CLI / bare RN
- Flutter
- Native Kotlin + Jetpack Compose
- Kotlin Multiplatform + Compose

Expo tidak menjadi default hanya karena pernah digunakan.

### 2.2 Application ≠ SH Authority
Framework/application tidak boleh menjadi source of truth untuk identity, ownership, authorization, privacy, transfer eligibility, governance, audit authority, atau provider credentials.

Boundary: Application → API / Runtime / Capability → Authority.

### 2.3 Backend Boundary
Application harus dapat berpindah backend tanpa rewrite seluruh application architecture. Boundary mencakup identity/session, authorization, persistence, audit, capability execution, dan error semantics.

Supabase saat ini merupakan implementation choice, bukan bagian immutable dari SH identity. Alternatif PostgreSQL/backend lain harus tetap feasible.

### 2.4 Provider / Infrastructure Boundary
Provider adalah dependency, bukan SH. Gunakan provider-independent contract → adapter / connector → provider.
Credential tidak boleh hardcoded, tidak menjadi application-domain state, dan tidak bocor ke client.

### 2.5 Workstream E / External Capability Boundary
Workstream E menjadi technology stress-test utama. Historical SH menunjukkan area ini dapat melibatkan task/reminder capability, external actions, connectors, adapters, MCP, plugin/extension concepts, dan provider integration.

Framework tidak harus menyediakan semuanya secara native. Yang wajib: framework tidak menghalangi architecture yang memungkinkan mekanisme tersebut ditambahkan tanpa menjadikan framework sebagai authority.

Boundary: SH Capability → Authorization → Execution boundary → Connector / Adapter → MCP / External Tool / Provider → Normalized Result → Audit.

MCP ≠ Plugin. Connector ≠ Provider. Tool ≠ Authority. Framework ≠ Authority.
Plugin/extension system penuh bukan prerequisite V1.0.

### 2.6 Local / Offline Boundary
Local capability harus dapat berdiri sebagai layer tersendiri: Remote State → Local State → Offline Operation → Queue / Pending Mutation → Reconnect → Reconciliation → Recovery.

Framework tidak boleh membuat offline architecture fundamentally impractical. Local storage harus mempertimbangkan privacy, encryption/secure storage where required, migration, corruption/recovery, synchronization, dan portability.

### 2.7 Local GGUF / Local Runtime Boundary
Local model/runtime bukan bagian dari application framework authority. Target: SH → Local Runtime Boundary → GGUF / Model Runtime → Inference → Normalized Result.

Framework harus memungkinkan native/local runtime integration tanpa architectural rewrite. Actual hardware-specific inference tetap constrained oleh zero-hardware current state, device resources, dan platform APIs. Jika actual inference belum dapat diuji, statusnya UNVERIFIED.

### 2.8 File & Multimodal Boundary
Application harus mendukung architecture untuk file selection, image/media, metadata, upload, local preview, processing, retry, cancellation, failure, dan offline interruption.
File handling tidak boleh mengunci SH pada satu storage/provider.

### 2.9 Security & Privacy Boundary
Technology harus mendukung secure credential handling, authenticated/unauthenticated states, session invalidation, owner-scoped authorization, private-data isolation, secure local storage, sensitive logging controls, dan least-privilege integration.

### 2.10 Identity Boundary
Technology tidak boleh memaksa identity model yang bertentangan dengan SH. Application harus mempertahankan Account_ID, SH_ID, Session_ID serta invariant 1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH.
Authentication identity tidak boleh disamakan dengan SH identity.

### 2.11 Lifecycle Boundary
Application architecture harus dapat merepresentasikan lifecycle tanpa mengasumsikan DECOMMISSION = IMMEDIATE PERMANENT DELETE. Lifecycle, recovery, persistence, dan deletion harus dapat dipisahkan secara architectural.

### 2.12 UI / UX Boundary
Technology harus memungkinkan modern visual language, responsive layouts, accessible interaction, loading/empty/error states, progressive capability disclosure, tablet adaptation, dan future iOS adaptation.
Historical UI bukan design authority. Can render a screen bukan bukti modern application foundation.

### 2.13 Testing & Verification Boundary
Technology harus mendukung unit, integration, application/runtime, E2E, build verification, deterministic CI where practical, dan evidence capture.

code exists ≠ integrated ≠ working ≠ persisted ≠ verified ≠ E2E verified.
Historical PASS tidak otomatis menjadi current PASS.

### 2.14 Build / CI Boundary
Current constraint: zero-budget + zero-hardware.
Minimum pipeline: clean checkout → dependency install → test → Android build → APK/AAB artifact.
GitHub Actions menjadi current CI boundary. Technology tidak boleh membutuhkan paid CI sebagai prerequisite.
iOS path harus tetap architecturally viable, tetapi actual iOS hardware build bukan current prerequisite karena zero-hardware constraint.

### 2.15 Cost / Resource Boundary
Current: zero-budget, zero-hardware, existing GitHub workflow, avoid mandatory paid infrastructure, avoid mandatory proprietary development hardware. External provider/account dependency harus dicatat.

### 2.16 Portability / Exit Boundary
Technology choice harus memiliki exit path. Pisahkan sejauh wajar: SH Domain, SH Contracts, Capability Semantics, Provider Adapters, Application UI, Platform Integration.
Framework-specific code boleh ada; framework coupling tidak boleh berubah menjadi SH architectural coupling.

## 3. Decision Criteria

Gunakan skala 0–5:
| Score | Meaning |
|---:|---|
| 0 | impossible / disqualifying |
| 1 | severe friction |
| 2 | significant workaround |
| 3 | acceptable |
| 4 | strong |
| 5 | excellent / natural fit |

| Criterion | Weight |
|---|---:|
| SH architectural fit | 5 |
| Workstream E / connectors / MCP / extension boundary | 5 |
| Local / offline architecture | 5 |
| Local GGUF / native runtime feasibility | 5 |
| GitHub Actions / Android CI | 5 |
| Zero-budget / zero-hardware fit | 5 |
| Security / privacy | 5 |
| Identity / backend boundary | 4 |
| Modern UI / UX | 4 |
| Native capability access | 4 |
| iOS / tablet expansion | 4 |
| Testing / verification | 4 |
| File / multimodal capability | 3 |
| Maintainability / ecosystem | 3 |
| Portability / exit path | 3 |
| SH learning transfer | 2 |

Maximum weighted score: 295.
Score bukan keputusan otomatis.

## 4. Disqualifiers
Candidate dapat dieliminasi jika POC membuktikan:
1. Android APK/AAB tidak dapat dibangun reproducibly melalui GitHub Actions.
2. Current development membutuhkan paid service sebagai prerequisite.
3. Native capability access tidak viable.
4. Local/offline membutuhkan fundamental architecture compromise.
5. Workstream E boundary menjadi impractical.
6. Provider credentials/semantics terpaksa masuk application core.
7. Material security/privacy limitation.
8. Zero-hardware constraint membuat baseline development impossible.
9. Future iOS/tablet path memerlukan fundamental rewrite yang dapat diprediksi sejak awal.

## 5. Evidence Hierarchy
Measured POC evidence → Observed behavior → Build/test evidence → Official documentation → Engineering inference → Opinion.
Historical implementation evidence digunakan untuk memahami risk/lesson, bukan untuk mengunggulkan framework tertentu.

## 6. Decision Gates
### Gate 1 — Feasibility
Build Android, run basic application, access required native capability, integrate API, execute tests.
### Gate 2 — SH Boundary
Identity boundary, backend boundary, provider boundary, security/privacy boundary, local/offline path.
### Gate 3 — SH Stress Test
Workstream E, connector/adapter, MCP feasibility, file/multimodal, local GGUF boundary.
### Gate 4 — Delivery
GitHub Actions, APK/AAB, artifact, reproducibility, zero-budget/zero-hardware.
### Gate 5 — Future Viability
iOS, tablet, local runtime evolution, provider replacement, backend replacement, application growth.

## 7. Technology Decision Record
Final decision wajib mencatat selected technology, rejected candidates, evidence, weighted score, disqualifier result, major trade-offs, known limitations, unverified areas, exit strategy, CI strategy, backend strategy, local/offline strategy, Workstream E strategy, GGUF strategy, dan iOS/tablet strategy.

Keputusan harus menjawab: Why is this the least constraining technology foundation for SH under current and foreseeable boundaries?

## 8. Boundary vs Implementation
Boundary ini bukan production architecture. Ia menetapkan WHAT TECHNOLOGY MUST ALLOW ≠ HOW SH WILL IMPLEMENT IT.
Implementation baru ditentukan setelah Technology Decision.

## 9. Final Decision Pipeline
SH Canonical / Contracts → Technology Boundaries → Decision Criteria → Candidate POC → Measured Evidence → Weighted Evaluation → Disqualifier Review → Architecture Review → Technology Decision → Application Architecture → Implementation

END