# EV-CROSS-004 — Repository Structure Audit / Design

**Project:** SECOND HEAD — SYSTEM BUILD  
**Status:** DONE — AUDIT / DESIGN COMPLETE  
**Audit Scope:** Repository physical structure, migration placement, runtime placement, documentation/evidence placement, future application/test/CI placement  
**Branch:** `dev`  
**Repository:** `savie/second-head`  
**Audit Date:** 2026-08-13  
**Remote mutation:** NONE  

## 1. OBJECTIVE

Audit the actual `dev` repository structure after the frozen migration disposition and define a minimal, safe repository structure that:

- preserves the frozen migration disposition;
- does not reopen Phase 1–5;
- does not rewrite or rename committed migrations;
- separates canonical source from historical/non-canonical source;
- keeps current runtime and Supabase Edge Function source discoverable;
- provides a clear future landing zone for the application/delivery surface;
- avoids speculative folders that have no legitimate consumer yet.

## 2. AUTHORITY / PREVIOUS DECISIONS

The following decisions remain binding:

- `database/migrations/` is the only canonical repository location for application schema migrations.
- Git is the source-of-truth for application migration definitions.
- Supabase DEV is the authoritative applied remote state.
- Committed migrations are immutable and forward-only.
- `supabase/migrations/` is frozen as non-canonical pending this structure audit.
- Historical aliases and source gaps are documented and must not be fabricated.
- Phase 1–5 migration replay is not required.
- Phase 1–5 are not reopened.

Reference: `docs/evidence/EV-CROSS-003_CANONICAL_MIGRATION_DISPOSITION.md`.

## 3. ACTUAL `dev` STRUCTURE — READ-ONLY FINDING

The current repository contains these meaningful top-level areas:

```text
/
├── .env.example
├── .gitignore
├── README.md
├── database/
│   ├── MIGRATION_FRAMEWORK.md
│   ├── MIGRATION_REMOTE_STATE.md
│   └── migrations/
├── docs/
│   ├── build/
│   ├── constitution/
│   ├── design/
│   ├── evidence/
│   ├── final/
│   ├── phase3/
│   ├── phase4/
│   ├── phase5/
│   ├── phase6/
│   └── reference/
├── runtime/
│   ├── p4a/
│   ├── p4b/
│   ├── p4c/
│   ├── p4d/
│   ├── p4e/
│   ├── p4f/
│   ├── p5a/
│   ├── p5b/
│   ├── p5c/
│   ├── p5d/
│   └── p5e/
└── supabase/
    ├── functions/
    └── migrations/
```

This is materially different from the original remembered conceptual sketch (`.github/`, `Database/`, `Docs/`, `Src/`, `Test/`, etc.). The current tree is the actual authority for this audit.

## 4. STRUCTURE FINDINGS

### 4.1 `database/` — CANONICAL / KEEP

`database/migrations/` is correctly retained as the canonical application migration source.

No move, rename, deletion, or rewrite of committed migration files is authorized by this audit.

### 4.2 `supabase/` — KEEP, BUT SPLIT SEMANTICALLY

The `supabase/` directory is not inherently invalid.

- `supabase/functions/` contains actual Supabase Edge Function source and is a legitimate platform/deployment surface.
- `supabase/migrations/` is different: it is explicitly non-canonical under the frozen migration disposition.

Therefore the correct interpretation is:

```text
supabase/functions/     = legitimate platform/deployment source
supabase/migrations/    = historical/non-canonical migration source; frozen
```

The structure audit MUST NOT treat the entire `supabase/` directory as disposable.

### 4.3 `runtime/` — KEEP / CURRENT CORE IMPLEMENTATION AREA

`runtime/` is the actual implementation area for Phase 4 and Phase 5 runtime logic and tests. It is not evidence of an application frontend.

The presence of runtime tests under `runtime/p4*` and `runtime/p5*` is accepted as the current project convention. A separate `tests/` directory should not be created merely for cosmetic symmetry.

### 4.4 `docs/` — KEEP / AUTHORITATIVE DOCUMENTATION AREA

The current documentation grouping is already substantially useful:

- `docs/final/` — final authority artifacts;
- `docs/constitution/` — governance/constitution records;
- `docs/evidence/` — evidence and reconciliation records;
- `docs/design/` — implementation/design artifacts;
- `docs/phase3`–`docs/phase6/` — phase execution/closure artifacts;
- `docs/reference/` — compiled/reference material;
- `docs/build/` — build/backlog artifacts.

No broad documentation relocation is required for this step.

### 4.5 `.github/` — DEFERRED UNTIL NEEDED

The current tree does not contain `.github/`.

This is not a defect by itself. A `.github/` directory should be introduced only when GitHub-specific workflow/configuration has a legitimate consumer, such as Actions workflows, issue templates, or repository automation.

### 4.6 `src/` / `app/` — NOT YET PRESENT / FUTURE DELIVERY AREA

The current tree contains no application frontend/mobile delivery surface.

