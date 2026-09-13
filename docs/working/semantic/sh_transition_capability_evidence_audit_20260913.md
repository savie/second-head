# SECOND HEAD — Transition Capability Evidence Audit

## Status

**WORKING AUDIT RECORD — PARTIAL PASS / IMPLEMENTATION GATE NOT CLOSED**

## Authority

Supporting audit record only.

Tidak mengubah Canonical, Approved Contract, schema, migration, runtime implementation, atau policy authority.

## Objective

Memverifikasi capability aktual DEV untuk memenuhi `sh_lifecycle_transition_contract_20260913.md`, khususnya:

- candidate retrieval
- callable transition capability
- EXECUTE grant
- authentication / ownership guard
- lifecycle guard
- policy guard
- Journey projection
- atomicity
- idempotency / correlation
- provenance
- positive / negative E2E evidence

## Evidence Sources

### GitHub DEV

Repository: `savie/second-head`

Branch: `dev`

Runtime entrypoint:

`functions/ai-runtime/semantic_lifecycle.ts`

Current blob SHA inspected: `78fccb57fa0f3299b3f8a03c6aa8d421ab1e9a12`

### Supabase DEV

Project: `pkhkgvsrqeupvwoqjwmd`

Actual database function inventory and definitions inspected directly from `pg_proc` / `pg_get_functiondef`.

## Findings

### 1. Candidate Retrieval

**STATUS: PARTIAL / DOMAIN-SPECIFIC**

Memory and Knowledge retrieval paths exist, but no dedicated generic lifecycle-transition resolver was found.

`runtime_record_memory` can locate an existing CANDIDATE / ACTIVE / UPDATED record by exact content and lock the selected row. `runtime_record_knowledge_candidate` can locate an existing CANDIDATE by exact content and lock the row.

These are capture/deduplication mechanisms, not an explicit transition API. They do not establish a stable transition target contract based on record identity + expected current lifecycle + operation key.

### 2. Dedicated CANDIDATE → ACTIVE Capability

**STATUS: NOT FOUND**

Actual DEV public function inventory contains no function whose name or definition establishes a dedicated candidate activation/promote transition.

Memory capture accepts `CANDIDATE` or `ACTIVE`, but this is creation/capture authority, not a safe generic activation operation.

Knowledge candidate capture explicitly writes `CANDIDATE`; no dedicated activation function was found.

Experience capture writes `ACTIVE` directly; a candidate activation boundary is therefore not currently implemented for Experience.

### 3. ACTIVE → UPDATE / SUPERSEDE

**STATUS: PARTIAL / MEMORY ONLY**

`runtime_replace_memory` implements a concrete Memory replacement flow:

1. authenticate caller
2. resolve current account
3. verify active SH ownership
4. resolve exactly one current candidate/active replacement target
5. insert successor as CANDIDATE
6. mark old record `UPDATED`
7. set `superseded_by`
8. emit Journey event

This proves a domain-specific replacement capability, but not a generic lifecycle transition contract. The successor remains CANDIDATE.

No equivalent dedicated Knowledge or Experience update/supersede transition capability was found.

### 4. Authentication / Ownership

**STATUS: PASS AT FUNCTION GUARD LEVEL**

Relevant SECURITY DEFINER write functions explicitly require `auth.uid()` and validate the requested SH belongs to `public.current_account_id()` and is not deactivated.

Observed functions include:

- `runtime_record_memory`
- `runtime_record_memory_with_journey`
- `runtime_record_knowledge_candidate`
- `runtime_record_knowledge_with_journey`
- `runtime_record_experience`
- `runtime_replace_memory`

This is positive function-level evidence only. Authenticated negative and cross-actor E2E tests remain open.

### 5. EXECUTE Grants

**STATUS: PASS FOR EXISTING PUBLIC RUNTIME FUNCTIONS; SECURITY REVIEW OPEN FOR FUTURE TRANSITION API**

Observed:

- `anon_execute = false`
- `authenticated_execute = true`

for the existing runtime capture/replacement functions above.

`runtime_record_journey_event` is SECURITY INVOKER and also has authenticated EXECUTE while anon EXECUTE is false.

No new transition function exists, so no transition-specific grant has been established or reviewed.

### 6. Lifecycle Guards

**STATUS: PARTIAL**

Memory capture validates only `CANDIDATE` / `ACTIVE` input values.

Knowledge candidate capture writes only `CANDIDATE`.

Memory replacement resolves only non-superseded `CANDIDATE` / `ACTIVE` source records and writes the old record as `UPDATED`.

No generic guard exists for:

`record_id + expected_current_lifecycle + requested_transition`

therefore transition legality is not centrally enforced.

### 7. Policy Guards

**STATUS: PARTIAL**

Existing functions validate scope and visibility; Experience additionally validates transfer policy. Existing lifecycle-transfer functions provide stronger transfer-specific policy enforcement.

However, a model-derived candidate activation function with explicit policy/confirmation authority does not exist. Therefore policy guards are not yet sufficient to authorize model-derived lifecycle activation.

