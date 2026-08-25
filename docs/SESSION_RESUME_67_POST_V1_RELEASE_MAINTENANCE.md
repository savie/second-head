# SECOND HEAD — SESSION RESUME 67

## Post-v1.0 Integration-Ready → User Validation & Reactive Maintenance

**Date:** 2026-08-26  
**Repository:** `savie/second-head`  
**Branch:** `dev`  
**Supabase DEV project:** `pkhkgvsrqeupvwoqjwmd`

---

## 1. Current Project Position

SH v1.0 has completed the Phase 6 chain and the Final Integration Gate.

```text
P1–P5                 🟢 CLOSED
P6A                   🟢
P6B                   🟢
P6C                   🟢
P6D                   🟢
P6E                   🟢
Final Integration     🟢 PASS

SH v1.0                = INTEGRATION-READY
```

**Integration-Ready does not mean no bugs will ever exist.** It means the engineering/integration gate has passed. After this point, user-reported defects and product feedback are handled through controlled reactive maintenance and targeted verification.

---

## 2. Frozen v1.0 Baseline — DO NOT MUTATE

There are two important immutable traceability references:

### 2.1 Frozen implementation candidate

```text
Implementation SHA: 40a8772e3c79e17de77c7581048620286ff638a9
APK:               #194
APK SHA-256:       bc53e9ebfe6c3fc92ec1e675998cbd774a97b5f51184e51c95236b97eb6690d4
Chat Verification: #252
```

This is the exact implementation candidate that was subjected to the Phase 6 / Final Integration Gate evidence chain.

### 2.2 Final Integration Gate disposition record

```text
Commit: c44b2bc311baea5a46d0acb957049eb3c8307817
```

This commit records the final SH v1.0 integration-gate disposition and establishes the release baseline record.

**Rule:** `40a8772...` and APK #194 remain historical/frozen evidence. `c44b2bc...` remains the final-gate record. Neither is overwritten, rebased, or silently amended.

---

## 3. Current DEV State Is Separate From the Frozen Baseline

The DEV branch continues to move only when an actual defect or approved change is being addressed.

Current DEV branch HEAD at Session Resume 67:

```text
HEAD: e29ad0b559ef589df960feac0a358fae82083d87
Message: Build #195: add bounded active-SH conversation context RPC
```

This is **not** a replacement of the frozen v1.0 baseline. It is a post-baseline maintenance candidate.

Current Supabase DEV latest migration:

```text
20260825215703_bug_001_short_term_conversation_context
```

The preceding reconciled state remains:

```text
20260824201714_reconcile_dev_db_functional_state
```

---

## 4. What Has Been Completed Since v1.0 Freeze

### BUG-001 — Immediate Conversational Recall

Observed on the frozen/runtime baseline:

- Previous user statements were visible in the conversation UI and persisted.
- Memory capture also worked.
- However, the runtime model request did not receive recent conversation history.
- Asking SH to recall a previous message therefore failed.

Root cause:

```text
UI conversation history       🟢
Persistence                   🟢
Memory capture                🟢

Runtime → model conversation context   ❌ missing
```

Fix direction and implementation:

```text
existing conversation persistence
        ↓
runtime-owned retrieval
        ↓
strict active-SH scope
        ↓
bounded recent window
        ↓
separate conversation_context
        ↓
model receives:
  - conversation context
  - current query
  - Memory
  - Experience
```

Memory and Experience retrieval/persistence remain separate and were not converted into transcript storage.

### BUG-001 device verification

The fix was tested on device using the new test account and the existing conversation.

The device successfully demonstrated that SH could refer to prior conversation messages and could answer based on recent conversation context while explicitly being told not to use Memory or Experience.

**BUG-001 status: 🟢 FIXED + DEVICE VERIFIED**

This verification does not retroactively change APK #194. The runtime fix is a post-baseline DEV maintenance change and therefore belongs to the next release/build candidate.

---

## 5. Current Primary User/Test Object

### Primary new-account smoke/E2E user

```text
E2E_TEST@SH.COM
```

This is the current primary test object for clean first-use and post-fix verification.

### Legacy/regression account

```text
sh-dev-test@banned.idn
```

Keep this account as a legacy/regression fixture because it previously exhibited the `CHAT190 / E2E / persistence marker` behavior.

**Do not treat the legacy behavior as a global UI rule without reproduction on both account types.**

Passwords/credentials must never be written into this document, source code, issues, commits, or logs. Automation credentials belong in GitHub Secrets only.

---

## 6. Frozen APK Rules

Once an APK is declared frozen/gated:

1. **Never mutate or overwrite the frozen APK.**
2. **Never rewrite its source history.**
3. Preserve its exact APK checksum and source SHA.
4. A bug found after freeze becomes a new maintenance candidate.
5. Every distributed APK gets a monotonically increasing build number.
6. Every build must remain traceable to its source commit and binary artifact.
7. A bugfix does not automatically reopen P1–P6; perform targeted verification according to the affected behavior.
8. If a change touches security, identity, authority, memory integrity, state integrity, continuity, recovery, audit, architecture, or another invariant, expand verification accordingly.
9. Never replay migrations or mutate Supabase without a technical reason.
10. Never delete historical evidence just to make a later candidate look clean.

