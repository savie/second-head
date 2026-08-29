# SECOND HEAD V1.0 — EXTERNAL ACCOUNT AUTHORIZATION

Status: **BOUNDED DESIGN / IMPLEMENTATION PREREQUISITE**
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
