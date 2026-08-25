# SECOND HEAD — SH CORE CANONICAL ADDENDUM v1.0
## Privacy, Visibility & Transfer Policy Semantics

**Status:** Canonical Addendum
**Parent authority:** SH Core Canonical
**Canonical reference baseline:** `a60eb32`
**Authority model:** Owner instruction remains highest authority. This document is a canonical extension of SH Core Canonical and governs the semantic area explicitly defined here. It does not replace or contradict SH Core Canonical.

---

## 1. Purpose

This addendum closes a semantic gap identified during implementation and verification:

> **PRIVACY / VISIBILITY IS NOT THE SAME THING AS TRANSFER ELIGIBILITY.**

A record being private does not mean that it can never participate in an authorized lifecycle transfer.

The implementation MUST NOT infer `NON_TRANSFERABLE` solely from `PRIVATE` scope or `OWNER_ONLY` visibility.

---

## 2. Core Rule

The canonical relationship is:

```text
PRIVACY / VISIBILITY
        !=
TRANSFER ELIGIBILITY
```

Privacy/scope answers:

> Who may view or access this record under the applicable authorization boundary?

Transfer policy answers:

> May this selected record participate in an authorized lifecycle transfer, and under which lifecycle mechanism?

These concerns MUST remain separate in the data model, BE enforcement, FE semantics, and verification tests.

---

## 3. Current Incorrect Implementation Semantics

The implementation identified during audit effectively behaved as:

```text
CURRENT
PRIVATE
   ↓
transfer rejected
```

This is too restrictive because it conflates the privacy boundary with transfer eligibility.

The same applies to `OWNER_ONLY` when it is used as an automatic transfer rejection condition.

---

## 4. Target Canonical Semantics

The target behavior is:

```text
TARGET
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

This applies conceptually to Memory, Knowledge, and Experience where lifecycle transfer is supported.

---

## 5. Privacy / Visibility Semantics

### 5.1 Private

`PRIVATE` is a privacy boundary. It does not mean the owner cannot see or manage the record.

For the owner, private records MUST remain discoverable through the appropriate owner-scoped product surfaces unless another canonical rule explicitly limits that surface.

`PRIVATE` MUST NOT be interpreted as:

```text
never visible to owner
never selectable by owner
never transferable under any circumstance
```

### 5.2 Shared / General

Where the existing canonical model uses `GENERAL` and/or `SHARED`, those values describe broader visibility/access semantics. They MUST NOT by themselves imply a transfer policy.

A shared/general record can still be non-transferable.

---

## 6. Transfer Policy Semantics

Transfer eligibility MUST be represented and enforced independently from privacy/visibility.

At minimum, the implementation must be capable of representing the semantic distinction between:

```text
NON_TRANSFERABLE
INHERITABLE
SUCCESSION
LEGACY
```

The final storage/API enum or representation MUST follow the established project contract; this addendum defines the semantic separation, not an excuse to introduce arbitrary incompatible enum names.

A transfer policy determines whether a selected record may participate in a specific lifecycle operation.

---

## 7. Authorization Requirement

Private data MUST NOT become accessible to another SH merely because a transfer policy exists.

The required sequence is:

```text
record
  ↓
transfer policy permits operation
  ↓
authorized lifecycle operation
  ↓
valid authorization
  ↓
explicit selection
  ↓
transfer
```

There MUST be no automatic private-data access across SH boundaries.

---

## 8. Selected Transfer Only

Inheritance, Succession, and Legacy MUST operate on explicitly selected eligible records according to the applicable lifecycle contract.

The system MUST NOT interpret authorization for a lifecycle operation as authorization to expose or transfer all private data.

---

## 9. FE Requirements

The FE MUST NOT communicate the following false equivalence:

```text
PRIVATE = cannot transfer
```

Owner-facing surfaces SHOULD allow the owner to distinguish, where the product surface supports it:

```text
Visibility / Scope
Transfer Eligibility / Policy
```

The FE MUST NOT hide an owner-owned private record merely because it is private, unless a separate canonical surface rule requires hiding it.

Lifecycle selection surfaces MUST show only records that are actually eligible for that lifecycle operation after policy and authorization checks.

---

## 10. BE Requirements

BE enforcement MUST preserve the privacy boundary while evaluating transfer policy independently.

The following pattern is prohibited as the sole transfer rule:

```text
if scope == PRIVATE:
    reject transfer
