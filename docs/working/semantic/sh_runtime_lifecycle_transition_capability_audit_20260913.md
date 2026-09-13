# SECOND HEAD — Runtime Lifecycle Transition Capability Audit

## Status
WORKING AUDIT RECORD — PARTIAL PASS / IMPLEMENTATION GATE NOT CLOSED

## Authority
Dokumen pendukung untuk working process saja.

Audit ini tidak mengubah Canonical, Approved Contract, database schema, perilaku runtime, atau semantic lifecycle.

## Scope
Audit capability aktual pada DEV Runtime + Supabase DEV untuk:

- Memory
- Knowledge
- Experience
- CANDIDATE → ACTIVE
- ACTIVE → UPDATE
- ACTIVE → SUPERSEDE
- Journey projection
- identity/ownership/policy guards
- transaction/idempotency/failure behavior

## Evidence Baseline

### GitHub
Repository: `savie/second-head`
Branch: `dev`

Runtime entrypoint yang diamati:
- `functions/ai-runtime/semantic_lifecycle.ts`

Semantic runtime explicit saat ini memanggil:
- `runtime_replace_memory`
- `runtime_record_knowledge_with_journey`
- `runtime_record_experience`
- `runtime_record_memory_with_journey`
- `runtime_record_journey_event`

### Supabase DEV
Project: `pkhkgvsrqeupvwoqjwmd`

Inventory public function saat ini mencakup:
- `runtime_record_memory`
- `runtime_record_memory_with_journey`
- `runtime_record_knowledge_candidate`
- `runtime_record_knowledge_with_journey`
- `runtime_record_experience`
- `runtime_replace_memory`
- `runtime_record_journey_event`
- `runtime_transfer_selected_journey_events`

## Findings

### 1. Memory capture
STATUS: EXISTING / VERIFIED AT CAPABILITY LEVEL

`runtime_record_memory` dan `runtime_record_memory_with_journey` hanya menerima nilai lifecycle `CANDIDATE` atau `ACTIVE`. Keduanya mengautentikasi caller dan memverifikasi bahwa SH yang diminta dimiliki active account saat ini. Wrapper Journey menyimpan event MEMORY setelah persistence domain.

Batas penting: belum ditemukan function lifecycle transition khusus yang terotorisasi oleh model/user untuk mempromosikan Memory yang sudah ada dari CANDIDATE menjadi ACTIVE. Jadi capability capture ada, tetapi capability activation belum terbentuk.

### 2. Knowledge capture
STATUS: EXISTING / VERIFIED AT CAPABILITY LEVEL

`runtime_record_knowledge_candidate` secara eksplisit membuat atau menggunakan kembali record Knowledge berstatus CANDIDATE. `runtime_record_knowledge_with_journey` juga menyimpan/menggunakan kembali Knowledge CANDIDATE dan menghasilkan event LEARNING pada Journey.

Belum ditemukan function DEV khusus untuk CANDIDATE → ACTIVE, ACTIVE → UPDATE, atau ACTIVE → SUPERSEDE pada Knowledge.

Jadi persistence candidate Knowledge tersedia; otoritas lifecycle transition masih OPEN.

### 3. Experience capture
STATUS: EXISTING / VERIFIED AT CAPABILITY LEVEL

`runtime_record_experience` membutuhkan authentication, memverifikasi ownership SH aktif terhadap account saat ini, memvalidasi scope/visibility/transfer policy, dan selalu melakukan insert dengan lifecycle `ACTIVE`.

Artinya Experience saat ini belum memiliki boundary capture candidate pada function runtime ini. Semantiknya tidak boleh disamakan dengan model candidate Memory/Knowledge.

Belum ditemukan function DEV khusus untuk Experience UPDATE/SUPERSEDE.

### 4. Memory replacement / supersession
STATUS: EXISTING / PARTIALLY VERIFIED

`runtime_replace_memory` melakukan operasi replacement konkret:

1. mengautentikasi dan memeriksa ownership SH;
2. mencari tepat satu target CANDIDATE/ACTIVE yang belum superseded;
3. membuat Memory baru sebagai CANDIDATE;
4. mengubah Memory lama menjadi `UPDATED` dan menetapkan `superseded_by` ke record baru;
5. membuat event MEMORY Journey yang memuat hubungan replacement.

Ini membuktikan ada operasi domain-specific ACTIVE/CANDIDATE → UPDATED + superseded_by untuk Memory.

Namun ini TIDAK membuktikan adanya generic `ACTIVE → SUPERSEDE` transition API dan tidak membuktikan candidate baru kemudian diaktifkan.

### 5. Journey projection boundary
STATUS: EXISTING / VERIFIED AT CAPABILITY LEVEL

