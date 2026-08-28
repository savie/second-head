SECOND_HEAD_PHASE_MINUS_1_v1.0
Project: SECOND HEAD — SYSTEM BUILD
Document Type: Compiled Phase -1 Planning Artifacts
Version: v1.0
Status: FINAL
Compiled Date: 2026-08-07

================================================================================
DAFTAR DOKUMEN DALAM COMPILASI INI (BERURUTAN)
================================================================================

| No | Nama File Standar | Peran | Status |
|---|---|---|---|
| 0 | IMPLEMENTATION AGENT RULES | Aturan wajib untuk implementation agent | FINAL |
| 0.1 | DOWNSTREAM BLOCKERS REGISTER | Catatan known downstream blockers | FINAL |
| 1 | SECOND_HEAD_CANONICAL_ARTIFACT_MAP_v1.0 | Referensi — Artifact Bridge / Dependency Map | OWNER-FROZEN |
| 2 | SECOND_HEAD_PHASE_MINUS_1_ARCHITECTURE_CHECKLIST_v1.0 | Artefak Phase -1 — Architecture Checklist | OWNER-FROZEN |
| 3 | SECOND_HEAD_PHASE_MINUS_1_MILESTONE_MAPPING_v1.0 | Artefak Phase -1 — Milestone Mapping | FINAL |
| 4 | SECOND_HEAD_PHASE_MINUS_1_TASK_BREAKDOWN_v1.0 | Artefak Phase -1 — Task Breakdown / WBS | FINAL |
| 5 | SECOND_HEAD_PHASE_MINUS_1_SPRINT_PLAN_v1.0 | Artefak Phase -1 — Sprint Plan | FINAL |
| 6 | SECOND_HEAD_PHASE_MINUS_1_RISK_REGISTER_v1.0 | Artefak Phase -1 — Risk Register | FINAL |
| 7 | SECOND_HEAD_PHASE_MINUS_1_RESOURCE_ALLOCATION_PLAN_v1.0 | Artefak Phase -1 — Resource Allocation Plan | FINAL |
| 8 | SECOND_HEAD_PHASE_MINUS_1_BACKLOG_DEFINITION_v1.0 | Artefak Phase -1 — Backlog Definition | FINAL |
| 9 | SECOND_HEAD_PHASE_MINUS_1_TIMELINE_ESTIMATION_v1.0 | Artefak Phase -1 — Timeline Estimation | FINAL |

STATUS CLARIFICATION:

Dokumen compiled ini berstatus FINAL.

Status individual artifacts di dalamnya:

- Artifact 1 (Canonical Artifact Map): OWNER-FROZEN
- Artifact 2 (Architecture Checklist): OWNER-FROZEN
- Artifact 3–9: FINAL

Phase -1 compilation dianggap FINAL setelah Owner melakukan lock pada dokumen compiled ini secara keseluruhan.

================================================================================
[0] IMPLEMENTATION AGENT RULES
================================================================================

Bagian ini berisi aturan wajib yang harus dipatuhi oleh implementation agent saat membaca dan menggunakan Phase -1 compiled document ini.

PHASE -1 IS AN EXECUTION CONTROL DOCUMENT.

It does NOT create canonical authority.

When any Phase -1 artifact conflicts with:

- SH Core Canonical
- Frozen Baseline
- Build Scope
- Implementation Contract
- Implementation Guide
- Execution Strategy

the higher authority wins.

AUTHORITY HIERARCHY (untuk reference):

PRIORITY 1: SH Core Canonical v1.0
PRIORITY 2: Frozen Baseline Phase 01–10
PRIORITY 3: SH Full Build Scope v1.0
PRIORITY 4: SH Full Implementation Contract v1.0
PRIORITY 5: SH Full Implementation Guide v1.0
PRIORITY 6: Canonical Architecture Diagram (Master Diagram)
PRIORITY 7: Execution Strategy v1.0
PRIORITY 8: Dokumen ini (Phase -1 compiled)
PRIORITY 9: Source Code / Repository

IMPLEMENTATION AGENT RULES:

1. Never infer a missing decision.
2. Never convert OPEN / PROPOSED / PARTIALLY READY into FROZEN.
3. Never resolve an OQ silently.
4. Never invent:
   - SH_ID format
   - Creator SH reserved identity
   - Authentication method
   - Technology Stack
   - Physical deployment architecture
   - Memory policy
   - Knowledge trust policy
   - Clone agreement enforcement
   - Model routing policy
   - Backup policy
   - Data portability format
5. If an implementation dependency is BLOCKED: STOP that dependency.
6. If a canonical invariant is unclear: STOP and escalate.
7. If a new requirement appears: DO NOT silently implement it.
8. Classify every new item as one of:
   - existing requirement
   - implementation detail
   - technical debt
   - open decision
   - change request
   - canonical change
9. Only proceed when the applicable gate is satisfied.
10. Logical Artifact ID (A1–A30) is the primary artifact identity. Physical file grouping is only a container.
11. Evidence is mandatory. No evidence = no completion.
12. No gate = no implementation.
13. No frozen decision = no implementation.

================================================================================
[0.1] DOWNSTREAM BLOCKERS REGISTER
================================================================================

Bagian ini mencatat known downstream blockers yang memang sengaja dibuat visible oleh Phase -1. Keberadaan blocker ini BUKAN defect Phase -1. Sebaliknya, Phase -1 melakukan hal yang benar dengan menunjukkan lubang yang belum boleh ditutup dengan halusinasi.

BLOCKER 1: SH_ID / SH-000 (True Missing Information)

Status: MISSING — resolution path melalui Decision Record.

Yang masih missing:

- SH_ID exact format
- Creator SH reserved identifier / SH-000

Implikasi:

- Artifact A5 (Identity Spec) berstatus PARTIALLY READY
- Artifact A1 (Data Model) berstatus PARTIALLY READY
- Identity/data model finalization TIDAK BOLEH dilakukan sebelum keputusan ini dibuat

CATATAN: Ini adalah correct blocker. Implementation agent TIDAK BOLEH menebak format SH_ID atau reserved identity. Phase -1 READY ≠ Identity Implementation READY.

BLOCKER 2: OQ-01 Technology Stack (Largest Downstream Gate)

Status: OPEN — merupakan largest downstream gate.

Affected artifacts:

A7, A8, A9, A13, A14, A15, A16, A20, A25, A26, A28, A29

CATATAN: SH Full stack tetap OQ-01 OPEN. Existing SH Lite stack adalah inherited/reference, BUKAN keputusan final untuk SH Full. Implementation agent TIDAK BOLEH mengasumsikan "existing SH Lite stack sudah ada, jadi pakai saja" tanpa Owner decision.

BLOCKER 3: OQ-07 Backup/Restore Policy

Status: OPEN — memblokir A27 Backup/Recovery.

BLOCKER 4: OQ-08 Data Portability Format

Status: OPEN — memblokir A27 Backup/Recovery.

BLOCKER 5: OQ-02, OQ-03, OQ-04 (Memory/Knowledge)

Status: OPEN — memblokir A1, A3 untuk ART-M3.

BLOCKER 6: OQ-05 Clone Agreement Enforcement

Status: OPEN — memblokir A1, A3, A19 untuk ART-M4.

BLOCKER 7: OQ-06 Model Selection Routing

Status: OPEN — memblokir A3 untuk ART-M2.

PRINSIP: Keberadaan blocker ini adalah known dan expected. Phase -1 tidak gagal karena blocker ini. Phase -1 justru berhasil karena menampilkannya secara eksplisit.

================================================================================
[1/9] SECOND_HEAD_CANONICAL_ARTIFACT_MAP_v1.0
Role: REFERENSI — FROZEN BASELINE ARTIFACT BRIDGE / DEPENDENCY MAP
Source: SECOND_HEAD_COMPILED_DOCUMENTATION_BASELINE_v1.0.md
Status: OWNER-FROZEN
================================================================================

SECOND_HEAD_CANONICAL_ARTIFACT_MAP_v1.0

Project: SECOND HEAD — SYSTEM BUILD
Document Type: Canonical Artifact Bridge / Dependency Map
Version: v1.0
Status: FROZEN — APPROVED OFFICIAL BRIDGE
Authority Level: Non-Canonical / Referential
Post-Reconciliation Acceptance Gate: PASS
Freeze Record: SECOND_HEAD_SIX_DOCUMENT_CROSS_RECONCILIATION_REPORT_v1.0.md

0. DOCUMENT STATUS & AUTHORITY

0.1 Purpose

Dokumen ini adalah Official Bridge antara:

- Canonical source-of-truth (Temporary Baseline, Phase 01–10)
- Build Scope (Build Contract)
- Implementation artifacts yang harus tersedia untuk build execution

Fungsi dokumen ini:

- Memetakan canonical decisions ke artifact yang diperlukan.
- Menetapkan logical artifact inventory.
- Menetapkan source traceability untuk setiap artifact.
- Menetapkan readiness classification.
- Menetapkan dependency navigation.
- Menetapkan stage organization.
- Menetapkan physical grouping principles.

0.2 Authority Position

Dokumen ini BUKAN:

- Source-of-truth canonical.
- Pengganti Temporary Baseline.
- Pengganti Build Scope.
- Authority untuk mengubah locked decisions.
- Authority untuk menambahkan canonical requirements baru.

Dokumen ini ADALAH:

- Bridge / navigation layer.
- Reconciliation reference.
- Artifact dependency map.
- Traceability layer.
- Readiness / status reference.

0.3 Authority Hierarchy

PHASE 01–10 / LOCKED CANONICAL DECISIONS
↓
SECOND_HEAD_TEMPORARY_BASELINE_v1.0.md ← PRIMARY AUTHORITY
↓
SECOND_HEAD_BUILD_SCOPE_v1.0.md
↓
SECOND_HEAD_CANONICAL_ARTIFACT_MAP_v1.0.md ← DOKUMEN INI
↓
SECOND_HEAD_IMPLEMENTATION_SPEC_v1.0.md
↓
SECOND_HEAD_BUILD_VALIDATION_SPEC_v1.0.md
↓
SECOND_HEAD_OPERATIONS_SPEC_v1.0.md
↓
SECOND_HEAD_SIX_DOCUMENT_CROSS_RECONCILIATION_REPORT_v1.0.md

Canonical source selalu menang terhadap dokumen ini.
Dokumen ini tidak boleh mengubah, menambahkan, atau menghapus canonical decisions.

0.4 Reconciliation Corrections Applied

Koreksi berikut telah diterapkan berdasarkan Six-Document Cross-Reconciliation:

| ID | Correction | Source | Applied |
|---|---|---|---|
| C1 | A11 Risk Register Fields — gunakan field exact BUILD_SCOPE §25.2 | Reconciliation Finding | v1.0 |
| C2 | Stage Ordering — DATA MODEL masuk Stage 1 / Core Foundation | Reconciliation Finding | v1.0 |
| C3 | A20 Secrets & Key Management — pisahkan dari operational grouping | Reconciliation Finding | v1.0 |
| C4 | Creator SH Wording — "Governance authority within explicitly defined boundaries" | Reconciliation Finding | v1.0 |
| C5 | Service Boundary — "Physical service deployment architecture remains open" | Reconciliation Finding | v1.0 |
| C6 | Context ≠ Memory — tambahkan explicit invariant ke A3 dan A1 scope | Reconciliation Finding | v1.0 |
| C7 | Memory Pipelines — tambahkan write/retrieval pipelines ke A1 dan A3 | Reconciliation Finding | v1.0 |
| C8 | Prompt Injection Testing — tambahkan ke A21 Test Strategy | Reconciliation Finding | v1.0 |
| C9 | A14 Repository Structure — tandai sebagai DERIVED STRUCTURE | Reconciliation Finding | v1.0 |
| C10 | A24 Performance Baseline — pertahankan sebagai standalone evidence artifact | Reconciliation Finding | v1.0 |

1. ARTIFACT MODEL

1.1 Logical Artifact Count

Total: 30 logical artifacts (A1–A30).

Logical artifact IDs tetap stabil kecuali diubah melalui approved change control.

1.2 Physical Grouping Principle

30 logical artifacts TIDAK berarti harus selalu 30 physical files.

Physical file grouping bersifat:

- DERIVED
- FLEXIBLE
- REVERSIBLE

Logical artifact IDs tetap penting untuk traceability.

CATATAN IMPLEMENTATION AGENT: Logical Artifact ID (A1–A30) adalah primary artifact identity. Physical file grouping hanyalah container. Agent harus selalu berpikir: A-ID = identity of artifact, file = container. Bukan sebaliknya.

1.3 Artifact Classification

Setiap artifact diklasifikasikan sebagai:

| Classification | Meaning |
|---|---|
| CANONICAL | Didukung langsung oleh canonical source |
| DERIVED STRUCTURE | Logically justified tetapi bukan canonical mandatory |
| EVIDENCE ARTIFACT | Post-implementation evidence, bukan design artifact |
| IMPLEMENTATION DECISION PENDING | Memerlukan implementation decision sebelum finalisasi |

2. LOGICAL ARTIFACT INVENTORY

Stage 0 — Governance Foundation

| ID | Artifact Name | Classification | Source Basis |
|---|---|---|---|
| A10 | Decision Records | CANONICAL | BUILD_SCOPE §25.2, OQ-09 |
| A11 | Risk Register | CANONICAL | BUILD_SCOPE §25.2 |
| A12 | Change Control | CANONICAL | BUILD_SCOPE §28, Temporary Baseline |

Stage 1 — Canonical Foundation / Core Design

| ID | Artifact Name | Classification | Source Basis |
|---|---|---|---|
| A1 | Data Model | CANONICAL | Temporary Baseline Phase 04–05, BUILD_SCOPE §10 |
| A3 | System Architecture | CANONICAL | Temporary Baseline Phase 03, BUILD_SCOPE §9 |
| A4 | Security Architecture | CANONICAL | Temporary Baseline Phase 05 §12, BUILD_SCOPE §12 |
| A5 | Identity Spec | CANONICAL | Temporary Baseline Phase 04 §4.1–4.2 |
| A6 | Auth Spec | CANONICAL | Temporary Baseline Phase 04 §4.3–4.4 |
| A19 | Access Control | CANONICAL | Temporary Baseline Phase 05 §12, BUILD_SCOPE §12 |

Stage 2 — Contracts / Implementation Foundation

| ID | Artifact Name | Classification | Source Basis |
|---|---|---|---|
| A2 | API Contracts | CANONICAL | BUILD_SCOPE §29.1, Temporary Baseline Phase 05 |
| A7 | Technology Stack Decision | IMPLEMENTATION DECISION PENDING | BUILD_SCOPE §25.1, OQ-01 |
| A8 | Deployment Operations Plan | CANONICAL | BUILD_SCOPE §29.1, OPERATIONS_SPEC |
| A9 | External Dependency Register | CANONICAL | BUILD_SCOPE §29.1 |
| A15 | Environment Config Spec | CANONICAL | BUILD_SCOPE §29.1, OPERATIONS_SPEC |
| A16 | DB Migration Plan | CANONICAL | BUILD_SCOPE §29.1, Temporary Baseline Phase 05 |

Stage 3 — Security / Privacy

| ID | Artifact Name | Classification | Source Basis |
|---|---|---|---|
| A17 | Security Baseline | CANONICAL | Temporary Baseline Phase 05 §12, BUILD_SCOPE §12 |
| A18 | Privacy Model | CANONICAL | Temporary Baseline Phase 04 §4.7, BUILD_SCOPE §12 |
| A20 | Secrets & Key Management | CANONICAL | BUILD_SCOPE §29.1, OPERATIONS_SPEC |

Stage 4 — Validation / Testing

| ID | Artifact Name | Classification | Source Basis |
|---|---|---|---|
| A21 | Test Strategy | CANONICAL | BUILD_SCOPE §26, BUILD_VALIDATION_SPEC |
| A22 | Test Plan M1 | CANONICAL | BUILD_SCOPE §26, BUILD_VALIDATION_SPEC |
| A23 | Test Evidence Register | CANONICAL | BUILD_VALIDATION_SPEC |

Stage 5 — Operations / Continuity

| ID | Artifact Name | Classification | Source Basis |
|---|---|---|---|
| A25 | Runbooks | CANONICAL | OPERATIONS_SPEC |
| A26 | Monitoring & Observability | CANONICAL | OPERATIONS_SPEC |
| A27 | Backup & Recovery | CANONICAL | OPERATIONS_SPEC, OQ-07 |
| A28 | Incident Response | CANONICAL | OPERATIONS_SPEC |

Stage 6 — Project / Product

| ID | Artifact Name | Classification | Source Basis |
|---|---|---|---|
| A29 | Budget | DERIVED STRUCTURE | BUILD_SCOPE §29.1 |
| A30 | Product Roadmap | DERIVED STRUCTURE | BUILD_SCOPE post-v1.0 activities |

Special Classification

| ID | Artifact Name | Classification | Notes |
|---|---|---|---|
| A13 | Implementation Plan | CANONICAL | BUILD_SCOPE §29.1 |
| A14 | Repository Structure | DERIVED STRUCTURE | Logically justified by version control and build organization needs. Not explicitly listed as mandatory artifact in BUILD_SCOPE §29.1. |
| A24 | Performance Baseline | EVIDENCE ARTIFACT | Post-implementation evidence artifact. Generated from running implemented system. Not a design artifact. |

3. SOURCE TRACEABILITY

3.1 Traceability Principle

Setiap artifact harus dapat ditelusuri kembali ke:

Canonical Source (Temporary Baseline / Phase documents)
↓
Build Scope requirement
↓
Artifact Map mapping
↓
Implementation Artifact

3.2 Traceability Matrix

| Artifact | Primary Source | Secondary Source | Gate Dependency |
|---|---|---|---|
| A1 Data Model | Phase 04 §4.7, Phase 05 | BUILD_SCOPE §10 | ART-M1 |
| A2 API Contracts | Phase 05 | BUILD_SCOPE §29.1 | ART-M1 |
| A3 System Architecture | Phase 03 | BUILD_SCOPE §9 | ART-M2 |
| A4 Security Architecture | Phase 05 §12 | BUILD_SCOPE §12 | ART-M1 |
| A5 Identity Spec | Phase 04 §4.1–4.2 | BUILD_SCOPE §10 | ART-M1 |
| A6 Auth Spec | Phase 04 §4.3–4.4 | BUILD_SCOPE §10 | ART-M1 |
| A7 Tech Stack | OQ-01 | BUILD_SCOPE §25.1 | ART-M1 |
| A8 Deployment Ops | OPERATIONS_SPEC | BUILD_SCOPE §29.1 | ART-M5 |
| A9 External Dependency | BUILD_SCOPE §29.1 | — | ART-M2 |
| A10 Decision Records | OQ-09 | BUILD_SCOPE §25.2 | Before cross-component |
| A11 Risk Register | BUILD_SCOPE §25.2 | — | ART-M1 |
| A12 Change Control | BUILD_SCOPE §28 | Temporary Baseline | ART-M1 |
| A13 Implementation Plan | BUILD_SCOPE §29.1 | — | ART-M1 |
| A14 Repo Structure | DERIVED | Version control needs | ART-M1 |
| A15 Env Config | OPERATIONS_SPEC | BUILD_SCOPE §29.1 | ART-M2 |
| A16 DB Migration | Phase 05 | BUILD_SCOPE §29.1 | ART-M1 |
| A17 Security Baseline | Phase 05 §12 | BUILD_SCOPE §12 | ART-M2 |
| A18 Privacy Model | Phase 04 §4.7 | BUILD_SCOPE §12 | ART-M3 |
| A19 Access Control | Phase 05 §12 | BUILD_SCOPE §12 | ART-M1 |
| A20 Secrets & Key Mgmt | OPERATIONS_SPEC | BUILD_SCOPE §29.1 | ART-M2 |
| A21 Test Strategy | BUILD_VALIDATION_SPEC | BUILD_SCOPE §26 | ART-M1 |
| A22 Test Plan M1 | BUILD_VALIDATION_SPEC | BUILD_SCOPE §26 | ART-M1 |
| A23 Test Evidence Register | BUILD_VALIDATION_SPEC | — | ART-M1 |
| A24 Performance Baseline | EVIDENCE | Running system | ART-M6 |
| A25 Runbooks | OPERATIONS_SPEC | — | ART-M5 |
| A26 Monitoring & Obs | OPERATIONS_SPEC | — | ART-M5 |
| A27 Backup & Recovery | OPERATIONS_SPEC | OQ-07 | ART-M5 |
| A28 Incident Response | OPERATIONS_SPEC | — | ART-M5 |
| A29 Budget | DERIVED | BUILD_SCOPE §29.1 | Post-ART-M1 |
| A30 Product Roadmap | DERIVED | Post-v1.0 | Post-ART-M6 |

CATATAN: Gate dependency di atas menggunakan prefix ART-M1..ART-M6 untuk Artifact Map gate milestone, yang BERBEDA dari project milestone MS-00..MS-07 di Milestone Mapping/Timeline Estimation. Lihat section 10 untuk definisi ART-M1..ART-M6.

4. DEPENDENCY MODEL

4.1 Critical Dependency Chain

CANONICAL BASELINE
│
▼
GOVERNANCE FOUNDATION
│
├── A10 DECISION RECORDS
├── A11 RISK REGISTER
└── A12 CHANGE CONTROL
│
▼
FOUNDATION
│
├── A5 IDENTITY SPEC
├── A6 AUTH SPEC
├── A4 SECURITY ARCHITECTURE
├── A19 ACCESS CONTROL
└── A1 DATA MODEL
⇄
A3 SYSTEM ARCHITECTURE
│
▼
DEPENDENCY CLOSURE
│
▼
FINALIZED ARCHITECTURE
│
▼
IMPLEMENTATION STRUCTURE
│
├── A13 IMPLEMENTATION PLAN
├── A14 REPOSITORY STRUCTURE
├── A15 ENV CONFIG
└── A16 DB MIGRATION PLAN
│
▼
SECURITY / PRIVACY
│
├── A17 SECURITY BASELINE
├── A18 PRIVACY MODEL
└── A20 SECRETS & KEY MANAGEMENT
│
▼
TESTING
│
├── A21 TEST STRATEGY
├── A22 TEST PLAN M1
└── A23 TEST EVIDENCE REGISTER
│
▼
BUILD / RUNTIME
│
├── A8 DEPLOYMENT OPS
├── A9 EXTERNAL DEPENDENCIES
├── A25 RUNBOOKS
├── A26 MONITORING & OBS
├── A27 BACKUP & RECOVERY
└── A28 INCIDENT RESPONSE
│
▼
VALIDATED RUNTIME
│
└── A24 PERFORMANCE BASELINE

4.2 A1 ↔ A3 Dependency Relationship

A1 DATA MODEL
⇄
A3 SYSTEM ARCHITECTURE
↓
DEPENDENCY CLOSURE
↓
DEPENDENT IMPLEMENTATION

A1 dan A3 boleh dikembangkan melalui controlled mutual iteration.

A3 boleh conceptual drafting secara paralel dengan A1.

Namun:

- Dependent implementation tidak boleh berjalan di atas unresolved atau inconsistent data/architecture contract.
- Final dependency closure harus tercapai sebelum dependent implementation dianggap finalized.

4.3 Data Model vs System Architecture Timing

Canonical timing:

- Data Model tersedia sebelum ART-M1.
- Architecture Documentation tersedia sebelum ART-M2.

Corrected interpretation:

- A1 DATA MODEL masuk Stage 1 / Core Foundation.
- A3 SYSTEM ARCHITECTURE dapat mulai secara konseptual paralel dengan A1.
- A3 tidak boleh dianggap fully finalized independently dari canonical data/identity/security constraints.

5. READINESS CLASSIFICATION

5.1 Readiness Categories

| Status | Meaning |
|---|---|
| READY | Dapat langsung dibuat tanpa menunggu keputusan besar |
| PARTIALLY READY | Dapat mulai drafting tetapi belum dapat finalisasi |
| BLOCKED | Menunggu implementation decision atau OQ resolution |
| POST-IMPLEMENTATION | Hanya dapat dibuat setelah running system tersedia |

5.2 Artifact Readiness

| ID | Artifact | Readiness | Blocker |
|---|---|---|---|
| A10 | Decision Records | READY | — |
| A11 | Risk Register | READY | — |
| A12 | Change Control | READY | — |
| A4 | Security Architecture | READY | — |
| A17 | Security Baseline | READY | — |
| A19 | Access Control | READY | — |
| A21 | Test Strategy | READY | — |
| A23 | Test Evidence Register | READY | — |
| A1 | Data Model | PARTIALLY READY | SH_ID format, tech stack |
| A2 | API Contracts | PARTIALLY READY | Tech stack |
| A3 | System Architecture | PARTIALLY READY | Data model closure |
| A5 | Identity Spec | PARTIALLY READY | SH_ID format, Creator SH reserved identity |
| A6 | Auth Spec | PARTIALLY READY | Authentication method |
| A8 | Deployment Ops | PARTIALLY READY | Tech stack |
| A9 | External Dependency | PARTIALLY READY | Tech stack |
| A13 | Implementation Plan | PARTIALLY READY | Tech stack |
| A15 | Env Config | PARTIALLY READY | Tech stack |
| A18 | Privacy Model | PARTIALLY READY | Retention / data portability |
| A20 | Secrets & Key Mgmt | PARTIALLY READY | Tech stack / tooling |
| A25 | Runbooks | PARTIALLY READY | Deployment decisions |
| A26 | Monitoring & Obs | PARTIALLY READY | Tech stack + thresholds |
| A27 | Backup & Recovery | PARTIALLY READY | OQ-07 |
| A28 | Incident Response | PARTIALLY READY | Deployment decisions |
| A30 | Product Roadmap | PARTIALLY READY | Post-v1.0 planning |
| A7 | Tech Stack | BLOCKED | OQ-01 |
| A14 | Repo Structure | BLOCKED | Tech stack |
| A16 | DB Migration Plan | BLOCKED | DB engine / final schema |
| A22 | Test Plan M1 | BLOCKED | A1, A5, A6 closure |
| A29 | Budget | BLOCKED | Tech stack / deployment |
| A24 | Performance Baseline | POST-IMPLEMENTATION | Running system |

CATATAN IMPLEMENTATION AGENT: PARTIALLY READY dan BLOCKED berarti keputusan terkait belum boleh ditebak. Lihat Downstream Blockers Register di compiled document untuk detail.

6. OPEN QUESTIONS MAPPING

6.1 Official Open Questions

| OQ | Description | Gate | Affected Artifacts |
|---|---|---|---|
| OQ-01 | Technology Stack | Before ART-M1 | A7, A8, A9, A13, A14, A15, A16, A20, A25, A26, A28, A29 |
| OQ-02 | Memory Decision Implementation | Before ART-M3 | A1, A3 |
| OQ-03 | Knowledge Ingestion | Before ART-M3 | A1, A3 |
| OQ-04 | Reference Material Trust Promotion | Before ART-M3 | A1, A3 |
| OQ-05 | Clone Agreement Enforcement | Before ART-M4 | A1, A3, A19 |
| OQ-06 | Model Selection Routing | Before ART-M2 | A3 |
| OQ-07 | Backup / Restore Policy | Before ART-M5 | A27 |
| OQ-08 | Data Portability Format | Before ART-M5 | A27 |
| OQ-09 | Decision Record Format | Before cross-component | A10 |

6.2 True Missing Information

Berikut adalah true missing information yang teridentifikasi selama reconciliation:

