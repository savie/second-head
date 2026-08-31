# SECOND HEAD — Candidate Evaluation / POC Results

**Status:** PRELIMINARY / NON-CANONICAL  
**Evaluation date:** 2026-08-31  
**Candidates:** React Native CLI / bare RN; Flutter; Native Kotlin + Jetpack Compose; Kotlin Multiplatform + Compose.

> Penting: dokumen ini memisahkan evidence dokumentasi/architecture dari measured POC. Tidak ada build lokal, device test, atau GitHub Actions run yang dianggap PASS hanya karena framework secara resmi mendukungnya. Area tersebut tetap `UNVERIFIED` sampai benar-benar dieksekusi.

## 1. Current Result

Belum ada Technology Decision.

Preliminary conclusion dari evidence saat ini:

- **React Native CLI / bare RN:** technically viable; native boundary kuat; Workstream E dapat memakai native modules / adapters; actual SH POC masih UNVERIFIED.
- **Flutter:** technically viable; platform channels/plugins memberi native boundary; Android APK/AAB path jelas; actual SH POC masih UNVERIFIED.
- **Native Kotlin + Jetpack Compose:** strongest Android-native fit; native capability and modern adaptive UI are direct; future iOS requires an additional platform strategy; actual SH POC masih UNVERIFIED.
- **Kotlin Multiplatform + Compose:** strongest explicit future multi-platform architecture fit; shared domain/UI plus platform-specific source sets are supported; complexity/compatibility burden must be tested; actual SH POC masih UNVERIFIED.

No candidate is disqualified by documentation evidence alone.

## 2. Evidence Review

### React Native CLI / bare RN

Official React Native documentation describes the current New Architecture native-module path using Turbo Native Modules: typed JS/TypeScript specification → Codegen → native implementation → React Native runtime. This is directly relevant to SH's native capability boundary. citeturn1search2

React Native also supports platform-specific files and native integration for Android/iOS. citeturn1search5turn1search1

**SH assessment:**

- Native capability: **SUPPORTED**
- Android/iOS boundary: **SUPPORTED**
- Connector/adapter architecture: **ARCHITECTURALLY FEASIBLE**
- MCP boundary: **UNVERIFIED** as a SH-specific integration
- Workstream E stress test: **UNVERIFIED**
- Offline architecture: **UNVERIFIED**
- GGUF/local runtime: **UNVERIFIED**
- GitHub Actions clean build: **UNVERIFIED**

### Flutter

Flutter officially supports multi-platform deployment and platform-specific integration. Platform channels allow Dart code to communicate with Kotlin/Java on Android and Swift/Objective-C on iOS; Pigeon can provide generated type-safe platform APIs. citeturn2search0turn2search2

Flutter officially documents Android App Bundle and APK generation through `flutter build appbundle` and `flutter build apk`. citeturn2search5

Flutter also supports platform plugins and separation of platform-specific code from UI code, which is relevant to SH's provider/native boundary. citeturn2search0

**SH assessment:**

- Native capability: **SUPPORTED**
- Android/iOS boundary: **SUPPORTED**
- Connector/adapter architecture: **ARCHITECTURALLY FEASIBLE**
- MCP boundary: **UNVERIFIED** as a SH-specific integration
- Workstream E stress test: **UNVERIFIED**
- Offline architecture: **UNVERIFIED**
- GGUF/local runtime: **UNVERIFIED**
- Android artifact path: **SUPPORTED**
- GitHub Actions clean build: **UNVERIFIED**

### Native Kotlin + Jetpack Compose

Google describes Jetpack Compose as the modern toolkit for native Android UI, with adaptive layouts for phones, tablets, and foldables. citeturn1search10turn1search13

Compose provides direct access to the Android application/platform environment without a cross-platform bridge. This is favorable for SH capabilities requiring Android-native APIs.

**SH assessment:**

- Native capability: **SUPPORTED / DIRECT**
- Android UI: **SUPPORTED / DIRECT**
- Tablet/adaptive UI: **SUPPORTED** citeturn1search13
- Connector/adapter architecture: **ARCHITECTURALLY FEASIBLE**
- MCP boundary: **UNVERIFIED** as a SH-specific integration
- Workstream E stress test: **UNVERIFIED**
- Offline architecture: **UNVERIFIED**
- GGUF/local runtime: **ARCHITECTURALLY STRONG; ACTUAL POC UNVERIFIED**
- iOS: **NOT PROVIDED BY JETPACK COMPOSE ITSELF**; requires separate technology/path
- GitHub Actions clean build: **UNVERIFIED**

### Kotlin Multiplatform + Compose

Official Kotlin documentation describes Kotlin Multiplatform as supporting shared business/data logic across Android, iOS, desktop, web and server, while Compose Multiplatform can additionally share UI. Platform-specific source sets remain available for APIs that cannot be shared. citeturn0search1turn0search0

Compose Multiplatform has Android and iOS targets and supports shared UI, while platform-specific APIs remain possible. citeturn0search3turn0search9

