# SECOND HEAD — Audit Operation Ledger & Transaction Boundary Lifecycle Knowledge — 2026-09-13

## Status

**WORKING DESIGN / TRANSACTION CONTRACT — PASS PARSIAL — GATE MIGRATION TERTUTUP**

Dokumen ini mencatat hasil audit terhadap state aktual Supabase DEV dan menetapkan boundary implementasi yang diperlukan. Dokumen ini bukan migration dan tidak mengubah Canonical.

## 1. Authority & Baseline

- Supabase DEV adalah authority untuk database/runtime state.
- GitHub `dev` adalah repository/history setelah state database diverifikasi.
- Existing lifecycle Knowledge:

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE → UPDATED / DEPRECATED → ARCHIVED
```

- `VALIDATION` adalah process boundary, bukan lifecycle enum.
- `SUPERSEDED` bukan enum baru; supersession direpresentasikan oleh `UPDATED + superseded_by`.
- Existing lifecycle transition target functions tetap working-contract targets dan belum terbukti sebagai runtime objects.

## 2. Audit Finding

### 2.1 `knowledge`

EXISTING:

- lifecycle constraint
- version
- superseded_by
- provenance
- scope
- visibility
- transfer_policy
- SH ownership relationship
- RLS

MISSING untuk authoritative transition execution:

- operation identity
- transition identity
- idempotency record
- lifecycle operation result history

### 2.2 `audit_events`

EXISTING sebagai generic runtime audit trail.

Current event types:

```text
RUNTIME_REQUEST
RUNTIME_RESPONSE
RUNTIME_MEMORY_DECISION
TOOL_INVOCATION
RUNTIME_ACTION
```

Current status values:

```text
SUCCESS
REJECTED
FAILED
```

Actual DEV evidence menunjukkan metadata existing belum menjadi semantic lifecycle ledger: operation key, operation id, knowledge id, dan transition tidak menjadi structured ledger fields.

Decision:

**`audit_events` tidak digunakan sebagai authoritative Knowledge lifecycle operation ledger.**

Alasan: contract existing adalah runtime audit dan event/status taxonomy-nya berbeda dari domain lifecycle operation identity.

### 2.3 `journey_events`

EXISTING sebagai continuity/history projection dengan RLS, SH/account ownership checks, continuity semantics, visibility, transfer policy, dan provenance.

`runtime_record_journey_event()` dapat merekam generic lifecycle/learning events, tetapi belum memaksa payload Knowledge lifecycle yang mencakup operation identity, old/new lifecycle, dan resulting record.

Decision:

**Journey tetap projection/history, bukan operation authority.**

### 2.4 Existing acquisition path

`runtime_record_knowledge_with_journey()` sudah menunjukkan transaction-scoped Knowledge acquisition + Journey projection.

Namun path tersebut hanya membuktikan candidate acquisition. Ia tidak membuktikan authoritative lifecycle promotion, operation idempotency, atau complete semantic lifecycle.

## 3. Authoritative Boundary

Target architecture:

```text
Authenticated Actor
        ↓
Resolve Account / SH
        ↓
Lock Knowledge target
        ↓
Verify ownership + active SH
        ↓
Verify expected lifecycle
        ↓
Verify legal transition
        ↓
Verify domain-specific authority
        ↓
Resolve operation identity
        ↓
Return ALREADY_APPLIED when exact same operation already succeeded
        ↓
Atomic Knowledge mutation
        ↓
Write lifecycle operation ledger
        ↓
Write lifecycle Journey projection
        ↓
Return observable result
```

Semua mutation lifecycle normal harus melalui transition RPC khusus. Caller tidak boleh melakukan direct lifecycle update sebagai application contract.

## 4. Proposed Operation Ledger

Target table name:

```text
knowledge_lifecycle_operations
```

Proposed minimum fields:

```text
operation_id uuid primary key
account_id uuid not null
sh_id uuid not null
knowledge_id uuid not null
transition text not null
expected_lifecycle text not null
previous_lifecycle text not null
resulting_lifecycle text not null
operation_key text not null
decision_ref text nullable
validation_ref text nullable
index_ref text nullable
update_ref text nullable
confirmation_ref text nullable
provenance jsonb not null
result_status text not null
resulting_knowledge_id uuid nullable
resulting_version integer nullable
journey_event_id uuid nullable
created_at timestamptz not null
authorized_at timestamptz nullable
```

Implementation may normalize optional transition-specific references into a structured `references` JSONB field only if that produces a stronger constraint and does not weaken queryability. The final schema must preserve exact transition identity and idempotency semantics.

### Required uniqueness

The authoritative idempotency identity is scoped to:

```text
account + sh + knowledge + transition + operation_key
```

It must be enforced by a database unique constraint/index, not only by application lookup.

An identical operation identity must not be silently reused for another target, SH, account, or transition.

## 5. Transition Contract

Required target functions remain:

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
```

The existing working implementation contract remains authoritative for their signatures unless concrete DB/runtime evidence establishes incompatibility.

