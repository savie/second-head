# SECOND HEAD — Audit Bukti Capability Transition

## Status

**CATATAN AUDIT KERJA — PARTIAL PASS / GATE IMPLEMENTASI BELUM DITUTUP**

## Otoritas

Hanya sebagai catatan audit pendukung.

Tidak mengubah Canonical, Approved Contract, schema, migration, implementasi runtime, atau otoritas policy.

## Tujuan

Memverifikasi capability aktual DEV untuk memenuhi `sh_lifecycle_transition_contract_20260913.md`, khususnya:

- retrieval candidate
- capability transition yang callable
- EXECUTE grant
- authentication / ownership guard
- lifecycle guard
- policy guard
- proyeksi Journey
- atomicity
- idempotency / correlation
- provenance
- evidence E2E positif / negatif

## Sumber Evidence

### GitHub DEV

Repository: `savie/second-head`

Branch: `dev`

Runtime entrypoint:

`functions/ai-runtime/semantic_lifecycle.ts`

Current blob SHA yang diinspeksi: `78fccb57fa0f3299b3f8a03c6aa8d421ab1e9a12`

### Supabase DEV

Project: `pkhkgvsrqeupvwoqjwmd`

Inventory dan definition function database aktual diinspeksi langsung dari `pg_proc` / `pg_get_functiondef`.

## Temuan

### 1. Retrieval Candidate

**STATUS: PARTIAL / SPESIFIK DOMAIN**

Path retrieval Memory dan Knowledge tersedia, tetapi tidak ditemukan resolver generic lifecycle-transition khusus.

`runtime_record_memory` dapat mencari record `CANDIDATE` / `ACTIVE` / `UPDATED` yang sudah ada berdasarkan exact content dan melakukan lock pada row yang dipilih. `runtime_record_knowledge_candidate` dapat mencari `CANDIDATE` yang sudah ada berdasarkan exact content dan melakukan lock pada row.

Mekanisme tersebut adalah mekanisme capture/deduplication, bukan API transition eksplisit. Mekanisme tersebut tidak menetapkan kontrak target transition yang stabil berdasarkan record identity + expected current lifecycle + operation key.

### 2. Capability Dedicated CANDIDATE → ACTIVE

**STATUS: TIDAK DITEMUKAN**

Inventory public function DEV aktual tidak memiliki function yang nama atau definition-nya menetapkan transition aktivasi/promosi candidate secara dedicated.

Capture Memory menerima `CANDIDATE` atau `ACTIVE`, tetapi ini adalah otoritas creation/capture, bukan operasi aktivasi generic yang aman.

Capture candidate Knowledge secara eksplisit menulis `CANDIDATE`; tidak ditemukan function aktivasi dedicated.

Capture Experience menulis `ACTIVE` secara langsung; karena itu boundary aktivasi candidate saat ini belum terimplementasi untuk Experience.

### 3. ACTIVE → UPDATE / SUPERSEDE

**STATUS: PARTIAL / MEMORY SAJA**

`runtime_replace_memory` mengimplementasikan flow replacement Memory yang konkret:

1. autentikasi caller
2. resolve current account
3. verifikasi ownership SH aktif
4. resolve tepat satu replacement target current candidate/active
5. insert successor sebagai CANDIDATE
6. set record lama menjadi `UPDATED`
7. set `superseded_by`
8. emit Journey event

Ini membuktikan capability replacement spesifik domain, tetapi bukan generic lifecycle transition contract. Successor tetap `CANDIDATE`.

Tidak ditemukan capability transition update/supersede dedicated yang ekuivalen untuk Knowledge atau Experience.

### 4. Authentication / Ownership

**STATUS: PASS PADA LEVEL FUNCTION GUARD**

Relevant SECURITY DEFINER write functions secara eksplisit membutuhkan `auth.uid()` dan memvalidasi bahwa SH yang diminta dimiliki oleh `public.current_account_id()` dan tidak deactivated.

Function yang teramati mencakup:

