# SECOND HEAD — P3D Knowledge Schema Design

## Status
DESIGN COMPLETE — BL-P3D-001 / AC-KNOW-01

## Purpose

Mendefinisikan bentuk minimal penyimpanan Knowledge untuk Phase 3D tanpa mengubah canonical rule, ownership/privacy boundary, atau membuat keputusan baru mengenai Knowledge acquisition dan trust promotion.

## Authority / Reconciliation

Sumber yang direkonsiliasi:

- SH Core Canonical v1.0
- SH Full Build Scope v1.0
- SH Full Implementation Contract v1.0
- SH Full Implementation Guide v1.0
- Phase -1 backlog: BL-P3D-001 — Knowledge Schema Design
- Existing P3B knowledge-eligibility implementation
- Owner / DM decision notes mengenai Memory → Understanding → Knowledge, generalization, provenance, sharing, dan superseded

Canonical invariants yang dipertahankan:

- KNOWLEDGE ≠ MEMORY
- KNOWLEDGE ≠ CONTEXT
- Private experience tidak otomatis menjadi shared knowledge
- Sharing tetap explicit / authorized / scoped / auditable
- Learning ≠ Automatic Core Modification
- Knowledge harus memiliki provenance dan dapat ditelusuri

## Design Boundary

BL-P3D-001 hanya menyelesaikan **schema design**.

Item berikut tetap merupakan backlog terpisah:

- acquisition
- validation
- normalization
- classification
- storage implementation
- indexing
- provenance implementation
- retrieval
- testing

Tidak ada migration atau perubahan database yang dilakukan oleh artifact ini.

## Knowledge Record — Minimal Logical Shape

```text
Knowledge
├── knowledge_id
├── content
├── knowledge_class
├── scope
├── visibility
├── source
├── provenance
├── confidence
├── version
├── lifecycle
├── superseded_by
├── created_at
└── updated_at
```

### Field intent

| Field | Intent |
|---|---|
| knowledge_id | Persistent identity untuk satu Knowledge record |
| content | Isi Knowledge |
| knowledge_class | Kategori Knowledge yang akan dibutuhkan oleh lifecycle/governance |
| scope | Boundary penggunaan Knowledge, termasuk pembedaan general/private bila relevan |
| visibility | Visibility/access boundary |
| source | Sumber langsung / reference source |
| provenance | Lineage / asal-usul yang dapat ditelusuri |
| confidence | Tingkat keyakinan yang terkait record; bukan klaim kebenaran absolut |
| version | Versi Knowledge untuk menjaga history perubahan |
| lifecycle | State lifecycle Knowledge |
| superseded_by | Relasi ke versi pengganti bila Knowledge disupersede |
| created_at | Waktu pembuatan record |
| updated_at | Waktu perubahan record |

## Knowledge Classification

Implementation Guide mendefinisikan kategori minimal:

- Canonical Knowledge
- Derived Knowledge
- Learned Knowledge
- Imported Knowledge
- Temporary Knowledge

Schema menyediakan `knowledge_class` sebagai tempat klasifikasi tersebut tanpa menetapkan aturan baru tentang bagaimana sebuah record dipromosikan antar-class.

## Knowledge Lifecycle

Lifecycle yang dirujuk Implementation Guide:

```text
Candidate
  → Validation
  → Accepted
  → Indexed
  → Active
  → Updated
  → Deprecated
  → Archived
```

Schema menyediakan `lifecycle` untuk state tersebut.

Lifecycle implementation merupakan backlog berikutnya dan bukan bagian dari BL-P3D-001.

## Provenance / Versioning

Knowledge tidak boleh kehilangan asal-usulnya.

Schema menyediakan:

- `source` untuk sumber langsung;
- `provenance` untuk lineage;
- `version` untuk version identity;
- `superseded_by` untuk hubungan ke versi pengganti.

Ini konsisten dengan keputusan Owner bahwa source identity private tidak harus dibuka kepada user lain, tetapi provenance/lineage tetap dapat dipertahankan secara internal.

## Privacy / Sharing Boundary

Schema tidak memberikan akses lintas-SH secara otomatis.

`scope` dan `visibility` disediakan sebagai metadata boundary, tetapi authorization tetap mengikuti ownership/governance layer yang sudah ada.

Private experience tidak otomatis menjadi shared Knowledge.

General/shared Knowledge dapat digunakan lintas user hanya sesuai governance dan authorization yang berlaku.

## Trust / OQ Boundary

Schema menyediakan `confidence` sebagai metadata keyakinan record.

Artifact ini **tidak** menetapkan:

- formula confidence;
- trust-promotion algorithm;
- automatic trust promotion;
- manual vs automated approval;
- authoritative source ranking.

Hal-hal tersebut tetap berada pada backlog/decision scope terkait OQ-03/OQ-04 dan tidak ditutup secara silent oleh schema design ini.

## Relationship to Existing Memory Implementation

Existing P3B implementation menyediakan memory storage dan knowledge-eligibility decision layer. Hasil tersebut tidak diperlakukan sebagai Knowledge storage.

Dengan demikian:

```text
MEMORY
  ↓
knowledge_candidate
  ↓
Knowledge acquisition / validation / governance
  ↓
KNOWLEDGE
```

`knowledge_candidate = true` bukan berarti record Knowledge sudah otomatis tercipta.

## Non-Goals

Artifact ini tidak:

- membuat tabel Knowledge;
- membuat RLS Knowledge;
- membuat acquisition pipeline;
- membuat validation engine;
- membuat trust promotion engine;
- mengubah Memory schema;
- mengubah Context;
- mengubah Core;
- menutup OQ secara formal.

## Conclusion

BL-P3D-001 dapat diselesaikan pada level design tanpa membuat architectural mutation baru. Bentuk schema minimal sudah ditetapkan dan dapat menjadi input untuk backlog P3D berikutnya.
