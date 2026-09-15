# SECOND HEAD — Journey Manual `+` Local-First Reconciliation

## Status

**WORKING VERIFICATION RECORD — IMPLEMENTATION RECONCILED**

## Authority

Supporting working document only.

This document records the currently implemented UI/runtime boundary for the manual Journey `+` creation path. It does not redefine any Canonical contract or authorize backend Journey creation wiring.

## Scope

In scope:

- Journey screen manual `+` action
- manual selection of Memory / Knowledge / Experience
- Journey editor result
- local `JourneyItem` creation
- local persistence through `JourneyStore.persist()`
- relationship to backend Journey retrieval/reconciliation

Out of scope:

- changing the Journey `+` implementation
- creating a backend Journey RPC
- adding a database migration
- changing semantic lifecycle contracts
- inferring backend persistence from local persistence

## 1. Current Implementation Evidence

The Journey screen exposes a floating action button whose action is `_create(context)`. The button is the manual Journey `+` entry point.

The `_create()` flow first asks the user to select one of three semantic types:

- Memory
- Knowledge
- Experience

It then opens the Journey editor and, when a draft is returned, inserts a `JourneyItem` into the local `items` collection and calls `JourneyStore.persist()`.

Evidence: `app/lib/features/journey/journey_view.dart`.

## 2. Boundary Classification

| Capability | Current state |
|---|---|
| Journey `+` UI | IMPLEMENTED |
| Manual type selection | IMPLEMENTED |
| Journey editor | IMPLEMENTED |
| Local `JourneyItem` creation | IMPLEMENTED |
| Local persistence | IMPLEMENTED |
| Backend semantic create from manual `+` | NOT WIRED |
| Backend Journey record creation from manual `+` | NOT EVIDENCED / OUT OF CURRENT PATH |

## 3. Local-First Semantics

The manual `+` path is **LOCAL-FIRST**.

The source path is:

`Journey +` → select semantic type → Journey editor → `JourneyItem` → `JourneyStore.persist()`

There is no backend semantic create call in this `_create()` path.

This is a current implementation boundary, not an implementation defect by itself.

## 4. Backend Retrieval Is a Separate Path

`_loadJourney()` first restores local Journey state with `JourneyStore.refreshFromDisk()`, then separately loads backend Journey records through `JourneyService().load(...)` and reconciles the resulting view state.

Therefore:

**manual local creation ≠ backend Journey creation**

and:

**backend Journey retrieval/reconciliation ≠ proof that manual `+` writes a backend Journey record.**

## 5. Security / Ownership Boundary

The local Journey store is account-scoped according to the existing Journey local-storage design. This document does not introduce a new authorization mechanism and does not infer backend ownership semantics for the manual `+` path.

Any future backend wiring must separately verify authentication, ownership, authorization, failure behavior, idempotency, and persistence before being classified as implemented or verified.

## 6. Decision

**DECISION: KEEP CURRENT MANUAL `+` PATH LOCAL-FIRST.**

No backend wiring is authorized or required by this reconciliation record.

Do not create a migration or backend RPC solely to make the manual `+` path appear backend-persistent.

## 7. Verification Classification

### Non-E2E

**PASS / RECONCILED** for the current implementation boundary:

- manual `+` exists
- type selection exists
- editor produces a draft
- draft becomes a local `JourneyItem`
- local state is persisted
- backend create is not claimed

### E2E

Runtime/device verification of the complete local flow remains subject to the applicable E2E verification matrix. This document does not convert source inspection into E2E proof.

## 8. Traceability

Implementation source:

`app/lib/features/journey/journey_view.dart`

Primary method:

`JourneyViewState._create(BuildContext context)`

Persistence call:

`JourneyStore.persist()`

Related retrieval path:

`JourneyViewState._loadJourney()`

## 9. Final State

**MANUAL JOURNEY `+` = IMPLEMENTED / LOCAL-FIRST / NON-E2E RECONCILED**

**BACKEND CREATE FROM MANUAL `+` = NOT WIRED / NOT CLAIMED**

**NO DATABASE CHANGE REQUIRED**
