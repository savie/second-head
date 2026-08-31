# SH Foundation Blueprint

**Project:** SECOND HEAD  
**Version:** SH v1.0  
**Target implementasi repository:** dev  
**Status:** Baseline foundation hasil rekonstruksi

## 1. Tujuan

Blueprint ini menjadi foundation untuk fresh reconstruction SH v1.0.

Sumber kerja:

```
dev_old
   ↓
deep read + cross-reference
   ↓
dua audit DEV ↔ DEV_OLD
   ↓
reconstruct SH foundation
```

Blueprint bukan copy Canonical, bukan copy Resume, bukan copy Evolution, dan bukan copy old code.

Yang direkonstruksi adalah hubungan antara:

```
Canonical meaning
+
architecture
+
product intent
+
historical lessons
+
target capability
+
fresh implementation direction
```

## 2. Foundation yang Harus Dipertahankan

```
persistent identity;
account relationship;
ownership;
state;
context;
memory;
knowledge;
conversation;
continuity;
history;
governance;
privacy;
security;
runtime;
recovery;
backup / restore;
clone;
inheritance / legacy;
tools / actions;
core evolution.
```

SH bukan model-only dan bukan chat-application-only.

Hubungan sistem yang harus tetap masuk akal:

```
WHO
↓
OWNS WHAT
↓
KNOWS WHAT
↓
REMEMBERS WHAT
↓
CAN DO WHAT
↓
DID WHAT
↓
RECOVERS FROM WHAT
↓
CONTINUES FROM WHAT
```

## 3. Canonical Boundary

```
Model ≠ SH Identity;
Runtime ≠ SH Identity;
Database ≠ SH Identity;
Hardware ≠ SH Identity;
Account_ID ≠ SH_ID;
Session_ID ≠ SH_ID;
Memory ≠ SH Identity;
Context ≠ Memory;
Knowledge ≠ Memory;
Model ≠ Authority;
Tool ≠ Authority;
Runtime Access ≠ Ownership;
Evolution ≠ Ownership Transfer;
Recovery ≠ Clone Creation;
Clone ≠ Source SH;
Inheritance ≠ Clone;
Inheritance ≠ Automatic Identity Transfer.
```

Dan:

```
Privacy = DEFAULT DENY
Sharing = EXPLICIT AUTHORIZATION
Learning ≠ Automatic Core Modification
```

## 4. Application Foundation

Fresh application tidak ditujukan untuk mereproduksi historical UI.

Prioritas:

```
modern mobile experience;
conversation-first interaction;
clear system states;
coherent navigation;
capability surfaces yang nyata;
recovery yang dapat dipahami;
minimal technical friction;
```

Application architecture harus mendefinisikan:

```
application shell;
navigation;
screens;
interaction model;
state handling;
capability surfaces;
loading states;
empty states;
error states;
confirmation states;
recovery states.
```

Prinsip:

> Familiar interaction, different brain/system.

Blueprint menetapkan arah design-first, tetapi tidak mengubah keputusan UX spesifik menjadi Canonical secara otomatis.

## 5. Runtime Foundation

```
Owner
 ↓
Application
 ↓
Authentication / Session
 ↓
SH Runtime
 ↓
Governance / Authorization
 ↓
Context / Continuity
 ↓
Capability
 ↓
Provider / Local Runtime / External Service
 ↓
Result
 ↓
Persistence / Audit
```

Runtime harus mempertahankan identity, ownership, privacy, authorization, continuity, dan audit boundary.

## 6. Capability Foundation

Target SH v1.0 mencakup capability yang ditemukan dalam architecture/build/evolution source:

```
conversation;
file;
multimodal;
bounded retrieval / search;
memory;
knowledge;
experience;
journey;
tools / actions;
authority;
provider / infrastructure boundary;
local storage / offline;
local AI / GGUF runtime.
```

Capability yang belum direalisasikan tetap masuk blueprint sebagai target. Status target tidak boleh disamakan dengan verified implementation.

## 7. File & Multimodal

File dan multimodal bukan tambahan kosmetik.

Foundation capability mencakup:

```
attachment lifecycle;
multiple attachments;
image input;
file intelligence / analysis;
camera input where justified;
multimodal conversation;
image understanding;
image generation.
```

Urutan implementasi mengikuti dependency runtime/provider yang nyata. Provider/runtime untuk image generation tetap harus dipilih dan dibuktikan sebelum dianggap capability final.

