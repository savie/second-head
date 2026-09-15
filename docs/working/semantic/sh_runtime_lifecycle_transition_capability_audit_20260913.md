# SECOND HEAD — Runtime Lifecycle Transition Capability Audit

## Status

**WORKING AUDIT RECORD — CURRENT STATE RECONCILED**

Earlier findings in this snapshot predate the implemented Knowledge lifecycle and must not be treated as current blockers.

## 1. Current Scope

The implemented lifecycle transition surface currently covered by this audit is Knowledge:

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE
ACTIVE → UPDATED + successor
ACTIVE → DEPRECATED → ARCHIVED
```

Memory activation and Experience candidate lifecycle are separate domain scope decisions and are not inferred from Knowledge.

## 2. Knowledge Capability — PASS

Current DEV provides:

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
```

Central authority:

`runtime_knowledge_transition`

## 3. Security / Ownership — VERIFIED

The Knowledge transition authority resolves authenticated identity, current account, active SH ownership, Knowledge ownership, expected lifecycle, legal transition, and required confirmation server-side.

Entry functions are `SECURITY DEFINER`, use `search_path = public`, deny anonymous EXECUTE, and grant EXECUTE to `authenticated`.

## 4. Confirmation — IMPLEMENTED

Dedicated Knowledge lifecycle confirmation exists and is bound to actor/account/SH/Knowledge/transition/operation key/decision reference/expiry.

Recovery confirmation is not reused as Knowledge lifecycle authority.

## 5. Idempotency / Atomicity — IMPLEMENTED AT DB BOUNDARY

`knowledge_lifecycle_operations` provides persistent operation identity and unique idempotency enforcement on `account_id + sh_id + operation_key`.

The central transition function locks the Knowledge target and performs Knowledge mutation, operation-ledger persistence, Journey `LIFECYCLE` projection, and Journey reference update within one PostgreSQL function transaction boundary.

## 6. Journey — IMPLEMENTED

Lifecycle Journey payload records Knowledge identity, transition, operation identity, previous/resulting lifecycle, resulting record/version, and provenance reference.

Journey is projection/history, not lifecycle authority.

## 7. Error Contract — IMPLEMENTED

Stable application SQLSTATE-style codes are implemented for the current authentication, ownership, not-found, lifecycle mismatch, invalid transition, confirmation, operation-key, and operation-conflict classes.

## 8. Domain Scope Notes

### Memory

Current Memory capture/replacement capabilities remain valid. A separate Memory candidate-activation API is not part of the current Knowledge implementation gate.

### Experience

Current Experience capture behavior remains domain-specific. A candidate lifecycle is not established by this Knowledge implementation.

### Model-derived persistence

The model-derived semantic persistence path remains a runtime/E2E verification item in the master E2E matrix. It is not a current non-E2E implementation blocker for the implemented Knowledge transition surface.

## 9. Current Gate

```text
Knowledge transition capability = IMPLEMENTED
Security / grants              = VERIFIED
Confirmation                   = IMPLEMENTED
Operation ledger               = IMPLEMENTED
Atomic DB boundary             = IMPLEMENTED
Journey projection             = IMPLEMENTED
Error mapping                  = IMPLEMENTED
NON-E2E IMPLEMENTATION GATE    = OPEN / VERIFIED
E2E BEHAVIORAL PROOF            = OPEN — E2E ONLY
```

## 10. Final Decision

No non-E2E blocker remains for the implemented Knowledge lifecycle transition surface. Remaining lifecycle verification is behavioral E2E.
