# SECOND HEAD — SH CORE INVENTORY & RECONCILIATION

**Project:** SECOND HEAD (SH)  
**Status:** Living Working Document — Active Reconciliation  
**Bahasa:** Indonesia  
**Scope:** Identity, State, Conversation, Memory, Knowledge, Experience, Journey, Lifecycle/EOL, Clone, Inheritance, Succession, Recovery, Governance/Runtime, serta capability/application evidence yang relevan  
**Authority Level:** Working / Reconciliation — bukan Canonical  
**Database Source of Truth:** Supabase DEV  
**Current Code:** branch `dev`  
**Historical Evidence:** `dev_old`

---

## 1. Tujuan

Dokumen ini adalah living inventory untuk merekonsiliasi evidence dokumentasi `docs/`, Supabase DEV, backend, dan frontend Flutter/Dart aktual di `app/` sebelum menarik kesimpulan atau masuk implementation berikutnya.

Dokumen ini **bukan Canonical, bukan Approved Contract, dan bukan feature wish-list**.

Tujuan utama:

1. menetapkan source authority yang benar;
2. mencatat kondisi aktual Supabase DEV dan current `dev`;
3. membedakan current implementation dari historical evidence;
4. menemukan documentation/contract drift;
5. mengklasifikasikan VALIDATED / CURRENT IMPLEMENTATION / LEGACY / GAP / OPEN / DEFERRED;
6. menjaga dependency dan execution gate.

**Tidak ada coding pada inventory/reconciliation kecuali user memberikan instruksi implementation setelah confirmed gap dan prerequisite dinyatakan.**

---

## 2. Evidence & Authority

### 2.1 Authority hierarchy

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

Jika sumber berbeda: identifikasi konflik, jangan menggabungkan diam-diam, prioritaskan authority lebih tinggi, dan catat implementation sebagai state bila belum sesuai authority.

### 2.2 Current evidence set

Current documentation yang relevan mencakup:

```text
docs/canonical/
docs/technology/
docs/architecture/
docs/contract/
docs/working/
```

Current implementation evidence mencakup `app/` Flutter/Dart, backend/runtime path, Supabase DEV schema/functions/RLS, migration artifacts, serta CI/build evidence.

`dev_old` hanya historical evidence untuk lineage, capability intent, historical implementation, bug/lesson, dan asal semantics. Ia tidak menggantikan current DEV.

### 2.3 Reconciliation method

```text
authority
  ↓
current docs / approved contract
  ↓
architecture + technology boundary
  ↓
Supabase DEV
  ↓
backend DEV
  ↓
frontend DEV
  ↓
dev_old evidence
  ↓
semantic + dependency reconciliation
  ↓
classification
  ↓
verification requirement
```

Analisis BE dan FE dilakukan **paralel** pada inventory. Execution implementation tetap **BE-first**.

---

## 3. Classification

| Label | Makna |
|---|---|
| **CANONICAL / VALIDATED** | Didukung authority Canonical/current authoritative addendum. |
| **APPROVED CONTRACT** | Contract yang disetujui dan berlaku untuk scope-nya. |
| **CURRENT IMPLEMENTATION** | Terbukti ada pada current DEV repository/backend/frontend. |
| **DERIVED / RECONSTRUCTED** | Hasil reconciliation/evidence, bukan authority baru. |
| **LEGACY RESIDUE** | Historical/compatibility implementation. |
| **BE-ONLY** | Authority/capability berada di backend/database/runtime. |
| **FE-ONLY** | Presentation/navigation/interaction/local UI/device concern. |
| **BE ↔ FE** | Membutuhkan backend dan frontend consumer/representation. |
| **GAP** | Kekurangan terbukti terhadap authority/contract/dependency. |
| **OPEN / UNRESOLVED** | Evidence/decision belum cukup. |
| **DEFERRED** | Sengaja belum dikerjakan/ditetapkan dan bukan otomatis blocker. |
| **PROPOSED / INTERPRETATION** | Usulan baru, bukan keputusan. |

Keberadaan tabel, RPC, screen, atau folder **tidak otomatis berarti capability selesai**.

---

# 4. CURRENT RECONCILIATION CHECKPOINT

## 4.1 Identity / Actor Resolution

Canonical actor semantics tetap berlaku:

- `1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH`;
- `Account_ID ≠ SH_ID`;
- Runtime ≠ SH Identity;
- Model ≠ SH Identity;
- Creator Authority ≠ Private Data Access;
- SH-000 Core Authority ≠ Private Data Access;
- Runtime Access ≠ Ownership;
- System Governance ≠ Omniscient Data Access.

Actor Resolution Addendum adalah authority current untuk actor/authority scope.

Current DEV memiliki `resolve_actor_context()` dan FE `ResolvedActorContext` integration. Classification Creator / SH-000 dan Account Owner / ORDINARY_SH telah diverifikasi untuk scope current yang diuji.

**Status:** VALIDATED / CURRENT IMPLEMENTATION.  
**Open:** technical mechanism untuk `SYSTEM_RUNTIME` masih OPEN; jangan disamakan dengan actor resolution.

## 4.2 Migration / Supabase reconstruction

Migration source reconstruction telah selesai. Current DEV migration history berada pada **173 entries**, dengan migration terbaru pada checkpoint ini:

`20260908032300_actor_resolution_context`

Jangan membuat migration historis baru, rename timestamp lama, mengubah isi migration historis, atau menggunakan `dev_old` sebagai source current.

## 4.3 State

Approved State direction tetap menggunakan dedicated `public.sh_states`, explicit version/revision, authorized runtime path, optimistic concurrency, serta recovery/migration semantics. `sh_instances.metadata` bukan State authority.

Current DEV memiliki `sh_states` beserta lineage runtime/recovery.

**Status:** CURRENT BACKEND IMPLEMENTATION; semantic/E2E verification tetap mengikuti contract dan verification layer yang relevan.

## 4.4 Project / Conversation / Message

Hierarchy current:

```text
Account / SH
    ↓
Project
    ↓
Conversation Thread
    ↓
Conversation / Message persistence
```

Current backend/runtime path dan Flutter consumer sudah ada untuk:

- list/create/rename/delete Project;
- create/list/select/rename/delete Conversation;
- move/remove Conversation dari Project;
- load/record/update/delete Message;
- load Conversation Context.

Current `ConversationService` memanggil runtime capability tersebut dan `ProjectConversationManagementView` menyediakan management surface.

Contract lama yang capability matrix-nya menyatakan sebagian operation masih gap telah direvisi/reconciled. Contract current sekarang menjadi reference untuk semantics, sedangkan implementation evidence dibaca dari current DEV.

**Status:** CURRENT IMPLEMENTATION / PARTIAL SEMANTIC CLOSURE.

Catatan confirmed audit target: bridge update/delete message perlu tetap diaudit terhadap parameter contract karena terdapat indikasi adapter mismatch (`messageId` vs `conversationId`). Jangan coding sebelum gap ini dikonfirmasi.

## 4.5 Memory / Knowledge / Experience / Journey

Canonical distinctions tetap berlaku:

```text
Memory ≠ Knowledge
Context ≠ Memory
Experience ≠ Conversation
Experience ≠ Journey
```

Current FE memiliki Journey surface dan interaction untuk Memory / Knowledge / Experience. Evidence source yang diperiksa menunjukkan sebagian semantics masih local/in-memory melalui `JourneyStore` dan belum dapat dianggap sebagai authorized backend integration hanya karena UI tersedia.

**Status:** FE SURFACE EXISTS; backend/semantic integration OPEN.

## 4.6 Lifecycle / EOL / Clone / Inheritance / Legacy / Recovery / Succession

Current FE memiliki surface untuk Lifecycle, EOL, Clone, Inheritance, Legacy, Recovery, dan Succession. Kedalaman implementation berbeda antar-domain.

Canonical boundaries tetap:

- `DECOMMISSION ≠ Immediate Permanent Delete`;
- `CLONE_SH ≠ SOURCE_SH`;
- `CREATOR_SH` non-clonable;
- `INHERITANCE ≠ CLONE`;
- `INHERITANCE ≠ Identity Transfer`;
- `EVOLUTION ≠ Ownership Transfer`;
- Evolution / Migration / Recovery ≠ New SH Identity;
- Privacy / Visibility ≠ Transfer Eligibility.

**Status:** FE SURFACE / BACKEND DEPTH VARIES; semantic + E2E reconciliation OPEN.

## 4.7 Recovery / Continuity

