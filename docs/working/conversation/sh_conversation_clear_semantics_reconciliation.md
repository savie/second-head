# SECOND HEAD — Conversation Clear Semantics Reconciliation

## Status

**WORKING / DOMAIN RECONCILIATION — OWNER DECISION LOCKED / IMPLEMENTATION GAP**

Dokumen ini adalah child working document untuk scope Project → Conversation → Message.

Dokumen ini **bukan Canonical** dan **bukan Approved Contract**. Fungsinya memisahkan semantics Clear dari Delete dan merekonsiliasi konsekuensinya terhadap persistence, Recovery, attachment, dan frontend session state.

Authority tetap:

```text
Owner / User Decision
        ↓
Canonical
        ↓
Approved Contract
        ↓
Architecture / Design
        ↓
Current Implementation
        ↓
Historical / dev_old evidence
```

---

## 1. Locked Owner Decision

Clear sekarang dikunci sebagai **temporary presentation/session state** dengan scope **application session lifetime**.

```text
CLEAR
→ temporary
→ berlaku selama application session
→ tidak menghapus Message dari Supabase
→ tidak menghapus Conversation
→ tidak menghapus Attachment
→ tidak mengubah Recovery snapshot
→ tidak memiliki Restore action terpisah
→ setelah application session berakhir, Clear state berakhir
```

Semantics ini menyelesaikan ambiguity sebelumnya antara Clear dan Delete. `Clear ≠ Delete` tetap berlaku.

Dokumen ini tidak mengubah Canonical secara sepihak. Approved Contract tetap menjadi authority contract; working document ini merekam Owner Decision dan implementation gap yang harus diturunkan ke contract/design yang relevan.

---

## 2. Current Implementation Evidence

Current backend memiliki persistence Message di `public.conversations` dan runtime deletion untuk individual Message / Conversation.

Current frontend `ConversationView._clearConversation()` masih melakukan:

```text
Clear
→ iterate Messages
→ deleteMessage untuk setiap Message yang memiliki runtimeRecordId
→ clear UI state
→ persist local empty state
```

Jadi current implementation secara faktual masih:

```text
CURRENT FE BEHAVIOR
Clear = destructive Message deletion + local empty-state persistence
```

Ini **bertentangan dengan locked Clear semantics**.

**CONFIRMED IMPLEMENTATION SEMANTIC GAP.**

Current backend juga belum memiliki dedicated Clear operation karena locked semantics tidak membutuhkan destructive backend mutation.

---

## 3. Locked Clear Semantics

### 3.1 Scope

```text
Application session lifetime
```

Clear state bukan screen-only state dan bukan indefinite persistent state.

Saat application session berakhir, Clear state tidak dipertahankan sebagai durable user state. Conversation dan Messages tetap durable.

### 3.2 Persistence

Clear state **tidak dipersist ke backend**.

```text
Clear
 ↓
application-session presentation state
 ↓
no Message mutation
 ↓
no Attachment mutation
 ↓
no Recovery mutation
```

Tidak ada requirement untuk membuat `clear` column, soft-delete flag, atau backend Clear RPC sebagai bagian dari semantics ini.

### 3.3 Restore

Tidak ada explicit `Restore` action sebagai lifecycle operation.

Data menjadi visible kembali ketika application session scope Clear berakhir sesuai lifecycle aplikasi.

---

## 4. What Clear Must NOT Mean

Clear bukan:

- hard delete Message;
- soft delete Message;
- delete Conversation;
- attachment deletion;
- attachment detach;
- Storage Object cleanup;
- Recovery deletion;
- retention operation;
- transfer operation;
- perubahan ownership;
- perubahan SH identity;
- authorization bypass.

Clear hanya mengubah presentation/session state.

---

## 5. UX Semantic Requirement

UI harus memperlakukan state Clear sebagai berbeda dari empty conversation yang memang tidak memiliki Message durable.

Secara semantic:

```text
No messages exist
        ≠
Messages exist but are temporarily cleared for this application session
```

UI tidak boleh menghasilkan false implication bahwa Message telah dihapus.

Tidak ada requirement untuk mengekspos detail internal implementation kepada user selama behavior tetap konsisten dengan semantics tersebut.

---

## 6. Attachment Consequence

Approved attachment contract menetapkan durable attachment sebagai resource terpisah dari local cache:

```text
Local attachment
→ UX / cache

Backend attachment
→ durable source of truth
```

Current DEV memiliki:

```text
public.conversation_attachments
public.conversation_attachment_recovery_refs
private bucket: second-head-conversation
```

