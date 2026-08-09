# EV-P0-004 — EXTENSION SETUP VERIFICATION (BL-P0-004)

Project: SECOND HEAD — SYSTEM BUILD
Evidence ID: EV-P0-004
Backlog Item: BL-P0-004 (Extension Setup)
AC Ref: AC-INFRA-04
Phase: Phase 0
Status: DONE / PASS (Owner-verified)
Date: 2026-08-09
Supabase Project: second-head (ref: pkhkgvsrqeupvwoqjwmd, region: ap-northeast-2)

## 1. PURPOSE & SCOPE
Evidence record untuk BL-P0-004 (Extension Setup), Phase 0 — Infrastructure & Development Foundation.
Record ini memverifikasi kondisi aktual PostgreSQL extensions pada project Supabase "second-head"
dan menetapkan keputusan bahwa tidak ada perubahan extension yang diperlukan pada Phase 0.
Read-only verification. Tidak ada perubahan Supabase, schema, RLS, migration, function, trigger,
atau konfigurasi teknis apa pun.

## 2. FACTUAL EVIDENCE (READ-ONLY, DASHBOARD)
Sumber: Supabase Dashboard → Database → Extensions (project second-head),
observasi Owner (screenshot disimpan lokal, tidak di-commit).

Enabled extensions (aktual):
| Extension | Version | Status |
| --- | --- | --- |
| pgcrypto | 1.3 | ENABLED |
| pg_stat_statements | 1.11 | ENABLED |
| uuid-ossp | 1.1 | ENABLED |
| plpgsql | 1.0 | ENABLED |

Tidak enabled (sample relevan):
| Extension | Version | Status |
| --- | --- | --- |
| vector | 0.8.2 | DISABLED |
| pgjwt | 0.2.0 (deprecated) | DISABLED |
| (seluruh extension lain) | — | DISABLED |

## 3. ANALYSIS
- pgcrypto + uuid-ossp: menyediakan UUID generation (gen_random_uuid()) untuk kebutuhan
  identity/primary key di Phase 1+. Cukup.
- plpgsql: diperlukan untuk database function/RPC (pola atomic persistence) di phase berikutnya. Cukup.
- pg_stat_statements: observability dasar. Cukup untuk Phase 0.
- vector: TIDAK diperlukan saat ini. Semantic memory / vector search berstatus BLUEPRINT/DEFERRED
  sesuai canonical (SH Core Canonical §24.6) dan non-goals SH Lite. Enable hanya jika ada consumer
  konkret di phase terkait, melalui decision record.
- pgjwt: deprecated; tidak digunakan. Authentication menggunakan Supabase Auth JWT bawaan (EV-P0-002).
- Seluruh extension enabled adalah free/built-in → konsisten dengan Zero Budget constraint.

## 4. DECISION (OWNER-APPROVED 2026-08-09)
- Mempertahankan default extension set (pgcrypto, pg_stat_statements, uuid-ossp, plpgsql)
  sebagai baseline Phase 0.
- Tidak melakukan enable/disable extension apa pun pada Phase 0.
- Kebutuhan extension tambahan (mis. vector) hanya dipertimbangkan ketika ada consumer/requirement
  konkret dari phase terkait, dan wajib melalui decision record / change control.
- BL-P0-004 dinyatakan DONE berdasarkan verifikasi read-only + keputusan Owner ini.

## 5. AC NOTE
- AC-INFRA-04 tidak memiliki teks acceptance criteria konkret di authority yang tersedia.
- Closure BL-P0-004 dilakukan berdasarkan Owner decision untuk scope Phase 0 (verification-only),
  BUKAN dengan menciptakan AC baru dan BUKAN klaim bahwa AC-INFRA-04 telah didefinisikan secara canonical.

## 6. CONSTRAINTS CHECK
- Zero Budget: ✅ (semua extension enabled free/built-in)
- Zero Hardware Cost: ✅
- Mobile-First: ✅ (verifikasi via dashboard mobile)
- No Canonical Change: ✅
- No Silent Scope Expansion: ✅

## 7. SIGN-OFF
| Role | Name | Date | Decision |
| --- | --- | --- | --- |
| Implementation Agent | AI Assistant | 2026-08-09 | SUBMITTED (draft) |
| Owner / Gatekeeper | Owner | 2026-08-09 | APPROVED — DONE / PASS (Owner-verified) |