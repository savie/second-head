# SECOND HEAD — Project, Conversation, Message Contract

## Status

**Approved working contract untuk scope Project → Conversation → Message.**

Dokumen ini menjadi acuan kerja untuk perapihan struktur, UI/UX, service, runtime integration, backend contract, dan verification pada scope ini.

Dokumen ini **bukan Canonical** dan tidak mengubah Canonical. Jika terdapat konflik dengan Canonical atau keputusan yang lebih tinggi, Canonical dan authority yang lebih tinggi tetap berlaku.

Dokumen ini telah direkonsiliasi terhadap current `dev` implementation. Capability matrix di bawah membedakan **contract semantics** dari **current implementation evidence**; keberadaan implementation tidak dengan sendirinya mengubah authority contract.

---

## 1. Tujuan dan Boundary

Scope contract ini adalah pengelolaan tiga tingkat utama:

```text
Project
   ↓
Conversation
   ↓
Message
```

Contract mencakup:

- struktur dan tanggung jawab feature;
- hubungan Project, Conversation, dan Message;
- behavior utama create, list, rename, move, clear, dan delete;
- Sidebar dan management surface;
- boundary frontend ↔ runtime ↔ Supabase;
- backend capability dan current implementation status;
- UI state dan verification yang wajib dijaga.

Contract ini tidak memperluas scope ke redesign visual SH atau perubahan semantics Journey/Lifecycle.

---

## 2. Authority dan Prinsip Kerja

Urutan authority tetap:

```text
Canonical
   ↓
Approved Contract
   ↓
Architecture / Design
   ↓
Implementation
```

`dev_old` dapat digunakan sebagai reference/evidence, tetapi historical implementation tidak menjadi baseline implementation baru.

Prinsip kerja:

1. Jangan mengubah Canonical melalui contract ini.
2. Jangan menganggap capability sudah benar secara semantic hanya karena UI atau RPC sudah ada.
3. Backend contract harus mendukung semantics yang ditampilkan UI.
4. Mutation data tetap melalui runtime/RPC boundary yang sesuai.
5. Tidak membuat visual language baru; UI mengikuti design language SH yang sudah ada.
6. Jika prerequisite atau backend capability belum tersedia, implementation tidak boleh menganggapnya selesai.
7. Current implementation evidence harus direkonsiliasi kembali bila contract berubah.

---

## 3. Model Relasi

Relasi yang menjadi dasar scope current DEV:

```text
accounts
  └─ sh_instances
      ├─ projects
      └─ conversation_threads
           └── conversations
```

Pada level application:

```text
Project
├── Conversation
│   ├── Message
│   ├── Message
│   └── ...
├── Conversation
│   └── ...
└── ...
```

Conversation dapat berada di dalam Project atau tidak memiliki Project (`No Project`).

```text
Project A
   └── Conversation 1

Project B
   └── Conversation 2

No Project
   └── Conversation 3
```

Conversation dapat dipindahkan antar-Project dan dapat dikeluarkan dari Project menjadi `No Project`.

---

## 4. Project Contract

### 4.1 Capability

Project harus mendukung:

- Create
- List
- Rename
- Delete

Sidebar menyediakan akses ringkas melalui:

```text
Project
├── New Project
├── Recent Projects ≤5
└── View All
```

Management surface menyediakan pengelolaan penuh.

### 4.2 Delete Project

Delete Project merupakan destructive capability yang harus memiliki confirmation, backend authorization, dan explicit transaction semantics.

Current DEV sudah memiliki runtime path `runtime_delete_project`; current frontend juga sudah memanggil capability tersebut. Namun keberadaan path tersebut **bukan** pengganti authenticated semantic verification.

Jika semantics final menyatakan bahwa penghapusan Project menghapus Conversation yang masih berada di dalamnya, maka Messages yang menjadi child Conversation ikut terhapus melalui lifecycle Conversation. Semantics tersebut harus tetap dibuktikan dari current backend implementation dan verification.

---

## 5. Conversation Contract

