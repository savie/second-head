# SECOND HEAD — P5C SELECTED TRANSFER RECONCILIATION v1.0

**Project:** SECOND HEAD — SYSTEM BUILD  
**Document Type:** P5C Execution Reconciliation / Selected Transfer Contract  
**Version:** v1.0  
**Status:** ACCEPTED FOR DEV IMPLEMENTATION  
**Canonical Status:** NON-CANONICAL  
**Mutation:** NO CANONICAL MUTATION

## 1. Purpose

This document records the implementation reconciliation performed after the Owner-established transfer semantics were clarified.

The governing principle is:

```text
selection
→ eligibility / privacy boundary
→ transfer
→ provenance
```

No transfer operation may silently mean "copy everything" when the governing semantics require explicit selection.

## 2. Existing persistent domains confirmed

The current DEV schema has persistent representations for:

- Memory — `public.memories`
- Knowledge — `public.knowledge`
- Experience — `public.experiences`
- Journey — `public.journey_events`
- Legacy preservation — `public.legacy_records`

Experience is a distinct semantic domain and is not collapsed into Knowledge.

## 3. Inheritance

`runtime_record_inheritance()` now consumes the approved authorization scope and performs selected transfer for:

```text
Memory
Knowledge
Experience
Journey
```

The operation validates that selected source IDs belong to the source SH.

Journey selection additionally respects its privacy/transfer boundary; private or non-transferable Journey events are rejected.

Transferred rows are recreated under the target SH and provenance records the source SH, authorization, and transfer timestamp.

## 4. Succession

`runtime_execute_succession()` now performs selected transfer for:

```text
Memory
Knowledge
Experience
Journey
```

The existing End-of-Life boundary remains mandatory:

```text
source SH = deactivated
+
active succession rule
+
active successor PRIMARY SH
+
explicit selected scope
```

The succession rule is consumed only after the selected transfer transaction succeeds.

## 5. Legacy

`runtime_preserve_selected_transfer_as_legacy()` provides selected preservation using the existing `legacy_records` mechanism.

No new History table was introduced.

Selected Memory, Knowledge, Experience, and eligible Journey records can be preserved with selection and provenance in the legacy record.

## 6. Reference / Value / History representation boundary

The audit did **not** invent new persistent source tables for Reference, Value, or History.

The current implementation therefore does not silently pretend that these domains have source-record IDs when the DEV schema does not provide such representations.

If a transfer scope explicitly supplies `reference_ids`, `value_ids`, or `history_ids`, the RPC rejects the operation with a deterministic representation-gap error.

This is intentional anti-drift behavior: unsupported data is never silently discarded or fabricated.

Whether those semantic concepts require future persistent source-domain representations remains a separate authority/semantic question and is not changed by this reconciliation.

## 7. Frontend wiring

The P5C frontend service now exposes a shared `TransferSelection` shape and passes selected scope into:

- Inheritance authorization creation
- Succession rule creation
- Selected Legacy preservation

The combined Inheritance / Legacy / Succession screen now exposes explicit selection JSON for those operations.

The existing Clone screen does not expose manual Clone execution. Clone remains Model B:

```text
A creates invitation
→ A approves
→ B registers with intended email
→ auth bootstrap materializes Clone
→ B receives PRIMARY SH
```

## 8. GitHub / Supabase reconciliation

The selected-transfer migration was applied to Supabase DEV and the migration history was reconciled to the DEV migration filename:

```text
20260819133000_p5c_selected_transfer_contract
```

The same migration exists in GitHub DEV.

Relevant implementation commits:

- selected transfer migration: `0aa00a9361cb16c92be8fc749d1590b2c625c3d1`
- selected transfer frontend service: `f8c4f9affa1380c4f4dd2f561f7db6f70692bdc9`
- selected transfer UI wiring: `afe5c3d13bbec72edc58768a43e1608d3812c2a3`

## 9. Functional closure boundary

Code-level backend ↔ service ↔ frontend mapping for P5C selected transfer is now coherent.

This does **not** constitute device E2E proof.

The remaining verification sequence is:

```text
BUILD APK
↓
install current DEV APK
↓
single-device E2E
↓
Inheritance selected transfer
↓
Succession selected transfer after End-of-Life
↓
Legacy selected preservation
↓
Clone Model-B registration materialization
↓
error-path verification
↓
full feature regression
```

Only after runtime verification passes should the project be treated as functionally closed for this delivery checkpoint.

## 10. Non-canonical status

This document does not modify Canonical Architecture, Frozen Baseline, Build Scope, Implementation Contract, Implementation Guide, or Execution Strategy.

It records implementation reconciliation only.
