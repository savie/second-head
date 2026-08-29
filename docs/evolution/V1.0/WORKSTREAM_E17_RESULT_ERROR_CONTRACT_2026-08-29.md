# WORKSTREAM E17 — RESULT / ERROR CONTRACT
**Status:** BOUNDED DESIGN / NOT IMPLEMENTATION-AUTHORIZED

## Purpose
Define governed result semantics without forcing every Tool into one domain payload model.

## Result distinction
Execution Result ≠ Authorization Decision ≠ Confirmation ≠ Audit Event.

## Minimum outcome classes
SUCCEEDED, FAILED, REJECTED_BEFORE_EXECUTION, RESULT_UNAVAILABLE.

Tool-specific payload may remain Tool-specific inside a governed envelope.

## Error boundary
Governance failures must remain distinguishable from Tool execution failures and result interpretation failures.

**Next:** E18 — Audit & Observability.