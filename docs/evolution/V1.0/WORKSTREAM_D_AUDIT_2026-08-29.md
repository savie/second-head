# SECOND HEAD V1.0 — WORKSTREAM D AUDIT

Status: **PLANNING / NON-CANONICAL**
Date: 2026-08-29
Branch: `dev`

## Authority / scope basis

This document derives Workstream D from the current V1.0 roadmap and the latest verified DEV state. It does not modify Canonical SH Core.

Roadmap defines D as **Continuity & Intelligence Surfaces**, with the relationship:

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

Resume 69 confirms that multimodal work is now implemented through C-Close, while Memory/Knowledge/Experience owner experience, global continuity semantics, and Global SH Search remain partial/candidate areas. Therefore D starts from integration of existing domains, not creation of new backend semantics from scratch.

## D objective

Make SH's existing continuity/intelligence domains usable as a coherent owner experience without collapsing their distinct semantics.

The target is **not** five disconnected screens. The target is a navigable relationship between conversation, continuity, source/history, and authorized information.

## D0 — Continuity contract & current-state audit

Before feature implementation:

- inspect current Memory, Knowledge, Experience, Journey, Conversation and relevant search/domain contracts;
- map what is already runtime-backed versus surface-only;
- identify provenance/source references available today;
- identify ownership/authorization boundaries;
- document gaps without silently changing Canonical semantics;
- define the minimum D acceptance contract.

**Exit:** D implementation slices have explicit dependencies and no unresolved prerequisite that would materially invalidate the slice.


## D0 audit result — 2026-08-29

### Verified current implementation

The DEV tree was inspected against the D objective and current runtime boundary.

**Conversation:** runtime already retrieves bounded conversation context through `runtime_load_conversation_context`, while the App uses the existing backend/runtime service boundary rather than introducing a new direct provider path.

**Memory:** the runtime already has bounded retrieval through `retrieve_memories_bounded` and returns a bounded memory context into model orchestration. Memory is therefore not an empty foundation; D1 is primarily an owner-facing continuity/retrieval integration task.

**Experience:** explicit user capture already records Experience as `PRIVATE` / `OWNER_ONLY` through `runtime_record_experience`; runtime can retrieve bounded Experience context through `list_experience_context`. This confirms Experience remains a distinct semantic/runtime domain.

**Journey:** Journey is materially runtime-backed. `journey-service.ts` exposes bounded event retrieval, classification, deletion, synchronized source deletion, selected transfer, and legacy preservation. The Journey App surface already filters events into Memory / Knowledge / Experience / Lifecycle-Other and exposes source/provenance plus record policy controls. D4 therefore extends an existing surface rather than creating Journey from zero.

**Knowledge:** runtime lifecycle handling can attach an acquired knowledge candidate to a Journey candidate. The current Journey UI distinguishes Knowledge from Memory and Experience. However, D0 does not establish that a complete owner-facing Knowledge retrieval/search experience already exists. D2 remains required.

**Search:** no verified general Global SH Search contract was found in the inspected DEV feature/runtime surface. Therefore D5 remains a design + implementation slice and must not be inferred from the existing in-chat “Find in chat” UI, which is conversation-local rather than Global SH Search.

### Boundary findings

1. **No new backend semantic layer is required by D0 itself.** Existing runtime/domain contracts provide the foundation.
2. **Journey is ahead of the other D domains at the owner-surface level.** D4 should integrate and connect it, not duplicate it.
3. **Memory retrieval exists but must not be confused with owner-visible global search.** Bounded retrieval is a runtime context capability; Search is a separate contract.
4. **Experience has explicit capture and bounded retrieval paths.** D3 should preserve that distinction instead of converting it into transcript/history.
5. **Knowledge has evidence of lifecycle integration, but owner-facing retrieval semantics remain insufficiently established for D2 to be skipped.**
6. **The current App “Find in chat” feature is not D5.** It searches only the currently loaded conversation messages.
7. **Authorization must remain server/runtime enforced.** D must not introduce client-side unrestricted private-memory retrieval.

