# SECOND HEAD — GitHub Working Rules

**Repository:** `savie/second-head`  
**Primary Development Branch:** `dev`  
**Historical Reference Branch:** `dev_old`

## 1. Branch Authority

- `dev` adalah branch utama untuk active development.
- `dev_old` adalah historical/reference source.
- Jangan membuat branch baru kecuali memang diperlukan dan sudah disepakati.
- Jangan menganggap `dev_old` sebagai baseline implementation. Gunakan sebagai reference/evidence.

## 2. Default Working Mode

Semua pekerjaan repository dilakukan langsung pada `dev`.

Sebelum mengubah repository:

1. Audit state `dev`.
2. Identifikasi commit/changes terakhir.
3. Periksa struktur dan file yang relevan.
4. Cocokkan dengan Canonical dan dokumen authority yang relevan.
5. Tentukan scope pekerjaan.
6. Baru lakukan perubahan.

Jangan langsung melakukan implementation hanya berdasarkan asumsi dari sesi sebelumnya.

## 3. Source Authority

Urutan authority:

1. Canonical SH.
2. Approved Build Scope.
3. Implementation Contract.
4. Implementation Guide.
5. Execution Strategy.
6. Technology Boundaries.
7. Working architecture/planning documents.
8. `dev` implementation.
9. `dev_old` historical/reference evidence.
10. Brainstorming atau percakapan lama.

Jika terdapat konflik:
- jangan diam-diam menggabungkan;
- identifikasi konflik;
- prioritaskan authority yang lebih tinggi;
- tandai gap bila belum dapat diputuskan.

## 4. Canonical Protection

- Jangan mengubah Canonical tanpa instruksi eksplisit.
- Jangan mengubah semantics SH hanya karena kebutuhan implementation.
- Technology, framework, provider, database, runtime, MCP, dan platform bukan authority SH.
- Implementation harus mengikuti boundary, bukan mendefinisikan boundary.

## 5. Commit Discipline

Commit harus merepresentasikan logical unit of work dan menggunakan nama yang meaningful.

Contoh:

- `feat(app): establish Flutter and Dart application foundation`
- `feat(conversation): implement conversation runtime path`
- `fix(runtime): resolve runtime session handling`
- `refactor(storage): isolate local storage boundary`
- `docs(architecture): update implementation architecture`
- `chore(repo): reorganize repository structure`
- `test(runtime): add runtime contract verification`

Hindari nama seperti `fix update test changes final final2 again misc`.

Commit granular selama pengerjaan diperbolehkan. Setelah logical unit selesai dan verified, commit dapat di-squash menjadi satu commit yang bermakna.

## 6. Squash Policy

Squash digunakan untuk menjaga history `dev` tetap readable, terutama ketika satu pekerjaan menghasilkan debugging/intermediate commits yang sebenarnya merupakan satu logical change.

Tidak perlu squash setiap commit.

Target history:

```
A B C
X — Repository + Documentation Structure
Y — Flutter + Dart Foundation
Z — Next Logical Development
```

bukan kumpulan commit intermediate yang tidak bermakna.

## 7. Commit Safety

Sebelum squash atau history rewrite:

- pastikan target commit jelas;
- pastikan repository state benar;
- pastikan hasil akhir tidak berubah;
- jangan menghapus perubahan yang belum diverifikasi;
- setelah rewrite, verify branch HEAD dan repository tree.

History rewrite hanya dilakukan pada branch yang memang kita kontrol.

## 8. Implementation Rule

Jangan mencampur pekerjaan berbeda dalam satu logical commit jika dapat dihindari.

Contoh:

- `X = Repository + Documentation Structure`
- `Y = Flutter + Dart Foundation`

Satu commit boleh mencakup beberapa file/folder apabila semuanya merupakan satu logical change.

## 9. Repository Structure

Struktur folder yang sudah ditetapkan harus dipertahankan.

- Jangan membuat folder baru hanya karena folder tersebut belum berisi file.
- Folder yang sudah disediakan boleh tetap kosong sebagai architectural placeholder.
- Buat folder baru hanya apabila ada concern/capability baru yang belum memiliki boundary folder yang sesuai.
- Setiap major folder harus memiliki `README.md` atau notes yang menjelaskan tujuan, artefak, boundary/responsibility, dan exclusion bila diperlukan.
- Jangan membuat struktur mengikuti `dev_old` secara otomatis.