## 8. Hands / Tools / Authority

Capability layer harus mengikuti:

```
SH
 ↓
Capability / Tool
 ↓
Authority
 ↓
Authorization / Risk Gate
 ↓
Execution
 ↓
Result
 ↓
SH
```

Minimum contract:

```
capability identity;
invocation contract;
actor / SH context;
authorization;
risk classification;
confirmation when required;
execution;
result normalization;
audit / event recording.
```

UI confirmation tidak sama dengan authorization.

## 9. Provider / Infrastructure Boundary

Target:

```
SH
 ↓
Application / Runtime contracts
 ↓
Data / Infrastructure boundary
 ↓
Provider implementation
```

Current provider coupling tidak boleh bocor menjadi product semantics.

Workstream ini **tetap target SH v1.0**, bukan item yang dibuang atau dianggap sekadar tambahan yang tidak diperlukan.

## 10. Local Storage / Offline

Offline bukan sekadar indikator koneksi.

Target harus mencakup:

```
local data scope;
offline read;
queued mutations;
synchronization;
conflict policy;
authentication / session behavior offline;
interrupted-sync recovery;
offline/error semantics;
local privacy/security.
```

Workstream ini **tetap target SH v1.0**.

Full offline parity tidak boleh diasumsikan tanpa scope dan dependency yang jelas.

## 11. Local GGUF Runtime

Local GGUF tetap merupakan target SH v1.0.

Area yang harus masuk foundation:

```
local inference runtime;
supported GGUF model classes / sizes;
model storage lifecycle;
download / update / delete;
device resource constraints;
fallback local ↔ remote;
privacy implications;
runtime contract compatibility.
```

Local GGUF adalah runtime implementation path, bukan identity SH.

Status implementation mengikuti dependency nyata; target capability tidak boleh dihapus hanya karena belum selesai.

## 12. Workstream Taxonomy

**Workstream A–H** adalah taxonomy Evolution V1.0 dan harus dibaca sebagai Workstream, bukan Family.

```
Workstream A — Foundation Reconciliation & Stabilization
Workstream B — Owner UX Consolidation
Workstream C — Multimodal & File Intelligence
Workstream D — Continuity & Intelligence Surfaces
Workstream E — Hands / Tools / Authority
Workstream F — Provider & Infrastructure Boundary
Workstream G — Local Storage & Offline
Workstream H — Local GGUF Runtime
```

Build Scope historis juga memiliki struktur Workstream tersendiri. Karena definisinya berbeda, taxonomy tersebut **tidak boleh dicampur** dengan Evolution V1.0.

Demikian pula:

```
Family A–G
≠
Workstream A–H
```

Jika menyebut F, G, atau H dalam blueprint ini, gunakan nama lengkap **Workstream F**, **Workstream G**, atau **Workstream H**.

## 13. Status Workstream

Untuk fresh reconstruction:

```
A → foundation reconciliation
B → owner experience
C → multimodal / file
D → continuity / intelligence
E → tools / authority
F → provider / infrastructure boundary
G → local storage / offline
H → local GGUF runtime
```

Workstream F, G, dan H **bukan DEFERRED OUT OF SCOPE**. Ketiganya tetap target SH v1.0; implementation sequencing mengikuti dependency masing-masing.

Roadmap V1.0 menyatakan:

```
A
 ↓
B
 ↓
C
 ↓
D
 ↓
E
 ↓
F
 ↓
G
 ↓
H
 ↓
V1.0 Release Candidate
```

Ini adalah dependency-oriented implementation order, bukan alasan untuk menghapus target capability.

## 14A. Invariant Current Canonical yang Dipertahankan

Foundation clean ini secara eksplisit mempertahankan detail berikut dari current authoritative SH Canonical state:

1 Email = 1 Account = 1 Primary SH.

DECOMMISSION ≠ Immediate Permanent Delete.

USER_SH Clone = Owner Approval + Agreement.

CLONE_SH ≠ SOURCE_SH; CREATOR_SH is NON-CLONABLE.

INHERITANCE ≠ CLONE; INHERITANCE ≠ Identity Transfer.

EVOLUTION ≠ Ownership Transfer; Evolution / Migration / Recovery ≠ New SH Identity.

Core Evolution memerlukan Governance / Review.

