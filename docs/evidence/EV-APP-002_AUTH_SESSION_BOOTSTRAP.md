# SECOND HEAD — EV-APP-002 AUTH / SESSION BOOTSTRAP AUDIT

Status: IMPLEMENTED / SOURCE-CONTRACT VERIFIED / RUNTIME E2E DEFERRED
Branch: `dev`

## Scope

This slice implements the first authenticated delivery-layer vertical slice:

`App → Supabase Auth → Session → Account → SH Instance / Ownership`

## Implementation

- `app/services/supabase.ts` — Supabase client boundary and persisted session storage.
- `app/services/auth.ts` — authentication/session API boundary.
- `app/services/account.ts` — authenticated account/SH bootstrap.
- `app/state/auth-context.tsx` — app session state and bootstrap lifecycle.
- `app/app/login.tsx` — minimal sign-in/sign-up surface.
- `app/app/index.tsx` — authenticated route gate and account/SH context display.
- `app/.env.example` — public client configuration convention.

## Supabase DEV Verification

The DEV database contains the expected identity tables:

- `accounts`
- `account_auth_links`
- `sh_instances`
- `sh_ownership`

Observed SELECT policies include:

- `account_auth_links_select_own`: Supabase provider + `subject_ref = auth.uid()`.
- `accounts_select_own`: `account_id = current_account_id()`.
- `sh_instances_select_own`: `account_id = current_account_id()`.
- `sh_ownership_select_own`: `account_id = current_account_id()`.

The DEV auth database also has `auth.users` trigger `on_auth_user_created`, calling `public.handle_new_auth_user()`, which provisions identity through `public.provision_identity_for_auth_subject(NEW.id::text, NEW.email)`.

## Security Boundary

PASS:

- Client uses only `EXPO_PUBLIC_SUPABASE_URL` and `EXPO_PUBLIC_SUPABASE_ANON_KEY`.
- No service-role key is introduced into `app/`.
- No model-provider secret is introduced into `app/`.
- Session persistence is isolated behind `expo-secure-store`.
- Account/SH data is requested through RLS-protected Supabase tables.
- App does not perform privileged database writes or bypass RLS.

## Architecture Baseline Audit

| Contract | Result |
|---|---|
| App owns presentation/session state | PASS |
| Supabase Auth owns authentication | PASS |
| Runtime remains separate from App | PASS |
| Session persisted securely for native delivery | PASS |
| Account identity resolved after authentication | PASS |
| SH identity/ownership resolved through backend/RLS boundary | PASS |
| Provider/model secret in client | PASS — absent |
| Service-role key in client | PASS — absent |
| Direct provider invocation from App | PASS — absent |
| Runtime/API invocation | NOT YET IMPLEMENTED |
| Chat/streaming | NOT YET IMPLEMENTED |
| High-risk confirmation | NOT YET IMPLEMENTED |
| Product E2E | DEFERRED |

## Important Limitation

No real user credentials were created or persisted in DEV as part of this audit. Therefore this evidence does NOT claim authenticated mobile E2E PASS.

The next verification step should run the app with configured client environment values and a controlled test account, then verify:

1. sign-up/sign-in;
2. session persistence after restart;
3. account bootstrap;
4. SH instance/ownership visibility under RLS;
5. logout and session revocation behavior.

## Conclusion

The Auth / Session vertical slice is structurally aligned with the SH App Architecture Baseline and actual Supabase DEV identity/RLS structure.

Status: READY FOR CONTROLLED APP RUNTIME VERIFICATION.

END OF EV-APP-002
