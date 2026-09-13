# SECOND HEAD — Knowledge Lifecycle Security, Confirmation & Operation Ledger Design — 2026-09-13

## Status

**WORKING DESIGN — DEPENDENCY GATE RECONCILED — IMPLEMENTATION STILL CLOSED**

Dokumen ini mencatat keputusan desain lanjutan setelah inspeksi actual Supabase DEV dan rekonsiliasi kontrak Knowledge lifecycle. Dokumen ini tidak mengubah Canonical dan tidak mengotorisasi mutation database.

## 1. Authority

Lifecycle yang dipilih tetap staged:

```text
CANDIDATE → ACCEPTED → INDEXED → ACTIVE → UPDATED / DEPRECATED → ARCHIVED
```

`VALIDATION` adalah process boundary, bukan lifecycle enum.

Target RPC tetap:

```text
runtime_accept_knowledge
runtime_index_knowledge
runtime_activate_knowledge
runtime_update_knowledge
runtime_deprecate_knowledge
runtime_archive_knowledge
```

Existing recovery confirmation tetap khusus `RECOVERY_RESTORE` dan tidak dipakai sebagai Knowledge authority.

## 2. Security Decision

Lifecycle mutation harus memiliki domain-specific RPC boundary. Caller tidak dipercaya untuk menentukan:

- account;
- actor;
- ownership;
- active SH;
- current lifecycle;
- legal transition;
- lifecycle authority.

Server harus menyelesaikan:

```text
authentication
→ account resolution
→ active SH resolution
→ Knowledge ownership
→ expected lifecycle
→ legal transition
→ domain authority
→ policy
→ confirmation/decision bila diperlukan
→ operation identity
```

`SECURITY DEFINER` digunakan hanya bila diperlukan untuk menjaga mutation boundary. Jika digunakan, function wajib memiliki safe `search_path`, server-resolved identity, ownership checks, exact grants, anonymous denial, dan tidak boleh menjadi bypass untuk authorization.

Existing RLS tetap defense-in-depth.

Direct client lifecycle mutation tidak menjadi application contract.

## 3. Confirmation Decision

Knowledge confirmation tidak menggunakan `runtime_high_risk_confirmations`, karena infrastructure tersebut secara domain dibatasi ke `RECOVERY_RESTORE`.

Confirmation Knowledge harus exact-action bound terhadap:

```text
actor_id
account_id
sh_id
knowledge_id
transition
operation_key
decision_ref
status
expires_at
confirmed_at
```

Confirmation tidak boleh menjadi global approval token.

Semantics:

- `CANDIDATE → ACCEPTED`: validation/acceptance decision + validation reference; confirmation tidak diwajibkan oleh baseline contract.
- `ACCEPTED → INDEXED`: indexing operation + index reference; confirmation tidak diwajibkan oleh baseline contract.
- `INDEXED → ACTIVE`: explicit activation decision + confirmation reference.
- `ACTIVE → UPDATED`: update/version authority; successor creation required; confirmation tidak diwajibkan oleh baseline contract.
- `ACTIVE → DEPRECATED`: explicit deprecation decision + confirmation reference.
- `DEPRECATED → ARCHIVED`: explicit archive decision + confirmation reference.

`confirmation_ref` tidak boleh diterima sebagai bypass jika transition policy tidak mensyaratkannya.

## 4. Operation Ledger Decision

Dedicated table:

```text
knowledge_lifecycle_operations
```

`audit_events` tetap generic runtime audit dan bukan authoritative lifecycle ledger.

Minimum semantic fields:

```text
operation_id
account_id
sh_id
knowledge_id
transition
expected_lifecycle
previous_lifecycle
resulting_lifecycle
operation_key
decision_ref
validation_ref
index_ref
update_ref
confirmation_ref
provenance
result_status
resulting_knowledge_id
resulting_version
journey_event_id
created_at
authorized_at
```

Idempotency identity wajib DB-enforced:

```text
account_id + sh_id + knowledge_id + transition + operation_key
```

Exact same operation identity after committed success → `ALREADY_APPLIED` dengan resulting record yang sama.

Same operation key dengan target/SH/account/transition berbeda → `OPERATION_CONFLICT`.

Content deduplication tidak menggantikan operation identity.

## 5. Transaction Boundary

Successful transition harus berada pada satu PostgreSQL transaction:

```text
AUTH
→ RESOLVE IDENTITY
→ LOCK KNOWLEDGE FOR UPDATE
→ VERIFY OWNERSHIP
→ VERIFY EXPECTED LIFECYCLE
→ VERIFY LEGAL TRANSITION
→ VERIFY AUTHORITY / POLICY / CONFIRMATION
→ RESOLVE OPERATION IDENTITY
→ MUTATE KNOWLEDGE
→ WRITE OPERATION LEDGER
→ WRITE REQUIRED JOURNEY PROJECTION
→ COMMIT
```

Required successful writes:

```text
Knowledge mutation
+ operation ledger
+ required Journey projection
```

harus atomic.

Jika downstream write gagal, domain mutation tidak boleh tersisa sebagai false success.

