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

Journey runtime foundation exists.

Verified foundation:

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

Journey Context Retrieval telah memiliki keputusan contract melalui Context Resolver Contract Decision.

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

Verified runtime flow:

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

Journey retrieval is connected through:

```
runtime_get_journey_context()
```

Current implementation therefore reconciles with the resolved Context Resolver contract.

---

# FE Projection Boundary

Journey UI may retrieve Journey data through the Journey retrieval boundary for presentation.

Current FE Journey service resolves the authenticated SH identity through:

```
resolve_identity()
```

and then retrieves Journey context through:

```
runtime_get_journey_context()
```

This FE projection does not redefine or bypass the Context Resolver contract.

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
