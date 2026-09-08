# SECOND HEAD — Workspace Bootstrap Reconciliation

**Status:** WORKING / PROPOSED DESIGN / AUDIT RECONCILIATION  
**Authority:** Working document. Bukan Canonical dan bukan Approved Contract.  
**Branch:** `dev`  
**Scope:** Workspace bootstrap dan environment readiness untuk SH.

---

## 1. Tujuan

SH membutuhkan workspace yang dapat direkonstruksi secara konsisten ketika AI workspace baru, kosong, atau di-reset.

Bootstrap harus membedakan dengan tegas:

- environment/toolchain yang dibutuhkan workspace;
- dependency project yang dikelola manifest project;
- akses repository;
- akses backend/database;
- verification terhadap environment;
- verification terhadap implementasi SH.

Target alur:

```text
NEW WORKSPACE
      ↓
BASE BOOTSTRAP
      ↓
SH BOOTSTRAP
      ↓
REPO CHECKOUT
      ↓
PROJECT DEPENDENCIES
      ↓
ENVIRONMENT VERIFY
      ↓
SH WORKSPACE READY
```

Dokumen ini menetapkan hasil audit dan proposed design. Ini belum menjadi executable bootstrap dan belum mengunci semua keputusan implementasi.

---

## 2. Authority dan Source of Truth

Urutan authority SH tetap:

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

Workspace bootstrap tidak boleh mengubah Canonical, Contract, atau implementation hanya agar bootstrap berhasil.

Source utama yang diaudit:

- GitHub repository `savie/second-head`, branch `dev` sebagai current implementation/source of truth.
- `dev_old` hanya historical/reference evidence.
- `database/` sebagai source boundary untuk schema/migration artifacts.
- `.github/workflows/frontend-ci.yml` sebagai evidence toolchain yang benar-benar dipakai CI.
- `app/pubspec.yaml` sebagai source dependency Flutter/Dart.
- `app/scripts/` sebagai source tooling signing yang dipakai CI.
- `docs/README.md` dan `.github/sh_github_working_rules.md` sebagai repository/documentation working rules.

Bootstrap bukan source of truth baru untuk schema, contract, atau feature semantics.

---

## 3. Scope

### In scope

1. Deteksi environment.
2. Deteksi tool yang sudah tersedia.
3. Instalasi hanya untuk tool yang missing/incompatible.
4. Repository checkout/reconciliation.
5. Instalasi project dependency melalui project-native mechanism.
6. Environment verification.
7. Workspace readiness declaration.
8. Credential/access boundary tanpa mengambil alih secret management.

### Out of scope

- Migrasi database otomatis.
- `db push` otomatis.
- Perubahan schema tanpa audit dan explicit migration operation.
- Pembuatan/rotasi credential.
- Penyimpanan secret.
- Modifikasi Canonical/Contract.
- Automatic overwrite working tree.
- Verifikasi bahwa seluruh implementasi SH sudah benar.
- Penggantian CI sebagai source of truth untuk seluruh developer environment.

---

## 4. Layered Workspace Profiles

Bootstrap diusulkan menggunakan profile agar workspace tidak membawa tool yang tidak diperlukan.

### 4.1 CORE

Baseline engineering workspace:

- POSIX/Linux shell utilities yang diperlukan oleh workflow.
- Git.
- Python 3.
- pip.
- curl/wget sesuai kebutuhan bootstrap.
- `jq` bila diperlukan oleh automation/verifikasi.
- build-essential/compiler toolchain bila dibutuhkan oleh native dependency.

CORE adalah baseline repository/workspace, bukan SH application/database readiness.

### 4.2 APP

CORE + toolchain aplikasi saat ini:

- Flutter stable.
- Dart melalui Flutter SDK.
- Android SDK.
- Android build-tools.
- JDK/tooling yang menyediakan `keytool`.
- `apksigner` dari Android build-tools.

Project dependency Flutter dipasang dari `app/pubspec.yaml`, bukan di-hardcode ke bootstrap.

### 4.3 DB

CORE + database operational tooling:

- Supabase CLI.
- PostgreSQL client utilities, termasuk `psql` untuk pemeriksaan database bila diperlukan.

Supabase/PostgreSQL adalah current technology direction pada boundary database yang ada sekarang. Struktur repository tidak boleh dipaksa menjadi provider-specific `supabase/` layout.

### 4.4 FULL

Gabungan APP + DB.

Profile FULL adalah kandidat profile utama untuk workspace SH yang menjalankan audit dan implementasi lintas domain.

---

## 5. Tool Classification hasil Audit

