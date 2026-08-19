# SECOND HEAD — P5B CLONE STATE TRANSFER RECONCILIATION v1.0

Project: SECOND HEAD — SYSTEM BUILD  
Document Type: P5B Clone State Transfer Execution Reconciliation / Addendum  
Version: v1.0  
Status: ACCEPTED FOR P5B STATE-TRANSFER RECONCILIATION  
Canonical Status: NON-CANONICAL  
Mutation: NO CANONICAL MUTATION

## 1. Purpose

This document reconciles what the current authority chain actually establishes about Clone state transfer.

It is intentionally separate from the previously recorded P5B target-identity reconciliation. Target registration and PRIMARY SH semantics are already Owner-locked in `SECOND_HEAD_P5B_CLONE_EXECUTION_RECONCILIATION_v1.0.md`.

This document answers a narrower question:

> What state is inherited by a Clone, what is not inherited by default, and what remains open for implementation?

No unsupported Clone payload is invented here.

---

## 2. Authority Chain

```text
SH Core Canonical
↓
Build Scope
↓
Implementation Guide
↓
Implementation Contract
↓
Execution Strategy
↓
Phase -1 / Phase artifacts
↓
Session Resume / recovered semantics
↓
Actual GitHub DEV implementation
```

This document is a reconciliation artifact, not a replacement authority.

---

## 3. Established Clone Semantics

The recovered project semantics establish that Clone is **not** a full copy of the Source SH.

The following boundaries are explicit:

```text
CLONE_SH ≠ SOURCE_SH

Clone has:
- own identity
- own SH_ID
- own Journey
- own Personality development
- own Relationship state
- own state boundary
- own Memory boundary
- own access control
```

A Clone therefore does not become the Source SH or continue the Source SH as the same identity.

The canonical/recovered model also states that Clone does not automatically inherit:

- SH Identity;
- Core;
- private Memory;
- original Journey;
- live State;
- ownership;
- credentials;
- authorization;
- Creator-only/private data.

This is consistent with the invariant that Clone is a separate SH identity and that advanced capabilities must not silently replace Identity Root or Ownership Root.

---

## 4. Selective Inheritance Boundary

The recovered semantics explicitly allow **selective** inheritance when permission and agreement authorize it.

The established candidate categories are:

```text
Knowledge
Selected Memory
Selected Traits
References
Context
Relationship Context
```

This is an authorization/scope concept, not an instruction to copy all source state.

Therefore:

```text
Clone creation
    ≠
full state copy
```

and:

```text
permission + agreement + scope
    ↓
selective inheritance
```

The distinction between private Memory and shared/general Knowledge must remain intact. Provenance may persist across transferred Knowledge/Memory where the applicable lineage model permits it, without automatically exposing the private identity of the original source.

---

## 5. Conversation

Conversation is **not established as automatically transferable Clone state**.

The recovered Clone semantics explicitly distinguish Clone from copying the Source SH's live/private state, and the session evidence states that Clone execution must not be assumed to copy all Source conversations.

Therefore the safe current classification is:

```text
Source Conversation → NOT INHERITED BY DEFAULT
```

A future explicit conversation-transfer requirement would require its own authority reconciliation rather than being inferred from the existence of Clone.

Operationally this supports the expected initial experience of a newly materialized Clone having its own conversation history rather than silently exposing/copying the Source's private chat history.

---

## 6. Journey

Journey is a temporal continuity construct, not a generic storage layer.

The recovered semantics state that a Clone has its **own Journey** and that the original Source Journey is **not inherited by default**.

Therefore:

```text
Source Journey
     ↓
NOT copied into Clone Journey by default
     ↓
Clone begins its own Journey
```

If selected historical information from the Source Journey is ever transferred, it must be represented as an explicitly authorized state/reference/inheritance operation rather than silently making the Clone's Journey identical to the Source's Journey.

---

## 7. Memory

Memory is deliberately retained state, not a transcript of everything that happened.

The established lifecycle is:

```text
Experience
↓
Memory Candidate
↓
Relevance / Scope / Privacy / Governance
↓
Memory
```

