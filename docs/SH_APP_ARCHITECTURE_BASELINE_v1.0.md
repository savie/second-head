# SECOND HEAD — SH APP ARCHITECTURE BASELINE v1.0

Status: DEV IMPLEMENTATION BASELINE / OWNER-DERIVED
Authority class: NON-CANONICAL DELIVERY ARCHITECTURE BASELINE
Branch: `dev`

## 0. Purpose

This document translates the approved delivery direction for SECOND HEAD into an implementable mobile application architecture before creation of the `app/` skeleton.

It defines:

- folder/module contract;
- App ↔ Runtime ↔ Supabase boundaries;
- API/runtime contract;
- authentication/session contract;
- data-flow contract;
- security boundary;
- testing contract;
- GitHub/CI/build integration expectations.

This document does not replace the Frozen Baseline, SH Core Canonical, Build Scope, Implementation Contract, Implementation Guide, Architecture, Execution Strategy, or Phase -1 authority.

## 1. Approved Delivery Direction

Owner-approved toolchain direction:

> React Native + Expo as the initial application delivery layer, with a native escape hatch when a material capability requirement is proven.

This is not a commitment to a specific model provider, streaming protocol, build provider, or native module set.

Current fixed infrastructure:

- GitHub repository: `savie/second-head`
- active development branch: `dev`
- Supabase project: `second-head`
- Supabase project ref: `pkhkgvsrqeupvwoqjwmd`
- runtime: existing TypeScript/Deno/Supabase Edge Function runtime
- delivery target: Android APK

The repository's current `dev` tree contains `database/`, `docs/`, `runtime/`, and `supabase/`; this baseline introduces the future `app/` delivery layer without replacing those existing surfaces.

## 2. Architectural Principle

The application is a delivery surface over the existing SH Core/Runtime foundation.

```text
USER
  ↓
SH APP (React Native + Expo)
  ↓ authenticated requests
SH RUNTIME / API BOUNDARY
  ↓
SUPABASE AUTH + RLS + DATABASE + EDGE FUNCTIONS
  ↓
MODEL / TOOLS / EXTERNAL PROVIDERS
```

The application must not become a second implementation of SH governance, identity, ownership, authorization, memory policy, or runtime policy.

Core invariants remain:

- Model ≠ SH Identity
- Runtime ≠ SH Identity
- Database ≠ SH Identity
- Hardware ≠ SH Identity
- Creator Authority ≠ Private Data Access
- Memory ≠ Knowledge
- Private Memory ≠ Shared Knowledge
- Learning ≠ Automatic Core Modification
- Clone ≠ Source SH
- Inheritance ≠ Clone
- Inheritance ≠ Automatic Identity Transfer
- Recovery ≠ New SH

## 3. Repository / Folder Contract

The future application is a sibling delivery surface, not a replacement for existing backend/runtime directories.

```text
/
├── app/                         # NEW: mobile delivery application
│   ├── app/                     # Expo Router route surface
│   ├── components/              # reusable presentation components
│   ├── features/                # feature modules grouped by product capability
│   ├── services/                # App-side API/runtime service adapters
│   ├── state/                   # client/session/UI state boundaries
│   ├── storage/                 # secure local storage adapters
│   ├── hooks/                   # app-specific React hooks
│   ├── types/                   # client contract types
│   ├── lib/                     # small framework/infrastructure helpers
│   └── tests/                   # app tests
│
├── runtime/                     # EXISTING SH runtime implementation
├── supabase/                    # EXISTING Supabase functions/migrations
├── database/                    # EXISTING database/history artifacts
└── docs/                        # architecture/evidence/documentation
```

### Module rules

`features/` owns product capabilities, not backend policy.

Suggested initial feature boundaries:

```text
features/
├── auth/
├── chat/
├── journey/
├── memory/
├── knowledge/
├── search/
├── actions/
├── clone/
├── inheritance/
├── recovery/
└── settings/
```

A feature may contain UI, hooks, view models, and service calls, but authorization decisions remain server-side.

## 4. App ↔ Runtime Contract

### App responsibilities

The App may:

- collect user input;
- render authenticated SH state;
- render conversations and authorized search/results;
- initiate runtime requests;
- render runtime status/events;
- request high-risk actions;
- collect explicit user confirmation;
- display clone/inheritance/recovery workflows;
- manage navigation and transient UI state;
- hold minimal secure session material.

### App must not own

- canonical SH identity creation;
- ownership authority;
- permission evaluation;
- private-data authorization;
- governance decisions;
- high-risk authorization decisions;
- model-provider secrets;
- service-role credentials;
- unrestricted memory export;
- runtime policy implementation.

## 5. API / Runtime Contract

The App communicates with stable runtime/application contracts rather than reaching directly into runtime implementation modules.

Conceptual request envelope:

```json
{
  "request_id": "uuid",
  "sh_id": "uuid",
  "conversation_id": "uuid|null",
  "operation": "CHAT|SEARCH|ACTION|JOURNEY|CLONE|INHERITANCE|RECOVERY|PORTABILITY",
  "payload": {},
  "client_context": {
    "app_version": "string",
    "platform": "android"
  }
}
```

