# SECOND_HEAD_SH_CORE_CANONICAL_v1.0_BILINGUAL

**Status:** Canonical Conceptual Authority / Otoritas Konseptual Canonical  
**Version:** v1.0  
**Project:** SECOND HEAD  
**Document Type:** Official Bilingual Canonical Conceptual / Architectural Foundation  
**Authority Scope:** SH Core / SH-CORE  
**Primary Role:** Single conceptual authority for future SECOND HEAD technical design and implementation work / Otoritas konseptual tunggal untuk pekerjaan desain teknis dan implementasi SECOND HEAD di masa depan

---

# OFFICIAL BILINGUAL EDITION / EDISI BILINGUAL RESMI

This document is the official bilingual edition of `SECOND_HEAD_SH_CORE_CANONICAL_v1.0.md`.

Dokumen ini adalah edisi bilingual resmi dari `SECOND_HEAD_SH_CORE_CANONICAL_v1.0.md`.

**Canonical authority:** The English and Indonesian sections express the same canonical meaning. If future translation ambiguity occurs, the canonical intent must be resolved against the English source and the project's validated conceptual authority.

**Otoritas canonical:** Bagian bahasa Inggris dan bahasa Indonesia menyampaikan makna canonical yang sama. Jika di kemudian hari terdapat ambiguitas terjemahan, maksud canonical harus dikembalikan pada source bahasa Inggris dan otoritas konseptual proyek yang telah divalidasi.

---

# PART I — ENGLISH CANONICAL VERSION

# SECOND_HEAD_SH_CORE_CANONICAL_v1.0

**Status:** Canonical Conceptual Authority  
**Version:** v1.0  
**Project:** SECOND HEAD  
**Document Type:** Canonical Conceptual / Architectural Foundation  
**Authority Scope:** SH Core / SH-CORE  
**Primary Role:** Single conceptual authority for future SECOND HEAD technical design and implementation work

---

# 1. PURPOSE & AUTHORITY

## 1.1 Purpose

This document formally defines the canonical concept of **SH Core / SH-CORE** for the SECOND HEAD system.

SH Core is not merely a system prompt, database, LLM provider, runtime, or isolated software module. It is the foundational concept that connects the fundamental identity and principles of SECOND HEAD with the architectural and runtime mechanisms required to preserve that identity, continuity, governance, and privacy across SH instances.

This document exists to prevent future technical work from interpreting SH Core solely from one implementation snapshot, one runtime, one model provider, or one historical terminology choice.

## 1.2 Authority

This document is an evolution of the previously validated SECOND HEAD foundation.

Its primary basis is:

1. The validated conceptual history of SECOND HEAD discussed in the project.
2. The validated source-document foundation:
   - `SECOND_HEAD_SESSION_RESUME_COMPILATION_v1.0.md`
   - `SECOND_HEAD_COMPILED_DOCUMENTATION_BASELINE_v1.0.md`
   - `SECOND_HEAD_SH_LITE_V2.0_COMPILED_DOCUMENTATION_v1.0.md`
   - `SECOND_HEAD_SH_LITE_V2.1_COMPILED_DOCUMENTATION_v1.0.md`
3. The validated mapping of occurrences, usages, and contexts of the term **SH Core / SH-CORE** across those four source documents.
4. Explicit decisions and clarifications made during the formation of this canonical document.

Two external AI analyses supplied during the formation of this document are treated only as secondary cross-checks and interpretive input. They are not canonical authority unless their conclusions are independently supported by the validated foundation or explicitly adopted here.

## 1.3 Classification Rules

Throughout this document:

- **CANONICAL / VALIDATED** means explicitly validated or established by the project's accepted foundation and decisions.
- **DERIVED / RECONSTRUCTED** means a strong synthesis of validated material and the evolution of the SECOND HEAD concept.
- **PROPOSED / INTERPRETATION** means a useful formulation that has not yet been elevated to immutable canonical fact.
- **OPEN / UNRESOLVED** means intentionally not finalized.

Where a point is open, this document does not invent a definitive answer.

---

# 2. CANONICAL DEFINITION OF SH CORE

## 2.1 Primary Definition

**SH Core / SH-CORE is the foundational and governing core of SECOND HEAD that preserves what makes SECOND HEAD remain SECOND HEAD across users, SH instances, models, runtimes, infrastructure, and system evolution.**

SH Core defines and protects the fundamental identity, principles, invariants, governance boundaries, privacy boundaries, and continuity foundations of SECOND HEAD, while also providing the conceptual and architectural basis through which those foundations are instantiated and operationalized in individual SH instances.

SH Core therefore exists simultaneously across related layers:

1. **Fundamental / Governance Layer** — what SECOND HEAD fundamentally is and what must remain protected.
2. **Architectural / System Layer** — how the fundamental core is represented and orchestrated through system architecture.
3. **Runtime / Operational Layer** — how an SH instance executes the core principles in actual interaction.
4. **Experiential Layer** — how the core is expressed as a persistent SH experience, including identity, continuity, memory, personality, relationship, context, and initiative where implemented.

These are not four unrelated systems. They are four levels of the same broader SH Core concept.

## 2.2 SH Core Is Not One Narrow Component

The historical use of the term **SH Core / SH-CORE** across validated project material occurred at different abstraction levels.

The Frozen Baseline uses **SH CORE** explicitly as an architectural layer and orchestration concept. Earlier conceptual history uses **SH Core** in the sense of a protected fundamental foundation and governance object.

This difference is treated as **evolution and abstraction-level specialization**, not as evidence that the underlying concept is contradictory.

The canonical relationship is therefore:

```text
                    SH CORE / SH-CORE
                           │
          ┌────────────────┴────────────────┐
          │                                 │
 FUNDAMENTAL / GOVERNANCE            ARCHITECTURAL / RUNTIME
 FOUNDATION                          CORE
          │                                 │
          │                         Orchestrates and realizes
          │                         the foundational principles
          │                                 │
          └────────────────┬────────────────┘
                           │
                    SH INSTANCE
                           │
                   Owner / User Domain
```

The fundamental SH Core establishes the protected "why" and "what".

The architectural and runtime SH Core establishes the "how" by operationalizing those principles.

---

# 3. WHY SH CORE EXISTS

SH Core exists to ensure that SECOND HEAD is not reduced to the identity of a particular LLM, prompt, runtime, database, application, or infrastructure provider.

The core purpose is continuity of identity and system integrity.

Therefore:

- **Model ≠ SH Identity**
- **Runtime ≠ SH Identity**
- **Database ≠ SH Identity**
- **Prompt ≠ Entire SH Core**
- **Infrastructure ≠ SH Identity**

A model may be replaced.

A runtime may be migrated.

Infrastructure may be rebuilt.

A database implementation may change.

The system may evolve.

Yet SECOND HEAD should remain recognizably the same fundamental system as long as its protected identity anchors, fundamental invariants, governance boundaries, and persistence/continuity foundations remain intact.

SH Core is therefore the conceptual bridge between **identity persistence** and **system evolution**.

---

# 4. SH CORE FUNDAMENTAL PRINCIPLES

## 4.1 Identity Persistence

SH Core protects the continuity of SECOND HEAD identity across implementation changes.

The identity of an SH must not be reduced to the model currently generating its responses.

## 4.2 Model Independence

The LLM provider is an execution dependency, not the identity of SH.

A model can be replaced without automatically creating a new SH.

## 4.3 Runtime Independence

Runtime infrastructure is an implementation environment, not the identity of SH.

A migration from one runtime or infrastructure stack to another does not automatically destroy SH identity.

## 4.4 Privacy by Boundary

Private data belonging to one SH/User remains isolated from other SH/User domains unless explicitly authorized through valid governance and access mechanisms.

## 4.5 Creator Authority Is Not Omniscient Data Access

> **Creator Authority ≠ Private Data Access.**

The Creator has special authority over the governance and evolution of SECOND HEAD, but that authority does not automatically grant unrestricted access to private data belonging to every SH/User.

## 4.6 SH-000 Core Authority Is Not Omniscient Data Access

> **SH-000 Core Authority ≠ Private Data Access.**

SH-000 may possess special authority to manage or modify SH Core within defined governance boundaries. That does not make SH-000 the owner of all SH instances or grant automatic access to their private data.

## 4.7 Runtime Access Is Not Ownership

> **Runtime Access ≠ Ownership.**

A runtime service may execute operations on behalf of an authenticated owner, but runtime capability does not itself establish ownership of the data.

## 4.8 System Governance Is Not Universal Data Access

> **System Governance ≠ Omniscient Data Access.**

Authority over rules and system governance must remain distinct from access to private user domains.

## 4.9 Learning Does Not Automatically Modify Core

> **Learning ≠ Automatic Core Modification.**

Experience and learning may update memory, knowledge, preferences, strategies, or behavior.

They do not automatically rewrite SH Core.

## 4.10 Protected Foundation With Controlled Evolution

SH Core contains protected/fundamental elements while still permitting controlled evolution.

Evolution must preserve the integrity of the system's foundational identity and boundaries.

---

# 5. SH CORE LAYERS / DIMENSIONS

## 5.1 Fundamental / Governance Foundation

This is the deepest conceptual layer.

It includes, as applicable:

- Fundamental identity
- Fundamental principles
- Core philosophy
- Core invariants
- Privacy boundaries
- Governance boundaries
- Identity rules
- Security principles
- Permission boundaries
- Continuity principles
- Lifecycle principles

