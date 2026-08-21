# SECOND HEAD — SESSION RESUME 52

## Melanjutkan dari

Session Resume 51 pada commit:
`b69c0a26d575ba0edb601aea0f9680df65f6c7af`

## Current HEAD

`1e0195c2badf6e906d31a97a11d1726686e9d595`

Reference utama:
- Canonical Matrix: `docs/SECOND_HEAD_CANONICAL_REAL_E2E_VERIFICATION_MATRIX_v1.0.md`
- Branch: `dev`
- Repository: `savie/second-head`
- Runtime test vehicle terakhir: APK #159
- Backend: Supabase DEV
- Runtime function: `runtime-p4a-001`, deployed v42 at the time of TC-EXP-10 verification

---

# 1. ATURAN KERJA YANG TETAP

```text
CANONICAL
   ↓
AUDIT GITHUB + SUPABASE
   ↓
BE/DB atau FE sesuai sumber defect
   ↓
CI
   ↓
APK baru bila diperlukan
   ↓
REAL E2E
   ↓
update Matrix
```

Aturan penting:

- Canonical Matrix adalah authority untuk TC-ID dan status.
- Jangan membuat TC-ID baru jika TC yang ada masih dapat menampung evidence.
- Actual CI/runtime evidence adalah authority saat debugging.
- Code existence ≠ E2E PASS.
- Historical DB row ≠ fresh mutation proof.
- Journey signal ≠ proof bahwa underlying domain retrieval sudah benar.
- Jangan mengubah lifecycle data secara irreversible tanpa evidence dan keputusan owner.
- Untuk defect minor yang tidak menghalangi domain progression, skip APK build bila owner sudah memutuskan demikian; lanjut audit/fix source dan Supabase hanya bila evidence mengharuskan.

---

# 2. AUDIT RANGE: RESUME 51 → CURRENT HEAD

GitHub compare menunjukkan HEAD maju 10 commit dari `b69c0a26...` ke `1e0195c2...` dan tidak behind terhadap base.

Urutan commit yang relevan:

1. `85e49a6` — `fix(FE): remove SH filter from account Journey read path`
2. `7463dc7` — `fix(FE): use account-scoped Journey read path`
3. `3d77b37` — `fix(FE): expose Journey event owner scope`
4. `0b380dd` — `fix(FE): skip owner policy for shared Journey events`
5. `4312e5e` — `docs(matrix): record EXP-06/07/08 verification`
6. `35dc304` — `fix(BE): use authorized shared Experience context retrieval`
7. `6d7a241` — `fix(BE): allow authorized shared Experience context`
8. `51669dd` — `fix(BE): preserve explicit Experience source metadata`
9. `f716937` — `fix(BE): expose authorized Experience context to model input`
10. `1e0195c` — `docs(matrix): record EXP-09/10 verification`

The first four commits addressed the Journey shared-read path and the owner-policy behavior for shared projections. `4312e5e` recorded the then-current EXP-06/07/08 evidence. The next four BE commits moved authorized shared Experience retrieval through the Chat/context path and preserved explicit source metadata, culminating in model-input exposure. The final commit records EXP-09/10 evidence in the canonical Matrix.

---

# 3. TC-EXP-06 — CURRENT DISPOSITION

Original defect:

```text
Account B
 ↓
Journey
 ↓
Experience
```

The FE previously constrained the Journey read to the recipient primary SH, so a GENERAL/SHARED Experience whose Journey event originated under another SH could not enter the result set even when Supabase RLS allowed shared visibility.

FE fix chain:

```text
85e49a6
remove SH filter
    ↓
7463dc7
account-scoped Journey read
    ↓
3d77b37
expose Journey event owner scope
    ↓
0b380dd
skip owner policy for shared Journey events
```

Runtime evidence after the fix showed Account B Journey could see the existing Account A `GENERAL / SHARED` Experience `TEST EXPERIENCE - PRIVATE LEGACY - E2E`.

The remaining issue at the time of the Matrix update was the shared-record detail policy read producing:

`JOURNEY_RECORD_POLICY_FAILED: JOURNEY_RECORD_POLICY_REJECTED: event not found or not owner-visible`

This was treated as a **minor FE policy-detail bug**, not a shared-visibility failure. The Matrix therefore keeps TC-EXP-06 at 🟡 until the corrected APK retest proves the detail path cleanly.

Do not reinterpret the shared visibility proof as full TC-EXP-06 PASS until the canonical Matrix is updated by explicit evidence.

---

# 4. TC-EXP-07 — PASS

Dedicated Experience fixture:

```text
Visibility: GENERAL / SHARED
Transfer policy: INHERITABLE
Experience ID:
aaa42648-4218-41ff-9c89-d099ad99ee6e
```

Runtime evidence:

- Experience appeared in Inheritance eligibility.
- Experience was selected.
- Authorization was created:
  `8978d126-9182-479b-bceb-6a7248aff05a`
- Status: `PENDING`
- Selected scope preserved the Experience ID in `experience_ids`.

Canonical Matrix status: **🟢 PASS**.

Important: authorization creation is proven; actual downstream enforcement/execution remains covered by later inheritance TCs and is not implied by this PASS.

---

# 5. TC-EXP-08 — PASS

Fixture:

```text
TEST EXPERIENCE - PRIVATE LEGACY - E2E
Visibility: PRIVATE / OWNER ONLY
Transfer policy: NON_TRANSFERABLE
```

Runtime evidence:

- The record remained visible to the owner-side Journey surface where appropriate.
- It did not appear as an eligible Experience in Inheritance.
- UI reported that no Experience records were marked `INHERITABLE`.

Canonical Matrix status: **🟢 PASS**.

This verifies that Journey visibility and transfer eligibility are separate semantics: a record can remain owner-visible while being non-transferable.

---

# 6. TC-EXP-09 — PASS

Account A created an Experience with:

```text
Visibility: PRIVATE / OWNER ONLY
Transfer policy: NON_TRANSFERABLE
```

Account B opened Journey and the private owner-only Experience did not appear.

Canonical Matrix status: **🟢 PASS**.

This is the negative cross-account privacy evidence for Experience visibility.

---

# 7. TC-EXP-10 — PASS

This was the final E2E proof for the Experience context chain.

Runtime vehicle:

```text
APK #159
```

Backend runtime:

```text
runtime-p4a-001
v42
```

Chat Verification:

```text
SH App Chat Verification #167
🟢 PASS
```

User test in Account B:

```text
Gunakan Experience dengan ID aaa42648-4218-41ff-9c89-d099ad99ee6e sebagai konteks. Jelaskan inti pengalaman tersebut secara singkat tanpa mengarang detail baru.
```

Observed SH response:

```text
Inti pengalaman tersebut adalah pengguna ingin membuat satu Experience khusus untuk uji transfer eligibility, dan meminta agar konteks percakapan ini ditandai sebagai pengalaman yang eksplisit serta dapat disimpan ke Journey.
```

The response matched the recorded Experience content and did not add unsupported detail.

Therefore the complete path is now runtime-proven:

```text
Journey-visible Experience
        ↓
Experience ID
        ↓
authorized Experience context retrieval
        ↓
RuntimeContext / model input
        ↓
system prompt
        ↓
model
        ↓
answer grounded in the stored Experience
```

Canonical Matrix status: **🟢 PASS**.

---

# 8. BACKEND EXPERIENCE CONTEXT CHAIN

The BE commit chain after the Journey visibility work was:

```text
35dc304
use authorized shared Experience context retrieval
        ↓
6d7a241
allow authorized shared Experience context
        ↓
51669dd
preserve explicit Experience source metadata
        ↓
f716937
expose authorized Experience context to model input
```

The final runtime verification on APK #159 demonstrated that this chain is not merely source-level: the specific Experience ID was successfully used by Chat as context and produced a grounded answer.

Supabase `runtime-p4a-001` was audited and deployed as v42 before the successful TC-EXP-10 run. No additional Supabase migration/fix was required for the final TC-EXP-10 proof after the deployment/runtime issue was resolved.

---

# 9. CURRENT CANONICAL EXPERIENCE STATE

```text
TC-EXP-01  🟢 PASS
TC-EXP-02  🟢 PASS
TC-EXP-03  🟢 PASS
TC-EXP-04  🟢 PASS
TC-EXP-05  🟢 PASS
TC-EXP-06  🟡 IN PROGRESS / minor FE policy-detail bug remains
TC-EXP-07  🟢 PASS
TC-EXP-08  🟢 PASS
TC-EXP-09  🟢 PASS
TC-EXP-10  🟢 PASS
```

Do not mark TC-EXP-06 PASS without a fresh APK retest of the shared event detail/policy path.

---

# 10. CURRENT MATRIX / PROJECT POSITION

Canonical Matrix at `1e0195c2...` uses APK #159 as runtime test vehicle and records EXP-09/10 as PASS.

Other important open domains remain:

- Memory creation/retrieval/continuity/authorization/context: largely ⏳.
- Knowledge creation/retrieval/continuity/authorization/context: largely ⏳.
- Clone: largely ⏳.
- Recovery: largely ⏳.
- Inheritance enforcement/negative authorization: largely ⏳.
- Succession: largely ⏳.
- End-of-life: ⏳.
- Error and authorization negative tests: largely ⏳.
- Functional Closure: ⏳.
- UI/UX: ⏳.

Do not infer Functional Closure from the Experience domain alone.

---

# 11. NEXT SESSION PRIORITY

First priority is to finish the remaining **TC-EXP-06 minor policy-detail defect** if owner wants Experience domain fully closed before moving on.

Expected flow:

```text
Audit current FE policy-detail path
        ↓
if source fix still required
        ↓
GitHub commit
        ↓
Chat Verification CI
        ↓
🟢 PASS
        ↓
Android Build
        ↓
APK install
        ↓
retest only TC-EXP-06
        ↓
if PASS → update Matrix
```

If owner chooses to defer the minor defect, explicitly retain TC-EXP-06 as 🟡 and proceed only where the Canonical Matrix permits.

After Experience disposition, continue with the next open canonical domain rather than creating duplicate Experience TCs.

---

# 12. SESSION RESUME 52 CLOSURE

```text
RESUME 51 START
b69c0a26...
    ↓
FE Journey shared-read fix chain
    ↓
BE authorized Experience context chain
    ↓
Chat Verification #167 🟢
    ↓
Supabase runtime-p4a-001 v42
    ↓
Android Build #159
    ↓
TC-EXP-09 🟢
TC-EXP-10 🟢
    ↓
Matrix commit
1e0195c2badf6e906d31a97a11d1726686e9d595
    ↓
SESSION RESUME 52
```

Resume 52 is a checkpoint only. The Canonical Matrix remains the authority for live TC status.
