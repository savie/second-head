# MIGRATION FRAMEWORK — SECOND HEAD (SH)

Document Type: Development Standard (Repository Foundation)
Backlog Item: BL-P0-005 (Migration Framework)
AC Ref: AC-INFRA-05
Phase: Phase 0
Status: ACTIVE (Owner-verified 2026-08-09)
Companion Evidence: docs/evidence/EV-P0-005_MIGRATION_FRAMEWORK.md

## 1. Purpose & Scope
Dokumen ini mendefinisikan migration framework untuk schema aplikasi SECOND HEAD:
struktur, naming, ordering, immutability, source-of-truth, dan workflow.
Dokumen ini TIDAK mendefinisikan schema aplikasi dan TIDAK mendefinisikan
tooling/execution (tooling/execution = BL-P0-016, deferred).

Out of scope (eksplisit):
- Perubahan schema Supabase, eksekusi SQL, migration apply (deferred).
- Supabase CLI setup dan direktori supabase/ (bukan canonical; deferred).
- Platform artifacts (rls_auto_enable, ensure_rls) = artifact platform Supabase,
  BUKAN migration aplikasi; tidak pernah ditangkap/direplikasi di sini.

## 2. Canonical Directory
- database/migrations/ adalah SATU-SATUNYA lokasi canonical migration schema aplikasi.
- Git (repository) = source-of-truth definisi schema aplikasi.
- Database remote (Supabase second-head) = applied state; harus konvergen ke
  repository melalui workflow terkontrol di bawah.
- Schema aplikasi saat ini KOSONG; database/ belum berisi schema aplikasi.

## 3. Naming Convention
Format file migration:
    YYYYMMDDHHMMSS_<snake_case_description>.sql
- Timestamp = UTC, 12 digit, monotonically increasing.
- Contoh: 20260809120000_create_accounts_table.sql
- Ekstensi WAJIB .sql; file non-SQL bukan migration.

## 4. Ordering / Versioning
- Ordering = urutan leksikografis nama file (= kronologis timestamp).
- Migration baru WAJIB memiliki timestamp lebih besar dari migration committed mana pun.
- Versioning implisit pada timestamp; tidak ada nomor versi terpisah.

## 5. Forward-Only / Immutability
- Migration yang sudah committed = IMMUTABLE: tidak boleh diedit, direname,
  di-reorder, atau dihapus.
- Koreksi = migration BARU (forward-only).
- Migration committed tapi belum applied: disposition wajib dicatat via
  evidence/decision record sebelum migration koreksi ditambahkan.

## 6. Source-of-Truth & No-Fiction Rules
- Git (database/migrations/) = source-of-truth perubahan schema aplikasi.
- Tidak ada migration fiktif: migration dibuat hanya jika ada perubahan schema
  aplikasi nyata yang sudah disetujui.
- Baseline migration DEFERRED sampai schema aplikasi pertama diperkenalkan
  (diperkirakan: Phase 1 identity schema). Sampai saat itu database/migrations/
  tetap kosong.
- Platform artifacts (rls_auto_enable, ensure_rls) BUKAN migration aplikasi dan
  tidak pernah ditangkap ke direktori ini.

## 7. Workflow (author -> review -> apply -> verify)
1. AUTHOR: buat YYYYMMDDHHMMSS_<desc>.sql di database/migrations/.
2. REVIEW: migration lolos Sprint Gate (architecture + security) sebelum merge.
3. APPLY: eksekusi HANYA via tooling yang disetujui (BL-P0-016). Tidak ada edit
   schema ad-hoc; tidak ada eksekusi SQL di bawah BL-P0-005.
4. VERIFY: applied state diverifikasi terhadap repository; evidence ditangkap
   (EV record / test report) sesuai Evidence Rule.
Sampai tooling BL-P0-016 ada, langkah 3-4 DEFERRED; migration (jika ada)
tidak diterapkan secara desain.

## 8. Separation: BL-P0-005 (Framework) vs BL-P0-016 (Tooling/Execution)
- BL-P0-005 (dokumen ini + direktori): struktur, konvensi, aturan, workflow.
- BL-P0-016 (deferred): tooling penerapan migration (pilihan CLI, execution
  environment, mekanisme apply/repair, integrasi CI).
- Tidak ada pemilihan/konfigurasi execution tooling dalam dokumen ini.

## 9. Constraints
- Tidak ada perubahan schema di luar framework ini (perubahan database = migration).
- Tidak ada eksekusi SQL, migration apply, atau Supabase CLI setup di bawah BL-P0-005.
- Constraint Zero Budget / Mobile-First berlaku untuk pilihan tooling (BL-P0-016).
