# BL-P2-001 — Permission Matrix Design

**Status:** COMPLETE — DESIGN APPROVED FOR BL-P2-002
**Phase:** 2
**Mutation class:** Repository documentation only
**Database mutation:** NONE
**Target branch:** `dev`

## 1. Purpose

Define the Phase 2 Permission Matrix as a dimensional authorization model without implementing database tables, policies, evaluator functions, or enforcement logic.

The matrix is a design reference for later authorization/RLS work. It does not itself grant access.

## 2. Frozen Authority Model

The matrix preserves the five distinct authority categories:

1. Governance Authority
2. Technical Authority
3. Runtime Access
4. Ownership
5. Private-Data Access

The following boundaries are non-negotiable:

- Creator Authority != Private-Data Access
- SH-000 Core Authority != Private-Data Access
- Runtime Access != Ownership
- System Governance != Omniscient Data Access
- Learning != Automatic Core Modification

Security baseline:

- DEFAULT DENY
- Access requires identity, authentication, authorization, ownership where applicable, and scope.
- Cross-SH private-data access is denied by default.
- Shared Core does not imply shared private memory.
- READ, COPY/EXPORT, and WRITE/EDIT remain distinct.

## 3. Matrix Dimensions

```text
ACTOR
  x
AUTHORITY DOMAIN
  x
ACTION
  x
TARGET DOMAIN
  x
TARGET SH
  x
SCOPE / CONDITION
  -> DECISION
```

### Actor

- `CREATOR`
- `SH-000`
- `ACCOUNT_OWNER`
- `ORDINARY_SH`
- `SYSTEM_RUNTIME`

`SH-000` is a conceptual actor only at this stage. Its technical identity remains unresolved and is intentionally not encoded here.

### Authority Domain

- `GOVERNANCE`
- `TECHNICAL`
- `RUNTIME`
- `OWNERSHIP`
- `PRIVATE_DATA`

### Action

- `READ`
- `WRITE`
- `COPY_EXPORT`
- `GOVERN`
- `EVOLVE`
- `EXECUTE`

### Target Domain

- `SYSTEM_CORE`
- `SYSTEM_GOVERNANCE`
- `GENERAL_KNOWLEDGE`
- `SYSTEM_KNOWLEDGE`
- `PRIVATE_MEMORY`
- `PRIVATE_CONVERSATION`
- `PRIVATE_CONTEXT`
- `SH_IDENTITY`
- `ACCOUNT`

### Target SH

- `SELF`
- `OTHER`
- `SYSTEM`
- `NOT_APPLICABLE`

### Scope / Condition

- `FULL`
- `PARTIAL_SELECTED`
- `SCOPED_BY_AUTHORIZATION`
- `TEMPORARY`
- `REVOCABLE`
- `GOVERNANCE_PROCESS_REQUIRED`
- `OWNERSHIP_VALIDATED`
- `AUTHENTICATED_PRINCIPAL`

Conditions are not authority grants by themselves; they are predicates that must be satisfied before an ALLOW can apply.

### Decision

- `ALLOW`
- `DENY`
- `ESCALATE`

`DENY` is the fallback for any request not covered by a valid allow rule. `ESCALATE` is reserved for actions requiring an additional governance/review decision rather than being a substitute for authorization.

## 4. Core Matrix Rules

