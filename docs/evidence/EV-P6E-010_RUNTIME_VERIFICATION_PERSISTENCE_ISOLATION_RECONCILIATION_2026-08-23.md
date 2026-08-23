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

The polluted Chat rows were persisted historical verification artifacts in `public.conversations` with:

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

## 5. Historical artifact cleanup

For the authenticated E2E SH used by the verification workflow, historical rows matching:

```text
source      = runtime-p4a-001
persistence = P4A-005
```

were removed from `public.conversations`.

Post-cleanup verification:

```text
verification_chat     = 0
recovery_snapshot     = 0
recovery_event        = 0
```

This cleanup is data cleanup only; it does not disable normal owner conversation persistence.

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

## 7. Frontend behavior

The owner Chat FE now supports recent real conversation continuity while filtering known verification artifacts before rendering history.

Relevant FE commits:

- `1e077ab018c0b916e5b52be959f5435bf0ed41ed` — restore filtered recent chat continuity
- `47e5e22e9ad66fc2c2449cff370d5eb1546c2b5d` — expose primary SH id for chat history

Desired owner behavior:

```text
Open Chat
   ↓
recent real conversation may appear
   ↓
verification/test artifacts must not appear
```

`New Chat` may still start empty; this is currently acceptable and is not a blocker for the persistence-isolation finding.

## 8. APK #190 REAL E2E checkpoint

APK #190 observations:

```text
Chat normal response              PASS
Memory                            PASS / visible
Knowledge                         PASS / visible
Experience                        PASS / visible
Recovery                          PASS / no phantom snapshot
Journey Evolution                 PASS / valid Evolution visible
Journey verification pollution   FIXED / historical artifacts removed
```

One remaining Chat verification response visible before cleanup was confirmed as a historical `P4A-005` artifact, not a newly generated verification-only record.

## 9. Gate before next testing

Do not mix this finding with downstream semantic testing.

Current gate:

```text
Runtime verification isolation   PASS
Historical recovery pollution    CLEAN
Historical Journey pollution     CLEAN
Historical verification Chat     CLEAN
Valid Evolution                  RETAINED

NEXT:
reload/reopen APK #190 and confirm the old verification message is gone
then continue with the next REAL E2E test surface
```

## 10. Reconciliation conclusion

The observed verification/test pollution was a combination of:

1. historical persisted test artifacts from the pre-isolation period, and
2. missing cleanup of those artifacts after verification runs.

The current verification path is now isolated and CI-proven. Existing polluted rows have been cleaned. The valid semantic Journey Evolution record remains intact.

This evidence supersedes any earlier assumption that Recovery/Chat/Journey pollution seen on APK #190 necessarily represented fresh runtime mutations after the isolation fix.