```

Likewise, this is prohibited as the sole rule:

```text
if visibility == OWNER_ONLY:
    reject transfer
```

The correct enforcement model is conceptually:

```text
privacy/access check
        ↓
transfer-policy check
        ↓
authorization check
        ↓
explicit selected-record check
        ↓
perform lifecycle transfer
```

---

## 11. Existing Data / Migration Safety

Existing records MUST NOT be mass-converted from private to public merely to make lifecycle transfer work.

In particular, the implementation MUST NOT solve this semantic gap by blindly changing:

```text
PRIVATE → GENERAL
OWNER_ONLY → SHARED
```

Existing records require a deterministic transfer-policy treatment consistent with the canonical contract and migration safety requirements.

Any default introduced for legacy rows MUST be explicit, deterministic, documented, and verified.

---

## 12. Scope of This Addendum

This addendum applies to:

- Memory
- Knowledge
- Experience
- Inheritance
- Succession
- Legacy
- Related FE selection/display semantics
- Related BE authorization/transfer enforcement
- Related database/RLS/migration behavior
- Related CI and Real E2E verification

It does not redefine unrelated SH lifecycle semantics.

---

## 13. Verification Requirements

Implementation is not considered complete merely because the schema accepts public/private values.

Verification MUST eventually cover at least these semantic combinations:

```text
PRIVATE + NON_TRANSFERABLE
PRIVATE + INHERITABLE
PRIVATE + SUCCESSION
PRIVATE + LEGACY

SHARED/GENERAL + NON_TRANSFERABLE
SHARED/GENERAL + applicable transfer policy
```

Each applicable lifecycle operation must verify:

1. owner visibility;
2. policy eligibility;
3. authorization;
4. selected-record restriction;
5. no unauthorized cross-SH access;
6. correct resulting lifecycle state.

CI PASS does not by itself constitute Real E2E PASS where the canonical matrix requires fresh APK/runtime evidence.

---

## 14. Canonical Decision

The following is the project decision established by this addendum:

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

Therefore:

> **Privacy is a boundary. Transfer policy is a separate capability decision.**

This distinction MUST be preserved across future BE, FE, database, CI, APK, and Real E2E work.

---

## 15. Authority and Change Control

This document is a **Canonical Addendum**, not an independent replacement for SH Core Canonical.

Authority ordering remains:

```text
OWNER
  ↓
SH CORE CANONICAL
  ↓
THIS CANONICAL ADDENDUM
  ↓
IMPLEMENTATION / SOURCE
  ↓
DEPLOYED RUNTIME
  ↓
CI / APK / REAL E2E EVIDENCE
```

Within the semantic area explicitly covered by this addendum, implementation MUST conform to this document once the Owner has approved/ratified it.

If a future Core Canonical revision intentionally changes this semantic area, the addendum MUST be reconciled and versioned rather than silently overridden in implementation.

---

## 16. Implementation Status

At creation of this addendum:

```text
Canonical semantic decision     → ESTABLISHED
Documentation                   → COMPLETE
BE implementation              → NOT YET RECONCILED
FE implementation              → NOT YET RECONCILED
DB/RLS/migrations               → NOT YET RECONCILED
CI verification                 → NOT YET RECONCILED
APK / Real E2E                  → NOT YET RECONCILED
```

No implementation should be declared complete until these layers are reconciled and verified against this addendum.
