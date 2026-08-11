# SECOND HEAD — P3D Knowledge Provenance

## Status
IMPLEMENTATION COMPLETE — BL-P3D-008 / AC-KNOW-08

## Purpose

Menetapkan dan merealisasikan provenance/lineage Knowledge pada batas minimal yang sudah didukung oleh desain dan storage Phase 3D, tanpa membuat provenance graph, trust engine, atau ownership model baru.

## Authority / Reconciliation

Direkonsiliasikan terhadap:

- SH Core Canonical v1.0
- SH Full Build Scope v1.0
- SH Full Implementation Contract v1.0
- SH Full Implementation Guide v1.0
- Phase -1 backlog
- P3D-001 Knowledge Schema Design
- P3D-002 Knowledge Acquisition
- P3D-006 Knowledge Storage
- Owner/DM decisions mengenai provenance, privacy/generalization, sharing, dan superseded

## Minimal Provenance Model

Knowledge mempertahankan dua lapisan asal-usul:

1. `source`
   - sumber langsung/reference source;
   - dapat berisi identifier atau reference yang tersedia pada saat acquisition.

2. `provenance`
   - metadata JSONB untuk lineage/asal-usul yang lebih lengkap;
   - tidak memaksa format provenance graph tertentu;
   - tidak membuka identity private kepada consumer yang tidak berwenang.

Version/supersession tetap dipisahkan dari provenance:

`version` + `superseded_by` menjaga hubungan antar versi Knowledge.

## Provenance Boundary

Provenance harus:

- dipertahankan ketika Knowledge berpindah atau digunakan kembali;
- dapat merujuk source/reference bila tersedia;
- tidak mengubah private source menjadi public identity disclosure;
- tidak memberikan authorization baru;
- tidak otomatis membuat Knowledge menjadi trusted/true;
- tidak mengubah Core.

Private source identity privacy tetap mengikuti ownership/privacy/governance layer yang sudah ada.

## Existing Physical Realization

`public.knowledge` yang direalisasikan pada BL-P3D-006 sudah menyediakan:

- `source TEXT`
- `provenance JSONB`
- `version INTEGER`
- `superseded_by UUID`

Dengan demikian BL-P3D-008 tidak membutuhkan schema mutation baru.

## Relationship to Acquisition

Acquisition tetap menghasilkan candidate dengan source/provenance bila tersedia.

Pipeline:

`SOURCE / MEMORY / EXPLICIT TEACHING`
`↓`
`ACQUISITION`
`↓`
`KNOWLEDGE CANDIDATE`
`↓`
`VALIDATION / CLASSIFICATION / TRUST`
`↓`
`KNOWLEDGE + SOURCE/PROVENANCE`

P3D-008 tidak mengubah acquisition boundary dan tidak membuat trust-promotion rule baru.

## Relationship to Supersession

Jika Knowledge dikoreksi:

`Knowledge v1`
`↓`
`Knowledge v2`

`v1.superseded_by → v2`

Provenance tetap tersedia pada masing-masing record sehingga lineage source dan lineage version tidak tercampur.

## Non-Goals

P3D-008 tidak membuat:

- provenance graph;
- external citation crawler;
- source trust ranking;
- automatic trust promotion;
- private-to-general promotion;
- cross-SH authorization;
- sharing engine;
- Core modification.

## Conclusion

BL-P3D-008 dapat diselesaikan melalui existing Knowledge storage realization. `source` dan `provenance` sudah tersedia sebagai persistent metadata, sedangkan `version` dan `superseded_by` menjaga version lineage. Tidak ada architectural atau schema mutation tambahan yang diperlukan.
