# SECOND HEAD — Backend / Frontend Reconciliation Status

## Status

**Working status record — sementara.**

Dokumen ini mencatat hasil pekerjaan dan posisi sementara rekonsiliasi Backend (Supabase) → Frontend (Flutter) sampai titik kerja saat ini.

Dokumen ini **bukan Canonical** dan tidak mengubah Canonical maupun Approved Contract yang sudah ada.

Dokumen ini dibuat sebagai **working checkpoint** agar urutan pekerjaan, blocker, dependency, dan status tidak hilang selama proses pembangunan masih berlangsung.

Setelah seluruh pekerjaan selesai dan baseline final sudah stabil, dokumen ini dapat digantikan dengan dokumen final yang menetapkan langkah kerja final (9 atau 10 langkah sesuai hasil akhir).

`dev_old` digunakan sebagai historical reference/evidence dan bukan baseline implementation baru.

---

## 1. Authority dan Prinsip Kerja

Urutan authority tetap:

```text
OWNER / USER DECISION
        ↓
CANONICAL
        ↓
APPROVED CONTRACT
        ↓
ARCHITECTURE / DESIGN
        ↓
IMPLEMENTATION
```

Prinsip kerja untuk checkpoint ini:

1. Backend / Supabase menjadi authority untuk identity, ownership, authority, permission, capability, dan runtime enforcement.
2. Frontend mengikuti contract dan capability yang disediakan backend; frontend tidak boleh menebak authority secara mandiri dari field ownership yang tidak dimaksudkan sebagai authority.
3. Tidak ada perubahan Canonical melalui pekerjaan di dokumen ini.
4. Historical implementation dari `dev_old` hanya digunakan untuk rekonstruksi maksud, lineage, dan evidence.
5. Status `deferred`, `superseded`, `pending`, dan `completed` harus dibedakan secara eksplisit.
6. Pekerjaan berikutnya tidak dianggap siap hanya karena pekerjaan sebelumnya secara nominal selesai apabila masih ada prerequisite atau verification gap yang relevan.

---

## 2. Current Work Status

| No. | Workstream | Status | Disposition |
|---|---|---|---|
| 1 | Task RPC dependency | ✅ **COMPLETED** | Broken `r6_tasks` dependency direkonsiliasi ke `task_reminders`. |
| 2 | Migration source reconstruction | ⏸️ **INTENTIONALLY DEFERRED** | Ditunda sebagai keputusan strategi selama SH masih dalam development; tidak membuat migration source fiktif. |
| 3 | Old Conversation contract | ⏸️ **INTENTIONALLY SUPERSEDED** | Contract lama tidak dijadikan baseline baru; akan digantikan oleh Conversation contract baru setelah backend model dan kebutuhan final lebih stabil. |
| 4 | Knowledge FK validation | ✅ **COMPLETED** | FK `knowledge_private_sh_id_fk` sudah divalidasi. |
| 5 | anon EXECUTE hardening | ✅ **COMPLETED** | Runtime privileged surface sudah di-hardening; residual public/anon surface tetap harus dipahami sesuai fungsi masing-masing. |
| 6 | Recovery ↔ Conversation continuity backend | ✅ **COMPLETED** | Recovery snapshot/restore sudah mencakup hierarchy Project → Conversation Thread → Message dan mempertahankan identity/thread continuity. |
| 7 | Contract reconciliation | ✅ **COMPLETED** | Contract yang ada direkonsiliasi terhadap kondisi DEV tanpa mengubah Canonical; drift Project/Conversation dicatat sebagai keputusan kerja, bukan blocker. |
| 8 | Backend fixes | ✅ **COMPLETED** | Backend runtime fixes yang teridentifikasi dari audit sudah diterapkan, termasuk retirement execute surface legacy Conversation RPC. |
| 9 | Verification | 🟡 **PARTIAL / PENDING** | Static/security baseline CLEAR; authenticated adversarial runtime harness masih pending. |
| 10 | Frontend integration | ⏳ **PENDING** | Frontend belum menjadi baseline final; akan mengikuti backend authority/capability contract setelah backend reconciliation cukup stabil. |

---

## 3. Detail Workstream

### 3.1 Task RPC Dependency — COMPLETED

Masalah awal:

- RPC `create_task` dan `list_tasks` masih mereferensikan `public.r6_tasks`.
- `r6_tasks` sudah tidak ada.
- Current table yang digunakan adalah `public.task_reminders`.

Perbaikan:

- `create_task` direkonsiliasi untuk menggunakan `task_reminders`.
- `list_tasks` direkonsiliasi untuk menggunakan `task_reminders`.
- Anonymous execute surface untuk kedua RPC tidak dibuka.

Hasil:

```text
legacy r6_tasks reference → removed
current task_reminders    → authoritative runtime target
```

Catatan: ini menyelesaikan dependency/function-schema break, bukan authenticated end-to-end verification.

