# SECOND HEAD — Full Semantic Lifecycle Verification — 2026-09-13

## Status

**WORKING — HASIL VERIFIKASI / PARTIAL PASS / FULL LIFECYCLE BELUM DITUTUP**

Dokumen ini mencatat hasil verifikasi siklus hidup semantik saat ini pada Memory, Knowledge, Experience, Journey, serta batas kebijakan lifecycle. Dokumen ini tidak mengubah otoritas Canonical atau Approved Contract.

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
```

## Scope

Memverifikasi rantai end-to-end semantik saat ini:

```text
User / Model signal
    ↓
Semantic decision
    ↓
Domain persistence
    ↓
Journey projection
    ↓
Lifecycle / policy metadata
    ↓
Retrieval / transfer eligibility boundary
```

Verifikasi secara eksplisit mencakup Journey karena Journey merupakan batas continuity/projection dan membawa metadata visibility/transfer yang berkaitan dengan lifecycle.

## Evidence

### 1. Explicit user capture

DEV saat ini memiliki record positif yang dihasilkan oleh `ai-runtime:explicit-user-request`:

- Memory: 1 record
- Knowledge: 1 record
- Experience: 1 record
- Journey: 3 event terkait

Record Knowledge dan Experience berkorelasi dengan user message yang tersimpan dan runtime request ID melalui path Conversation/runtime.

### 2. Current semantic record state

Untuk SH yang diuji:

| Domain | Lifecycle | Scope | Visibility | Transfer policy | Source |
|---|---|---|---|---|---|
| Memory | CANDIDATE | PRIVATE | OWNER_ONLY | NON_TRANSFERABLE | ai-runtime:explicit-user-request |
| Knowledge | CANDIDATE | PRIVATE | OWNER_ONLY | NON_TRANSFERABLE | ai-runtime:explicit-user-request |
| Experience | ACTIVE | PRIVATE | OWNER_ONLY | NON_TRANSFERABLE | ai-runtime:explicit-user-request |

Hal ini membuktikan persistence dan metadata policy memang ada, tetapi belum dengan sendirinya membuktikan keseluruhan model transition lifecycle.

### 3. Journey projection

Event Journey pada DEV saat ini:

| Event | Domain reference | Continuity | Visibility | Transfer policy |
|---|---|---|---|---|
| MEMORY | memory_id present | CONTINUOUS | PRIVATE | NON_TRANSFERABLE |
| LEARNING | knowledge_id present | CONTINUOUS | PRIVATE | NON_TRANSFERABLE |
| EXPERIENCE | experience_id present | CONTINUOUS | PRIVATE | NON_TRANSFERABLE |

Dengan demikian Journey memiliki referensi deterministik kembali ke record domain semantik untuk path capture yang diuji.

### 4. Journey policy boundary

Function runtime saat ini `runtime_get_journey_record_policy(event_id)` hanya me-resolve event jika event tersebut dimiliki oleh active SH pada account saat ini, kemudian me-resolve domain record dan mengembalikan scope, visibility, serta transfer policy.

`runtime_classify_journey_event()` saat ini menegakkan authenticated ownership dan memvalidasi vocabulary visibility/transfer-policy Journey.

Implementasi transfer saat ini membutuhkan otorisasi yang sesuai lifecycle dan menolak selection yang private, non-transferable, atau tidak kompatibel dengan policy lifecycle yang diwajibkan.

### 5. Lifecycle policy boundary

Vocabulary policy saat ini untuk semantic record adalah:

```text
NON_TRANSFERABLE
INHERITANCE
SUCCESSION
LEGACY
```

`INHERITABLE` dinormalisasi menjadi `INHERITANCE` oleh policy function saat ini.

Safeguard lifecycle yang saat ini teramati mencakup:

- SH yang deactivated/terminal tidak dapat memutasi record policy;
- record hasil inheritance tidak dapat policy-nya ditulis ulang oleh target SH;
- Succession membutuhkan source SH yang end-of-life/deactivated dan succession rule yang aktif;
- Inheritance membutuhkan inheritance authorization yang disetujui;
- transfer Journey membutuhkan pemilihan event secara eksplisit dan lifecycle eligibility yang sesuai;
- record Journey yang ditransfer dimaterialisasi sebagai PRIVATE / NON_TRANSFERABLE pada target dan tetap menyimpan provenance source.

## Verification Matrix

| Claim | Evidence | Result |
|---|---|---|
| Explicit Knowledge capture persists | DEV Knowledge row + runtime audit + user message correlation | PASS |
| Explicit Experience capture persists | DEV Experience row + runtime audit + user message correlation | PASS |
| Semantic capture projects to Journey | Knowledge/Experience/Memory Journey events reference domain IDs | PASS |
| Journey continuity is preserved | All tested semantic events are CONTINUOUS | PASS |
| Journey policy can be resolved through domain boundary | `runtime_get_journey_record_policy()` implementation + active DB definition | PASS (static/runtime-state verification) |
| Journey classification enforces owner/auth boundary | `runtime_classify_journey_event()` active DB definition | PASS (static verification) |
| Lifecycle transfer policy is enforced | active `runtime_transfer_selected_journey_events()` definition | PASS (static verification) |
| Model-derived semantic signal is persisted according to decision | Current runtime records signals/decisions but marks persistence `not_performed` | **NOT CLOSED** |
| Candidate → active/review lifecycle is fully verified for all domains | Current positive evidence does not cover complete transition matrix | **OPEN** |
| Full Knowledge lifecycle semantics | Capture/projection verified only | **OPEN** |
| Full Experience lifecycle semantics | Capture/projection verified only | **OPEN** |
| Full Journey + Clone/Inheritance/Succession execution E2E | Source/policy boundary exists, execution harness evidence incomplete | **OPEN** |

## Critical Finding

Runtime saat ini memiliki dua jalur semantik yang berbeda:

### Explicit user path

```text
explicit user request
    ↓
