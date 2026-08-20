# SECOND HEAD — CANONICAL REAL E2E VERIFICATION MATRIX v1.0

**Status:** Active execution matrix  
**Branch:** `dev`  
**Runtime test vehicle:** APK #150  
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
| TC-AUTH-06 | Account identity consistency | 🟢 | Account UUID consistent. |
| TC-AUTH-07 | SH resolution consistency | 🟢 | SH instances remained `1`. |
| TC-AUTH-08 | Unauthorized / invalid session access | ⏳ | Not tested. |
| TC-AUTH-09 | Session expiration / invalidation handling | ⏳ | Not tested. |

# 2. ACCOUNT
| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-ACCOUNT-01 | Authenticated account resolution | 🟢 | Account displayed correctly on Home. |
| TC-ACCOUNT-02 | Account → primary SH resolution | 🟢 | Home showed `SH instances: 1`. |
| TC-ACCOUNT-03 | Account consistency after logout/login | 🟢 | Same account UUID after re-login. |
| TC-ACCOUNT-04 | Account / SH isolation | ⏳ | Not tested against another account. |
| TC-ACCOUNT-05 | Wrong-account object access | ⏳ | Authorization test not yet run. |

# 3. HOME / NAVIGATION
| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-HOME-01 | Home loads authenticated state | 🟢 | Authenticated Home observed. |
| TC-HOME-02 | Home → Chat | 🟢 | Route reachable and Chat tested. |
| TC-HOME-03 | Home → Journey | 🟢 | Route reachable and Journey tested. |
| TC-HOME-04 | Home → Clone | 🟢 | Route reachable; functionality still unproven. |
| TC-HOME-05 | Home → Recovery | 🟢 | Route reachable; full controlled E2E still unproven. |
| TC-HOME-06 | Home → Inheritance | 🟢 | Route reachable; full lifecycle still unproven. |
| TC-HOME-07 | Home → Runtime Verification | 🟢 | Route reachable. |
| TC-HOME-08 | Route exit/re-entry preserves auth context | 🟢 | Tested across Chat/Journey/Clone/Recovery/Inheritance/Runtime. |

# 4. CHAT
| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-CHAT-01 | Open authenticated SH Chat | 🟢 | Runtime proven. |
| TC-CHAT-02 | Send message → SH response | 🟢 | Multiple messages received responses. |
| TC-CHAT-03 | Streaming lifecycle → completion | 🟢 | Active/streaming/idle behavior observed. |
| TC-CHAT-04 | Conversation persists after Chat exit/re-entry | 🟢 | Existing conversation remained after re-entry. |
| TC-CHAT-05 | User message persists | 🟢 | Test markers remained in conversation. |
| TC-CHAT-06 | SH response persists | 🟢 | Responses remained in conversation. |
| TC-CHAT-07 | Fresh response exposes Save Last Message | 🟢 | Button appeared after fresh response. |
| TC-CHAT-08 | Save Last Message → Journey | 🟢 | `Journey event saved.` observed. |
| TC-CHAT-09 | Saved event actually persists in Journey | 🟢 | EXPERIENCE event remained after leaving/re-entering Journey. |
| TC-CHAT-10 | Save button behavior after Chat re-entry | 🔵 | Button disappears after Chat re-entry because current last-message state is not restored; not a backend bug. |
| TC-CHAT-11 | Chat error handling | ⏳ | Not tested. |
| TC-CHAT-12 | Chat unauthorized runtime access | ⏳ | Not tested. |
| TC-CHAT-13 | Chat → Experience / Memory / Knowledge acquisition | ⏳ | Not tested; required later. |
| TC-CHAT-14 | Retrieved acquired context usable through Chat | ⏳ | Not tested; required later. |

# 5. JOURNEY
| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-JOURNEY-01 | Open Journey for current SH | 🟢 | Journey opened for current SH. |
| TC-JOURNEY-02 | Existing Journey events readable | 🟢 | Existing events displayed. |
| TC-JOURNEY-03 | Chat explicit capture creates EXPERIENCE | 🟢 | Explicit save created EXPERIENCE event. |
| TC-JOURNEY-04 | Correct event type = EXPERIENCE | 🟢 | Observed `EXPERIENCE`. |
| TC-JOURNEY-05 | Correct source = runtime:p5a:explicit_user_capture | 🟢 | Observed exact source. |
| TC-JOURNEY-06 | Correct captured representation / payload | 🟢 | Event creation and captured marker verified. |
| TC-JOURNEY-07 | Event persists after route exit/re-entry | 🟢 | EXPERIENCE remained after re-entry. |
| TC-JOURNEY-08 | Experience lifecycle / read semantics | 🟢 | EXPERIENCE row was readable and persisted after re-entry. |
| TC-JOURNEY-09 | Journey visibility semantics | 🟢 | Visibility/transfer policy controls are now available from Journey record detail; creation and policy-management path proven separately. |
| TC-JOURNEY-10 | Private Journey event enforcement | ⚠️ | BLOCKED — no dedicated private Journey fixture/path established. |
| TC-JOURNEY-11 | Non-transferable Journey event enforcement | ⚠️ | BLOCKED — no dedicated NON_TRANSFERABLE Journey fixture/path established. |
| TC-JOURNEY-12 | Invalid Journey operation rejected | ⏳ | Not yet tested. |
| TC-JOURNEY-13 | Journey → Memory relationship | 🟢 | Memory Journey event observed and persisted. |
| TC-JOURNEY-14 | Journey → Knowledge relationship | 🟢 | Knowledge Journey event observed. |