For Clone:

```text
Private Memory → NOT INHERITED BY DEFAULT

Selected Memory → MAY BE INHERITED
                   only with explicit permission/agreement/scope
```

Therefore the presence of a `scope` field in `clone_agreements` is compatible with selective transfer, but the current implementation does not yet establish a complete, category-specific Memory transfer engine.

That implementation gap must not be filled by simply copying all memory rows.

---

## 8. Knowledge

Knowledge is distinct from Memory and Reference:

```text
Reference = where information comes from
Knowledge = what SH understands / can use
Memory = what SH retains
Context = what SH currently needs
```

The recovered Clone semantics allow selective Knowledge inheritance.

Therefore:

```text
Knowledge → NOT automatically copied in full
Selected Knowledge → MAY be inherited when authorized
```

Knowledge provenance/lineage should be preserved where the relevant implementation supports it, while source-private identity information must remain protected.

The practical Knowledge Candidate rule recovered elsewhere in the project (`occurrence_count >= 5`) does **not** mean that every candidate becomes trusted/active, and it does not by itself define Clone transfer semantics.

---

## 9. Candidate State

`CANDIDATE` is a lifecycle/trust state and must not be conflated with active Knowledge or Memory.

Therefore a Clone implementation must not assume:

```text
Candidate → automatically promoted Knowledge
```

or:

```text
Candidate → automatically promoted Memory
```

If Candidate material is within an explicitly authorized transfer scope, its Candidate status should remain semantically distinguishable unless a higher-authority rule explicitly authorizes promotion.

Current authority does not establish an automatic Candidate promotion during Clone creation.

Classification: **OPEN IMPLEMENTATION DETAIL, bounded by existing Candidate semantics**.

---

## 10. Personality / Traits

The recovered semantics allow selective inheritance of **Selected Traits**, while also establishing that a Clone develops its own Personality over its own Journey.

Therefore:

```text
Source Personality → NOT copied wholesale
Selected Traits    → MAY be inherited when authorized
Clone Personality  → develops independently
```

A Clone must not become behaviorally identical merely because selected traits were transferred.

---

## 11. Context

Context is dynamic and request/session scoped. It is not identical to Memory or Knowledge.

The recovered semantics allow selective inheritance of Context / Relationship Context when explicitly authorized.

However, the current implementation does not establish a complete generic Context transfer engine.

Therefore:

```text
Live Source Context → NOT automatically inherited
Selected Context    → MAY be inherited if explicitly scoped
Clone Context       → subsequently assembled for Clone's own runtime
```

A live Source session must never become the Clone's live session merely because a Clone was created.

---

## 12. Ownership / Identity / Credentials / Authorization

These are explicitly **not transferred as Source state**.

The Owner-resolved target lifecycle establishes the new Account and PRIMARY Clone SH as belonging to the recipient.

Therefore:

```text
Source Account      ≠ Target Account
Source SH           ≠ Clone SH
Source ownership    ≠ Target ownership
Source credentials  ≠ Clone credentials
Source authorization ≠ automatic target authorization
```

The target's ownership is newly established through its own identity lifecycle.

---

## 13. Provenance / Lineage

Provenance is not the same thing as private-data access.

A transferred Knowledge/Memory/reference lineage may preserve source provenance without exposing private source identity beyond the authorization boundary.

At minimum, the Clone relationship itself must remain auditable through:

```text
Clone SH
↓
Source SH
↓
Clone Agreement
↓
Target ownership
```

The current `sh_clones` relationship and agreement metadata provide a foundation for this relationship.

A complete per-item state-transfer lineage mechanism is **not yet proven by the current Clone implementation**.

---

## 14. Current Implementation vs Reconciled Semantics

Current DEV implementation now materializes the target Clone as the recipient's PRIMARY SH through the email-registration lifecycle.

However, the current Clone materialization path creates identity/ownership/relationship records; it does not establish a complete selective state-transfer engine for Memory, Knowledge, Candidate, Journey, Conversation, Context, or Traits.

Therefore the current state is:

```text
Clone identity/materialization       🟢 RECONCILED
Target PRIMARY SH                    🟢 RECONCILED
Source/Clone separation              🟢 RECONCILED
Agreement/provenance relationship    🟢 FOUNDATION
Full state transfer                  🟡 NOT IMPLEMENTED / NOT PROVEN
Selective Memory transfer            🟡 OPEN IMPLEMENTATION
Selective Knowledge transfer         🟡 OPEN IMPLEMENTATION
Candidate transfer semantics         🟡 OPEN IMPLEMENTATION
Journey transfer                     🟡 OPEN / NOT DEFAULT
Conversation transfer                🟡 NOT DEFAULT / NOT IMPLEMENTED
Trait transfer                       🟡 OPEN IMPLEMENTATION
Context transfer                     🟡 OPEN IMPLEMENTATION
Per-item provenance transfer         🟡 OPEN IMPLEMENTATION
```

---

## 15. What We Must NOT Do

Do not implement any of the following merely to make Clone look complete:

```text
COPY all conversations
COPY all Memory
COPY all Knowledge
COPY all Journey events
COPY live Context
PROMOTE all Candidates
COPY credentials
COPY ownership
COPY source authorization
MAKE Clone share Source SH_ID
```

Those behaviors would conflict with the recovered Clone boundaries.

---

## 16. Implementation Target

The next implementation should be a **scope-driven selective transfer layer**, not a full database clone.

Conceptual target:

```text
Source SH
   ↓
Approved Clone Agreement
   ↓
Transfer Scope
   ├── selected Knowledge
   ├── selected Memory
   ├── selected Traits
   ├── selected References
   ├── selected Context
   └── selected Relationship Context
   ↓
validate privacy / ownership / provenance
   ↓
materialize authorized state into Clone SH
   ↓
record per-transfer provenance/audit
```

The exact scope schema and per-domain transfer functions remain implementation details to be derived from existing Memory/Knowledge/Context contracts before code mutation.

---

## 17. Acceptance Criteria for State-Transfer Implementation

Before Clone state transfer can be called complete:

- [ ] Clone has independent identity and ownership.
- [ ] Source private state is not copied by default.
- [ ] Conversation is not copied by default.
- [ ] Source Journey is not copied by default.
- [ ] Live Source Context is not copied by default.
- [ ] Transfer is driven by explicit agreement scope.
- [ ] Selected Memory can be transferred without bypassing privacy rules.
- [ ] Selected Knowledge can be transferred while preserving Memory/Knowledge distinction.
- [ ] Candidate state remains distinguishable from promoted Knowledge/Memory.
- [ ] Selected Traits do not collapse Clone Personality into Source Personality.
- [ ] Provenance is preserved where applicable.
- [ ] Target ownership remains exclusive to the recipient.
- [ ] Source credentials/authorization are never transferred.
- [ ] Every transfer is auditable.
- [ ] Authenticated E2E verifies the user-visible result.

---

## 18. Status

```text
Target identity semantics        🟢 OWNER LOCKED
Registration lifecycle            🟢 RECONCILED
Primary SH semantics              🟢 RECONCILED
Clone/source separation           🟢 RECONCILED
Default state-transfer boundary   🟢 RECOVERED
Selective transfer model          🟡 IMPLEMENTATION REQUIRED
Exact transfer schema             🟡 OPEN
Per-domain transfer RPCs          🟡 OPEN
Per-item provenance               🟡 OPEN
Authenticated E2E                  ⏳ PENDING
Canonical                         UNCHANGED
Mutation                          NONE
```

## 19. Session Handoff

The next session/auditor should not reopen the question "Does Clone copy the whole Source SH?" unless a higher-authority source contradicts this reconciliation.

The current recovered answer is:

> **No. Clone is a new SH with its own identity, Journey, Personality development, Relationship state, Memory boundary and access control. Selected state may be inherited through explicit permission/agreement/scope.**

If the exact transfer mechanism for a state category is not specified by the authority chain, classify it as OPEN rather than inventing a copy rule.
