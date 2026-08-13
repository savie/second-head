# SECOND HEAD — EV-APP-004 RUNTIME INVOCATION VERTICAL SLICE

Status: DEV / STRUCTURAL PASS / CONTROLLED E2E GATE DEFERRED

## Scope

App → existing SH Runtime adapter, controlled request/response verification, and audit against `docs/SH_APP_ARCHITECTURE_BASELINE_v1.0.md`.

## Implementation

The App runtime boundary is implemented in:

- `app/services/runtime.ts`
- `app/types/runtime.ts`
- `app/app/runtime-test.tsx`
- `app/tests/runtime-invocation-verification.mjs`

The adapter:

1. requires an authenticated Supabase session;
2. obtains the current access token from Supabase Auth;
3. invokes the existing `runtime-p4a-001` Edge Function;
4. sends the bearer token to the runtime boundary;
5. validates the returned SH identity and response contract;
6. does not call a model provider directly from the App.

## Actual Supabase DEV reconciliation

Project ref: `pkhkgvsrqeupvwoqjwmd`

`runtime-p4a-001` is ACTIVE and configured with JWT verification enabled.

The actual Edge Function verifies the bearer-authenticated user, resolves an existing SH identity through `resolve_identity`, and returns the P4A-001 response envelope. The current implementation uses a `mock` provider response and does not create a new SH identity or perform a memory write.

## Baseline audit

| Requirement | Result |
|---|---|
| App is delivery surface over existing runtime | PASS |
| Stable App-side runtime adapter boundary | PASS |
| Authenticated request required | PASS |
| No service-role credential in App | PASS |
| No model-provider secret in App | PASS |
| App does not call LLM provider directly | PASS |
| Runtime resolves SH identity | PASS |
| Runtime remains server-side authorization/runtime boundary | PASS |
| Runtime response contract validated by App | PASS |
| Controlled mobile request/response execution | DEFERRED |
| Product E2E | DEFERRED |

## Controlled verification gate

The repository contains a controlled verification harness requiring a dedicated test credential via environment variables:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SH_TEST_EMAIL`
- `SH_TEST_PASSWORD`

No test password is stored in GitHub and no existing user password is available through the repository or Supabase database inspection. Therefore this audit does NOT claim that the authenticated request/response execution has passed from an actual Expo/device runtime.

This is intentional: a structural/runtime contract pass must not be represented as mobile E2E evidence.

## Result

The App → existing SH Runtime boundary is implemented and reconciled against the current App Architecture Baseline and actual Supabase DEV runtime function.

The next gate is a controlled authenticated execution using an authorized DEV test account. Once that passes, the next implementation slice is:

> GO CHAT REQUEST/RESPONSE VERTICAL SLICE — build the authenticated chat surface on top of the verified runtime adapter, verify request/response behavior, then proceed to streaming/event normalization.

Do not add provider-specific logic to the App.

END OF EV-APP-004
