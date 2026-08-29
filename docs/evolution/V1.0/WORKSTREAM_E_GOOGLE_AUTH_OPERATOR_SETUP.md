# R4 — GOOGLE ACCOUNT AUTHORIZATION SETUP

Status: **OPERATOR SETUP REQUIRED**
Branch: `dev`
Date: 2026-08-29

## What is required

R4 needs permission to act on the Owner's Google Calendar. SH's existing Supabase password authentication is **not** that permission. Do not reuse the Supabase Google sign-in provider as a shortcut for Calendar authorization.

For the first bounded implementation, use a separate Google OAuth consent flow for Calendar access.

## Operator steps

1. Open Google Cloud Console and create/select a project for SH DEV.
2. Configure the OAuth consent screen for the DEV test application.
3. Create an OAuth Client ID for the SH Android/mobile flow appropriate to the final Expo/Android implementation.
4. Add only the redirect URI that the SH authorization implementation specifies.
5. Enable **Google Calendar API** for the project.
6. Request the narrowest Calendar scope that supports the bounded operation: preferably `https://www.googleapis.com/auth/calendar.events.owned` when compatible with the selected target; otherwise `https://www.googleapis.com/auth/calendar.events`.
7. Do **not** paste the Client Secret into GitHub or chat.

## Important

Do not configure the credential yet if the exact redirect URI has not been supplied by the implementation. The redirect URI must match the actual SH callback path exactly.

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
