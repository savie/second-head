# SECOND HEAD — SH CORE INVENTORY & RECONCILIATION

**Project:** SECOND HEAD (SH)  
**Status:** Living Working Document — Active Reconciliation  
**Bahasa:** Indonesia  
**Scope:** Identity, Conversation, Memory, Knowledge, Experience, Journey, Lifecycle/EOL, Clone, Inheritance, Succession, Recovery, Governance/Runtime  
**Authority Level:** Working / Reconciliation — bukan Canonical  
**Source of Truth Database:** Supabase DEV  
**Historical Evidence:** `dev_old`  
**Current Code:** branch `dev`

---

## 1. Tujuan

Dokumen ini menjadi living document untuk melakukan inventory dan reconciliation terhadap kondisi aktual SH Core di DEV.

Tujuan utamanya bukan langsung menghapus legacy, mengganti arsitektur, atau melakukan implementation. Tujuannya adalah memisahkan secara eksplisit:

1. semantic foundation yang sudah benar dan tervalidasi;
2. implementation legacy yang masih valid sebagai fondasi;
3. legacy residue yang masih membawa semantics lama atau accidental complexity;
4. reconciliation/hardening yang sudah membentuk fondasi baru;
5. gap yang benar-benar terbukti;
6. open decision yang belum boleh diisi dengan asumsi;
7. evolution opportunity yang baru boleh menjadi pekerjaan setelah dependency dan authority jelas.

Dokumen ini tidak mengubah Canonical. Jika ditemukan konflik, konflik dicatat dan authority yang lebih tinggi diprioritaskan.

---

## 2. Authority dan Classification

Authority hierarchy:

```text
OWNER / USER DECISION
        ↓
CANONICAL
        ↓
APPROVED CONTRACT
        ↓
ARCHITECTURE / DESIGN
        ↓
CURRENT IMPLEMENTATION
        ↓
HISTORICAL / dev_old EVIDENCE
```

Classification yang digunakan:

| Label | Makna |
|---|---|
| **CANONICAL / VALIDATED** | Didukung Canonical atau sudah diverifikasi terhadap source of truth yang relevan. |
| **DERIVED / RECONSTRUCTED** | Hasil rekonstruksi/reconciliation dari artefact dan implementation yang ada. |
| **CURRENT IMPLEMENTATION** | Kondisi aktual yang ditemukan pada DEV/repository saat inventory. |
| **LEGACY RESIDUE** | Bagian yang masih membawa pola/semantics historical dan belum dinyatakan sebagai target baru. |
| **GAP** | Kekurangan yang benar-benar terbukti terhadap contract/authority. |
| **OPEN / UNRESOLVED** | Belum cukup bukti atau memang belum diputuskan. |
| **PROPOSED / INTERPRETATION** | Usulan atau interpretasi baru; bukan keputusan. |

**Aturan:** keberadaan nama tabel/function lama tidak otomatis berarti semantics-nya legacy. Sebaliknya, nama baru tidak otomatis berarti semantics-nya sudah baru. Reconciliation harus melihat contract, dependency, source of truth, enforcement, dan verification.

---

## 3. Current DEV Baseline

Baseline database saat dokumen ini dibuat:

- Supabase DEV migration history: **173 entries**.
- Migration terakhir: `20260908032300_actor_resolution_context`.
- Migration reconstruction terhadap `recovery/dev-migrations-172` telah selesai.
- `dev_old` diperlakukan sebagai historical evidence, bukan current source of truth.
- Actor Resolution telah ditutup sebagai scope tersendiri melalui `docs/canonical/sh_actor_resolution_canonical_addendum_v1.0.md`.
- `SYSTEM_RUNTIME` technical mechanism tetap **OPEN** sebagai keputusan teknis tersendiri.

Baseline tidak berarti seluruh domain SH Core sudah selesai atau siap dievolusikan.

---

## 4. SH Core Dependency Order

Reconciliation mengikuti dependency order berikut:

```text
Identity
   ↓
Conversation
   ↓
Memory
   ↓
Knowledge
   ↓
Experience
   ↓
Journey
   ↓
Lifecycle / EOL
   ↓
Clone
   ↓
Inheritance
   ↓
Succession
   ↓
Recovery
   ↓
Governance / Runtime
```

Urutan ini adalah **working reconciliation sequence**, bukan perubahan Canonical baru. Domain berikutnya tidak dianggap siap hanya karena domain sebelumnya memiliki implementation.

Cross-domain dependency tetap harus diperiksa sebelum menyatakan suatu domain closed.

---

## 5. Reconciliation Method

Setiap domain diperiksa dengan urutan:

```text
1. Canonical / Contract
        ↓
2. Supabase schema + data + constraints + RLS
        ↓
3. Backend functions / enforcement
        ↓
4. Current DEV application implementation
        ↓
5. Historical dev_old evidence
        ↓
6. Legacy vs new semantic reconciliation
        ↓
7. Confirmed gaps
        ↓
8. Open decisions
        ↓
9. Evolution opportunities
        ↓
10. Verification status
```

Tidak ada coding pada tahap inventory/reconciliation kecuali user memberikan instruksi implementation setelah gap dikonfirmasi.

---

# 6. DOMAIN INVENTORY

## 6.1 Identity

### Current foundation

**Status awal: CANONICAL / VALIDATED + CURRENT IMPLEMENTATION**

DEV memiliki foundation identity yang terdiri dari:

```text
account_auth_links
        ↓
accounts
        ↓
sh_instances
        ↓
sh_ownership
```

Foundation ini diperkuat dengan:

- `public.resolve_identity()`;
- `public.current_account_id()`;
- trusted Creator Authority resolution;
- `public.resolve_actor_context()`;
- `ResolvedActorContext` pada Flutter;
- auth/session lifecycle wiring.

### Legacy / historical evidence

`dev_old` memiliki lineage identity/governance yang menjadi evidence atas evolusi foundation tersebut.

Historical implementation tidak otomatis menjadi target current design.

### Reconciliation position

Identity merupakan salah satu foundation baru yang paling jelas saat ini.

**Tidak boleh:**

- membuat Account kedua untuk SH-000;
- membuat Primary SH kedua hanya karena designation;
- menggunakan `creator_ref` sebagai authority source;
- menjadikan UI sebagai actor resolver.

### Gap / Open

Tidak ada confirmed Actor Resolution gap pada scope yang sudah ditutup.

Technical `SYSTEM_RUNTIME` mechanism tetap open dan dipisahkan dari identity resolution.

### Evolution opportunity

**OPEN FOR LATER:** identity dapat menjadi stable dependency bagi domain berikutnya, tetapi tidak perlu diredesign tanpa gap nyata.

---

## 6.2 Conversation

### Current foundation

**Status awal: CURRENT IMPLEMENTATION / RECONCILED FOUNDATION**

DEV saat ini memiliki:

- `projects`;
- `conversation_threads`;
- conversation message compatibility layer;
- thread foreign-key reconciliation;
- empty-thread creation;
- initial greeting;
- project/conversation management runtime;
- recovery ↔ conversation hierarchy integration.

Recent migration lineage menunjukkan conversation telah melalui beberapa tahap reconciliation/hardening, bukan sekadar historical carry-over.

### Legacy residue

Masih terdapat artefact/runtime lineage conversation lama yang perlu dibandingkan dengan hierarchy baru. Migration `20260907054613_retire_legacy_conversation_runtime_execute` menunjukkan sebagian runtime historical telah secara eksplisit dipensiunkan.

### Reconciliation questions

- Apakah `conversation_threads` sudah menjadi semantic thread boundary yang konsisten di seluruh backend dan frontend?
- Apakah `conversations` yang masih ada merupakan compatibility residue atau masih memiliki active semantic role?
- Apakah project → conversation → thread hierarchy konsisten dengan persistence dan recovery?
- Apakah message compatibility layer hanya compatibility atau masih membawa semantics lama?
- Apakah seluruh runtime read/write memakai trusted identity dan target ownership yang sama?

