# SECOND HEAD — SESSION RESUME 69

## Sesi brainstorming pengembangan SH

Resume ini khusus untuk **brainstorming, ide, masukan, arah pengembangan, dan hasil obrolan** tentang SECOND HEAD setelah v0.1.0.

Ini **bukan Canonical**, bukan implementation contract, dan bukan keputusan final. Isinya boleh berubah, bertambah, diperdebatkan, atau dibuang pada sesi berikutnya.

Tujuan utamanya sederhana: **jangan sampai ide-ide daging hasil diskusi hilang.**

---

# CARA BACA RESUME 69

Resume 69 adalah **kumpulan diskusi dan brainstorming**, bukan dokumen kesimpulan.

Di dalamnya boleh ada:
- ide mentah
- pertanyaan
- kemungkinan
- usulan
- perbandingan
- kekhawatiran
- bantahan
- revisi pemikiran
- ide yang kemudian berubah atau dibuang
- hal yang masih ingin diaudit

Tulisan di sini **tidak otomatis menjadi keputusan**. Kalau suatu ide nantinya matang, pembahasannya dapat dipindahkan ke dokumen Evolution/Design/Implementation yang lebih terstruktur.

Urutan berpikir yang diinginkan:

IDE → ngobrol → eksplorasi → kritik → mungkin berkembang → mungkin dibuang → kandidat → keputusan formal (jika memang diperlukan)

Resume 69 sengaja boleh berubah melalui banyak commit karena fungsinya adalah menjaga memory diskusi.

---

# BRAINSTORM AWAL — SETELAH V0.1.0

Bagian ini menangkap brainstorming awal yang menjadi pemicu diskusi Resume 69. Isinya bukan daftar kewajiban dan bukan scope final.

## 1. CHAT — fondasi sudah cukup matang

Saat brainstorming dimulai, fungsi yang sudah terbukti meliputi conversation, history, rename, find, copy, share, export, delete, edit, regenerate, attachment, photo, camera, file, Android back dialog, persistence, dan isolation.

Pertanyaan yang muncul bukan lagi "chat harus ditambah apa supaya ada fitur", tetapi:

> Kalau SH diberikan ke user biasa, apa yang masih membuatnya terasa setengah jadi?

Kemungkinan quality-of-life yang dilempar ke meja:
- stop generation
- retry failed response
- attachment preview yang lebih enak
- multiple attachments

Semua ini kandidat diskusi, bukan keputusan implementasi.

## 2. JOURNEY

Journey dipandang berpotensi menjadi salah satu surface paling menarik.

Bukan cuma list, tetapi kemungkinan:
- filter All / Memory / Knowledge / Experience / Lifecycle/Other
- event detail
- tap event → source
- source event → conversation
- search
- chronological grouping
- event type indicator
- empty state
- refresh
- pagination

Muncul ide:

> **Journey → Chat**

Kalau event berasal dari conversation, user dapat langsung kembali ke conversation tersebut.

Pertanyaan yang masih terbuka: apakah Journey akan terasa sebagai continuity system atau hanya database viewer?

## 3. MEMORY

Pertanyaan awal:

> Kalau user punya Memory, bagaimana cara mengelolanya dengan nyaman?

Kemungkinan:
- view
- search
- detail
- source/provenance
- delete
- mungkin edit

Edit sengaja dipandang hati-hati karena bisa menyentuh provenance/lifecycle semantics.

## 4. KNOWLEDGE

Pertanyaan:

> Bagaimana user memasukkan Knowledge?

Ide yang dilempar:
- text
- file
- URL
- from conversation?

Kemudian kemungkinan metadata:
- title
- content
- source
- provenance
- visibility
- created

Belum diputuskan karena semantics Knowledge perlu dipahami dulu.

## 5. EXPERIENCE

Muncul pertanyaan apakah Experience benar-benar berbeda dari Memory.

Mental model awal:

Memory → tentang user / hal yang perlu diingat.

Knowledge → hal yang diketahui tentang sesuatu.

Experience → apa yang dialami/dipelajari SH dalam perjalanan.

Ide surface Experience:

What happened → What was learned → Context → Outcome → Journey

Masih eksplorasi.

## 6. SEARCH

Find di Chat sudah terbukti berguna.

Muncul ide **Global SH Search**:

Search Second Head → Conversations / Memory / Knowledge / Experience / Journey

Contoh pencarian seperti regression BUG-004 dapat menemukan sumber lintas surface, tetap dengan boundary account/privacy.

## 7. LIFECYCLE

Muncul keinginan mengaudit apakah surface Lifecycle benar-benar executable atau sebagian baru kosmetik.

Konsep yang ingin dicek:
- Clone
- Recovery
- Inheritance
- Succession
- End-of-Life
- Legacy

Contoh flow konseptual:

Clone → Create Clone → approval → agreement → new SH

Recovery → snapshot → validation → confirmation → restore

Pertanyaan utamanya:

> Mana yang functional, partial, dan cosmetic?

Ini awalnya ide audit, bukan keputusan bahwa semua lifecycle feature harus dibangun sekarang.

## 8. MORE

More juga dicurigai berpotensi menjadi kumpulan tombol yang terlihat ada tetapi belum berguna.

Yang ingin dieksplor:
- Runtime Verification
- Authorization
- Error
- Account / Sign out

Contoh ide:

Runtime Verification → diagnostic yang berguna.

Authorization → user memahami authority SH.

Error → error center sederhana.

Account → identity/session/sign out.

## 9. ERROR UX

Pengalaman nyata dengan error seperti MODEL_SELECTION_FAILED dan SH_RUNTIME_STREAM_FAILED memunculkan ide bahwa user tidak seharusnya dipaksa membaca JSON teknis.

Kemungkinan UX:

> SH mengalami masalah saat memproses permintaan.
>
> [Try again]

Detail teknis tetap bisa tersedia melalui diagnostic/error surface.

Mental model:

USER UX → sederhana  
TECHNICAL DIAGNOSTIC → detail

## 10. LOADING / EMPTY / OFFLINE STATES

Hal kecil yang bisa membuat aplikasi terasa jauh lebih matang:
- history kosong → penjelasan yang natural
- Journey kosong → penjelasan
- network mati → status yang jelas
- model unavailable → status yang jelas
- upload → uploading / processing / analyzing

