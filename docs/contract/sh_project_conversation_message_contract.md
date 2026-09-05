# SECOND HEAD — Project, Conversation, Message Contract

## Status

**Approved working contract untuk scope Project → Conversation → Message.**

Dokumen ini menjadi acuan kerja untuk perapihan struktur, UI/UX, service, runtime integration, backend contract, dan verification pada scope ini.

Dokumen ini **bukan Canonical** dan tidak mengubah Canonical. Jika terdapat konflik dengan Canonical atau keputusan yang lebih tinggi, Canonical dan authority yang lebih tinggi tetap berlaku.

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
- backend capability yang sudah tersedia dan yang masih menjadi gap;
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
2. Jangan menganggap capability sudah tersedia hanya karena UI dapat dibuat.
3. Backend contract harus mendukung semantics yang ditampilkan UI.
4. Mutation data tetap melalui runtime/RPC boundary yang sesuai.
5. Tidak membuat visual language baru; UI mengikuti design language SH yang sudah ada.
6. Jika prerequisite atau backend capability belum tersedia, implementation tidak boleh menganggapnya selesai.

---

## 3. Model Relasi

Relasi yang menjadi dasar scope:

```text
accounts
  └─ sh_instances
      ├─ projects
      └─ conversation_threads
           └─ conversations
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

Untuk tahap ini, **UX Delete Project disiapkan terlebih dahulu**. Backend execution belum menjadi bagian dari implementation sampai backend contract disepakati dan tersedia.

UX harus menyediakan confirmation yang jelas sebelum destructive action.

Jika semantics final menyatakan bahwa penghapusan Project menghapus Conversation yang masih berada di dalamnya, maka Messages yang menjadi child Conversation ikut terhapus melalui lifecycle Conversation.

Namun, semantics tersebut **tidak boleh diasumsikan sebagai behavior database saat ini**. Implementasi backend harus dibuat eksplisit dan transactional ketika capability tersebut masuk execution scope.

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

Runtime capability yang sudah tersedia untuk target ini adalah:

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
- Clear behavior sesuai semantics yang telah ditetapkan dan hasil validasi final.

### 6.1 Clear vs Delete

Canonical membedakan Clear dan Delete.

```text
Clear
→ membersihkan isi chat / message dari tampilan atau state yang ditetapkan
→ Conversation tetap ada

Delete Conversation
→ menghapus Conversation
→ child Messages mengikuti lifecycle deletion Conversation
```

Behavior persistence/recovery untuk Clear masih harus divalidasi sebelum dianggap final sebagai implementation behavior baru.

Contract ini tidak mengubah Canonical Clear semantics.

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

Search harus menggunakan pattern/design search SH yang sudah ada. Tidak membuat visual language search baru.

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

Struktur target:

```text
features/
│
├── conversation/
│   ├── conversation_view.dart
│   ├── conversation_service.dart
│   ├── conversation_runtime_bridge.dart
│   └── widgets/
│
├── project_conversation/
│   ├── project_conversation_management_view.dart
│   └── widgets/
│       ├── project_section.dart
│       ├── project_item.dart
│       ├── conversation_section.dart
│       └── conversation_item.dart
│
├── chat/
│   └── ...
│
├── journey/
│   └── ...
│
├── lifecycle/
│   └── ...
│
├── profile/
│   └── ...
│
├── more/
│   ├── side_menu.dart
│   ├── more_widgets.dart
│   ├── about/
│   └── help_support/
│
└── auth/
    └── ...
