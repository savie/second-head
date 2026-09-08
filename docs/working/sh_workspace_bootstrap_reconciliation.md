# SECOND HEAD — Workspace Bootstrap Reconciliation

**Status:** LOCKED FOR IMPLEMENTATION  
**Authority:** Working design approved for implementation. Bukan Canonical dan bukan Approved Contract.  
**Branch:** `dev`  
**Scope:** Workspace infrastructure untuk membangun, menjalankan, mengaudit, dan memverifikasi SH.

---

## 1. Tujuan

SH membutuhkan workspace yang dapat direkonstruksi secara konsisten ketika AI workspace baru, kosong, atau di-reset.

Bootstrap menyediakan environment yang diperlukan untuk **membangun SH**; bootstrap bukan bagian dari SH runtime/product capability dan bukan bukti bahwa SH sudah selesai atau terverifikasi.

Target alur:

```text
NEW WORKSPACE
      ↓
BASE BOOTSTRAP
      ↓
SH WORKSPACE BOOTSTRAP
      ↓
REPO CHECKOUT / RECONCILIATION
      ↓
PROJECT DEPENDENCIES
      ↓
ENVIRONMENT VERIFY
      ↓
SH WORKSPACE READY
```

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
- `.github/workflows/frontend-ci.yml` sebagai evidence current APP toolchain/verification.
- `app/pubspec.yaml` sebagai source dependency Flutter/Dart.
- `app/scripts/` sebagai source tooling signing yang dipakai CI.
- `.github/sh_github_working_rules.md` dan `docs/README.md` sebagai repository/documentation working rules.

Bootstrap bukan source of truth baru untuk schema, contract, atau feature semantics.

---

## 3. Locked Workspace Boundary

Workspace bootstrap berada pada **SH development infrastructure boundary**, terpisah dari SH product/runtime boundaries.

Current root boundaries:

```text
SH SYSTEM
├── app/
├── database/
├── functions/
└── runtime/

SH DOCUMENTATION
└── docs/

REPOSITORY / CI INFRASTRUCTURE
└── .github/

SH DEVELOPMENT INFRASTRUCTURE
└── devtools/
```

### Locked decision: `devtools/`

Executable workspace bootstrap akan berada di bawah root `devtools/`.

Alasan:

- `app/scripts/` sudah merupakan tooling spesifik APP dan tidak boleh menjadi general workspace boundary.
- `app/lib/capabilities/tools/` adalah SH capability boundary dan tidak boleh dicampur dengan development tooling.
- `.github/` bertanggung jawab atas repository/CI automation, bukan local workspace bootstrap.
- root saat ini tidak memiliki development-tool boundary yang lebih tepat.
- `devtools/` secara semantic berarti tooling untuk mengembangkan SH, bukan capability yang dimiliki SH.

Jangan membuat `tools/` sebagai root workspace boundary karena current app sudah memiliki `app/lib/capabilities/tools/`.

Jangan membuat root `supabase/` hanya untuk bootstrap. `dev_old` memiliki provider-specific `supabase/`, tetapi itu historical evidence dan bukan current `dev` boundary.

Untuk v1, jangan membuat subdirectory tambahan di dalam `devtools/` sebelum ada concern berbeda yang nyata.

---

## 4. Locked Target Environment

Bootstrap v1 menargetkan **Ubuntu/Linux workspace**.

Windows/macOS belum menjadi requirement v1 karena current evidence belum menetapkannya sebagai supported bootstrap target.

Perbedaan environment di luar target v1 tidak boleh diperlakukan sebagai failure SH; itu adalah unsupported bootstrap environment.

---

## 5. Locked Profiles

Bootstrap menggunakan layered profile agar workspace tidak membawa tool yang tidak diperlukan.

### CORE

Baseline engineering workspace:

- Git.
- Python 3.
- pip.
- curl/wget sesuai kebutuhan bootstrap.
- POSIX/Linux shell utilities yang diperlukan workflow.
- compiler/build toolchain bila dibutuhkan dependency/platform.

### APP

CORE +:

- Flutter stable.
- Dart melalui Flutter SDK.
- Android SDK.
- Android build-tools.
- JDK/tooling yang menyediakan `keytool`.
- `apksigner` dari Android build-tools.

### DB

CORE +:

- Supabase CLI.
- PostgreSQL client utilities, termasuk `psql` bila diperlukan untuk inspection.

Current database technology direction adalah Supabase + PostgreSQL, tetapi repository boundary tetap provider-neutral melalui `database/`.

### FULL

Gabungan APP + DB.

**FULL adalah default profile untuk SH implementation workspace.**

Profile selection tetap memungkinkan CORE/APP/DB untuk workspace yang memang tidak membutuhkan seluruh toolchain.

---

## 6. Tool Classification