Tujuannya agar user tidak bertanya apakah aplikasi freeze atau sedang bekerja.

## 11. CONVERSATION MANAGEMENT

Rename sudah ada, tetapi muncul ide otomatis conversation title.

Misalnya user bertanya:

> Buat resume dari file...

Conversation dapat memperoleh title yang lebih bermakna daripada "Untitled conversation".

Rename manual tetap ada.

## 12. NOTIFICATIONS

Kemungkinan:
- long-running processing selesai
- recovery selesai
- export selesai

Belum dianggap prioritas.

## 13. VOICE

Ide:

🎤 → speech-to-text → normal SH chat pipeline

Tetapi waktu itu sengaja tidak diprioritaskan karena multimodal/file/photo/camera baru saja distabilkan.

## 14. MULTIMODAL RESPONSE

Awalnya SH sudah bergerak dari:

user → image → SH → text

Kemudian muncul bayangan kemampuan yang lebih utuh:

image → question → reasoning → answer

Bukan hanya attachment, tetapi capability multimodal.

## 15. SH STATUS

Ide surface ringan untuk menunjukkan kondisi SH:

SECOND HEAD

Status → Online  
Identity → SH-xxxx  
Runtime → Available  
Memory → ...  
Knowledge → ...  
Experience → ...  
Conversation → ...

Bukan dashboard besar. Hanya "kondisi SH saya sekarang".

## 16. IMAGE GENERATION

Kemudian muncul ide yang dianggap jelas belum ada:

User → "buatkan gambar..." → SH Runtime → image generation capability → hasil gambar → save/share/download

Poin pentingnya: image generation tidak hanya dianggap attachment kebalikan, tetapi capability SH sendiri.

## 17. PROJECTS

Muncul ide workspace/project seperti:

Projects
- SECOND HEAD
- Work
- Personal

Dengan kemungkinan conversations, files, knowledge, instructions di dalam project.

Tetapi langsung muncul pertanyaan penting:

> Project boundary ≠ SH boundary.

Jadi konsep ini tidak boleh sekadar meniru produk lain.

## 18. TOOLS / PLUGINS / EXTENSIONS

Ide awalnya bukan membuat puluhan plugin.

Lebih menarik jika ada konsep:

SH → capability/tool → authorization → execution → result → reasoning

Contoh capability:
- web search
- calculator
- file reader
- image generator

Plugin/extension kemudian bisa menjadi layer yang mendeklarasikan capability, bukan sekadar tombol tambahan.

## 19. MODERN UI

Keinginan owner:

> UI jangan konservatif seperti sekarang; lebih modern dan enak dipakai.

Referensi visual/UX yang disebut dalam diskusi:
- ChatGPT
- Qwen Studio
- Claude
- produk AI modern lain
- MiRA sebagai salah satu pembanding visual

Tetapi targetnya bukan clone ChatGPT.

Mental model:

> **ChatGPT-like UX + SH architecture.**

Clean, modern, conversation-first, ringan di HP, composer natural, attachment natural, message actions rapi, dan tidak terasa seperti admin dashboard.

## 20. V0.1.0 → V1.0.0

Muncul gagasan:

v0.1.0 = functional foundation / proving ground

v1.0.0 = SH yang mulai terasa sebagai sistem utuh.

Kemungkinan isi v1.0.0 yang dilempar ke meja:
- modern UI
- conversational UX
- Memory
- Knowledge
- Experience
- Journey
- Projects
- Tools
- Extensions
- multimodal
- image understanding
- image generation
- file intelligence
- Lifecycle
- global search

Tetapi ini **bukan daftar final**.

---

# TITIK AWAL

v0.1.0 secara fungsi dasar sudah terasa hidup.

BUG-001 sampai BUG-006 sudah selesai berdasarkan evidence masing-masing.

Karena itu kita sepakat untuk sementara **tidak buru-buru mencari bug baru** dan tidak langsung masuk ke pengembangan besar dari Canonical.

Kita brainstorming dulu:

> **Kalau SECOND HEAD mau naik kelas menjadi SH yang benar-benar matang, apa yang masih kurang? Apa yang perlu ditambah? Apa yang bisa dibuat jauh lebih keren?**

---

# IDE BESAR — SH BUKAN CHATBOT

Salah satu kesimpulan paling kuat dari obrolan:

> **SH bukan chatbot.**

Kita juga tidak terlalu suka menyebutnya sekadar **personal AI assistant**, karena istilah itu terasa terlalu kecil.

Cara berpikir yang muncul:

SH = JIWA
AI MODEL = OTAK

Model AI adalah mesin intelligence/reasoning yang dipakai SH.

SH sendiri adalah system/entity layer yang membawa identity, continuity, memory, knowledge, experience, journey, lifecycle, dan hubungan dengan owner.

---

# IDE — OTAK, JIWA, INDERA, TANGAN

Analogi yang muncul dan sangat disukai:

SECOND HEAD
├── JIWA
├── OTAK — AI / Models
├── INDERA — menerima dunia
└── TANGAN — bertindak di dunia

## Jiwa

Kandidat elemen:
- Identity
- Memory
- Knowledge
- Experience
- Conversation continuity
- Journey
- Lifecycle
- relationship dengan owner

## Otak

Model AI/provider:
- language
- reasoning
- vision
- planning
- task-specific capabilities

SH tidak harus bergantung pada satu model.

Secara konsep: SH → runtime → model/provider/capability.

Jadi model bisa berubah tanpa identitas SH ikut berubah.

## Indera

Yang sudah mulai nyata:
- text
- file
- photo
- camera

Yang bisa dipikirkan:
- audio
- voice
- visual context
- kemungkinan input lain

## Tangan

Yang sudah/ mulai ada:
- tools
- actions
- file handling
- web/service integrations
- image generation

Arah besarnya:

> SH tidak cuma menjawab apa yang harus dilakukan; SH juga memiliki kemampuan untuk melakukan sesuatu melalui tools.

---

# IDE — SEMUA KITA HAJAR

Bukan berarti memasukkan semua fitur produk AI lain secara membabi buta.

Maksudnya:

