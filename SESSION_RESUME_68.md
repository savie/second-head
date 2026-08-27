# SESSION RESUME 68 — COMPLETE POST-FROZEN BUG AUDIT

## Project
SECOND HEAD — SYSTEM BUILD

## Audit basis
- Frozen final-gate baseline: `c44b2bc311baea5a46d0acb957049eb3c8307817`
- Frozen implementation candidate: `40a8772e3c79e17de77c7581048620286ff638a9`
- Frozen APK: #194
- APK SHA-256: `bc53e9ebfe6c3fc92ec1e675998cbd774a97b5f51184e51c95236b97eb6690d4`
- Audit continued through current DEV maintenance history after the freeze.
- Current DEV HEAD at this resume update: `5444e180cde293d1692958cef6efa9b0a2201802`

> Frozen baseline remains immutable. All items below are post-baseline maintenance history.

---

# BUG-001 — IMMEDIATE / SHORT-TERM CONVERSATIONAL RECALL

## Problem
Conversation messages were already persisted and visible in the UI, but the runtime model request did not receive recent conversation history.

Therefore SH could not reliably answer using immediately preceding conversation messages.

## Root cause
The missing link was:

```
conversation persistence
        ↓
runtime-owned retrieval
        ↓
active-SH scope
        ↓
bounded recent window
        ↓
conversation_context
        ↓
model request
```

Memory and Experience were separate persistence/context domains and were not supposed to become transcript storage.

## Fix
A runtime-owned conversation-context retrieval path was added using the existing `conversations` persistence.

The DB function bounds the recent window and verifies the requested `sh_id` against the authenticated active SH identity.

## Verification
Device verification demonstrated that SH could refer to prior conversation messages without relying on Memory or Experience.

## Status
**🟢 FIXED + DEVICE VERIFIED**

Relevant implementation started with Build #195 / migration:
`20260826050000_bug_001_short_term_conversation_context`

---

# BUG-002 — MEMORY PERSISTENCE POLICY / DUPLICATE PREVENTION

## Problem
Ordinary conversation could previously result in unwanted automatic Memory persistence.

The required behavior is:

```
ordinary conversation
        ↓
NO automatic Memory persistence

explicit "remember/save as Memory"
        ↓
Memory may be persisted

explicit opt-out
        ↓
hard boundary / do not persist
```

## Additional historical issue
Earlier implementation could create duplicate Memory records for repeated explicit saves.

Those historical duplicates are evidence/history and must not be deleted merely to make current state look clean.

## Fix / reconciliation
The persistence and deduplication behavior was corrected.

Current expected behavior:

- ordinary statement does not create Memory/Experience
- explicit Memory request creates Memory
- Memory recall works
- repeated explicit save against the same Memory does not create a new duplicate
- ordinary paraphrase does not create Memory
- retrieval does not create Memory

## Verification
These behaviors were verified on device.

## Status
**🟢 FIXED + VERIFIED**

Historical duplicate Memory records remain preserved as evidence.

---

# BUG-003 — MEMORY LISTING RESPONSE FORMATTING

## Problem
Memory retrieval itself was working, but a request to list all Memory one-per-line with blank lines produced concatenated output.

Observed pattern:

```
1. ...
2. ...3. ...
```

The underlying retrieval returned all expected Memory records, so this was not initially classified as a retrieval failure.

## Trace / diagnosis
The audit followed:

```
authorized_memory_context
        ↓
context assembly
        ↓
model request
        ↓
runtime SSE serialization
        ↓
natural-language response
```

Two relevant defects were addressed:

1. Explicit response-formatting instructions were not sufficiently enforced in the semantic model prompt.
2. Runtime SSE chunk handling could collapse/preserve line breaks incorrectly.

## Fixes
- Explicit formatting instructions are now passed as a hard response-formatting requirement.
- Runtime SSE handling was corrected to preserve newline characters.

Relevant commits include:

- `93bf3f8c3911592de9bc92deb7c6cb9d4938c018` — honor explicit response formatting instructions
- `945b659fd5e28ef48bc8130029f81d1b6f80d171` — preserve newlines in runtime SSE chunks

## Important distinction
The Memory inventory/retrieval itself was already passing:

- all Memory retrieval: PASS
- no new Memory during retrieval: PASS
- no new duplicate: PASS

The defect was response presentation/serialization.

## Status
**🟢 FIXED**

---

# BUG-004 — SYNCHRONIZED LIFECYCLE DELETION

## Scope
BUG-004 expanded from Memory-only deletion into synchronized lifecycle deletion for domains that actually have source-record deletion semantics:

- MEMORY
- KNOWLEDGE
- EXPERIENCE

Target principle:

```
delete from Journey
        ↕
delete source record
        ↓
Journey representation/event synchronized
```

Recovery/Evolution were not forced into delete semantics without implementation evidence.

## BUG-004A — Journey → Memory
PASS.

Tests included:
- single Memory deletion
- Memory with multiple Journey events

Results:
- source Memory removed
- associated Journey events removed
- refresh remained clean

## BUG-004B — Chat → Memory
Initial failure:
SH reported Memory deleted, but the source and Journey representation remained.

Root cause:
Chat deletion was not routed through the synchronized lifecycle deletion mechanism.

Fix:
Chat Memory deletion was routed through:

```
runtime_delete_record_with_journey(domain, record_id)
```

Final result:
**PASS**

## BUG-004C — Journey → Knowledge
PASS.

Important semantic distinction:

```
source domain = KNOWLEDGE
Journey representation = LEARNING
```

