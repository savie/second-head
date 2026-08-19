# SECOND HEAD — P5B CLONE STATE TRANSFER RECONCILIATION v1.0

Project: SECOND HEAD — SYSTEM BUILD  
Document Type: P5B Clone State Transfer Execution Reconciliation / Addendum  
Version: v1.0  
Status: ACCEPTED FOR P5B STATE-TRANSFER RECONCILIATION  
Canonical Status: NON-CANONICAL  
Mutation: NO CANONICAL MUTATION

## 1. Purpose

This document reconciles what the current authority chain and Owner decisions establish about Clone state transfer.

It is separate from the previously recorded P5B target-identity reconciliation. Target registration and PRIMARY SH semantics are already Owner-locked in `SECOND_HEAD_P5B_CLONE_EXECUTION_RECONCILIATION_v1.0.md`.

This document answers a narrower question:

> What state is inherited by a Clone, what is not inherited, and what implementation work remains?

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
Owner Decisions recorded here
↓
Actual GitHub DEV implementation
```

This document is a reconciliation artifact, not a replacement authority.

---

## 3. Established Clone Semantics

Clone is **not** a full copy of the Source SH.

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

The Clone does not automatically inherit:

- SH Identity;
- Core;
- private Source Memory;
- original Source Journey;
- live Source State;
- ownership;
- credentials;
- authorization;
- Creator-only/private data;
- Source Conversation / chat history.

---

## 4. OWNER DECISIONS — STATE TRANSFER

The Owner resolves the remaining Clone state-transfer semantics as follows.

### 4.1 Automatic inherited state

When a Clone is created, the following Source state is intended to come with the Clone:

```text
Knowledge
Memory
Context
References
Traits
```

This is the intended human/semantic meaning of Clone state inheritance. It is not a request to copy unrelated private infrastructure state, identity, credentials, ownership, or conversations.

### 4.2 Candidate state

Candidate state is included in the Clone inheritance semantics.

This applies to Candidate forms of the relevant domains, including for example:

```text
Knowledge Candidate → Clone
Memory Candidate    → Clone
```

A Candidate remains a Candidate unless an existing higher-authority lifecycle rule explicitly promotes it. Clone creation itself must not silently promote Candidate material into trusted/active Knowledge or Memory.

### 4.3 Conversation / chat

Conversation, using the Owner's human terminology of **chat**, does **not** come into the Clone.

This is intentional and already established by the recovered Clone semantics.

```text
Source chat
    ↓
NOT transferred
    ↓
Clone starts with its own conversation history
```

### 4.4 Journey

The Source Journey does **not** come into the Clone.

Clone has its own Journey and begins its own continuity/development.

```text
Source Journey
    ↓
NOT transferred
    ↓
Clone Journey
```

### 4.5 Recipient consent / acceptance

The intended recipient cannot be assumed to have chosen to become a Clone merely because the Source created the Clone relationship.

The resolved human flow is:

```text
A creates Clone for B
        ↓
B is intended recipient
        ↓
B registers / claims the recipient identity
        ↓
