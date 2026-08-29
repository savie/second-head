# WORKSTREAM E14 — RISK / CONFIRMATION MATRIX
**Status:** BOUNDED DESIGN / NOT IMPLEMENTATION-AUTHORIZED

## Purpose
Make risk and confirmation Action-specific while preserving existing SH sequence.

PLAN → AUTHORIZATION → CONFIRMATION → EXECUTE → AUDIT.

## Principles
Risk belongs to Action + invocation context, not Capability alone.

At minimum distinguish:
- no explicit confirmation;
- explicit confirmation required;
- additional governed handling/escalation required.

DENY cannot be overridden by confirmation. Confirmation is not authority and not execution.

## Existing foundation
Current DEV high-risk confirmation infrastructure remains a foundation to reconcile, not an automatic generic contract.

**Next:** E15 — Execution Eligibility & Boundary.