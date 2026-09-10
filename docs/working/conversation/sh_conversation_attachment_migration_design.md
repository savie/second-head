# SECOND HEAD — Conversation Attachment Migration Design

## Status

**FROZEN / LOCKED — DEV MIGRATION EXECUTED / CLEANUP + ORPHAN RECONCILIATION BACKEND IMPLEMENTED / E2E VERIFICATION DEFERRED**

Dokumen ini adalah working design record untuk migration attachment pada domain Conversation → Message. Dokumen ini bukan Canonical dan tidak mengubah Approved Contract.

Authority:

```text
Owner / User Decision
        ↓
Canonical
        ↓
Approved Contract
        ↓
Architecture / Design
        ↓
Implementation
        ↓
Historical / dev_old evidence
```

Approved attachment contract:
`docs/contract/sh_conversation_attachment_contract.md`

Clear semantics working authority:
`docs/working/conversation/sh_conversation_clear_semantics_reconciliation.md`

---

## 1. Frozen Semantic Model

```text
Conversation
   ↓
Message
   ├── content
   └── attachments[]
          ↓
     durable Storage Object
```

Satu Message dapat berisi text dan zero atau multiple attachment. Attachment bukan Message baru dan bukan domain SH lifecycle baru.

Existing Message contract tetap berlaku: `runtime_record_conversation_message()` saat ini mensyaratkan content non-empty. Migration attachment tidak memperluas Message menjadi attachment-only.

Local file adalah UX/cache. Backend-persisted attachment adalah durable source of truth. Local path bukan identity.

---

## 2. Frozen Attachment Resource Schema

Table: `public.conversation_attachments`

Columns:

- `attachment_id uuid NOT NULL` — primary key.
- `account_id uuid NOT NULL` — trusted Account boundary.
- `sh_id uuid NOT NULL` — trusted SH boundary.
- `message_id uuid NULL` — active Message relationship; nullable after Message deletion.
- `filename text NOT NULL`.
- `mime_type text NOT NULL`.
- `size_bytes bigint NOT NULL`.
- `storage_ref text NOT NULL` — opaque durable object locator, not authority.
- `status text NOT NULL` — CHECK: `PENDING`, `PERSISTED`, `FAILED`.
- `created_at timestamptz NOT NULL`.
- `updated_at timestamptz NOT NULL`.
- `persisted_at timestamptz NULL`.

No checksum is added in this migration.

Constraints:

- PK on `attachment_id`.
- FK `account_id → accounts.account_id`.
- FK `sh_id → sh_instances.sh_id`.
- `message_id → conversations.message_id` with **ON DELETE SET NULL**.
- `UNIQUE(storage_ref)`.
- CHECK for non-negative `size_bytes`.
- CHECK for allowed status values.

Indexes:

- `message_id`.
- `(account_id, sh_id)`.
- `(status, created_at)`.

The existing `conversations` table is not structurally altered to add a composite unique key. Account/SH/message consistency is enforced by the trusted attachment RPC boundary, avoiding unnecessary mutation of the established Message schema.

---

## 3. Frozen Storage Boundary

Bucket name:

`second-head-conversation`

Bucket is **private** (`public = false`).

No public object access is granted.

No exact product-specific MIME or file-size limit is invented in this migration; those limits remain operational/product configuration unless separately locked.

Storage object path is not an identity source. The durable Attachment Resource owns the relationship between attachment identity and storage locator.

---

## 4. Frozen RLS / Privilege Boundary

`public.conversation_attachments` has RLS enabled.

Authenticated direct access is restricted to the caller's trusted Account/SH boundary. Client-provided identifiers do not establish authority.

Direct authenticated DELETE on the attachment resource is not granted.

Storage object access is private and must be authorized against the Attachment Resource / trusted Account-SH boundary. Arbitrary storage path knowledge is not treated as authority.

Physical Storage Object deletion is performed only through the Supabase Storage API by the backend cleanup/reconciliation workers; direct SQL deletion from `storage.objects` is not used.

Unauthenticated/anon access is denied.

---

## 5. Frozen RPC Boundary