recordExplicitSemanticLifecycle()
    ↓
Memory / Knowledge / Experience persistence
    ↓
Journey projection
```

Jalur ini telah diverifikasi untuk bukti capture/projection positif.

### Model-derived signal path

```text
provider output
    ↓
<semantic_signals>
    ↓
signals()
    ↓
evaluateSemanticSignal()
    ↓
RUNTIME_MEMORY_DECISION audit
    ↓
persistence = not_performed
```

`semantic_decision.ts` saat ini secara eksplisit memperlakukan output model sebagai candidate dan menjaga otoritas persistence tetap berada di luar fungsi decision. Karena itu persistence semantik yang berasal dari model **belum terbukti** oleh implementasi saat ini.

Temuan ini merupakan batas implementasi, bukan izin untuk mendesain ulang semantics dalam pass verifikasi ini.

## Decision

**Full Semantic Lifecycle Verification: PARTIAL PASS — NOT CLOSED.**

Sudah ditutup untuk scope yang saat ini diuji:

```text
Explicit semantic capture
Knowledge persistence
Experience persistence
Memory tested persistence
Journey projection
Journey continuity
Journey policy metadata
Journey retrieval policy boundary
Lifecycle transfer-policy validation (static)
```

Masih terbuka:

```text
Model-derived signal → policy decision → persistence
Candidate → Active / Confirm / Reject lifecycle transitions
Full Knowledge lifecycle
Full Experience lifecycle
Journey Clone / Inheritance / Succession execution E2E
Security/succession semantic harness
```

## Scope Boundary

Tidak ada database migration, perubahan Canonical, atau speculative semantic redesign yang diperkenalkan oleh verifikasi ini.

Jika diminta membuat keputusan implementasi berikutnya, terlebih dahulu harus didefinisikan approved contract untuk model-derived persistence dan transition matrix lifecycle sebelum menambahkan perilaku runtime.

## Verification Principle

```text
DB state proves state.
Runtime audit proves execution path.
Journey correlation proves projection linkage.
Policy function inspection proves enforcement logic exists.
Only authenticated execution E2E can close the full security/lifecycle claim.
```
