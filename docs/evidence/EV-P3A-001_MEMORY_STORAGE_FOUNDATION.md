# EV-P3A-001 — Memory Storage Foundation

## Status
PASS / VERIFIED

## Scope
Minimal Phase 3A memory-storage realization following the Owner-approved technical direction:

- Memory is owner/SH scoped.
- Memory is not automatically Knowledge.
- General-scope memory may become a Knowledge candidate only after repeated occurrence.
- Technical threshold: `occurrence_count >= 5`.
- The threshold does not itself publish/shared-promote Knowledge; OQ-03/OQ-04 remain open.

## Source / Authority
- SH Core Canonical v1.0
- SH Full Build Scope v1.0
- SH Full Implementation Contract v1.0
- SH Full Implementation Guide v1.0
- SH Full Execution Strategy v1.0
- Phase -1 Artifact Map / Backlog
- Owner decision from current project discussion: `occurrence >= 5` for Knowledge candidacy after scope/privacy classification.

## Engineering Realization
Migration:
`database/migrations/20260811034535_create_memory_storage_and_knowledge_eligibility.sql`

Objects created:
- `public.memories`
- `public.memory_knowledge_eligibility`

Memory metadata includes:
- SH scope
- type
- content
- source
- confidence
- scope
- visibility
- lifecycle
- occurrence count
- timestamps
- supersession reference

## Privacy / Governance Controls
`public.memories` has RLS enabled.

Owner-scoped policies are present for:
- SELECT
- INSERT
- UPDATE
- DELETE

The policies resolve ownership through:
`sh_instances -> accounts -> account_auth_links -> auth.uid()`.

No cross-SH sharing mechanism was introduced by this mutation.

## Knowledge Boundary
The eligibility view evaluates:

`scope = GENERAL AND occurrence_count >= 5`

as `knowledge_candidate = true`.

Examples verified:
- PRIVATE + 5 occurrences -> false
- GENERAL + 4 occurrences -> false
- GENERAL + 5 occurrences -> true
- GENERAL + 6 occurrences -> true

This is eligibility only. It does not create or publish shared Knowledge.

## Supabase Verification
Migration applied successfully to project `pkhkgvsrqeupvwoqjwmd`.

Verified:
- migration version `20260811034535` exists;
- `public.memories` exists;
- RLS is enabled on `public.memories`;
- four owner-scoped policies exist;
- `public.memory_knowledge_eligibility` exists as a view;
- threshold behavior matches the Owner-approved rule.

## Non-Goals / Still Open
Not implemented by this evidence:
- Knowledge ingestion pipeline (OQ-03)
- Reference trust promotion mechanism (OQ-04)
- automated privacy/general-vs-private classification
- full relevance scoring policy
- full confidence determination policy
- semantic/vector memory
- cross-SH Knowledge sharing

## Result
Phase 3A memory-storage foundation is technically realized and verified without changing Canonical authority.
