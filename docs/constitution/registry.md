# SECOND HEAD — Constitution Registry

**Status:** Active Governance Artifact
**Authority:** SH Core Canonical v1.0 §20, §26, §27; SH Full Execution Strategy v1.0 §6.4; SH Full Build Scope v1.0 §32; ADR-001; ADR-002
**Created:** 2026-08-10
**Maintainer:** Owner / Governance Process
**Representation:** Repository-only (ADR-001). No database registry. No runtime enforcement.

## Purpose

This registry catalogs the Phase 1 governance seed set and records the engineering realization state of selected Core-related entries. It also provides the separate Immutable vs Evolvable dimension required by Execution Strategy §6.4.

**Important scope clarification:** the 58 rows are not all canonical “Core elements”. Category 1 and Category 4 are canonical Core material; Category 2 and Category 3 are open-question and decision records. Therefore `constitution_class` is canonical only where the referenced source explicitly classifies a Core element under Canonical §20. For non-Core registry records, the value is an **engineering/derived registry classification** used for traceability and must not be read back into the Canonical as a new classification.

This registry is not a runtime database, not a new authority, and not a source of new invariants.

## ADR-001 — Constitution Registry Representation Format

**Status:** ACCEPTED  
**Authority Level:** Engineering Realization / Implementation-Specific

Decision:
- Repository-only representation for Phase 1.
- Source of truth: `docs/constitution/registry.md`
- Audit trail: `docs/constitution/change_log.md`
- No database registry in BL-P1-001.
- No runtime enforcement in BL-P1-001.

Rejected alternatives:
1. Database-only registry — premature Phase 2 governance surface.
2. Hybrid DB index — deferred until a later runtime consumer requires queryability.

Canonical impact: NONE.

## ADR-002 — Constitution Registry Field Structure

**Status:** ACCEPTED — REVISED
**Authority Level:** Engineering Realization / Implementation-Specific

The registry uses eight fields:
- `element_id`
- `element_name`
- `constitution_class`
- `immutability_class`
- `authority_ref`
- `implementation_status`
- `version`
- `change_ref`

### `constitution_class`

For actual Core elements, this follows the four-class model in Canonical §20 exactly:
- Protected/Fundamental
- Evolvable-Through-Governance
- Instance-Specific
- Implementation-Specific

For Category 2 Open Questions and Category 3 Decision Records, this field is a **derived registry placement**, not a claim that Canonical §20 directly classifies those records. This clarification prevents the registry from silently turning non-Core governance records into canonical Core elements.

### `immutability_class`

This is a separate engineering/derived dimension created to satisfy Execution Strategy §6.4’s “Immutable vs Evolvable” DoD. It is not a new canonical classification.

Allowed values:
- `IMMUTABLE` — absolutely immutable, where a legitimate canonical determination exists.
- `EVOLVABLE` — evolvable, where a legitimate determination exists.
- `UNRESOLVED_PENDING_OQ-02` — legitimate Immutable/Evolvable determination is not yet available because Canonical §27.2 remains OPEN.

Mapping:
- Protected/Fundamental → `UNRESOLVED_PENDING_OQ-02`
- Evolvable-Through-Governance → `EVOLVABLE`
- Instance-Specific → `EVOLVABLE`
- Implementation-Specific → `EVOLVABLE`

This mapping is intentionally conservative. Canonical §20.1 requires strong protection but does not itself declare Protected/Fundamental absolutely immutable. Canonical §27.2 explicitly asks which Core elements are absolutely immutable versus protected but evolvable. Therefore no Protected/Fundamental row is promoted to `IMMUTABLE` in this Phase 1 registry.

### `implementation_status`

Only the declared enum is used:
`CANONICAL`, `IMPLEMENTED`, `HARDENED`, `IN_DEVELOPMENT`, `PARTIALLY_IMPLEMENTED`, `DESIGNED`, `DEFERRED`, `NOT_YET_STARTED`, `OPEN`, `ACTIVE_CONSTRAINT`.

Approval state and phase sequencing remain in Notes, never in `implementation_status`.

### Critical separation rule

`constitution_class` ≠ `immutability_class` ≠ `implementation_status` ≠ approval/decision state ≠ phase sequencing.

## Canonical Reference — §20

Canonical §20 states that “immutable” must be interpreted carefully. Protected/Fundamental elements require strong protection; it does not state that every such element is absolutely immutable. Evolvable-Through-Governance covers controlled evolution. Instance-Specific and Implementation-Specific material may change without redefining SH identity.

## OQ-02 Boundary

Canonical §27.2 remains OPEN:

> Which Core elements are absolutely immutable, and which are protected but evolvable?

This registry does **not** resolve OQ-02. `UNRESOLVED_PENDING_OQ-02` is an engineering/derived state only.