The attachment migration introduces authorized backend boundaries for:

1. `runtime_create_conversation_attachment(filename, mime_type, size_bytes)`
2. `runtime_finalize_conversation_attachment(attachment_id, message_id)`
3. `runtime_fail_conversation_attachment(attachment_id)`
4. `runtime_load_conversation_attachments(message_id)`
5. `runtime_detach_conversation_attachment(attachment_id)`

Cleanup reconciliation adds internal/backend worker boundaries:

6. `runtime_claim_conversation_attachment_cleanup(limit)`
7. `runtime_complete_conversation_attachment_cleanup(cleanup_id)`
8. `runtime_fail_conversation_attachment_cleanup(cleanup_id, error)`
9. `runtime_reconcile_conversation_attachment_storage_refs(text[])`
10. `runtime_reconcile_conversation_attachment_storage_refs_internal(text[])` — service-role-only global classification.

All user-facing attachment RPCs resolve/validate trusted Account/SH ownership at the backend boundary. Client-provided ownership values are not authority. Finalize validates target Message ownership and same Account/SH. Retry of the same logical attachment retains the same `attachment_id`.

The cleanup queue is not directly exposed as a table to `anon` or `authenticated`; cleanup operations are mediated through SECURITY DEFINER RPCs and backend workers. The global reconciliation RPC is service-role-only.

---

## 6. Frozen Delete and Clear Semantics

Existing DEV Message/Conversation deletion functions remain trusted Account/SH boundaries as currently implemented.

Attachment rule:

```text
Delete Message / Conversation
        ↓
active attachment relationship removed
        ↓
cleanup queue entry created
        ↓
Attachment Resource removed only after retention checks
        ↓
Storage Object removed through Supabase Storage API
```

The FK uses `ON DELETE SET NULL`, so existing Message/Thread deletion remains compatible without destructive trigger behavior.

Storage cleanup occurs only when no valid active Message or Recovery retention dependency remains.

The cleanup queue is asynchronous. If a valid Recovery dependency exists, cleanup is deferred and retried later; it is not treated as permission to delete the retained Attachment Resource or Storage Object.

Locked Clear semantics are:

```text
Clear
→ temporary presentation/session state
→ application session lifetime
→ no Message mutation
→ no Attachment deletion/detach
→ no Storage Object cleanup
→ no Recovery mutation
→ no backend durable Clear state
```

Clear therefore remains completely outside the destructive attachment lifecycle.

---

## 7. Frozen Recovery Integration

Existing DEV Recovery captures/restores Conversation Messages inside `recovery_snapshots.manifest`.

The attachment migration integration is implemented in DEV through persisted attachment descriptors/references. Binary data is not embedded in the JSON manifest.

Recovery relationship:

`public.conversation_attachment_recovery_refs`

Current snapshot/restore path:

```text
Message with durable attachment
        ↓
Recovery manifest captures attachment descriptor/reference
        ↓
Recovery reference retained
        ↓
Restore reconnects existing durable Attachment/Storage Object
```

Restore only succeeds for the attachment dependency when the durable resource, Storage Object, and target Message dependency are available. Missing dependency must surface as an explicit recovery gap.

Existing Recovery idempotency and trusted Account ownership boundaries remain intact.

Authenticated Recovery E2E, missing-object behavior, and cleanup/retention E2E remain deferred verification work.

---

## 8. Frozen Orphan / Retention Semantics

Distinguish:

```text
Storage Object without Attachment Resource
→ orphan object

Attachment Resource PENDING/FAILED + Storage Object exists
→ retryable attachment resource; do not delete

Attachment Resource PENDING/FAILED + Storage Object missing
→ retryable upload; do not delete the resource

Attachment Resource without active Message
→ may still be retained by Recovery

Attachment Resource without Message and without valid retention dependency
→ cleanup candidate
```

Because Storage upload and PostgreSQL transaction are not atomic, implementation provides a cleanup/reconciliation path for failed database persistence after successful object upload.

No synchronous blind object deletion is attached to Message DELETE or Clear.

Current PENDING / PERSISTED / FAILED lifecycle and stable attachment identity support the retry boundary.