This layer answers:

> What must remain true for SECOND HEAD to remain SECOND HEAD?

Not every element of this layer is necessarily immutable forever. Some are protected and may evolve through governance and review.

## 5.2 Architectural / System Core

At the architecture level, SH CORE is the system layer responsible for maintaining the relationships among:

- Identity
- State
- Context
- Memory
- Knowledge
- Model
- Tools
- Actions
- Continuity

SH Core does not replace the authentication system, database, model, or tools.

It orchestrates their relationship according to the system's foundational rules.

## 5.3 Runtime / Operational Core

At runtime, the SH Core concept is realized through the execution flow that transforms authenticated user input into a coherent SH response while preserving identity, context, memory, ownership, security, persistence, and continuity.

The exact implementation may change.

The underlying responsibilities must remain consistent with the canonical principles.

## 5.4 Experiential Core

The experiential dimension represents how SH Core is experienced by the Owner.

For SH Core Lite, the validated conceptual pillars include:

1. Identity
2. Memory + Continuity
3. Relationship
4. Personality + Virtual Emotional Expression
5. Context + Initiative

These pillars represent an experiential foundation and are not, by themselves, a complete definition of the entire SH Core.

---

# 6. SH CORE COMPONENTS

The following components form the canonical conceptual map.

## 6.1 Fundamental Identity

The persistent identity foundation that allows an SH to remain the same SH across model, runtime, and infrastructure changes.

## 6.2 Core Philosophy

The fundamental philosophy and purpose that define the character and direction of SECOND HEAD.

## 6.3 Core Principles and Invariants

Rules that protect the integrity of the system.

Examples include:

- One email = one account = one primary SH, where applicable to the validated account model.
- Model is not SH identity.
- Private data is isolated by default.
- Learning does not automatically modify Core.
- Creator authority does not equal unrestricted private-data access.

## 6.4 Governance

The authority structure governing changes to fundamental system principles, Core, and system boundaries.

## 6.5 Identity and Ownership

The mechanisms that establish which User/Owner is associated with which SH instance and which private domain belongs to that Owner.

## 6.6 Context

The mechanism that assembles relevant information for a current interaction.

Context is not identical to Memory.

## 6.7 Memory

Persistent or semi-persistent information associated with an SH/User domain.

Private memory remains owner-scoped unless explicitly authorized.

## 6.8 Knowledge

Knowledge is distinct from private personal memory.

Knowledge may represent generalized or system-level information where governance permits it.

The full SH Knowledge architecture remains partly blueprint-level.

## 6.9 Model Orchestration

The abstraction that allows SH Core to interact with one or more AI models without treating any model as the SH identity itself.

## 6.10 Tools and Actions

Capabilities available to an SH runtime.

They are subordinate to the identity, authorization, and governance boundaries of the system.

## 6.11 Continuity

The mechanisms and principles that preserve coherent identity and experience across sessions and time.

## 6.12 Security and Persistence

Authentication, authorization, owner isolation, RLS, transactional persistence, and related controls provide implementation-level enforcement of Core boundaries.

---

# 7. CREATOR

## 7.1 Definition

The **Creator** is the unique identity with the highest governance authority over SECOND HEAD's fundamental Core and system governance, within defined boundaries.

Creator authority is not equivalent to unrestricted access to all user data.

## 7.2 Creator Responsibilities

Creator authority may include:

- Establishing fundamental system direction.
- Governing Core principles.
- Reviewing proposed Core evolution.
- Governing system-wide boundaries.
- Authorizing controlled Core changes.
- Maintaining the integrity of SECOND HEAD.

## 7.3 Creator Privacy Boundary

The following invariant applies:

> **Creator Authority ≠ Private Data Access.**

Creator does not automatically gain unrestricted access to private memory, conversations, context, or other private data belonging to other SH/User domains.

---

# 8. SH-000

## 8.1 Canonical Direction

For this version, the project adopts the following understanding:

> **SH-000 is the SH/account belonging to the Creator.**

SH-000 is therefore the Creator's SH representation within the SECOND HEAD system.

## 8.2 SH-000 Core Authority

SH-000 may possess special authority to manage or modify SH Core within defined governance boundaries.

This authority is not unlimited.

SH-000 remains subject to:

- Fundamental SECOND HEAD boundaries.
- Privacy principles.
- Governance constraints.
- Core protection rules.
- Explicitly defined authority boundaries.

## 8.3 SH-000 Is Not the Owner of All SH Instances

SH-000 is not the owner of all user SH instances.

SH-000 does not automatically own or control the private domains of other Users.

## 8.4 SH-000 Privacy Boundary

> **SH-000 Core Authority ≠ Private Data Access.**

Authority to modify or govern Core does not automatically provide access to private memory, conversations, or context belonging to another SH/User.

## 8.5 Relationship

The canonical conceptual relationship is:

```text
CREATOR
   │
   │ owns / controls
   ▼
SH-000
   │
   │ possesses special Core Governance Authority
   ▼
SH CORE
   │
   │ provides common foundation
   ▼
SH INSTANCES
   │
   ├── SH-A → Owner A private domain
   ├── SH-B → Owner B private domain
   └── SH-C → Owner C private domain
```

The exact technical representation of Creator and SH-000 remains an implementation detail unless explicitly defined elsewhere.

---

# 9. SH CORE AUTHORITY & GOVERNANCE

## 9.1 Authority Principle

SH Core is protected from arbitrary modification by ordinary users.

Core governance exists to prevent accidental or unauthorized destruction of the system's fundamental identity and boundaries.

## 9.2 Core Modification

Core modification must not be treated as an ordinary user-level personalization operation.

A Core change may require governance/review appropriate to the significance of the change.

## 9.3 Governance Boundary

Core authority does not imply:

- Ownership of all SH instances.
- Universal access to private data.
- Ability to bypass security controls.
- Ability to silently remove fundamental privacy protections.
- Ability to redefine every boundary without constraint.

## 9.4 Core Evolution

Core may evolve from one version to another while existing SH instances remain the same identities.

Conceptually:

```text
SH Core v1
   │
   │ controlled evolution / governance
   ▼
SH Core v2
   │
   ├── SH-A remains SH-A
   ├── SH-B remains SH-B
   └── SH-C remains SH-C
```

Core evolution does not automatically mean that every SH instance becomes a new SH.

---

# 10. SH INSTANCE & OWNER

An SH Instance is an individual operational manifestation of SECOND HEAD associated with an Owner/User.

The Owner's domain contains private information such as:

- Private conversations
- Private memories
- Private context
- User-specific preferences
- Other owner-scoped data

The SH instance inherits the common foundation of SH Core while maintaining a private domain.

The relationship can be expressed as:

```text
SH CORE
   │
   ├── common foundation
   ├── common invariants
   ├── common governance boundaries
   └── common system principles
          │
          ├── SH-A ↔ Owner A private domain
          ├── SH-B ↔ Owner B private domain
          └── SH-C ↔ Owner C private domain
```

A common Core does not mean common private memory.

---

# 11. PRIVACY & DATA BOUNDARY

Privacy is both:

1. A fundamental SH Core principle.
2. An architectural boundary.
3. An implementation security property.

## 11.1 Fundamental Principle

Private data belonging to one SH/User is not automatically available to another SH/User.

## 11.2 Architectural Boundary

Cross-instance memory access is denied by default unless explicitly authorized through valid governance and access mechanisms.

## 11.3 Implementation Boundary

The SH Lite V2.0/V2.1 implementation applies owner-scoped authentication and database-level isolation mechanisms including JWT-derived identity and RLS policies.

The implementation is an enforcement mechanism for the principle, not the definition of the principle itself.

## 11.4 Data Categories

The following must remain conceptually distinct:

- Private Memory
- Private Conversation
- Private Context
- General Knowledge
- System Core
- System Governance

These categories must not be collapsed into a single shared data pool.

---

# 12. SH CORE VS SH CORE LAYER / RUNTIME

The phrase **SH CORE** in the Frozen Baseline is primarily associated with the architectural Layer 4 and the orchestration of system subsystems.

The canonical interpretation is:

```text
SH CORE — FUNDAMENTAL FOUNDATION
          │
          │ defines / protects
          ▼
SH CORE — ARCHITECTURAL LAYER
          │
          │ orchestrates
          ▼
Identity / State / Context / Memory / Knowledge
Model / Tools / Actions / Continuity
          │
          ▼
SH INSTANCE RUNTIME
```

The architectural SH Core is therefore the operational realization of the broader fundamental SH Core.

It must not be interpreted as a completely separate concept.

---

# 13. SH CORE VS SH CORE LITE

SH Core Lite is not a different species of SECOND HEAD.

It is a constrained and pragmatic implementation of selected SH Core capabilities within a smaller scope.

SH Core Lite may implement:

- Identity
- Memory and continuity
- Basic context assembly
- Personality expression
- Basic initiative/contextual opening
- Owner isolation
- Basic persistence

It does not imply that the full SH Core has been completely implemented.

Conceptually:

```text
FULL SH CORE
│
├── Fundamental / Governance
├── Architecture
├── Runtime
├── Knowledge
├── Tools / Capabilities
├── Relationship
├── Continuity
├── Evolution
└── Other full-system capabilities
        │
        ▼
SH CORE LITE
   └── selected subset implemented pragmatically
```

