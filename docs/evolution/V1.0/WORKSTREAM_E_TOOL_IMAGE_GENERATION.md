# SECOND HEAD V1.0 — WORKSTREAM E TOOL — R5 IMAGE GENERATION

Status: **IMPLEMENTED / CI VERIFICATION PENDING**
Date: 2026-08-29
Branch: dev

## 1. Position

R5 is the selected representative Tool / model capability for:

- Family: D — Creation & Generation
- Candidate: D.1 Image Generation
- Selection: R5
- Role: create a new visual artifact from an owner request
- Strategy: REUSE / ADAPT the existing SH Runtime model-capability boundary

R5 completes a materially different capability from R3:

> R3 processes an existing supplied artifact; R5 creates a new artifact.

## 2. Why R5

R1 tests governed search.
R2 tests authorized retrieval.
R3 tests bounded artifact processing.
R4 tests governed external state mutation.
R5 tests bounded artifact creation through an image-capable model provider.

R5 is intentionally one narrow generation slice. It does not establish a generic media platform, asset manager, image editor, gallery, or multi-provider abstraction.

## 3. Basic Flow

OWNER REQUEST
→ SH Runtime identity/context
→ image capability selection
→ zero-budget image provider
→ generated image
→ normalized runtime result
→ chat presentation
→ audit / conversation evidence

The provider is a capability dependency. It does not become SH identity, authority, or system instruction.

## 4. Current DEV Implementation

The existing runtime-p4a-001 model boundary already contains an image capability and an OpenRouter image adapter.

R5 activates the bounded zero-budget path using:

recraft/recraft-v3:free

The paid path remains explicitly opt-in through SH_IMAGE_GENERATION_ALLOW_PAID=true; R5 does not require paid generation.

The runtime returns the generated image as bounded base64 image data and the chat runtime carries the generated image through the response event for presentation.

## 5. Boundary

IN:
- authenticated SH runtime request;
- one generation prompt;
- one bounded generated image;
- provider/model capability selection;
- normalized image result;
- chat presentation;
- audit/conversation trace through existing runtime infrastructure.

OUT:
- generic image editor;
- image gallery/asset-management platform;
- arbitrary external image provider credentials;
- automatic publishing/sharing;
- external storage authority;
- multi-image workflow;
- autonomous generation loops;
- generic media pipeline;
- paid generation by default.

## 6. Zero-Budget Constraint

R5 uses a free image endpoint as the default so the representative capability does not require a paid provider.

The current DEV implementation treats image selection as ZERO_BUDGET and rejects a non-:free image model unless paid generation is explicitly enabled.

OpenRouter currently documents recraft/recraft-v3:free as a free image-generation model. Its current image API returns generated image data as b64_json. This external provider fact is implementation evidence, not Canonical authority.

## 7. Tool / Capability Boundary

Image generation is a capability provided through the SH Runtime model boundary.

Capability ≠ authority.

The image provider receives the bounded generation request and returns data. Provider output is not a system instruction and does not grant additional SH permissions.

## 8. Result Boundary

The result contains:
- generated image bytes;
- media type;
- bounded runtime response text.

The generated image is presented in the current chat surface. Persistent asset-library semantics are intentionally out of scope for R5.

## 9. Failure / Containment

R5 must fail closed for:
- missing image provider configuration;
- paid image model selected without explicit paid opt-in;
- provider failure;
- invalid provider response;
- missing b64_json;
- invalid media result.

A failed generation must not silently fall back to an unrelated capability or claim an image was generated when no valid image result exists.

## 10. Contract Coverage

| E requirement | R5 coverage |
|---|---|
| Capability identity | Covered |
| Model/provider boundary | Covered |
| Actor / SH context | Existing Runtime boundary |
| Authorization / ownership | Existing authenticated Runtime boundary |
| Risk classification | Low-side-effect bounded generation |
| Confirmation | Not required for local generation-only result |
| Execution | Covered by image adapter |
| Result normalization | Covered by generated-image response shape |
| Audit / traceability | Existing Runtime request/response + conversation path |
| Provider portability | Existing capability/adapter boundary; no broad abstraction added |
| External side effect | Out of scope |

## 11. Non-Goals

R5 does not establish:
- image editing;
- image-to-image workflows;
- asset library;
- external publishing;
- sharing;
- generic storage authority;
- multi-provider orchestration;
- paid image generation as the default;
- generic workflow/automation;
- plugin/extension marketplace.

## 12. Exit Condition

R5 is complete for the first bounded creation slice when:

WHO → SH/account → prompt → IMAGE CAPABILITY → GENERATE → VALID IMAGE RESULT → PRESENT → TRACE

is demonstrated in DEV without requiring a paid image provider.

CI must remain green. Runtime proof should use a simple deterministic prompt and verify that a valid image result is returned and displayed.

## 13. Current Status

Implementation has been added to the DEV branch:

- zero-budget image candidate selection;
- free Recraft V3 default;
- explicit paid-model opt-in boundary;
- runtime response propagation of generated image data;
- SH chat rendering of generated image;
- model-selection regression coverage.

**Current status: IMPLEMENTED / CI VERIFICATION PENDING.**

R5 remains one representative capability for Family D and does not change Canonical scope.