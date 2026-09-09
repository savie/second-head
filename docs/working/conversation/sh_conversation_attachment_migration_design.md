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

Service-role/internal cleanup may operate on privileged attachment/storage records and objects.

Unauthenticated/anon access is denied.

---

## 5. Frozen RPC Boundary

The migration introduces authorized backend boundaries for:

1. `runtime_create_conversation_attachment(filename, mime_type, size_bytes)`
2. `runtime_finalize_conversation_attachment(attachment_id, message_id, storage_ref)`
3. `runtime_fail_conversation_attachment(attachment_id)`
4. `runtime_load_conversation_attachments(message_id)`
5. `runtime_detach_conversation_attachment(attachment_id)`

All resolve/validate trusted Account/SH ownership at the backend boundary. Client-provided ownership values are not authority. Finalize validates target Message ownership and same Account/SH. Retry of the same logical attachment retains the same `attachment_id`.

Physical cleanup is service-role/internal and is not exposed as an authenticated arbitrary-delete RPC.

---

## 6. Frozen Delete and Clear Semantics

Existing DEV Message/Conversation deletion functions remain trusted Account/SH boundaries as currently implemented.

Attachment rule:

```text
Delete Message / Conversation
        ↓
active attachment relationship removed
        ↓
Storage Object NOT blindly deleted
```

The FK uses `ON DELETE SET NULL`, so existing Message/Thread deletion remains compatible without destructive trigger behavior.

Storage cleanup occurs only when no valid active Message or Recovery retention dependency remains.

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

Authenticated Recovery E2E, missing-object behavior, and cleanup/retention verification remain open.

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

No synchronous blind object deletion is attached to Message DELETE or Clear.

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

## 11. Execution Result / Current DEV Checkpoint

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

## 12. Execution Gate

The design remains **FROZEN / LOCKED** for the implemented DEV migration.

Clear semantics are now locked separately as an application-session presentation state. Attachment implementation must preserve that boundary and must not introduce destructive Clear behavior.

Next verification gates:

1. verify schema/constraints/indexes;
2. verify bucket/privacy/storage policies;
3. verify RPC definitions/privileges;
4. verify Message delete and Conversation delete behavior;
5. verify Clear produces no destructive attachment mutation;
6. verify Recovery create/restore attachment handling;
7. run security matrix;
8. run FE integration verification;
9. run authenticated APK E2E.
