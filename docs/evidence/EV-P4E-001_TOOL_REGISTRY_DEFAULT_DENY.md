# EV-P4E-001 — Tool Registry & DEFAULT DENY Enforcement

Project: SECOND HEAD — SYSTEM BUILD
Phase: 4 — Runtime & Orchestration
Backlog: P4E-001
Status: PASS / DEV
Owner DM Required: NO
Canonical Mutation: NONE
Supabase Mutation: NONE

## 1. Requirement

P4E-001 is the accepted execution decomposition for the Tool Execution boundary:

- available tools are explicitly registered/described;
- tool access is denied unless explicit authorization exists;
- a Tool remains a capability, not authority;
- registration does not itself grant permission to invoke a tool.

The Phase 4 execution reconciliation accepts P4E-001 without freezing a specific tool registry schema or persistence architecture.

## 2. Audit

Existing Phase 4 runtime establishes identity before downstream execution and keeps runtime access distinct from SH identity/ownership. The Phase 4 reconciliation explicitly preserves `TOOL != AUTHORITY` and `DEFAULT ACCESS = DENY`.

No higher-authority document requires a specific database table for the registry. Therefore this item is realized as an execution-local registry boundary rather than introducing schema mutation.

## 3. Minimal Realization

Added:

- `runtime/p4e/tool_registry.ts`
- `runtime/p4e/tool_registry.test.ts`

The registry provides:

- explicit tool registration;
- deterministic listing of registered capabilities;
- deny-by-default invocation;
- explicit authorization callback before execution;
- rejection of unregistered tools;
- no identity creation or ownership mutation capability.

The authorization decision is deliberately injected. P4E-001 does not invent a new authorization system and does not replace the existing Phase 2 authorization boundary.

## 4. Security / Authority Boundary

A registered tool is a capability only. Registration does not make the tool an authority and does not permit it to override system rules.

No authorization object is accepted from tool output, and no tool execution path is given a capability to create or mutate SH identity.

The absence of an authorizer is treated as denial, preserving DEFAULT DENY.

## 5. Verification

Repository-level tests cover:

1. registration does not grant invocation permission;
2. explicit authorization permits an already-registered tool;
3. explicit authorization denial blocks invocation;
4. unregistered tools remain denied.

Execution-environment note: this evidence claims implementation/test coverage at the repository level; it does not claim application/API/UI E2E verification.

## 6. Supabase Cross-Check

No P4E-001-specific migration is required. Existing identity, ownership, authorization, and audit boundaries remain the authoritative persistence/security mechanisms.

No `tool_registries` table is introduced by this item because the Phase 4 reconciliation explicitly leaves the registry schema unfrozen and the minimal execution-local realization is sufficient for the current acceptance contract.

## 7. Reconciliation Result

RESULT: PASS / DEV

No material contradiction found.
No Owner decision required.
No canonical mutation.
No ownership/privacy/security boundary change.
No fundamental architecture redesign.
No mandatory paid dependency introduced.

## 8. Assurance Limitation

Application/API/UI E2E assurance for a concrete external tool integration remains deferred. This item verifies the Tool Registry and DEFAULT DENY execution boundary only.

## 9. Next

P4E-002 — Tool Invocation & Untrusted Data Boundary

END OF EV-P4E-001