> **Semua capability yang masuk akal untuk membuat SH menjadi sistem AI yang utuh boleh kita eksplor.**

Yang dikejar bukan jumlah fitur, tetapi kelengkapan sistem:

- Brain
- Soul
- Senses
- Hands
- Authority
- Continuity
- Provenance
- Lifecycle
- UX

---

# IDE — CHATGPT-LIKE UX, TAPI BUKAN CHATGPT CLONE

SH tidak perlu menjadi SH Lite.

Yang dimaksud:

> **SECOND HEAD tetap SECOND HEAD, tetapi UX/UI dibuat modern dan familiar seperti ChatGPT dalam versi yang lebih ringan.**

Target feel:
- clean
- modern
- conversation-first
- sidebar/drawer yang enak
- composer modern
- attachment natural
- message actions rapi
- spacing dan typography modern
- dialog/modal polished
- tidak terasa seperti aplikasi admin

Tidak semua fitur ChatGPT harus diadopsi.

Contoh yang boleh dieksplor:
- Projects
- tools
- search
- multimodal
- image generation
- extensions/integrations

Prinsip:

> **Familiar interface, different brain/system.**

---

# IDE — SH HARUS MEMILIKI CONTINUITY

Ini dianggap sebagai salah satu pembeda paling penting.

AI biasa: Prompt → Answer.

SH: Conversation → Memory / Knowledge / Experience → Journey → future interaction.

User bisa datang kembali dan berkata:

> "Lanjut yang kemarin."

SH idealnya memahami apa arti "kemarin" berdasarkan continuity sistem, bukan sekadar mencari text secara acak.

---

# IDE — MEMORY ≠ KNOWLEDGE ≠ EXPERIENCE

SH tidak menyatukan semua informasi menjadi satu bucket bernama memory.

Memory = hal tentang user / hal yang memang perlu diingat.

Knowledge = hal yang diketahui tentang sesuatu.

Experience = hal yang dialami dalam perjalanan interaksi.

Ketiganya dapat memiliki fungsi dan lifecycle berbeda.

Ini masih arah pemikiran, bukan perubahan Canonical.

---

# IDE — JOURNEY

Journey dianggap lebih dari sekadar halaman timeline.

Journey dapat menjadi representation dari perjalanan SH dan owner.

Contoh konseptual:

Conversation → Experience → Memory / Knowledge → Journey → future interaction.

BUG-004 juga memperlihatkan pentingnya synchronized lifecycle/provenance antara source record dan Journey representation.

Pertanyaan pengembangan:
- Apa yang sebenarnya perlu terlihat oleh user?
- Apa yang sebaiknya tetap internal?
- Apakah Journey dapat membantu SH memahami perkembangan hubungan/interaksi?
- Bagaimana Journey berinteraksi dengan lifecycle SH?

Belum diputuskan.

---

# IDE — PROVENANCE

Data SH memiliki asal-usul dan lifecycle.

Contoh yang sudah terbukti dalam maintenance:

Source record ↕ Journey representation.

Ketika source record dihapus, representation terkait harus ikut sinkron.

Ke depan provenance bisa menjadi fondasi:
- traceability
- audit
- lifecycle
- explanation
- action history
- trust

---

# IDE — HANDS / TOOLS

Attachment bukan sekadar upload UI.

BUG-006 menunjukkan flow harus benar-benar menjadi satu:

composer → attachment → sent message → runtime → model/capability.

Ke depan hands bisa berkembang menjadi:
- web/search
- file creation
- file transformation
- image generation
- external services
- integrations
- plugins/extensions
- automation
- actions atas data SH

Semakin kuat tangan SH, semakin penting authority dan confirmation.

---

# IDE — AUTHORITY / WILL

Konsekuensi langsung dari konsep SH punya tangan.

Jika SH bisa melakukan tindakan:

SH wants to do X → Is SH allowed? → What authority? → Owner confirmation? → Execute → Record what happened.

Jadi bukan hanya "SH bisa melakukan X", tetapi:

> **SH boleh melakukan X, tahu konteksnya, dan tindakan itu dapat dipertanggungjawabkan.**

Ini berpotensi menjadi pembeda penting.

---

# IDE — BODY / UI

Kalau jiwa = SH system, otak = model, indera = input, tangan = tools, maka aplikasi/UI bisa dipandang sebagai:

> **tubuh/interface tempat semuanya bertemu.**

UI tidak harus menjadi sumber identitas SH.

UI harus membuat sistem kompleks terasa natural.

---

# IDE — POSITIONING

Rumusan yang muncul:

> **SECOND HEAD adalah personal AI system yang dirancang untuk mempertahankan continuity dengan user — bukan hanya melalui percakapan, tapi melalui Memory, Knowledge, Experience, Journey, dan lifecycle-nya.**

Rumusan lebih konseptual:

> **SH adalah jiwa. Model AI adalah otaknya. Indera membuatnya bisa menerima dunia. Tools dan integrations menjadi tangannya.**

Ini bukan Canonical wording. Ini hasil brainstorming dan calon positioning.

---

# IDE — V1.0.0

Muncul ide bahwa produk sekarang lebih cocok dipandang sebagai:

> **v0.1.0 = functional foundation**

Sedangkan target berikutnya bisa menjadi:

> **v1.0.0 = SH yang mulai terasa sebagai sistem utuh.**

Namun daftar fitur v1.0.0 belum final.

Jangan menganggap seluruh brainstorming di Resume 69 otomatis menjadi scope v1.0.0.

Masih perlu menemukan:
- capability minimum yang membuat SH pantas disebut v1.0
- UX yang tepat
- architecture boundaries
- dependency
- priority
- wajib vs nice-to-have

---

# IDE — CAPABILITY MAP AWAL

SECOND HEAD
├── SOUL
│   ├── Identity
│   ├── Memory
│   ├── Knowledge
│   ├── Experience
│   ├── Journey
│   └── Lifecycle
├── BRAIN
│   ├── AI Models
│   ├── Reasoning
│   ├── Vision
│   └── Planning
├── SENSES
│   ├── Text
│   ├── Image
│   ├── Camera
│   ├── File
│   └── Audio
├── HANDS
│   ├── Tools
│   ├── Actions
│   ├── Search
│   ├── Web
│   ├── Files
│   ├── Image Generation
│   └── Extensions / Integrations
├── AUTHORITY
│   ├── Permission
│   ├── Owner confirmation
│   ├── Action boundary
│   └── Auditability
└── BODY / UX
    ├── Chat
    ├── Navigation
    ├── Projects?
    ├── Tools UI
    └── Modern interaction model