SH Core Lite is therefore an implementation scope, not a replacement definition for SH Core.

---

# 14. SH CORE ↔ IDENTITY

Identity is one of the most fundamental relationships of SH Core.

SH Core protects the distinction between:

- SH identity
- User identity
- Account identity
- Model identity
- Runtime identity
- Database identity

An implementation mapping may temporarily use the same identifier between account and SH representation, but this must not automatically be interpreted as a universal conceptual invariant unless explicitly canonicalized.

The long-term architectural principle is:

> SH Identity is a persistent identity anchor independent of the model used to generate responses.

---

# 15. SH CORE ↔ MEMORY

Memory provides continuity of experience.

SH Core governs the relationship between identity and memory while preserving ownership boundaries.

Memory may include:

- Personal facts
- Conversation history
- Relevant continuity information
- Other owner-scoped information

Private memory belongs to the relevant SH/User domain.

Memory does not automatically become Core.

Memory does not automatically become Knowledge.

Learning from memory does not automatically modify Core.

---

# 16. SH CORE ↔ KNOWLEDGE

Knowledge is conceptually distinct from private personal memory.

A future or full SH architecture may support generalized knowledge that is useful beyond a single Owner domain.

However:

> Personal experience must not automatically become shared system knowledge.

A potential evolution path is:

```text
Private Experience
      ↓
Observation / Learning
      ↓
Candidate Insight
      ↓
Generalization
      ↓
Governance / Review
      ↓
Approved Knowledge
```

This is a conceptual evolution model.

The exact technical mechanism, review authority, privacy-preserving generalization process, and promotion criteria remain **OPEN / UNRESOLVED**.

Most importantly:

> **Learning ≠ Automatic Core Modification.**

Knowledge evolution and Core evolution are related but not identical.

---

# 17. SH CORE ↔ MODEL

The model is an execution capability.

The model:

- Generates responses.
- Performs reasoning or inference.
- May be replaced.
- May be upgraded.
- May be routed through different providers.

The model is not the SH identity.

Therefore:

> **Model ≠ SH Identity.**

A model change does not automatically create a new SH.

A future multi-model architecture may allow SH Core to select among providers without changing the identity of the SH.

The complete multi-model router/provider abstraction remains **BLUEPRINT / DEFERRED** in the current SH Lite implementation scope.

---

# 18. SH CORE ↔ RUNTIME

Runtime is the environment in which SH Core is operationalized.

Runtime may include:

- Application frontend
- Backend services
- Edge Functions
- Database
- Authentication services
- AI provider integrations
- Tool execution infrastructure

Runtime is not SH identity.

Therefore:

> **Runtime ≠ SH Identity.**

A runtime migration must preserve the relevant identity anchors, ownership boundaries, persistence, and continuity guarantees if the same SH identity is to continue.

---

# 19. SH CORE EVOLUTION

## 19.1 Evolution Principle

SECOND HEAD is designed to evolve.

Evolution may occur at multiple levels:

- Implementation
- Runtime
- Model
- Memory architecture
- Knowledge
- Architecture
- Governance
- Core itself

These levels must not be conflated.

## 19.2 Conceptual Evolution Flow

A safe conceptual model is:

```text
Experience
   ↓
Observation
   ↓
Evaluation
   ↓
Learning Candidate
   ↓
Validation
   ↓
Memory / Knowledge / Preference / Strategy / Behavior Update
   │
   │ only if a fundamental change is proposed
   ▼
Core Review / Governance
   ↓
Approved Core Evolution
   ↓
SH Core Revision
```

This flow preserves the distinction between ordinary learning and fundamental Core modification.

## 19.3 Core Evolution and Identity Continuity

If SH Core evolves:

```text
SH Core v1 → SH Core v2
```

the existing instances may remain:

```text
SH-A → remains SH-A
SH-B → remains SH-B
SH-C → remains SH-C
```

Core evolution is therefore not equivalent to identity replacement.

---

# 20. IMMUTABLE / PROTECTED VS EVOLVABLE

The term "immutable" must be interpreted carefully.

It does not mean that every aspect of SH Core can never change.

The canonical distinction is:

## 20.1 Protected / Fundamental

Examples:

- Fundamental identity principles
- Fundamental privacy boundaries
- Core invariants
- Core governance boundaries
- Identity continuity principles
- The distinction between SH identity and model identity

These require strong protection.

## 20.2 Evolvable Through Governance

Potential examples:

- Clarification of Core principles
- Expansion of system knowledge
- Architectural improvements
- Governance refinements
- Model abstraction improvements
- Runtime improvements
- Core revisions that preserve the fundamental identity of SECOND HEAD

## 20.3 Instance-Specific

Examples:

- User preferences
- Private memory
- Private conversations
- Private context
- Owner-specific personalization

These belong to individual SH domains and must not automatically propagate to the global Core.

## 20.4 Implementation-Specific

Examples:

- Specific database technology
- Specific LLM provider
- Specific runtime platform
- Specific API implementation
- Specific persistence mechanism

These may change without necessarily changing SH identity.

---

# 21. OPERATIONAL / RUNTIME MODEL

A canonical conceptual runtime flow is:

```text
User Input
   ↓
Account / Authentication
   ↓
Authorization / Ownership
   ↓
SH Identity Resolution
   ↓
SH State / Session
   ↓
Conversation
   ↓
Context Assembly
   ├── Identity
   ├── Relevant Memory
   ├── Knowledge / Reference
   └── Session Continuity
   ↓
Model / AI Orchestration
   ↓
Tools / Actions (if authorized)
   ↓
Response
   ↓
Memory Decision
   ↓
State Update
   ↓
Audit / Persistence
   ↓
Continuity
```

The exact runtime implementation may be simplified in SH Lite.

The architectural principle remains that identity, ownership, context, memory, model execution, persistence, and continuity are related but distinct responsibilities.

---

# 22. IMPLEMENTATION MAPPING

## 22.1 SH Lite V2.0

The SH Lite V2.0 implementation represents a limited realization of SH Core concepts.

Implemented or substantially represented:

- SH identity representation
- Owner-scoped context
- Read-only context construction
- Conversation persistence
- Basic memory extraction/retrieval
- Virtual session continuity
- Persona directives
- Basic contextual opening
- Owner-scoped data handling

The implementation is not a complete implementation of the full SH Core.

## 22.2 SH Lite V2.1

V2.1 strengthens the implementation boundary through:

- JWT-derived owner identity
- `auth.uid()` ownership enforcement
- RLS owner-isolation policies
- Atomic conversation persistence
- Hardening against client-supplied ownership identity
- Preservation of the existing SH Lite conceptual scope

V2.1 should be understood as technical hardening of SH Lite, not as completion of the entire SH Core architecture.

## 22.3 Canonical Implementation Principle

Implementation details may evolve.

The following conceptual invariants must remain stable:

- Ownership must be authenticated.
- Private data must remain isolated.
- SH identity must not be confused with model identity.
- Runtime capability must not imply ownership.
- Core principles must not be silently bypassed.

---

# 23. CURRENT IMPLEMENTATION STATUS

The current state is best represented as follows.

| Area | Status |
|---|---|
| Fundamental SH Core concept | CANONICAL |
| Fundamental governance concept | CANONICAL / PARTIALLY FORMALIZED |
| Privacy as Core boundary | CANONICAL |
| Creator authority boundary | CANONICAL |
| SH-000 as Creator's SH/account | CANONICAL DIRECTION |
| SH-000 Core modification authority | CANONICAL DIRECTION, exact mechanism OPEN |
| SH Core architectural orchestration | CANONICAL / DESIGNED |
| SH Core Lite experiential foundation | CANONICAL |
| Identity representation in SH Lite | IMPLEMENTED |
| Read-only Context Builder | IMPLEMENTED |
| Basic Memory / Continuity | IMPLEMENTED |
| Owner isolation | IMPLEMENTED / HARDENED |
| JWT / `auth.uid()` ownership enforcement | IMPLEMENTED / HARDENED |
| Atomic conversation persistence | IMPLEMENTED / HARDENED |
| Full SH Core governance engine | NOT IMPLEMENTED |
| Full Core Evolution pipeline | OPEN / BLUEPRINT |
| Full SH Knowledge system | BLUEPRINT / DEFERRED |
| Full Relationship Engine | BLUEPRINT / DEFERRED |
| Full Capability / Tool system | BLUEPRINT / DEFERRED |
| Multi-model routing | BLUEPRINT / DEFERRED |
| Full semantic memory architecture | BLUEPRINT / DEFERRED |

---

# 24. BLUEPRINT / DEFERRED / OPEN DESIGN

The following remain open or incomplete.

## 24.1 SH Core Fundamental Contents

The complete formal inventory of every element that belongs to the fundamental Core remains open.

The current canonical concept protects the existence and role of the fundamental Core without pretending that every internal element has already been exhaustively specified.

## 24.2 SH-000 Technical Definition

The conceptual relationship is established:

> SH-000 = Creator's SH/account.

The exact technical representation and identifier architecture remain implementation-specific unless separately canonicalized.

## 24.3 Core Authority Mechanism

The existence of special Core governance authority is established conceptually.

The exact permission model, approval mechanism, audit requirements, rollback mechanism, and technical enforcement remain open.

## 24.4 Core Review

A formal Core Review process is not yet fully implemented.

