# P3E — Context Testing v1.0

## Status

PASS / DEV

Backlog: `BL-P3E-009`
Acceptance Criteria: `AC-CTX-09`
Domain: Phase 3E — Context

## Purpose

Memverifikasi bahwa existing context assembly contract bekerja sebagai satu jalur terintegrasi setelah Context Assembly, Composition, Layering, Prioritization, Validation, Disposal, dan Budget & Truncation.

## Test Basis

Testing menggunakan existing:

`public.assemble_context(p_sh_id, p_query_text, p_memory_limit, p_knowledge_limit)`

Tidak dibuat context table, retrieval engine, atau authorization path baru.

## Verification Matrix

1. **Envelope validity**
   - hasil berupa JSON object;
   - `query` tersedia;
   - `memory` berupa array;
   - `knowledge` berupa array.

2. **Source separation**
   - memory tetap berada pada section `memory`;
   - knowledge tetap berada pada section `knowledge`;
   - tidak terjadi pencampuran source menjadi satu array.

3. **Memory isolation**
   - synthetic memory milik SH lain tidak masuk ke context SH yang diuji;
   - `wrong_sh_memory_count = 0` pada verification run.

4. **Knowledge visibility boundary**
   - hanya knowledge `SHARED` yang masuk retrieval path;
   - synthetic `OWNER_ONLY` knowledge tidak masuk context.

5. **Explicit limit behavior**
   - request `memory_limit=2`, `knowledge_limit=2` menghasilkan `2 + 2 = 4` item.

6. **Combined context budget**
   - request maksimum `50 + 50` tidak menghasilkan lebih dari 50 total item;
   - verification menghasilkan `49 memory + 1 knowledge = 50`.

7. **Null/empty query behavior**
   - `query = null` tetap menghasilkan envelope valid dan retrieval bounded sesuai limit.

8. **Residue cleanup**
   - synthetic verification dilakukan dalam transaction dan di-rollback;
   - final test residue: `0 memory`, `0 knowledge`.

## Security / Privacy Boundary

Testing tidak mengubah:

- RLS;
- ownership boundary;
- privacy boundary;
- Memory schema;
- Knowledge schema;
- canonical invariant `MEMORY ≠ KNOWLEDGE ≠ CONTEXT`.

`assemble_context(...)` tetap `SECURITY INVOKER`.

## Minimal Reconciliation

P3E-009 tidak memerlukan schema mutation atau function baru. Existing context assembly point sudah menyediakan seluruh behavior yang perlu diuji.

Perubahan P3E-008 mengenai combined budget/truncation menjadi bagian dari verification surface P3E-009.

## Assurance Limitation

Database/function-level integration behavior telah benar-benar diuji dengan synthetic rows.

Application/API/UI E2E assurance dan model/token-budget runtime assurance belum diuji pada item ini dan tetap `DEFERRED`.

## Completion Statement

`BL-P3E-009 = PASS / DEV`

Context Testing v1 is satisfied through direct verification of the existing context assembly contract, source separation, isolation boundary, limits, combined budget, null-query behavior, and clean test rollback without architectural mutation.
