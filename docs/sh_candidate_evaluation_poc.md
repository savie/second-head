# SECOND HEAD — Candidate Evaluation / POC

**Status:** WORKING / NON-CANONICAL  
**Purpose:** Menilai empat kandidat application foundation berdasarkan Technology Boundaries & Decision Criteria SH sebelum Technology Decision.  
**Candidates:** React Native CLI / bare RN; Flutter; Native Kotlin + Jetpack Compose; Kotlin Multiplatform + Compose.

> POC ini adalah evaluation protocol, bukan keputusan teknologi. Tidak ada kandidat yang dianggap unggul sebelum evidence diperoleh.

## 1. Evaluation Rule

Evaluasi harus menjawab satu pertanyaan utama:

> Teknologi mana yang paling sedikit membatasi SH ketika seluruh boundary diuji bersama, dengan kondisi zero-budget dan zero-hardware?

Historical implementation `dev_old` digunakan sebagai lesson/risk evidence, bukan sebagai alasan otomatis memilih teknologi yang sama.

POC harus membedakan:

`SUPPORTED` / `MEASURED` / `OBSERVED` / `INFERRED` / `UNVERIFIED`.

Tidak boleh menyamakan kemampuan teoritis dengan hasil POC.

## 2. Common POC Scope

Setiap kandidat diuji terhadap baseline capability yang sama.

### POC-A — Application Foundation

- create minimal SH application shell;
- modern navigation/layout;
- loading, empty, error states;
- responsive layout;
- separation domain/application/platform code.

**Evidence:** source structure, running app, build artifact.

### POC-B — GitHub Actions / Android Delivery

Pipeline minimal:

`checkout → dependency install → test → Android build → APK/AAB artifact`

Uji reproducibility dari clean checkout.

**Pass condition:** build dapat dilakukan tanpa paid CI/service dan menghasilkan artifact yang usable.

### POC-C — SH Identity / Backend Boundary

Simulasikan atau hubungkan flow:

`Account_ID → SH_ID → Session_ID → API → persistence`

Pastikan application tidak menjadikan framework identity sebagai SH identity.

Uji owner-scoped state dan session invalidation boundary.

### POC-D — Security / Privacy

Uji:

- credential storage boundary;
- authenticated vs unauthenticated state;
- owner-scoped access;
- private-data handling;
- sensitive logging;
- secure local secret storage where required.

**Failure yang material:** framework memaksa credential/private-data exposure ke application core.

### POC-E — Workstream E Stress Test

Ini mandatory.

Simulasikan satu capability external-action/task-reminder yang melewati:

`Capability → Authorization → Tool → Connector/Adapter → External Provider/MCP → Normalized Result → Audit`

POC tidak perlu membangun seluruh Workstream E.

Yang diuji adalah apakah application foundation memungkinkan boundary tersebut tanpa framework becoming authority.

Uji secara terpisah:

- connector;
- adapter;
- external tool;
- MCP integration point;
- plugin/extension boundary bila tersedia;
- normalized result;
- audit/event handoff.

**Catatan:** MCP, connector, adapter, dan plugin bukan hal yang sama dan tidak boleh digabung menjadi satu abstraction hanya demi POC.

### POC-F — Local / Offline

Minimal flow:

`remote read → local cache → offline read → pending mutation → reconnect → reconciliation`

Uji juga migration dan recovery boundary secara sederhana.

### POC-G — File / Multimodal

Uji:

`select → local handling → metadata → upload boundary → failure/retry`

Tidak perlu mengikat POC ke provider storage tertentu.

### POC-H — Local Runtime / GGUF Boundary

Tidak diwajibkan melakukan real inference karena zero-hardware.

Uji architecture boundary:

`SH → local runtime adapter → model/runtime → normalized result`

Jika actual model execution tidak dapat dilakukan, tandai `UNVERIFIED`, bukan PASS.

### POC-I — Testing / Verification

Minimal:

- unit test;
- integration test;
- application/runtime test;
- one meaningful E2E path;
- build verification.

Evidence harus dapat ditelusuri ke commit/run/artifact.

### POC-J — Future Platform Boundary

Evaluasi architecture untuk:

- iOS;
- tablet;
- platform-specific capability;
- shared domain/state where appropriate.

Tidak diwajibkan actual iOS build karena zero-hardware.

Yang dinilai adalah realistic expansion path dan rewrite risk.

## 3. Candidate Matrix

| Candidate | A App | B CI | C Identity | D Security | E Workstream E | F Offline | G File | H GGUF | I Testing | J Future | Overall |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| React Native CLI / bare RN | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| Flutter | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| Native Kotlin + Jetpack Compose | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| Kotlin Multiplatform + Compose | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |

Nilai final menggunakan weighted criteria pada `sh_technology_boundaries_and_decision_criteria.md`; tabel di atas adalah execution matrix, bukan pengganti weighted scoring.

## 4. Candidate-Specific Risk Questions

### React Native CLI / bare RN

- Apakah native access tetap straightforward tanpa Expo?
- Apakah Workstream E boundary tetap clean ketika connector/MCP/native modules masuk?
- Apakah local/offline dan local runtime dapat diisolasi dari React layer?
- Apakah dependency/runtime complexity tetap manageable?

### Flutter

- Apakah native integration untuk SH-specific capability tetap clean?
- Bagaimana boundary connector/MCP/native runtime dipisahkan dari Dart application layer?
- Apakah local/offline architecture tetap maintainable?
- Apakah future platform expansion memberi benefit nyata dibanding complexity tambahan?

### Native Kotlin + Jetpack Compose

- Apakah Android-first advantage cukup besar tanpa mengorbankan future iOS path?
- Apakah domain/application/platform boundaries tetap clean?
- Bagaimana portability strategy jika SH membutuhkan iOS/shared logic?
- Apakah Workstream E dan local runtime integration mendapat native advantage yang signifikan?

### Kotlin Multiplatform + Compose

- Apakah shared layer mengurangi duplication secara nyata atau justru menambah complexity?
- Apakah platform-specific capability boundary tetap jelas?
- Apakah Android delivery tetap sederhana dalam zero-hardware/zero-budget environment?
- Apakah complexity tambahan justified oleh future iOS/tablet requirements?

## 5. Disqualifier Check

Untuk setiap candidate catat:

- Android CI failure;
- paid prerequisite;
- impossible native access;
- impractical offline architecture;
- impractical Workstream E boundary;
- provider leakage;
- material security/privacy issue;
- zero-hardware blocker;
- predictable fundamental rewrite for future platforms.

Satu disqualifier material dapat menghentikan candidate tanpa menunggu total score.

## 6. Evaluation Output

Setiap candidate harus menghasilkan:

1. build evidence;
2. test evidence;
3. architecture/source evidence;
4. Workstream E evidence;
5. local/offline evidence;
6. security/privacy findings;
7. known limitations;
8. unverified areas;
9. weighted score;
10. disqualifier result;
11. engineering assessment.

## 7. Decision Gate

Candidate belum dipilih hanya karena:

- paling cepat dibuat;
- UI paling menarik;
- ecosystem paling populer;
- paling familiar;
- pernah digunakan sebelumnya.

Technology Decision dilakukan setelah evidence POC dibandingkan secara setara.

Final decision harus menjawab:

> Why is this the least constraining technology foundation for SH under current and foreseeable boundaries?

## 8. Stop Condition

POC/evaluation tidak boleh berubah menjadi production implementation.

Jangan membangun full SH capability sebelum Technology Decision disahkan.

`Candidate POC → Evidence → Evaluation → Decision → Application Architecture → Implementation`

**END**