Conversation harus mendukung:

- Create dengan Project tertentu;
- Create tanpa Project;
- List;
- Open / Select;
- Rename;
- Move ke Project lain;
- Remove from Project → `No Project`;
- Delete.

Sidebar:

```text
Conversation
├── New Conversation
├── Recent Conversations ≤5
└── View All
```

Conversation management dilakukan pada management surface, bukan dengan menjadikan Sidebar sebagai pusat seluruh CRUD logic.

### 5.1 Delete Conversation

Canonical distinction tetap berlaku:

```text
Delete Conversation
        ↓
Delete conversation thread
        ↓
Child messages ikut terhapus
```

Untuk hierarchy baru, execution path yang menjadi target adalah deletion pada `conversation_threads`, bukan legacy deletion pada `conversations`.

Runtime capability current DEV:

`runtime_delete_conversation_thread`

Legacy `runtime_delete_conversation` tidak menjadi path untuk architecture hierarchy baru.

---

## 6. Message Contract

Message adalah isi chat yang berada di dalam Conversation.

Tidak dibuat table Message baru untuk scope ini. Existing `public.conversations` tetap menjadi storage Message pada hierarchy yang berjalan saat ini.

Capability yang perlu dipertahankan:

- Load messages;
- Record message;
- Update message;
- Delete individual message;
- Clear sebagai non-destructive presentation/state behavior sesuai semantics contract.

### 6.1 Clear vs Delete

Approved semantic boundary:

```text
Clear ≠ Delete
```

Clear adalah **non-destructive** terhadap durable Conversation data:

```text
Clear
→ Conversation tetap ada
→ Message tidak dihapus
→ Attachment tidak dihapus
→ Recovery snapshot tidak dihapus
→ tidak mengubah ownership
→ tidak mengubah SH identity
```

Clear boleh mengubah tampilan atau state presentation/session yang ditetapkan oleh design/implementation, tetapi detail scope dan persistence state tersebut bukan alasan untuk mengubah Clear menjadi operasi deletion.

Delete Conversation tetap merupakan destructive operation:

```text
Delete Conversation
→ menghapus Conversation thread
→ child Messages mengikuti lifecycle deletion
```

Current FE yang masih melakukan deletion individual Message ketika user memilih Clear adalah **implementation gap terhadap contract**, bukan semantics yang valid.

Contract ini tidak mengubah Canonical; ia mengunci boundary `Clear ≠ Delete` untuk scope Project → Conversation → Message.

---

## 7. Management Surface

Disiapkan satu surface untuk pengelolaan Project dan Conversation:

```text
ProjectConversationManagementView
│
├── Search
│
├── Projects
│   ├── Create
│   ├── Rename
│   └── Delete
│
└── Conversations
    ├── Create
    ├── Rename
    ├── Move
    ├── Remove from Project
    └── Delete
```

Current DEV memang memiliki `ProjectConversationManagementView` dengan operation tersebut. Search saat ini adalah local filtering terhadap loaded Project/Conversation summaries; ini bukan bukti backend search capability terpisah.

Management surface wajib mengikuti visual language dan interaction pattern SH yang sudah berjalan.

---

## 8. Sidebar Boundary

Target tanggung jawab Sidebar:

```text
SideMenu
├── Navigation
│   ├── Journey
│   ├── Lifecycle
│   └── Profile
├── Project
│   ├── New Project
│   ├── Recent Projects ≤5
│   └── View All
├── Conversation
│   ├── New Conversation
│   ├── Recent Conversations ≤5
│   └── View All
├── Quick Actions
│   ├── Help & Support
│   └── About
└── Log Out
```

Sidebar berfokus pada navigation dan recent items.

Logic CRUD dan management yang lebih kompleks tidak ditempatkan seluruhnya di `SideMenu`.

---

## 9. Feature / Folder Boundary

Current implementation menggunakan:

```text
features/
├── conversation/
├── project_conversation/
├── chat/
├── journey/
├── lifecycle/
├── profile/
├── more/
└── auth/
```

