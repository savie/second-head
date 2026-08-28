# SECOND HEAD V1.0 — ROADMAP

Status: **WORKING / NON-CANONICAL**
Branch: `dev`
Last refinement: 2026-08-28

This roadmap is an evolution plan, not a Canonical change.

## 0. Planning rule

V1.0 is an evolution of the verified DEV foundation, not a restart.

The ordering below is dependency-oriented:

```
VERIFY FOUNDATION
      ↓
STABILIZE APP/RUNTIME CONTRACTS
      ↓
MODERNIZE OWNER EXPERIENCE
      ↓
MULTIMODAL / FILE CAPABILITY
      ↓
UNIFY MEMORY / KNOWLEDGE / EXPERIENCE / JOURNEY / SEARCH
      ↓
TOOLS / HANDS / AUTHORITY
      ↓
PORTABILITY BOUNDARY
      ↓
LOCAL / OFFLINE
      ↓
LOCAL GGUF
      ↓
V1.0 RELEASE CANDIDATE
```

An item may be explored earlier, but implementation should not bypass a prerequisite when the dependency is material.

---

## 1. Current verified starting point

The current DEV state is materially beyond the original V1.0 brainstorming baseline.

Verified on 2026-08-28:

- GitHub `dev` is the active development branch.
- SH App already exists as a React Native + Expo delivery layer.
- Current App includes Chat, Journey, Lifecycle-related surfaces, authentication, runtime/backend service boundaries, and owner UX work.
- `app/services/backend.ts` is the current client-side provider boundary; application features should not import Supabase directly.
- Runtime/server implementation remains provider-coupled to Supabase Edge Functions and Supabase APIs.
- Database artifacts remain under `database/`, with migrations under `database/migrations/`.
- Supabase DEV project `pkhkgvsrqeupvwoqjwmd` is populated with the current SH domains, including identity, ownership, memory, knowledge, conversations, Journey, Experience, lifecycle, recovery, portability, and high-risk confirmation structures.
- Remote migration history is verified through the current DEV migration set; historical repository/remote timestamp discrepancies remain a documentation/reconciliation concern, not permission to replay old migrations.
- A provider-dependency audit exists and explicitly does **not** claim database/provider portability is complete.
- Canonical SH Core remains the highest conceptual authority.

Therefore the first V1.0 task is **not** to create the App skeleton again. The immediate work is to verify and stabilize the existing foundation against the intended V1.0 product direction.

---

## 2. Workstream A — Foundation Reconciliation & Stabilization

**Priority: prerequisite**

Purpose: establish the exact baseline from which V1.0 feature work can safely proceed.

### Required work

- reconcile current App architecture against the current DEV tree;
- reconcile current runtime contracts used by the App;
- verify authentication → account → SH identity continuity;
- verify current owner-facing navigation against the latest UX structure;
- audit database source artifacts against the running DEV database;
- document remaining repository/remote migration-history gaps without mutating DEV merely for cosmetic convergence;
- map remaining Supabase coupling;
- verify build, typecheck, lint, tests, and current Android delivery path;
- identify active blockers/regressions before adding new capability.

### Exit condition

A reproducible DEV baseline exists with known:

- working surfaces;
- partial/cosmetic surfaces;
- known bugs;
- provider-specific boundaries;
- database synchronization gaps;
- test/build status.

**No large V1.0 feature should be treated as implementation-ready until this baseline is closed enough to make its dependencies explicit.**

---

## 3. Workstream B — Owner UX Consolidation

**Depends on: A**

The current App already has an owner-facing navigation direction. V1.0 work should therefore refine and consolidate it rather than recreate navigation from the earlier brainstorming model.

Current working direction:

```
AUTH
  ↓
CHAT
  ↓
Chat | Journey | Lifecycle | More
```

### Target qualities

- conversation-first;
- lightweight mobile interaction;
- clear loading/empty/offline/error states;
- readable attachment and runtime states;
- Journey as the continuity/history surface;
- Lifecycle as an action/process surface;
- Memory/Knowledge/Experience exposed through meaningful Journey/context flows rather than placeholder screens;
- technical diagnostics detailed but copyable/selectable;
- no client-side duplication of governance, identity, ownership, or authorization.

