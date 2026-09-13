# SECOND HEAD — Knowledge Lifecycle Implementation Reconciliation — 2026-09-13

## Status

**WORKING VERIFICATION RECORD — DB CAPABILITY IMPLEMENTED — E2E PARTIAL / RUNTIME INTEGRATION OPEN**

Dokumen ini merekonsiliasi working contract dengan actual Supabase DEV setelah implementation gate dijalankan. Dokumen ini tidak mengubah Canonical atau Approved Contract.

## 1. Supabase-First Execution

Supabase DEV diubah terlebih dahulu, kemudian diverifikasi secara langsung. Migration history Supabase sekarang memiliki:

```text
20260913092434 knowledge_lifecycle_authority_and_operations
20260913092503 knowledge_lifecycle_authority_exposure_hardening
20260913092952 revoke_direct_semantic_mutation_access
```

Nama migration bersifat deskriptif dan tidak menggunakan label P3/P4/P5.

## 2. Implemented Objects

Implemented pada DEV:

- `knowledge_lifecycle_confirmations`
- `knowledge_lifecycle_operations`
- `runtime_create_knowledge_lifecycle_confirmation`
- `runtime_confirm_knowledge_lifecycle`
- `runtime_accept_knowledge`
- `runtime_index_knowledge`
- `runtime_activate_knowledge`
- `runtime_update_knowledge`
- `runtime_deprecate_knowledge`
- `runtime_archive_knowledge`
- internal `runtime_knowledge_transition`

Confirmation dan operation tables menggunakan RLS dan direct mutation grants untuk `anon`/`authenticated` telah dicabut. Direct mutation grants pada `knowledge` dan `journey_events` juga telah dicabut untuk `public`/`anon`/`authenticated`.

## 3. Security Verification

Actual function privilege verification menunjukkan seluruh public Knowledge lifecycle entry points:

```text
anon          = EXECUTE false
authenticated = EXECUTE true
public        = EXECUTE false
```

Entry points menggunakan `SECURITY DEFINER` dengan fixed `search_path=public` dan authentication/ownership checks di implementation boundary.

Internal `runtime_knowledge_transition` tidak diekspos ke `public`, `anon`, atau `authenticated`.

Actual table privilege verification menunjukkan:

```text
knowledge:
  anon/authenticated = SELECT + REFERENCES + TRIGGER
  mutation           = revoked

journey_events:
  anon/authenticated = SELECT + REFERENCES + TRIGGER
  mutation           = revoked

knowledge_lifecycle_confirmations:
  anon/authenticated = no direct table privileges

knowledge_lifecycle_operations:
  anon/authenticated = no direct table privileges
```

## 4. Confirmation Authority

Knowledge lifecycle sekarang memiliki confirmation mechanism terpisah dari recovery confirmation.

Confirmation terikat pada:

```text
actor
account
SH
knowledge
transition
operation_key
decision_ref
status
expiry
```

Confirmation-required transitions:

```text
INDEXED → ACTIVE
ACTIVE → DEPRECATED
DEPRECATED → ARCHIVED
```

Recovery confirmation (`RECOVERY_RESTORE`) tidak digunakan sebagai Knowledge lifecycle authority.

## 5. Operation Identity / Idempotency

`knowledge_lifecycle_operations` menjadi persistent lifecycle operation ledger.

Logical idempotency scope pada database:

```text
account + SH + operation_key
```

Database unique index menegakkan scope tersebut. Existing operation dengan operation key yang sama diperiksa terhadap target Knowledge dan transition. Konflik target/transition ditolak.

## 6. Transition Matrix Implemented

```text
CANDIDATE → ACCEPTED
ACCEPTED → INDEXED
INDEXED → ACTIVE
ACTIVE → UPDATED + successor
ACTIVE → DEPRECATED
DEPRECATED → ARCHIVED
```

`ACTIVE → UPDATED` membuat successor `ACTIVE`, mempertahankan source sebagai `UPDATED`, dan mengisi `superseded_by`.

## 7. Transaction Boundary

Transition helper melakukan target row lock sebelum lifecycle mutation.

Successful path melakukan:

```text
Knowledge mutation
→ operation ledger insert
→ Journey lifecycle projection
→ operation ledger Journey reference
→ commit
```