Ini brainstorming map, bukan architecture replacement.

---

# HAL YANG MASIH TERBUKA

1. Apa sebenarnya "jiwa" SH secara teknis dan behavioral?
2. Bagaimana Identity berbeda dari Memory?
3. Apa hubungan Knowledge ↔ Experience?
4. Apa yang harus masuk Journey dan apa yang tidak?
5. Apa bentuk hands pertama yang paling berguna?
6. Bagaimana authority bekerja ketika SH melakukan action?
7. Apakah Projects cocok untuk SH?
8. Bagaimana image generation masuk tanpa menjadi fitur tempelan?
9. Bagaimana voice/audio masuk?
10. Apa UX modern SH yang tepat?
11. Apa yang harus terlihat user dan apa yang sebaiknya invisible?
12. Apa capability minimum agar SH pantas disebut v1.0.0?
13. Apa yang membuat SH benar-benar berbeda dari AI product lain?
14. Bagaimana SH tetap ringan di HP walaupun capability bertambah?
15. Bagaimana menjaga identitas SH ketika model/provider berganti?

---

# PRINSIP SESI BRAINSTORMING

Resume ini boleh berubah berkali-kali.

Tidak masalah jika sampai puluhan/ratusan commit karena ini adalah living discussion record.

Ide yang hari ini dianggap bagus boleh besok dibuang.

Ide yang masih mentah tetap dicatat kalau berpotensi penting.

Alurnya:

IDE → DISCUSSION → REFINEMENT → CANDIDATE → DECISION → baru nanti masuk scope / Canonical bila memang diputuskan.

**Jangan mengubah Canonical hanya karena ide muncul di Resume 69.**

---

# POSISI SEKARANG

BUG-001 → BUG-006 selesai.

v0.1.0 functional foundation sudah berjalan.

Tidak ada kewajiban mencari bug baru sekarang.

Fokus sesi berikutnya:

> **Brainstorming SH — apa yang belum ada, apa yang perlu ditambah, dan bagaimana membuat SH benar-benar menjadi sistem yang berbeda dari produk AI lain.**

---

# CATATAN PENTING

Semua isi Resume 69 setelah bagian ini adalah bahan diskusi.

Boleh kritis. Boleh saling bertentangan. Boleh berubah. Boleh ditolak.

Tidak ada yang otomatis menjadi Canonical hanya karena tertulis di sini.

---

# LANJUTAN BRAINSTORMING — MiRA, PRODUK AI LAIN, PORTABILITY, DAN LOCAL RUNTIME

## MiRA — tetap proyek terpisah

MiRA dibahas sebagai proyek terpisah dari SH.

Tidak ada niat mencampur codebase, architecture, identity, atau scope MiRA dengan SH.

Yang ingin diambil hanyalah insight/pattern yang memang berguna untuk SH.

Observasi dari diskusi:
- UI MiRA terasa lebih menarik dibanding UI SH v0.1.0 saat ini.
- MiRA menunjukkan bahwa local-first/local runtime adalah arah yang menarik untuk dipelajari.
- Local implementation MiRA yang pernah diuji masih mengalami masalah ketika konek melalui Termux.
- Preferensi owner untuk SH: jika local AI dikembangkan, pengalaman user sebaiknya terintegrasi langsung di APK dan tidak mengharuskan Termux/service manual.

Prinsip:

> Ambil ide yang berguna, jangan mencampur proyek.

## Produk AI lain sebagai referensi

Brainstorming tidak berhenti pada ChatGPT dan MiRA. Beberapa produk/open-source project dapat menjadi sumber inspirasi untuk bagian yang berbeda:

- ChatGPT → conversation-first UX, composer, attachment, message actions, navigation.
- Qwen Studio → workspace feel, multimodal interaction, capability presentation, file interaction.
- Claude → readability, typography, whitespace, calm conversation UX.
- Perplexity → search/research workflow dan source/result presentation.
- Gemini → multimodal interaction dan capability discovery.
- Open WebUI → capability platform, tools/function calling, knowledge/RAG, web search, multimodal, provider abstraction.
- LibreChat → multi-model/provider UX, comparison, presets/configuration.
- AnythingLLM → workspace/context boundary dan knowledge separation.
- LobeChat → polished AI UX, assistant/tool presentation, conversation organization.
- Jan → local-first feeling, local simplicity, privacy-oriented capability.
- OpenClaw → agent/action model, tools, browser/file/service interaction.
- Open Interpreter → action execution dan permission boundary.
- Dify → workflow thinking dan chaining capability/action/reasoning.
- Onyx → knowledge access dan connected information.

Semua ini adalah bahan inspirasi, bukan daftar kewajiban fitur SH.

Prinsip pemilihannya:

> Apakah konsep ini memperkuat identitas SH?

Bukan:

> Produk lain punya fitur X, jadi SH wajib punya X.

## SH jangan menjadi Frankenstein

Risiko dari terlalu banyak referensi adalah membuat SH menjadi kumpulan fitur tanpa identitas.

Targetnya bukan:

ChatGPT + MiRA + Qwen + Claude + Gemini + Open WebUI + LibreChat + dst.

Targetnya:

- ambil pola yang terbukti bagus
- pahami alasan kenapa bagus
- adaptasikan ke SH
- pertahankan identitas SH

Mental model:

ChatGPT → conversation UX
Claude → readability
Qwen Studio → workspace/capability UX
Perplexity → research UX
Gemini → multimodal UX
MiRA → local/personal feel
Open WebUI → capability platform
LibreChat → provider abstraction
AnythingLLM → context/workspace thinking
LobeChat → polished UX
Jan → local simplicity
OpenClaw → hands/action
Open Interpreter → execution model
Dify → workflow thinking
Onyx → knowledge access

↓

SH

## Portability — GitHub tetap rumah source code

Diskusi juga membahas apakah suatu hari Supabase perlu diganti.