The concept remains necessary for controlled Core evolution.

## 24.5 Knowledge Generalization

The complete mechanism for converting private experience into privacy-preserving generalized knowledge remains open.

No private user data should be promoted to shared knowledge without appropriate governance and privacy safeguards.

## 24.6 Semantic Memory

Advanced semantic memory, embeddings, vector search, clustering, deduplication, and related governance remain deferred or blueprint-level within SH Lite.

## 24.7 Multi-Model Routing

Provider abstraction and automatic model routing remain future architecture work.

## 24.8 Full SH Core Runtime

SH Lite demonstrates selected components.

The complete full-system runtime is not yet implemented.

---

# 25. NON-GOALS & MISINTERPRETATIONS

The following interpretations are explicitly rejected.

## 25.1 SH Core Is Not a System Prompt

A prompt may implement part of SH Core behavior, but the prompt is not the entire Core.

## 25.2 SH Core Is Not the LLM

The LLM is a model capability.

It is not SH identity.

## 25.3 SH Core Is Not the Database

The database stores state and data.

It does not, by itself, constitute SH identity or Core.

## 25.4 SH Core Is Not the Runtime

Runtime executes the system.

It does not define SH identity by itself.

## 25.5 Creator Is Not an Omniscient Administrator

Creator authority does not equal unrestricted private-data access.

## 25.6 SH-000 Is Not the Owner of All SH Instances

SH-000 is the Creator's SH/account.

It is not a universal owner of all user SH domains.

## 25.7 Shared Core Does Not Mean Shared Private Memory

All SH instances may share the same fundamental Core while maintaining isolated private domains.

## 25.8 Learning Is Not Automatic Core Modification

Personal experience does not automatically rewrite the fundamental Core.

## 25.9 SH Core Lite Is Not the Full SH Core

SH Core Lite is a constrained implementation scope.

It must not be mistaken for the complete system.

---

# 26. CANONICAL INVARIANTS

The following invariants are canonical for this version:

1. **SH Core is the foundational and governing core of SECOND HEAD.**
2. **SH Core exists at both fundamental/governance and architectural/runtime levels as related layers of one broader concept.**
3. **SH Core protects the identity and continuity of SECOND HEAD across model, runtime, and infrastructure changes.**
4. **Model ≠ SH Identity.**
5. **Runtime ≠ SH Identity.**
6. **Database ≠ SH Identity.**
7. **Creator Authority ≠ Private Data Access.**
8. **SH-000 Core Authority ≠ Private Data Access.**
9. **Runtime Access ≠ Ownership.**
10. **System Governance ≠ Omniscient Data Access.**
11. **Private SH/User data is isolated by default.**
12. **Shared SH Core does not imply shared private memory or private context.**
13. **Learning ≠ Automatic Core Modification.**
14. **Core evolution requires appropriate governance/review.**
15. **Core evolution does not automatically replace the identity of existing SH instances.**
16. **SH Core Lite is a constrained implementation of selected SH Core concepts, not a separate species of SH.**
17. **Model, runtime, infrastructure, and implementation technology may evolve without automatically changing SH identity.**
18. **Fundamental Core boundaries must not be silently bypassed by ordinary user-level operations.**

---

# 27. OPEN QUESTIONS

The following remain intentionally open for future canonical decisions:

1. What is the complete formal inventory of all fundamental SH Core elements?
2. Which Core elements are absolutely immutable, and which are protected but evolvable?
3. What exact governance mechanism authorizes SH-000/Core changes?
4. What are the exact limits of SH-000 Core authority?
5. How is Core Review formally performed and audited?
6. How are generalized insights separated from private user information?
7. How does SH Knowledge relate technically to SH Core?
8. What exact identity-anchor architecture will replace or formalize temporary implementation mappings?
9. How should Core evolution be versioned, migrated, rolled back, and validated?
10. Which parts of the full SH Core architecture must be implemented before SH Full can be considered complete?

These questions do not invalidate the current Core definition.

They define the remaining design space.

---

# 28. FINAL CANONICAL SUMMARY

**SH Core / SH-CORE is the foundational and governing core of SECOND HEAD that preserves what makes SECOND HEAD remain SECOND HEAD across users, SH instances, models, runtimes, infrastructure, and system evolution.**

It is simultaneously:

- a fundamental identity and governance foundation;
- a protected set of principles, invariants, and boundaries;
- an architectural orchestration concept;
- a runtime responsibility;
- and an experiential foundation expressed through SH behavior and continuity.

The fundamental Core defines and protects the system's deepest identity and boundaries.

The architectural Core operationalizes those principles by coordinating identity, state, context, memory, knowledge, model, tools, actions, and continuity.

The runtime realizes those responsibilities in actual execution.

SH Core is shared as a foundational system concept, but private user domains remain isolated.

The Creator holds the highest governance authority over the Core within defined boundaries.

SH-000 is the Creator's SH/account and may possess special authority to manage or modify SH Core within those boundaries.

Neither Creator authority nor SH-000 Core authority implies unrestricted access to private data belonging to other SH/User domains.

SH Core Lite is a constrained, pragmatic realization of selected SH Core concepts. It is not a replacement for the full SH Core.

The central invariants are:

> **Model ≠ SH Identity.**  
> **Runtime ≠ SH Identity.**  
> **Database ≠ SH Identity.**  
> **Creator Authority ≠ Private Data Access.**  
> **SH-000 Core Authority ≠ Private Data Access.**  
> **Runtime Access ≠ Ownership.**  
> **System Governance ≠ Omniscient Data Access.**  
> **Learning ≠ Automatic Core Modification.**

The current SH Lite V2.0/V2.1 implementations demonstrate meaningful portions of SH Core at the identity, context, memory, continuity, persistence, and privacy-enforcement levels.

They do not constitute completion of the entire SH Core.

The full SH Core remains an evolving architecture whose protected foundation must remain stable while its implementation, knowledge systems, runtime, model layer, governance mechanisms, and capabilities may evolve through controlled design and review.

**This document is the conceptual authority for SH Core / SH-CORE. Future technical work should use this document as the primary conceptual reference and must not redefine SH Core solely from a single implementation snapshot, model provider, runtime, or historical terminology.**


---

# PART II — VERSI BAHASA INDONESIA RESMI

# SECOND_HEAD_SH_CORE_CANONICAL_v1.0 — BAHASA INDONESIA

**Status:** Canonical Conceptual Authority  
**Versi:** v1.0  
**Proyek:** SECOND HEAD  
**Jenis Dokumen:** Fondasi Konseptual / Arsitektural Canonical  
**Cakupan Authority:** SH Core / SH-CORE  
**Peran Utama:** Otoritas konseptual tunggal untuk desain teknis dan pekerjaan implementasi SECOND HEAD di masa depan

---

# 1. TUJUAN & OTORITAS

## 1.1 Tujuan

Dokumen ini secara formal mendefinisikan konsep canonical **SH Core / SH-CORE** untuk sistem SECOND HEAD.

SH Core bukan sekadar system prompt, database, LLM provider, runtime, atau modul software yang berdiri sendiri. SH Core adalah konsep fundamental yang menghubungkan identitas dan prinsip dasar SECOND HEAD dengan mekanisme arsitektural dan runtime yang diperlukan untuk mempertahankan identitas, kontinuitas, governance, dan privacy tersebut di seluruh SH instance.

Dokumen ini ada untuk mencegah pekerjaan teknis di masa depan menafsirkan SH Core hanya berdasarkan satu snapshot implementasi, satu runtime, satu model provider, atau satu pilihan terminologi historis.

## 1.2 Otoritas

Dokumen ini merupakan evolusi dari fondasi SECOND HEAD yang telah divalidasi sebelumnya.

Dasar utamanya adalah:

1. Sejarah konseptual SECOND HEAD yang telah divalidasi dalam proyek.
2. Fondasi source document yang telah divalidasi:
   - `SECOND_HEAD_SESSION_RESUME_COMPILATION_v1.0.md`
   - `SECOND_HEAD_COMPILED_DOCUMENTATION_BASELINE_v1.0.md`
   - `SECOND_HEAD_SH_LITE_V2.0_COMPILED_DOCUMENTATION_v1.0.md`
   - `SECOND_HEAD_SH_LITE_V2.1_COMPILED_DOCUMENTATION_v1.0.md`
3. Pemetaan yang telah divalidasi mengenai kemunculan, penggunaan, dan konteks istilah **SH Core / SH-CORE** di dalam keempat source document tersebut.
4. Keputusan dan klarifikasi eksplisit yang dibuat selama pembentukan dokumen canonical ini.

Dua analisis AI eksternal yang diberikan selama pembentukan dokumen ini hanya diperlakukan sebagai cross-check sekunder dan input interpretatif. Keduanya bukan otoritas canonical kecuali kesimpulannya didukung secara independen oleh fondasi yang telah divalidasi atau secara eksplisit diadopsi di sini.

## 1.3 Aturan Klasifikasi

Dalam dokumen ini:

- **CANONICAL / VALIDATED** berarti telah dinyatakan valid secara eksplisit atau telah ditetapkan oleh fondasi dan keputusan proyek yang diterima.
- **DERIVED / RECONSTRUCTED** berarti merupakan sintesis kuat dari materi yang telah divalidasi dan evolusi konsep SECOND HEAD.
- **PROPOSED / INTERPRETATION** berarti formulasi yang berguna tetapi belum dinaikkan menjadi fakta canonical yang immutable.
- **OPEN / UNRESOLVED** berarti sengaja belum difinalkan.