---

## 7. Version vs Build Identity

Product version and exact build identity are separate.

Example:

```text
SH v1.0.0
Build 194   ← frozen base
Build 195   ← bugfix candidate
Build 196   ← later bugfix
```

A normal bugfix/refinement remains on the same product version while the build number increases.

Macro releases change product version:

```text
v1.0.0 → v1.1.0 → v2.0.0
```

The exact executable must always expose enough identity for a user/support report to answer:

> "Build berapa yang sedang dipakai?"

**Build identity in the APK UI is still a pending product task; it was not part of the BUG-001 runtime fix.**

---

## 8. Current Immediate Product Tasks

Priority order after Session Resume 67:

### A. Chat header cleanup

The new account produces a clean normal conversation title and does not show the old `#190 / E2E / persistence marker`.

The legacy account previously showed the marker. Before changing global header code, reproduce/trace the legacy behavior to determine whether it is account/data-specific or a true UI defect.

Do not implement rename conversation merely as part of this cleanup; rename remains separate until intentionally scoped.

### B. Build identity in APK

Add clear user-visible product/build identity, for example:

```text
SH
v1.0.0
Build 195
```

Every new distributed APK increments the build number.

### C. User-facing smoke/stability audit

Continue with:

- first-use flow
- registration/login
- new conversation
- normal chat response
- conversation continuity
- close/reopen app
- persistence
- loading/error states
- network interruption behavior
- navigation/back behavior
- basic visual consistency

Do not turn this into an uncontrolled redesign or feature expansion.

---

## 9. User Error / Complaint Response Protocol

When a real user reports an error, the development team should be **reactive and traceable**, not speculative.

### Step 1 — Capture exact build identity

Ask for:

```text
App version
Build number
Approximate time
What the user did
What the user expected
What actually happened
Screenshot/video if available
```

If possible also capture the conversation/flow identifier without exposing sensitive data.

### Step 2 — Reproduce

Reproduce against the same build where possible.

Do not immediately assume the latest DEV behavior represents the user's build.

### Step 3 — Classify

Use a simple severity classification:

```text
P0 — security/data/system-breaking
P1 — major functional defect
P2 — normal functional defect
P3 — cosmetic/polish
```

### Step 4 — Trace

```text
user report
   ↓
exact build
   ↓
APK / binary
   ↓
source SHA
   ↓
component / runtime path
   ↓
root cause
```

### Step 5 — Fix only the affected scope

Do not alter unrelated behavior.
Do not mutate frozen baseline evidence.
Do not replay migrations unless technically required.

### Step 6 — Verify

Run targeted verification for the defect and regression checks for adjacent behavior.

If the change crosses an architectural/security/invariant boundary, widen verification accordingly.

### Step 7 — Commit + push

Every accepted fix goes directly to DEV with a descriptive commit and remains traceable.

### Step 8 — New build

Increment the APK build number.

Example:

```text
Build 194  frozen base
   ↓
BUG found
   ↓
fix
   ↓
Build 195
   ↓
verify
   ↓
release/update
```

### Step 9 — Preserve history

The old build remains a valid historical artifact. Never replace it with the new build.

---

## 10. Release/Maintenance Principle

The intended post-v1.0 lifecycle is:

```text
SH v1.0
INTEGRATION-READY 🟢
        ↓
Frozen Base APK #194
        ↓
User use
        ↓
Bug / complaint
        ↓
Reactive development
        ↓
Fix + targeted verification
        ↓
Build +1
        ↓
User update
        ↓
Repeat
```

A macro product change becomes a new product version (`v1.1.0`, `v2.0.0`, etc.) rather than being hidden inside an endless v1.0 build stream.

---

## 11. Source of Truth / Navigation

GitHub DEV repository:

`https://github.com/savie/second-head/tree/dev`

Supabase DEV project:

`https://supabase.com/dashboard/project/pkhkgvsrqeupvwoqjwmd`

Primary v1.0 final-gate record:

`c44b2bc311baea5a46d0acb957049eb3c8307817`

Frozen implementation candidate:

`40a8772e3c79e17de77c7581048620286ff638a9`

Current post-v1.0 DEV maintenance HEAD at resume creation:

`e29ad0b559ef589df960feac0a358fae82083d87`

---

## 12. Session Resume 67 Starting Point

```text
FINAL GATE             🟢 PASS
SH v1.0                🟢 INTEGRATION-READY
Frozen APK #194        🟢 preserved
Frozen impl SHA        40a8772...
Final gate record      c44b2bc...

BUG-001                🟢 fixed + device verified
Current DEV            e29ad0b...
Supabase DEV           latest migration 20260825215703

Primary test user      E2E_TEST@SH.COM
Legacy test user       sh-dev-test@banned.idn

Next:
1. Header investigation/cleanup
2. Build identity in APK
3. Continue user-facing smoke audit
4. Reactive bug-fix loop with build increment
```

**END — SESSION RESUME 67**
