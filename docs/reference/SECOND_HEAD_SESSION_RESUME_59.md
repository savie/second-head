# SECOND HEAD — SESSION RESUME 59

## Audit Base

- Audit range: `a1862392d1675eace336e75646d4d1da485a8467` → latest DEV head at checkpoint time.
- Scope: Canonical, architecture, scope, Phase -1, execution strategy, resumes, Supabase DEV state, BE implementation/reconciliation.
- FE/device work intentionally not required for this pass.

## Owner-Ratified Lifecycle Rules

- `DEACTIVATED` = EOL / terminal.
- Deactivated SH cannot recover/restore or mutate record policy.
- Inheritance: ACTIVE source + ACTIVE target.
- Succession: DEACTIVATED/EOL source → ACTIVE successor.
- Legacy: DEACTIVATED/EOL source → preservation, not operational transfer.
- If an authorization/release governing derived information is revoked, derived information at the target is removed while source/original information remains retained.

## BE Findings Closed Through This Pass

- Recovery restore terminal guard.
- Recovery restore idempotency.
- Terminal record-policy mutation guard.
- Inherited record-policy immutability.
- Inheritance provenance and revoke cleanup, including Journey.
- Clone revoke/release cleanup for derived Memory/Knowledge/Experience.
- Lifecycle-specific Journey eligibility.
- Transfer-policy vocabulary reconciliation.

## New P1 Fixed in This Pass

`runtime_record_experience()` accepted `INHERITABLE` as an input but persisted it unchanged. The canonical vocabulary permits `INHERITABLE` only as a compatibility alias; persisted policy is canonical `INHERITANCE`.

Fix applied to Supabase DEV and reconciled to GitHub as:

`supabase/migrations/20260822150000_p1_normalize_inheritance_transfer_policy_alias.sql`

No existing DEV Memory/Knowledge/Experience rows used `INHERITABLE`, so no data rewrite was required.

## Remaining Evidence Gates

- Authenticated runtime/E2E verification remains open where code-only inspection cannot prove real user/account behavior.
- Clean-room migration replay/history identity remains an evidence/reproducibility item; do not fabricate historical migration IDs.
- Supabase security advisor still reports generic SECURITY DEFINER warnings; each function requires semantic review before changing privileges. No blanket privilege removal is authorized by the current source.

## Rule

If source/contract is explicit and implementation is wrong: FIX → RECONCILE → RE-AUDIT.
If source does not determine the behavior: OWNER DECISION REQUIRED; do not guess.