- `runtime_record_memory`
- `runtime_record_memory_with_journey`
- `runtime_record_knowledge_candidate`
- `runtime_record_knowledge_with_journey`
- `runtime_record_experience`
- `runtime_replace_memory`

Ini hanya evidence level function. Authenticated negative test dan cross-actor E2E masih OPEN.

### 5. EXECUTE Grants

**STATUS: PASS UNTUK PUBLIC RUNTIME FUNCTION YANG SUDAH ADA; SECURITY REVIEW OPEN UNTUK TRANSITION API DI MASA DEPAN**

Yang teramati:

- `anon_execute = false`
- `authenticated_execute = true`

untuk runtime capture/replacement function yang disebut di atas.

`runtime_record_journey_event` adalah SECURITY INVOKER dan juga memiliki authenticated EXECUTE sementara anon EXECUTE false.

Karena belum ada transition function baru, belum ada grant khusus transition yang dapat ditetapkan atau direview.

### 6. Lifecycle Guards

**STATUS: PARTIAL**

Capture Memory hanya memvalidasi nilai input `CANDIDATE` / `ACTIVE`.

Capture candidate Knowledge hanya menulis `CANDIDATE`.

Replacement Memory hanya me-resolve source `CANDIDATE` / `ACTIVE` yang belum superseded dan menulis record lama sebagai `UPDATED`.

Tidak ada guard generic untuk:

`record_id + expected_current_lifecycle + requested_transition`

sehingga legalitas transition belum ditegakkan secara terpusat.

### 7. Policy Guards

**STATUS: PARTIAL**

Function yang ada memvalidasi scope dan visibility; Experience juga memvalidasi transfer policy. Function lifecycle-transfer yang ada menyediakan enforcement policy yang lebih kuat dan spesifik terhadap transfer.

Namun function aktivasi candidate yang berasal dari model, dengan policy/confirmation authority eksplisit, belum ada. Karena itu policy guard saat ini belum cukup untuk mengotorisasi aktivasi lifecycle yang berasal dari model.

### 8. Proyeksi Journey

**STATUS: ADA / PARTIAL**

`runtime_record_journey_event` memverifikasi ownership SH aktif dan memvalidasi continuity/event type sebelum memasukkan Journey event.

`runtime_replace_memory` memanggil pencatatan Journey setelah mutation domain.

`semantic_lifecycle.ts` saat ini juga melakukan persistence domain eksplisit lalu memanggil Journey RPC secara terpisah untuk beberapa path.

Karena itu proyeksi Journey tersedia, tetapi transaction boundary atomic antara domain + Journey **BELUM TERBUKTI** pada seluruh path semantic runtime.

### 9. Idempotency / Correlation

**STATUS: OPEN / EVIDENCE GAP**

Tidak ditemukan logical operation key level request pada signature runtime function yang diinspeksi.

Content matching / reuse candidate tidak sama dengan request-level idempotency yang aman terhadap retry.

Karena itu requirement transition contract untuk stable operation identity masih belum terpenuhi.

### 10. Provenance

**STATUS: PARTIAL**

Path Memory dan Knowledge menerima provenance; Experience menerima provenance; replacement saat ini membuat Memory baru tanpa dedicated transition-operation provenance structure.

Runtime saat ini mengirim `source_message` / `capture_mode` untuk semantic path eksplisit.

Yang masih belum terbukti adalah rantai provenance transition lengkap yang berisi actor/account, SH, source signal, model/provider, decision, confirmation/authorization, transition, resulting record, dan Journey event di bawah satu stable correlation identity.

### 11. Boundary Otoritas Model

**STATUS: PASS / RECONCILED**

Semantic runtime yang diinspeksi saat ini secara eksplisit berbasis pattern detection pada user message untuk path lifecycle eksplisit yang sudah ada. Implementasi tersebut tidak menetapkan output model sebagai otoritas persistence independen.

Ini tidak membuktikan pipeline model-derived di masa depan aman; pipeline tersebut masih berada di luar capability yang terverifikasi saat ini.

### 12. Security Surface

