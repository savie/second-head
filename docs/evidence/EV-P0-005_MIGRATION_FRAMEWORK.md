# EV-P0-005 — MIGRATION FRAMEWORK (BL-P0-005)

Project: SECOND HEAD — SYSTEM BUILD
Evidence ID: EV-P0-005
Backlog Item: BL-P0-005 (Migration Framework)
AC Ref: AC-INFRA-05
Phase: Phase 0
Status: DONE / PASS (Owner-verified)
Date: 2026-08-09
Supabase Project: second-head (ref: pkhkgvsrqeupvwoqjwmd, region: ap-northeast-2)

## 1. Purpose
Evidence bahwa migration framework (BL-P0-005) terinstansiasi di repository sebagai
framework repository-ready, tanpa schema aplikasi, tanpa eksekusi SQL, tanpa setup tooling.

## 2. Framework Instantiation (Repository)
File yang dibuat oleh change ini:
- database/MIGRATION_FRAMEWORK.md — standar framework (canonical directory, naming,
  ordering, immutability, source-of-truth, workflow, separasi BL-P0-005 vs BL-P0-016).
- database/migrations/.gitkeep — track direktori migrations canonical yang kosong.

## 3. Explicit Statements (Verified)
- Schema aplikasi KOSONG; tidak ada tabel aplikasi di repository maupun remote.
- Tidak ada migration SQL aplikasi yang dibuat; database/migrations/ hanya berisi .gitkeep.
- Platform artifacts rls_auto_enable / ensure_rls adalah artifact platform Supabase;
  BUKAN migration aplikasi; tidak ditangkap dan tidak direplikasi.
- Baseline migration aplikasi DEFERRED sampai schema aplikasi pertama diperkenalkan
  (diperkirakan Phase 1 identity schema).
- Tooling/execution (apply, CLI, CI) DEFERRED ke BL-P0-016; tidak ada tooling yang dibuat.
- Tidak ada perubahan Supabase, eksekusi SQL, migration apply, atau perubahan
  RLS/function/trigger di bawah item ini.

## 4. Conventions Established (ringkasan; teks penuh di database/MIGRATION_FRAMEWORK.md)
- Canonical directory: database/migrations/.
- Naming: YYYYMMDDHHMMSS_<snake_case_description>.sql (UTC, monotonik).
- Ordering/versioning: leksikografis = kronologis; versioning implisit timestamp.
- Forward-only: migration committed immutable; koreksi = migration baru.
- Source-of-truth: Git; remote DB = applied state yang konvergen via workflow terkontrol.
- Workflow: author -> review (Sprint Gate) -> apply via tooling BL-P0-016 -> verify + evidence.

## 5. Separation BL-P0-005 vs BL-P0-016
- BL-P0-005 = framework (struktur + konvensi + aturan + workflow). DONE di sini.
- BL-P0-016 = tooling/execution. DEFERRED; tidak disentuh.

## 6. Verification Method
- Inspeksi repository read-only: database/migrations/ ada dan ter-track Git.
- Dokumen framework ada dan konsisten dengan final verification yang disetujui Owner.
- Commit change ini hanya berisi file BL-P0-005 (tidak ada perubahan Supabase/schema).
- Push TIDAK dilakukan; commit tetap lokal sesuai instruksi Owner (batch push deferred).

## 7. Conclusion / Status
BL-P0-005 = DONE / PASS (Owner-verified).
Migration framework repository-ready; baseline aplikasi dan tooling tetap deferred
sebagaimana tercatat di atas.

## 8. Sign-off
| Role | Name | Date | Decision |
|---|---|---|---|
| Implementation Agent | [AI] | 2026-08-09 | SUBMITTED |
| Owner / Gatekeeper | [Owner] | 2026-08-09 | APPROVED — DONE / PASS (Owner-verified) |
