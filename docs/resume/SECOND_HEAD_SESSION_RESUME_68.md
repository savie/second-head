# SECOND HEAD — SESSION RESUME 68

## Melanjutkan dari SESSION RESUME 67


## Proyek
SECOND HEAD — SYSTEM BUILD

## Dasar audit

### Status APK — frozen baseline dan APK aktif
- **APK #194** adalah **frozen baseline saja** dan tetap immutable.
- **APK aktif untuk regression saat ini: #199**.
- Build #199 dibuat setelah frozen baseline dan digunakan untuk pengujian BUG-004.
- Workflow Android Build #199: run `33032370331` — **success**.
- Source commit Build #199: `393f7e770b6108f394410bd3885024ca686430e9`.
- Artifact: `sh-app-release-apk` — artifact ID `9630932207`.
- Jika perubahan berikutnya membutuhkan APK baru, build number **wajib meningkat** (mis. #200), dan APK baru tersebut menjadi **APK aktif/regression terbaru**.
- Setelah APK baru tersedia dan digunakan untuk regression, seluruh pengujian berikutnya menggunakan APK terbaru tersebut. **APK #194 tidak lagi dipakai sebagai APK testing aktif.**
- Jika perubahan hanya berada di backend/DB dan tidak membutuhkan APK baru, tidak perlu membuat APK baru hanya untuk mengganti baseline testing.

- Frozen final-gate baseline: `c44b2bc311baea5a46d0acb957049eb3c8307817`
- Frozen implementation candidate: `40a8772e3c79e17de77c7581048620286ff638a9`
- Frozen APK: #194 (hanya frozen baseline)
- APK SHA-256: `bc53e9ebfe6c3fc92ec1e675998cbd774a97b5f51184e51c95236b97eb6690d4`
- Audit dilanjutkan melalui seluruh riwayat maintenance DEV setelah freeze.
- DEV HEAD aktual saat Resume 68 diperbarui: `4c9146f3a059891c93edc2e60828c837337219f2`
- **APK regression terakhir yang digunakan untuk pengujian BUG-004: #199**
- Workflow Android Build #199: run `33032370331`
- Commit source Build #199: `393f7e770b6108f394410bd3885024ca686430e9`
- Status Build #199: **success**
- Artifact APK: `sh-app-release-apk` (artifact ID `9630932207`)

> Frozen baseline tetap tidak berubah. Seluruh bug di bawah adalah maintenance setelah baseline.

---

# BUG-001 — SHORT-TERM CONVERSATIONAL RECALL

## Masalah
Pesan percakapan sudah tersimpan dan terlihat di UI, tetapi runtime belum mengirim riwayat percakapan terbaru ke model.

Akibatnya SH tidak dapat secara konsisten menjawab berdasarkan pesan percakapan yang baru saja terjadi.

## Akar masalah
Jalur yang hilang adalah:

```
conversation persistence
        ↓
runtime-owned retrieval
        ↓
active-SH scope
        ↓
bounded recent window
        ↓
conversation_context
        ↓
model request
```

Memory dan Experience tetap merupakan domain persistence/context terpisah dan tidak digunakan sebagai penyimpanan transcript percakapan.

## Perbaikan
Ditambahkan jalur retrieval conversation context yang dimiliki runtime menggunakan persistence `conversations` yang sudah ada.

DB function membatasi jendela pesan terbaru dan memverifikasi `sh_id` terhadap active SH yang terautentikasi.

## Verifikasi
Verifikasi perangkat menunjukkan SH dapat merujuk pesan percakapan sebelumnya tanpa bergantung pada Memory atau Experience.

## Status
**🟢 FIXED + DEVICE VERIFIED**

Implementasi terkait dimulai pada Build #195 / migration:
`20260826050000_bug_001_short_term_conversation_context`

---

# BUG-002 — KEBIJAKAN PERSISTENSI MEMORY / PENCEGAHAN DUPLIKAT

## Masalah
Percakapan biasa sebelumnya dapat menyebabkan Memory tersimpan otomatis tanpa permintaan eksplisit.

Behavior yang diwajibkan:

```
ordinary conversation
        ↓
NO automatic Memory persistence

explicit "remember/save as Memory"
        ↓
Memory may be persisted

explicit opt-out
        ↓
hard boundary / do not persist
```

## Masalah historis tambahan
Implementasi sebelumnya dapat membuat duplicate Memory pada repeated explicit save.

Duplicate historis tersebut adalah evidence/history dan tidak boleh dihapus hanya agar kondisi saat ini terlihat bersih.

## Perbaikan / reconciliation
Behavior persistence dan deduplication telah diperbaiki.

Behavior yang sekarang diharapkan:

- ordinary statement does not create Memory/Experience
- explicit Memory request creates Memory
- Memory recall works
- repeated explicit save against the same Memory does not create a new duplicate
- ordinary paraphrase does not create Memory
- retrieval does not create Memory

## Verifikasi
Behavior tersebut telah diverifikasi pada perangkat.

## Status
**🟢 FIXED + VERIFIED**

Duplicate Memory historis tetap dipertahankan sebagai evidence.

---

# BUG-003 — FORMAT RESPONS DAFTAR MEMORY

## Masalah
Retrieval Memory sebenarnya sudah bekerja, tetapi permintaan untuk menampilkan semua Memory satu per baris dengan satu baris kosong menghasilkan output yang menyatu.

Pola yang terlihat:

```
1. ...
2. ...3. ...
```

Retrieval di backend mengembalikan seluruh record Memory yang diharapkan, sehingga awalnya ini bukan kegagalan retrieval.

## Trace / diagnosis
Audit mengikuti jalur:

```
authorized_memory_context
        ↓
context assembly
        ↓
model request
        ↓
runtime SSE serialization
        ↓
natural-language response
```

Dua defect terkait ditemukan dan diperbaiki:

1. Instruksi format respons eksplisit belum cukup ditegakkan pada semantic model prompt.
2. Penanganan chunk SSE runtime dapat menyebabkan line break tidak dipertahankan dengan benar.

## Perbaikan
- Instruksi format eksplisit sekarang diteruskan sebagai persyaratan format respons.
- Penanganan SSE runtime diperbaiki agar karakter newline tetap dipertahankan.

Relevant commits include:

- `93bf3f8c3911592de9bc92deb7c6cb9d4938c018` — honor explicit response formatting instructions
- `945b659fd5e28ef48bc8130029f81d1b6f80d171` — preserve newlines in runtime SSE chunks

## Pembedaan penting
Inventaris/retrieval Memory sendiri sudah PASS:

- all Memory retrieval: PASS
- no new Memory during retrieval: PASS
- no new duplicate: PASS

Defect berada pada penyajian/serialisasi respons.

## Status
**🟢 FIXED**

---

# BUG-004 — PENGHAPUSAN LIFECYCLE TERSINKRONISASI

## Cakupan
BUG-004 diperluas dari deletion Memory menjadi synchronized lifecycle deletion untuk domain yang memang mempunyai source-record deletion semantics:

- MEMORY
- KNOWLEDGE
- EXPERIENCE

Prinsip target:

```
delete from Journey
        ↕
delete source record
        ↓
Journey representation/event synchronized
```

Recovery/Evolution tidak dipaksa menjadi delete semantics tanpa evidence dari implementation aktual.

## BUG-004A — Journey → Memory
PASS.

Pengujian mencakup:
- single Memory deletion
- Memory with multiple Journey events

Hasil:
- source Memory removed
- associated Journey events removed
- refresh remained clean

## BUG-004B — Chat → Memory
Kegagalan awal:
SH reported Memory deleted, but the source and Journey representation remained.

Akar masalah:
Chat deletion belum diarahkan ke mekanisme synchronized lifecycle deletion.

Perbaikan:
Chat Memory deletion was routed through:

```
runtime_delete_record_with_journey(domain, record_id)
```

Hasil akhir:
**PASS**

## BUG-004C — Journey → Knowledge
PASS.

Pembedaan semantic penting:

```
source domain = KNOWLEDGE
Journey representation = LEARNING
```

`LEARNING` does not mean the source became another domain.

## BUG-004D — Chat → Knowledge
Kegagalan awal:
Chat Knowledge deletion did not reliably resolve the target source record.

Perbaikan:
- Routing Chat deletion untuk Knowledge ditambahkan.
- Knowledge matching corrected.
- Regression code eksplisit diprioritaskan untuk resolusi target yang deterministik.
- Deletion menggunakan synchronized lifecycle mechanism.

Hasil akhir:
**PASS**

## BUG-004E — Journey → Experience
PASS.

Source Experience dan Journey representation tersinkron saat deletion.

## BUG-004F — Chat → Experience
Kegagalan awal:
Chat Experience deletion belum sepenuhnya terhubung ke synchronized lifecycle deletion.

Perbaikan:
Chat Experience deletion diarahkan melalui common deletion path.

Hasil akhir:
**PASS**

## Penerimaan akhir BUG-004

```
Journey → Memory       PASS
Journey → Knowledge    PASS
Journey → Experience   PASS

Chat → Memory          PASS
Chat → Knowledge       PASS
Chat → Experience      PASS
```

Pemeriksaan kebersihan account E2E dilakukan pada:
`E2E_TEST@SH.COM`

Journey bersih dari record Memory/Knowledge/Experience yang diuji. General Shared Experience tidak dihitung sebagai kebocoran data private E2E pada acceptance check.

## DB / provenance
BUG-004 menggunakan mekanisme database lifecycle:

```
runtime_delete_record_with_journey(domain, record_id)
```

Riwayat migration terkait:

- `20260827020203`
- `20260827074749_bug004_sync_journey_source_delete_v2`
- `20260827120000_bug004_synchronized_journey_source_delete`

Perbaikan runtime di-commit ke GitHub DEV dan di-deploy ke Supabase DEV dari source DEV yang sesuai.

## Status
**🟢 CLOSED / PASS**

---

# BUG-005 — RIWAYAT PERCAKAPAN

## Posisi
BUG-005 adalah **area fungsional berikutnya setelah BUG-004**.

Jangan menyamakannya dengan BUG-001.

### BUG-001
Short-term conversation context **inside the active conversation/runtime model context**.

### BUG-005
Persisted **Riwayat Percakapan / navigasi dan continuity percakapan sebagai fitur produk**.

Repository sudah memiliki lineage implementasi Conversation History, termasuk authenticated history read/load dan perbaikan agar chat baru tetap kosong, bukan mengisi history seluruh account.

Commit historis terkait:

- `1483d14a896f0aeaf72d6360656c3e1a6e11649f` — authenticated conversation history read function
- `f25b9471e2b179e114b1b89fd3b7d32a38286c84` — authenticated conversation history read
- `70504ba8a0d9cc1ca7a6c61c6ed7b6c1a4d993e9` — authenticated conversation history loader
- `054a42c3997ec4d600829d7175dbfe740e292eb4` — load persisted conversation history on chat open
- `ab67a4148ab6a21ca2c488b54a554d7471564e18` — keep new chat empty; remove account-wide history hydration

## Audit berikutnya yang wajib dilakukan

Sebelum mengubah code:

1. Trace record Conversation yang tersimpan.
2. Trace authenticated history read.
3. Trace history loader dan behavior saat chat dibuka.
4. Trace perbedaan active conversation dan conversation baru.
5. Verifikasi isolasi account/SH.
6. Tentukan UX yang benar berdasarkan implementation aktual dan project contract.
7. Reproduce behavior saat ini pada `E2E_TEST@SH.COM`.
8. Setelah itu baru klasifikasikan defect BUG-005 yang sebenarnya.
9. Lakukan fix minimal.
10. Commit + push DEV.
11. Deploy melalui jalur resmi.
12. Verifikasi CI.
13. Uji pada perangkat.
14. Verifikasi DB dan UI.

**Jangan membuat hasil acceptance BUG-005 sebelum audit ini dilakukan.**

## Status
**🟡 NEXT / AUDIT REQUIRED**

---

# RANGKAIAN BUG SETELAH FROZEN BASELINE

```
Frozen v1.0
APK #194
c44b2bc...
        ↓
BUG-001
Short-term Conversational Recall
        ↓
FIXED + DEVICE VERIFIED

        ↓
BUG-002
Kebijakan Persistence Memory
        ↓
FIXED + VERIFIED

        ↓
BUG-003
Format Respons Daftar Memory
        ↓
FIXED

        ↓
BUG-004
Penghapusan Lifecycle Tersinkronisasi
APK #199
Source: 393f7e7...
        ↓
CLOSED / PASS

        ↓
BUG-005
Conversation History
        ↓
NEXT / AUDIT REQUIRED
```

---

# KETERLACAKAN DEV / SUPABASE

GitHub DEV:
`savie/second-head`

Supabase DEV:
`pkhkgvsrqeupvwoqjwmd`

Frozen final-gate record:
`c44b2bc311baea5a46d0acb957049eb3c8307817`

Frozen implementation:
`40a8772e3c79e17de77c7581048620286ff638a9`

Frozen APK:
`#194` — frozen baseline saja

APK regression aktif terakhir:
`#199` — digunakan untuk verifikasi BUG-004

Source commit APK #199:
`393f7e770b6108f394410bd3885024ca686430e9`

Workflow Android Build #199:
`33032370331` — success

Artifact APK #199:
`sh-app-release-apk` — artifact ID `9630932207`

Aturan APK aktif:
- #194 hanya frozen baseline historis dan tidak dipakai sebagai APK testing aktif setelah tersedia build regression.
- Jika perubahan berikutnya membutuhkan APK baru, build number wajib naik; APK terbaru itulah yang menjadi APK aktif untuk regression berikutnya.
- Jangan menebak source APK dari commit dokumentasi Resume.

DEV HEAD sebelum commit dokumentasi Resume 68 ini:
`4c9146f3a059891c93edc2e60828c837337219f2`

**Penting:** SHA commit dokumentasi tidak boleh dipakai sebagai source APK. Source APK aktif selalu ditentukan dari build artifact dan commit source build yang sebenarnya.

---

# ATURAN KERJA

```
TRACE ACTUAL STATE
        ↓
COMPARE WITH CONTRACT
        ↓
IDENTIFY EXACT GAP
        ↓
MINIMAL FIX
        ↓
COMMIT + PUSH DEV
        ↓
DEPLOY
        ↓
CI GREEN
        ↓
DEVICE TEST
        ↓
DB + UI VERIFICATION
        ↓
CLOSE ONLY WITH EVIDENCE
```

Evidence historis harus dipertahankan.
APK frozen #194 tidak boleh diubah.
Tidak ada migration spekulatif.
Tidak boleh menghapus evidence regression secara manual.
GitHub DEV dan Supabase DEV harus tetap konsisten secara provenance.

## TINDAKAN BERIKUTNYA

**BUG-005 Conversation History — audit implementation terlebih dahulu, baru lakukan implementation jika memang ditemukan gap.**

---