**STATUS: REVIEW DIPERLUKAN SEBELUM TRANSITION API BARU**

Runtime write function yang ada menggunakan SECURITY DEFINER di `public`, tetapi secara eksplisit menolak anonymous execution dan melakukan authentication/ownership checks.

Karena SECURITY DEFINER melewati execution context RLS normal, transition function masa depan harus mendapat security review eksplisit terhadap function body, search_path, grants, ownership checks, lifecycle/policy checks, dan perilaku cross-actor sebelum diekspos.

## Matriks Capability

| Capability | Evidence DEV | Status |
|---|---|---|
| Pembuatan candidate | Memory + Knowledge | PASS |
| Retrieval candidate berdasarkan content | Memory + Knowledge | PARTIAL |
| Generic Candidate → Active | Tidak ditemukan | OPEN |
| Memory replacement | `runtime_replace_memory` | PASS / spesifik domain |
| Knowledge update/supersede | Tidak ditemukan | OPEN |
| Experience candidate workflow | Tidak ditemukan | OPEN |
| Auth guard | Runtime function yang ada | PASS |
| Ownership guard | Runtime function yang ada | PASS |
| EXECUTE grant | authenticated saja | PASS |
| Policy guard | spesifik domain | PARTIAL |
| Proyeksi Journey | Existing | PASS / atomicity open |
| Atomic domain + Journey | Tidak terbukti | OPEN |
| Request idempotency | Tidak ditemukan | OPEN |
| Rantai provenance lengkap | Partial | OPEN |
| Authenticated positive E2E | Evidence historis untuk capture | PARTIAL |
| Authenticated negative/cross-actor E2E | Belum selesai untuk transition | OPEN |
| Transfer E2E | Capability ada, bukan proof transition | PARTIAL |

## Temuan Kritis

Gate implementasi harus tetap **CLOSED**.

Saat ini tidak ada capability CANDIDATE → ACTIVE yang aman, eksplisit, dan generic yang dapat dipanggil oleh semantic decision yang berasal dari model sambil memenuhi requirement transition contract untuk authorization, confirmation, lifecycle legality, idempotency, provenance, dan konsistensi Journey.

Sistem yang ada memiliki reusable domain capability, tetapi menggunakan ulang capture function sebagai aktivasi akan mencampur:

- otoritas capture
- otoritas transition
- mutation state lifecycle
- model decision
- semantics retry

Hal tersebut akan melanggar design gate saat ini.

## Keputusan

**REUSE EXISTING CAPABILITY:** hanya untuk perilaku domain yang sudah terimplementasi dan semantiknya cocok, misalnya Memory replacement.

**EXTEND EXISTING CAPABILITY:** masuk akal untuk Memory/Knowledge, tetapi hanya setelah authorization transition, idempotency, provenance, dan transaction boundary dirancang dan memiliki evidence.

**CREATE NEW CAPABILITY:** diperlukan jika tidak ada function domain yang ada yang dapat mengekspresikan lifecycle transition terotorisasi dengan aman tanpa membebani semantik capture.

Tidak ada implementasi yang diotorisasi oleh audit ini.

## Gate Berikutnya

**Lifecycle Transition Runtime Design Review**

Sebelum coding migration/runtime, definisikan surface API transition domain-specific yang paling kecil dan selesaikan:

1. confirmation authority
2. retrieval candidate berdasarkan stable record ID
3. expected-current-lifecycle check
4. sumber transition authorization
5. operation/correlation key
6. kontrak provenance
7. transaction boundary domain + Journey
8. path aktivasi Knowledge
9. path aktivasi Memory
10. model lifecycle Experience
11. rencana authenticated positive E2E
12. rencana authenticated negative/cross-actor E2E
13. security review untuk exposure SECURITY DEFINER

## State Akhir

`POLICY CONTRACT = RECONCILED`

`RUNTIME CAPABILITY = PARTIAL`

`TRANSITION CONTRACT = DEFINED`

`TRANSITION EVIDENCE AUDIT = PARTIAL PASS`

`IMPLEMENTATION GATE = CLOSED`