## Category 1: Canonical Invariants (Canonical §26)

**Count:** 18

| element_id | element_name | constitution_class | immutability_class | authority_ref | implementation_status | version | change_ref |
|---|---|---|---|---|---|---|---|
| CI-01 | SH Core is the foundational and governing core of SECOND HEAD | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.1 | CANONICAL | v1.0 | BL-P1-001 |
| CI-02 | SH Core exists at fundamental/governance and architectural/runtime levels as related layers of one broader concept | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.2 | CANONICAL | v1.0 | BL-P1-001 |
| CI-03 | SH Core protects identity and continuity of SECOND HEAD across model, runtime, and infrastructure changes | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.3 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| CI-04 | Model ≠ SH Identity | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.4; Contract §3; Guide INV-03 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| CI-05 | Runtime ≠ SH Identity | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.5; Contract §3; Guide INV-04 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| CI-06 | Database ≠ SH Identity | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.6 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| CI-07 | Creator Authority ≠ Private Data Access | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.7; §4.5; §7.3; BuildScope D-05 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| CI-08 | SH-000 Core Authority ≠ Private Data Access | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.8; §4.6; §8.4; BuildScope D-06 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| CI-09 | Runtime Access ≠ Ownership | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.9; §4.7 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| CI-10 | System Governance ≠ Omniscient Data Access | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.10; §4.8 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| CI-11 | Private SH/User data is isolated by default | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.11; §11.1; Contract §29 | PARTIALLY_IMPLEMENTED | v1.0 | BL-P1-001 |
| CI-12 | Shared SH Core does not imply shared private memory or private context | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.12; §11.4; §25.7 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| CI-13 | Learning ≠ Automatic Core Modification | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.13; §4.9 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| CI-14 | Core evolution requires appropriate governance/review | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.14; §9.2; §19 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| CI-15 | Core evolution does not automatically replace the identity of existing SH instances | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.15; §9.4; §19.3 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| CI-16 | SH Core Lite is a constrained implementation of selected SH Core concepts, not a separate species of SH | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.16; §13 | CANONICAL | v1.0 | BL-P1-001 |
| CI-17 | Model, runtime, infrastructure, and implementation technology may evolve without automatically changing SH identity | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.17; §20.4 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| CI-18 | Fundamental Core boundaries must not be silently bypassed by ordinary user-level operations | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §26.18; §9.3 | NOT_YET_STARTED | v1.0 | BL-P1-001 |

**Notes:** All 18 invariants are Protected/Fundamental and therefore remain `UNRESOLVED_PENDING_OQ-02`. This does not resolve OQ-02. CI-01, CI-02 and CI-16 are marked CANONICAL because they are directly stated by Canonical §26. CI-11 retains PARTIALLY_IMPLEMENTED only as an engineering status carried from the pre-mutation package; this registry does not independently establish that implementation claim.

## Category 2: Open Questions (Canonical §27)

**Count:** 10

These are registry records for open design questions, not additional Core elements. Their `constitution_class` and `immutability_class` are derived engineering placement values only.

| element_id | element_name | constitution_class | immutability_class | authority_ref | implementation_status | version | change_ref |
|---|---|---|---|---|---|---|---|
| OQ-01 | Complete formal inventory of all fundamental SH Core elements | Evolvable-Through-Governance | EVOLVABLE | Canonical §27.1 | OPEN | v1.0 | BL-P1-001 |
| OQ-02 | Which Core elements are absolutely immutable vs protected but evolvable | Evolvable-Through-Governance | EVOLVABLE | Canonical §27.2 | OPEN | v1.0 | BL-P1-001 |
| OQ-03 | Exact governance mechanism authorizing SH-000/Core changes | Evolvable-Through-Governance | EVOLVABLE | Canonical §27.3 | OPEN | v1.0 | BL-P1-001 |
| OQ-04 | Exact limits of SH-000 Core authority | Evolvable-Through-Governance | EVOLVABLE | Canonical §27.4 | OPEN | v1.0 | BL-P1-001 |
| OQ-05 | How Core Review is formally performed and audited | Evolvable-Through-Governance | EVOLVABLE | Canonical §27.5 | OPEN | v1.0 | BL-P1-001 |
| OQ-06 | How generalized insights are separated from private user information | Evolvable-Through-Governance | EVOLVABLE | Canonical §27.6 | OPEN | v1.0 | BL-P1-001 |
| OQ-07 | How SH Knowledge relates technically to SH Core | Evolvable-Through-Governance | EVOLVABLE | Canonical §27.7 | OPEN | v1.0 | BL-P1-001 |
| OQ-08 | Exact identity-anchor architecture replacing/formalizing temporary implementation mappings | Evolvable-Through-Governance | EVOLVABLE | Canonical §27.8 | OPEN | v1.0 | BL-P1-001 |
| OQ-09 | How Core evolution is versioned, migrated, rolled back, and validated | Evolvable-Through-Governance | EVOLVABLE | Canonical §27.9 | OPEN | v1.0 | BL-P1-001 |
| OQ-10 | Which parts of full SH Core must be implemented before SH Full is complete | Evolvable-Through-Governance | EVOLVABLE | Canonical §27.10 | OPEN | v1.0 | BL-P1-001 |

