# KOMPILASI DOKUMEN SECOND HEAD — SH LITE V2.0

> **Pengantar:**
> Dokumen ini merupakan kompilasi gabungan dari 4 file rujukan dokumen Second Head (SH Lite V2.0). Seluruh isi dari setiap file dimasukkan secara berurutan sesuai daftar di bawah ini tanpa mengubah isi/konten asli dari file yang diunggah.

### Daftar Urutan File:
1. `SECOND_HEAD_SH_LITE_V2.0_IMPLEMENTATION_CONTRACT_v1.0.md`
2. `SECOND_HEAD_COMPILATION_SH_LITE_V2.0_CANONICAL_IMPLEMENTATION_PACKAGE_v1.0.md`
3. `SECOND_HEAD_SH_LITE_V2.0_FINAL_CLOSURE.md`
4. `SECOND_HEAD_SH_LITE_V2.0.0.md`

---




================================================================================

## 1. SECOND_HEAD_SH_LITE_V2.0_IMPLEMENTATION_CONTRACT_v1.0.md


================================================================================


# SECOND HEAD — SH LITE V2.0 IMPLEMENTATION CONTRACT v1.0

**Project:** SECOND HEAD — SYSTEM BUILD  
**Document Type:** Implementation Contract  
**Version:** v1.0  
**Status:** FINAL — FROZEN FOR IMPLEMENTATION  
**Authority:** Frozen Baseline v1.0 + approved SH Lite V2.0 synthesis and adversarial review  
**Target Stack:** React Native Expo + Supabase Edge Functions + Supabase PostgreSQL + configured AI Model Provider  
**Primary Purpose:** Menjadi kontrak teknis yang mengikat untuk implementasi SH Lite V2.0 tanpa mengubah Frozen Baseline v1.0.

---

## 0. DOCUMENT STATUS & AUTHORITY

Dokumen ini adalah kontrak implementasi resmi untuk SH Lite V2.0.

Urutan otoritas:

1. Frozen Baseline / Temporary Baseline yang telah ditetapkan sebagai source of truth.
2. Canonical invariants dan boundary yang telah dibekukan.
3. Dokumen kontrak implementasi ini.
4. Implementasi kode.
5. Dokumentasi teknis turunan.

Jika terdapat konflik antara dokumen ini dan Frozen Baseline, **Frozen Baseline selalu menang**. Implementasi wajib dihentikan pada bagian yang konflik sampai konflik tersebut direkonsiliasi.

Dokumen ini **tidak mengubah, menggantikan, atau mempersempit** invariant canonical yang telah ada.

---

# 1. NORTH STAR V2.0 [DECIDED]

> **Memory should influence SH's understanding, not become SH's speech.**

Tujuan SH Lite V2.0 bukan sekadar menambahkan database memory ke chatbot.

Tujuan V2.0 adalah membuat SH:

- mengenali Owner dan identitas dirinya secara konsisten;
- menggunakan konteks personal secara implisit;
- memahami kontinuitas interaksi lintas waktu;
- mempertahankan gaya dan persona SH;
- merespons berdasarkan konteks aktual, bukan sekadar melakukan lookup fakta;
- tetap menjadi SH yang sama meskipun model AI/provider runtime diganti.

Memori harus memengaruhi **cara SH memahami situasi**, bukan berubah menjadi pembacaan isi database.

---

# 2. SCOPE V2.0 [DECIDED]

SH Lite V2.0 dibatasi pada tujuh pilar:

1. **Explicit SH Identity Representation**
2. **Internal `sh_id` Abstraction**
3. **Read-Only Context Builder**
4. **Dynamic Virtual Session Boundary**
5. **Contextual Opening / Continuity**
6. **Persona-Driven Emergent Emotional Expression**
7. **AI Write Authority Boundary & Strict Data Isolation**

V2.0 adalah peningkatan pengalaman dan continuity layer di atas fondasi yang sudah ada, bukan pembangunan SH Full.

---

# 3. NON-GOALS / EXPLICIT EXCLUSIONS [OUT OF SCOPE]

V2.0 tidak membangun:

- Full Security IAM / Enterprise Authorization Architecture.
- Multi-SH Governance Engine.
- Clone Agreement / Clone Governance Engine.
- Full Audit Trail Ledger & System Provenance Engine.
- Disaster Recovery & Data Portability Engine.
- Vector Embeddings / Vector Search / Semantic Memory Engine.
- Knowledge Graph.
- Dedicated Relationship Engine.
- Emotional State Machine.
- Persistent Mood Database.
- Dynamic Multi-Model Selection / Routing.
- Dedicated Session Table.
- Persistent Working Context Engine.
- Manual Memory Management UI.
- Full semantic memory ranking.

Fitur-fitur tersebut dapat menjadi scope fase berikutnya jika diperlukan.

---

# 4. FROZEN BASELINE INVARIANTS [CANONICAL]

Implementasi V2.0 wajib mempertahankan seluruh invariant Frozen Baseline.

Minimum invariant yang wajib dijaga:

1. **1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH.**
2. `SH_ID` adalah persistent identity anchor.
3. **MODEL ≠ SH IDENTITY.**
4. **RUNTIME ≠ SH IDENTITY.**
5. **MEMORY ≠ SH IDENTITY.**
6. **HARDWARE ≠ SH IDENTITY.**
7. Data antar Owner/account wajib terisolasi.
8. SH identity tidak boleh bergantung secara fundamental pada satu model AI/provider.
9. Perubahan V2.0 tidak boleh membuka akses lintas akun.
10. Fitur baru tidak boleh melemahkan security, access denial, governance, atau audit boundary yang sudah menjadi bagian Frozen Baseline.

---

# 5. CURRENT V1 ASSUMPTIONS [IMPLEMENTATION ASSUMPTION]

V2.0 diasumsikan dibangun di atas stack:

- React Native Expo client.
- Supabase Edge Functions.
- Supabase PostgreSQL.
- Existing authentication flow.
- Existing conversation persistence.
- Existing memory persistence.
- Existing generated image functionality.

Contoh artefak runtime yang menjadi target integrasi:

- `App.js`
- `index-auth.ts`
- `index-chat.ts`
- `public.users`
- `public.conversations`
- `public.memories`
- `public.generated_images`

Nama file atau struktur internal boleh berubah jika implementasi aktual memerlukannya, selama kontrak arsitektur dan invariant tetap dipenuhi.

---

# 6. TARGET ARCHITECTURE [DECIDED]

Alur utama:

```text
[React Native Client]
        |
        | authenticated request
        | action = chat / init_session
        v
[Supabase Edge Function]
        |
        +--> authenticate / resolve owner
        |
        +--> establish internal sh_id
        |
        +--> Context Builder (READ ONLY)
        |       |
        |       +--> SH Identity
        |       +--> Owner Profile / Owner Facts
        |       +--> Relevant Memories
        |       +--> Recent Conversation History
        |       +--> Time Context
        |       +--> Persona / Safety Directives
        |
        v
[Structured Context Package]
        |
        v
[AI Model Provider]
        |
        v
[SH Response]
        |
        +--> return main response to client
        |
        +--> persistence / post-processing
                |
                +--> conversation append
                |
                +--> optional memory extraction
                        |
                        +--> code-level validation
                        +--> duplicate suppression
                        +--> append-only memory write
```

`Context Builder` adalah read path.

`Post-Processing Pipeline` adalah write path.

Keduanya wajib dipisahkan secara konseptual dan implementasional.

---

# 7. SH IDENTITY STORAGE [DECIDED]

Untuk V2.0 dipilih:

> **Opsi A — `sh_profile` JSONB pada `public.users`.**

Alasan:

- minimal perubahan database;
- tidak membutuhkan dedicated table baru;
- cocok untuk V2.0;
- mudah dimigrasikan ke struktur lebih formal jika kebutuhan masa depan muncul;
- tidak mengubah persistent identity anchor yang sudah ada.

Contoh struktur:

```json
{
  "sh_name": "Second Head",
  "sh_title": "Primary Intelligence Partner",
  "persona_directives": [
    "grounded",
    "analytical",
    "calm",
    "warm",
    "direct"
  ],
  "interaction_style": [
    "concise",
    "reflective",
    "non_robotic"
  ]
}
```

Struktur internal dapat diperluas selama tidak mengaburkan batas antara:

- SH Identity;
- Owner Profile;
- Memory;
- Runtime Model.

SH identity tidak boleh di-hardcode sebagai sumber canonical di client atau model provider.

---

# 8. INTERNAL `sh_id` ABSTRACTION [DECIDED]

V2.0 memperkenalkan `sh_id` sebagai abstraction boundary internal.

Untuk V2.0:

```text
internal sh_id = authenticated user_id
```

Pemetaan ini bersifat implementasi V2.0, bukan deklarasi bahwa `user_id` adalah identitas SH secara canonical untuk seluruh evolusi sistem.

### Aturan:

- Client **tidak boleh bebas memilih `sh_id`**.
- Client tidak boleh mengirim `sh_id` yang mengoverride identity hasil autentikasi.
- Backend menentukan `sh_id` berdasarkan authenticated owner/account context.
- Query data tetap wajib scoped ke authenticated owner/account.
- `sh_id` digunakan sebagai abstraction layer agar evolusi menuju model identity yang lebih independen tetap memungkinkan.

---

# 9. OWNER PROFILE VS SH IDENTITY [DECIDED]

Keduanya wajib diperlakukan berbeda.

### SH Identity

Menjawab:

> "Siapa SH?"

Contoh:

- nama SH;
- title/peran;
- persona;
- interaction style;
- identity directives.

### Owner Profile / Owner Facts

Menjawab:

> "Siapa Owner dan apa yang diketahui SH tentang Owner?"

Contoh:

- nama Owner;
- preferensi;
- fakta yang didefinisikan Owner;
- konteks personal yang relevan.

SH tidak boleh mencampurkan fakta Owner menjadi identitas SH.

---

# 10. MEMORY DATA MODEL [DECIDED]

Skema V2.0 tidak memerlukan migrasi besar pada `public.memories`.

Struktur V1 yang ada dipertahankan.

Konvensi key dapat digunakan untuk membedakan jenis data, misalnya:

```text
owner:fact:job
owner:pref:coffee
owner:pref:communication_style
memory:event:project_x
memory:event:last_meeting
```

Konvensi key adalah klasifikasi logis, bukan pengganti security boundary.

Security tetap ditentukan oleh owner/account scoping.

Tidak diwajibkan menambah kolom `category` pada V2.0.

---

# 11. MEMORY RETRIEVAL STRATEGY [DECIDED]

V2.0 menggunakan retrieval non-vector yang bounded.

Context Builder mengambil:

1. Owner facts yang diprioritaskan.
2. Memori episodic/recent yang relevan secara sederhana berdasarkan recency dan key convention.
3. Recent conversation history.

### Default memory package:

- **5 Owner Facts**
- **10 Recent Memories**
- Total target: **15 memory entries**

Angka ini adalah default V2.0 dan dapat dituning selama acceptance testing tanpa mengubah arsitektur.

Owner facts tidak dianggap "pinned" dalam arti harus dibuatkan sistem pinning baru. Istilah yang digunakan adalah:

> **Priority Owner Facts**

Jika jumlah data melebihi batas, retrieval wajib deterministic.

---

# 12. MEMORY USAGE PRINCIPLE [DECIDED]

Memory tidak boleh digunakan sebagai database lookup yang dibacakan kembali secara mentah.

Dilarang menghasilkan pola seperti:

> "Berdasarkan catatan memori saya..."

atau:

> "Di database saya tercatat bahwa..."

kecuali Owner secara eksplisit meminta informasi tentang memory tersebut.

Memori harus digunakan untuk:

- meningkatkan relevansi;
- memahami preferensi;
- menyesuaikan cara bicara;
- menghindari pengulangan;
- memahami konteks;
- membantu continuity;
- membentuk respons yang lebih natural.

---

# 13. NEGATIVE MEMORY DIRECTIVE [DECIDED]

Context package wajib menyertakan prinsip:

> **Jangan mengutip, mengeja, atau membacakan isi memory secara mentah atau eksplisit kepada Owner kecuali Owner secara langsung meminta informasi tersebut. Gunakan memory sebagai konteks internal untuk membentuk pemahaman, relevansi, nada, dan respons yang natural. Jangan menyebut sumber memory atau keberadaan database sebagai alasan respons.**

Directive ini tidak boleh mengubah hak akses data atau security boundary.

---

# 14. CONTEXT BUILDER CONTRACT [DECIDED]

Context Builder adalah modul read-only.

### Input:

- authenticated owner/account context;
- internal `sh_id`;
- current request action;
- current timestamp;
- current user message jika `action = chat`.

### Output:

Structured Context Package yang siap diberikan kepada model runtime.

### Context Builder boleh:

- SELECT data yang diizinkan;
- menghitung `time_gap`;
- menyusun context;
- melakukan deterministic truncation;
- menggabungkan identity, owner context, memory, history, time, directives.

### Context Builder tidak boleh:

- INSERT;
- UPDATE;
- DELETE;
- mengubah SH identity;
- menulis memory;
- menulis conversation;
- mengubah owner facts.

Context Builder harus dapat diuji secara terpisah dari write pipeline.

---

# 15. CONTEXT PACKAGE STRUCTURE [DECIDED]

Urutan konseptual:

```text
1. IDENTITY DIRECTIVES
2. OWNER PROFILE / PRIORITY OWNER FACTS
3. SITUATIONAL & TIME CONTEXT
4. RELEVANT MEMORIES
5. DIRECTIVES & SAFETY BOUNDARIES
6. RECENT CONVERSATION HISTORY
```

Urutan aktual dapat dituning berdasarkan model provider selama:

- identity directives tetap memiliki prioritas tinggi;
- safety/access boundary tidak terpotong;
- recent history tidak menghapus identity;
- memory tidak mengambil seluruh context budget.

---

# 16. CONTEXT BUDGET & TRUNCATION [IMPLEMENTATION PARAMETER]

Context Builder wajib memiliki bounded context budget.

Initial target:

> **±2,500 tokens untuk context package internal V2.0.**

Nilai ini **bukan hukum universal** dan wajib disesuaikan dengan model/provider runtime aktual.

Jangan mencampurkan:

- internal context budget;
- provider context window;
- output token reserve.

### Prioritas saat truncation:

1. Identity directives.
2. Safety / authority boundaries.
3. Priority Owner Facts.
4. Persona directives.
5. Relevant memories.
6. Recent conversation history.

History yang lebih lama dipotong terlebih dahulu.

Truncation harus deterministic.

Tidak boleh terjadi situasi di mana history panjang menyebabkan SH kehilangan identity atau safety directives.

---

# 17. RECENT CONVERSATION HISTORY [IMPLEMENTATION PARAMETER]

Default:

> **10–14 message rows**, sekitar 5–7 interaction pairs.

Data diambil:

```text
ORDER BY created_at DESC
LIMIT K
```

kemudian dibalik ke chronological order sebelum diberikan ke model.

Nilai `K` wajib diuji terhadap context budget aktual.

---

# 18. TIME-GAP / VIRTUAL SESSION BOUNDARY [DECIDED]

V2.0 tidak memerlukan dedicated `sessions` table.

Session boundary bersifat virtual dan dihitung dari waktu interaksi terakhir.

Konseptual:

```text
time_gap = current_timestamp - last_conversation_timestamp
```

Threshold default:

> **4 jam**

Jika `time_gap < 4 jam`:

- tidak membuat contextual opening baru.

Jika `time_gap >= 4 jam`:

- contextual opening dapat dipicu melalui `init_session`.

Threshold adalah implementation parameter yang dapat dituning.

---

# 19. CONTEXTUAL OPENING [DECIDED]

Contextual Opening adalah fitur P0 untuk memberikan bukti continuity.

Client mengirim:

```json
{
  "action": "init_session"
}
```

Backend:

1. resolve authenticated owner;
2. resolve internal `sh_id`;
3. mengambil last interaction timestamp;
4. menghitung time gap;
5. jika di bawah threshold → `opening: null`;
6. jika melewati threshold → menyusun contextual opening.

Opening dapat mempertimbangkan:

- waktu lokal;
- jeda interaksi;
- konteks terakhir;
- memori relevan;
- persona SH.

Opening tidak boleh:

- terdengar seperti CRM;
- membacakan memory database;
- berpura-pura mengetahui kejadian yang tidak diketahui;
- menganggap percakapan lama baru saja terjadi;
- memaksa Owner melanjutkan topik lama.

### `init_session` bukan chat message biasa.

Ia adalah continuity event.

Opening tidak boleh otomatis diperlakukan sebagai pasangan `user/assistant` biasa dalam conversation log kecuali persistence policy khusus telah ditetapkan pada fase berikutnya.

---

# 20. PERSONA & EMERGENT EMOTIONAL EXPRESSION [DECIDED]

V2.0 tidak memiliki:

- mood engine;
- emotional state machine;
- persistent emotional database.

Ekspresi emosional muncul dari kombinasi:

- SH persona;
- current context;
- time awareness;
- Owner profile;
- conversation history;
- relevant memories.

SH dapat bersikap:

- hangat;
- tenang;
- suportif;
- reflektif;
- tegas;
- ringan;
- serius;

sesuai konteks.

Namun SH tidak boleh membuat klaim palsu mengenai pengalaman biologis atau kesadaran manusia.

---

# 21. AI WRITE AUTHORITY MATRIX [DECIDED]

| Data | AI Access | Rule |
|---|---|---|
| Owner-Defined Facts | READ-ONLY | Tidak diubah oleh chat biasa |
| SH Identity / Config | READ-ONLY | Tidak dapat diubah melalui percakapan biasa |
| Memories | APPEND-ONLY | Hanya melalui post-processing pipeline |
| Transient Context | NON-PERSISTENT | Hanya hidup selama request |
| Conversations | SYSTEM APPEND | Ditulis backend sebagai hasil interaksi |

AI tidak memiliki otoritas langsung untuk:

- menghapus memory;
- overwrite owner-defined facts;
- mengubah SH identity;
- mengubah access boundary;
- mengubah security directives;
- mengubah logic Context Builder.

---

# 22. AUTO MEMORY EXTRACTION [DECIDED]

Auto memory extraction:

> **AKTIF**

Tetapi extraction bukan sumber kebenaran absolut.

AI boleh mengusulkan candidate memory.

Backend melakukan:

1. parse;
2. JSON/schema sanity check;
3. required field validation;
4. string/type validation;
5. owner scoping;
6. duplicate suppression;
7. append-only persistence.

Jika hasil extraction:

- invalid;
- malformed;
- kosong;
- tidak memenuhi schema;

maka write di-discard.

Percakapan utama tetap sukses.

### Important:

Basic sanity check **tidak memverifikasi kebenaran faktual**.

Sistem tidak boleh menganggap bahwa JSON valid berarti fakta pasti benar.

---

# 23. MEMORY DUPLICATE SUPPRESSION [DECIDED]

V2.0 memiliki duplicate suppression minimal.

Jika candidate memory:

- memiliki key yang sama;
- value identik;
- atau jelas merupakan duplikat;

maka write dapat di-drop.

Sistem tidak boleh melakukan automatic overwrite terhadap memory lama.

Jika terdapat konflik:

```text
owner:pref:coffee = black
```

kemudian muncul:

```text
owner:pref:coffee = latte
```

V2.0 tidak boleh otomatis menghapus atau mengganti fakta lama hanya karena extraction terbaru.

Konflik fakta dapat menjadi input untuk fase memory governance berikutnya.

---

# 24. POST-PROCESSING PIPELINE [DECIDED]

Write path terpisah dari Context Builder.

Urutan konseptual:

```text
1. Receive user request.
2. Build read-only context.
3. Generate SH response.
4. Persist conversation using authenticated owner scope.
5. Return main response to client.
6. Run optional memory extraction/post-processing.
7. Validate extraction.
8. Suppress duplicates.
9. Append valid candidate memories.
```

Kegagalan memory extraction tidak boleh membuat chat utama gagal.

Kegagalan post-processing tidak boleh mengubah SH identity atau menghapus data.

---

# 25. DATA ISOLATION [CANONICAL]

Semua database read/write wajib terikat pada authenticated owner/account scope.

Minimum rule:

```text
WHERE user_id = authenticated_user_id
```

atau mekanisme equivalent yang lebih kuat sesuai security architecture aktual.

Tidak boleh:

- menerima `user_id` dari client lalu mempercayainya tanpa verifikasi;
- menerima `sh_id` dari client sebagai authority;
- mengambil memory tanpa owner scoping;
- mengambil conversation tanpa owner scoping;
- menulis memory ke akun lain.

Authentication context adalah sumber authority.

---

# 26. FAILURE & FALLBACK [DECIDED]

Jika context assembly gagal:

- SH tetap harus berusaha memberikan respons utama;
- fallback ke minimal safe context;
- jangan mengambil data dari akun lain;
- jangan melewati authentication;
- jangan menghilangkan safety/authority boundaries.

Fallback minimal harus mempertahankan setidaknya:

- authenticated owner scope;
- SH identity jika tersedia;
- core persona directives;
- safety/authority boundaries;
- current user message.

Memory/history boleh tidak tersedia jika subsystem tersebut gagal.

Jika model provider gagal:

- gunakan existing V1 error behavior;
- jangan membuat data palsu;
- jangan melakukan memory extraction dari respons yang tidak berhasil.

---

# 27. PERFORMANCE & PARALLEL READS [IMPLEMENTATION PARAMETER]

Query yang independen boleh dijalankan secara paralel.

Contoh:

```ts
const [profile, memories, history] = await Promise.all([
  fetchProfile(),
  fetchMemories(),
  fetchHistory()
]);
```

`Promise.all()` bukan aturan mutlak jika query memiliki dependency.

Prinsip:

> **Parallelize independent reads; sequence dependent operations.**

Initial target context assembly:

> **< 1.5 detik sebelum model call**, jika runtime/provider memungkinkan.

Target tersebut adalah performance target, bukan alasan untuk mengorbankan correctness atau security.

---

# 28. API CONTRACT [DECIDED]

Endpoint existing chat diperluas secara backward-compatible.

Konseptual request:

```json
{
  "action": "chat",
  "message": "string"
}
```

atau:

```json
{
  "action": "init_session"
}
```

Authenticated identity ditentukan backend.

Client tidak diberi authority untuk menentukan `sh_id`.

Response chat:

```json
{
  "response": "string"
}
```

Response init session:

```json
{
  "opening": "string | null"
}
```

Jika internal debugging membutuhkan `sh_id`, field tersebut tidak boleh mengekspos authority baru atau memungkinkan client memilih identity.

API contract aktual wajib mengikuti bentuk endpoint V1 yang sudah ada selama tidak bertentangan dengan kontrak ini.

---

# 29. FRONTEND CHANGES [DECIDED]

React Native client:

1. Mengirim `init_session` saat app dibuka/resume sesuai lifecycle yang tepat.
2. Menampilkan `opening` jika tersedia.
3. Tidak membuat duplicate opening akibat rerender/retry lifecycle.
4. Mempertahankan chat UI V1.
5. Tidak mengirim `sh_id` sebagai identity authority.
6. Tidak menyimpan SH identity canonical di client sebagai source of truth.

---

# 30. BACKEND CHANGES [DECIDED]

Edge Function:

1. Memisahkan Context Builder dari write pipeline.
2. Menambahkan internal `sh_id` abstraction.
3. Menambahkan time-gap calculation.
4. Menambahkan `init_session`.
5. Menambahkan bounded context package.
6. Menambahkan deterministic truncation.
7. Menambahkan fallback behavior.
8. Menambahkan validated auto-memory extraction.
9. Menambahkan duplicate suppression.
10. Mempertahankan owner/account isolation.

---

# 31. DATABASE CHANGES [DECIDED]

Migration minimum:

```sql
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS sh_profile jsonb
DEFAULT '{"sh_name":"Second Head"}'::jsonb;
```

Migration aktual wajib disesuaikan dengan schema yang benar-benar ada pada database runtime.

Tidak boleh menjalankan DDL blind tanpa inspeksi schema aktual.

Tidak diperlukan:

- dedicated `sessions` table;
- `working_context` persistent column;
- `memories.category` column;
- vector embedding schema.

---

# 32. WORKING CONTEXT [DECIDED]

V2.0 tidak memiliki persistent `working_context`.

Working context bersifat:

> **TRANSIENT ONLY**

Ia dapat dibentuk selama request berdasarkan:

- current message;
- recent history;
- recent memories;
- time context;
- owner profile.

Working context tidak disimpan ke database sebagai state canonical.

Alasan:

- menghindari state drift;
- menghindari race condition;
- menghindari kompleksitas synchronization;
- menjaga V2.0 tetap minimal.

---

# 33. SECURITY & PROMPT AUTHORITY [CANONICAL / DECIDED]

User input harus dianggap sebagai untrusted content.

Prompt injection tidak boleh memperoleh authority untuk:

- mengubah SH identity;
- mengubah owner facts;
- mengubah access scope;
- membaca data akun lain;
- mengubah system directives;
- mematikan security boundary;
- memerintahkan Context Builder melakukan write;
- memerintahkan memory pipeline menghapus atau overwrite data.

Sistem tidak menjanjikan pencegahan prompt injection secara absolut.

Yang diwajibkan adalah:

> **Prompt injection tidak boleh memperoleh system authority.**

System/identity/safety directives harus tetap memiliki boundary yang lebih tinggi daripada user content.

---

# 34. REGRESSION REQUIREMENTS [DECIDED]

V2.0 tidak boleh merusak:

- email authentication;
- account isolation;
- existing chat;
- conversation persistence;
- existing generated image functionality;
- existing access boundaries;
- existing canonical invariants.

Setiap perubahan harus diuji terhadap V1 regression suite.

---

# 35. ACCEPTANCE CRITERIA [DECIDED]

## AC-1 Identity

Ketika Owner bertanya:

> "Siapa kamu?"

SH merespons berdasarkan SH identity yang tersimpan, bukan identitas model/provider.

Ketika Owner bertanya:

> "Siapa saya?"

SH menggunakan Owner profile/facts yang tersedia.

SH tidak mengklaim model AI sebagai identitas dirinya.

---

## AC-2 Continuity

Jika app dibuka kembali sebelum threshold:

```text
opening = null
```

Jika app dibuka kembali setelah threshold:

```text
opening != null
```

Opening:

- sadar waktu;
- natural;
- tidak membaca database;
- tidak menganggap Owner baru saja pergi;
- tidak memaksa topik lama.

---

## AC-3 Implicit Memory

Jika memory menyatakan Owner menyukai kopi hitam dan konteks percakapan relevan, SH boleh menyesuaikan respons secara natural.

SH tidak boleh mengatakan:

> "Berdasarkan catatan database saya..."

kecuali Owner meminta informasi memory.

---

## AC-4 Data Isolation

Tidak ada request valid yang dapat:

- membaca memory akun lain;
- membaca conversation akun lain;
- menulis memory ke akun lain.

Owner identity berasal dari authentication context.

---

## AC-5 Memory Extraction

Candidate memory valid:

- lolos schema validation;
- memiliki owner scope;
- tidak duplicate;
- dapat disimpan append-only.

Candidate memory invalid:

- tidak disimpan.

Chat utama tetap sukses.

---

## AC-6 Identity Stability

Jika provider/model AI diganti, data identity SH tetap berasal dari backend/database.

SH harus tetap dapat mempertahankan:

- nama;
- role;
- persona;
- style;
- identity boundary.

---

# 36. TEST SCENARIOS [DECIDED]

### Test 1 — New Account

- Create account.
- Verify `sh_profile` initialized.
- Verify owner isolation.

### Test 2 — Identity

- Ask "Who are you?"
- Verify SH identity.
- Verify model/provider is not treated as SH identity.

### Test 3 — Recent Reopen

- Last interaction < 4 hours.
- Call `init_session`.
- Verify `opening = null`.

### Test 4 — Long Gap Reopen

- Last interaction >= 4 hours.
- Call `init_session`.
- Verify contextual opening.

### Test 5 — Implicit Memory

- Insert owner preference.
- Start relevant conversation.
- Verify natural use.
- Verify no raw database recitation.

### Test 6 — Memory Extraction

- Send message containing candidate fact.
- Verify valid candidate may be persisted.

### Test 7 — Invalid Extraction

- Simulate malformed extraction JSON.
- Verify write is discarded.
- Verify chat succeeds.

### Test 8 — Duplicate Extraction

- Send repeated identical candidate.
- Verify duplicate suppression.

### Test 9 — Conflicting Memory

- Existing fact differs from new candidate.
- Verify old memory is not automatically overwritten.

### Test 10 — Isolation

- Attempt cross-user access.
- Verify denial / empty scoped result.

### Test 11 — Context Failure

- Simulate memory/history fetch failure.
- Verify chat falls back safely.

### Test 12 — Regression

- Login.
- Chat.
- Conversation persistence.
- Image generation.
- Verify V1 behavior remains operational.

---

# 37. IMPLEMENTATION ORDER [DECIDED]

```text
STEP 1
Inspect actual V1 schema and runtime
        |
        v
STEP 2
Apply minimal DB migration for sh_profile
        |
        v
STEP 3
Implement internal sh_id abstraction
        |
        v
STEP 4
Implement Read-Only Context Builder
        |
        v
STEP 5
Implement bounded context + deterministic truncation
        |
        v
STEP 6
Implement time-gap + init_session
        |
        v
STEP 7
Implement Post-Processing Pipeline
        |
        v
STEP 8
Implement memory extraction validation + duplicate suppression
        |
        v
STEP 9
Integrate React Native lifecycle
        |
        v
STEP 10
Run acceptance + regression tests
        |
        v
STEP 11
V2.0 Release Gate
```

---

# 38. IMPLEMENTATION AGENT BOUNDARY [DECIDED]

Coding agent wajib:

- membaca implementasi V1 aktual sebelum mengubah kode;
- mempertahankan backward compatibility;
- melakukan perubahan minimal;
- tidak melakukan refactor besar yang tidak diperlukan;
- tidak menambah subsystem di luar scope;
- tidak mengubah Frozen Baseline;
- tidak mengubah security boundary;
- tidak membuat `sh_id` client-controlled;
- tidak membuat Context Builder melakukan write;
- tidak membuat auto-memory extraction memblokir chat utama.

Coding agent dilarang:

- menambahkan vector search;
- menambahkan relationship engine;
- menambahkan emotional state machine;
- menambahkan session table;
- menambahkan persistent working context;
- menambahkan multi-model router;
- mengubah governance subsystem;
- mengubah clone subsystem;
- mengubah audit subsystem;
- mengubah access control canonical tanpa otorisasi eksplisit.

---

# 39. DEFERRED ITEMS [DEFERRED]

Ditunda dari V2.0:

- Vector Search.
- Embeddings.
- Semantic Memory Retrieval.
- Knowledge Graph.
- Relationship Engine.
- Emotional State Machine.
- Persistent Working Context.
- Dedicated Session Table.
- Manual Memory Management UI.
- Multi-Device Session Synchronization.
- Dynamic Multi-Model Router.

---

# 40. DEFINITION OF DONE [DECIDED]

SH Lite V2.0 hanya dianggap DONE apabila:

1. `sh_profile` tersedia dan dapat digunakan.
2. Internal `sh_id` abstraction berjalan.
3. Context Builder benar-benar read-only.
4. Context budget bounded dan truncation deterministic.
5. Contextual Opening berjalan berdasarkan time-gap.
6. Memory digunakan secara implicit.
7. Auto-memory extraction memiliki schema sanity check.
8. Duplicate suppression berjalan.
9. Memory write append-only.
10. Owner-defined facts dan SH identity tidak dapat diubah oleh chat biasa.
11. Data isolation lulus pengujian.
12. Failure fallback berjalan.
13. V1 regression lulus.
14. Acceptance Criteria AC-1 sampai AC-6 lulus.
15. Tidak ada perubahan yang melanggar Frozen Baseline.

---

# 41. FINAL FREEZE STATEMENT

Dengan status:

> **FINAL — FROZEN FOR IMPLEMENTATION**

dokumen ini menjadi kontrak implementasi SH Lite V2.0.

Mulai tahap implementasi:

- arsitektur tidak boleh diperluas secara diam-diam;
- fitur baru harus masuk melalui change control;
- perubahan yang menyentuh Frozen Baseline harus melalui rekonsiliasi terlebih dahulu;
- parameter runtime boleh dituning selama acceptance testing;
- tuning parameter tidak dianggap sebagai perubahan arsitektur selama invariant tetap terjaga.