---

### 3.2 Migration Source Reconstruction — INTENTIONALLY DEFERRED

Current DEV database dan historical migration lineage sudah diaudit.

Temuan:

- Current `dev` repository belum memiliki source migration/database yang mereproduksi seluruh remote DEV.
- `dev_old` memiliki historical migration lineage.
- Historical evidence menetapkan bahwa migration source reconstruction tidak boleh dilakukan dengan migration fiktif atau replacement yang tidak terverifikasi.

Keputusan kerja saat ini:

> Migration source reconstruction **sengaja ditunda** selama SH masih dalam fase development.

Tidak ada migration source fiktif yang dibuat untuk menutupi gap tersebut.

Status ini adalah **deferred debt / future reconciliation item**, bukan blocker aktif untuk pekerjaan runtime yang sedang berjalan.

---

### 3.3 Old Conversation Contract — INTENTIONALLY SUPERSEDED

Approved Working Contract Conversation yang lama sudah diaudit terhadap current DEV.

Current DEV ternyata sudah memiliki capability yang pada contract lama masih dicatat sebagai gap, termasuk beberapa project/conversation management operation.

Drift tersebut merupakan hasil keputusan kerja selama implementasi dan tidak diperlakukan sebagai blocker.

Keputusan kerja:

- Contract lama tidak diubah secara diam-diam.
- Contract lama tidak dijadikan baseline baru untuk implementation berikutnya.
- Akan dibuat **Conversation contract baru** ketika backend authority/capability model dan kebutuhan Conversation sudah cukup stabil.
- Contract baru akan menyerap capability yang benar-benar disepakati serta kebutuhan tambahan yang muncul.

---

### 3.4 Knowledge FK Validation — COMPLETED

Validation gap pada:

```text
public.knowledge
    ↓
knowledge_private_sh_id_fk
    ↓
public.sh_instances(sh_id)
```

sudah ditutup melalui validation constraint.

Tidak ada perubahan semantic model Knowledge yang dilakukan.

---

### 3.5 anon EXECUTE Hardening — COMPLETED

Audit menemukan privileged runtime functions yang sebelumnya masih memiliki anonymous execute surface.

Hardening dilakukan dengan mencabut anonymous/public execute dari runtime functions yang memerlukan authenticated identity.

Residual anonymous execute surface tidak dicabut secara blind apabila fungsi tersebut merupakan:

- trigger helper;
- SECURITY INVOKER bounded function; atau
- fungsi lain yang perlu dianalisis berdasarkan execution context-nya.

Status:

```text
Broad runtime anon execute surface → hardened
```

Residual review harus tetap dibedakan dari proven security vulnerability.

---

### 3.6 Recovery ↔ Conversation Continuity Backend — COMPLETED

Gap awal:

- Recovery snapshot belum menyimpan `conversation_threads` sebagai first-class recovery object.
- Restore belum secara eksplisit memulihkan thread hierarchy.
- Trigger fallback berpotensi merekonstruksi thread secara tidak identik dengan thread asli.

Perbaikan:

```text
Projects
   ↓
Conversation Threads
   ↓
Messages / Conversations
```

Recovery sekarang mempertahankan informasi hierarchy dan identity yang relevan, termasuk original thread/project/message identity dan boundary SH/account.

Restore dilakukan dalam urutan hierarchy yang eksplisit dan tidak bergantung pada fallback trigger sebagai mekanisme utama restoration.

Catatan:

Authenticated E2E recovery verification masih menunggu APK/frontend siap.

---

### 3.7 Contract Reconciliation — COMPLETED

Contract reconciliation dilakukan terhadap:

- Project / Conversation contract;
- State Persistence contract;
- Canonical Supabase Map;
- migration-source disposition.

Hasil:

1. State Persistence semantic boundary tetap valid.
2. Recovery tetap merupakan recovery container, bukan State representation.
3. Project/Conversation implementation DEV lebih maju daripada capability matrix contract lama.
4. Drift tersebut dicatat sebagai working decision dan tidak digunakan untuk mengubah Canonical.
5. Migration source reconstruction tetap intentionally deferred.

Tidak ada Canonical mutation dalam pekerjaan ini.

---

### 3.8 Backend Fixes — COMPLETED

Runtime backend yang sudah direkonsiliasi mencakup capability Project, Conversation, State, dan Recovery yang relevan dengan current DEV architecture.

Legacy Conversation runtime execute surface yang tidak lagi menjadi target architecture sudah dinonaktifkan dari client execution path tanpa harus menghapus historical function definition secara langsung.

Current principle:

```text
Current runtime contract
        ↓
Current backend RPC
        ↓
Authenticated identity / ownership / authority checks
        ↓
Persistent operation
```

Backend belum dianggap final secara keseluruhan hanya karena workstream ini selesai; verification runtime masih menjadi gate.

