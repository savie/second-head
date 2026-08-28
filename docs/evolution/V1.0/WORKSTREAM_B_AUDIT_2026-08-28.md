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

## Next B step

Concrete UX exploration dimulai dari navigation + conversation/home + composer + drawer/history. Gunakan visual evidence di atas sebagai referensi konkret agar eksplorasi berikutnya tidak hanya bergantung pada deskripsi teks. Jangan coding significant UI sebelum interaction model tersebut cukup jelas.

END OF WORKSTREAM B LIVING DOCUMENT
