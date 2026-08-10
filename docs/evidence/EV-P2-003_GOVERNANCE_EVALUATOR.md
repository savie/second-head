# EV-P2-003 — Governance Evaluator

**BL:** BL-P2-003 — Governance Evaluator  
**Phase:** Phase 2  
**Status:** VERIFIED  
**Verification mode:** Actual-state verification against GitHub `dev` and Supabase `second-head`  
**Migration:** `20260810131800_create_governance_evaluator`

## 1. Implementation result

The Governance Evaluator is implemented as:

`private.governance_evaluator(text, text, text, uuid, uuid)`

The evaluator:

- derives actor identity from trusted `auth.uid()` / `current_account_id()` context;
- rejects unauthenticated or unresolved identity;
- rejects a caller-supplied ACCOUNT_ID that does not match the trusted resolved account;
- derives target SH relation as `SYSTEM`, `SELF`, or `OTHER` from actual ownership;
- evaluates the Phase 2 permission matrix;
- applies DEFAULT DENY when no rule matches;
- enforces `OWNERSHIP_VALIDATED` from actual ownership rather than caller assertion;
- does not treat `EXPLICIT_SCOPED_AUTHORIZATION` as satisfied without a trusted authorization source;
- returns `ESCALATE` when a matched rule requires a governance process.

## 2. Security boundary

The function is stored in the `private` schema, uses `SECURITY DEFINER` with an empty `search_path`, and is not exposed as a public RPC surface. Execute is revoked from `PUBLIC` and `anon`; `authenticated` is granted only the minimum function execution needed for downstream policy use.

The implementation does not introduce SH-000 technical identity recognition. It also does not invent a Creator identity mapping that is absent from the current actual schema/state. Those authority classifications remain downstream engineering work where their trusted identity source is available.

## 3. Supabase verification

Project: `second-head`  
Project ref: `pkhkgvsrqeupvwoqjwmd`

Applied migration history includes:

- `20260810131800 create_governance_evaluator`

Verification cases:

- Unauthenticated call → `DENY / UNAUTHENTICATED` (fail closed).
- Authenticated owner reading own private memory → `ALLOW`, matching rule 20.
- Authenticated owner reading another SH's private memory → `DENY`, matching rule 26.
- Caller-supplied mismatched ACCOUNT_ID → `DENY`, identity spoofing rejected.

## 4. Boundary check

No Policy Enforcement Engine, Isolation Checker, Access Decision Gate, Creator Authority Boundary, or SH-000 technical identity was implemented by BL-P2-003.

The evaluator is intentionally limited to trusted identity resolution and matrix evaluation. Explicit sharing authorization is not fabricated where no trusted authorization source exists yet.

## 5. Security advisor

The post-change security advisor did not report the new evaluator as an exposed SECURITY DEFINER function. Existing findings for Phase 1 `public` SECURITY DEFINER helpers and the intentional `permission_matrix` RLS-without-policy finding remain outside this BL's mutation scope.

## 6. Result

**BL-P2-003 — COMPLETE / VERIFIED.**
