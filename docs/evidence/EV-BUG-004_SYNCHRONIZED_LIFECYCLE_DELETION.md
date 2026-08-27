# EV-BUG-004 — SYNCHRONIZED LIFECYCLE DELETION

Status: **CLOSED / PASS**

## Scope
Synchronized deletion for source-record domains with Journey representations:

- MEMORY
- KNOWLEDGE
- EXPERIENCE

Recovery/Evolution were not forced into delete semantics without implementation evidence.

Target invariant:

`delete from Journey ↔ delete source record → Journey representation/event synchronized`

## Acceptance matrix

| Path | Result |
|---|---|
| Journey → Memory | PASS |
| Journey → Knowledge | PASS |
| Journey → Experience | PASS |
| Chat → Memory | PASS |
| Chat → Knowledge | PASS |
| Chat → Experience | PASS |

## Journey semantics
For Knowledge:

`source domain = KNOWLEDGE`

`Journey representation = LEARNING`

The Journey event type does not mean the source record changed domain.

## Defects and fixes

### Journey → Memory
Single Memory deletion and Memory with multiple Journey events both passed. Source Memory and associated Journey events were removed; refresh remained clean.

### Chat → Memory
Initial failure: Chat reported deletion while source and Journey representation remained.

Fix: Chat deletion routed through:

`runtime_delete_record_with_journey(domain, record_id)`

Final: PASS.

### Journey → Knowledge
PASS.

### Chat → Knowledge
Initial failure: target source record was not reliably resolved.

Fixes:
- Chat Knowledge deletion routing added;
- Knowledge matching corrected;
- deterministic regression resolution prioritized;
- synchronized lifecycle mechanism used.

Final: PASS.

### Journey → Experience
PASS.

### Chat → Experience
Initial failure: Chat Experience deletion was not fully connected to synchronized lifecycle deletion.

Fix: routed through the common deletion path.

Final: PASS.

## Database / provenance
Common lifecycle mechanism:

`runtime_delete_record_with_journey(domain, record_id)`

Recorded migrations:

- `20260827020203`
- `20260827074749_bug004_sync_journey_source_delete_v2`
- `20260827120000_bug004_synchronized_journey_source_delete`

Runtime fixes were committed to GitHub DEV and deployed to Supabase DEV from the corresponding DEV source.

## E2E acceptance
Account used:
`E2E_TEST@SH.COM`

Journey was clean for the tested Memory/Knowledge/Experience records. General Shared Experience was not treated as private E2E leakage.

## Regression APK
BUG-004 device regression used **APK #199**.

Source commit:
`393f7e770b6108f394410bd3885024ca686430e9`

Android workflow:
`33032370331` — success.

Artifact:
`sh-app-release-apk`, artifact ID `9630932207`.

Frozen APK #194 remained immutable and was not the active regression APK.

## Final
**🟢 CLOSED / PASS**
