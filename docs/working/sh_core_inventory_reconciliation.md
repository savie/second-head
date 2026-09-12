# SECOND HEAD — SH CORE INVENTORY & RECONCILIATION

**Project:** SECOND HEAD (SH)  
**Status:** Living Working Document — CURRENT CHECKPOINT RECONCILIATED  
**Bahasa:** Indonesia  
**Scope:** Identity, State, Conversation, Attachment, Memory, Knowledge, Experience, Journey, Lifecycle/EOL, Clone, Inheritance, Succession, Recovery, Governance/Runtime, capability/application evidence  
**Authority Level:** Working / Reconciliation — bukan Canonical  
**Database Source of Truth:** Supabase DEV  
**Current Code:** branch `dev`  
**Historical Evidence:** `dev_old`

## 1. Tujuan

Dokumen ini adalah living inventory untuk menjaga satu current-state reference antara `docs/`, current `dev`, Supabase DEV, frontend, backend/runtime, CI, dan device/E2E evidence.

Dokumen ini bukan Canonical, bukan Approved Contract, dan bukan feature wish-list.

## 2. Authority & Reconciliation Rule

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
RUNTIME / DATABASE EVIDENCE
        ↓
DEVICE / E2E EVIDENCE
        ↓
HISTORICAL / dev_old
```

Evidence mendahului claim. `Source exists ≠ runtime works`, `Migration exists ≠ database changed`, `Deployed ≠ verified`, dan `Test pass ≠ whole system correct`.

`dev_old` hanya historical reference. Ia tidak menggantikan current DEV.

## 3. Current Domain Checkpoint

| Domain | Current classification | Verification |
|---|---|---|
| Identity / Actor | CURRENT IMPLEMENTATION | VALIDATED untuk scope yang diuji |
| State | CURRENT BACKEND IMPLEMENTATION | verification mengikuti State contract |
| Project | CURRENT IMPLEMENTATION | current runtime/FE path |
| Conversation / Message | CURRENT IMPLEMENTATION | happy-path/runtime/device verified; adapter audit tetap open |
| Conversation Attachment | CURRENT IMPLEMENTATION | happy-path E2E verified |
| Memory | CURRENT IMPLEMENTATION | tested persistence/projection verified |
| Knowledge | CURRENT IMPLEMENTATION / DOMAIN PRESENT | positive semantic E2E OPEN; 0 rows at checkpoint |
| Experience | CURRENT IMPLEMENTATION / DOMAIN PRESENT | positive semantic E2E OPEN; 0 rows at checkpoint |
| Journey | CURRENT IMPLEMENTATION | persistence/retrieval/FE/account isolation verified |
| Context Resolver | IMPLEMENTED / RECONCILED | runtime/contract verified for current scope |
| Lifecycle / EOL | CURRENT SURFACE / DEPTH VARIES | semantic/E2E open |
| Clone / Inheritance / Succession | CURRENT SURFACE / BACKEND DEPTH VARIES | semantic/security verification open where applicable |
| Recovery | CURRENT BACKEND LINEAGE | full restore E2E open |
| Tools / External | PARTIAL / OPEN | capability-specific verification required |

## 4. Identity / Actor Resolution

Canonical actor semantics tetap:

- `1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH`;
- `Account_ID ≠ SH_ID`;
- Runtime ≠ SH Identity;
- Model ≠ SH Identity;
- Creator Authority ≠ Private Data Access;
- SH-000 Core Authority ≠ Private Data Access;
- Runtime Access ≠ Ownership.

Current DEV memiliki trusted actor/identity resolution dan FE consumer. Current tested Creator/SH-000 dan ordinary account classifications sudah tervalidasi.

**Status:** VALIDATED / CURRENT IMPLEMENTATION.  
`SYSTEM_RUNTIME` technical mechanism tetap OPEN dan tidak disamakan dengan actor resolution.

## 5. State

Current DEV memiliki dedicated `public.sh_states` beserta runtime/recovery lineage. `sh_instances.metadata` bukan State authority.

**Status:** CURRENT BACKEND IMPLEMENTATION; detail semantic/E2E mengikuti contract masing-masing.

## 6. Project / Conversation / Message

Current hierarchy:

```text
Account / SH
    ↓
