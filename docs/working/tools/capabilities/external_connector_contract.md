# SECOND HEAD — External Connector Capability Contract

## Status

WORKING CONTRACT DRAFT

## Authority

Supporting document only.

Dokumen ini tidak mendefinisikan:
- Canonical architecture;
- Runtime mandatory contract;
- Security policy.

---

# 1. Capability Identity

Capability Name:

External Connector

Tool ID:

TBD

Version:

TBD

Status:

Candidate

---

# 2. Purpose & Scope

## Purpose

Menyediakan boundary standar untuk capability yang berinteraksi dengan external system/provider.

Contoh:
- calendar;
- messaging;
- productivity service;
- external data source.

## Out of Scope

Tidak termasuk:

- provider-specific object menjadi SH domain object;
- direct frontend → provider communication;
- bypass runtime authorization.

---

# 3. Execution Boundary

Flow:

```
SH Runtime
↓
Tool Contract
↓
Connector / Adapter
↓
External Provider
```

External provider harus terisolasi melalui adapter boundary.

---

# 4. Provider Isolation

External provider model bukan SH-owned contract.

Adapter bertanggung jawab untuk:

- provider API translation;
- schema normalization;
- error normalization;
- provider-specific handling.

---

# 5. Security Contract

## Authentication

Model:

TBD

Contoh:

- OAuth;
- service credential;
- delegated access.

## Authorization

Harus mendefinisikan:

- owner identity;
- permission scope;
- access lifetime;
- revocation behavior.

---

# 6. Input Contract

Arguments:

TBD

Validation:

TBD

---

# 7. Output Contract

Normalized result:

TBD

Provider response tidak langsung diekspos sebagai application contract.

---

# 8. Audit Contract

Required:

- tool_id
- tool_version
- action_id
- owner identity
- permission scope
- execution status

---

# 9. Verification Gate

Sebelum implementation:

- [ ] Provider boundary reviewed
- [ ] Authentication model defined
- [ ] Authorization model defined
- [ ] Failure handling defined
- [ ] Audit path defined

---

# 10. Decision Record

Decision:

TBD

Reason:

TBD

---

Classification:

```
External Connector Contract

Type: WORKING CONTRACT DRAFT
Authority: Supporting
Runtime: Tidak berubah
Supabase: Tidak berubah
```
