# 1. Executive Overview Diagram ✅

```
Creator

↓

Core

↓

Platform

↓

SH

↓

Execution

↓

Infrastructure
```

# 2. Canonical Architecture Diagram (Master Diagram) ✅

```
╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
║                                     SECOND HEAD (SH) SYSTEM                                      ║
║              Persistent Personal Intelligence System — Architecture & Governance Map             ║
║                        (Derived representation of canonical documents)                            ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════╝


════════════════════════════════════════════════════════════════════════════════════════════════════
LAYER 0 — FUNDAMENTAL / GOVERNANCE FOUNDATION (The Protected Core)
════════════════════════════════════════════════════════════════════════════════════════════════════

                        ┌─────────────────────────┐
                        │        CREATOR           │
                        │  (Highest Governance     │
                        │   Authority within       │
                        │   Defined Boundaries)    │
                        └────────────┬────────────┘
                                     │ owns / controls
                                     ▼
                        ┌─────────────────────────┐
                        │        SH-000            │
                        │  (Creator's SH / Account)│
                        │  Special Core Governance │
                        │  Authority               │
                        │  ≠ Private Data Access   │
                        └────────────┬────────────┘
                                     │ possesses Core Governance Authority
                                     ▼
 ┌────────────────────────────────────────────────────────────────────────────────────────────────┐
 │                                   SH CORE CONSTITUTION                                         │
 ├────────────────────────────────────────────────────────────────────────────────────────────────┤
 │                                                                                                │
 │  ┌── PROTECTED / FUNDAMENTAL (Strong Protection) ──────────────────────────────────────────┐   │
 │  │                                                                                         │   │
 │  │  • Model ≠ SH Identity                    • Runtime ≠ SH Identity                       │   │
 │  │  • Database ≠ SH Identity                 • Hardware ≠ SH Identity                      │   │
 │  │  • Account_ID ≠ SH_ID                     • Session_ID ≠ SH_ID                          │   │
 │  │  • Creator Authority ≠ Private Data Access                                              │   │
 │  │  • SH-000 Core Authority ≠ Private Data Access                                          │   │
 │  │  • Runtime Access ≠ Ownership             • System Governance ≠ Omniscient Access        │   │
 │  │  • Learning ≠ Automatic Core Modification                                              │   │
 │  │  • Context ≠ Memory                       • Knowledge ≠ Memory                           │   │
 │  │  • Private Data Isolated by Default       • Shared Core ≠ Shared Private Memory          │   │
 │  │  • 1 Email = 1 Account = 1 Primary SH                                                   │   │
 │  │  • CLONE_SH ≠ SOURCE_SH                   • CREATOR_SH is NON-CLONABLE                   │   │
 │  │  • USER_SH CLONE = Owner Approval + Agreement                                           │   │
 │  │  • INHERITANCE ≠ CLONE                    • INHERITANCE ≠ Identity Transfer              │   │
 │  │  • EVOLUTION ≠ Ownership Transfer         • DECOMMISSION ≠ Immediate Permanent Delete    │   │
 │  │  • Evolution / Migration / Recovery ≠ New SH Identity                                   │   │
 │  │                                                                                         │   │
 │  └─────────────────────────────────────────────────────────────────────────────────────────┘   │
 │                                                                                                │
 │  ┌── EVOLVABLE THROUGH GOVERNANCE (Controlled Review Required) ────────────────────────────┐   │
 │  │                                                                                         │   │
 │  │  • Core Principle Clarifications            • System Knowledge Expansion                 │   │
 │  │  • Architectural Improvements               • Governance Refinements                     │   │
 │  │  • Model Abstraction Improvements           • Runtime Improvements                       │   │
 │  │  • Core Revisions Preserving Fundamental Identity                                       │   │
 │  │                                                                                         │   │
 │  └─────────────────────────────────────────────────────────────────────────────────────────┘   │
 │                                                                                                │
 │  ┌── INSTANCE-SPECIFIC (Belongs to Individual SH Domains) ────────────────────────────────┐   │
 │  │  • User Preferences  • Private Memory  • Private Conversations  • Private Context       │   │
 │  └─────────────────────────────────────────────────────────────────────────────────────────┘   │
 │                                                                                                │
 │  ┌── IMPLEMENTATION-SPECIFIC (May Change Without Changing SH Identity) ───────────────────┐   │
 │  │  • Database Technology  • LLM Provider  • Runtime Platform  • API Implementation         │   │
 │  └─────────────────────────────────────────────────────────────────────────────────────────┘   │
 │                                                                                                │
 └────────────────────────────────────────────────────────────────────────────────────────────────┘


════════════════════════════════════════════════════════════════════════════════════════════════════
LAYER 1 — ARCHITECTURAL / SYSTEM CORE (Global Shared Orchestration Platform)
════════════════════════════════════════════════════════════════════════════════════════════════════

                         ┌──────────────────────────────────────────────┐
                         │           SH CORE ORCHESTRATION              │
                         │   Orchestrates Relationships Among All       │
                         │   Subsystems Per Fundamental Rules           │
                         └──────────────────────┬───────────────────────┘
                                                │
     ┌──────────┬──────────┬──────────┬─────────┼─────────┬──────────┬──────────┬──────────┐
     ▼          ▼          ▼          ▼         ▼         ▼          ▼          ▼          ▼
 ┌────────┐┌────────┐┌────────┐┌────────┐┌─────────┐┌─────────┐┌────────┐┌────────┐┌─────────┐
 │Identity││ State  ││Context ││ Memory ││Knowledge││  Model  ││ Tools  ││Actions ││Continu- │
 │   &    ││        ││        ││        ││         ││Orchestr.││        ││        ││  ity    │
 │Account ││        ││        ││        ││         ││         ││        ││        ││         │
 └────────┘└────────┘└────────┘└────────┘└─────────┘└─────────┘└────────┘└────────┘└─────────┘
     │          │          │          │         │         │          │          │          │
     └──────────┴──────────┴──────────┴─────────┼─────────┴──────────┴──────────┴──────────┘
                                                │
                                                ▼
                         ┌──────────────────────────────────────────────┐
                         │     CROSS-CUTTING: Security • Privacy •      │
                         │     Audit • Provenance • Versioning •        │
                         │     Recovery • Deployment                    │
                         └──────────────────────┬───────────────────────┘
                                                │
                  ┌─────────────────────────────┼─────────────────────────────┐
                  ▼                             ▼                             ▼
   ┌─────────────────────────────┐ ┌───────────────────────────┐ ┌────────────────────────────┐
   │ Security & Privacy Boundary │ │ Audit & Traceability      │ │ Recovery, Backup & Restore │
   │ (Default Deny)              │ │ (Immutable Records)       │ │ (Identity Preservation)    │
   └─────────────────────────────┘ └───────────────────────────┘ └────────────────────────────┘


════════════════════════════════════════════════════════════════════════════════════════════════════
LAYER 2 — SH INSTANCE / EXPERIENTIAL (Isolated Private Domains — Default Deny)
════════════════════════════════════════════════════════════════════════════════════════════════════

          PRIMARY SH (OWNER A)                                    PRIMARY SH (OWNER B)
 ┌──────────────────────────────────────┐                ┌──────────────────────────────────────┐
 │ • SH Identity (SH_ID_A)             │                │ • SH Identity (SH_ID_B)             │
 │ • Account Binding (ACCOUNT_ID_A)    │                │ • Account Binding (ACCOUNT_ID_B)    │
 │ • Private Memory                     │                │ • Private Memory                     │
 │ • Private Context                    │                │ • Private Context                    │
 │ • Private Conversations              │                │ • Private Conversations              │
 │ • Knowledge Base                     │                │ • Knowledge Base                     │
 │ • Journey (Timeline & Milestones)    │                │ • Journey (Timeline & Milestones)    │
 │ • Personality & Directives           │                │ • Personality & Directives           │
 │ • State                              │                │ • State                              │
 │ • Clone Agreement Config             │                │ • Clone Agreement Config             │
 │ • Inheritance / Legacy Config        │                │ • Inheritance / Legacy Config        │
 │ • Capability (Tools / Actions)       │                │ • Capability (Tools / Actions)       │
 └──────────────────────────────────────┘                └──────────────────────────────────────┘
                    ▲                                                       ▲
                    │                                                       │
 ═══════════════════╧════════════════ Privacy Boundary ═════════════════════╧════════════════════
                    │                                                       │
                    │   DEFAULT DENY: Cross-SH Private Data Access = DENY   │
                    │   Shared SH Core ≠ Shared Private Memory              │
                    │   Shared SH Core ≠ Shared Private Context             │
                    │                                                       │
 ═════════════════════════════════════════════════════════════════════════════════════════════════
                    │                                                       │
                    ▼                                                       ▼
          CLONE SH (CLONE_A1)                                     SH-000 (CREATOR'S SH)
 ┌──────────────────────────────────────┐                ┌──────────────────────────────────────┐
 │ • Own SH_ID (CLONE ≠ SOURCE)        │                │ • Creator's SH Instance              │
 │ • Own Runtime Identity               │                │ • Own Private Domain                 │
 │ • Own State & Memory Boundary        │                │ • Own Memory & Context               │
 │ • Own Access Control                 │                │ • Core Governance Authority           │
 │ • Bound by Clone Agreement           │                │   (within defined boundaries)        │
 │ • Owner Approval + Agreement Req.    │                │ • ≠ Private Data Access to Others    │
 │ • Does NOT inherit live memory/state │                │ • NON-CLONABLE                       │
 └──────────────────────────────────────┘                └──────────────────────────────────────┘


════════════════════════════════════════════════════════════════════════════════════════════════════
LAYER 3 — RUNTIME / OPERATIONAL (Intelligence Execution Pipeline)
════════════════════════════════════════════════════════════════════════════════════════════════════

 User Input
   │
   ▼
 Account / Authentication
   │
   ▼
 Authorization / Ownership
   │
   ▼
 SH Identity Resolution
   │
   ▼
 SH State / Session
   │
   ▼
 Conversation
   │
   ▼
 Context Assembly ◄──── Identity Directives
   │              ◄──── Relevant Memory
   │              ◄──── Knowledge / Reference
   │              ◄──── Session Continuity
   ▼
 Model / AI Orchestration
   │
   ▼
 Tools / Actions (if authorized)
   │
   ▼
 Response
   │
   ▼
 Memory Decision
   │
   ▼
 State Update
   │
   ▼
 Audit / Persistence
   │
   ▼
 Continuity


════════════════════════════════════════════════════════════════════════════════════════════════════
LAYER 4 — IMPLEMENTATION / INFRASTRUCTURE (Replaceable — Identity Must Persist)
════════════════════════════════════════════════════════════════════════════════════════════════════
 [ CONSTRAINTS: Zero-Budget • Zero-Hardware-Cost • Mobile-First • Vendor-Agnostic ]

 ┌────────────────────────────────────────────────────────────────────────────────────────────────┐
 │ • App Frontend (Mobile / Web)              • API Gateway & Auth Services                       │
 │ • Backend Services & Edge Workers          • Relational & Key-Value Database                   │
 │ • Vector Store & Indexing (if applicable)  • Object Storage & Local Vault                      │
 │ • LLM Providers (Cloud / Local / Hybrid)   • Secret Management & Security Vault                │
 │ • Queue & Scheduler                        • Monitoring & Observability                        │
 └────────────────────────────────────────────────────────────────────────────────────────────────┘

 RULE: Model / Runtime / Database / Hardware may change or be replaced.
       SH Identity, Ownership, Memory, and Continuity MUST persist.
       Implementation-Specific changes do NOT create a new SH.


════════════════════════════════════════════════════════════════════════════════════════════════════
CANONICAL INVARIANTS (Complete)
════════════════════════════════════════════════════════════════════════════════════════════════════

  IDENTITY & SEPARATION:
  ✓ Model ≠ SH Identity                    ✓ Runtime ≠ SH Identity
  ✓ Database ≠ SH Identity                 ✓ Hardware ≠ SH Identity
  ✓ Account_ID ≠ SH_ID                     ✓ Session_ID ≠ SH_ID
  ✓ Context ≠ Memory                       ✓ Knowledge ≠ Memory
  ✓ Memory ≠ SH Identity

  AUTHORITY & ACCESS:
  ✓ Creator Authority ≠ Private Data Access
  ✓ SH-000 Core Authority ≠ Private Data Access
  ✓ Runtime Access ≠ Ownership
  ✓ System Governance ≠ Omniscient Data Access

  LEARNING & EVOLUTION:
  ✓ Learning ≠ Automatic Core Modification
  ✓ Evolution ≠ New SH Identity            ✓ Migration ≠ New SH Identity
  ✓ Recovery ≠ New SH Identity             ✓ Evolution ≠ Ownership Transfer

  CLONE & INHERITANCE:
  ✓ CLONE_SH ≠ SOURCE_SH                  ✓ CREATOR_SH is NON-CLONABLE
  ✓ USER_SH CLONE = Owner Approval + Agreement
  ✓ INHERITANCE ≠ CLONE                   ✓ INHERITANCE ≠ Identity Transfer

  PRIVACY & ISOLATION:
  ✓ Private Data Isolated by Default       ✓ Default Access = DENY
  ✓ Shared Core ≠ Shared Private Memory    ✓ Shared Core ≠ Shared Private Context

  LIFECYCLE:
  ✓ 1 Email = 1 Account = 1 Primary SH
  ✓ DECOMMISSION ≠ Immediate Permanent Delete
  ✓ Core Evolution requires Governance/Review
  ✓ Core Evolution does NOT replace existing SH Identities


════════════════════════════════════════════════════════════════════════════════════════════════════
SYSTEM LIFECYCLE
════════════════════════════════════════════════════════════════════════════════════════════════════

  CREATION ──► INITIALIZATION ──► OPERATION ──► MEMORY & LEARNING
                                                     │
                                                     ▼
  DECOMMISSION ◄── CONTINUATION ◄── RECOVERY ◄── MIGRATION ◄── EVOLUTION
       │
       ▼
  LEGACY / INHERITANCE / SUCCESSION
  (Authorized transfer of selected experience, knowledge, or journey)
```  
  
---

# 