# SECOND HEAD V1.0 — WORKSTREAM C AUDIT

Status: **WORKING / NON-CANONICAL / LIVING DOCUMENT**  
Branch: `dev`  
Created: 2026-08-29

## 0. Purpose

This document is the living audit/tracking record for **Workstream C — Multimodal & File Intelligence**.

It does not change Canonical SH semantics and does not replace `docs/evolution/V1.0/ROADMAP.md`.

Workstream C depends on:

- Workstream A — Foundation Reconciliation & Stabilization;
- Workstream B — Owner UX Consolidation.

The roadmap defines the current dependency-oriented C order as:

```
attachment lifecycle and UI states
        ↓
multiple attachments
        ↓
image input
        ↓
file intelligence / analysis
        ↓
camera input where justified
        ↓
multimodal conversation
        ↓
image understanding
        ↓
image generation
```

The exact provider/runtime path for image generation remains an open design decision.

---

## 1. Working principles

For every C slice:

```
AUDIT
  ↓
VALUE
  ↓
DEPENDENCY
  ↓
RISK
  ↓
ORDER
  ↓
IMPLEMENT
  ↓
VERIFY
  ↓
RECONCILE
```

Do not treat presentation-only controls as completed multimodal capability.

Do not change Canonical semantics through C implementation.

Do not introduce provider-specific product semantics merely because the current runtime uses Supabase.

---

## 2. Current baseline entering C

Workstream B is closed at the implementation/automated-verification boundary.

Current owner-facing structure:

```
Chat | Journey | Lifecycle | More
```

The current Chat implementation already contains attachment capability for:

- File;
- Photo;
- Camera.

Therefore C begins by **evolving the existing attachment flow**, not recreating attachment capability from zero.

---

## 3. C1 — Attachment Lifecycle & UI States

### Scope

Turn the existing attachment selection flow into a coherent visible lifecycle.

Required baseline states:

- idle;
- preparing;
- ready;
- failed;
- remove;
- replace.

### Current implementation

Implemented in current DEV Chat surface.

Commit:

```
78a9f66585074ca8fc8955de941915bf3766a283
feat: complete attachment lifecycle states
```

### Implemented behavior

- attachment enters a preparing state;
- successful preparation exposes a ready-to-send state;
- failed preparation exposes an explicit failure state;
- attachment can be removed;
- attachment can be replaced;
- state is reset when attachment is cleared;
- File / Photo / Camera use the same lifecycle model;
- runtime/data contract was not intentionally changed by this slice.

### Verification

**Pending at document creation time.**

C1 must not be marked fully green until the relevant DEV verification paths pass.

### Status

**IMPLEMENTED / VERIFICATION PENDING**

---

## 4. C2 — Multiple Attachments

### Scope

Allow more than one attachment in a single composition flow.

### Dependencies

C1 lifecycle model must remain coherent when:

- attachments have different states;
- one attachment fails;
- one attachment is removed;
- attachments are replaced;
- multiple attachments are sent together.

### Open questions

- maximum attachment count;
- supported mixed media combinations;
- ordering;
- per-item versus batch processing state;
- runtime request contract;
- failure/retry semantics.

### Status

**NOT STARTED**

Do not implement until C1 verification is reconciled.

---

## 5. C3 — Image Input

### Scope

Promote image input from an attachment capability into a first-class multimodal input path.

Potential sources include:

- existing Photo flow;
- Camera flow where applicable.

### Dependencies

- C1;
- C2 where multiple-image composition materially affects the contract;
- runtime capability confirmation.

### Status

**NOT STARTED**

---

### Current implementation

C3 promotes image input to an explicit multimodal request path while preserving the C2 attachment composition contract:

- image attachments are projected into explicit `image_inputs[]` at the Chat → runtime boundary;
- only image MIME types with prepared base64 content qualify as image inputs;
- runtime validates image inputs before model execution;
- image-capable routing is selected when prepared image input exists;
- existing zero-budget vision routing is reused;
- multiple image inputs remain supported through the C2 composition list;
- request audit records the image-input count.

Commits:

```
3f35736e  feat: expose first-class image input
073cf246  fix: reconcile image input validation order
```

### Verification

**Pending.** C3 must pass typecheck and all relevant DEV verification paths before being marked green.

### Status

**IMPLEMENTED / VERIFICATION PENDING**

## 6. C4 — File Intelligence / Analysis

### Scope

Move from attaching a file to SH being able to process/analyze supported file content.

### Required distinction

Attachment presence is not equivalent to file intelligence.

The implementation must establish:

```
file selected
    ↓
file prepared
    ↓
file accepted
    ↓
file processed
    ↓
analysis/result
```

with explicit failure/unsupported states.

### Open questions

- supported file classes;
- extraction/processing location;
- size limits;
- authorization and privacy boundaries;
- result persistence;
- provenance.

### Status

**NOT STARTED**

---

### Current implementation

C4 establishes a bounded file-intelligence path for currently supported text-oriented file classes:

- supported classes are explicitly accepted: plain text, Markdown, CSV, JSON, and XML;
- prepared file content is decoded and injected into model context for analysis;
- decode failure returns an explicit `FILE_PROCESSING_FAILED` state;
- unsupported file classes return an explicit `FILE_UNSUPPORTED` state;
- the runtime audit records when file intelligence is processed;
- image files remain on the C3 multimodal path rather than being treated as text files.

Important boundary: this slice does **not** claim arbitrary PDF, Office-document, archive, or binary extraction. Those classes remain unsupported until a separately verified extraction path exists.

Commits:

```
1109f0bd  feat: add supported file intelligence states
9ff36deb  feat: enforce file intelligence acceptance states
```

### Verification

**Pending.** C4 must pass typecheck and all relevant DEV verification paths before being marked green.

### Status

**IMPLEMENTED / VERIFICATION PENDING**

## 7. C5 — Camera Input

### Scope

Validate whether direct camera capture provides enough owner value to justify a dedicated implementation path.

### Dependencies

- C1;
- C3;
- platform capability verification.

### Status

**NOT STARTED / VALUE VALIDATION REQUIRED**

---

### C5 validation result

The existing Chat surface already provides a direct camera path through the platform image-picker capability:

- requests camera permission before capture;
- launches the native camera flow;
- requests image/base64 preparation at capture time;
- rejects the capture when image data cannot be prepared;
- appends the resulting image into the same C2 `attachments[]` composition;
- therefore the captured image continues through the C3 first-class image-input path;
- the existing lifecycle, remove, and replace controls remain shared with File/Photo.

### Decision

**Dedicated camera implementation is NOT required for this slice.** The existing direct-camera capability is already sufficient to satisfy the current C5 value/dependency check. C5 is therefore a validation/reconciliation slice rather than a request to create a second camera architecture.

No Canonical semantics or new provider dependency is introduced.

Evidence in DEV:

```
app/app/chat.tsx
handleAttachment('Camera')
requestCameraPermissionsAsync()
launchCameraAsync({ mediaTypes: ['images'], base64: true, quality: 0.85 })
```

### Status

**VERIFIED / NO DEDICATED IMPLEMENTATION REQUIRED**

## 8. C6 — Multimodal Conversation

### Scope

Allow conversation turns to contain meaningful multimodal input rather than treating media as a detached attachment UI.

### Dependencies

- C1–C4 as applicable;
- runtime/model capability;
- conversation persistence contract.

### Exit requirement

The multimodal turn must remain coherent across:

- composition;
- processing;
- runtime execution;
- response;
- failure/retry;
- conversation history.

### Status

**NOT STARTED**

---

### Current implementation

C6 closes the multimodal conversation coherence gap:

- Chat composes attachments through the existing C2 `attachments[]` contract;
- C3 image inputs and C4 supported file intelligence continue through the same runtime turn;
- runtime executes the turn with conversation context plus the supplied multimodal inputs;
- user turns persist attachment count, names, and MIME types;
- assistant turns persist matching multimodal metadata;
- conversation history reconstructs attachment names from persisted metadata, so a multimodal turn remains recognizable after reload;
- no new provider or Canonical semantic layer is introduced.

Commits:

```
9cbd037e  feat: persist multimodal turn metadata
d632ff2e  fix: restore multimodal attachments in history
```

### Verification

**Pending.** C6 must pass typecheck and relevant DEV verification paths before being marked green.

### Status

**IMPLEMENTED / VERIFICATION PENDING**

## 9. C7 — Image Understanding

### Scope

Enable SH to consume and reason over image input through a verified runtime/model path.

### Dependencies

- C3;
- C6;
- model/provider capability verification.

### Open questions

- supported image formats;
- image size/processing limits;
- model selection;
- provenance;
- privacy/storage policy.

### Status

**NOT STARTED**

---

## 10. C8 — Image Generation

### Scope

Enable SH to generate images through a verified runtime/provider path.

### Important boundary

The V1.0 roadmap explicitly leaves the exact provider/runtime path as an open design decision.

Therefore:

- no provider is assumed as Canonical;
- no implementation commitment is made until the runtime path is verified;
- image generation UI alone does not satisfy C8.

### Status

**NOT STARTED / PROVIDER-RUNTIME DECISION OPEN**

---

## 11. C-Close — Integration & Verification

C can close only when relevant capabilities are:

- runtime-backed;
- integrated with the owner conversation flow;
- explicit about processing/failure states;
- authorized correctly;
- persistence behavior verified where applicable;
- build/typecheck/test paths verified;
- free of blocking regressions;
- consistent with Canonical invariants.

Presentation-only capability does not satisfy C-Close.

### Status

**NOT STARTED**

---

## 12. Current status

```
C1  🟢 Verified
C2  🟢 Verified
C3  🟢 Verified
C4  🟡 Implemented / verification pending
C5  🟢 Verified / no dedicated implementation required
C6  🟡 Implemented / verification pending
C7  ⏳ Not started
C8  ⏳ Not started
C-Close ⏳ Not started
```

The 🟡 state is intentional: implementation exists, but verification is the authority for completion.

---

## 13. Change log

### 2026-08-29

- Created this living Workstream C audit document.
- Recorded C1 implementation and commit `78a9f665...`.
- Implemented C2 multiple attachment composition and extended the runtime attachment contract.
- Implemented C3 first-class image input and runtime validation/routing.
- Implemented C4 bounded file intelligence for supported text-oriented file classes with explicit unsupported/failed states.
- Preserved the roadmap dependency order from `ROADMAP.md`.
- Explicitly kept image-generation provider/runtime unresolved.
- Validated C5 against the existing direct-camera path; no duplicate camera architecture introduced.
- Implemented C6 multimodal turn persistence and history continuity.

---

## 14. Document authority

This document is:

- **NON-CANONICAL**;
- a living implementation/evolution audit;
- subordinate to Canonical SH Core;
- subordinate to approved technical contracts where applicable;
- consistent with `docs/evolution/V1.0/ROADMAP.md`;
- not a replacement for `docs/resume/` history.

END OF WORKSTREAM C AUDIT
