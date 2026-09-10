# SECOND HEAD — GitHub Working Rules

**Repository:** `savie/second-head`  
**Primary Development Branch:** `dev`  
**Historical Reference Branch:** `dev_old`

## 0. Agent AI
Gunakan workspace dengan akses penuh.

Repository:
https://github.com/savie/second-head

Branch kerja:
dev

Requirement wajib:
- GitHub workspace aktif
- Bisa read repository
- Bisa edit file
- Bisa create file
- Bisa delete file jika diperlukan
- Bisa commit perubahan langsung ke branch dev
- Jangan hanya memberi instruksi

Supabase DEV:
https://supabase.com/dashboard/project/pkhkgvsrqeupvwoqjwmd

Requirement:
- Supabase connector aktif
- Bisa read schema/database
- Bisa cek migration history
- Bisa execute SQL
- Bisa apply migration
- Bisa verify function/table live

## 1. Authority

Urutan authority:

1. **Explicit Owner/User Decision**
2. Canonical SH
3. Approved Build Scope
4. Implementation Contract
5. Implementation Guide
6. Execution Strategy
7. Technology Boundaries
8. Working Architecture / Planning Documents
9. `dev` implementation
10. `dev_old` historical/reference evidence
11. Brainstorming / conversation history

Keputusan Owner/User adalah authority tertinggi. Jangan mengubah Canonical atau semantics SH tanpa keputusan eksplisit.

Jika terdapat konflik, identifikasi konflik, prioritaskan authority yang lebih tinggi, dan tandai gap bila belum dapat diputuskan.

---

## 2. Branch Authority

- `dev` adalah branch utama active development.
- `dev_old` adalah historical/reference source.
- Jangan membuat branch baru kecuali diperlukan dan disepakati.
- `dev_old` bukan baseline implementation.
- Semua pekerjaan repository dilakukan pada `dev`.

---

## 3. Default Working Mode

Sebelum implementation:

1. Audit current `dev` state.
2. Periksa commit dan perubahan terakhir.
3. Periksa struktur dan source yang relevan.
4. Cocokkan dengan authority dan dokumentasi terkait.
5. Tentukan scope, dependency, blocker, dan expected result.
6. Baru execute.

Jangan menganggap konteks percakapan sebelumnya sebagai repository state aktual.

Audit → Evidence → Contract → Implement → Verify → Commit  → Push

---

## 4. Canonical Protection

- Jangan mengubah Canonical tanpa instruksi eksplisit.
- Jangan mengubah semantics SH hanya untuk menyesuaikan implementation.
- Technology, framework, provider, database, runtime, MCP, dan platform bukan authority SH.
- Implementation mengikuti boundary SH.

---

## 5. Scope Control

Jangan memperluas scope secara diam-diam.

Temuan di luar scope diklasifikasikan sebagai:

`BLOCKER / GAP / DEFERRED / FOLLOW-UP / OUT OF SCOPE`

Pekerjaan hanya diperluas setelah impact dan relevansinya jelas.

---

## 6. Implementation Rule

Tidak ada kewajiban terhadap metode, tooling, atau bentuk edit tertentu.

Yang penting hasil akhir:

- sesuai scope dan expected result;
- sesuai authority, contract, dan boundary;
- tidak merusak bagian di luar scope;
- tidak meninggalkan perubahan yang tidak disengaja;
- dapat diverifikasi.

---

## 7. Repository Structure

Struktur repository yang telah ditetapkan harus dipertahankan.

- Jangan membuat folder baru tanpa kebutuhan architectural/capability yang jelas.
- Folder architectural placeholder boleh tetap kosong.
- Major folder harus memiliki `README.md` atau notes bila diperlukan untuk menjelaskan purpose, boundary, responsibility, dan exclusion.
- Jangan menyalin struktur `dev_old` secara otomatis.

---

## 8. Documentation Rule

Dokumentasi ditempatkan berdasarkan concern dan authority.

Sebelum membuat dokumen baru, tentukan:

- Purpose
- Authority
- Status
- Destination
- Relationship dengan dokumen existing

Dokumen non-Canonical tidak boleh diberi kesan sebagai Canonical.

Dokumentasi menggunakan Bahasa Indonesia kecuali Canonical. Penamaan mengikuti convention repository.

---

## 9. Technology Rule

Technology direction harus dibedakan dari implementation evidence.

Untuk SH:

Flutter + Dart
    ↓
Technology Direction

sedangkan:

Expo + bare React Native
    ↓
dev_old historical implementation evidence

