# WORKSTREAM E16 — TOOL ADAPTER CONTRACT
**Status:** BOUNDED DESIGN / NOT IMPLEMENTATION-AUTHORIZED

## Purpose
Define the adapter as the controlled bridge from governed execution eligibility to concrete Tool implementation.

## Boundary
Governed Execution Request → Adapter → Concrete Tool → Raw Outcome → Result Contract.

## Adapter must
Preserve Tool/Action identity, approved input, target/context, correlation, and execution eligibility.

## Adapter must not
Authorize, grant private-data permission, substitute another Action, bypass confirmation, or become an authority.

Built-in and external Tools may use the same semantic adapter boundary.

**Next:** E17 — Result/Error Contract.