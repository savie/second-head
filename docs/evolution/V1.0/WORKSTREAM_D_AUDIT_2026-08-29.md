# SECOND HEAD V1.0 — WORKSTREAM D AUDIT

Status: **CLOSED / VERIFIED / NON-CANONICAL**
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

## D1 implementation boundary — 2026-08-29

D1 is now defined as an owner-facing Memory flow, not a new Memory backend. Existing bounded memory retrieval remains the authority boundary.

### Implementation scope

- expose a compact Memory surface from the existing contextual/owner navigation;
- load only authorized, bounded Memory records/context;
- show enough context/provenance to understand why a memory is present;
- support safe owner actions already permitted by the existing Memory contract;
- keep transcript/history, Experience, and Knowledge visibly distinct;
- avoid client-side unrestricted memory retrieval or a second local Memory store.

### Acceptance

A D1 implementation is GREEN only when runtime retrieval, authorization boundary, owner surface, persistence/action semantics where applicable, and typecheck/runtime verification all pass. A static Memory list does not satisfy D1.

### Current decision

**D1 CLOSED / GREEN (verified externally).**

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

D5 is now implemented and verified as a bounded Global SH Search contract plus owner-facing App surface.

### Implemented boundary

- searchable domains: Conversation, Memory, Knowledge, Experience, Journey;
- server-side SH/account ownership validation;
- authenticated execution only; anonymous RPC execution explicitly denied;
- bounded query length, result limit, and pagination offset;
- domain allow-list; unsupported domains are rejected;
- server-side retrieval only; no unrestricted private-memory download/search in the App;
- private Memory remains scoped to the authorized SH and eligible lifecycle states;
- shared/general Knowledge remains distinct from private Memory;
- Experience preserves private owner-only vs shared semantics;
- Journey remains SH/account scoped and carries source/provenance context;
- verification-only conversation artifacts are excluded;
- normalized result model includes domain, title, snippet, source reference, provenance, timestamp, and bounded relevance score;
- App exposes domain filters and bounded pagination through the existing owner navigation.

### Verification

- Supabase DEV RPC verified with authenticated identity and bounded result retrieval.
- Domain filtering verified for Knowledge.
- Unsupported-domain rejection verified.
- Anonymous execution explicitly revoked.
- Supabase security review did not report the D5 RPC as anonymously executable after the hardening fix.
- SH Runtime Controlled Verification passed for the D5 hardening commits.
- SH App Android Build passed for the D5 route commit; latest reported DEV state is **All Green**.

### Reconciliation decision

D5 satisfies the D acceptance contract without introducing a new Canonical semantic layer. It is an evolution-layer retrieval/surface contract that reuses existing domain and authorization boundaries.

**D5 CLOSED / GREEN.**

## D-Close

D is now closed because the relevant implemented surfaces are:

- runtime-backed where applicable;
- connected rather than isolated;
- authorization-safe;
- provenance-aware where source data exists;
- persistence behavior verified where applicable;
- runtime verification and Android build verification passed for the completed D slices;
- free of reported blocking regressions in the latest DEV verification state;
- consistent with Canonical invariants.

D-Close does not claim that every future Search or continuity feature is complete. It claims that the defined D1–D5 slices meet their current bounded contracts and verification gates.

**D-CLOSE: GREEN / VERIFIED.**

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
D0 🟢
↓
D1 Memory ─┐
D2 Knowledge├→ D4 Journey → D5 Global Search 🟢
D3 Experience┘                 ↓
                           D-CLOSE 🟢
```

D1–D3 overlapped where their contracts permitted. D5 did not bypass authorization/provenance design.

## Current status

**D0–D5 CLOSED / GREEN / VERIFIED.**

The document has been reconciled against the completed DEV implementation state. It remains non-Canonical and does not redefine SH Core semantics.

END OF WORKSTREAM D AUDIT
