# SECOND HEAD — SESSION RESUME 68

## Melanjutkan dari SESSION RESUME 67


## Proyek
SECOND HEAD — SYSTEM BUILD

## Dasar audit

### Status APK — frozen baseline dan APK aktif
- **APK #194** adalah **frozen baseline saja** dan tetap immutable.
- **APK aktif untuk regression saat ini: #220**.
- Build #199 digunakan untuk pengujian BUG-004. APK #220 kemudian menjadi regression build terbaru setelah BUG-006.
- Workflow Android Build #199: run `33032370331`
- APK #220: manual build, installed and device-verified for BUG-006 — **success**.
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
- **APK regression terakhir yang digunakan untuk pengujian BUG-006: #220**
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

## Audit result

BUG-005 **memang memiliki gap implementation aktual**.

Pembedaan tetap:

### BUG-001
Short-term conversation context **inside the active conversation/runtime model context**.

### BUG-005
Persisted **Conversation History / navigasi dan continuity percakapan sebagai fitur produk**.

## Audit trace

### Persistence

`public.conversations` menyimpan persisted conversation rows dengan:

- `conversation_id`
- `account_id`
- `sh_id`
- `role`
- `content`
- `created_at`
- `metadata`

Runtime chat menulis melalui `runtime_record_conversation(...)`.

### Authenticated read

`runtime_load_conversation(p_limit)` menggunakan `resolve_identity()` dan membatasi hasil ke authenticated account + primary SH.

Current DEV privileges:

- authenticated: execute = TRUE
- anon: execute = FALSE
- direct authenticated table access ke `public.conversations`: tidak diberikan

### Loader

Implementation lineage Conversation History memang ada.

Namun active Chat implementation sebelumnya hanya memuat recent rows ke Chat screen.

Tidak ada product-level history navigation yang mengenumerasi persisted conversation groups dan membuka kembali group tertentu.

### Active conversation vs new conversation

Current Chat mempunyai local `New chat` clearing.

Tetapi tidak ada persisted conversation/session selector untuk membedakan dan membuka kembali conversation history sebagai daftar product-level.

Akibatnya persisted history ada di DB tetapi belum menjadi fitur navigasi yang lengkap.

### Account / SH isolation

DEV database menggunakan identity resolution untuk account + primary SH scoping.

Untuk `e2e_test@sh.com`:

- account: `047927de-576b-4df1-9d82-4a02f0d5a932`
- primary SH: `e9f3e857-df6b-479b-a5df-09563b118604`
- persisted conversation rows: 104

Dengan virtual-session boundary 3600 detik, data E2E saat ini membentuk 9 virtual conversation groups.

### Contract / UX

Architecture contract menempatkan ConversationState dan navigation pada App, sementara server state tetap authoritative.

Implementation Contract mempertahankan continuity/history dan menyatakan continuity gap tidak boleh disamarkan.

Actual gap: persisted history tersedia tetapi belum mempunyai navigable product surface.

## Minimal fix

Tidak dibuat migration baru.

Existing P4A-005 design memang menggunakan `conversations` persistence + computed virtual-session boundary dan tidak membutuhkan dedicated `sessions` table.

Perubahan DEV:

1. `d129d2a96e2c6d0a4354b12adea677ebe6d2300e`
   - expose authenticated persisted conversation history rows melalui App service.

2. `125baf05793e16194b82eea6bf5083a32859ad2b`
   - add `Conversation history` navigation;
   - group persisted rows memakai existing 3600-second virtual-session rule;
   - reopen selected persisted conversation group;
   - preserve local `New chat` empty behavior.

Evidence:
`docs/evidence/EV-BUG-005_CONVERSATION_HISTORY.md`

## Status

**🟢 CLOSED / PASS — DEVICE VERIFIED**

Acceptance selesai pada APK #202. Verified: Conversation History visible; persisted conversation dapat dibuka; content yang dipilih benar; New Chat tetap kosong; history dapat dibuka kembali setelah New Chat; persisted history tetap tersedia setelah force-close/reopen; account/SH isolation tetap benar.

Evidence: `docs/evidence/EV-BUG-005_CONVERSATION_HISTORY.md` — commit `f1529cf2cca3b7d5fcd2455ed4329c593406de8f`.

---

# BUG-006 — CHAT ACTIONS FUNCTIONALITY

## Cakupan

BUG-006 mencakup user-facing Chat actions pada conversation menu (⋮), message menu (⋮), serta attachment flow yang menjadi bagian dari Chat UX.

Scope berkembang selama audit menjadi dua kelompok:

- conversation/message actions;
- file, photo, dan camera attachment serta runtime processing.

## Audit / perbaikan

Gap yang ditemukan dan diperbaiki mencakup:

- Conversation History actions: rename, find/search, copy, share, export, delete.
- Message actions: copy, edit, delete, regenerate.
- Regenerate sebelumnya dapat menghasilkan duplicated/chunked response; diperbaiki agar membuat user prompt/assistant response baru.
- Required-choice/action dialogs tidak boleh dibypass dengan Android back; behavior diperbaiki dan diverifikasi.
- Attachment sebelumnya hanya terlihat di composer dan belum benar-benar ikut ke sent message/runtime.
- File/photo/camera attachment routing dan runtime processing diperbaiki.
- Photo/camera sebelumnya gagal karena MODEL_SELECTION_FAILED: no zero-budget model available for capability/task; failure tersebut tidak lagi terjadi pada regression final.

## Verification

APK #220 dibuat secara manual, di-install, dan diuji pada device.

PASS:

- Conversation history dapat dibuka.
- Rename conversation berfungsi.
- Find/search berfungsi.
- Copy berfungsi dan terverifikasi via copy/paste.
- Share berfungsi melalui native text sharing.
- Export berfungsi melalui native text export/share.
- Delete conversation menghapus conversation dari history.
- Message copy berfungsi.
- Message edit berfungsi.
- Message delete berfungsi.
- Regenerate berfungsi dan menghasilkan prompt/response baru tanpa duplicated streamed chunks.
- Android back pada required-choice/action dialogs berfungsi sesuai acceptance.
- File attachment berfungsi.
- Photo attachment berfungsi.
- Camera attachment berfungsi.
- Filename attachment tampil pada sent message.
- File content dapat diproses Runtime.
- Photo/camera image dapat diproses Runtime/model.
- Attachment conversation continuity/history berfungsi.
- Account/SH isolation terverifikasi; data attachment/conversation tidak muncul pada user lain.

Evidence: `docs/evidence/EV-BUG-006_CHAT_ACTIONS_FUNCTIONALITY.md` — commit `2b13e2babeda973ca561950a4b2a6984b196fc0f`.

## Status

**🟢 CLOSED / PASS — APK #220 DEVICE VERIFIED**

BUG-006 selesai. APK #220 menjadi regression APK aktif terbaru setelah digunakan untuk verifikasi.

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
CLOSED / PASS

        ↓
BUG-006
Chat Actions + Attachments
APK #220
        ↓
CLOSED / PASS
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

**BUG-001 → BUG-006: seluruh bug yang tercatat dalam Resume 68 telah selesai sesuai evidence masing-masing. BUG-005 ditutup dengan APK #202; BUG-006 ditutup dengan APK #220.**

---