Clone becomes B's PRIMARY SH
```

The implementation must therefore preserve a recipient-side acceptance/claim boundary appropriate to the registration lifecycle. A Source action must not silently force an already-unwilling person into a Clone identity.

The exact UI wording/mechanism may be derived during implementation as long as it preserves this semantic boundary.

---

## 5. What "Automatic" Means Here

"Automatic" means that once the Clone is legitimately materialized for the intended recipient, the defined transferable state categories are part of the Clone's initial state without requiring the Owner to manually select individual rows one by one.

It does **not** mean:

```text
COPY every row from every Source table
```

The implementation must still respect:

- privacy boundaries;
- domain lifecycle rules;
- Candidate status;
- provenance;
- source/target ownership separation;
- authorization;
- data-model constraints.

Therefore the target is a **domain-aware automatic transfer**, not a raw database clone.

---

## 6. State Transfer Matrix

| State / Domain | Clone Result | Notes |
|---|---|---|
| SH Identity | ❌ Not copied | Clone has its own identity |
| Core | ❌ Not copied | Clone remains independently governed |
| Ownership | ❌ Not copied | Target recipient owns Clone |
| Credentials | ❌ Not copied | Target has independent credentials |
| Authorization | ❌ Not copied | Source authorization does not become Target authorization |
| Private Source data | ❌ Not copied wholesale | Privacy boundary remains |
| Knowledge | 🟢 Inherited | Owner decision: automatic domain transfer |
| Knowledge Candidate | 🟢 Inherited | Remains Candidate unless existing lifecycle promotes it |
| Memory | 🟢 Inherited | Owner decision: automatic domain transfer |
| Memory Candidate | 🟢 Inherited | Remains Candidate unless existing lifecycle promotes it |
| Context | 🟢 Inherited | Initial transferable Context state; not live Source session |
| References | 🟢 Inherited | Preserve applicable provenance/lineage |
| Traits | 🟢 Inherited | Does not make Clone's Personality identical to Source |
| Conversation / chat | ❌ Not inherited | Explicit Owner decision |
| Source Journey | ❌ Not inherited | Clone has its own Journey |
| Live Source runtime/session | ❌ Not inherited | Clone gets its own runtime state |
| Provenance | 🟢 Preserved where applicable | Must remain auditable without exposing private Source data |

---

## 7. Knowledge, Memory, and Candidate Semantics

Knowledge and Memory remain distinct domains.

```text
Reference = where information comes from
Knowledge = what SH understands / can use
Memory    = what SH retains
Context   = what SH currently needs
```

Candidate is a lifecycle/trust state, not a synonym for Knowledge or Memory.

Therefore:

```text
Knowledge Candidate → inherited as Candidate
Memory Candidate    → inherited as Candidate
```

and not:

```text
Candidate → automatic promotion
```

Existing Candidate promotion rules remain authoritative. Clone transfer must not bypass them.

---

## 8. Personality / Traits

Traits are included in the automatic inherited state.

However:

```text
Selected/inherited Traits
        ≠
copy Source Personality wholesale
```

The Clone still develops its own Personality over its own Journey and subsequent interaction.

---

## 9. Context

Context is transferable initial state, but it must not become the Source's live session.

Therefore:

```text
Source Context
    ↓
initial Clone Context state
    ↓
Clone subsequently assembles its own runtime Context
```

The implementation must distinguish transferred Context from a live Source runtime/session.

---

## 10. Conversation / Chat Boundary

Conversation is explicitly excluded by Owner decision.

The expected user-visible behavior is:

```text
B registers
↓
Clone PRIMARY SH exists
↓
Knowledge / Memory / Context / References / Traits / Candidates exist as applicable
↓
Chat history is empty/new
↓
Clone starts a new conversation
```

No historical Source chat should be copied merely because Clone state is materialized.

---

## 11. Journey Boundary

The Source Journey is explicitly excluded.

Clone begins its own Journey:

```text
Source Journey ────────────────┐
                              │
                              X  not transferred
                              │
Clone Journey → starts independently
```

This does not prevent future authorized references to historical Source information from existing elsewhere in the Clone state. Such references must not silently become the Clone's original Journey.

---

## 12. Provenance / Lineage

Provenance is not the same thing as private-data access.

Transferred Knowledge, Memory, References, Traits, Context, and Candidate material may retain appropriate Source lineage while respecting privacy boundaries.

At minimum the Clone relationship remains auditable through:

```text
Clone SH
↓
Source SH
↓
Clone Agreement
↓
Target ownership
```

The implementation must preserve provenance where the domain model supports it.

---

## 13. Recipient Acceptance Boundary

The Owner clarified an important human semantic:

> The Source can create someone as the intended Clone recipient, but the recipient cannot be assumed to have consented merely because the Source created the relationship.

Therefore the registration/claim lifecycle must provide a meaningful recipient boundary.

The conceptual flow is:

```text
A / Source
↓
creates Clone for B's email
↓
B is an intended recipient
↓
B registers / claims the invitation
↓
B becomes Account owner
↓
Clone becomes B's PRIMARY SH
```

If B does not claim/register the intended Clone, the implementation must not silently turn an unrelated account into the Clone.

---

## 14. Current Implementation vs Reconciled Semantics

Current DEV implementation has reconciled the target identity lifecycle and PRIMARY SH semantics.

The remaining implementation gap is the domain-aware automatic transfer described by the Owner decisions in this document.

Current status:

```text
Clone identity/materialization       🟢 RECONCILED
Target PRIMARY SH                    🟢 RECONCILED
Source/Clone separation              🟢 RECONCILED
Agreement/provenance relationship    🟢 FOUNDATION
Knowledge transfer                   🟡 IMPLEMENTATION REQUIRED
Knowledge Candidate transfer         🟡 IMPLEMENTATION REQUIRED
Memory transfer                      🟡 IMPLEMENTATION REQUIRED
Memory Candidate transfer            🟡 IMPLEMENTATION REQUIRED
Context transfer                     🟡 IMPLEMENTATION REQUIRED
Reference transfer                   🟡 IMPLEMENTATION REQUIRED
Trait transfer                       🟡 IMPLEMENTATION REQUIRED
Conversation transfer                🟢 EXCLUDED
Source Journey transfer              🟢 EXCLUDED
Recipient acceptance/claim           🟡 IMPLEMENTATION REQUIRED
Per-item provenance transfer         🟡 IMPLEMENTATION REQUIRED
Authenticated E2E                     ⏳ PENDING
```

---

## 15. What We Must NOT Do

Do not implement any of the following:

```text
COPY Source conversations/chat
COPY Source Journey as Clone Journey
COPY Source credentials
COPY Source ownership
COPY Source authorization
MAKE Clone share Source SH_ID
PROMOTE every Candidate automatically
COPY live Source runtime/session
```

Also do not implement state transfer as a blind table-to-table copy. The transfer must respect each domain's existing lifecycle and privacy rules.

---

## 16. Implementation Target

The next implementation should be a **domain-aware automatic Clone transfer layer**.

Conceptual target:

```text
Source SH
   ↓
