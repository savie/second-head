# WORKSTREAM E9 — EXISTING DEV CAPABILITY-TO-ACTION MINING

**Project:** SECOND HEAD V1.0  
**Workstream:** E9  
**Date:** 2026-08-29  
**Status:** AUDIT → MAP → RECONCILE COMPLETE / CANDIDATE IDENTIFIED  
**Implementation:** NOT AUTHORIZED

> Living evolution/design document. Non-Canonical. No implementation or schema mutation is authorized by this document.

## 1. Purpose

E9 mines existing DEV operations to determine whether a real working operation can become the first governed Tool/Action vertical slice, instead of inventing an external Tool prematurely.

## 2. GitHub evidence

Existing services contain real bounded operations:
- `app/services/global-search.ts` exposes `globalSearch({ shId, query, limit, offset, domains })` and calls `global_search_bounded`.
- `app/services/context.ts` exposes `loadSHContext(...)` and calls `assemble_context` plus bounded Journey retrieval.
- `app/features/journey/journey-service.ts` exposes bounded Journey operations including retrieval, classification, deletion, source-record deletion, transfer, and legacy preservation.
- `functions/runtime-p4a-001/sh_runtime_bundle.ts` contains model/provider adapters and image generation, but these are model capabilities, not yet a governed generic Tool/Action executor.

## 3. Supabase DEV evidence

Current DEV exposes Runtime RPCs including:
- `global_search_bounded`;
- `assemble_context`;
- `runtime_assert_active_sh`;
- `runtime_record_audit`;
- `runtime_confirm_high_risk_action`;
- `runtime_create_high_risk_confirmation`;
- `runtime_execute_high_risk_action`;
- Journey and lifecycle Runtime operations;
- memory/knowledge/experience recording operations.

This is significant evidence that SH already has governed Runtime operations which can serve as foundations. It is not evidence that they are already registered as Tools.

## 4. Candidate mining result

### Candidate A — Global Search

**Capability:** Global Search / retrieval across SH domains.  
**Existing operation:** `globalSearch`.  
**Backend:** `global_search_bounded`.  
**Side effect:** Read-oriented.  
**Target:** explicit `shId` + query.  
**Result:** bounded page with results, query, offset, limit, `has_more`.  
**Current assessment:** **🟢 strongest first-slice candidate**.

Why:
- already implemented;
- bounded input;
- explicit SH context;
- read-oriented;
- deterministic result envelope already exists;
- no destructive side effect;
- easy to correlate and test;
- does not require a plugin/provider ecosystem.

### Candidate B — SH Context Retrieval

`loadSHContext` is real and bounded, but it is primarily internal Runtime context assembly rather than a user-facing Tool Action.

**Assessment: 🟡 foundation, not first Tool.**

### Candidate C — Journey retrieval

`loadJourneyEvents` is real and read-oriented, but it is a domain-specific service operation. It could become a Tool later if product semantics justify exposing Journey retrieval as an explicit Action.

**Assessment: 🟡 candidate, lower priority than Global Search.**

### Candidate D — Journey mutation / transfer / deletion

These are real Runtime operations but have meaningful state-changing effects and therefore are poor first slices for validating the generic Tool boundary.

**Assessment: 🟡/🔴 defer as first slice; retain as later high-risk/state-changing Action candidates.**

### Candidate E — Image generation / model provider adapters

Real provider adapters exist in the Runtime, including image generation, but they belong to model/provider execution rather than an already-governed Tool/Action layer.

**Assessment: 🟡 capability/provider foundation, not first Tool without additional governance wrapping.**

## 5. First candidate decision

**E9 promotes Global Search as the preferred first concrete Action candidate.**

Proposed semantic shape:

`Capability: GLOBAL_SEARCH`

`Tool: SH_GLOBAL_SEARCH`

`Action: SEARCH_SH`

These names are **working design identifiers only** and are not Canonical or implementation identifiers yet.

The Action is read-oriented and should normally be low-risk, subject to the final risk contract in E10.

## 6. Vertical lifecycle

The proposed first slice is:

User intent
→ Capability GLOBAL_SEARCH
→ Tool SH_GLOBAL_SEARCH
→ Action SEARCH_SH
→ Invocation with shId + query + bounded parameters
→ Authorization
→ Risk classification
→ Confirmation only if required by final policy
→ Execution eligibility
→ existing `globalSearch` / `global_search_bounded`
→ Result envelope
→ Audit correlation

Important: E9 does not claim this lifecycle is already wired together. Only the underlying search operation is existing evidence.

## 7. Why this does not violate the Canonical boundary

Global Search already exists as a real SH capability and operation. E9 is not inventing a new conceptual authority.

The Tool/Action wrapper is an evolution-layer engineering representation that must remain subordinate to Canonical semantics and Runtime governance.

## 8. Registry implication

Global Search can be represented as a bounded static binding initially.

Therefore E6's registry decision remains valid:

**No generic registry is required for the first slice.**

A registry may only be reconsidered if later evidence demonstrates dynamic discovery/configuration requirements.

## 9. Result implication

Global Search already has a useful result shape:

- results;
- query;
- offset;
- limit;
- has_more.

E5 should therefore be refined around an envelope rather than replacing this existing domain result with an unnecessarily generic universal schema.

## 10. Authorization implication

The existing search service requires an `shId`, but that is not equivalent to authorization.

The governed Tool Action must establish authorization separately and must not infer permission merely because a valid SH identifier was supplied.

## 11. Risk implication

Global Search is read-oriented and has no identified state mutation in the audited path.

This makes it a strong candidate for a low-risk Action. Final classification remains an E10 decision based on the actual authorization/data-access semantics.

## 12. Existing foundation to reuse

E9 identifies reusable foundations rather than replacing them:

- `globalSearch` service boundary;
- `global_search_bounded` RPC;
- existing SH context/ownership boundary;
- existing Runtime audit infrastructure;
- existing authorization/confirmation infrastructure where applicable.

No duplicate search engine or new provider is proposed.

## 13. Gaps before implementation

Before implementation, E10+ must still freeze:
1. exact Capability/Tool/Action semantic contract;
2. authorization mapping for SEARCH_SH;
3. risk classification;
4. whether confirmation is ever required;
5. execution adapter boundary;
6. result envelope/correlation;
7. audit event semantics;
8. input/output/error contract;
9. test/evidence criteria.

## 14. Status

**E9 = 🟢 CANDIDATE IDENTIFIED — GLOBAL SEARCH PROMOTED TO FIRST-SLICE CANDIDATE**

This is a design promotion, not implementation authorization.

## 15. Next candidate

**E10 — GLOBAL SEARCH ACTION CONTRACT + AUTHORIZATION/RISK FREEZE**

E10 should audit the actual Global Search authorization/data boundary and freeze the concrete Action contract before any code changes.
