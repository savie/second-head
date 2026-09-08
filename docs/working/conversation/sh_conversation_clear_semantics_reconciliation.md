# SECOND HEAD — Conversation Clear Semantics Reconciliation

## Status

**WORKING / DOMAIN RECONCILIATION — OWNER PROPOSAL**

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

## 1. Current Authority

Approved Conversation contract saat ini menetapkan:

```text
Clear ≠ Delete

Clear
→ membersihkan isi chat / message dari tampilan atau state yang ditetapkan
→ Conversation tetap ada

Delete Conversation
→ menghapus Conversation
→ child Messages mengikuti lifecycle deletion
```

Contract juga menyatakan persistence/recovery behavior Clear masih perlu divalidasi.

Tidak ada perubahan Canonical melalui dokumen ini.

---

## 2. Current Implementation / Backend + Frontend Evidence

Current backend memiliki persistence Message di `public.conversations` dan runtime deletion untuk individual Message / Conversation.

Recovery snapshot saat ini memasukkan `conversation_threads` dan `conversations`, dan restore juga mengembalikan keduanya.

Backend **tidak memiliki runtime capability Clear terpisah** yang mempertahankan Message tetapi mengubah presentation/session state.

Current frontend `ConversationView._clearConversation()` justru melakukan:

```text
Clear
→ iterate Messages
→ deleteMessage untuk setiap Message yang memiliki runtimeRecordId
→ clear UI state
→ persist local empty state
```

`runtimeRecordId` yang diteruskan ke bridge merupakan Message ID, walaupun parameter bridge saat ini bernama `conversationId`.

Jadi current implementation secara faktual adalah:

```text
CURRENT FE BEHAVIOR
Clear = destructive Message deletion + local empty-state persistence
```

Ini **bertentangan dengan approved semantic boundary `Clear ≠ Delete`**.

**CONFIRMED IMPLEMENTATION SEMANTIC GAP.**

Gap ini tidak boleh diselesaikan dengan menganggap behavior saat ini sebagai semantics yang baru; authority tetap berada pada Approved Contract dan Owner decision.

---

## 3. Owner Proposal — Temporary Clear

Owner mengusulkan semantics:

```text
CLEAR
→ temporary
→ berlaku pada session / presentation context tertentu
→ tidak menghapus Message dari Supabase
→ tidak menghapus Conversation
→ tidak menghapus Attachment
→ setelah scope temporary berakhir, data dapat ditampilkan kembali
```

**STATUS: OWNER PROPOSAL — NOT LOCKED**

Alasan utama:

```text
UI terlihat kosong
        tetapi
backend masih menyimpan Message
```

Dengan semantics temporary, kondisi tersebut bukan contradiction. UI sedang berada dalam state Clear; data durable tetap ada.

---

## 4. What Clear Must NOT Mean

Dalam proposal ini Clear bukan:

- hard delete Message;
- soft delete Message;
- delete Conversation;
- attachment deletion;
- Recovery deletion;
- retention operation;
- transfer operation;
- perubahan ownership;
- perubahan SH identity.

Clear juga tidak boleh menjadi authorization bypass atau cara untuk mengakses kembali data yang seharusnya tidak visible menurut boundary lain.

---

## 5. Temporary Scope — OPEN OWNER DECISION

Belum ditentukan scope temporary yang final.

Candidate:

```text
A. Screen / surface lifetime
   Clear berlaku sampai surface ditutup.

B. Application session lifetime
   Clear berlaku sampai application session berakhir.

C. Explicit restore
   Clear tetap berlaku sampai user memilih restore/reload.
```

Tidak ada satu pun candidate di atas yang boleh dianggap final tanpa Owner lock.

---

## 6. Persistence of Clear State — OPEN

Ada dua model utama:

### Model 1 — In-memory only

```text
Clear
 ↓
local runtime state
 ↓
screen/session berubah
```

Tidak menulis Clear state ke backend.

### Model 2 — Local session persistence

```text
Clear
 ↓
local session/application state
 ↓
restore UI state saat app tetap dalam scope yang sama
```

Keduanya tetap berbeda dari backend Message mutation.

Belum ada keputusan final.

---

## 7. UX Semantic Requirement

Jika Clear temporary disetujui, UI harus membedakan:

```text
No messages exist
```

dari:

```text
Messages exist but are temporarily cleared from this presentation/session
```

UI tidak harus selalu menampilkan detail internal, tetapi behavior tidak boleh membuat user percaya bahwa data telah dihapus jika sebenarnya masih durable.

