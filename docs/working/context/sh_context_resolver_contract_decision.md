# SH Context Resolver Contract Decision

**Status:** WORKING document  
**Scope:** Context Runtime contract preparation

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

- Memory runtime foundation exists.
- Knowledge runtime foundation exists.
- Experience runtime foundation exists.
- Journey runtime foundation exists.

Context Resolver Integration Layer sudah melalui implementation verification.

---

# Current Context Runtime

Existing:

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
- Tidak membuat consumer harus memahami banyak payload terpisah.

Resolver internal tetap dapat berasal dari domain berbeda.

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

Ordering ini adalah contract assembly order, bukan ranking importance.

---

## 3. Inclusion Policy

Context Resolver wajib mempertahankan:

- relevance boundary;
- visibility boundary;
- ownership boundary;
- lifecycle boundary.

Tidak semua data domain otomatis masuk Context Package.

---

## 4. Security Boundary

Decision:

Context Resolver tidak boleh bypass domain security.

Resolver harus menggunakan boundary existing:

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

Verified flow:

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

Verification status:

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

# Non Goal

Dokumen ini tidak:

- membuat migration;
- membuat function baru;
- membuat tabel baru;
- duplicate runtime domain;
- masuk FE;
- melakukan E2E.

---

# Decision Gate

Runtime verification selesai.

Gate berikutnya:

```
Resolver Contract Decision Gate
```

Current status:

```
Context Resolver:
IMPLEMENTATION VERIFIED

Runtime implementation:
COMPLETED

Next:
CONTRACT DECISION GATE
```