| Item | Status | Resolution Path |
|---|---|---|
| SH_ID exact format | MISSING | Decision Record setelah OQ-01 |
| Creator SH reserved identifier (SH-000) | MISSING | Decision Record |
| Authentication method wajib untuk v1.0 | MISSING | Decision Record |
| Performance targets numerik | MISSING | A24 setelah running system |
| Alert thresholds numerik | MISSING | A26 setelah deployment |
| Retention policy per data category | MISSING | A18 / A27 |
| Backup frequency dan retention duration | MISSING | A27 setelah OQ-07 |
| Data portability export/import format | MISSING | A27 setelah OQ-08 |
| Project budget | MISSING | A29 setelah OQ-01 |

6.3 Implementation-Level Decisions

Berikut adalah implementation-level decisions yang bukan canonical OQ:

| Item | Status | Resolution Path |
|---|---|---|
| Microservice vs modular monolith | OPEN | Physical deployment architecture |
| Repository folder structure | OPEN | Setelah OQ-01 |
| Migration tooling | OPEN | Setelah OQ-01 |
| Observability tooling | OPEN | Setelah OQ-01 |
| Alert implementation details | OPEN | Setelah deployment |
| On-call routing | OPEN | OPERATIONS_SPEC |

7. STAGE ORGANIZATION

7.1 Stage Definitions

| Stage | Name | Purpose |
|---|---|---|
| 0 | Governance Foundation | Decision records, risk register, change control |
| 1 | Canonical Foundation / Core Design | Identity, security, data model, architecture |
| 2 | Contracts / Implementation Foundation | API, tech stack, deployment, migration |
| 3 | Security / Privacy | Security baseline, privacy model, secrets |
| 4 | Validation / Testing | Test strategy, test plans, evidence |
| 5 | Operations / Continuity | Runbooks, monitoring, backup, incident |
| 6 | Project / Product | Budget, roadmap |

7.2 Stage Ordering

STAGE 0
Governance Foundation
→ STAGE 1
Canonical Foundation / Core Design
A1 DATA MODEL
A3 SYSTEM ARCHITECTURE
A4 SECURITY ARCHITECTURE
A5 IDENTITY SPEC
A6 AUTH SPEC
A19 ACCESS CONTROL
→ STAGE 2
Contracts / Implementation Foundation
A2 API CONTRACTS
A7 TECHNOLOGY STACK
A8 DEPLOYMENT OPS
A9 EXTERNAL DEPENDENCY
A15 ENV CONFIG
A16 DB MIGRATION
→ STAGE 3
Security / Privacy
A17 SECURITY BASELINE
A18 PRIVACY MODEL
A20 SECRETS & KEY MANAGEMENT
→ STAGE 4
Validation / Testing
A21 TEST STRATEGY
A22 TEST PLAN M1
A23 TEST EVIDENCE REGISTER
→ STAGE 5
Operations / Continuity
A25 RUNBOOKS
A26 MONITORING & OBS
A27 BACKUP & RECOVERY
A28 INCIDENT RESPONSE
→ STAGE 6
Project / Product
A29 BUDGET
A30 PRODUCT ROADMAP

7.3 Stage Dependency Rules

- Stage 0 harus selesai sebelum stage lain dimulai.
- Stage 1 A1 dan A3 dapat developed melalui controlled mutual iteration.
- Stage 2 bergantung pada Stage 1 dependency closure.
- Stage 3 dapat mulai paralel dengan Stage 2 untuk security architecture.
- Stage 4 bergantung pada Stage 1 dan Stage 2.
- Stage 5 bergantung pada deployment decisions.
- Stage 6 bergantung pada tech stack dan deployment decisions.

8. PHYSICAL GROUPING PRINCIPLES

8.1 Principle

Physical file grouping bersifat DERIVED dan FLEXIBLE.

Logical artifact IDs (A1–A30) tetap menjadi primary reference.

Physical grouping boleh:

- Menggabungkan beberapa logical artifacts dalam satu file jika terkait erat.
- Memisahkan satu logical artifact menjadi beberapa file jika terlalu besar.
- Mengubah grouping selama traceability tetap terjaga.

8.2 Recommended Physical Grouping

| Group | Artifacts | Rationale |
|---|---|---|
| File Group 01 | A10, A11, A12 | Governance foundation |
| File Group 02 | A1, A3 | Data model + system architecture (controlled mutual iteration) |
| File Group 03 | A4, A5, A6, A19 | Identity + security architecture |
| File Group 04 | A2, A7 | API contracts + tech stack |
| File Group 05 | A8, A9, A13, A15, A16 | Implementation foundation |
| File Group 06a | A7, A9 | Technology + external dependency |
| File Group 06b | A8, A15 | Deployment + environment |
| File Group 06c | A20 | Secrets & key management (separate sensitivity boundary) |
| File Group 07 | A17, A18 | Security + privacy |
| File Group 08 | A21, A22, A23 | Testing |
| File Group 09 | A25, A26, A27, A28 | Operations |
| File Group 10 | A29, A30 | Project / product |
| Standalone | A14 | Repository structure (derived) |
| Standalone | A24 | Performance baseline (evidence artifact) |

8.3 A20 Special Handling

A20 SECRETS & KEY MANAGEMENT tidak boleh dianggap lifecycle-identical dengan Deployment Operations.

A20 memiliki:

- Sensitivity berbeda.
- Audience berbeda.
- Security boundary berbeda.
- Lifecycle berbeda.

A20 dapat berdiri sendiri atau ditempatkan bersama security-sensitive artifacts jika physical grouping diperlukan.

8.4 A24 Special Handling

A24 PERFORMANCE BASELINE adalah:

- POST-IMPLEMENTATION EVIDENCE ARTIFACT.
- Dihasilkan dari running implemented system.
- Bukan design artifact biasa.
- Bukan ordinary design documentation.

A24 menjadi bagian dari evidence package untuk Final Integration Gate.

A24 tidak secara independen menghasilkan `SH v1.0 = INTEGRATION-READY`.

Final Integration Gate tetap merupakan formal acceptance event.

CATATAN: Identitas final A24 adalah "Performance Baseline". Istilah "A24 Lifecycle" yang muncul di reconciliation lama adalah leftover terminology dan telah dibersihkan menjadi "A24 Performance Baseline".

9. CANONICAL CONSTRAINTS & INVARIANTS MAPPING

9.1 Creator SH Constraint

Creator SH adalah governance authority within explicitly defined boundaries.

Explicit constraints:

- Creator SH cannot bypass security boundaries.
- Creator SH cannot automatically access private data of other SHs.
- Creator status is not an authorization bypass.
- Access to private data still requires valid authorization.
- Creator SH cannot violate canonical security and privacy invariants.

Creator SH remains:

- Non-clonable.
- Governance authority.
- Subject to explicit boundaries.

9.2 Service Boundary

Logical service boundaries sudah didefinisikan di Phase 05 §8.

Minimum conceptual services include:

- ACCOUNT SERVICE
- IDENTITY SERVICE
- AUTHENTICATION SERVICE
- AUTHORIZATION SERVICE
- OWNERSHIP SERVICE
- SH SERVICE
- RUNTIME SERVICE
- CONTEXT SERVICE
- MEMORY SERVICE
- KNOWLEDGE SERVICE
- MODEL SERVICE
- TOOL SERVICE
- ACTION SERVICE
- CONVERSATION SERVICE
- CONTINUITY SERVICE
- SECURITY SERVICE
- AUDIT SERVICE
- OBSERVABILITY SERVICE
- RECOVERY SERVICE

Canonical distinction:

- LOGICAL SERVICE BOUNDARIES = already defined.
- PHYSICAL DEPLOYMENT ARCHITECTURE = still open.

Possible physical models:

- Microservice.
- Modular monolith.
- In-process module.

The unresolved item is:

"Physical service deployment architecture"

NOT:

"Exact service boundaries"

9.3 Context ≠ Memory

Canonical invariant:

CONTEXT ≠ MEMORY

Context:

- Request-scoped.
- Temporary.
- Execution-related.
- Not automatically persistent.

Memory:

- Persistent according to policy.
- Governed by memory write pipeline.
- Subject to relevance, confidence, policy, audit, and persistence controls.

Mapping:

- A3 SYSTEM ARCHITECTURE → Context isolation boundary, Context is request-scoped, Context is not memory.
- A1 DATA MODEL → Separation of context and persistent memory, Memory lifecycle and persistence semantics.

9.4 Memory Pipelines

Memory Write Pipeline:

INTERACTION
→ CANDIDATE
→ RELEVANCE
→ CONFIDENCE
→ POLICY
→ WRITE
→ PERSIST
→ AUDIT

Memory Retrieval Pipeline:

QUERY
→ RETRIEVE
→ FILTER
→ RANK
→ VALIDATE
→ CONTEXT

Primary artifact mapping:

- A1 DATA MODEL
- A3 SYSTEM ARCHITECTURE

Not primarily A27 BACKUP & RECOVERY.

A27 focuses on recovery, restoration, backup, and continuity of memory/data.

9.5 Prompt Injection Boundary

Canonical principle:

External content is untrusted by default.

Prompt injection boundary adalah testable security requirement.

Mapping:

- A4 SECURITY ARCHITECTURE
- A17 SECURITY BASELINE
- A19 ACCESS CONTROL
- A21 TEST STRATEGY

A21 must explicitly include:

- Prompt injection boundary testing.
- Untrusted external content handling.
- Trust boundary enforcement.

9.6 Risk Register Fields

A11 RISK REGISTER harus menggunakan field exact BUILD_SCOPE §25.2:

- RISK_ID
- Description
- Classification (HIGH / MEDIUM / LOW)
- Affected Component
- Milestone / Gate Impact
- Mitigation Plan
- Residual Risk
- Owner
- Status (OPEN / MITIGATING / RESOLVED / ACCEPTED)

Map tidak boleh mengganti canonical fields dengan:

- probability
- severity
- affected artifact

Jika field tambahan diperlukan, harus ditandai sebagai DERIVED STRUCTURE / optional extension, bukan canonical requirement.

10. MILESTONE GATE MAPPING

CATATAN: Milestone gate di Artifact Map ini menggunakan identifier ART-M1..ART-M6, yang BERBEDA dari project milestone MS-00..MS-07 di Milestone Mapping dan Timeline Estimation. Kedua sistem identifier ini merepresentasikan semantic layer yang berbeda:

- ART-M1..ART-M6: Artifact Map gate milestones (ketersediaan artifact untuk build).
- MS-00..MS-07: Project milestones (fase eksekusi proyek).

Jangan mencampuradukkan keduanya. Saat membaca "A1 → ART-M1", artinya A1 harus tersedia sebelum Artifact Map gate ART-M1. Saat membaca "MS-02 Identity Locked", artinya project milestone MS-02.

10.1 Artifact Map Milestone Definitions

| Milestone | Gate Condition |
|---|---|
| ART-M1 | Foundation — Identity, Auth, Security, Data Model tersedia |
| ART-M2 | Core Architecture — Runtime, Context, Model orchestration |
| ART-M3 | Memory / Knowledge — Memory pipeline, Knowledge ingestion |
| ART-M4 | Tools / Actions / Clone — Tool execution, Clone agreement |
| ART-M5 | Security / Operations — Backup, Recovery, Monitoring |
| ART-M6 | Performance / Evidence — Performance baseline, Final Integration Gate |

10.2 Artifact → Milestone Mapping

| Artifact | Required Before |
|---|---|
| A1 Data Model | ART-M1 |
| A3 System Architecture | ART-M2 |
| A4 Security Architecture | ART-M1 |
| A5 Identity Spec | ART-M1 |
| A6 Auth Spec | ART-M1 |
| A7 Tech Stack | ART-M1 |
| A19 Access Control | ART-M1 |
| A21 Test Strategy | ART-M1 |
| A2 API Contracts | ART-M2 |
| A18 Privacy Model | ART-M3 |
| A27 Backup & Recovery | ART-M5 |
| A24 Performance Baseline | ART-M6 |

11. BRIDGE INTEGRITY RULES

11.1 Rule 1 — No Authority Inversion

CANONICAL_ARTIFACT_MAP tidak boleh override:

- TEMPORARY_BASELINE.
- Phase decisions.
- BUILD_SCOPE.
- Locked canonical invariants.

11.2 Rule 2 — No False Canonicalization

Derived structures tidak boleh direpresentasikan sebagai locked decisions.

Contoh derived structures:

- Physical file grouping.
- Repository structure.
- Specific service deployment model.
- Additional Risk Register fields.
- Implementation tooling.

11.3 Rule 3 — No False Gaps

Map tidak boleh mengklaim sesuatu unresolved ketika sudah canonically defined.

Known false gap removed:

- Logical service boundaries.

Remaining open:

- Physical deployment architecture.

11.4 Rule 4 — True Missing Information Must Remain Visible

True missing information tidak boleh silently invented oleh Map.

11.5 Rule 5 — Open Questions Must Not Be Promoted to Canonical Decisions

Canonical OQs:

OQ-01 through OQ-09 tetap canonical sebagaimana didefinisikan BUILD_SCOPE.

Additional items identified during review harus diklasifikasikan sebagai:

- True missing information.
- Implementation-level decisions.

Bukan canonical OQ baru tanpa validasi.

12. NEXT EXECUTION ORDER

Recommended sequence setelah dokumen ini frozen:

STEP 1
Finalize CANONICAL_ARTIFACT_MAP_v1.0 text.

STEP 2
Run final consistency check against:
TEMPORARY_BASELINE
Phase 01–08 canonical outputs
BUILD_SCOPE

STEP 3
Freeze CANONICAL_ARTIFACT_MAP_v1.0 as:
RECONCILIATION BASELINE
APPROVED WITH CORRECTIONS

STEP 4
Create / finalize A10 DECISION RECORD format.
This is important because future open decisions need a canonical recording mechanism.

STEP 5
Draft the immediately available artifacts:
Priority group:
A4 Security Architecture
A17 Security Baseline
A19 Access Control
A21 Test Strategy
A23 Test Evidence Register
A11 Risk Register
A12 Change Control
A10 Decision Records

STEP 6
Resolve OQ-01 Technology Stack.
This is the largest downstream gate.

STEP 7
Resolve true missing identity decisions:
SH_ID format
Creator SH reserved identifier / SH-000
These must be formalized through appropriate decision/change-control mechanisms before identity/data model finalization.

STEP 8
Continue artifact generation according to dependency graph.

13. DOCUMENT CONTROL

Document: SECOND_HEAD_CANONICAL_ARTIFACT_MAP_v1.0.md
Version: v1.0
Status: FROZEN — APPROVED OFFICIAL BRIDGE
Post-Reconciliation Acceptance Gate: PASS
Freeze Meaning: Frozen for build reference; does not imply production readiness.

END OF SECOND_HEAD_CANONICAL_ARTIFACT_MAP_v1.0

================================================================================
[2/9] SECOND_HEAD_PHASE_MINUS_1_ARCHITECTURE_CHECKLIST_v1.0
Role: ARTEFAK PHASE -1 — ARCHITECTURE CHECKLIST
Source: Phase -1 Planning
Status: OWNER-FROZEN
================================================================================

SECOND_HEAD_PHASE_MINUS_1_ARCHITECTURE_CHECKLIST_v1.0

Project: SECOND HEAD — SYSTEM BUILD
Document Type: Phase -1 Artifact — Architecture Checklist
Version: v1.0
Status: FROZEN
Authority: Derived from CANONICAL_ARTIFACT_MAP_v1.0 + TEMPORARY_BASELINE + BUILD_SCOPE

1. CHECKLIST PURPOSE & USAGE

1.1 When to Use

Checklist ini wajib dijalankan SEBELUM implementasi komponen apa pun dimulai.

Setiap komponen yang akan diimplementasi harus melewati seluruh section berikut.

Jika ada satu item yang TIDAK BISA dijawab "YA" atau "TERVERIFIKASI", implementasi komponen tersebut TIDAK BOLEH dimulai sampai issue diselesaikan.

1.2 Who Executes

- Implementation Agent executes the checklist.
- Owner / Gatekeeper reviews and approves the result.
- Jika ada section yang gagal, implementasi harus berhenti sampai failure diselesaikan.

1.3 Checklist Result

Setiap section menghasilkan salah satu dari:

- PASS — Seluruh item terverifikasi. Lanjut.
- PASS WITH RISK — Seluruh item terverifikasi, tetapi ada risiko yang harus dicatat dan dimonitor.
- BLOCKED — Ada item yang belum dapat diselesaikan karena dependency atau open question. Tunda sampai resolved.
- FAILED — Ada item yang gagal. Berhenti. Resolve sebelum lanjut.

1.4 Authority Hierarchy

PRIORITY 1: SH Core Canonical
PRIORITY 2: Frozen Baseline Phase 01–10
PRIORITY 3: Build Scope
PRIORITY 4: Implementation Contract
PRIORITY 5: Implementation Guide
PRIORITY 6: Execution Strategy
PRIORITY 7: Canonical Artifact Map

Jika ada konflik, priority yang lebih tinggi berlaku.

1.5 Authority Verification Rule

Komponen yang akan diimplementasi harus memiliki authority yang memadai sesuai klasifikasi perubahan.

Untuk perubahan Major / Breaking / Canonical:

- Harus dapat ditelusuri ke minimal satu authority document.
- Tidak boleh dibuat tanpa dasar authority.

Untuk perubahan Minor:

- Tidak perlu muncul eksplisit di seluruh authority document.
- Cukup memiliki justification teknis yang wajar.
- Tetap harus dicatat dalam Change Log.

Klasifikasi perubahan mengikuti Section J (Change Control).

2. SECTION A — AUTHORITY VERIFICATION

Verifikasi bahwa komponen yang akan dibangun memiliki dasar authority yang memadai.

| # | Check | Status |
|---|---|---|
| A-1 | Apakah komponen ini ada di SH Core Canonical? | ☐ YA / ☐ TIDAK / ☐ N/A |
| A-2 | Apakah komponen ini ada di Build Scope? | ☐ YA / ☐ TIDAK / ☐ N/A |
| A-3 | Apakah komponen ini ada di Implementation Contract? | ☐ YA / ☐ TIDAK / ☐ N/A |
| A-4 | Apakah komponen ini ada di Implementation Guide? | ☐ YA / ☐ TIDAK / ☐ N/A |
| A-5 | Apakah komponen ini ada di Execution Strategy? | ☐ YA / ☐ TIDAK / ☐ N/A |
| A-6 | Apakah ada referensi section/clause spesifik? | ☐ YA / ☐ TIDAK |
| A-7 | Jika referensi: [tuliskan referensi] | _________________ |
| A-8 | Jika tidak ada di authority, apakah ini Minor Change? | ☐ YA / ☐ TIDAK |

Authority Verification Decision:

Jika komponen ada di minimal satu authority document:
→ Lanjut ke Section B.

Jika komponen tidak ada di authority document:
→ Jika Minor Change: boleh lanjut, catat di Change Log.
→ Jika bukan Minor Change: BLOCKED. Harus mendapat Owner Decision.

Minor Change Examples

Yang dapat diklasifikasikan sebagai Minor Change:

- Bug fix kecil.
- Logging tambahan.
- Monitoring tambahan.
- Refactor internal tanpa mengubah behavior.
- Penamaan variabel.
- Formatting.
- Comment tambahan.

Yang TIDAK boleh diklasifikasikan sebagai Minor Change:

- Perubahan boundary.
- Perubahan invariant.
- Perubahan ownership.
- Perubahan security model.
- Penambahan komponen baru yang mengubah arsitektur.
- Perubahan data model.

3. SECTION B — ARCHITECTURE VERIFICATION

Verifikasi bahwa komponen tidak melanggar arsitektur yang telah ditetapkan.

3.1 Component Boundary

| # | Check | Status |
|---|---|---|
| B-1 | Apakah komponen ini memiliki tanggung jawab yang jelas? | ☐ YA / ☐ TIDAK |
| B-2 | Apakah komponen ini memiliki boundary yang jelas? | ☐ YA / ☐ TIDAK |
| B-3 | Apakah komponen ini menghindari mengambil tanggung jawab dari domain lain? | ☐ YA / ☐ TIDAK |
| B-4 | Apakah komponen ini berkomunikasi hanya melalui interface yang telah ditentukan? | ☐ YA / ☐ TIDAK |
| B-5 | Apakah komponen ini menghindari cross-domain shortcut? | ☐ YA / ☐ TIDAK |

3.2 Architecture Drift Assessment

| # | Check | Drift Score |
|---|---|---|
| B-6 | Apakah komponen ini match dengan definisi arsitektur di source documents? | ☐ 0 / ☐ 1 / ☐ 2 / ☐ 3 / ☐ Critical |
| B-7 | Apakah komponen ini memperkenalkan konsep arsitektur baru yang tidak ada di source? | ☐ 0 / ☐ 1 / ☐ 2 / ☐ 3 / ☐ Critical |
| B-8 | Jika B-6 atau B-7 bukan 0, apakah ini legitimate implementation detail atau new canonical concept? | ☐ Implementation Detail / ☐ New Canonical Concept |

Drift Score Definitions:

- 0 = No Drift. Tidak ada deviasi.
- 1 = Documentation Only. Deviasi hanya pada dokumentasi.
- 2 = Implementation Impact. Deviasi mempengaruhi implementasi.
- 3 = Architecture Impact. Deviasi mengubah arsitektur.
- Critical = Canonical Violation. Pelanggaran canonical invariant.

Decision:

- Jika B-8 = New Canonical Concept: BLOCKED. Eskalasi ke Owner.
- Jika B-6 atau B-7 = 3 atau Critical: FAILED. Resolve sebelum lanjut.
- Jika B-6 atau B-7 = 1 atau 2: PASS WITH RISK. Catat dan monitor.

4. SECTION C — CANONICAL INVARIANT VERIFICATION

Verifikasi bahwa komponen tidak melanggar canonical invariant.

4.1 Verification Method

Checklist ini harus memverifikasi seluruh Canonical Invariant yang berlaku pada versi Canonical yang menjadi authority.

Gate bergantung pada: "Seluruh Canonical Invariant yang terdefinisi dalam versi Canonical yang berlaku pada saat checklist ini dijalankan."

Jika Canonical bertambah INV baru, checklist ini tetap berlaku tanpa perlu edit. INV baru otomatis termasuk dalam scope verifikasi.

4.2 Verification Checklist

| # | Check | Status |
|---|---|---|
| C-1 | Apakah seluruh Canonical Invariant yang berlaku telah diverifikasi? | ☐ TERJAGA / ☐ TIDAK |
| C-2 | Apakah ada invariant yang berpotensi terlanggar oleh komponen ini? | ☐ TIDAK ADA / ☐ ADA |
| C-3 | Jika ADA, invariant mana? | _________________ |
| C-4 | Jika ADA, apakah ada mitigation? | ☐ YA / ☐ TIDAK |
| C-5 | Jika ADA dan TIDAK ada mitigation, apakah Owner telah approve? | ☐ YA / ☐ TIDAK |

4.3 Invariant Categories

Identity & Separation:

- Model ≠ SH Identity
- Runtime ≠ SH Identity
- Database ≠ SH Identity
- Hardware ≠ SH Identity
- Account_ID ≠ SH_ID
- Session_ID ≠ SH_ID
- Context ≠ Memory
- Knowledge ≠ Memory
- Memory ≠ SH Identity

Authority & Access:

- Creator Authority ≠ Private Data Access
- SH-000 Core Authority ≠ Private Data Access
- Runtime Access ≠ Ownership
- System Governance ≠ Omniscient Data Access

Learning & Evolution:

- Learning ≠ Automatic Core Modification
- Evolution ≠ New SH Identity
- Migration ≠ New SH Identity
- Recovery ≠ New SH Identity
- Evolution ≠ Ownership Transfer

Clone & Inheritance:

- CLONE_SH ≠ SOURCE_SH
- CREATOR_SH is NON-CLONABLE
- USER_SH CLONE = Owner Approval + Agreement
- INHERITANCE ≠ CLONE
- INHERITANCE ≠ Identity Transfer

Privacy & Isolation:

- Private Data Isolated by Default
- Default Access = DENY
- Shared Core ≠ Shared Private Memory
- Shared Core ≠ Shared Private Context

Lifecycle:

- 1 Email = 1 Account = 1 Primary SH
- DECOMMISSION ≠ Immediate Permanent Delete
- Core Evolution requires Governance/Review
- Core Evolution does NOT replace existing SH Identities

4.4 Decision

Jika seluruh invariant TERJAGA:
→ PASS. Lanjut ke Section D.

Jika ada invariant TIDAK TERJAGA:
→ FAILED. Berhenti. Resolve sebelum lanjut.

Jika ada invariant yang berpotensi terlanggar tetapi ada mitigation dan Owner approve:
→ PASS WITH RISK. Catat mitigation dan monitor.

5. SECTION D — IMPLEMENTATION READINESS VERIFICATION

Verifikasi bahwa komponen siap untuk diimplementasi.

| # | Check | Status |
|---|---|---|
| D-1 | Apakah komponen ini dapat dibuat sebagai Vertical Slice? | ☐ YA / ☐ TIDAK |
| D-2 | Apakah komponen ini memiliki Definition of Done? | ☐ YA / ☐ TIDAK |
| D-3 | Apakah komponen ini memiliki Acceptance Criteria? | ☐ YA / ☐ TIDAK |
| D-4 | Apakah komponen ini memiliki Testing Plan? | ☐ YA / ☐ TIDAK |
| D-5 | Apakah komponen ini memiliki Evidence Plan? | ☐ YA / ☐ TIDAK |
| D-6 | Apakah dependency komponen ini sudah selesai? | ☐ YA / ☐ TIDAK |
| D-7 | Apakah ada Open Question yang memblokir komponen ini? | ☐ YA / ☐ TIDAK |
| D-8 | Jika ada OQ blocker: [tuliskan OQ] | _________________ |
| D-9 | Apakah Decision untuk komponen ini sudah FROZEN? | ☐ YA / ☐ TIDAK / ☐ N/A |
| D-10 | Apakah Dependency Health Status untuk komponen ini 🟢 Healthy? | ☐ YA / ☐ TIDAK / ☐ N/A |

Decision Lifecycle Reference

Komponen tidak boleh diimplementasi jika Decision belum FROZEN.

Lifecycle:

OPEN → PROPOSED → APPROVED → FROZEN → IMPLEMENTED

Jika Decision masih OPEN / PROPOSED / APPROVED:
→ BLOCKED. Tunggu sampai FROZEN.

Jika Decision sudah FROZEN:
→ Lanjut.

Dependency Health Status Reference

- 🟢 Healthy = On track. Tidak ada issue.
- 🟡 At Risk = Potensi issue teridentifikasi. Mitigasi sedang berjalan.
- 🔴 Blocked = Tidak dapat proceed. Memerlukan intervensi.

Jika Dependency Health = 🔴 Blocked:
→ BLOCKED. Tunggu sampai resolved.

Jika Dependency Health = 🟡 At Risk:
→ PASS WITH RISK. Catat dan monitor.

Decision

Jika seluruh item terverifikasi:
→ PASS. Lanjut ke Section E.

Jika ada dependency blocked:
→ BLOCKED. Tunggu.

Jika ada item yang gagal:
→ FAILED. Resolve.

6. SECTION E — SECURITY VERIFICATION

Verifikasi bahwa komponen memenuhi security requirement.