Jika suatu hal masih open, dokumen ini tidak mengarang jawaban definitif.

---

# 2. DEFINISI CANONICAL SH CORE

## 2.1 Definisi Utama

**SH Core / SH-CORE adalah fondasi dan governing core dari SECOND HEAD yang menjaga agar SECOND HEAD tetap menjadi SECOND HEAD di seluruh user, SH instance, model, runtime, infrastructure, dan evolusi sistem.**

SH Core mendefinisikan dan melindungi identitas fundamental, prinsip, invariants, governance boundaries, privacy boundaries, dan fondasi continuity SECOND HEAD, sekaligus menyediakan dasar konseptual dan arsitektural yang memungkinkan fondasi tersebut diinstansiasikan dan dioperasionalkan pada setiap SH instance.

Karena itu SH Core hadir secara bersamaan dalam beberapa layer yang saling berhubungan:

1. **Fundamental / Governance Layer** — apa sebenarnya SECOND HEAD dan apa yang harus tetap terlindungi.
2. **Architectural / System Layer** — bagaimana fundamental Core direpresentasikan dan diorkestrasikan melalui arsitektur sistem.
3. **Runtime / Operational Layer** — bagaimana prinsip Core dijalankan dalam interaksi aktual sebuah SH instance.
4. **Experiential Layer** — bagaimana Core diwujudkan sebagai pengalaman SH yang persisten, termasuk identity, continuity, memory, personality, relationship, context, dan initiative jika telah diimplementasikan.

Keempatnya bukan empat sistem yang tidak berhubungan. Keempatnya adalah empat tingkat dari konsep SH Core yang lebih luas.

## 2.2 SH Core Bukan Satu Komponen Sempit

Penggunaan historis istilah **SH Core / SH-CORE** dalam materi proyek yang telah divalidasi muncul pada beberapa tingkat abstraksi.

Frozen Baseline menggunakan **SH CORE** secara eksplisit sebagai architectural layer dan konsep orchestration. Sejarah konseptual sebelumnya menggunakan **SH Core** dalam arti fundamental foundation dan governance object yang terlindungi.

Perbedaan ini diperlakukan sebagai **evolusi dan spesialisasi level abstraksi**, bukan sebagai bukti adanya kontradiksi terhadap konsep dasarnya.

Hubungan canonical-nya adalah:

```text
                    SH CORE / SH-CORE
                           │
          ┌────────────────┴────────────────┐
          │                                 │
 FUNDAMENTAL / GOVERNANCE            ARCHITECTURAL / RUNTIME
 FOUNDATION                          CORE
          │                                 │
          │                         Mengorkestrasikan dan
          │                         merealisasikan prinsip
          │                         fundamental
          │                                 │
          └────────────────┬────────────────┘
                           │
                    SH INSTANCE
                           │
                    Owner / User Domain
```

Fundamental SH Core menetapkan dan melindungi **"mengapa"** dan **"apa"**.

Architectural dan runtime SH Core menetapkan **"bagaimana"** dengan mengoperasionalkan prinsip-prinsip tersebut.

---

# 3. MENGAPA SH CORE ADA

SH Core ada untuk memastikan bahwa SECOND HEAD tidak direduksi menjadi identitas dari LLM, prompt, runtime, database, aplikasi, atau infrastructure provider tertentu.

Tujuan utamanya adalah kontinuitas identitas dan integritas sistem.

Karena itu:

- **Model ≠ SH Identity**
- **Runtime ≠ SH Identity**
- **Database ≠ SH Identity**
- **Prompt ≠ Entire SH Core**
- **Infrastructure ≠ SH Identity**

Model dapat diganti.

Runtime dapat dimigrasikan.

Infrastructure dapat dibangun ulang.

Implementasi database dapat berubah.

Sistem dapat berevolusi.

Namun SECOND HEAD seharusnya tetap dapat dikenali sebagai sistem fundamental yang sama selama identity anchors, fundamental invariants, governance boundaries, dan persistence/continuity foundations yang terlindungi tetap terjaga.

Dengan demikian, SH Core adalah jembatan konseptual antara **identity persistence** dan **system evolution**.

---

# 4. PRINSIP FUNDAMENTAL SH CORE

## 4.1 Identity Persistence

SH Core melindungi kontinuitas identitas SECOND HEAD di seluruh perubahan implementasi.

Identitas sebuah SH tidak boleh direduksi menjadi model yang saat ini menghasilkan responsnya.

## 4.2 Model Independence

LLM provider adalah dependency eksekusi, bukan identitas SH.

Model dapat diganti tanpa secara otomatis menciptakan SH baru.

## 4.3 Runtime Independence

Runtime infrastructure adalah lingkungan implementasi, bukan identitas SH.

Migrasi dari satu runtime atau infrastructure stack ke stack lain tidak secara otomatis menghancurkan identitas SH.

## 4.4 Privacy by Boundary

Data privat milik satu SH/User tetap terisolasi dari domain SH/User lain kecuali secara eksplisit diotorisasi melalui mekanisme governance dan access yang valid.

## 4.5 Creator Authority Is Not Omniscient Data Access

> **Creator Authority ≠ Private Data Access.**

Creator memiliki authority khusus atas governance dan evolusi SECOND HEAD, tetapi authority tersebut tidak secara otomatis memberikan akses tidak terbatas terhadap data privat setiap SH/User.

## 4.6 SH-000 Core Authority Is Not Omniscient Data Access

> **SH-000 Core Authority ≠ Private Data Access.**

SH-000 dapat memiliki authority khusus untuk mengelola atau mengubah SH Core dalam governance boundaries yang telah ditentukan. Hal tersebut tidak menjadikan SH-000 sebagai pemilik seluruh SH instance atau memberikan akses otomatis terhadap data privat mereka.

## 4.7 Runtime Access Is Not Ownership

> **Runtime Access ≠ Ownership.**

Sebuah runtime service dapat menjalankan operasi atas nama owner yang terautentikasi, tetapi kemampuan runtime itu sendiri tidak menetapkan ownership atas data.

## 4.8 System Governance Is Not Universal Data Access

> **System Governance ≠ Omniscient Data Access.**

Authority atas aturan dan governance sistem harus tetap dibedakan dari akses terhadap private user domain.

## 4.9 Learning Does Not Automatically Modify Core

> **Learning ≠ Automatic Core Modification.**

Experience dan learning dapat memperbarui memory, knowledge, preferences, strategies, atau behavior.

Namun keduanya tidak secara otomatis menulis ulang SH Core.

## 4.10 Protected Foundation With Controlled Evolution

SH Core memiliki elemen yang protected/fundamental sekaligus tetap memungkinkan controlled evolution.

Evolusi harus menjaga integritas identity dan boundaries fundamental sistem.

---

# 5. LAYER / DIMENSI SH CORE

## 5.1 Fundamental / Governance Foundation

Ini adalah layer konseptual terdalam.

Dapat mencakup:

- Fundamental identity
- Fundamental principles
- Core philosophy
- Core invariants
- Privacy boundaries
- Governance boundaries
- Identity rules
- Security principles
- Permission boundaries
- Continuity principles
- Lifecycle principles

Layer ini menjawab:

> Apa yang harus tetap benar agar SECOND HEAD tetap menjadi SECOND HEAD?

Tidak setiap elemen dalam layer ini harus immutable selamanya. Sebagian bersifat protected dan dapat berevolusi melalui governance dan review.

## 5.2 Architectural / System Core

Pada level arsitektur, SH CORE adalah layer sistem yang bertanggung jawab menjaga hubungan antara:

- Identity
- State
- Context
- Memory
- Knowledge
- Model
- Tools
- Actions
- Continuity

SH Core tidak menggantikan authentication system, database, model, atau tools.

SH Core mengorkestrasikan hubungan di antara semuanya sesuai fundamental rules sistem.

## 5.3 Runtime / Operational Core

Pada runtime, konsep SH Core diwujudkan melalui execution flow yang mengubah input user terautentikasi menjadi respons SH yang koheren sambil mempertahankan identity, context, memory, ownership, security, persistence, dan continuity.

Implementasi spesifik dapat berubah.

Tanggung jawab dasarnya harus tetap konsisten dengan prinsip canonical.

## 5.4 Experiential Core

Dimensi experiential merepresentasikan bagaimana SH Core dialami oleh Owner.

Untuk SH Core Lite, validated conceptual pillars mencakup:

1. Identity
2. Memory + Continuity
3. Relationship
4. Personality + Virtual Emotional Expression
5. Context + Initiative

Pilar-pilar ini merupakan experiential foundation dan bukan definisi lengkap dari seluruh SH Core.

---

# 6. KOMPONEN SH CORE

Komponen berikut membentuk canonical conceptual map.

## 6.1 Fundamental Identity

Fondasi identity persisten yang memungkinkan SH tetap menjadi SH yang sama di seluruh perubahan model, runtime, dan infrastructure.

## 6.2 Core Philosophy

Filosofi fundamental dan tujuan yang menentukan karakter serta arah SECOND HEAD.

## 6.3 Core Principles and Invariants

Aturan yang melindungi integritas sistem.

Contohnya:

