# SECOND HEAD — SESSION RESUME 63

## Reconciled continuation point

This resume intentionally establishes a **reconciled continuation from Session Resume 51**.

### Authority model

```text
Resume 51
   ↓
intermediate development trail (Resumes 52–62)
   ↓
source / commit / CI / device evidence reconciliation
   ↓
Resume 63 = current continuation point
```

Resumes 52–62 are retained as historical development records, but they are **not the primary continuation authority** for this session. They must not be interpreted as a separate canonical branch of project direction. Where later source/evidence superseded an intermediate statement, the later verified state is authoritative.

Resume 51 itself was created as the reference checkpoint at commit `b69c0a26d575ba0edb601aea0f9680df65f6c7af`. fileciteturn153file0L3-L7

The current `dev` head reached `78cab6fbd500fa63e9640f1dd4de7b633a7fc5c5`; the GitHub comparison from Resume 51 contains 120 commits of subsequent development/reconciliation. fileciteturn154file0L2-L2

---

# 1. Working rules retained from Resume 51

```text
CANONICAL
   ↓
AUDIT GITHUB + SUPABASE
   ↓
identify actual defect source
   ↓
BE/DB or FE fix
   ↓
CI
   ↓
APK when device evidence is required
   ↓
REAL E2E
   ↓
update Matrix / evidence / resume
```

Rules retained:

- Canonical Matrix/contracts remain authoritative for TC semantics and lifecycle rules.
- Code existence is not E2E PASS.
- CI PASS is not device E2E PASS.
- Historical DB rows are not fresh mutation proof.
- Backend/runtime remains authoritative for ownership, authorization and lifecycle enforcement.
- Do not make irreversible lifecycle/data changes without evidence and explicit scope.
- When a later verified implementation contradicts an intermediate resume statement, the later verified implementation wins.

---

# 2. Major reconciliation since Resume 51

The post-51 development trail covered several distinct areas. The important reconciled outcomes are:

## 2.1 Journey / Experience visibility

The original TC-EXP-06 defect was localized to the FE Journey read path: an account-scoped FE query could discard shared Experience rows before RLS/shared-visibility logic had a chance to authorize them.

The subsequent source trail implemented the account-scoped Journey read-path correction and shared Experience context handling. This work was followed by further lifecycle/contract reconciliation rather than being treated as an isolated UI patch.

## 2.2 Clone / Inheritance / Succession / End-of-Life

The implementation trail reconciled:

- Inheritance target → Account ID.
- Succession successor → Account ID.
- Clone recipient → email/current-account context.
- Transfer-policy terminology → canonical inheritance terminology.
- Explicit End-of-Life confirmation and terminal lifecycle.
- Legacy preservation gating on terminal lifecycle.
- Clone privacy and transfer boundaries.
- Revoke/release cleanup and provenance boundaries.

The FE/BE contract was subsequently synchronized so that FE exposes the intended controls while BE remains authoritative for validation and enforcement. Resume 62 explicitly recorded this FE↔BE synchronization point. fileciteturn155file0L2-L2

## 2.3 P5A semantic persistence reconciliation

The later source trail introduced and reconciled:

- explicit semantic save candidate execution;
- explicit save-intent fallback;
- explicit Memory replacement execution;
- atomic semantic persistence boundaries;
- separation of continuity Journey events from semantic-domain persistence;
- private-scope constraint for model semantic candidates;
- revocation of public semantic mutation execution;
- duplicate Knowledge Journey persistence removal.

These changes are part of the reconciled current semantic-persistence architecture, not standalone experimental branches.

## 2.4 Migration / security / Supabase parity

The later reconciliation work canonicalized migration filenames/source, removed non-canonical duplicate migrations, moved live Supabase state into the executable migration chain, and reconciled GitHub↔Supabase migration parity.

Security work also closed or hid exposed security-definer/public execution boundaries where required, including internal SH assertion and transfer-scope validation paths.

The final migration repository structure reconciliation was recorded before the current FE/runtime verification work.

---

# 3. FE ↔ BE lifecycle synchronization checkpoint

Resume 62 recorded the deterministic FE changes that were completed before the later runtime-verification work:

1. Chat restored explicit Save to Journey and Save as Memory actions while remaining continuously sendable.
2. Legacy preservation became FE-gated until both Account and SH are `DEACTIVATED`.
3. Succession displays configured rules and exposes execution for the configured successor; BE remains authoritative for terminal-state and successor validation.

Canonical alignment retained:

- `database/migrations/` is the canonical migration source.
- Journey is the common Memory / Knowledge / Experience policy-detail surface.
- Backend/runtime remains authoritative for ownership, authorization and lifecycle enforcement.

These points are inherited into Resume 63. fileciteturn155file0L2-L2

---

# 4. Chat / runtime verification reconciliation

This is the most recent major debugging thread and is now explicitly separated from the lifecycle/transfer work above.

## 4.1 Verification harness pollution found

Historical verification tests were creating persistent artifacts in the same interactive SH used for real E2E. This produced unwanted:

- `SH runtime controlled verification`
- streaming verification messages
- recovery artifacts
- Journey test artifacts

The test harness was subsequently changed so verification artifacts are isolated/non-persistent and recovery roundtrip artifacts are cleaned up. The source history contains dedicated fixes for runtime verification persistence, streaming verification persistence, recovery cleanup and Journey cleanup.

## 4.2 CI dependency / trigger reconciliation

The runtime verification workflow initially failed because `@supabase/supabase-js` was not installed before the Node test executed.

A CI dependency-install step was added in commit `31bea45c9cb828b4a436bd048a06682ae8838071`.

