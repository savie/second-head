# EV-P0-008 — RLS FOUNDATION (BL-P0-008)

Project: SECOND HEAD — SYSTEM BUILD
Evidence ID: EV-P0-008
Backlog Item: BL-P0-008 (RLS Foundation)
AC Ref: AC-INFRA-08
Phase: Phase 0
Status: DONE / PASS (Owner-verified)
Date: 2026-08-09
Supabase Project: second-head (ref: pkhkgvsrqeupvwoqjwmd, region: ap-northeast-2)

## 1. Purpose & Scope
- Evidence closure BL-P0-008 (RLS Foundation) untuk Phase 0.
- Mode closure: verification-only / foundation-ready (sesuai resolusi Owner FLAG-008-AC).
- Tidak ada policy aplikasi konkret yang dibuat selama application schema kosong.
- Ini interpretasi scope Phase 0, bukan pembuatan AC canonical baru.

## 2. Authority & Traceability
- Backlog Definition: BL-P0-008 | RLS Foundation | P0 | dep: BL-P0-001 | AC-INFRA-08.
- Execution Strategy §5.2: "RLS Foundation" dalam scope Phase 0; MS-01 DoD:
  "RLS foundation & Audit table structure tersedia."
- Canonical invariants: DEFAULT ACCESS = DENY; private data isolated by default;
  owner isolation.
- FLAG-008-AC: RESOLVED (Owner) — closure verification-only / foundation-ready
  untuk Phase 0.
- FLAG-008-PATTERN: RESOLVED (Owner) — pola owner-isolation SH Lite diterima sebagai
  reference-derived convention untuk RLS aplikasi SECOND HEAD di masa depan;
  bukan pengganti atau perubahan canonical authority.

## 3. Actual Condition (Read-Only, Evidence Existing)
- Application schema: KOSONG. Tidak ada tabel aplikasi di public schema
  ("No tables in schema"; "No tables to create policies for").
- Application RLS policies: NONE (tidak ada tabel untuk di-attach policy).
- Migrations: belum ada yang diterapkan pada project baru
  (database/migrations hanya berisi .gitkeep).
- Platform artifacts (pre-existing / default Supabase):
  - Function `public.rls_auto_enable()` (event trigger function, SECURITY DEFINER,
    search_path pg_catalog).
  - Event trigger `ensure_rls` (DDL_COMMAND_END → rls_auto_enable).
  - Efek: RLS auto-enabled pada tabel baru di public schema → menopang postur
    DEFAULT DENY.
- Roles: role standar Supabase (anon, authenticated, service_role, dll.);
  tidak ada role aplikasi custom.
- Extensions relevan: plpgsql, pgcrypto, uuid-ossp enabled.
- Evidence basis: inventory read-only dashboard dari audit sebelumnya
  (Tables, Policies, Functions, Event Triggers). Tidak diperlukan screenshot baru.

## 4. Platform vs Application Separation
- PLATFORM (pre-existing / default, BUKAN application RLS):
  - rls_auto_enable + ensure_rls = artifact platform Supabase.
  - Tidak dimodifikasi, tidak dihapus, tidak diduplikasi, tidak di-capture
    sebagai application migration.
- APPLICATION (deferred):
  - Policy owner-isolation konkret = application RLS.
  - Dibuat hanya bersama schema/migration aplikasi yang membutuhkannya
    (via migration vehicle BL-P0-005).

## 5. Adopted RLS Convention (Reference-Derived, per FLAG-008-PATTERN)
Untuk RLS aplikasi masa depan (saat schema ada), konvensi yang diadopsi
(reference-derived dari SH Lite V2.1):
- Owner isolation: `auth.uid() = <owner column>` (mis. user_id; untuk tabel users: id).
- Role: `{authenticated}`.
- Policy hanya untuk operasi yang benar-benar diperlukan
  (SELECT/INSERT/UPDATE/DELETE sesuai behavior aktual).
- Tidak ada policy fiktif demi memenuhi pola.
- Append-only invariant dijaga bila diperlukan (tanpa policy DELETE bila
  invariant append-only berlaku).
- RPC/function: SECURITY INVOKER sebagai default; SECURITY DEFINER hanya dengan
  kebutuhan tervalidasi + security review.
- Identity dari authentication context (auth.uid()); tidak pernah menerima
  client-supplied owner identity.
- Konvensi ini reference-derived; tidak menggantikan atau mengubah canonical authority.

## 6. Deferred Concrete Policies
- Policy aplikasi konkret deferred sampai schema/migration aplikasi pertama yang
  membutuhkannya (Phase 1 identity schema onward).
- Delivery via migration vehicle BL-P0-005 (database/migrations), bukan ad-hoc.
- BL-P0-009 (Audit Table Foundation) tetap terpisah; RLS audit table mengikuti
  konvensi yang sama saat dibuat.

## 7. Actions Not Taken (By Design)
- Tidak membuat tabel.
- Tidak membuat RLS policy.
- Tidak ada perubahan SQL RLS.
- Tidak membuat atau menerapkan migration.
- Tidak membuat business logic.
- Tidak modify / remove / duplicate / capture rls_auto_enable / ensure_rls.
- Tidak ada perubahan konfigurasi Supabase.
- Tidak ada pekerjaan BL lain.

## 8. Conclusion / Status
- BL-P0-008 = DONE / PASS (Owner-verified) untuk scope Phase 0
  (verification-only / foundation-ready).
- RLS foundation = platform auto-RLS (postur DEFAULT DENY) + konvensi
  owner-isolation yang diadopsi + deferred concrete policies terikat
  application schema.
- Tidak ada canonical authority atau invariant yang diubah.

## 9. Sign-off
| Role | Name | Date | Decision |
|---|---|---|---|
| Implementation Agent | [AI] | 2026-08-09 | SUBMITTED |
| Owner / Gatekeeper | [Owner] | 2026-08-09 | APPROVED — DONE / PASS (Owner-verified) |