---

## 4. Authority / Creator / User Finding

Audit identity dan authority menghasilkan temuan penting.

Current DEV memiliki:

- `sh_ownership.role = OWNER` sebagai ownership relationship;
- `private.authority_assignments` sebagai authority assignment layer;
- authority `CREATOR` untuk satu account tertentu;
- `private.governance_evaluator` yang memilih `CREATOR` jika assignment aktif, dan `ACCOUNT_OWNER` sebagai fallback;
- `permission_matrix` yang memiliki actor taxonomy termasuk `CREATOR`, `ACCOUNT_OWNER`, `SH-000`, `ORDINARY_SH`, dan `SYSTEM_RUNTIME`.

Penting:

```text
OWNER ≠ CREATOR
```

Satu account dapat memiliki ownership relationship `OWNER` sekaligus authority `CREATOR`.

`sh_instances.creator_ref` bukan source of truth authority Creator pada current model yang sudah diaudit.

### 4.1 Current APK Observation

Login menggunakan tiga account DEV menunjukkan bahwa UI/feature surface yang terlihat saat ini masih sama antar-account.

Observation ini **belum** membuktikan bahwa backend authority enforcement gagal.

Observation ini menunjukkan bahwa sebelum frontend integration final dilakukan, backend authority → capability surface harus dipastikan cukup jelas sehingga frontend mempunyai contract yang benar untuk diikuti.

---

## 5. Verification Status

### Static / Security Baseline

Status:

**CLEAR berdasarkan audit static/security yang sudah dilakukan.**

Area yang sudah diperiksa antara lain:

- identity / ownership boundary;
- RLS posture;
- privileged runtime function execute surface;
- FK integrity;
- recovery hierarchy references;
- legacy runtime exposure;
- authority assignment structure;
- permission matrix structure.

### Authenticated Adversarial Verification

Status:

**PENDING.**

Belum ada authenticated runtime harness yang committed sebagai integration test suite di current `dev` repository.

Verification yang masih diperlukan:

```text
Account A
  → own resources      → ALLOW
  → Account B resources → DENY

Creator
  → creator-authorized action → expected result

Account Owner
  → owner-authorized action   → expected result

Unauthorized actor
  → protected action          → DENY
```

Verification ini berbeda dari APK E2E.

---

## 6. Frontend Integration — PENDING

Frontend belum dijadikan authority source.

Target architecture:

```text
Supabase Backend
      ↓
Identity
      ↓
Authority
      ↓
Permission / Capability
      ↓
Runtime enforcement
      ↓
Frontend contract
      ↓
Flutter UI
```

Frontend integration baru dianggap siap setelah backend authority/capability model cukup stabil dan behavior penting sudah diverifikasi.

Frontend tidak boleh membuat mapping baru seperti:

```text
OWNER = CREATOR
```

tanpa contract/backend evidence yang eksplisit.

---

## 7. Current Gate

Posisi kerja saat dokumen ini dibuat:

```text
Backend foundation / reconciliation
            ↓
      mostly completed
            ↓
Authenticated runtime verification
            ↓
   authority/capability validation
            ↓
Conversation contract baru
            ↓
Frontend integration
```

Frontend bukan blocker yang harus langsung dikerjakan hanya karena UI tiga account terlihat sama.

Backend authority/capability reconciliation dan authenticated verification tetap menjadi prerequisite sebelum frontend dijadikan target integration final.

---

## 8. Dokumen Ini Bersifat Sementara

Dokumen ini **bukan daftar langkah final proyek**.

Tujuannya hanya menjaga checkpoint pekerjaan saat ini agar tidak hilang ketika pekerjaan berpindah antara Supabase/backend, verification, contract, dan frontend.

Setelah:

- backend authority/capability model selesai direkonsiliasi;
- authenticated verification selesai;
- Conversation contract baru disepakati;
- frontend integration selesai;
- seluruh dependency dan blocker ditutup;

maka status ini harus direkonsiliasi kembali menjadi **final work sequence** yang dapat berjumlah 9 atau 10 langkah sesuai kondisi aktual saat itu.

---

## 9. Current Summary

```text
1  ✅ Task RPC dependency
2  ⏸️ Migration source reconstruction — intentionally deferred
3  ⏸️ Old Conversation contract — intentionally superseded by future new contract
4  ✅ Knowledge FK validation
5  ✅ anon EXECUTE hardening
6  ✅ Recovery ↔ Conversation continuity backend
7  ✅ Contract reconciliation
8  ✅ Backend fixes
9  🟡 Verification — static/security baseline CLEAR,
       authenticated adversarial runtime verification pending
10 ⏳ Frontend integration
```

**Current working direction:** rapikan dan pastikan Backend / Supabase terlebih dahulu, kemudian Frontend menyesuaikan backend contract dan capability yang sudah authoritative.