| Tool | Status terhadap current `dev` | Dasar |
|---|---|---|
| Git | Required CORE | Repository workflow |
| Python 3 | Required CORE / APP support | Signing scripts dan automation |
| pip | Required CORE / APP support | Instalasi Python dependency tooling |
| curl/wget | Bootstrap utility | Retrieval/bootstrap operations |
| jq | Optional utility | Hanya jika verification/bootstrap membutuhkannya |
| build-essential/native compiler | Required bila dependency/platform membutuhkan | Native build support |
| Flutter | Required APP | Current application technology + CI |
| Dart | Via Flutter SDK | Current app SDK |
| Android SDK | Required APP | APK build |
| Android build-tools | Required APP | APK signing/build verification |
| JDK / keytool | Required APP | Signing verification/configuration |
| apksigner | Required APP | APK signing verification |
| Supabase CLI | Required DB | Database/migration operational work |
| PostgreSQL client / psql | Required DB | Database inspection/verification |
| Node/npm | **Not current requirement** | dev_old technology evidence only |
| Deno | **Not current requirement** | No current `dev` requirement found |
| Docker | **Not current requirement** | No current `dev` requirement found |

Absence of a current requirement berarti bootstrap tidak boleh memasang tool tersebut hanya karena pernah dipakai oleh `dev_old`.

Jika current implementation kemudian menambah dependency baru, classification harus diaudit dan diperbarui sebelum tool tersebut dianggap required.

---

## 6. Detection Rules

Bootstrap harus idempotent dan audit-first.

Untuk setiap required tool:

1. Detect apakah command tersedia.
2. Jika tersedia, baca version/health bila memungkinkan.
3. Bandingkan dengan minimum/compatible version yang benar-benar diperlukan oleh current project.
4. Jika compatible → gunakan existing installation.
5. Jika missing → install.
6. Jika incompatible → STOP atau upgrade hanya bila upgrade path sudah jelas dan aman.
7. Setelah perubahan → verify ulang.

Bootstrap **tidak boleh** melakukan blind reinstall terhadap tool yang sudah valid.

Version requirement yang belum punya evidence tidak boleh dikarang. Jika exact minimum version perlu dikunci, itu menjadi open decision/evidence task.

---

## 7. Installation Rules

### 7.1 General

- Gunakan package manager/native installer yang sesuai dengan environment.
- Install hanya komponen yang diperlukan profile.
- Hindari global package yang sebenarnya merupakan project dependency.
- Jangan menyimpan credential di script.
- Jangan print secret ke log.
- Setelah install, verify command dan version.

### 7.2 Project dependencies

Project dependency harus berasal dari manifest/source project.

Untuk Flutter:

```text
app/pubspec.yaml
        ↓
flutter pub get
        ↓
package resolution verification
```

Jangan membuat daftar dependency Flutter kedua di bootstrap.

Python dependency yang memang diperlukan oleh current CI/tooling dapat dipasang sesuai kebutuhan script. Current CI secara eksplisit memasang `cryptography` untuk signing helper.

### 7.3 Environment-specific package manager

Bootstrap implementation harus memiliki boundary yang jelas antara:

- detection;
- install;
- configure PATH/environment;
- verify.

Perbedaan OS/package manager tidak boleh mengubah semantics readiness.

Support matrix OS/package manager belum dikunci dalam dokumen ini.

---

## 8. Repository Checkout dan Reconciliation

Repository target:

```text
savie/second-head
```

Branch kerja:

```text
 dev
```

Historical branch:

```text
dev_old
```

`dev_old` tidak boleh menjadi checkout default untuk workspace implementation.

### Jika repository belum ada

Bootstrap boleh melakukan checkout/clone ke workspace yang ditentukan.

### Jika repository sudah ada

Bootstrap harus terlebih dahulu memeriksa:

- repository identity;
- current branch;
- HEAD;
- working tree state;
- remote/reference yang relevan.

Bootstrap **tidak boleh overwrite uncommitted work secara otomatis**.

Jika state ambigu atau berisiko kehilangan perubahan → STOP.

Jika branch bukan `dev`, bootstrap tidak boleh diam-diam mengganti branch ketika ada perubahan lokal yang belum aman direkonsiliasi.

GitHub adalah persistent reconciliation point antara workspace AI dan local/user workspace, tetapi local working tree tetap memiliki boundary sendiri.

---

## 9. Credential dan Privacy Boundary

Bootstrap tidak boleh meminta, menanam, atau mengirim credential user.

Secara khusus jangan memasukkan ke script/repository:

- GitHub token/password/private key;
- Supabase service-role key;
- `.env` secrets;
- keystore secrets/private keys;
- `SH_DEV_SIGNING_SEED`;
- database password;
- credential provider lain.

Bootstrap boleh melakukan **presence/access check** bila diperlukan, tetapi nilai secret tidak boleh dicetak atau disimpan oleh bootstrap.

