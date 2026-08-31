# SECOND HEAD (SH) v1.0

**Target implementasi repository:** `dev`  
**Status foundation:** Baseline foundation hasil rekonstruksi

SECOND HEAD adalah persistent personal intelligence system yang dibangun di atas SH Core, persistent identity, continuity, governance, privacy, dan runtime yang dapat berevolusi tanpa menyamakan SH dengan model, runtime, database, atau hardware.

## Dokumen Utama

```
README.md

docs/
├── sh_canonical_map.md
├── sh_architecture_map.md
├── sh_supabase_map.md
└── sh_foundation_blueprint.md
```

## Cara Membaca

```
sh_canonical_map.md
        ↓
sh_architecture_map.md
        ↓
sh_supabase_map.md
        ↓
sh_foundation_blueprint.md
```

Keempat dokumen adalah foundation maps/blueprint untuk fresh reconstruction. Mereka tidak menggantikan source authority di `dev_old`.

## Batas Sumber

```
dev_old = sumber / referensi / riwayat
dev     = rekonstruksi clean saat ini / target implementasi
```

`dev_old` digunakan untuk mengambil konsep tervalidasi, contract, architecture, capability intent, historical lessons, dan evidence. Historical implementation tidak dicopy wholesale ke `dev`.

## Constraint Saat Ini

```
zero-budget;
zero-hardware.
```

Keduanya adalah constraint kondisi pembangunan saat ini, bukan identitas atau batas permanen SH.

## Prinsip

> Familiar interaction, different brain/system.

SH harus terasa familiar untuk digunakan, tetapi sistem di belakangnya mempertahankan identity, continuity, privacy, governance, authorization, dan capability boundaries miliknya sendiri.

## Prinsip Rekonstruksi

```
design
   ↓
architecture mapping
   ↓
canonical validation
   ↓
capability mapping
   ↓
implementation
   ↓
verification
```

Design baru tidak boleh mengubah Canonical secara diam-diam.

## Otoritas Saat Ini

Otoritas Canonical saat ini adalah SH Core Canonical bersama Canonical Addendum yang lebih baru dan authoritative untuk area semantik yang diaturnya. Frozen Baseline yang telah disupersede merupakan materi historis/provenance dan tidak mengesampingkan koreksi authoritative yang lebih baru.

Clean baseline harus mempertahankan boundary SH berikut: 1 Email = 1 Account = 1 Primary SH; DECOMMISSION ≠ Immediate Permanent Delete; USER_SH Clone = Owner Approval + Agreement; INHERITANCE ≠ CLONE; INHERITANCE ≠ Identity Transfer; EVOLUTION ≠ Ownership Transfer; Evolution / Migration / Recovery ≠ New SH Identity; Privacy / Visibility ≠ Transfer Eligibility; Core Evolution memerlukan Governance / Review.

## Status

Foundation baseline telah direkonstruksi dari `dev_old` dan hasil dua audit DEV ↔ DEV_OLD. Capability yang belum direalisasikan tetap dicantumkan sebagai target dan tidak boleh dianggap verified hanya karena telah dipetakan.
