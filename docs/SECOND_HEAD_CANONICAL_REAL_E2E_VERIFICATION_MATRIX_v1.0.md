# SECOND HEAD — CANONICAL REAL E2E VERIFICATION MATRIX v1.0

**Status:** Active execution matrix  
**Branch:** `dev`  
**Runtime test vehicle:** APK #81  
**Backend:** Supabase DEV  
**Implementation source:** GitHub DEV  
**Purpose:** Canonical, persistent master matrix for REAL E2E functional verification through Functional Closure and UI/UX.

> TC-ID assignments are locked once established and must never be reused with a different meaning. This file is updated incrementally as domain verification progresses.

## Status Legend

- 🟢 PASS
- 🟡 IN PROGRESS
- 🔴 FAIL
- ⏳ NOT TESTED
- ⚠️ BLOCKED
- 🔵 EXPECTED / NOT A BUG

## Fix Disposition Legend

- `BE` — Backend / Supabase fix
- `FE` — Frontend / APK rebuild required
- `—` — Not yet determined

---

# 1. AUTH

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-AUTH-01 | Valid login → authenticated session | 🟢 | Runtime proven on APK #81. |
| TC-AUTH-02 | Invalid password → rejected | 🟢 | `Invalid login credentials` observed. |
| TC-AUTH-03 | Logout → login kembali | 🟢 | Runtime proven. |
| TC-AUTH-04 | Authenticated → force close → reopen | 🟢 | Session remained authenticated. |
| TC-AUTH-05 | Signed-out → force close → reopen | 🟢 | Login screen returned. |
| TC-AUTH-06 | Account identity consistency | 🟢 | Account `83c9f2a1-7617-471c-9c68-75e0003ea6ab` consistent. |
| TC-AUTH-07 | SH resolution consistency | 🟢 | SH instances remained `1`. |
| TC-AUTH-08 | Unauthorized / invalid session access | ⏳ | Not tested. |
| TC-AUTH-09 | Session expiration / invalidation handling | ⏳ | Not tested. |

# 2. ACCOUNT

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-ACCOUNT-01 | Authenticated account resolution | ⏳ | — |
| TC-ACCOUNT-02 | Account → primary SH resolution | ⏳ | — |
| TC-ACCOUNT-03 | Account consistency after logout/login | ⏳ | — |
| TC-ACCOUNT-04 | Account / SH isolation | ⏳ | — |
| TC-ACCOUNT-05 | Wrong-account object access | ⏳ | — |

# 3. HOME / NAVIGATION

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-HOME-01 | Home loads authenticated state | ⏳ | — |
| TC-HOME-02 | Home → Chat | ⏳ | — |
| TC-HOME-03 | Home → Journey | ⏳ | — |
| TC-HOME-04 | Home → Clone | ⏳ | — |
| TC-HOME-05 | Home → Recovery | ⏳ | — |
| TC-HOME-06 | Home → Inheritance | ⏳ | — |
| TC-HOME-07 | Home → Runtime Verification | ⏳ | — |
| TC-HOME-08 | Route exit/re-entry preserves auth context | ⏳ | — |

# 4. CHAT

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-CHAT-01 | Open authenticated SH Chat | ⏳ | — |
| TC-CHAT-02 | Send message → SH response | ⏳ | — |
| TC-CHAT-03 | Streaming lifecycle → completion | ⏳ | — |
| TC-CHAT-04 | Conversation persists after Chat exit/re-entry | ⏳ | — |
| TC-CHAT-05 | User message persists | ⏳ | — |
| TC-CHAT-06 | SH response persists | ⏳ | — |
| TC-CHAT-07 | Fresh response exposes Save Last Message | ⏳ | — |
| TC-CHAT-08 | Save Last Message → Journey | ⏳ | — |
| TC-CHAT-09 | Saved event actually persists in Journey | ⏳ | — |
| TC-CHAT-10 | Save button behavior after Chat re-entry | ⏳ | — |
| TC-CHAT-11 | Chat error handling | ⏳ | — |
| TC-CHAT-12 | Chat unauthorized runtime access | ⏳ | — |
| TC-CHAT-13 | Chat → Experience / Memory / Knowledge acquisition | ⏳ | — |
| TC-CHAT-14 | Retrieved acquired context usable through Chat | ⏳ | — |

