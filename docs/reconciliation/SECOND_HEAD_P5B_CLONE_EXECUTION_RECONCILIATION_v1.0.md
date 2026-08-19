# SECOND HEAD — P5B CLONE EXECUTION RECONCILIATION v1.0

Project: SECOND HEAD — SYSTEM BUILD  
Document Type: P5B Clone Execution Reconciliation / Addendum  
Version: v1.0  
Status: ACCEPTED FOR P5B RECONCILIATION & EXECUTION  
Canonical Status: NON-CANONICAL  
Canonical Mutation: NONE

## Authority Context

```text
SH Core Canonical
→ Build Scope
→ Implementation Guide
→ Implementation Contract
→ Execution Strategy
→ Phase -1
→ P1 Identity Semantics
→ P5B Clone Semantics
→ Actual GitHub / Supabase Implementation
→ Owner Decisions recorded in this reconciliation
```

This document records the reconciliation of the current P5B Clone implementation with the resolved Owner semantics. It does not replace or mutate the SH Canonical.

---

## 1. Reconciliation Trigger

The previous implementation realized Clone using an existing target Account:

```text
A / Source
↓
existing B Account
↓
B has no SH
↓
create Clone SH
↓
is_primary = false
```

This realization is rejected by the Owner.

It does not represent the intended P5B Clone semantics.

The previous implementation also represented the target through `target_account_id` as a prerequisite, whereas the resolved semantics allow the target to begin as an email-only intended recipient.

---

## 2. OWNER DECISIONS — LOCKED

The Owner resolves P5B Clone semantics as follows:

1. The target recipient does **not** need an existing Account when the Clone agreement/invitation is created.
2. The target begins as an **email-only intended recipient**.
3. A Clone agreement/invitation may exist before target registration.
4. The intended recipient registers using the relevant recipient identity/email.
5. Registration establishes or links the target Account according to P1 identity rules.
6. Clone materialization occurs as part of, or immediately following, successful registration linkage.
7. The resulting Clone SH becomes the target Account's **PRIMARY SH**.
8. Therefore the resolved identity invariant for the resulting registered target is:

```text
1 EMAIL
=
1 ACCOUNT
=
1 PRIMARY SH
```

9. The Clone SH remains distinct from the Source SH.
10. Source provenance and privacy boundaries remain preserved.
11. The previously implemented model in which an already-existing target Account receives a non-primary Clone SH is rejected as an obsolete realization.

These are **OWNER DECISIONS recorded by this reconciliation**. They do not modify the Canonical document itself.

---

## 3. Current Implementation vs Target Realization

### 3.1 Previous — REJECTED REALIZATION

```text
Target Account required
↓
target_account_id required
↓
Target Account exists
↓
Target has no SH
↓
runtime_create_clone()
↓
Clone SH
↓
is_primary = false
```

Status: **OBSOLETE / REJECTED REALIZATION**.

### 3.2 Target — OWNER-ACCEPTED REALIZATION

```text
Target email
↓
Clone invitation / agreement
↓
Source approval
↓
Recipient registration
↓
Account creation / linkage
↓
Clone materialization
↓
Clone SH
↓
is_primary = true
↓
PRIMARY SH of target Account
```

Status: **OWNER-ACCEPTED TARGET REALIZATION**.

---

## 4. Identity and Registration Reconciliation

The P1 identity implementation provisions a normal registered identity as:

```text
auth subject
↓
Account
↓
PRIMARY SH
↓
OWNER
```

P5B Clone now reconciles with that identity lifecycle rather than create a second, non-primary SH for a newly registered recipient.

The intended Clone registration lifecycle is therefore:

```text
INTENDED RECIPIENT
(email only)
      ↓
PENDING CLONE INVITATION
      ↓
Source approval
      ↓
recipient registration
      ↓
ACCOUNT B
      ↓
PRIMARY CLONE SH
      ↓
OWNER = B
```

The implementation must prevent duplicate Primary SH creation while preserving the P1 invariant.

---

## 5. Clone Agreement / Target Representation

The reconciled target representation supports:

```text
target_email
pending / intended-recipient state
target_account_id = NULL before registration

target_account_id = B after successful registration linkage
```

The current implementation uses a unique pending/approved email boundary so an unregistered recipient cannot have multiple active Clone intents competing for the same email.

Invitation-token delivery, expiry, and external email delivery remain outside the present implementation claim unless separately defined by the applicable authority.

---

## 6. Clone Materialization Trigger

Clone materialization no longer depends on the target already having an SH.

The implementation lifecycle is:

```text
approved Clone intent
↓
recipient registers with intended email
↓
identity provisioning resolves approved Clone intent
↓
create target Account
↓
materialize Clone SH as target PRIMARY SH
↓
create ownership
↓
record Clone provenance
↓
link target_account_id to agreement
```

The old `runtime_create_clone()` path has been retained only as a compatibility symbol and now fails closed with the reconciled lifecycle message. It is no longer the materialization path.

---

## 7. Actor Model

The source is the party authorizing the creation of the Clone relationship. The recipient is the intended future owner of the resulting Clone SH.

Resolved conceptual flow:

```text
A = Source / authorizing owner
B = intended recipient

A
↓
create Clone invitation/agreement for B's email
↓
approval
↓
B registers
↓
Clone becomes B's PRIMARY SH
```

The implementation preserves explicit source authorization and does not grant the source permanent ownership of the target's private state.

---

## 8. Provenance and Privacy Boundary

The following remain required and are represented by the implementation:

```text
Clone SH != Source SH
Source provenance is preserved
Target ownership is explicit
Privacy remains default-deny
Source authorization does not imply unrestricted access to target private state
```

Existing provenance and RLS mechanisms are reused/reconciled rather than introducing a second ownership model.

