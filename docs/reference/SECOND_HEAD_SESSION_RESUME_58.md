# SECOND HEAD — SESSION RESUME 58

## Checkpoint

This resume continues the audit requested from commit `a1862392d1675eace336e75646d4d1da485a8467` through the current DEV head.

- Audit base: `a1862392d1675eace336e75646d4d1da485a8467`
- Pre-audit checkpoint: `a5f09b8a9c1b8d01a927d50263249c6bb77846c2`
- Backend: Supabase DEV `pkhkgvsrqeupvwoqjwmd`
- GitHub branch: `dev`

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

The GitHub comparison from `a186239...` to the pre-resume-57 head contained 105 commits. The audit cross-checked the commit history, Session Resume 55, Session Resume 56, Session Resume 57, the current Canonical Matrix, the Privacy/Transfer Canonical Addendum, lifecycle reconciliation documents, Supabase DEV function definitions, privileges, and live data semantics.

## 3. Confirmed lifecycle model

The current implementation and the Owner clarification are reconciled as:

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
```

The Resume 57 implementation already explicitly recorded Inheritance as active-source → active-target and Succession as deactivated-source → active-target. The Owner clarification in this session establishes the same EOL rule for Legacy.

## 4. Deterministic BE fixes in this pass

### 4.1 Recovery restore on terminal SH

`runtime_restore_recovery_snapshot()` now rejects restore when the snapshot's SH is `DEACTIVATED`.

Result:

```text
DEACTIVATED / EOL
  ↓
restore snapshot
  ↓
REJECTED
```

No reactivation semantics were introduced.

### 4.2 Record policy mutation on terminal SH

`runtime_set_record_policy()` now rejects policy mutation when the owning SH is `DEACTIVATED`.

### 4.3 Inherited record policy

`runtime_set_record_policy()` now rejects policy mutation for records carrying `inheritance_origin` provenance.

The inherited target therefore follows the source SH's transfer policy; the target cannot rewrite the source-controlled inheritance policy.

### 4.4 Memory provenance

`memories.provenance` was added so transferred Memory rows can be traced deterministically. Inheritance-created Memory records carry `inheritance_origin` including the source SH and authorization ID. Clone/Succession Memory materialization is also provenance-traceable.

### 4.5 Inheritance release/revoke

Added authenticated owner-authorized `runtime_revoke_inheritance_authorization(uuid)`.

For an APPROVED or CONSUMED authorization, it removes only target-derived Memory, Knowledge, and Experience rows whose provenance points to that authorization, then marks the authorization `REVOKED` with `revoked_at`.

The source records remain untouched.

Privileges:

```text
anon = false
public = false

 authenticated = true
```

### 4.6 Legacy EOL enforcement

Both Journey-based Legacy preservation and transfer-based Legacy validation now require the source SH to be `DEACTIVATED` / EOL. Transfer-based Legacy also explicitly checks source ownership.

### 4.7 Transfer-policy vocabulary

The established semantic value is `INHERITANCE`. `INHERITABLE` is accepted only as a compatibility alias and normalized to `INHERITANCE` by the policy mutation RPC.

### 4.8 Journey lifecycle eligibility

Inheritance and Succession Journey transfer now require the selected Journey event's `transfer_policy` to match the lifecycle operation. `NON_TRANSFERABLE` remains rejected.

## 5. Existing reconciled fixes carried forward

From Resume 57:

- terminal account/session lifecycle hardening;
- Succession source/target lifecycle reconciliation;
- terminal account Clone materialization guard;
- SH-scoped Experience context retrieval;
- Inheritance authorization consumption on success;
- operational conversation deactivation guard;
- `rls_auto_enable()` client execution closure;
- Recovery restore idempotency;
- remaining security-definer privilege hardening.

## 6. Canonical/E2E status remains separate from BE closure

The Canonical Matrix still contains open runtime evidence, including:

- cross-account Experience visibility final fresh proof;
- authenticated Memory/Knowledge/Replacement roundtrip;
- Recovery fresh controlled E2E;
- Clone PRIMARY assertion;
- Clone non-transferable fresh re-test;
- unauthorized lifecycle attempts;
- remaining Memory/Knowledge canonical verification.

No source inspection is promoted to Real E2E PASS.

## 7. Owner Decision recorded in this resume

Owner explicitly clarified during this session:

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
→ derived Memory / Knowledge / Experience at SH-B must be removed
→ SH-A originals remain
```

This is an Owner decision recorded here because the available source material did not explicitly define every one of these lifecycle/release details.

## 8. Next execution rule

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