Posisi brainstorming:

GitHub tetap sangat nyaman sebagai rumah source code dan workflow:
- source control
- branch
- commit
- CI/CD
- Actions
- artifact/build lineage
- audit

Tidak ada kebutuhan mengganti GitHub hanya demi portability database.

## Portability — Supabase sebagai infrastructure saat ini

Supabase dipandang sebagai infrastructure yang digunakan SH saat ini, bukan identitas SH.

Target konseptual:

SH
↓
SH runtime/data contracts
↓
adapter/layer
↓
Supabase

Jika suatu hari perlu pindah:

SH
↓
SH runtime/data contracts
↓
adapter/layer
↓
Provider B / PostgreSQL lain / local

Harapannya migrasi cukup berpusat pada infrastructure/data layer dan tidak memaksa bongkar total aplikasi.

Migrasi database tidak hanya export/import data. Hal yang mungkin perlu ditangani antara lain:
- schema
- data
- indexes
- functions
- triggers
- RLS/security policies
- auth
- storage
- realtime
- edge functions
- Supabase-specific RPC/API usage

Karena Supabase berbasis PostgreSQL, perpindahan ke provider PostgreSQL lain secara konsep dapat lebih ringan daripada berpindah engine database yang berbeda. Detail migration tetap harus diaudit ketika kebutuhan nyata muncul.

Prinsip:

> Don't make SH permanently Supabase-dependent.

Tetapi juga:

> Jangan membangun portability abstraction berlebihan sekarang hanya untuk mengantisipasi masalah hipotetis.

## Analogi provider

Model AI dan database sama-sama sebaiknya tidak menjadi identitas SH.

Model:

SH Runtime
↓
Model Provider Interface
├── A
├── B
├── C
└── D

Data/infrastructure:

SH Runtime
↓
Data/Infrastructure Interface
├── Supabase
├── PostgreSQL provider lain
└── Local store

Gagasan utamanya:

> SH harus tetap SH walaupun implementation provider berubah.

## Local / Offline SH

Muncul keinginan agar SH suatu hari tetap berguna di area tanpa sinyal atau ketika internet tidak tersedia.

Offline tidak harus berarti seluruh SH harus berjalan penuh tanpa internet.

Kemungkinan capability:

- buka conversation lama → kemungkinan offline
- baca Memory → kemungkinan offline
- baca Knowledge tersimpan → kemungkinan offline
- baca Journey → kemungkinan offline
- edit data lokal → kemungkinan offline
- buat draft → kemungkinan offline
- sync perubahan → membutuhkan koneksi
- cloud model → membutuhkan koneksi
- web search → membutuhkan koneksi
- cloud tools → membutuhkan koneksi
- local model → mungkin offline jika tersedia

Ini masih brainstorming.

## Local model — preferensi pengalaman user

Owner lebih menyukai local model yang terintegrasi langsung dengan aplikasi Android daripada flow yang mengharuskan Termux.

Target pengalaman konseptual:

Install SH APK
↓
download/import GGUF
↓
SH mendeteksi model
↓
load model
↓
inference langsung di Android

Model besar tidak harus dibundel ke APK.

Konsep pemisahan:

SH APK
├── SH application
├── runtime
└── local inference engine

App/device storage
└── models/
    ├── model-a.gguf
    └── model-b.gguf

Lokasi storage final belum diputuskan.

Yang penting dari sisi UX:
- model dapat di-import/download
- model tidak harus menjadi bagian dari APK utama
- model dapat diganti
- inference berjalan langsung dari aplikasi
- user tidak membutuhkan Termux atau service manual

## Local runtime sebagai otak alternatif

Mental model:

SH
↓
Model Runtime Interface
├── CLOUD
│   └── remote model/provider
└── LOCAL
    └── GGUF / native Android runtime

Jika online:

SH → remote brain

Jika offline dan local model tersedia:

SH → local brain

Model/provider tetap bukan identitas SH.

## Offline bukan sekadar cache

Jika offline mode benar-benar dikembangkan, kemungkinan perlu memikirkan:
- local state
- local database
- sync engine
- conflict resolution
- source-of-truth rules
- offline-created records
- deletion synchronization
- ordering
- authentication/session handling
- local attachment storage
- encryption/privacy
- capability availability rules

Karena itu offline SH tidak ideal dibuat sekadar sebagai cache chat.

## Local + cloud hybrid

Kemungkinan jangka panjang:

SH
↓
Data / State Layer
├── Remote Store
│   └── Supabase atau provider lain
└── Local Store
    └── device

Online:
- Remote Brain
- Remote Storage
- Tools
- Web

Offline:
- Local State
- Local Memory
- Local Knowledge
- Local Journey
- Local Tools
- Optional Local Brain

Masih berupa ide, bukan keputusan arsitektur.

## Arah gabungan

Brainstorming sampai titik ini mengarah pada mental model:

SOUL
↓
BRAIN
↓
SENSES
↓
HANDS
↓
AUTHORITY
↓
CONTINUITY
↓
PROVENANCE
↓
LIFECYCLE
↓
UX

Dengan kemungkinan implementation:

CLOUD BRAIN ↔ LOCAL BRAIN
REMOTE STORE ↔ LOCAL STORE

Namun semuanya tetap berada di bawah identitas dan runtime SH.

## Prinsip besar yang muncul

SH sebaiknya dibangun agar:

> **provider dapat diganti, tetapi identity SH tidak ikut berganti.**

Dan untuk infrastructure:

> **Supabase boleh menjadi rumah sekarang tanpa harus menjadi penjara arsitektur selamanya.**

Untuk local capability:

> **Offline/local adalah kemungkinan pengembangan, bukan alasan untuk membebani v0.1.0 dengan kompleksitas yang belum dibutuhkan.**

---

# CATATAN SESI TERKINI

Diskusi setelah v0.1.0 sekarang mencakup tiga jalur besar:

1. **Product identity** — SH bukan chatbot dan bukan sekadar personal AI assistant.
2. **Capability expansion** — Brain, Soul, Senses, Hands, Authority, Continuity, Provenance, Lifecycle.
3. **Product quality** — modern UX, multimodal, image generation, tools, provider portability, dan kemungkinan local/offline runtime.

