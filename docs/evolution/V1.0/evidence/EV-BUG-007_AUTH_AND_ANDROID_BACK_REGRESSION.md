# EV-BUG-007 — WS-A AUTH & ANDROID BACK REGRESSION

Status: **OPEN — REMEDIATION IMPLEMENTED, DEVICE VERIFICATION REQUIRED**

## Scope
WS-A manual APK verification covering authentication/account entry and Android Back behavior on attachment-related surfaces.

## Initial audit
The active V1.0.0 APK was manually tested after Workstream A–E implementation.

Verified PASS:

- APK can enter with the expected account.
- Session remains active.
- Account identity is correct.
- SH identity is correct.
- Chat receives a normal SH response.
- Chat, Journey, Lifecycle, and More navigation open correctly.
- Basic conversation send/response/persistence/reopen works.
- Drawer/navigation works.
- Modal/dialog behavior works.
- Keyboard/composer behavior works.
- Attachment surface does not leave the app stuck.
- User request → SH response runtime flow works consistently.

Findings:

1. **Forgot/Forget Password is missing from the Login surface.**
   - This is an authentication/account UX gap.
   - The current APK does not provide a password-recovery entry point.

2. **Android Back does not correctly dismiss the lower attachment/file/photo surface.**
   - Android Back remains incorrect specifically for the lower attachment/file/photo interaction surface.
   - Other tested Android Back/navigation behavior passed.

## Historical reference — EV-BUG-006

EV-BUG-006_CHAT_ACTIONS_FUNCTIONALITY previously recorded attachment and Android Back behavior as **CLOSED / PASS — DEVICE VERIFIED** on APK #220.

That evidence stated that:

- File attachment worked.
- Photo attachment worked.
- Camera attachment worked.
- Attachment content participated in Runtime/model processing.
- Android back behavior for required-choice/action dialogs was fixed and verified.

Therefore the current attachment/file/photo Android Back finding is recorded as a **possible regression / recurrence**, not silently treated as a new unrelated behavior.

The current audit does **not** invalidate the historical EV-BUG-006 evidence. It establishes that the behavior needs to be re-investigated against the current V1.0.0 APK.

## Additional finding — recovery redirect

The first remediation added a password-reset request from Login, but device verification exposed a second gap: the Supabase recovery email redirected to `localhost:3000`, which is not reachable from the Android APK. The email delivery itself succeeded; recovery completion did not.

This establishes that password recovery is a new SH capability gap requiring an end-to-end contract:

`Login → Supabase recovery email → SH Android deep link → Reset Password screen → password update → Login`

The current app already declares the `secondhead` custom scheme. The remediation now routes `resetPasswordForEmail` to the native `secondhead://reset-password` URL and adds a dedicated Reset Password route that handles recovery session establishment and password update. This requires a new APK because Expo custom-scheme/deep-link behavior is build-time configuration. The corresponding `secondhead://reset-password` redirect URI must also be allowlisted in the Supabase Auth URL configuration before device verification.

## Required fix scope

### A. Login
Provide the intended password-recovery path from Login, consistent with the existing SH authentication contract.

### B. Attachment/file/photo Android Back
Restore the expected Android Back dismissal behavior for the affected lower attachment/file/photo surface without regressing:

- File attachment
- Photo attachment
- Camera attachment
- Composer behavior
- Dialog behavior
- Runtime attachment processing

## Verification requirement
After implementation, verify on the current APK:

- Login → password recovery entry is present and usable.
- Android Back dismisses the affected attachment/file/photo surface correctly.
- File/Photo/Camera attachment still works.
- Existing WS-A authentication, navigation, conversation, and runtime checks remain PASS.

## Provenance
Historical reference:

- docs/evidence/EV-BUG-006_CHAT_ACTIONS_FUNCTIONALITY.md
- EV-BUG-006 recorded the prior device-verified attachment/back fix on APK #220.

Current evidence:

- Manual V1.0.0 APK audit performed before the WS-A remediation work.
- Password-reset request was implemented and device-tested; email delivery passed.
- Device test then exposed the `localhost:3000` recovery redirect failure.
- Native recovery redirect and Reset Password route are now implemented in DEV.
- Android APK verification and Supabase redirect allowlist verification remain pending.

## Final status
**🔴 OPEN — WS-A remediation required**

This evidence is intentionally recorded before remediation so a recurrence can be compared against the historical BUG-006 fix rather than losing the regression history.
