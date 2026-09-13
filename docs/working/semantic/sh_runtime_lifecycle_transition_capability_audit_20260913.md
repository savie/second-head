# SECOND HEAD — Runtime Lifecycle Transition Capability Audit

## Status
WORKING AUDIT RECORD — PARTIAL PASS / IMPLEMENTATION GATE NOT CLOSED

## Authority
Supporting working document only.

This audit does not modify Canonical, Approved Contract, database schema, runtime behavior, or lifecycle semantics.

## Scope
Audit the actual DEV Runtime + Supabase DEV capability boundary for:

- Memory
- Knowledge
- Experience
- CANDIDATE → ACTIVE
- ACTIVE → UPDATE
- ACTIVE → SUPERSEDE
- Journey projection
- identity/ownership/policy guards
- transaction/idempotency/failure behavior

## Evidence Baseline

### GitHub
Repository: `savie/second-head`
Branch: `dev`

Observed runtime entrypoint:
- `functions/ai-runtime/semantic_lifecycle.ts`

The explicit semantic runtime currently calls:
- `runtime_replace_memory`
- `runtime_record_knowledge_with_journey`
- `runtime_record_experience`
- `runtime_record_memory_with_journey`
- `runtime_record_journey_event`

### Supabase DEV
Project: `pkhkgvsrqeupvwoqjwmd`

Current public function inventory includes:
- `runtime_record_memory`
- `runtime_record_memory_with_journey`
- `runtime_record_knowledge_candidate`
- `runtime_record_knowledge_with_journey`
- `runtime_record_experience`
- `runtime_replace_memory`
- `runtime_record_journey_event`
- `runtime_transfer_selected_journey_events`

## Findings

### 1. Memory capture
STATUS: EXISTING / VERIFIED AT CAPABILITY LEVEL

`runtime_record_memory` and `runtime_record_memory_with_journey` accept only `CANDIDATE` or `ACTIVE` lifecycle values. They authenticate the caller and verify that the requested SH belongs to the current active account. The journey wrapper persists a MEMORY event after domain persistence.

Important limitation: there is no dedicated model/user-authorized lifecycle transition function found that promotes an existing Memory from CANDIDATE to ACTIVE. Therefore capture capability exists, but activation capability is not established.

### 2. Knowledge capture
STATUS: EXISTING / VERIFIED AT CAPABILITY LEVEL

`runtime_record_knowledge_candidate` explicitly creates or reuses a CANDIDATE Knowledge record. `runtime_record_knowledge_with_journey` likewise persists/reuses CANDIDATE Knowledge and emits a LEARNING Journey event.

No dedicated current DEV function was found for CANDIDATE → ACTIVE, ACTIVE → UPDATE, or ACTIVE → SUPERSEDE for Knowledge.

Therefore Knowledge candidate persistence exists; lifecycle transition authority remains OPEN.

### 3. Experience capture
STATUS: EXISTING / VERIFIED AT CAPABILITY LEVEL

`runtime_record_experience` requires authentication, verifies active SH ownership against the current account, validates scope/visibility/transfer policy, and always inserts lifecycle `ACTIVE`.

This means Experience currently has no candidate capture boundary in this runtime function. It is not equivalent to the Memory/Knowledge candidate model.

No dedicated current DEV transition function was found for Experience UPDATE/SUPERSEDE.

### 4. Memory replacement / supersession
STATUS: EXISTING / PARTIALLY VERIFIED

`runtime_replace_memory` performs a concrete replacement operation:

1. authenticates and checks SH ownership;
2. locates exactly one non-superseded CANDIDATE/ACTIVE target;
3. inserts a new Memory as CANDIDATE;
4. marks the old Memory `UPDATED` and sets `superseded_by` to the new record;
5. emits a MEMORY Journey event containing the replacement relationship.

This proves a domain-specific ACTIVE/CANDIDATE → UPDATED + superseded_by operation exists for Memory.

It does NOT prove a generic `ACTIVE → SUPERSEDE` transition API, nor does it prove that the new candidate is later activated.

