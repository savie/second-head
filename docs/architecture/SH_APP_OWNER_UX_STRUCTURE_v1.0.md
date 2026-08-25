# SECOND HEAD — OWNER UX STRUCTURE v1.0

**Status:** DEV delivery design / non-canonical UX specification  
**Branch:** `dev`  
**Purpose:** Menyederhanakan surface Android SECOND HEAD agar owner dapat menggunakan SH tanpa harus memahami istilah teknis, UUID, RPC, atau struktur database.

> Dokumen ini tidak menggantikan Canonical Architecture, SH Core Canonical, Implementation Contract, atau REAL E2E Verification Matrix. Ia hanya menentukan cara capability yang sudah ada ditampilkan kepada owner.

---

## 1. Prinsip Utama

SECOND HEAD memiliki banyak domain teknis, tetapi domain teknis **tidak harus menjadi tombol utama**.

Canonical App Architecture menyatakan navigation awal bersifat capability-oriented, bukan table-oriented. Karena itu UI tidak boleh berubah menjadi daftar:

```text
AUTH
ACCOUNT
HOME/NAV
CHAT
JOURNEY
MEMORY
KNOWLEDGE
EXPERIENCE
CLONE
RECOVERY
INHERITANCE
SUCCESSION
END-OF-LIFE
LEGACY
ERROR
AUTHORIZATION
```

Daftar tersebut tetap berguna sebagai **arsitektur internal / verification map**, bukan sebagai menu owner.

---

## 2. Owner Home

```text
AUTH
└── Login / Sign up

MAIN — SECOND HEAD
├── Talk to SH
│   └── Chat
│
├── Continuity
│   └── Journey
│       └── tap event → detail / isi / status / visibility / transfer policy
│
├── SH Data
│   └── Experience
│       └── owner-scoped recorded Experience
│
├── Lifecycle & Transfer
│   ├── Clone
│   ├── Recovery
│   └── Inheritance / Succession / Legacy
│
└── Developer / Verification
    └── Runtime Verification

SYSTEM / CROSS-CUTTING
├── Error states
├── Authorization
└── End-of-Life
```

Error, Authorization, dan End-of-Life tidak menjadi tombol utama karena ketiganya merupakan state/rules/workflows yang muncul ketika capability terkait membutuhkannya.

---

## 3. Domain-to-UI Mapping

| Domain / verification area | Owner surface |
|---|---|
| AUTH | Login / session bootstrap |
| ACCOUNT | Identity card / account status |
| HOME / NAV | Main Home |
| CHAT | Talk to SH |
| JOURNEY | Continuity → Journey |
| EXPERIENCE | SH Data → Experience |
| MEMORY | Runtime/context; dedicated surface only when implemented |
| KNOWLEDGE | Runtime/context; dedicated surface only when implemented |
| CLONE | Lifecycle & Transfer → Clone |
| RECOVERY | Lifecycle & Transfer → Recovery |
| INHERITANCE | Lifecycle & Transfer → Inheritance / Succession / Legacy |
| SUCCESSION | Lifecycle & Transfer → Inheritance / Succession / Legacy |
| LEGACY | Lifecycle & Transfer → Inheritance / Succession / Legacy |
| END-OF-LIFE | Lifecycle state / guarded workflow, not a primary menu item |
| ERROR | Contextual error UI |
| AUTHORIZATION | Contextual confirmation / authorization UI |

No dead buttons should be added for a domain whose user-facing implementation does not yet exist.

---

## 4. Journey UX

Journey is a timeline, not a raw database table.

Each event card should show only the information needed for scanning:

```text
EXPERIENCE
19 Aug 2026, 22:45
CONTINUOUS
Source: explicit user capture
[View details]
```

When opened:

```text
Experience

What was recorded
APK #85 is the runtime test vehicle...

Status
Continuous

Visibility
Owner only

Transfer policy
Explicit only / actual backend value

Source
runtime:p5a:explicit_user_capture

[Close]
```