| # | Check | Status |
|---|---|---|
| E-1 | Apakah komponen ini menerapkan DEFAULT DENY? | ☐ YA / ☐ TIDAK / ☐ N/A |
| E-2 | Apakah komponen ini menjaga Privacy Boundary? | ☐ YA / ☐ TIDAK / ☐ N/A |
| E-3 | Apakah komponen ini menjaga Owner Isolation? | ☐ YA / ☐ TIDAK / ☐ N/A |
| E-4 | Apakah komponen ini memiliki Audit Trail? | ☐ YA / ☐ TIDAK / ☐ N/A |
| E-5 | Apakah komponen ini tidak melemahkan security boundary yang sudah ada? | ☐ YA / ☐ TIDAK |
| E-6 | Apakah komponen ini tidak membuka cross-SH access? | ☐ YA / ☐ TIDAK |
| E-7 | Apakah external content diperlakukan sebagai untrusted data? | ☐ YA / ☐ TIDAK / ☐ N/A |
| E-8 | Apakah prompt injection boundary testing termasuk dalam test plan? | ☐ YA / ☐ TIDAK / ☐ N/A |

Decision

Jika seluruh item terverifikasi:
→ PASS. Lanjut ke Section F.

Jika E-5 = TIDAK:
→ FAILED. Berhenti. Security regression tidak boleh diabaikan.

Jika E-6 = TIDAK:
→ FAILED. Berhenti. Cross-SH access violation tidak boleh diabaikan.

7. SECTION F — TESTING & VALIDATION VERIFICATION

Verifikasi bahwa komponen memiliki testing dan validation yang memadai.

7.1 Testing Categories

Setiap komponen harus memiliki testing dalam kategori berikut:

| # | Category | Status | Notes |
|---|---|---|---|
| F-1 | Functional Test | ☐ YA / ☐ TIDAK / ☐ N/A | |
| F-2 | Integration Test | ☐ YA / ☐ TIDAK / ☐ N/A | |
| F-3 | Security Test | ☐ YA / ☐ TIDAK / ☐ N/A | |
| F-4 | Regression Test | ☐ YA / ☐ TIDAK / ☐ N/A | |
| F-5 | Canonical Compliance Test | ☐ YA / ☐ TIDAK / ☐ N/A | |

7.2 Testing Category Definitions

Functional Test:
Test fungsi komponen secara individual.

Integration Test:
Test integrasi antar komponen.

Security Test:
Test security boundary, termasuk:

- Cross-SH isolation test
- Prompt injection test
- Access control test

Regression Test:
Test bahwa perubahan tidak merusak fungsi yang sudah ada.

Canonical Compliance Test:
Test bahwa komponen mematuhi canonical invariant.

7.3 Validation Evidence

| # | Check | Status |
|---|---|---|
| F-6 | Apakah validation evidence terdefinisi? | ☐ YA / ☐ TIDAK |
| F-7 | Apakah validation evidence traceable ke requirement? | ☐ YA / ☐ TIDAK |
| F-8 | Apakah validation evidence reproducible? | ☐ YA / ☐ TIDAK |
| F-9 | Apakah setiap Invariant ID memiliki minimal satu test yang memverifikasi? | ☐ YA / ☐ TIDAK / ☐ N/A |

Decision

Jika seluruh item terverifikasi:
→ PASS. Lanjut ke Section G.

Jika ada item yang gagal:
→ FAILED. Resolve.

8. SECTION G — DOCUMENTATION VERIFICATION

Verifikasi bahwa komponen akan terdokumentasi dengan benar.

| # | Check | Status |
|---|---|---|
| G-1 | Apakah komponen ini memerlukan ADR? | ☐ YA / ☐ TIDAK |
| G-2 | Jika YA, ADR Category: | ☐ Architecture / ☐ Security / ☐ Governance / ☐ Performance / ☐ Privacy / ☐ Infrastructure / ☐ Developer Experience |
| G-3 | Apakah komponen ini berpotensi menghasilkan Technical Debt? | ☐ YA / ☐ TIDAK |
| G-4 | Jika YA, Technical Debt harus dicatat di Register dengan "Must Close Before" target. | ☐ YA / ☐ TIDAK |
| G-5 | Apakah komponen ini memerlukan Evidence? | ☐ YA / ☐ TIDAK |
| G-6 | Apakah komponen ini memerlukan update ke dokumentasi existing? | ☐ YA / ☐ TIDAK |
| G-7 | Apakah komponen ini traceable ke authority? | ☐ YA / ☐ TIDAK |

Decision

Jika G-1 = YA:
→ ADR harus dibuat SEBELUM implementasi.

Jika G-3 = YA:
→ Technical Debt harus dicatat di Register.

Jika G-5 = YA:
→ Evidence Plan harus tersedia SEBELUM implementasi.

9. SECTION H — CHANGE IMPACT & DRIFT ASSESSMENT

9.1 Change Impact Checklist

Apakah perubahan ini mempengaruhi:

| Area | Impact? |
|---|---|
| Database | ☐ YA / ☐ TIDAK |
| API | ☐ YA / ☐ TIDAK |
| RLS | ☐ YA / ☐ TIDAK |
| Memory | ☐ YA / ☐ TIDAK |
| Context | ☐ YA / ☐ TIDAK |
| Journey | ☐ YA / ☐ TIDAK |
| Clone | ☐ YA / ☐ TIDAK |
| Inheritance | ☐ YA / ☐ TIDAK |
| Recovery | ☐ YA / ☐ TIDAK |
| Runtime | ☐ YA / ☐ TIDAK |
| Tool | ☐ YA / ☐ TIDAK |
| Model | ☐ YA / ☐ TIDAK |
| Governance | ☐ YA / ☐ TIDAK |
| Documentation | ☐ YA / ☐ TIDAK |

9.2 Impact Classification

| Jumlah Area Terdampak | Klasifikasi | Action |
|---|---|---|
| 0 | No Impact | Proceed |
| 1–3 | Low Impact | Review + document |
| 4–7 | Medium Impact | Architecture Review |
| 8–14 | High Impact | STOP + Owner Decision |

9.3 Architecture Drift Score

| # | Check | Drift Score |
|---|---|---|
| H-1 | Apakah perubahan ini menyebabkan drift dari arsitektur yang telah ditetapkan? | ☐ 0 / ☐ 1 / ☐ 2 / ☐ 3 / ☐ Critical |
| H-2 | Apakah perubahan ini melanggar canonical invariant? | ☐ 0 / ☐ 1 / ☐ 2 / ☐ 3 / ☐ Critical |

Decision

Jika H-1 atau H-2 = Critical:
→ FAILED. STOP. Owner Decision diperlukan.

Jika H-1 atau H-2 = 3:
→ BLOCKED. Architecture Review diperlukan sebelum lanjut.

Jika H-1 atau H-2 = 1 atau 2:
→ PASS WITH RISK. Catat dan monitor.

10. SECTION I — BACKWARD COMPATIBILITY CHECK

| # | Check | Status | Notes |
|---|---|---|---|
| I-1 | Apakah perubahan ini membuat data lama tidak kompatibel? | ☐ YA / ☐ TIDAK | |
| I-2 | Apakah migration diperlukan? | ☐ YA / ☐ TIDAK | |
| I-3 | Apakah rollback tersedia? | ☐ YA / ☐ TIDAK | |
| I-4 | Apakah export lama masih valid? | ☐ YA / ☐ TIDAK | |
| I-5 | Apakah API lama rusak? | ☐ YA / ☐ TIDAK | |

Decision

Jika seluruh TIDAK:
→ PASS. Proceed.

Jika ada YA:
→ PASS WITH RISK. Review + migration plan + rollback plan.

Jika ada YA tanpa rollback:
→ BLOCKED. Owner Decision diperlukan.

11. SECTION J — CHANGE CONTROL

11.1 Change Classification

| Classification | Definisi | Action |
|---|---|---|
| Minor | Perubahan kecil, tidak mempengaruhi arsitektur/invariant | Document saja |
| Major | Mempengaruhi implementasi, tidak mengubah arsitektur/invariant | Change Control + Review |
| Breaking | Mengubah interface/behavior yang sudah ada | Change Control + Migration + Rollback |
| Canonical | Mengubah invariant/arsitektur fundamental | Change Control + Owner Decision + Governance Review |

11.2 Decision Lifecycle

OPEN → PROPOSED → APPROVED → FROZEN → IMPLEMENTED

12. SECTION K — FINAL GATE

12.1 Summary

| Section | Result |
|---|---|
| A — Authority Verification | ☐ PASS / ☐ PASS WITH RISK / ☐ BLOCKED / ☐ FAILED |
| B — Architecture Verification | ☐ PASS / ☐ PASS WITH RISK / ☐ BLOCKED / ☐ FAILED |
| C — Canonical Invariant Verification | ☐ PASS / ☐ PASS WITH RISK / ☐ BLOCKED / ☐ FAILED |
| D — Implementation Readiness | ☐ PASS / ☐ PASS WITH RISK / ☐ BLOCKED / ☐ FAILED |
| E — Security Verification | ☐ PASS / ☐ PASS WITH RISK / ☐ BLOCKED / ☐ FAILED |
| F — Testing & Validation | ☐ PASS / ☐ PASS WITH RISK / ☐ BLOCKED / ☐ FAILED |
| G — Documentation Verification | ☐ PASS / ☐ PASS WITH RISK / ☐ BLOCKED / ☐ FAILED |
| H — Change Impact & Drift | ☐ PASS / ☐ PASS WITH RISK / ☐ BLOCKED / ☐ FAILED |
| I — Backward Compatibility | ☐ PASS / ☐ PASS WITH RISK / ☐ BLOCKED / ☐ FAILED |
| J — Change Control | ☐ PASS / ☐ PASS WITH RISK / ☐ BLOCKED / ☐ FAILED |

Final Gate Outcomes:

- Implementation Approved
- Implementation Approved with Constraints
- Architecture Review Required
- Owner Decision Required
- Canonical Governance Required

13. SECTION L — VERSION COMPATIBILITY

| Authority | Version | Status |
|---|---|---|
| CAN (SH Core Canonical) | _________ | ☐ ACTIVE / ☐ SUPERSEDED |
| CON (Implementation Contract) | _________ | ☐ ACTIVE / ☐ SUPERSEDED |
| GUI (Implementation Guide) | _________ | ☐ ACTIVE / ☐ SUPERSEDED |
| EXE (Execution Strategy) | _________ | ☐ ACTIVE / ☐ SUPERSEDED |
| BSC (Build Scope) | _________ | ☐ ACTIVE / ☐ SUPERSEDED |
| DEP (Dependency Map) | _________ | ☐ ACTIVE / ☐ SUPERSEDED |
| BSL (Frozen Baseline) | _________ | ☐ ACTIVE / ☐ SUPERSEDED |
| ART (Canonical Artifact Map) | _________ | ☐ ACTIVE / ☐ SUPERSEDED |

14. DOCUMENT CONTROL

Document: SECOND_HEAD_PHASE_MINUS_1_ARCHITECTURE_CHECKLIST_v1.0
Version: v1.0
Status: FROZEN
Authority Level: Derived Checklist (Below CANONICAL_ARTIFACT_MAP)

END OF SECOND_HEAD_PHASE_MINUS_1_ARCHITECTURE_CHECKLIST_v1.0

================================================================================
[3/9] SECOND_HEAD_PHASE_MINUS_1_MILESTONE_MAPPING_v1.0
Role: ARTEFAK PHASE -1 — MILESTONE MAPPING
Source: Phase -1 Planning
Status: FINAL
================================================================================

SECOND_HEAD_PHASE_MINUS_1_MILESTONE_MAPPING_v1.0

Project: SECOND HEAD — SYSTEM BUILD
Document Type: Derived Operational Artifact (Milestone Mapping)
Version: v1.0
Status: FINAL
Authority Level: Derived Operational Document (Below Execution Strategy)
Target: SH Full Implementation Execution

0. DOCUMENT STATUS & AUTHORITY

0.1 Purpose

Dokumen ini adalah Milestone Mapping untuk pembangunan SH Full.

Dokumen ini menerjemahkan Seven-Phase Execution Roadmap dari `SECOND_HEAD_SH_FULL_EXECUTION_STRATEGY_v1.0.md` menjadi titik-titik pencapaian (milestones) yang terukur, memiliki Definition of Done (DoD) yang eksplisit, dan gerbang validasi (gates) yang wajib dilewati.

Dokumen ini BUKAN:

- Canonical source baru.
- Pengganti Execution Strategy, Build Scope, atau Implementation Contract.
- Dokumen yang mengubah requirement, arsitektur, atau invariant.

0.2 Authority Hierarchy

- SH Core Canonical v1.0
- Frozen Baseline Phase 01–10
- SH Full Build Scope v1.0
- SH Full Implementation Contract v1.0
- SH Full Implementation Guide v1.0
- SH Full Execution Strategy v1.0
- Dokumen ini (Milestone Mapping)
- Source Code / Repository

0.3 Milestone Identifier Note

Dokumen ini menggunakan identifier MS-00..MS-07 untuk project milestones. Identifier ini BERBEDA dari identifier ART-M1..ART-M6 yang digunakan oleh Canonical Artifact Map untuk artifact gate milestones.

- MS-00..MS-07: Project milestones (fase eksekusi proyek). Digunakan di dokumen ini dan Timeline Estimation.
- ART-M1..ART-M6: Artifact Map gate milestones (ketersediaan artifact untuk build). Digunakan di Canonical Artifact Map.

Jangan mencampuradukkan kedua sistem identifier ini.

1. MILESTONE MATRIX (PHASE MAPPING)

Setiap Milestone (MS) berkorespondensi langsung dengan Phase pada Execution Strategy. Sebuah Milestone TIDAK BOLEH dinyatakan selesai (CLOSED) sebelum seluruh Definition of Done (DoD) terpenuhi dan Sprint Gate dilewati.

📍 MS-00: Planning & Architecture Lock

- Target Phase: Phase -1 (Planning)
- Fokus: Perencanaan, pemetaan backlog, dan penguncian arsitektur awal.
- Key Deliverables:
  - Sprint Plan & Task Breakdown
  - Risk Register (Initialized)
  - Architecture Checklist & Dependency Map
- Entry Criteria: Tidak ada (Titik awal proyek).
- Exit Criteria (DoD):
  - [ ] Seluruh backlog terstruktur dan terpetakan ke milestone.
  - [ ] Arsitektur checklist tersedia dan disetujui.
  - [ ] Resource & timeline estimasi tercatat.
- Gate: `PLANNING APPROVAL GATE`

📍 MS-01: Infrastructure & Development Foundation

- Target Phase: Phase 0 (Infrastructure & Dev Foundation)
- Fokus: Pondasi teknis, CI/CD, RLS foundation, dan standar development.
- Key Deliverables:
  - Supabase Project Skeleton & Auth Config
  - Migration Framework & Audit Table Foundation
  - CI Pipeline, Linting, Testing Framework
- Entry Criteria: MS-00 CLOSED.
- Exit Criteria (DoD):
  - [ ] Supabase project aktif, Auth dasar berfungsi.
  - [ ] RLS foundation & Audit table structure tersedia.
  - [ ] CI pipeline & Branching strategy terdokumentasi & aktif.
  - [ ] Constraint Check: Zero Budget & Zero Hardware Cost terpenuhi.
- Gate: `INFRASTRUCTURE READINESS GATE`

📍 MS-02: Constitution & Identity Locked

- Target Phase: Phase 1 (Constitution & Identity)
- Fokus: Identitas persisten, konstitusi sistem, dan boundary privasi dasar.
- Key Deliverables:
  - Immutable vs Evolvable Core Registry
  - SH_ID & ACCOUNT_ID Persistence Implementation
  - Cross-SH Isolation & DEFAULT DENY Enforcement
- Entry Criteria: MS-01 CLOSED.
- Exit Criteria (DoD):
  - [ ] `1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH` terverifikasi di level DB & API.
  - [ ] `SH_ID` terbukti persisten dan terpisah dari Model/Runtime/Session.
  - [ ] Privacy boundary (DEFAULT DENY) aktif dan teruji.
- Gate: `IDENTITY & CONSTITUTION GATE`

CATATAN: MS-02 memerlukan SH_ID exact format dan Creator SH reserved identifier (SH-000) yang masih MISSING (lihat Downstream Blockers Register). Identity/data model finalization TIDAK BOLEH dilakukan sebelum keputusan ini dibuat.

📍 MS-03: Governance & Authority Active

- Target Phase: Phase 2 (Governance & Authority)
- Fokus: Mekanisme evaluasi governance, matriks izin, dan boundary Creator/SH-000.
- Key Deliverables:
  - Permission Matrix
  - Governance Evaluator & Policy Enforcement Engine
  - Access Decision Gate (PASS / REJECT)
- Entry Criteria: MS-02 CLOSED.
- Exit Criteria (DoD):
  - [ ] Permission Matrix terdefinisi dan diimplementasikan.
  - [ ] `Creator Authority ≠ Private Data Access` terverifikasi.
  - [ ] `SH-000 Core Authority ≠ Private Data Access` terverifikasi.
  - [ ] `System Governance ≠ Omniscient Data Access` terverifikasi.
- Gate: `GOVERNANCE ENFORCEMENT GATE`

📍 MS-04: Cognitive Foundation Operational

- Target Phase: Phase 3 (Cognitive Foundation)
- Fokus: Memory lifecycle, Knowledge engine, dan Context assembly.
- Key Deliverables:
  - Memory Storage, Lifecycle, & Retrieval Pipelines
  - Knowledge Ingestion & Provenance Engine
  - Context Assembly & Isolation Engine
- Entry Criteria: MS-03 CLOSED.
- Exit Criteria (DoD):
  - [ ] Memory write/retrieval pipeline berfungsi dan terisolasi per SH.
  - [ ] `MEMORY ≠ KNOWLEDGE ≠ CONTEXT` terverifikasi secara arsitektural.
  - [ ] Context engine mampu merakit konteks secara bounded dan deterministic.
  - [ ] Knowledge provenance tracking aktif.
- Gate: `COGNITIVE ENGINE GATE`

CATATAN: MS-04 memerlukan OQ-02, OQ-03, OQ-04 resolved sebelum implementasi (lihat Downstream Blockers Register).

📍 MS-05: Runtime & Orchestration Active

- Target Phase: Phase 4 (Runtime & Orchestration)
- Fokus: Core loop runtime, reasoning, model routing, tool, dan action execution.
- Key Deliverables:
  - Runtime Core Loop Pipeline
  - Model Orchestration & Routing (Zero-Budget path)
  - Tool Execution & High-Risk Action Authorization
- Entry Criteria: MS-04 CLOSED.
- Exit Criteria (DoD):
  - [ ] Runtime core loop (Input -> Context -> Model -> Response -> Persistence) berjalan end-to-end.
  - [ ] `RUNTIME ≠ SH IDENTITY` dan `MODEL ≠ SH IDENTITY` terverifikasi.
  - [ ] Tool execution mematuhi `DEFAULT DENY` dan isolasi hasil (untrusted external data).
  - [ ] High-risk action flow (Plan -> Auth -> Confirm -> Execute -> Audit) berfungsi.
- Gate: `RUNTIME ORCHESTRATION GATE`

CATATAN: MS-05 memerlukan OQ-06 (Model Selection Routing) resolved sebelum Phase 4D (lihat Downstream Blockers Register).

📍 MS-06: Advanced Capabilities Integrated

- Target Phase: Phase 5 (SH Advanced Capabilities)
- Fokus: Journey, Clone, Inheritance, Recovery, dan Legacy.
- Key Deliverables:
  - Journey Timeline & Milestone Tracking
  - Clone Mechanism & Agreement Enforcement
  - Inheritance & Legacy Representation
  - Backup, Restore, & Recovery Pipeline
- Entry Criteria: MS-05 CLOSED.
- Exit Criteria (DoD):
  - [ ] `CLONE_SH ≠ SOURCE_SH` dan `CREATOR_SH = NON-CLONABLE` terverifikasi.
  - [ ] `INHERITANCE ≠ IDENTITY TRANSFER` terverifikasi.
  - [ ] Recovery pipeline mampu memulihkan state tanpa membuat SH baru (`RECOVERY ≠ NEW SH`).
  - [ ] Data Portability dan Continuity Gap handling berfungsi.
- Gate: `ADVANCED CAPABILITIES GATE`

CATATAN: MS-06 memerlukan OQ-05 (Clone Agreement Enforcement), OQ-07 (Backup/Restore Policy), OQ-08 (Data Portability Format) resolved sebelum implementasi terkait (lihat Downstream Blockers Register).

📍 MS-07: Assurance, Integration & Release

- Target Phase: Phase 6 (Assurance, Integration & Release)
- Fokus: Integrasi penuh, pembekuan implementasi, dan rilis final.
- Key Deliverables:
  - End-to-End Integration Test Suite
  - Architecture Drift & Contract Verification Reports
  - Final Source & Database Snapshots
- Entry Criteria: MS-06 CLOSED.
- Exit Criteria (DoD):
  - [ ] Seluruh integration tests PASS.
  - [ ] Architecture Review selesai (Zero Critical/High Drift).
  - [ ] Implementation Freeze dilakukan.
  - [ ] Final Integration Gate PASS -> `SH v1.0 = INTEGRATION-READY`.
- Gate: `FINAL INTEGRATION GATE`

2. RELEASE STAGE MILESTONES

Setelah `MS-07` (Final Integration Gate) dilewati, sistem memasuki tahap rilis bertahap menuju produksi.

| Release Stage | Milestone Target | Kriteria Utama |
|---|---|---|
| Developer Preview | Post-MS-05 | Core loop berfungsi, identity/ownership terverifikasi, basic security aktif. Belum stabil. |
| Internal Alpha | Post-MS-06 | Seluruh core & advanced features berfungsi, security hardening dimulai, masih ada known issues. |
| Closed Alpha | MS-07 (Pre-Freeze) | Seluruh features terimplementasi, testing masif, akses terbatas (internal tester). |
| Open Alpha | MS-07 (Post-Freeze) | Features stabil, performance acceptable, dokumentasi publik tersedia. |
| Beta | Operational Readiness | Production-ready, performance target tercapai, akses publik terbatas. |
| RC (Release Candidate) | Pre-Production | Seluruh acceptance criteria terpenuhi, zero critical blockers. |
| SH v1.0 | PRODUCTION | Production Release, Operational Readiness tercapai, Monitoring aktif. |

3. MILESTONE GOVERNANCE & TRACKING

3.1 Sprint Gate Enforcement

Setiap sprint yang berkontribusi pada sebuah Milestone TIDAK BOLEH di-merge ke branch utama sebelum melewati:

- Architecture Review (Mendeteksi Architecture Drift)
- Code Review (Standar kualitas & Traceability)
- Security Review (Validasi Boundary & RLS)
- Testing (Unit, Integration, Security)
- Evidence Collection (Bukti objektif DoD)

3.2 Architecture Drift & Technical Debt Tracking

- Drift Register: Jika implementasi menyimpang dari Canonical Architecture Diagram, Milestone DITUNDA hingga Corrective Action diselesaikan (terutama untuk Critical/High Drift).
- Technical Debt Register: Debt yang ditemukan selama pengerjaan Milestone harus dicatat. Debt dengan severity Critical atau High memblokir penutupan Milestone saat ini. Debt Medium/Low dapat dipindahkan ke Milestone berikutnya atau Post-Release Backlog dengan persetujuan Owner.

3.3 Milestone Transition Rule (Backward Revision)

Jika pada saat pengerjaan `MS-N` ditemukan cacat fundamental atau missing invariant pada `MS-(N-1)`:

1. STOP pengerjaan fitur baru di `MS-N`.
2. IDENTIFY & CLASSIFY dampak terhadap phase sebelumnya.
3. UPDATE & REVALIDATE phase sebelumnya.
4. CONTINUE hanya setelah phase sebelumnya kembali memenuhi DoD.

(Dilarang melakukan silent backward revision.)

4. CONSTRAINTS & INVARIANT CHECKPOINTS

Setiap Milestone WAJIB memvalidasi constraint berikut sebelum dinyatakan CLOSED:

- [ ] Zero Budget: Tidak ada mandatory paid dependency yang ditambahkan pada milestone ini.
- [ ] Zero Hardware Cost: Tidak ada mandatory hardware purchase yang dipersyaratkan.
- [ ] Mobile-First: Workflow development dan arsitektur yang dihasilkan mendukung mobile-first constraint.
- [ ] Canonical Invariants: Tidak ada satupun invariant dari `SH Core Canonical v1.0` yang dilanggar atau dilemahkan (misal: `Model ≠ SH Identity`, `Learning ≠ Automatic Core Modification`).

5. APPROVAL & SIGN-OFF

| Role | Name / Entity | Status | Date |
|---|---|---|---|
| System Architect | [AI / Engineer] | Drafted | 2026-08-07 |
| Architecture Owner | [Reviewer] | Pending Review | - |
| Gatekeeper / Owner | [Owner] | Pending Approval | - |

END OF SECOND_HEAD_PHASE_MINUS_1_MILESTONE_MAPPING_v1.0

================================================================================
[4/9] SECOND_HEAD_PHASE_MINUS_1_TASK_BREAKDOWN_v1.0
Role: ARTEFAK PHASE -1 — TASK BREAKDOWN / WORK BREAKDOWN STRUCTURE (WBS)
Source: Phase -1 Planning
Status: FINAL
================================================================================

SECOND_HEAD_PHASE_MINUS_1_TASK_BREAKDOWN_v1.0

Project: SECOND HEAD — SYSTEM BUILD
Phase: Phase -1 (Planning)
Document Type: Task Breakdown / Work Breakdown Structure (WBS)
Version: v1.0
Status: FINAL
Authority: Derived from SH Full Execution Strategy v1.0

0. DOCUMENT PURPOSE

Dokumen ini memecah seluruh scope pembangunan SH Full (Phase 0 hingga Phase 6) menjadi Epic dan Task yang dapat dieksekusi.

Setiap task dirancang untuk mendukung prinsip Vertical Slice Development dan mematuhi Definition of Done (DoD) per phase.

1. CROSS-CUTTING TASKS (Berlaku Sepanjang Siklus Hidup)

- [ ] CC-01: Setup & Maintain Architecture Decision Record (ADR) Register.
- [ ] CC-02: Setup & Maintain Technical Debt Register.
- [ ] CC-03: Setup & Maintain Architecture Drift Detection Log.
- [ ] CC-04: Continuous Evidence Collection & Audit Trail Maintenance.
- [ ] CC-05: Sprint Gate Execution (Architecture, Code, Security, Testing, Evidence Review).

2. EPIC 0: INFRASTRUCTURE & DEVELOPMENT FOUNDATION (Phase 0)

Fokus: Pondasi teknis, environment, dan standar development. Belum ada logic SH.

- [ ] E0-T01: Setup Supabase Project (Auth config, Storage/Bucket, Extensions).
- [ ] E0-T02: Implementasi RLS Foundation & Audit Table Structure.
- [ ] E0-T03: Setup Migration Framework & Seed Data Structure.
- [ ] E0-T04: Konfigurasi Environment Variables & Shared Types.
- [ ] E0-T05: Setup Repository Standards (Linting, Formatting, Commit Convention, Branching Strategy).
- [ ] E0-T06: Setup CI Pipeline & Testing Framework (Unit/Integration test skeleton).
- [ ] E0-T07: Definisi Folder Structure & Documentation Standard.

3. EPIC 1: CONSTITUTION & IDENTITY (Phase 1)

Fokus: Fondasi identitas, konstitusi, dan privacy boundary.