### D0 acceptance contract

For the next D slices, the minimum acceptance contract is now:

- Memory, Knowledge, Experience, Journey and Conversation remain distinct domains.
- Existing backend/runtime boundaries are reused.
- Private Memory remains private; shared/general Knowledge remains distinct.
- Experience is not silently collapsed into transcript or Journey storage.
- Journey references preserve source/provenance where available.
- Search, when implemented, operates on an authorized bounded backend retrieval contract.
- No D slice is considered complete from UI/navigation alone.
- Typecheck/build/runtime verification remains mandatory at each implementation boundary.

### D0 decision

**D0 CLOSED / READY FOR D1.**

No implementation change was made to product code during D0. The output is the dependency and acceptance baseline for D1–D5.

## D1 — Memory owner experience

Refine how the owner discovers and uses relevant memory through existing contextual/Journey surfaces.

Rules:
- preserve private memory semantics;
- do not turn transcript/history into memory by default;
- no client-side unrestricted private-memory download/search;
- no automatic promotion of private experience into shared knowledge.

**Exit:** relevant authorized memory can be surfaced through a meaningful owner flow with provenance/context.

## D2 — Knowledge owner experience

Refine authorized knowledge retrieval/presentation while keeping shared/general knowledge distinct from private memory.

Rules:
- preserve authorization boundary;
- distinguish source/provenance from conversational text;
- avoid creating a generic "everything" store.

**Exit:** owner can understand where knowledge came from and why it is available.

## D3 — Experience integration

Use the existing Experience domain as its own semantic domain.

Do not:
- collapse Experience into transcript storage;
- duplicate Journey as another event store;
- silently redefine Experience semantics.

**Exit:** Experience can contribute meaningful continuity/context without losing its distinct identity.

## D4 — Journey continuity

Extend the already implemented Journey/context surfaces into a useful continuity view.

Focus:
- conversation/source navigation;
- provenance;
- meaningful detail;
- continuity across relevant event sources;
- connection back to the originating surface.

**Exit:** Journey functions as a continuity/history surface rather than an isolated page.

## D5 — Global SH Search

Search is the most contract-sensitive D slice and must be defined before broad UI implementation.

Define:
- searchable domains;
- authorization scope;
- result model;
- provenance;
- ranking/relevance expectations;
- source navigation;
- pagination/limits;
- private-data isolation.

Search must consume authorized backend retrieval contracts. The App must not download unrestricted private memory and search it locally.

**Exit:** bounded search contract exists and can return authorized results with source/provenance context.

## D-Close

D may close only when the relevant implemented surfaces are:

- runtime-backed where applicable;
- connected rather than isolated;
- authorization-safe;
- provenance-aware where source data exists;
- persistence behavior verified where applicable;
- typecheck/build/test verified;
- free of blocking regressions;
- consistent with Canonical invariants.

A placeholder screen or navigation-only implementation does not satisfy D-Close.

## Explicit non-scope / deferred from Resume 69

These remain candidates and are **not silently pulled into D**:

- Voice / Audio;
- broad Plugins / Extensions / Integrations;
- full Projects capability;
- general Provider / Model Registry;
- general provider/database switching;
- full Offline / Local-first;
- integrated local GGUF runtime;
- official Web client.

Provider/model registry remains a future architecture candidate arising from C8, not a D dependency.

## Dependency map

```
A 🟢
↓
B 🟢
↓
C 🟢 CLOSED
↓
D0 Audit / Contract
↓
D1 Memory ─┐
D2 Knowledge├→ D4 Journey integration → D5 Search → D-Close
D3 Experience┘
```

D1–D3 may overlap where their contracts permit, but D5 should not bypass authorization/provenance design.

## Current status

**D0 CLOSED / READY FOR D1**

No D implementation is claimed by this planning document.

END OF WORKSTREAM D AUDIT
