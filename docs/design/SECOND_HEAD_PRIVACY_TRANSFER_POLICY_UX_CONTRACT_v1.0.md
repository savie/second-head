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

Journey remains the unified discovery/history surface. Journey may display:

- meaningful content
- source
- visibility/scope
- transfer policy
- timestamp

Journey remains read/discovery oriented and does not execute lifecycle actions.

### 4.2 Memory

No new top-level Memory management screen is required by this contract.

Memory can be discovered through Journey and authorized runtime context. When an Owner-facing record detail exists, the policy block belongs there.

### 4.3 Knowledge

No new top-level Knowledge management screen is required by this contract.

Knowledge can be discovered through Journey and authorized runtime context. When an Owner-facing record detail exists, the policy block belongs there.

### 4.4 Experience

Existing Experience detail/list presentation remains the base surface. Do not create a new primary Home/More destination solely for policy editing.

## 5. Policy presentation

For an Owner-owned record, the detail context may show:

```text
Visibility
Private / Shared

Transfer policy
Non-transferable / Inheritable / Succession / Legacy
```

Internal IDs must not be the primary mental model.

## 6. Editability

Policy editing is an Owner-authorized record-management operation, not a lifecycle execution operation.

The policy may be edited only when:

1. the authenticated actor is authorized to manage the source record;
2. the record belongs to the Owner's SH domain;
3. the backend accepts the requested policy transition;
4. the resulting state is persisted successfully.

The client must not implement authorization or ownership decisions locally.

## 7. No automatic policy change

The following transitions are prohibited as implicit side effects:

```text
PRIVATE → GENERAL merely to enable transfer
OWNER_ONLY → SHARED merely to enable transfer
NON_TRANSFERABLE → INHERITABLE merely because Inheritance screen is opened
NON_TRANSFERABLE → SUCCESSION merely because Succession screen is opened
NON_TRANSFERABLE → LEGACY merely because Legacy screen is opened
```

Lifecycle screens only consume already-authorized eligible policy states.

## 8. Lifecycle separation

Lifecycle is an action/process surface.

```text
Record detail
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

## 9. Eligibility presentation

Lifecycle selection must filter by the relevant transfer policy, not by privacy scope.

```text
Inheritance → INHERITABLE
Succession  → SUCCESSION
Legacy      → LEGACY
```

`NON_TRANSFERABLE` is excluded from the corresponding transfer selection.

A PRIVATE record with an applicable transfer policy remains eligible subject to authorization and selection rules.

A SHARED/GENERAL record without an applicable transfer policy remains ineligible.

## 10. Authorization separation

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

## 11. Domain options

For Memory, Knowledge, and Experience the common transfer-policy vocabulary is:

```text
NON_TRANSFERABLE
INHERITABLE
SUCCESSION
LEGACY
```

The UI should present human-readable labels. Internal enum values remain implementation vocabulary.

Domain-specific restrictions must be enforced by the backend contract; the FE must not invent additional policy semantics.

## 12. Default state

Existing/new record defaults remain governed by the canonical/backend contract.

Current DEV default is:

```text
PRIVATE
OWNER_ONLY
NON_TRANSFERABLE
```

This contract does not authorize mass conversion of existing records to GENERAL/SHARED.

## 13. UX anti-patterns

Do not add:

- a standalone `Policy Management` item to More solely for this capability;
- a second `Open Experience` surface duplicating Journey unnecessarily;
- policy controls inside lifecycle execution that silently change policy;
- public/private as a proxy for transfer eligibility;
- local FE authorization logic.

## 14. Minimal UI direction

When a record detail surface supports editing, the minimal interaction is a compact policy section in that detail context:

```text
Visibility
Private

Transfer policy
Non-transferable   [edit]
```

Editing should expose only the supported policy choices and require an explicit save/confirmation path. Exact component styling is intentionally left to the existing owner-app design system.

No new navigation destination is required by this contract.

## 15. Backend contract boundary

The FE may call the existing policy-management service/API capability, but backend remains authoritative for:

- ownership
- RLS/privacy boundary
- authorization
- valid policy transitions
- transfer eligibility
- lifecycle execution
- audit/provenance

The FE must treat backend rejection as authoritative.

## 16. Verification contract

Before APK/Real E2E, verify at BE/DB level:

1. Owner can read own PRIVATE record.
2. Owner can read own SHARED/GENERAL record.
3. PRIVATE + NON_TRANSFERABLE is rejected by transfer execution.
4. PRIVATE + INHERITABLE can pass eligible inheritance selection when authorized.
5. PRIVATE + SUCCESSION can pass eligible succession selection when authorized.
6. PRIVATE + LEGACY can pass eligible legacy selection when authorized.
7. SHARED/GENERAL without applicable transfer policy is not transferable.
8. Unauthorized cross-SH access remains denied.
9. Lifecycle selection does not mutate policy.
10. Policy editing does not itself execute lifecycle transfer.

## 17. Canonical / UX alignment

The owner app remains capability-oriented:

```text
Chat | Journey | Lifecycle | More
```

Journey is the unified continuity/history viewer; Lifecycle is the action/process surface; backend/runtime remains authoritative for governance, ownership, authorization, and lifecycle policy.

This contract extends the existing canonical privacy/transfer semantics without changing the primary navigation model.

## 18. Scope / contract / execution mapping

### Scope

- define privacy/visibility versus transfer-policy semantics;
- define Owner-facing presentation and editability;
- reconcile Memory, Knowledge, Experience;
- reconcile Inheritance, Succession, Legacy selection;
- define authorization boundary;
- define verification cases.

### Implementation Contract

- preserve existing canonical navigation;
- use record detail as the policy presentation point when available;
- do not create a new primary policy-management destination;
- keep lifecycle screens action-only;
- keep backend authoritative.

### Executive Execution Strategy

```text
Canonical + Addendum
        ↓
UX Contract
        ↓
BE/DB/RLS contract validation
        ↓
FE policy presentation/edit interaction
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

The implementation task should therefore be recorded as a scoped backlog item with dependencies and DoD before coding.

## 19. Implementation status

- [x] Canonical baseline identified.
- [x] Privacy/transfer addendum identified.
- [x] Owner ratification completed by explicit Owner `GO`.
- [x] Existing owner navigation preserved.
- [x] Record-detail policy location defined.
- [x] Memory/Knowledge/Experience surface strategy defined.
- [x] Lifecycle separation defined.
- [x] Authorization separation defined.
- [x] Supported policy options defined.
- [x] Anti-patterns defined.
- [x] Verification contract defined.
- [x] BE migration exposes Experience transfer policy in existing owner retrieval.
- [x] FE Experience detail supports policy presentation/edit/save.
- [ ] Memory owner-facing record detail policy editor.
- [ ] Knowledge owner-facing record detail policy editor.
- [ ] CI verification.
- [ ] Supabase DEV verification after implementation.
- [ ] Real E2E evidence.

END
