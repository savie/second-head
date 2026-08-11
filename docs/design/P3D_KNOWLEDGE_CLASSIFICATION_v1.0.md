# SECOND HEAD — P3D Knowledge Classification

## Status

**DESIGN COMPLETE — BL-P3D-005 / AC-KNOW-05**

## Purpose

Mendefinisikan classification boundary untuk Knowledge candidate setelah acquisition, validation, dan normalization.

Classification menentukan kategori representasi Knowledge yang sudah memiliki dasar dari authority dan keputusan Owner/DM. Classification tidak menentukan kebenaran absolut, tidak melakukan trust promotion, tidak memberikan akses baru, dan tidak mengubah Core.

## Authority / Reconciliation

Sumber yang direkonsiliasi:

- SH Core Canonical v1.0;
- SH Full Build Scope v1.0;
- SH Full Implementation Contract v1.0;
- SH Full Implementation Guide v1.0;
- Phase -1 backlog: `BL-P3D-005 — Knowledge Classification / AC-KNOW-05`;
- P3D-001 Knowledge Schema Design;
- P3D-002 Knowledge Acquisition;
- P3D-003 Knowledge Validation;
- P3D-004 Knowledge Normalization;
- existing P3B knowledge-eligibility implementation;
- Owner / DM decision notes mengenai Memory → Understanding → Knowledge, explicit teaching, occurrence threshold, privacy/generalization, provenance, sharing, superseded, dan external/reference source.

Boundary invariants yang dipertahankan:

- `KNOWLEDGE ≠ MEMORY`;
- `KNOWLEDGE ≠ CONTEXT`;
- private information tidak otomatis menjadi shared/general Knowledge;
- sharing tetap mengikuti ownership/privacy/governance boundary;
- Knowledge mempertahankan source/provenance;
- `Learning ≠ Automatic Core Modification`;
- classification ≠ validation ≠ trust promotion;
- Knowledge ≠ Guaranteed Result.

## Classification Categories

Implementation Guide dan P3D-001 menyediakan kategori minimal berikut:

1. `CANONICAL`
2. `DERIVED`
3. `LEARNED`
4. `IMPORTED`
5. `TEMPORARY`

Representasi schema menggunakan `knowledge_class`.

Nama kategori di atas adalah representasi teknis dari kategori Knowledge yang sudah ada. Classification tidak membuat kategori baru pada backlog ini.

## Classification Boundary

Classification menjawab pertanyaan:

> "Knowledge ini termasuk kategori apa berdasarkan asal-usul dan status yang sudah diketahui?"

Classification tidak menjawab:

- apakah Knowledge benar secara absolut;
- apakah Knowledge harus dipercaya secara final;
- apakah Knowledge boleh dibagikan;
- apakah Knowledge menjadi Core;
- apakah source tertentu selalu lebih benar daripada source lain;
- apakah Knowledge menjamin hasil implementasi.

Dengan demikian classification adalah **categorization**, bukan **truth adjudication**.

## Minimum Classification Rules

### 1. Canonical Knowledge

`CANONICAL` hanya digunakan bila Knowledge memang berasal dari atau telah ditetapkan oleh authority yang sah sebagai canonical knowledge.

Candidate tidak boleh menjadi `CANONICAL` hanya karena:

- occurrence_count tinggi;
- confidence tinggi;
- berasal dari user/Owner;
- berasal dari external source;
- sering digunakan;
- lolos validation.

Classification tidak memiliki kewenangan untuk membuat sesuatu menjadi canonical.

### 2. Derived Knowledge

`DERIVED` digunakan ketika Knowledge merupakan hasil turunan/inferensi yang dibentuk dari Knowledge/source lain yang sudah tersedia, dengan hubungan derivation yang dapat ditelusuri.

Derived Knowledge tidak boleh diperlakukan sebagai source original dan tidak boleh menghapus provenance upstream.

Derivation juga tidak otomatis menaikkan trust atau menjadikan hasilnya canonical.

### 3. Learned Knowledge

`LEARNED` digunakan untuk Knowledge yang diperoleh melalui proses pembelajaran SH, termasuk Knowledge yang berasal dari memory-derived candidate atau explicit Owner/User teaching, setelah memenuhi validation boundary yang berlaku.

Rule praktis upstream tetap berlaku:

```text
occurrence_count >= 5
→ knowledge_candidate = true
```

Threshold tersebut adalah eligibility signal, bukan bukti kebenaran dan bukan automatic classification menjadi `CANONICAL`.

Explicit teaching dapat menjadi acquisition/learning signal, tetapi tidak otomatis menjadi canonical, trusted final, atau shared.

### 4. Imported Knowledge

`IMPORTED` digunakan untuk Knowledge yang diperoleh dari external/reference source dan dipertahankan bersama source/reference information.

Imported tidak berarti untrusted dan juga tidak berarti trusted secara final.

Classification tidak menetapkan ranking kepercayaan berdasarkan asal source.

### 5. Temporary Knowledge

`TEMPORARY` digunakan untuk Knowledge yang secara eksplisit hanya dimaksudkan untuk penggunaan sementara atau lifecycle terbatas.

Temporary tidak berarti salah atau tidak berguna.

Classification ini tidak otomatis menentukan kapan record harus dihapus atau diarsipkan; lifecycle tetap mengikuti lifecycle policy yang relevan.

## Precedence / Ambiguity Rule

Classification harus menggunakan bukti yang tersedia dan tidak boleh mengarang provenance atau intent.