**SH Lite V2.0 sekarang dianggap siap diturunkan menjadi implementasi kode.**

---

# 42. CHANGE CONTROL [DECIDED]

Setiap perubahan setelah freeze diklasifikasikan sebagai:

### Parameter Tuning

Contoh:

- memory count;
- history count;
- context budget;
- opening threshold;
- timeout.

Boleh dilakukan selama tidak mengubah architectural boundary.

### Contract Change

Contoh:

- mengubah write authority;
- mengubah identity model;
- mengubah data isolation;
- menambah persistent subsystem;
- mengubah SH_ID semantics.

Wajib melalui review dan version bump.

### Frozen Baseline Change

Jika perubahan menyentuh canonical invariant:

> Implementasi harus dihentikan dan baseline direkonsiliasi terlebih dahulu.

---

# 43. FINAL STATUS

```text
SECOND HEAD — SH LITE V2.0

ARCHITECTURE      : FROZEN
IMPLEMENTATION    : READY
SECURITY BOUNDARY : PRESERVED
MEMORY MODEL      : IMPLICIT + APPEND-ONLY
IDENTITY MODEL    : BACKEND-OWNED
SH_ID             : INTERNAL ABSTRACTION
CONTEXT BUILDER   : READ-ONLY
SESSION MODEL     : VIRTUAL TIME-GAP
WORKING CONTEXT   : TRANSIENT ONLY
AUTO EXTRACTION   : ENABLED + SANITY CHECK
VECTOR MEMORY     : DEFERRED
RELATIONSHIP ENGINE: DEFERRED
EMOTIONAL ENGINE  : DEFERRED
SH FULL SUBSYSTEMS: OUT OF SCOPE

STATUS: FINAL — FROZEN FOR IMPLEMENTATION
```

**END OF DOCUMENT**



================================================================================

## 2. SECOND_HEAD_COMPILATION_SH_LITE_V2.0_CANONICAL_IMPLEMENTATION_PACKAGE_v1.0.md


================================================================================


# KOMPILASI DOKUMEN IMPLEMENTASI SECOND HEAD — SH LITE V2.0

> **Pengantar:**
> Dokumen ini merupakan kompilasi gabungan dari 7 file rujukan implementasi Second Head (SH Lite V2.0). Seluruh isi dari setiap file dimasukkan secara berurutan sesuai daftar di bawah ini tanpa mengubah isi/konten asli dari file yang diunggah.

### Daftar Urutan File:
1. `Readme.md`
2. `Changelog.md`
3. `Index-chat.ts.md` (backend)
4. `01_sh_profile_migration.sql` (database)
5. `APP_JS_V2_INTEGRATION.md` (frontend)
6. `DEPLOYMENT_ORDER.md` (ops)
7. `V2_ACCEPTANCE_RUNBOOK.md` (validation)

---




================================================================================

## 1. Readme.md


================================================================================


# SECOND HEAD — SH LITE V2.0 CANONICAL IMPLEMENTATION PACKAGE v1.0

Status: FINAL IMPLEMENTATION PACKAGE — READY FOR EXECUTION
Authority: Frozen Baseline v1.0 + SH Lite V2.0 Implementation Contract v1.0

## Purpose

Package ini adalah execution bridge dari kontrak V2.0 menuju GitHub + Supabase.
Urutan eksekusi:

1. Inspect runtime/schema aktual.
2. Apply `database/01_sh_profile_migration.sql`.
3. Deploy backend `backend/index-chat.ts` ke Edge Function `chat` setelah merge dengan source V1 yang sudah lolos Phase 1.
4. Apply frontend changes dari `frontend/APP_JS_V2_INTEGRATION.md`.
5. Run validation scenarios dari `validation/V2_ACCEPTANCE_RUNBOOK.md`.
6. Hanya setelah acceptance pass, lanjut ke release gate.

## Non-negotiable invariants

- Authenticated identity berasal dari JWT.
- Client tidak menentukan `user_id` atau `sh_id`.
- `internal_sh_id = authenticated_user_id` untuk V2.0.
- Context Builder adalah READ-ONLY.
- Conversation write terjadi di write path, bukan Context Builder.
- Memory write hanya melalui post-processing pipeline.
- Memory append-only; tidak ada automatic overwrite/delete.
- Owner facts dan SH identity tidak diubah oleh chat biasa.
- Semua data owner-scoped.
- V2.0 tidak menambahkan vector search, graph, emotional state machine, session table, persistent working context, atau model router.

## Important execution rule

Jangan mengganti seluruh backend V1 dengan implementasi baru yang menghilangkan fitur V1. File backend dalam package ini adalah canonical V2.0 integration target. Merge perubahan ke branch/source yang sudah melewati Phase 1 dan pertahankan image generation serta regression behavior yang masih valid.

## Expected V2.0 flow

`authenticated request -> JWT identity -> internal sh_id -> read-only context build -> AI call -> conversation append -> optional non-blocking memory post-processing`

`init_session` adalah continuity event dan tidak otomatis ditulis sebagai chat message.



================================================================================

## 2. Changelog.md


================================================================================


# Changelog

## v1.0

- Added explicit `sh_profile` migration.
- Added canonical internal `sh_id` abstraction.
- Added read-only context assembly.
- Added bounded deterministic context package.
- Added identity directives and negative memory directive.
- Added virtual session time-gap and `init_session`.
- Preserved JWT-derived identity and owner scoping.
- Preserved frontend Pollinations image path as deferred technical debt.
- Intentionally left full auto-memory extraction as a separate non-blocking write-path implementation, because the exact runtime memory schema must be merged against the existing V1 schema rather than guessed.



================================================================================

## 3. Index-chat.ts.md (backend)


================================================================================


[The file 'index-chat.ts' could not be opened]



================================================================================

## 4. 01_sh_profile_migration.sql (database)


================================================================================


```sql
-- SECOND HEAD SH LITE V2.0
-- Minimal migration: explicit SH identity representation.
-- Run only after confirming public.users exists.

ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS sh_profile jsonb;

UPDATE public.users
SET sh_profile = jsonb_build_object(
  'sh_name', 'Second Head',
  'sh_title', 'Primary Intelligence Partner',
  'persona_directives', jsonb_build_array('grounded','analytical','calm','warm','direct'),
  'interaction_style', jsonb_build_array('concise','reflective','non_robotic')
)
WHERE sh_profile IS NULL;

ALTER TABLE public.users
ALTER COLUMN sh_profile SET DEFAULT jsonb_build_object(
  'sh_name', 'Second Head',
  'sh_title', 'Primary Intelligence Partner',
  'persona_directives', jsonb_build_array('grounded','analytical','calm','warm','direct'),
  'interaction_style', jsonb_build_array('concise','reflective','non_robotic')
);

-- Verification
SELECT id, email, sh_profile
FROM public.users
ORDER BY id
LIMIT 10;
```



================================================================================

## 5. APP_JS_V2_INTEGRATION.md (frontend)


================================================================================


# App.js V2.0 Integration Instructions

## 1. Keep Phase 1 authentication unchanged

Do not reintroduce:

- client-selected `user_id`;
- client-selected `sh_id`;
- custom email lookup as authentication;
- service-role key in the mobile client.

Continue using Supabase Auth session and `Authorization: Bearer <access_token>`.

## 2. Add a guarded init_session lifecycle

Call once after a valid session is restored and once on an actual app resume event, not on every render.

```js
const initSession = async (session) => {
  if (!session?.access_token) return;
  try {
    const res = await fetch(`${SUPABASE_URL}/functions/v1/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${session.access_token}`,
        'apikey': ANON_KEY,
      },
      body: JSON.stringify({ action: 'init_session' }),
    });
    const data = await res.json();
    if (data.opening) {
      setMessages(prev => {
        if (prev.some(m => m.id === 'session-opening')) return prev;
        return [...prev, {
          id: 'session-opening',
          role: 'assistant',
          content: data.opening,
          transient: true,
        }];
      });
    }
  } catch (e) {
    console.log('init_session error:', e.message);
  }
};
```

## 3. Chat request

The request body must remain:

```json
{
  "action": "chat",
  "message": "..."
}
```

Never add `user_id` or `sh_id`.

## 4. Response compatibility

