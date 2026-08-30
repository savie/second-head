# SH Architecture Map

**Project:** SECOND HEAD  
**Version:** SH v1.0  
**Target implementasi repository:** dev

## Tujuan

Map ini menerjemahkan foundation Canonical dan hasil rekonstruksi historical menjadi hubungan sistem untuk fresh implementation. Map ini bukan pengganti Canonical dan bukan bukti bahwa seluruh capability sudah implemented.

## Arsitektur Tingkat Tinggi

```
Creator
    ↓
SH-000 / Core Governance
    ↓
SH Core
    ↓
SH Instance
    ↓
Owner / User Domain
    ↓
Application
    ↓
SH Runtime
    ├── State
    ├── Context
    ├── Memory
    ├── Knowledge
    ├── Conversation
    ├── Experience
    ├── Journey
    ├── Lifecycle
    ├── Recovery
    └── Capability / Tools / Actions
    ↓
Provider / Local Runtime / External Service
    ↓
Result
    ↓
Persistence / Audit
```

## Identity Boundary

```
ACCOUNT_ID
    ≠
SH_ID
    ≠
SESSION_ID
    ≠
MODEL
    ≠
RUNTIME
    ≠
DATABASE
    ≠
HARDWARE
```

Authentication menyelesaikan account/session concern; persistent SH identity tetap merupakan concern tersendiri.

Invariant account Canonical: 1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH.

## Application Architecture

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

Arah fresh application adalah mobile-first dan modern. Historical UI tidak menjadi visual authority hanya karena pernah implemented.

Prinsip UX:

> Familiar interaction, different brain/system.

Blueprint tidak mengunci satu visual layout atau satu launch/login flow yang belum ditetapkan sebagai requirement tersendiri.

## Runtime Boundary

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
  ↓
Application
```

Runtime access tidak sama dengan ownership.

## Capability Contract

Setiap capability harus memiliki:

```
contract;
authorization;
execution path;
result;
error path;
persistence requirement;
verification path.
```

Keberadaan UI, tabel, atau endpoint tidak cukup untuk menyatakan capability selesai.

## Boundary Lifecycle, Clone, Transfer & Governance

DECOMMISSION ≠ Immediate Permanent Delete. Decommissioning tidak boleh disamakan dengan penghancuran permanen SH identity/history secara langsung.

CLONE_SH ≠ SOURCE_SH; CREATOR_SH is NON-CLONABLE; USER_SH Clone = Owner Approval + Agreement.

INHERITANCE ≠ CLONE; INHERITANCE ≠ Identity Transfer; EVOLUTION ≠ Ownership Transfer; Evolution / Migration / Recovery ≠ New SH Identity.

Privacy / Visibility ≠ Transfer Eligibility. Visibility private atau owner-only tidak otomatis berarti non-transferable.

Core Evolution memerlukan Governance / Review; perilaku learning/runtime tidak boleh diam-diam menulis ulang SH Core.

## Continuity Architecture

```
Conversation
    ↕
Context
    ↕
Memory / Knowledge
    ↕
Experience
    ↕
Journey
    ↕
Search / Retrieval
```

Hubungan ini tidak menghapus semantic distinction antar-domain.

## Provider / Infrastructure Boundary

```
SH
 ↓
Application / Runtime Contract
 ↓
Provider / Infrastructure Boundary
 ↓
Provider / Infrastructure
```

Current provider adalah implementation dependency. Ia tidak boleh menjadi product identity SH.

## Local / Offline Direction

Target architecture mencakup dua jalur:

```
ONLINE
SH → remote services / storage

OFFLINE
SH → local state / local storage / local runtime
```

Local AI / GGUF adalah runtime path, bukan identity SH.

## Verification Boundary

Bedakan:

```
implemented;
integrated;
persisted;
verified;
end-to-end verified.
```

Historical PASS tidak otomatis menjadi current DEV PASS.

## Source References

```
docs/canonical/SECOND_HEAD_CANONICAL_ARCHITECTURE_DIAGRAM.md
docs/architecture/
docs/canonical/SECOND_HEAD_SH_FULL_BUILD_SCOPE_v1.0.md
docs/canonical/SECOND_HEAD_SH_FULL_IMPLEMENTATION_CONTRACT_v1.0.md
docs/canonical/SECOND_HEAD_SH_FULL_IMPLEMENTATION_GUIDE_v1.0.md
docs/canonical/SECOND_HEAD_SH_FULL_EXECUTION_STRATEGY_v1.0.md
docs/evolution/V1.0/ROADMAP.md
```
