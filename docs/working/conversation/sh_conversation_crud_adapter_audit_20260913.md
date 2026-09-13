# SECOND HEAD — Conversation Message CRUD Adapter Audit — 2026-09-13

## Status

**WORKING — STATIC CONTRACT AUDIT PASS / DEVICE E2E OPEN**

Dokumen ini adalah catatan audit working. Dokumen ini tidak mengubah otoritas Canonical atau Approved Contract.

## Scope

Hanya alignment adapter untuk `update` dan `delete` pada individual Conversation Message.

Di luar scope:

- Conversation create/delete E2E
- Project mutation
- Attachment retry/idempotency
- Regenerate Assistant
- refactor Conversation yang lebih luas

## Evidence

### Backend function signatures

Supabase DEV saat ini mengekspos:

```text
runtime_update_conversation_message_v2(uuid,text,text)
runtime_delete_conversation_message_v2(uuid)
```

Kedua function menggunakan `SECURITY DEFINER`.

Privilege execution untuk authenticated:

```text
update → true
delete → true
```

Privilege execution untuk anonymous:

```text
update → false
delete → false
```

### Backend authorization boundary

`runtime_update_conversation_message_v2` me-resolve identity melalui `resolve_identity()` dan hanya melakukan update jika Message ID yang diberikan memang milik account dan SH yang ter-resolve serta old content cocok.

`runtime_delete_conversation_message_v2` me-resolve identity melalui `resolve_identity()` dan hanya melakukan delete jika Message ID yang diberikan memang milik account dan SH yang ter-resolve.

Jadi contract function dibatasi oleh actor/ownership, bukan hanya berdasarkan ID.

### Flutter adapter

`ConversationService` saat ini memetakan:

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

dan:

```dart
 deleteMessage(messageId)
    → runtime_delete_conversation_message_v2
       p_message_id
```

Mapping ini sesuai dengan signature dan nama parameter backend saat ini.

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

E2E device/runtime aktual belum digunakan sebagai evidence untuk:

```text
Edit Message
→ content berubah dan tersimpan
→ reload/navigation tetap mempertahankan perubahan

Delete Message
→ message terhapus
→ reload/navigation tetap menunjukkan message sudah tidak ada
```

Jangan menyatakan full Message CRUD E2E PASS sebelum kedua tindakan ini diuji secara independen.

## Next verification

Gunakan Conversation Message test/disposable di device DEV:

1. Kirim user message normal.
2. Edit message tersebut dan verifikasi content yang berubah tetap tersimpan setelah reload/navigation.
3. Hapus test message lain dan verifikasi message hilang serta tetap tidak muncul setelah reload/navigation.
4. Jangan menggunakan attachment retry sebagai evidence untuk mutation mana pun.

Expected:

```text
Edit E2E        PASS / FAIL
Delete E2E      PASS / FAIL
```

Hanya hasil yang benar-benar diuji yang boleh dipromosikan ke master inventory.
