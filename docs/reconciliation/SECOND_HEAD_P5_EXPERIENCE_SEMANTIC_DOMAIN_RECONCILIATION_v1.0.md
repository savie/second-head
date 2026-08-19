# SECOND HEAD — P5 EXPERIENCE SEMANTIC DOMAIN RECONCILIATION v1.0

**Project:** SECOND HEAD — SYSTEM BUILD  
**Document Type:** Phase 5 Semantic / Architecture Reconciliation / Addendum  
**Version:** v1.0  
**Status:** ACCEPTED FOR P5 EXECUTION  
**Canonical Status:** NON-CANONICAL  
**Mutation:** NO CANONICAL MUTATION  

---

## 1. Purpose

This document records the reconciliation of the Owner-approved semantic decision that **Experience is a distinct domain and is not Knowledge**.

It exists so future sessions and audits do not reinterpret Experience as a Knowledge subtype merely because the existing runtime previously represented `EXPERIENCE` only as a Journey event type.

---

## 2. Authority Reconciliation

The Canonical SH Core defines an **Experiential Layer** and identifies Journey as part of SH continuity. The canonical architecture also places Memory, Knowledge, Context, and Journey inside the SH Instance / Experiential domain.

The current implementation had:

- `journey_events` with `event_type = EXPERIENCE`;
- semantic Journey candidates that could carry `EXPERIENCE` as an event type;
- Memory and Knowledge as persistent domains;
- no persistent `Experience` domain.

The Owner subsequently clarified:

> **Experience ≠ Knowledge**
>
> **Experience is its own domain/category.**

This clarification is adopted as an implementation decision without modifying the Canonical document itself.

---

## 3. Existing Representation Audit

### Existing

`journey_events.event_type = EXPERIENCE`

This remains valid as a Journey representation of a significant experience occurring in the SH timeline.

It is **not** sufficient to represent Experience as an independent semantic domain.

### Existing

`memories`

Used for Memory lifecycle and persistence.

### Existing

`knowledge`

Used for Knowledge lifecycle and persistence.

### Missing

A persistent domain representing selected/recorded Experience independently from Knowledge and Journey.

No existing table was found that could safely be reused without collapsing the semantic distinction.

---

## 4. Minimal Realization

A new `public.experiences` domain was introduced.

The domain stores:

- `experience_id`
- `sh_id`
- `account_id`
- `experience_type`
- `content`
- `scope`
- `visibility`
- `source_ref`
- `provenance`
- `lifecycle`
- `occurred_at`
- timestamps

The domain is intentionally minimal.

It does not replace:

- Journey
- Memory
- Knowledge
- Context
- Conversation

---

## 5. Semantic Boundary

```text
SH INSTANCE
     ↓
EXPERIENTIAL DOMAIN
     ├── Memory
     ├── Knowledge
     ├── Journey
     └── Experience
```

Important distinction:

```text
Experience ≠ Knowledge
Experience ≠ Conversation
Experience ≠ Journey
Experience may be represented in Journey
```

A Journey event can record that an Experience occurred.

That does not make Journey the permanent storage domain for all Experience semantics.

---

## 6. Provenance / Privacy

Experience follows the existing SH ownership model.

Default realization:

- `scope = PRIVATE`
- `visibility = OWNER_ONLY`

The domain retains provenance and source references so later transfer/selection mechanisms can preserve lineage.

Cross-SH access remains denied unless an explicit authorized transfer mechanism exists.

---

## 7. Runtime Boundary

The minimal runtime entry point is:

`runtime_record_experience(...)`

It requires:

- authenticated caller;
- SH owned by the caller's current Account;
- active SH;
- explicit Experience content/type;
- explicit scope/visibility;
- optional source/provenance metadata.

Automatic semantic capture is **not** claimed by this reconciliation.

The purpose of this first realization is to establish the correct domain boundary without inventing a new automatic-learning policy.

---

## 8. Service Mapping

The application service layer now exposes:

- `listExperiences()`
- `recordExperience(...)`

These map directly to the new `experiences` table and `runtime_record_experience` RPC.

Frontend UI integration remains a subsequent wiring step; this reconciliation does not claim a complete Experience UI.

---

## 9. Relationship to Memory / Knowledge

The following remain unchanged:

```text
Experience
    ↓
may influence Memory

Experience
    ↓
may contribute to Knowledge formation

Experience
    ↓
may become represented in Journey
```

But:

```text
Experience
    ≠
Memory

Experience
    ≠
Knowledge

Experience
    ≠
Journey
```

The conversion from Experience into Memory or Knowledge must continue to follow their existing lifecycle/governance rules.

---

## 10. Relationship to Clone / Inheritance / Succession / Legacy

The new domain is intentionally prepared for future selected-state transfer.

Potential semantic mapping:

- Clone: selected initial Experience may become part of Clone's initial state.
- Inheritance: selected Experience may be authorized while both SHs remain active.
- Succession: selected Experience may be transferred after source End-of-Life.
- Legacy: selected Experience may be preserved as legacy material.

No automatic full Experience transfer is introduced by this document.

Selection remains explicit.

---

## 11. Architecture Diagram Reconciliation

The Canonical Architecture Diagram remains the higher authority.

The implementation interpretation is now:

```text
CANONICAL ARCHITECTURE
        ↓
EXPERIENTIAL
        ↓
selected / recorded Experience
        ↓
Memory / Knowledge / Journey semantics
        ↓
actual schema
        ↓
runtime
        ↓
service
        ↓
frontend
        ↓
provenance
```

This is a derived implementation map, not a replacement architecture diagram.

---

## 12. Verification

DEV verification completed:

- `public.experiences` exists;
- RLS is enabled;
- authenticated ownership policy exists;
- `runtime_record_experience` exists;
- authenticated execution is granted;
- no Experience rows were introduced as test residue.

Full authenticated application E2E is not yet claimed PASS.

---

## 13. Non-Goals

This realization does not:

- redefine SH Core Canonical;
- make Experience equivalent to Knowledge;
- replace Journey;
- copy conversations into Experience;
- introduce automatic capture thresholds;
- introduce automatic promotion to Memory or Knowledge;
- expose private Experience cross-SH;
- claim full frontend Experience UI completion.

---

**End of Reconciliation**
