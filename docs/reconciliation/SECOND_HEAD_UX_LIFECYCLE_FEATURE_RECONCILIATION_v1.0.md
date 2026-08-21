# SECOND HEAD — UX / LIFECYCLE FEATURE RECONCILIATION v1.0

Status: RATIFIED FOR IMPLEMENTATION
Baseline: Canonical Matrix remains the single execution authority. Architecture baseline remains unchanged.

## 1. Audit result

The following owner requests were audited against the existing architecture, lifecycle reconciliation, privacy/transfer reconciliation, runtime implementation and current application behavior. Where the canonical sources already establish the semantic boundary, this document does not replace that rule; it reconciles the missing user-facing contract.

## 2. Ratified UX contracts

| Area | Ratified behavior |
|---|---|
| Inheritance | User enters **Target Account ID only**. Backend resolves the target account's active PRIMARY SH. SH IDs remain internal system identifiers. |
| Succession | User enters **Successor Account ID**. Existing model remains. |
| Clone | User enters **recipient email only**. Backend/application resolves the current account's PRIMARY SH as the source. |
| End-of-Life | User first sees a confirmation dialog. Execution occurs only after explicit **Yes**. **No** cancels without execution. |
| Chat continuity | A completed response returns the composer to a sendable state. Saving to Journey is optional and must not gate the next message. |
| Save to Journey | Remains an explicit optional capture action. |
| Save as Memory | A user may explicitly save the latest user statement as Memory. This is not automatic Memory creation. |
| Journey detail | Long `What happened` content must be scrollable and must not hide Save Policy / Cancel / Close actions. |
| Journey deletion | Owner may delete a Journey event through an authorized backend operation. Deleting a Journey event does not delete its underlying Memory, Knowledge or Experience record. |

## 3. Authority boundary

FE provides the user interaction. BE/runtime remains responsible for authentication, ownership, Account→PRIMARY-SH resolution, authorization and mutation enforcement.

## 4. Privacy / transfer boundary

The previously ratified rules remain unchanged:

- `INHERITABLE` terminology is replaced by `INHERITANCE`.
- `NON_TRANSFERABLE` is excluded from Clone state.
- private personal/sensitive material is not Clone state.
- Authority is an explicit enforcement layer between eligibility policy and operation execution.

## 5. Recovery observation

Repeated Recovery records appearing around ordinary login/session bootstrap require runtime evidence before a final semantic claim is made. Recovery Journey records must represent actual recovery events, not ordinary authentication alone. This remains a BE audit item and is not silently declared fixed by the UI changes in this reconciliation.

## 6. Implementation checkpoint

Implementation scope for this reconciliation includes:

- Account-only Inheritance UI + Account→PRIMARY-SH backend resolution.
- Email-only Clone UI with automatic source SH resolution in the current account context.
- End-of-Life confirmation gate.
- Continuous chat send state and explicit Save as Memory action.
- Journey delete service/RPC and owner check.
- Scrollable Journey detail/editor surface.
- `INHERITANCE` terminology in Experience policy types/UI.

CI is the next acceptance gate. Runtime APK evidence remains separate and must be recorded in the Canonical Matrix only after actual execution.
