# SECOND HEAD — P5B CLONE EXECUTION RECONCILIATION v1.0

Project: SECOND HEAD — SYSTEM BUILD  
Document Type: P5B Clone Execution Reconciliation / Addendum  
Version: v1.0  
Status: ACCEPTED FOR P5B RECONCILIATION & EXECUTION  
Canonical Status: NON-CANONICAL  
Mutation: NO CANONICAL MUTATION

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

The current implementation realizes Clone using an existing target Account:

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

The current implementation also represents the target through `target_account_id`, whereas the resolved semantics allow the target to begin as an email-only intended recipient.

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

### 3.1 Current — REJECTED REALIZATION

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

P5B Clone must reconcile with that identity lifecycle rather than create a second, non-primary SH for a newly registered recipient.

The intended Clone registration lifecycle is therefore:

```text
INTENDED RECIPIENT
(email only)
      ↓
PENDING CLONE INVITATION
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

The existing realization uses `target_account_id` as a prerequisite for Clone agreement creation. This is incompatible with the Owner-accepted email-only recipient model.

The reconciled target representation must support, at minimum:

```text
target_email
pending / intended-recipient state
target_account_id only after registration/linkage
```

The exact schema shape, invitation-token mechanism, expiry/revocation details, and registration-claim mechanism are implementation details to be reconciled against the existing identity and authorization architecture before mutation.

No unsupported mechanism is prescribed by this document.

---

## 6. Clone Materialization Trigger

Clone materialization must not depend on the target already having an SH.

The intended lifecycle is:

```text
approved Clone intent
↓
recipient claims / registers identity
↓
resolve intended recipient
↓
create or link target Account
↓
materialize Clone SH as target PRIMARY SH
↓
create ownership
↓
record Clone provenance
```

The existing `runtime_create_clone()` path must therefore be reconciled. It may be replaced, narrowed to an internal materialization primitive, or otherwise adapted; no specific implementation choice is mandated until its current callers and dependency boundaries are verified.

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

The implementation must preserve explicit authorization and must not silently grant the source permanent access to the target's private state.

---

## 8. Provenance and Privacy Boundary

The following remain required:

```text
Clone SH != Source SH
Source provenance is preserved
Target ownership is explicit
Privacy remains default-deny
Source authorization does not imply unrestricted access to target private state
```

Existing provenance and RLS mechanisms should be reused or reconciled rather than duplicated without need.

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

The implementation workstream must reconcile at least:

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

The old existing-account / non-primary-Clone path must not remain the effective P5B semantics after reconciliation.

---

## 11. Migration / Compatibility Considerations

Current DEV is clean for the P5 tables according to the current audit evidence. The reconciliation therefore targets the implementation model rather than a migration of known production Clone records.

Any migration must be designed to be safe for the actual DEV schema and must preserve unrelated P1–P5 behavior.

No data mutation is authorized by this document alone.

---

## 12. Acceptance Criteria

P5B Clone reconciliation is implementation-ready when:

- [ ] Target may be represented without an existing Account.
- [ ] Target identity is tied to intended-recipient email.
- [ ] A pending Clone agreement/invitation can exist before registration.
- [ ] Recipient registration can claim/link the intended Clone.
- [ ] Account creation remains compliant with P1 identity semantics.
- [ ] The resulting Clone SH is the target Account's PRIMARY SH.
- [ ] No duplicate PRIMARY SH can be created.
- [ ] Clone SH != Source SH.
- [ ] Ownership is correctly established.
- [ ] Provenance is preserved.
- [ ] Privacy boundaries remain enforced.
- [ ] The obsolete existing-account / non-primary Clone path is removed or fully reconciled.
- [ ] Full authenticated multi-account E2E is subsequently verified.

---

## 13. Non-Goals

This reconciliation does not:

- mutate SH Canonical;
- redefine P1 identity semantics beyond the Owner-resolved Clone registration realization;
- finalize the complete Clone state-transfer payload;
- authorize production data migration;
- claim authenticated E2E success before testing is performed;
- authorize implementation mutation without subsequent code/schema review.

---

## 14. Status

```text
P5B Clone target semantics       OWNER DECISION LOCKED
Target registration model        OWNER DECISION LOCKED
Primary SH semantics             OWNER DECISION LOCKED
Current implementation           REJECTED REALIZATION
Target implementation            ACCEPTED FOR RECONCILIATION
Canonical                        UNCHANGED
Mutation                         NONE
Next                             Implementation reconciliation → audit → E2E verification
```

---

## 15. Session Handoff Note

A future session or independent auditor should treat this document as the current P5B Clone reconciliation record.

Do not reopen the rejected question of whether the target must already have an Account unless a higher-authority document explicitly contradicts this Owner Decision.

Do not reinterpret `is_primary = false` as the intended final Clone semantics. The Owner has resolved that the Clone SH becomes the target Account's PRIMARY SH.

If a detail is not specified here and is also absent from the applicable authority chain, classify it as **OPEN** or request an Owner Decision rather than inventing semantics.
