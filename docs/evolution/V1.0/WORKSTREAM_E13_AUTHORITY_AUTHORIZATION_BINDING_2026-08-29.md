# WORKSTREAM E13 — AUTHORITY / AUTHORIZATION BINDING
**Status:** BOUNDED DESIGN / NOT IMPLEMENTATION-AUTHORIZED

## Purpose
Define how Action requests connect to existing SH authority, ownership, access, and permission foundations.

## Principles
Actor, authority, ownership, target, and access relation remain distinct.

Authorization must be Runtime-owned and must evaluate the concrete Invocation, not merely Tool existence.

Existing permission/access foundations are reused; E13 must not create a competing authority source.

## Decisions
- App cannot authorize.
- Model cannot authorize.
- Tool/plugin cannot authorize itself.
- Confirmation cannot rescue DENY.
- Valid SH identifier is not by itself authorization.

## Open
Exact evaluator contract and field mapping require implementation-stage reconciliation.

**Next:** E14 — Risk & Confirmation Matrix.