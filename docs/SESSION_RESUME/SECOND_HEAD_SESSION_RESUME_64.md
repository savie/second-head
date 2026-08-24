# SECOND HEAD — SESSION RESUME 64

## Purpose

This resume is the direct continuation of Session Resume 63 and the current DEV branch state. It preserves the reconciled continuity point and records the verified work completed after Resume 63 without reopening previously closed gates.

## Continuity baseline

- Resume 63 remains the prior reconciled checkpoint.
- Historical Resumes 52–62 remain historical/working-session material, not independent canonical authority.
- Current implementation and verification state must be interpreted against the Canonical, architecture, scope, execution strategy, addendum, reconcile, and current Supabase DEV state.
- Do not restart the project-wide audit from zero merely because a later retrieval/context defect is found.

## Current DEV implementation state after Resume 63

The following changes are present after the Resume 63 checkpoint:

1. `fix(P4A): retrieve Memory before model context assembly` (`99b5f4a`) — runtime retrieves Memory before `executeModel()` and passes retrieved Memory plus Experience context into model execution.
2. `fix(P4A): normalize knowledge candidate persistence` (`a264575`) — Knowledge candidate persistence was normalized.
3. `fix(P4A): bound Experience context by query relevance` (`da707f6`) — Experience retrieval was bounded by query relevance rather than blindly exposing account-wide Experience context.
4. `fix(P4A): retrieve relevant Experience context` (`065ed8a`) — relevant Experience context retrieval was further corrected.
5. `fix(P3C): reconcile partial-match Memory retrieval` (`f94e1c8`) — Memory relevance retrieval was corrected so natural-language recall can match durable Memory without requiring every query term to occur in the Memory text. The bounded retrieval remains scoped to the current `sh_id`, permitted lifecycle values, relevance threshold, deterministic ranking, and bounded limit.

## Important current retrieval/runtime path

The current runtime path is:

```text
Authenticated request
    ↓
resolveIdentity()
    ↓
retrieveMemories(sh_id, user_message)
    ↓
retrieveExperiences(sh_id, user_message)
    ↓
executeModel(user_message, { memories, experiences })
    ↓
model context assembly
    ↓
model response + semantic_signals
    ↓
conversation persistence
    ↓
Journey decision/recording
    ↓
recordSemanticLifecycle()
```

The critical invariant is that retrieval must be **current-SH scoped, relevance-bounded, lifecycle/visibility constrained by the persistence contract, and context-authorized** before any retrieved record reaches the model.

## APK #192 state

Resume 63 established the following real-device evidence:

```text
#192
Chat/auth/runtime                 PASS
New Conversation isolation       PASS
Memory acquisition                PASS
Knowledge acquisition             PASS
Experience acquisition            HOLD / path reconciliation required
```

The Memory acquisition evidence was the durable coffee preference test. The Knowledge acquisition evidence was the explicit Supabase-backend teaching test. These were real acquisition records and must not be confused with later retrieval tests.

## Retrieval investigation state

The next problem surfaced by APK #192 is not whether Memory/Knowledge can be acquired; that gate was already passed. The unresolved issue is whether the **correct** stored records are retrieved and composed into model context.

Observed failure mode before the latest retrieval reconciliation:

- The coffee Memory existed, but a natural-language recall question could fail to retrieve it because the prior P3C relevance primitive effectively required all non-stopword query terms to match.
- Experience context could be too broad if retrieval was not query-bounded, allowing unrelated historical material such as clone/transfer/APK-test records to become model context.
- Therefore a natural-language question about the coffee habit could be answered from an older/incorrect Experience record or contaminated context instead of the current Memory.

The latest P3C reconciliation changes Memory scoring to an OR-style `websearch_to_tsquery` term construction while retaining deterministic `ts_rank_cd`, a non-trivial relevance threshold, current-SH scoping, lifecycle filtering, deterministic ordering, and a bounded result count. fileciteturn437file0L7-L11

## Current audit focus

The next verification must trace the exact data path rather than infer correctness from the natural-language answer:

```text
APK #192
   ↓
retrieveMemories()
   ↓
Did the current coffee Memory return?
   ↓
retrieveExperiences()
   ↓
Are unrelated clone / transfer / APK-test records excluded?
   ↓
executeModel()
   ↓
What exact authorized Memory + Experience context was assembled?
   ↓
model response
```

The goal is to establish the exact root cause and verify the minimal correction. Do not introduce broad cleanup, delete historical records, or weaken existing isolation merely to make one answer look correct.

## Safety / non-regression rules

1. Preserve `sh_id` ownership isolation.
2. Preserve PRIVATE / OWNER_ONLY semantics for owner Memory/Knowledge/Experience records.
3. Do not treat historical records as newly acquired evidence.
4. Do not reintroduce the removed Experience capture UI merely to satisfy a historical test path.
5. Do not replace Memory retrieval with account-wide transcript/Experience search.
6. Do not pass raw retrieved records to the model without the runtime's authorized-context framing.
7. Do not broaden lifecycle eligibility merely to recover a missing record.
8. Prefer minimal forward-only patches over destructive data changes.
9. Separate implementation fix, CI result, APK result, and documentation/reconcile state.
10. If a test expectation conflicts with the current canonical/runtime path, reconcile the test before changing product behavior.

## Current continuation point

The project is **not** back at the semantic acquisition starting line. Memory and Knowledge acquisition remain PASS on APK #192. The current continuation point is the retrieval/context correctness gate:

```text
Acquisition
  Memory      PASS
  Knowledge   PASS

Retrieval
  Memory recall correctness          VERIFY / latest reconciliation present
  Experience relevance isolation    VERIFY

Context assembly
  Exact authorized context           VERIFY on APK #192

Experience E2E
  Current supported path             HOLD / reconcile canonical test path
```

## Immediate next action

Run the APK #192 retrieval verification against the current DEV state and inspect the actual returned Memory/Experience context and resulting model context. Only after that evidence is collected should any further patch be proposed.

The latest DEV commit at the time of this resume is `f94e1c8` (`fix(P3C): reconcile partial-match Memory retrieval`).
