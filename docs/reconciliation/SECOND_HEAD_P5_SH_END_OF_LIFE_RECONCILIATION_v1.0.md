# SECOND HEAD — P5 SH END-OF-LIFE RECONCILIATION v1.0

**Project:** SECOND HEAD — SYSTEM BUILD  
**Document Type:** Phase 5 Lifecycle Execution Reconciliation  
**Version:** v1.0  
**Status:** ACCEPTED FOR IMPLEMENTATION  
**Canonical Status:** NON-CANONICAL  
**Mutation:** NO CANONICAL MUTATION  

## 1. Purpose

This document records the Owner decision and implementation reconciliation for the lifecycle boundary of an Account and its SH when the Owner ends the active life of that SH.

It exists so future sessions and independent audits do not reopen the already-settled lifecycle semantic.

## 2. Owner Decision

The Owner selected the following model:

```text
ACCOUNT + SH
    ↓
ACTIVE LIFECYCLE
    ↓
OWNER END-OF-LIFE / DEACTIVATE
    ↓
ACCOUNT + SH remain permanently retained
    ↓
both become non-active
    ↓
identity / history / provenance remain available
    ↓
email remains permanently reserved
    ↓
email cannot create or claim another Account / SH
```

End-of-Life is **not deletion** and is **not reactivation**.

The Owner's human semantic is that an SH leaving the active lifecycle remains part of the historical identity record, while no longer participating as an active SH.

## 3. Relationship to Existing Identity Invariants

The existing identity model already establishes:

```text
1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH
```

`accounts.email` has a case-insensitive unique index. The Account row therefore remains the identity anchor and retains the email reservation after deactivation.

The new lifecycle realization does not create a second identity system and does not create a replacement Account for the same email.

## 4. Actual Schema Before Reconciliation

Existing `accounts` and `sh_instances` already contained a generic `status` field.

The audit found:

- no explicit End-of-Life state;
- no terminal deactivation RPC;
- no reactivation guard;
- no explicit deactivation timestamp;
- no mechanism connecting End-of-Life to the lifecycle boundary required by Succession.

Therefore the existing tables were reused rather than creating a new lifecycle table.

## 5. Minimal Realization

The DEV implementation adds:

### `accounts`

- `deactivated_at timestamptz`
- terminal status value: `deactivated`

### `sh_instances`

- `deactivated_at timestamptz`
- terminal status value: `deactivated`

### Runtime RPC

`runtime_end_of_life_sh(sh_id, reason)`:

1. resolves the SH through `current_account_id()`;
2. rejects SHs not owned by the authenticated Account;
3. is idempotent when the SH is already deactivated;
4. marks the SH `deactivated`;
5. records `deactivated_at`;
6. records a compact End-of-Life metadata record;
7. marks the owning Account `deactivated`;
8. leaves the Account row and email intact.

### Terminal guard

`prevent_identity_reactivation()` is attached to both `accounts` and `sh_instances`.

Once status is `deactivated`, a transition back to another status is rejected.

## 6. Email Reservation

No email-release mechanism is introduced.

The Account row remains permanently retained and the existing case-insensitive unique email index remains the reservation boundary.

Therefore:

```text
old Account
email = x@example.com
status = deactivated
        ↓
email remains occupied
        ↓
new Account using x@example.com
        ↓
REJECTED by existing identity uniqueness boundary
```

## 7. Privacy / History Boundary

End-of-Life does not delete:

- Account identity;
- SH identity;
- ownership history;
- Memory;
- Knowledge;
- Journey;
- provenance;
- historical records.

This document does **not** authorize any new cross-SH visibility. Existing RLS and ownership boundaries remain authoritative.

## 8. Recovery Relationship

Recovery remains distinct from End-of-Life.

```text
Recovery
= restore persistent state of the same SH

End-of-Life
= terminally leave the active SH lifecycle
```

No reactivation path is created by Recovery.

## 9. Succession Relationship

End-of-Life is now an explicit lifecycle boundary that Succession may use as its terminal trigger.

This reconciliation does **not** invent automatic transfer rules for Succession.

Succession remains selective: only state explicitly assigned to a successor may be transferred.

The next Succession implementation work must consume this lifecycle boundary rather than inventing a second definition of SH death/end-of-life.

## 10. Explicit Non-Goals

This reconciliation does not:

- delete Account or SH rows;
- release email addresses;
- reactivate deactivated identities;
- create a new lifecycle table;
- create a new identity system;
- automatically transfer all data to successors;
- define inheritance or clone semantics again;
- mutate the Canonical.

## 11. Verification Status

Schema verification in Supabase DEV confirmed the existing fields and identity structure before the migration.

The lifecycle migration was applied to Supabase DEV and mirrored in:

`supabase/migrations/20260819110000_p5_lifecycle_end_of_life_identity_boundary.sql`

GitHub DEV commit:

`6e1c71fa2a00b98b9335df211f22efbd3ff685d2`

The DEV environment currently had seven Accounts and seven SH instances, all with the pre-existing `created` status. No existing identity was deactivated by this reconciliation.

## 12. Current Disposition

**SH End-of-Life semantics:** 🟢 OWNER-RESOLVED  
**Existing schema reuse:** 🟢  
**Terminal deactivation RPC:** 🟢 IMPLEMENTED  
**Email retention:** 🟢 PRESERVED BY EXISTING IDENTITY MODEL  
**Reactivation prevention:** 🟢 IMPLEMENTED  
**Automatic Succession transfer:** 🟡 NEXT WORKSTREAM  
**Canonical mutation:** NONE  

## 13. Continuation Rule

Future audit sessions must not reopen the question:

> Should an ended SH be deleted or should its Account/email be released?

Owner decision is settled:

> **Account and SH remain permanently stored as identity/history; both become non-active; email remains permanently reserved and cannot create/claim a new Account/SH.**

Only a material contradiction with the authoritative chain may reopen this decision.