Locked Clear behavior:

```text
Clear
 ↓
Message tetap durable
 ↓
Attachment relationship tetap durable
 ↓
Storage Object tidak disentuh
 ↓
Recovery state tidak dihapus
```

**Clear tidak boleh memanggil attachment deletion, detach, atau storage cleanup.**

---

## 7. Recovery Consequence

Recovery snapshot tidak berubah hanya karena Clear dilakukan.

```text
Clear
 ↓
Recovery snapshot tetap historical/durable
```

Tidak ada snapshot baru yang diperlukan hanya karena Clear, kecuali contract Recovery lain di masa depan secara eksplisit menetapkan behavior berbeda.

Missing attachment dependency tetap harus dilaporkan sebagai recovery gap dan tidak boleh dianggap silently restored.

**Status: IMPLEMENTATION SUPPORT PRESENT / CLEAR SEMANTIC VERIFICATION OPEN.**

---

## 8. Delete vs Clear Matrix

| Operation | Conversation | Message | Attachment | Recovery snapshot |
|---|---|---|---|---|
| Clear | tetap | tetap durable, presentation temporarily cleared | tetap | tetap |
| Delete Message | tetap | dihapus | active relationship mengikuti delete semantics | existing snapshot tetap historical |
| Delete Conversation | dihapus | child mengikuti lifecycle deletion | active relationships mengikuti delete semantics; Storage Object tidak blind-delete bila masih dibutuhkan Recovery | existing snapshot tetap historical |

Clear dan Delete tidak boleh diimplementasikan melalui shared destructive mutation path.

---

## 9. Security Boundary

Clear state tidak boleh menjadi source of authorization.

```text
Account / SH identity
        ↓
Conversation authorization
        ↓
Message authorization
        ↓
Clear presentation state
```

Clear tidak mengubah ownership, access rights, identity resolution, atau backend authorization.

---

## 10. Reconciliation Result

### LOCKED — OWNER DECISION

- Clear ≠ Delete.
- Clear bersifat temporary.
- Scope Clear = application session lifetime.
- Clear tidak melakukan destructive backend mutation.
- Clear tidak menghapus Message.
- Clear tidak menghapus Conversation.
- Clear tidak menghapus atau detach Attachment.
- Clear tidak mengubah Storage Object lifecycle.
- Clear tidak mengubah Recovery snapshot.
- Tidak ada explicit Restore action.
- Clear state tidak dipersist sebagai backend durable state.
- Data kembali visible setelah application session scope berakhir.

### CONFIRMED / EXISTING IMPLEMENTATION GAP

- **Current FE Clear implementation masih destructive:** Clear memanggil delete Message untuk setiap Message yang memiliki `runtimeRecordId`.
- Current backend belum memiliki dedicated Clear capability; locked semantics tidak memerlukan destructive backend Clear RPC.
- Local empty-state persistence saat ini harus direkonsiliasi agar tidak menyatakan durable deletion.
- Attachment backend persistence/reconstruction sudah implemented; semantic/authenticated E2E masih open.
- Attachment Recovery relationship sudah implemented; authenticated recovery/E2E masih open.
- Attachment deletion/retention runtime dan cleanup semantics masih memerlukan verification.

### NO LONGER OPEN OWNER DECISIONS

1. Temporary scope → **LOCKED: application session lifetime**.
2. Clear state persistence → **LOCKED: application-session presentation state; no backend persistence**.
3. Restore action → **LOCKED: none**.
4. Clear attachment behavior → **LOCKED: non-destructive**.
5. Clear Recovery behavior → **LOCKED: snapshot unchanged**.

---

## 11. Implementation Gate

**SEMANTICS LOCKED — IMPLEMENTATION MAY PROCEED.**

Required sequence:

```text
Locked Owner Decision
        ↓
Approved Contract / design reconciliation
        ↓
FE state design
        ↓
remove destructive Clear path
        ↓
backend impact verification
        ↓
E2E verification
```

Implementation must not use hard-delete, soft-delete, attachment deletion, or Recovery mutation as a workaround for Clear.

---

## 12. Relation to Existing Documents

Parent working document:

`docs/working/conversation/sh_conversation_inventory_reconciliation.md`

Attachment reconciliation:

`docs/working/conversation/sh_conversation_attachment_contract_reconciliation.md`

Attachment migration design:

`docs/working/conversation/sh_conversation_attachment_migration_design.md`

Approved contract:

`docs/contract/sh_project_conversation_message_contract.md`

Dokumen ini **tidak mengubah Canonical**.
