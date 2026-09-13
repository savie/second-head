# SECOND HEAD — Domain Reconciliation Checkpoint — 2026-09-13

## Status

**WORKING — CURRENT CHECKPOINT / JOURNEY VERIFICATION RECONCILIATED**

This checkpoint supersedes stale status statements from the 2026-09-12 checkpoint where they conflict with later verified evidence. It is a working continuity record and does not modify Canonical or Approved Contract authority.

## Authority

```text
OWNER / USER DECISION
        ↓
CANONICAL
        ↓
APPROVED CONTRACT
        ↓
ARCHITECTURE / DESIGN
        ↓
CURRENT IMPLEMENTATION
        ↓
RUNTIME / DATABASE EVIDENCE
        ↓
DEVICE / E2E EVIDENCE
        ↓
HISTORICAL / dev_old
```

## Workspace

- GitHub repository: `savie/second-head`
- Active branch: `dev`
- Supabase DEV project: `pkhkgvsrqeupvwoqjwmd`

## Latest Journey verification evidence

Frontend CI #660 completed successfully for commit:

`6142ed8295fd9e6f7a09f806f986cca4b418f218`

CI steps verified:

- Analyze — PASS
- Test — PASS
- Build APK — PASS
- Verify APK signing identity — PASS
- Upload APK artifact — PASS

Device E2E using build #660 verified the complete Journey filter projection:

```text
Journey
 ├── All
 │    ├── Memory       PASS
 │    ├── Knowledge    PASS
 │    └── Experience   PASS
 │
 ├── Memory
 │    └── memory card       PASS
 │
 ├── Knowledge
 │    └── knowledge card    PASS
 │
 └── Experience
      └── experience card   PASS
```

## Journey classification reconciliation

### Knowledge

Knowledge capture produces a Journey event whose runtime event type is `LEARNING`.

The frontend now normalizes both `KNOWLEDGE` and `LEARNING` to the Journey UI type `Knowledge`.

Legacy local Journey items are also normalized so an already persisted `LEARNING` item is not permanently stranded outside the `Knowledge` filter.

### Experience

Experience persistence and Journey event persistence are present.

Historical Journey Experience events that lack `payload.content` are hydrated through the owner-scoped Experience retrieval boundary using the event's `experience_id`.

New Experience Journey events also carry `content` so future events do not require the historical hydration fallback.

No database migration or security-boundary bypass was introduced for this repair.

## Current Journey status

```text
Journey persistence                 VERIFIED
Journey backend retrieval           VERIFIED
Journey Context integration         VERIFIED
Journey FE hydration                VERIFIED
Journey local account isolation     VERIFIED
Knowledge classification            VERIFIED
Knowledge legacy normalization      VERIFIED
Experience persistence              VERIFIED
Experience Journey projection       VERIFIED
Experience historical hydration     VERIFIED
All filter                          VERIFIED (device)
Memory filter                      VERIFIED (device)
Knowledge filter                   VERIFIED (device)
Experience filter                  VERIFIED (device)
Frontend CI                        VERIFIED (#660)
Device E2E                         PASS (#660)
```

## Change lineage

```text
66bd0f9  fix(journey): map learning events to knowledge
5178c102 fix(journey): include experience content in journey event
8659ce43 fix(journey): hydrate experience event content
6142ed82 fix(journey): normalize legacy learning items
```

The effective verified Journey projection state is represented by commit `6142ed82...` and CI/device verification associated with it.

## Scope boundary

Closed Journey projection work must not be reopened without new evidence.

The following remain separate/open unless independently verified:

- attachment retry/idempotency;
- full Knowledge lifecycle semantics beyond the tested capture/projection path;
- full Experience lifecycle semantics beyond the tested capture/projection path;
- all Conversation CRUD E2E;
- full Recovery restore E2E;
- complete Lifecycle/Clone/Inheritance/Succession semantics;
- universal semantic correctness across every AI provider and every context domain.

## Next gate

Proceed only to a confirmed OPEN dependency from the master/domain inventory. Do not broaden scope merely because an adjacent concept exists.

This checkpoint is a continuity and reconciliation record only; it does not authorize implementation of the listed open items.