- One email = one account = one primary SH, sejauh berlaku pada account model yang telah divalidasi.
- Model is not SH identity.
- Private data terisolasi secara default.
- Learning tidak secara otomatis memodifikasi Core.
- Creator authority tidak sama dengan unrestricted private-data access.

## 6.4 Governance

Authority structure yang mengatur perubahan terhadap fundamental system principles, Core, dan system boundaries.

## 6.5 Identity and Ownership

Mekanisme yang menetapkan User/Owner mana yang terkait dengan SH instance tertentu dan private domain mana yang menjadi milik Owner tersebut.

## 6.6 Context

Mekanisme yang menyusun informasi relevan untuk interaksi saat ini.

Context tidak identik dengan Memory.

## 6.7 Memory

Informasi persisten atau semi-persisten yang terkait dengan domain SH/User.

Private memory tetap berada dalam scope Owner kecuali secara eksplisit diotorisasi.

## 6.8 Knowledge

Knowledge berbeda dari private personal memory.

Knowledge dapat merepresentasikan informasi yang telah digeneralisasi atau informasi level sistem jika governance mengizinkannya.

Arsitektur lengkap SH Knowledge masih sebagian berada pada level blueprint.

## 6.9 Model Orchestration

Abstraksi yang memungkinkan SH Core berinteraksi dengan satu atau lebih AI model tanpa memperlakukan model mana pun sebagai SH identity.

## 6.10 Tools and Actions

Kapabilitas yang tersedia bagi SH runtime.

Keduanya tunduk pada identity, authorization, dan governance boundaries sistem.

## 6.11 Continuity

Mekanisme dan prinsip yang menjaga coherent identity dan experience lintas session dan waktu.

## 6.12 Security and Persistence

Authentication, authorization, owner isolation, RLS, transactional persistence, dan kontrol terkait lainnya menyediakan enforcement level implementasi atas boundary Core.

---

# 7. CREATOR

## 7.1 Definisi

**Creator** adalah identity unik dengan governance authority tertinggi atas fundamental Core dan system governance SECOND HEAD, dalam batasan yang telah ditentukan.

Creator authority tidak sama dengan unrestricted access terhadap seluruh user data.

## 7.2 Tanggung Jawab Creator

Creator authority dapat mencakup:

- Menetapkan arah fundamental sistem.
- Mengatur prinsip Core.
- Mereview usulan Core evolution.
- Mengatur system-wide boundaries.
- Mengotorisasi perubahan Core yang terkontrol.
- Menjaga integritas SECOND HEAD.

## 7.3 Creator Privacy Boundary

Invariant berikut berlaku:

> **Creator Authority ≠ Private Data Access.**

Creator tidak secara otomatis memperoleh unrestricted access terhadap private memory, conversations, context, atau private data lain milik SH/User domain lain.

---

# 8. SH-000

## 8.1 Arah Canonical

Untuk versi ini, proyek mengadopsi pemahaman berikut:

> **SH-000 adalah SH/account milik Creator.**

Dengan demikian, SH-000 adalah representasi SH milik Creator di dalam sistem SECOND HEAD.

## 8.2 SH-000 Core Authority

SH-000 dapat memiliki authority khusus untuk mengelola atau memodifikasi SH Core dalam governance boundaries yang telah ditentukan.

Authority ini tidak tanpa batas.

SH-000 tetap tunduk pada:

- Fundamental SECOND HEAD boundaries.
- Privacy principles.
- Governance constraints.
- Core protection rules.
- Explicitly defined authority boundaries.

## 8.3 SH-000 Bukan Owner Semua SH Instance

SH-000 bukan owner dari seluruh user SH instance.

SH-000 tidak secara otomatis memiliki atau mengendalikan private domain milik User lain.

## 8.4 SH-000 Privacy Boundary

> **SH-000 Core Authority ≠ Private Data Access.**

Authority untuk memodifikasi atau mengatur Core tidak secara otomatis memberikan akses terhadap private memory, conversations, atau context milik SH/User lain.

## 8.5 Relasi

Relasi konseptual canonical adalah:

```text
CREATOR
   │
   │ owns / controls
   ▼
SH-000
   │
   │ possesses special Core Governance Authority
   ▼
SH CORE
   │
   │ provides common foundation
   ▼
SH INSTANCES
   │
   ├── SH-A → Owner A private domain
   ├── SH-B → Owner B private domain
   └── SH-C → Owner C private domain
```

Representasi teknis Creator dan SH-000 secara spesifik tetap merupakan implementation detail kecuali ditentukan secara eksplisit di tempat lain.

---

# 9. SH CORE AUTHORITY & GOVERNANCE

## 9.1 Authority Principle

SH Core dilindungi dari perubahan arbitrer oleh ordinary users.

Core governance ada untuk mencegah kerusakan atau penghancuran tidak sengaja maupun tidak sah terhadap fundamental identity dan boundaries sistem.

## 9.2 Core Modification

Modifikasi Core tidak boleh diperlakukan sebagai operasi personalisasi ordinary user.

Perubahan Core dapat memerlukan governance/review sesuai tingkat signifikansi perubahan tersebut.

## 9.3 Governance Boundary

Core authority tidak berarti:

- Ownership atas seluruh SH instance.
- Universal access terhadap private data.
- Kemampuan melewati security controls.
- Kemampuan menghapus fundamental privacy protections secara diam-diam.
- Kemampuan mendefinisikan ulang seluruh boundary tanpa constraint.

## 9.4 Core Evolution

Core dapat berevolusi dari satu versi ke versi berikutnya sementara existing SH instance tetap menjadi identity yang sama.

```text
SH Core v1
   │
   │ controlled evolution / governance
   ▼
SH Core v2
   │
   ├── SH-A tetap SH-A
   ├── SH-B tetap SH-B
   └── SH-C tetap SH-C
```

Core evolution tidak otomatis berarti setiap SH instance menjadi SH baru.

---

# 10. SH INSTANCE & OWNER

SH Instance adalah manifestasi operasional individual dari SECOND HEAD yang terhubung dengan Owner/User.

Domain Owner dapat berisi informasi privat seperti:

- Private conversations
- Private memories
- Private context
- User-specific preferences
- Data lain yang bersifat owner-scoped

SH instance mewarisi common foundation dari SH Core sambil mempertahankan private domain miliknya sendiri.

Relasinya dapat digambarkan:

```text
SH CORE
   │
   ├── common foundation
   ├── common invariants
   ├── common governance boundaries
   └── common system principles
          │
          ├── SH-A ↔ Owner A private domain
          ├── SH-B ↔ Owner B private domain
          └── SH-C ↔ Owner C private domain
```

Common Core tidak berarti common private memory.

---

# 11. PRIVACY & DATA BOUNDARY

Privacy adalah sekaligus:

1. Prinsip fundamental SH Core.
2. Architectural boundary.
3. Implementation security property.

## 11.1 Fundamental Principle

Data privat milik satu SH/User tidak otomatis tersedia bagi SH/User lain.

## 11.2 Architectural Boundary

Cross-instance memory access ditolak secara default kecuali secara eksplisit diotorisasi melalui governance dan access mechanism yang valid.

## 11.3 Implementation Boundary

Implementasi SH Lite V2.0/V2.1 menerapkan authenticated owner-scoped access dan database-level isolation melalui JWT-derived identity dan RLS policies.

Implementasi tersebut adalah mekanisme enforcement atas prinsip, bukan definisi dari prinsip itu sendiri.

## 11.4 Data Categories

Kategori berikut harus tetap dibedakan secara konseptual:

- Private Memory
- Private Conversation
- Private Context
- General Knowledge
- System Core
- System Governance

Kategori-kategori ini tidak boleh dilebur menjadi satu shared data pool.

---

# 12. SH CORE VS SH CORE LAYER / RUNTIME

Istilah **SH CORE** dalam Frozen Baseline terutama berkaitan dengan architectural Layer 4 dan orchestration atas subsystem sistem.

Interpretasi canonical-nya adalah:

```text
SH CORE — FUNDAMENTAL FOUNDATION
          │
          │ defines / protects
          ▼
SH CORE — ARCHITECTURAL LAYER
          │
          │ orchestrates
          ▼
Identity / State / Context / Memory / Knowledge
Model / Tools / Actions / Continuity
          │
          ▼
SH INSTANCE RUNTIME
```

Dengan demikian, architectural SH Core adalah operational realization dari broader fundamental SH Core.

Keduanya tidak boleh dipahami sebagai dua konsep yang sepenuhnya terpisah.

---

# 13. SH CORE VS SH CORE LITE

SH Core Lite bukan spesies SECOND HEAD yang berbeda.

SH Core Lite adalah implementasi yang dibatasi dan pragmatis dari kapabilitas SH Core tertentu dalam scope yang lebih kecil.

SH Core Lite dapat mengimplementasikan:

- Identity
- Memory dan continuity
- Basic context assembly
- Personality expression
- Basic initiative/contextual opening
- Owner isolation
- Basic persistence

Namun hal tersebut tidak berarti full SH Core telah diimplementasikan seluruhnya.

Secara konseptual:

```text
FULL SH CORE
│
├── Fundamental / Governance
├── Architecture
├── Runtime
├── Knowledge
├── Tools / Capabilities
├── Relationship
├── Continuity
├── Evolution
└── Other full-system capabilities
        │
        ▼
SH CORE LITE
   └── selected subset implemented pragmatically
```