# 5. JOURNEY

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-JOURNEY-01 | Open Journey for current SH | ⏳ | — |
| TC-JOURNEY-02 | Existing Journey events readable | ⏳ | — |
| TC-JOURNEY-03 | Chat explicit capture creates EXPERIENCE | ⏳ | — |
| TC-JOURNEY-04 | Correct event type = EXPERIENCE | ⏳ | — |
| TC-JOURNEY-05 | Correct source = runtime:p5a:explicit_user_capture | ⏳ | — |
| TC-JOURNEY-06 | Correct captured representation / payload | ⏳ | — |
| TC-JOURNEY-07 | Event persists after route exit/re-entry | ⏳ | — |
| TC-JOURNEY-08 | Experience lifecycle / read semantics | ⏳ | — |
| TC-JOURNEY-09 | Journey visibility semantics | ⏳ | — |
| TC-JOURNEY-10 | Private Journey event enforcement | ⏳ | — |
| TC-JOURNEY-11 | Non-transferable Journey event enforcement | ⏳ | — |
| TC-JOURNEY-12 | Invalid Journey operation rejected | ⏳ | — |
| TC-JOURNEY-13 | Journey → Memory relationship | ⏳ | — |
| TC-JOURNEY-14 | Journey → Knowledge relationship | ⏳ | — |

# 6. EXPERIENCE

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-EXP-01 | Create Experience through supported runtime path | ⏳ | — |
| TC-EXP-02 | Experience persistence | ⏳ | — |
| TC-EXP-03 | Experience payload integrity | ⏳ | — |
| TC-EXP-04 | Experience retrieval | ⏳ | — |
| TC-EXP-05 | Experience continuity semantics | ⏳ | — |
| TC-EXP-06 | Experience visibility | ⏳ | — |
| TC-EXP-07 | Experience transfer eligibility | ⏳ | — |
| TC-EXP-08 | Experience non-transferable enforcement | ⏳ | — |
| TC-EXP-09 | Experience unauthorized access | ⏳ | — |
| TC-EXP-10 | Experience usable by downstream Chat / context | ⏳ | — |

# 7. MEMORY

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-MEM-01 | Memory creation / acquisition through supported path | ⏳ | — |
| TC-MEM-02 | Memory persistence | ⏳ | — |
| TC-MEM-03 | Memory retrieval | ⏳ | — |
| TC-MEM-04 | Memory continuity | ⏳ | — |
| TC-MEM-05 | Memory visibility / privacy | ⏳ | — |
| TC-MEM-06 | Memory authorization | ⏳ | — |
| TC-MEM-07 | Memory transfer selection | ⏳ | — |
| TC-MEM-08 | Memory transfer enforcement | ⏳ | — |
| TC-MEM-09 | Memory usable through Chat / context | ⏳ | — |

# 8. KNOWLEDGE

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-KNOW-01 | Knowledge acquisition / creation | ⏳ | — |
| TC-KNOW-02 | Knowledge persistence | ⏳ | — |
| TC-KNOW-03 | Knowledge retrieval | ⏳ | — |
| TC-KNOW-04 | Knowledge continuity | ⏳ | — |
| TC-KNOW-05 | Knowledge visibility | ⏳ | — |
| TC-KNOW-06 | Knowledge authorization | ⏳ | — |
| TC-KNOW-07 | Knowledge transfer selection | ⏳ | — |
| TC-KNOW-08 | Knowledge transfer enforcement | ⏳ | — |
| TC-KNOW-09 | Knowledge usable through Chat / context | ⏳ | — |

# 9. CLONE

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-CLONE-01 | Clone screen / current implementation | ⏳ | — |
| TC-CLONE-02 | Create invitation | ⏳ | — |
| TC-CLONE-03 | Invitation persisted | ⏳ | — |
| TC-CLONE-04 | Recipient approval | ⏳ | — |
| TC-CLONE-05 | Recipient registration / session bootstrap | ⏳ | — |
| TC-CLONE-06 | Clone materialization | ⏳ | — |
| TC-CLONE-07 | Clone becomes recipient PRIMARY SH | ⏳ | — |
| TC-CLONE-08 | Correct transferable content | ⏳ | — |
| TC-CLONE-09 | Private content excluded | ⏳ | — |
| TC-CLONE-10 | Non-transferable content excluded | ⏳ | — |
| TC-CLONE-11 | Source / recipient isolation | ⏳ | — |
| TC-CLONE-12 | Unauthorized clone operation | ⏳ | — |
| TC-CLONE-13 | Current APK matches latest Clone contract | ⏳ | — |