| Actor | Authority | Action | Target | Target SH | Condition | Decision |
|---|---|---|---|---|---|---|
| CREATOR | GOVERNANCE | GOVERN | SYSTEM_CORE | SYSTEM | GOVERNANCE_PROCESS_REQUIRED | ALLOW |
| CREATOR | GOVERNANCE | EVOLVE | SYSTEM_CORE | SYSTEM | GOVERNANCE_PROCESS_REQUIRED | ALLOW |
| CREATOR | PRIVATE_DATA | READ | PRIVATE_MEMORY | OTHER | none | DENY |
| CREATOR | PRIVATE_DATA | READ | PRIVATE_CONVERSATION | OTHER | none | DENY |
| CREATOR | PRIVATE_DATA | READ | PRIVATE_CONTEXT | OTHER | none | DENY |
| SH-000 | GOVERNANCE | GOVERN | SYSTEM_CORE | SYSTEM | GOVERNANCE_PROCESS_REQUIRED + SH-000 AUTHORITY | ALLOW |
| SH-000 | GOVERNANCE | EVOLVE | SYSTEM_CORE | SYSTEM | GOVERNANCE_PROCESS_REQUIRED + SH-000 AUTHORITY | ALLOW |
| SH-000 | PRIVATE_DATA | READ | PRIVATE_MEMORY | OTHER | none | DENY |
| SH-000 | PRIVATE_DATA | READ | PRIVATE_CONVERSATION | OTHER | none | DENY |
| SH-000 | PRIVATE_DATA | READ | PRIVATE_CONTEXT | OTHER | none | DENY |
| SH-000 | PRIVATE_DATA | READ | PRIVATE_* | OTHER | explicit scoped authorization | ALLOW |
| ACCOUNT_OWNER | OWNERSHIP | READ | PRIVATE_MEMORY | SELF | OWNERSHIP_VALIDATED | ALLOW |
| ACCOUNT_OWNER | OWNERSHIP | WRITE | PRIVATE_MEMORY | SELF | OWNERSHIP_VALIDATED | ALLOW |
| ACCOUNT_OWNER | OWNERSHIP | READ | PRIVATE_CONVERSATION | SELF | OWNERSHIP_VALIDATED | ALLOW |
| ACCOUNT_OWNER | OWNERSHIP | WRITE | PRIVATE_CONVERSATION | SELF | OWNERSHIP_VALIDATED | ALLOW |
| ACCOUNT_OWNER | OWNERSHIP | READ | PRIVATE_CONTEXT | SELF | OWNERSHIP_VALIDATED | ALLOW |
| ACCOUNT_OWNER | OWNERSHIP | WRITE | PRIVATE_CONTEXT | SELF | OWNERSHIP_VALIDATED | ALLOW |
| ACCOUNT_OWNER | PRIVATE_DATA | READ | PRIVATE_* | OTHER | none | DENY |
| ACCOUNT_OWNER | PRIVATE_DATA | READ | PRIVATE_* | OTHER | explicit scoped authorization | ALLOW |
| ORDINARY_SH | GOVERNANCE | GOVERN | SYSTEM_CORE | SYSTEM | none | DENY |
| SYSTEM_RUNTIME | RUNTIME | EXECUTE | authorized target | SELF/OTHER as authorized | AUTHENTICATED_PRINCIPAL + authorization + scope | ALLOW |
| SYSTEM_RUNTIME | RUNTIME | EXECUTE | private data | OTHER | explicit authorization + scope | ALLOW |
| SYSTEM_RUNTIME | RUNTIME | EXECUTE | private data | OTHER | no authorization | DENY |
| ANY | GOVERNANCE | GOVERN/EVOLVE | SYSTEM_CORE/SYSTEM_GOVERNANCE | SYSTEM | governance review required but authorization unresolved | ESCALATE |
| ANY | PRIVATE_DATA | COPY_EXPORT | PRIVATE_* | OTHER | no explicit scoped authorization | DENY |
| ANY | PRIVATE_DATA | COPY_EXPORT | PRIVATE_* | OTHER | explicit scoped authorization | ALLOW |

`PRIVATE_*` means the applicable private-data category only; it does not collapse Private Memory, Private Conversation, and Private Context into one data class for implementation.

## 5. Important Boundary Clarifications

### Creator

Creator governance authority permits Core/governance operations according to the required governance process. It does not create omniscient access to another SH's private memory, conversation, or context.

### SH-000

SH-000 may receive Core Governance authority within its defined boundary. That authority does not create universal access to other SH private data. SH-000's own private domain is a separate ownership/privacy domain.

### Runtime

Runtime Access is an execution capability, not an ownership grant. The runtime may execute an operation only when the authenticated principal, authorization, ownership condition where applicable, and scope requirements are satisfied. Runtime must not infer ownership merely because it can execute an operation.

### Explicit sharing/authorization

Cross-SH private-data access remains DENY by default. A valid explicit, scoped, auditable authorization may produce an ALLOW limited to the granted scope. COPY/EXPORT does not imply ownership, WRITE, or identity transfer.

### Core modification

Core modification is not ordinary personalization. Governance/review requirements remain applicable according to the canonical authority. `ESCALATE` represents the need for that additional decision; it does not itself authorize the operation.

## 6. Permission Level Model

```text
READ-ONLY -> COPY / EXPORT -> WRITE / EDIT
```

The levels are independent permissions:

- READ does not imply WRITE.
- COPY/EXPORT does not imply OWNERSHIP.
- ACCESS does not imply OWNERSHIP.
- WRITE does not imply identity transfer.

## 7. Default-Deny Rule

For any tuple not matched by a valid authorization rule:

```text
DECISION = DENY
```

No actor receives authority solely because of a role label. The effective decision must still satisfy identity, authentication, authorization, ownership where applicable, and scope.

## 8. Open Engineering Decisions Deferred

These are intentionally not frozen by BL-P2-001:

- Physical representation of the matrix (database, repository artifact, configuration, or another form).
- Evaluator actor-identity realization.
- SH-000 technical identity/reserved ID.
- Audit mechanism/schema.
- `service_role` handling and trusted system path details.
- RLS integration mechanics.
- Concrete ESCALATE/review workflow.

## 9. Actual-State Audit Note

Pre-execution audit confirmed the current Supabase `second-head` project contains the Phase 1 foundation tables:

- `accounts`
- `sh_instances`
- `sh_ownership`
- `account_auth_links`

All four public foundation tables currently have RLS enabled. The current Supabase migration history contains the Phase 1 identity/RLS migrations and no Phase 2 Permission Matrix implementation.

The GitHub repository is `savie/second-head` with `dev` as the default branch. Existing final Phase 1/foundation documentation is present. No existing BL-P2-001 Permission Matrix implementation was found during the repository audit.

## 10. Execution Boundary

BL-P2-001 is a design artifact. Therefore:

- No Supabase mutation is required.
- No migration is created.
- No table/policy/function is created.
- The repository artifact itself is the implementation of this design deliverable.
- BL-P2-002 remains the next execution item.

## 11. Acceptance

BL-P2-001 is considered complete when this artifact is present and the dimensional model, frozen boundaries, default-deny behavior, permission levels, and deferred engineering decisions are traceable without resolving the SH-000 technical identity.
