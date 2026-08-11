# SECOND HEAD — P3D Knowledge Acquisition

## Status

**DESIGN COMPLETE — BL-P3D-002 / AC-KNOW-02**

## Purpose

Mendefinisikan acquisition boundary dan intake contract Knowledge Phase 3D dengan memanfaatkan schema design P3D-001 dan keputusan Owner/DM terbaru, tanpa mengubah canonical rule, ownership/privacy boundary, atau membuat trust-promotion policy baru.

## Authority / Reconciliation

Sumber yang direkonsiliasi:

- SH Core Canonical v1.0
- SH Full Build Scope v1.0
- SH Full Implementation Contract v1.0
- SH Full Implementation Guide v1.0
- Phase -1 backlog: BL-P3D-002 — Knowledge Acquisition
- P3D-001 Knowledge Schema Design
- Existing P3B knowledge-eligibility implementation
- Owner / DM decision notes mengenai Memory → Understanding → Knowledge, explicit teaching, generalization, provenance, sharing, superseded, dan external/web source

Canonical / boundary invariants yang dipertahankan:

- KNOWLEDGE ≠ MEMORY
- KNOWLEDGE ≠ CONTEXT
- Private information tidak otomatis menjadi shared/general Knowledge
- Sharing tetap mengikuti ownership/privacy/governance boundary
- Knowledge mempertahankan source/provenance
- Learning ≠ Automatic Core Modification
- Acquisition ≠ Validation ≠ Trust Promotion

## Acquisition Sources

P3D-002 mengenali tiga sumber acquisition yang sudah didukung oleh keputusan Owner/DM dan existing design:

### 1. Memory-derived acquisition

Memory atau `knowledge_candidate` dapat menjadi input acquisition ketika memenuhi rule dan boundary yang berlaku.

`knowledge_candidate = true` adalah sinyal eligibility/intake, bukan bukti bahwa Knowledge sudah accepted.

### 2. Explicit Owner/User Teaching

User/Owner dapat secara eksplisit menyatakan bahwa suatu informasi sedang diajarkan sebagai ilmu/pengetahuan.

Contoh intent:

> "Gw mau ngajarin lu teknik fotografi ini."

Sinyal explicit teaching dapat menjadi input acquisition tanpa otomatis melewati validation atau governance.

### 3. External / Reference Source

Knowledge dapat diakuisisi dari sumber eksternal/reference, termasuk web/external material bila sumber tersebut tersedia bagi sistem.

External source harus mempertahankan reference/source information sehingga provenance tidak hilang.

## Acquisition Contract

Setiap intake Knowledge minimal menghasilkan candidate record yang memiliki:

- content;
- source;
- provenance/lineage bila tersedia;
- knowledge_class sesuai asal intake;
- scope;
- visibility;
- confidence bila tersedia dari source/intake context;
- lifecycle awal yang sesuai dengan schema design.

Acquisition tidak boleh menghapus provenance atau private-source boundary.

## Privacy / Generalization Boundary

Acquisition tidak boleh melakukan private-to-general promotion secara otomatis hanya karena informasi berasal dari Memory.

Jika source merupakan pengalaman/informasi private:

`PRIVATE SOURCE → ACQUISITION CANDIDATE`

bukan:

`PRIVATE SOURCE → AUTOMATIC SHARED KNOWLEDGE`

General/shared use tetap memerlukan governance/authorization yang sesuai.

Source identity private tidak perlu dibuka kepada user lain hanya karena Knowledge digunakan lintas user.

## Acquisition vs Validation vs Trust

P3D-002 hanya menetapkan intake.

Pipeline konseptual:

```text
SOURCE / MEMORY / EXPLICIT TEACHING
            ↓
       ACQUISITION
            ↓
    KNOWLEDGE CANDIDATE
            ↓
       VALIDATION
            ↓
   CLASSIFICATION / TRUST
            ↓
       KNOWLEDGE
```

Dengan demikian:

- acquisition tidak berarti validation passed;
- acquisition tidak berarti trusted;
- acquisition tidak berarti canonical truth;
- acquisition tidak berarti automatic sharing;
- acquisition tidak berarti Core modification.

## Versioning / Supersession

Acquisition terhadap Knowledge yang merupakan koreksi atau versi baru harus dapat mempertahankan hubungan dengan predecessor melalui version/supersession metadata yang sudah disediakan pada P3D-001.

History tidak boleh hilang hanya karena Knowledge diperbarui.

## Relationship to P3B

P3B tetap menjadi upstream source untuk memory-derived eligibility.

```text
MEMORY
  ↓
knowledge_candidate
  ↓
P3D Knowledge Acquisition
  ↓
Validation / Classification / Trust
  ↓
Knowledge
```

P3D-002 tidak mengubah rule P3B `occurrence >= 5` dan tidak mengubah Memory schema.

## Minimal Realization Boundary

Tidak ada Knowledge table/storage mutation pada P3D-002.

Storage implementation tetap merupakan backlog P3D-006.

P3D-002 karena itu direalisasikan sebagai acquisition contract/design artifact yang menjadi input langsung untuk implementation backlog berikutnya tanpa mendahului storage, validation, classification, atau provenance implementation.

## Explicit Non-Goals

P3D-002 tidak menetapkan:

- semantic validation engine;
- truth verification;
- final confidence formula;
- trust-promotion algorithm;
- authoritative source ranking;
- automatic private-to-general promotion;
- Knowledge storage schema mutation;
- indexing;
- retrieval;
- Core modification.

Hal-hal tersebut tetap berada pada backlog/decision scope masing-masing.

## OQ Reconciliation Note

OQ-03 masih dapat tercatat OPEN secara formal pada Phase -1/documentation layer.

Namun keputusan Owner/DM terbaru sudah memberikan implementation direction yang cukup untuk acquisition contract ini tanpa mengubah canonical architecture, ownership, privacy, security boundary, atau fundamental flow.

Karena itu status praktis untuk backlog ini adalah:

`UNBLOCKED FOR CURRENT IMPLEMENTATION`

Formal OQ closure tidak diklaim oleh artifact ini.

## Conclusion

BL-P3D-002 dapat diselesaikan pada level acquisition contract/design tanpa architectural mutation baru. P3D-002 sekarang memberikan boundary yang jelas untuk tiga sumber acquisition utama, mempertahankan provenance/privacy, dan memisahkan acquisition dari validation/trust/storage.