- [ ] E1-T01: Implementasi Core Registry (Pemetaan Immutable vs Evolvable Core).
- [ ] E1-T02: Implementasi Persistent Identity Anchor (`SH_ID`) & `ACCOUNT_ID`.
- [ ] E1-T03: Implementasi Ownership Model & Relationship (1 Email = 1 Account = 1 Primary SH).
- [ ] E1-T04: Implementasi Privacy Boundary & Cross-SH Isolation (DEFAULT DENY).
- [ ] E1-T05: Vertical Slice Testing: Identity Resolution & Ownership Verification.

4. EPIC 2: GOVERNANCE & AUTHORITY (Phase 2)

Fokus: Mekanisme evaluasi kebijakan, matriks izin, dan batasan authority.

- [ ] E2-T01: Definisi & Implementasi Permission Matrix.
- [ ] E2-T02: Implementasi Governance Evaluator & Policy Enforcement Engine.
- [ ] E2-T03: Implementasi Isolation Checker & Access Decision Gate (PASS / REJECT).
- [ ] E2-T04: Hardcoding Boundary: Creator Authority ≠ Private Data Access.
- [ ] E2-T05: Hardcoding Boundary: SH-000 Core Authority ≠ Private Data Access.
- [ ] E2-T06: Vertical Slice Testing: Governance Boundary & Privilege Escalation Prevention.

5. EPIC 3: COGNITIVE FOUNDATION (Phase 3)

Fokus: Memory, Knowledge, dan Context. Dipecah menjadi 5 Sub-Epic sesuai Execution Strategy §8.2.

Sub-Epic 3A: Memory Storage (SPRINT-006)

- [ ] E3A-T01: Desain tabel memory (schema, indexes, constraints) — isolated per SH.
- [ ] E3A-T02: Implementasi memory schema di database.
- [ ] E3A-T03: Implementasi memory persistence layer.
- [ ] E3A-T04: Implementasi memory isolation per SH_ID.
- [ ] E3A-T05: Implementasi memory ownership boundary.
- [ ] E3A-T06: Testing: memory storage, isolation, dan ownership.

Sub-Epic 3B: Memory Lifecycle (SPRINT-007)

- [ ] E3B-T01: Implementasi Memory Creation Pipeline (INTERACTION → CANDIDATE → RELEVANCE → CONFIDENCE → POLICY → WRITE → PERSIST → AUDIT).
- [ ] E3B-T02: Implementasi memory validation (schema, type, length).
- [ ] E3B-T03: Implementasi memory update mechanism.
- [ ] E3B-T04: Implementasi memory archival mechanism.
- [ ] E3B-T05: Implementasi memory deletion mechanism (authorized).
- [ ] E3B-T06: Testing: seluruh memory lifecycle operations.

Sub-Epic 3C: Memory Retrieval (SPRINT-008)

- [ ] E3C-T01: Desain retrieval strategy (QUERY → RETRIEVE → FILTER → RANK → VALIDATE → CONTEXT).
- [ ] E3C-T02: Implementasi relevance scoring mechanism.
- [ ] E3C-T03: Implementasi ranking mechanism.
- [ ] E3C-T04: Implementasi filtering logic.
- [ ] E3C-T05: Implementasi context injection (memory → context).
- [ ] E3C-T06: Implementasi bounded & deterministic retrieval logic.
- [ ] E3C-T07: Testing: retrieval strategy, scoring, ranking, filtering, injection.

Sub-Epic 3D: Knowledge Engine (SPRINT-009)

- [ ] E3D-T01: Desain schema knowledge (distinct from memory).
- [ ] E3D-T02: Implementasi knowledge acquisition mechanism.
- [ ] E3D-T03: Implementasi knowledge validation.
- [ ] E3D-T04: Implementasi knowledge normalization.
- [ ] E3D-T05: Implementasi knowledge classification.
- [ ] E3D-T06: Implementasi knowledge storage.
- [ ] E3D-T07: Implementasi knowledge indexing.
- [ ] E3D-T08: Implementasi knowledge provenance tracking.
- [ ] E3D-T09: Implementasi knowledge retrieval.
- [ ] E3D-T10: Testing: knowledge engine end-to-end.

Sub-Epic 3E: Context Engine (SPRINT-010)

- [ ] E3E-T01: Implementasi context assembly engine.
- [ ] E3E-T02: Implementasi context composition (multi-source assembly).
- [ ] E3E-T03: Implementasi context prioritization.
- [ ] E3E-T04: Implementasi context layering.
- [ ] E3E-T05: Implementasi context isolation per SH.
- [ ] E3E-T06: Implementasi context validation.
- [ ] E3E-T07: Implementasi context disposal (request-scoped cleanup).
- [ ] E3E-T08: Implementasi context budget & deterministic truncation.
- [ ] E3E-T09: Testing: context engine end-to-end.

Vertical Slice Testing: Cognitive Foundation End-to-End:

- [ ] E3-T99: Vertical Slice Testing: Cognitive Foundation End-to-End (mencakup 3A–3E).

6. EPIC 4: RUNTIME & ORCHESTRATION (Phase 4)

Fokus: Execution layer, reasoning, model routing, tools, dan actions.

- [ ] E4-T01: Implementasi Runtime Core Loop (Auth → Identity → Context → Model → Response → Persistence).
- [ ] E4-T02: Implementasi Reasoning & Planning/Workflow Engine.
- [ ] E4-T03: Implementasi Model Abstraction Layer & Routing (Zero-budget path prioritized).
- [ ] E4-T04: Implementasi Tool Execution (Discovery, Auth, Invocation, DEFAULT DENY).
- [ ] E4-T05: Implementasi Action Execution (High-risk flow: Plan → Auth → Confirm → Execute → Audit).
- [ ] E4-T06: Vertical Slice Testing: Runtime Core Loop & Model Replacement (Identity Persistence).

7. EPIC 5: SH ADVANCED CAPABILITIES (Phase 5)

Fokus: Journey, Clone, Inheritance, Recovery, dan Legacy.

- [ ] E5-T01: Implementasi Journey Tracking (Timeline, Milestones, Event Recording).
- [ ] E5-T02: Implementasi Clone Mechanism & Clone Agreement Enforcement (CLONE_SH ≠ SOURCE_SH).
- [ ] E5-T03: Implementasi Inheritance & Succession Mechanism (Authorized Transfer).
- [ ] E5-T04: Implementasi Legacy Preservation & Archival.
- [ ] E5-T05: Implementasi Recovery, Backup & Restore, dan Data Portability.
- [ ] E5-T06: Implementasi Continuity Gap Handling.
- [ ] E5-T07: Vertical Slice Testing: Clone Isolation & Inheritance Boundary.

8. EPIC 6: ASSURANCE, INTEGRATION & RELEASE (Phase 6)

Fokus: Testing menyeluruh, review arsitektur, freeze, dan release.

- [ ] E6-T01: Eksekusi Component & End-to-End Integration Testing.
- [ ] E6-T02: Eksekusi Security, Continuity, & Cross-SH Isolation Testing.
- [ ] E6-T03: Architecture Review & Drift Verification.
- [ ] E6-T04: Contract Verification (Memastikan seluruh Acceptance Criteria terpenuhi).
- [ ] E6-T05: Implementation Freeze (Snapshot final source code, DB schema, config).
- [ ] E6-T06: Final Integration Gate Execution & Evidence Compilation.
- [ ] E6-T07: Operational Readiness & Production Release Preparation.

9. EXECUTION RULES FOR TASKS

- Vertical Slice: Selesaikan satu domain secara utuh (Table → Policy → API → Service → Runtime → Test) sebelum pindah ke domain berikutnya.
- Evidence First: Setiap task yang di-checklist WAJIB memiliki link/referensi ke Evidence Record atau Test Report.
- No Silent Expansion: Kebutuhan fitur di luar daftar ini wajib dicatat di Technical Debt Register atau Backlog, bukan langsung diimplementasikan.

END OF SECOND_HEAD_PHASE_MINUS_1_TASK_BREAKDOWN_v1.0

================================================================================
[5/9] SECOND_HEAD_PHASE_MINUS_1_SPRINT_PLAN_v1.0
Role: ARTEFAK PHASE -1 — SPRINT PLAN
Source: Phase -1 Planning
Status: FINAL
================================================================================

SECOND_HEAD_PHASE_MINUS_1_SPRINT_PLAN_v1.0

Project: SECOND HEAD — SYSTEM BUILD
Document Type: Sprint Plan
Version: v1.0
Status: FINAL
Authority Level: Derived Operational Document (Below Execution Strategy)

1. DOCUMENT STATUS & AUTHORITY

1.1 Status

Dokumen ini adalah Sprint Plan untuk Phase -1 Planning.

Dokumen ini merupakan turunan operasional dari:

- SECOND_HEAD_SH_FULL_EXECUTION_STRATEGY_v1.0
- SECOND_HEAD_SH_FULL_IMPLEMENTATION_CONTRACT_v1.0
- SECOND_HEAD_SH_FULL_IMPLEMENTATION_GUIDE_v1.0
- SECOND_HEAD_PHASE_MINUS_1_MILESTONE_MAPPING_v1.0
- SECOND_HEAD_PHASE_MINUS_1_TASK_BREAKDOWN_v1.0
- SECOND_HEAD_PHASE_MINUS_1_RISK_REGISTER_v1.0

1.2 Authority Hierarchy

PRIORITY 1: SH Core Canonical v1.0
PRIORITY 2: Frozen Baseline Phase 01–10
PRIORITY 3: SH Full Build Scope v1.0
PRIORITY 4: SH Full Implementation Contract v1.0
PRIORITY 5: SH Full Implementation Guide v1.0
PRIORITY 6: Canonical Architecture Diagram (Master Diagram)
PRIORITY 7: Execution Strategy v1.0
PRIORITY 8: Dokumen ini (Sprint Plan)
PRIORITY 9: Source Code / Repository

1.3 Purpose

Dokumen ini menjawab pertanyaan:

"BAGAIMANA pekerjaan implementasi SH Full diorganisasikan ke dalam sprint yang terstruktur, terukur, dan konsisten dengan seluruh authority yang telah dibekukan?"

Dokumen ini TIDAK menjawab:

- "Apa yang harus dibangun?" → dijawab oleh Build Scope.
- "Bagaimana sistem harus dibangun secara teknis?" → dijawab oleh Implementation Contract dan Guide.
- "Kapan milestone dicapai?" → dijawab oleh Milestone Mapping.

1.4 Sprint Capacity Interpretation Note

Kapasitas sprint 24 jam efektif adalah PLANNING CAPACITY CAP PER SPRINT, bukan total availability atau entitlement.

Interpretasi final:

- 24h = planning capacity cap per sprint.
- Available time ≠ committed sprint capacity.
- Untuk sprint 2 minggu, cap 24h tetap berlaku sebagai committed capacity, bukan berarti total jam kalender yang tersedia dikali dua.
- Ini adalah commitment ceiling untuk sustainability, bukan entitlement.

Implikasi:

- Jika sprint = 1 minggu, max 24h committed.
- Jika sprint = 2 minggu, max 24h committed (bukan 48h).
- Ini menjaga sustainability dan mencegah overcommitment.
- Implementation agent tidak boleh mengasumsikan lebih banyak jam hanya karena sprint lebih panjang.

2. SPRINT PRINCIPLES

2.1 Vertical Slice Per Sprint

Setiap sprint harus menghasilkan minimal satu vertical slice yang selesai end-to-end.

Vertical slice berarti:

Table → Policy → API → Repository → Service → Runtime → Testing → Documentation → Evidence

Satu sprint tidak boleh hanya menghasilkan:

- Semua table tanpa API.
- Semua API tanpa testing.
- Semua service tanpa documentation.
- Semua documentation tanpa evidence.

2.2 Sprint Gate Enforcement

Setiap sprint tidak boleh di-merge sebelum melewati Sprint Gate:

Architecture Review → Code Review → Security Review → Testing → Evidence → Sprint Gate PASS → Merge

2.3 Definition of Done Per Sprint

Sebuah sprint dianggap selesai hanya jika:

- [ ] Seluruh task dalam sprint telah selesai.
- [ ] Seluruh Acceptance Criteria telah terpenuhi.
- [ ] Architecture Review telah dilakukan dan tidak ada drift.
- [ ] Code Review telah dilakukan dan code quality acceptable.
- [ ] Security Review telah dilakukan dan tidak ada vulnerability baru.
- [ ] Testing telah dilakukan dan seluruh test PASS.
- [ ] Evidence telah dikumpulkan dan terdokumentasi.
- [ ] Documentation telah diperbarui.
- [ ] Sprint Retrospective telah dilakukan.

2.4 No Silent Scope Expansion

Sprint scope tidak boleh diperluas secara diam-diam selama sprint berlangsung.

Jika ada kebutuhan baru yang muncul selama sprint:

NEW REQUIREMENT DETECTED
↓
CLASSIFY (Critical / High / Medium / Low)
↓
IF Critical: STOP sprint, escalate to Owner
↓
IF High: Add to next sprint backlog, do not add to current sprint
↓
IF Medium/Low: Add to backlog for future sprint

2.5 Sprint Sustainability

Sprint harus sustainable.

Tidak boleh ada sprint yang:

- Memaksa overtime berlebihan.
- Mengorbankan quality untuk speed.
- Mengabaikan testing untuk mengejar deadline.
- Melewatkan documentation untuk mengejar feature.

3. SPRINT STRUCTURE

3.1 Sprint Duration

Sprint duration default: 1 minggu (7 hari).

Sprint duration dapat disesuaikan berdasarkan:

- Kompleksitas task.
- Availability Owner.
- Dependency eksternal.
- Risk level.

Sprint duration tidak boleh lebih dari 2 minggu tanpa persetujuan Owner.

3.2 Sprint Numbering

Sprint diberi nomor berurutan:

- SPRINT-001: Phase 0 — Infrastructure Foundation
- SPRINT-002: Phase 1A — Constitution
- SPRINT-003: Phase 1B — Identity
- SPRINT-004: Phase 1C — Ownership & Privacy
- SPRINT-005: Phase 2 — Governance & Authority
- SPRINT-006: Phase 3A — Memory Storage
- SPRINT-007: Phase 3B — Memory Lifecycle
- SPRINT-008: Phase 3C — Memory Retrieval
- SPRINT-009: Phase 3D — Knowledge
- SPRINT-010: Phase 3E — Context
- SPRINT-011: Phase 4A — Runtime Pipeline
- SPRINT-012: Phase 4B — Reasoning
- SPRINT-013: Phase 4C — Planning
- SPRINT-014: Phase 4D — Model Routing
- SPRINT-015: Phase 4E — Tool Execution
- SPRINT-016: Phase 4F — Action Execution
- SPRINT-017: Phase 5A — Journey
- SPRINT-018: Phase 5B — Clone
- SPRINT-019: Phase 5C — Inheritance
- SPRINT-020: Phase 5D — Recovery
- SPRINT-021: Phase 5E — Legacy
- SPRINT-022: Phase 6A — Integration Testing
- SPRINT-023: Phase 6B — Architecture Review
- SPRINT-024: Phase 6C — Contract Verification
- SPRINT-025: Phase 6D — Implementation Freeze
- SPRINT-026: Phase 6E — Release

Catatan:

- Nomor sprint bersifat indikatif. Satu phase dapat memerlukan lebih dari satu sprint jika kompleksitasnya tinggi. Satu sprint dapat mencakup lebih dari satu sub-phase jika kompleksitasnya rendah.
- Penyesuaian nomor sprint harus didokumentasikan dalam Sprint Log.

3.3 Sprint Components

Setiap sprint terdiri dari:

Sprint Goal → Sprint Backlog → Sprint Execution → Sprint Review → Sprint Retrospective → Sprint Gate → Sprint Closure

4. SPRINT GOAL

4.1 Sprint Goal Definition

Setiap sprint harus memiliki satu Sprint Goal yang jelas.

Sprint Goal adalah:

- Satu kalimat yang menggambarkan hasil utama sprint.
- Terukur dan dapat diverifikasi.
- Konsisten dengan Milestone Mapping.
- Konsisten dengan Task Breakdown.
- Tidak boleh diubah selama sprint berlangsung tanpa persetujuan Owner.

4.2 Sprint Goal Format

SPRINT-[NNN] GOAL:
"[Deskripsi hasil utama sprint]"

Contoh:

- SPRINT-001 GOAL: "Supabase project terkonfigurasi dengan authentication, RLS foundation, audit table, dan migration framework yang berfungsi."
- SPRINT-002 GOAL: "Constitution registry terimplementasi dengan pemisahan Immutable Core dan Evolvable Core yang terverifikasi."
- SPRINT-003 GOAL: "SH_ID persistent identity anchor terimplementasi dan terverifikasi dengan ACCOUNT_ID yang terpisah."

4.3 Sprint Goal Alignment

Setiap Sprint Goal harus dapat ditelusuri ke:

- Milestone Mapping → Milestone ID
- Task Breakdown → Task ID
- Risk Register → Risk ID (jika relevan)
- Implementation Contract → Acceptance Criteria ID

Jika Sprint Goal tidak dapat ditelusuri ke salah satu di atas, Sprint Goal tidak valid.

5. SPRINT BACKLOG

5.1 Sprint Backlog Definition

Sprint Backlog adalah daftar task yang akan dikerjakan dalam satu sprint.

Sprint Backlog diambil dari Task Breakdown dan harus:

- Konsisten dengan Sprint Goal.
- Konsisten dengan Dependency Map.
- Tidak melebihi kapasitas sprint.
- Memiliki Acceptance Criteria yang jelas.
- Memiliki estimasi effort.

5.2 Sprint Backlog Format

| Task ID | Task Description | Priority | Effort | Dependency | Acceptance Criteria | Status |
|---|---|---|---|---|---|---|
| T-001 | [Deskripsi] | P0 | S/M/L | None | [AC] | TODO |
| T-002 | [Deskripsi] | P0 | S/M/L | T-001 | [AC] | TODO |
| T-003 | [Deskripsi] | P1 | S/M/L | T-002 | [AC] | TODO |

5.3 Priority Levels

- P0: Must have. Sprint gagal jika task ini tidak selesai.
- P1: Should have. Sprint dapat selesai tanpa task ini, tetapi harus diselesaikan di sprint berikutnya.
- P2: Nice to have. Dapat ditunda tanpa dampak signifikan.
- P3: Future. Tidak diperlukan untuk sprint ini atau sprint berikutnya.

5.4 Effort Estimation

- S: Small. Dapat diselesaikan dalam < 2 jam.
- M: Medium. Dapat diselesaikan dalam 2–8 jam.
- L: Large. Memerlukan > 8 jam. Harus dipecah menjadi task yang lebih kecil.

Task dengan effort L harus dipecah sebelum masuk Sprint Backlog.

5.5 Sprint Backlog Capacity

Kapasitas sprint default:

- 1 sprint = 5–8 task dengan effort S/M.
- 1 sprint = maksimal 2 task dengan effort L.
- Total effort per sprint tidak boleh melebihi kapasitas Owner.

Jika Sprint Backlog melebihi kapasitas, task dengan priority terendah harus dipindahkan ke sprint berikutnya.

6. SPRINT EXECUTION

6.1 Sprint Execution Flow

Sprint Backlog Locked → Task Execution (Vertical Slice) → Unit Testing → Integration Testing → Code Review → Security Review → Architecture Review → Evidence Collection → Documentation Update → Sprint Review → Sprint Retrospective → Sprint Gate → Sprint Closure

6.2 Task Execution Rules

- Task harus dikerjakan secara berurutan berdasarkan Dependency Map.
- Task tidak boleh dikerjakan jika dependency-nya belum selesai.
- Task harus mengikuti Vertical Slice Development: Table → Policy → API → Repository → Service → Runtime → Testing → Documentation → Evidence
- Task tidak boleh di-split menjadi: Semua table dulu, baru semua API. Semua API dulu, baru semua testing. Semua testing dulu, baru semua documentation.

6.3 Task Status Tracking

Setiap task memiliki status:

- TODO: Belum dimulai.
- IN PROGRESS: Sedang dikerjakan.
- TESTING: Menunggu testing.
- REVIEW: Menunggu review.
- DONE: Selesai dan terverifikasi.
- BLOCKED: Terblokir oleh dependency atau issue.
- CANCELLED: Dibatalkan.

6.4 Daily Check-in

Setiap hari selama sprint, Owner dan AI Assistant melakukan check-in:

- Task apa yang selesai kemarin?
- Task apa yang akan dikerjakan hari ini?
- Ada blocker?
- Ada risiko baru?
- Ada perubahan scope?

Check-in tidak boleh lebih dari 15 menit.

7. SPRINT REVIEW

7.1 Sprint Review Purpose

Sprint Review adalah evaluasi hasil sprint terhadap Sprint Goal.

Sprint Review menjawab:

- Apakah Sprint Goal tercapai?
- Apakah seluruh Acceptance Criteria terpenuhi?
- Apakah ada drift dari arsitektur?
- Apakah ada risiko baru?
- Apakah ada technical debt baru?
- Apakah ada pelajaran yang dapat diterapkan di sprint berikutnya?

7.2 Sprint Review Format

SPRINT-[NNN] REVIEW

Sprint Goal: [Goal]
Sprint Duration: [Start Date] — [End Date]
Tasks Completed: [X] / [Y]
Tasks Blocked: [Z]

Acceptance Criteria Status:
[AC-1] PASS / FAIL
[AC-2] PASS / FAIL
[AC-3] PASS / FAIL

Architecture Drift: NONE / DETECTED
Security Issues: NONE / DETECTED
Technical Debt: NONE / TD-[NNN]
New Risks: NONE / RISK-[NNN]

Lessons Learned:
[Lesson 1]
[Lesson 2]

Sprint Verdict: PASS / FAIL / PARTIAL

7.3 Sprint Review Decision

- PASS: Sprint Goal tercapai. Lanjut ke sprint berikutnya.
- FAIL: Sprint Goal tidak tercapai. Identifikasi penyebab dan corrective action.
- PARTIAL: Sprint Goal sebagian tercapai. Tentukan task yang harus dilanjutkan di sprint berikutnya.

8. SPRINT RETROSPECTIVE

8.1 Sprint Retrospective Purpose

Sprint Retrospective adalah evaluasi proses sprint.

Sprint Retrospective menjawab:

- Apa yang berjalan baik?
- Apa yang tidak berjalan baik?
- Apa yang dapat diperbaiki di sprint berikutnya?

8.2 Sprint Retrospective Format

SPRINT-[NNN] RETROSPECTIVE

What went well:
[Item 1]
[Item 2]

What did not go well:
[Item 1]
[Item 2]

What can be improved:
[Item 1]
[Item 2]

Action Items:
[Action 1] → Owner: [Name] → Due: [Date]
[Action 2] → Owner: [Name] → Due: [Date]

8.3 Sprint Retrospective Rules

- Sprint Retrospective tidak boleh menyalahkan.
- Sprint Retrospective harus menghasilkan minimal satu action item yang konkret.
- Action item harus diterapkan di sprint berikutnya.

9. SPRINT GATE

9.1 Sprint Gate Criteria

Sprint Gate PASS jika:

- [ ] Architecture Review: tidak ada drift.
- [ ] Code Review: code quality acceptable.
- [ ] Security Review: tidak ada vulnerability baru.
- [ ] Testing: seluruh test PASS.
- [ ] Evidence: evidence tersedia dan terdokumentasi.
- [ ] Documentation: documentation diperbarui.
- [ ] Sprint Review: Sprint Goal tercapai.
- [ ] Sprint Retrospective: dilakukan dan action item tercatat.

9.2 Sprint Gate Failure

Jika Sprint Gate FAIL:

Identify issue → Fix → Re-review → Re-test → Re-gate

Tidak boleh merge jika Sprint Gate belum PASS.

9.3 Sprint Gate Override

- Sprint Gate tidak boleh di-override oleh AI Assistant.
- Sprint Gate hanya dapat di-override oleh Owner dengan alasan yang terdokumentasi.
- Override harus dicatat dalam Sprint Log.

10. SPRINT CEREMONY

10.1 Sprint Planning

- Waktu: Awal sprint.
- Durasi: Maks 30 menit.
- Output: Sprint Backlog locked.
- Agenda: Review Sprint Goal. Review Sprint Backlog. Confirm capacity. Confirm dependencies. Lock Sprint Backlog.

10.2 Daily Check-in

- Waktu: Setiap hari selama sprint.
- Durasi: Maks 15 menit.
- Output: Status update.
- Agenda: Task selesai kemarin. Task hari ini. Blocker. Risiko baru.

10.3 Sprint Review

- Waktu: Akhir sprint.
- Durasi: Maks 30 menit.
- Output: Sprint Review Report.
- Agenda: Review Sprint Goal. Review Acceptance Criteria. Review Architecture Drift. Review Security Issues. Review Technical Debt. Review New Risks. Lessons Learned. Sprint Verdict.

10.4 Sprint Retrospective

- Waktu: Setelah Sprint Review.
- Durasi: Maks 15 menit.
- Output: Action Items.
- Agenda: What went well. What did not go well. What can be improved. Action Items.

11. SPRINT CAPACITY & RESOURCE ALLOCATION

11.1 Sprint Capacity

Sprint capacity ditentukan oleh:

- Availability Owner.
- Complexity task.
- Dependency eksternal.
- Risk level.

Default capacity:

- 1 sprint = 5–8 task dengan effort S/M.
- 1 sprint = maksimal 2 task dengan effort L.
- 1 sprint = maksimal 24 jam kerja efektif.

CATATAN: 24 jam adalah planning capacity cap per sprint, bukan total availability. Lihat section 1.4 untuk interpretasi lengkap. Untuk sprint 2 minggu, cap 24h tetap berlaku sebagai committed capacity.

11.2 Resource Allocation

| Resource | Allocation | Notes |
|---|---|---|
| Owner Time | [X] hours | Decision making, review, testing |
| AI Assistant | [Y] hours | Implementation, documentation, testing |
| Supabase | Free tier | Zero budget constraint |
| GitHub | Free tier | Zero budget constraint |
| AI Model | Groq free tier | Zero budget constraint |

11.3 Zero Budget Constraint

- Tidak boleh ada mandatory paid dependency.
- Tidak boleh ada mandatory hardware purchase.
- Free tier harus cukup untuk development dan testing.
- Paid upgrade hanya optional, bukan mandatory.

11.4 Mobile-First Constraint

- Coding dapat dilakukan dari mobile device.
- Testing dapat dilakukan dari mobile device.
- Deployment dapat dilakukan dari mobile device.
- Remote development diperbolehkan jika mobile tidak cukup.

12. SPRINT LOG

12.1 Sprint Log Purpose

Sprint Log adalah catatan resmi seluruh aktivitas sprint.

Sprint Log harus mencatat:

- Sprint Goal.
- Sprint Backlog.
- Task status changes.
- Sprint Review result.
- Sprint Retrospective action items.
- Sprint Gate result.
- Sprint Closure.

12.2 Sprint Log Format

SPRINT-[NNN] LOG

Sprint Goal: [Goal]
Sprint Duration: [Start Date] — [End Date]
Sprint Capacity: [X] hours

Sprint Backlog:
| Task ID | Description | Priority | Effort | Status |
|---|---|---|---|---|
| T-001 | [Desc] | P0 | S | DONE |
| T-002 | [Desc] | P0 | M | DONE |
| T-003 | [Desc] | P1 | S | BLOCKED |

Daily Check-ins:
[Date 1]: [Summary]
[Date 2]: [Summary]
[Date 3]: [Summary]

Sprint Review:
Verdict: PASS / FAIL / PARTIAL
[Details]

