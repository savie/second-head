# SECOND HEAD — SESSION RESUME 51

## Continuation point

This Resume 51 is refreshed to reflect the latest verified state on `dev` after the runtime-verification persistence isolation and historical-artifact cleanup work.

Primary evidence:
`docs/evidence/EV-P6E-010_RUNTIME_VERIFICATION_PERSISTENCE_ISOLATION_RECONCILIATION_2026-08-23.md`

Latest documentation commit before this refresh:
`e16f27e53c11c86835fad8e103c521f95fa40a0f`

Branch: `dev`
Repository: `savie/second-head`

---

# 1. AUTHORITY / WORKING ORDER

Continue to use the Canonical REAL E2E Verification Matrix and existing project contracts as authority.

Working order:

```text
CANONICAL
   ↓
AUDIT GITHUB + SUPABASE
   ↓
BE / DB or FE according to actual defect source
   ↓
CI / smoke verification
   ↓
APK only when required
   ↓
REAL E2E
   ↓
update evidence / Matrix / Resume
```

Actual CI error/output remains authoritative when debugging CI.

Do not mix Chat history, verification persistence, Recovery, Journey semantics, and Memory/Knowledge/Experience retrieval into one defect.

---

# 2. RUNTIME VERIFICATION — PASS

GitHub Actions workflow:

```text
SH Runtime Controlled Verification #3
commit: 33e450d6bb00ffd897d636e802ebe90500845492
status: PASS
```

Passed checks included:

```text
authenticated session obtained
runtime-p4a-001 accepts authenticated request
runtime resolves and returns SH identity
runtime response contract is valid
verification-only persistence isolation is active
bounded context assembly returns memory and knowledge arrays
journey retrieval is bounded to authenticated SH and RLS
logout succeeds
```

Observed context counts:

```text
Memory    = 5
Knowledge = 0
Journey   = 10
```

Conclusion:

```text
verification-only runtime path is isolated from ordinary persistence
```

This is a CI/runtime proof, not by itself a proof of every Android E2E surface.

---

# 3. CHAT HISTORY CONTINUITY

Current intended owner behavior:

```text
Open Chat
   ↓
recent real conversation may appear
   ↓
verification/test artifacts must not appear
```

Recent FE commits:

- `1e077ab018c0b916e5b52be959f5435bf0ed41ed` — restore filtered recent chat continuity.
- `47e5e22e9ad66fc2c2449cff370d5eb1546c2b5d` — expose primary SH id for chat history.

`New Chat` may still start empty; this is currently accepted.

The key invariant is:

```text
real user conversation       → may persist / reappear
verification-only test data  → must not persist / reappear
```

---

# 4. HISTORICAL VERIFICATION CHAT POLLUTION — CLEANED

APK #190 still showed one old assistant response:

```text
I can assist with runtime verification. Please let me know what you'd like to verify or any details you have in mind.
```

Database audit identified the polluted verification rows as historical rows carrying:

```text
metadata.source      = runtime-p4a-001
metadata.persistence = P4A-005
```

Those historical verification rows were removed from the E2E SH.

Post-cleanup database check:

```text
verification Chat rows with source runtime-p4a-001 + P4A-005 = 0
```

Therefore the remaining APK #190 message was **historical persisted test data**, not proof that the current verification-only runtime path was still writing new Chat rows.

---

# 5. RECOVERY — CLEAN

For the E2E SH after cleanup:

```text
recovery_snapshots = 0
recovery_events    = 0
```

The previously observed phantom Recovery state is not present in the cleaned database.

Do not merge Recovery state into the Chat/Journey finding unless a fresh mutation is observed.

---

# 6. JOURNEY / OTHER — CLEAN EXCEPT VALID EVOLUTION

Previously observed verification/test pollution included:

```text
LIFECYCLE — SH runtime controlled verification
LEGACY    — APK #85 runtime-test artifact
```

Those records were removed.

Current relevant `runtime:p4d:journey_candidate` records include:

```text
EVOLUTION
  APK #175 replaced APK #85

EXPERIENCE
  APK #174 replaced APK #85

EXPERIENCE
  explicit transfer eligibility test
```

The `EVOLUTION` record is intentionally retained because it is a valid semantic Journey change.

Do not disable Evolution.
Do not treat every `runtime:p4d:journey_candidate` as junk.
Only verification/test artifacts should be isolated or cleaned.

---

# 7. VERIFICATION HARNESS / TEST CLEANUP

Relevant commits:

- `83f9625fb89be65e16aec514b97728b6bc845cb0` — isolate verification harness artifacts.
- `6f44808833f681559f2f6fd5c71047e5c8a372d2` — isolate runtime verification persistence.
- `3588cfc8bd64d042be5b1b305d667aaaf9c3e47d` — runtime invocation verification non-persistent.
- `8239f86c43bc2e840b72841e0e00284b079d73f4` — runtime streaming verification non-persistent.
- `4249a220bacb269afe57f316208b36970b14e218` — recovery roundtrip artifact cleanup.
- `1eaf16d3c8f2bc2e2e16e081e746fd340e1b4145` — recovery journey artifact cleanup.
- `31bea45c9cb828b4a436bd048a06682ae8838071` — install runtime verification dependency in CI.
- `33e450d6bb00ffd897d636e802ebe90500845492` — run runtime verification automatically on `dev` pushes.

The verification workflow is now a proper CI gate rather than an artifact-producing owner-chat test.

---

# 8. APK #190 REAL E2E CHECKPOINT

User-observed state on APK #190:

```text
New Conversation             clean / acceptable
Memory                       visible
Knowledge                    visible
Experience                   visible
Recovery                     clean
Journey Evolution            remains
Journey test pollution       identified and cleaned
Chat verification artifact  identified as historical and cleaned
```

No new APK is required merely for the historical DB cleanup.

---

# 9. CURRENT GATE BEFORE NEXT TEST

Before moving to another semantic/lifecycle test, recheck APK #190 after the DB cleanup:

### A — Chat

Reload/reopen Chat.

Expected:

```text
last real conversation may appear
old verification response must be gone
```

### B — Normal message

Send one ordinary message.

Expected:

```text
one user message
one SH response
no SH runtime verification message
no streaming verification message
```

### C — Recovery

Open Recovery.

Expected:

```text
no phantom snapshot
no phantom recovery event
```

### D — Journey / Other

Expected:

```text
valid Evolution may remain
verification LIFECYCLE/LEGACY junk must not return
```

Only after A–D are confirmed should the next semantic/lifecycle test begin.

---

# 10. SEPARATION RULE

Keep these dimensions separate:

```text
Chat history continuity
        ≠
verification persistence isolation
        ≠
Recovery snapshot lifecycle
        ≠
Journey semantic candidate recording
        ≠
Memory / Knowledge / Experience retrieval
```

A PASS in one dimension is not proof of another.

---

# 11. CURRENT PROJECT CHECKPOINT

```text
CI runtime verification                  🟢 PASS
Verification-only persistence isolation  🟢 PASS
Historical verification Chat cleanup     🟢 CLEAN
Recovery phantom artifacts               🟢 CLEAN
Journey verification pollution           🟢 CLEAN
Valid Evolution                           🟢 RETAINED
Memory                                    🟢 observed
Knowledge                                 🟢 observed
Experience                                🟢 observed

NEXT ACTION:
recheck APK #190 after DB cleanup
then continue with the next REAL E2E surface
```

Do not build a new APK solely because historical rows were cleaned. Build only if the next check demonstrates an actual code regression or a required FE change.
