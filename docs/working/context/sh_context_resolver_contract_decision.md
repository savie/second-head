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

# Resolver Contract Questions

Sebelum implementasi harus diputuskan:

## 1. Resolver Output

Pilihan yang perlu diputuskan:

A.

```
separate domain payload
```

atau

B.

```
unified semantic context package
```

---

## 2. Resolver Ordering

Belum ditetapkan.

Perlu keputusan mengenai urutan:

- conversation
- state
- memory
- knowledge
- experience
- journey

---

## 3. Inclusion Policy

Resolver harus menentukan:

- relevance boundary;
- visibility boundary;
- ownership boundary;
- lifecycle boundary.

---

## 4. Security Boundary

Resolver tidak boleh bypass:

- Memory boundary;
- Knowledge boundary;
- Experience boundary;
- Journey boundary.

---

## 5. Non Goal

Dokumen ini tidak:

- membuat migration;
- membuat function baru;
- membuat tabel baru;
- duplicate runtime domain;
- masuk FE;
- melakukan E2E.

---

# Decision Gate

Implementation hanya dilakukan setelah:

- resolver contract jelas;
- output contract jelas;
- security boundary jelas;
- inclusion policy disetujui.

Current status:

```
Context Resolver:
DESIGN PENDING

Runtime implementation:
NOT STARTED
```