**Notes:** All OQs remain OPEN. OQ-02 is intentionally not resolved by this registry.

## Category 3: Decision Records (Build Scope §32)

**Count:** 18

These are Owner-approved build-scope decisions, not additional Canonical §20 Core elements. Their `constitution_class` and `immutability_class` are derived registry placement values used for traceability only.

| element_id | element_name | constitution_class | immutability_class | authority_ref | implementation_status | version | change_ref |
|---|---|---|---|---|---|---|---|
| DR-01 | Full SH Core Realization | Evolvable-Through-Governance | EVOLVABLE | BuildScope §32 D-01 | DESIGNED | v1.0 | BL-P1-001 |
| DR-02 | SH Full as continuation of the journey (not restart) | Evolvable-Through-Governance | EVOLVABLE | BuildScope §32 D-02 | DESIGNED | v1.0 | BL-P1-001 |
| DR-03 | V2.1 Status: Implementation Complete + Owner Ratified | Instance-Specific | EVOLVABLE | BuildScope §32 D-03 | IMPLEMENTED | v1.0 | BL-P1-001 |
| DR-04 | Account Identity: 1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | BuildScope §32 D-04; Canonical §6.3; Contract §3 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| DR-05 | Creator Authority (≠ Private Data Access) | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | BuildScope §32 D-05; Canonical §7.3 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| DR-06 | Creator Privacy Boundary | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | BuildScope §32 D-06; Canonical §7.3; §25.5 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| DR-07 | SH-000 as Creator's SH with privileged Core Governance capability | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | BuildScope §32 D-07; Canonical §8 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| DR-08 | SH Journey / Inheritance / Legacy | Evolvable-Through-Governance | EVOLVABLE | BuildScope §32 D-08; Contract §12–15 | DEFERRED | v1.0 | BL-P1-001 |
| DR-09 | Memory Governance | Evolvable-Through-Governance | EVOLVABLE | BuildScope §32 D-09; Canonical §15 | DEFERRED | v1.0 | BL-P1-001 |
| DR-10 | Continuity / Recovery / Backup / Restore | Evolvable-Through-Governance | EVOLVABLE | BuildScope §32 D-10; Canonical §6.11 | DEFERRED | v1.0 | BL-P1-001 |
| DR-11 | Clone | Evolvable-Through-Governance | EVOLVABLE | BuildScope §32 D-11; Contract §11 | DEFERRED | v1.0 | BL-P1-001 |
| DR-12 | Data Portability | Evolvable-Through-Governance | EVOLVABLE | BuildScope §32 D-12 | DEFERRED | v1.0 | BL-P1-001 |
| DR-13 | Zero Budget | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | BuildScope §32 D-13; BuildScope §5 | ACTIVE_CONSTRAINT | v1.0 | BL-P1-001 |
| DR-14 | Zero Hardware Cost | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | BuildScope §32 D-14; BuildScope §5 | ACTIVE_CONSTRAINT | v1.0 | BL-P1-001 |
| DR-15 | Mobile-First | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | BuildScope §32 D-15; BuildScope §6 | ACTIVE_CONSTRAINT | v1.0 | BL-P1-001 |
| DR-16 | Tools (full scope) | Evolvable-Through-Governance | EVOLVABLE | BuildScope §32 D-16; Canonical §6.10 | DEFERRED | v1.0 | BL-P1-001 |
| DR-17 | Scope Coverage (full capability inclusion) | Evolvable-Through-Governance | EVOLVABLE | BuildScope §32 D-17; BuildScope §7 | DESIGNED | v1.0 | BL-P1-001 |
| DR-18 | Creator-Immutability Boundary | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | BuildScope §32 D-18; Canonical §7.3; §25.5 | NOT_YET_STARTED | v1.0 | BL-P1-001 |

**Notes:** DR-01, DR-02 and DR-17 are APPROVED scope decisions; `DESIGNED` means scope/design is set, not that they are Canonical. DR-03 records the stated V2.1 implementation/ratification state; it is an Instance-Specific registry record, not a new Core invariant. DR-08..DR-12 and DR-16 are deferred by phase sequencing. DR-13..DR-15 are active constraints.

## Category 4: Core Components (Canonical §6)

**Count:** 12