Privacy / Visibility ≠ Transfer Eligibility. PRIVATE / OWNER-ONLY must not be inferred to mean NON-TRANSFERABLE.

Ini adalah semantik yang dipertahankan dari source, bukan keputusan design baru dan bukan pengganti source Canonical.

## 14. Design vs Implementation

Fresh reconstruction menggunakan:

```
design
   ↓
architecture mapping
   ↓
canonical validation
   ↓
capability mapping
   ↓
implementation
   ↓
integration
   ↓
persistence
   ↓
verification
```

Historical implementation boleh dipakai sebagai evidence, reference, atau lesson.

Historical implementation tidak otomatis menjadi design authority.

Historical bug, accidental complexity, dan UI yang tidak memenuhi target fresh application tidak dibawa hanya karena pernah ada.

## 15. Data Foundation

Foundation data harus mempertahankan:

```
ACCOUNT_ID;
SH_ID;
ownership;
authorization;
memory;
knowledge;
conversation;
journey;
experience;
clone;
inheritance;
succession;
recovery;
portability;
audit.
```

Semantic boundary tetap dijaga:

```
Context ≠ Memory;
Knowledge ≠ Memory;
Experience ≠ Conversation;
Experience ≠ Journey.
```

## 16. Zero-Budget / Zero-Hardware Constraint

```
zero-budget;
zero-hardware.
```

Keduanya adalah constraint pembangunan saat ini.

Artinya fresh reconstruction harus dapat dimulai dan dikembangkan dengan resource yang tersedia saat ini tanpa menjadikan pembelian hardware atau mandatory paid dependency sebagai prasyarat core awal.

Constraint ini **bukan scope permanen SH**. Jika kondisi resource berubah, constraint dapat berubah tanpa mengubah identity SH.

## 17. Historical Lessons

Dari historical implementation/evolution, yang dipertahankan:

```
validated concepts;
contracts;
architecture;
capability intent;
historical lessons;
verification evidence.
```

Yang tidak otomatis dipertahankan:

```
historical bugs;
accidental complexity;
obsolete implementation;
UI decisions yang tidak sesuai target fresh application;
provider leakage;
unverified capability claims.
```

Historical PASS tetap merupakan evidence historical. Fresh DEV harus memperoleh verification sendiri.

## 18. Verification Foundation

Setiap capability penting harus dapat dibedakan:

```
specified;
designed;
implemented;
integrated;
persisted;
verified;
end-to-end verified.
```

Code exists ≠ working.

Table exists ≠ feature works.

Historical PASS ≠ fresh DEV PASS.

## 19. Source / Authority Handling

Foundation ini tidak mengubah Canonical.

Gunakan:

```
SH Core Canonical + current authoritative Canonical Addendum
        ↓
governing contracts
        ↓
architecture / design
        ↓
build / implementation specifications
        ↓
verification / evidence / reconciliation
        ↓
resume / historical discussion
        ↓
new design decision
```

Jika source berbeda, identifikasi perbedaannya dan jangan diam-diam menggabungkan dua definisi.

## 19A. Historical Phase / DoD Boundary

Execution Phase/DoD yang telah selesai dan ditutup sebelum Evolution merupakan konteks historis, bukan prerequisite aktif. Deferred assurance tidak otomatis merupakan blocker. Dependency hanya menjadi aktif jika evidence saat ini secara eksplisit membukanya kembali.

Constitution/Open Questions historis tetap menjadi konteks sampai ada keputusan authoritative yang secara eksplisit menaikkan suatu pertanyaan menjadi requirement saat ini.

## 20. Reconstruction Output

Foundation repository terdiri dari:

```
README.md
docs/
├── sh_canonical_map.md
├── sh_architecture_map.md
├── sh_supabase_map.md
└── sh_foundation_blueprint.md
```

Dokumen-dokumen ini adalah satu foundation set. Detail implementation berikutnya harus dibangun dari set ini dan source authority di `dev_old`.

## 21. Next Implementation Direction

Setelah foundation ini, implementation harus bergerak capability-by-capability dengan dependency yang eksplisit.

Tidak ada capability yang boleh dianggap selesai hanya karena:

```
screen exists;
table exists;
endpoint exists;
historical implementation exists.
```

Setiap slice harus berakhir pada verification yang sesuai.

**End of SH Foundation Blueprint**
