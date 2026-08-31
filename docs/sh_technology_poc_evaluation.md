# SH-Specific POC & Technology Evaluation

**Project:** SECOND HEAD  
**Version:** SH v1.0  
**Status:** WORKING / NON-CANONICAL  
**Branch:** `dev_temp`  
**Purpose:** Comparative proof-of-concept plan untuk memilih application framework SH.

> Dokumen ini tidak memilih framework. Dokumen ini menetapkan cara membuktikan pilihan tersebut.

---

## 1. Decision Target

Candidate utama:

1. React Native CLI / bare React Native
2. Flutter
3. Native Kotlin + Jetpack Compose
4. Kotlin Multiplatform + Compose

Target keputusan:

> Pilih application technology yang paling sedikit mempersulit SH ketika boundary penting SH diuji secara nyata.

POC bukan production implementation dan bukan pembangunan ulang historical application.

---

## 2. SH-Specific Constraints

POC harus tunduk pada:

- Android-first delivery;
- iOS/tablet harus tetap viable secara architecture;
- GitHub + GitHub Actions;
- zero-budget;
- zero-hardware;
- modern UI/UX;
- native capability access;
- local/offline;
- local GGUF;
- file/multimodal;
- security/privacy;
- provider independence;
- reproducible verification;
- Workstream E integration complexity.

Historical implementation hanya digunakan sebagai lesson/evidence.

---

## 3. POC Rules

Semua candidate harus diuji dengan scope dan acceptance criteria yang setara.

POC:

- sekecil mungkin;
- architecture-focused;
- mencakup happy path dan failure path;
- mencatat friction dan workaround;
- mencatat native/plugin dependency;
- mencatat provider dependency;
- mencatat CI impact;
- tidak membutuhkan hardware baru;
- tidak mengubah Canonical;
- tidak menjadi production code;
- tidak meng-copy historical application.

Jangan memberi nilai berdasarkan dokumentasi saja.

Bedakan:

```
DOCUMENTED
OBSERVED
MEASURED
INFERRED
UNVERIFIED
```

---

# 4. Mandatory POC Tracks

## POC-A — Modern Application Shell

Prototype yang sama pada semua candidate:

- conversation-first screen;
- message list;
- composer;
- loading;
- empty;
- error;
- attachment entry;
- responsive layout;
- tablet expansion path.

Dinilai:

- UI quality;
- responsiveness;
- state clarity;
- accessibility path;
- framework friction;
- maintainability.

Bukan dinilai dari seberapa cepat Hello World selesai.

---

## POC-B — Identity / API Boundary

Prototype:

```
Application
 ↓
authenticated session
 ↓
authorized API
 ↓
response
 ↓
Application
```

Uji:

- login/session state;
- session expiry;
- unauthorized response;
- owner-scoped request;
- credential boundary;
- error handling.

Secret provider tidak boleh masuk source aplikasi.

Tujuan: membuktikan application layer dapat tetap menjadi client tanpa mengambil alih authority.

---

## POC-C — Local / Offline

Prototype bounded:

```
remote state
 ↓
local persistence
 ↓
offline read
 ↓
queued mutation
 ↓
reconnect
 ↓
reconciliation
```

Uji minimal:

1. persist data;
2. restart application;
3. read offline;
4. mutate offline;
5. reconnect;
6. reconcile;
7. failure/recovery state.

Tidak perlu membangun synchronization engine penuh.

Dinilai:

- local storage;
- offline state;
- sync architecture;
- recovery;
- privacy/security;
- portability.

---

## POC-D — File / Multimodal

Uji:

- file/image selection;
- metadata;
- local preview;
- upload;
- processing state;
- failure/retry;
- cancellation;
- permission denial;
- offline interruption.

Dinilai lifecycle penuh, bukan sekadar picker.

---

## POC-E — Workstream E Stress Test

**Mandatory.**

Workstream E historical SH bukan sekadar function call. POC harus membuktikan bahwa application framework tidak menghalangi progression:

```
Capability
 ↓
Authority / Authorization
 ↓
Execution
 ↓
Connector / Adapter
 ↓
External Provider
 ↓
Normalized Result
 ↓
Audit
```

### E1 — Internal bounded capability

Gunakan capability internal yang:

- persistent;
- owner-scoped;
- memiliki result;
- memiliki audit/error path.

Tujuan: membuktikan application → runtime/capability boundary.

### E2 — External Connector / Adapter

Gunakan external API sederhana.

Uji:

- credential boundary;
- authorization;
- request/response normalization;
- provider failure;
- retry/error.

Connector tidak boleh menjadi authority.

### E3 — MCP

Buktikan feasibility:

```
SH Runtime
 ↓
MCP Client
 ↓
MCP Server
 ↓
Tool
 ↓
Normalized Result
 ↓
SH
```

Minimal:

- protocol/client feasibility;
- discovery/tool metadata;
- invocation;
- normalized result;
- error propagation;
- credential boundary.

Tidak perlu plugin marketplace.

### E4 — Extension / Plugin Boundary

Tidak perlu membuat plugin system.

Yang diuji:

> apakah extension/plugin layer dapat ditambahkan kemudian tanpa menjadikan framework sebagai authority dan tanpa rewrite application core?

MCP ≠ Plugin.

Connector ≠ Authority.

Tool ≠ Authority.

---

## POC-F — Local GGUF Feasibility

Uji architecture path:

```
SH
 ↓
local model/runtime
 ↓
inference
 ↓
result
 ↓
SH
```

Minimal:

- runtime boundary;
- model loading path;
- invocation;
- resource/error handling;
- offline path;
- remote fallback concept.

