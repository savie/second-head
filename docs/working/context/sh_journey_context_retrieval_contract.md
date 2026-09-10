# SH Journey Context Retrieval Contract

**Status:** WORKING

**Purpose:**

Menentukan boundary retrieval Journey sebelum masuk ke Context Package.

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
- tidak melakukan implementasi;
- mendokumentasikan contract decision gate untuk integrasi Journey Context.

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

# Gap

Belum ada Journey Context Retrieval Contract.

Journey domain runtime sudah tersedia, namun boundary retrieval menuju Context Package belum ditentukan.

---

# Decision Required

## 1. Semantic Context Inclusion

Keputusan diperlukan:

Apakah Journey masuk ke semantic_context pada Context Package.

---

## 2. Resolver Output Shape

Alternatif output resolver:

- event list;
- continuity summary;
- lifecycle state;
- lineage reference.

Output contract harus ditentukan sebelum implementasi resolver.

---

## 3. Inclusion Policy

Policy yang harus ditentukan:

- relevance;
- visibility;
- ownership;
- lifecycle.

---

## 4. Security Boundary

Context Resolver tidak boleh bypass Journey domain boundary.

Retrieval harus melalui resolver contract dan policy yang disepakati.

---

# Non Goal

Dokumen ini tidak membuat:

- tabel baru;
- duplicate journey runtime;
- query langsung dari Context Runtime tanpa resolver boundary;
- FE implementation.

---

# Current Status

```
Journey Event Runtime:
VERIFIED

Journey Context Retrieval:
PENDING CONTRACT

Context Package Integration:
BLOCKED UNTIL CONTRACT CLOSED
```
