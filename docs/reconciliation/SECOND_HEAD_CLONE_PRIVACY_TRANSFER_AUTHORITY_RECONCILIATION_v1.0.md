# SECOND HEAD — CLONE PRIVACY, TRANSFER POLICY & AUTHORITY RECONCILIATION
## v1.0 — Owner-Ratified Semantic Contract

**Status:** Owner-ratified semantic reconciliation / implementation in progress  
**Branch:** `dev`  
**Scope:** Clone, privacy, transfer policy, authority/authorization, lifecycle semantics  
**Canonical Matrix:** `docs/SECOND_HEAD_CANONICAL_REAL_E2E_VERIFICATION_MATRIX_v1.0.md` remains the single persistent REAL E2E execution matrix.  
**Architecture:** `docs/SH_APP_ARCHITECTURE_BASELINE_v1.0.md` remains the architecture baseline.  

---

## 1. Ratified rules

Owner has ratified four rules:

1. `INHERITABLE` is replaced by `INHERITANCE`.
2. `NON_TRANSFERABLE` is excluded from Clone state.
3. Private personal/sensitive material is not Clone state.
4. Authority is an explicit enforcement layer between policy eligibility and operation execution.

---

## 2. Model

```text
SCOPE / VISIBILITY
        ↓
siapa yang boleh melihat / mengakses
        ↓
PAGAR PRIVASI

TRANSFER POLICY
        ↓
record boleh ikut lifecycle transfer yang mana
        ↓
IZIN LIFECYCLE

AUTHORITY / AUTHORIZATION
        ↓
siapa yang sah melakukan operasi
        ↓
IZIN AKSI
```

`PRIVATE` dan `OWNER_ONLY` tidak otomatis berarti `NON_TRANSFERABLE`.

Privacy menentukan access boundary. Transfer Policy menentukan lifecycle eligibility. Authority menentukan apakah actor sah menjalankan operasi.

---

## 3. Transfer Policy

Canonical vocabulary after Owner ratification:

- `NON_TRANSFERABLE`
- `INHERITANCE`
- `SUCCESSION`
- `LEGACY`

`INHERITABLE` is no longer the project terminology.

`NON_TRANSFERABLE` means the record is not eligible for Inheritance, Succession, Legacy, or Clone transferable state.

The other policies do not automatically grant access to another SH; they only identify lifecycle eligibility subject to authority and selection.

---

## 4. Authority

Enforcement order:

```text
record
  ↓
privacy / access check
  ↓
transfer-policy check
  ↓
authority / authorization check
  ↓
explicit selected-record check
  ↓
execute operation
```

Having a transfer policy never grants automatic access to another SH.

---

## 5. Clone boundary

Clone is not synonymous with Inheritance, Succession, or Legacy.

```text
SOURCE SH
    ↓
CLONE AGREEMENT
    ↓
CLONE ELIGIBILITY
    ↓
AUTHORITY / AGREEMENT CHECK
    ↓
SELECTIVE STATE
    ↓
TARGET ACCOUNT
    ↓
PRIMARY CLONE SH
```

`CLONE_SH != SOURCE_SH`.

Clone is not a full copy of the Source owner's private life.

### Clone exclusions

The Clone materialization contract excludes:

- private personal material;
- private conversations;
- private context;
- private Memory;
- credentials;
- source identity/ownership material;
- creator-only material;
- other private/sensitive material outside the permitted Clone state;
- every record whose Transfer Policy is `NON_TRANSFERABLE`.

The current BE materialization rule therefore requires Clone state to be `GENERAL` + `SHARED` and not `NON_TRANSFERABLE`.

```text
GENERAL / SHARED / NON_TRANSFERABLE
        ↓
        ❌ Clone

PRIVATE / OWNER_ONLY
        ↓
        ❌ Clone state
```

Policies other than `NON_TRANSFERABLE` do not by themselves make a record Cloneable; Clone eligibility, authority, agreement, and selected state still apply.

---

## 6. Lifecycle semantic matrix