### Exit condition

The primary owner flow is coherent enough that new V1.0 capabilities can plug into it without repeatedly redesigning the navigation model.

---

## 4. Workstream C — Multimodal & File Intelligence

**Depends on: A + B**

Existing attachment capability should evolve into a coherent multimodal interaction model.

### Explore / implement in dependency order

1. attachment lifecycle and UI states;
2. multiple attachments;
3. image input;
4. file intelligence / analysis;
5. camera input where justified;
6. multimodal conversation;
7. image understanding;
8. image generation.

The exact provider/runtime path for image generation remains an open design decision until verified.

### Exit condition

Multimodal capabilities are real runtime-backed flows, not presentation-only controls, with clear failure and processing states.

---

## 5. Workstream D — Continuity & Intelligence Surfaces

**Depends on: A + B**

This workstream integrates capabilities that already have meaningful backend/domain foundations.

Core relationship:

```
Conversation
    ↕
Experience
    ↕
Memory / Knowledge
    ↕
Journey
    ↕
Search
```

### D1 — Memory

Refine owner-visible memory behavior and continuity without changing Canonical semantics.

### D2 — Knowledge

Refine authorized knowledge retrieval/presentation. Keep private memory distinct from shared/general knowledge.

### D3 — Experience

Use the existing Experience domain as a distinct semantic domain; do not collapse it into transcript storage or Journey storage.

### D4 — Journey

Make Journey the useful continuity/history view across relevant event sources, with provenance/source navigation and meaningful detail.

### D5 — Global SH Search

Define the searchable SH scope, authorization boundary, provenance, and result model before building a broad search UI.

### Dependency note

Search should consume authorized backend retrieval contracts. The App must not download unrestricted private memory and search it locally.

### Exit condition

The user can move between conversation, continuity, source/history, and authorized information without those surfaces becoming disconnected silos.

---

## 6. Workstream E — Hands / Tools / Authority

**Depends on: A + stable runtime contract + D-level context/continuity where required**

This is a system capability layer, not merely a UI feature.

Conceptual flow:

```
SH
 ↓
Capability / Tool
 ↓
Authority
 ↓
Authorization / Risk Gate
 ↓
Execution
 ↓
Result
 ↓
SH
```

### First implementation boundary

Define a minimum useful tool contract covering:

- capability identity;
- invocation contract;
- actor/SH context;
- authorization;
- risk classification;
- confirmation when required;
- execution;
- result normalization;
- audit/event recording.

Distinguish:

- built-in Tools;
- Extensions/Plugins;
- provider/model capabilities.

Do not introduce a plugin marketplace or broad extension ecosystem before the execution/authority contract is stable.

### Exit condition

At least one meaningful tool/action can traverse the complete authorized lifecycle without putting authority decisions in the App.

---

## 7. Workstream F — Provider & Infrastructure Boundary

**Depends on: A; should be informed by B–E contracts**

Current state is **provider-contained, not provider-agnostic**.

The intended boundary is:

```
SH
 ↓
Application / Runtime contracts
 ↓
Data / Infrastructure boundary
 ↓
Provider implementation
```

### Current reality

- App provider-specific access is concentrated in `app/services/backend.ts`.
- Supabase Auth remains current authentication infrastructure.
- Runtime functions remain deployed through Supabase Edge Functions.
- Server/database code still uses Supabase APIs.
- Database source artifacts remain provider-neutral in repository structure.

### Work

- preserve the existing boundary;
- identify provider-specific assumptions in contracts;
- avoid premature multi-provider abstraction;
- define which interfaces would be required for future provider replacement;
- do not claim drop-in multi-database or multi-provider support until demonstrated.

### Exit condition

Provider coupling is explicitly mapped and does not leak unnecessarily into product feature modules.

---

## 8. Workstream G — Local Storage & Offline

**Depends on: A + stable application/data contracts + sufficient F-level boundary clarity**

Offline is not a cosmetic network-status feature.

Questions that must be resolved before implementation:

- which data is locally available;
- which operations are read-only offline;
- which mutations can be queued;
- synchronization/conflict policy;
- authentication/session behavior offline;
- recovery after interrupted synchronization;
- user-visible offline/error semantics;
- privacy/security of local data.

### Exit condition

A bounded offline capability has explicit ownership, synchronization, privacy, and recovery semantics.

Do not attempt full offline parity by default.

---

## 9. Workstream H — Local GGUF Runtime

**Depends on: A + F + G**

Local GGUF is intentionally late because it crosses several boundaries at once:

- model execution;
- local storage;
- device resources;
- offline behavior;
- model lifecycle;
- provider/model abstraction;
- UX for model availability and failure.

### Explore first

- viable Android local inference runtime;
- supported GGUF model classes/sizes;
- model storage outside the APK package where appropriate;
- download/update/delete lifecycle;
- memory/CPU/GPU constraints;
- fallback between local and remote execution;
- privacy implications;
- runtime contract compatibility.

This remains a design/exploration item, **not an implementation commitment**.

### Exit condition

A local inference path can be introduced without redefining SH identity, ownership, or core runtime semantics.

---

## 10. Cross-cutting dependency rules

### Identity / ownership

Any feature touching private SH state must preserve:

- authenticated ownership;
- server-side authorization;
- private-data isolation;
- SH identity continuity.

### Memory / Knowledge

```
Private Memory ≠ Shared Knowledge
Learning ≠ Automatic Core Modification
```

No V1.0 feature may silently promote private experience into shared/system knowledge.

### Tools / Actions

```
UI confirmation ≠ authorization
Runtime access ≠ ownership
```

High-risk operations remain runtime-authorized and auditable.

### Provider portability

```
Current provider = implementation
SH identity = system concept
```

Do not allow current Supabase implementation details to become accidental product semantics.

### Canonical boundary

Evolution may propose UX/product/technical development.

It may not silently redefine Canonical SH Core, identity, governance, privacy, ownership, or continuity semantics.

---

## 11. V1.0 implementation order

The recommended implementation order is now:

```
A  Foundation Reconciliation & Stabilization
        ↓
B  Owner UX Consolidation
        ↓
C  Multimodal & File Intelligence
        ↓
D  Continuity & Intelligence Surfaces
        ↓
E  Hands / Tools / Authority
        ↓
F  Provider & Infrastructure Boundary
        ↓
G  Local Storage & Offline
        ↓
H  Local GGUF Runtime
        ↓
V1.0 Release Candidate
```

This is **not** a rigid waterfall.

Work may be prototyped in parallel when it does not violate a dependency. However, an implementation should not be declared complete while a prerequisite contract it materially depends on remains unresolved.

---

## 12. Release Candidate gate

V1.0 RC requires more than UI coverage.

At minimum, relevant work must be:

- implemented;
- runtime-backed where applicable;
- authorized correctly;
- persistence/data behavior verified;
- tested;
- build-verified;
- documented enough to reproduce;
- free of known blocking regressions;
- consistent with Canonical invariants.

A capability represented only by navigation, placeholder screens, or mocked behavior does not satisfy the V1.0 gate.

---

## 13. Explicitly deferred / unresolved

The following remain open unless separately resolved:

- exact final V1.0 feature inventory;
- exact image-generation provider/runtime;
- complete global Search semantics;
- complete Project boundary and scope;
- minimum Tool contract details;
- Extension/Plugin contract;
- multi-provider/database abstraction depth;
- offline synchronization model;
- local inference runtime choice;
- local GGUF model lifecycle;
- final V1.0 release scope.

These are not blockers to the roadmap refinement itself. They are decision points that must be resolved before the affected implementation slice is treated as committed.

---

## 14. Relationship to other documents

Authority remains:

1. **Canonical** — highest conceptual authority.
2. Approved/verified architecture and implementation contracts — technical constraints for current DEV implementation.
3. `docs/evolution/V1.0/` — working product/evolution planning.
4. `docs/resume/` — continuity/history, not final authority.

This roadmap must not rewrite Canonical or historical Phase/Resume material.

END OF SECOND HEAD V1.0 — ROADMAP
