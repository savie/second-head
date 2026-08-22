# SECOND HEAD — SESSION RESUME 58

## Checkpoint

This resume continues the audit requested from commit `a1862392d1675eace336e75646d4d1da485a8467` through the current DEV head.

- Audit base: `a1862392d1675eace336e75646d4d1da485a8467`
- Backend: Supabase DEV `pkhkgvsrqeupvwoqjwmd`
- GitHub branch: `dev`
- Current continuity checkpoint: this file

## 1. Authority

Authority ordering remains:

```text
OWNER
  ↓
SH CORE CANONICAL
  ↓
CANONICAL ADDENDA / RATIFIED RECONCILIATIONS
  ↓
ARCHITECTURE / BUILD SCOPE / IMPLEMENTATION CONTRACT / GUIDE
  ↓
PHASE -1 / EXECUTION STRATEGY
  ↓
SESSION RESUME / STATE
  ↓
IMPLEMENTATION
  ↓
RUNTIME / E2E EVIDENCE
```

No Canonical concept was silently changed.

## 2. Audit scope

The audit covers the GitHub DEV implementation history from `a1862392d1675eace336e75646d4d1da485a8467` through the current DEV head, cross-checked against Session Resumes 55–58, Canonical/architecture/scope material, lifecycle reconciliation, Supabase DEV migration history, live function definitions, privileges, and live data semantics.

## 3. Confirmed lifecycle model

```text
INHERITANCE
  source SH = ACTIVE
  target SH = ACTIVE

SUCCESSION
  source SH = END-OF-LIFE / DEACTIVATED
  target = ACTIVE PRIMARY SH

LEGACY
  source SH = END-OF-LIFE / DEACTIVATED
  preservation only; no target SH is created

DEACTIVATED = END OF LIFE
  → no recovery restore
  → no record-policy mutation
```

## 4. Deterministic BE fixes completed

### 4.1 Recovery restore terminal guard

`runtime_restore_recovery_snapshot()` rejects restore when the snapshot SH is `DEACTIVATED`.

### 4.2 Terminal record-policy guard

`runtime_set_record_policy()` rejects policy mutation when the owning SH is `DEACTIVATED`.

### 4.3 Inherited policy immutability

Records carrying `inheritance_origin` cannot have their source-controlled transfer policy rewritten by the target SH.

### 4.4 Transfer Memory provenance

`memories.provenance` enables deterministic source/authorization tracing for transferred Memory.

### 4.5 Inheritance revoke/release

`runtime_revoke_inheritance_authorization(uuid)` is authenticated and source-owner controlled. Revocation removes only target-derived records tied to the authorization and retains source/original records.

The cleanup covers:

```text
Memory
Knowledge
Experience
Journey
```

Journey provenance includes the Inheritance authorization ID, and cleanup is performed by that deterministic identifier rather than content heuristics.

### 4.6 Clone revoke/release

`runtime_revoke_clone_agreement(uuid)` is authenticated and source-owner controlled. It revokes the Clone agreement/clone state and removes only Clone-derived Memory/Knowledge/Experience tied to the agreement provenance. Source records remain retained.

Clone currently does not materialize Journey as part of its derived-information path, so no artificial Journey cleanup rule was added.

### 4.7 Legacy EOL enforcement

Legacy preservation/transfer paths require an EOL/deactivated source SH. Legacy is not treated as an active operational transfer to a target SH.

### 4.8 Transfer-policy vocabulary

`INHERITANCE` is the established semantic value. `INHERITABLE` is retained only as a compatibility alias at the policy RPC boundary and normalized to `INHERITANCE`.

### 4.9 Journey lifecycle eligibility

Inheritance and Succession Journey transfers require lifecycle-matching transfer policy and reject `NON_TRANSFERABLE` selections.

## 5. Supabase ↔ GitHub migration parity

Live Supabase DEV migration history contains the P1 tail through:

```text
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
20260822055203 p1_lifecycle_transfer_policy_and_recovery_reconciliation
20260822055238 fix_legacy_eol_transfer_guard_v2
20260822055314 p1_reconcile_transfer_policy_vocabulary_and_journey_eligibility
20260822065752 p1_inheritance_revoke_journey_provenance_cleanup
20260822070005 p1_clone_revoke_release_cleanup
```

GitHub DEV carries the final two implementations as later reconciliation filenames:

```text
20260822142000_p1_inheritance_revoke_journey_provenance_cleanup.sql
20260822143000_p1_clone_revoke_release_cleanup.sql
```

This is intentional traceability reconciliation; historical Supabase migration versions are not fabricated or duplicated in GitHub merely to imitate past execution timestamps.

A dedicated parity note is tracked at:

`docs/reference/SECOND_HEAD_GITHUB_SUPABASE_MIGRATION_PARITY.md`

Status:

```text
Live Supabase runtime              🟢
GitHub semantic implementation     🟢 reconciled
Historical migration identity      🟡 intentionally not fabricated
Clean-room fresh replay            🟡 open evidence
```

## 6. Runtime/E2E evidence remains separate from BE closure

Still not promoted to PASS without authenticated runtime evidence:

- cross-account Experience visibility final fresh proof;
- authenticated Memory/Knowledge/Replacement roundtrip;
- Recovery fresh controlled E2E;
- Clone PRIMARY assertion;
- Clone non-transferable fresh re-test;
- unauthorized lifecycle attempts;
- remaining Memory/Knowledge canonical verification.

No device or authenticated E2E PASS is claimed from source inspection.

## 7. Owner decisions recorded

```text
DEACTIVATED = END OF LIFE
→ no recovery restore
→ no record-policy mutation

Inheritance
→ both SHs active

Succession
→ source SH already EOL/deactivated

Legacy
→ source SH already EOL/deactivated

Inherited information at SH-B
→ follows SH-A's source policy
→ SH-B does not rewrite that inherited policy

If SH-A releases/revokes an active Inheritance authorization
→ derived Memory / Knowledge / Experience / Journey at SH-B must be removed
→ SH-A originals remain
```

These are Owner decisions recorded because the available source material did not explicitly define every one of these lifecycle/release details.

## 8. Execution rule

Continue:

```text
Audit
  ↓
Canonical / reconciliation / resume / Supabase state comparison
  ↓
If deterministic and improves SH Core
  ↓
FIX
  ↓
GitHub ↔ Supabase reconcile
  ↓
RE-AUDIT
```

If the sources do not determine the intended semantics, stop and present an **OWNER DECISION REQUIRED** item in plain language rather than inventing behavior.
