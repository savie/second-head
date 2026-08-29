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

**D0 READY TO START**

No D implementation is claimed by this planning document.

END OF WORKSTREAM D AUDIT
