# SECOND HEAD — SESSION RESUME 51

## Continuation point

Resume 51 is refreshed after the runtime-verification isolation work and the subsequent correction of an overly broad historical Chat cleanup.

Primary evidence:
`docs/evidence/EV-P6E-010_RUNTIME_VERIFICATION_PERSISTENCE_ISOLATION_RECONCILIATION_2026-08-23.md`

Latest documentation commit:
`3902fe171fad26c9c7bcdf95e33ebbf47e03acc5`

Branch: `dev`
Repository: `savie/second-head`

---

# 1. AUTHORITY / WORKING ORDER

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

Actual CI output remains authoritative.

Keep these dimensions separate:

```text
Chat history continuity
≠ verification persistence isolation
≠ Recovery lifecycle
≠ Journey semantic recording
≠ Memory / Knowledge / Experience retrieval
```

---

# 2. RUNTIME VERIFICATION ISOLATION — PASS

GitHub Actions:

```text
SH Runtime Controlled Verification #3
commit: 33e450d
status: PASS
```

Passed checks included:

```text
authenticated session obtained
runtime-p4a-001 accepts authenticated request
runtime resolves SH identity
runtime response contract valid
verification-only persistence isolation is active
bounded Memory/Knowledge context assembly
Journey retrieval bounded to authenticated SH and RLS
logout succeeds
```

Context counts reported by CI:

```text
Memory    = 5
Knowledge = 0
Journey   = 10
```

Conclusion:

```text
current verification-only runtime path is isolated
```

---

# 3. CHAT HISTORY — IMPORTANT CURRENT STATE

Desired product behavior remains:

```text
Open Chat
   ↓
recent real conversation may appear
   ↓
verification/test artifacts must not appear
```

Relevant FE commits:

- `1e077ab018c0b916e5b52be959f5435bf0ed41ed` — restore filtered recent chat continuity.
- `47e5e22e9ad66fc2c2449cff370d5eb1546c2b5d` — expose primary SH id for chat history.

APK #190 showed one remaining verification response:

```text
I can assist with runtime verification. Please let me know what you'd like to verify or any details you have in mind.
```

Database audit showed this belonged to historical rows with:

```text
metadata.source      = runtime-p4a-001
metadata.persistence = P4A-005
```

---

# 4. CLEANUP-SCOPE CORRECTION — OPEN

A cleanup query intended to remove historical verification artifacts used the metadata pair above.

The predicate was too broad and removed **all `public.conversations` rows carrying that historical P4A-005 metadata**, not only the visible verification artifact.

The E2E SH's conversation table now returns:

```text
0 rows
```

Therefore:

```text
verification junk              = cleaned
historical Chat continuity      = currently empty
Chat continuity PASS            = NOT YET
```

This is a cleanup-scope error and must not be misreported as a runtime isolation failure.

No Memory, Knowledge, Experience, Journey, Recovery, or Auth data was removed by that conversation cleanup query.

Do not claim the previous Chat history is preserved until an authoritative restoration/reconstruction path is established.

---

# 5. RECOVERY — CLEAN

Current E2E SH database state:

```text
recovery_snapshots = 0
recovery_events    = 0
```

No phantom Recovery artifact remains.

---

# 6. JOURNEY / OTHER — CLEAN EXCEPT VALID EVOLUTION

Historical test pollution removed:

```text
LIFECYCLE — SH runtime controlled verification
LEGACY    — APK #85 runtime-test artifact
```

Valid Journey records retained:

```text
EVOLUTION
  APK #175 replaced APK #85

EXPERIENCE
  APK #174 replaced APK #85

EXPERIENCE
  explicit transfer eligibility test
```

Do not disable Evolution.
Do not treat every `runtime:p4d:journey_candidate` as junk.
Only verification/test artifacts should be isolated or cleaned.

---

# 7. RELEVANT IMPLEMENTATION / CI COMMITS

Runtime/test isolation:

- `83f9625fb89be65e16aec514b97728b6bc845cb0`
- `6f44808833f681559f2f6fd5c71047e5c8a372d2`
- `3588cfc8bd64d042be5b1b305d667aaaf9c3e47d`
- `8239f86c43bc2e840b72841e0e00284b079d73f4`
- `4249a220bacb269afe57f316208b36970b14e218`
- `1eaf16d3c8f2bc2e2e16e081e746fd340e1b4145`

CI:

- `31bea45c9cb828b4a436bd048a06682ae8838071` — install verification dependency.
- `33e450d6bb00ffd897d636e802ebe90500845492` — run runtime verification on `dev` push.

---

# 8. APK #190 CHECKPOINT

Before the broad cleanup, user observed:

```text
New Conversation             clean / acceptable
Memory                       visible
Knowledge                    visible
Experience                   visible
Recovery                     clean
Journey Evolution            visible / valid
Journey verification junk   identified
Chat verification artifact  identified as historical
```

After cleanup:

```text
verification Chat junk      gone
Recovery junk               gone
Journey junk                gone
valid Evolution             retained
Chat history                currently empty
```

No new APK should be built solely for the cleanup itself.

---

# 9. NEXT ACTION — DO NOT TEST OTHER SURFACES YET

First resolve the Chat continuity consequence.

Preferred order:

```text
1. Establish authoritative recovery/reconstruction source for the deleted historical Chat rows.
2. Restore/reconstruct only authoritative recent owner Chat history.
3. Keep verification-only isolation active.
4. Reload APK #190.
5. Confirm real recent chat appears without verification junk.
6. Send one normal message.
7. Confirm no self-generated verification/streaming message.
8. Recheck Recovery and Journey/Other.
```

Only after this gate passes should the next semantic/lifecycle E2E surface continue.

---

# 10. CURRENT STATUS

```text
CI runtime verification                  🟢 PASS
Verification-only persistence isolation  🟢 PASS
Historical Recovery pollution            🟢 CLEAN
Historical Journey pollution              🟢 CLEAN
Valid Evolution                            🟢 RETAINED
Historical verification Chat junk         🟢 CLEAN
Chat history continuity                    🔴 OPEN — cleanup scope correction

NEXT:
resolve/reconstruct Chat history before further E2E testing
```