`LEARNING` does not mean the source became another domain.

## BUG-004D — Chat → Knowledge
Initial failure:
Chat Knowledge deletion did not reliably resolve the target source record.

Fix:
- Chat deletion routing added for Knowledge.
- Knowledge matching corrected.
- Explicit regression codes are prioritized for deterministic target resolution.
- Deletion uses the synchronized lifecycle mechanism.

Final result:
**PASS**

## BUG-004E — Journey → Experience
PASS.

Experience source and Journey representation are synchronized on deletion.

## BUG-004F — Chat → Experience
Initial failure:
Chat Experience deletion was not fully connected to synchronized lifecycle deletion.

Fix:
Chat Experience deletion routed through the common deletion path.

Final result:
**PASS**

## Final BUG-004 acceptance

```
Journey → Memory       PASS
Journey → Knowledge    PASS
Journey → Experience   PASS

Chat → Memory          PASS
Chat → Knowledge       PASS
Chat → Experience      PASS
```

Final E2E account cleanliness check was performed on:
`E2E_TEST@SH.COM`

Journey was clean of the tested Memory/Knowledge/Experience records. General Shared Experience records were not treated as private E2E leakage in the acceptance check.

## DB / provenance
BUG-004 uses the database lifecycle mechanism:

```
runtime_delete_record_with_journey(domain, record_id)
```

Relevant migration lineage includes:

- `20260827020203`
- `20260827074749_bug004_sync_journey_source_delete_v2`
- `20260827120000_bug004_synchronized_journey_source_delete`

Runtime fixes were committed to GitHub DEV and deployed to Supabase DEV from the corresponding DEV source.

## Status
**🟢 CLOSED / PASS**

---

# BUG-005 — CONVERSATION HISTORY

## Position
BUG-005 is the **next functional area after BUG-004**.

Do not confuse it with BUG-001.

### BUG-001
Short-term conversation context **inside the active conversation/runtime model context**.

### BUG-005
Persisted **Conversation History / conversation navigation and continuity as a product feature**.

The repository already contains a conversation-history implementation lineage, including authenticated history read/load and subsequent corrections to keep a newly created chat empty rather than hydrating account-wide history.

Relevant historical implementation commits include:

- `1483d14a896f0aeaf72d6360656c3e1a6e11649f` — authenticated conversation history read function
- `f25b9471e2b179e114b1b89fd3b7d32a38286c84` — authenticated conversation history read
- `70504ba8a0d9cc1ca7a6c61c6ed7b6c1a4d993e9` — authenticated conversation history loader
- `054a42c3997ec4d600829d7175dbfe740e292eb4` — load persisted conversation history on chat open
- `ab67a4148ab6a21ca2c488b54a554d7471564e18` — keep new chat empty; remove account-wide history hydration

## Required next audit

Before changing code:

1. Trace persisted conversation records.
2. Trace authenticated history read.
3. Trace history loader and chat-open behavior.
4. Trace active conversation vs newly created conversation.
5. Verify account/S H isolation.
6. Determine exact expected UX from current implementation and project contract.
7. Reproduce current behavior on `E2E_TEST@SH.COM`.
8. Only then classify the actual BUG-005 defect.
9. Fix minimally.
10. Commit + push DEV.
11. Deploy through the official path.
12. Verify CI.
13. Device-test.
14. Verify DB and UI.

**Do not invent a BUG-005 acceptance result before this audit.**

## Status
**🟡 NEXT / AUDIT REQUIRED**

---

# COMPLETE POST-FROZEN BUG CHAIN

```
Frozen v1.0
APK #194
c44b2bc...
        ↓
BUG-001
Immediate Conversational Recall
        ↓
FIXED + DEVICE VERIFIED

        ↓
BUG-002
Memory Persistence Policy
        ↓
FIXED + VERIFIED

        ↓
BUG-003
Memory Listing Response Formatting
        ↓
FIXED

        ↓
BUG-004
Synchronized Lifecycle Deletion
        ↓
CLOSED / PASS

        ↓
BUG-005
Conversation History
        ↓
NEXT / AUDIT REQUIRED
```

---

# CURRENT DEV / SUPABASE TRACEABILITY

GitHub DEV:
`savie/second-head`

Supabase DEV:
`pkhkgvsrqeupvwoqjwmd`

Frozen final-gate record:
`c44b2bc311baea5a46d0acb957049eb3c8307817`

Frozen implementation:
`40a8772e3c79e17de77c7581048620286ff638a9`

Frozen APK:
`#194`

Latest documented DEV commit before this resume update:
`5444e180cde293d1692958cef6efa9b0a2201802`

**Important:** `5444e18...` is the current documentation commit for this Resume 68 update; the next implementation commit must be based on the actual DEV HEAD, not assumed from an older resume.

---

# WORKING RULE

```
TRACE ACTUAL STATE
        ↓
COMPARE WITH CONTRACT
        ↓
IDENTIFY EXACT GAP
        ↓
MINIMAL FIX
        ↓
COMMIT + PUSH DEV
        ↓
DEPLOY
        ↓
CI GREEN
        ↓
DEVICE TEST
        ↓
DB + UI VERIFICATION
        ↓
CLOSE ONLY WITH EVIDENCE
```

Historical evidence must be preserved.
Frozen APK #194 must not be mutated.
No speculative migration.
No manual deletion of regression evidence.
GitHub DEV and Supabase DEV must remain provenance-consistent.

## NEXT ACTION

**BUG-005 Conversation History — audit first, implementation second.**

---