Current DEV memiliki recovery lineage dan integrasi conversation hierarchy. Recovery tidak boleh dianggap sebagai pembuatan identity baru.

**Status:** CURRENT BACKEND LINEAGE; full cross-domain verification remains OPEN.

## 4.8 Tools / Actions / External Integration

Architecture/technology boundaries tetap mendefinisikan capability, adapter/connector, MCP, native/platform, provider, dan external service boundaries.

Current app memiliki representative integration surfaces dan capability scaffolding, tetapi keberadaan integration code/UI tidak membuktikan generic Tool/Action bridge complete.

**Status:** PARTIAL / OPEN.

---

# 5. CURRENT FRONTEND INVENTORY

Current application adalah Flutter/Dart. Feature areas yang terbukti ada antara lain:

```text
auth/
chat/
conversation/
home/
journey/
lifecycle/
more/
profile/
project_conversation/
```

### Identity / Auth

`ShIdentity`, `ResolvedActorContext`, auth lifecycle, backend auth boundary, dan profile/account representation sudah terintegrasi untuk scope Actor Resolution yang diverifikasi.

### Conversation

Current surface bukan placeholder: conversation service/runtime bridge/view, project/conversation management, message operations, local persistence/fallback, search dan interaction tersedia.

Namun `_send()` masih memiliki static assistant response; dynamic AI/runtime response belum menjadi complete path.

**Status:** CURRENT IMPLEMENTATION / PARTIAL.

### Journey

Surface exists untuk Memory / Knowledge / Experience / Journey, tetapi backend semantic integration belum closed.

### Lifecycle / EOL / Clone / Inheritance / Legacy / Recovery / Succession

Surface exists dengan implementation depth yang berbeda. Route/view existence bukan bukti execution completeness.

### Local / Offline

Conversation memiliki bounded local persistence, connectivity state, dan fallback/local state. Belum terbukti full queued mutation, sync, conflict policy, authoritative reconciliation, offline auth semantics, atau complete corruption/recovery model.

**Status:** PARTIAL CURRENT IMPLEMENTATION.

### Multimodal / File / Camera

FE memiliki picker/camera/gallery/file/preview/local attachment interaction. Belum terbukti complete metadata → upload → processing → cancellation → retry → failure → permission → offline lifecycle.

**Status:** FE IMPLEMENTED / RUNTIME LIFECYCLE OPEN.

---

# 6. BACKEND ↔ FRONTEND RECONCILIATION MATRIX

| Domain | Backend / Supabase | Frontend DEV | Relationship | Status |
|---|---|---|---|---|
| Identity / Actor | Resolver + trusted auth boundary | ResolvedActorContext consumer | BE ↔ FE | VALIDATED / CURRENT |
| State | `sh_states` + runtime/recovery lineage | Current state/storage surfaces | BE ↔ FE | CURRENT / VERIFY |
| Project | Runtime CRUD RPCs | Management UI + service | BE ↔ FE | CURRENT |
| Conversation | Runtime CRUD/load/context/message RPCs | ConversationService + views | BE ↔ FE | CURRENT / SEMANTIC VERIFY |
| Message | Load/record/update/delete runtime paths | Conversation UI/service | BE ↔ FE | CURRENT / ADAPTER AUDIT |
| Memory | DEV table/runtime lineage | Journey surface | BE ↔ FE | OPEN |
| Knowledge | DEV table/runtime lineage | Journey surface | BE ↔ FE | OPEN |
| Experience | DEV table/runtime lineage | Journey surface | BE ↔ FE | OPEN |
| Journey | `journey_events` | Journey UI/store | BE ↔ FE | OPEN |
| Lifecycle / EOL | Backend lineage exists | Current lifecycle/EOL surfaces | BE ↔ FE | OPEN |
| Clone | DEV schema/runtime lineage | Current surface | BE ↔ FE | OPEN |
| Inheritance | DEV schema/runtime lineage | Current surface | BE ↔ FE | OPEN |
| Succession | DEV schema/runtime lineage | Current surface | BE ↔ FE | SECURITY/SEMANTIC OPEN |
| Recovery | Recovery events/integration | Current recovery surface | BE ↔ FE | OPEN |
| Governance / Runtime | Boundary functions + runtime RPCs | Runtime-dependent consumers | BE ↔ FE | SECURITY VERIFICATION IN PROGRESS |
| Tools / External | Google/task/external lineage | Representative UI/integration | BE ↔ FE | PARTIAL / OPEN |

