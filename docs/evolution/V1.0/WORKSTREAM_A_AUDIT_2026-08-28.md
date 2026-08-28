# SECOND HEAD V1.0 — WORKSTREAM A AUDIT

Status: **IN PROGRESS / NON-CANONICAL**
Date: 2026-08-28
Branch: `dev`

## Scope

Foundation Reconciliation & Stabilization sesuai ROADMAP V1.0: App architecture/current tree; App → runtime contracts; authentication → account → SH identity continuity; owner navigation; database source artifacts vs DEV database; provider coupling; build/test verification surface; blockers/regressions.

## Evidence baseline

### App

Current App is React Native + Expo. Verified current surfaces include Chat, Journey, Lifecycle-related routes, More, Authorization, Runtime verification, Experience and lifecycle-related routes, authentication/account services, and the runtime service adapter.

`app/services/backend.ts` is the current App-side Supabase client boundary.

### Runtime

`app/services/runtime.ts` invokes `runtime-p4a-001` through the backend client and requires an authenticated session/bearer token. The runtime deployment workflow stages `functions/runtime-p4a-001` into the Supabase Edge Function deployment path.

Runtime, `runtime-p4a-001`, and Supabase Edge Functions remain distinct concepts.

### Authentication / account / SH continuity

The intended App flow is:

```text
Auth session
   ↓
Authenticated account
   ↓
SH instance(s)
   ↓
ownership / role context
   ↓
owner-facing App
```

A source audit found two concrete implementation defects:

1. `app/services/auth.ts` referenced an undefined `supabase` identifier instead of the established `backend` boundary.
2. `app/services/account.ts` contained the same undefined `supabase` reference in account, SH-instance, and ownership queries.

Both were corrected to use the existing `backend` client.

Fix commits:

- `0e1634a5df1656eed6390bbf4a93e3637447800e`
- `78394b2494f6daab44c75cf4e6fd52ddba373f92`

### Owner navigation

Current authenticated entry redirects to:

```text
Chat
  ├─ Chat
  ├─ Journey
  ├─ Lifecycle
  └─ More
```

The current More surface exposes technical verification/authorization controls while keeping daily use centered on Chat, Journey, and Lifecycle.

### Database

DEV Supabase project: `pkhkgvsrqeupvwoqjwmd`

Current DEV database contains the major SH domains including identity, ownership, permission/governance, memory, knowledge, audit, conversations, Journey, clone/inheritance/succession, recovery, portability, high-risk runtime confirmation, and Experience.

All listed DEV tables have RLS enabled.

Repository database source structure remains:

```text
database/
└── migrations/
```

No `database/supabase/` provider-specific source tree was introduced.

### Migration reconciliation

Remote DEV migration history is populated through the current Bug 006-related migration set.

A historical naming/timestamp discrepancy exists between repository migration filenames and remote migration version metadata. This remains a reconciliation/documentation issue, not permission to replay or mutate DEV history.

No DEV reset or migration replay was performed for this audit.

### Provider coupling

Current state remains:

```text
SH
 ↓
Application / Runtime contracts
 ↓
current provider implementation
 ↓
Supabase
```

Provider coupling still exists in the App backend client, Auth infrastructure, runtime deployment, and server/database implementation.

This is expected for the current foundation and is not evidence of true multi-provider/database portability.

### CI / verification surface

Dedicated workflows exist for Android build, Chat/runtime verification, runtime deployment, high-risk runtime verification, semantic signal verification, and controlled runtime verification.

The Android workflow includes dependency installation, Expo dependency reconciliation, TypeScript typecheck, clean Android prebuild, autolinking verification, Gradle release APK build, and APK/JS bundle existence checks.

The Chat verification workflow includes App typecheck, chat/runtime contract checks, authenticated runtime response and streaming verification, recovery round-trip verification, and recovery Journey verification.

## Verification limitations

This audit was performed against the current DEV repository/database/tool state.

The available GitHub connector does not expose a general current-run listing for push-triggered Actions in this audit path, and the local environment cannot clone GitHub because network/DNS access is unavailable.

Therefore **fresh CI execution of typecheck/Android build is not claimed here**.

Static source audit did identify the two undefined `supabase` references and they have been fixed.

## Current Workstream A status

### CLOSED / VERIFIED

- current App exists;
- current owner navigation exists;
- current runtime adapter exists;
- runtime deployment boundary is identified;
- database DEV domain inventory is present;
- database artifact location follows the provider-neutral repository rule;
- provider coupling is identified;
- two concrete App service-layer backend-boundary defects were corrected.

### OPEN

- fresh CI typecheck after the fixes;
- fresh Android release build after the fixes;
- fresh authenticated runtime/Chat verification after the fixes;
- full database artifact-by-artifact reconciliation against DEV;
- complete current blocker/regression inventory;
- formal final A exit decision.

## Exit gate

Workstream A is **not yet declared complete**.

It becomes complete only after the remaining runtime/build/database verification evidence is obtained and no blocking regression remains.

END OF WORKSTREAM A AUDIT
