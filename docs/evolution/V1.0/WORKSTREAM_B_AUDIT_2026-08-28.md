# SECOND HEAD V1.0 — WORKSTREAM B AUDIT

Status: **DESIGN / NON-CANONICAL — LIVING WORKSTREAM DOCUMENT**
Date: 2026-08-28
Branch: `dev`
Depends on: Workstream A — CLOSED

## Purpose

Dokumen kerja berkelanjutan Workstream B. Bagian awal mencatat audit current state; bagian berikutnya menerjemahkan Resume 69 menjadi arah desain UX/UI V1.0. Dokumen ini bukan Canonical dan tidak mengubah implementation contract.

## Current verified shell

Current authenticated navigation is:

```
Chat | Journey | Lifecycle | More
```

The Expo tab layout directly defines these four owner-facing destinations.

## Findings

### B-1 — Conversation-first entry
**Status: PASS**

Authenticated entry is Chat-oriented and the primary tab is Chat.

The current Chat surface already supports:
- conversation history;
- new conversation;
- rename;
- copy;
- edit/delete message flows;
- streaming state;
- cancellation/background handling;
- attachment selection;
- runtime confirmation state;
- error/system messaging.

This is sufficient as a foundation for B; no shell recreation is justified.

### B-2 — Journey as continuity/history
**Status: PARTIAL / GOOD FOUNDATION**

Journey already presents recorded events with:
- event type;
- date;
- continuity status;
- payload preview;
- source reference;
- detail view;
- visibility/scope;
- transfer policy;
- authorized delete;
- policy editing.

It therefore functions as a real continuity/history surface rather than a placeholder.

Remaining B-level refinement:
- make the relationship between Journey and Chat more obvious;
- preserve source/provenance visibility;
- improve empty/error/loading copy and navigation affordances where useful.

### B-3 — Lifecycle as process/action surface
**Status: PASS / MINOR REFINEMENT**

Lifecycle is explicitly separated from Journey and exposes:
- Clone;
- Recovery;
- Inheritance;
- Succession;
- Legacy;
- End-of-Life.

Descriptions correctly frame Lifecycle as process execution while Journey is where results/history are recorded.

No navigation restructuring is required.

### B-4 — More as technical/account surface
**Status: PASS**

More explicitly keeps technical tools/account controls outside daily Chat/Journey/Lifecycle use.

Current items include:
- Runtime Verification;
- Authorization;
- Account/sign-out;
- build information.

This matches the working direction.

### B-5 — Memory / Knowledge / Experience placement
**Status: GAP / REQUIRES REFINEMENT**

The current Runtime Verification screen exposes authorized Memory, Knowledge, and Journey context lookup for diagnostics.

Experience has its own route and service, but it is not part of the primary owner navigation.

The roadmap's B target says Memory/Knowledge/Experience should be exposed through meaningful Journey/context flows rather than placeholder screens.

Therefore the current state is functional but not yet fully consolidated into the owner experience.

Important: this does **not** justify inventing a new top-level tab. The current roadmap explicitly favors consolidation rather than navigation growth.

### B-6 — State quality
**Status: PARTIAL**

Chat and Journey have meaningful loading/error/empty behavior.

Lifecycle is primarily a static action launcher and does not need a complex loading state, but its process/error semantics are delegated to downstream screens.

More is similarly static.

The remaining priority is consistency of user-facing state language and affordances, not adding state machinery everywhere.

### B-7 — Authorization / governance placement
**Status: PASS**

Authorization is kept as a technical/status surface.

The App does not appear to make ownership/authorization decisions itself; those remain service/runtime concerns.

No client-side governance redesign should be introduced in B.

## B implementation boundary

Workstream B should therefore be a **consolidation pass**, not a broad UI rewrite.

Recommended implementation scope:

1. Preserve the four-tab shell.
2. Refine Chat/Journey handoff and continuity affordances.
3. Improve Journey empty/error/detail discoverability without changing its data contract.
4. Keep Lifecycle as action/process surface and ensure result/history expectations are explicit.
5. Keep More technical and account-focused.
6. Introduce an owner-facing path to Memory/Knowledge/Experience through existing Journey/context surfaces where the current contracts support it.
7. Do not create a new top-level Memory, Knowledge, or Experience tab.
8. Do not move authorization or governance decisions into the client.

## Dependency decision

Workstream B is **implementation-ready for a bounded consolidation pass**.

Workstream C should remain downstream of B completion because multimodal/file UX will plug into Chat and should not force a second navigation redesign.

## No Canonical change

This audit proposes no Canonical modification.

END OF WORKSTREAM B AUDIT


# B — MODERN UX/UI DESIGN DIRECTION

## Reframe

Workstream B bukan bounded UI refinement. Resume 69 mengarah pada lompatan pengalaman yang terasa: clean, modern, conversation-first, ringan di mobile, composer natural, attachment natural, message actions rapi, spacing/typography modern, dialog/modal polished, dan tidak terasa seperti admin dashboard.

Mental model kerja: ChatGPT-like UX + SH architecture. Ini bukan clone; prinsipnya familiar interface, different brain/system.

Current Chat | Journey | Lifecycle | More adalah current implementation, bukan design lock V1.0. Desain boleh mengubah information hierarchy dan interaction model secara material.

## Primary experience

Conversation menjadi pusat pengalaman:

OPEN SH → CONVERSATION → COMPOSE / ATTACH / ACT → SH RESPONDS → CONTEXTUAL CONTINUITY

Contextual continuity dapat membuka Journey, Memory, Knowledge, atau Experience. User tidak perlu memahami Soul / Brain / Senses / Hands / Authority untuk menggunakan SH; konsep itu harus terasa melalui behavior dan contextual UI, bukan architecture dashboard.

## Navigation exploration

Eksplorasi boleh mencakup conversation-first navigation, drawer/sidebar, conversation history, Search, dan workspace/project entry bila Projects nanti lolos product definition. Jangan memaksa setiap subsystem menjadi top-level screen.

## Conversation + composer

Conversation adalah visual center V1.0: spacious tetapi efisien di HP, minimal chrome, readable messages, smooth streaming, quiet contextual actions, dan natural return ke conversation lama.

Composer adalah redesign priority: text + attachment/capability entry + send/stop state dalam satu interaction model. Photo/camera/file harus terasa sebagai satu capability picker. Upload/processing state harus jelas tanpa technical noise.

## Continuity

Pembeda utama SH bukan halaman Memory terpisah, tetapi continuity: Conversation → Context → Memory / Knowledge / Experience → Journey → future interaction.

Journey harus terasa sebagai representasi perjalanan SH/owner, bukan database table viewer. Source/provenance dan jalur kembali ke source conversation tetap penting.

Memory / Knowledge / Experience tidak boleh otomatis menjadi tiga CRUD screen. Mental model Resume 69 tetap working/non-canonical sampai semantics-nya matang.

## Lifecycle / Hands / Authority

Lifecycle: action → confirmation/authority → execution → result → recorded continuity.
Tools/Hands harus terasa sebagai capability, bukan tumpukan tombol. UX perlu membuat boundary authority, confirmation, execution, dan result dapat dipahami tanpa mengekspos plumbing.

## Search / Projects

Global SH Search adalah candidate capability dari Resume 69. Projects tetap candidate; jika dipertahankan, Project adalah workspace/context boundary, bukan SH identity boundary. Jangan implementasikan UI Projects sebelum product definition menjelaskan semantics-nya.

## Visual/state direction

User-facing error sederhana; technical detail melalui diagnostic path. Loading, empty, upload, processing, unavailable, dan offline states harus komunikatif.

