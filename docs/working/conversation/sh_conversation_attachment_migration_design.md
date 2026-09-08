# SECOND HEAD — Conversation Attachment Migration Design

## Status

**FROZEN / LOCKED — DEV MIGRATION EXECUTED / VERIFICATION CHECKPOINT OPEN**

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

Service-role/internal cleanup may operate on privileged attachment/storage records and objects.

Unauthenticated/anon access is denied.

---

## 5. Frozen RPC Boundary

The migration introduces authorized backend boundaries for:

1. `runtime_create_conversation_attachment(filename, mime_type, size_bytes)`
   - resolves Account/SH from trusted identity;
   - creates `PENDING` resource;
   - does not trust client Account/SH ownership input.

2. `runtime_finalize_conversation_attachment(attachment_id, message_id, storage_ref)`
   - requires trusted authenticated identity;
   - validates attachment ownership;
   - validates target Message ownership and same Account/SH;
   - validates pending/idempotent transition;
   - associates Message and marks `PERSISTED`.

3. `runtime_fail_conversation_attachment(attachment_id)`
   - trusted owner boundary;
   - transitions unfinished attachment to `FAILED`.

4. `runtime_load_conversation_attachments(message_id)`
   - trusted Message/Account/SH boundary;
   - returns durable descriptors for reconstruction.

5. `runtime_detach_conversation_attachment(attachment_id)`
   - removes active Message relationship by setting `message_id = NULL`;
   - does not physically delete Storage Object.

Physical cleanup is service-role/internal and is not exposed as an authenticated arbitrary-delete RPC.

Retry of the same logical attachment retains the same `attachment_id`.

---

## 6. Frozen Delete Semantics

Existing DEV Message delete function:
`runtime_delete_conversation_message_v2(uuid)`

Existing DEV Thread delete function:
`runtime_delete_conversation_thread(uuid)`

Existing DEV service-only Conversation delete function:
`runtime_delete_conversation(uuid)`

These functions remain trusted Account/SH boundaries as currently implemented.

Attachment rule:

```text
Delete Message / Conversation
        ↓
active attachment relationship removed
        ↓
Storage Object NOT blindly deleted
```

The FK uses `ON DELETE SET NULL`, so existing Message/Thread deletion remains compatible without requiring destructive trigger behavior.

Storage cleanup occurs only when no valid active Message or Recovery retention dependency remains.

Clear remains non-destructive and must not invoke attachment deletion/detach semantics.

---

## 7. Frozen Recovery Integration

Existing DEV Recovery captures/restores Conversation Messages inside `recovery_snapshots.manifest`.

The attachment migration integration is now **implemented in DEV** through persisted attachment descriptors/references. Binary data is not embedded in the JSON manifest.

Recovery relationship:

Table: `public.conversation_attachment_recovery_refs`

Columns:

- `snapshot_id uuid NOT NULL`.
- `attachment_id uuid NOT NULL`.
- `created_at timestamptz NOT NULL`.

Constraints:

- composite primary/unique relationship `(snapshot_id, attachment_id)`.
- FK `snapshot_id → recovery_snapshots.snapshot_id`.
- FK `attachment_id → conversation_attachments.attachment_id`.
- Recovery reference is a retention dependency, not a replacement for snapshot evidence.

Current snapshot/restore path:

```text
Message with durable attachment
        ↓
Recovery manifest captures attachment descriptor/reference
        ↓
Recovery reference retained
```

Restore:

```text
Snapshot
   ↓
Message
   ↓
Attachment reference
   ↓
existing durable Attachment/Storage Object
```

Missing durable object/resource must produce an explicit recovery gap; restore must not claim attachment recovery when the object cannot be reconstructed.

Existing Recovery idempotency and trusted Account ownership boundaries remain intact.

Current implementation has reached backend relationship/reconstruction support. Authenticated Recovery E2E, missing-object behavior, and cleanup/retention verification remain open.

---