---

# 7. DOCUMENT DRIFT REGISTER — UPDATED

Reconciliation document drift yang **sudah diperbaiki pada checkpoint ini**:

| Document | Drift | Disposition |
|---|---|---|
| `docs/contract/sh_project_conversation_message_contract.md` | Capability matrix tidak lagi mencerminkan current Project/Conversation implementation | **REVISED / RECONCILED** |
| `docs/contract/sh_backend_frontend_reconciliation_status.md` | FE integration masih berstatus `PENDING` walau current integration sudah ada | **REVISED / RECONCILED** |
| `docs/canonical/sh_supabase_map.md` | Map belum mencerminkan Project/Conversation/SH State dan migration reconstruction current | **REFERENCE MAP REVISED; SEMANTIC CANONICAL UNCHANGED** |

Dokumen di atas **tidak lagi diperlakukan sebagai stale pada poin-poin tersebut**.

Masih perlu audit/reconciliation berikutnya bila current source menunjukkan drift baru. Jangan menganggap dokumen lain stale hanya berdasarkan umur; gunakan pola current source → evidence → classify → revise only what is justified.

---

# 8. SECURITY HARNESS / BACKEND GATE

Security harness Step 7 **belum PASS final**.

Yang sudah diverifikasi pada checkpoint sebelumnya:

- runtime boundary SELF / OTHER / SPOOF / UNAUTH;
- authenticated runtime surface inventory;
- anon execute surface hardening;
- unchecked primitive isolation;
- sebagian besar public runtime functions menggunakan trusted identity boundary.

Confirmed open target:

```text
runtime_validate_selected_transfer_scope()
        ↓
succession_rules semantics
        ↓
runtime_execute_succession()
        ↓
wrapper / trusted identity / ownership boundary
        ↓
GAP atau NO-CODE-GAP determination
```

`runtime_execute_succession(uuid)` masih merupakan wrapper yang harus diaudit karena authenticated EXECUTE tersedia sementara penggunaan resolver trusted identity tidak terlihat langsung pada wrapper.

Jangan menyatakan Step 7 PASS sebelum target di atas selesai diverifikasi.

---

# 9. CURRENT EXECUTION GATES

Urutan kerja yang berlaku:

```text
Current source inventory
        ↓
Evidence
        ↓
Classify
        ↓
Revise only justified docs
        ↓
Verify SHA/content
        ↓
BE security / semantic verification
        ↓
Confirmed gap inventory
        ↓
Implementation (BE-first)
        ↓
Backend verification
        ↓
Contract verification
        ↓
FE user-visible representation
        ↓
Security harness
        ↓
APK E2E / regression
        ↓
Clone integration
```

### Hard gates

1. Canonical tidak diubah tanpa instruksi eksplisit user.
2. Historical `dev_old` tidak menjadi current source.
3. Current UI tidak otomatis menjadi semantic authority.
4. Tidak coding sebelum gap confirmed dan prerequisite jelas.
5. Backend verification mendahului FE semantic completion ketika capability membutuhkan backend authority.
6. Security failure/blocker menghentikan klaim completion domain terkait.
7. `SYSTEM_RUNTIME` tetap open sampai technical mechanism diputuskan dan diverifikasi.

---

# 10. NEXT RECONCILIATION TARGET

Setelah documentation drift pass ini, next target bukan mengulang dokumen yang sudah direvisi.

Prioritas berikut:

```text
1. Security Harness Step 7 — succession wrapper / validation boundary
2. Conversation adapter audit — update/delete message parameter contract
3. Memory / Knowledge / Experience / Journey semantic BE ↔ FE reconciliation
4. Lifecycle / EOL backend ↔ FE semantic reconciliation
5. Clone / Inheritance / Recovery / Succession reconciliation
6. Confirmed-gap implementation only
7. APK E2E after backend + contract gates
```

**Current checkpoint conclusion:** documentation drift yang terbukti pada tiga dokumen di atas sudah direkonsiliasi. Living inventory sekarang harus dipakai sebagai index kerja terbaru, tetapi **belum menjadi declaration bahwa seluruh SH Core/domain implementation selesai**.