The UI may display technical fields when useful, but they must be presented with human-readable labels. UUIDs should not be the primary explanation of an event.

Journey detail must read the persisted event payload returned by the backend. It must not reconstruct event content from Chat state.

---

## 5. Experience UX

Experience is a real domain and therefore may have a dedicated data surface, but it should not duplicate the Journey timeline.

Journey answers:

> "Apa yang terjadi pada SH?"

Experience answers:

> "Pengalaman apa yang tersimpan dan dapat digunakan oleh SH?"

Therefore:

```text
Journey
  → event/history view

Experience
  → owner-scoped Experience records
  → retrieval / detail
```

The Home should not show both as unrelated duplicate buttons without explanation.

---

## 6. Memory and Knowledge

The current DEV App baseline does not yet contain complete dedicated Memory and Knowledge owner screens.

Therefore the UI must **not** add fake Memory / Knowledge buttons merely because the canonical verification matrix contains those domains.

Until dedicated surfaces are implemented, they remain available through the runtime/context behavior and are verified through the REAL E2E matrix.

When dedicated screens are later implemented, they should be grouped under `SH Data`, not promoted to the same visual level as Chat and Journey.

---

## 7. Lifecycle & Transfer

Clone, Recovery, Inheritance, Succession, and Legacy are related owner workflows and should be grouped rather than presented as a long list of technical buttons.

```text
Lifecycle & Transfer
│
├── Clone
│   └── create / approve / materialize
│
├── Recovery
│   └── snapshot / restore / portability
│
└── Inheritance / Succession / Legacy
    ├── inheritance authorization
    ├── succession rule
    └── legacy preservation
```

The backend remains authoritative for authorization, ownership, privacy, and execution.

---

## 8. Text Input Rule

Every editable field must provide:

1. visible label;
2. visible placeholder/example;
3. readable input text;
4. enough explanation to know what belongs in the field;
5. no requirement for the owner to infer meaning from a UUID or JSON structure.

Example:

```text
Source SH ID
The SH that owns the selected data.
[Enter Source SH ID]
```

For advanced JSON fields, the UI should eventually replace raw JSON entry with structured selection controls. Raw JSON is acceptable only as a transitional verification/developer surface.

---

## 9. Verification vs Owner UX

Developer/verification surfaces may expose:

- UUIDs;
- raw scope JSON;
- runtime states;
- technical source references;
- provider/runtime diagnostics.

Owner-facing surfaces should instead expose:

- human-readable labels;
- meaningful descriptions;
- confirmations;
- clear success/error messages;
- progressive disclosure for technical details.

The existence of a REAL E2E test path does not require the owner to see the test harness as the primary application navigation.

---

## 10. Current DEV Implementation Direction

The current Home implementation is being simplified toward this structure.

Current implemented owner-facing groups:

```text
SECOND HEAD
│
├── Your Second Head
│   ├── Account
│   └── SH instances
│
├── Talk to SH
│   └── Chat
│
├── Continuity
│   └── Journey
│
├── SH Data
│   └── Experience
│
├── Lifecycle & Transfer
│   ├── Clone
│   ├── Recovery
│   └── Inheritance / Succession / Legacy
│
└── Developer / Verification
    └── Runtime Verification
```

Journey events are now intended to be opened to see their recorded content and relevant lifecycle metadata.

---

## 11. Acceptance Direction

Before the next APK is treated as the owner-facing candidate, verify:

- no unexplained top-level technical buttons;
- no duplicate Journey/Experience presentation without purpose;
- Journey event detail is readable;
- text inputs are readable and self-explanatory;
- owner can understand where Chat, Journey, Experience, and lifecycle workflows live;
- technical verification remains accessible without dominating the owner UX;
- backend remains authoritative for identity, ownership, privacy, authorization, and lifecycle semantics.

END OF OWNER UX STRUCTURE v1.0