Belum ada keputusan final bahwa seluruh jalur tersebut harus masuk v1.0.0.

Resume 69 tetap menjadi tempat eksplorasi sampai arah pengembangan cukup matang untuk dirumuskan menjadi candidate scope atau keputusan resmi.


---

# BRAINSTORMING — ROADMAP PENGEMBANGAN V1.0.0

Roadmap ini **belum merupakan roadmap resmi/implementation plan**. Ini hanya bentuk sementara dari obrolan kita supaya urutan gagasan tidak hilang.

Satu keputusan terminologi yang muncul: **jangan memakai kata "Phase" untuk jalur V1.0.0**. SH sudah memiliki Phase/phase history tersendiri, sehingga istilah baru lebih aman agar tidak terjadi tracking/history confusion.

Istilah sementara: **V1.0 Development Track** dengan milestone bernomor.

## Draft alur yang sedang dipikirkan

```
V1.0-00  Product Direction / Definition Lock
              ↓
V1.0-01  Foundation Audit + Freeze
              ↓
V1.0-02  Modern UX / UI
              ↓
V1.0-03  Multimodal + Image Generation
              ↓
V1.0-04  Memory / Knowledge / Experience / Journey
              ↓
V1.0-05  Hands + Tools + Authority
              ↓
V1.0-06  Provider / Infrastructure Portability
              ↓
V1.0-07  Local Storage + Offline
              ↓
V1.0-08  Local AI Runtime / GGUF
              ↓
V1.0-09  Integration + Hardening + QA
              ↓
V1.0-RC  Release Candidate
```

## Kenapa ada V1.0-00?

Sebelum membangun banyak fitur, perlu ada ruang untuk mengunci arah produk secara konseptual:

- SH mau menjadi apa?
- apa pembeda utamanya?
- apa arti "jiwa / otak / indera / tangan" secara produk?
- seperti apa modern UX SH?
- capability minimum apa yang layak disebut V1.0.0?

Ini bukan perubahan Canonical. Justru supaya brainstorming tidak langsung berubah menjadi implementation scope.

## Kenapa ada Foundation Audit + Freeze?

v0.1.0 sudah berfungsi sebagai functional foundation/proving ground. Sebelum redesign besar, ide yang muncul adalah audit kondisi foundation terlebih dahulu lalu membekukan baseline yang dianggap stabil.

Audit dapat mencakup:
- surface yang sudah functional
- surface yang masih partial/cosmetic
- error handling
- persistence
- isolation
- attachment/multimodal foundation
- integration antar fitur

Belum diputuskan detail audit maupun arti "freeze" secara formal.

## Modern UX / UI

Target bukan membuat "SH Lite" dan bukan clone ChatGPT.

Mental model:

> **SECOND HEAD tetap SECOND HEAD, tetapi UX/UI dibuat modern dan familiar seperti produk AI modern, dalam client yang tetap ringan di HP.**

Referensi boleh datang dari ChatGPT, Qwen Studio, Claude, dan produk lain, tetapi identitas SH harus tetap berbeda.

## Multimodal + Image Generation

Multimodal berkembang dari attachment/file/photo/camera menjadi capability yang lebih utuh.

Image generation juga mulai dianggap capability SH sendiri:

user → request → SH Runtime → image generation capability → image result → save/share/download

Bukan sekadar tombol tempelan.

## Continuity refinement

Memory / Knowledge / Experience / Journey perlu dipikirkan sebagai sistem continuity SH, bukan sekadar kumpulan halaman.

Kemungkinan fokus:
- UX discovery
- relationship antar data
- provenance
- Journey → source/conversation
- search
- lifecycle

## Hands + Tools + Authority

Jika SH bukan chatbot, maka SH perlu mempunyai "tangan" untuk melakukan sesuatu.

Konsep awal:

SH → capability/tool → authorization → execution → result → record

Semakin kuat action capability, semakin penting permission, owner confirmation, authority boundary, dan auditability.

## Provider / Infrastructure Portability

Portability dipandang sebagai cara menjaga identity SH tetap stabil ketika implementation provider berubah.

Target konseptual:

```
SH App
  ↓
SH Runtime / Contracts
  ↓
Infrastructure layer
  ├── Supabase
  ├── provider lain
  └── local store
```

Untuk model:

```
SH Runtime
  ↓
Model Runtime Interface
  ├── Provider A
  ├── Provider B
  ├── Provider C
  └── Local model
```

Supabase tetap infrastructure saat ini. GitHub tetap rumah source code. Portability tidak berarti harus pindah sekarang.

## Local Storage + Offline

Offline dipandang sebagai capability yang lebih luas daripada cache.

Kemungkinan:
- membaca conversation/memory/knowledge/journey saat offline
- draft
- local attachment
- local state
- sync saat online
- conflict resolution
- deletion synchronization
- authentication/session rules

Tidak semua harus offline. Capability cloud seperti web search atau cloud model tetap bisa membutuhkan koneksi.

## Local AI Runtime / GGUF

Target pengalaman yang dibayangkan:

```
SH APK
  ↓
import/download GGUF
  ↓
SH mendeteksi model
  ↓
local inference engine
  ↓
jawaban tanpa Termux/service manual
```

Model tidak harus dibundel ke APK; dapat berada di device storage. Lokasi storage dan engine belum diputuskan.

Preferensi utamanya adalah **integrated Android experience**, bukan workflow Termux.

## Integration + Hardening + QA

Setelah capability besar masuk, perlu tahap untuk memastikan fitur tidak hanya bekerja sendiri-sendiri.

Contoh risiko:

```
attachment
 + memory
 + knowledge
 + project
 + tool
 + streaming
 + regenerate
```

harus tetap konsisten ketika dipakai bersamaan.

Kemungkinan cakupan:
- integration testing
- failure handling
- performance
- security/isolation
- persistence
- cross-feature behavior
- release regression

## Release Candidate

V1.0-RC adalah checkpoint ketika capability dan UX sudah dianggap cukup matang untuk diuji sebagai produk, bukan sekadar kumpulan feature.

Belum ada definisi acceptance criteria final.

---

# CATATAN: URUTAN INI BOLEH BERUBAH

Roadmap di atas adalah **hasil brainstorming saat ini**.