Sprint Retrospective:
[Action Items]

Sprint Gate:
Result: PASS / FAIL
[Details]

Sprint Closure:
[Summary]

12.3 Sprint Log Retention

- Sprint Log harus disimpan selama proyek berlangsung.
- Sprint Log tidak boleh dihapus.
- Sprint Log dapat diarsipkan setelah proyek selesai.

13. SPRINT DEPENDENCY MANAGEMENT

13.1 Dependency Rules

- Task dalam Sprint Backlog harus mengikuti Dependency Map.
- Task tidak boleh dikerjakan jika dependency-nya belum selesai.
- Jika dependency terblokir, task harus ditandai BLOCKED dan dipindahkan ke sprint berikutnya.

13.2 Cross-Sprint Dependency

Jika task di sprint N bergantung pada task di sprint N-1:

- Task di sprint N-1 harus selesai sebelum sprint N dimulai.
- Jika task di sprint N-1 belum selesai, sprint N tidak boleh dimulai.
- Exception: Owner dapat memberikan persetujuan untuk memulai sprint N dengan task yang tidak bergantung pada task yang belum selesai.

13.3 External Dependency

Jika task bergantung pada external dependency:

- External dependency harus diidentifikasi di Sprint Planning.
- External dependency harus memiliki fallback plan.
- Jika external dependency tidak tersedia, task harus ditandai BLOCKED.

14. SPRINT RISK MANAGEMENT

14.1 Sprint Risk Identification

Setiap sprint harus mengidentifikasi risiko baru:

- Risiko teknis.
- Risiko operasional.
- Risiko governance.
- Risiko security.
- Risiko project.

14.2 Sprint Risk Assessment

Risiko baru harus dinilai:

- Probability: Low / Medium / High.
- Impact: Low / Medium / High / Critical.
- Priority: Low / Medium / High / Critical.

14.3 Sprint Risk Mitigation

- Risiko dengan priority High atau Critical harus memiliki mitigation plan sebelum sprint dimulai.
- Risiko dengan priority Medium harus memiliki mitigation plan sebelum sprint berakhir.
- Risiko dengan priority Low dapat ditunda ke sprint berikutnya.

14.4 Sprint Risk Register Update

- Risiko baru harus ditambahkan ke Risk Register.
- Risiko yang sudah resolved harus di-update statusnya.
- Risiko yang sudah closed harus diarsipkan.

15. SPRINT TECHNICAL DEBT MANAGEMENT

15.1 Sprint Technical Debt Identification

Setiap sprint harus mengidentifikasi technical debt baru:

- Security debt.
- Performance debt.
- Maintainability debt.
- Architecture debt.
- Documentation debt.

15.2 Sprint Technical Debt Assessment

Technical debt baru harus dinilai:

- Severity: Critical / High / Medium / Low.
- Impact: Deskripsi dampak.
- Target Phase: Phase penyelesaian.

15.3 Sprint Technical Debt Register Update

- Technical debt baru harus ditambahkan ke Technical Debt Register.
- Technical debt yang sudah resolved harus di-update statusnya.
- Technical debt yang sudah closed harus diarsipkan.

15.4 Technical Debt Budget

- Setiap sprint harus mengalokasikan minimal 10% kapasitas untuk technical debt resolution.
- Jika tidak ada technical debt, kapasitas dapat dialihkan ke feature development.

16. SPRINT ARCHITECTURE DRIFT DETECTION

16.1 Sprint Architecture Review

Setiap sprint harus melakukan Architecture Review:

- Verifikasi implementasi terhadap Canonical Architecture Diagram.
- Verifikasi implementasi terhadap Implementation Contract.
- Verifikasi implementasi terhadap Implementation Guide.
- Identifikasi drift.

16.2 Sprint Drift Classification

Jika drift terdeteksi:

- Critical Drift: Implementasi melanggar canonical invariant. STOP.
- High Drift: Implementasi mengubah architectural boundary. STOP.
- Medium Drift: Implementasi mengubah component relationship. Fix in current sprint.
- Low Drift: Implementasi mengubah naming atau structure minor. Fix in next sprint.

16.3 Sprint Drift Register Update

- Drift baru harus ditambahkan ke Drift Register.
- Drift yang sudah resolved harus di-update statusnya.
- Drift yang sudah closed harus diarsipkan.

17. SPRINT EVIDENCE MANAGEMENT

17.1 Sprint Evidence Requirements

Setiap sprint harus menghasilkan evidence:

- Validation Report.
- Test Report.
- Audit Trail.
- Implementation Record.
- Evidence Record.

17.2 Sprint Evidence Format

Evidence harus:

- Terstruktur.
- Dapat diverifikasi.
- Dapat ditelusuri ke task dan Acceptance Criteria.
- Disimpan dalam repository.
- Tidak boleh dihapus.

17.3 Sprint Evidence Review

- Evidence harus di-review selama Sprint Review.
- Evidence yang tidak lengkap harus dilengkapi sebelum Sprint Gate.
- Evidence yang tidak valid harus diperbaiki sebelum Sprint Gate.

18. SPRINT DOCUMENTATION MANAGEMENT

18.1 Sprint Documentation Requirements

Setiap sprint harus memperbarui documentation:

- Architecture documentation (jika ada perubahan).
- API documentation (jika ada perubahan).
- Database documentation (jika ada perubahan).
- Deployment documentation (jika ada perubahan).
- Testing documentation (jika ada perubahan).

18.2 Sprint Documentation Format

Documentation harus:

- Konsisten dengan Canonical Architecture Diagram.
- Konsisten dengan Implementation Contract.
- Konsisten dengan Implementation Guide.
- Terstruktur.
- Dapat ditelusuri.

18.3 Sprint Documentation Review

- Documentation harus di-review selama Sprint Review.
- Documentation yang tidak lengkap harus dilengkapi sebelum Sprint Gate.
- Documentation yang tidak konsisten harus diperbaiki sebelum Sprint Gate.

19. SPRINT CHANGE CONTROL

19.1 Sprint Scope Change

Sprint scope tidak boleh diubah selama sprint berlangsung tanpa persetujuan Owner.

Jika ada kebutuhan perubahan scope:

CHANGE REQUEST → CLASSIFY (Critical / High / Medium / Low) → IMPACT ANALYSIS → OWNER DECISION → IF APPROVED: Update Sprint Backlog / IF REJECTED: Add to next sprint backlog

19.2 Sprint Goal Change

Sprint Goal tidak boleh diubah selama sprint berlangsung tanpa persetujuan Owner.

Jika ada kebutuhan perubahan Sprint Goal:

GOAL CHANGE REQUEST → IMPACT ANALYSIS → OWNER DECISION → IF APPROVED: Update Sprint Goal, re-plan Sprint Backlog / IF REJECTED: Continue with original Sprint Goal

19.3 Sprint Duration Change

Sprint duration tidak boleh diubah selama sprint berlangsung tanpa persetujuan Owner.

Jika ada kebutuhan perubahan sprint duration:

DURATION CHANGE REQUEST → IMPACT ANALYSIS → OWNER DECISION → IF APPROVED: Update Sprint Duration / IF REJECTED: Continue with original Sprint Duration

20. SPRINT CLOSURE

20.1 Sprint Closure Criteria

Sprint dapat ditutup jika:

- [ ] Sprint Gate PASS.
- [ ] Sprint Review selesai.
- [ ] Sprint Retrospective selesai.
- [ ] Sprint Log lengkap.
- [ ] Evidence lengkap.
- [ ] Documentation diperbarui.
- [ ] Technical Debt Register di-update.
- [ ] Risk Register di-update.
- [ ] Drift Register di-update.

20.2 Sprint Closure Format

SPRINT-[NNN] CLOSURE

Sprint Goal: [Goal]
Sprint Verdict: PASS / FAIL / PARTIAL
Sprint Gate: PASS / FAIL

Tasks Completed: [X] / [Y]
Tasks Blocked: [Z]
Tasks Cancelled: [W]

Acceptance Criteria: [X] / [Y] PASS
Architecture Drift: NONE / DETECTED
Security Issues: NONE / DETECTED
Technical Debt: [List]
New Risks: [List]

Evidence: COMPLETE / INCOMPLETE
Documentation: COMPLETE / INCOMPLETE

Sprint Closed: [Date]
Closed By: [Name]

20.3 Sprint Closure Decision

- PASS: Sprint ditutup. Lanjut ke sprint berikutnya.
- FAIL: Sprint tidak ditutup. Identifikasi penyebab dan corrective action. Sprint diulang.
- PARTIAL: Sprint ditutup dengan catatan. Task yang belum selesai dipindahkan ke sprint berikutnya.

21. SPRINT GOVERNANCE

21.1 Sprint Governance Roles

Owner:

- Decision making.
- Sprint Goal approval.
- Sprint Backlog approval.
- Sprint Gate override (jika diperlukan).
- Sprint Closure approval.

AI Assistant:

- Implementation.
- Documentation.
- Testing.
- Evidence collection.
- Sprint Review preparation.
- Sprint Retrospective preparation.

21.2 Sprint Governance Rules

AI Assistant tidak boleh:

- Mengubah Sprint Goal tanpa persetujuan Owner.
- Mengubah Sprint Backlog tanpa persetujuan Owner.
- Override Sprint Gate.
- Menutup sprint tanpa Sprint Review dan Sprint Retrospective.
- Menghapus Sprint Log.
- Menghapus Evidence.

21.3 Sprint Escalation

Jika ada issue yang tidak dapat diselesaikan oleh AI Assistant:

ISSUE DETECTED → CLASSIFY → IMPACT ANALYSIS → ESCALATE TO OWNER → OWNER DECISION → CORRECTIVE ACTION → RE-VERIFY

22. SPRINT METRICS

22.1 Sprint Metrics Definition

Sprint metrics digunakan untuk mengukur progress dan kualitas sprint.

Sprint metrics tidak boleh digunakan untuk:

- Menekan Owner atau AI Assistant.
- Mengorbankan quality untuk speed.
- Mengabaikan testing untuk mengejar deadline.

22.2 Sprint Metrics List

| Metric | Definition | Target |
|---|---|---|
| Sprint Goal Achievement | % Sprint Goal tercapai | 100% |
| Task Completion Rate | % task selesai / total task | > 80% |
| Acceptance Criteria Pass Rate | % AC PASS / total AC | 100% |
| Architecture Drift Count | Jumlah drift terdeteksi | 0 |
| Security Issue Count | Jumlah security issue terdeteksi | 0 |
| Technical Debt Count | Jumlah technical debt baru | < 2 per sprint |
| Sprint Gate Pass Rate | % Sprint Gate PASS / total sprint | 100% |
| Evidence Completeness | % evidence lengkap / total evidence | 100% |
| Documentation Completeness | % documentation lengkap / total documentation | 100% |

22.3 Sprint Metrics Review

- Sprint metrics harus di-review selama Sprint Retrospective.
- Jika metric tidak mencapai target, harus ada action item untuk perbaikan.
- Action item harus diterapkan di sprint berikutnya.

23. SPRINT CONTINUITY

23.1 Sprint Continuity Principle

- Sprint harus memiliki continuity.
- Sprint N harus dapat dilanjutkan dari Sprint N-1 tanpa kehilangan konteks.
- Sprint continuity dijaga melalui: Sprint Log, Sprint Backlog, Task status tracking, Evidence, Documentation.

23.2 Sprint Handoff

Jika sprint tidak dapat diselesaikan dalam satu session:

SPRINT HANDOFF → Document current status → Document remaining tasks → Document blockers → Document next steps → Save to Sprint Log → Continue in next session

23.3 Sprint Resume

Jika sprint dilanjutkan di session berikutnya:

SPRINT RESUME → Read Sprint Log → Read Sprint Backlog → Read Task status → Read Evidence → Read Documentation → Continue from last status

24. SPRINT TEMPLATE

24.1 Sprint Planning Template

SPRINT-[NNN] PLANNING

Sprint Goal: [Goal]
Sprint Duration: [Start Date] — [End Date]
Sprint Capacity: [X] hours

Sprint Backlog:
| Task ID | Description | Priority | Effort | Dependency | Acceptance Criteria | Status |
|---|---|---|---|---|---|---|
| T-001 | [Desc] | P0 | S | None | [AC] | TODO |
| T-002 | [Desc] | P0 | M | T-001 | [AC] | TODO |
| T-003 | [Desc] | P1 | S | T-002 | [AC] | TODO |

Dependencies:
[Dependency 1]
[Dependency 2]

Risks:
[Risk 1]
[Risk 2]

Technical Debt Budget: [X] hours

Sprint Backlog Locked: [Date]
Locked By: [Name]

24.2 Sprint Review Template

SPRINT-[NNN] REVIEW

Sprint Goal: [Goal]
Sprint Duration: [Start Date] — [End Date]
Tasks Completed: [X] / [Y]
Tasks Blocked: [Z]

Acceptance Criteria Status:
[AC-1] PASS / FAIL
[AC-2] PASS / FAIL
[AC-3] PASS / FAIL

Architecture Drift: NONE / DETECTED
Security Issues: NONE / DETECTED
Technical Debt: NONE / TD-[NNN]
New Risks: NONE / RISK-[NNN]

Lessons Learned:
[Lesson 1]
[Lesson 2]

Sprint Verdict: PASS / FAIL / PARTIAL

24.3 Sprint Retrospective Template

SPRINT-[NNN] RETROSPECTIVE

What went well:
[Item 1]
[Item 2]

What did not go well:
[Item 1]
[Item 2]

What can be improved:
[Item 1]
[Item 2]

Action Items:
[Action 1] → Owner: [Name] → Due: [Date]
[Action 2] → Owner: [Name] → Due: [Date]

24.4 Sprint Closure Template

SPRINT-[NNN] CLOSURE

Sprint Goal: [Goal]
Sprint Verdict: PASS / FAIL / PARTIAL
Sprint Gate: PASS / FAIL

Tasks Completed: [X] / [Y]
Tasks Blocked: [Z]
Tasks Cancelled: [W]

Acceptance Criteria: [X] / [Y] PASS
Architecture Drift: NONE / DETECTED
Security Issues: NONE / DETECTED
Technical Debt: [List]
New Risks: [List]

Evidence: COMPLETE / INCOMPLETE
Documentation: COMPLETE / INCOMPLETE

Sprint Closed: [Date]
Closed By: [Name]

25. SPRINT ANTI-PATTERNS

25.1 Anti-Pattern: Big Bang Sprint

- Deskripsi: Satu sprint mencoba menyelesaikan seluruh phase.
- Dampak: Quality turun, testing tidak lengkap, documentation tidak terupdate.
- Solusi: Pecah menjadi sprint yang lebih kecil dengan Sprint Goal yang jelas.

25.2 Anti-Pattern: No Testing Sprint

- Deskripsi: Sprint tanpa testing.
- Dampak: Bug tidak terdeteksi, quality tidak terjamin.
- Solusi: Setiap sprint harus memiliki testing task.

25.3 Anti-Pattern: No Documentation Sprint

- Deskripsi: Sprint tanpa documentation update.
- Dampak: Documentation tidak terupdate, traceability terputus.
- Solusi: Setiap sprint harus memiliki documentation task.

25.4 Anti-Pattern: Scope Creep Sprint

- Deskripsi: Sprint scope diperluas secara diam-diam.
- Dampak: Sprint tidak selesai, quality turun.
- Solusi: Sprint scope tidak boleh diubah tanpa persetujuan Owner.

25.5 Anti-Pattern: No Evidence Sprint

- Deskripsi: Sprint tanpa evidence.
- Dampak: Implementasi tidak dapat diverifikasi, audit tidak dapat dilakukan.
- Solusi: Setiap sprint harus menghasilkan evidence.

25.6 Anti-Pattern: No Retrospective Sprint

- Deskripsi: Sprint tanpa retrospective.
- Dampak: Pelajaran tidak diambil, kesalahan diulang.
- Solusi: Setiap sprint harus memiliki retrospective.

26. SPRINT GLOSSARY

| Term | Definition |
|---|---|
| Sprint | Satu periode kerja terstruktur dengan Sprint Goal yang jelas. |
| Sprint Goal | Satu kalimat yang menggambarkan hasil utama sprint. |
| Sprint Backlog | Daftar task yang akan dikerjakan dalam satu sprint. |
| Sprint Capacity | Kapasitas kerja yang tersedia untuk satu sprint. |
| Sprint Gate | Gate yang harus dilewati sebelum sprint dapat di-merge. |
| Sprint Review | Evaluasi hasil sprint terhadap Sprint Goal. |
| Sprint Retrospective | Evaluasi proses sprint. |
| Sprint Log | Catatan resmi seluruh aktivitas sprint. |
| Sprint Closure | Penutupan sprint setelah seluruh kriteria terpenuhi. |
| Vertical Slice | Satu unit kerja yang selesai end-to-end dari table hingga evidence. |
| Sprint Anti-Pattern | Pola sprint yang harus dihindari. |

27. DOCUMENT CONTROL

Document: SECOND_HEAD_PHASE_MINUS_1_SPRINT_PLAN_v1.0
Version: v1.0
Status: FINAL
Authority Level: Derived Operational Document (Below Execution Strategy)

END OF SECOND_HEAD_PHASE_MINUS_1_SPRINT_PLAN_v1.0

================================================================================
[6/9] SECOND_HEAD_PHASE_MINUS_1_RISK_REGISTER_v1.0
Role: ARTEFAK PHASE -1 — RISK REGISTER (INITIALIZED)
Source: Phase -1 Planning
Status: FINAL
================================================================================

SECOND_HEAD_PHASE_MINUS_1_RISK_REGISTER_v1.0

Project: SECOND HEAD — SYSTEM BUILD
Document Type: Phase -1 Artifact — Risk Register (Initialized)
Version: v1.0
Status: FINAL
Authority Level: Derived Operational Document (Below Execution Strategy)

1. DOCUMENT STATUS & AUTHORITY

1.1 Status

Dokumen ini adalah Risk Register (Initialized) untuk Phase -1 Planning.

Dokumen ini merupakan turunan operasional dari:

- SECOND_HEAD_SH_FULL_EXECUTION_STRATEGY_v1.0 §20
- SECOND_HEAD_SH_FULL_COMPILED_IMPLEMENTATION_GUIDE_v1.0 §40
- SECOND_HEAD_SH_FULL_IMPLEMENTATION_CONTRACT_v1.0 §37
- SECOND_HEAD_SH_FULL_BUILD_SCOPE_v1.0
- SECOND_HEAD_SH_CORE_CANONICAL_v1.0 §27

1.2 Authority Hierarchy

PRIORITY 1: SH Core Canonical v1.0
PRIORITY 2: Frozen Baseline Phase 01–10
PRIORITY 3: SH Full Build Scope v1.0
PRIORITY 4: SH Full Implementation Contract v1.0
PRIORITY 5: SH Full Implementation Guide v1.0
PRIORITY 6: Canonical Architecture Diagram (Master Diagram)
PRIORITY 7: Execution Strategy v1.0
PRIORITY 8: Dokumen ini (Risk Register)
PRIORITY 9: Source Code / Repository

Dokumen ini tidak boleh:

- Mengubah authority yang lebih tinggi.
- Mengubah requirement.
- Mengubah arsitektur.
- Mengubah invariant.
- Mengubah scope.
- Menutup risiko tanpa validasi.
- Menyembunyikan risiko yang masih aktif.

1.3 Purpose

Dokumen ini menjawab pertanyaan:

"RISIKO apa saja yang dapat menghambat, menggagalkan, atau menyimpangkan implementasi SH Full, dan bagaimana risiko tersebut dikelola secara sistematis?"

Dokumen ini TIDAK menjawab:

- "Apa yang harus dibangun?" → dijawab oleh Build Scope.
- "Bagaimana sistem harus dibangun?" → dijawab oleh Implementation Contract dan Guide.
- "Kapan dibangun?" → dijawab oleh Milestone Mapping dan Sprint Plan.

2. RISK MANAGEMENT FRAMEWORK

2.1 Risk Principles

1. Risiko harus diidentifikasi sedini mungkin.
2. Seluruh risiko memiliki owner yang jelas.
3. Setiap risiko memiliki tingkat prioritas.
4. Mitigasi harus terdokumentasi.
5. Status risiko selalu diperbarui.
6. Risiko yang ditutup tetap disimpan sebagai evidence.
7. Risk Management tidak boleh mengubah Authority.
8. Risk Management tidak boleh mengubah Requirement.
9. Risk Management tidak boleh menghilangkan evidence.
10. Risk Management tidak boleh menutup risiko tanpa validasi.
11. Risk Management tidak boleh menyembunyikan risiko yang masih aktif.

2.2 Risk Classification

| Kategori | Deskripsi | Contoh |
|---|---|---|
| Technical Risk | Kegagalan implementasi, dependency conflict, integrasi gagal, kehilangan data. | Schema migration gagal, API provider berubah, RLS misconfiguration. |
| Operational Risk | Deployment gagal, monitoring tidak berjalan, backup tidak tersedia. | Supabase outage, Groq rate limit, CI/CD failure. |
| Governance Risk | Pelanggaran Authority, perubahan tanpa approval, requirement tidak terdokumentasi. | Scope creep, architecture drift, silent canonical change. |
| Security Risk | Akses tidak sah, kebocoran data, privilege escalation. | RLS bypass, JWT manipulation, cross-SH data leak. |
| Project Risk | Keterlambatan implementasi, kekurangan resource, perubahan scope. | Mobile-first constraint, zero-budget limitation, timeline slip. |

2.3 Risk Assessment Attributes

- Risk ID
- Description
- Category
- Cause
- Impact
- Probability (Low / Medium / High)
- Severity (Low / Medium / High / Critical)
- Priority (Low / Medium / High / Critical)
- Owner
- Mitigation Plan
- Current Status (Open / Mitigating / Resolved / Accepted)

2.4 Risk Lifecycle

Identification → Assessment → Prioritization → Mitigation → Monitoring → Review → Closure

Seluruh perubahan status harus terdokumentasi.

2.5 Mitigation Strategy

- Avoidance: Menghindari risiko dengan mengubah pendekatan.
- Reduction: Mengurangi probabilitas atau dampak risiko.
- Transfer: Memindahkan risiko ke pihak lain.
- Acceptance: Menerima risiko dengan dokumentasi dan contingency plan.

Strategi yang dipilih harus disertai alasan yang jelas.

2.6 Risk Evidence

Evidence minimal meliputi:

- Risk Register (dokumen ini).
- Risk Assessment.
- Mitigation Plan.
- Validation Report.
- Risk Review Record.

3. RISK REGISTER — TECHNICAL RISKS

| Risk ID | Description | Probability | Severity | Priority | Mitigation Plan | Status |
|---|---|---|---|---|---|---|
| TR-001 | Database schema migration gagal atau data loss | Medium | Critical | Critical | Migration script teruji, backup sebelum migration, rollback plan | Open |
| TR-002 | AI model provider API berubah/didepresiasi | Medium | High | High | Model abstraction layer, fallback model | Open |
| TR-003 | Context window limitation | High | Medium | High | Deterministic truncation, prioritaskan identity/safety | Open |
| TR-004 | RLS policy misconfiguration | Low | Critical | Critical | Audit RLS sebelum deployment, cross-owner access test | Open |
| TR-005 | Atomic conversation persistence gagal | Low | High | High | PostgreSQL Function/RPC, rollback verification | Open |
| TR-006 | Memory extraction non-deterministic | High | Medium | Medium | Code-level validation, unique index | Open |
| TR-007 | Groq API rate limiting | Medium | Medium | Medium | Retry logic, fallback provider | Open |
| TR-008 | Supabase Edge Function deployment gagal | Low | High | High | Environment variable checklist, rollback plan | Open |
| TR-009 | SH_ID mapping conflict | Medium | High | High | Dokumentasikan sebagai implementation mapping, siapkan migration path | Open |
| TR-010 | Context Builder read-only boundary dilanggar | Low | Critical | Critical | Code review, automated test | Open |

4. RISK REGISTER — OPERATIONAL RISKS

| Risk ID | Description | Probability | Severity | Priority | Mitigation Plan | Status |
|---|---|---|---|---|---|---|
| OR-001 | Deployment gagal/downtime | Low | High | High | CI/CD testing, staging, rollback, health check | Open |
| OR-002 | Monitoring tidak berjalan | Medium | Medium | Medium | Konfigurasi sebelum deployment | Open |
| OR-003 | Backup tidak tersedia/tidak teruji | Medium | Critical | Critical | Backup script sebelum Phase 1, restore test | Open |
| OR-004 | Supabase service outage | Low | High | High | Monitor status, fallback plan | Open |
| OR-005 | Groq API outage/degradation | Medium | Medium | Medium | Monitor status, fallback provider | Open |
| OR-006 | Environment variable missing/incorrect | Medium | High | High | Checklist, pre-deployment verification | Open |

5. RISK REGISTER — GOVERNANCE RISKS

| Risk ID | Description | Probability | Severity | Priority | Mitigation Plan | Status |
|---|---|---|---|---|---|---|
| GR-001 | Architecture drift | Medium | Critical | Critical | Drift Detection, Architecture Checklist, Review per sprint | Open |
| GR-002 | Scope creep | Medium | High | High | No Silent Scope Expansion, Change Control | Open |
| GR-003 | Silent canonical change | Low | Critical | Critical | Authority First, Canonical Before Convenience | Open |
| GR-004 | Requirement tidak terdokumentasi | Medium | Medium | Medium | Documentation requirement, traceability | Open |
| GR-005 | Open Decisions tidak terselesaikan tepat waktu | Medium | High | High | OQ tracking, priority-based resolution | Open |
| GR-006 | Cross-phase dependency conflict | Medium | Medium | Medium | Backward Revision Rule | Open |

6. RISK REGISTER — SECURITY RISKS

| Risk ID | Description | Probability | Severity | Priority | Mitigation Plan | Status |
|---|---|---|---|---|---|---|
| SR-001 | Cross-SH data leak via RLS bypass | Low | Critical | Critical | DEFAULT DENY, RLS audit, cross-owner test | Open |
| SR-002 | JWT token manipulation/replay | Low | Critical | Critical | JWT validation, token expiry | Open |
| SR-003 | Privilege escalation via service role | Low | Critical | Critical | Service role key tidak di client | Open |
| SR-004 | Prompt injection via user input | Medium | High | High | Untrusted input, system directive priority | Open |
| SR-005 | Memory extraction menyimpan data sensitif | Medium | Medium | Medium | Extraction validation, owner-scoped | Open |
| SR-006 | Creator/SH-000 authority boundary dilanggar | Low | Critical | Critical | Permission Matrix, Access Decision Gate | Open |

7. RISK REGISTER — PROJECT RISKS

| Risk ID | Description | Probability | Severity | Priority | Mitigation Plan | Status |
|---|---|---|---|---|---|---|
| PR-001 | Zero-Budget constraint membatasi implementasi | High | Medium | High | Free-first, open-source-first, vendor-agnostic | Open |
| PR-002 | Zero-Hardware constraint | Medium | Medium | Medium | Mobile-first workflow, remote dev | Open |
| PR-003 | Mobile-first development challenge | Medium | Medium | Medium | Workflow optimization, remote tools | Open |
| PR-004 | Timeline slip karena complexity | Medium | Medium | Medium | Realistic timeline, buffer, dependency tracking | Open |
| PR-005 | Resource constraint (single developer) | High | Medium | Medium | Vertical Slice, clear DoD, evidence-based | Open |
| PR-006 | Open Questions tidak terselesaikan sebelum milestone | Medium | High | High | OQ tracking per milestone | Open |

