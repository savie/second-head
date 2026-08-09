# EV-P0-001 — SUPABASE PROJECT SETUP (BL-P0-001)

Project: SECOND HEAD — SYSTEM BUILD
Evidence ID: EV-P0-001
Backlog Item: BL-P0-001 (Supabase Project Setup)
AC Ref: AC-INFRA-01
Phase: Phase 0
Status: DONE / PASS (Owner-verified)
Date: 2026-08-08
Supabase Project: second-head (ref: pkhkgvsrqeupvwoqjwmd, region: ap-northeast-2)
Evidence Type: Archive / Traceability
Version: v1.0

## 1. Purpose
Record ini adalah arsip/traceability untuk BL-P0-001.
Ia mencatat APA yang diverifikasi, OLEH SIAPA, dan di mana raw evidence berada.
Record ini TIDAK berisi secret, token, atau raw output sensitif.

## 2. Verification Basis (Owner-verified)
Status DONE/PASS berasal dari verifikasi langsung Owner, bukan klaim AI.

V1 — Project exists & active
- Project Supabase baru "second-head" dibuat, terpisah dari SH Lite legacy.
- Status: Healthy. Region: ap-northeast-2.
- Diverifikasi Owner via Supabase Dashboard.

V2 — Auth basic function
- Owner menjalankan signup + signin via curl di Termux dengan email test terpisah.
- access_token berhasil diperoleh.
- Raw output disimpan lokal (disensor), TIDAK masuk Git.

V3 — Environment separation
- Dev project terpisah dari SH Lite legacy (fbiazqbrkwovzrirnzpb).
- Tidak ada business schema / identity schema / RLS business policy pada langkah ini.

V4 — Repository linkage
- Repo GitHub savie/second-head, branch dev, SSH verified.
- Record ini di-commit ke dev dan di-push ke origin/dev.

## 3. OQ-01 Resolution (Owner Decision, BUKAN ADR)
- OQ-01 (Technology Stack) = RESOLVED oleh keputusan eksplisit Owner.
- Keputusan: baseline stack SH = React Native + Expo, Supabase PostgreSQL,
  Supabase Edge Functions (Deno), Groq (initial provider).
- SH Lite V2.0/V2.1 = reference/inherited knowledge saja, BUKAN blueprint.
- Ini keputusan Owner yang dicatat untuk traceability. BUKAN ADR dan tidak membuat ADR baru.

## 4. Raw Supporting Evidence (Local Only, NOT in Git)
- Raw output Termux V1–V4 (disensor) disimpan lokal oleh Owner.
- Screenshot (disensor) disimpan lokal oleh Owner.
- Keduanya hanya supporting evidence; sengaja TIDAK masuk Git agar tidak ada secret/token di repository.

## 5. Secrets Hygiene
- Tidak ada API key, anon key, service role key, access token, atau password di repository ini.
- File .env lokal tetap lokal dan ter-gitignore.

## 6. Traceability
- Authority: SECOND_HEAD_SH_FULL_EXECUTION_STRATEGY_v1.0 §5 (Phase 0), BL-P0-001 / AC-INFRA-01.
- Phase -1 compiled: SECOND_HEAD_PHASE_MINUS_1_v1.0 (FINAL).
- Downstream: BL-P0-002..BL-P0-010 terbuka oleh record ini (tunduk verifikasi masing-masing).

## 7. Status
BL-P0-001 = DONE / PASS (Owner-verified).
Record ini hanya arsip/traceability; tidak mengubah arsitektur, scope, atau canonical authority.