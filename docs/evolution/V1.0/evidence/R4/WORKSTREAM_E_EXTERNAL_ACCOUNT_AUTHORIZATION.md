# SECOND HEAD V1.0 — EXTERNAL ACCOUNT AUTHORIZATION

Status: **SUPPORTING R4 AUTHORIZATION RECORD / CI VERIFIED / RUNTIME VERIFICATION PENDING**
Date: 2026-08-29
Branch: `dev`

## Purpose

Provide the minimum SH-owned authorization path required before R4 can perform a real external action.

For the first implementation, the external provider is **Google** and the bounded capability is **Google Calendar**.

## Boundary

```
Owner
  ↓
SH "Connect Google"
  ↓
Google OAuth consent
  ↓
Supabase-authenticated SH session
  ↓
provider authorization evidence
  ↓
SH Runtime
  ↓
R4 Google Calendar CREATE EVENT
```

This is not a generic OAuth marketplace, credential manager, or integration platform.

## Rules

- The Owner explicitly initiates the connection.
- Google is the authorization provider; Google credentials/passwords never enter SH.
- SH Runtime remains the authority for R4 execution.
- The App may initiate the OAuth flow but must not decide whether an external action is authorized.
- Provider tokens/secrets must not be committed to Git or exposed in chat.
- R4 must bind the target to the authenticated Owner's primary calendar.
- Calendar CREATE EVENT remains behind the R4 confirmation gate.
- Disconnect/revocation must prevent subsequent R4 execution.

## First implementation boundary

Only Google OAuth + Google Calendar is in scope.

The implementation should first establish:
1. a mobile-safe OAuth initiation/callback path;
2. verified Google authorization state;
3. secure handling of provider credentials;
4. a Runtime-consumable authorization reference;
5. no external mutation during connection itself.

The actual Calendar mutation remains a separate R4 execution step.

## Operator prerequisite

Supabase DEV must have the Google OAuth provider configured with a Google Cloud OAuth client and the required redirect URI. The client secret belongs only in the approved Supabase secret/provider configuration; never in the mobile app bundle or repository.

## Exit condition

External account authorization is considered ready only when a DEV account can:
- connect Google successfully;
- show the connection state in SH;
- retain no plaintext credential in source;
- expose only the minimum authorization evidence required by Runtime;
- disconnect/revoke without leaving an executable R4 credential path.

No R4 CREATE EVENT execution is implied by this document alone.

## DEV implementation status — 2026-08-29

The first SH-owned Google authorization bridge is now implemented in DEV.

Implemented:
- functions/r4-google-oauth/index.ts — authenticated OAuth initiation, state binding, Google callback, authorization-code exchange, scope verification, Vault-backed refresh-token storage, connection state, disconnect/revocation, and audit evidence.
- database/migrations/20260829130000_r4_google_calendar_authorization.sql — short-lived OAuth state storage, non-secret Google connection metadata, RLS, and service-role-only Vault helper functions.
- app/services/google-authorization.ts — mobile client bridge.
- app/app/authorization.tsx — DEV connection/status surface and deep-link return handling.
- supabase/config.toml — callback function has JWT gateway verification disabled because the function implements its own authenticated start/disconnect checks and must accept Google's unauthenticated callback.

Security boundary:
- OAuth state is generated server-side and only its SHA-256 hash is persisted.
- Google refresh tokens are not stored in Git, app bundle, chat, or the public connection table; they are stored through Supabase Vault.
- The App can initiate connection and display status but does not decide R4 authorization.
- Connection performs no Calendar mutation.
- Disconnect removes the stored refresh credential and marks the connection REVOKED.

Current operator prerequisites:
1. Add the exact callback URI below to the Google OAuth Web client:
   https://pkhkgvsrqeupvwoqjwmd.supabase.co/functions/v1/r4-google-oauth
2. Add these DEV Edge Function secrets:
   - R4_GOOGLE_CLIENT_ID = the Google OAuth Client ID
   - R4_GOOGLE_CLIENT_SECRET = the Google OAuth Client Secret
3. Keep the Google OAuth consent application in DEV/testing and ensure the Owner account is an allowed test user.
4. Keep Calendar scope at https://www.googleapis.com/auth/calendar.events.owned.

The callback URI is deliberately the deployed SH Edge Function callback, not the Supabase Google Sign-in callback.

## Verification gate

The source, migration, and deployed Edge Function are present in DEV. Final end-to-end authorization verification remains blocked only on the operator Google credential wiring above.

Required runtime proof:
Owner → Connect Google → Google consent → callback → CONNECTED state → Disconnect → REVOKED state

No R4 CREATE EVENT mutation is executed as part of this authorization verification.

## CURRENT DEV RECONCILIATION — 2026-08-29

The authorization implementation prerequisite described above is now implemented in DEV. Latest DEV verification is GREEN, including R4-specific verification #2.

The remaining gate is live runtime proof: Owner → Connect Google → Google consent → callback → CONNECTED, followed separately by the R4 action proof. No live Google-account E2E or real Calendar mutation is claimed yet.

An APK download is not required to establish the repository/CI implementation state; device-level verification remains a separate runtime gate when the actual client flow is exercised.


## DOCUMENT ROLE RECONCILIATION — 2026-08-29

This file is retained as the supporting authorization record for R4, not as a separate Workstream E/R track. Its implementation and runtime-gate facts are part of the R4 External Create / Update slice. The parent R4 document is the primary R4 workstream record; this file preserves detailed authorization evidence and operator prerequisites.
