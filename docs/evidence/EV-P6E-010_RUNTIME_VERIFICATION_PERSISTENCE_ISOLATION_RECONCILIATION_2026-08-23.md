# SECOND HEAD — EVIDENCE / RECONCILIATION

## EV-P6E-010 — Runtime Verification Persistence Isolation

Date: 2026-08-23
Branch: `dev`

## 1. Problem observed

During REAL E2E on APK #190, normal owner chat was functional and semantic surfaces were populated, but verification/test artifacts had polluted the owner-visible Chat and Journey surfaces.

Observed Chat artifact:

```text
I can assist with runtime verification. Please let me know what you'd like to verify or any details you have in mind.
```

Observed Journey pollution included test-derived `LIFECYCLE` / `LEGACY` records. The valid `EVOLUTION` record describing APK #175 replacing APK #85 was intentionally retained.

## 2. Root cause

The polluted Chat rows were historical verification/test rows in `public.conversations` with:

```text
metadata.source      = runtime-p4a-001
metadata.persistence = P4A-005
```

These rows predated the verification-only persistence isolation fix. They were not evidence that the current verification-only runtime path was still persisting new conversation data.

The current runtime verification contract was separately verified by CI as:

```text
verification-only persistence isolation is active
```

## 3. Runtime isolation fix

The verification harness/runtime path was changed so controlled verification requests do not use the normal persistence path.

Relevant commits:

- `83f9625fb89be65e16aec514b97728b6bc845cb0` — isolate verification harness artifacts
- `6f44808833f681559f2f6fd5c71047e5c8a372d2` — isolate runtime verification persistence
- `3588cfc8bd64d042be5b1b305d667aaaf9c3e47d` — make runtime invocation verification non-persistent
- `8239f86c43bc2e840b72841e0e00284b079d73f4` — make runtime streaming verification non-persistent
- `4249a220bacb269afe57f316208b36970b14e218` — cleanup recovery roundtrip artifacts
- `1eaf16d3c8f2bc2e2e16e081e746fd340e1b4145` — cleanup recovery journey artifacts

## 4. CI proof

GitHub Actions workflow:

`SH Runtime Controlled Verification #3`

Commit:

`33e450d6bb00ffd897d636e802ebe90500845492`

The controlled runtime verification test returned:

```json
{
  "status": "PASS",
  "checks": [
    "authenticated session obtained",
    "runtime-p4a-001 accepts authenticated request",
    "runtime resolves and returns SH identity",
    "runtime response contract is valid",
    "verification-only persistence isolation is active",
    "bounded context assembly returns memory and knowledge arrays",
    "journey retrieval is bounded to the authenticated SH and RLS",
    "logout succeeds"
  ],
  "context_counts": {
    "memory": 5,
    "knowledge": 0,
    "journey": 10
  }
}
```

Therefore the current runtime verification path is not allowed to persist through the ordinary conversation/semantic persistence path.

## 5. Historical artifact cleanup — IMPORTANT CORRECTION

A cleanup query was executed against the E2E SH using the historical verification metadata pair:

```text
source      = runtime-p4a-001
persistence = P4A-005
```

The predicate was broader than intended and removed **all conversation rows carrying that historical metadata pair**, not only the single visible verification message.

The deletion result included multiple old test conversations and historical owner/test conversation rows from the same P4A-005 persistence era. After the cleanup, the current `public.conversations` query for the E2E SH returned zero rows.

Therefore:

```text
verification Chat pollution = cleaned
BUT
historical conversation continuity = currently empty for this SH
```

This is a **cleanup-scope mistake**, not a runtime-isolation failure.

No claim should be made that the user's previous Chat history is fully preserved until it is restored/reconstructed from an authoritative backup or another authoritative source.

The cleanup did not modify Memory, Knowledge, Experience, Journey, Recovery, or Auth tables.

## 6. Journey cleanup status

Historical verification/test Journey pollution was removed.

Current `runtime:p4d:journey_candidate` records for the E2E SH include:

```text
EVOLUTION
  APK #175 replaced APK #85

EXPERIENCE
  APK #174 replaced APK #85

EXPERIENCE
  explicit transfer eligibility test
```

The `EVOLUTION` record is intentionally retained because it represents a valid semantic Journey change rather than verification noise.

The previously observed verification `LIFECYCLE` record and APK #85 test-vehicle `LEGACY` artifact were removed.

## 7. Recovery cleanup status

Post-cleanup verification for the E2E SH:

```text
recovery_snapshot = 0
recovery_event    = 0
```

Recovery tables were not affected by the conversation cleanup query.

## 8. Frontend behavior

The owner Chat FE supports recent conversation continuity while filtering known verification artifacts before rendering history.

Relevant FE commits:

- `1e077ab018c0b916e5b52be959f5435bf0ed41ed` — restore filtered recent chat continuity
- `47e5e22e9ad66fc2c2449cff370d5eb1546c2b5d` — expose primary SH id for chat history

Desired owner behavior remains:

```text
Open Chat
   ↓
recent real conversation may appear
   ↓
verification/test artifacts must not appear
```

`New Chat` may still start empty and is currently accepted.

## 9. APK #190 REAL E2E checkpoint

Before the broad cleanup, APK #190 observations were:

```text
Chat normal response              PASS
Memory                            PASS / visible
Knowledge                         PASS / visible
Experience                        PASS / visible
Recovery                          PASS / no phantom snapshot
Journey Evolution                 PASS / valid Evolution visible
Journey verification pollution   identified
```

The remaining visible Chat verification response was confirmed as historical P4A-005 data.

After cleanup, the historical verification rows are gone, but Chat continuity must now be re-established/verified because the cleanup predicate removed the full P4A-005 conversation class.

## 10. Gate before next testing

Do not proceed to another semantic/lifecycle test yet.

First resolve the Chat-history cleanup consequence:

```text
1. preserve the runtime verification isolation fix
2. recover/reconstruct authoritative recent owner Chat history
3. verify verification-only artifacts remain excluded
4. reload APK #190
5. confirm real recent chat can appear without test junk
```

Only after that should the next REAL E2E surface continue.

## 11. Reconciliation conclusion

The current verification-only runtime path is **CI-proven isolated**.

The Journey verification pollution is cleaned while valid Evolution remains.

The Recovery pollution is cleaned.

However, the historical Chat cleanup was broader than intended and emptied the E2E SH's `conversations` table. That consequence is now explicitly recorded and must be resolved before claiming Chat continuity PASS.

This evidence therefore distinguishes:

```text
RUNTIME ISOLATION          = PASS
HISTORICAL JUNK CLEANUP   = PASS
CLEANUP SCOPE             = ERROR / RECOVERY REQUIRED
CHAT CONTINUITY            = OPEN
```
