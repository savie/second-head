# SH Supabase Map

**Project:** SECOND HEAD  
**Version:** SH v1.0  
**Environment:** Supabase DEV  
**Target implementasi repository:** dev

## Tujuan

Map ini memetakan data/persistence layer yang ditemukan pada historical source dan DEV environment. Schema adalah implementation layer; schema bukan source of truth untuk semantic identity SH.

## Identity & Ownership

```
public.accounts
        ↓
public.account_auth_links
        ↓
public.sh_instances
        ↓
public.sh_ownership
```

Peran:

```
accounts = ACCOUNT_ID anchor;
account_auth_links = authentication subject → ACCOUNT_ID;
sh_instances = persistent SH_ID anchor;
sh_ownership = explicit ownership relationship.
```

Account bukan SH. Ownership harus explicit, verifiable, dan auditable.

Invariant account Canonical: 1 EMAIL = 1 ACCOUNT = 1 PRIMARY SH. Schema DEV saat ini memiliki constraint struktural yang sesuai untuk email unik dan satu primary SH per account; ini merupakan schema evidence, bukan verifikasi perilaku end-to-end.

## Governance & Audit

```
public.permission_matrix
public.audit_events
private.authority_assignments
public.runtime_high_risk_confirmations
```

Authorization tetap merupakan runtime/server boundary. Default deny dan explicit authorization harus dipertahankan sesuai source.

## Continuity / Intelligence Domains

```
public.conversations
public.memories
public.knowledge
public.experiences
public.journey_events
```

Semantic separation:

```
Context ≠ Memory;
Knowledge ≠ Memory;
Experience ≠ Knowledge;
Experience ≠ Conversation;
Experience ≠ Journey.
```

## Clone / Inheritance / Succession / Legacy

```
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

DECOMMISSION ≠ Immediate Permanent Delete. Persistence lifecycle saat ini mempertahankan semantik identity/history dan tidak memperlakukan deactivation sebagai penghancuran row secara langsung; perilaku runtime tetap memerlukan verifikasi.

Canonical Addendum saat ini menetapkan Privacy / Visibility ≠ Transfer Eligibility. Default schema yang ada bukan, dengan sendirinya, bukti compliance runtime saat ini.

Operasi clone/inheritance/succession/legacy tetap terikat pada authorization dan harus mempertahankan distinction identity.

## Recovery / Portability

```
public.recovery_snapshots
public.recovery_events
public.portability_exports
```

Recovery harus mempertahankan identity/history semantics dan membedakan recovery dari clone creation.

## External Capability / Runtime

```
public.r4_google_oauth_states
public.r4_google_connections
public.r4_google_calendar_actions
public.r6_tasks
public.runtime_high_risk_confirmations
```

External capability berada di bawah account/SH association dan authorization/confirmation boundary.

## DEV Observed Tables

```
accounts;
sh_instances;
sh_ownership;
account_auth_links;
permission_matrix;
memories;
knowledge;
audit_events;
conversations;
journey_events;
clone_agreements;
sh_clones;
succession_rules;
inheritance_authorizations;
inheritance_events;
legacy_records;
recovery_snapshots;
recovery_events;
portability_exports;
runtime_high_risk_confirmations;
succession_events;
experiences;
r4_google_oauth_states;
r4_google_connections;
r4_google_calendar_actions;
r6_tasks.
```

Current audit mencatat 26 public tables pada DEV. Keberadaan tabel tidak menjadi bukti bahwa capability fresh implementation sudah terintegrasi atau verified.

## Repository / Remote Boundary

Historical repository memiliki database source dan migration lineage. Current `dev` foundation belum memiliki source database/migration implementation yang mereproduksi seluruh remote DEV state.

Karena itu:

```
dev repository
      ≠
historical dev_old implementation
      ≠
current Supabase DEV state
```

Lineage harus direkonstruksi sebelum persistence implementation dianggap synchronized.

## Source References

```
database/
supabase/
docs/verification/
docs/evidence/
docs/reconciliation/
```

Map ini mempertahankan observed data domains sebagai foundation target, bukan mengklaim fresh implementation selesai.