### 5. Journey projection boundary
STATUS: EXISTING / VERIFIED AT CAPABILITY LEVEL

`runtime_record_journey_event` verifies that the SH belongs to the current active account and normalizes/validates event types and continuity status before inserting the event.

The semantic lifecycle runtime separately calls Journey in some paths. Knowledge uses a DB function that itself emits Journey, while Memory and Experience paths also have Journey coupling. This is not yet sufficient evidence that every domain persistence + Journey projection is atomic as one logical transaction across all runtime paths.

### 6. Identity and authorization
STATUS: PASS AT FUNCTION GUARD LEVEL / E2E NEGATIVE TEST OPEN

Observed DB functions consistently require `auth.uid()` and verify SH ownership through `current_account_id()` for domain writes. Transfer functions additionally require lifecycle-specific authorization/agreement/rule state.

However, a complete authenticated negative security harness covering cross-actor SH IDs and all transition functions has not been executed in this audit.

### 7. Security-definer exposure
STATUS: RISK REVIEW REQUIRED / NOT AN AUTOMATIC FAILURE

Several runtime write functions are `SECURITY DEFINER` in `public`. Their bodies contain explicit authentication and ownership checks, which is positive evidence. Supabase security guidance requires special care because SECURITY DEFINER bypasses RLS.

The audit does not change grants or function placement. A separate security review should verify EXECUTE grants and exposure for these functions before model-derived persistence is enabled.

### 8. Idempotency
STATUS: OPEN

Memory and Knowledge capture perform content-based lookup/reuse, which provides limited deduplication behavior. This is not equivalent to request-level idempotency keyed by semantic decision/request/correlation ID.

No decision_id/correlation_id/idempotency key was found in the audited function signatures.

### 9. Model-derived persistence
STATUS: OPEN / NOT VERIFIED

The runtime semantic lifecycle file currently implements explicit-user-request persistence. The previously audited model path still ends at semantic decision evaluation without proof of durable model-derived persistence.

Therefore the full path:

`MODEL OUTPUT → semantic signal → decision → persistence → Journey`

remains unverified.

## Capability Matrix

| Domain | Capture | Candidate | Candidate→Active | Active→Update | Active→Supersede | Journey | Idempotency | E2E |
|---|---|---|---|---|---|---|---|---|
| Memory | PASS | PASS | OPEN | DOMAIN-SPECIFIC | DOMAIN-SPECIFIC | PASS* | OPEN | PARTIAL |
| Knowledge | PASS | PASS | OPEN | OPEN | OPEN | PASS* | OPEN | PARTIAL |
| Experience | PASS | NOT ESTABLISHED | NOT APPLICABLE/OPEN | OPEN | OPEN | PASS* | OPEN | PARTIAL |

`*` Capability-level evidence exists; complete transaction/E2E proof is still open.

## Gate Decision

RESULT: **PARTIAL PASS — IMPLEMENTATION GATE REMAINS CLOSED**

The current DEV system has real domain capture and some domain-specific lifecycle behavior, but does not yet expose a reconciled, verified lifecycle-transition capability suitable for model-derived semantic persistence.

## Blockers Before Implementation

1. Define and verify confirmation/activation authority for model-derived signals.
2. Provide or explicitly reject dedicated CANDIDATE → ACTIVE transition capability per domain.
3. Define Knowledge and Experience UPDATE/SUPERSEDE semantics.
4. Define request/decision/correlation idempotency semantics.
5. Verify atomicity of domain persistence + Journey projection.
6. Execute authenticated positive and negative E2E tests, including cross-actor isolation.
7. Review SECURITY DEFINER function grants/exposure before enabling additional model-driven write paths.

## Next Safe Gate

**Lifecycle Transition Contract & Runtime Capability Design**

Before coding, reconcile the intended transition semantics with the existing domain-specific behavior. The next implementation gate should specify exact transition functions, authorization/confirmation source, idempotency key, provenance, transaction boundary, failure semantics, and verification cases for Memory, Knowledge, and Experience.

## Change Record

No runtime code, migration, schema, Canonical document, or Approved Contract was changed by this audit.