This is an existing implementation gap identified separately in cross-phase assurance. It is not to be solved by creating empty placeholder folders.

When the application is actually started, its real framework/toolchain should determine the correct directory (`app/`, `src/`, or framework-specific structure). The repository should not pre-create speculative application folders now.

### 4.7 `test/` / `tests/` — DEFERRED

No separate test root is required at present because implementation tests already live beside the relevant runtime components.

A separate integration/E2E test area should be introduced only when P6 integration tooling has a real consumer and its placement is explicitly decided.

## 5. TARGET STRUCTURE — MINIMAL SAFE DESIGN

The target is not a cosmetic reorganization. It is a semantic map of the repository's actual responsibilities:

```text
/
├── README.md
├── .gitignore
├── .env.example
│
├── database/                 # application database source-of-truth
│   ├── MIGRATION_FRAMEWORK.md
│   ├── MIGRATION_REMOTE_STATE.md
│   └── migrations/          # ONLY canonical app-schema migrations
│
├── runtime/                  # SH runtime/core implementation
│   ├── p4a ... p4f
│   └── p5a ... p5e
│
├── supabase/                 # Supabase platform/deployment source
│   ├── functions/            # Edge Functions
│   └── migrations/           # historical/non-canonical; frozen
│
├── docs/                     # authority, design, evidence, phase records
│   ├── final/
│   ├── constitution/
│   ├── evidence/
│   ├── design/
│   ├── build/
│   ├── phase3/
│   ├── phase4/
│   ├── phase5/
│   ├── phase6/
│   └── reference/
│
└── [future application surface]
    # created only when an actual app framework/toolchain is adopted
```

This is the minimum structure that explains the repository without inventing empty folders.

## 6. IMPORTANT SEMANTIC RULES

### Rule R-01 — Migration authority

There is exactly one canonical application migration source:

`database/migrations/`

### Rule R-02 — Supabase is not one semantic bucket

Do not equate `supabase/` with `supabase/migrations/`.

`supabase/functions/` is legitimate current source. `supabase/migrations/` is non-canonical historical source.

### Rule R-03 — No cosmetic renames of committed migrations

The malformed historical migration filename and historical timestamp aliases remain documented facts. They are not renamed merely to make the tree look cleaner.

### Rule R-04 — No empty future structure

Do not create `.github/`, `src/`, `app/`, `tests/`, `packages/`, or similar directories solely because a generic software repository normally has them.

Create them together with the real consumer/toolchain that requires them.

### Rule R-05 — Runtime tests remain local unless a real P6 harness requires otherwise

Existing runtime tests remain under their component areas. A future integration/E2E harness may introduce a dedicated location when its design is known.

### Rule R-06 — APP is a downstream implementation area, not a Phase 1–5 repair

The absence of an application/delivery surface is an open downstream implementation gap. It does not invalidate closed Phase 1–5 backend/runtime work.

## 7. STRUCTURE DEBT IDENTIFIED

| ID | Finding | Status | Action |
|---|---|---|---|
| RS-01 | Two migration locations exist | CONTROLLED DEBT | Keep canonical `database/migrations/`; freeze `supabase/migrations/` pending historical disposition |
| RS-02 | One committed migration filename violates 12-digit timestamp convention | IMMUTABLE HYGIENE DEBT | Do not rename; future corrections forward-only |
| RS-03 | Application/delivery surface absent | OPEN GAP | Implement later as legitimate consumer; do not create placeholder folders |
| RS-04 | No `.github/` | DEFERRED | Create only when GitHub workflow/config consumer exists |
| RS-05 | No dedicated E2E test root | DEFERRED | Decide when P6 integration harness exists |
| RS-06 | Documentation has multiple semantic groups | ACCEPTED | Current grouping is traceable; no broad relocation required |

## 8. PHASE BOUNDARY

This audit does NOT reopen Phase 0–5.

It does NOT change migration history, schema, RLS, runtime behavior, Edge Functions, or Supabase state.

It only establishes the repository-structure interpretation and safe future placement rules needed for subsequent assurance.

## 9. RESULT

**Repository Structure Audit / Design: DONE.**

### Frozen conclusions

1. `database/migrations/` remains the sole canonical application migration location.
2. `supabase/functions/` remains a legitimate current platform/deployment source.
3. `supabase/migrations/` remains non-canonical and frozen; no blind deletion or move is performed.
4. `runtime/` remains the current runtime implementation/test area.
5. `docs/` remains the documentation/evidence authority area.
6. `.github/`, `src/`, `app/`, `tests/`, and similar future roots remain deferred until a legitimate consumer exists.
7. The APP/delivery gap remains an open downstream implementation item, not a reason to reopen Phase 1–5.
8. No repository or Supabase mutation was performed by the audit itself.

## 10. NEXT STEP

Proceed to **⑤ Reconcile Evidence** using this structure map as the repository placement baseline, then perform final cross-phase assurance and confirm the exact P6 dependency chain.
