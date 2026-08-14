# EV-PRE-P6-001 — High-Risk Runtime Round-Trip

Project: SECOND HEAD — SYSTEM BUILD
Scope: Pre-P6 Assurance
Status: VERIFIED / DEV
Date: 2026-08-14

## 1. Objective

Close the explicit Pre-P6 assurance item requiring a real high-risk Runtime round-trip:

`confirmation_id → Runtime re-validation → execution → audit`

The concrete action used for this proof is `RECOVERY_RESTORE`, operating on an authenticated SH-owned recovery snapshot.

## 2. Implementation Surface

- `supabase/functions/runtime-p4f-006/index.ts`
- `supabase/migrations/20260814103000_p4f_006_high_risk_runtime_confirmation.sql`
- `supabase/migrations/20260814110000_p4a_004_audit_identity_policy_fix.sql`
- `app/tests/high-risk-runtime-roundtrip.mjs`
- `.github/workflows/sh-high-risk-runtime-verification.yml`

The Runtime endpoint requires a valid JWT and exposes three explicit stages:

1. `prepare` → creates a PENDING confirmation;
2. `confirm` → transitions the confirmation to CONFIRMED;
3. `execute` → revalidates identity, ownership, confirmation status, expiry, operation, and target snapshot before execution.

Execution invokes the existing authenticated recovery restore function and records a `RUNTIME_ACTION` audit event.

## 3. Actual Verification

Controlled GitHub Actions verification:

- Workflow: `SH High-Risk Runtime Round-Trip Verification`
- Run: `31809196229`
- Attempt: `2`
- Result: SUCCESS
- Verification checkout SHA: `8ac76f7f4b0d1820118992151e0e9e79824c535b`

The verification output recorded:

- SH: `78965d6c-33c2-45f1-9177-bd57b59eadf2`
- Snapshot: `836c3985-6ce6-469f-a75a-a307e47ae6cb`
- Action: `p4f006-recovery-1786717467459`
- Confirmation: `4c06d25c-45d8-4712-9625-68be761feb54`
- Confirmation status: `CONFIRMED`
- Execution status: `EXECUTED`
- Recovery event: `d20f6f4d-0189-4f22-85a1-6066473551a4`
- Audit rows verified: `3`
- Recovery outcome: `RESTORED`
- Continuity status: `RECOVERED`
- Gap code: `null`

## 4. Revalidation / Audit Evidence

The successful execution audit contains the same `confirmation_id` and records:

- confirmation creation;
- confirmation confirmation;
- high-risk execution;
- `revalidated_at` timestamp;
- resulting `recovery_event_id`.

The persisted confirmation reached `EXECUTED` state, with `confirmed_at` preceding `executed_at`.

## 5. Current-HEAD Applicability

Current `dev` is now `91bd439e6d632708dde7d328fbdc47aa2711cbe0`.

The high-risk implementation was introduced before the verification run and remains unchanged through the current `dev` commits; subsequent commits only added the audit identity policy correction and verification workflow path update.

The deployed Supabase Edge Function `runtime-p4f-006` is ACTIVE with JWT verification enabled and contains the same endpoint implementation.

## 6. Boundary / Result

This artifact proves a real authenticated Runtime high-risk round-trip for the concrete `RECOVERY_RESTORE` action.

It does not claim that every possible high-risk action is E2E verified. The proof is intentionally bounded to this concrete action.

**PRE-P6 HIGH-RISK RUNTIME ROUND-TRIP = VERIFIED.**

END OF EV-PRE-P6-001