# 10. RECOVERY

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-REC-01 | Recovery screen / current SH resolution | ⏳ | — |
| TC-REC-02 | Create new FULL snapshot | ⏳ | — |
| TC-REC-03 | Snapshot persists | ⏳ | — |
| TC-REC-04 | Snapshot contains expected domains | ⏳ | — |
| TC-REC-05 | Restore same SH | ⏳ | — |
| TC-REC-06 | Recovery event generated | ⏳ | — |
| TC-REC-07 | Continuity becomes RECOVERED | ⏳ | — |
| TC-REC-08 | Post-recovery Chat | ⏳ | — |
| TC-REC-09 | Post-recovery Journey | ⏳ | — |
| TC-REC-10 | Post-recovery Memory / Knowledge / Experience | ⏳ | — |
| TC-REC-11 | Unauthorized restore rejected | ⏳ | — |
| TC-REC-12 | JSON portability export | ⏳ | — |

# 11. INHERITANCE

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-INH-01 | Inheritance screen / current account | ⏳ | — |
| TC-INH-02 | Explicit Memory selection | ⏳ | — |
| TC-INH-03 | Explicit Knowledge selection | ⏳ | — |
| TC-INH-04 | Explicit Experience selection | ⏳ | — |
| TC-INH-05 | Explicit Journey selection | ⏳ | — |
| TC-INH-06 | Create authorization with selected scope | ⏳ | — |
| TC-INH-07 | Backend enforces selected scope | ⏳ | — |
| TC-INH-08 | Private events rejected | ⏳ | — |
| TC-INH-09 | Non-transferable events rejected | ⏳ | — |
| TC-INH-10 | No silent approximation of source-domain IDs | ⏳ | — |
| TC-INH-11 | Unauthorized inheritance rejected | ⏳ | — |

# 12. SUCCESSION

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-SUC-01 | Create succession rule | ⏳ | — |
| TC-SUC-02 | Explicit succession scope | ⏳ | — |
| TC-SUC-03 | Authorization enforcement | ⏳ | — |
| TC-SUC-04 | Successor resolution | ⏳ | — |
| TC-SUC-05 | Succession activation | ⏳ | — |
| TC-SUC-06 | Correct transferable content | ⏳ | — |
| TC-SUC-07 | Private exclusion | ⏳ | — |
| TC-SUC-08 | Non-transferable exclusion | ⏳ | — |
| TC-SUC-09 | Continuity / lifecycle event | ⏳ | — |
| TC-SUC-10 | Unauthorized succession | ⏳ | — |

# 13. END-OF-LIFE

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-EOL-01 | Enter EOL lifecycle condition | ⏳ | — |
| TC-EOL-02 | Correct state transition | ⏳ | — |
| TC-EOL-03 | Access after EOL | ⏳ | — |
| TC-EOL-04 | Transfer eligibility after EOL | ⏳ | — |
| TC-EOL-05 | Protected / private content remains protected | ⏳ | — |
| TC-EOL-06 | Journey lifecycle record | ⏳ | — |
| TC-EOL-07 | Unauthorized EOL action | ⏳ | — |

# 14. LEGACY

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-LEG-01 | Select transfer for Legacy | ⏳ | — |
| TC-LEG-02 | Preserve selected transfer as Legacy | ⏳ | — |
| TC-LEG-03 | Record Legacy type | ⏳ | — |
| TC-LEG-04 | Legacy persistence | ⏳ | — |
| TC-LEG-05 | Legacy visibility | ⏳ | — |
| TC-LEG-06 | Private / non-transferable exclusion | ⏳ | — |
| TC-LEG-07 | Unauthorized Legacy operation | ⏳ | — |