Boundary utama:

- `conversation/` menangani conversation runtime dan conversation surface yang sudah ada.
- `project_conversation/` menangani management UI Project + Conversation.
- `more/side_menu.dart` menangani Sidebar/navigation, bukan seluruh management implementation.
- Feature Journey, Lifecycle, Profile, Auth, About, dan Help & Support tetap berada pada boundary masing-masing.

Contract ini tidak memaksa pemecahan `domain/data/presentation` apabila belum ada kebutuhan arsitektural yang nyata. Extraction model/service dilakukan hanya bila dibutuhkan untuk boundary yang lebih jelas.

---

## 10. Service dan Runtime Boundary

Current runtime path tetap menjadi dasar:

```text
UI
 ↓
ConversationService / adapter
 ↓
backendClient
 ↓
Supabase RPC
 ↓
Database
```

`ConversationRuntimeBridge` tetap menjadi adapter yang mendelegasikan capability ke service yang ada.

Current Flutter evidence menunjukkan `ConversationService` memanggil RPC untuk list/create/rename/delete Project, create/list/select/rename/delete Conversation, move/remove Conversation, load/record/update/delete Message, dan context loading.

Refactor tidak boleh mengubah semantics hanya untuk merapikan folder.

Model existing yang saat ini diekspos melalui `conversation_service.dart` dapat dipertahankan sementara. Pemindahan model ke file/layer lain hanya dilakukan bila dibutuhkan untuk boundary yang lebih jelas.

---

## 11. Backend Capability Matrix — Reconciled

| Capability | Current runtime path | Current FE consumer | Current status |
|---|---|---|---|
| Create Project | `runtime_create_project` | `ConversationService` | CURRENT / implemented |
| List Project | `runtime_list_projects` | `ConversationService` | CURRENT / implemented |
| Rename Project | `runtime_rename_project` | `ConversationService` | CURRENT / implemented |
| Delete Project | `runtime_delete_project` | `ConversationService` | CURRENT / implemented; semantic verification required |
| Create Conversation | `runtime_create_conversation` | `ConversationService` | CURRENT / implemented |
| List Conversation | `runtime_list_conversations` | `ConversationService` | CURRENT / implemented |
| Rename Conversation | `runtime_rename_conversation_thread` | `ConversationService` | CURRENT / implemented |
| Delete Conversation | `runtime_delete_conversation_thread` | `ConversationService` | CURRENT / implemented |
| Move Conversation | `runtime_assign_conversation_project` | `ConversationService` | CURRENT / implemented |
| Remove from Project | `runtime_assign_conversation_project` with null project | `ConversationService` | CURRENT / implemented |
| Load Messages | `runtime_load_conversation_messages` | `ConversationService` | CURRENT / implemented |
| Record Message | `runtime_record_conversation_message` | `ConversationService` | CURRENT / implemented |
| Update Message | `runtime_update_conversation_message_v2` | `ConversationService` | CURRENT / implemented |
| Delete Message | `runtime_delete_conversation_message_v2` | `ConversationService` | CURRENT / implemented |
| Load Context | `runtime_load_conversation_context_for_thread` | `ConversationService` | CURRENT / implemented |

**Important:** `CURRENT / implemented` means the runtime path and FE consumer are present in current DEV. It does **not** mean authenticated adversarial verification, complete AI integration, or final semantic DoD has already passed.

---

## 12. Database Constraint

Current relationship:

```text
conversation_threads.project_id
        ↓
projects.project_id
```

Current hierarchy must be interpreted together with current migrations/backend implementation. Existing FK behavior alone is not sufficient evidence for complete Delete Project semantics.

Conversation deletion uses hierarchy baru:

```text
conversation_threads
        ↓ ON DELETE CASCADE
conversations
```

Target deletion path remains `runtime_delete_conversation_thread`.

---

## 13. UI State Contract

Action management wajib menangani state yang relevan:

```text
Normal
  ↓
Loading
  ↓
Success / Error
```

