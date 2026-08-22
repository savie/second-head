# EV-CROSS-007 — Repository Migration Structure Closure

**Status:** DONE
**Branch:** `dev`
**Supabase Project:** `pkhkgvsrqeupvwoqjwmd`
**Purpose:** close the controlled repository-structure step without rewriting Supabase history.

## Frozen rule preserved

`database/migrations/` remains the only canonical application migration source. Supabase DEV remains the authoritative applied-state record. `supabase/migrations/` is not a second canonical source.

## Verified current P1 tail

The live Supabase tail includes the post-P1 reconciliation migrations:

```text
20260822091610 p1_normalize_inheritance_transfer_policy_alias
20260822092029 p1_hide_internal_active_sh_assertion
20260822092412 p1_hide_internal_journey_shared_helper
20260822092425 reconcile_journey_shared_helper_rls_execution
20260822092516 reconcile_journey_shared_helper_execution
```

## Repository action

Verified source/functionality is now represented under canonical `database/migrations/`:

```text
20260822142000_p1_inheritance_revoke_journey_provenance_cleanup.sql
20260822143000_p1_clone_revoke_release_cleanup.sql
20260822150000_p1_normalize_inheritance_transfer_policy_alias.sql
20260822151000_p1_hide_internal_active_sh_assertion.sql
20260822153000_reconcile_journey_shared_helper_execution.sql
```

The four duplicate P1 files previously under `supabase/migrations/` were removed from that non-canonical location after verifying their contents and live semantics. This did not alter Supabase's migration catalog.

The three historical Journey shared-helper ACL migrations were not fabricated as separate historical repository files. Their final live state is represented by one canonical final-state reconciliation migration:

```text
runtime_journey_event_is_shared(uuid)
    authenticated = EXECUTE
    anon/public    = no EXECUTE
```

This is required by the authenticated `journey_events` visibility RLS policy.

## Runtime verification

Live Supabase function/catalog inspection confirmed:

```text
runtime_record_experience(...)
    INHERITABLE input → INHERITANCE persisted

runtime_assert_active_sh(uuid,text)
    authenticated/anon/public = no EXECUTE

runtime_journey_event_is_shared(uuid)
    authenticated = EXECUTE
    anon/public = no EXECUTE
```

## Safety rule

No remote migration history was deleted, renamed, replayed, or rewritten. No Phase 1–5 migration was replayed.

## Result

```text
Canonical source                     🟢
Non-canonical duplicate cleanup      🟢
Live Supabase semantics               🟢
Historical migration identity        🟢 preserved
Clean-room replay                    🟡 open evidence
```
