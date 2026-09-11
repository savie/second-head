# SECOND HEAD — Capability Expansion Contract Template

## Status

WORKING TEMPLATE

## Authority

Supporting document only.

Dokumen ini tidak mendefinisikan:
- Canonical architecture;
- Runtime mandatory contract;
- Security policy.

Dokumen ini digunakan sebagai template persiapan capability expansion.

---

# 1. Capability Identity

## Capability Name

[NAME]

## Tool ID

[TOOL_ID]

## Version

[VERSION]

## Status

- Proposed
- Designed
- Implemented
- Verified

---

# 2. Purpose & Scope

## Purpose

Capability ini menyediakan:

[DESCRIPTION]

## Out of Scope

Tidak termasuk:

[LIMITATIONS]

---

# 3. Security Contract

## Risk Level

Pilih:

- READ_ONLY
- LOW
- HIGH

## Confirmation Requirement

- Required
- Not Required

## Authorization Boundary

Jelaskan sumber authorization:

[AUTHORIZATION_MODEL]

---

# 4. Execution Contract

## Adapter Type

Pilih:

- Internal RPC
- MCP
- Connector
- Internal Service

## Execution Flow

```
Capability ↓ Tool Contract ↓ Runtime Boundary ↓ Adapter ↓ Provider / Service
```

## Provider Isolation

Provider-specific implementation detail tidak boleh menjadi application contract.

Perubahan provider harus tetap berada di adapter boundary.

---

# 5. Input Contract

## Arguments

| Name | Type | Required | Description |
|---|---|---|---|
| | | | |

## Validation Rules

[VALIDATION]

## Rejected Cases

[REJECTION_RULES]

---

# 6. Output Contract

## Success Result

[NORMALIZED_OUTPUT]

## Error Result

[NORMALIZED_ERROR]

---

# 7. Audit Contract

Capability harus menghasilkan audit metadata:

- tool_id
- tool_version
- action_id
- risk
- status

Tambahan metadata:

[ADDITIONAL_METADATA]

---

# 8. Verification Gate

Sebelum implementation:

- [ ] Contract reviewed
- [ ] Authorization reviewed
- [ ] Failure path defined
- [ ] Audit path defined
- [ ] Runtime integration reviewed

---

# 9. Decision Record

## Decision

[DECISION]

## Reason

[REASON]

## Related Documents

[DOCUMENT_REFERENCES]

---

Classification:

```
File type: WORKING TEMPLATE

Tidak:
- Canonical
- Approved Contract
- Runtime implementation spec
```
