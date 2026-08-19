# SECOND HEAD — P5B CLONE STATE TRANSFER CONTRACT v1.0

Project: SECOND HEAD — SYSTEM BUILD  
Document Type: P5B Clone State Transfer Contract / Execution Reconciliation  
Version: v1.0  
Status: ACTIVE — OWNER-RESOLVED / IMPLEMENTATION  
Canonical Status: NON-CANONICAL  
Mutation: NO CANONICAL MUTATION  
Working Branch: `dev`

---

## 1. Purpose

This document converts the Owner-resolved Clone state-transfer semantics into an implementation-facing contract without changing the Canonical.

Authority order remains:

```text
Canonical
 ↓
Build Scope
 ↓
Implementation Guide
 ↓
Implementation Contract
 ↓
Execution Strategy
 ↓
Phase -1
 ↓
P1 Identity semantics
 ↓
P5B Clone semantics
 ↓
Actual schema / RPC
 ↓
Owner decisions where the authority chain does not answer the practical question
```

---

## 2. Owner-Locked Clone Transfer Semantics

When an approved Clone recipient registers and the Clone SH is materialized:

### Transfer into Clone

```text
Knowledge
Memory
Context
Reference
Traits
Knowledge Candidate
Memory Candidate
```

Owner clarification:

```text
Memory Candidate   → Memory
Knowledge Candidate → Knowledge
```

Candidates are therefore not preserved as Candidate state when transferred by Clone. They become the corresponding destination domain.

### Context / Reference / Traits clarification

Owner selected the **initial inherited runtime-state model**.

Meaning:

```text
Source
  ↓
Clone creation
  ↓
initial inherited runtime state / starting configuration
  ↓
Clone lives independently
  ↓
existing Context / Reference / Personality mechanisms govern it
```

This does **not** authorize creation of new generic `context`, `reference`, or `traits` persistence tables merely to make Clone transfer possible.

The implementation must use an existing representation where one exists. Where a domain is runtime-composed rather than persisted, Clone receives the corresponding initial semantics through the existing runtime boundary rather than by copying Source runtime/session state.

### Never transfer

```text
Conversation / chat history
Source Journey
Source identity
Source ownership
Source credentials
Source live session
```

The Clone starts with its own Journey and new conversations.

---

## 3. Existing Schema / Runtime Mapping

### Memory — IMPLEMENTABLE

Existing `public.memories` is SH-scoped through `sh_id` and supports lifecycle values including `CANDIDATE` and `ACTIVE`.

For Clone transfer:

```text
source SH memory
        ↓
new memory row under Clone SH
        ↓
CANDIDATE → ACTIVE
ACTIVE    → ACTIVE
```

Existing fields are preserved where represented:

- memory_type
- content
- source
- confidence
- scope
- visibility
- occurrence_count
- lifecycle semantics

Existing ownership/RLS remains SH/account based.

### Knowledge — IMPLEMENTABLE

Existing `public.knowledge` is an independent domain from Memory and has its own lifecycle, scope, visibility, provenance, version and SH linkage.

For Clone transfer:

```text
source Knowledge Candidate → destination Knowledge
source Knowledge           → destination Knowledge
```

Destination lifecycle is materialized as active Knowledge rather than Candidate.

Existing provenance is retained and extended so the destination can identify its Source lineage.

### Context — RUNTIME INITIAL STATE

Current DEV implementation uses runtime context assembly rather than a dedicated persistent `context` table.

Therefore:

```text
Clone SH
 ↓
existing context assembly
 ↓
Clone-specific Memory / Knowledge / Journey
```

No new Context table is introduced by P5B.

Source Journey remains excluded; the Clone has its own Journey.

### Reference — INITIAL INHERITED RUNTIME SEMANTICS

Owner decision is that Reference is part of the Clone's initial inherited runtime state, not a reason to invent a new generic persistence domain.

If an existing Reference representation is consumed by the runtime, the Clone must receive the corresponding initial semantics through that existing mechanism. Source credentials, private authorization, and live Source state are never transferred.

### Traits — INITIAL INHERITED PERSONALITY SEMANTICS

Owner decision is that Traits are part of the Clone's initial inherited runtime/personality starting state, not a reason to invent a new generic `traits` table inside P5B.

After materialization, the Clone evolves independently through the existing Personality/Traits mechanisms.

---

## 4. Materialization Contract

The intended recipient does not need an Account or SH when the Source creates the invitation.

```text
A / Source Account
 ↓
create Clone invitation for B email
 ↓
Source approves
 ↓
B does not yet have Account / SH
 ↓
B registers with intended email
 ↓
auth bootstrap detects approved invitation
 ↓
transactional Clone materialization
 ↓
B Account + one PRIMARY Clone SH
```

The recipient does not manually press a `Become Clone` action after registration. Registration/session bootstrap is the materialization trigger.

The materialization transaction creates the Clone SH, ownership, clone provenance, Memory, Knowledge and agreement linkage atomically. Context / Reference / Traits use the initial inherited runtime-state semantics above.

---

## 5. Explicit Non-Transfer Boundaries

The following are locked and do not require another Owner decision:

```text
Conversation/chat      = NOT TRANSFERRED
Source Journey         = NOT TRANSFERRED
Source identity        = NOT TRANSFERRED
Source ownership       = NOT TRANSFERRED
Source credentials     = NOT TRANSFERRED
Live source state      = NOT TRANSFERRED
```

Clone has its own:

```text
Account
PRIMARY SH
SH_ID
Journey
Conversation
Ownership
Runtime boundary
```

---

## 6. Implementation Rule

Do not implement Clone as a full SH copy.

Do not copy arbitrary tables merely because they appear related to the Source SH.

Use existing domain storage and lifecycle semantics wherever a representation already exists.

For Context / Reference / Traits, do not invent generic persistence solely for Clone. Realize the Owner-approved initial inherited runtime semantics through existing runtime/personality mechanisms and keep the Clone independent after materialization.

---

## 7. Current Disposition

```text
Clone identity / registration        🟢 RECONCILED
Clone PRIMARY SH                     🟢 RECONCILED
Memory transfer semantics            🟢 OWNER LOCKED / SCHEMA EXISTS
Memory Candidate → Memory            🟢 OWNER LOCKED
Knowledge transfer semantics         🟢 OWNER LOCKED / SCHEMA EXISTS
Knowledge Candidate → Knowledge      🟢 OWNER LOCKED
Context initial runtime state        🟢 OWNER RESOLVED / NO NEW TABLE
Reference initial runtime state      🟢 OWNER RESOLVED / NO NEW TABLE
Traits initial runtime state         🟢 OWNER RESOLVED / NO NEW TABLE
Conversation exclusion               🟢 LOCKED
Journey exclusion                    🟢 LOCKED
Recipient registration trigger       🟢 IMPLEMENTED
Transactional materialization        🟢 IMPLEMENTED
Frontend manual materialization      🔴 MUST NOT BE USED

Next gate: full backend ↔ frontend functional audit, then APK build.
```

No P6 transition is implied by this document.