Conceptual response envelope:

```json
{
  "request_id": "uuid",
  "status": "SUCCESS|REJECTED|FAILED|CONFIRMATION_REQUIRED",
  "event_type": "RESPONSE|TOKEN|TOOL|CONFIRMATION|ERROR|COMPLETE",
  "payload": {},
  "error": null
}
```

These envelopes are architectural contracts, not yet a frozen wire-format specification. Exact field names and endpoints must be reconciled against existing runtime contracts before implementation of the first API adapter.

### Runtime responsibilities

Runtime resolves/validates:

1. authenticated actor;
2. account identity;
3. SH identity;
4. ownership/authority context;
5. relevant context;
6. memory/knowledge retrieval;
7. model selection/fallback;
8. tool selection/execution;
9. risk/authorization gates;
10. audit/event recording.

## 6. Authentication / Session Contract

Authentication is a product flow backed by Supabase Auth and the existing account/identity model.

```text
App launch
  ↓
restore authenticated session
  ↓
Supabase Auth
  ↓
resolve ACCOUNT_ID
  ↓
resolve SH identity
  ↓
load authorized app bootstrap state
  ↓
authenticated application
```

The App must not invent a parallel account/SH identity model.

Existing DEV foundations include:

- `accounts`
- `account_auth_links`
- `sh_instances`
- `sh_ownership`

and the existing authentication/identity boundary is expected to remain authoritative.

### Session rules

- Session/token material is treated as sensitive client state.
- Secure native storage is preferred for persisted session material.
- No service-role key may reach the App.
- No model-provider secret may reach the App.
- Logout clears local authenticated session material.
- Expired/invalid sessions return the user to authentication without silently creating a new SH.

## 7. Supabase Contract

The App may use the public Supabase client surface where the operation is intentionally client-safe and protected by RLS.

Runtime-sensitive operations should cross the runtime/API boundary.

### Direct client candidates

- authentication/session operations;
- narrowly scoped owner-visible reads protected by RLS;
- narrowly scoped non-sensitive mutations explicitly designed for client access.

### Runtime/API candidates

- chat/runtime invocation;
- context assembly;
- model selection/fallback;
- tool execution;
- high-risk actions;
- clone creation;
- inheritance execution;
- recovery/restore;
- portability generation;
- governance-sensitive operations.

The App must never use a service-role credential.

## 8. Data-Flow Contract

### Chat

```text
User input
  ↓
Chat UI
  ↓
App chat service
  ↓
authenticated runtime request
  ↓
identity + authorization
  ↓
context / memory / knowledge
  ↓
model abstraction / selection / fallback
  ↓
optional tool execution
  ↓
normalized runtime response/events
  ↓
Chat UI
```

The App must not call an LLM provider directly for SH chat.

### Search

```text
Search input
  ↓
App Search Service
  ↓
authorized backend retrieval
  ↓
privacy/ownership boundary
  ↓
results
  ↓
App
```

The App must not download the complete private memory store and perform unrestricted local search.

### High-risk action

```text
User request
  ↓
Runtime evaluates action
  ↓
if high-risk
  ↓
CONFIRMATION_REQUIRED
  ↓
App confirmation UI
  ↓
explicit confirmation request
  ↓
Runtime re-validates authorization
  ↓
execute
  ↓
audit
```

A UI confirmation button is not itself an authorization decision.

### Clone

```text
Source SH
  ↓
clone request
  ↓
agreement / participant boundary
  ↓
approval
  ↓
runtime clone operation
  ↓
new CLONE_SH
```

### Recovery

```text
Select recovery snapshot
  ↓
show identity/ownership validation
  ↓
explicit confirmation
  ↓
runtime restore
  ↓
validate original SH identity
  ↓
record recovery event
```

Recovery must not silently create a replacement SH identity.

## 9. Security Boundary

### Client-safe

- public Supabase project URL;
- Supabase anon/public client key where required by the established Supabase client model;
- non-sensitive app configuration;
- transient UI state.

### Server-only

- Supabase service-role key;
- model-provider API keys;
- privileged governance credentials;
- privileged runtime credentials;
- unrestricted export/recovery authority;
- any secret capable of bypassing RLS.

Existing repository environment convention already separates public Expo variables from backend secrets. `.env.example` explicitly marks `EXPO_PUBLIC_SUPABASE_URL` and `EXPO_PUBLIC_SUPABASE_ANON_KEY` as public client configuration and service-role/model keys as backend secrets.

### RLS

RLS remains a backend security boundary.

The current DEV state contains an intentionally reconciled exception:

`private.authority_assignments` currently has RLS disabled and is treated by the existing project checkpoint as an internal governance condition. This baseline does not change that condition.

No App implementation may expose this private authority table directly to ordinary client code.

## 10. State / Context Contract

Client state is divided into bounded domains:

```text
AuthState
SHState
ConversationState
RuntimeState
UIState
```