Karena seluruh operasi berada dalam satu PostgreSQL function transaction, failure pada required Journey projection menyebabkan transaction gagal/rollback.

Atomicity design sudah diimplementasikan, tetapi full concurrency/E2E proof masih OPEN.

## 8. Journey Projection

Successful lifecycle transition menggunakan Journey event type:

```text
LIFECYCLE
```

Payload minimum yang ditulis:

```text
domain
knowledge_id
transition
operation_id
operation_key
previous_lifecycle
resulting_lifecycle
resulting_knowledge_id
resulting_version
provenance_ref
```

Journey tetap projection/history dan bukan lifecycle authority.

## 9. Data Safety

Setelah migration:

```text
knowledge rows = 1
knowledge_lifecycle_operations = 0
knowledge_lifecycle_confirmations = 0
journey_events = 3
```

Tidak ada existing Knowledge record yang dimutasi oleh migration implementation.

Current Knowledge lifecycle distribution tetap:

```text
CANDIDATE = 1
```

## 10. Important Verification Limitation

Tool execution pada current audit context tidak menyediakan authenticated end-user session yang dapat dipakai secara aman untuk menjalankan full positive lifecycle mutation terhadap existing user-owned record.

Karena itu belum boleh diklaim:

```text
full authenticated E2E = VERIFIED
cross-account E2E       = VERIFIED
concurrency E2E         = VERIFIED
runtime caller integration = VERIFIED
```

Static database verification dan privilege verification sudah dilakukan; behavioral E2E tetap OPEN.

## 11. Runtime Boundary

Current AI runtime tetap berada pada candidate acquisition path dan tidak diberi automatic lifecycle promotion authority.

Tidak ada perubahan runtime code pada implementation ini.

Model output dan confidence tetap bukan lifecycle authority.

Runtime caller untuk explicit lifecycle operation masih merupakan integration workstream berikutnya dan harus menggunakan authenticated actor authority, bukan automatic model promotion.

## 12. GitHub Reconciliation

Migration history Supabase sekarang direpresentasikan pada GitHub DEV sebagai:

```text
database/migrations/20260913092434_knowledge_lifecycle_authority_and_operations.sql
database/migrations/20260913092503_knowledge_lifecycle_authority_exposure_hardening.sql
database/migrations/20260913092952_revoke_direct_semantic_mutation_access.sql
```

Actual GitHub DEV files telah diverifikasi setelah write. Migration `20260913092952` memiliki nama dan version yang sama dengan actual Supabase migration history.

## 13. Gate Result

```text
Supabase schema capability        = IMPLEMENTED
Confirmation authority            = IMPLEMENTED (DB boundary)
Operation ledger                  = IMPLEMENTED
Idempotency enforcement           = IMPLEMENTED
Atomic transaction design         = IMPLEMENTED
Journey lifecycle projection      = IMPLEMENTED
Security exposure                 = VERIFIED STATIC
Direct semantic table mutation    = HARDENED / VERIFIED STATIC
Data preservation                 = VERIFIED
Authenticated behavioral E2E      = OPEN
Cross-actor E2E                   = OPEN
Concurrency E2E                   = OPEN
Runtime caller integration        = OPEN
SQLSTATE/error mapping            = OPEN

OVERALL KNOWLEDGE LIFECYCLE GATE  = PARTIAL PASS
```

## 14. Next Engineering Gate

**DATABASE BEHAVIORAL VERIFICATION + RUNTIME INTEGRATION AUDIT**

Required evidence:

1. authenticated positive lifecycle path;
2. required confirmation path;
3. wrong lifecycle rejection;
4. cross-account/cross-actor rejection;
5. operation-key idempotency;
6. operation-key conflict;
7. concurrent transition behavior;
8. rollback when Journey projection fails;
9. update/supersession integrity;
10. terminal archive behavior;
11. runtime caller authority and E2E integration;
12. stable SQLSTATE/error mapping if required by the approved runtime contract.

## Change Boundary

```text
Supabase schema/data       = CHANGED (schema only; existing Knowledge preserved)
Migration history          = CHANGED
GitHub migration files     = CHANGED
Working verification docs  = CHANGED
Runtime code               = UNCHANGED
Canonical                  = UNCHANGED
Approved Contract          = UNCHANGED
```