---

## 9. Clone State Transfer — OPEN

This reconciliation resolves **target identity, registration semantics, and Primary SH semantics**.

It does **not** by itself finalize the complete transferable state payload.

The following remain subject to authority reconciliation and, where the authority chain provides no definitive answer, explicit Owner Decision:

- Memory
- Knowledge
- Candidate
- Journey
- Conversation
- Context
- Other transferable state

No unsupported transfer semantics shall be invented during implementation.

The distinction between candidate state and promoted Knowledge/Memory must remain consistent with the existing SH semantics and must not be collapsed merely because the Clone is materialized.

---

## 10. Implementation Reconciliation Requirements

The implementation workstream has reconciled:

- `clone_agreements` target representation
- email-only intended recipient
- pending invitation/agreement state
- recipient registration linkage
- target Account creation/linkage
- Clone materialization trigger
- PRIMARY SH creation
- ownership creation
- provenance linkage
- privacy / RLS boundary
- existing `runtime_create_clone()` path
- Clone frontend flow
- error and lifecycle observability

The old existing-account / non-primary-Clone path is no longer the effective P5B semantics in the updated implementation.

---

## 11. Implementation Artifacts

The reconciliation implementation is committed on `dev` as:

```text
supabase/migrations/20260819100000_p5b_clone_email_registration_reconciliation.sql
supabase/migrations/20260819110000_p5b_clone_email_invitation_hardening.sql
app/features/clone/clone-service.ts
app/app/clone.tsx
```

The migration was applied to Supabase DEV.

Implementation commits:

```text
8fed572d19281fe88391ddc35d53e879434aca4b
337cb22465ea115d1b666153381e1a611f37e931
9f53a937985b7aef8315a96a8b817fe44584340e
edfba24516d5f795256159bfec9a639033988bb9
```

The reconciliation document itself was subsequently updated to record this implementation status.

---

## 12. Verification Performed

Supabase DEV verification has confirmed:

- `clone_agreements.target_email` exists and is required.
- `target_account_id` is nullable before registration.
- Pending/approved unregistered target emails have a uniqueness boundary.
- Source-side insert policy now requires the authenticated source account and an email-only target.
- The old direct Clone RPC no longer materializes the obsolete non-primary Clone path.
- A transactional synthetic registration test successfully materialized:
  - a new target Account,
  - a `CLONE` SH,
  - `is_primary = true`,
  - OWNER ownership,
  - `sh_clones` provenance,
  - and `clone_agreements.target_account_id` linkage.
- The same transactional test was rolled back; DEV contains no residual test rows.
- A separate transactional normal-registration test still materialized a normal `PRIMARY` SH and was rolled back.

Authenticated real-device multi-account E2E has **not** yet been claimed as PASS.

---

## 13. Migration / Compatibility Considerations

Current DEV was clean for the P5 Clone tables before this reconciliation. No known production Clone records required migration.

The new target lifecycle is designed to preserve the P1 identity invariant while changing the P5B realization from existing-account/non-primary to email-recipient/primary-Clone.

The old `runtime_create_clone()` entry point is retained as a fail-closed compatibility symbol so stale clients cannot silently recreate the rejected semantics.

No production data migration is authorized by this document.

---

## 14. Acceptance Criteria

P5B Clone reconciliation is implementation-ready when:

- [x] Target may be represented without an existing Account.
- [x] Target identity is tied to intended-recipient email.
- [x] A pending Clone agreement/invitation can exist before registration.
- [x] Recipient registration can claim/link the intended Clone.
- [x] Account creation remains compliant with P1 identity semantics.
- [x] The resulting Clone SH is the target Account's PRIMARY SH.
- [x] No duplicate PRIMARY SH can be created by the Clone registration path.
- [x] Clone SH != Source SH.
- [x] Ownership is correctly established.
- [x] Provenance is preserved.
- [x] Privacy boundaries remain enforced by the existing participant RLS model.
- [x] The obsolete existing-account / non-primary Clone path is removed from the effective flow.
- [ ] Full authenticated multi-account E2E is subsequently verified.
- [ ] Complete transferable state payload is reconciled and verified.

---

## 15. Non-Goals

This reconciliation does not:

- mutate SH Canonical;
- redefine P1 identity semantics beyond the Owner-resolved Clone registration realization;
- finalize the complete Clone state-transfer payload;
- authorize production data migration;
- claim authenticated E2E success before testing is performed;
- claim the external email delivery/invitation transport is implemented;
- authorize unrelated P5/P6 changes.

---

## 16. Status

```text
P5B Clone target semantics       OWNER DECISION LOCKED
Target registration model        OWNER DECISION LOCKED
Primary SH semantics             OWNER DECISION LOCKED
Previous implementation          REJECTED REALIZATION
Current implementation           RECONCILED
Canonical                        UNCHANGED
Canonical mutation               NONE
Implementation mutation          APPLIED TO DEV + COMMITTED ON dev
Runtime E2E                       PENDING
Transfer-state semantics         OPEN
P6                                 PARKED
```

---

## 17. Session Handoff Note

A future session or independent auditor should treat this document as the current P5B Clone reconciliation record.

Do not reopen the rejected question of whether the target must already have an Account unless a higher-authority document explicitly contradicts this Owner Decision.

Do not reinterpret `is_primary = false` as the intended final Clone semantics. The Owner has resolved that the Clone SH becomes the target Account's PRIMARY SH.

The current implementation has already been reconciled to that decision on `dev`. The next work is **authenticated multi-account E2E and complete Clone state-transfer reconciliation**, not another identity-semantics debate.

If a detail is not specified here and is also absent from the applicable authority chain, classify it as **OPEN** or request an Owner Decision rather than inventing semantics.