| element_id | element_name | constitution_class | immutability_class | authority_ref | implementation_status | version | change_ref |
|---|---|---|---|---|---|---|---|
| CC-01 | Fundamental Identity | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §6.1 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| CC-02 | Core Philosophy | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §6.2 | CANONICAL | v1.0 | BL-P1-001 |
| CC-03 | Core Principles and Invariants | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §6.3; §26 | CANONICAL | v1.0 | BL-P1-001 |
| CC-04 | Governance | Evolvable-Through-Governance | EVOLVABLE | Canonical §6.4 | DEFERRED | v1.0 | BL-P1-001 |
| CC-05 | Identity and Ownership | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §6.5 | NOT_YET_STARTED | v1.0 | BL-P1-001 |
| CC-06 | Context | Evolvable-Through-Governance | EVOLVABLE | Canonical §6.6 | DEFERRED | v1.0 | BL-P1-001 |
| CC-07 | Memory | Evolvable-Through-Governance | EVOLVABLE | Canonical §6.7 | DEFERRED | v1.0 | BL-P1-001 |
| CC-08 | Knowledge | Evolvable-Through-Governance | EVOLVABLE | Canonical §6.8 | DEFERRED | v1.0 | BL-P1-001 |
| CC-09 | Model Orchestration | Implementation-Specific | EVOLVABLE | Canonical §6.9 | DEFERRED | v1.0 | BL-P1-001 |
| CC-10 | Tools and Actions | Implementation-Specific | EVOLVABLE | Canonical §6.10 | DEFERRED | v1.0 | BL-P1-001 |
| CC-11 | Continuity | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §6.11 | DEFERRED | v1.0 | BL-P1-001 |
| CC-12 | Security and Persistence | Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | Canonical §6.12 | PARTIALLY_IMPLEMENTED | v1.0 | BL-P1-001 |

**Notes:** Category 4 consists of canonical Core components. The §20 classification is an engineering mapping from the nature of each component to the four-class model; where the canonical text does not explicitly label the component's class, this registry must not be treated as having added canonical semantics.

## Registry Summary

| Category | Source | Count |
|---|---|---:|
| Canonical Invariants | Canonical §26 | 18 |
| Open Questions | Canonical §27 | 10 |
| Decision Records | Build Scope §32 | 18 |
| Core Components | Canonical §6 | 12 |
| **Total** | | **58** |

## Immutability Dimension Summary

| immutability_class | Count | Meaning |
|---|---:|---|
| IMMUTABLE | 0 | No entry is legitimately declared absolutely immutable while OQ-02 remains OPEN. |
| EVOLVABLE | 26 | Derived from the non-Protected/Fundamental placements used in this registry. |
| UNRESOLVED_PENDING_OQ-02 | 32 | Protected/Fundamental placements for which Canonical §27.2 prevents a legitimate absolute determination. |
| **Total** | **58** | |

The zero `IMMUTABLE` count is deliberate and conservative. It does not mean Canonical §20 declares that nothing is immutable; it means this registry does not make that determination while OQ-02 is open.

## Self-Audit

### implementation_status

| Status | Count |
|---|---:|
| CANONICAL | 5 |
| IMPLEMENTED | 1 |
| HARDENED | 0 |
| IN_DEVELOPMENT | 0 |
| PARTIALLY_IMPLEMENTED | 2 |
| DESIGNED | 3 |
| DEFERRED | 13 |
| NOT_YET_STARTED | 21 |
| OPEN | 10 |
| ACTIVE_CONSTRAINT | 3 |
| **Total** | **58** |

### constitution_class placement

| constitution_class | Count |
|---|---:|
| Protected/Fundamental | 32 |
| Evolvable-Through-Governance | 23 |
| Instance-Specific | 1 |
| Implementation-Specific | 2 |
| **Total** | **58** |

**Important:** these counts are registry placement counts, not a claim that all 58 rows are Canonical §20 Core elements.

### Cross-dimension consistency

| constitution_class | immutability_class | Result |
|---|---|---|
| Protected/Fundamental | UNRESOLVED_PENDING_OQ-02 | CONSISTENT |
| Evolvable-Through-Governance | EVOLVABLE | CONSISTENT |
| Instance-Specific | EVOLVABLE | CONSISTENT AS DERIVED REGISTRY STATE |
| Implementation-Specific | EVOLVABLE | CONSISTENT AS DERIVED REGISTRY STATE |

## Acceptance Evidence

This file is the repository representation required by Execution Strategy §6.4. It does not claim the later Phase 1 identity, ownership, privacy, or isolation DoD items are complete.

## Governance Notes

- Changes require the applicable governance process.
- Every registry mutation is recorded in `change_log.md`.
- This registry adds no invariant and no canonical authority.
- OQ-02 remains OPEN.
- `UNRESOLVED_PENDING_OQ-02` is an engineering/derived state only.
- Canonical changes must be made through the Canonical governance process.
