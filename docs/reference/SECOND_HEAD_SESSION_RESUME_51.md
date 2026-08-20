# SECOND HEAD — SESSION RESUME 51

## Melanjutkan dari

Session Resume 50 pada commit:
`a1862392d1675eace336e75646d4d1da485a8467`

Reference utama:
- Canonical Matrix: `docs/SECOND_HEAD_CANONICAL_REAL_E2E_VERIFICATION_MATRIX_v1.0.md`
- Branch: `dev`
- Repository: `savie/second-head`
- Runtime test vehicle terakhir: APK #153
- Backend: Supabase DEV

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
- Actual CI error adalah authority saat debugging CI.
- Code existence ≠ E2E PASS.
- Historical DB row ≠ fresh mutation proof.
- Journey signal ≠ proof bahwa underlying domain retrieval sudah benar.
- Jangan mengubah lifecycle data secara irreversible tanpa evidence dan keputusan owner.

---

# 2. HASIL SEJAK RESUME 50

Resume 50 berakhir pada BE recovery alignment dan kemudian pekerjaan berlanjut ke policy/transfer UX serta REAL E2E Experience.

Commit penting yang teraudit dari GitHub DEV:

- `cacc00f` — restore Journey filter state.
- `66e23ae` — remove legacy Experience recorder overload.
- `24fb11c` — resolve Journey policy UUID without `max(uuid)`.
- `9383006` — route inheritance authorization through owner RPC.
- `c5930fb` — track owner inheritance authorization RPC.
- `21add32` / `088da01` — align and track applied inheritance RPC migration.
- `57ce0d1` — record APK #150 Experience continuity evidence.
- `a1d4ab0` — add Journey visibility bridge for GENERAL/SHARED underlying records.
- `38daa4e` — update canonical Matrix with TC-EXP-06 result on APK #153.

---

# 3. JOURNEY POLICY / LIFECYCLE UX

Journey sekarang menjadi detail surface untuk Memory / Knowledge / Experience milik Owner.

Flow yang terbukti di APK sebelumnya:

```text
Journey
 ↓
Memory / Knowledge / Experience
 ↓
Detail
 ↓
Visibility
Transfer Policy
 ↓
Edit
```

Evidence user:

- Memory policy edit: PASS.
- Memory after reload: PASS.
- Memory inheritance checklist: muncul.
- Knowledge policy edit: PASS.
- Knowledge after reload: PASS.
- Knowledge succession: muncul.
- Knowledge checklist: ada.
- Experience policy edit sebelumnya gagal dan kemudian backend/UX recorder path diperbaiki.
- Legacy Experience record akhirnya dapat muncul dan policy dapat diedit.

Journey filter state juga sudah dipulihkan melalui `cacc00f`.

---

# 4. EXPERIENCE REAL E2E

Experience test record yang dipakai:

```text
TEST EXPERIENCE - PRIVATE LEGACY - E2E
```

Pada test terakhir record domain Experience di Supabase DEV adalah:

```text
scope: GENERAL
visibility: SHARED
transfer_policy: NON_TRANSFERABLE
source_ref: runtime:p5a:explicit_user_capture
```

Experience ID aktual yang ditemukan di Supabase DEV:

`a5692b47-616f-4560-bfe3-d9921b97b981`

Source SH:

`78965d6c-33c2-45f1-9177-bd57b59eadf2`

Account owner:

`83c9f2a1-7617-471c-9c68-75e0003ea6ab`

## Canonical Experience status

```text
TC-EXP-01  🟢 Create Experience
TC-EXP-02  🟢 Experience persistence
TC-EXP-03  🟢 Experience payload integrity
TC-EXP-04  🟢 Experience retrieval
TC-EXP-05  🟢 Experience continuity semantics
TC-EXP-06  🔴 Experience visibility
TC-EXP-07  ⏳ Experience transfer eligibility
TC-EXP-08  ⏳ Experience non-transferable enforcement
TC-EXP-09  ⏳ Experience unauthorized access
TC-EXP-10  ⏳ Experience usable by downstream Chat/context
```

TC-EXP-05 sudah PASS berdasarkan APK #150: follow-up Chat mengambil Experience persisted dengan ID `c75fc10d-f12a-4567-ac52-4546a54a11ef` dan menjelaskan bahwa pengalaman tersebut dipakai sebagai dasar jawaban.

---

# 5. TC-EXP-06 — HASIL TERAKHIR

APK #150 dan APK #152 sudah dipakai untuk retest visibility.

Perbaikan backend `a1d4ab0` kemudian dibuat dan migration terkait diterapkan ke Supabase DEV. Chat Verification untuk `a1d4ab0` juga PASS sebagai #158.

APK #153 kemudian di-install dan TC-EXP-06 diulang hanya pada bagian yang gagal:

```text
Account B
 ↓
Journey
 ↓
Experience
 ↓
No events in this category
```