Untuk destructive action:

```text
Delete
  ↓
Confirmation
  ↓
Execution
  ↓
Success / Error
```

UI tidak boleh menampilkan state sukses sebelum backend operation benar-benar berhasil.

Empty state dan error state harus tersedia untuk list dan management surface sesuai kebutuhan flow.

Clear tidak boleh menggunakan destructive Message Delete sebagai implementation shortcut.

---

## 14. Verification Contract

Implementation scope ini belum dianggap selesai hanya karena UI tampil atau RPC tersedia.

Minimum verification:

### Project

- Create
- List
- Rename
- Delete
- Empty Project
- Project dengan Conversation
- destructive behavior dan authorization

### Conversation

- Create dengan Project
- Create tanpa Project
- List
- Open / Select
- Rename
- Move antar-Project
- Remove → No Project
- Delete

### Message

- Load
- Record
- Update
- Delete individual message
- Clear: memastikan Message/Conversation tetap durable dan tidak terhapus

### Integration

- Sidebar refresh
- Management refresh
- Active Conversation consistency
- Navigation consistency
- Loading/error state
- Backend failure tidak menghasilkan false success

### Security / isolation

- Account A own resources → ALLOW
- Account A → Account B resources → DENY
- spoofed identity → DENY
- unauthenticated protected mutation → DENY

### Regression

- Google Login tetap menjadi regression item terpisah.
- Signing/build behavior yang sudah solved tidak boleh diregresikan.
- Navigation drawer race fix tidak boleh diregresikan.

---

## 15. Definition of Done

Scope ini hanya dapat dinyatakan selesai jika:

1. Project, Conversation, dan Message memiliki boundary implementation yang jelas.
2. Sidebar tidak lagi menjadi pusat seluruh management logic.
3. Management surface menggunakan visual language SH yang sudah ada.
4. Conversation dapat dikelola dengan dan tanpa Project.
5. Move dan Remove from Project menggunakan backend capability yang benar dan terverifikasi.
6. Delete Conversation menggunakan hierarchy/thread deletion yang benar.
7. Delete Project memiliki backend semantics yang eksplisit dan terverifikasi.
8. Clear tidak disamakan dengan Delete.
9. Semua mutation melewati runtime/backend boundary yang sesuai.
10. Verification mencakup behavior, error, state, security isolation, dan regression yang relevan.
11. Dynamic AI response/runtime integration dibedakan dari conversation persistence/UI implementation.

---

## 16. Open Items / Tidak Boleh Dianggap Selesai

Item berikut tetap terbuka:

- authenticated adversarial verification untuk seluruh Project/Conversation/Message mutation;
- final validation terhadap Delete Project transaction semantics;
- implementation correction untuk current FE Clear behavior;
- dynamic AI conversation runtime/model integration;
- full Sidebar responsibility reconciliation;
- Google Login regression audit;
- full offline synchronization/conflict behavior;
- final Conversation contract closure terhadap broader SH continuity/AI semantics.

Open item berarti **belum ready untuk execution penuh**, bukan alasan untuk membuat workaround yang mengubah semantics.

---

## 17. Execution Rule

Urutan kerja yang mengikuti contract ini:

```text
Contract
   ↓
Current backend/runtime evidence
   ↓
Verification / confirmed gaps
   ↓
Management UI / FE integration
   ↓
End-to-End Verification
   ↓
Regression Validation
```

Tidak boleh membalik dependency dengan membuat UI mengasumsikan backend capability yang belum ada.

Untuk Clear, implementation hanya boleh dilanjutkan setelah state/presentation design ditetapkan tanpa mengubah boundary `Clear ≠ Delete`.

---

## 18. Perubahan terhadap Canonical

Tidak ada.

Dokumen ini merupakan approved working contract untuk scope Project → Conversation → Message. Setiap perubahan yang menyentuh semantics Canonical harus diproses melalui authority Canonical yang sesuai dan tidak dilakukan melalui perubahan sepihak pada dokumen ini.