Credential user tetap dikelola oleh user/environment yang memiliki credential tersebut.

`SH_DEV_SIGNING_SEED` adalah secret boundary CI dan bukan nilai yang boleh dibundel ke bootstrap.

---

## 10. Database Operational Readiness

DB profile menyediakan tool dan kemampuan untuk melakukan audit database, bukan izin untuk melakukan perubahan schema otomatis.

Urutan yang diusulkan:

```text
DB TOOLS AVAILABLE
        ↓
CREDENTIAL / ACCESS CHECK
        ↓
REMOTE CONNECTIVITY
        ↓
MIGRATION HISTORY READABLE
        ↓
SOURCE MIGRATIONS READABLE
        ↓
PARITY INSPECTION READY
```

Migration workflow tetap:

```text
SOURCE FILES
      ↓
REMOTE MIGRATION HISTORY
      ↓
COMPARE / RECONCILE
      ↓
EXPLICIT MIGRATION OPERATION
      ↓
VERIFY
```

Bootstrap **tidak** boleh menjalankan `db push` atau operasi migrasi otomatis sebagai bagian dari generic workspace setup.

Migration creation command/convention belum dikunci karena evidence current `dev` belum cukup untuk menetapkan satu command sebagai SH rule.

### Distinction penting

```text
DB READY
≠
DATABASE SCHEMA VERIFIED
```

DB READY hanya berarti workspace memiliki tool/access yang diperlukan untuk melakukan verification.

---

## 11. Verification Levels

Verification harus dipisahkan agar status tidak menyesatkan.

### Level A — Tool Ready

Required commands untuk profile tersedia dan compatible.

### Level B — Repository Ready

Repository benar, branch target tersedia, dan working tree aman untuk digunakan.

### Level C — Project Dependency Ready

Project dependency berhasil di-resolve menggunakan mechanism project-native.

### Level D — Environment Ready

Tool + repository + dependency + basic platform verification berhasil.

### Level E — SH Implementation Verified

Test/build/runtime/security/domain verification berhasil sesuai gate SH.

Level E bukan tanggung jawab generic bootstrap.

Dengan demikian:

```text
WORKSPACE READY
≠
SH IMPLEMENTATION VERIFIED
```

---

## 12. APP Verification Candidate

Untuk APP profile, verification minimal kandidat berdasarkan current CI:

1. `flutter --version` berhasil.
2. Android SDK/toolchain terdeteksi.
3. `keytool` tersedia.
4. `apksigner` tersedia.
5. `flutter pub get` berhasil.
6. `flutter analyze --no-fatal-warnings` berhasil.
7. `flutter test` berhasil.
8. APK debug dapat dibuild bila workspace verification memang meminta build.

CI saat ini juga melakukan Android scaffold generation dan signing verification. Itu adalah evidence CI, tetapi belum otomatis berarti semua langkah tersebut harus menjadi bootstrap requirement setiap profile APP.

---

## 13. READY Contract — Proposed

Workspace dapat dinyatakan **SH WORKSPACE READY** hanya jika:

- repository identity benar;
- target branch tersedia dan state working tree aman;
- CORE tools tersedia;
- selected profile tools tersedia;
- project dependencies berhasil di-resolve;
- basic environment verification berhasil;
- tidak ada bootstrap blocker yang unresolved.

Untuk profile DB, READY tidak berarti schema/database parity sudah PASS.

Untuk profile APP, READY tidak berarti APK E2E atau seluruh domain SH sudah PASS.

Status implementation tetap mengikuti gate SH yang terpisah.

---

## 14. STOP Conditions

Bootstrap harus STOP dan tidak melakukan destructive recovery jika:

1. repository identity tidak dapat dipastikan;
2. branch target tidak dapat direkonsiliasi secara aman;
3. working tree memiliki perubahan yang berisiko tertimpa;
4. required tool missing dan installation path tidak aman/tidak diketahui;
5. tool version incompatible dan tidak ada upgrade path yang telah diverifikasi;
6. project dependency resolution gagal;
7. required platform toolchain tidak dapat diverifikasi;
8. credential/access yang memang diperlukan untuk requested verification tidak tersedia;
9. remote database tidak dapat diverifikasi ketika DB verification memang diminta;
10. migration source/history parity mismatch ditemukan dalam operation yang meminta DB parity verification;
11. bootstrap membutuhkan secret untuk melanjutkan tetapi secret tersebut seharusnya tetap berada di user/environment boundary.

STOP berarti berhenti dan melaporkan gap. Bukan mengarang fallback yang mengubah state.

---

## 15. Relationship dengan CI

