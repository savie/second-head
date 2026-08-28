# EV-BUG-006 — CHAT ACTIONS FUNCTIONALITY

Status: **CLOSED / PASS — DEVICE VERIFIED**

## Scope
User-facing actions exposed by the Chat conversation menu (⋮), message menu (⋮), and related chat actions.

## Initial audit
The #202 implementation showed several actions were UI/local-state only:

- Edit message — local state only.
- Delete message — local state only.
- Delete conversation — local state only.
- Rename conversation — local state only.
- Regenerate — prepared the last user message rather than actually regenerating through Runtime.
- Share conversation — placeholder.
- Export conversation — placeholder.
- Attachments (File/Photo/Camera) — placeholder.

Copy actions were already proven.

## Fix implemented
Authenticated DB RPCs were added for:

- persisted message update;
- persisted message deletion;
- persisted conversation deletion;
- persisted conversation rename.

The App service layer now calls those authenticated RPCs.

Chat was updated so:

- Edit persists the edited message;
- Delete message persists deletion;
- Delete conversation persists deletion;
- Rename persists conversation title in conversation metadata;
- History recognizes persisted conversation titles;
- Share uses the native OS share surface;
- Export uses the native OS share surface with exported conversation text;
- Regenerate deletes the persisted previous assistant response when identifiable and sends the last user prompt through Runtime again;
- after a normal send, persisted history is synchronized back into Chat state so subsequent actions have persisted row identity.

## Database security
The new RPCs require an authenticated user and verify that the conversation's SH belongs to the current active account before mutation.

## Provenance
DB migration:
`20260827150000_bug006_chat_actions`

Git commits:
- `ac94a739214d217250b7a58397bb8a882293dbdd` — DB RPC migration
- `2e4d6e3f92b8d13e20372d2948fafdaf13b4a47a` — runtime service calls
- `d1887aba3e4c66ca4d81f56f8d24a3bbc113005b` — Chat action wiring
- `e43811204948ea186905c40517a80eb1034160ab` — persisted-state synchronization and title handling

## Verification evidence

### APK #220 — device regression
Manual Android build **#220** was installed and tested on device.

Verified PASS:

- Conversation history opens and persisted conversations can be opened.
- Conversation rename works.
- Conversation find/search works and identifies matching conversation content.
- Copy works and was verified by copy/paste.
- Share works through native text sharing.
- Export works through native text export/share.
- Delete conversation removes it from history.
- Message copy works.
- Message edit works.
- Message delete works.
- Regenerate works by creating a new user prompt/assistant response rather than duplicating streamed chunks.
- Android back behavior for required-choice/action dialogs was fixed and verified.
- File attachment works.
- Photo attachment works.
- Camera attachment works.
- Attached filename is rendered as part of the sent message rather than remaining only in the composer.
- File content can be processed by Runtime.
- Photo/camera images can be processed by Runtime/model.
- Attachment conversation continuity/history behavior was verified.
- Account/SH isolation was verified: attachment/conversation data did not appear for another user.

### Regression result

All previously identified BUG-006 Chat Actions and attachment cases tested on the active regression APK are **PASS**.

The earlier attachment failure:

`MODEL_SELECTION_FAILED: no zero-budget model available for capability/task`

is no longer reproduced on APK #220.

The earlier attachment UI-only behavior is no longer reproduced: the attachment is represented in the sent message and participates in runtime processing.

## Dialog/back behavior
Verified on device. Required-choice dialogs cannot be bypassed with Android back; the user must explicitly choose an available option.

## Final status
**🟢 CLOSED / PASS — APK #220 DEVICE VERIFIED**