### Confirmed gap

Belum dinyatakan ada gap semantic baru. Inventory detail masih diperlukan.

### Status

**OPEN / RECONCILIATION IN PROGRESS**

---

## 6.3 Memory

### Current foundation

DEV memiliki domain `memories` dan sejumlah migration untuk storage, retrieval, relevance, lifecycle, dan transfer/privacy policy.

### Legacy residue

Domain memory memiliki lineage yang panjang sehingga perlu dibedakan antara:

- storage model yang masih valid;
- retrieval logic yang sudah direkonsiliasi;
- policy historical;
- compatibility/reconciliation layer.

### Semantic boundary

```text
Memory ≠ Context
Memory ≠ Knowledge
Memory ≠ Conversation
```

### Reconciliation questions

- Apa yang benar-benar menjadi source of truth memory?
- Apakah retrieval tetap bound ke trusted SH/account context?
- Apakah privacy/visibility dipisahkan dari transfer eligibility?
- Apakah lifecycle memory berbeda dari lifecycle SH?
- Apakah learning benar-benar dipisahkan dari automatic Core modification?

### Status

**OPEN / RECONCILIATION REQUIRED**

---

## 6.4 Knowledge

### Current foundation

DEV memiliki domain `knowledge`, indexing/retrieval lineage, serta validasi private `sh_id` foreign key.

Migration `20260907044648_validate_knowledge_private_sh_id_fk` menunjukkan integrity boundary telah diperkuat.

### Semantic boundary

```text
Knowledge ≠ Memory
Knowledge ≠ Context
```

### Legacy residue

Perlu diperiksa apakah historical retrieval/indexing assumptions masih bercampur dengan memory semantics atau provider-specific implementation.

### Reconciliation questions

- Apakah ownership/privacy boundary knowledge konsisten?
- Apakah private SH linkage enforced, bukan hanya convention?
- Apakah retrieval memakai trusted identity context?
- Apakah knowledge mutation mempunyai authorization boundary yang tepat?

### Status

**CURRENT FOUNDATION EXISTS / SEMANTIC RECONCILIATION OPEN**

---

## 6.5 Experience

### Current foundation

DEV memiliki domain `experiences` dengan account/SH scoping.

### Semantic boundary

```text
Experience ≠ Conversation
Experience ≠ Journey
Experience ≠ Memory
```

### Legacy residue

Perlu dibuktikan apakah Experience sudah benar-benar menjadi domain semantic tersendiri atau masih menyimpan historical assumptions dari conversation/journey.

### Reconciliation questions

- Apa event/record yang membentuk Experience?
- Apa relation Experience terhadap Memory dan Journey?
- Apakah provenance dan ownership konsisten?
- Apakah Experience dapat dibangun ulang dari continuity data tanpa mengubah SH identity?

### Status

**OPEN / RECONCILIATION REQUIRED**

---

## 6.6 Journey

### Current foundation

DEV memiliki `journey_events` dan lineage yang mencakup continuity/gap/transfer/lifecycle/provenance.

### Semantic boundary

Journey adalah continuity/history domain dan bukan synonym Experience.

### Legacy residue

Journey memiliki complexity tinggi karena berpotensi bersinggungan dengan conversation, experience, lifecycle, recovery, dan transfer.

### Reconciliation questions

- Apa unit canonical Journey?
- Apa boundary antara Journey event dan Experience record?
- Bagaimana provenance dipertahankan?
- Bagaimana recovery memulihkan continuity tanpa membuat identity baru?
- Apakah transfer/inheritance semantics tidak bocor ke Journey identity?

### Status

**OPEN / CROSS-DOMAIN RECONCILIATION REQUIRED**

---

## 6.7 Lifecycle / EOL

### Current foundation

DEV memiliki lifecycle/deactivation/terminal guard/transfer boundary lineage.

Canonical boundary yang harus dipertahankan:

```text
DECOMMISSION ≠ immediate permanent delete
```

Lifecycle juga harus tetap dipisahkan dari ownership transfer dan identity recreation.

### Legacy residue