Expected:

```text
Account A Experience
GENERAL / SHARED
        ↓
Account B Journey
        ↓
Experience terlihat
```

Hasil APK #153: **FAIL**.

---

# 6. AUDIT GITHUB + SUPABASE SETELAH APK #153

## Supabase

Migration berikut sudah ada di DEV:

`20260820134854 — fix_journey_shared_experience_visibility`

Function aktual di DEV:

`public.runtime_journey_event_is_shared(uuid)`

Status:

- SECURITY DEFINER: aktif.
- `authenticated` memiliki EXECUTE.
- RLS `journey_events` memakai `journey_events_visibility_select`.
- Policy owner tetap memberi akses untuk SH milik account sendiri.
- Policy shared memanggil `runtime_journey_event_is_shared(event_id)`.

Function memang memeriksa underlying Memory / Knowledge / Experience dan hanya membuka `GENERAL + SHARED`.

## Data aktual

Journey Experience event untuk record test lama masih memiliki payload:

```text
capture_mode: EXPLICIT_USER
representation: TEST EXPERIENCE - PRIVATE LEGACY - E2E
```

Payload event tersebut **tidak membawa `experience_id`**.

Migration sudah memiliki backward-compatible fallback yang mencocokkan:

```text
source_ref = runtime:p5a:explicit_user_capture
content = representation
```

Dengan data DEV saat ini, underlying Experience yang cocok adalah satu record dan sudah `GENERAL / SHARED`.

## Sumber defect yang ditemukan

Audit source menunjukkan FE masih melakukan:

```text
loadJourneyEvents(primarySH.sh_id)
```

dan `journey-service.ts` menjalankan query:

```text
.from('journey_events')
.select(...)
.eq('sh_id', shId)
```

Artinya saat Account B membuka Journey, query sudah lebih dulu dibatasi ke **SH milik Account B**.

RLS shared visibility tidak dapat menambahkan row dari SH Account A karena row tersebut sudah dibuang oleh filter `.eq('sh_id', B_SH_ID)`.

Jadi defect TC-EXP-06 sekarang terlokalisasi sebagai **FE/read-path defect**, bukan migration/RLS defect.

Belum ada fix FE pada Resume 51. Jangan membuat APK baru sebelum source fix dibuat dan CI PASS.

---

# 7. INHERITANCE / SUCCESSION / LEGACY

Evidence APK #150 yang sudah terbukti:

```text
Inheritance authorization created:
dc8f020c-23ee-4711-a776-d2519477dd4c
status: PENDING
selected Memory preserved in memory_ids
```

Succession:

```text
07cc54fb-48b1-49f7-a80a-6dd32f8eaba7
```

Legacy:

```text
939b8387-29d3-4099-9caf-2947b91b24a8
```

Kesalahan target account/SH sebelumnya sudah dilacak dan kemudian target valid berhasil digunakan sampai authorization creation sukses.

Jangan menganggap creation = enforcement. TC enforcement masih terbuka.

---

# 8. CI / APK STATE

Workflow Chat Verification sudah berhasil menjalankan commit `a1d4ab0`:

```text
SH App Chat Verification #158
commit a1d4ab0
🟢 PASS
```

Android Build #152 masih dipakai sebelum DB visibility fix efektif untuk retest.

Android Build #153 sudah di-install dan menjadi runtime evidence terakhir.

Hasil #153 tetap:

```text
TC-EXP-06 = 🔴 FAIL
```

Jangan menganggap CI PASS sebagai E2E PASS.

---

# 9. CURRENT POSITION

```text
TC-EXP-01..05     🟢 PASS
TC-EXP-06         🔴 FAIL
                    ↓
          FE Journey read-path defect
                    ↓
        remove/reshape current-SH filter
                    ↓
              CI verification
                    ↓
                APK baru
                    ↓
          retest hanya TC-EXP-06
```

TC berikutnya **belum boleh dilanjutkan** sebelum TC-EXP-06 selesai atau owner memutuskan disposition lain.

---

# 10. NEXT SESSION INSTRUCTION

Lanjut dari commit terakhir Resume 51.

Prioritas tunggal:

```text
Audit + fix FE Journey read path untuk TC-EXP-06.
```

Jangan mengubah Canonical semantics.
Jangan membuat TC baru.
Jangan mengubah data lifecycle secara manual.

Fix harus membuat Account B dapat membaca `GENERAL / SHARED` Experience dari Account A melalui Journey, sementara `PRIVATE / OWNER_ONLY` tetap tidak bocor.

Audit actual source dulu. Setelah fix:

```text
GitHub commit
 ↓
Chat Verification
 ↓
🟢
 ↓
Android Build
 ↓
APK baru
 ↓
install
 ↓
TC-EXP-06 retest
 ↓
update Matrix + Resume berikutnya
```

Jika test masih gagal, audit actual query/RLS lagi; jangan menebak.
