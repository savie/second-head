# SECOND HEAD — Conversation Message CRUD Adapter Audit — 2026-09-13

## Status

**WORKING — STATIC CONTRACT AUDIT PASS / DEVICE E2E PASS — OWNER-REPORTED**

Dokumen ini adalah catatan audit working. Dokumen ini tidak mengubah otoritas Canonical atau Approved Contract.

## Scope

Alignment adapter untuk `update` dan `delete` pada individual Conversation Message.

Di luar scope:

- Conversation create/delete E2E sebagai flow terpisah;
- Project mutation;
- Attachment retry/idempotency;
- Regenerate Assistant;
- refactor Conversation yang lebih luas.

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

`ConversationService` memetakan:

```dart
updateMessage(messageId, oldContent, newContent)
  → runtime_update_conversation_message_v2
     p_message_id
     p_old_content
     p_new_content
```

```dart
deleteMessage(messageId)
  → runtime_delete_conversation_message_v2
     p_message_id
```

Mapping sesuai dengan signature dan nama parameter backend saat ini.

## Result

```text
Backend signature alignment        PASS
Flutter parameter mapping         PASS
SECURITY DEFINER boundary         PASS
Authenticated EXECUTE             PASS
Anonymous EXECUTE denied           PASS
Ownership-scoped backend logic     PASS
Static adapter contract            PASS
Edit Message E2E                   PASS — OWNER-REPORTED
Delete Conversation/Message E2E   PASS — OWNER-REPORTED
```

### Latest owner-reported E2E evidence

Edit dan delete sudah digunakan dalam recovery test nyata. Data yang telah diedit pada Project / Conversation / Message / Memory / Knowledge / Experience tetap benar, kemudian Conversation dihapus dan full snapshot/restore dijalankan. Conversation dan data terkait berhasil kembali dengan state yang tetap benar.

Dengan evidence tersebut, status lama `DEVICE E2E OPEN` pada dokumen ini sudah stale dan direkonsiliasi menjadi `DEVICE E2E PASS — OWNER-REPORTED`.

## Remaining verification boundary

Pass di atas menutup mutation behavior yang benar-benar sudah diuji. Ini **tidak otomatis menutup seluruh Conversation verification**, khususnya local serialization round-trip dan attachment retry/idempotency.

Required separate gate:

```text
serialize → persist → read → deserialize
```

untuk semantic Message fields tetap berada pada `E2E Master Verification Matrix`.

## Next verification

Tidak perlu mengulang edit/delete sebagai blocker hanya karena dokumen lama belum diperbarui.

Fokus berikutnya adalah gate yang benar-benar belum ditutup pada E2E Master Verification Matrix.

## Change Control

Perubahan dokumen ini hanya merekonsiliasi status verification berdasarkan latest owner-reported execution evidence.

Tidak ada perubahan pada:

- Canonical;
- Approved Contract;
- backend schema;
- migration;
- runtime semantics.
