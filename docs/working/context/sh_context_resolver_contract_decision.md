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

Dokumen ini tidak mengubah Canonical dan tidak melakukan implementasi runtime.

---

# Background

Hasil reconciliation:

- Memory runtime foundation exists.
- Knowledge runtime foundation exists.
- Experience runtime foundation exists.
- Journey runtime foundation exists.

Gap yang ditemukan:

```
Context Resolver Integration Layer
```

Bukan pembangunan domain baru.

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

Decision awal:

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

Implementasi detail belum dilakukan sebelum verification contract.

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

# Implementation Gate

Implementasi hanya dilakukan setelah:

- existing resolver/function diverifikasi;
- security boundary diverifikasi;
- migration/function naming diverifikasi;
- output contract sesuai runtime existing.

Current status:

```
Context Resolver:
CONTRACT DECIDED

Runtime implementation:
NOT STARTED
```