### 8. Journey Projection

**STATUS: EXISTING / PARTIAL**

`runtime_record_journey_event` verifies active SH ownership and validates continuity/event type before inserting Journey events.

`runtime_replace_memory` calls Journey recording after domain mutation.

The current `semantic_lifecycle.ts` also performs explicit domain persistence followed by separate Journey RPC calls for several paths.

Therefore Journey projection exists, but an atomic domain+Journey transaction boundary is **NOT PROVEN** across the semantic runtime paths.

### 9. Idempotency / Correlation

**STATUS: OPEN / EVIDENCE GAP**

No request-level logical operation key was found in the inspected runtime function signatures.

Content matching / candidate reuse is not equivalent to retry-safe operation idempotency.

The transition contract requirement for stable operation identity therefore remains unsatisfied.

### 10. Provenance

**STATUS: PARTIAL**

Memory and Knowledge paths accept provenance; Experience accepts provenance; replacement currently writes a new Memory without a dedicated transition-operation provenance structure.

The current runtime sends `source_message` / `capture_mode` for explicit semantic paths.

What remains unproven is a complete transition provenance chain containing actor/account, SH, source signal, model/provider, decision, confirmation/authorization, transition, resulting record, and Journey event under one stable correlation identity.

### 11. Model Authority Boundary

**STATUS: PASS / RECONCILED**

The current semantic runtime inspected is explicitly based on user-message pattern detection for the existing explicit lifecycle path. The implementation does not establish model output as an independent persistence authority.

This does not prove the future model-derived pipeline is safe; that pipeline remains outside current verified capability.

### 12. Security Surface

**STATUS: REVIEW REQUIRED BEFORE NEW TRANSITION API**

Existing runtime write functions are SECURITY DEFINER in `public` but explicitly deny anonymous execution and perform authentication/ownership checks.

Because SECURITY DEFINER bypasses normal RLS execution context, any future transition function must receive an explicit security review of function body, search_path, grants, ownership checks, lifecycle/policy checks, and cross-actor behavior before exposure.

## Capability Matrix

| Capability | DEV Evidence | Status |
|---|---|---|
| Candidate creation | Memory + Knowledge | PASS |
| Candidate retrieval by content | Memory + Knowledge | PARTIAL |
| Candidate → Active generic transition | None found | OPEN |
| Memory replacement | `runtime_replace_memory` | PASS / domain-specific |
| Knowledge update/supersede | None found | OPEN |
| Experience candidate workflow | None found | OPEN |
| Auth guard | Existing runtime functions | PASS |
| Ownership guard | Existing runtime functions | PASS |
| EXECUTE grant | authenticated only | PASS |
| Policy guard | domain-specific | PARTIAL |
| Journey projection | Existing | PASS / atomicity open |
| Atomic domain + Journey | Not proven | OPEN |
| Request idempotency | None found | OPEN |
| Full provenance chain | Partial | OPEN |
| Authenticated positive E2E | Existing historical evidence for capture | PARTIAL |
| Authenticated negative/cross-actor E2E | Not completed for transition | OPEN |
| Transfer E2E | Existing capability, not transition proof | PARTIAL |

## Critical Finding

The implementation gate must remain **CLOSED**.

There is currently no safe, explicit, generic CANDIDATE → ACTIVE transition capability that can be invoked by a model-derived semantic decision while satisfying the transition contract requirements for authorization, confirmation, lifecycle legality, idempotency, provenance, and Journey consistency.

The existing system has reusable domain capabilities, but reusing capture functions as activation would conflate:

- capture authority
- transition authority
- lifecycle state mutation
- model decision
- retry semantics

That would violate the current design gate.

## Decision

**REUSE EXISTING CAPABILITY:** only for already-implemented domain behavior where semantics match (for example Memory replacement).

**EXTEND EXISTING CAPABILITY:** plausible for Memory/Knowledge, but only after transition-specific authorization, idempotency, provenance, and transaction boundaries are designed and evidenced.

**CREATE NEW CAPABILITY:** required if no existing domain function can safely express an authorized lifecycle transition without overloading capture semantics.

No implementation is authorized by this audit.

## Next Gate

**Lifecycle Transition Runtime Design Review**

Before migration/runtime coding, define the smallest domain-specific transition API surface and resolve:

1. confirmation authority
2. candidate retrieval by stable record ID
3. expected-current-lifecycle check
4. transition authorization source
5. operation/correlation key
6. provenance contract
7. domain + Journey transaction boundary
8. Knowledge activation path
9. Memory activation path
10. Experience lifecycle model
11. authenticated positive E2E plan
12. authenticated negative/cross-actor E2E plan
13. security review for SECURITY DEFINER exposure

## Final State

`POLICY CONTRACT = RECONCILED`

`RUNTIME CAPABILITY = PARTIAL`

`TRANSITION CONTRACT = DEFINED`

`TRANSITION EVIDENCE AUDIT = PARTIAL PASS`

`IMPLEMENTATION GATE = CLOSED`