Project
    ↓
Conversation Thread
    ↓
Message
```

Current runtime/FE paths tersedia untuk Project/Conversation management, Message load/record/update/delete, context loading, search, loading/error/empty states, dan destructive confirmations.

Current runtime path juga sudah terhubung ke dynamic AI runtime pada tested conversation flow.

**Status:** CURRENT IMPLEMENTATION / RUNTIME VERIFIED FOR TESTED PATH.

**OPEN:** adapter update/delete message parameter contract tetap harus diaudit secara eksplisit sebelum ditutup. Jangan menganggap attachment E2E sebagai bukti parameter contract CRUD.

## 7. Conversation Attachment

Attachment adalah Message-owned resource/payload, bukan domain SH lifecycle baru.

Semantics locked:

```text
local file → UX/cache
backend attachment → durable source of truth
attachment_id → stable identity
Message → Attachment[] → Storage Object
```

Current device + DEV evidence membuktikan:

- preview;
- composer/caption;
- send;
- Message persistence;
- Attachment persistence;
- Message ↔ Attachment linkage;
- Storage object;
- finalize → `PERSISTED`;
- SH response;
- navigation persistence;
- account isolation.

**Status:** HAPPY-PATH E2E VERIFIED.

**OPEN RISK:** failure retry/idempotency belum diverifikasi. Retry harus mempertahankan logical `attachment_id` dan tidak membuat duplicate durable attachment. Ini non-blocking hardening, bukan alasan membuka kembali happy path.

## 8. Memory / Knowledge / Experience / Journey

Canonical distinctions:

```text
Memory ≠ Knowledge
Context ≠ Memory
Experience ≠ Conversation
Experience ≠ Journey
```

### Memory

Tested explicit Memory capture telah tersimpan di DEV dan menghasilkan Journey projection. Owner-private scope pada tested path terverifikasi.

**Status:** TESTED PERSISTENCE / PROJECTION VERIFIED; full lifecycle/retrieval semantics belum global-closed.

### Knowledge

Current DEV memiliki `knowledge` domain/source. Tidak ada positive Knowledge row pada current checkpoint.

**Status:** DOMAIN PRESENT / POSITIVE SEMANTIC E2E OPEN.

### Experience

Current DEV memiliki `experiences` domain/source. Tidak ada positive Experience row pada current checkpoint.

**Status:** DOMAIN PRESENT / POSITIVE SEMANTIC E2E OPEN.

### Journey

Journey runtime retrieval dan Context Resolver integration sudah direconcile. `runtime_get_journey_context()` tetap menjadi Journey retrieval boundary.

Current FE memuat backend Journey melalui trusted identity boundary dan local Journey storage sudah account-scoped.

Device verification menunjukkan Account A data tidak muncul di Account B, dan kembali ke A memulihkan data A tanpa B.

**Status:** VERIFIED untuk tested persistence/retrieval/FE/account-isolation path.

## 9. Context Resolver

Current contract dan implementation telah direconcile:

```text
runtime_get_context_package()
        ↓
assemble_context()
        ↓
actor
conversation
state
memory
knowledge
experience
journey
```

Ordering current:

`actor → conversation → state → memory → knowledge → experience → journey`

Domain boundary, ownership/visibility, dan relevance policy tetap berlaku.

**Status:** IMPLEMENTED / RECONCILED / VERIFIED untuk current scope.

Jangan reopen hanya karena dokumen historical masih menyebut PENDING/BLOCKED.

## 10. Recovery / Lifecycle / Transfer Domains

Current DEV memiliki Recovery lineage dan hubungan Conversation hierarchy. Full recovery restore E2E tetap open.

Canonical boundaries tetap:

- `DECOMMISSION ≠ Immediate Permanent Delete`;
- `CLONE_SH ≠ SOURCE_SH`;
- `CREATOR_SH` non-clonable;
- `INHERITANCE ≠ CLONE`;
- `INHERITANCE ≠ Identity Transfer`;
- `EVOLUTION ≠ Ownership Transfer`;
- Evolution / Migration / Recovery ≠ New SH Identity;
- Privacy / Visibility ≠ Transfer Eligibility.

Lifecycle/Clone/Inheritance/Succession tidak ditutup hanya berdasarkan keberadaan screen atau RPC.

## 11. Frontend Inventory

Current Flutter areas include auth, conversation, project/conversation management, journey, lifecycle, more/profile/navigation, and related storage/integration surfaces.

FE surface existence tidak otomatis berarti semantic/backend/security/E2E complete.

Attachment FE path saat ini:

```text
Composer
  ↓