The workflow also initially had only `workflow_dispatch`; it was then changed to run automatically on pushes to `dev` in commit `33e450d6bb00ffd897d636e802ebe90500845492`.

The resulting workflow run was observed as green, and the runtime invocation test subsequently returned:

```text
status: PASS

checks:
- authenticated session obtained
- runtime-p4a-001 accepts authenticated request
- runtime resolves and returns SH identity
- runtime response contract is valid
- verification-only persistence isolation is active
- bounded context assembly returns memory and knowledge arrays
- journey retrieval is bounded to the authenticated SH and RLS
- logout succeeds
```

Therefore the **runtime verification CI gate is PASS**. The verification-isolation requirement is not merely source-level; it reached an actual CI PASS.

## 4.3 FE chat continuity reconciliation

Commit `ab67a4148ab6a21ca2c488b54a554d7471564e18` intentionally removed account-wide history hydration so a New Conversation started empty and avoided historical verification pollution.

During subsequent discussion, desired product behavior was clarified:

- opening the Chat surface may show the last real conversation;
- verification/test conversations must not be rehydrated into the visible chat history;
- pressing New Conversation may still produce a clean new conversation.

Commit `1e077ab018c0b916e5b52be959f5435bf0ed41ed` then restored filtered recent-chat continuity, followed by `47e5e22e9ad66fc2c2449cff370d5eb1546c2b5d` to expose the primary SH ID required by the history read path.

These changes require device confirmation; they are not declared final E2E PASS solely from source/CI.

---

# 5. Verification cleanup scope correction — IMPORTANT

A cleanup operation during this debugging thread was discovered to have been **too broad**: it removed conversation rows associated with the cleanup predicate instead of only removing the intended verification artifacts.

This is explicitly recorded as a **known correction / open issue**, not hidden or converted into a PASS.

The documentation trail subsequently corrected the cleanup scope and recorded the correction in commit `78cab6fbd500fa63e9640f1dd4de7b633a7fc5c5`.

Current rule:

```text
verification cleanup
   ≠
blanket conversation deletion
```

Future cleanup must identify artifacts by explicit verification provenance/marker and must preserve real user conversation history.

---

# 6. APK / Real E2E checkpoint

The latest device checkpoint discussed in the current continuation is **APK #190**.

Observed on #190:

- New Conversation was clean; this was accepted for the current checkpoint.
- Memory appeared.
- Knowledge appeared.
- Experience appeared.
- Recovery was no longer showing the previous phantom recovery artifacts.
- In `Other`, historical Journey artifacts such as `LIFECYCLE` / `LEGACY` verification pollution were cleaned; valid `EVOLUTION` was intentionally retained.
- One historical verification response was still visible in Chat, showing that chat-history cleanup/continuity remained an issue to reconcile rather than a fully closed gate.

These observations are **device evidence from the current project thread**, but they do not constitute a blanket PASS for all semantic/lifecycle TC IDs.

---

# 7. Current status matrix for this continuation

```text
Canonical / migration authority       🟢 reconciled source direction
FE ↔ BE lifecycle synchronization     🟢 source-level reconciliation
Runtime verification CI               🟢 PASS
Verification persistence isolation    🟢 PASS
Recovery test artifact cleanup        🟢 implemented / observed clean
Journey test pollution cleanup        🟢 implemented / observed clean
Valid Evolution                       🟢 retained
Memory / Knowledge / Experience UI    🟢 observed on APK #190
Chat verification junk prevention     🟢 new verification path isolated
Chat historical continuity            🟡 OPEN / requires careful reconciliation
Conversation data recovery             🔴 OPEN if historical rows need restoration
Full authenticated multi-account E2E  ⏳ not yet globally closed
Clean-room migration replay           ⏳ separate evidence gate
```

Do not interpret this table as replacing the Canonical Matrix. It is a session-level continuation checkpoint.

---

# 8. What is superseded from the intermediate Resumes 52–62

Resumes 52–62 remain valid historical records of work performed, but they are **not the clean continuation path** for a reader entering the project now.

The following interpretation rule applies:

```text
Resume 52–62 statement
        ↓
compare against actual source / later commit / CI / E2E evidence
        ↓
if superseded → do not inherit as current state
if still supported → retain
```

In particular, no intermediate resume should be used to infer that a source-level change was an E2E PASS when later device evidence contradicted or narrowed it.

---

# 9. Current continuation order

Before moving to unrelated TC testing:

```text
1. Reconcile / recover Chat conversation continuity safely.
2. Verify verification artifacts remain isolated after fresh CI/test execution.
3. Run required CI gates for the current FE/runtime state.
4. Build a new APK only when the source state is stable enough for device evidence.
5. Re-test the smallest affected Real E2E surface.
6. Update Canonical Matrix/evidence.
7. Only then advance to the next unrelated verification area.
```

Do **not** perform broad DB cleanup as a substitute for provenance-aware cleanup.

---

# 10. Resume 63 continuation rule

This file is now the preferred session handoff for continuation after the Resume 51 baseline.

```text
Resume 51
   ↓
52–62 = historical intermediate trail
   ↓
source + CI + E2E reconciliation
   ↓
Resume 63
   ↓
continue from OPEN items only
```

The goal is not to erase the historical trail. The goal is to prevent a future reader from confusing intermediate development states with the current reconciled project state.

## Immediate next technical focus

**Safely restore/reconcile real Chat history continuity without reintroducing verification/test artifacts.**

Only after that gate is understood and evidenced should the project resume broader Real E2E verification.
