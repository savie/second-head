# EV-CROSS-003 — Canonical Migration Disposition

**Status:** DONE — FROZEN
**Audit Scope:** Canonical disposition of migration history and repository migration sources
**Branch:** `dev`
**Supabase Project:** `pkhkgvsrqeupvwoqjwmd`
**Audit Date:** 2026-08-13
**Remote mutation:** NONE

## 1. Objective

Freeze the authoritative disposition of the migration sources after the completed migration-history audit and GitHub ↔ Supabase reconciliation.

This record determines which source is canonical, how historical aliases and gaps are treated, and what cleanup is permitted in the next repository-structure step.

It does not rename, delete, rewrite, replay, or repair any applied migration.

## 2. Authority Basis

The active repository migration framework establishes:

- `database/migrations/` as the single canonical location for application schema migrations;
- Git as the source-of-truth for application schema definitions;
- Supabase as the applied remote state;
- committed migrations as immutable and forward-only;
- no fictional reconstruction of historical SQL.

The current GitHub ↔ Supabase reconciliation confirms that Supabase DEV has 38 applied migrations and that the current mismatch is primarily historical representation, source location, timestamp aliasing, and several unrecovered source definitions — not evidence that Phase 1–5 migrations must be replayed.

## 3. FROZEN CANONICAL DISPOSITION

### D-01 — Canonical migration source

**DECISION: FROZEN**

`database/migrations/` is the **only canonical repository location** for application schema migration definitions going forward.

No second canonical migration authority is recognized.

### D-02 — Supabase migration history

**DECISION: FROZEN**

The applied migration history reported by Supabase DEV is the authoritative record of what was actually applied remotely.

Remote version/timestamp values are historical facts. They are not to be cosmetically rewritten merely to match repository filenames.

### D-03 — `supabase/migrations/`

**DECISION: FROZEN AS NON-CANONICAL**

SQL under `supabase/migrations/` is not a second source-of-truth.

Existing files may contain valid historical application migration source and therefore must not be deleted or moved blindly. Their final repository disposition belongs to the controlled repository-structure audit/cleanup step.

### D-04 — Historical timestamp aliases

**DECISION: ACCEPT AS HISTORICAL FACT**

Where a repository migration has verified equivalent SQL/functionality but uses a different timestamp from the applied Supabase version, the difference is recorded as a historical timestamp alias.

The repository filename is not retroactively renamed solely to make it equal to the remote timestamp.

### D-05 — Historical source gaps

**DECISION: KEEP AS GAP / DEFERRED**

Where the original SQL source for an applied migration cannot currently be verified, no replacement migration will be invented.

A later reconciliation may close such a gap only when the original source can be recovered and verified from trustworthy history.

### D-06 — Malformed committed migration filename

**DECISION: IMMUTABLE HISTORICAL ARTIFACT**

`database/migrations/2026081013_create_access_decision_gate.sql` violates the active 12-digit timestamp naming convention.

Because committed migrations are immutable, this is recorded as repository hygiene debt rather than silently renamed in place.

Future migration work must follow the canonical naming convention. Any correction must be forward-only and must not rewrite applied history.

### D-07 — Phase 1–5 replay

**DECISION: NOT REQUIRED**

The migration discrepancy does not authorize or require replay of Phase 1–5 schema migrations.

The actual Supabase DEV state already contains the applied history through the current Phase 5 database work.

### D-08 — Supabase history repair

**DECISION: NOT REQUIRED**

No remote migration-history repair is required merely to normalize timestamps, filenames, or repository locations.

Any future remote schema change must follow the controlled migration workflow.

## 4. DISPOSITION CLASSES

| Class | Meaning | Action now |
|---|---|---|
| `CANONICAL` | Retained application migration source under `database/migrations/` | Retain |
| `HISTORICAL-ALIAS` | Verified source/functionality represented under a different remote timestamp | Retain; document alias |
| `NON-CANONICAL-SOURCE` | Valid historical source currently under `supabase/migrations/` | Freeze; resolve during structure cleanup |
| `HISTORICAL-SOURCE-GAP` | Applied remote migration whose original source is not currently verified | Document; do not fabricate |
| `HYGIENE-GAP` | Committed artifact violates current naming/location discipline | Retain immutably; correct only through safe future workflow |
| `REMOTE-STATE` | Fact that migration is applied in Supabase DEV | Treat as historical fact |

## 5. CURRENT FROZEN STATE

- Canonical application migration directory: **`database/migrations/`**
- Canonical source-of-truth: **Git**
- Applied-state authority: **Supabase DEV**
- `supabase/migrations/`: **NON-CANONICAL / FROZEN PENDING STRUCTURE AUDIT**
- Historical aliases: **DOCUMENTED / ACCEPTED**
- Historical source gaps: **DOCUMENTED / DEFERRED**
- Malformed committed filename: **DOCUMENTED / IMMUTABLE**
- Migration replay: **NO**
- Remote migration-history rewrite: **NO**
- Supabase mutation in this step: **NONE**

## 6. WHAT THIS UNLOCKS

This disposition authorizes the next controlled step:

**④ AUDIT / DESIGN REPOSITORY STRUCTURE**

That step may determine the safe final placement of existing historical source files, documentation, tests, and other repository artifacts.

It must preserve the dispositions above and must not silently rewrite migration history.

## 7. P1–P5 / P6 BOUNDARY

This disposition does not reopen Phase 1–5.

The migration/source representation problem is now classified as a repository synchronization and hygiene issue. It becomes a prerequisite for clean final assurance, but it does not imply that the underlying Phase 1–5 schema implementation must be rebuilt.

P6 may proceed only after the remaining repository/evidence reconciliation work establishes a clean, auditable source representation and confirms its actual runtime state.

## 8. FINAL RESULT

**Canonical Migration Disposition: DONE.**

**Canonical source:** `database/migrations/`

**Remote applied history:** Supabase DEV historical authority

**Historical aliases:** accepted and documented

**Historical source gaps:** remain explicitly deferred; no fabrication

**`supabase/migrations/`:** frozen as non-canonical pending controlled repository-structure audit

**Committed migration immutability:** preserved

**Phase 1–5 migration replay:** not required

**Supabase mutation:** none

**Next step:** Repository Structure Audit / Design (④)