`.github/workflows/frontend-ci.yml` adalah evidence kuat untuk current APP toolchain dan verification sequence.

CI saat ini menggunakan:

- GitHub checkout;
- Flutter stable;
- Python `cryptography` untuk signing helper;
- Android tooling;
- `flutter pub get`;
- analyze;
- test;
- APK build;
- APK signing verification.

CI **tidak** menjadi bukti bahwa Supabase CLI, `psql`, Node/npm, Deno, atau Docker wajib untuk seluruh current workspace.

Sebaliknya, ketiadaan suatu tool dari CI tidak otomatis berarti tool tersebut tidak dibutuhkan oleh developer/AI workspace. Classification harus berdasarkan current workflow/domain evidence.

---

## 16. Provider Boundary

SH tidak boleh mengunci generic workspace layout terhadap satu provider hanya karena current backend technology menggunakan Supabase/PostgreSQL.

Current repository sudah memiliki boundary:

```text
database/
  README.md
  migrations/
```

Tidak ada requirement untuk membuat root `supabase/` directory hanya demi bootstrap.

Demikian pula AI/model provider bukan alasan untuk membuat bootstrap provider-specific tanpa contract/architecture decision.

---

## 17. Proposed Bootstrap Architecture

Implementasi nantinya sebaiknya dipisah menjadi layer berikut:

```text
bootstrap entrypoint
        ↓
platform detection
        ↓
tool detector
        ↓
install planner
        ↓
installer
        ↓
repo reconciler
        ↓
project dependency setup
        ↓
verification runner
        ↓
READY / STOP report
```

Setiap layer harus memiliki output yang dapat diverifikasi dan tidak boleh diam-diam melakukan destructive action.

Installer tidak menentukan semantics SH.

Repo reconciler tidak menentukan branch policy baru.

Verification runner tidak boleh mengubah PASS/FAIL hanya agar workspace dapat dinyatakan READY.

---

## 18. Open Decisions / Evidence Gaps

Hal berikut belum dikunci oleh dokumen ini:

1. OS support matrix yang benar-benar harus didukung.
2. Package manager/installation strategy per OS.
3. Exact minimum/compatible version untuk setiap external tool.
4. Apakah profile FULL menjadi default untuk SH implementation workspace.
5. Exact bootstrap entrypoint/path dalam repository.
6. Apakah bootstrap harus mendukung non-interactive/CI mode sejak versi pertama.
7. Migration creation command/convention yang resmi untuk SH.
8. Batas antara generic environment verification dan full APP build verification.
9. Apakah `jq` benar-benar required atau tetap optional setelah implementation bootstrap dibuat.

Tidak ada item di atas yang boleh diasumsikan sudah locked hanya karena masuk dalam proposed design.

---

## 19. Implementation Gate

**Bootstrap executable belum boleh dibuat hanya berdasarkan dokumen ini.**

Urutan berikut harus terjadi lebih dulu:

```text
AUDIT COMPLETE
      ↓
DESIGN / CONTRACT REVIEW
      ↓
LOCK OPEN DECISIONS YANG REQUIRED
      ↓
IMPLEMENT BOOTSTRAP
      ↓
VERIFY ON CLEAN WORKSPACE
      ↓
VERIFY IDEMPOTENCY
      ↓
VERIFY STOP / FAILURE SAFETY
      ↓
VERIFY SH WORKSPACE READY
```

Bootstrap implementation sendiri harus mengikuti SAFE EDIT RULE:

- jangan overwrite file berdasarkan fetch yang truncated;
- repository HEAD adalah source of truth;
- gunakan patch/diff/Git-native partial edit untuk file besar;
- update_file hanya bila full current content tersedia;
- setelah edit verify diff dan file integrity;
- jika safe edit tidak tersedia, STOP sebelum write.

---

## 20. Current Conclusion

Audit menghasilkan baseline yang cukup untuk membangun bootstrap design, tetapi belum cukup untuk mengunci seluruh executable behavior.

Yang sudah jelas dari current `dev`:

- Flutter/Dart adalah current application technology.
- Android tooling diperlukan untuk APK workflow.
- Python tooling dipakai oleh signing helpers.
- Supabase CLI dan PostgreSQL client relevan untuk DB operational workspace.
- Node/npm/Deno/Docker bukan current requirement berdasarkan evidence yang tersedia.
- Project dependency harus mengikuti manifest.
- Repository checkout harus aman terhadap local changes.
- Credential harus tetap di luar bootstrap.
- Generic bootstrap tidak boleh menjalankan migration mutation.
- Workspace readiness harus dipisahkan dari SH implementation verification.

**Next state:** review/lock design yang diperlukan, lalu baru implement executable bootstrap. Tidak ada perubahan Canonical pada tahap ini.