Server state remains server-authoritative.

The App must not cache an alternative authoritative copy of ownership, governance, private memory authorization, or SH identity.

## 11. Navigation Contract

Initial product navigation is capability-oriented rather than table-oriented.

```text
AUTH
├── Welcome
├── Login / Sign up
└── Account bootstrap

MAIN
├── Chat
├── Journey
├── Memory
├── Knowledge
└── Search

SH
├── Identity / Status
├── Continuity
├── Clone
├── Inheritance
└── Recovery / Portability

SETTINGS
├── Account
├── Security
└── App / Runtime status
```

Exact navigation implementation is intentionally deferred until the skeleton is created.

## 12. Streaming Contract

The App is streaming-ready but provider-agnostic.

The expected normalized event categories are:

- response/token text;
- tool status;
- confirmation required;
- error;
- completion.

The runtime owns provider-specific streaming semantics and normalizes them before the App consumes them.

No model provider is frozen by this baseline.

## 13. Testing Contract

Testing is layered.

### Layer 1 — App unit/component

Must cover:

- authentication screens;
- navigation;
- chat rendering;
- streaming event handling;
- confirmation UI;
- clone/recovery UI states;
- loading/error/empty states;
- secure-storage adapter behavior through mocks.

### Layer 2 — App service contract tests

Must verify:

- authenticated request construction;
- response-envelope handling;
- session expiry behavior;
- runtime error mapping;
- confirmation-required handling;
- no secret leakage into request payloads/logs.

### Layer 3 — Runtime contract tests

Existing runtime tests remain authoritative for runtime behavior. App tests must not replace them.

### Layer 4 — Integration / DEV tests

Verify:

```text
App
 ↓
Auth
 ↓
Runtime
 ↓
Supabase
 ↓
response/event
 ↓
App
```

### Layer 5 — Product E2E

Eventually verify complete user-visible flows:

- sign in → authenticated SH;
- chat → runtime → model → response;
- search → authorized result;
- high-risk action → confirmation → execution/audit;
- clone → agreement → approval → clone;
- recovery → identity validation → restore;
- continuity gap rendered correctly.

Product E2E is not claimed complete by this baseline.

## 14. GitHub / CI Contract

All App work is developed on `dev` first.

Repository history remains the audit trail.

Expected future checks for App changes:

```text
format / lint
   ↓
typecheck
   ↓
App unit/component tests
   ↓
Runtime contract tests
   ↓
integration checks
   ↓
Android build validation
   ↓
artifact/evidence
```

The exact build provider is not frozen here. Expo remains the selected application framework direction; EAS is not mandatory by this baseline.

CI must not require paid hardware.

## 15. Build / APK Contract

Target output:

`Android APK`

Initial strategy:

- Expo-managed development capabilities first;
- development build when native/device capabilities require it;
- native escape hatch/CNG if a real requirement emerges;
- no rewrite of the App solely because a native capability is later introduced.

A capability may justify native customization only after the requirement is demonstrated and the Expo capability set is insufficient.

## 16. Implementation Sequence

The first App implementation should proceed in vertical slices:

```text
A. app skeleton + configuration
      ↓
B. Supabase Auth/session bootstrap
      ↓
C. SH identity bootstrap
      ↓
D. navigation + app state boundaries
      ↓
E. runtime API adapter
      ↓
F. chat request/response
      ↓
G. streaming/event normalization
      ↓
H. confirmation gate UI
      ↓
I. search / memory / journey surfaces
      ↓
J. clone / inheritance / recovery surfaces
      ↓
K. App integration tests
      ↓
L. CI / APK build
```

Each slice follows:

`reconcile → minimal realization → verify → evidence → commit to dev`

## 17. Explicit Non-Decisions

This baseline does NOT decide:

- LLM provider;
- production model;
- model routing policy beyond existing runtime abstraction;
- exact streaming transport;
- state management library;
- exact secure-storage package;
- EAS as mandatory build service;
- production deployment topology;
- future native modules;
- production Product E2E completion.

These must not be invented during skeleton implementation.

## 18. Acceptance Gate Before App Skeleton

The App skeleton is considered architecturally ready when:

- App is clearly separated from Runtime and Supabase;
- authentication maps to existing Account/SH identity boundaries;
- no client secret path exists;
- runtime invocation has a stable adapter boundary;
- high-risk confirmation is explicitly modeled as a server-authorized workflow;
- clone/recovery/continuity are represented without violating identity invariants;
- testing layers are defined;
- GitHub `dev` is the development source of record;
- no settled backend Phase 1–5 work is reopened without material reason.

## 19. Status

This document is the current DEV implementation baseline for the SH App delivery layer.

It is intentionally more precise than the earlier discussion draft but remains subordinate to canonical authorities and Owner decisions.

Next implementation step after acceptance:

> Create the minimal `app/` Expo/React Native skeleton on `dev`, then verify the skeleton against this baseline before adding product features.

END OF SH APP ARCHITECTURE BASELINE v1.0
