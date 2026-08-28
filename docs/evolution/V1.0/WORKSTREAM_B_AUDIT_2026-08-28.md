# SECOND HEAD V1.0 — WORKSTREAM B AUDIT

Status: **AUDIT / NON-CANONICAL**
Date: 2026-08-28
Branch: `dev`
Depends on: Workstream A — CLOSED

## Purpose

Audit current owner-facing UX against the approved working V1.0 roadmap before implementation. This is not a redesign from scratch.

## Current verified shell

Current authenticated navigation is:

```
Chat | Journey | Lifecycle | More
```

The Expo tab layout directly defines these four owner-facing destinations.

## Findings

### B-1 — Conversation-first entry
**Status: PASS**

Authenticated entry is Chat-oriented and the primary tab is Chat.

The current Chat surface already supports:
- conversation history;
- new conversation;
- rename;
- copy;
- edit/delete message flows;
- streaming state;
- cancellation/background handling;
- attachment selection;
- runtime confirmation state;
- error/system messaging.

This is sufficient as a foundation for B; no shell recreation is justified.

### B-2 — Journey as continuity/history
**Status: PARTIAL / GOOD FOUNDATION**

Journey already presents recorded events with:
- event type;
- date;
- continuity status;
- payload preview;
- source reference;
- detail view;
- visibility/scope;
- transfer policy;
- authorized delete;
- policy editing.

It therefore functions as a real continuity/history surface rather than a placeholder.

Remaining B-level refinement:
- make the relationship between Journey and Chat more obvious;
- preserve source/provenance visibility;
- improve empty/error/loading copy and navigation affordances where useful.

### B-3 — Lifecycle as process/action surface
**Status: PASS / MINOR REFINEMENT**

Lifecycle is explicitly separated from Journey and exposes:
- Clone;
- Recovery;
- Inheritance;
- Succession;
- Legacy;
- End-of-Life.

Descriptions correctly frame Lifecycle as process execution while Journey is where results/history are recorded.

No navigation restructuring is required.

### B-4 — More as technical/account surface
**Status: PASS**

More explicitly keeps technical tools/account controls outside daily Chat/Journey/Lifecycle use.

Current items include:
- Runtime Verification;
- Authorization;
- Account/sign-out;
- build information.

This matches the working direction.

### B-5 — Memory / Knowledge / Experience placement
**Status: GAP / REQUIRES REFINEMENT**

The current Runtime Verification screen exposes authorized Memory, Knowledge, and Journey context lookup for diagnostics.

Experience has its own route and service, but it is not part of the primary owner navigation.

The roadmap's B target says Memory/Knowledge/Experience should be exposed through meaningful Journey/context flows rather than placeholder screens.

Therefore the current state is functional but not yet fully consolidated into the owner experience.

Important: this does **not** justify inventing a new top-level tab. The current roadmap explicitly favors consolidation rather than navigation growth.

### B-6 — State quality
**Status: PARTIAL**

Chat and Journey have meaningful loading/error/empty behavior.

Lifecycle is primarily a static action launcher and does not need a complex loading state, but its process/error semantics are delegated to downstream screens.

More is similarly static.

The remaining priority is consistency of user-facing state language and affordances, not adding state machinery everywhere.

### B-7 — Authorization / governance placement
**Status: PASS**

Authorization is kept as a technical/status surface.

The App does not appear to make ownership/authorization decisions itself; those remain service/runtime concerns.

No client-side governance redesign should be introduced in B.

## B implementation boundary

Workstream B should therefore be a **consolidation pass**, not a broad UI rewrite.

Recommended implementation scope:

1. Preserve the four-tab shell.
2. Refine Chat/Journey handoff and continuity affordances.
3. Improve Journey empty/error/detail discoverability without changing its data contract.
4. Keep Lifecycle as action/process surface and ensure result/history expectations are explicit.
5. Keep More technical and account-focused.
6. Introduce an owner-facing path to Memory/Knowledge/Experience through existing Journey/context surfaces where the current contracts support it.
7. Do not create a new top-level Memory, Knowledge, or Experience tab.
8. Do not move authorization or governance decisions into the client.

## Dependency decision

Workstream B is **implementation-ready for a bounded consolidation pass**.

Workstream C should remain downstream of B completion because multimodal/file UX will plug into Chat and should not force a second navigation redesign.

## No Canonical change

This audit proposes no Canonical modification.

END OF WORKSTREAM B AUDIT