Jika satu candidate memenuhi lebih dari satu karakteristik, classification harus mempertahankan kategori yang paling dapat dibuktikan dari source/decision metadata yang tersedia.

Prioritas praktis untuk mencegah klaim berlebihan:

```text
EXPLICIT CANONICAL AUTHORITY
        ↓
EXPLICIT TEMPORARY INTENT
        ↓
EXPLICIT EXTERNAL / REFERENCE ORIGIN
        ↓
EXPLICIT DERIVATION RELATIONSHIP
        ↓
LEARNING / ACQUISITION ORIGIN
        ↓
NEEDS REVIEW IF BASIS IS INSUFFICIENT
```

Urutan ini bukan trust ranking. Ini hanya aturan deterministik untuk memilih classification berdasarkan evidence yang tersedia.

Jika evidence tidak cukup untuk membedakan kategori secara aman, classification tidak boleh dipaksakan. Candidate dapat ditandai `NEEDS_REVIEW` pada decision layer yang menggunakan classification.

## Privacy / Sharing Boundary

Classification tidak memberikan akses baru.

Private source tetap private/scoped meskipun candidate diklasifikasikan sebagai `LEARNED`, `DERIVED`, atau kategori lain.

`LEARNED` tidak berarti otomatis shared.

`IMPORTED` tidak berarti otomatis public.

`CANONICAL` tidak berarti akses ke private source menjadi terbuka.

Scope, visibility, ownership, dan authorization tetap berasal dari governance/security boundary yang sudah ada.

## Provenance / Lineage

Classification wajib mempertahankan provenance.

Contoh:

```text
User / Memory / External Source
            ↓
       Knowledge Candidate
            ↓
        Classification
            ↓
      knowledge_class
```

Kategori tidak menggantikan source atau lineage.

Untuk `DERIVED`, hubungan ke source/upstream Knowledge harus tetap dapat ditelusuri bila tersedia.

Untuk `IMPORTED`, external/reference source harus tetap tersedia.

Source identity private tidak perlu dibuka kepada user lain hanya karena classification dilakukan.

## Confidence / Trust Boundary

Classification tidak menghitung ulang `confidence`.

Classification tidak menaikkan confidence.

Classification tidak melakukan trust promotion.

Classification juga tidak menganggap:

```text
confidence = high
→ CANONICAL
```

atau:

```text
occurrence_count >= 5
→ CANONICAL
```

Keduanya tidak sah.

## Validation Relationship

Pipeline Phase 3D:

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
                  CLASSIFICATION
                         ↓
          TRUST / STORAGE / PROVENANCE / INDEXING
```

Candidate `INVALID` tidak boleh dipromosikan menjadi Knowledge hanya karena classification.

Candidate `NEEDS_REVIEW` tidak boleh diperlakukan sebagai final Knowledge hanya karena sebuah class dapat ditebak.

Classification dilakukan terhadap candidate yang sudah melewati boundary validation/normalization yang berlaku.

## Core Boundary

Classification tidak mengubah Core.

```text
CLASSIFICATION
      ↓
KNOWLEDGE CATEGORY
      ↓
NOT AUTOMATIC CORE MODIFICATION
```

Jika suatu Knowledge pada masa depan memenuhi syarat untuk digunakan dalam Core, proses tersebut harus mengikuti governance dan authority yang relevan.

## Storage Boundary

Knowledge Storage adalah `BL-P3D-006`.

Karena itu `BL-P3D-005` tidak membutuhkan:

- Knowledge table;
- Knowledge RLS;
- Knowledge migration;
- Knowledge database function/view;
- Knowledge indexing;
- Knowledge retrieval implementation.

`knowledge_class` sudah merupakan bagian dari logical schema P3D-001 dan dapat menjadi field storage pada backlog berikutnya.

## OQ Reconciliation Note

OQ-03/OQ-04 dapat tetap tercatat OPEN secara formal pada Phase -1/documentation layer.

Keputusan Owner/DM terbaru memberikan direction praktis yang cukup untuk classification boundary ini dan tidak mengubah canonical architecture, ownership, privacy, security boundary, atau fundamental flow.

Karena itu:

`FORMAL OQ CLOSURE = NOT CLAIMED`

`PRACTICAL IMPLEMENTATION DIRECTION = SUFFICIENT FOR P3D-005`

Status OQ formal tidak diperlakukan sebagai practical blocker untuk backlog ini selama classification tetap pada boundary di atas.

## Minimal Realization

BL-P3D-005 direalisasikan sebagai:

1. classification contract/design artifact;
2. deterministic category rules untuk lima kategori yang sudah tersedia;
3. traceability terhadap P3D-001 sampai P3D-004, P3B eligibility, dan Owner/DM decisions;
4. evidence reconciliation;
5. tanpa mutation Knowledge storage di Supabase.

## Non-Goals

BL-P3D-005 tidak menetapkan atau mengimplementasikan:

- trust-promotion algorithm;
- authoritative source ranking;
- universal truth verification;
- automatic private-to-general sharing;
- Core modification;
- Knowledge storage;
- Knowledge indexing;
- Knowledge retrieval;
- new Knowledge categories;
- new RLS/authorization model;
- automatic confidence recalculation.

## Conclusion

BL-P3D-005 dapat diselesaikan melalui minimal classification contract/design. Classification menyediakan kategori Knowledge yang deterministik dan dapat diaudit tanpa mengubah makna Knowledge, provenance, privacy, ownership, trust boundary, atau Core governance.
