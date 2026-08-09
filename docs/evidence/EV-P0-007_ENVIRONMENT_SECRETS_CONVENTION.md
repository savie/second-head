# EV-P0-007 — ENVIRONMENT & SECRETS CONVENTION (BL-P0-007)

Project: SECOND HEAD — SYSTEM BUILD
Evidence ID: EV-P0-007
Backlog Item: BL-P0-007 (Environment Configuration)
AC Ref: AC-INFRA-07
Phase: Phase 0
Status: DONE / PASS (Owner-verified)
Date: 2026-08-09
Supabase Project: second-head (ref: pkhkgvsrqeupvwoqjwmd, region: ap-northeast-2)

## 1. Purpose & Scope
- Evidence bahwa BL-P0-007 ditutup pada scope FINAL:
  "Application Environment & Secrets Convention only".
- Deliverable: konvensi environment + secrets aplikasi SECOND HEAD,
  diwujudkan sebagai `.env.example` (template) + dokumentasi konvensi.
- BUKAN scope: platform/security hardening Supabase, secret asli, .env real,
  Edge Function deployment, RLS/Auth/Storage change, atau pekerjaan BL lain.

## 2. Authority & Traceability
- Backlog Definition: BL-P0-007 | Environment Configuration | P0 | dep BL-P0-001 | AC-INFRA-07.
- Execution Strategy §5.2: "Environment configuration" (Infrastructure Foundation).
- Implementation Spec: A15 ENV CONFIG; A20 SECRETS & KEY MANAGEMENT.
- Implementation Spec — SECRET MANAGEMENT: secrets must not be stored in
  SOURCE CODE, LOGS, MEMORY, USER RESPONSE, PLAINTEXT DATABASE.
- FLAG-007-AC: AC-INFRA-07 tidak memiliki teks konkret di authority;
  Owner meratifikasi interpretasi closure = convention-only (RESOLVED).
- FLAG-007-SCOPE: Owner membatasi scope pada application env & secrets convention;
  platform security (SSL enforcement, network restrictions, connection logging)
  DEFERRED ke pre-production / Phase 6 (RESOLVED).

## 3. Convention Established
Klasifikasi variabel:
- [PUBLIC] boleh terekspos ke client (Expo) via EXPO_PUBLIC_*;
  tetap tidak boleh di-hardcode di source; diambil dari env.
- [SECRET] WAJIB hanya berada di runtime secret store
  (Supabase Edge Function secrets / CI secrets); tidak masuk client, Git, logs.
- [CONFIG] non-secret runtime configuration (opsional).

Aturan:
- `.env.example` = template; tidak berisi nilai asli.
- `.env` (real) = lokal saja; sudah masuk `.gitignore`.
- Secrets tidak boleh masuk: Git, source code, logs, memory, user response,
  plaintext database.
- Client hanya memegang anon key (public) + URL; service_role & provider keys
  hanya di backend / Edge Function secrets.

## 4. Actual Condition / Deliverables (commit ini)
- File baru: `.env.example` (template placeholder, tanpa nilai asli).
- File baru: `docs/evidence/EV-P0-007_ENVIRONMENT_SECRETS_CONVENTION.md` (evidence ini).
- `.gitignore` sudah meng-exclude `.env`, `.env.local`, `.env.*.local` (pre-existing).
- Tidak ada `.env` real di repo.

## 5. Actions Not Taken (by design)
- Tidak ada secret asli / nilai riil apa pun.
- Tidak ada `.env` real.
- Tidak ada perubahan Supabase / platform security (SSL, network, logging).
- Tidak ada Edge Function deployment.
- Tidak ada RLS / Auth / Storage change.
- Tidak ada pekerjaan BL lain (BL-P0-008 dst tetap menunggu GO).

## 6. Deferred
- Injeksi secret aktual saat Edge Functions dibangun (BL terkait).
- Secret/key-management tooling spesifik = open operational decision
  (Operations Spec) — tidak diputuskan sekarang.
- Environment separation (dev/staging/prod) & platform hardening = pre-production / Phase 6.

## 7. Conclusion / Status
- BL-P0-007 = DONE / PASS (Owner-verified) untuk scope convention-only.
- Closure berdasarkan Owner GO + repo evidence; bukan klaim platform hardening.

## 8. Sign-off
| Role | Name | Date | Decision |
|---|---|---|---|
| Implementation Agent | [AI] | 2026-08-09 | SUBMITTED |
| Owner / Gatekeeper | [Owner] | 2026-08-09 | APPROVED — DONE / PASS (Owner-verified) |