| Tool | Classification | Evidence / rule |
|---|---|---|
| Git | Required CORE | Repository workflow |
| Python 3 | Required CORE / APP support | Signing scripts dan automation |
| pip | Required CORE / APP support | Python tooling |
| curl/wget | Bootstrap utility | Retrieval/bootstrap operations |
| jq | Optional | Tidak menjadi required sampai implementation membuktikan kebutuhan |
| build-essential/native compiler | Conditional | Dipasang bila dependency/platform membutuhkan |
| Flutter | Required APP | Current application technology + CI |
| Dart | Via Flutter SDK | Current app SDK |
| Android SDK | Required APP | APK workflow |
| Android build-tools | Required APP | APK build/signing verification |
| JDK / keytool | Required APP | Signing tooling |
| apksigner | Required APP | APK signing verification |
| Supabase CLI | Required DB | Database/migration operational work |
| PostgreSQL client / psql | Required DB | Database inspection/verification |
| Node/npm | Not current requirement | `dev_old` historical technology only |
| Deno | Not current requirement | No current `dev` requirement |
| Docker | Not current requirement | No current `dev` requirement |

New tool requirements must be established from current implementation/workflow evidence before being added to bootstrap.

---

## 7. Detection and Installation Contract

Bootstrap harus idempotent dan audit-first.

Untuk setiap required tool:

1. Detect availability.
2. Detect version/health bila memungkinkan.
3. Compare terhadap version requirement yang benar-benar didukung evidence.
4. Compatible → gunakan existing installation.
5. Missing → install.
6. Incompatible → STOP, kecuali ada upgrade path yang sudah jelas dan aman.
7. Verify ulang setelah perubahan.

Bootstrap tidak boleh blind reinstall tool yang sudah valid.

Exact minimum version yang belum memiliki evidence tidak boleh dikarang. Version policy dapat ditambahkan kemudian tanpa mengubah boundary bootstrap.

OS/package-manager implementation detail boleh berbeda selama semantics detection/install/verify tetap sama.

---

## 8. Repository Checkout dan Reconciliation

Repository target:

```text
savie/second-head
```

Implementation branch:

```text
dev
```

Historical branch:

```text
dev_old
```

Jika repository belum ada, bootstrap boleh checkout/clone.

Jika repository sudah ada, bootstrap wajib memeriksa:

- repository identity;
- current branch;
- HEAD;
- working tree state;
- relevant remote/reference state.

Bootstrap tidak boleh overwrite uncommitted work otomatis.

Jika branch bukan `dev` dan local state belum aman untuk direkonsiliasi → STOP.

Jika repository identity ambigu → STOP.

GitHub adalah persistent reconciliation point, tetapi local working tree tetap memiliki boundary sendiri.

---

## 9. Credential dan Privacy Boundary

Bootstrap tidak boleh meminta, menanam, mengirim, atau menyimpan credential user.

Jangan memasukkan ke script/repository:

- GitHub token/password/private key;
- Supabase service-role key;
- `.env` secrets;
- keystore secrets/private keys;
- `SH_DEV_SIGNING_SEED`;
- database password;
- credential provider lain.

Bootstrap boleh melakukan presence/access check bila requested operation membutuhkan access, tetapi secret value tidak boleh dicetak atau disimpan.

Credential tetap dikelola oleh user/environment yang memilikinya.

---

## 10. Project Dependency Boundary

Project dependency berasal dari project manifest/source, bukan daftar duplicate di bootstrap.

Untuk Flutter:

```text
app/pubspec.yaml
        ↓
flutter pub get
        ↓
package resolution verification
```

Python dependency hanya dipasang bila diperlukan oleh tooling yang benar-benar dijalankan. Current CI menggunakan `cryptography` untuk signing helper.

Bootstrap tidak boleh mengambil alih dependency management project.

---

## 11. Database Operational Boundary

DB profile menyediakan tool dan readiness untuk audit/inspection database; bukan automatic migration executor.

Urutan readiness:

