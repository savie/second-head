# WORKSTREAM E10 — TOOL GOVERNANCE & EXTENSIBILITY BOUNDARY
**Status:** BOUNDED DESIGN / NOT IMPLEMENTATION-AUTHORIZED

## Purpose
Define the common governance boundary for all Tool classes without making Global Search the architecture center.

## Scope
Built-in/internal Tools, future extensions, and plugin/provider-backed Tools may exist, but all enter through the same SH Runtime governance path.

## Hard boundaries
- Tool ≠ authority.
- Provider/plugin ≠ authority.
- Capability ≠ permission.
- Tool availability ≠ authorization.
- App/Model ≠ authorization authority.
- No unrestricted autonomous execution.
- Private-data access is never implied by capability or Tool presence.

## Common lifecycle
Capability → Tool → Action → Invocation → Authorization → Risk/Confirmation → Execution Eligibility → Adapter → Execution → Result → Audit.

## Design decision
Extensibility is allowed; governance is not extensible away from SH Runtime.

## Out of scope
Marketplace, plugin ecosystem, dynamic discovery, implementation, migration, Canonical changes.

**Exit:** common governance boundary accepted; exact contracts remain downstream.
**Next:** E11 — Tool Class Boundary.