# 15. ERROR

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-ERR-01 | Invalid ID | ⏳ | — |
| TC-ERR-02 | Invalid lifecycle transition | ⏳ | — |
| TC-ERR-03 | Missing required scope | ⏳ | — |
| TC-ERR-04 | Backend rejection has no partial mutation | ⏳ | — |
| TC-ERR-05 | Frontend handles backend error correctly | ⏳ | — |
| TC-ERR-06 | Network / runtime failure handling | ⏳ | — |

# 16. AUTHORIZATION

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-AUTHZ-01 | Wrong account access | ⏳ | — |
| TC-AUTHZ-02 | Wrong SH access | ⏳ | — |
| TC-AUTHZ-03 | Private object access | ⏳ | — |
| TC-AUTHZ-04 | Non-transferable object access | ⏳ | — |
| TC-AUTHZ-05 | Unauthorized transfer | ⏳ | — |
| TC-AUTHZ-06 | Unauthorized recovery | ⏳ | — |
| TC-AUTHZ-07 | Unauthorized succession | ⏳ | — |
| TC-AUTHZ-08 | Unauthorized Legacy operation | ⏳ | — |

# 17. FUNCTIONAL CLOSURE GATE

| Gate | Status | Keterangan |
|---|---|---|
| All required domain TCs PASS | ⏳ | — |
| All known backend defects fixed | ⏳ | — |
| All required frontend defects rebuilt / retested | ⏳ | — |
| Negative authorization tests PASS | ⏳ | — |
| Cross-domain lifecycle tests PASS | ⏳ | — |
| No unresolved functional blockers | ⏳ | — |
| **FUNCTIONAL CLOSURE** | ⏳ | — |

# 18. UI / UX

| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-UI-01 | Login form / input presentation | ⏳ | — |
| TC-UI-02 | Password field presentation | ⏳ | — |
| TC-UI-03 | Chat input presentation | ⏳ | — |
| TC-UI-04 | Runtime input presentation | ⏳ | — |
| TC-UI-05 | Loading / streaming state | ⏳ | — |
| TC-UI-06 | Error presentation | ⏳ | — |
| TC-UI-07 | Empty states | ⏳ | — |
| TC-UI-08 | Navigation consistency | ⏳ | — |
| TC-UI-09 | Accessibility / basic affordances | ⏳ | — |
| TC-UI-10 | Final visual consistency | ⏳ | — |

---

# Global Execution Flow

```text
AUTH
  ↓
ACCOUNT
  ↓
HOME / NAVIGATION
  ↓
CHAT
  ↓
JOURNEY
  ↓
EXPERIENCE
  ↓
MEMORY
  ↓
KNOWLEDGE
  ↓
CROSS-DOMAIN CHAT / CONTEXT
  ↓
CLONE
  ↓
RECOVERY
  ↓
INHERITANCE
  ↓
SUCCESSION
  ↓
END-OF-LIFE
  ↓
LEGACY
  ↓
ERROR / AUTHORIZATION
  ↓
FUNCTIONAL CLOSURE
  ↓
UI / UX
  ↓
FINAL BUILD
```

# Execution Rules

1. TC-ID is permanent once assigned. Never reuse an existing TC-ID for a different test meaning.
2. New uncovered tests receive a new TC-ID appended to the relevant domain.
3. At least one domain-level progress update must update this file and create a new commit.
4. Backend / Supabase defects are fixed directly when technically safe and within DEV scope; then the affected TC is re-tested.
5. Frontend defects are marked `FE / BUILD APK REQUIRED` and are not marked PASS until a rebuilt APK is tested.
6. Existing data is not treated as proof of a new E2E operation unless the test explicitly defines it as read-only verification.
7. Expected behavior is recorded as `🔵 EXPECTED / NOT A BUG` with the reason.
8. Functional Closure remains unachieved until required functional domains and negative authorization paths are proven.
9. UI/UX is audited after Functional Closure unless a UI defect blocks functional verification.

# Current Test Vehicle / Environment
- APK: **#81**
- GitHub: **`savie/second-head` / `dev`**
- Supabase: **SECOND HEAD DEV**
- Current E2E phase: **REAL E2E FUNCTIONAL VERIFICATION**