```text
DB TOOLS AVAILABLE
        ↓
ACCESS CHECK
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

Bootstrap tidak boleh menjalankan `db push` atau mutation migration otomatis.

Migration creation command/convention bukan bagian bootstrap contract dan tetap mengikuti workflow database SH yang terpisah.

```text
DB READY
≠
DATABASE SCHEMA VERIFIED
```

---

## 12. Verification Contract

Verification dibagi menjadi:

### A — Tool Ready

Required tools untuk selected profile tersedia dan compatible.

### B — Repository Ready

Repository benar, branch target tersedia, working tree aman.

### C — Project Dependency Ready

Project dependency berhasil di-resolve melalui project-native mechanism.

### D — Workspace Ready

Tool + repository + dependency + basic platform verification berhasil.

### E — SH Implementation Verified

Test/build/runtime/security/domain verification berhasil sesuai SH gates.

Level E bukan tanggung jawab generic workspace bootstrap.

Dengan demikian:

```text
SH WORKSPACE READY
≠
SH IMPLEMENTATION VERIFIED
```

### APP project verification

Berdasarkan current CI, APP verification dapat mencakup:

- `flutter --version`;
- Android SDK/toolchain detection;
- `keytool`;
- `apksigner`;
- `flutter pub get`;
- `flutter analyze --no-fatal-warnings`;
- `flutter test`;
- APK debug build bila requested.

CI signing/scaffolding sequence tetap menjadi evidence CI; tidak semua langkah CI otomatis menjadi mandatory bootstrap step.

---

## 13. READY Criteria

Workspace dapat dinyatakan **SH WORKSPACE READY** jika:

- target environment supported;
- repository identity benar;
- target branch tersedia dan state working tree aman;
- CORE tools tersedia;
- selected profile tools tersedia;
- project dependencies berhasil di-resolve;
- basic environment verification berhasil;
- tidak ada bootstrap blocker unresolved.

FULL READY tidak berarti database parity PASS.

FULL READY tidak berarti APK E2E PASS.

FULL READY tidak berarti seluruh domain SH PASS.

---

## 14. STOP Conditions

Bootstrap harus STOP tanpa destructive recovery jika:

1. repository identity tidak dapat dipastikan;
2. branch target tidak dapat direkonsiliasi secara aman;
3. working tree berisiko tertimpa;
4. required tool missing dan installation path tidak aman/tidak diketahui;
5. tool incompatible dan tidak ada upgrade path terverifikasi;
6. project dependency resolution gagal;
7. required platform toolchain tidak dapat diverifikasi;
8. requested access/credential tidak tersedia;
9. requested DB verification tidak dapat mengakses remote database;
10. migration source/history parity mismatch ditemukan ketika parity verification memang diminta;
11. bootstrap membutuhkan secret yang seharusnya tetap berada di user/environment boundary.

STOP berarti melaporkan gap, bukan membuat fallback yang mengubah state secara diam-diam.

---

## 15. CI Relationship

`.github/workflows/frontend-ci.yml` adalah evidence current APP toolchain dan project verification.

CI saat ini mencakup checkout, Flutter stable, Python signing tooling, Android tooling, dependency resolution, analyze, test, APK build, dan APK signing verification.

CI tidak membuktikan bahwa Supabase CLI, `psql`, Node/npm, Deno, atau Docker wajib untuk seluruh workspace.

Sebaliknya, absence dari CI tidak otomatis berarti sebuah tool tidak dibutuhkan developer/AI workspace; classification tetap harus berbasis current workflow/domain evidence.

---

## 16. Provider Boundary

Workspace infrastructure tidak boleh mengunci SH pada provider layout tertentu.

Current database boundary:

```text
database/
  README.md
  migrations/
```

Tidak ada requirement root `supabase/` untuk bootstrap.

AI/model provider juga tidak boleh dijadikan bootstrap-specific architecture tanpa decision/contract yang relevan.

---

## 17. Locked Bootstrap Architecture

Executable implementation akan berada di:

```text
devtools/
```

Architecture minimal:

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

Tidak membuat subdirectory `devtools/` tambahan pada v1 tanpa concern berbeda yang nyata.

Setiap layer harus memiliki output yang dapat diverifikasi dan tidak boleh melakukan destructive action diam-diam.

Installer tidak menentukan semantics SH.

Repo reconciler tidak membuat branch policy baru.

Verification runner tidak memanipulasi PASS/FAIL agar workspace menjadi READY.

---

## 18. Deferred / Non-Blocking

Hal berikut belum dikunci sebagai detail implementation, tetapi **tidak memblokir boundary v1**:

1. Exact minimum/compatible version untuk setiap external tool yang belum memiliki evidence.
2. Detail package manager/native installer implementation untuk Ubuntu variants.
3. Non-interactive/CI mode bila belum dibutuhkan v1.
4. Apakah `jq` diperlukan setelah implementation nyata dibuat.

Migration creation command tetap berada di luar bootstrap scope.

Jika salah satu detail di atas terbukti memengaruhi safety/semantics, implementation harus berhenti dan design direvisi sebelum melanjutkan.

---

## 19. Implementation Gate

Design ini sekarang **LOCKED FOR IMPLEMENTATION** untuk boundary dan semantics yang telah disetujui.

Urutan implementation:

```text
LOCKED DESIGN
      ↓
IMPLEMENT devtools/
      ↓
VERIFY DIFF + FILE INTEGRITY
      ↓
CLEAN WORKSPACE TEST
      ↓
IDEMPOTENCY TEST
      ↓
STOP / FAILURE SAFETY TEST
      ↓
SH WORKSPACE READY
```

Implementation wajib mengikuti SAFE EDIT RULE:

- jangan overwrite file berdasarkan fetch yang truncated;
- repository HEAD adalah source of truth;
- gunakan patch/diff/Git-native partial edit untuk file besar;
- update_file hanya bila full current content tersedia;
- setelah edit verify diff dan file integrity;
- jika safe edit tidak tersedia, STOP sebelum write.

Tidak ada perubahan Canonical pada design lock ini.
