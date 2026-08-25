# SECOND HEAD — SESSION RESUME 57

## Checkpoint

This resume supersedes Session Resume 56 as the latest continuity checkpoint.

- Previous resume: `SECOND_HEAD_SESSION_RESUME_56.md`
- Backend: Supabase DEV `pkhkgvsrqeupvwoqjwmd`
- Audit base: `a60eb3237f1bee48e050bc1d869e955a8d07337e`
- Pre-resume-57 implementation head: `0876110f059851bd6acd9a55228076e47e2bcda8`

## 1. Authority

Canonical authority remains unchanged.

- SH Core Canonical remains conceptual authority.
- Canonical architecture remains authoritative at its defined abstraction level.
- Build Scope, Implementation Contract, Implementation Guide, Phase -1 and Execution Strategy remain derived execution authorities.
- Session Resume is continuity state only and never overrides higher authority.
- No Owner decision was introduced in this reconciliation pass.

## 2. Audit scope

Audit covered the DEV implementation history from commit `a60eb3237f1bee48e050bc1d869e955a8d07337e` through the current DEV head, cross-checked against Canonical, architecture, scope, Phase -1, execution strategy, reconciliation records, Session Resume 56, GitHub migration history, and live Supabase DEV state.

## 3. Closed / reconciled since Resume 56

### 3.1 Terminal lifecycle and transfer security

- Terminal deactivation lifecycle guards reconciled.
- Succession source/target lifecycle semantics reconciled: deactivated source → active target.
- Inheritance remains active-source → active-target.
- Terminal accounts cannot materialize Clone SHs.

### 3.2 Experience context isolation

`list_experience_context(p_sh_id, ...)` now honors explicit SH scope while preserving GENERAL/SHARED visibility semantics. Private Experience from another SH is not included in an SH-scoped context request.

### 3.3 Inheritance replay/idempotency

Successful inheritance now consumes the authorization in the same transaction, preventing replay of an already executed authorization.

### 3.4 Runtime conversation lifecycle

Operational conversation writes now reject deactivated SH lifecycle state.

### 3.5 Security-definer client execution

The event-trigger infrastructure function `public.rls_auto_enable()` had residual API-role execution despite prior hardening. Final reconciliation revoked `PUBLIC`, `anon`, and `authenticated` execution and retained execution for `postgres` only.

### 3.6 Recovery restore idempotency

`runtime_restore_recovery_snapshot()` previously appended a new `RESTORED` recovery event and a new `RECOVERY` Journey event on every repeated restore call. Live DEV currently has one recovery event per snapshot and no snapshot has multiple recovery events.

A final idempotency migration now:

- enforces one `recovery_events` row per `snapshot_id`;
- prevents duplicate RECOVERY Journey events by `source_ref`;
- locks the snapshot during restore;
- returns the existing recovery event on repeat invocation instead of appending another outcome/event pair.

## 4. Current Supabase DEV migration tail

The current live tail includes:

```text
20260822021005 explicit_memory_replacement
20260822021024 semantic_persistence_atomicity
20260822021134 revoke_anon_semantic_mutation_execute
20260822033444 p1_terminal_lifecycle_security_reconciliation
20260822033544 p1_close_public_security_definer_grants
20260822033920 p1_journey_lifecycle_and_internal_runtime_acl
20260822033930 p1_revoke_client_event_trigger_execute
20260822035431 20260822110000_scope_experience_context_by_sh
20260822050952 inheritance_authorization_consume_on_success
20260822051302 p1_transfer_lifecycle_reconciliation_20260822050000
20260822051357 p1_clone_terminal_account_guard_20260822053000
20260822051922 p1_revoke_client_event_trigger_execute_final
20260822052048 p1_recovery_restore_idempotency
```

## 5. Security advisor disposition

The previous `anon SECURITY DEFINER` warning for `rls_auto_enable()` is now closed.

Remaining `authenticated SECURITY DEFINER` warnings are for exposed application/runtime RPC boundaries and are not automatically defects; they require function-level authorization review rather than blanket revocation.

RLS-enabled/no-policy INFO findings remain default-deny candidates and are not treated as defects without a contract requiring direct table policies.

## 6. Remaining open work

1. Fresh authenticated E2E for cross-account Experience visibility.
2. Fresh reproduction/evidence for prior Experience disappearance/visibility anomalies.
3. Experience → Memory semantic promotion behavior/evidence.
4. Full authenticated Memory/Knowledge/Replacement roundtrip.
5. Authenticated runtime regression for newly hardened SECURITY DEFINER paths.
6. Recovery restore lifecycle semantics for a terminal/deactivated SH remain a contract-level review item; no reactivation behavior has been introduced.
7. `runtime_set_record_policy` lifecycle behavior for terminal SH remains a contract-level review item; no mutation semantics were invented.

## 7. Explicit non-goals

- No Canonical concept changed.
- No Owner decision invented.
- No deletion/reactivation semantics changed.
- No FE feature was marked PASS based solely on source inspection.
- No device verification was claimed.

## 8. Execution rule

Continue with deterministic BE audit → fix → Supabase/GitHub reconcile → re-audit. Stop only where Canonical/reconciliation records do not determine the intended semantics.
