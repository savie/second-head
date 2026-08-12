# SECOND HEAD — EV-P4B-003 Reasoning Security / Prompt-Injection Boundary

Project: SECOND HEAD — SYSTEM BUILD
Phase: 4 — Runtime & Orchestration
Backlog: P4B-003
Status: PASS / DEV
Evidence Type: Implementation + repository reconciliation + live Supabase schema verification

---

## 1. Acceptance

P4B-003 is realized as an execution boundary for reasoning/context security.

The implementation enforces the reconciled contract:

- contextual/external content is treated as data, not authority;
- detected instruction-override patterns are blocked before the model executor is reached;
- contextual entries claiming system/root authority are blocked;
- blocked attempts produce a bounded security event through the existing audit/observability boundary;
- raw contextual content is not persisted by the security boundary;
- no canonical jailbreak detector or algorithm is frozen;
- direct user instructions remain outside the external-content detector;
- SH identity is not changed by security handling.

The Phase 4 reconciliation explicitly accepts P4B-003 as an execution decomposition and does not freeze a specific detection algorithm. See `docs/phase4/SECOND_HEAD_PHASE_4_EXECUTION_RECONCILIATION_v1.0.md`.

---

## 2. Implementation

### Runtime security boundary

`runtime/p4b/reasoning_security.ts`

Provides:

- `validateReasoningSecurityBoundary()`;
- bounded instruction-override detection;
- structural rejection of untrusted system/root authority claims;
- `createReasoningSecurityBoundary()` wrapper;
- optional `ReasoningSecurityEventSink` for audit/observability.

### Runtime integration

`runtime/p4a/runtime_core_loop.ts`

When a `reasoningEngine` is present, the runtime automatically wraps it with the P4B-003 security boundary before contextual data reaches the reasoning/model executor.

The existing P4A path remains compatible when no reasoning engine is supplied.

### Tests

`runtime/p4b/reasoning_security.test.ts`

Covers:

- clean contextual data;
- instruction override detection;
- authority-claim detection;
- blocked model execution;
- direct user message remaining outside the external-content detector.

`runtime/p4b/p4b003_runtime_integration.test.ts`

Covers the runtime path and verifies that a blocked contextual injection does not reach the reasoning/model executor and that the existing `SH_ID` is preserved.

---

## 3. Supabase DEV verification

Project: `second-head`

Live DEV verification confirmed that `public.audit_events` exists with the fields required by the existing audit boundary:

- `event_id`
- `created_at`
- `account_id`
- `sh_id`
- `event_type`
- `status`
- `metadata`

The table currently contains no rows, so no persistent test residue was created.

No new table, column, RLS policy, or schema mutation was required for P4B-003.

---

## 4. Security interpretation

P4B-003 does NOT claim that the current detector can identify every possible prompt injection.

The detector is a replaceable v1 implementation mechanism. The invariant being enforced is the boundary itself:

`EXTERNAL / CONTEXTUAL DATA != SYSTEM AUTHORITY`

A future stronger detector or provider-specific security layer may replace/extend the implementation without changing SH identity or canonical architecture.

The implementation also intentionally does not inspect the direct user message as external data. User intent is a separate authority/input channel and must not be confused with third-party contextual content.

---

## 5. Assurance status

Implementation status: PASS / DEV

Repository evidence: PRESENT

Supabase schema verification: PASS

CI/application E2E execution: DEFERRED — no workflow run was available for the implementation commits during this verification.

This deferred assurance is not treated as an implementation failure because the acceptance contract is implemented at the repository/security-boundary level and the Phase 4 execution reconciliation explicitly leaves the exact detector implementation open.

---

## 6. Invariants preserved

- `RUNTIME != SH IDENTITY`
- `MODEL != SH IDENTITY`
- `MODEL != AUTHORITY`
- `TOOL != AUTHORITY`
- `CONTEXT != MEMORY`
- external/contextual content does not gain system authority
- private data remains within existing authorization boundaries
- no automatic Core mutation

---

## 7. Result

P4B-003: **PASS / DEV**

Next target: **P4C-001 — audit → reconcile → DEV**

END OF EVIDENCE