Jika zero-hardware membuat actual inference tidak dapat diuji, gunakan stub/mock hanya untuk architecture validation dan tandai actual inference sebagai **UNVERIFIED**.

Mock ≠ actual local inference verification.

---

## POC-G — Security / Privacy

Uji:

- secure credential storage path;
- no provider secret in source;
- authenticated/unauthenticated state;
- unauthorized capability;
- owner boundary;
- local-data handling;
- logout/session invalidation;
- sensitive error/log handling.

Security limitation yang material dapat menjadi disqualifier.

---

## POC-H — Testing / Verification

Setiap candidate minimal memiliki:

- unit test;
- integration test;
- runtime/application test;
- satu E2E path;
- build verification.

Failure path harus diuji.

Dinilai:

- reproducibility;
- determinism;
- debugging clarity;
- execution cost;
- CI compatibility;
- artifact verification.

---

## POC-I — GitHub Actions

Target:

```
clean checkout
 ↓
dependency install
 ↓
test
 ↓
build
 ↓
APK/AAB
 ↓
artifact
```

Uji:

- clean checkout;
- dependency installation;
- cache;
- tests;
- build;
- artifact upload;
- failure visibility.

Tidak boleh menjadikan local machine sebagai satu-satunya build environment.

iOS cukup diuji dari sisi architecture/build path karena zero-hardware constraint.

---

# 5. Evaluation Matrix

Gunakan skala:

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
| SH Architectural Fit | 5 |
| Native Capability Access | 4 |
| Cross-Platform Expansion | 4 |
| Modern UI / UX | 4 |
| Local / Offline / GGUF | 5 |
| Workstream E / Integration | 5 |
| GitHub Actions / Build CI | 5 |
| Verification | 4 |
| Operational Complexity | 4 |
| Ecosystem / Maintainability | 3 |
| SH Learning Transfer | 2 |
| Zero-Budget / Zero-Hardware | 5 |

Maximum:

```
250
```

Score membantu keputusan tetapi tidak menggantikan engineering judgment.

---

# 6. Disqualifiers

Candidate dapat dieliminasi bila terbukti:

1. Android artifact tidak viable melalui GitHub Actions;
2. core development membutuhkan paid service;
3. native capability access tidak credible;
4. local/offline membutuhkan major architecture rewrite;
5. Workstream E integration boundary menjadi impractical;
6. provider semantics dipaksa masuk application core;
7. security/privacy limitation tidak dapat diterima;
8. basic feasibility membutuhkan hardware baru.

---

# 7. Evidence Record

Untuk setiap track:

```
Candidate:
Version:
Environment:

POC Track:
Result:
Score:

Observed:
Measured:
Documented:
Inferred:
Unverified:

Friction:
Workaround:
Native dependency:
Plugin dependency:
Provider dependency:
CI impact:
Security impact:
Offline impact:
GGUF impact:
Workstream E impact:
Maintenance impact:

Verdict:
```

Verdict:

- PASS
- PASS WITH FRICTION
- PARTIAL
- FAIL
- UNVERIFIED

---

# 8. Fair Comparison Rule

Candidate tidak boleh dinilai berdasarkan:

- Hello World speed;
- popularity;
- historical familiarity;
- tutorial count;
- demo UI saja.

Candidate dinilai berdasarkan:

```
same scope
+
same acceptance criteria
+
same failure cases
+
same CI requirement
+
same SH boundaries
```

Jika satu candidate membutuhkan native bridge dan candidate lain tidak, catat sebagai architectural trade-off; jangan otomatis menganggap bridge sebagai failure.

---

# 9. Decision Gate

Setelah POC selesai:

```
POC evidence
 ↓
weighted scoring
 ↓
disqualifier check
 ↓
architecture review
 ↓
SH-specific trade-off review
 ↓
Technology Decision
```

Technology Decision wajib menjawab:

1. framework terpilih;
2. alasan;
3. trade-off;
4. capability yang belum terbukti;
5. migration/exit path;
6. Android impact;
7. iOS/tablet impact;
8. Workstream E impact;
9. local/offline/GGUF impact;
10. CI/cost impact.

Jika hasil dua candidate terlalu dekat, lakukan POC tambahan pada capability yang benar-benar membedakan.

---

# 10. Expected POC Order

Urutan yang disarankan:

```
A — Modern UI
 ↓
B — Identity/API
 ↓
C — Local/Offline
 ↓
D — File/Multimodal
 ↓
E — Workstream E
 ↓
F — Local GGUF
 ↓
G — Security/Privacy
 ↓
H — Testing
 ↓
I — GitHub Actions
```

Alasan:

- A cepat menguji kualitas application foundation;
- B menguji boundary dengan backend;
- C/D menguji application capability;
- E menjadi stress-test utama SH;
- F menguji future local runtime;
- G/H menguji reliability;
- I memastikan hasil benar-benar buildable dalam constraint saat ini.

Jika candidate gagal pada disqualifier sebelum seluruh track selesai, tidak perlu membuang waktu menyelesaikan seluruh POC candidate tersebut.

---

# 11. Final Rule

Technology Decision bukan:

> framework yang paling gampang dipakai.

Bukan pula:

> framework yang paling powerful di atas kertas.

Keputusan adalah:

> **framework yang paling sedikit mempersulit SH ketika architecture, capability, security, local/offline, Workstream E, CI, dan future platform expansion diuji bersama.**

Historical implementation tidak menentukan pilihan.

SH Canonical tidak berubah karena pilihan framework.

```
SH Canonical
 ↓
SH architecture / contracts
 ↓
technology boundaries
 ↓
POC
 ↓
technology decision
 ↓
fresh implementation
```

**END OF SH-SPECIFIC POC & TECHNOLOGY EVALUATION**