## 8. Frozen Orphan / Retention Semantics

Distinguish:

```text
Storage Object without Attachment Resource
→ orphan object

Attachment Resource without active Message
→ may still be retained by Recovery

Attachment Resource without Message and without valid retention dependency
→ cleanup candidate
```

Because Storage upload and PostgreSQL transaction are not atomic, implementation must provide a cleanup/reconciliation path for failed database persistence after successful object upload.

No synchronous blind object deletion is attached to Message DELETE.

Current PENDING / PERSISTED / FAILED lifecycle and stable attachment identity support the intended retry boundary. Full orphan cleanup/reconciliation behavior remains a verification gate.

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
- Message DELETE → relationship removed, object retained when Recovery dependency exists;
- Clear → no destructive attachment mutation;
- Recovery create/restore → attachment dependency preserved/reconstructed or explicit gap;
- Clone/Inheritance/Succession → no implicit attachment transfer.

**Verification status:** implementation is present; authenticated semantic harness remains OPEN.

---

## 11. Pre-Migration Audit Result

Audited against current DEV definitions and privilege surface before SQL freeze:

- `runtime_create_conversation` — trusted identity and project ownership boundary preserved.
- `runtime_record_conversation_message` — trusted Account/SH/Thread boundary preserved; existing non-empty content rule preserved.
- `runtime_load_conversation_messages` — trusted Thread + Account/SH boundary preserved.
- `runtime_load_conversation_context_for_thread` — trusted Thread + Account/SH boundary preserved.
- `runtime_delete_conversation_message_v2` — authenticated trusted Account/SH delete boundary preserved.
- `runtime_delete_conversation_thread` — authenticated trusted Account/SH delete boundary preserved.
- `runtime_delete_conversation` — service-role-only boundary preserved.
- `runtime_create_recovery_snapshot` — authenticated, current-account-owned active SH validation preserved; Conversation remains in manifest.
- `runtime_restore_recovery_snapshot` — authenticated, current-account snapshot/SH validation and existing Recovery idempotency preserved; attachment reconstruction is additive and must surface missing attachment as a recovery gap.
- Existing RLS on Conversation/Recovery remains unchanged; new attachment resources receive their own RLS.
- Existing anon execution surface remains denied for the relevant Conversation/Recovery boundaries.

This section records the **pre-migration audit evidence**. It is not a statement that all post-migration runtime verification is complete.

---

## 12. Execution Result / Current DEV Checkpoint

Migration design is **FROZEN / LOCKED** and the design has been executed in DEV.

Applied migrations:

```text
20260908113655_conversation_attachments
20260908120543_revoke_conversation_attachment_truncate
```

Current implementation state:

```text
Attachment schema                 IMPLEMENTED
Private Storage bucket            IMPLEMENTED
RLS / privilege boundary          IMPLEMENTED
Trusted attachment RPCs           IMPLEMENTED
Message ↔ Attachment relationship IMPLEMENTED
Recovery relationship             IMPLEMENTED
FE attachment wiring              IMPLEMENTED
```

Remaining verification:

```text
Authenticated semantic harness   OPEN
Upload/reload/retry E2E           OPEN
Delete/cleanup/retention E2E      OPEN
Recovery create/restore E2E       OPEN
Real APK E2E                      OPEN
```

No additional schema migration is implied by these verification gaps.

---

## 13. Execution Gate

The design remains **FROZEN / LOCKED** for the implemented DEV migration. SQL must continue to conform to this design and must not silently introduce additional semantic scope.

Next verification gates:

1. verify schema/constraints/indexes;
2. verify bucket/privacy/storage policies;
3. verify RPC definitions/privileges;
4. verify Message delete and Conversation delete behavior;
5. verify Clear produces no destructive attachment mutation once Clear semantics are locked;
6. verify Recovery create/restore attachment handling;
7. run security matrix;
8. run FE integration verification;
9. run authenticated APK E2E.
