# SECOND HEAD — Conversation Message CRUD Adapter Audit — 2026-09-13

## Status

**WORKING — STATIC CONTRACT AUDIT PASS / DEVICE E2E OPEN**

This document is a working audit record. It does not modify Canonical or Approved Contract authority.

## Scope

Only individual Conversation Message `update` and `delete` adapter alignment.

Out of scope:

- Conversation create/delete E2E
- Project mutation
- Attachment retry/idempotency
- Regenerate Assistant
- broader Conversation refactor

## Evidence

### Backend function signatures

Supabase DEV currently exposes:

```text
runtime_update_conversation_message_v2(uuid,text,text)
runtime_delete_conversation_message_v2(uuid)
```

Both functions are `SECURITY DEFINER`.

Authenticated execution privilege:

```text
update → true
delete → true
```

Anonymous execution privilege:

```text
update → false
delete → false
```

### Backend authorization boundary

`runtime_update_conversation_message_v2` resolves identity through `resolve_identity()` and updates only when the supplied message ID belongs to the resolved account and SH and the old content matches.

`runtime_delete_conversation_message_v2` resolves identity through `resolve_identity()` and deletes only when the supplied message ID belongs to the resolved account and SH.

Therefore the function contract is actor/ownership scoped rather than ID-only.

### Flutter adapter

Current `ConversationService` maps:

```dart
updateMessage(
  messageId,
  oldContent,
  newContent,
)
    → runtime_update_conversation_message_v2
       p_message_id
       p_old_content
       p_new_content
```

and:

```dart
 deleteMessage(messageId)
    → runtime_delete_conversation_message_v2
       p_message_id
```

This matches the current backend signatures and parameter names.

## Result

```text
Backend signature alignment       PASS
Flutter parameter mapping        PASS
SECURITY DEFINER boundary        PASS
Authenticated EXECUTE            PASS
Anonymous EXECUTE denied          PASS
Ownership-scoped backend logic    PASS
Static adapter contract           PASS
```

## Remaining verification gap

Actual device/runtime E2E has not been used as evidence for:

```text
Edit Message
→ persisted updated content
→ reload/navigation persistence

Delete Message
→ message removed
→ reload/navigation persistence
```

Do not claim full Message CRUD E2E PASS until these actions are independently tested.

## Next verification

Use a disposable/test Conversation Message on the DEV device:

1. Send a normal user message.
2. Edit that exact message and verify the changed content persists after reload/navigation.
3. Delete another test message and verify it disappears and remains absent after reload/navigation.
4. Do not use attachment retry as evidence for either mutation.

Expected:

```text
Edit E2E        PASS / FAIL
Delete E2E      PASS / FAIL
```

Only the tested result should be promoted into the master inventory.