Approved Clone Agreement
   ↓
Recipient registration / claim
   ↓
Create target Account + Clone PRIMARY SH
   ↓
Transfer initial authorized Clone state
   ├── Knowledge
   ├── Knowledge Candidates
   ├── Memory
   ├── Memory Candidates
   ├── Context
   ├── References
   └── Traits
   ↓
DO NOT transfer
   ├── Conversation / chat
   ├── Source Journey
   ├── credentials
   ├── ownership
   └── live Source session
   ↓
Preserve applicable provenance / audit
```

The exact implementation must reuse existing domain contracts and lifecycle rules instead of inventing parallel representations.

---

## 17. Acceptance Criteria for State-Transfer Implementation

Before Clone state transfer can be called complete:

- [ ] Knowledge is inherited automatically as defined above.
- [ ] Knowledge Candidate state is inherited and remains Candidate.
- [ ] Memory is inherited automatically as defined above.
- [ ] Memory Candidate state is inherited and remains Candidate.
- [ ] Context is inherited as initial state, not as a live Source session.
- [ ] References are inherited with applicable provenance.
- [ ] Traits are inherited without collapsing Clone Personality into Source Personality.
- [ ] Conversation/chat is not copied.
- [ ] Source Journey is not copied.
- [ ] Credentials and ownership are never copied.
- [ ] Source authorization is never silently transferred.
- [ ] Recipient registration/claim is required before the Clone is assigned to the recipient.
- [ ] Target ownership remains exclusive to the recipient.
- [ ] Provenance remains auditable.
- [ ] Privacy boundaries remain enforced.
- [ ] Authenticated E2E verifies the user-visible result.

---

## 18. Status

```text
Target identity semantics        🟢 OWNER LOCKED
Registration lifecycle            🟢 RECONCILED
Primary SH semantics              🟢 RECONCILED
Clone/source separation           🟢 RECONCILED
Knowledge inheritance             🟢 OWNER DECISION LOCKED
Memory inheritance                🟢 OWNER DECISION LOCKED
Context inheritance               🟢 OWNER DECISION LOCKED
Reference inheritance             🟢 OWNER DECISION LOCKED
Trait inheritance                 🟢 OWNER DECISION LOCKED
Knowledge Candidate inheritance  🟢 OWNER DECISION LOCKED
Memory Candidate inheritance     🟢 OWNER DECISION LOCKED
Conversation/chat                 🟢 OWNER EXCLUDED
Source Journey                    🟢 OWNER EXCLUDED
Recipient acceptance/claim        🟢 OWNER SEMANTICS LOCKED
Implementation transfer layer    🟡 NEXT
Authenticated E2E                  ⏳ PENDING
Canonical                         UNCHANGED
Mutation                          NONE
```

## 19. Session Handoff

The next session/auditor should treat the Owner decisions in this document as the current P5B Clone state-transfer resolution.

Do not reopen these questions unless a higher-authority document explicitly contradicts them:

```text
Clone gets automatically:
Knowledge
Memory
Context
References
Traits
Knowledge Candidates
Memory Candidates

Clone does NOT get:
Conversation / chat
Source Journey
Credentials
Ownership
Source authorization
Live Source runtime/session
```

If a technical implementation detail is not specified here or by the applicable authority chain, derive it from the existing domain contracts and lifecycle rules. If it still cannot be determined without changing semantics, stop and request an Owner Decision rather than inventing behavior.