The durable cleanup path handles detached persisted resources through the cleanup queue, Recovery guard, and Storage API worker.

The orphan reconciliation path scans the private attachment bucket, classifies each object against the authoritative Attachment Resource table, deletes only objects with no Attachment Resource, and reports PENDING/FAILED resources as retryable rather than destroying their stable identity.

A PERSISTED Attachment Resource whose Storage Object is missing is surfaced as an integrity gap and is not silently deleted. This preserves the Recovery and durable-source-of-truth semantics for later explicit verification/recovery handling.

---

## 9. Frozen Cross-Domain Boundary

```text
Clone        → Attachment not automatically transferred
Inheritance  → Attachment not automatically transferred
Succession   → Attachment not automatically transferred
```

This migration does not expand transfer scope.

---

## 10. Frozen Security Matrix

Minimum verification cases:

- own Account + own SH attachment create → ALLOW;
- own read → ALLOW;
- other Account read → DENY;
- cross-SH Message association → DENY;
- spoofed attachment ID → DENY;
- spoofed storage reference → DENY;
- unauthenticated/anon → DENY;
- arbitrary storage path → DENY;
- invalid/nonexistent Message → DENY;
- duplicate finalize → idempotent/safe;
- retry same logical attachment → same attachment identity;
- failed persistence → not durable success;
- Message DELETE → relationship removed and cleanup queued; object retained while Recovery dependency exists;
- orphan Storage Object → service-only classification and Storage API removal;
- PENDING/FAILED + object → retryable resource, not blind deletion;
- PENDING/FAILED without object → retryable upload, not blind deletion;
- Clear → no destructive attachment mutation;
- Recovery create/restore → attachment dependency preserved/reconstructed or explicit gap;
- Clone/Inheritance/Succession → no implicit attachment transfer.

**Verification status:** implementation is present; authenticated semantic/E2E harness remains deferred.

---

## 11. Execution Result / Current DEV Checkpoint

Migration design is **FROZEN / LOCKED** and the design has been executed in DEV.

Applied migrations:

```text
20260908113655_conversation_attachments
20260908120543_revoke_conversation_attachment_truncate
20260909024233_conversation_attachment_cleanup
20260909024649_conversation_attachment_orphan_reconciliation
20260909024705_conversation_attachment_orphan_reconciliation_global
```

Repository migration sources:

```text
database/migrations/20260909024233_conversation_attachment_cleanup.sql
database/migrations/20260909024649_conversation_attachment_orphan_reconciliation.sql
database/migrations/20260909024705_conversation_attachment_orphan_reconciliation_global.sql
```

Repository migration source and Supabase DEV migration history are now reconciled by exact migration version/name. No alternate schema artifact is treated as authoritative.

Current implementation state:

```text
Attachment schema                    IMPLEMENTED
Private Storage bucket               IMPLEMENTED
RLS / privilege boundary             IMPLEMENTED
Trusted attachment RPCs              IMPLEMENTED
Message ↔ Attachment relationship    IMPLEMENTED
Recovery relationship                IMPLEMENTED
Cleanup queue / retention guard      IMPLEMENTED
Storage API cleanup worker           IMPLEMENTED
Orphan classification RPC            IMPLEMENTED
Service-only orphan reconciliation   IMPLEMENTED
FE attachment wiring                 IMPLEMENTED
```

Remaining verification/deferred work:

```text
Authenticated semantic harness      DEFERRED
Upload/reload/retry E2E              DEFERRED
Delete/cleanup/retention E2E         DEFERRED
Recovery create/restore E2E          DEFERRED
Real APK E2E                         DEFERRED
```

No frontend implementation was changed for this backend work.

---

## 12. Execution Gate

The design remains **FROZEN / LOCKED**. Cleanup/reconciliation implementation does not alter the approved Attachment semantic model or Clear semantics.

Backend source reconciliation is now aligned for both durable-retention cleanup and ambiguous-upload/orphan classification. Runtime/E2E execution is intentionally deferred per current scope.

Next work is execution verification, not another backend semantic/schema invention, unless E2E exposes a concrete source/runtime conflict.