SH Core Lite adalah implementation scope, bukan replacement definition untuk SH Core.

---

# 14. SH CORE ↔ IDENTITY

Identity adalah salah satu hubungan paling fundamental dalam SH Core.

SH Core melindungi perbedaan antara:

- SH identity
- User identity
- Account identity
- Model identity
- Runtime identity
- Database identity

Sebuah implementation mapping dapat menggunakan identifier yang sama sementara antara account dan SH representation, tetapi hal tersebut tidak boleh otomatis ditafsirkan sebagai universal conceptual invariant kecuali telah secara eksplisit dicanonicalkan.

Prinsip arsitektural jangka panjangnya adalah:

> SH Identity adalah persistent identity anchor yang independen dari model yang digunakan untuk menghasilkan respons.

---

# 15. SH CORE ↔ MEMORY

Memory menyediakan continuity of experience.

SH Core mengatur hubungan antara identity dan memory sambil mempertahankan ownership boundaries.

Memory dapat mencakup:

- Personal facts
- Conversation history
- Relevant continuity information
- Informasi owner-scoped lainnya

Private memory adalah bagian dari domain SH/User terkait.

Memory tidak otomatis menjadi Core.

Memory tidak otomatis menjadi Knowledge.

Learning dari memory tidak otomatis memodifikasi Core.

---

# 16. SH CORE ↔ KNOWLEDGE

Knowledge secara konseptual berbeda dari private personal memory.

Arsitektur SH masa depan atau full SH dapat mendukung generalized knowledge yang berguna di luar satu Owner domain.

Namun:

> Pengalaman personal tidak boleh secara otomatis menjadi shared system knowledge.

Salah satu kemungkinan evolution path adalah:

```text
Private Experience
      ↓
Observation / Learning
      ↓
Candidate Insight
      ↓
Generalization
      ↓
Governance / Review
      ↓
Approved Knowledge
```

Ini adalah conceptual evolution model.

Mekanisme teknis pasti, proses privacy-preserving generalization, authority review, dan kriteria promosi masih **OPEN / UNRESOLVED**.

Yang paling penting:

> **Learning ≠ Automatic Core Modification.**

Knowledge evolution dan Core evolution saling berkaitan tetapi bukan hal yang identik.

---

# 17. SH CORE ↔ MODEL

Model adalah execution capability.

Model:

- Menghasilkan respons.
- Melakukan reasoning atau inference.
- Dapat diganti.
- Dapat di-upgrade.
- Dapat dirutekan melalui provider yang berbeda.

Model bukan SH identity.

Karena itu:

> **Model ≠ SH Identity.**

Perubahan model tidak otomatis menciptakan SH baru.

Arsitektur multi-model di masa depan dapat memungkinkan SH Core memilih antara beberapa provider tanpa mengubah identity SH.

Multi-model router/provider abstraction lengkap masih berada pada status **BLUEPRINT / DEFERRED** dalam scope implementasi SH Lite saat ini.

---

# 18. SH CORE ↔ RUNTIME

Runtime adalah lingkungan tempat SH Core dioperasionalkan.

Runtime dapat mencakup:

- Application frontend
- Backend services
- Edge Functions
- Database
- Authentication services
- AI provider integrations
- Tool execution infrastructure

Runtime bukan SH identity.

Karena itu:

> **Runtime ≠ SH Identity.**

Migrasi runtime harus mempertahankan identity anchors, ownership boundaries, persistence, dan continuity guarantees yang relevan jika identity SH yang sama ingin dipertahankan.

---

# 19. SH CORE EVOLUTION

## 19.1 Evolution Principle

SECOND HEAD dirancang untuk berevolusi.

Evolusi dapat terjadi pada beberapa level:

- Implementation
- Runtime
- Model
- Memory architecture
- Knowledge
- Architecture
- Governance
- Core itu sendiri

Level-level tersebut tidak boleh dicampuradukkan.

## 19.2 Conceptual Evolution Flow

Model konseptual yang aman adalah:

```text
Experience
   ↓
Observation
   ↓
Evaluation
   ↓
Learning Candidate
   ↓
Validation
   ↓
Memory / Knowledge / Preference / Strategy / Behavior Update
   │
   │ hanya jika diusulkan perubahan fundamental
   ▼
Core Review / Governance
   ↓
Approved Core Evolution
   ↓
SH Core Revision
```

Alur ini mempertahankan perbedaan antara ordinary learning dan fundamental Core modification.

## 19.3 Core Evolution and Identity Continuity

Jika SH Core berevolusi:

```text
SH Core v1 → SH Core v2
```

instance yang sudah ada dapat tetap menjadi:

```text
SH-A → tetap SH-A
SH-B → tetap SH-B
SH-C → tetap SH-C
```

Core evolution bukan hal yang sama dengan identity replacement.

---

# 20. IMMUTABLE / PROTECTED VS EVOLVABLE

Istilah "immutable" harus ditafsirkan secara hati-hati.

Tidak berarti setiap aspek SH Core tidak akan pernah berubah.

Pembedaan canonical-nya adalah:

## 20.1 Protected / Fundamental

Contohnya:

- Fundamental identity principles
- Fundamental privacy boundaries
- Core invariants
- Core governance boundaries
- Identity continuity principles
- Distingsi antara SH identity dan model identity

Semua ini memerlukan perlindungan kuat.

## 20.2 Evolvable Through Governance

Contoh potensial:

- Clarification atas Core principles
- Perluasan system knowledge
- Architectural improvements
- Governance refinements
- Model abstraction improvements
- Runtime improvements
- Core revisions yang mempertahankan fundamental identity SECOND HEAD

## 20.3 Instance-Specific

Contohnya:

- User preferences
- Private memory
- Private conversations
- Private context
- Owner-specific personalization

Semua ini milik domain SH individual dan tidak boleh otomatis dipropagasikan ke global Core.

## 20.4 Implementation-Specific

Contohnya:

- Database technology tertentu
- LLM provider tertentu
- Runtime platform tertentu
- API implementation tertentu
- Persistence mechanism tertentu

Semua ini dapat berubah tanpa harus mengubah SH identity.

---

# 21. MODEL OPERASIONAL / RUNTIME

Canonical conceptual runtime flow adalah:

```text
User Input
   ↓
Account / Authentication
   ↓
Authorization / Ownership
   ↓
SH Identity Resolution
   ↓
SH State / Session
   ↓
Conversation
   ↓
Context Assembly
   ├── Identity
   ├── Relevant Memory
   ├── Knowledge / Reference
   └── Session Continuity
   ↓
Model / AI Orchestration
   ↓
Tools / Actions (if authorized)
   ↓
Response
   ↓
Memory Decision
   ↓
State Update
   ↓
Audit / Persistence
   ↓
Continuity
```

Implementasi runtime dapat disederhanakan dalam SH Lite.

Prinsip arsitekturalnya tetap bahwa identity, ownership, context, memory, model execution, persistence, dan continuity adalah tanggung jawab yang saling berhubungan tetapi tetap berbeda.

---

# 22. PEMETAAN IMPLEMENTASI

## 22.1 SH Lite V2.0

Implementasi SH Lite V2.0 merupakan realisasi terbatas dari konsep SH Core.

Yang telah diimplementasikan atau direpresentasikan secara substansial:

- SH identity representation
- Owner-scoped context
- Read-only context construction
- Conversation persistence
- Basic memory extraction/retrieval
- Virtual session continuity
- Persona directives
- Basic contextual opening
- Owner-scoped data handling

Implementasi ini bukan implementasi lengkap dari full SH Core.

## 22.2 SH Lite V2.1

V2.1 memperkuat implementation boundary melalui:

- JWT-derived owner identity
- `auth.uid()` ownership enforcement
- RLS owner-isolation policies
- Atomic conversation persistence
- Hardening terhadap client-supplied ownership identity
- Mempertahankan scope konseptual SH Lite yang telah ada

V2.1 harus dipahami sebagai technical hardening SH Lite, bukan sebagai penyelesaian seluruh SH Core.

## 22.3 Canonical Implementation Principle

Detail implementasi dapat berevolusi.

Invariants konseptual berikut harus tetap stabil:

- Ownership harus terautentikasi.
- Private data harus tetap terisolasi.
- SH identity tidak boleh disamakan dengan model identity.
- Runtime capability tidak boleh berarti ownership.
- Core principles tidak boleh dilewati secara diam-diam.

---

# 23. STATUS IMPLEMENTASI SAAT INI

| Area | Status |
|---|---|
| Fundamental SH Core concept | CANONICAL |
| Fundamental governance concept | CANONICAL / PARTIALLY FORMALIZED |
| Privacy as Core boundary | CANONICAL |
| Creator authority boundary | CANONICAL |
| SH-000 as Creator's SH/account | CANONICAL DIRECTION |
| SH-000 Core modification authority | CANONICAL DIRECTION, exact mechanism OPEN |
| SH Core architectural orchestration | CANONICAL / DESIGNED |
| SH Core Lite experiential foundation | CANONICAL |
| Identity representation in SH Lite | IMPLEMENTED |
| Read-only Context Builder | IMPLEMENTED |
| Basic Memory / Continuity | IMPLEMENTED |
| Owner isolation | IMPLEMENTED / HARDENED |
| JWT / `auth.uid()` ownership enforcement | IMPLEMENTED / HARDENED |
| Atomic conversation persistence | IMPLEMENTED / HARDENED |
| Full SH Core governance engine | NOT IMPLEMENTED |
| Full Core Evolution pipeline | OPEN / BLUEPRINT |
| Full SH Knowledge system | BLUEPRINT / DEFERRED |
| Full Relationship Engine | BLUEPRINT / DEFERRED |
| Full Capability / Tool system | BLUEPRINT / DEFERRED |
| Multi-model routing | BLUEPRINT / DEFERRED |
| Full semantic memory architecture | BLUEPRINT / DEFERRED |

