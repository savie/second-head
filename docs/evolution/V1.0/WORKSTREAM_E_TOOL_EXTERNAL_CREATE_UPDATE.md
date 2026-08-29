# SECOND HEAD V1.0 — WORKSTREAM E TOOL — R4 EXTERNAL ACTION

Status: **IMPLEMENTED / CI VERIFIED / RUNTIME VERIFICATION PENDING**
Date: 2026-08-29
Branch: dev

## 1. Position

R4 is the selected representative Tool for:

- Family: F — External Actions
- Candidate: F.1 Create / Update / Send / Submit
- Selection: R4
- Role: test governed external side effects
- Strategy: REUSE / ADAPT an existing external-service capability

R4 deliberately starts with one bounded CREATE or UPDATE operation. SEND / SUBMIT and DELETE remain separate action designs.

## 2. Why R4

R1 tests governed search.
R2 tests authorized retrieval.
R3 tests bounded artifact processing.
R4 tests the next materially different boundary:

> SH can cause an external state change only when the exact actor, target, operation, scope, authorization, and required confirmation are valid.

This is the representative high-risk slice. It is not permission to build a generic action engine or autonomous workflow platform.

## 3. Basic Flow

PLAN
→ AUTHORIZATION
→ CONFIRMATION (when required)
→ EXECUTE
→ RESULT / EVIDENCE
→ AUDIT

No execution occurs when an eligibility condition fails.

## 4. Existing Capability / Source Strategy

R4 must not build an external-service ecosystem.

Preferred order:
1. identify an existing external service capability;
2. verify its supported CREATE/UPDATE operation and API boundary;
3. reuse it when its boundary fits;
4. otherwise adapt it through SH Runtime;
5. build only SH-specific governance/bridge behavior that cannot reasonably be reused.

Source-level verification completed against the current DEV runtime. The six configured model-provider secrets are not R4 targets. GitHub was evaluated as a convenient technical target, but is not selected as the representative user-facing external service. The representative target is now **Google Calendar → CREATE EVENT**, because it is a direct productivity capability likely to be useful to SH and provides a bounded external state mutation. No GitHub credential is required for R4.

## R4 Conclusion

External Create / Update remains the selected representative of Family F because it completes the current four-tool representative set by testing a real external side effect under explicit governance. The strategy remains reuse/adapt: SH builds and owns the governance boundary, while the external capability supplies the underlying operation.


### R4 Representative Target

**Google Calendar — CREATE EVENT**

Target: the authenticated owner's **primary Google Calendar**.
Operation: create one calendar event with bounded title, start, end, and optional description/location.
Authorization: Google OAuth, using the narrowest suitable Calendar Events scope.
SH controls: authenticated SH identity → target binding (primary calendar) → authorization → explicit confirmation → execution → evidence/audit.

Google's official Calendar API supports `events.insert` for creating an event. The API requires start/end for the event, and Google documents OAuth scopes including `calendar.events` and the narrower `calendar.events.owned` for events on calendars owned by the user. The implementation should choose the narrowest scope that satisfies the bounded target.

The six existing model-provider secrets remain generation capabilities and are not reused for R4.

**Operator prerequisite:** Google OAuth authorization must be connected for the DEV test account. No Google password or OAuth refresh token should be sent in chat; the resulting credential must be stored in the approved DEV secret/credential mechanism.


## CURRENT DEV RECONCILIATION — 2026-08-29

The external-capability implementation gap identified in the earlier bounded-design check is now crossed for the bounded Google Calendar slice.

Implemented: primary-calendar CREATE_EVENT action; PENDING/CONFIRMED/EXECUTING/EXECUTED/FAILED/EXPIRED state lifecycle; explicit confirmation and expiry; Vault-backed OAuth token retrieval; Google Calendar `events.insert`; normalized result; failure recording; audit events; bounded input contract/tests; dedicated R4 CI verification.

Latest DEV head `c0bc185034a04384ba0466fac0af172e9ebd2b03` is GREEN across R4 Verification #2, Runtime Controlled Verification #411, and App Chat Verification #397.

Remaining: live Google OAuth E2E, live Calendar CREATE_EVENT mutation proof, and final R4 acceptance. CI GREEN is classified as CI VERIFIED, not RUNTIME VERIFIED or ACCEPTED/CLEAR.

Bounded scope is unchanged: no generic workflow engine, plugin marketplace, arbitrary third-party execution, broad provider abstraction, SEND/SUBMIT, or DELETE.


## SUPPORTING R4 DOCUMENTS — 2026-08-29

The following existing documents are supporting R4 evidence and are kept under `evidence/R4/`; they are not separate Workstream E/R implementations:

- `evidence/R4/WORKSTREAM_E_EXTERNAL_ACCOUNT_AUTHORIZATION.md` — detailed Google authorization implementation, security boundary, operator prerequisites, and runtime authorization proof.
- `evidence/R4/WORKSTREAM_E_GOOGLE_AUTH_OPERATOR_SETUP.md` — operator setup/runbook for Google OAuth configuration and credential wiring.

The primary R4 record is this document. Supporting documents retain their detail/history; they do not define a separate R4 scope or override the current implementation. The current implementation uses the deployed SH Edge Function callback specified in the authorization record, so earlier Android/mobile-client wording in the operator runbook is historical and does not override the current implementation.

## R4 CURRENT DEV AUDIT — 2026-08-29

Current DEV CI line is GREEN. R4 implementation is present and automated verification is green. Remaining R4 gates are live Google OAuth E2E and live Google Calendar mutation proof. CI does not imply runtime acceptance.
