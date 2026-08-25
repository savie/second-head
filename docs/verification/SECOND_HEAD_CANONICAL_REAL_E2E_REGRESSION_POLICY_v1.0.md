# SECOND HEAD — CANONICAL REAL E2E REGRESSION POLICY v1.0

**Status:** Canonical supporting policy for `SECOND_HEAD_CANONICAL_REAL_E2E_VERIFICATION_MATRIX_v1.0.md`  
**Branch:** `dev`  
**Scope:** REAL E2E evidence validity, build regression, failure classification, and retest scope

## 1. Purpose

The REAL E2E Verification Matrix is a persistent execution matrix. A new APK/build does **not** automatically invalidate every previously recorded PASS.

TC-IDs remain locked and the matrix is updated incrementally. Evidence validity is determined by the affected implementation scope and the evidence recorded for the test, not by APK number alone.

## 2. Failure classification

Every red CI, build, or E2E result MUST be classified before changing a Matrix test status.

| Class | Meaning | Default disposition |
|---|---|---|
| `FE` | Frontend/UI/mobile implementation defect | FE fix; APK rebuild; retest affected scope |
| `BE` | Backend/Supabase implementation or policy defect | BE fix/reconcile; retest affected scope |
| `FE-BE` | Contract/interface mismatch between FE and BE | Reconcile the boundary; retest both sides of affected flow |
| `CI-BUILD` | Build/toolchain/workflow/infrastructure failure without product-defect evidence | Do not mark E2E TC FAIL solely from this result |
| `TEST-ENV` | Test fixture, account, device, seed data, or environment problem | Repair environment and rerun; do not infer product failure |
| `EVIDENCE` | Evidence is insufficient, ambiguous, stale, or cannot prove the TC | Keep/open as `⏳` or `⚠️`; do not convert to PASS or FAIL by inference |

## 3. APK/build replacement rule

A new APK/build does NOT reset the Matrix.

For each new build:

1. Record the build/APK identifier and FE commit.
2. Identify changed FE files/features and any BE/Supabase state changes.
3. Determine the regression blast radius.
4. Retest affected TCs and any explicitly regression-critical TCs.
5. Preserve unrelated PASS evidence unless its validity was actually invalidated.

## 4. When previous PASS remains valid

A previous PASS may remain valid across a new APK when:

- the tested behavior was not changed;
- no shared FE primitive used by that behavior changed;
- no relevant BE contract, RPC, policy, schema, or migration changed;
- no test environment condition invalidates the evidence; and
- the original evidence remains traceable to its APK/build and relevant implementation state.

## 5. When PASS must be retested or invalidated

Retest is required when a change touches the tested flow, a shared dependency/primitive, authentication/session behavior, a relevant BE contract, or another component in the TC's dependency path.

Broader regression is required when the blast radius cannot be bounded or the change is cross-cutting (for example auth, global policy, shared lifecycle primitive, migration affecting multiple domains, or major navigation/runtime infrastructure).

A PASS is invalidated only when the change actually affects its asserted behavior or its evidence no longer represents the current contract/state.

## 6. FE vs BE disposition

A UX/UI mismatch is normally reconciled in FE without changing BE semantics.

BE is changed only when:

- the canonical contract says the BE behavior is wrong;
- the BE implementation is demonstrably broken/non-functional; or
- a deterministic security, authorization, integrity, lifecycle, or data-consistency defect is proven.

A UX request that introduces new SH Core semantics not present in the canonical contract is an Owner Decision, not an automatic BE change.

## 7. CI/build failures are not automatically E2E failures

A failed `typecheck`, bundling step, Gradle build, workflow setup, dependency installation, or similar build-stage failure MUST first be classified as `FE` or `CI-BUILD` based on root cause.

A product E2E TC is not marked `🔴 FAIL` merely because a build failed. If the build failure is caused by a product source defect, classify it as `FE`/`BE` as appropriate and retest after the fix.

## 8. Evidence fields

For every newly established or retested PASS, record at minimum when applicable:

- TC-ID
- APK/build identifier
- FE commit
- relevant BE/Supabase migration/function state
- test account/fixture context without exposing secrets
- evidence reference
- retest reason when the TC was rerun after a change

## 9. Regression scope notation

A test may be marked as:

- `RETEST-REQUIRED` — directly affected;
- `REGRESSION-REQUIRED` — indirectly affected/shared dependency;
- `PASS-RETAINED` — previous evidence remains valid;
- `BLOCKED` — cannot execute because required fixture/environment is unavailable;
- `EVIDENCE-OPEN` — execution occurred but evidence is insufficient for the asserted claim.

These labels describe execution state and do not replace the Matrix status legend.

## 10. Canonical relationship

This policy supplements the REAL E2E Verification Matrix. It does not create or modify TC-ID meanings and does not override Canonical SH Core semantics.

The Matrix remains the authoritative test ledger; this policy defines how its evidence survives builds and how failures are classified.