---

# 24. BLUEPRINT / DEFERRED / OPEN DESIGN

Hal-hal berikut masih open atau belum lengkap.

## 24.1 SH Core Fundamental Contents

Inventaris formal lengkap dari seluruh elemen yang termasuk fundamental Core masih open.

Konsep canonical saat ini melindungi keberadaan dan peran fundamental Core tanpa berpura-pura bahwa setiap elemen internalnya telah ditentukan secara exhaustive.

## 24.2 SH-000 Technical Definition

Relasi konseptual telah ditetapkan:

> SH-000 = Creator's SH/account.

Representasi teknis dan identifier architecture yang tepat masih merupakan implementation-specific, kecuali telah dicanonicalkan secara terpisah.

## 24.3 Core Authority Mechanism

Keberadaan special Core governance authority telah ditetapkan secara konseptual.

Exact permission model, approval mechanism, audit requirements, rollback mechanism, dan technical enforcement masih open.

## 24.4 Core Review

Formal Core Review process belum sepenuhnya diimplementasikan.

Konsep ini tetap diperlukan untuk controlled Core evolution.

## 24.5 Knowledge Generalization

Mekanisme lengkap untuk mengubah private experience menjadi generalized knowledge yang privacy-preserving masih open.

Tidak ada private user data yang boleh dipromosikan menjadi shared knowledge tanpa governance dan privacy safeguards yang sesuai.

## 24.6 Semantic Memory

Advanced semantic memory, embeddings, vector search, clustering, deduplication, dan governance terkait masih deferred atau berada pada level blueprint dalam SH Lite.

## 24.7 Multi-Model Routing

Provider abstraction dan automatic model routing masih merupakan pekerjaan arsitektur masa depan.

## 24.8 Full SH Core Runtime

SH Lite menunjukkan selected components.

Full-system runtime belum diimplementasikan.

---

# 25. NON-GOALS & MISINTERPRETASI

Interpretasi berikut secara eksplisit ditolak.

## 25.1 SH Core Bukan System Prompt

Prompt dapat mengimplementasikan sebagian behavior SH Core, tetapi prompt bukan keseluruhan Core.

## 25.2 SH Core Bukan LLM

LLM adalah model capability.

LLM bukan SH identity.

## 25.3 SH Core Bukan Database

Database menyimpan state dan data.

Database itu sendiri bukan SH identity atau Core.

## 25.4 SH Core Bukan Runtime

Runtime menjalankan sistem.

Runtime tidak dengan sendirinya mendefinisikan SH identity.

## 25.5 Creator Bukan Omniscient Administrator

Creator authority tidak sama dengan unrestricted private-data access.

## 25.6 SH-000 Bukan Owner Semua SH Instance

SH-000 adalah SH/account milik Creator.

SH-000 bukan universal owner dari seluruh SH user domain.

## 25.7 Shared Core Tidak Berarti Shared Private Memory

Semua SH instance dapat berbagi fundamental Core yang sama sambil tetap memiliki private domain yang terisolasi.

## 25.8 Learning Bukan Automatic Core Modification

Personal experience tidak secara otomatis menulis ulang fundamental Core.

## 25.9 SH Core Lite Bukan Full SH Core

SH Core Lite adalah implementation scope yang dibatasi.

SH Core Lite tidak boleh disalahartikan sebagai keseluruhan sistem.

---

# 26. CANONICAL INVARIANTS

Invariant berikut adalah canonical untuk versi ini:

1. **SH Core adalah fondasi dan governing core dari SECOND HEAD.**
2. **SH Core hadir pada level fundamental/governance dan architectural/runtime sebagai layer yang saling berhubungan dalam satu konsep yang lebih luas.**
3. **SH Core melindungi identity dan continuity SECOND HEAD di seluruh perubahan model, runtime, dan infrastructure.**
4. **Model ≠ SH Identity.**
5. **Runtime ≠ SH Identity.**
6. **Database ≠ SH Identity.**
7. **Creator Authority ≠ Private Data Access.**
8. **SH-000 Core Authority ≠ Private Data Access.**
9. **Runtime Access ≠ Ownership.**
10. **System Governance ≠ Omniscient Data Access.**
11. **Private SH/User data terisolasi secara default.**
12. **Shared SH Core tidak berarti shared private memory atau private context.**
13. **Learning ≠ Automatic Core Modification.**
14. **Core evolution memerlukan governance/review yang sesuai.**
15. **Core evolution tidak otomatis menggantikan identity SH instance yang telah ada.**
16. **SH Core Lite adalah implementasi terbatas dari selected SH Core concepts, bukan spesies SH yang berbeda.**
17. **Model, runtime, infrastructure, dan implementation technology dapat berevolusi tanpa otomatis mengubah SH identity.**
18. **Fundamental Core boundaries tidak boleh dilewati secara diam-diam oleh operasi ordinary user-level.**

---

# 27. OPEN QUESTIONS

Hal-hal berikut sengaja tetap open untuk keputusan canonical di masa depan:

1. Apa inventaris formal lengkap dari seluruh elemen fundamental SH Core?
2. Elemen Core mana yang benar-benar immutable dan mana yang protected tetapi evolvable?
3. Mekanisme governance apa yang secara tepat mengotorisasi perubahan SH-000/Core?
4. Apa batas pasti authority SH-000 terhadap Core?
5. Bagaimana Core Review dilakukan dan diaudit secara formal?
6. Bagaimana generalized insights dipisahkan dari private user information?
7. Bagaimana SH Knowledge secara teknis berhubungan dengan SH Core?
8. Apa arsitektur identity-anchor yang tepat untuk menggantikan atau memformalkan temporary implementation mappings?
9. Bagaimana Core evolution harus diberi version, dimigrasikan, di-rollback, dan divalidasi?
10. Bagian mana dari full SH Core architecture yang harus diimplementasikan sebelum SH Full dapat dianggap complete?

Pertanyaan-pertanyaan ini tidak membatalkan definisi Core saat ini.

Pertanyaan tersebut mendefinisikan design space yang masih tersisa.

---

# 28. FINAL CANONICAL SUMMARY

**SH Core / SH-CORE adalah fondasi dan governing core dari SECOND HEAD yang menjaga agar SECOND HEAD tetap menjadi SECOND HEAD di seluruh user, SH instance, model, runtime, infrastructure, dan evolusi sistem.**

SH Core secara bersamaan merupakan:

- fondasi fundamental identity dan governance;
- kumpulan principles, invariants, dan boundaries yang protected;
- konsep architectural orchestration;
- runtime responsibility;
- dan experiential foundation yang diwujudkan melalui behavior dan continuity SH.

Fundamental Core mendefinisikan dan melindungi identity serta boundaries terdalam sistem.

Architectural Core mengoperasionalkan prinsip-prinsip tersebut dengan mengoordinasikan identity, state, context, memory, knowledge, model, tools, actions, dan continuity.

Runtime mewujudkan tanggung jawab tersebut dalam eksekusi aktual.

SH Core bersifat shared sebagai common system foundation, tetapi private user domain tetap terisolasi.

Creator memiliki governance authority tertinggi atas Core dalam batasan yang telah ditentukan.

SH-000 adalah SH/account milik Creator dan dapat memiliki special authority untuk mengelola atau memodifikasi SH Core dalam batasan tersebut.

Baik Creator authority maupun SH-000 Core authority tidak berarti unrestricted access terhadap private data milik SH/User lain.

SH Core Lite adalah realisasi terbatas dan pragmatis dari selected SH Core concepts. SH Core Lite bukan pengganti full SH Core.

Invariant utamanya adalah:

> **Model ≠ SH Identity.**  
> **Runtime ≠ SH Identity.**  
> **Database ≠ SH Identity.**  
> **Creator Authority ≠ Private Data Access.**  
> **SH-000 Core Authority ≠ Private Data Access.**  
> **Runtime Access ≠ Ownership.**  
> **System Governance ≠ Omniscient Data Access.**  
> **Learning ≠ Automatic Core Modification.**

Implementasi SH Lite V2.0/V2.1 saat ini menunjukkan bagian penting dari SH Core pada level identity, context, memory, continuity, persistence, dan privacy enforcement.

Namun implementasi tersebut belum merupakan penyelesaian seluruh SH Core.

Full SH Core tetap merupakan arsitektur yang terus berevolusi. Fondasi yang protected harus tetap stabil, sementara implementation, knowledge systems, runtime, model layer, governance mechanisms, dan capabilities dapat berevolusi melalui desain dan review yang terkontrol.

**Dokumen ini adalah otoritas konseptual untuk SH Core / SH-CORE. Pekerjaan teknis di masa depan harus menggunakan dokumen ini sebagai referensi konseptual utama dan tidak boleh mendefinisikan ulang SH Core hanya berdasarkan satu snapshot implementasi, model provider, runtime, atau terminologi historis.**