recordUserWithAttachments
  ↓
ConversationService.recordWithAttachments
  ↓
Message
  ↓
Attachment
  ↓
Storage
  ↓
Finalize
  ↓
AI Runtime
```

## 12. Backend / Supabase Evidence Checkpoint

Current DEV database domain counts pada reconciliation checkpoint:

```text
conversations              37
conversation_threads         9
conversation_attachments    5
memories                     1
knowledge                    0
experiences                  0
journey_events               1
```

Counts adalah state evidence, bukan capability proof.

Current attachment storage bucket yang digunakan adalah private `second-head-conversation`.

## 13. Security / Isolation

Current tested security model mempertahankan:

```text
Authentication
 → Identity Resolution
 → Actor Classification
 → Authority Resolution
 → Runtime Context
 → Permission Policy
 → Enforcement
```

Cross-actor conversation negative access sudah teruji pada DB path. Journey account isolation sudah teruji pada device. Attachment happy-path account isolation juga terobservasi melalui account switching.

Remaining security semantic harnesses untuk transfer/succession dan broader domains tetap open sampai execution evidence tersedia.

## 14. Documentation Drift Register

Reconciliation drift yang kini ditutup pada current checkpoint:

| Area | Previous stale state | Current disposition |
|---|---|---|
| Conversation AI/runtime | masih ditulis belum complete | RECONCILED to current tested runtime |
| Attachment FE E2E | masih ditulis deferred | HAPPY-PATH E2E VERIFIED; retry hardening OPEN |
| Memory/Journey | masih ditulis backend integration open | TESTED persistence/retrieval/projection VERIFIED |
| Journey Context Resolver | masih ditulis pending/blocked | IMPLEMENTED / RECONCILED / VERIFIED |
| Knowledge | tidak boleh dinaikkan hanya karena domain exists | OPEN until positive evidence |
| Experience | tidak boleh dinaikkan hanya karena domain exists | OPEN until positive evidence |

Dokumen Canonical tidak diubah oleh reconciliation ini.

## 15. Verification Discipline

Untuk setiap claim berikutnya:

```text
Claim
 ↓
Expected
 ↓
Evidence
 ↓
Actual
 ↓
Result
```

Level verification dipilih sesuai kebutuhan:

`Static → Unit → DB/Function → Integration → Runtime/HTTP → UI/E2E`

`DB PASS ≠ HTTP E2E PASS`.

## 16. Current Open Queue

1. Conversation adapter update/delete message parameter audit.
2. Knowledge positive semantic/runtime verification.
3. Experience positive semantic/runtime verification.
4. Security/succession semantic harness.
5. Recovery restore E2E.
6. Attachment failure/retry/idempotency hardening.
7. Other confirmed gaps discovered through evidence.

**Temuan ≠ perintah.** Item open tidak otomatis menjadi implementation request.

## 17. Current Checkpoint Summary

```text
Identity / Actor Resolution        → VALIDATED / CLOSED FOR TESTED SCOPE
State                              → CURRENT / VERIFY BY CONTRACT
Project / Conversation / Message  → CURRENT / TESTED RUNTIME PASS
Conversation Attachment            → HAPPY-PATH E2E VERIFIED
Memory                             → TESTED PERSISTENCE + JOURNEY PROJECTION VERIFIED
Knowledge                          → OPEN POSITIVE E2E
Experience                         → OPEN POSITIVE E2E
Journey                            → VERIFIED TESTED PATH
Context Resolver                   → IMPLEMENTED / RECONCILED / VERIFIED
Recovery                           → CURRENT BACKEND / E2E OPEN
Security transfer/succession       → SEMANTIC E2E OPEN
Attachment retry/idempotency       → OPEN NON-BLOCKING RISK

Next action: pilih confirmed open dependency; jangan reopen closed domain tanpa new evidence.
```
