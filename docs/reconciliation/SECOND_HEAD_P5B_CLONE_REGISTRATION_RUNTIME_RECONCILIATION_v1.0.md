# SECOND HEAD — P5B CLONE REGISTRATION RUNTIME RECONCILIATION v1.0

**Project:** SECOND HEAD — SYSTEM BUILD  
**Document Type:** P5B Execution Reconciliation / Runtime Addendum  
**Version:** v1.0  
**Status:** ACCEPTED FOR DEV EXECUTION  
**Canonical Status:** NON-CANONICAL  
**Mutation:** NO CANONICAL MUTATION  
**Scope:** Clone email-only registration, identity provisioning, runtime materialization, privilege boundary

---

## 1. Purpose

This document records the final reconciliation discovered during the backend ↔ frontend functional audit before APK build.

The Owner-approved Clone semantics are already settled:

```text
A
↓
create Clone intent for B email
↓
approve
↓
B does not have an Account/SH yet
↓
B registers
↓
Account B exists
↓
Clone materialization
↓
Clone becomes B PRIMARY SH
```

This document does not alter Canonical semantics. It reconciles the implementation so the actual runtime follows that semantics.

---

## 2. Finding

The audit found that the auth identity provisioning function could materialize a Clone SH directly during `auth.users` provisioning when an approved Clone agreement existed.

That path created the Clone SH before `runtime_materialize_registered_clone()` ran.

The transactional Clone worker `runtime_create_clone()` intentionally rejects a target account that already has an SH.

Therefore the sequence could become:

```text
B registration
↓
auth provisioning
↓
Clone SH created
↓
AuthProvider bootstrap
↓
runtime_materialize_registered_clone()
↓
runtime_create_clone()
↓
REJECTED: target account already has an SH
```

More importantly, the direct auth-provisioning path did not execute the complete Clone state-transfer transaction for Memory and Knowledge.

This was a real backend/runtime wiring contradiction, not an Owner Decision gap.

---

## 3. Reconciliation Decision

Identity provisioning is split into two cases.

### Normal registration

```text
auth.users
↓
Account
↓
PRIMARY SH
↓
OWNER
```

### Approved Clone recipient registration

```text
auth.users
↓
Account
↓
NO SH YET
↓
AuthProvider bootstrap
↓
runtime_materialize_registered_clone()
↓
runtime_create_clone()
↓
Clone PRIMARY SH
+
Clone ownership
+
Clone provenance
+
Memory transfer
+
Knowledge transfer
+
Agreement linkage
```

This preserves:

```text
1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH
```

while also preserving the Owner-approved email-only recipient model.

---

## 4. Frontend Realization

`AuthProvider` already invokes:

```text
runtime_materialize_registered_clone()
```

after authenticated account context is loaded.

Therefore no new frontend Clone button or manual materialization path is required.

The correct lifecycle is:

```text
A creates/approves
↓
B registers
↓
AuthProvider bootstrap
↓
automatic Clone materialization
```

The old direct `executeClone()` service path is no longer part of the frontend lifecycle.

---

## 5. Transactional Worker

`runtime_create_clone()` remains the transactional Clone worker.

Its existing boundary requires:

- authenticated caller;
- resolved target Account;
- approved agreement;
- valid source SH ownership;
- source and target accounts differ;
- recipient email matches intended email;
- target account has no SH;
- Clone SH is created as `PRIMARY`;
- Clone ownership is created;
- `sh_clones` provenance is created;
- Memory is copied to the new SH;
- Candidate Memory becomes destination Memory state;
- Knowledge is copied with Clone provenance;
- Candidate Knowledge becomes destination Knowledge state;
- source Conversation is not copied;
- source Journey is not copied;
- agreement is linked to target Account.

---

## 6. Privilege Reconciliation

The audit also found that the internal Clone worker had been executable by `authenticated`, and the registration materialization function had `anon` execute privilege.

Final boundary:

```text
runtime_materialize_registered_clone()
    authenticated: EXECUTE
    anon:           NO EXECUTE

runtime_create_clone(uuid,text)
    authenticated: NO EXECUTE
    anon:           NO EXECUTE
    PUBLIC:         NO EXECUTE
```

`runtime_create_clone()` is now an internal transactional worker invoked by the security-definer materialization function.

This prevents a client from bypassing the intended registration/bootstrap lifecycle.

---

## 7. Existing Semantics Preserved

No change was made to the Owner decisions:

```text
Clone recipient may be email-only.
Target does not need an existing SH.
Registration claims the approved Clone intent.
Clone becomes the target Account's PRIMARY SH.
Memory transfers.
Knowledge transfers.
Candidate Memory becomes Memory.
Candidate Knowledge becomes Knowledge.
Context / Reference / Traits are initial Clone state/bekal.
Conversation does not transfer.
Source Journey does not transfer.
Clone has independent identity, Conversation and Journey.
```

---

## 8. DEV State Notes

The DEV database currently contains historical/test Clone agreement rows and Accounts/SHs from earlier experiments.

Those rows are not treated as proof of the final Model B E2E flow.

In particular, an existing Account/SH cannot be reused as the new email-only recipient test case because the final Clone invariant explicitly requires the recipient to have no SH before materialization.

No destructive cleanup was performed as part of this reconciliation.

---

## 9. Verification

Verified after migration:

```text
provision_identity_for_auth_subject()
→ approved Clone recipient creates Account without SH
→ normal recipient still receives normal PRIMARY SH

runtime_materialize_registered_clone()
→ authenticated EXECUTE
→ anon EXECUTE revoked

runtime_create_clone()
→ authenticated EXECUTE revoked
→ anon EXECUTE revoked
```

The DEV migration ledger contains the reconciliation migration.

---

## 10. Status

```text
Semantics              🟢 OWNER-RESOLVED
Identity model         🟢 RECONCILED
Clone worker           🟢 PRESENT
State transfer         🟢 PRESENT
Registration trigger   🟢 WIRED
Privilege boundary     🟢 HARDENED
Frontend lifecycle     🟢 WIRED
Single-device E2E       🟡 PENDING
APK verification       ⏳ PENDING
```

---

## 11. Next Step

Do not reopen Clone identity semantics.

Continue the final backend ↔ frontend functional audit, then build the APK only after the remaining domain wiring and verification gates are closed.

---

**END OF DOCUMENT**
