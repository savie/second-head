# SH Context Resolver Contract Decision

**Status:** WORKING document  
**Scope:** Persiapan contract Context Runtime

## Authority

Urutan authority:

```
Owner/User Decision
↓
Canonical
↓
Approved Contract
↓
Architecture
↓
Current Implementation
↓
Historical evidence
```

Dokumen ini tidak mengubah Canonical dan tidak membuat contract baru.

---

# Background

Hasil reconciliation:

- Fondasi runtime Memory sudah ada.
- Fondasi runtime Knowledge sudah ada.
- Fondasi runtime Experience sudah ada.
- Fondasi runtime Journey sudah ada.

Context Resolver Integration Layer sudah melalui implementation verification.

---

# Current Context Runtime

Yang sudah ada:

- actor resolution
- conversation resolution
- state resolution

Migration:

```
20260910123358_context_runtime_package_entry_point.sql
```

Runtime entry:

```
runtime_get_context_package()
```

---

# Contract Decision

## 1. Resolver Output

Decision:

```
unified semantic context package
```

Alasan:

- Context Runtime memiliki satu boundary output.
- Domain resolver tetap menjaga ownership semantic masing-masing.
- Consumer tidak perlu memahami banyak payload yang terpisah.

Resolver internal tetap dapat berasal dari domain yang berbeda.

---

## 2. Resolver Ordering

Decision:

```
actor
 ↓
conversation
 ↓
state
 ↓
memory
 ↓
knowledge
 ↓
experience
 ↓
journey
```

Catatan:

Ordering ini adalah urutan assembly contract, bukan ranking importance.

---

## 3. Inclusion Policy

Context Resolver wajib mempertahankan:

- relevance boundary;
- visibility boundary;
- ownership boundary;
- lifecycle boundary.

Tidak semua data domain otomatis masuk ke Context Package.

---

## 4. Security Boundary

Decision:

Context Resolver tidak boleh bypass domain security.

Resolver harus menggunakan boundary yang sudah ada:

- Memory boundary;
- Knowledge boundary;
- Experience boundary;
- Journey boundary.

---

## 5. Output Contract Direction

Target contract:

```
runtime_get_context_package()
        |
        + actor
        + conversation
        + state
        + semantic_context
              |
              + memory
              + knowledge
              + experience
              + journey
```

---

# Runtime Verification Result

Flow yang sudah diverifikasi:

```
runtime_get_context_package()
↓
assemble_context()
↓
Memory retrieval
↓
Knowledge retrieval
↓
Experience retrieval
↓
Journey retrieval
```

Status verification:

```
Resolver runtime:
VERIFIED

Context Resolver integration:
IMPLEMENTED

Migration/function naming:
VERIFIED

Security boundary:
PRESERVED
```

---

# Resolver Contract Decision Gate Result

Klasifikasi review:

```
Resolver Output:
DECIDED

Resolver Ordering:
DECIDED

Inclusion Policy:
DECIDED

Security Boundary:
DECIDED

Output Contract Direction:
DECIDED
```

Ambiguitas yang belum terselesaikan:

```
NONE IDENTIFIED
```

Decision:

```
Resolver Contract Decision Gate:
COMPLETED
```

---

# Non Goal

Dokumen ini tidak:

- membuat migration;
- membuat function baru;
- membuat tabel baru;
- duplicate runtime domain;
- masuk FE;
- melakukan E2E.

---

# Final Status

```
Context Resolver:
CONTRACT DECIDED

Runtime implementation:
COMPLETED

Runtime verification:
COMPLETED

Resolver Contract Decision Gate:
COMPLETED
```
