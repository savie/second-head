# SECOND HEAD V1.0 — MODERN UX/UI DESIGN DIRECTION

Status: WORKING DESIGN / NON-CANONICAL
Date: 2026-08-28
Branch: dev
Depends on: Workstream A — CLOSED; Resume 69 brainstorming

## Purpose
This document translates the UX/product direction in Resume 69 into a concrete design direction for V1.0. It is a working design direction, not an implementation contract and not a Canonical change.
The goal is not to decorate the current v0.1.0 UI. The goal is to make SH feel materially more modern, conversational, lightweight, and coherent while preserving SH identity and existing system boundaries.

## Design thesis
> Familiar AI interaction, different brain/system.
SH should feel like a modern AI product rather than an admin application.
Resume 69 explicitly calls for clean, modern, conversation-first, lightweight-on-mobile UX, a natural composer, natural attachment interaction, clean message actions, modern spacing and typography, and polished dialogs/modals.

## What changes
This is a product-level UX refresh, not a cosmetic pass.
Design must reconsider information hierarchy, navigation model, conversation entry, composer, attachment affordances, message actions, contextual access to continuity, modal/sheet behavior, empty/loading/error states, and technical surfaces.
Existing functional capabilities are inputs to the redesign, not reasons to preserve the current presentation unchanged.

## Primary interaction model
OPEN SH → CONVERSATION → COMPOSE / ATTACH / ACT → SH RESPONDS → CONTEXTUAL CONTINUITY
Continuity may lead to Journey, Memory, Knowledge, or Experience.
The user should not have to understand SH internal architecture before using it.
Soul / Brain / Senses / Hands / Authority remain system concepts. They should become visible through behavior and contextual UI, not through an architecture dashboard.

## Navigation direction
The current four-tab shell, Chat | Journey | Lifecycle | More, is current implementation, not a V1.0 design lock.
V1.0 should explore a conversation-first navigation model, including a drawer/sidebar-style conversation and workspace surface where appropriate.
Candidate primary surfaces: conversation/home, conversation history, search, and Project/workspace entry if Projects survives product definition.
Candidate contextual surfaces: Journey, Memory, Knowledge, Experience, Lifecycle, tools/capabilities.
Candidate technical/account surfaces: runtime status, authorization, account/session, diagnostics.
Principle: Do not turn every SH subsystem into a top-level screen.

## Conversation surface
The conversation surface is the visual center of V1.0.
Desired feel: spacious but efficient on phone; minimal chrome; readable messages; strong distinction without oversized bubbles; smooth streaming; unobtrusive status; quiet contextual message actions; natural return to previous conversations.
Existing history, rename, find, copy, share, export, delete, edit, regenerate, and cancellation should become one coherent conversation-management model rather than a collection of controls.
Automatic conversation titles may be explored while manual rename remains available.

## Composer
The composer is one of the most important V1.0 redesign targets.
Conceptual model: attachment/capability entry + writing area + context-appropriate input/send/stop controls.
Requirements: attachment feels native to composing; multiple attachments can be represented if supported by the underlying contract; photo/camera/file entry feels like one coherent capability picker; send/stop state is obvious; upload/processing states are visible without technical noise; comfortable on small Android screens.

## Attachment and multimodal affordance
Attachment should not feel like a separate utility bolted onto chat.
Mental model: Composer → text, image/photo, camera, file.
Later senses can extend this interaction without redesigning the basic composer model.

## Message actions
Actions should be contextual and low-noise. Copy, retry/regenerate, edit, share, and more should be easy to reach where useful. Destructive actions should not compete visually with normal actions.

## SH identity
SH should feel like a persistent entity/system without anthropomorphic UI theater.
Identity can be expressed through consistent visual language, response presence, continuity cues, status/capability context, and source/provenance when relevant.
Avoid giant architecture diagrams in normal use and avoid exposing internal identifiers unnecessarily.

## Continuity UX
The key V1.0 differentiator is continuity across interaction, not a separate Memory page.
Conceptual flow: Conversation → Context → Memory / Knowledge / Experience → Journey → future conversation.
Explore contextual links such as conversation → related Journey events, Journey event → source conversation, and relevant Memory/Knowledge/Experience from context. Preserve account, privacy, and authorization boundaries.