---

## 8. Attachment Consequence

Dengan Hybrid Attachment Model yang sudah menjadi Owner Decision:

```text
Local attachment
→ cache / UX

Backend attachment
→ durable source of truth
```

Maka temporary Clear harus berperilaku:

```text
Clear
 ↓
Message tetap durable
 ↓
Attachment reference tetap durable
 ↓
Storage Object tetap mengikuti lifecycle attachment
 ↓
Recovery state tidak dihapus
```

Jadi:

**Clear tidak boleh menjadi trigger attachment deletion.**

---

## 9. Recovery Consequence

Current Recovery menyimpan Message state dan dapat restore Conversation + Message.

Jika Clear hanya temporary:

```text
Clear
 ↓
Recovery snapshot tetap tidak berubah
```

Recovery tidak perlu membuat snapshot baru hanya karena user melakukan Clear, kecuali contract Recovery berikutnya secara eksplisit menentukan demikian.

Attachment Recovery tetap merupakan dependency terpisah yang saat ini belum tersedia.

---

## 10. Delete vs Clear Matrix

| Operation | Conversation | Message | Attachment | Recovery snapshot |
|---|---|---|---|---|
| Clear candidate | tetap | tetap durable, tidak ditampilkan sementara | tetap | tetap |
| Delete Message | tetap | dihapus | lifecycle terpisah; tidak otomatis hard-delete | snapshot existing tetap historical |
| Delete Conversation | dihapus | child ikut deletion | lifecycle terpisah; policy wajib ditentukan | existing snapshot tetap historical |

Matrix ini adalah reconciliation model. Detail attachment retention/deletion masih open.

---

## 11. Important Recovery Insight

Recovery snapshot memiliki dependency `RESTRICT` dengan `recovery_events` dan `portability_exports`.

Karena itu snapshot tidak boleh dianggap temporary UI cache.

Dengan demikian ada empat lifecycle berbeda:

```text
Message lifecycle
        ≠
Attachment Resource lifecycle
        ≠
Storage Object lifecycle
        ≠
Recovery Snapshot lifecycle
```

Clear berada di luar lifecycle destructive tersebut dalam Owner Proposal ini.

---

## 12. Security Boundary

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

Clear hanya mengubah presentation/session state. Ia tidak mengubah ownership, access rights, atau backend identity resolution.

---

## 13. Reconciliation Result

### LOCKED

- Clear ≠ Delete.
- Conversation tetap ada ketika Clear dilakukan.
- Hybrid Attachment Model.
- Local path bukan durable attachment identity.
- Backend-persisted attachment adalah durable source of truth.

### OWNER PROPOSAL — NOT LOCKED

- Clear bersifat temporary.
- Clear tidak melakukan destructive backend mutation.
- Clear tidak menghapus Attachment.
- Clear tidak mengubah Recovery snapshot.
- Data kembali terlihat setelah temporary scope berakhir.

### CONFIRMED / EXISTING GAP

- **Current FE Clear implementation masih destructive:** Clear memanggil delete Message untuk setiap Message yang memiliki runtimeRecordId.
- Backend belum memiliki dedicated Clear operation/presentation-state capability.
- Attachment persistence/reconstruction belum tersedia.
- Attachment Recovery belum tersedia.
- Attachment deletion/retention lifecycle belum tersedia.

### OPEN OWNER DECISIONS

1. Temporary scope: screen, application session, atau explicit restore.
2. Apakah Clear state cukup in-memory atau perlu local session persistence.
3. Bagaimana UI memberi indikasi bahwa data sedang cleared tanpa membingungkan user.
4. Apakah ada action `Restore` atau Clear berakhir otomatis sesuai scope.

---

## 14. Implementation Gate

**NO CODING YET.**

Sebelum implementasi Clear:

```text
Owner lock semantics
        ↓
Approved Contract update
        ↓
FE state design
        ↓
backend impact verification
        ↓
implementation
        ↓
E2E verification
```

Tidak boleh membuat backend deletion/soft-delete workaround untuk memenuhi UI Clear sebelum semantics final dikunci.

---

## 15. Relation to Existing Documents

Parent working document:

`docs/working/conversation/sh_conversation_inventory_reconciliation.md`

Attachment reconciliation:

`docs/working/conversation/sh_conversation_attachment_contract_reconciliation.md`

Approved contract:

`docs/contract/sh_project_conversation_message_contract.md`

Dokumen ini **tidak mengubah** Approved Contract dan **tidak mengubah** Canonical.