Boleh:
- ditambah
- dikurangi
- dipindah urutannya
- dipecah menjadi beberapa milestone
- digabung
- dibatalkan

Tidak ada item di sini yang otomatis menjadi Canonical atau scope implementation.

Tujuan roadmap sementara ini hanya:

> **membantu kita melihat arah besar tanpa mengunci tangan kita terlalu cepat.**


---

# UPDATE TERBARU — IMPLEMENTATION MAP, PROVIDER BOUNDARY, DAN CARA TRACKING AUDIT

Diskusi kemudian masuk ke pertanyaan yang lebih teknis: bagaimana membedakan **SH Runtime**, **functions**, dan infrastructure provider, serta bagaimana melakukan audit tanpa harus membuka ulang seluruh sejarah 800+ commit.

## Current implementation map

Kita membuat working reference terpisah:

`docs/architecture/SECOND_HEAD_CURRENT_IMPLEMENTATION_MAP_DEV.md`

Dokumen ini **NON-CANONICAL**.

Mental model yang dipakai:

```
SECOND HEAD
│
├── app/
│   └── mobile application / UI / client interaction
│
├── functions/
│   └── server-side executable/deployment units
│       └── runtime-p4a-001/
│
├── database/
│   └── database artifacts
│       └── migrations/
│
└── docs/
    ├── canonical/
    ├── architecture/
    └── resume/
```

### Function vs Runtime

Pembeda istilah yang disepakati untuk mempermudah diskusi:

- **SH Runtime** = konsep/sistem runtime SH yang melakukan processing/orchestration.
- **Function** = executable server-side unit.
- **runtime-p4a-001** = current function/deployment unit yang membawa runtime implementation.
- **Supabase Edge Function** = infrastructure execution mechanism yang saat ini dipakai.

Jadi `functions/` tidak boleh otomatis dianggap sinonim seluruh SH Runtime.

## Provider boundary

Current state yang ditemukan:

```
                  SH
                   │
          ┌────────┴────────┐
          │                 │
      Application        Runtime
          │                 │
          ↓                 ↓
   backend.ts          current functions
          │                 │
          └────────┬────────┘
                   ↓
             Supabase DEV
              │         │
              ↓         ↓
          PostgreSQL   Edge Functions
```

Supabase masih merupakan current infrastructure/provider.

Application backend access sekarang mempunyai boundary di:

`app/services/backend.ts`

Ini lebih baik daripada feature/UI layer tersebar memakai modul bernama provider.

Tetapi **SH belum true multi-database/provider**.

Yang masih provider-coupled antara lain:
- `app/services/backend.ts` implementation;
- Supabase Auth;
- Supabase Edge Function deployment;
- server-side Supabase/database client calls.

Jadi portability saat ini adalah **arah/boundary**, bukan klaim drop-in provider switching.

## Database repository structure

Prinsip yang ditegaskan:

`database/` tetap menjadi lokasi general untuk database artifacts.

Migration source:

`database/migrations/`

Tidak perlu:

`database/supabase/`

Supabase adalah provider/infrastructure saat ini; PostgreSQL adalah database engine yang mendasarinya.

Tujuan struktur ini adalah supaya suatu hari provider database bisa diganti tanpa harus mengubah identitas/nama folder database artifacts.

## Provider portability — prinsip brainstorming

Target jangka panjang:

```
SH
 ↓
SH Runtime / contracts
 ↓
Infrastructure / data boundary
 ↓
Supabase / PostgreSQL provider lain / local
```

Tetapi kita sepakat tidak membangun abstraction berlebihan sekarang hanya untuk mengejar label "multi-database".

Prinsip:

> **Don't make SH permanently Supabase-dependent.**

Dan sekaligus:

> **Jangan membuat portability abstraction berlebihan sebelum ada kebutuhan nyata.**

## GitHub sebagai source-code home

GitHub tetap dipandang sebagai rumah source code/workflow:

- source control
- branch
- commit
- CI/CD
- artifact/build lineage
- audit

Tidak ada alasan mengganti GitHub hanya demi portability database.

## Audit/tracking baseline

Muncul pertanyaan apakah audit harus dimulai dari commit awal atau commit terbaru.

Kesimpulan brainstorming:

> **Audit kondisi sekarang dimulai dari latest verified DEV baseline.**

Tidak perlu replay 800+ commit untuk audit normal.

Flow:

```
CURRENT / VERIFIED DEV BASELINE
        ↓
     AUDIT
        ↓
     FINDING
        ↓
       FIX
        ↓
    VERIFY
```

History Git baru dibuka jika diperlukan untuk:
- regression
- mencari commit penyebab perubahan
- menelusuri migration
- memahami asal dependency
- investigasi anomaly

Prinsip:

> **Latest verified state adalah titik awal audit. History adalah alat investigasi, bukan titik awal default.**

## Audit architecture vs Canonical

Current implementation map hanya menjawab:

> "Bagaimana system SH saat ini direpresentasikan oleh code DEV?"

Canonical tetap authority.

Jika implementation berbeda dari Canonical, jangan diam-diam menganggap implementation tersebut sebagai perubahan Canonical. Catat sebagai implementation state/gap dan audit lebih lanjut.

## Dokumen audit provider

Kita juga membuat:

`docs/architecture/SH_PROVIDER_DEPENDENCY_AUDIT_DEV_2026-08-28.md`

Dokumen ini juga **NON-CANONICAL** dan berisi hasil audit dependency provider pada DEV.

Audit tersebut tidak melakukan reset/replay/mutation terhadap database DEV.

---

# POSISI TERBARU RESUME 69

Brainstorming sekarang tidak hanya membahas "fitur apa yang kurang", tetapi mulai membentuk cara berpikir pengembangan SH:

```
PRODUCT IDENTITY
      ↓
CAPABILITIES
      ↓
MODERN UX
      ↓
RUNTIME / PROVIDER BOUNDARIES
      ↓
LOCAL / CLOUD POSSIBILITY
      ↓
AUDITABLE IMPLEMENTATION
```

Namun semua ini tetap berada di wilayah brainstorming/working reference sampai ada keputusan formal.

**Canonical tidak berubah.**

END UPDATE


---

