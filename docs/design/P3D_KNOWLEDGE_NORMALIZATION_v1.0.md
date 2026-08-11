# SECOND HEAD — P3D Knowledge Normalization

## Status

**DESIGN COMPLETE — BL-P3D-004 / AC-KNOW-04**

## Purpose

Mendefinisikan normalization boundary untuk candidate Knowledge setelah acquisition dan validation, tanpa mengubah canonical rule, ownership/privacy/security boundary, atau membuat trust-promotion policy baru.

Normalization memastikan candidate Knowledge memiliki bentuk representasi yang konsisten untuk diproses oleh classification, storage, provenance, indexing, dan retrieval pada backlog berikutnya.

## Authority / Reconciliation

Sumber yang direkonsiliasi:

- SH Core Canonical v1.0;
- SH Full Build Scope v1.0;
- SH Full Implementation Contract v1.0;
- SH Full Implementation Guide v1.0;
- Phase -1 backlog: BL-P3D-004 — Knowledge Normalization / AC-KNOW-04;
- P3D-001 Knowledge Schema Design;
- P3D-002 Knowledge Acquisition;
- P3D-003 Knowledge Validation;
- existing P3B knowledge-eligibility implementation;
- Owner / DM decision notes mengenai Memory → Understanding → Knowledge, explicit teaching, occurrence threshold, privacy/generalization, provenance, sharing, superseded, dan external/reference source.

Canonical / boundary invariants yang dipertahankan:

- KNOWLEDGE ≠ MEMORY;
- KNOWLEDGE ≠ CONTEXT;
- private information tidak otomatis menjadi shared/general Knowledge;
- sharing tetap mengikuti ownership/privacy/governance boundary;
- Knowledge mempertahankan source/provenance;
- Learning ≠ Automatic Core Modification;
- normalization ≠ validation ≠ trust promotion.

## Normalization Boundary

Normalization hanya mengubah **bentuk representasi**, bukan makna, status trust, ownership, atau authorization.

Minimum normalization mencakup:

1. content representation dibuat konsisten tanpa mengubah semantic intent;
2. source dan provenance dipertahankan;
3. scope dan visibility dipertahankan;
4. knowledge_class dipertahankan bila sudah ditentukan, atau tetap tidak dipaksakan bila classification belum dilakukan;
5. confidence dipertahankan sebagai metadata keyakinan dan tidak dinaikkan otomatis;
6. version dan superseded_by dipertahankan;
7. lifecycle/status tidak dipromosikan hanya karena normalization;
8. context/condition yang diperlukan untuk memahami Knowledge tidak dibuang;
9. metadata yang tidak tersedia tidak boleh diinventasikan seolah-olah fakta;
10. private-source identity tidak boleh diekspose hanya karena normalization.

## Canonical Representation

Normalisasi menghasilkan bentuk logical record yang kompatibel dengan schema P3D-001:

```text
Knowledge Candidate
├── content
├── knowledge_class (if available)
├── scope
├── visibility
├── source
├── provenance
├── confidence (if available)
├── version (if available)
├── lifecycle
├── superseded_by (if applicable)
└── normalization metadata
```

Normalization metadata dapat digunakan untuk traceability teknis, tetapi tidak menjadi pengganti provenance sumber.

## Semantic Preservation Rule

Normalization MUST be semantics-preserving.

Artinya normalization boleh:

- merapikan format;
- menyamakan representasi field;
- membersihkan noise formatting yang tidak bermakna;
- menstandarkan metadata yang memang sudah diketahui;
- membuat bentuk record konsisten.

Normalization tidak boleh:

- mengubah klaim menjadi lebih benar;
- menambah fakta yang tidak ada di source;
- menghapus kondisi penting;
- mengubah private menjadi general/shared;
- menaikkan confidence/trust;
- membuat Knowledge baru dari informasi yang belum lolos validation;
- mengubah Memory menjadi Knowledge hanya karena formatnya sudah normalized.

## Acquisition / Validation Relationship

Pipeline Phase 3D tetap:

```text
SOURCE / MEMORY / EXPLICIT TEACHING / EXTERNAL REFERENCE
                         ↓
                    ACQUISITION
                         ↓
               KNOWLEDGE CANDIDATE
                         ↓
                    VALIDATION
                         ↓
                   NORMALIZATION
                         ↓
          CLASSIFICATION / TRUST / STORAGE
```

Normalization bukan pengganti validation.

Candidate yang `INVALID` tidak menjadi valid hanya karena normalized.

Candidate `NEEDS_REVIEW` tetap `NEEDS_REVIEW` sampai proses berikutnya memberikan keputusan yang sah.

## Privacy / Generalization

Normalization tidak melakukan private-to-general promotion.

Jika source adalah pengalaman pribadi:

```text
PRIVATE SOURCE
    ↓
NORMALIZED CANDIDATE
```

bukan:

```text
PRIVATE SOURCE
    ↓
NORMALIZED SHARED KNOWLEDGE
```

Scope, visibility, ownership, dan authorization tetap berasal dari boundary yang berlaku.

## Provenance / Versioning

Normalization wajib mempertahankan lineage yang tersedia.

Untuk Knowledge yang merupakan koreksi atau versi baru:

```text
OLD VERSION
    ↓
NEW / NORMALIZED VERSION
    ↓
SUPERSEDES OLD VERSION
```

Normalization tidak menghapus predecessor dan tidak memutus `superseded_by`.

External/reference source tetap mempertahankan source/reference information.

## Confidence / Trust Boundary

Normalization tidak menentukan truth atau trust.

`confidence` hanya dipertahankan bila tersedia dari upstream.

Tidak ada:

- automatic confidence increase;
- trust promotion;
- authoritative source ranking;
- truth verification;
- manual approval policy baru.

Hal tersebut tetap menjadi scope backlog/decision yang relevan.

## Relationship to Existing P3D Artifacts

P3D-001 menyediakan logical Knowledge fields yang menjadi target representation.

P3D-002 menetapkan tiga acquisition source utama:

- memory-derived candidate;
- explicit Owner/User teaching;
- external/reference source.

P3D-003 memisahkan validation dari acquisition dan trust promotion serta menetapkan outcome `VALID`, `INVALID`, dan `NEEDS_REVIEW`.

P3D-004 menggunakan hasil tersebut tanpa membuat storage mutation. Knowledge storage tetap merupakan backlog P3D-006.

## Minimal Realization

BL-P3D-004 direalisasikan sebagai normalization design/contract artifact.

Tidak diperlukan:

- Knowledge table;
- Knowledge RLS;
- migration;
- database function/view;
- indexing;
- retrieval implementation.

Semua itu berada di backlog berikutnya sesuai scope.

## OQ Reconciliation Note

OQ-03/OQ-04 dapat tetap tercatat OPEN secara formal pada Phase -1/documentation layer.

Keputusan Owner/DM yang sudah tersedia memberikan direction praktis yang cukup untuk normalization boundary ini dan tidak mengubah canonical architecture, ownership, privacy, security boundary, atau fundamental flow.

Karena itu formal OQ closure tidak diklaim dan status OQ tidak diperlakukan sebagai practical blocker untuk BL-P3D-004.

## Conclusion

BL-P3D-004 dapat diselesaikan melalui minimal realization pada level normalization contract/design. Normalization menjaga semantic intent, provenance, privacy, context, confidence, dan version lineage tanpa mendahului classification, trust, storage, indexing, atau retrieval.
