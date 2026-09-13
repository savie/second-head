# SH Journey Context Retrieval Contract

**Status:** WORKING — RECONCILED

**Purpose:**

Mendokumentasikan boundary retrieval Journey yang digunakan oleh Context Package.

---

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

Dokumen ini adalah WORKING document.

Dokumen ini:

- tidak mengubah Canonical;
- tidak menggantikan Approved Contract;
- tidak membuat contract baru;
- mendokumentasikan hasil reconciliation contract dan implementation Journey Context Retrieval.

---

# Current Finding

Foundation runtime Journey sudah tersedia.

Foundation yang sudah diverifikasi:

- journey_events;
- continuity model;
- lifecycle boundary;
- runtime_record_journey_event();
- runtime_classify_journey_event();
- runtime_get_journey_record_policy();
- runtime_journey_event_is_shared().

Classification:

```
Journey Event Runtime:
VERIFIED
```

---

# Retrieval Contract Decision

Journey Context Retrieval sudah memiliki keputusan contract melalui Context Resolver Contract Decision.

## 1. Semantic Context Inclusion

Decision:

```
Journey INCLUDED in semantic_context
```

Journey retrieval merupakan bagian dari unified semantic context package.

## 2. Resolver Output Shape

Decision:

```
unified semantic context package
```

Journey tetap menjadi domain-owned retrieval boundary di dalam Context Resolver.

## 3. Resolver Ordering

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

Ordering adalah contract assembly order, bukan ranking importance.

## 4. Inclusion Policy

Context Resolver wajib mempertahankan:

- relevance boundary;
- visibility boundary;
- ownership boundary;
- lifecycle boundary.

Tidak semua Journey event otomatis masuk Context Package tanpa memenuhi boundary domain tersebut.

## 5. Security Boundary

Context Resolver tidak boleh bypass Journey domain boundary.

Journey retrieval menggunakan existing Journey retrieval boundary:

```
runtime_get_journey_context()
```

---

# Implementation Evidence

Flow runtime yang sudah diverifikasi:

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

Journey retrieval terhubung melalui:

```
runtime_get_journey_context()
```

Dengan demikian implementasi saat ini sudah selaras dengan Context Resolver contract yang telah diputuskan.

---

# FE Projection Boundary

Journey UI dapat mengambil data Journey melalui retrieval boundary Journey untuk kebutuhan presentation.

Journey service pada FE saat ini me-resolve identity SH yang terautentikasi melalui:

```
resolve_identity()
```

kemudian mengambil Journey context melalui:

```
runtime_get_journey_context()
```

Projection FE ini tidak mendefinisikan ulang atau melewati Context Resolver contract.

---

# Current Status

```
Journey Event Runtime:
VERIFIED

Journey Context Retrieval Contract:
DECIDED

Journey Context Retrieval Runtime:
IMPLEMENTED

Context Resolver Integration:
IMPLEMENTED

Runtime Verification:
VERIFIED

Documentation Reconciliation:
COMPLETED
```

---

# Non Goal

Dokumen ini tidak membuat:

- tabel baru;
- duplicate journey runtime;
- query langsung dari Context Runtime yang bypass Journey boundary;
- FE contract baru;
- perubahan Canonical;
- perubahan migration SQL.
