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

### Current implementation

C7 is implemented on top of the verified C3/C6 multimodal path:

- image attachments with prepared base64 are promoted to the runtime vision capability;
- the runtime already sends image parts as `image_url` data URLs to an image-capable model;
- the vision candidate is zero-budget and has an explicit fallback;
- image-understanding language is now classified as the explicit `vision` task rather than relying only on generic conversation/reasoning classification;
- conversation and reasoning requests containing images continue to use the same vision-capable path;
- no image is persisted or interpreted as Canonical memory merely because it was analyzed.

Commit:

```
68f771b8  feat: make image understanding task explicit
```

### Verification

**Pending.** C7 must pass typecheck and relevant DEV verification paths before being marked green.

### Status

**IMPLEMENTED / VERIFICATION PENDING**

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

### C8 provider/runtime audit & decision

The provider/runtime decision is now resolved for the V1.0 implementation path.

**Selected path: OpenRouter Unified Image API** using the same `OPENROUTER_API_KEY` already used by the verified text/vision runtime, but through the dedicated `POST /api/v1/images` endpoint rather than Chat Completions. OpenRouter documents this as its unified image-generation interface, with model discovery, capability metadata, provider routing/failover, and base64 image output. citeturn0search0turn0search2

This is an implementation choice, not a Canonical provider lock.

**Budget boundary:** OpenRouter currently has no free image-generation model; image generation consumes credit balance. Therefore C8 is **explicitly gated** behind `SH_IMAGE_GENERATION_ENABLED=true`; it is not silently added to SH's zero-budget automatic model pool. citeturn0search2

**Initial model default:** `recraft/recraft-v3`, selected as a low-cost, image-generation-capable model with text/image input support. The model remains configurable through `SH_IMAGE_MODEL`, so changing the model does not require changing the runtime architecture. citeturn0search10

Implementation:

- dedicated image-generation adapter;
- explicit paid-capability gate;
- configurable model selection;
- dedicated OpenRouter Image API request;
- generated image returned as base64 + media type in runtime metadata;
- existing zero-budget text/vision routing remains untouched.

Commits:

```
5afd8fa1  feat: add gated image generation provider path
d9011b0d  fix: expose generated image result metadata
dfb5b47c  feat: expose generated image runtime result
```

**Important remaining integration boundary:** the current slice proves the provider/runtime path and exposes the generated asset through runtime metadata. It does not yet claim owner-facing image rendering/storage lifecycle is complete. That must be verified before C8 is green.

### Status

**IMPLEMENTED / PROVIDER PATH SELECTED / VERIFICATION PENDING**

## 11. C-Close — Integration & Verification

### Closure audit

All eight planned C slices have now been implemented and reported GREEN through the DEV verification evidence supplied during this workstream. The closing review confirms:

- **C1–C4:** attachment, multi-attachment, image-input, and bounded file-intelligence paths are runtime-backed and integrated into the existing Chat composition flow.
- **C5:** direct camera capture is reused rather than creating a duplicate camera architecture.
- **C6:** multimodal turns persist enough attachment metadata for history continuity.
- **C7:** image understanding uses the verified vision path and remains separate from Canonical memory semantics.
- **C8:** image generation has a dedicated provider/runtime path, an explicit paid gate, and configurable model selection; it is not part of zero-budget automatic routing.
- No C slice intentionally introduces a new Canonical semantic layer or changes SH Core semantics.
- Unsupported file classes remain explicitly bounded rather than being represented as generic file intelligence.
- The provider/model selection idea remains a future architecture candidate; C8's configurable image model is not a general runtime model registry.

### Remaining boundary / non-blocking follow-up

C-Close does **not** promote unimplemented ideas into scope. The following remain outside C closure:

- arbitrary PDF/Office/archive/binary extraction;
- voice/audio;
- broad plugins/integrations;
- full offline/local-first runtime;
- official web client;
- general provider/database switching;
- general runtime-configurable provider/model registry.

These are explicitly outside the current C closure and belong to future roadmap/evolution decisions if approved.

### Closure decision

**WORKSTREAM C CLOSED — V1.0 IMPLEMENTATION/VERIFICATION BOUNDARY**

C is closed at the implementation/verification boundary, not as a claim that every future multimodal idea is complete.

### Status

**CLOSED / VERIFIED**

---

## 12. Current status

```
C1  🟢 Verified
C2  🟢 Verified
C3  🟢 Verified
C4  🟢 Verified
C5  🟢 Verified / no dedicated implementation required
C6  🟢 Verified
C7  🟢 Verified
C8  🟢 Verified / provider path selected
C-Close 🟢 Closed / Verified
```

C4 and C8 are now recorded GREEN based on the DEV verification results supplied after implementation. C-Close remains the final integration gate.

---

## 13. Change log

### 2026-08-29

- Created this living Workstream C audit document.
- Recorded C1 implementation and commit `78a9f665...`.
- Implemented C2 multiple attachment composition and extended the runtime attachment contract.
- Implemented C3 first-class image input and runtime validation/routing.
- Implemented C4 bounded file intelligence for supported text-oriented file classes with explicit unsupported/failed states.
- Preserved the roadmap dependency order from `ROADMAP.md`.
- Resolved C8 provider/runtime to the OpenRouter Unified Image API with an explicit paid-capability gate.
- Kept the provider choice implementation-level, not Canonical.
- Validated C5 against the existing direct-camera path; no duplicate camera architecture introduced.
- Implemented C6 multimodal turn persistence and history continuity.
- Implemented C7 explicit image-understanding task classification on the existing vision runtime path.
- Closed Workstream C at the V1.0 implementation/verification boundary after C1–C8 were reported GREEN.

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


## CURRENT DEV VERIFICATION — 2026-08-29

Current DEV head at reconciliation: `c02e918d02062c4951ab296a28c2395afedf9f32`.

Automated verification on the current DEV line is GREEN. This is recorded as **CI VERIFIED** evidence only. It does not silently upgrade any separately required manual/device/runtime acceptance gate.

The workstream's existing closure/status sections remain historical/source-specific and are not rewritten solely from CI status. Where a manual APK/device/runtime proof is explicitly pending in this document, that gate remains pending.