Historical EOL implementation perlu diperiksa untuk memastikan terminal semantics tidak tercampur dengan deletion, clone, recovery, atau transfer.

### Reconciliation questions

- Apakah terminal state authoritative?
- Apakah EOL guard enforced backend?
- Apakah decommission dapat direcover tanpa identity recreation?
- Apakah lifecycle state menjadi prerequisite yang benar untuk clone/inheritance/succession?

### Status

**FOUNDATION EXISTS / VERIFICATION AND CROSS-DOMAIN RECONCILIATION OPEN**

---

## 6.8 Clone

### Current foundation

DEV memiliki:

- `clone_agreements`;
- `sh_clones`;
- clone materialization lineage;
- privacy/authorization boundary.

Canonical distinction:

```text
CLONE_SH ≠ SOURCE_SH
CLONE ≠ Source Identity
```

Creator SH non-clonable dan User SH clone memerlukan Owner Approval + Agreement sesuai Canonical/approved contract.

### Legacy residue

Perlu dipastikan tidak ada historical clone path yang mem-bypass agreement, authorization, atau identity distinction.

### Reconciliation questions

- Apakah clone identity benar-benar baru dan bukan alias source?
- Apakah source ownership dan clone ownership dipisahkan?
- Apakah privacy boundary tetap eksplisit?
- Apakah recovery atau inheritance pernah menggunakan clone path secara tidak semestinya?

### Status

**STRONG FOUNDATION / VERIFICATION OPEN**

---

## 6.9 Inheritance

### Current foundation

DEV memiliki:

- `inheritance_authorizations`;
- `inheritance_events`;
- transfer/eligibility lineage.

Canonical distinction:

```text
INHERITANCE ≠ CLONE
INHERITANCE ≠ automatic identity transfer
```

### Legacy residue

Inheritance harus diperiksa terhadap historical transfer semantics agar tidak berubah menjadi clone atau ownership shortcut.

### Reconciliation questions

- Apa authorization boundary inheritance?
- Apa yang diwariskan: data, capability, continuity, ownership, atau kombinasi yang secara eksplisit dikontrak?
- Apakah identity tetap dibedakan dari ownership transfer?
- Apakah privacy/visibility tidak disamakan dengan transfer eligibility?

### Status

**FOUNDATION EXISTS / SEMANTIC RECONCILIATION OPEN**

---

## 6.10 Succession

### Current foundation

DEV memiliki:

- `succession_rules`;
- `succession_events`;
- succession validation/runtime lineage;
- explicit scope validation primitives.

### Security note

Authenticated `runtime_execute_succession(uuid)` adalah wrapper runtime yang perlu diaudit secara semantic terhadap trusted identity/ownership boundary.

Unchecked primitives terkait succession tidak exposed kepada authenticated caller secara langsung.

### Reconciliation questions

- Apakah `succession_rules` menjadi authoritative rule layer?
- Apakah rule ownership/authority scope tervalidasi sebelum execution?
- Apakah successor account semantics sesuai contract?
- Apakah EOL prerequisite enforced?
- Apakah succession execution tetap membedakan identity, ownership, dan authority?

### Status

**OPEN / SECURITY + SEMANTIC RECONCILIATION REQUIRED**

Ini adalah dependency penting sebelum Step 7 Security Harness dapat dinyatakan complete.

---

## 6.11 Recovery

### Current foundation

DEV memiliki:

- `recovery_snapshots`;
- `recovery_events`;
- recovery/restore lineage;
- recovery ↔ conversation hierarchy integration.

Canonical distinction:

```text
Recovery ≠ Clone Creation
Recovery ≠ new SH identity
```

### Legacy residue

Recovery harus diperiksa terhadap historical restore paths agar restore tidak secara tidak sengaja membuat identity baru, menggandakan ownership, atau mengubah continuity semantics.

### Reconciliation questions

- Apa exact recovery unit?
- Snapshot mencakup state apa saja?
- Apakah restore mempertahankan Account/SH identity?
- Bagaimana conversation continuity dipertahankan?
- Apakah restore authorization bound ke trusted owner/authority?
- Apakah recovery event/audit menjadi evidence yang cukup?