# UPDATE TERBARU — MODERN UX, RESPONSIVE / WEB APPLICABILITY

Dari eksplorasi visual Workstream B muncul satu masukan product/UX yang layak disimpan di Resume 69 sebelum hilang:

## Modern UX tidak harus mobile-only

Arah V1.0 tetap **mobile-first** karena SH saat ini dibangun dan diverifikasi terutama sebagai Android application.

Namun interaction model yang sedang dieksplorasi — conversation-first, drawer/sidebar, conversation history, contextual surfaces, composer, attachment/capability picker — secara alami dapat dibuat **responsive**.

Bayangan konseptual:

```text
PHONE
→ drawer/sheet
→ conversation full-screen
→ contextual surface sebagai sheet

TABLET
→ navigation + conversation
→ contextual panel bila ruang memungkinkan

WEB / DESKTOP
→ persistent sidebar
→ conversation center
→ optional contextual panel
```

Ini membuka kemungkinan bahwa **SH dapat memiliki web-based experience/client di masa depan**, tanpa berarti web menjadi scope V1.0 saat ini.

Prinsip desain yang muncul:

> **Design once, adapt across surfaces.**

Artinya interaction model sebaiknya tidak sengaja dikunci pada layout Android saja jika keputusan desain yang sama dapat diterapkan secara responsive pada mobile, tablet, dan web.

## Applicability vs commitment

Ini masih **IDE / PRODUCT DIRECTION CANDIDATE**, bukan commitment.

Pertanyaan yang perlu dieksplorasi nanti:
- apakah web menjadi client resmi SH?
- apakah web dan Android berbagi interaction model yang sama?
- capability apa yang cocok/berbeda di web?
- bagaimana local/offline capability dipetakan antara Android dan web?
- apakah web membutuhkan workspace/sidebar yang lebih persistent?
- bagaimana menjaga identity dan continuity SH tetap sama lintas client?

Tidak perlu membuat web client sekarang hanya karena arah desain memungkinkan.

Yang penting:

> **Jangan membuat V1.0 UX yang secara tidak perlu mengunci SH hanya pada Android jika ada kemungkinan SH juga akan hadir sebagai web experience.**

Ini adalah brainstorming Resume 69, bukan perubahan Canonical dan bukan keputusan implementation.


---

# UPDATE TERBARU — C8 IMAGE GENERATION & PROVIDER/MODEL CONFIGURATION

Workstream C sekarang sudah mencapai C-Close. Seluruh C1–C8 telah dilaporkan GREEN melalui DEV verification, termasuk C8 image-generation provider/runtime path.

## Yang sudah terealisasi dari brainstorming Resume 69

### Multimodal capability

Resume 69 sebelumnya membayangkan evolusi:

```
image → question → reasoning → answer
```

Sekarang jalur tersebut sudah mempunyai implementation evidence melalui C3/C6/C7: first-class image input, multimodal conversation continuity, dan explicit image-understanding task routing.

### Image generation

Ide yang sebelumnya masih berupa:

```
user → "buatkan gambar..."
→ SH Runtime
→ image generation capability
→ hasil gambar
→ save/share/download
```

sekarang sudah mempunyai provider/runtime implementation path pada C8.

Provider yang dipilih untuk implementation saat ini adalah **OpenRouter Unified Image API**. Ini adalah implementation choice, bukan Canonical provider lock.

C8 juga sengaja memakai **explicit paid-capability gate**. Image generation tidak dimasukkan ke automatic zero-budget routing.

## Ide baru yang muncul dari implementasi C8

Pengalaman provider image menunjukkan pentingnya memisahkan **provider/model configuration** dari APK/client code.

Arah yang layak dieksplorasi:

```
SH App
   ↓
SH Runtime / Contracts
   ↓
Provider / Model Registry
   ├── Provider A
   │    ├── model 1
   │    └── model 2
   ├── Provider B
   └── Provider C
```

Target konseptualnya:

> Ganti provider/model sebisa mungkin melalui runtime/configuration surface tanpa rebuild APK hanya karena model/provider berubah.

Namun ini **belum implemented dan belum menjadi keputusan arsitektur**.

Hal yang masih perlu dipikirkan:
- siapa yang boleh melakukan override;
- automatic routing vs manual override;
- fallback behavior;
- cost/zero-budget policy;
- capability compatibility;
- image vs text vs vision provider contract;
- bagaimana configuration tetap berada di bawah authority SH.

Referensi pola dari proyek MiRA hanya dipakai sebagai inspiration/pattern reference. MiRA tetap proyek terpisah dan tidak menjadi dependency SH.

## Audit Resume 69 — status brainstorming vs implementation

```
SUDAH PUNYA IMPLEMENTATION EVIDENCE
├── Modern UX / contextual surfaces — Workstream B
├── Journey continuity surface — Workstream B
├── Attachment lifecycle
├── Multiple attachments
├── Image input
├── File intelligence — bounded supported classes
├── Camera input
├── Multimodal conversation continuity
├── Image understanding
└── Image generation provider/runtime path

MASIH PARTIAL / PERLU REFINEMENT
├── Memory / Knowledge / Experience owner experience
├── Global continuity semantics
├── Error/loading/empty UX consistency
├── Hands / Tools / Authority
└── Lifecycle end-to-end semantics

MASIH BRAINSTORMING / BELUM IMPLEMENTED
├── Global SH Search
├── Voice / Audio
├── broad Plugins / Extensions / Integrations
├── Projects sebagai full product capability
├── general provider/database switching
├── full Offline / Local-first SH
├── integrated local GGUF runtime
├── official Web client
└── runtime-configurable Provider / Model Registry
```

Catatan penting: **implementation evidence tidak otomatis mengubah ide Resume 69 menjadi Canonical.** Resume 69 tetap non-Canonical dan berfungsi sebagai living brainstorming record.

## Workstream C closure

```
C1 🟢
C2 🟢
C3 🟢
C4 🟢
C5 🟢
C6 🟢
C7 🟢
C8 🟢
C-Close 🟢 CLOSED
```

C-Close berarti implementation/verification boundary Workstream C sudah ditutup. Future multimodal ideas tetap dapat muncul di Resume 69 tanpa membuka kembali Workstream C.

---

END UPDATE