## 10. Documentation Rule

Dokumentasi ditempatkan berdasarkan concern.

Struktur docs saat ini:

```
docs/
├── README.md
├── canonical/
│   ├── README.md
│   ├── sh_canonical_map.md
│   ├── sh_architecture_map.md
│   ├── sh_supabase_map.md
│   └── sh_foundation_blueprint.md
├── technology/
│   ├── README.md
│   └── sh_technology_boundaries.md
└── architecture/
    ├── README.md
    └── sh_flutter_dart_architecture_and_implementation_working.md
```

Dokumen non-Canonical tidak boleh diberi kesan sebagai Canonical.

Sebelum membuat dokumen baru, tentukan:
- Purpose
- Authority
- Status
- Destination
- Relationship to existing documents

Isi dokumentasi menggunakan Bahasa Indonesia kecuali Canonical. Penamaan file menggunakan convention repository yang konsisten.

## 11. Technology Rule

Technology direction harus dibedakan dari implementation evidence.

Untuk SH saat ini:

```
Flutter + Dart
    ↓
Technology Direction
```

sedangkan:

```
Expo + bare React Native
    ↓
dev_old historical implementation evidence
```

Jangan menyatakan Flutter sudah implemented hanya karena architecture atau technology boundary sudah ditetapkan.

## 12. Verification Rule

Setiap pekerjaan implementation diverifikasi sesuai scope:

```
Changed
  ↓
Build / Type Check
  ↓
Relevant Tests
  ↓
Integration / Runtime Verification
  ↓
Final State Check
  ↓
Commit
```

Jika verification belum dilakukan, jangan menyebutnya verified.

Bedakan:
- Designed;
- Implemented;
- Integrated;
- Tested;
- Runtime Verified;
- Device Verified;
- E2E Verified.

## 13. Session Continuity Rule

Jika memulai sesi baru, jangan langsung melanjutkan implementation berdasarkan ingatan percakapan.

Mulai dengan:

1. Check current branch.
2. Check current HEAD.
3. Check recent commits.
4. Check working tree.
5. Check repository structure.
6. Read relevant source documents.
7. Identify current milestone.
8. Identify blockers/unfinished work.
9. Continue only after state is reconciled.

Jika konteks sesi dan repository berbeda, repository state menjadi evidence aktual.

## 14. Work Handoff

Setiap logical milestone sebaiknya meninggalkan state yang dapat dilanjutkan tanpa konteks percakapan sebelumnya.

Minimal jelas:
- Current state
- Completed
- Remaining
- Known blockers
- Relevant documents
- Relevant commit
- Next intended work

Jika diperlukan, tambahkan informasi tersebut ke working documentation yang relevan.

## 15. No Silent Scope Expansion

Jangan memperluas scope hanya karena menemukan sesuatu yang menarik.

Klasifikasikan temuan baru sebagai:

```
BLOCKER
GAP
DEFERRED
FOLLOW-UP
OUT OF SCOPE
```

Baru lanjut setelah impact-nya jelas.

## 16. Destructive Operations

Untuk operasi yang dapat mengubah history atau menghapus data:

```
AUDIT
  ↓
CONFIRM TARGET
  ↓
EXECUTE
  ↓
VERIFY
```

Jangan melakukan force push, branch deletion, mass file deletion, history rewrite, atau destructive migration berdasarkan asumsi.

## 17. Definition of Done

Pekerjaan dianggap selesai apabila:

- scope jelas;
- implementation selesai;
- relevant verification selesai;
- repository state konsisten;
- documentation diperbarui bila diperlukan;
- commit memiliki nama meaningful;
- tidak meninggalkan perubahan yang tidak disengaja;
- status berikutnya jelas.

## 18. Default Session Instruction

Jika dokumen ini digunakan sebagai context pada sesi baru:

**Audit current `dev` state first. Reconcile against SH authority and relevant documentation. Do not assume previous conversation state is current. Do not modify Canonical without explicit instruction. Work directly on `dev`. Keep changes scoped and structurally consistent. Use meaningful logical commits and periodically squash intermediate commits when a logical unit is complete and verified. Verify repository state after every significant operation.**