### Status

**FOUNDATION EXISTS / CROSS-DOMAIN VERIFICATION OPEN**

---

## 6.12 Governance / Runtime

### Current foundation

Ini adalah salah satu foundation baru terkuat di DEV.

Komponen utama yang sudah ditemukan:

```text
resolve_identity()
        ↓
governance_evaluator()
        ↓
policy_enforcement_engine()
        ↓
isolation_checker()
        ↓
access_decision_gate()
        ↓
runtime_access_boundary()
        ↓
Runtime Entry Points
```

Tambahan Actor Resolution:

```text
resolve_actor_context()
        ↓
Resolved Actor / Identity Context
```

### Security foundation

- RLS aktif pada domain tables yang diaudit.
- Authenticated runtime surface telah di-inventory.
- Anon EXECUTE surface telah diperiksa.
- Unchecked runtime primitives succession/inheritance/legacy tidak exposed langsung kepada authenticated caller.
- SELF / OTHER / SPOOF / UNAUTH runtime boundary tests telah PASS pada representative runtime access boundary.

### Confirmed open point

`runtime_execute_succession(uuid)` memiliki authenticated EXECUTE tetapi tidak secara langsung memanggil trusted identity helper. Ia harus direkonsiliasi terhadap authoritative succession validation sebelum Security Harness ditutup.

### SYSTEM_RUNTIME

```text
SYSTEM_RUNTIME ≠ SH Identity
```

Trusted PostgreSQL `SECURITY DEFINER` runtime infrastructure sudah menjadi fondasi execution boundary, tetapi technical semantic mechanism untuk menyatakan `SYSTEM_RUNTIME` secara eksplisit tetap **OPEN**.

### Status

**STRONG FOUNDATION / SECURITY HARNESS NOT YET CLOSED**

---

# 7. CROSS-DOMAIN RECONCILIATION MATRIX

| Domain | Foundation DEV | Legacy Residue | Confirmed Gap | Status |
|---|---|---|---|---|
| Identity | Kuat | Historical lineage | Tidak pada Actor Resolution scope | VALIDATED / CLOSED |
| Conversation | Ada hierarchy/runtime baru | Compatibility + retired lineage | Belum | OPEN |
| Memory | Ada domain + retrieval lineage | Banyak reconciliation layer | Belum | OPEN |
| Knowledge | Ada domain + FK integrity | Retrieval/indexing lineage | Belum | OPEN |
| Experience | Ada domain | Perlu semantic isolation check | Belum | OPEN |
| Journey | Ada continuity domain | Complexity lintas domain | Belum | OPEN |
| Lifecycle/EOL | Ada guard/deactivation lineage | Historical EOL paths | Belum | OPEN |
| Clone | Agreement + clone model | Historical clone paths perlu audit | Belum | OPEN |
| Inheritance | Authorization + event | Transfer legacy semantics perlu audit | Belum | OPEN |
| Succession | Rules + events + runtime | Wrapper semantic boundary | **Validation gap under audit** | OPEN / BLOCKED FOR SECURITY CLOSE |
| Recovery | Snapshot + events + continuity | Restore legacy semantics perlu audit | Belum | OPEN |
| Governance/Runtime | Sangat kuat | Sebagian historical runtime residue | Succession wrapper validation | OPEN |

Matrix ini adalah working inventory, bukan Canonical map.

---

# 8. LEGACY VS NEW FOUNDATION — WORKING MODEL

Working interpretation saat ini:

```text
LEGACY
  │
  ├── Historical UI / provider assumptions
  ├── Old runtime paths
  ├── Compatibility layers
  └── Historical semantics yang belum direkonsiliasi
             │
             ▼
      RECONCILIATION / HARDENING
             │
             ▼
NEW SH FOUNDATION
  │
  ├── Stable Identity
  ├── Explicit Ownership
  ├── Trusted Actor Resolution
  ├── Backend Governance
  ├── Runtime Boundary
  ├── Conversation Hierarchy
  ├── State / Recovery Foundation
  └── Explicit Lifecycle / Clone / Inheritance / Succession domains
```

