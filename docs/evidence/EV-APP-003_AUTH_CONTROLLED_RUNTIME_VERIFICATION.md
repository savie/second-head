# SECOND HEAD — EV-APP-003 AUTH CONTROLLED RUNTIME VERIFICATION

Status: CONTROLLED VERIFICATION HARNESS READY / DEVICE EXECUTION DEFERRED
Scope: authentication + session bootstrap + account/SH resolution
Baseline: `docs/SH_APP_ARCHITECTURE_BASELINE_v1.0.md`

## Actual Supabase DEV observation

At verification time:

- `auth.users`: 2
- `public.account_auth_links` rows for provider `supabase`: 2
- `public.accounts`: 2
- `public.sh_instances`: 2
- `public.sh_ownership`: 2
- every Supabase auth link resolves to an account

No test row was inserted by this verification.

## Controlled runtime harness

`app/tests/auth-runtime-verification.mjs` performs, against a supplied DEV test account:

1. Supabase password sign-in through the public Auth endpoint.
2. Assert that an authenticated user/session is returned.
3. Query `account_auth_links` using the authenticated bearer token.
4. Assert exactly one account link for the authenticated subject.
5. Query `sh_instances` using the same authenticated bearer token.
6. Assert returned SH rows are account-scoped to the resolved account.
7. Call Auth logout and assert success.

Required environment variables are intentionally supplied at execution time:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SH_TEST_EMAIL`
- `SH_TEST_PASSWORD`

No credential is committed to GitHub.

## Verification result

### PASS — architecture / data-boundary readiness

The actual DEV state contains the expected Auth → account link → account → SH relationship, and the controlled harness is implemented without requiring service-role credentials.

### NOT CLAIMED — device/application E2E

This checkpoint does not claim that the Expo application itself has successfully executed sign-in on a physical device or emulator. No device credential was available in the execution environment, and inventing that result would violate the evidence contract.

## Security boundary

The verification uses only the public client key and an explicitly supplied test account. It does not use a service-role key, direct privileged SQL, or provider/model secret from the App.

## Exit criteria for this slice

The Auth slice becomes runtime-verified when the harness executes successfully against DEV and the same flow is confirmed through the Expo app:

`App → Supabase Auth → session → account_auth_links → account → SH`

## NEXT INSTRUCTION

After providing a controlled DEV test account/configuration, execute the harness and verify the Expo app login/session flow. If PASS, continue with:

`GO RUNTIME INVOCATION VERTICAL SLICE — implement the App → existing SH Runtime adapter, execute controlled request/response verification, then audit against the SH App Architecture Baseline before adding chat/streaming.`

END OF EV-APP-003
