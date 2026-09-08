# SH Supabase Map

**Project:** SECOND HEAD  
**Version:** SH v1.0  
**Environment:** Supabase DEV  
**Target implementasi repository:** dev

## Tujuan

Map ini memetakan data/persistence layer yang ditemukan pada historical source dan current DEV environment. Schema adalah implementation layer; schema bukan source of truth untuk semantic identity SH.

**Status dokumen:** reference map hasil reconciliation. Dokumen ini tidak menggantikan Canonical source dan tidak boleh digunakan untuk mengubah semantic Canonical secara implisit.

## Identity & Ownership

```text
public.accounts
        ↓
public.account_auth_links
        ↓
public.sh_instances
        ↓
public.sh_ownership
```

Peran:

```text
accounts = ACCOUNT_ID anchor;
account_auth_links = authentication subject → ACCOUNT_ID;
sh_instances = persistent SH_ID anchor;
sh_ownership = explicit ownership relationship.
```

Account bukan SH. Ownership harus explicit, verifiable, dan auditable.

Invariant account Canonical: 1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH. Schema DEV memiliki structural evidence yang mendukung invariant tersebut; ini bukan pengganti verifikasi behavior end-to-end.

## Governance & Audit

```text
public.permission_matrix
public.audit_events
private.authority_assignments
public.runtime_high_risk_confirmations
```

Authorization tetap merupakan runtime/server boundary. Default deny dan explicit authorization harus dipertahankan sesuai source.

## Continuity / Intelligence Domains

```text
public.conversations
public.memories
public.knowledge
public.experiences
public.journey_events
```

Semantic separation:

```text
Context ≠ Memory;
Knowledge ≠ Memory;
Experience ≠ Knowledge;
Experience ≠ Conversation;
Experience ≠ Journey.
```

Keberadaan tabel tidak membuktikan bahwa seluruh domain sudah terintegrasi atau verified pada frontend/backend.

## Project / Conversation Hierarchy

Current DEV juga memiliki:

```text
public.projects
public.conversation_threads
public.conversations
```

Hierarchy implementation saat ini:

```text
Account / SH
     ↓
Project
     ↓
Conversation Thread
     ↓
Conversation / Message storage
```

`conversation_threads` merupakan hierarchy/thread layer current. `public.conversations` tetap menjadi storage message pada hierarchy yang berjalan saat ini; keberadaannya tidak boleh dibaca sebagai legacy runtime authority tanpa melihat current function/migration path.

Current runtime management paths mencakup Project/Conversation create/list/rename/delete, assignment/remove, message CRUD, dan context loading. Verification semantic/security tetap merupakan concern terpisah.

## SH State

Current DEV memiliki:

```text
public.sh_states
```

State merupakan persistence concern tersendiri dan tidak boleh digantikan dengan `sh_instances.metadata` sebagai State authority.

State juga dibedakan dari Recovery container dan persistent SH identity.

## Clone / Inheritance / Succession / Legacy

```text
public.clone_agreements
public.sh_clones
public.inheritance_authorizations
public.inheritance_events
public.succession_rules
public.succession_events
public.legacy_records
```

Relasi tersebut tidak boleh disederhanakan menjadi satu konsep transfer identity.

## Lifecycle / Transfer Boundary

DECOMMISSION ≠ Immediate Permanent Delete. Persistence lifecycle mempertahankan semantic distinction identity/history; behavior runtime tetap harus diverifikasi pada capability yang relevan.

Canonical Addendum menetapkan Privacy / Visibility ≠ Transfer Eligibility. Default schema yang ada bukan, dengan sendirinya, bukti compliance runtime.

Operasi clone/inheritance/succession/legacy tetap terikat pada authorization dan harus mempertahankan distinction identity.

## Recovery / Portability

```text
public.recovery_snapshots
public.recovery_events
public.portability_exports
```

Recovery harus mempertahankan identity/history semantics dan membedakan recovery dari clone creation.

Current backend recovery lineage juga mencakup Project → Conversation Thread → Message continuity.

## External Capability / Runtime

```text
public.google_oauth_states
public.google_connections
public.google_calendar_actions
public.task_reminders
public.runtime_high_risk_confirmations
```

External capability berada di bawah account/SH association dan authorization/confirmation boundary.

## Current DEV Observed Tables

Current reconciliation checkpoint mencatat public tables berikut:

```text
accounts;
account_auth_links;
sh_instances;
sh_ownership;
permission_matrix;
audit_events;
projects;
conversation_threads;
conversations;
memories;
knowledge;
experiences;
journey_events;
sh_states;
clone_agreements;
sh_clones;
inheritance_authorizations;
inheritance_events;
succession_rules;
succession_events;
legacy_records;
recovery_snapshots;
recovery_events;
portability_exports;
runtime_high_risk_confirmations;
google_oauth_states;
google_connections;
google_calendar_actions;
task_reminders.
```

**Current count: 29 public tables** pada checkpoint reconciliation ini. Count merupakan observed DEV state dan harus dianggap snapshot; perubahan migration berikutnya dapat mengubahnya.

Keberadaan tabel tidak menjadi bukti bahwa capability fresh implementation sudah terintegrasi atau verified.

## Repository / Remote Boundary

Migration source reconstruction current DEV sudah diselesaikan pada repository `dev` berdasarkan migration lineage/artifact yang direkonsiliasi.

Tetap bedakan:

```text
dev repository migration artifacts
          ≠
current Supabase DEV remote state
          ≠
historical dev_old implementation
```

Migration reconstruction memastikan source lineage tersedia; verification terhadap remote DEV tetap merupakan concern tersendiri.

## Source References

```text
database/
supabase/
docs/verification/
docs/evidence/
docs/reconciliation/
```

Map ini mempertahankan observed data domains sebagai current DEV reference, bukan mengklaim fresh implementation selesai.
