# SECOND HEAD — P5B CLONE STATE TRANSFER CONTRACT v1.0

Project: SECOND HEAD — SYSTEM BUILD  
Document Type: P5B Clone State Transfer Contract / Execution Reconciliation  
Version: v1.0  
Status: ACTIVE — IMPLEMENTATION MAPPING  
Canonical Status: NON-CANONICAL  
Mutation: NO CANONICAL MUTATION  
Working Branch: `dev`

---

## 1. Purpose

This document converts the latest Owner decisions for Clone state transfer into an implementation-facing contract without changing the Canonical.

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
Memory Candidate → Memory
Knowledge Candidate → Knowledge
```

Candidates are therefore not preserved as Candidate state when transferred by Clone. They become the corresponding destination domain.

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

## 3. Existing Schema Mapping

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

Existing fields to preserve where represented:

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

Existing provenance must be retained and extended so the destination can still identify its source lineage.

### Context — NOT YET MATERIALIZABLE

Current implementation search found no dedicated persistent `context` table in Supabase DEV.

Canonical semantics define Context as dynamic/request-scoped state rather than a Memory-like storage domain.

Therefore no `SELECT → INSERT` transfer is permitted yet.

### Reference — NOT YET MATERIALIZABLE

Current implementation search found no dedicated persistent `reference` table in Supabase DEV.

Canonical semantics define Reference as a source used for verification/reasoning/knowledge formation/context enrichment.

Therefore no new Reference storage model may be invented inside P5B merely to satisfy the Clone transfer request.

### Traits — NOT YET MATERIALIZABLE

Current implementation search found no dedicated persistent `traits` table in Supabase DEV.

Canonical semantics place Traits within Personality development rather than defining an independent storage table in the currently verified schema.

Therefore no new Personality/Trait storage architecture may be invented inside P5B without reconciliation.

---

## 4. Current Stop Condition

The Owner has already answered the semantic question: these domains are intended to be available to the Clone.

The remaining unresolved question is technical/materialization semantics for three domains:

```text
Context
Reference
Traits
```

Before adding a new persistence model, Owner clarification is required in plain language:

> Saat Clone lahir, ketika kita bilang Context, Reference, dan Traits "ikut", apakah maksudnya ketiganya harus menjadi **data/state persistent milik Clone**, atau cukup menjadi **initial inherited runtime state** yang tersedia untuk Clone tetapi tidak menjadi storage domain baru?

This is a material implementation decision because the current DEV schema does not contain dedicated persistent representations for those three domains.

No speculative table, metadata schema, or new architecture is introduced until this question is resolved.

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

Do not copy arbitrary tables merely because they appear related to the source SH.

Use existing domain storage and lifecycle semantics wherever a representation already exists.

For domains without an existing representation, stop and obtain the minimum Owner decision needed to choose between:

1. inherited runtime state, or
2. a separately reconciled persistent representation.

---

## 7. Current Disposition

```text
Clone identity / registration        🟢 RECONCILED
Clone PRIMARY SH                     🟢 RECONCILED
Memory transfer semantics            🟢 OWNER LOCKED / SCHEMA EXISTS
Memory Candidate → Memory            🟢 OWNER LOCKED
Knowledge transfer semantics         🟢 OWNER LOCKED / SCHEMA EXISTS
Knowledge Candidate → Knowledge     🟢 OWNER LOCKED
Conversation exclusion               🟢 LOCKED
Journey exclusion                    🟢 LOCKED
Context materialization              🟡 OWNER CLARIFICATION REQUIRED
Reference materialization            🟡 OWNER CLARIFICATION REQUIRED
Traits materialization               🟡 OWNER CLARIFICATION REQUIRED
```

No P6 transition is implied by this document.
