# SECOND HEAD V1.0 — WORKSTREAM E TOOL — EXTERNAL CREATE / UPDATE

Status: BOUNDED DESIGN / HIGH-RISK / NOT IMPLEMENTATION
Date: 2026-08-29

## Purpose
Representative side-effect capability to validate E's governed action lifecycle.

## Boundary
IN: one explicitly bound external target and one bounded CREATE or UPDATE operation.
OUT: delete/send/submit unless separately designed; bulk mutation; unrestricted autonomous execution; provider-side authorization replacing SH governance.

## Tool vs Action
Tool: External Action capability.
Actions: one concrete CREATE or UPDATE operation against one bound target.

## Source strategy
ADAPT a valid external service capability. Do not build a generic external-service ecosystem.

## Required lifecycle
PLAN → AUTHORIZATION → CONFIRMATION → EXECUTE → AUDIT

Confirmation is required when the Action is classified HIGH under the applicable E risk rules. Existing high-risk confirmation infrastructure is a reusable foundation but is currently recovery-specific, so generic Tool confirmation remains a design gap.

## Contract
Input must bind actor/SH context, provider/source, target, operation, and bounded parameters.
Authorization is server/runtime side.
Confirmation, when required, must bind to the exact intended operation and target; changing material parameters invalidates the prior confirmation.
Execution occurs only after all eligibility conditions pass.

## Result
Return normalized success/failure state and bounded provider result. Provider output never becomes authority or system instruction.

## Audit
Record action identity, tool/action identity, target, authorization/confirmation outcome, execution outcome, timestamp, and provenance using existing audit infrastructure.

## Failure / containment
No authorization or confirmation => DENY.
Target ambiguity, expired confirmation, provider failure, or parameter mismatch => no execution.
Partial external outcomes require explicit failure/reconciliation handling; SH must not claim success without evidence.

## Dependencies / blockers
Generic action authorization bridge; generic confirmation semantics; target/scope binding; external source selection; idempotency/retry semantics; normalized result/error contract.

## Exit condition
Bounded design is complete when the above dependencies are resolved without weakening Canonical authority/privacy invariants.