| Scope | Visibility | Policy | Inheritance | Succession | Legacy |
|---|---|---|---|---|---|
| PRIVATE | OWNER_ONLY | NON_TRANSFERABLE | ❌ | ❌ | ❌ |
| PRIVATE | OWNER_ONLY | INHERITANCE | ✅* | ❌ | ❌ |
| PRIVATE | OWNER_ONLY | SUCCESSION | ❌ | ✅* | ❌ |
| PRIVATE | OWNER_ONLY | LEGACY | ❌ | ❌ | ✅* |
| PRIVATE | SHARED | NON_TRANSFERABLE | ❌ | ❌ | ❌ |
| PRIVATE | SHARED | INHERITANCE | ✅* | ❌ | ❌ |
| PRIVATE | SHARED | SUCCESSION | ❌ | ✅* | ❌ |
| PRIVATE | SHARED | LEGACY | ❌ | ❌ | ✅* |
| GENERAL | OWNER_ONLY | NON_TRANSFERABLE | ❌ | ❌ | ❌ |
| GENERAL | OWNER_ONLY | INHERITANCE | ✅* | ❌ | ❌ |
| GENERAL | OWNER_ONLY | SUCCESSION | ❌ | ✅* | ❌ |
| GENERAL | OWNER_ONLY | LEGACY | ❌ | ❌ | ✅* |
| GENERAL | SHARED | NON_TRANSFERABLE | ❌ | ❌ | ❌ |
| GENERAL | SHARED | INHERITANCE | ✅* | ❌ | ❌ |
| GENERAL | SHARED | SUCCESSION | ❌ | ✅* | ❌ |
| GENERAL | SHARED | LEGACY | ❌ | ❌ | ✅* |

`*` Eligibility still requires authority, lifecycle validity, and explicit selection.

This is the semantic contract; runtime truth remains the Canonical REAL E2E Verification Matrix.

---

## 7. BE implementation

Implemented in Supabase DEV:

- `INHERITABLE` data migrated to `INHERITANCE`.
- Transfer-policy constraints now use `INHERITANCE`.
- Clone materialization requires authenticated recipient authority and approved agreement.
- Source ownership boundary is enforced.
- Recipient email/target identity is enforced.
- Existing target SH blocks duplicate materialization.
- Clone Memory/Knowledge/Experience materialization excludes `NON_TRANSFERABLE`.
- Clone materialization excludes non-`GENERAL` or non-`SHARED` records.
- Clone provenance identifies the source SH, source account, agreement, and Clone privacy boundary.
- Selected transfer validation recognizes `INHERITANCE`, `SUCCESSION`, and `LEGACY`.

Database migration:

`supabase/migrations/20260821120000_clone_privacy_policy_authority_v1.sql`

---

## 8. FE implementation

Implemented in `dev`:

- Transfer-policy TypeScript vocabulary now uses `INHERITANCE`.
- Inheritance selection UI now filters for `INHERITANCE`.
- Inheritance UI no longer displays the obsolete `INHERITABLE` terminology.
- Clone UI now explains the privacy/transfer boundary to the Owner.
- FE continues to treat BE as the authority for authorization and rejection.

---

## 9. Canonical Matrix

The Canonical REAL E2E Verification Matrix remains the only execution matrix.

It is still relevant and is not replaced.

The existing TC IDs remain valid. The semantic rules above are applied to the affected Clone and lifecycle acceptance criteria during verification.

Relevant Clone coverage remains:

- `TC-CLONE-09` — private-content exclusion;
- `TC-CLONE-10` — `NON_TRANSFERABLE` exclusion;
- `TC-CLONE-11` — source/recipient isolation and authority boundary;
- `TC-CLONE-12` — unauthorized Clone operation;
- `TC-CLONE-13` — APK/runtime contract verification.

No competing Matrix is created by this reconciliation.

---

## 10. Architecture

`docs/SH_APP_ARCHITECTURE_BASELINE_v1.0.md` remains the architecture baseline.

This reconciliation does not replace the architecture baseline.

The implementation uses the existing ownership, privacy, RLS, authorization, and Source SH / Clone SH boundaries.

---

## 11. Verification status

```text
Semantic decision                 → OWNER RATIFIED
BE/DB contract implementation    → APPLIED TO SUPABASE DEV
FE contract implementation      → COMMITTED TO DEV
CI/typecheck                     → pending observed workflow evidence
APK                               → pending observed build artifact
Real E2E                          → pending device/runtime evidence
Canonical Matrix                 → unchanged / still authoritative
```

No runtime PASS is claimed by this document.

---

## 12. Evidence discipline

Historical DB rows are not fresh runtime proof.

Source/document evidence is not behavioral proof.

UI evidence proves only what is actually visible.

Real E2E PASS requires fresh runtime evidence according to the Canonical Matrix.

END