Technology direction tidak membuktikan implementation telah selesai.

---

## 10. Change Integrity

Final repository state harus sesuai dengan intended change.

Sebelum commit pastikan:

- tidak ada perubahan di luar scope;
- tidak ada content loss;
- tidak ada accidental deletion, rename, atau move;
- file dan repository tetap valid;
- hasil sesuai expected result.

Jika hasil tidak sesuai, jangan commit.

---

## 11. Verification Rule

Verification disesuaikan dengan jenis dan scope perubahan.

Pastikan perubahan yang dinyatakan selesai benar-benar sesuai authority, contract, semantics, expected result, dan tidak merusak existing behavior di luar scope.

Bedakan status:

- Designed
- Implemented
- Integrated
- Tested
- Runtime Verified
- Device Verified
- E2E Verified

Jangan menyatakan status lebih tinggi daripada evidence yang tersedia.

---

## 12. Runtime / Backend State

Repository source, migration, database state, dan runtime behavior adalah evidence yang berbeda.

Keberadaan source atau dokumentasi tidak otomatis berarti sesuatu telah applied, integrated, tested, atau verified.

Status harus berdasarkan evidence aktual.

---

## 13. Commit Discipline

Commit harus merepresentasikan logical unit of work dan menggunakan nama meaningful.

Contoh:

- `feat(conversation): implement conversation runtime path`
- `fix(runtime): resolve runtime session handling`
- `refactor(storage): isolate local storage boundary`
- `docs(architecture): update implementation architecture`
- `test(runtime): add runtime contract verification`

Commit granular diperbolehkan selama pengerjaan. Setelah logical unit selesai dan verified, intermediate commits dapat di-squash.

---

## 14. Commit Safety

Sebelum commit atau history rewrite:

- target dan scope harus jelas;
- final result harus terverifikasi;
- tidak boleh ada perubahan yang tidak disengaja;
- repository state harus konsisten;
- history rewrite tidak boleh menghilangkan perubahan yang belum diverifikasi.

History rewrite hanya pada branch yang dikontrol.

---

## 15. Migration / Durable State

Perubahan durable seperti database migration, schema, RLS, privilege, RPC, storage, atau data harus:

- sesuai authority dan scope;
- mempertimbangkan dependency dan impact;
- diverifikasi terhadap actual state bila termasuk dalam scope.

Migration file saja bukan bukti bahwa perubahan durable telah applied atau verified.

---

## 16. Blocker

Jika prerequisite atau verification yang diperlukan belum tersedia:

- jangan menganggap pekerjaan selesai;
- jangan mengubah contract atau semantics untuk melewati blocker;
- tandai `BLOCKER` atau `DEFERRED`;
- jelaskan penyebab, impact, prerequisite, dan solusi/next action.

Pekerjaan independen yang aman tetap dapat dilanjutkan.

---

## 17. Session Continuity & Handoff

Pada sesi baru, reconcile:

- current branch;
- current HEAD;
- recent commits;
- repository state dan structure;
- relevant authority/documentation;
- current milestone;
- completed, remaining, dan blockers.

Setiap logical milestone harus meninggalkan state yang dapat dilanjutkan tanpa konteks percakapan, minimal dengan:

- Current State
- Completed
- Remaining
- Known Blockers
- Relevant Documents
- Relevant Commit
- Next Intended Work

---

## 18. Definition of Done

Pekerjaan dianggap selesai apabila:

- scope dan expected result jelas;
- implementation menghasilkan result yang diperlukan;
- relevant verification selesai;
- repository/runtime state konsisten dengan result;
- documentation diperbarui bila diperlukan;
- commit meaningful;
- tidak ada unintended changes;
- remaining work atau next state jelas.

---

## 19. Language / Working Style

Bahasa kerja:

Indonesia.

Gaya:

- natural
- langsung
- kritis
- presisi
- systemic reasoning
- tidak bertele-tele
- bahasa manusia

Jangan sekadar bilang "sudah aman".

Tunjukkan:

- apa yang diverifikasi;
- source-nya;
- state aktual;
- gap;
- blocker;
- consequence;
- next action.

---

## Default Session Instruction

Audit current `dev` state first. Reconcile against explicit Owner/User decisions, SH authority, and relevant documentation. Do not assume previous conversation state is current. Do not modify Canonical without explicit instruction. Keep scope controlled and repository structure consistent. Use any appropriate implementation method; judge completion by the correctness of the final result and available verification evidence. Do not silently change semantics, expand scope, or bypass blockers. Keep `dev` consistent and continuation-ready.