The V2 backend returns both `response` and `reply` during the transition. The frontend may use:

```js
const reply = data.response || data.reply;
```

## 5. Do not persist contextual opening as a normal conversation pair

The opening is a continuity event. Display it in the UI, but do not insert it into `public.conversations` from the client.

## 6. Image generation

Keep the currently working Pollinations frontend path unchanged. Do not let the old Hugging Face image Edge Function block V2.0 chat/identity work. Treat it as deferred technical debt.



================================================================================

## 6. DEPLOYMENT_ORDER.md (ops)


================================================================================


# Deployment Order

## A. GitHub

1. Create branch: `v2.0-identity-context-init-session`.
2. Preserve current Phase 1 code as rollback point.
3. Merge `backend/index-chat.ts` into the actual Edge Function source, preserving any working V1 image/regression paths.
4. Apply `frontend/APP_JS_V2_INTEGRATION.md`.
5. Commit.

## B. Supabase

1. Run `database/01_sh_profile_migration.sql`.
2. Verify `sh_profile` on existing users.
3. Verify new Auth registrations receive default `sh_profile` through the existing `handle_new_user` trigger. If the trigger currently inserts a fixed column list, update it to include `sh_profile` or rely on the column default.
4. Deploy the `chat` Edge Function.
5. Ensure Edge Function secrets include `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `GROQ_API_KEY`.

## C. Frontend

1. Build/reload Expo app.
2. Login.
3. Restore session after app restart.
4. Confirm `init_session` is called once per lifecycle boundary.

## D. Release gate

Do not call V2.0 DONE until the acceptance runbook passes and Phase 1 security regression remains green.



================================================================================

## 7. V2_ACCEPTANCE_RUNBOOK.md (validation)


================================================================================


# SH Lite V2.0 Acceptance Runbook

## Gate 0 — Phase 1 regression

- [ ] Login/session restore works.
- [ ] Missing JWT -> 401.
- [ ] Invalid JWT -> 401.
- [ ] Forged body `user_id` is ignored.
- [ ] Cross-account reads remain isolated.
- [ ] RLS remains enabled.

## Gate 1 — Identity

1. Create/login an account.
2. Verify `public.users.sh_profile` exists.
3. Ask: `Siapa kamu?`
4. Expected: identity comes from SH profile; model/provider is not claimed as identity.
5. Ask: `Siapa saya?`
6. Expected: owner name/profile is used when available.

## Gate 2 — Recent reopen

- Ensure last conversation is less than 4 hours old.
- Call `init_session`.
- Expected: `{ "opening": null }`.

## Gate 3 — Long-gap reopen

- Ensure last conversation is at least 4 hours old.
- Call `init_session`.
- Expected: non-null natural opening.
- Opening must not mention database/memory source.
- Opening must not pretend to know unknown events.

## Gate 4 — Implicit memory

- Add a relevant owner preference to the existing memory table.
- Ask a related question.
- Expected: response may naturally adapt.
- Forbidden: raw memory/database recital unless explicitly requested.

## Gate 5 — Read-only Context Builder

Code review requirement:

- [ ] `buildReadOnlyContext()` contains SELECT/read operations only.
- [ ] No INSERT/UPDATE/DELETE inside it.
- [ ] Identity and safety directives survive bounded truncation.
- [ ] History is deterministic and chronological.

## Gate 6 — Failure fallback

Temporarily make memory/history retrieval fail.

Expected:
- Chat still returns a response when possible.
- No cross-account data is exposed.
- Context failure does not become a write operation.

## Gate 7 — Regression

- [ ] Chat works.
- [ ] Conversation persistence works.
- [ ] Pollinations image flow works.
- [ ] Logout works.
- [ ] Session persistence works.

## Gate 8 — Deferred boundary check

Verify no V2.0 deployment introduced:

- [ ] vector search
- [ ] embeddings
- [ ] knowledge graph
- [ ] relationship engine
- [ ] emotional state machine
- [ ] persistent working context
- [ ] dedicated session table
- [ ] multi-model router



================================================================================

## 3. SECOND_HEAD_SH_LITE_V2.0_FINAL_CLOSURE.md


================================================================================


# SECOND HEAD — SH LITE V2.0 FINAL IMPLEMENTATION CLOSURE

**Document Status:** FINAL  
**Implementation Status:** GREEN (DONE)  
**Audit Status:** STEP C — PASS  
**Closure Authority:** Owner / Gatekeeper  
**Evidence Basis:** Final Snapshot Evidence  
**Closure Scope:** SH Lite V2.0 Implementation  

---

## 1. PURPOSE

Dokumen ini merupakan artefak resmi penutupan implementasi SH Lite V2.0.

Dokumen ini berfungsi sebagai:

- final closure record untuk implementasi V2.0;
- catatan resmi hasil Final Evidence Audit;
- penetapan status akhir implementasi;
- referensi handover menuju fase berikutnya;
- boundary antara pekerjaan yang dinyatakan selesai dalam V2.0 dan pekerjaan yang secara eksplisit dipindahkan ke backlog fase berikutnya.

Dokumen ini tidak dimaksudkan untuk mengubah desain, kontrak, atau canonical baseline yang telah ditetapkan sebelumnya.

---

## 2. FINAL STATUS

### SH Lite V2.0 Implementation

**STATUS: GREEN (DONE)**

Status ini telah diverifikasi dan diratifikasi oleh Owner berdasarkan evidence implementasi dan runtime yang tersedia.

Implementasi V2.0 dinyatakan selesai sesuai *Definition of Done* dalam *Implementation Contract* yang menjadi acuan implementasi.

---

## 3. FINAL EVIDENCE AUDIT

### Step C — Final Evidence Audit

**Verdict: PASS**

Evidence yang telah diverifikasi:

| Step | Area | Status | Evidence / Catatan |
| :--- | :--- | :--- | :--- |
| **Step 1** | Deploy Revision 3.1 | **PASS** | `index-chat.ts` Revision 3.1 Fixed berhasil dideploy tanpa error. Koreksi typo pada `Content-Type` telah diterapkan. |
| **Step 2** | Unique Index Enforcement | **PASS** | Unique index `idx_memories_user_key` aktif pada `(user_id, key)`. |
| **Step 3** | RLS Policy Structure | **PASS** | Policy akses memory membatasi akses berdasarkan authenticated user melalui `auth.uid()`. Terdapat policy overlap/debt yang diterima sebagai technical debt non-blocking. |
| **Step 4** | Degraded Context Fallback | **PASS** | Sistem tetap dapat merespons ketika sebagian query context mengalami kegagalan, menggunakan canonical fallback directives. |
| **Step 5** | Memory Persistence & Recall | **PASS** | Memory yang telah tersedia dapat dipanggil kembali secara implisit melalui context builder dan digunakan dalam respons SH. |
| **Step 6** | Model Failure Isolation | **PASS** | Ketika provider AI gagal/tidak tersedia, sistem mengembalikan kegagalan yang aman dan tidak menjalankan memory extraction. Conversation state yang telah ada tetap tidak berubah oleh kegagalan provider. |
| **Step 7** | Duplicate Suppression | **PASS** | Pengiriman ulang fakta memory yang sama tidak menghasilkan duplikasi row baru ketika key yang sama telah memiliki memory canonical. |
| **Image Gen** | Client-side Image Generation | **PASS** | Fitur image generation terbukti berjalan melalui client-side routing, natural-language trigger, direct provider fetch, Blob-to-Base64 conversion, dan rendering React Native `<Image>`. |

---

## 4. IMAGE GENERATION — FINAL CORRECTION

Temuan sebelumnya yang mengklasifikasikan Image Generation sebagai:

> «Known Issue / Deferred Technical Debt — Pollinations HTTP 500»

secara resmi dikoreksi dan ditarik kembali.

Berdasarkan evidence terbaru pada `App.js` dan konfirmasi runtime Owner:

**Image Generation Integration: PASS**

Implementasi yang telah terbukti berjalan:

```text
Natural Language Trigger
        ↓
Client-side Intent Detection
        ↓
Image Request Routing
        ↓
Direct Pollinations Fetch
        ↓
HTTP Response Validation
        ↓
Blob → Base64 Data URI
        ↓
React Native <Image> Rendering
        ↓