## Journey
Journey should feel like a representation of the relationship/history of SH and owner, not a database table viewer.
Design direction: chronological grouping, meaningful event type indication, concise previews, clear detail surface, source/conversation return path, filters/search when useful, readable empty state, readable error state.
The UI should answer: What happened, and why is this relevant?

## Memory / Knowledge / Experience
Do not force these into three generic CRUD screens.
Working mental models from Resume 69: Memory = what SH retains that is relevant to the owner; Knowledge = information SH has about something; Experience = what SH has gone through/learned in its interaction journey.
These are working mental models, not Canonical definitions. UX should expose them contextually and explain provenance where appropriate.

## Lifecycle
Lifecycle is action/process territory. The visual model is ACTION → CONFIRMATION / AUTHORITY → EXECUTION → RESULT → RECORDED CONTINUITY.
Clone, Recovery, Inheritance, Succession, Legacy, and End-of-Life should not look like ordinary settings toggles.

## Hands / Tools
Tools should appear as capabilities, not a pile of buttons.
Potential interaction: user intent → SH capability → authority/confirmation → execution → result → record.
Action boundaries should be understandable without exposing implementation plumbing.

## Search
Global SH Search is a candidate capability from Resume 69. If implemented, it should search relevant SH surfaces while respecting account/privacy boundaries.
Potential groups: Conversations, Journey, Memory, Knowledge, Experience.

## Projects
Projects remain a product-definition candidate. If retained, a Project should be treated as a workspace/context boundary, not another identity for SH.
Important distinction: Project boundary ≠ SH boundary.
No Project UI should be implemented until product definition establishes what Projects mean for SH.

## Error UX
Normal users should not be forced to read raw technical errors.
Target pattern: simple user-facing explanation + primary recovery action; technical details remain available through a diagnostic path.
Resume 69 principle: USER UX → simple; TECHNICAL DIAGNOSTIC → detailed.

## Loading / empty / offline states
States should communicate what SH is doing: empty history, empty Journey, attachment upload, file processing, model unavailable, network unavailable, action in progress.
Avoid generic indefinite spinners where useful status can be given.
Offline is a future capability direction, not a requirement to redesign the current system around local sync now.

## Visual language
Direction: modern typography, generous but controlled spacing, restrained chrome, rounded surfaces where useful, polished sheets/dialogs, subtle hierarchy, touch-friendly controls, and platform-consistent light/dark behavior where existing architecture permits.
Do not introduce visual complexity just to look modern.

## Mobile-first constraints
Priority: conversation readability; composer reachability; attachment access; navigation discoverability; contextual actions; advanced/technical surfaces.
Avoid desktop-first layouts squeezed onto mobile.

## Explicitly rejected
Current UI + a few extra buttons; admin-dashboard aesthetics; one top-level tab for every subsystem; a Memory/Knowledge/Experience CRUD wall; architecture terminology everywhere; feature badges everywhere; ChatGPT clone visuals; and a Frankenstein of patterns copied from other AI products.

## Reference products
Resume 69 identifies references for particular patterns: ChatGPT for conversation UX/composer/attachment/message actions/navigation; Claude for readability and calm UX; Qwen Studio for workspace/capability/file interaction; Perplexity for research/search/source presentation; Gemini for multimodal interaction; MiRA for local/personal feel; Open WebUI for capability/tool/provider thinking; LibreChat for multi-provider UX; AnythingLLM for context/workspace thinking; LobeChat for polished UX; Jan for local simplicity; OpenClaw and Open Interpreter for action/execution thinking; Dify for workflow thinking; Onyx for knowledge access.
These are references, not implementation requirements.

## Design gate before implementation
Before significant UI coding, settle: primary navigation model; conversation/home composition; composer structure; attachment/capability picker behavior; conversation history/drawer behavior; contextual continuity entry points; Journey presentation; Lifecycle presentation; technical/account placement; and core visual language.
No Canonical change is implied.

## Relationship to Workstream B
Workstream B should be treated as Modern UX/UI + interaction-model consolidation, not minor UI refinement of the existing shell.
Implementation should begin only after this design direction is refined enough that the target experience is materially clear.

END OF DESIGN DIRECTION