8. OPEN DECISION RISK MAPPING

| Open Decision | Related Risk | Target Phase |
|---|---|---|
| OQ-01: Technology Stack | TR-002, TR-008, OR-004, OR-005, PR-001 | Phase 0 |
| OQ-02: Memory Decision | TR-006, SR-005 | Phase 3 |
| OQ-03: Knowledge Ingestion | TR-003 | Phase 3 |
| OQ-04: Reference Material Trust | SR-004 | Phase 3 |
| OQ-05: Clone Agreement | GR-002, SR-006 | Phase 5 |
| OQ-06: Model Selection Policy | TR-002, TR-007 | Phase 4 |
| OQ-07: Backup / Restore | OR-003 | Phase 5 |
| OQ-08: Data Portability Format | OR-003 | Phase 5 |
| OQ-09: Decision Record Format | GR-004, GR-005 | Phase -1 |

Open Decision Resolution Priority:

- P0 (Immediate): OQ-01, OQ-09
- P1 (Before Phase 3): OQ-02, OQ-03, OQ-04
- P2 (Before Phase 4): OQ-06
- P3 (Before Phase 5): OQ-05, OQ-07, OQ-08

9. RISK REGISTER SUMMARY

| Category | Count | Critical | High | Medium |
|---|---|---|---|---|
| Technical | 10 | 3 | 4 | 3 |
| Operational | 6 | 1 | 3 | 2 |
| Governance | 6 | 2 | 2 | 2 |
| Security | 6 | 4 | 1 | 1 |
| Project | 6 | 0 | 2 | 4 |
| Total | 34 | 10 | 12 | 12 |

Top 10 Risks by Priority:

1. TR-001 — Database schema migration gagal (Critical)
2. TR-004 — RLS policy misconfiguration (Critical)
3. TR-010 — Context Builder read-only boundary dilanggar (Critical)
4. OR-003 — Backup tidak tersedia (Critical)
5. GR-001 — Architecture drift (Critical)
6. GR-003 — Silent canonical change (Critical)
7. SR-001 — Cross-SH data leak (Critical)
8. SR-002 — JWT token manipulation (Critical)
9. SR-003 — Privilege escalation (Critical)
10. SR-006 — Creator/SH-000 authority boundary dilanggar (Critical)

10. RISK MONITORING & REVIEW

Monitoring Frequency:

- Technical/Operational/Project: per sprint.
- Governance/Security: per phase.

Review pada: Sprint Review, Phase Transition, Milestone Review, Ad-hoc.

11. RISK ESCALATION

Eskalasi ke Owner jika:

- Severity/Priority = Critical.
- Mitigasi tidak efektif setelah 2 sprint.
- Menghambat phase transition.
- Memerlukan perubahan scope/arsitektur/invariant.

12. RISK REGISTER CONSTRAINTS

Risk Register tidak boleh:

- Mengubah Authority.
- Mengubah Requirement.
- Mengubah Arsitektur.
- Mengubah Invariant.
- Mengubah Scope.
- Menghilangkan evidence.
- Menutup risiko tanpa validasi.
- Menyembunyikan risiko yang masih aktif.

13. DOCUMENT CONTROL

Document: SECOND_HEAD_PHASE_MINUS_1_RISK_REGISTER_v1.0
Version: v1.0
Status: FINAL
Authority Level: Derived Operational Document (Below Execution Strategy)

END OF SECOND_HEAD_PHASE_MINUS_1_RISK_REGISTER_v1.0

================================================================================
[7/9] SECOND_HEAD_PHASE_MINUS_1_RESOURCE_ALLOCATION_PLAN_v1.0
Role: ARTEFAK PHASE -1 — RESOURCE ALLOCATION PLAN
Source: Phase -1 Planning
Status: FINAL
================================================================================

SECOND_HEAD_PHASE_MINUS_1_RESOURCE_ALLOCATION_PLAN_v1.0

Project: SECOND HEAD — SYSTEM BUILD
Document Type: Phase -1 Artifact — Resource Allocation Plan
Version: v1.0
Status: FINAL
Authority Level: Derived Operational Document (Phase -1 Output)

1. DOCUMENT STATUS & AUTHORITY

1.1 Status

Dokumen ini adalah Resource Allocation Plan untuk Phase -1 Planning.

Dokumen ini merupakan turunan operasional dari:

- SECOND_HEAD_SH_FULL_EXECUTION_STRATEGY_v1.0 (Section 19: Constraints)
- SECOND_HEAD_SH_FULL_BUILD_SCOPE_v1.0 (Build Constraints)
- SECOND_HEAD_SH_FULL_IMPLEMENTATION_CONTRACT_v1.0

1.2 Authority Hierarchy

PRIORITY 1: SH Core Canonical v1.0
PRIORITY 2: Frozen Baseline Phase 01–10
PRIORITY 3: SH Full Build Scope v1.0
PRIORITY 4: SH Full Implementation Contract v1.0
PRIORITY 5: SH Full Implementation Guide v1.0
PRIORITY 6: Canonical Architecture Diagram (Master Diagram)
PRIORITY 7: Execution Strategy v1.0
PRIORITY 8: Dokumen ini (Resource Allocation Plan)
PRIORITY 9: Source Code / Repository

1.3 Purpose

Dokumen ini menjawab pertanyaan:

"SIAPA mengerjakan APA, dengan RESOURCE APA, dan dalam CONSTRAINT apa?"

Dokumen ini TIDAK menjawab:

- "Apa yang harus dibangun?" → Build Scope.
- "Bagaimana cara membangunnya?" → Implementation Guide.
- "Kapan dibangun?" → Timeline Estimation.

1.4 Capacity Interpretation Note

Kapasitas yang didefinisikan di dokumen ini (2–4 jam/hari × 4–6 hari/minggu) adalah MAXIMUM AVAILABILITY, bukan committed sprint capacity.

Sprint Plan menetapkan 24 jam efektif sebagai PLANNING CAPACITY CAP PER SPRINT.

Interpretasi final:

- Available time ≠ committed sprint capacity.
- 24h = commitment ceiling per sprint, bukan entitlement.
- Untuk sprint 2 minggu, cap 24h tetap berlaku sebagai committed capacity.
- Ini menjaga sustainability dan mencegah overcommitment.

2. RESOURCE CONSTRAINTS (LOCKED)

2.1 Zero Budget Constraint

Tidak boleh ada mandatory paid dependency untuk membuat core SH Full dapat dibangun dan diuji pada tahap awal.

Implikasi:

- Seluruh tooling harus memiliki free tier yang memadai.
- AI model provider harus memiliki free tier atau local option.
- Database harus menggunakan free tier.
- CI/CD harus menggunakan free tier.
- Hosting harus menggunakan free tier.
- Paid upgrade hanya OPTIONAL, bukan MANDATORY.

2.2 Zero Hardware Cost Constraint

Tidak boleh ada mandatory hardware purchase sebagai prasyarat awal pembangunan.

Implikasi:

- Development dapat dilakukan dari existing device.
- Tidak perlu membeli server fisik.
- Tidak perlu membeli GPU dedicated.
- Cloud/remote resource boleh digunakan selama free.

2.3 Mobile-First Constraint

Pengembangan dilakukan dengan workflow mobile-first.

Implikasi:

- Coding dapat dilakukan dari mobile device.
- Testing dapat dilakukan dari mobile device.
- Deployment dapat dilakukan dari mobile device.
- Remote development diperbolehkan jika mobile tidak cukup.
- BUKAN berarti mobile-only. Desktop/laptop boleh digunakan jika tersedia.

2.4 Technology Independence Constraint

Implementasi tidak boleh terkunci pada satu vendor atau platform.

Implikasi:

- Model AI harus dapat diganti.
- Database harus dapat dimigrasikan.
- Runtime harus dapat dipindahkan.
- Provider harus dapat di-switch.
- Abstraction layer harus dibangun untuk setiap external dependency.

3. ROLE ALLOCATION

3.1 Owner / Gatekeeper

Role: Decision Maker, Reviewer, Approver.

Tanggung jawab:

- Menyetujui atau menolak setiap phase transition.
- Menyetujui atau menolak setiap architectural decision.
- Menyetujui atau menolak setiap scope change.
- Melakukan review terhadap evidence.
- Melakukan ratifikasi terhadap closure.
- Menyelesaikan Open Questions yang memerlukan keputusan.
- Menetapkan prioritas jika ada konflik resource.

Batasan:

- Owner tidak perlu menulis kode.
- Owner tidak perlu melakukan debugging teknis.
- Owner tidak perlu mengelola infrastructure secara langsung.
- Owner fokus pada decision, review, dan approval.

3.2 AI Assistant / Implementation Agent

Role: Drafter, Implementer, Tester, Documenter.

Tanggung jawab:

- Menyusun draft dokumen dan artifact.
- Menulis kode implementasi.
- Menulis migration scripts.
- Menulis test cases.
- Menulis documentation.
- Melakukan self-review sebelum submit ke Owner.
- Menyiapkan evidence untuk review Owner.
- Melaksanakan instruksi Owner.

Batasan:

- AI tidak boleh mengubah canonical tanpa approval Owner.
- AI tidak boleh memperluas scope tanpa approval Owner.
- AI tidak boleh melakukan deployment production tanpa approval Owner.
- AI tidak boleh menghapus data tanpa approval Owner.
- AI tidak boleh membuat keputusan arsitektural fundamental tanpa review Owner.

3.3 Role Interaction Model

Owner → Memberikan instruksi / keputusan, Review & approve / reject, Menyelesaikan Open Questions, Ratifikasi closure
↓
AI Assistant → Draft & implement, Self-review, Submit evidence, Execute approved decisions
↓
Output / Artifact / Code
↓
Review oleh Owner

Tidak ada role ketiga pada tahap ini.

Jika di masa depan diperlukan role tambahan (misal: dedicated tester, security auditor), harus melalui keputusan Owner.

4. TECHNOLOGY STACK ALLOCATION

4.1 Stack Saat Ini (Inherited from SH Lite V2.0/V2.1)

| Layer | Technology | Status | Constraint |
|---|---|---|---|
| Frontend | React Native (Expo) | EXISTING | Mobile-first |
| Backend | Supabase Edge Functions (Deno) | EXISTING | Free tier |
| Database | Supabase PostgreSQL | EXISTING | Free tier |
| Authentication | Supabase Auth | EXISTING | Free tier |
| AI Model | Groq (llama-3.1-8b-instant) | EXISTING | Free tier |
| Image Generation | Pollinations AI (client-side) | EXISTING | Free tier |
| Storage | Supabase Storage | EXISTING | Free tier |

CATATAN: Stack di atas adalah inherited/reference dari SH Lite. SH Full stack tetap OQ-01 OPEN. Lihat Downstream Blockers Register. Implementation agent TIDAK BOLEH mengasumsikan stack ini sebagai keputusan final untuk SH Full tanpa Owner decision.

4.2 Stack untuk SH Full (Phase 0 Decision Pending)

Technology stack final untuk SH Full belum diputuskan.

Ini adalah OQ-01: Technology Stack yang masih OPEN.

Namun, berdasarkan constraint yang ada, stack harus memenuhi:

- Free tier available.
- Mobile-first compatible.
- Vendor-agnostic (dapat diganti).
- Mendukung RLS atau equivalent isolation.
- Mendukung edge/serverless execution.
- Mendukung relational database.
- Mendukung authentication.
- Mendukung file storage.

4.3 Stack Decision Authority

Keputusan technology stack:

- Diusulkan oleh AI Assistant.
- Diputuskan oleh Owner.
- Dicatat dalam ADR.
- Tidak boleh diubah tanpa change control.

4.4 Abstraction Layer Requirement

| Dependency | Abstraction | Purpose |
|---|---|---|
| AI Model Provider | Model Abstraction Layer | Memungkinkan ganti provider tanpa ubah SH_ID |
| Database | Data Access Layer | Memungkinkan migrasi DB tanpa ubah logic |
| Authentication | Auth Abstraction Layer | Memungkinkan ganti auth provider |
| Storage | Storage Abstraction Layer | Memungkinkan ganti storage provider |
| Runtime | Runtime Abstraction Layer | Memungkinkan ganti runtime environment |

5. INFRASTRUCTURE ALLOCATION

5.1 Development Environment

| Resource | Allocation | Notes |
|---|---|---|
| Code Editor | Mobile-compatible IDE / Remote IDE | Harus bisa diakses dari mobile |
| Version Control | GitHub (free tier) | Branching strategy sesuai Sprint Plan |
| Database | Supabase (free tier) | Development project terpisah dari production |
| Edge Functions | Supabase Edge Functions | Deno runtime |
| AI Model | Groq free tier / fallback | Harus ada fallback jika rate limit |
| CI/CD | GitHub Actions (free tier) | Automated testing |
| Documentation | Markdown files dalam repository | Version-controlled |

5.2 Environment Separation

| Environment | Purpose | Data |
|---|---|---|
| Development | Coding & testing | Test data only |
| Staging (optional) | Pre-production validation | Synthetic data |
| Production | Live system | Real data |

Pada tahap awal, Development dan Staging boleh digabung jika resource terbatas.

Production tidak boleh disentuh sampai Phase 6 (Assurance & Release).

5.3 Repository Structure

Repository structure akan didefinisikan secara detail pada Phase 0.

Namun prinsip dasarnya:

second-head/
├── docs/
│   ├── canonical/
│   ├── phase-1/
│   ├── adr/
│   └── evidence/
├── src/
├── database/
├── tests/
├── scripts/
├── .github/
└── README.md

Detail final akan diputuskan pada Phase 0.

6. TIME ALLOCATION

6.1 Sprint Duration

Sprint duration default: 1 minggu (7 hari).

Sprint duration dapat disesuaikan berdasarkan:

- Kompleksitas task.
- Availability Owner.
- Dependency eksternal.
- Risk level.

Sprint duration tidak boleh lebih dari 2 minggu tanpa persetujuan Owner.

6.2 Time Allocation Per Sprint

| Activity | Allocation | Notes |
|---|---|---|
| Planning & Review | 10-15% | Sprint planning, review, retrospective |
| Implementation | 50-60% | Coding, migration, configuration |
| Testing & Verification | 20-25% | Unit test, integration test, evidence |
| Documentation | 5-10% | Update docs, ADR, evidence capture |

Ini adalah alokasi konseptual, bukan aturan kaku. Aktual allocation dapat bervariasi per sprint.

6.3 Owner Time Commitment

Owner diharapkan tersedia untuk:

- Sprint review: ~15-30 menit per sprint.
- Decision making: sesuai kebutuhan (async OK).
- Evidence review: ~15-30 menit per phase transition.
- Open Question resolution: sesuai kebutuhan.

Owner tidak diharapkan:

- Hadir real-time selama coding.
- Melakukan debugging.
- Menulis kode.
- Mengelola infrastructure.

6.4 AI Assistant Availability

- On-demand (ketika Owner memulai session).
- Tidak ada background processing.
- Tidak ada autonomous execution tanpa instruksi Owner.
- Setiap session dimulai dengan context loading.

7. TOOLING ALLOCATION

7.1 Development Tools

| Tool | Purpose | Constraint |
|---|---|---|
| Code Editor | Writing code | Mobile-compatible atau remote |
| Terminal/Shell | Running commands | Mobile-compatible atau remote |
| Git | Version control | Free |
| GitHub | Repository hosting | Free tier |
| Supabase Dashboard | Database management | Free tier |
| AI Chat | Drafting & implementation | Free tier |

7.2 Testing Tools

| Tool | Purpose | Constraint |
|---|---|---|
| Unit Test Framework | Component testing | Free, open-source |
| Integration Test Framework | Cross-component testing | Free, open-source |
| Manual Testing | UI/UX verification | Mobile device |
| Evidence Capture | Screenshot, log, query result | Built-in |

7.3 Documentation Tools

| Tool | Purpose | Constraint |
|---|---|---|
| Markdown | Documentation format | Free, universal |
| Version Control | Documentation versioning | Git |
| Diagram (text-based) | Architecture diagrams | ASCII/Markdown |

7.4 Monitoring Tools (Phase 6+)

| Tool | Purpose | Constraint |
|---|---|---|
| Logging | Error tracking | Free tier / built-in |
| Health Check | System status | Built-in |
| Audit Trail | Action tracking | Database-based |

Monitoring tools detail akan diputuskan pada Phase 6.

Pada tahap awal, monitoring boleh menggunakan built-in logging dan database audit.

8. KNOWLEDGE & CONTEXT ALLOCATION

8.1 Document Hierarchy

AI Assistant harus selalu memiliki akses ke:

| Priority | Document | Purpose |
|---|---|---|
| 1 | SH Core Canonical v1.0 | Conceptual authority |
| 2 | Frozen Baseline Phase 01-10 | Architecture authority |
| 3 | SH Full Build Scope v1.0 | Build authority |
| 4 | SH Full Implementation Contract v1.0 | Implementation authority |
| 5 | SH Full Implementation Guide v1.0 | Technical guide |
| 6 | Canonical Architecture Diagram | Visual reference |
| 7 | Execution Strategy v1.0 | Execution plan |
| 8 | Phase -1 Artifacts | Planning artifacts |
| 9 | SH Lite V2.0/V2.1 Documentation | Implementation reference |

8.2 Context Loading

Setiap session baru, AI Assistant harus:

1. Load seluruh canonical documents.
2. Load Execution Strategy.
3. Load Phase -1 artifacts yang relevan.
4. Load current sprint context.
5. Load any pending decisions atau open questions.

8.3 Knowledge Boundary

AI Assistant TIDAK boleh:

- Mengubah canonical documents.
- Mengubah frozen baseline.
- Mengubah approved contracts.
- Membuat asumsi di luar dokumen yang ada.
- Menginvent solusi untuk Open Questions tanpa approval Owner.

9. RISK-RELATED RESOURCE ALLOCATION

9.1 Risk Buffer

Setiap sprint harus memiliki buffer untuk:

- Unexpected debugging.
- Rework akibat review feedback.
- Open Question resolution.
- Technical debt yang teridentifikasi.

Buffer konseptual: 15-20% dari sprint capacity.

9.2 Contingency Allocation

Jika terjadi blocker kritis:

- Sprint dapat di-pause.
- Resource dapat dialihkan ke blocker resolution.
- Timeline dapat disesuaikan dengan approval Owner.
- Scope TIDAK boleh diperluas sebagai kompensasi.

9.3 Fallback Resources

| Scenario | Fallback |
|---|---|
| AI Model rate limit | Switch ke model lain / tunggu reset |
| Database free tier limit | Optimize query / cleanup test data |
| CI/CD limit | Run test locally |
| Storage limit | Cleanup unused artifacts |
| Network issue | Offline work, sync later |

10. COMMUNICATION ALLOCATION

10.1 Communication Model

- Asynchronous: Owner memberikan instruksi, AI melaksanakan, Owner review.
- Session-based: Setiap interaksi adalah satu session.
- Evidence-based: Setiap klaim harus didukung evidence.

10.2 Decision Escalation

Issue Detected → Classify (Technical / Architectural / Scope / Canonical) → IF Technical: AI resolves, document in evidence → IF Architectural: AI proposes, Owner decides → IF Scope: STOP, Owner decides → IF Canonical: STOP, Owner decides, governance review

10.3 Reporting Cadence

| Event | Report |
|---|---|
| Sprint completion | Sprint Review Report |
| Phase completion | Phase Closure Report + Evidence |
| Blocker detected | Blocker Report |
| Risk materialized | Risk Update Report |
| Open Question resolved | Decision Record |

11. PHASE-SPECIFIC RESOURCE NOTES

11.1 Phase 0 (Infrastructure)

Resource focus: Supabase project setup, Repository initialization, CI/CD pipeline configuration, Testing framework setup, Development environment validation.

Constraint check: Seluruh setup harus free. Seluruh setup harus bisa dilakukan dari mobile/remote. Tidak boleh ada hardware purchase.

11.2 Phase 1 (Constitution & Identity)

Resource focus: Database schema design, Identity resolution logic, RLS policy implementation, Constitution registry.

Constraint check: SH_ID harus persistent. 1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH harus enforced. DEFAULT DENY harus aktif.

CATATAN: Phase 1 memerlukan SH_ID exact format dan Creator SH reserved identifier (SH-000) yang masih MISSING. Lihat Downstream Blockers Register.

11.3 Phase 2 (Governance)

Resource focus: Permission matrix implementation, Policy enforcement engine, Access decision gate.

Constraint check: Creator Authority ≠ Private Data Access harus terverifikasi. SH-000 Authority ≠ Private Data Access harus terverifikasi.

11.4 Phase 3 (Cognitive Foundation)

Resource focus: Memory pipeline implementation, Knowledge engine implementation, Context assembly implementation.

Constraint check: MEMORY ≠ KNOWLEDGE ≠ CONTEXT harus terverifikasi. Context budget harus bounded. Retrieval harus deterministic.

CATATAN: Phase 3 memerlukan OQ-02, OQ-03, OQ-04 resolved. Lihat Downstream Blockers Register.

11.5 Phase 4 (Runtime)

Resource focus: Runtime core loop, Model orchestration, Tool/Action execution framework.

Constraint check: RUNTIME ≠ SH IDENTITY harus terverifikasi. MODEL ≠ SH IDENTITY harus terverifikasi. Zero-budget model path harus tersedia.

CATATAN: Phase 4 memerlukan OQ-06 resolved untuk Phase 4D. Lihat Downstream Blockers Register.

11.6 Phase 5 (Advanced Capabilities)

Resource focus: Journey tracking, Clone mechanism, Inheritance mechanism, Recovery mechanism.

Constraint check: CLONE_SH ≠ SOURCE_SH harus terverifikasi. CREATOR_SH NON-CLONABLE harus terverifikasi. Recovery ≠ New SH harus terverifikasi.

CATATAN: Phase 5 memerlukan OQ-05, OQ-07, OQ-08 resolved. Lihat Downstream Blockers Register.

11.7 Phase 6 (Assurance & Release)

Resource focus: Integration testing, Security audit, Performance validation, Documentation finalization.

Constraint check: Seluruh acceptance criteria harus PASS. Seluruh evidence harus tersedia. Final Integration Gate harus PASS.

12. RESOURCE ALLOCATION INVARIANTS

1. Zero Budget: Tidak ada mandatory paid dependency.
2. Zero Hardware: Tidak ada mandatory hardware purchase.
3. Mobile-First: Workflow harus mobile-first.
4. Technology Independence: Tidak boleh vendor lock-in.
5. Owner Decision: Keputusan resource final ada di Owner.
6. Evidence-Based: Setiap klaim resource harus didukung evidence.
7. No Silent Expansion: Resource tidak boleh diperluas tanpa approval.
8. Canonical Preservation: Resource allocation tidak boleh mengubah canonical.

13. OPEN RESOURCE QUESTIONS

| ID | Question | Status | Blocking |
|---|---|---|---|
| ORQ-01 | Technology stack final untuk SH Full | OPEN (OQ-01) | Phase 0 |
| ORQ-02 | Apakah perlu staging environment terpisah | OPEN | Phase 0 |
| ORQ-03 | AI model fallback strategy jika Groq rate limit | OPEN | Phase 4 |
| ORQ-04 | Apakah perlu dedicated test database | OPEN | Phase 0 |
| ORQ-05 | Monitoring tooling untuk Phase 6 | OPEN | Phase 6 |

Open Resource Questions ini harus diselesaikan sebelum phase yang bergantung padanya dimulai.

14. RESOURCE ALLOCATION MATRIX SUMMARY

| Phase | Primary Resource | Constraint | Risk |
|---|---|---|---|
| Phase -1 | Planning time, AI drafting | Zero cost | Low |
| Phase 0 | Supabase free tier, GitHub free tier | Zero budget, mobile-first | Low |
| Phase 1 | Database, RLS, Identity logic | Zero budget | Medium |
| Phase 2 | Policy engine, Permission matrix | Zero budget | Medium |
| Phase 3 | Memory/Knowledge/Context pipeline | Zero budget, model free tier | High |
| Phase 4 | Runtime, Model orchestration | Zero budget, model free tier | High |
| Phase 5 | Clone/Inheritance/Recovery | Zero budget | High |
| Phase 6 | Testing, Audit, Documentation | Zero budget | Medium |

15. DOCUMENT CONTROL

Document: SECOND_HEAD_PHASE_MINUS_1_RESOURCE_ALLOCATION_PLAN_v1.0
Version: v1.0
Status: FINAL
Authority Level: Derived Operational Document (Phase -1 Output)

END OF SECOND_HEAD_PHASE_MINUS_1_RESOURCE_ALLOCATION_PLAN_v1.0

================================================================================
[8/9] SECOND_HEAD_PHASE_MINUS_1_BACKLOG_DEFINITION_v1.0
Role: ARTEFAK PHASE -1 — BACKLOG DEFINITION
Source: Phase -1 Planning
Status: FINAL
================================================================================

SECOND_HEAD_PHASE_MINUS_1_BACKLOG_DEFINITION_v1.0

Project: SECOND HEAD — SYSTEM BUILD
Document Type: Phase -1 Artifact — Backlog Definition
Version: v1.0
Status: FINAL
Authority Level: Derived Operational Document (Phase -1 Output)

0. DOCUMENT STATUS & AUTHORITY

0.1 Status

Dokumen ini adalah Backlog Definition untuk Phase -1 Planning.

Dokumen ini merupakan turunan operasional dari:

- Execution Strategy v1.0 (Seven-Phase Execution Roadmap)
- Build Scope v1.0 (Build Requirements)
- Implementation Contract v1.0 (Acceptance Criteria)
- Milestone Mapping v1.0 (Phase-to-Milestone Mapping)
- Task Breakdown v1.0 (Work Decomposition)
- Dependency Map v1.0 (Execution Order)
- Risk Register v1.0 (Risk Assessment)

0.2 Authority Hierarchy

PRIORITY 1: SH Core Canonical v1.0
PRIORITY 2: Frozen Baseline Phase 01–10
PRIORITY 3: SH Full Build Scope v1.0
PRIORITY 4: SH Full Implementation Contract v1.0
PRIORITY 5: SH Full Implementation Guide v1.0
PRIORITY 6: Canonical Architecture Diagram
PRIORITY 7: Execution Strategy v1.0
PRIORITY 8: Dokumen ini (Backlog Definition)
PRIORITY 9: Source Code / Repository

0.3 Backlog Principles

1. Setiap backlog item traceable ke minimal satu authority document.
2. Setiap backlog item memiliki acceptance criteria reference.
3. Setiap backlog item memiliki dependency yang jelas.
4. Tidak boleh melanggar canonical invariants.
5. Tidak boleh memperluas scope tanpa Owner approval.
6. Mengikuti vertical slice development principle.
7. Harus dapat diverifikasi melalui evidence.

1. BACKLOG ID CONVENTION

1.1 Format

BL-[PHASE]-[SEQUENCE]

Contoh:

- BL-P0-001 → Phase 0, item ke-1
- BL-P1-003 → Phase 1, item ke-3
- BL-P3A-002 → Phase 3A, item ke-2
- BL-P5-007 → Phase 5, item ke-7

1.2 Priority Levels

- P0 — CRITICAL: Harus selesai. Phase gagal jika tidak selesai.
- P1 — HIGH: Harus selesai sebelum phase berikutnya dimulai.
- P2 — MEDIUM: Penting, dapat ditunda satu sprint jika diperlukan.
- P3 — LOW: Nice to have, dapat ditunda tanpa dampak signifikan.