Ini bukan keputusan bahwa seluruh legacy harus dihapus. Setiap historical component harus dinilai berdasarkan semantics dan dependency aktual.

---

# 9. CONFIRMED BLOCKERS

Saat dokumen ini dibuka, blocker yang masih jelas dari reconciliation/security sequence:

1. `runtime_execute_succession()` harus direkonsiliasi terhadap authoritative succession validation sebelum Security Harness dinyatakan complete.
2. Cross-domain semantic reconciliation belum selesai untuk Conversation → Memory → Knowledge → Experience → Journey.
3. Lifecycle/EOL → Clone → Inheritance → Succession → Recovery relationship masih membutuhkan verification.
4. `SYSTEM_RUNTIME` technical mechanism masih OPEN.

Tidak ada blocker baru yang boleh diciptakan hanya karena historical code terlihat berbeda dari current design.

---

# 10. RULES FOR NEXT WORK

1. Jangan coding hanya karena menemukan legacy residue.
2. Jangan menghapus historical implementation tanpa confirmed semantic replacement.
3. Jangan menjadikan nama tabel/function sebagai bukti semantics.
4. Jangan menggunakan `dev_old` sebagai current authority.
5. Gunakan Supabase DEV sebagai source of truth database/runtime state.
6. Gunakan Canonical dan approved contract sebagai semantic authority.
7. Setiap gap harus dibuktikan sebelum implementation.
8. Setiap proposed evolution harus diberi label **PROPOSED / INTERPRETATION**.
9. Jika dependency belum selesai, domain berikutnya tidak dianggap ready.
10. Security Harness tidak boleh ditutup sebelum succession wrapper audit selesai.
11. Actor Resolution Addendum tidak dibuka ulang kecuali ditemukan contradiction nyata terhadap Canonical/contract.
12. Dokumen ini boleh berubah mengikuti hasil inventory, tetapi perubahan tidak mengubah authority layer di atasnya.

---

# 11. NEXT RECONCILIATION TARGET

Target berikutnya adalah melanjutkan inventory secara evidence-driven, dimulai dari:

```text
Conversation
    ↓
Memory
    ↓
Knowledge
    ↓
Experience
    ↓
Journey
```

Untuk setiap domain, hasil final harus memisahkan:

```text
CANONICAL / VALIDATED
DERIVED / RECONSTRUCTED
CURRENT IMPLEMENTATION
LEGACY RESIDUE
CONFIRMED GAP
OPEN / UNRESOLVED
PROPOSED / INTERPRETATION
```

Tidak ada implementation change yang dihasilkan dari dokumen ini sampai confirmed gap dan execution scope disetujui.

---

## 12. Verification Vocabulary

Gunakan istilah berikut secara ketat:

- **Specified** — requirement/contract sudah ditentukan.
- **Designed** — architecture/design sudah ditentukan.
- **Implemented** — code/schema/function sudah ada.
- **Integrated** — komponen sudah terhubung ke lifecycle/runtime yang relevan.
- **Persisted** — state/data benar-benar tersimpan pada source of truth.
- **Verified** — behaviour telah diuji terhadap contract.
- **E2E Verified** — behaviour telah dibuktikan melalui jalur end-to-end yang relevan.

Keberadaan migration atau function tidak sama dengan Verified.

---

## 13. Final Working Rule

SH Core tidak boleh dinilai dengan binary:

```text
legacy = buruk
baru = benar
```

Model kerja yang digunakan adalah:

```text
Historical Evidence
        ↓
Semantic Reconciliation
        ↓
Validated Foundation
        ↓
Confirmed Gap
        ↓
Targeted Implementation
        ↓
Verification
        ↓
SH Core Evolution
```

Dokumen ini tetap living dan dapat diperbarui setelah evidence baru ditemukan. Ia bukan Canonical dan tidak boleh menjadi alasan untuk mengubah Canonical secara diam-diam.
