# EV-BUG-001 — SHORT-TERM CONVERSATIONAL RECALL

Status: **FIXED + DEVICE VERIFIED**

## Scope
Short-term conversational recall inside the active conversation/runtime model context.

This is distinct from persisted Conversation History (BUG-005).

## Problem
Conversation messages were persisted and visible in UI, but recent conversation history was not being sent back into the model runtime.

## Root cause
Missing runtime-owned retrieval path:

`conversation persistence → runtime-owned retrieval → active-SH scope → bounded recent window → conversation_context → model request`

Memory and Experience remained separate persistence/context domains and were not used as transcript storage.

## Fix
Runtime conversation-context retrieval was added using the existing `conversations` persistence.

The DB function limits the recent-message window and verifies `sh_id` against the authenticated active SH.

Migration:
`20260826050000_bug_001_short_term_conversation_context`

## Verification
Device verification confirmed SH could refer to earlier messages in the active conversation without depending on Memory or Experience.

## Evidence basis
Reconstructed from Session Resume 68 and its recorded implementation lineage.

## Final
**🟢 FIXED + DEVICE VERIFIED**

Frozen baseline was not modified.