Current documentation also explicitly warns that compatibility between Kotlin Multiplatform, Gradle, Android Gradle Plugin, Compose Multiplatform and Xcode must be managed. citeturn0search10

**SH assessment:**

- Shared domain/application layer: **SUPPORTED**
- Shared UI: **SUPPORTED**
- Android/iOS: **SUPPORTED**
- Platform-specific capability: **SUPPORTED**
- Connector/adapter architecture: **ARCHITECTURALLY STRONG**
- MCP boundary: **UNVERIFIED** as a SH-specific integration
- Workstream E stress test: **UNVERIFIED**
- Offline architecture: **UNVERIFIED**
- GGUF/local runtime: **ARCHITECTURALLY STRONG; ACTUAL POC UNVERIFIED**
- CI/build compatibility: **UNVERIFIED**
- Complexity/compatibility risk: **CONFIRMED RISK AREA**

## 3. Preliminary Criteria Assessment

This is **not the final weighted score**. It records only what can responsibly be concluded before measured SH-specific execution.

| Criterion | RN CLI | Flutter | Kotlin + Compose | KMP + Compose |
|---|---|---|---|---|
| SH architectural fit | Strong | Strong | Strong | Strong |
| Workstream E boundary | Strong potential | Strong potential | Strong potential | Strong potential |
| Local/offline | Unverified | Unverified | Unverified | Unverified |
| Local GGUF/native runtime | Strong potential | Strong potential | Strong potential | Strong potential |
| Android CI | Unverified | Documented path | Standard Gradle path; unverified in SH | Gradle path; unverified in SH |
| Zero-budget fit | Potentially strong | Potentially strong | Potentially strong | Potentially strong |
| Security/privacy | Framework-feasible | Framework-feasible | Native-feasible | Native/platform-feasible |
| Native capability | Strong | Strong | Direct | Direct/platform-specific |
| Modern UI/UX | Strong | Strong | Strong | Strong |
| iOS/tablet expansion | Strong | Strong | Separate strategy needed | Strongest explicit path |
| Maintainability | Unverified | Unverified | Unverified | Compatibility burden to test |
| Exit/portability | Good with boundaries | Good with boundaries | Android-native coupling | Good if shared/platform boundaries remain disciplined |

## 4. What the Actual POC Must Still Prove

Documentation is insufficient for the following:

1. Clean GitHub Actions Android build for each candidate.
2. APK/AAB artifact generation from clean checkout.
3. SH identity boundary implementation.
4. One real backend request/persistence flow.
5. Secure local credential boundary.
6. Workstream E task/reminder stress path.
7. Connector → adapter → external tool/MCP boundary.
8. Normalized result → audit/event handoff.
9. Offline cache → pending mutation → reconnect/reconciliation.
10. File selection → upload boundary → retry.
11. Local runtime adapter boundary.
12. Unit + integration + meaningful E2E test.
13. Actual measured build time/resource burden in GitHub Actions.
14. Candidate-specific failure/recovery behavior.

## 5. POC Execution Order

To avoid wasting effort, run the highest-risk/highest-information tests first:

### POC-1 — Build / CI

Create minimal application and produce Android artifact through GitHub Actions.

### POC-2 — Workstream E

Implement only the boundary skeleton:

`UI → capability contract → authorization → tool → connector → adapter → external/MCP boundary → normalized result → audit`

Use a fake external service if necessary. The goal is architecture, not production integration.

### POC-3 — Native Capability

Exercise one Android-native capability that is relevant to SH, preferably calendar/task/reminder style functionality.

### POC-4 — Offline

Implement one read/cache/pending-write/reconnect path.

### POC-5 — Security

Test credential and private-state handling.

### POC-6 — Local Runtime Boundary

Stub the runtime if hardware/model execution is unavailable. Verify that real inference can later be substituted without changing SH contracts.

### POC-7 — Verification

Run tests and one E2E path; collect CI evidence.

## 6. Current Ranking

**No final ranking yet.**

A forced ranking before measured POC would violate the evaluation rule.

However, the current evidence suggests three distinct strategic shapes:

- **React Native CLI:** strongest continuation candidate if the goal is JS/TS application productivity plus direct native escape hatches.
- **Flutter:** strongest alternative if SH prioritizes a fresh, controlled UI/application foundation with multi-platform capability.
- **Native Kotlin + Compose:** strongest Android-first candidate with maximum native access and modern Android UI.
- **KMP + Compose:** strongest future multi-platform candidate, but also the candidate with the highest need to validate complexity and build/compatibility overhead.

These are **preliminary engineering hypotheses**, not Technology Decision.

## 7. Current Decision Gate

`PRELIMINARY EVIDENCE → POC EXECUTION REQUIRED → MEASURED EVIDENCE → WEIGHTED EVALUATION → DISQUALIFIER REVIEW → TECHNOLOGY DECISION`

**STOP CONDITION:** Jangan memilih framework berdasarkan dokumen ini saja.

**END**
