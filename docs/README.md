# SECOND HEAD — Documentation

Folder ini menampung dokumentasi SH dengan pemisahan yang jelas antara baseline reference, technology boundary, architecture, contract, dan dokumentasi lain yang akan ditambahkan sesuai kebutuhan.

## Authority

- Canonical tetap menjadi authority tertinggi SH.
- Dokumen di repository ini tidak mengubah Canonical kecuali dinyatakan dan dipromosikan secara eksplisit.
- Dokumen non-Canonical harus mempertahankan status dan perannya dengan jelas.
- `dev_old` digunakan sebagai reference/evidence bila dinyatakan oleh dokumen terkait.
- Technology dan implementation tidak menjadi authority atas SH semantics.

## Struktur

```
docs/
├── README.md
├── canonical/
│   ├── README.md
│   ├── sh_canonical_map.md
│   ├── sh_architecture_map.md
│   ├── sh_supabase_map.md
│   └── sh_foundation_blueprint.md
├── technology/
│   ├── README.md
│   └── sh_technology_boundaries.md
├── architecture/
│   ├── README.md
│   └── sh_flutter_dart_architecture_and_implementation_working.md
└── contract/
    └── sh_project_conversation_message_contract.md
```

### canonical/

Berisi empat dokumen baseline reference yang merupakan hasil reconcile terhadap `dev_old` dan digunakan sebagai navigasi/reference foundation. Dokumen di sini tidak menggantikan source Canonical.

### technology/

Berisi Technology Boundaries yang menetapkan batas teknologi untuk implementation.

### architecture/

Berisi architecture dan implementation working reference untuk pembangunan SH dengan Flutter + Dart.

### contract/

Berisi approved working contract yang menetapkan scope, boundary, behavior, dependency, dan execution constraint untuk bagian SH tertentu. Contract tidak mengubah Canonical kecuali dipromosikan secara eksplisit melalui authority yang sesuai.

## Aturan Dokumentasi

- Jangan membuat dokumen baru jika kebutuhan masih dapat dipenuhi oleh dokumen yang sudah tepat.
- Jangan mencampurkan Canonical, approved contract, working document, reference, dan evidence tanpa klasifikasi.
- Gunakan Bahasa Indonesia kecuali Canonical dan istilah teknis yang memang perlu dipertahankan dalam bahasa Inggris.
- Struktur folder tidak mengikuti `dev_old` secara otomatis; struktur mengikuti kebutuhan SH saat ini.