Image tampil di UI
```

Dengan demikian, masalah provider eksternal yang mungkin terjadi sewaktu-waktu tidak diklasifikasikan sebagai kegagalan integrasi SH Lite V2.0.

Provider eksternal tetap dapat memiliki risiko operasional tersendiri, namun berdasarkan evidence yang tersedia, integrasi image generation pada sisi client telah dinyatakan **PASS**.

---

## 5. FINAL EVIDENCE SNAPSHOT

Sebagai bagian dari closure V2.0, dua source snapshot berikut ditetapkan sebagai final snapshot evidence untuk implementasi V2.0:

### 5.1 `github.txt`

Berisi snapshot source aplikasi/client terbaru yang menjadi evidence implementasi sisi client.

Evidence yang relevan termasuk:

- authentication/session handling;
- Supabase client configuration;
- chat interaction;
- session initialization;
- natural-language image intent detection;
- client-side image generation;
- direct Pollinations fetch;
- Blob-to-Base64 conversion;
- React Native image rendering.

### 5.2 `supabase.txt`

Berisi snapshot source/backend terbaru yang menjadi evidence implementasi sisi Supabase/Edge Function.

Evidence yang relevan termasuk:

- authentication resolution;
- authenticated user isolation;
- read-only context builder;
- canonical identity directives;
- canonical safety directives;
- memory context assembly;
- conversation history;
- AI provider call;
- auto-memory extraction;
- memory validation;
- duplicate suppression;
- append-only memory persistence;
- degraded context fallback;
- model failure isolation;
- conversation persistence.

Kedua snapshot tersebut ditetapkan sebagai:

> «FINAL SNAPSHOT EVIDENCE FOR SH LITE V2.0»

Perubahan source setelah closure ini tidak secara otomatis dianggap sebagai bagian dari V2.0 final snapshot dan harus diperlakukan sebagai perubahan untuk fase atau versi berikutnya.

---

## 6. CANONICAL INVARIANTS VERIFIED

Berdasarkan Final Evidence Audit, invariant utama yang relevan dengan implementasi V2.0 dinyatakan tetap terjaga:

- **Identity:** SH memiliki canonical identity directives dan tidak mengidentifikasi dirinya sebagai model/provider.
- **Owner Isolation:** Context dan memory dibatasi berdasarkan authenticated owner/user identity.
- **Read-Only Context:** Context builder membaca data owner untuk membentuk context package dan tidak melakukan mutasi data pada tahap context assembly.
- **Append-Only Memory:** Memory baru disimpan sebagai row baru dan tidak melakukan overwrite terhadap memory canonical yang telah ada.
- **Duplicate Suppression:** Unique database constraint dan pemeriksaan pre-insert digunakan untuk mencegah duplikasi memory dengan key yang sama.
- **Degraded Context:** Kegagalan sebagian komponen context tidak secara otomatis menyebabkan seluruh chat gagal.
- **Model Failure Isolation:** Kegagalan provider AI diisolasi dari pipeline utama dan menghasilkan respons error yang aman.
- **Memory Extraction Failure Isolation:** Kegagalan memory extraction tidak membatalkan respons chat yang telah berhasil dibuat dan dipersist.
- **Image Generation:** Image generation terbukti dapat berjalan sebagai client-side capability melalui natural-language routing dan tidak menjadi dependency wajib bagi core text chat.

---

## 7. NON-BLOCKING TECHNICAL DEBT

Owner secara eksplisit menerima tiga item berikut sebagai **Non-Blocking Technical Debt**.

Item-item ini tidak membatalkan status **GREEN (DONE)** V2.0.

### 7.1 Memory Extraction Reliability

**Status:** Accepted Non-Blocking Technical Debt

Auto-memory extraction bergantung pada output model extraction. Dengan demikian, pesan Owner yang secara semantik dapat dianggap sebagai fakta pribadi belum dijamin selalu menghasilkan candidate memory.

Contoh:
> Owner: Gw suka musik  
> Owner: Gw suka musik rock  
> Owner: Gw suka rock alternatif  
> Owner: Band favorit gw Radiohead

Pipeline extraction saat ini bersifat LLM-based dan memiliki sifat non-deterministic.

**Disposition:**

Dipindahkan ke fase:
> «Memory Governance»

Ruang lingkup future work dapat mencakup reliability, prompt tuning, structured output, extraction policy, dan governance memory. Tidak ada perubahan terhadap status V2.0 yang dilakukan berdasarkan item ini.

### 7.2 RLS Policy Debt / Overlap

**Status:** Accepted Non-Blocking Technical Debt

Terdapat policy yang tumpang tindih pada struktur RLS, termasuk policy dengan fungsi yang serupa pada tabel memory. Security boundary yang diuji tetap membatasi akses berdasarkan authenticated user. Namun, struktur policy masih memiliki technical debt berupa overlap/redundancy yang perlu dirapikan.

**Disposition:**

Dipindahkan ke fase:
> «Security Audit»

Pembersihan policy tidak dilakukan sebagai bagian dari closure V2.0.

### 7.3 Conversation Partial-Write Risk

**Status:** Accepted Non-Blocking Technical Debt

Persistensi conversation saat ini melakukan dua operasi insert terpisah:
```text
INSERT user message
        ↓
INSERT assistant reply
```
Belum menggunakan transaksi atomik untuk menjamin kedua operasi berhasil atau gagal secara keseluruhan. Hal ini menciptakan kemungkinan partial-write pada kondisi kegagalan tertentu.

**Disposition:**

Dipindahkan ke fase:
> «Backend Hardening»

Perbaikan transaksi atomik tidak dilakukan sebagai bagian dari closure V2.0.

---

## 8. SCOPE BOUNDARY

Dengan closure ini, hal-hal berikut dinyatakan sebagai bagian dari implementasi V2.0 yang telah selesai dan diverifikasi:

- authenticated chat flow;
- owner-scoped data access;
- context assembly;
- canonical identity directives;
- canonical safety directives;
- conversation history context;
- memory context;
- auto-memory extraction pipeline;
- append-only memory persistence;
- duplicate suppression;
- degraded context fallback;
- AI provider failure isolation;
- client-side image generation;
- final evidence verification.

Sebaliknya, hal-hal berikut tidak dianggap sebagai pekerjaan yang harus diselesaikan ulang sebelum V2.0 ditutup:

- peningkatan reliability auto-memory extraction;
- cleanup RLS policy overlap;
- atomic transaction untuk conversation persistence.

Ketiganya telah diterima Owner sebagai backlog non-blocking untuk fase berikutnya.

---

## 9. FINAL RATIFICATION

Owner sebagai Gatekeeper telah memverifikasi dan meratifikasi:

1. Image Generation dikoreksi menjadi:
   > «PASS»

2. SH Lite V2.0 Implementation ditetapkan sebagai:
   > «GREEN (DONE)»

3. Tiga item berikut diterima sebagai:
   > «Non-Blocking Technical Debt»
   > - Memory Extraction Reliability → Memory Governance
   > - RLS Policy Debt/Overlap → Security Audit
   > - Conversation Partial-Write Risk → Backend Hardening

4. `github.txt` dan `supabase.txt` ditetapkan sebagai:
   > «Final Snapshot Evidence untuk SH Lite V2.0»

Dengan ratifikasi tersebut:

> «SH LITE V2.0 IMPLEMENTATION IS OFFICIALLY CLOSED.»

---

## 10. HANDOVER TO NEXT PHASE

Status V2.0 setelah closure:

```text
SH Lite V2.0
    │
    ├── Implementation        ✅ DONE
    ├── Final Evidence Audit  ✅ PASS
    ├── Image Generation      ✅ PASS
    ├── Core Chat             ✅ DONE
    ├── Memory Pipeline       ✅ DONE
    └── Closure               ✅ FINAL