# 6. EXPERIENCE
| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-EXP-01 | Create Experience through supported runtime path | 🟢 | APK #150 creation path proven. |
| TC-EXP-02 | Experience persistence | 🟢 | Created Experience remained in Journey. |
| TC-EXP-03 | Experience payload integrity | 🟢 | Explicit capture marker/source observed. |
| TC-EXP-04 | Experience retrieval | 🟢 | Persisted Experience retrieved previously. |
| TC-EXP-05 | Experience continuity semantics | ⏳ | **Next target.** Prior cross-runtime retrieval evidence exists, but canonical continuity semantics are not yet fully satisfied. |
| TC-EXP-06 | Experience visibility | ⏳ | Not tested as a canonical TC. |
| TC-EXP-07 | Experience transfer eligibility | ⏳ | Not tested. |
| TC-EXP-08 | Experience non-transferable enforcement | ⏳ | Not tested. |
| TC-EXP-09 | Experience unauthorized access | ⏳ | Not tested. |
| TC-EXP-10 | Experience usable by downstream Chat / context | ⏳ | Not tested. |

# 7. MEMORY
| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-MEM-01 | Memory creation / acquisition through supported path | ⏳ | Not tested as canonical creation TC. |
| TC-MEM-02 | Memory persistence | ⏳ | Not tested. |
| TC-MEM-03 | Memory retrieval | ⏳ | Not tested. |
| TC-MEM-04 | Memory continuity | ⏳ | Not tested. |
| TC-MEM-05 | Memory visibility / privacy | ⏳ | Not tested. |
| TC-MEM-06 | Memory authorization | ⏳ | Not tested. |
| TC-MEM-07 | Memory transfer selection | 🟢 | APK #150: Memory selected in Inheritance checklist. |
| TC-MEM-08 | Memory transfer enforcement | ⏳ | Authorization creation succeeded; actual execution/enforcement not tested. |
| TC-MEM-09 | Memory usable through Chat / context | ⏳ | Not tested. |

# 8. KNOWLEDGE
| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-KNOW-01 | Knowledge acquisition / creation | ⏳ | Not tested. |
| TC-KNOW-02 | Knowledge persistence | ⏳ | Not tested. |
| TC-KNOW-03 | Knowledge retrieval | ⏳ | Not tested. |
| TC-KNOW-04 | Knowledge continuity | ⏳ | Not tested. |
| TC-KNOW-05 | Knowledge visibility | ⏳ | Not tested. |
| TC-KNOW-06 | Knowledge authorization | ⏳ | Not tested. |
| TC-KNOW-07 | Knowledge transfer selection | ⏳ | No Knowledge record was available in APK #150 Inheritance eligibility. |
| TC-KNOW-08 | Knowledge transfer enforcement | ⏳ | Not tested. |
| TC-KNOW-09 | Knowledge usable through Chat / context | ⏳ | Not tested. |

# 9. CLONE
| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-CLONE-01 | Clone screen / current implementation | 🟢 | Route/UI observed. |
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
| TC-CLONE-13 | Current APK matches latest Clone contract | ⏳ | Current Clone contract still requires later verification. |

# 10. RECOVERY
| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-REC-01 | Recovery screen / current SH resolution | 🟢 | Route and SH resolution observed. |
| TC-REC-02 | Create new FULL snapshot | ⏳ | Existing snapshots are historical data, not fresh-operation proof. |
| TC-REC-03 | Snapshot persists | ⏳ | — |
| TC-REC-04 | Snapshot contains expected domains | ⏳ | — |
| TC-REC-05 | Restore same SH | ⏳ | — |
| TC-REC-06 | Recovery event generated | ⏳ | Fresh operation not yet tested. |
| TC-REC-07 | Continuity becomes RECOVERED | ⏳ | Fresh operation not yet tested. |
| TC-REC-08 | Post-recovery Chat | ⏳ | — |
| TC-REC-09 | Post-recovery Journey | ⏳ | — |
| TC-REC-10 | Post-recovery Memory / Knowledge / Experience | ⏳ | — |
| TC-REC-11 | Unauthorized restore rejected | ⏳ | — |
| TC-REC-12 | JSON portability export | ⏳ | Fresh export not yet tested. |

