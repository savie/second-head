# SECOND HEAD V1.0 — WORKSTREAM E TOOL — R7 CONNECTOR ADAPTER

Status: **IMPLEMENTED / CI VERIFICATION PENDING**
Date: 2026-08-29
Branch: `dev`

## 1. Position

R7 is the selected representative capability for:

- Family: G — Integration & Extension
- Candidate: Connector / Adapter
- Selection: R7
- Role: demonstrate that an external provider capability can be reached through an explicit SH connector boundary without moving authority into the connector.

## 2. Why R7

R1–R6 demonstrate bounded capabilities/actions.

R7 demonstrates the next architectural property of Hands:

> external capability connectivity can be isolated behind a connector/adapter boundary.

R7 deliberately does **not** introduce a plugin marketplace, generic MCP platform, or broad extension ecosystem.

## 3. Real Implementation

The existing Google Calendar integration is routed through a new connector adapter:

`runtime/p4g/connectors/google_calendar.ts`

Registry:

`connectorRegistry.google_calendar`

The existing R4 Google Calendar CREATE_EVENT path now invokes this adapter instead of calling the Google Calendar HTTP endpoint inline.

Therefore R7 is not a mock-only demonstration. It is a real integration boundary used by an existing external capability.

## 4. Boundary

```
SH Runtime / R4 Action
        ↓
Google Calendar Connector
        ↓
Google Calendar API
        ↓
Normalized Result
        ↓
R4 Action / Audit
```

The connector owns provider transport and result normalization.

It does **not** own:

- SH identity;
- ownership;
- authorization;
- risk classification;
- confirmation;
- permission decisions;
- action lifecycle.

Those remain in the R4 runtime/action boundary.

## 5. Why This Does Not Duplicate R4

R4 proves:

`CREATE_EVENT` against Google Calendar with authorization and confirmation.

R7 proves:

`SH capability → connector/adapter → external provider`.

The same Google Calendar provider is intentionally reused because creating a second external integration only to demonstrate a connector would add complexity without proving a stronger SH capability.

R7 changes the integration architecture, not the R4 semantic action.

## 6. Adapter Contract

The connector receives:

- provider access token;
- bounded Calendar CREATE_EVENT input;
- provider event identifier.

It returns a normalized result containing:

- provider;
- calendar ID;
- external event ID;
- HTML link;
- provider status.

Provider HTTP errors are normalized into existing R4 error codes.

## 7. Authority Boundary

The connector cannot authorize itself.

Required order remains:

`OWNER → IDENTITY → AUTHORIZATION → RISK / CONFIRMATION → EXECUTION → CONNECTOR → RESULT → AUDIT`

A valid connector connection is not equivalent to permission to perform an action.

## 8. Extension / Plugin / MCP Boundary

R7 intentionally stops at Connector / Adapter.

Not included:

- plugin installation system;
- extension marketplace;
- dynamic arbitrary code loading;
- generic MCP client/server platform;
- automatic tool discovery from untrusted providers;
- provider-defined authority.

These remain future design candidates.

## 9. Failure Handling

The adapter normalizes:

- 401/403 → `R4_GOOGLE_CALENDAR_WRITE_REJECTED`;
- 409 → `R4_GOOGLE_EVENT_ID_CONFLICT`;
- other provider failures → `R4_GOOGLE_CREATE_EVENT_FAILED`.

The R4 action layer remains responsible for persisting failure state and audit evidence.

## 10. Tests

R7 includes contract coverage for:

1. connector registry identity;
2. provider rejection normalization;
3. successful provider-result normalization.

The tests use a mocked HTTP boundary only to verify the adapter contract; the production adapter remains wired to the real Google Calendar API.

## 11. Non-Goals

R7 does not establish:

- generic plugin architecture;
- MCP as the SH plugin architecture;
- arbitrary external tool execution;
- multi-provider abstraction;
- provider migration;
- dynamic remote code execution;
- external authority delegation;
- a new Google OAuth flow.

## 12. Exit Condition

R7 is complete for the representative connector slice when DEV verification demonstrates:

`R4 authorized action → connector adapter → provider boundary → normalized result → R4 persistence/audit`

with CI green.

Runtime proof may reuse the existing R4 verification path; no new provider account or paid infrastructure is required.

## 13. Current Status

Implementation added to DEV:

- Google Calendar connector adapter;
- connector registry;
- R4 integration through connector boundary;
- R7 adapter contract tests;
- R7 evolution documentation.

**Current status: IMPLEMENTED / CI VERIFICATION PENDING.**

R7 does not modify Canonical scope.
