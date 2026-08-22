# SECOND HEAD — SESSION RESUME 56

## Checkpoint

This resume supersedes Session Resume 55 as the latest continuity checkpoint.

- Previous checkpoint: `756240e454391db831b19dcaeb7c2403aafa0381`
- Current DEV branch checkpoint: `9a84b021d2269a852a22a1ba21e3c71007140055`
- Backend: Supabase DEV `pkhkgvsrqeupvwoqjwmd`
- Current Supabase migration tail:
  - `20260822021005` `explicit_memory_replacement`
  - `20260822021024` `semantic_persistence_atomicity`
  - `20260822021134` `revoke_anon_semantic_mutation_execute`

## 1. Authority

Canonical authority remains unchanged.

- SH Core Canonical remains the conceptual authority.
- Canonical architecture remains authoritative at its defined abstraction level.
- Build Scope, Implementation Contract, Implementation Guide, Phase -1 and Execution Strategy remain derived execution authorities.
- Session Resume is only a continuity checkpoint and never overrides higher authority.
- No new Owner decision was introduced by this reconciliation pass.

## 2. Why this checkpoint was created

The previous Session Resume 55 ended at `756240e`, while subsequent implementation continued without a new resume. The later commits exposed a real GitHub ↔ Supabase DEV drift and semantic persistence defects.

This pass therefore performed audit → fix → reconcile → re-audit before continuing.

## 3. P0 CLOSED IN THIS PASS

### 3.1 GitHub ↔ Supabase semantic migration drift

Supabase DEV was missing the explicit memory replacement migration that existed in GitHub. The migration was applied and its remote history is now recorded.

### 3.2 Missing runtime replacement function

`public.runtime_replace_memory(...)` now exists in Supabase DEV.

### 3.3 Replacement broad-update defect

Replacement no longer updates every matching memory. The runtime function now requires a non-empty target pattern, resolves active/candidate matches, rejects zero matches, rejects ambiguous matches, and supersedes exactly one resolved memory.

### 3.4 Semantic domain mutation / Journey partial-write boundary

New server-side functions make Memory + Journey and Knowledge + Journey persistence occur within one database function/transaction boundary:

- `runtime_record_memory_with_journey`
- `runtime_record_knowledge_with_journey`
- `runtime_replace_memory`

The Edge runtime no longer performs a second Journey RPC for these domain writes.

### 3.5 Duplicate Knowledge Journey write

The runtime previously persisted Knowledge Journey in semantic lifecycle and then emitted another Knowledge Journey event in `index.ts`. The duplicate path has been removed.

## 4. P1 FIXED IN THIS PASS

### 4.1 Semantic candidate privacy boundary

Model-produced Memory/Knowledge candidates are now persisted with deterministic `PRIVATE` / `OWNER_ONLY` scope and visibility. The model cannot promote a semantic candidate to shared/general storage merely by returning different scope/visibility fields.

### 4.2 Explicit persistence fallback

The keyword fallback was narrowed from generic update/replace/ganti language to explicit persistence-leading commands. Replacement requests remain handled by the dedicated replacement parser.

### 4.3 Journey candidate boundary

`MEMORY` and `LEARNING` are no longer accepted as generic `journey_candidate` types from the model path. Those domain writes generate their own exact Journey event inside the atomic persistence function. Continuity Journey candidates remain for lifecycle/continuity-oriented event types.

### 4.4 Runtime mutation privileges

Semantic mutation functions and Journey delete are restricted to `authenticated`; `public` and `anon` execution was revoked.

## 5. Migration reconciliation

GitHub migration filenames were aligned to the actual Supabase DEV remote versions rather than using later local timestamps.

The authoritative DEV tail is now represented in GitHub as:

```text
20260822021005_explicit_memory_replacement.sql
20260822021024_semantic_persistence_atomicity.sql
20260822021134_revoke_anon_semantic_mutation_execute.sql
```

## 6. Remaining P1 / evidence work

The following items remain OPEN and are not claimed as PASS by this resume:

1. Cross-account Experience visibility requires fresh authenticated E2E proof.
2. Experience disappearance/visibility anomalies from the previous checkpoint require fresh reproduction and proof.
3. Recovery duplicate `RECOVERY` / `RESTORED` records remain an open integrity investigation until fresh evidence closes them.
4. Experience → Memory semantic promotion remains an open behavior contract/evidence item.
5. Full authenticated semantic Memory/Knowledge/Replacement roundtrip still needs fresh runtime E2E proof against the reconciled DEV database.
6. The new `SECURITY DEFINER` functions require final privilege and authenticated-path regression evidence; privilege state is reconciled, but runtime E2E is not yet a PASS claim.

## 7. Explicit non-goals of this checkpoint

No new product feature was introduced.

No Canonical concept was changed.

No Owner decision was invented.

No FE feature was marked complete merely because UI code exists.

## 8. Next execution gate

Before feature expansion, run fresh authenticated verification for:

```text
Memory candidate
   ↓
atomic Memory + Journey

Knowledge candidate
   ↓
atomic Knowledge + Journey

Explicit replacement
   ↓
exactly one target
   ↓
supersession
   ↓
new Memory + Journey

Cross-account boundary
   ↓
owner A cannot expose private semantic records to owner B
```

Only after these pass should the remaining P1 backlog be closed or the next feature phase be resumed.
