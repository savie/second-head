# SECOND HEAD V1.0 — ROADMAP

Status: **WORKING / BRAINSTORM-DERIVED / NON-CANONICAL**

This roadmap is an evolution plan, not a Canonical change.

## Starting point

The current v0.1.0 build is treated in this planning discussion as the functional foundation/proving ground: core architecture, runtime, persistence, chat mechanics, attachments, and related mechanics have been exercised.

The V1.0 goal is therefore not to restart SH from zero, but to evolve the existing foundation into a more complete, modern, user-grade SH.

## Roadmap

### A — Foundation & Baseline

- establish a verified DEV baseline;
- audit current architecture and implementation;
- audit database artifacts against the current DEV database;
- map provider coupling;
- verify known functionality, CI/build, and migration discipline;
- preserve Canonical as authority.

### B — Modern UX

Move from the current conservative UI toward a lightweight, modern, conversation-first experience.

Areas to explore:
- modern navigation/drawer;
- Home / chat entry experience;
- conversation management;
- attachment presentation;
- loading, empty, offline and error states;
- Journey presentation;
- Memory / Knowledge / Experience surfaces;
- More / Settings.

Target direction: **ChatGPT-like usability without blindly copying ChatGPT.**

### C — Multimodal + Image Generation

Evolve existing attachment capability into broader multimodal interaction:

- image input;
- camera;
- file intelligence;
- multiple attachments;
- multimodal conversation;
- image understanding;
- image generation.

Image generation is explicitly part of the V1.0 direction from the brainstorming discussion.

### D — SH Intelligence Surfaces

Refine how these capabilities work together:

- Memory;
- Knowledge;
- Experience;
- Journey;
- global SH Search;
- Projects.

The goal is not isolated screens, but useful continuity between sources, conversations, events and SH state.

### E — Hands / Tools / Authority

Explore the SH differentiator discussed in brainstorming:

AI/model = brain  
SH = system / identity / continuity  
Hands = ability to act

Potential model:

```
SH
 ↓
Tool / capability
 ↓
Authority
 ↓
Execution
 ↓
Result
 ↓
SH
```

Tools, extensions and plugins should be treated as capability/execution layers, not merely extra buttons.

### F — Provider / Infrastructure Portability

Strengthen boundaries so SH is not permanently identified with its current infrastructure provider.

Target direction:

```
SH
 ↓
application / runtime contracts
 ↓
data & infrastructure boundary
 ↓
provider implementation
```

Current Supabase infrastructure can remain the implementation while boundaries are improved.

Do not introduce unnecessary abstraction solely to claim multi-provider support.

### G — Local Storage + Offline

Explore local/offline capability after the cloud foundation and provider boundaries are stable.

Questions include:
- what can work without network;
- local data/storage responsibilities;
- synchronization;
- recovery;
- user-visible offline behavior.

### H — Local GGUF Runtime

Explore an integrated local model runtime rather than requiring Termux as an external dependency.

The brainstorming direction included model files stored outside the APK package where Android permits an appropriate application-managed location, with SH able to run a local GGUF runtime.

This remains a design/exploration item, not an implementation commitment.

## Release gate

A V1.0 Release Candidate should only be considered after the relevant roadmap work is implemented, verified, and not merely represented by cosmetic UI.

## Important

This sequence is a planning proposal. Individual items may move, split, merge, or be deferred after dependency/risk analysis.