1.3 Status Values

- TODO — Belum dimulai.
- IN PROGRESS — Sedang dikerjakan.
- TESTING — Menunggu testing / dalam proses testing.
- REVIEW — Menunggu review.
- DONE — Selesai dan terverifikasi.
- BLOCKED — Terblokir oleh dependency.
- CANCELLED — Dibatalkan (dengan alasan).

State machine: TODO → IN PROGRESS → TESTING → REVIEW → DONE, dengan cabang BLOCKED dan CANCELLED.

2. PHASE 0 — INFRASTRUCTURE & DEVELOPMENT FOUNDATION

Epic P0-A: Infrastructure Foundation

| ID | Item | Priority | Dependency | AC Ref |
|---|---|---|---|---|
| BL-P0-001 | Supabase Project Setup | P0 | None | AC-INFRA-01 |
| BL-P0-002 | Authentication Configuration | P0 | BL-P0-001 | AC-INFRA-02 |
| BL-P0-003 | Storage / Bucket Configuration | P1 | BL-P0-001 | AC-INFRA-03 |
| BL-P0-004 | Extension Setup | P1 | BL-P0-001 | AC-INFRA-04 |
| BL-P0-005 | Migration Framework | P0 | BL-P0-001 | AC-INFRA-05 |
| BL-P0-006 | Seed Data Structure | P2 | BL-P0-005 | AC-INFRA-06 |
| BL-P0-007 | Environment Configuration | P0 | BL-P0-001 | AC-INFRA-07 |
| BL-P0-008 | RLS Foundation | P0 | BL-P0-001 | AC-INFRA-08 |
| BL-P0-009 | Audit Table Foundation | P1 | BL-P0-001 | AC-INFRA-09 |
| BL-P0-010 | Shared Types | P1 | BL-P0-001 | AC-INFRA-10 |

Epic P0-B: Development Foundation

| ID | Item | Priority | Dependency | AC Ref |
|---|---|---|---|---|
| BL-P0-011 | Linting Configuration | P1 | None | AC-DEV-01 |
| BL-P0-012 | Formatting Configuration | P1 | None | AC-DEV-02 |
| BL-P0-013 | CI Pipeline Setup | P1 | BL-P0-011, BL-P0-012 | AC-DEV-03 |
| BL-P0-014 | Branching Strategy | P1 | None | AC-DEV-04 |
| BL-P0-015 | Commit Convention | P2 | None | AC-DEV-05 |
| BL-P0-016 | Migration Tooling | P1 | BL-P0-005 | AC-DEV-06 |
| BL-P0-017 | Folder Structure | P1 | None | AC-DEV-07 |
| BL-P0-018 | Testing Framework | P0 | None | AC-DEV-08 |
| BL-P0-019 | Code Review Process | P2 | None | AC-DEV-09 |
| BL-P0-020 | Documentation Standard | P2 | None | AC-DEV-10 |

Phase 0 DoD Reference:

Phase 0 dianggap DONE jika:

- Seluruh BL-P0-001 s/d BL-P0-010 berstatus DONE.
- Seluruh BL-P0-011 s/d BL-P0-020 berstatus DONE.
- Evidence tersedia dan terverifikasi.

3. PHASE 1 — CONSTITUTION & IDENTITY

Epic P1-A: Constitution

| ID | Item | Priority | Dependency | AC Ref |
|---|---|---|---|---|
| BL-P1A-001 | Immutable Core Definition | P0 | Phase 0 DONE | AC-CONST-01 |
| BL-P1A-002 | Evolvable Core Definition | P0 | BL-P1A-001 | AC-CONST-02 |
| BL-P1A-003 | Core Registry | P0 | BL-P1A-001, BL-P1A-002 | AC-CONST-03 |
| BL-P1A-004 | Protected vs Evolvable Boundary | P0 | BL-P1A-003 | AC-CONST-04 |
| BL-P1A-005 | Core Registry API | P1 | BL-P1A-003 | AC-CONST-05 |
| BL-P1A-006 | Core Registry Testing | P0 | BL-P1A-005 | AC-CONST-06 |

Epic P1-B: Identity

| ID | Item | Priority | Dependency | AC Ref |
|---|---|---|---|---|
| BL-P1B-001 | SH_ID Schema Design | P0 | Phase 1A DONE | AC-ID-01 |
| BL-P1B-002 | ACCOUNT_ID Schema Design | P0 | BL-P1B-001 | AC-ID-02 |
| BL-P1B-003 | OWNER Definition | P0 | BL-P1B-002 | AC-ID-03 |
| BL-P1B-004 | INSTANCE Definition | P0 | BL-P1B-003 | AC-ID-04 |
| BL-P1B-005 | 1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH | P0 | BL-P1B-004 | AC-ID-05 |
| BL-P1B-006 | SH_ID Persistence | P0 | BL-P1B-001 | AC-ID-06 |
| BL-P1B-007 | Identity Resolution Service | P0 | BL-P1B-006 | AC-ID-07 |
| BL-P1B-008 | Identity Testing | P0 | BL-P1B-007 | AC-ID-08 |

Epic P1-C: Ownership & Privacy

| ID | Item | Priority | Dependency | AC Ref |
|---|---|---|---|---|
| BL-P1C-001 | Ownership Model Design | P0 | Phase 1B DONE | AC-OWN-01 |
| BL-P1C-002 | Privacy Boundary Implementation | P0 | BL-P1C-001 | AC-OWN-02 |
| BL-P1C-003 | Authorization Foundation | P0 | BL-P1C-002 | AC-OWN-03 |
| BL-P1C-004 | DEFAULT DENY Principle | P0 | BL-P1C-003 | AC-OWN-04 |
| BL-P1C-005 | Cross-SH Isolation | P0 | BL-P1C-004 | AC-OWN-05 |
| BL-P1C-006 | Ownership Testing | P0 | BL-P1C-005 | AC-OWN-06 |

Phase 1 DoD Reference:

Phase 1 dianggap DONE jika:

- Seluruh BL-P1A-* berstatus DONE.
- Seluruh BL-P1B-* berstatus DONE.
- Seluruh BL-P1C-* berstatus DONE.
- Constitution registry tersedia (Immutable vs Evolvable).
- SH_ID persistent identity anchor terimplementasi.
- ACCOUNT_ID terimplementasi.
- Ownership relationship terimplementasi.
- Privacy boundary terimplementasi.
- DEFAULT DENY terverifikasi.
- 1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH terverifikasi.
- Cross-SH isolation terverifikasi.
- Evidence tersedia dan terverifikasi.

4. PHASE 2 — GOVERNANCE & AUTHORITY

| ID | Item | Priority | Dependency | AC Ref |
|---|---|---|---|---|
| BL-P2-001 | Permission Matrix Design | P0 | Phase 1 DONE | AC-GOV-01 |
| BL-P2-002 | Permission Matrix Implementation | P0 | BL-P2-001 | AC-GOV-02 |
| BL-P2-003 | Governance Evaluator | P0 | BL-P2-002 | AC-GOV-03 |
| BL-P2-004 | Policy Enforcement Engine | P0 | BL-P2-003 | AC-GOV-04 |
| BL-P2-005 | Isolation Checker | P0 | BL-P2-004 | AC-GOV-05 |
| BL-P2-006 | Access Decision Gate | P0 | BL-P2-005 | AC-GOV-06 |
| BL-P2-007 | Creator Authority Boundary | P0 | BL-P2-006 | AC-GOV-07 |
| BL-P2-008 | SH-000 Authority Boundary | P0 | BL-P2-007 | AC-GOV-08 |
| BL-P2-009 | Runtime Access Boundary | P0 | BL-P2-008 | AC-GOV-09 |
| BL-P2-010 | System Governance Boundary | P0 | BL-P2-009 | AC-GOV-10 |
| BL-P2-011 | Governance Testing | P0 | BL-P2-010 | AC-GOV-11 |

Phase 2 DoD Reference:

Phase 2 dianggap DONE jika:

- Seluruh BL-P2-* berstatus DONE.
- Permission Matrix terdefinisi dan terdokumentasi.
- Governance evaluator terimplementasi.
- Policy enforcement terverifikasi.
- Creator Authority ≠ Private Data Access terverifikasi.
- SH-000 Core Authority ≠ Private Data Access terverifikasi.
- Runtime Access ≠ Ownership terverifikasi.
- System Governance ≠ Omniscient Data Access terverifikasi.
- Evidence tersedia dan terverifikasi.

5. PHASE 3 — COGNITIVE FOUNDATION

Epic P3-A: Memory Storage

| ID | Item | Priority | Dependency | AC Ref |
|---|---|---|---|---|
| BL-P3A-001 | Memory Table Design | P0 | Phase 2 DONE | AC-MEM-01 |
| BL-P3A-002 | Memory Schema Implementation | P0 | BL-P3A-001 | AC-MEM-02 |
| BL-P3A-003 | Memory Persistence Layer | P0 | BL-P3A-002 | AC-MEM-03 |
| BL-P3A-004 | Memory Isolation per SH | P0 | BL-P3A-003 | AC-MEM-04 |
| BL-P3A-005 | Memory Ownership Boundary | P0 | BL-P3A-004 | AC-MEM-05 |
| BL-P3A-006 | Memory Storage Testing | P0 | BL-P3A-005 | AC-MEM-06 |

Epic P3-B: Memory Lifecycle

| ID | Item | Priority | Dependency | AC Ref |
|---|---|---|---|---|
| BL-P3B-001 | Memory Creation Pipeline | P0 | Phase 3A DONE | AC-MEM-07 |
| BL-P3B-002 | Memory Validation | P0 | BL-P3B-001 | AC-MEM-08 |
| BL-P3B-003 | Memory Update Pipeline | P1 | BL-P3B-002 | AC-MEM-09 |
| BL-P3B-004 | Memory Archival | P2 | BL-P3B-003 | AC-MEM-10 |
| BL-P3B-005 | Memory Deletion | P2 | BL-P3B-004 | AC-MEM-11 |
| BL-P3B-006 | Memory Lifecycle Testing | P0 | BL-P3B-005 | AC-MEM-12 |

Epic P3-C: Memory Retrieval

| ID | Item | Priority | Dependency | AC Ref |
|---|---|---|---|---|
| BL-P3C-001 | Retrieval Strategy Design | P0 | Phase 3B DONE | AC-MEM-13 |
| BL-P3C-002 | Relevance Scoring | P0 | BL-P3C-001 | AC-MEM-14 |
| BL-P3C-003 | Ranking Mechanism | P0 | BL-P3C-002 | AC-MEM-15 |
| BL-P3C-004 | Filtering Logic | P0 | BL-P3C-003 | AC-MEM-16 |
| BL-P3C-005 | Context Injection | P0 | BL-P3C-004 | AC-MEM-17 |
| BL-P3C-006 | Bounded Retrieval | P0 | BL-P3C-005 | AC-MEM-18 |
| BL-P3C-007 | Retrieval Testing | P0 | BL-P3C-006 | AC-MEM-19 |

Epic P3-D: Knowledge

| ID | Item | Priority | Dependency | AC Ref |
|---|---|---|---|---|
| BL-P3D-001 | Knowledge Schema Design | P0 | Phase 3C DONE | AC-KNOW-01 |
| BL-P3D-002 | Knowledge Acquisition | P0 | BL-P3D-001 | AC-KNOW-02 |
| BL-P3D-003 | Knowledge Validation | P0 | BL-P3D-002 | AC-KNOW-03 |
| BL-P3D-004 | Knowledge Normalization | P1 | BL-P3D-003 | AC-KNOW-04 |
| BL-P3D-005 | Knowledge Classification | P1 | BL-P3D-004 | AC-KNOW-05 |
| BL-P3D-006 | Knowledge Storage | P0 | BL-P3D-005 | AC-KNOW-06 |
| BL-P3D-007 | Knowledge Indexing | P1 | BL-P3D-006 | AC-KNOW-07 |
| BL-P3D-008 | Knowledge Provenance | P0 | BL-P3D-007 | AC-KNOW-08 |
| BL-P3D-009 | Knowledge Retrieval | P0 | BL-P3D-008 | AC-KNOW-09 |
| BL-P3D-010 | Knowledge Testing | P0 | BL-P3D-009 | AC-KNOW-10 |

Epic P3-E: Context

| ID | Item | Priority | Dependency | AC Ref |
|---|---|---|---|---|
| BL-P3E-001 | Context Assembly Engine | P0 | Phase 3D DONE | AC-CTX-01 |
| BL-P3E-002 | Context Composition | P0 | BL-P3E-001 | AC-CTX-02 |
| BL-P3E-003 | Context Prioritization | P0 | BL-P3E-002 | AC-CTX-03 |
| BL-P3E-004 | Context Layering | P1 | BL-P3E-003 | AC-CTX-04 |
| BL-P3E-005 | Context Isolation | P0 | BL-P3E-004 | AC-CTX-05 |
| BL-P3E-006 | Context Validation | P0 | BL-P3E-005 | AC-CTX-06 |
| BL-P3E-007 | Context Disposal | P1 | BL-P3E-006 | AC-CTX-07 |
| BL-P3E-008 | Context Budget & Truncation | P0 | BL-P3E-007 | AC-CTX-08 |
| BL-P3E-009 | Context Testing | P0 | BL-P3E-008 | AC-CTX-09 |

Phase 3 DoD Reference:

Phase 3 dianggap DONE jika:

- Seluruh BL-P3A-* berstatus DONE.
- Seluruh BL-P3B-* berstatus DONE.
- Seluruh BL-P3C-* berstatus DONE.
- Seluruh BL-P3D-* berstatus DONE.
- Seluruh BL-P3E-* berstatus DONE.
- Memory storage terimplementasi dan terverifikasi.
- Memory lifecycle terimplementasi dan terverifikasi.
- Memory write pipeline terverifikasi.
- Memory retrieval pipeline terverifikasi.
- Memory isolation per SH terverifikasi.
- Knowledge engine terimplementasi dan terverifikasi.
- Knowledge provenance terverifikasi.
- Context engine terimplementasi dan terverifikasi.
- Context assembly terverifikasi.
- Context isolation terverifikasi.
- MEMORY ≠ KNOWLEDGE ≠ CONTEXT terverifikasi.
- Evidence tersedia dan terverifikasi.

6. PHASE 4 — RUNTIME & ORCHESTRATION

Epic P4-A: Runtime Pipeline

| ID | Item | Priority | Dependency | AC Ref |
|---|---|---|---|---|
| BL-P4A-001 | Runtime Core Loop Design | P0 | Phase 3 DONE | AC-RT-01 |
| BL-P4A-002 | SH Identity Resolution | P0 | BL-P4A-001 | AC-RT-02 |
| BL-P4A-003 | SH State / Session Management | P0 | BL-P4A-002 | AC-RT-03 |
| BL-P4A-004 | Conversation Handling | P0 | BL-P4A-003 | AC-RT-04 |
| BL-P4A-005 | Response Generation | P0 | BL-P4A-004 | AC-RT-05 |
| BL-P4A-006 | Memory Decision Integration | P0 | BL-P4A-005 | AC-RT-06 |
| BL-P4A-007 | State Update Integration | P0 | BL-P4A-006 | AC-RT-07 |
| BL-P4A-008 | Audit / Persistence Integration | P0 | BL-P4A-007 | AC-RT-08 |
| BL-P4A-009 | Continuity Integration | P0 | BL-P4A-008 | AC-RT-09 |
| BL-P4A-010 | Runtime Pipeline Testing | P0 | BL-P4A-009 | AC-RT-10 |

Epic P4-B s/d P4-F: (Reasoning, Planning/Workflow, Model Routing, Tool Execution, Action Execution — sesuai Task Breakdown dan Execution Strategy §9.2)

7. PHASE 5 — SH ADVANCED CAPABILITIES

Epic P5-A s/d P5-E: (Journey, Clone, Inheritance, Recovery, Legacy — sesuai Task Breakdown dan Execution Strategy §10.2)

8. PHASE 6 — ASSURANCE, INTEGRATION & RELEASE

Epic P6-A s/d P6-E: (Integration Testing, Architecture Review, Contract Verification, Implementation Freeze, Release — sesuai Task Breakdown dan Execution Strategy §11.2)

9. BACKLOG SUMMARY

| Phase | Epic Count | Item Count | P0 | P1 | P2 | P3 |
|---|---|---|---|---|---|---|
| Phase 0 | 2 | 20 | 7 | 9 | 4 | 0 |
| Phase 1 | 3 | 20 | 18 | 1 | 1 | 0 |
| Phase 2 | 2 | 11 | 11 | 0 | 0 | 0 |
| Phase 3 | 5 | 39 | 31 | 6 | 2 | 0 |
| Phase 4 | 6 | 44 | 33 | 8 | 3 | 0 |
| Phase 5 | 5 | 30 | 23 | 5 | 2 | 0 |
| Phase 6 | 5 | 26 | 25 | 1 | 0 | 0 |
| TOTAL | 28 | 190 | 148 | 30 | 12 | 0 |

10. BACKLOG TRACEABILITY MATRIX

10.1 Authority Traceability

Setiap backlog item harus dapat ditelusuri ke minimal satu authority document:

| Authority | Reference |
|---|---|
| SH Core Canonical v1.0 | Canonical §[section] |
| Frozen Baseline Phase 01–10 | Phase [XX] §[section] |
| SH Full Build Scope v1.0 | Build Scope §[section] |
| SH Full Implementation Contract v1.0 | Contract §[section] |
| SH Full Implementation Guide v1.0 | Guide §[section] |
| Canonical Architecture Diagram | Diagram Layer [X] |
| Execution Strategy v1.0 | Exec Strategy §[section] |

10.2 Acceptance Criteria Traceability

| AC Prefix | Phase | Domain |
|---|---|---|
| AC-INFRA-* | Phase 0 | Infrastructure & Development |
| AC-CONST-* | Phase 1A | Constitution |
| AC-ID-* | Phase 1B | Identity |
| AC-OWN-* | Phase 1C | Ownership & Privacy |
| AC-GOV-* | Phase 2 | Governance & Authority |
| AC-MEM-* | Phase 3A/3B/3C | Memory |
| AC-KNOW-* | Phase 3D | Knowledge |
| AC-CTX-* | Phase 3E | Context |
| AC-RT-* | Phase 4 | Runtime & Orchestration |
| AC-ADV-* | Phase 5 | Advanced Capabilities |
| AC-INT-* | Phase 6 | Assurance, Integration & Release |

10.3 Task Breakdown Traceability

Seluruh item `BL-*` pada dokumen ini adalah turunan langsung dan pemetaan 1:1 atau 1:N dari item `E[X]-T[YY]` pada Task Breakdown (`SECOND_HEAD_PHASE_MINUS_1_TASK_BREAKDOWN_v1.0`).

Pemetaan:

| Task Breakdown ID | Backlog ID | Hubungan |
|---|---|---|
| E0-T01 s/d E0-T07 | BL-P0-001 s/d BL-P0-020 | 1:N (satu task WBS dapat mencakup beberapa backlog item) |
| E1-T01 s/d E1-T05 | BL-P1A-001 s/d BL-P1C-006 | 1:N |
| E2-T01 s/d E2-T06 | BL-P2-001 s/d BL-P2-011 | 1:N |
| E3A-T01 s/d E3A-T06 | BL-P3A-001 s/d BL-P3A-006 | 1:1 |
| E3B-T01 s/d E3B-T06 | BL-P3B-001 s/d BL-P3B-006 | 1:1 |
| E3C-T01 s/d E3C-T07 | BL-P3C-001 s/d BL-P3C-007 | 1:1 |
| E3D-T01 s/d E3D-T10 | BL-P3D-001 s/d BL-P3D-010 | 1:1 |
| E3E-T01 s/d E3E-T09 | BL-P3E-001 s/d BL-P3E-009 | 1:1 |
| E4-T01 s/d E4-T06 | BL-P4A-001 s/d BL-P4F-010 | 1:N |
| E5-T01 s/d E5-T07 | BL-P5A-001 s/d BL-P5E-006 | 1:N |
| E6-T01 s/d E6-T07 | BL-P6A-001 s/d BL-P6E-004 | 1:N |

Catatan: Untuk Epic 0, 1, 2, 4, 5, dan 6, satu task WBS (`E[X]-T[YY]`) dapat mencakup beberapa backlog item (`BL-*`) karena backlog mendefinisikan item pada granularitas yang lebih halus. Untuk Epic 3 (Phase 3), pemetaan bersifat 1:1 karena Task Breakdown telah direvisi menjadi 5 Sub-Epic (3A–3E) yang identik dengan struktur Backlog.

11. BACKLOG STATUS TRACKING

| Phase | Total Items | TODO | IN PROGRESS | TESTING | REVIEW | DONE | BLOCKED | CANCELLED |
|---|---|---|---|---|---|---|---|---|
| Phase 0 | 20 | 20 | 0 | 0 | 0 | 0 | 0 | 0 |
| Phase 1 | 20 | 20 | 0 | 0 | 0 | 0 | 0 | 0 |
| Phase 2 | 11 | 11 | 0 | 0 | 0 | 0 | 0 | 0 |
| Phase 3 | 39 | 39 | 0 | 0 | 0 | 0 | 0 | 0 |
| Phase 4 | 44 | 44 | 0 | 0 | 0 | 0 | 0 | 0 |
| Phase 5 | 30 | 30 | 0 | 0 | 0 | 0 | 0 | 0 |
| Phase 6 | 26 | 26 | 0 | 0 | 0 | 0 | 0 | 0 |
| TOTAL | 190 | 190 | 0 | 0 | 0 | 0 | 0 | 0 |

Update Rules:

- Status di-update setiap sprint.
- Status tidak boleh di-inflate.
- Status harus mencerminkan kondisi aktual.
- Perubahan status harus disertai evidence.

12. BACKLOG GOVERNANCE

Backlog ini tidak boleh diubah tanpa:

1. Identifikasi perubahan.
2. Klasifikasi perubahan.
3. Impact analysis.
4. Owner approval.
5. Version bump.
6. Update traceability.

13. DOCUMENT CONTROL

Document: SECOND_HEAD_PHASE_MINUS_1_BACKLOG_DEFINITION_v1.0
Version: v1.0
Status: FINAL
Authority Level: Derived Operational Document (Phase -1 Output)

END OF SECOND_HEAD_PHASE_MINUS_1_BACKLOG_DEFINITION_v1.0

================================================================================
[9/9] SECOND_HEAD_PHASE_MINUS_1_TIMELINE_ESTIMATION_v1.0
Role: ARTEFAK PHASE -1 — TIMELINE ESTIMATION
Source: Phase -1 Planning
Status: FINAL
================================================================================

SECOND_HEAD_PHASE_MINUS_1_TIMELINE_ESTIMATION_v1.0

Project: SECOND HEAD — SYSTEM BUILD
Document Type: Phase -1 Artifact — Timeline Estimation
Version: v1.0
Status: FINAL
Authority Level: Derived Operational Document (Phase -1 Output)

0. DOCUMENT STATUS & AUTHORITY

0.1 Status

Dokumen ini adalah Timeline Estimation untuk Phase -1 Planning.

Dokumen ini merupakan turunan operasional dari:

- Execution Strategy v1.0 (Seven-Phase Execution Roadmap)
- Milestone Mapping v1.0 (Phase-to-Milestone Mapping)
- Task Breakdown v1.0 (Work Decomposition)
- Dependency Map v1.0 (Execution Order)
- Risk Register v1.0 (Risk Assessment)
- Resource Allocation Plan v1.0 (Resource Constraints)

0.2 Authority Hierarchy

PRIORITY 1: SH Core Canonical v1.0
PRIORITY 2: Frozen Baseline Phase 01–10
PRIORITY 3: SH Full Build Scope v1.0
PRIORITY 4: SH Full Implementation Contract v1.0
PRIORITY 5: SH Full Implementation Guide v1.0
PRIORITY 6: Canonical Architecture Diagram (Master Diagram)
PRIORITY 7: Execution Strategy v1.0
PRIORITY 8: Dokumen ini (Timeline Estimation)
PRIORITY 9: Source Code / Repository

0.3 Purpose

Dokumen ini menjawab pertanyaan:

"BERAPA LAMA estimasi waktu yang diperlukan untuk menyelesaikan setiap phase dan keseluruhan proyek SH Full, dengan mempertimbangkan seluruh constraint yang telah ditetapkan?"

Dokumen ini TIDAK menjawab:

- "Apa yang harus dibangun?" → Build Scope.
- "Bagaimana cara membangunnya?" → Implementation Guide.
- "Apakah sudah selesai?" → Evidence dan DoD.

0.4 Estimation Disclaimer

Timeline ini adalah ESTIMASI, bukan KOMITMEN.

Estimasi ini dibuat berdasarkan:

- Kondisi aktual SH Lite V2.0/V2.1 yang sudah CLOSED/GREEN.
- Constraint Zero Budget, Zero Hardware Cost, Mobile-First.
- Single developer dengan AI assistance.
- Open Questions yang masih unresolved (OQ-01 s/d OQ-09).
- Ketidakpastian inherent dalam pengembangan software.

Estimasi ini dapat berubah jika:

- Open Questions belum resolved saat phase terkait dimulai.
- Ditemukan technical debt baru selama implementasi.
- Constraint berubah (misal: budget tersedia, hardware baru).
- Ditemukan architectural drift yang memerlukan rework.
- Owner memutuskan perubahan priority atau scope.

0.5 Milestone Identifier Note

Dokumen ini menggunakan identifier MS-00..MS-07 untuk project milestones, konsisten dengan Milestone Mapping. Identifier ini BERBEDA dari identifier ART-M1..ART-M6 yang digunakan oleh Canonical Artifact Map untuk artifact gate milestones.

- MS-00..MS-07: Project milestones (fase eksekusi proyek).
- ART-M1..ART-M6: Artifact Map gate milestones (ketersediaan artifact untuk build).

Jangan mencampuradukkan kedua sistem identifier ini.

0.6 Sprint-Calendar Reconciliation Note

Timeline realistic ~31 minggu adalah CALENDAR ESTIMATE, bukan sprint count × default sprint duration.

Penjelasan eksplisit:

- Timeline realistic ~31 minggu adalah calendar estimate.
- Sprint count 17–22 adalah planning range.
- Sprint duration variable 1–2 minggu.
- Untuk mencapai ~31 minggu dengan 17–22 sprint, rata-rata sprint duration adalah ~1.4–1.8 minggu.
- Ini BUKAN berarti 17–22 sprint × 1 minggu default.
- Sprint duration dapat bervariasi antara 1–2 minggu tergantung kompleksitas dan availability.

Implikasi:

- Jangan menghitung milestone date sebagai sprint count × 1 minggu.
- Gunakan calendar estimate ~31 minggu sebagai planning baseline.
- Sprint duration aktual akan bervariasi.
- Jangan pernah jadikan Week 31 sebagai hard deadline.

1. ESTIMATION ASSUMPTIONS

1.1 Developer Capacity

| Parameter | Value | Notes |
|---|---|---|
| Developer | 1 (Owner) | Single developer |
| AI Assistance | Available | AI assistant untuk drafting, coding, review |
| Working Mode | Mobile-First | Development dari mobile device |
| Daily Productive Hours | 2–4 hours | Realistis untuk mobile-first workflow |
| Weekly Productive Days | 4–6 days | Tergantung availability Owner |
| Sprint Duration | 1–2 weeks | Sesuai Sprint Plan |

1.2 AI Assistance Impact

AI assistance dapat mempercepat:

- Drafting dokumen dan artifact.
- Code generation untuk boilerplate.
- Review dan analysis.
- Test case generation.
- Documentation.

AI assistance TIDAK dapat mempercepat:

- Runtime testing pada device.
- Supabase deployment dan verification.
- Manual acceptance testing.
- Owner decision-making.
- Open Question resolution.

1.3 Technology Stack Assumptions

Berdasarkan kondisi aktual SH Lite V2.0/V2.1:

- Frontend: React Native Expo (existing).
- Backend: Supabase Edge Functions (existing).
- Database: Supabase PostgreSQL (existing).
- Auth: Supabase Auth (existing).
- AI Model: Groq free tier (existing).
- Image: Pollinations AI client-side (existing).

Jika OQ-01 (Technology Stack) mengubah stack, timeline harus direvisi.

CATATAN: Stack di atas adalah inherited/reference. SH Full stack tetap OQ-01 OPEN. Lihat Downstream Blockers Register.

1.4 Uncertainty Factors

| Factor | Impact | Probability |
|---|---|---|
| OQ-01 Technology Stack change | HIGH | LOW |
| Mobile development friction | MEDIUM | HIGH |
| Supabase free tier limitations | MEDIUM | MEDIUM |
| AI model API instability | LOW | HIGH |
| Unexpected architectural drift | HIGH | MEDIUM |
| Scope creep | HIGH | MEDIUM |
| Owner availability fluctuation | MEDIUM | HIGH |
| Technical debt from V2.0/V2.1 | MEDIUM | HIGH |

2. PHASE-LEVEL TIMELINE ESTIMATION

2.1 Phase -1 — Planning

| Item | Estimate | Notes |
|---|---|---|
| Duration | 1–2 weeks | Sebagian besar sudah selesai |
| Complexity | LOW | Dokumentasi dan planning |
| Dependency | None | Titik awal |
| Risk Level | LOW | Tidak ada coding |

Status aktual: Selesai. Artifact 1–9 sudah dibuat dan difinalkan.

2.2 Phase 0 — Infrastructure & Development Foundation

| Item | Estimate | Notes |
|---|---|---|
| Duration | 1–2 weeks | Sebagian infra sudah ada dari V2.0/V2.1 |
| Complexity | LOW–MEDIUM | Setup dan configuration |
| Dependency | Phase -1 DONE | |
| Risk Level | LOW | Sebagian besar sudah proven |

Breakdown:

| Task | Estimate | Notes |
|---|---|---|
| Supabase project verification | 1–2 days | Sudah ada dari V2.0/V2.1 |
| Auth configuration review | 1–2 days | Sudah ada, perlu review |
| Storage/Bucket configuration | 1 day | |
| Extension setup | 1 day | |
| Migration framework | 1–2 days | |
| Seed data structure | 1 day | |
| Environment configuration | 1 day | |
| RLS Foundation | 1–2 days | Sudah ada dasar dari V2.1 |
| Audit Table foundation | 1–2 days | Baru |
| Shared Types | 1 day | |
| Linting & Formatting | 1 day | |
| CI Pipeline | 1–2 days | |
| Branching Strategy | 0.5 day | |
| Commit Convention | 0.5 day | |
| Folder Structure | 0.5 day | |
| Testing Framework | 1–2 days | |
| Documentation Standard | 0.5 day | |

Catatan: Banyak infrastruktur sudah ada dari V2.0/V2.1. Phase 0 lebih ke formalisasi, hardening, dan penambahan yang belum ada.

CATATAN: Phase 0 memerlukan OQ-01 (Technology Stack) resolved. Lihat Downstream Blockers Register.

2.3 Phase 1 — Constitution & Identity

| Item | Estimate | Notes |
|---|---|---|
| Duration | 2–4 weeks | Core identity architecture |
| Complexity | HIGH | Fondasi seluruh sistem |
| Dependency | Phase 0 DONE | |
| Risk Level | HIGH | Kesalahan di sini berdampak ke seluruh phase |

Breakdown:

| Sub-Phase | Estimate | Notes |
|---|---|---|
| Phase 1A — Constitution | 1 week | Immutable vs Evolvable definition |
| Phase 1B — Identity | 1–2 weeks | SH_ID, ACCOUNT_ID, persistence |
| Phase 1C — Ownership & Privacy | 1 week | Privacy boundary, DEFAULT DENY |

Catatan kritis:

- `internal_sh_id = authenticated_user_id` mapping dari V2.0/V2.1 harus dievolusi menjadi proper SH_ID separation.
- Ini adalah perubahan arsitektural signifikan.
- Memerlukan careful migration dari existing data.
- OQ terkait identity model harus resolved sebelum implementasi.

CATATAN: Phase 1 memerlukan SH_ID exact format dan Creator SH reserved identifier (SH-000) yang masih MISSING. Lihat Downstream Blockers Register. Identity/data model finalization TIDAK BOLEH dilakukan sebelum keputusan ini dibuat.

2.4 Phase 2 — Governance & Authority

| Item | Estimate | Notes |
|---|---|---|
| Duration | 2–3 weeks | Governance engine |
| Complexity | MEDIUM–HIGH | Policy enforcement |
| Dependency | Phase 1 DONE | |
| Risk Level | MEDIUM | |

Breakdown:

| Task | Estimate | Notes |
|---|---|---|
| Permission Matrix design | 3–4 days | |
| Permission Matrix implementation | 3–4 days | |
| Governance Evaluator | 3–4 days | |
| Policy Enforcement Engine | 3–4 days | |
| Isolation Checker | 2–3 days | |
| Access Decision Gate | 2–3 days | |
| Creator Authority boundary | 2–3 days | |
| SH-000 Authority boundary | 2–3 days | |
| Testing & verification | 3–4 days | |

2.5 Phase 3 — Cognitive Foundation

| Item | Estimate | Notes |
|---|---|---|
| Duration | 4–8 weeks | Paling kompleks |
| Complexity | VERY HIGH | Memory, Knowledge, Context |
| Dependency | Phase 2 DONE | |
| Risk Level | HIGH | Banyak OQ terkait |

Breakdown:

| Sub-Phase | Estimate | Notes |
|---|---|---|
| Phase 3A — Memory Storage | 1–2 weeks | Schema, persistence, isolation |
| Phase 3B — Memory Lifecycle | 1–2 weeks | Write pipeline, validation, update |
| Phase 3C — Memory Retrieval | 1 week | Retrieval strategy, scoring |
| Phase 3D — Knowledge | 1–2 weeks | Acquisition, validation, provenance |
| Phase 3E — Context | 1–2 weeks | Assembly, composition, budget |

Catatan kritis:

- OQ-02 (Memory Decision Implementation) harus resolved sebelum Phase 3B.
- OQ-03 (Knowledge Ingestion) harus resolved sebelum Phase 3D.
- OQ-04 (Reference Material Trust Promotion) harus resolved sebelum Phase 3D.
- V2.0/V2.1 sudah memiliki basic memory pipeline. Phase 3 meng-evolusi ini menjadi full Memory Governance.
- Context Builder sudah ada di V2.0/V2.1. Phase 3E meng-evolusi ini.

2.6 Phase 4 — Runtime & Orchestration

| Item | Estimate | Notes |
|---|---|---|
| Duration | 3–6 weeks | Runtime core |
| Complexity | HIGH | Orchestration layer |
| Dependency | Phase 3 DONE | |
| Risk Level | MEDIUM–HIGH | |

Breakdown:

| Sub-Phase | Estimate | Notes |
|---|---|---|
| Phase 4A — Runtime Pipeline | 1–2 weeks | Core loop |
| Phase 4B — Reasoning | 1 week | Reasoning process |
| Phase 4C — Planning | 0.5–1 week | Workflow engine |
| Phase 4D — Model Routing | 1 week | Model abstraction |
| Phase 4E — Tool Execution | 0.5–1 week | Tool framework |
| Phase 4F — Action Execution | 0.5–1 week | Action framework |

Catatan:

- OQ-06 (Model Selection Policy) harus resolved sebelum Phase 4D.
- V2.0/V2.1 sudah memiliki basic runtime loop. Phase 4 meng-evolusi ini menjadi full Runtime Orchestration.
- Model routing saat ini menggunakan Groq single model. Phase 4D harus mendukung abstraction untuk future multi-model.

2.7 Phase 5 — SH Advanced Capabilities

| Item | Estimate | Notes |
|---|---|---|
| Duration | 4–8 weeks | Advanced features |
| Complexity | VERY HIGH | Journey, Clone, Inheritance, Recovery |
| Dependency | Phase 4 DONE | |
| Risk Level | HIGH | Banyak konsep baru |

Breakdown:

| Sub-Phase | Estimate | Notes |
|---|---|---|
| Journey | 1–2 weeks | Timeline, milestones, events |
| Clone | 1–2 weeks | Clone mechanism, agreement |
| Inheritance | 1–2 weeks | Successor, ownership transition |
| Recovery | 1 week | Backup, restore, portability |
| Legacy | 0.5–1 week | Legacy representation |

Catatan kritis:

- OQ-05 (Clone Agreement Enforcement) harus resolved sebelum Clone implementation.
- OQ-07 (Backup / Restore Policy) harus resolved sebelum Recovery implementation.
- OQ-08 (Data Portability Format) harus resolved sebelum Data Portability implementation.
- Ini adalah fase dengan paling banyak konsep baru yang belum pernah diimplementasikan di V2.0/V2.1.

2.8 Phase 6 — Assurance, Integration & Release

| Item | Estimate | Notes |
|---|---|---|
| Duration | 3–5 weeks | Testing dan release |
| Complexity | MEDIUM–HIGH | Integration testing |
| Dependency | Phase 5 DONE | |
| Risk Level | MEDIUM | |

Breakdown:

| Sub-Phase | Estimate | Notes |
|---|---|---|
| Phase 6A — Integration Testing | 1–2 weeks | Full integration test |
| Phase 6B — Architecture Review | 0.5–1 week | Drift verification |
| Phase 6C — Contract Verification | 0.5–1 week | Requirement verification |
| Phase 6D — Implementation Freeze | 0.5 week | Freeze |
| Phase 6E — Release | 0.5–1 week | Final gate |

3. TOTAL PROJECT TIMELINE

3.1 Optimistic Estimate

Jika semua berjalan lancar, OQ resolved tepat waktu, tidak ada drift signifikan:

| Phase | Duration | Cumulative |
|---|---|---|
| Phase -1 | 1 week | 1 week |
| Phase 0 | 1 week | 2 weeks |
| Phase 1 | 2 weeks | 4 weeks |
| Phase 2 | 2 weeks | 6 weeks |
| Phase 3 | 4 weeks | 10 weeks |
| Phase 4 | 3 weeks | 13 weeks |
| Phase 5 | 4 weeks | 17 weeks |
| Phase 6 | 3 weeks | 20 weeks |

Total Optimistic: ~20 weeks (~5 months)

3.2 Realistic Estimate

Dengan mempertimbangkan mobile-first friction, OQ resolution delay, technical debt, dan availability fluctuation:

| Phase | Duration | Cumulative |
|---|---|---|
| Phase -1 | 2 weeks | 2 weeks |
| Phase 0 | 2 weeks | 4 weeks |
| Phase 1 | 3 weeks | 7 weeks |
| Phase 2 | 3 weeks | 10 weeks |
| Phase 3 | 6 weeks | 16 weeks |
| Phase 4 | 5 weeks | 21 weeks |
| Phase 5 | 6 weeks | 27 weeks |
| Phase 6 | 4 weeks | 31 weeks |

Total Realistic: ~31 weeks (~7–8 months)

3.3 Pessimistic Estimate

Jika terdapat banyak blocker, OQ berlarut, architectural drift signifikan, atau availability sangat terbatas:

| Phase | Duration | Cumulative |
|---|---|---|
| Phase -1 | 2 weeks | 2 weeks |
| Phase 0 | 2 weeks | 4 weeks |
| Phase 1 | 4 weeks | 8 weeks |
| Phase 2 | 3 weeks | 11 weeks |
| Phase 3 | 8 weeks | 19 weeks |
| Phase 4 | 6 weeks | 25 weeks |
| Phase 5 | 8 weeks | 33 weeks |
| Phase 6 | 5 weeks | 38 weeks |

Total Pessimistic: ~38 weeks (~9–10 months)

3.4 Summary

| Scenario | Duration | Calendar Time |
|---|---|---|
| Optimistic | ~20 weeks | ~5 months |
| Realistic | ~31 weeks | ~7–8 months |
| Pessimistic | ~38 weeks | ~9–10 months |

Recommended Planning Baseline: Realistic (~7–8 months)

CATATAN: Angka ~31 minggu adalah calendar estimate, bukan hard deadline. Lihat section 0.6 untuk sprint-calendar reconciliation.

4. CRITICAL PATH

4.1 Critical Path Sequence

Urutan task yang menentukan durasi total proyek:

Phase -1 → Phase 0 → Phase 1A → 1B → 1C → Phase 2 → Phase 3A → 3B → 3C → 3D → 3E → Phase 4A → 4D → 4E → 4F → Phase 5A → 5B → 5C → 5D → 5E → Phase 6A → 6B → 6C → 6D → 6E

4.2 Critical Path Duration

Critical path mengikuti Realistic Estimate: ~31 weeks.

4.3 Non-Critical Path Items

Beberapa item dapat dikerjakan paralel jika capacity memungkinkan:

- Phase 0 Development Foundation (linting, CI, branching) dapat paralel dengan Infrastructure Foundation.
- Phase 4B (Reasoning) dan 4C (Planning) dapat paralel setelah 4A selesai.
- Phase 5E (Legacy) dapat mulai setelah 5C selesai, tidak perlu menunggu 5D.

Namun, mengingat single developer constraint, paralelisasi terbatas.

5. MILESTONE TIMELINE

5.1 Milestone Mapping

| Milestone | Phase | Target (Realistic) | Notes |
|---|---|---|---|
| MS-00: Planning Complete | Phase -1 | Week 2 | |
| MS-01: Infrastructure Ready | Phase 0 | Week 4 | |
| MS-02: Identity Locked | Phase 1 | Week 7 | Critical milestone |
| MS-03: Governance Active | Phase 2 | Week 10 | |
| MS-04: Cognitive Foundation | Phase 3 | Week 16 | Longest phase |
| MS-05: Runtime Active | Phase 4 | Week 21 | |
| MS-06: Advanced Capabilities | Phase 5 | Week 27 | |
| MS-07: Integration Ready | Phase 6 | Week 31 | Final gate |

5.2 Milestone Dependencies

MS-00 → MS-01 → MS-02 → MS-03 → MS-04 → MS-05 → MS-06 → MS-07

Tidak ada milestone yang boleh di-skip.

6. SPRINT TIMELINE

6.1 Sprint Structure

Berdasarkan Sprint Plan:

- Sprint duration: 1–2 weeks.
- Recommended: 2 weeks per sprint untuk memberikan buffer.

6.2 Sprint Count Estimate

| Phase | Sprint Count | Notes |
|---|---|---|
| Phase -1 | 1 sprint | Selesai |
| Phase 0 | 1 sprint | |
| Phase 1 | 2–3 sprints | |
| Phase 2 | 2 sprints | |
| Phase 3 | 3–4 sprints | |
| Phase 4 | 3 sprints | |
| Phase 5 | 3–4 sprints | |
| Phase 6 | 2 sprints | |

Total Estimated Sprints: 17–22 sprints

Dengan 2 weeks per sprint: ~34–44 weeks.
Dengan 1.5 weeks per sprint (average): ~26–33 weeks.

Ini konsisten dengan Realistic Estimate.

CATATAN: Lihat section 0.6 untuk sprint-calendar reconciliation. Angka 17–22 sprint adalah planning range dengan sprint duration variable 1–2 minggu. Calendar estimate ~31 minggu mengasumsikan rata-rata sprint duration ~1.4–1.8 minggu, bukan default 1 minggu.

7. OPEN QUESTION IMPACT ON TIMELINE

7.1 OQ Resolution Deadline

| OQ | Description | Must Resolve Before | Impact if Delayed |
|---|---|---|---|
| OQ-01 | Technology Stack | Phase 0 start | HIGH — dapat mengubah seluruh stack |
| OQ-02 | Memory Decision Implementation | Phase 3B start | HIGH — blocks memory pipeline |
| OQ-03 | Knowledge Ingestion | Phase 3D start | MEDIUM — blocks knowledge engine |
| OQ-04 | Reference Material Trust Promotion | Phase 3D start | MEDIUM — blocks trust boundary |
| OQ-05 | Clone Agreement Enforcement | Phase 5B start | HIGH — blocks clone mechanism |
| OQ-06 | Model Selection Policy | Phase 4D start | MEDIUM — blocks model routing |
| OQ-07 | Backup / Restore Policy | Phase 5D start | MEDIUM — blocks recovery |
| OQ-08 | Data Portability Format | Phase 5D start | MEDIUM — blocks portability |
| OQ-09 | Decision Record Format | Phase -1 end | LOW — dapat diselesaikan cepat |

7.2 OQ Resolution Strategy

OQ harus resolved SEBELUM phase yang bergantung padanya dimulai.

Jika OQ belum resolved saat phase terkait akan dimulai:

1. Phase tersebut BLOCKED.
2. Owner harus memutuskan: resolve OQ atau defer phase.
3. Tidak boleh memulai implementasi tanpa OQ resolved.

7.3 OQ Resolution Timeline

| OQ | Recommended Resolution Time | Notes |
|---|---|---|
| OQ-09 | Phase -1 (Week 1–2) | Quick decision |
| OQ-01 | Phase -1 / Phase 0 (Week 1–3) | Critical, affects everything |
| OQ-02 | Before Phase 3B (Week ~12) | |
| OQ-03 | Before Phase 3D (Week ~14) | |
| OQ-04 | Before Phase 3D (Week ~14) | |
| OQ-06 | Before Phase 4D (Week ~19) | |
| OQ-05 | Before Phase 5B (Week ~23) | |
| OQ-07 | Before Phase 5D (Week ~25) | |
| OQ-08 | Before Phase 5D (Week ~25) | |

8. RISK IMPACT ON TIMELINE

8.1 High-Impact Risks

| Risk | Probability | Timeline Impact | Mitigation |
|---|---|---|---|
| OQ-01 Technology Stack change | LOW | +4–8 weeks | Resolve early, keep current stack if possible |
| Architectural drift in Phase 1 | MEDIUM | +2–4 weeks | Strict review, evidence-based |
| Memory Governance complexity | HIGH | +2–4 weeks | Incremental approach, vertical slice |
| Mobile development friction | HIGH | +20–30% overall | Accept slower pace, use AI assistance |
| Owner availability fluctuation | HIGH | +2–6 weeks | Flexible sprint, no hard deadline |
| Supabase free tier limitation | MEDIUM | +1–2 weeks | Optimize usage, plan migration path |

8.2 Timeline Buffer

Recommended buffer: +20–30% dari Realistic Estimate.

Ini sudah termasuk dalam Pessimistic Estimate.

9. TIMELINE CONSTRAINTS

9.1 Hard Constraints

- Tidak boleh melompati phase.
- Tidak boleh memulai phase sebelum phase sebelumnya DONE.
- Tidak boleh memulai implementasi sebelum OQ terkait resolved.
- Tidak boleh mengorbankan quality untuk speed.
- Tidak boleh mengorbankan security untuk speed.
- Tidak boleh mengorbankan evidence untuk speed.

9.2 Soft Constraints

- Target milestone bersifat guidance, bukan deadline ketat.
- Sprint duration dapat disesuaikan berdasarkan availability.
- Task order dalam satu phase dapat disesuaikan selama dependency terpenuhi.

9.3 No Deadline Principle

Proyek ini TIDAK memiliki hard deadline.

Quality, security, dan correctness lebih penting daripada speed.

Jika harus memilih antara:

- Selesai cepat tapi ada drift → TIDAK BOLEH.
- Selesai lambat tapi benar → BOLEH.

10. TIMELINE REVIEW & UPDATE

10.1 Review Cadence

Timeline harus di-review:

- Setiap phase transition.
- Setiap milestone completion.
- Setiap OQ resolution.
- Setiap significant risk materialization.
- Setiap 4 sprints (minimum).

10.2 Update Triggers

Timeline harus di-update jika:

- Actual progress deviasi >20% dari estimate.
- OQ resolution mengubah scope atau complexity.
- Technical debt baru ditemukan yang signifikan.
- Constraint berubah.
- Owner memutuskan priority change.

10.3 Update Process

DEVIATION DETECTED → ASSESS IMPACT → UPDATE TIMELINE → DOCUMENT REASON → OWNER REVIEW → LOCK UPDATED TIMELINE

11. EXISTING ASSET LEVERAGE

11.1 V2.0/V2.1 Assets

SH Lite V2.0/V2.1 sudah mengimplementasikan:

- Supabase project setup ✅
- Auth flow ✅
- RLS foundation ✅
- Context Builder (read-only) ✅
- Memory extraction pipeline ✅
- Conversation persistence ✅
- Image generation (client-side) ✅
- Virtual session / init_session ✅
- Owner isolation ✅

Ini dapat di-leverage untuk Phase 0 dan sebagian Phase 1, 3, 4.

11.2 Leverage Impact on Timeline

Dengan leverage V2.0/V2.1:

- Phase 0: ~50% effort reduction.
- Phase 1: ~20% effort reduction (identity mapping perlu evolusi).
- Phase 3: ~30% effort reduction (basic memory sudah ada).
- Phase 4: ~20% effort reduction (basic runtime sudah ada).

Tanpa leverage (greenfield): timeline bisa +40–60%.

12. TIMELINE VISUALIZATION

12.1 Gantt-Style Overview (Realistic)

Week:  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16
       ├──P-1──┤
             ├────P0────┤
                      ├──────P1──────┤
                                   ├──────P2──────┤
                                                ├────────────P3────────────┤

Week: 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
                                                 ├────────P4────────┤
                                                                   ├────────P5────────┤
                                                                                     ├────P6────┤

12.2 Milestone Markers

- Week 2: MS-00 ✅ Planning Complete
- Week 4: MS-01 ✅ Infrastructure Ready
- Week 7: MS-02 ✅ Identity Locked
- Week 10: MS-03 ✅ Governance Active
- Week 16: MS-04 ✅ Cognitive Foundation
- Week 21: MS-05 ✅ Runtime Active
- Week 27: MS-06 ✅ Advanced Capabilities
- Week 31: MS-07 ✅ Integration Ready → SH v1.0

13. RECOMMENDATIONS

13.1 Priority Recommendations

1. Resolve OQ-09 dan OQ-01 secepat mungkin (Phase -1).
2. Mulai Phase 0 segera setelah Phase -1 locked.
3. Berikan perhatian ekstra pada Phase 1 (Identity) karena ini fondasi.
4. Phase 3 adalah fase terpanjang; pertimbangkan untuk memecah menjadi sprint yang lebih kecil.
5. Jangan rush Phase 5; banyak konsep baru yang belum proven.
6. Sisihkan buffer untuk unexpected issues.

13.2 Anti-Patterns to Avoid

- ❌ Memulai coding sebelum Phase -1 selesai.
- ❌ Melompati phase karena "sudah tahu caranya".
- ❌ Mengabaikan OQ dan berharap tidak berdampak.
- ❌ Mengorbankan testing untuk mengejar timeline.
- ❌ Mengubah arsitektur di tengah phase tanpa change control.
- ❌ Menetapkan hard deadline yang tidak realistis.

13.3 Success Criteria

Timeline dianggap sukses jika:

- Seluruh phase selesai sesuai urutan.
- Seluruh DoD terpenuhi.
- Seluruh evidence tersedia.
- Tidak ada critical drift.
- Tidak ada unresolved high-risk item saat Final Integration Gate.
- SH v1.0 = INTEGRATION-READY.

14. FINAL STATEMENT

Timeline Estimation ini adalah guidance untuk perencanaan, bukan komitmen.

SH Full dibangun dengan prinsip:

- Quality over speed.
- Security over convenience.
- Evidence over assumption.
- Correctness over deadline.

Estimasi realistis untuk keseluruhan proyek SH Full adalah:

~7–8 bulan (31 weeks)

dengan asumsi:

- Single developer dengan AI assistance.
- Mobile-first workflow.
- Zero budget constraint.
- 2–4 jam produktif per hari.
- 4–6 hari produktif per minggu.
- Tidak ada perubahan scope signifikan.
- OQ resolved tepat waktu.

Jika kondisi berubah, timeline harus di-update melalui process yang telah ditetapkan.

Yang terpenting bukan kapan selesai, tetapi:

«SH Full harus selesai dengan benar, aman, terverifikasi, dan konsisten dengan seluruh canonical authority yang telah ditetapkan.»

15. DOCUMENT CONTROL

Document: SECOND_HEAD_PHASE_MINUS_1_TIMELINE_ESTIMATION_v1.0
Version: v1.0
Status: FINAL
Authority Level: Derived Operational Document (Phase -1 Output)

END OF SECOND_HEAD_PHASE_MINUS_1_TIMELINE_ESTIMATION_v1.0

================================================================================
END OF COMPILED DOCUMENT
SECOND_HEAD_PHASE_MINUS_1_v1.0
================================================================================

ARCHIVE NOTES

Revision history sebelumnya (v1.0-rev1, v1.0-rev2) dianggap sebagai bagian dari archive/history dan tidak ditampilkan sebagai revision number pada dokumen final ini. Dokumen final menggunakan identity v1.0.

Perubahan yang diterapkan dari draft ke final:

1. Version identity diset ke v1.0 (bukan v1.0-rev2).
2. Status diset ke FINAL.
3. Revision log dipindahkan ke Archive Notes ini.
4. Label "Status Revisi" pada header artifact dihapus.
5. Formatting dirapikan tanpa mengubah substansi.
6. Artefak 1 dan 2 tetap OWNER-FROZEN tanpa perubahan substansi.
7. Seluruh terminology canonical dipertahankan exactly.
8. Seluruh traceability reference dipertahankan.
9. Seluruh invariant dipertahankan tanpa perubahan.

FINAL CONSISTENCY CHECK:

Structural:
[x] Semua artifact ada (0, 0.1, 1–9).
[x] Semua section ada.
[x] Numbering konsisten.
[x] Tidak ada heading yang hilang.
[x] Tidak ada duplicate section.

Content Integrity:
[x] Tidak ada requirement hilang.
[x] Tidak ada requirement baru.
[x] Tidak ada invariant berubah.
[x] Tidak ada authority berubah.
[x] Tidak ada decision berubah.
[x] Tidak ada governance rule berubah.
[x] Tidak ada security boundary berubah.
[x] Tidak ada ownership rule berubah.

Terminology:
[x] Canonical terminology konsisten.
[x] Invariant ID konsisten.
[x] Decision Lifecycle konsisten.
[x] Dependency Health terminology konsisten.
[x] Architecture Drift Score terminology konsisten.
[x] Traceability terminology konsisten.

Formatting:
[x] Markdown valid.
[x] Semua tabel valid.
[x] Checkbox konsisten.
[x] Heading konsisten.
[x] Spacing rapi.
[x] Tidak ada artefak formatting.
[x] Tidak ada accidental duplicated text.

Version:
[x] Semua final artifact menggunakan v1.0.
[x] Tidak ada v1.1/v1.2 pada identity final.
[x] Status FINAL.
[x] Tidak ada label "draft" pada final document.

PHASE -1 DOCUMENT PACKAGE = FINAL v1.0

================================================================================
END OF SECOND_HEAD_PHASE_MINUS_1_v1.0
================================================================================