# EV-P2-002 — Permission Matrix Implementation

**BL:** BL-P2-002 — Permission Matrix Implementation  
**Phase:** Phase 2  
**Status:** VERIFIED  
**Verification mode:** Actual-state verification against GitHub `dev` and Supabase `second-head`  
**Migration:** `20260810130620_create_permission_matrix`  

## 1. Implementation result

The Phase 2 Permission Matrix is implemented as the repository migration:

`database/migrations/20260810130620_create_permission_matrix.sql`

The migration creates `public.permission_matrix`, seeds the Phase 2 matrix rules, enables RLS, and removes direct table privileges from `anon` and `authenticated`.

No governance evaluator, policy enforcement engine, isolation checker, access gate, or SH-000 technical identity was implemented by BL-P2-002.

## 2. Supabase verification

Project: `second-head`  
Project ref: `pkhkgvsrqeupvwoqjwmd`

Applied migration history includes:

- `20260810130620 create_permission_matrix`

Live `public.permission_matrix` state:

- 45 permission rules present.
- 32 `ALLOW` rules.
- 13 `DENY` rules.
- 0 `ESCALATE` rows persisted; escalation remains a downstream evaluator/review behavior rather than a blanket actor wildcard rule.
- RLS enabled.
- FORCE ROW LEVEL SECURITY remains false.
- `anon` and `authenticated` have no table privileges.
- `service_role` retains table privileges for trusted system paths; service-role semantics remain an open engineering question for BL-P2-003/004.

## 3. Boundary verification

The implementation preserves the frozen boundaries represented by the BL-P2-001 design:

- Creator governance authority does not grant private-data access to another SH.
- SH-000 governance authority does not grant private-data access to another SH.
- Runtime execution is represented separately from ownership.
- Cross-SH private-data access is DENY by default and explicit scoped authorization is represented separately.
- READ, WRITE, and COPY/EXPORT remain distinct actions.
- SH-000 remains a conceptual actor; no technical SH-000 identifier was introduced.
- No Phase 2 evaluator or enforcement semantics were introduced early.

## 4. Repository verification

GitHub repository: `savie/second-head`  
Target branch: `dev`

The implementation migration is present on `dev` with the same SQL that was applied to Supabase. The migration timestamp matches the applied Supabase migration version.

## 5. Security/advisor observation

Supabase security advisor reports `rls_enabled_no_policy` for `public.permission_matrix`. This is intentional for BL-P2-002: the matrix is configuration for the later trusted evaluator/enforcement path and is not directly exposed to client roles. The advisor also reports pre-existing SECURITY DEFINER privilege findings for existing Phase 1 functions; those are outside BL-P2-002 scope.

## 6. Phase boundary

BL-P2-002 does not implement:

- Governance Evaluator (BL-P2-003)
- Policy Enforcement Engine (BL-P2-004)
- Isolation Checker (BL-P2-005)
- Access Decision Gate (BL-P2-006)
- Creator Authority Boundary testing (BL-P2-007)
- SH-000 technical identity resolution

Those remain downstream work items.

## 7. Result

**BL-P2-002 — COMPLETE / VERIFIED.**

The Permission Matrix now exists as an actual, protected Supabase representation with a canonical repository migration, while downstream evaluator/enforcement behavior remains intentionally unimplemented.