# 11. INHERITANCE
| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-INH-01 | Inheritance screen / current account | 🟢 | Route/UI observed. |
| TC-INH-02 | Explicit Memory selection | 🟢 | APK #150: Memory checklist selected. |
| TC-INH-03 | Explicit Knowledge selection | ⏳ | No Knowledge record available for selection. |
| TC-INH-04 | Explicit Experience selection | ⏳ | No Experience record marked INHERITABLE. |
| TC-INH-05 | Explicit Journey selection | ⏳ | No transferable Journey record available. |
| TC-INH-06 | Create authorization with selected scope | 🟢 | APK #150 created authorization `dc8f020c-23ee-4711-a776-d2519477dd4c`, status `PENDING`, with selected scope containing the Memory ID. |
| TC-INH-07 | Backend enforces selected scope | ⏳ | Creation succeeded; execution/enforcement not yet tested. |
| TC-INH-08 | Private events rejected | ⏳ | Not tested; selected Memory was PRIVATE but INHERITABLE, which is explicitly eligible under the ratified policy semantics. |
| TC-INH-09 | Non-transferable events rejected | ⏳ | Not tested. |
| TC-INH-10 | No silent approximation of source-domain IDs | 🟢 | Authorization response preserved the selected Memory ID in `memory_ids`. |
| TC-INH-11 | Unauthorized inheritance rejected | ⏳ | Not tested. |

# 12. SUCCESSION
| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-SUC-01 | Create succession rule | 🟢 | APK #150 created rule `07cc54fb-48b1-49f7-a80a-6dd32f8eaba7` from one selected record. |
| TC-SUC-02 | Explicit succession scope | ⏳ | Creation with one selected record observed; canonical scope semantics not yet fully verified. |
| TC-SUC-03 | Authorization enforcement | ⏳ | Not tested. |
| TC-SUC-04 | Successor resolution | ⏳ | Not tested. |
| TC-SUC-05 | Succession activation | ⏳ | Not tested. |
| TC-SUC-06 | Correct transferable content | ⏳ | Not tested. |
| TC-SUC-07 | Private exclusion | ⏳ | Not tested. |
| TC-SUC-08 | Non-transferable exclusion | ⏳ | Not tested. |
| TC-SUC-09 | Continuity / lifecycle event | ⏳ | Not tested. |
| TC-SUC-10 | Unauthorized succession | ⏳ | Not tested. |

# 13. END-OF-LIFE
| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-EOL-01 | Enter EOL lifecycle condition | ⏳ | Not tested. |
| TC-EOL-02 | Correct state transition | ⏳ | Not tested. |
| TC-EOL-03 | Access after EOL | ⏳ | Not tested. |
| TC-EOL-04 | Transfer eligibility after EOL | ⏳ | Not tested. |
| TC-EOL-05 | Protected / private content remains protected | ⏳ | Not tested. |
| TC-EOL-06 | Journey lifecycle record | ⏳ | Not tested. |
| TC-EOL-07 | Unauthorized EOL action | ⏳ | Not tested. |

# 14. LEGACY
| TC-ID | Aktivitas / Test | Status | Fix / Keterangan |
|---|---|---|---|
| TC-LEG-01 | Select transfer for Legacy | 🟢 | APK #150 selected one record for Legacy preservation. |
| TC-LEG-02 | Preserve selected transfer as Legacy | 🟢 | APK #150: `Legacy preserved: 939b8387-29d3-4099-9caf-2947b91b24a8`. |
| TC-LEG-03 | Record Legacy type | ⏳ | Result ID created; explicit type verification not separately tested. |
| TC-LEG-04 | Legacy persistence | ⏳ | Not yet verified after reload. |
| TC-LEG-05 | Legacy visibility | ⏳ | Not yet verified after preservation in this run. |
| TC-LEG-06 | Private / non-transferable exclusion | ⏳ | Not tested. |
| TC-LEG-07 | Unauthorized Legacy operation | ⏳ | Not tested. |

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
| TC-AUTHZ-04 | Transfer scope enforcement | ⏳ | — |
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

# Global Execution Flow
```text
AUTH → ACCOUNT → HOME/NAV → CHAT → JOURNEY → EXPERIENCE → MEMORY → KNOWLEDGE
→ CROSS-DOMAIN CHAT/CONTEXT → CLONE → RECOVERY → INHERITANCE → SUCCESSION
→ END-OF-LIFE → LEGACY → ERROR/AUTHORIZATION → FUNCTIONAL CLOSURE → UI/UX → FINAL BUILD
```

# Execution Rules
1. TC-ID is permanent once assigned. Never reuse an existing TC-ID for a different test meaning.
2. New uncovered tests receive a new TC-ID appended to the relevant domain.
3. Real-user runtime evidence is required to mark functional behavior as PASS.
4. Existing historical database rows do not count as proof of a fresh mutation/operation.
5. If a required operation is unavailable in APK #81, record `⚠️ BLOCKED` rather than fabricating PASS/FAIL.
6. Deterministic backend defects are fixed in Supabase/BE when possible; frontend defects require APK rebuild/retest.
7. Update this same canonical file incrementally as verification progresses; do not create competing matrices.
8. Do not reopen settled semantics unless new evidence creates a concrete contradiction.
