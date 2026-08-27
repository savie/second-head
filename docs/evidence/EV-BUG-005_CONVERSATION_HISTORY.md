# EV-BUG-005 — Conversation History Audit / Minimal Fix

Status: DEVICE VERIFIED / DB + UI ACCEPTANCE PASS

## Scope

BUG-005 covers persisted Conversation History as a product feature: navigation, continuity, and loading previously persisted conversations.

It is distinct from BUG-001, which covers short-term conversation context supplied to the active runtime/model request.

## Audit trace

### 1. Persistence

DEV persists chat messages in `public.conversations`.

The current table contains:

- `conversation_id`
- `account_id`
- `sh_id`
- `role`
- `content`
- `created_at`
- `metadata`

Runtime chat writes use `runtime_record_conversation(...)`.

### 2. Authenticated read

`runtime_load_conversation(p_limit)` resolves the authenticated identity through `resolve_identity()` and returns rows restricted to:

`account_id = resolved account_id`
and
`sh_id = resolved primary SH`.

The function is executable by `authenticated` and not by `anon`.

No direct table grants are present for `authenticated` on `public.conversations`.

### 3. Loader

Historical App loader logic existed, but the active implementation did not expose persisted history rows as a navigable product surface.

The App previously loaded a bounded recent slice directly into the Chat screen.

The runtime service also had a history loader, but the active Chat screen did not provide a persisted-history navigation surface.

### 4. Active conversation vs new conversation

The active Chat screen previously had only local `New chat` clearing.

There was no persisted conversation/session selection identity in the App.

Therefore:

- existing persisted rows could be loaded as the latest recent chat;
- `New chat` could clear the current UI;
- there was no product-level way to enumerate and reopen prior conversation groups.

### 5. Account / SH isolation

The database read path is scoped through `resolve_identity()` to the authenticated account and primary SH.

DEV database inspection shows the E2E account `e2e_test@sh.com` currently resolves to account `047927de-576b-4df1-9d82-4a02f0d5a932` and primary SH `e9f3e857-df6b-479b-a5df-09563b118604`.

That SH currently has 104 persisted conversation rows.

No cross-account/sh rows are returned by the read function's predicate.

### 6. Contract / UX comparison

The App architecture contract states that the App may render conversations and manage navigation/transient UI state, while server state remains authoritative.

The implementation contract requires continuity/history to survive device migration/reinstall when identity and data remain valid, and treats history loss as a continuity gap rather than silent replacement.

The active implementation did not provide persisted history navigation. This was the actual BUG-005 gap.

## Reproduction from actual implementation

The defect was reproducible from the current DEV source path:

1. Persisted conversation rows exist in `public.conversations`.
2. Chat screen loaded only the latest bounded recent rows.
3. Chat menu had `New chat`, rename, clear, delete, copy, share, and export UI.
4. There was no `Conversation history` navigation control.
5. There was no persisted conversation/session selector.
6. Therefore previously persisted conversation groups could not be enumerated and reopened as a product feature.

A live device reproduction could not be executed in this tool session because no Android/iOS device session was available. This is explicitly not claimed as device verification.

## Data evidence

E2E DEV account currently contains 104 conversation rows.

Using the project's existing 3600-second virtual-session rule, those rows form 9 virtual conversation groups in the current data set.

This is consistent with the existing P4A conversation-continuity implementation, which defines a virtual session boundary from the time gap without introducing a dedicated sessions table.

## Minimal fix

No database migration was introduced.

Two App-side changes were made:

1. `app/services/runtime-stream.ts`
   - added authenticated `loadConversationHistoryRows()`;
   - retains the existing authenticated runtime history endpoint;
   - returns normalized persisted conversation rows sorted chronologically.

2. `app/app/chat.tsx`
   - groups persisted rows into virtual conversation sessions using the existing 3600-second boundary;
   - adds `Conversation history` navigation;
   - lists persisted conversation groups;
   - allows reopening a selected persisted group;
   - preserves `New chat` as a local empty-chat action.

DEV commits:

- `d129d2a96e2c6d0a4354b12adea677ebe6d2300e` — expose persisted conversation history rows
- `125baf05793e16194b82eea6bf5083a32859ad2b` — add persisted conversation history navigation

## Why no migration

The existing P4A-005 design explicitly uses the `conversations` persistence boundary plus computed virtual-session continuity and does not require a dedicated `sessions` table.

The minimal fix therefore reuses the existing persisted rows and virtual-session rule instead of introducing speculative schema.

## Verification state

### PASS / confirmed

- persisted conversation records exist;
- authenticated history RPC exists;
- account/SH scoping is enforced by `resolve_identity()`;
- `anon` cannot execute the history RPC;
- direct authenticated table access is not granted;
- E2E data can be grouped into virtual sessions using the existing continuity rule;
- DEV App source now contains persisted history navigation.

### DEVICE ACCEPTANCE — PASS

APK #202 was built successfully and installed on the test device.

Device verification confirmed:

- Conversation History is visible.
- An existing conversation can be opened from History.
- Selected historical conversation content is correct.
- New Chat starts empty after leaving a historical conversation.
- History can be reopened after starting New Chat.
- After force-close/reopen, persisted conversation history remains available.
- Account/SH isolation remained correct for the tested E2E account.

### FINAL STATUS

**BUG-005 — CLOSED / PASS**

Edit/Delete/Regenerate controls visible inside conversations are not part of the BUG-005 acceptance scope and remain separate functionality to audit if required by contract.
