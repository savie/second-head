# SECOND HEAD — Privacy / Transfer Policy Reconciliation v1.0

**Canonical baseline:** `a60eb32`
**Canonical Addendum:** `SECOND_HEAD_SH_CORE_CANONICAL_ADDENDUM_PRIVACY_TRANSFER_POLICY_v1.0.md`
**Status:** Implementation reconciliation in progress

## Decision

```text
PRIVACY / VISIBILITY != TRANSFER ELIGIBILITY
```

Owner-visible private records remain discoverable by the owner. Lifecycle transfer is controlled by an explicit transfer policy plus authorization and explicit selection.

```text
PRIVATE
   ↓
owner can see
   ↓
transfer policy decides
   ├── NON_TRANSFERABLE → reject
   └── INHERITABLE / SUCCESSION / LEGACY
          ↓
       authorization
          ↓
       selected transfer
```

## BE / DB

Implemented on Supabase DEV:

- `memories.transfer_policy`
- `knowledge.transfer_policy`
- `experiences.transfer_policy`
- allowed values: `NON_TRANSFERABLE`, `INHERITABLE`, `SUCCESSION`, `LEGACY`
- existing rows receive deterministic `NON_TRANSFERABLE`
- `runtime_validate_selected_transfer_scope()` now validates transfer eligibility by `transfer_policy`, not by `PRIVATE` / `OWNER_ONLY`
- Experience creation accepts explicit transfer policy while retaining private/owner-only defaults
- `runtime_set_record_policy()` provides owner-scoped policy mutation for Memory, Knowledge, and Experience
- Knowledge private SELECT RLS was reconciled to `current_account_id()` so private owner visibility does not depend on `auth.uid()` being the account identifier

## FE

Implemented:

- Memory / Knowledge / Experience types now expose `transfer_policy`
- Inheritance selection filters by `INHERITABLE`
- Succession selection filters by `SUCCESSION`
- Legacy selection filters by `LEGACY`
- lifecycle selection no longer rejects a record merely because it is `PRIVATE` or `OWNER_ONLY`
- owner policy service is available through `setRecordPolicy()`

The dedicated owner-facing policy editor UI is not yet added; the service/API exists for controlled integration.

## Current DEV data after migration

- Memory: 4 rows, all `PRIVATE + OWNER_ONLY + NON_TRANSFERABLE`
- Knowledge: 3 `GENERAL + SHARED + NON_TRANSFERABLE`; 5 `PRIVATE + OWNER_ONLY + NON_TRANSFERABLE`
- Experience: 1 `PRIVATE + OWNER_ONLY + NON_TRANSFERABLE`

No existing records were mass-converted to public/shared.

## Verification status

- Supabase DEV migration applied successfully.
- Supabase DEV schema verified with transfer-policy columns and constraints.
- Supabase DEV RLS verified for owner visibility paths.
- CI verification: pending / must use actual workflow result as authority.
- APK: not required merely for this BE/DB change; current APK remains valid for server-side verification unless FE behavior under test requires a fresh build.
- Real E2E: pending. Must verify private + eligible transfer, private + non-transferable, shared/general + eligible transfer, authorization, explicit selection, and cross-SH denial.

## Safety rule

Do not mass-change:

```text
PRIVATE → GENERAL
OWNER_ONLY → SHARED
```

merely to make lifecycle transfer work.