Visual direction: modern typography, controlled spacing, restrained chrome, polished sheets/dialogs, touch-friendly controls, mobile-first composition. Hindari admin-dashboard aesthetics, feature-badge overload, architecture terminology everywhere, dan copied product visuals.

## Design gate

Sebelum significant UI coding, perjelas: primary navigation model; conversation/home composition; composer structure; attachment/capability picker; history/drawer behavior; continuity entry points; Journey presentation; Lifecycle presentation; technical/account placement; core visual language.

## Status keputusan

CANON: tidak berubah.
Existing implementation: baseline/audit evidence.
Resume 69: brainstorming source; bukan commitment.
Working design: bagian ini; boleh direvisi sebelum implementation.
Implementation: HOLD sampai design gate cukup jelas.

## Visual evidence / candidate references

Visual candidate yang dipilih sementara untuk eksplorasi desain B disimpan sebagai repository evidence:

- `evidence/ui/SH_V1_UI_HYBRID_1_3_5_CANDIDATE.png` — hybrid navigation + conversation + contextual panel + summary.
- `evidence/brand/SH_LOGO_C2_V3_CANDIDATE.png` — brand/logo candidate, C2 evolution dengan V3 sebagai pilihan sementara.

Status keduanya **REFERENCE / CANDIDATE — NON-CANONICAL**. Visual ini adalah evidence dari eksplorasi, bukan commitment final dan bukan perubahan Canonical.

## B roadmap — dari design gate menuju implementation

Setelah audit current state dan visual exploration, Workstream B dilanjutkan sebagai **design-first consolidation**, bukan langsung coding.

Urutan kerja sementara:

B0 DESIGN GATE
↓
B1 NAVIGATION + DRAWER / HISTORY
↓
B2 CONVERSATION HOME / CHAT COMPOSITION
↓
B3 COMPOSER + CAPABILITY ENTRY
↓
B4 CONTEXTUAL SURFACES
↓
B5 JOURNEY / CONTINUITY PRESENTATION
↓
B6 LIFECYCLE / MORE POLISH
↓
B7 RESPONSIVE BEHAVIOR REVIEW
↓
B8 INTEGRATION + UX VERIFICATION
↓
B-CLOSE

### B0 — Design Gate

Sebelum significant UI implementation, tetapkan working interaction model untuk primary navigation, collapsed/expanded navigation, drawer/history, conversation/home composition, composer, attachment/capability entry, contextual right-side surface, Journey entry/return-to-source, Lifecycle/More placement, mobile-first behavior, dan responsive applicability untuk tablet/web.

Gunakan evidence/ui/SH_V1_UI_HYBRID_1_3_5_CANDIDATE.png sebagai kandidat utama, bukan design lock.

### B1 — Navigation + Drawer / History

Working direction:
- icon-first/collapsed navigation;
- expandable navigation ketika diperlukan;
- history/conversation discovery tidak mengorbankan conversation space;
- mobile memakai drawer/sheet;
- desktop/web boleh mempertahankan rail/sidebar lebih persistent bila ruang memungkinkan.

Jangan menambah top-level destination hanya karena subsystem tersedia.

### B2 — Conversation Home / Chat Composition

Conversation menjadi visual center. Fokus pada hierarchy percakapan, spacing/typography, message actions yang tenang, streaming/cancellation/error states, return ke conversation lama, dan empty/new conversation experience.

Tidak mengubah runtime/data contract hanya demi kosmetik UI.

### B3 — Composer + Capability Entry

Composer menjadi redesign priority: TEXT + ATTACHMENT/CAPABILITY + SEND/STOP.

Photo/camera/file dan capability lain diarahkan menuju interaction model yang konsisten. Upload/processing/unavailable state harus terlihat tanpa membocorkan plumbing/provider detail.

### B4 — Contextual Surfaces

Eksplorasi panel/sheet kontekstual untuk informasi yang membantu conversation tanpa membuat dashboard permanen.

Candidate content: relevant Journey/context, Memory, Knowledge, Experience, dan tool/action context bila tersedia.

