# EV-P3B-003 — Memory / Knowledge Provenance, Sharing & Superseded Reconciliation

## Status

**PASS — VERIFIED / DEV**

Backlog item: `BL-P3B-003`
Domain: Phase 3B — Memory / Knowledge
Mutation type: Evidence-only; no new database/schema mutation required.

## Audit Scope

This completion audit reconciles the latest Owner decision layer:

`Memory → Knowledge → General Knowledge → Sharing → Provenance → Superseded`

against the current canonical/implementation source available in GitHub and the known actual Supabase realization previously established for Phase 3A/3B.

No new architectural decision is introduced by this evidence.

## Owner Decision Layer Reconciled

The current Owner discussion establishes:

1. Memory preserves useful experience/interactions for continuity and is not automatically spoken verbatim.
2. Information does not automatically become Knowledge.
3. Knowledge can arise through SH recognition/evaluation or explicit Owner/user teaching.
4. The initial concrete eligibility rule is `occurrence >= 5 → knowledge = true`.
5. The threshold is a practical v1 rule, not proof of absolute truth.
6. Private information must not automatically become shared/general knowledge.
7. General knowledge may help other users without exposing the private identity of the original source.
8. Provenance/lineage remains relevant even after knowledge is shared.
9. Knowledge can be corrected; an older representation may become `SUPERSEDED` rather than silently rewriting history.
10. Knowledge does not automatically modify Core.

## GitHub Verification

The existing migration source contains the realization required for this backlog boundary:

- `scope` distinguishes `PRIVATE` and `GENERAL`;
- `visibility` distinguishes `OWNER_ONLY` and `SHARED`;
- `source` is retained on each memory record;
- lifecycle includes `SUPERSEDED`;
- `superseded_by` preserves replacement lineage;
- `occurrence_count` is persisted;
- the knowledge eligibility view derives `knowledge_candidate` only when `scope = 'GENERAL'` and `occurrence_count >= 5`;
- the eligibility view only considers `CANDIDATE` and `ACTIVE` lifecycle states;
- RLS policies constrain memory access to the authenticated owner linked to the SH/account.

Source:
`database/migrations/20260811034535_create_memory_storage_and_knowledge_eligibility.sql`

## Supabase Verification Boundary

The actual Supabase project was previously verified during P3A/P3B work to contain the corresponding `public.memories` realization and ownership/RLS reconciliation migrations.

A fresh direct SQL verification attempt in this audit was denied by the currently available Supabase tool permission (`MCP error -32600: You do not have permission to perform this action`). Therefore this evidence does **not** fabricate a new live-query result. It relies only on the already verified actual-state evidence from the preceding P3A/P3B completion work.

No Supabase mutation was performed for BL-P3B-003.

## Boundary / Non-Decision

This PASS does not claim that SH already has:

- a complete autonomous semantic Knowledge engine;
- final truth verification;
- automatic private-to-general promotion without governance/privacy checks;
- a complete external-source ingestion/trust pipeline;
- automatic sharing to arbitrary users;
- Core modification through learning.

Those remain outside this backlog item's realization boundary unless separately specified by a later approved implementation slice.

## Completion Result

**BL-P3B-003 = PASS**

Reason: the Owner decision layer concerning provenance, general/shared knowledge boundaries, ownership visibility, and supersession is consistent with the existing GitHub realization and the previously verified Supabase state. No additional schema mutation or new architectural decision is required.

Next backlog item may proceed through:

`AUDIT → REALIZATION MINIMAL (if needed) → VERIFY → EVIDENCE → DEV`
