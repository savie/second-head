# SECOND HEAD — Privacy / Transfer Policy UX Contract v1.0

Status: RATIFIED / IMPLEMENTATION IN PROGRESS
Branch: `dev`
Authority baseline: SH Core Canonical at `a60eb3237f1bee48e050bc1d869e955a8d07337e`
Related canonical extension: Privacy / Transfer Policy Addendum `6a307f20684bbc10f0ef4660ede588c9b0c00e`
Related UX baseline: `docs/SH_APP_OWNER_UX_STRUCTURE_v1.1.md`
Owner decision status: RATIFIED by explicit Owner `GO` after contract review.

## 1. Purpose

Define the exact owner-facing UX contract for Memory, Knowledge, and Experience privacy and transfer policy before further FE implementation.

This document is the ratified design contract for the implementation work below. It does not authorize changes that conflict with the Core Canonical or Addendum.

## 2. Core semantic rule

```text
PRIVACY / VISIBILITY
        ≠
TRANSFER ELIGIBILITY
```

Privacy/scope answers who may access or view a record.

Transfer policy answers whether a record may participate in an authorized lifecycle transfer and, if so, through which lifecycle mechanism.

A PRIVATE record is not automatically NON_TRANSFERABLE.

A SHARED/GENERAL record is not automatically transferable.

## 3. Owner mental model

The Owner should see one record with two separate concepts:

```text
Record
├── Visibility / Scope
└── Transfer Policy
```

The Owner must never be required to infer transfer eligibility from the word `Private` or `Public/Shared`.

## 4. Where policy is shown

### 4.1 Primary presentation

Policy is presented in the existing record/event detail context, not as a new primary navigation destination.

**Journey is the unified owner-facing discovery/detail surface for Memory, Knowledge, and Experience.** The existing Journey filters remain:

```text
All | Memory | Knowledge | Experience | Lifecycle / Other
```

The Owner taps a relevant event/record and sees its detail. For owner-owned Memory, Knowledge, and Experience records, the detail includes the record's visibility/scope and transfer policy, with an explicit policy edit/save interaction.

Journey remains a discovery/history surface and does not execute lifecycle transfers.

### 4.2 Memory

No new top-level Memory management screen is required.

Memory is discovered through the existing Journey Memory filter. The selected Memory detail resolves the underlying Owner-owned Memory record and exposes its policy controls.

### 4.3 Knowledge

No new top-level Knowledge management screen is required.

Knowledge is discovered through the existing Journey Knowledge filter. The selected Knowledge/learning detail resolves the underlying Owner-owned Knowledge record and exposes its policy controls.

### 4.4 Experience

No new primary Experience navigation destination is required for policy editing.

Experience is discovered through the existing Journey Experience filter, and the existing Experience list/detail remains available as a compatible secondary surface. Journey detail also resolves the underlying Experience record and exposes the same policy controls.

## 5. Creation versus post-creation policy control

The current Chat capture flow is intentionally **not** a transfer-policy authoring surface.

Chat explicit save exposes Experience capture scope/visibility (`PRIVATE/GENERAL` and `OWNER_ONLY/SHARED`) and saves the last message to Journey. It does not expose transfer policy selection.

Therefore:

```text
Chat capture
    ↓
create/capture Experience
    ↓
default transfer policy remains backend-defined
    ↓
Journey record detail
    ↓
Owner may explicitly edit record policy
    ↓
Lifecycle consumes resulting eligibility
```

Do not add a transfer-policy selector to Chat merely because the backend service supports `transfer_policy`.

For new records, the current DEV backend default remains:

```text
PRIVATE
OWNER_ONLY
NON_TRANSFERABLE
```

## 6. Policy presentation

For an Owner-owned record, the detail context shows:

```text
Visibility
Private / Shared

Transfer policy
Non-transferable / Inheritable / Succession / Legacy

[Edit policy]
```

Internal IDs must not be the primary mental model.

## 7. Editability

Policy editing is an Owner-authorized record-management operation, not a lifecycle execution operation.