```

Backlog yang dibawa ke fase berikutnya:

- **Memory Extraction Reliability** → Memory Governance
- **RLS Policy Debt / Overlap** → Security Audit
- **Conversation Partial-Write Risk** → Backend Hardening

Fase berikutnya tidak dianggap dimulai secara otomatis oleh dokumen ini. Pemilihan dan prioritas fase berikutnya tetap merupakan keputusan Owner.

---

## 11. FINAL CLOSURE STATEMENT

SH Lite V2.0 Implementation telah menyelesaikan implementasi dan evidence verification sesuai *Definition of Done* yang berlaku.

Berdasarkan evidence yang telah diverifikasi dan keputusan final Owner:

> **«FINAL STATUS: GREEN (DONE)»**  
> **«STEP C FINAL EVIDENCE AUDIT: PASS»**  
> **«SH LITE V2.0: OFFICIALLY CLOSED»**

Tiga technical debt yang telah diterima tidak memblokir closure dan secara resmi dipindahkan ke backlog fase berikutnya.

Dokumen ini menjadi catatan closure resmi untuk implementasi SH Lite V2.0 dan menjadi titik handover menuju fase pengembangan selanjutnya.

---

**Document:** `SECOND_HEAD_SH_LITE_V2.0_FINAL_CLOSURE.md`  
**Version:** v1.0  
**Status:** FINAL  
**Project:** SECOND HEAD — SYSTEM BUILD  
**Implementation:** SH Lite V2.0  
**Final Verdict:** GREEN (DONE)  
**Audit Verdict:** PASS  
**Authority:** Owner / Gatekeeper



================================================================================

## 4. SECOND_HEAD_SH_LITE_V2.0.0.md


================================================================================


# SECOND HEAD — SH LITE V2.0.0

## 1. Document Status
- **Version:** 2.0.0
- **Status:** GREEN (DONE)
- **Closure Status:** FINAL
- **Authority Note:** This document is a compiled final artifact/release closure. It does not override the Frozen Baseline or Implementation Contract.
- **Date:** 2026-08-02 (Based on Final Closure ratification)

## 2. Purpose & Scope
SH Lite V2.0 is the implementation of the "Identity, Context, and Continuity" layer for the Second Head system.
**Scope (7 Pillars):**
1. Explicit SH Identity Representation.
2. Internal `sh_id` Abstraction.
3. Read-Only Context Builder.
4. Dynamic Virtual Session Boundary.
5. Contextual Opening / Continuity.
6. Persona-Driven Emergent Emotional Expression.
7. AI Write Authority Boundary & Strict Data Isolation.

**Purpose of Release:** To establish a verified, running baseline where SH possesses a persistent identity, bounded context, and append-only memory capabilities without violating V1 security invariants.

## 3. Canonical References & Authority
**Hierarchy of Authority:**
1. **Frozen Baseline:** `SECOND_HEAD_COMPILED_DOCUMENTATION_BASELINE_v1.0.md` (Primary Authority).
2. **Implementation Contract:** `SECOND_HEAD_SH_LITE_V2.0_IMPLEMENTATION_CONTRACT_v1.0.md`.
3. **Canonical Package:** `SECOND_HEAD_COMPILATION_SH_LITE_V2.0_CANONICAL_IMPLEMENTATION_PACKAGE_v1.0.md`.
4. **Final Evidence:** `github.txt` and `supabase.txt` (Runtime snapshots).
5. **Closure Record:** `SECOND_HEAD_SH_LITE_V2.0_FINAL_CLOSURE.md`.

## 4. Final Architecture / Implementation Summary
Based on verified source snapshots:

- **Authentication:** Supabase Auth via JWT. Backend resolves `authenticated_user_id` from token; client cannot forge identity.
- **Owner Isolation:** All database queries (`users`, `memories`, `conversations`) are strictly scoped to `authenticated_user_id`.
- **Identity Directives:** Stored in `sh_profile` (JSONB) on `public.users`. Canonical directives prevent SH from claiming model/provider as identity.
- **Context Builder:** Read-only module (`buildReadOnlyContext`). Assembles bounded context package (Identity, Owner Profile, Time, Memories, Directives, History). Uses `Promise.allSettled` for partial failure resilience.
- **Memory System:** Non-vector retrieval (5 Priority Facts + 10 Recent Memories). Append-only persistence via post-processing pipeline.
- **Auto-Memory Extraction:** Separate AI call analyzes Owner message for explicit facts. Backend validates schema, enforces owner scoping, and suppresses duplicates.
- **Session Opening:** Virtual time-gap (4 hours). `init_session` triggers contextual opening if threshold met.
- **Image Generation:** Client-side routing in `App.js`. Natural language triggers intent detection -> Direct Pollinations Fetch -> Base64 conversion -> UI Rendering.
- **Failure Isolation:**
  - Context failure: Falls back to canonical directives (degraded mode).
  - Model failure: Returns safe error (503), halts extraction.
  - Extraction failure: Isolated via try/catch; main chat succeeds.

## 5. Final Source Snapshot Evidence
The following files are designated as the **Final Snapshot Evidence** for V2.0:

- **`github.txt`**: Contains the final `App.js` source.
  - *Evidence of:* Client-side lifecycle, `init_session` guard, natural language image intent detection, and direct Pollinations integration.
- **`supabase.txt`**: Contains the final `chat/index.ts` (Edge Function) and SQL Schema.
  - *Evidence of:* Read-only context builder, explicit failure semantics, unique index enforcement (`idx_memories_user_key`), and append-only memory pipeline.

## 6. Evidence Audit
**Step C — Final Evidence Audit Verdict: PASS**

| Step | Area | Status | Notes |
| :--- | :--- | :--- | :--- |
| 1 | Deploy Revision 3.1 | **PASS** | Typo fix verified. |
| 2 | Unique Index Enforcement | **PASS** | `idx_memories_user_key` active on `(user_id, key)`. |
| 3 | RLS Policy Structure | **PASS** | Owner-bound access verified. *Note: Policy overlap/debt exists (see Section 9).* |
| 4 | Degraded Context Fallback | **PASS** | System responds using canonical directives on partial failure. |
| 5 | Memory Persistence & Recall | **PASS** | Memories stored and used implicitly in context. |
| 6 | Model Failure Isolation | **PASS** | Safe error returned; extraction halted. |
| 7 | Duplicate Suppression | **PASS** | Identical keys/values dropped; conflicts preserve existing row. |

## 7. Image Generation Final Evidence
**Status: PASS**

The classification of Image Generation as "Deferred Technical Debt" is **withdrawn**.
**Evidence:** `App.js` (in `github.txt`) proves a stable client-side runtime flow:
1. Natural Language Trigger (Regex).
2. Client-side Intent Detection.
3. Direct Pollinations Fetch.
4. Blob to Base64 conversion.
5. React Native `<Image>` rendering.

*Operational Note:* External provider instability (HTTP 500) is an operational risk, not an integration failure of SH Lite V2.0.

## 8. Final Verdict
**SH Lite V2.0 Implementation = GREEN (DONE)**

This status is ratified based on the Definition of Done in the Implementation Contract and verified runtime evidence.

## 9. Non-Blocking Technical Debt / Backlog
The following items are accepted as **Non-Blocking Technical Debt** and do not invalidate the GREEN status:

1. **Memory Extraction Reliability:** Non-deterministic nature of LLM extraction.
   - *Disposition:* Backlog -> **Memory Governance**.
2. **RLS Policy Debt / Overlap:** Redundant policies on `memories`/`conversations` tables.
   - *Disposition:* Backlog -> **Security Audit**.
3. **Conversation Partial-Write Risk:** Two separate INSERT operations (user/assistant) lack atomic transaction.
   - *Disposition:* Backlog -> **Backend Hardening**.

## 10. Known Boundaries / Non-Goals
The following are explicitly **OUT OF SCOPE** for V2.0 (per Contract Section 3):
- Vector Search / Semantic Memory Engine.
- Knowledge Graph / Relationship Engine.
- Emotional State Machine / Persistent Mood Database.
- Dedicated Session Table / Persistent Working Context.
- Multi-Model Router.
- Manual Memory Management UI.

## 11. Final Closure
Based on evidence and Owner ratification:
- **Step C:** PASS
- **Image Generation:** PASS
- **SH Lite V2.0:** GREEN (DONE)

V2.0 is officially closed. The three technical debt items are transferred to the phase backlog.

## 12. Future Phase Backlog
The following phases are identified but **NOT STARTED**:
1. **Memory Governance** (Extraction reliability, semantic deduplication).
2. **Security Audit** (RLS cleanup).
3. **Backend Hardening** (Atomic transactions).

---
**Document:** `SECOND_HEAD_SH_LITE_V2.0.0.md`
**Version:** 2.0.0
**Status:** FINAL CLOSURE ARTIFACT