Every function must execute the same security and transaction boundary while applying transition-specific authority.

## 6. Concurrency & Atomicity

The target Knowledge row must be locked before lifecycle validation and mutation:

```text
SELECT ... FOR UPDATE
```

The operation identity must be resolved inside the same transaction.

The following must be atomic for a successful transition:

```text
Knowledge mutation
+ operation ledger record
+ required Journey projection
```

If any required write fails, the transition must fail and the Knowledge mutation must roll back.

No false `SUCCESS` may be returned after partial persistence.

A retry after a committed successful operation must return `ALREADY_APPLIED` when the exact operation identity matches.

A reused operation key with a different semantic identity must be rejected as a conflict.

## 7. Journey Contract

Lifecycle Journey is a projection, not the authority.

Minimum payload:

```json
{
  "domain": "KNOWLEDGE",
  "knowledge_id": "<source-record-id>",
  "transition": "<transition>",
  "operation_id": "<operation-id>",
  "operation_key": "<operation-key>",
  "previous_lifecycle": "<old>",
  "resulting_lifecycle": "<new>",
  "resulting_knowledge_id": "<result-id>",
  "resulting_version": "<version>",
  "provenance_ref": "<reference>"
}
```

For update/supersession, the payload must additionally identify the successor and `superseded_by` relationship.

Journey must never be capable of independently promoting Knowledge lifecycle.

## 8. Authority Requirements by Transition

### CANDIDATE → ACCEPTED

Requires explicit validation/acceptance authority plus `decision_ref` and `validation_ref`.

Model confidence, retrieval, Journey replay, or candidate existence cannot authorize acceptance.

### ACCEPTED → INDEXED

Requires indexing authority and an `index_ref` representing the indexing/storage operation.

Indexing must not silently activate Knowledge.

### INDEXED → ACTIVE

Requires explicit activation authority. `decision_ref` and confirmation semantics must be resolved before implementation.

### ACTIVE → UPDATED

Requires creation of a successor record. Existing record becomes `UPDATED` and references successor through `superseded_by`.

### ACTIVE → DEPRECATED

Requires explicit deprecation authority. Deprecation does not imply archive.

### DEPRECATED → ARCHIVED

Requires explicit archive authority. `ARCHIVED` is terminal on the normal lifecycle path.

## 9. Confirmation Boundary

Existing high-risk confirmation infrastructure is explicitly scoped to `RECOVERY_RESTORE`.

It must not be reused for Knowledge lifecycle merely because it already exists.

For Knowledge transitions that require confirmation, a Knowledge-specific authority/confirmation contract must be established before implementation. `confirmation_ref` may only be accepted after its authority, target, operation, actor, and status are independently validated.

## 10. Security Boundary

Transition functions should be `SECURITY DEFINER` only when required to protect the mutation boundary, with:

- fixed safe `search_path`
- server-resolved auth identity
- account/SH ownership validation
- active SH validation
- exact grants
- no anon execution
- no caller-controlled authority fields
- no direct authenticated table mutation path

Existing RLS remains defense-in-depth and must not be treated as a replacement for transition authorization.

## 11. Result Contract

Machine-observable categories:

```text
SUCCESS
ALREADY_APPLIED
REJECTED
FAILED
```

Recommended semantics:

- `SUCCESS`: transition committed and required ledger/projection writes committed.
- `ALREADY_APPLIED`: exact operation identity already committed; return the previously resulting record.
- `REJECTED`: authentication, ownership, lifecycle, authority, scope/policy, or semantic contract rejected before successful mutation.
- `FAILED`: unexpected runtime/database failure; no successful partial mutation may be claimed.

SQLSTATE mapping must be finalized against the actual PostgreSQL implementation rather than invented in advance.

## 12. Verification Requirements Before Gate Opens

Minimum verification matrix:

1. positive authorized transition
2. unauthenticated rejection
3. wrong-account rejection
4. wrong-SH rejection
5. wrong expected lifecycle rejection
6. illegal transition rejection
7. duplicate exact operation → `ALREADY_APPLIED`
8. same operation key with different semantic target/transition → conflict
9. concurrent transition behavior
10. mutation + ledger + Journey atomicity
11. forced downstream Journey failure → full rollback
12. update/supersession integrity
13. archive terminal behavior
14. RLS/direct mutation denial
15. exact grants / anon denial
16. Journey payload completeness
17. operation ledger provenance completeness
18. full lifecycle E2E from candidate through terminal state

## 13. Gate Decision

**DESIGN BOUNDARY: PASS PARSIAL**

**MIGRATION: NOT AUTHORIZED YET**

**IMPLEMENTATION: NOT AUTHORIZED YET**

Remaining blockers before migration:

1. final schema/constraint review
2. exact transition-specific authority, especially activation/deprecation/archive confirmation semantics
3. exact ledger result semantics
4. exact SQLSTATE/error contract based on implementation
5. exact Journey event/payload contract approval
6. implementation and E2E test plan

No database mutation is authorized by this document alone.
