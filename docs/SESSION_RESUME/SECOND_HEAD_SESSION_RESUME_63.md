# SECOND HEAD — SESSION RESUME 63

## Purpose

This resume supersedes the continuity gap created by the historical Resume 52–62 sequence. Resume 63 is the reconciled continuation point from Resume 51, incorporating the subsequent work only where it is consistent with the canonical, architecture, scope, execution strategy, addendum, reconcile, and current-state evidence.

## Reconciliation baseline

- Resume 51 remains the valid prior continuity checkpoint.
- Resumes 52–62 are treated as historical/working-session material, not as independent canonical authority.
- This document is the continuation point for the reconciled state after reviewing the work that followed Resume 51.

## Current verified implementation state

- FE new-conversation behavior was corrected so a newly opened conversation does not hydrate the account-wide legacy conversation history.
- Runtime verification/authentication propagation was repaired and verified in CI.
- The runtime verification persistence isolation contract is active.
- The previous self-generated SH runtime/streaming verification contamination in ordinary chat was removed from the current flow.
- Legacy Recovery contamination was removed from the current UI path; current Lifecycle / Other state may still contain the canonical Evolution representation.
- Runtime semantic assessment was restored and subsequently hardened with structured semantic output requirements.
- Real device APK #191 established the semantic-acquisition failure baseline: normal chat worked, but an ordinary semantic preference did not create new Memory/Knowledge/Experience records.
- The semantic-output fix was then committed and CI passed.
- APK #192 subsequently verified real semantic acquisition:
  - Memory candidate: PASS; a new Memory record was created from the coffee preference test.
  - Knowledge candidate: PASS; a new Knowledge/Learning record was created from the dedicated knowledge test.
  - Experience has not yet been executed as a current UI E2E because the former explicit capture button/path was intentionally removed from the current Chat UI and must not be reintroduced merely for testing.

## #192 real E2E evidence

Memory test:

> Saya suka kopi hitam dan biasanya minum kopi hitam setiap pagi sebelum mulai bekerja.

Observed new Memory:
- 2026-08-23 23:27:07
- source: `runtime:p4d:memory_candidate`
- status: CONTINUOUS
- visibility: PRIVATE / OWNER ONLY
- transfer: NON TRANSFERABLE

A second identical Memory existed at 22:18:25 and is attributable to the earlier test based on timestamp separation; it was not treated as a duplicate write without further evidence.

Knowledge test:

> Saya ingin kamu menyimpan pengetahuan bahwa Second Head menggunakan Supabase sebagai backend utama untuk runtime dan persistence.

Observed new Knowledge/Learning:
- 2026-08-23 23:37:47
- source: `runtime:p4d:knowledge_candidate`
- status: CONTINUOUS
- visibility: PRIVATE / OWNER ONLY
- transfer: NON TRANSFERABLE

## Experience status

Experience must remain distinct from Memory and Knowledge. Canonical/reconciled architecture defines supported explicit Experience creation through the runtime Experience path, while the current Chat UI no longer exposes the former capture button. Do not restore the removed button merely to satisfy an old test path.

The current gap is therefore a test-path/coverage reconciliation item for Experience, not permission to regress the current UI. The next action is to reconcile the canonical `TC-EXP-*` / `TC-CHAT-13` expectations against the current supported runtime path and determine the valid current execution method.

## Current E2E status

```text
#192
Chat/auth/runtime                 PASS
New Conversation isolation       PASS
Memory acquisition                PASS
Knowledge acquisition             PASS
Experience acquisition            HOLD / path reconciliation required
```

## Next execution rule

Do not restart the full audit from zero. Continue from this resume. For every next E2E test:

1. Use the canonical test matrix and current architecture as authority.
2. Use real device evidence for device/runtime claims.
3. Do not treat old records as newly acquired evidence.
4. Do not restore removed UI solely because a historical test expected it.
5. If a test path no longer exists, reconcile the test against the current canonical/runtime contract before modifying product behavior.
6. Keep implementation fixes, CI verification, APK verification, and documentation/reconcile state explicitly separated.

## Continuation point

The project is currently beyond the semantic Memory and Knowledge acquisition gates on APK #192. The next unresolved canonical area is Experience execution/path reconciliation, followed by the remaining E2E matrix rather than another reset of previously passed gates.
