# EV-FE-BE-001 — FE ↔ BE UX / Lifecycle Synchronization Closure

Status: RECONCILED / IMPLEMENTATION CLOSED FOR DETERMINISTIC FE GAPS
Authority baseline: canonical matrix + ratified UX/lifecycle reconciliation
Branch: dev

## Scope

Audit FE implementation against the ratified UX/lifecycle contracts for Chat, Journey, Inheritance, Succession, Legacy, Clone and End-of-Life.

## Deterministic findings fixed

### 1. Chat capture actions were stale on `dev`

The `dev` branch Chat surface did not contain the already-ratified explicit Save to Journey / Save as Memory flow even though the UX reconciliation requires both actions and states that they must not gate the next message.

Fixed by restoring:

- explicit Save to Journey action;
- explicit Save as Memory action;
- explicit Memory capture through `runtime_record_memory`;
- Journey capture through the existing runtime capture service;
- explicit capture visibility controls for Journey/Experience capture;
- send remains available independently of capture.

### 2. Legacy preservation was exposed before terminal lifecycle

Legacy is an End-of-Life preservation mechanism. The FE previously exposed the preservation action regardless of current lifecycle state.

Fixed by gating Legacy preservation on both Account and SH being `DEACTIVATED`, while BE remains authoritative and continues to reject invalid lifecycle execution.

### 3. Succession FE did not expose the configured-successor execution path

The backend/service contract already provided `executeSuccession()`, while the FE only created rules. The ratified P5C reconciliation requires configured succession rules to be displayed and executable by the configured successor after source End-of-Life.

Fixed by adding rule listing and an Execute Succession action. Backend remains authoritative for End-of-Life, successor identity, active PRIMARY SH and selected scope validation.

## Preserved UX / architecture rules

- Inheritance uses Target Account ID; SH IDs remain internal.
- Succession uses Successor Account ID.
- Clone uses recipient email and current-account context.
- End-of-Life requires explicit Yes confirmation.
- Journey remains the unified record-detail policy surface.
- Lifecycle screens consume policy and do not silently mutate policy.
- Backend/runtime remains authoritative for ownership, authorization and mutation enforcement.
- Runtime APK / authenticated E2E remains a separate verification gate.

## Evidence boundary

This closure is source-level reconciliation. It does not claim APK or authenticated multi-account E2E PASS.
