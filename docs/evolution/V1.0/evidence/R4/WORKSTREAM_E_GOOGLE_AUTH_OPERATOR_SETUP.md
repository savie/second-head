# SECOND HEAD V1.0 — GOOGLE ACCOUNT AUTHORIZATION SETUP

Status: **SUPPORTING R4 OPERATOR SETUP RECORD / RUNTIME PREREQUISITE**
Branch: `dev`
Date: 2026-08-29

## What is required

R4 needs permission to act on the Owner's Google Calendar. SH's existing Supabase password authentication is **not** that permission. Do not reuse the Supabase Google sign-in provider as a shortcut for Calendar authorization.

For the first bounded implementation, use a separate Google OAuth consent flow for Calendar access.

## Operator steps

1. Open Google Cloud Console and create/select a project for SH DEV. **Do not start a Google Cloud Free Trial and do not add a card.** Google’s Resource Manager documentation distinguishes creating a project from attaching a billing account.
2. Configure the OAuth consent screen for the DEV test application. Keep the app in testing and add the Owner account as a test user.
3. Create an OAuth Client ID for the SH Android/mobile flow appropriate to the final Expo/Android implementation.
4. Add only the redirect URI that the SH authorization implementation specifies.
5. Enable **Google Calendar API** for the project. Google’s current Calendar quickstart does not list billing as a Calendar setup prerequisite, and standard Calendar API usage is currently available at no additional cost. If the Console specifically blocks Calendar API enablement behind billing, **STOP and report the exact screen; do not add a card.**
6. Request the narrowest Calendar scope that supports the bounded operation: preferably `https://www.googleapis.com/auth/calendar.events.owned` when compatible with the selected target; otherwise `https://www.googleapis.com/auth/calendar.events`.
7. Do **not** paste the Client Secret into GitHub or chat.

## Important

Do not configure the credential yet if the exact redirect URI has not been supplied by the implementation. The redirect URI must match the actual SH callback path exactly.

**Billing boundary:** The payment screen previously encountered is the Google Cloud billing/free-trial flow. It is not evidence that the Owner must pay to use Calendar. For SH Zero-Budget DEV, do not enter payment details. Use an unbilled Cloud project if the Console permits it; do not activate Free Trial just to continue.

## SH-side contract

The authorization implementation must:
- generate a state value tied to the authenticated SH/Owner;
- send the Owner to Google's consent screen;
- validate the OAuth callback state;
- exchange the authorization code server-side;
- keep provider credentials out of the mobile bundle;
- expose only authorization state/reference to the SH Runtime;
- support disconnect/revocation;
- never execute a Calendar mutation during authorization.

## Next implementation boundary

Once the actual mobile callback URI and Google OAuth client configuration are available, implement the authorization endpoint/callback and secure provider-credential storage in DEV. Then verify:

`Owner → Connect Google → Google consent → callback → connected state`

Only after that proceed to R4:

`CREATE EVENT → confirmation → execute → audit`.


## DOCUMENT ROLE RECONCILIATION — 2026-08-29

This file is retained as the supporting operator runbook for the R4 Google Calendar authorization path, not as a separate Workstream E/R track. The implementation has since moved to the deployed SH Edge Function callback documented by the R4 authorization record. The old Android/mobile-client wording is historical and must not override the current callback implementation. Runtime credential wiring remains an operator prerequisite.
