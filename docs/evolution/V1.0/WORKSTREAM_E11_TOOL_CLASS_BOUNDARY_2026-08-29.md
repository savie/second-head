# WORKSTREAM E11 — TOOL CLASS BOUNDARY
**Status:** BOUNDED DESIGN / NOT IMPLEMENTATION-AUTHORIZED

## Purpose
Define how built-in, extension, and plugin/provider-backed Tools differ without creating separate governance systems.

## Classes
1. Built-in/Internal — SH-controlled implementation.
2. Extension — separately bounded implementation attached through an SH-controlled adapter.
3. Plugin/Provider-backed — external implementation behind an explicit adapter boundary.

## Common requirements
Every class must expose bounded Actions and pass SH Runtime authorization, risk/confirmation, execution eligibility, result, and audit boundaries.

## Provider rule
External implementation may provide execution capability; it does not provide SH authority, permission, ownership, or confirmation.

## Design decision
Classifying a Tool does not determine its authorization. Authorization is Action + invocation-context dependent.

**Next:** E12 — Action Contract.