Concurrent requests terhadap Knowledge yang sama harus membaca state yang sudah terkunci dan tidak boleh menghasilkan duplicate invalid transition/successor.

## 6. Journey Decision

Journey tetap projection/history dan bukan lifecycle authority.

Lifecycle transition akan menggunakan canonical Journey event type `LIFECYCLE` dengan payload yang membawa semantic Knowledge transition:

```json
{
  "domain": "KNOWLEDGE",
  "knowledge_id": "<source-record-id>",
  "transition": "<transition>",
  "operation_id": "<operation-id>",
  "operation_key": "<operation-key>",
  "previous_lifecycle": "<old>",
  "resulting_lifecycle": "<new>",
  "resulting_knowledge_id": "<result-id>",
  "resulting_version": "<version>",
  "provenance_ref": "<reference>"
}
```

Untuk update/supersession, payload juga harus membawa successor dan hubungan `superseded_by`.

Projection dilakukan di dalam transaction lifecycle; replay/edit Journey tidak boleh mempromosikan Knowledge.

## 7. Error Contract

Machine-observable result categories:

```text
SUCCESS
ALREADY_APPLIED
REJECTED
FAILED
```

Semantic rejection categories:

```text
UNAUTHENTICATED
NOT_AUTHORIZED
SH_NOT_OWNED
RECORD_NOT_FOUND
WRONG_LIFECYCLE
INVALID_TRANSITION
INVALID_POLICY
DECISION_REQUIRED
CONFIRMATION_REQUIRED
OPERATION_KEY_INVALID
OPERATION_CONFLICT
CONCURRENCY_CONFLICT
DOMAIN_MUTATION_FAILED
JOURNEY_PROJECTION_FAILED
INTERNAL_FAILURE
```

SQLSTATE belum dikarang. Mapping final harus berasal dari implementasi PostgreSQL actual dan test DEV.

## 8. Exposure Hardening

Actual DEV inspection menemukan direct table privileges yang lebih luas daripada target lifecycle boundary pada `knowledge`, `audit_events`, dan `journey_events`. Karena itu implementation gate wajib mencakup review/restriction exposure yang relevan, tanpa memutus dependency existing secara speculative.

Target:

```text
client
  ↓
exact RPC EXECUTE
  ↓
server-side authorization
  ↓
internal mutation
```

Anonymous execution untuk lifecycle mutation harus ditolak.

Existing acquisition path `runtime_record_knowledge_with_journey` tetap dipisahkan dari lifecycle promotion authority.

## 9. Runtime Caller Boundary

Current `functions/ai-runtime/semantic_lifecycle.ts` membuktikan explicit Knowledge acquisition melalui `runtime_record_knowledge_with_journey`, tetapi belum membuktikan caller untuk staged lifecycle promotion.

Keputusan:

**AI semantic capture tidak boleh otomatis mempromosikan Knowledge lifecycle.**

Tidak ada runtime caller baru yang dibuat pada gate ini karena tidak ada approved contract yang menentukan kapan model/runtime berwenang melakukan acceptance, indexing, activation, deprecation, atau archive.

Lifecycle RPC dapat menjadi capability domain, tetapi caller integration tetap menunggu authority contract yang sesuai.

Dengan demikian, absence of caller bukan alasan untuk membuat speculative runtime behavior.

## 10. Gate Result

```text
Lifecycle authority                         PASS
Transition graph                            PASS
Security model                              PASS
Confirmation domain separation              PASS
Confirmation exact-action binding            PASS DESIGN
Operation ledger architecture                PASS DESIGN
DB idempotency identity                      PASS DESIGN
Atomic Knowledge + ledger + Journey         PASS DESIGN
Journey event convention                    PASS DESIGN
Exposure hardening requirement                PASS
Error categories                             PASS
SQLSTATE mapping                             OPEN until implementation
Runtime lifecycle caller authority           OPEN
Runtime lifecycle integration                OPEN
DB implementation                            NOT AUTHORIZED
E2E verification                             OPEN
```

## 11. Why Supabase-first Is Still Closed

Satu coherent database mutation sekarang dapat dirancang dengan boundary yang jelas, tetapi full-write implementation belum aman untuk dijalankan karena lifecycle caller authority belum disetujui dan SQLSTATE hanya boleh ditetapkan setelah implementation/test PostgreSQL actual.

Kita tidak membuat:

```text
ledger-only partial implementation
confirmation-only partial implementation
RPC-only partial implementation
speculative AI lifecycle promotion
```

Baseline DEV dipertahankan.

## 12. Next Gate

Sebelum Supabase-first implementation:

1. final implementation-level SQL design untuk ledger + confirmation + six RPC;
2. define exact PostgreSQL error/SQLSTATE mapping during implementation;
3. verify final grants against existing callers;
4. define database test harness including rollback and concurrency;
5. obtain/establish an explicit caller authority contract if runtime integration is required.

Setelah dependency tersebut tertutup, implementasi mengikuti:

```text
Supabase DEV
→ verify actual state
→ migration history
→ GitHub reconciliation
```

No Canonical change.
No production change.
No speculative migration.