Tidak membuat tiga CRUD screen Memory/Knowledge/Experience hanya karena domain backend sudah ada.

### B5 — Journey / Continuity Presentation

Journey diposisikan sebagai continuity/history experience. Event harus mudah dipahami, provenance/source tetap terlihat, source conversation/object dapat dibuka kembali jika contract mendukung, detail tidak terasa seperti database record viewer, dan state loading/empty/error konsisten.

### B6 — Lifecycle / More Polish

Lifecycle tetap action/process surface. More tetap technical/account surface. Polish diarahkan pada hierarchy, copy, confirmation, result/error feedback, dan diagnostic detail bila diperlukan.

Tidak memindahkan governance/authorization decision ke client.

### B7 — Responsive Behavior Review

Mobile tetap primary target, tetapi interaction model tidak sengaja dikunci ke Android.

PHONE → drawer/sheet → conversation full-screen

TABLET → navigation + conversation → contextual panel bila ruang memungkinkan

WEB/DESKTOP → persistent sidebar → conversation center → optional contextual panel

Status: applicability candidate, bukan commitment untuk membuat web client pada Workstream B.

### B8 — Integration + UX Verification

**Status: AUTOMATED INTEGRATION PASS / MANUAL VISUAL REVIEW PENDING**

Current DEV head `9a6a35f92fe071162d098c265513eb3efb29f8ce` passed the available automated verification paths after the B7 reconciliation:
- Runtime Controlled Verification #245 — PASS
- App Chat Verification #360 — PASS
- App Android Build #269 — PASS

The integrated shell now covers the four owner-facing destinations (`Chat | Journey | Lifecycle | More`), responsive rail/drawer behavior, contextual surface behavior, Journey continuity context, and Lifecycle/More context surfaces without changing the database/runtime contract.

Manual APK visual review is intentionally not treated as completed in this pass; the Android build artifact was not manually inspected. Therefore B8 can confirm automated integration/build health, but cannot claim final visual UX acceptance from device inspection alone.

### B-Close

**Status: CLOSED FOR IMPLEMENTATION / AUTOMATED ACCEPTANCE**

B-Close is satisfied for the current implementation boundary:
- primary interaction model is explicit;
- Chat/Journey/Lifecycle/More hierarchy is coherent;
- contextual surfaces are implemented without adding top-level navigation;
- responsive rules exist for phone/tablet/desktop applicability;
- runtime/data contracts were left intact;
- automated Runtime, Chat, and Android verification passed on the final reconciled DEV head;
- Workstream C can enter without requiring another navigation redesign.

Manual device visual inspection remains an optional product/UX review and is **not** recorded as a completed acceptance gate. This does not block the implementation transition to C because no manual inspection was defined as an automated release prerequisite.

B is therefore considered **closed at the implementation/verification boundary**, while visual polish may continue later if a concrete UX issue is found.

Implementation rule: B belum implementation-complete hanya karena mock/screen visual terlihat bagus. Significant UI changes harus melalui implementation → verify → reconcile.

## Next action

**Workstream B sekarang CLOSED untuk implementation/verification boundary.**

Automated verification sudah hijau pada final reconciled DEV head. Manual APK visual review tetap optional dan belum diklaim selesai.

**Next: Workstream C — Multimodal & File Intelligence.**


END OF WORKSTREAM B LIVING DOCUMENT


## CURRENT DEV VERIFICATION — 2026-08-29

Current DEV head at reconciliation: `c02e918d02062c4951ab296a28c2395afedf9f32`.

Automated verification on the current DEV line is GREEN. This is recorded as **CI VERIFIED** evidence only. It does not silently upgrade any separately required manual/device/runtime acceptance gate.

The workstream's existing closure/status sections remain historical/source-specific and are not rewritten solely from CI status. Where a manual APK/device/runtime proof is explicitly pending in this document, that gate remains pending.
