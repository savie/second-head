# EV-P0-002 — AUTHENTICATION CONFIGURATION (BL-P0-002)

Project: SECOND HEAD — SYSTEM BUILD
Evidence ID: EV-P0-002
Backlog Item: BL-P0-002 (Authentication Configuration)
AC Ref: AC-INFRA-02
Phase: Phase 0
Status: DONE / PASS (Owner-verified)
Date: 2026-08-08
Supabase Project: second-head (ref: pkhkgvsrqeupvwoqjwmd, region ap-northeast-2)

## 1. Scope of Verification
- Supabase Auth configuration untuk SH dev project: email/password provider + session management defaults.
- Out of scope: business schema, identity schema (SH_ID/ACCOUNT_ID), RLS business policies (deferred ke Phase 1).

## 2. Owner Decisions Recorded
- FLAG-01: Default Supabase Auth session management cukup untuk Phase 0. Tidak ada custom JWT expiry/rotation/revocation policy pada tahap ini.
- FLAG-03: Confirm email = OFF untuk development environment. Revisit sebelum production.
- FLAG-04: GitHub OAuth tetap enabled tetapi BUKAN acceptance requirement BL-P0-002; tidak dilakukan konfigurasi tambahan.

## 3. Configuration State (Verified)
- Email provider: Enabled
- Confirm email: OFF (dev decision)
- Allow new user signups: ON
- Allow anonymous sign-ins: OFF
- Allow manual linking: OFF
- GitHub OAuth: Enabled (bukan acceptance requirement; tanpa konfigurasi tambahan)

## 4. Functional Evidence (Owner-executed, Owner-verified)
- Signup via curl (email/password): SUCCESS — user dibuat, session dikembalikan.
- Signin via curl (grant_type=password): SUCCESS — access_token + refresh_token dikembalikan.
- Raw output disimpan lokal oleh Owner; tidak di-commit (repo tidak berisi secret).

## 5. Acceptance Criteria Mapping
- AC-INFRA-02 (Authentication Configuration): PASS
  - Email/password auth berfungsi (signup + signin terverifikasi).
  - Session management defaults diterima sesuai FLAG-01.
  - Postur DEFAULT DENY terjaga (anonymous sign-ins OFF).

## 6. Invariant Check
- Tidak ada canonical invariant yang dilanggar.
- Tidak ada business/identity schema diperkenalkan (SH_ID/ACCOUNT_ID deferred ke Phase 1).
- Tidak ada RLS business policy diperkenalkan pada tahap ini.

## 7. Result
BL-P0-002: DONE / PASS (Owner-verified).

## 8. References
- Authority: SECOND_HEAD_SH_FULL_EXECUTION_STRATEGY_v1.0 §5.2 (Phase 0 Scope), AC-INFRA-02.
- Related: EV-P0-001 (Supabase Project Setup).