The policy may be edited only when:

1. the authenticated actor is authorized to manage the source record;
2. the record belongs to the Owner's SH domain;
3. the backend accepts the requested policy transition;
4. the resulting state is persisted successfully.

The client must not implement authorization or ownership decisions locally.

## 8. No automatic policy change

The following transitions are prohibited as implicit side effects:

```text
PRIVATE → GENERAL merely to enable transfer
OWNER_ONLY → SHARED merely to enable transfer
NON_TRANSFERABLE → INHERITABLE merely because Inheritance screen is opened
NON_TRANSFERABLE → SUCCESSION merely because Succession screen is opened
NON_TRANSFERABLE → LEGACY merely because Legacy screen is opened
```

Lifecycle screens only consume already-authorized eligible policy states.

## 9. Lifecycle separation

Lifecycle is an action/process surface.

```text
Journey record detail
    ↓
policy is defined
    ↓
Lifecycle
    ↓
eligible records are shown
    ↓
Owner explicitly selects records
    ↓
authorization is evaluated
    ↓
selected transfer executes
```

Inheritance, Succession, and Legacy must not silently mutate a record's policy simply by selecting it.

## 10. Eligibility presentation

Lifecycle selection must filter by the relevant transfer policy, not by privacy scope.

```text
Inheritance → INHERITABLE
Succession  → SUCCESSION
Legacy      → LEGACY
```

`NON_TRANSFERABLE` is excluded from the corresponding transfer selection.

A PRIVATE record with an applicable transfer policy remains eligible subject to authorization and selection rules.

A SHARED/GENERAL record without an applicable transfer policy remains ineligible.

## 11. Authorization separation

Authorization is a separate concern from both visibility and transfer policy.

```text
visibility/scope
      ↓
who may access/view

transfer policy
      ↓
what lifecycle mechanism may use the record

authorization
      ↓
whether this particular cross-SH transfer is permitted

selection
      ↓
which eligible records are actually transferred
```

No UI shortcut may collapse these into a single `Public/Private` switch.

## 12. Domain options

For Memory, Knowledge, and Experience the common transfer-policy vocabulary is:

```text
NON_TRANSFERABLE
INHERITABLE
SUCCESSION
LEGACY
```

The UI presents human-readable labels. Internal enum values remain implementation vocabulary.

Domain-specific restrictions are enforced by the backend contract; the FE does not invent additional policy semantics.

## 13. Default state

Existing/new record defaults remain governed by the canonical/backend contract.

Current DEV default is:

```text
PRIVATE
OWNER_ONLY
NON_TRANSFERABLE
```

This contract does not authorize mass conversion of existing records to GENERAL/SHARED.

## 14. UX anti-patterns

Do not add:

- a standalone `Policy Management` item to More solely for this capability;
- a second `Open Experience` surface duplicating Journey unnecessarily;
- policy controls inside lifecycle execution that silently change policy;
- public/private as a proxy for transfer eligibility;
- local FE authorization logic;
- a transfer-policy selector in Chat capture solely to expose a backend capability.

## 15. Minimal UI direction

Journey detail uses one consistent policy block for Memory, Knowledge, and Experience:

```text
Visibility
Private

Transfer policy
Non-transferable

[Edit policy]
```

Editing exposes the supported scope/visibility and transfer-policy choices and requires an explicit save/cancel path. Exact component styling follows the existing owner-app design system.

No new navigation destination is required.

## 16. Backend contract boundary

The FE may call the existing policy-management service/API capability, but backend remains authoritative for:

- ownership
- RLS/privacy boundary
- authorization
- valid policy transitions
- transfer eligibility
- lifecycle execution
- audit/provenance

Journey uses a backend record-resolution bridge to map a Journey event to its underlying Owner-owned Memory, Knowledge, or Experience record. The bridge does not grant additional access and does not execute lifecycle operations.

The FE must treat backend rejection as authoritative.

## 17. Verification contract

Before APK/Real E2E, verify at BE/DB level:

1. Owner can read own PRIVATE record.
2. Owner can read own SHARED/GENERAL record.
3. Journey Memory detail resolves the underlying Owner Memory record.
4. Journey Knowledge detail resolves the underlying Owner Knowledge record.
5. Journey Experience detail resolves the underlying Owner Experience record.
6. Owner policy edit persists through the backend policy service.
7. PRIVATE + NON_TRANSFERABLE is rejected by transfer execution.
8. PRIVATE + INHERITABLE can pass eligible inheritance selection when authorized.
9. PRIVATE + SUCCESSION can pass eligible succession selection when authorized.
10. PRIVATE + LEGACY can pass eligible legacy selection when authorized.
11. SHARED/GENERAL without applicable transfer policy is not transferable.
12. Unauthorized cross-SH access remains denied.
13. Lifecycle selection does not mutate policy.
14. Policy editing does not itself execute lifecycle transfer.

## 18. Canonical / UX alignment

The owner app remains capability-oriented:

```text
Chat | Journey | Lifecycle | More
```

Journey is the unified continuity/history viewer and now the common record-detail policy presentation point; Lifecycle is the action/process surface; backend/runtime remains authoritative for governance, ownership, authorization, and lifecycle policy.

This contract extends the existing canonical privacy/transfer semantics without changing the primary navigation model.

## 19. Scope / contract / execution mapping

### Scope

- define privacy/visibility versus transfer-policy semantics;
- define Owner-facing presentation and editability;
- reconcile Memory, Knowledge, Experience;
- reconcile Inheritance, Succession, Legacy selection;
- define authorization boundary;
- define verification cases.

### Implementation Contract

- preserve existing canonical navigation;
- use Journey detail as the common policy presentation/edit point;
- do not create a new primary policy-management destination;
- keep lifecycle screens action-only;
- keep backend authoritative;
- keep Chat capture focused on Journey/Experience capture rather than transfer-policy authoring.

### Executive Execution Strategy

```text
Canonical + Addendum
        ↓
UX Contract
        ↓
BE/DB/RLS contract validation
        ↓
FE Journey detail policy interaction
        ↓
CI
        ↓
Supabase DEV verification
        ↓
APK only if FE changes require it
        ↓
Real E2E
```

### Phase -1 linkage

This work is treated as planning/contract refinement before implementation, consistent with Phase -1's purpose. Phase -1 planning defines backlog, milestone mapping, task breakdown, risk register, architecture checklist, dependency map, and evidence; planning must not change architecture or requirements by itself.

## 20. Implementation status

- [x] Canonical baseline identified.
- [x] Privacy/transfer addendum identified.
- [x] Owner ratification completed by explicit Owner `GO`.
- [x] Existing owner navigation preserved.
- [x] Journey filters preserved.
- [x] Common Journey record-detail policy location defined.
- [x] Memory/Knowledge/Experience surface strategy defined.
- [x] Lifecycle separation defined.
- [x] Authorization separation defined.
- [x] Supported policy options defined.
- [x] Anti-patterns defined.
- [x] Verification contract defined.
- [x] Chat capture audited and confirmed as non-policy-authoring flow.
- [x] BE migration exposes Experience transfer policy in existing owner retrieval.
- [x] FE Experience detail supports policy presentation/edit/save.
- [x] Journey FE policy editor implemented for resolvable Memory/Knowledge/Experience records.
- [x] BE Journey-to-record policy resolution bridge added.
- [x] Supabase DEV migration applied.
- [ ] Controlled INHERITABLE/SUCCESSION/LEGACY fixture verification.
- [ ] CI verification.
- [ ] APK verification for Journey policy editor.
- [ ] Real E2E evidence.

## 21. Current decision status

No further Owner product decision is required for the policy-editor location.

Owner decision is:

```text
Journey
  ↓
Memory / Knowledge / Experience filter
  ↓
Record / Event Detail
  ↓
Visibility
Transfer Policy
  ↓
Edit
```

Implementation proceeds under this decision.

END
