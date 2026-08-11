# SECOND HEAD — P3C Retrieval Strategy v1.0

## Status
IMPLEMENTED — BL-P3C-001 / AC-MEM-13

## Scope
This document realizes **BL-P3C-001 — Retrieval Strategy Design** only.

It does not implement relevance scoring, ranking, filtering logic, context injection, bounded retrieval execution, or retrieval testing. Those are downstream BL-P3C-002 through BL-P3C-007 items.

## Authority
Primary execution requirement:
- Phase -1: BL-P3C-001 / AC-MEM-13
- Task: E3C-T01 — Design retrieval strategy
- Required pipeline: `QUERY → RETRIEVE → FILTER → RANK → VALIDATE → CONTEXT`

The strategy preserves the existing invariants:
- MEMORY ≠ KNOWLEDGE ≠ CONTEXT
- retrieval must remain owner-scoped
- private memory must not cross SH/account boundaries
- external/untrusted content does not become trusted merely by retrieval
- retrieval must be deterministic at the system level

## Retrieval Contract

```text
QUERY
  ↓
RETRIEVE
  ↓
FILTER
  ↓
RANK
  ↓
VALIDATE
  ↓
CONTEXT
```

### 1. QUERY
Input is a retrieval request derived from the current interaction/context.

The query does not itself grant access to memory.

Authorization remains determined by the authenticated owner / SH boundary.

### 2. RETRIEVE
Retrieve candidate memory records from the persistent Memory store that are within the authorized SH scope.

At this stage the system obtains candidates; it does not yet claim that every candidate is relevant, safe to inject, or appropriate for context.

### 3. FILTER
Remove candidates that fail applicable constraints.

Filtering is a separate downstream implementation concern (BL-P3C-004).

Examples of constraints that must remain enforceable include:
- ownership / SH scope
- lifecycle eligibility
- visibility / privacy boundary
- other applicable policy constraints

### 4. RANK
Order eligible candidates by the relevance/ranking mechanism.

The scoring formula and ranking algorithm are intentionally NOT defined here because they belong to BL-P3C-002 and BL-P3C-003.

### 5. VALIDATE
Validate the selected candidates before they become context input.

Validation must preserve:
- authorization boundary
- privacy boundary
- lifecycle validity
- memory/knowledge/context separation
- deterministic behavior

Retrieval must not silently promote a memory into Knowledge merely because it was retrieved.

### 6. CONTEXT
Validated retrieval output becomes input to the request-scoped Context layer.

Context is not persistent Memory.

Context injection is implemented by BL-P3C-005, not by this strategy-design item.

## Boundary Between P3C Items

| Item | Responsibility |
|---|---|
| BL-P3C-001 | Retrieval strategy / pipeline contract |
| BL-P3C-002 | Relevance scoring |
| BL-P3C-003 | Ranking mechanism |
| BL-P3C-004 | Filtering logic |
| BL-P3C-005 | Memory → Context injection |
| BL-P3C-006 | Bounded + deterministic retrieval execution |
| BL-P3C-007 | Retrieval testing |

## Existing Database Preconditions Verified

The live `dev` Supabase database already contains the required Memory foundation:
- `public.memories`
- `memories.sh_id` → `sh_instances.sh_id`
- owner-scoped RLS policies
- lifecycle state including CANDIDATE / ACTIVE / UPDATED / SUPERSEDED / ARCHIVED / DEACTIVATED / DELETED
- indexes on `(sh_id, lifecycle, updated_at DESC)` and `(sh_id, occurrence_count DESC)`

No schema mutation is required for BL-P3C-001.

## Explicit Non-Goals

This item does NOT introduce:
- vector search
- embeddings
- semantic search infrastructure
- a new Knowledge table
- a new Context persistence layer
- a new authorization model
- new ownership semantics
- a new ranking formula
- a new filtering policy
- a new context budget

Those decisions/implementations remain within their existing downstream scope or existing authority.
