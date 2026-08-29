# SECOND HEAD V1.0 — WORKSTREAM E TOOL — R6 TASK REMINDER

Status: **IMPLEMENTED / CI VERIFICATION PENDING**
Date: 2026-08-29
Branch: `dev`

## 1. Position

R6 is the selected representative capability for:

- Family: E — Productivity & Communication
- Candidate: Task / Reminder
- Selection: R6
- Role: create a persistent SH-owned productivity task with a future due time.

R6 is intentionally local to SH. It does not introduce another external provider after R4.

## 2. Capability Delta

R4 is an external Calendar CREATE_EVENT action.

R6 is a persistent SH-owned productivity object:

`owner request → task/reminder → persisted due time → trace`

It therefore represents a different capability rather than duplicating Google Calendar.

## 3. Bounded Flow

```
OWNER REQUEST
→ authenticated SH runtime
→ R6 task boundary
→ owner-scoped persistence
→ task result
→ conversation + audit trace
```

The representative natural-language form is deterministic:

`Remind me at YYYY-MM-DDTHH:MM±HH:MM to <task>`

An explicit runtime operation may also supply the same title and ISO due time.

## 4. Data Boundary

Table:

`public.r6_tasks`

Stored fields include:

- task identity;
- account and SH identity;
- actor identity;
- title;
- due time;
- OPEN / COMPLETED / CANCELLED status;
- source;
- timestamps.

Direct table mutation is not exposed to the client. Creation is through the authenticated `r6_create_task` RPC, which derives account/SH context from the authenticated session.

Task listing uses the owner-scoped `r6_list_tasks` RPC.

## 5. Security Boundary

R6 reuses the existing authenticated account → SH ownership boundary.

- unauthenticated requests are rejected by Runtime;
- the task RPC derives the current account;
- the SH identity is resolved from that account;
- task rows are owner-scoped;
- direct client INSERT/UPDATE/DELETE privileges are not granted;
- task creation records actor identity from `auth.uid()`.

R6 does not treat the task capability as authority.

## 6. Risk

Creating an internal owner task is a bounded LOW-risk state mutation. It does not mutate SH identity or ownership and does not perform an external side effect.

No external confirmation gate is added for this low-risk slice.

The existing P4F action modules remain the architectural reference for later generalized action execution; R6 does not silently redefine the generic P4F contract.

## 7. Scheduling Boundary

R6 persists a future due time. It does **not** claim that V1.0.0 has a background notification scheduler.

Therefore:

- task creation = in scope;
- due-time persistence = in scope;
- task listing = in scope;
- OS push/local notification delivery = out of scope for this slice;
- autonomous background execution = out of scope.

This is deliberate: it proves the productivity capability without adding a new notification infrastructure or hardware/provider dependency.

## 8. Failure Handling

Reject:

- missing title;
- invalid due time;
- due time in the past;
- missing authenticated account/SH;
- persistence failure.

Failure never returns a successful task result.

## 9. Audit

Successful creation records:

- R6 capability;
- CREATE_TASK operation;
- action ID;
- authenticated authorization basis;
- due time;
- task ID;
- result status.

This reuses the existing Runtime audit boundary.

## 10. Non-Goals

R6 does not establish:

- Google Tasks integration;
- Gmail integration;
- external notification provider;
- push-notification infrastructure;
- autonomous task execution;
- recurring task engine;
- generic workflow automation;
- calendar event duplication;
- broad task-management platform.

## 11. Exit Condition

R6 is complete for the bounded representative slice when DEV verification demonstrates:

`OWNER → REQUEST → CREATE_TASK → PERSIST → RETURN → AUDIT`

with an owner-scoped task and future due time.

CI must remain green.

Runtime verification should create one disposable future task and verify its returned task ID, owner scope, OPEN status, due time, and audit trace.

## 12. Current Status

Implementation added to DEV:

- `r6_tasks` owner-scoped table;
- authenticated `r6_create_task` RPC;
- owner-scoped `r6_list_tasks` RPC;
- Runtime R6 operation and deterministic reminder phrase;
- action/audit metadata;
- contract regression tests.

**Current status: IMPLEMENTED / CI VERIFICATION PENDING.**

R6 does not modify Canonical scope.
