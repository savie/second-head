# EV-P3C-002 — Repository / Runtime Reconciliation

## Backlog Item
BL-P3C-002 — Relevance Scoring

## Acceptance Criterion
AC-MEM-14

## Result
**PASS — REPOSITORY / LIVE DATABASE RECONCILED**

## Audit Basis
Phase -1 remains the execution-control starting point. No new architectural decision or governance policy was introduced by this reconciliation.

The scoring primitive remains limited to relevance-score production for downstream retrieval ranking. It does not implement ranking, filtering, context injection, bounded retrieval, or retrieval testing.

## Findings

The live `second-head` development database contained the historical remote migration:

`20260811103611_add_memory_relevance_scoring`

The corresponding historical SQL artifact was not present in the Git `database/migrations/` source at the time of audit.

This was treated as repository/runtime synchronization debt, not as permission to fabricate or rewrite the historical migration.

## Reconciliation

A forward-only repository migration was added:

`database/migrations/20260811120000_reconcile_memory_relevance_scoring_source.sql`

It captures the verified live function definition without rewriting the historical migration.

The migration was applied to the live development database as:

`reconcile_memory_relevance_scoring_source`

A second forward-only hardening migration was added:

`database/migrations/20260811121000_harden_memory_relevance_score_search_path.sql`

It pins the function search path to `pg_catalog`.

## Live Verification

Function:

`public.memory_relevance_score(query_text text, memory_content text) -> numeric`

Verified properties:

- `IMMUTABLE`
- `PARALLEL SAFE`
- `search_path = pg_catalog`
- score bounded by `1.0`
- relevant lexical overlap produced `0.1` in the synthetic verification case
- unrelated content produced `0`
- empty query produced `0`

## Security Verification

The initial Supabase security advisor flagged the scoring function for a mutable function search path. The issue was remediated with the forward-only hardening migration.

After remediation, the security advisor no longer reports `function_search_path_mutable` for `public.memory_relevance_score`.

Other pre-existing advisor findings remain outside BL-P3C-002 scope.

## Governance Boundary

This reconciliation does not resolve OQ-02, OQ-03, or OQ-04.

It does not introduce:

- a new relevance policy;
- a new memory policy;
- embeddings;
- vector retrieval;
- ranking logic;
- filtering logic;
- context assembly;
- authorization changes;
- ownership changes;
- Knowledge promotion logic.

## Final Status

**BL-P3C-002 = PASS / DEV**

Runtime/application E2E retrieval remains deferred to the downstream P3C backlog, especially BL-P3C-003 through BL-P3C-007.