```

Boundary utama:

- `conversation/` menangani conversation runtime dan conversation surface yang sudah ada.
- `project_conversation/` menangani management UI Project + Conversation.
- `more/side_menu.dart` menangani Sidebar/navigation, bukan seluruh management implementation.
- Feature Journey, Lifecycle, Profile, Auth, About, dan Help & Support tetap berada pada boundary masing-masing.

Contract ini tidak memaksa pemecahan `domain/data/presentation` apabila belum ada kebutuhan arsitektural yang nyata. Extraction model/service dilakukan hanya bila justified oleh boundary implementation.

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

Refactor tidak boleh mengubah semantics hanya untuk merapikan folder.

Model existing yang saat ini diekspos melalui `conversation_service.dart` dapat dipertahankan sementara. Pemindahan model ke file/layer lain hanya dilakukan bila dibutuhkan untuk boundary yang lebih jelas.

---

## 11. Backend Capability Matrix

### Sudah tersedia

| Capability | Runtime | Status |
|---|---|---|
| Create Project | `runtime_create_project` | Ada |
| List Project | `runtime_list_projects` | Ada |
| Create Conversation | `runtime_create_conversation` | Ada |
| List Conversation | `runtime_list_conversations` | Ada |
| Rename Conversation | `runtime_rename_conversation_thread` | Ada |
| Delete Conversation | `runtime_delete_conversation_thread` | Ada |
| Delete Message | `runtime_delete_conversation_message_v2` | Ada |

### Masih menjadi backend gap

| Capability | Target | Status |
|---|---|---|
| Rename Project | `runtime_rename_project` atau contract equivalent | Belum tersedia |
| Delete Project | `runtime_delete_project` atau contract equivalent | Belum tersedia |
| Move Conversation | runtime capability yang mendukung assignment | Belum tersedia |
| Remove from Project | assignment ke `project_id = NULL` | Belum tersedia |

Nama RPC final untuk capability yang belum tersedia **belum dikunci** oleh contract ini. Yang dikunci adalah capability dan semantics-nya.

---

## 12. Database Constraint yang Harus Diperhatikan

Current relationship:

```text
conversation_threads.project_id
        ↓
projects.project_id
```

saat ini menggunakan:

`ON DELETE SET NULL`

Dengan demikian, direct database deletion terhadap Project saat ini tidak memenuhi semantics Delete Project yang menghapus Conversation di dalamnya.

Karena itu:

- jangan mengandalkan FK existing untuk Delete Project;
- jangan mengimplementasikan destructive behavior di client;
- backend deletion harus memiliki explicit contract dan transaction boundary ketika execution dimulai.

Conversation deletion menggunakan hierarchy baru:

```text
conversation_threads
        ↓ ON DELETE CASCADE
conversations
```

Ini sesuai dengan lifecycle Delete Conversation yang menjadi target contract.

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

---

## 14. Verification Contract

Implementation scope ini belum dianggap selesai hanya karena UI tampil.

Minimum verification:

### Project

- Create
- List
- Rename
- Delete UX
- Empty Project
- Project dengan Conversation

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
- Clear behavior setelah validasi

### Integration

- Sidebar refresh
- Management refresh
- Active Conversation consistency
- Navigation consistency
- Loading/error state
- Backend failure tidak menghasilkan false success

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
5. Move dan Remove from Project memiliki backend capability yang benar sebelum diaktifkan penuh.
6. Delete Conversation menggunakan hierarchy/thread deletion yang benar.
7. Delete Project tidak dieksekusi sebelum backend semantics tersedia dan diverifikasi.
8. Clear tidak disamakan dengan Delete.
9. Semua mutation melewati runtime/backend boundary yang sesuai.
10. Verification mencakup behavior, error, state, dan regression yang relevan.

---

## 16. Open Items / Tidak Boleh Dianggap Selesai

Item berikut tetap terbuka dan tidak boleh diam-diam dianggap solved:

- Project Rename backend capability.
- Project Delete backend capability dan exact transaction semantics.
- Conversation Move backend capability.
- Remove Conversation from Project backend capability.
- Final validation terhadap Clear behavior.
- Management search integration.
- Full Sidebar responsibility refactor.
- Google Login regression audit.

Open item berarti **belum ready untuk execution penuh**, bukan alasan untuk membuat workaround yang mengubah semantics.

---

## 17. Execution Rule

Urutan kerja yang mengikuti contract ini:

```text
Contract
   ↓
Folder / Responsibility
   ↓
Backend Gap
   ↓
Management UI
   ↓
Service / Bridge Integration
   ↓
End-to-End Verification
   ↓
Regression Validation
```

Tidak boleh membalik dependency dengan membuat UI mengasumsikan backend capability yang belum ada.

---

## 18. Perubahan terhadap Canonical

Tidak ada.

Dokumen ini merupakan approved working contract untuk scope Project → Conversation → Message. Setiap perubahan yang menyentuh semantics Canonical harus diproses melalui authority Canonical yang sesuai dan tidak dilakukan melalui perubahan sepihak pada dokumen ini.