`runtime_record_journey_event` memverifikasi bahwa SH dimiliki active account saat ini dan melakukan normalisasi/validasi event type serta continuity status sebelum insert event.

Semantic lifecycle runtime secara terpisah memanggil Journey pada beberapa path. Knowledge menggunakan DB function yang sekaligus menghasilkan Journey, sementara path Memory dan Experience juga memiliki coupling dengan Journey. Ini belum menjadi evidence yang cukup bahwa setiap persistence domain + Journey projection selalu atomic sebagai satu transaction pada seluruh path runtime.

### 6. Identity and authorization
STATUS: PASS AT FUNCTION GUARD LEVEL / E2E NEGATIVE TEST OPEN

Function DB yang diamati secara konsisten membutuhkan `auth.uid()` dan memverifikasi ownership SH melalui `current_account_id()` untuk domain write. Function transfer juga membutuhkan authorization/agreement/rule state sesuai lifecycle.

Namun authenticated negative security harness lengkap yang mencakup cross-actor SH ID dan seluruh transition function belum dijalankan dalam audit ini.

### 7. Security-definer exposure
STATUS: RISK REVIEW REQUIRED / NOT AN AUTOMATIC FAILURE

Beberapa runtime write function menggunakan `SECURITY DEFINER` di `public`. Body function memiliki authentication dan ownership check eksplisit, yang merupakan evidence positif. Supabase security guidance membutuhkan perhatian khusus karena SECURITY DEFINER melewati RLS.

Audit ini tidak mengubah grant atau penempatan function. Security review terpisah harus memverifikasi EXECUTE grant dan exposure function tersebut sebelum model-derived persistence diaktifkan.

### 8. Idempotency
STATUS: OPEN

Memory dan Knowledge capture melakukan lookup/reuse berbasis content, yang memberi deduplication terbatas. Ini tidak sama dengan request-level idempotency yang menggunakan semantic decision/request/correlation ID.

Tidak ditemukan decision_id/correlation_id/idempotency key pada signature function yang diaudit.

### 9. Model-derived persistence
STATUS: OPEN / NOT VERIFIED

File semantic lifecycle runtime saat ini mengimplementasikan persistence explicit-user-request. Model path yang telah diaudit sebelumnya masih berhenti pada semantic decision evaluation tanpa bukti persistence durable yang berasal dari model.

Karena itu jalur lengkap:

`MODEL OUTPUT → semantic signal → decision → persistence → Journey`

masih belum terverifikasi.

## Capability Matrix

| Domain | Capture | Candidate | Candidate→Active | Active→Update | Active→Supersede | Journey | Idempotency | E2E |
|---|---|---|---|---|---|---|---|---|
| Memory | PASS | PASS | OPEN | DOMAIN-SPECIFIC | DOMAIN-SPECIFIC | PASS* | OPEN | PARTIAL |
| Knowledge | PASS | PASS | OPEN | OPEN | OPEN | PASS* | OPEN | PARTIAL |
| Experience | PASS | NOT ESTABLISHED | NOT APPLICABLE/OPEN | OPEN | OPEN | PASS* | OPEN | PARTIAL |

`*` Evidence level capability tersedia; bukti transaction/E2E lengkap masih OPEN.

## Gate Decision

RESULT: **PARTIAL PASS — IMPLEMENTATION GATE REMAINS CLOSED**

Sistem DEV saat ini memiliki domain capture nyata dan sebagian lifecycle behavior spesifik domain, tetapi belum mengekspos capability lifecycle-transition yang sudah direkonsiliasi dan terverifikasi untuk kebutuhan model-derived semantic persistence.

## Blockers Before Implementation

1. Definisikan dan verifikasi confirmation/activation authority untuk model-derived signal.
2. Sediakan atau secara eksplisit tolak capability CANDIDATE → ACTIVE khusus per domain.
3. Definisikan semantics UPDATE/SUPERSEDE Knowledge dan Experience.
4. Definisikan semantics idempotency request/decision/correlation.
5. Verifikasi atomicity persistence domain + Journey projection.
6. Jalankan authenticated positive dan negative E2E, termasuk cross-actor isolation.
7. Review grant/exposure function SECURITY DEFINER sebelum menambah write path yang dikendalikan model.

## Next Safe Gate

**Lifecycle Transition Contract & Runtime Capability Design**

Sebelum coding, rekonsiliasikan semantics transition yang diinginkan dengan perilaku spesifik domain yang sudah ada. Gate implementasi berikutnya harus menentukan transition function secara tepat, sumber authorization/confirmation, idempotency key, provenance, transaction boundary, failure semantics, dan kasus verifikasi untuk Memory, Knowledge, dan Experience.

## Change Record

Tidak ada runtime code, migration, schema, Canonical document, atau Approved Contract yang diubah oleh audit ini.
