# SECOND HEAD — P5C SUCCESSION / END-OF-LIFE RECONCILIATION v1.0

**Project:** SECOND HEAD — SYSTEM BUILD  
**Document Type:** Phase 5C Execution Reconciliation / Addendum  
**Version:** v1.0  
**Status:** ACCEPTED FOR P5C EXECUTION  
**Canonical Status:** NON-CANONICAL  
**Mutation:** NO CANONICAL MUTATION  

---

## 1. Purpose

This reconciliation records the Owner-approved End-of-Life and Succession realization so future audits do not reopen the semantic question.

## 2. Owner Decision

An Account and its SH are permanent identity/history records. End-of-Life does not delete them.

At End-of-Life:

- Account becomes non-active.
- SH becomes non-active.
- identity/history/provenance remain preserved.
- the email remains permanently reserved.
- the Account/SH cannot be reactivated.
- the email cannot be used to create a new Account/SH.

This is a terminal lifecycle state, not deletion.

## 3. Succession Semantics

Succession is what may be received by another existing SH when the source SH reaches its End-of-Life condition.

Succession is selective.

A successor receives **only the explicitly selected scope**. Succession does not imply full private-state access.

Example:

- Knowledge X → Successor B
- Memory Y → Successor B
- Experience Z → Successor C
- private Memory Q → nobody

Therefore:

`SUCCESSOR ELIGIBILITY != FULL SOURCE ACCESS`

## 4. Relationship to Inheritance

Inheritance and Succession remain distinct:

- **Inheritance:** authorized transfer/derivation while the source SH may still be active.
- **Succession:** governance of selected state after the source SH reaches End-of-Life.
- **Legacy:** preserved selected material/history that may remain available after End-of-Life.
- **Clone:** creation of a new SH from initial transferred state; not an End-of-Life mechanism.

## 5. Existing Representation Reused

Existing `succession_rules` is retained as the governance/eligibility record.

Existing `memories` and `knowledge` are reused for selected materialization.

No replacement of the existing identity model was introduced.

A minimal `succession_events` table was added because no existing persistent event representation recorded the actual post-End-of-Life materialization.

## 6. Scope Contract

The first runtime realization uses explicit IDs:

```json
{
  "memory_ids": ["<memory uuid>", "..."],
  "knowledge_ids": ["<knowledge uuid>", "..."]
}
```

An empty list means nothing from that domain is transferred.

The runtime does not interpret an empty scope as "all".

## 7. Runtime Lifecycle

```text
Source SH ACTIVE
      ↓
Owner configures Succession Rule
      ↓
selected scope is stored
      ↓
Source reaches End-of-Life
      ↓
Account + SH become DEACTIVATED
      ↓
identity/history remain preserved
      ↓
Successor authenticates
      ↓
SUCCESSION RPC
      ↓
validate source is End-of-Life
validate caller is configured successor
validate successor has active PRIMARY SH
validate selected scope
      ↓
copy only selected Memory / Knowledge
      ↓
attach provenance
      ↓
record succession event
      ↓
consume succession rule
```

## 8. Security Boundary

The successor cannot execute another account's succession rule.

The RPC requires:

- authenticated caller;
- active succession rule;
- source SH already deactivated;
- caller account equals configured successor account;
- active PRIMARY SH exists for successor;
- explicit selected scope.

No source private data outside the selected scope is copied.

## 9. Candidate Semantics

If selected Memory or Knowledge is still in `CANDIDATE` lifecycle, the existing P5 transfer realization promotes it into the destination domain lifecycle during transfer, consistent with the previously reconciled Clone transfer semantics.

No new candidate promotion policy is introduced.

## 10. Runtime / Frontend Realization

Backend:

- `runtime_end_of_life_sh`
- `runtime_execute_succession`

Service:

- `executeSuccession()`

Runtime UI:

- create Succession Rule with explicit scope JSON;
- display rules;
- configured successor can execute the selected succession.

## 11. Verification Boundary

The schema/RPC/service/UI wiring is now present in DEV.

Full authenticated multi-account E2E remains a runtime test item and is not claimed PASS by this document.

## 12. Non-Goals

This realization does not:

- delete Account or SH;
- reactivate End-of-Life identities;
- transfer all private state;
- replace Inheritance;
- replace Legacy;
- create a new SH identity for the successor;
- make the successor become the source SH.

---

**End of Reconciliation**
