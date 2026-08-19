# SECOND HEAD — SH APP OWNER UX STRUCTURE v1.1

Status: DEV FE DELIVERY TARGET / OWNER-APP UX
Branch: `dev`

## Purpose

Define the simplified owner-facing navigation after APK #93 review. This document describes presentation/navigation only; backend authority, ownership, authorization, lifecycle policy, and Journey recording remain server/runtime responsibilities.

## Primary flow

```text
AUTH
└── Login
     ↓
CHAT
     ↓
Bottom navigation
├── Chat
├── Journey
├── Lifecycle
└── More
```

Authenticated entry opens Chat directly. Home is not a required dashboard step for normal use.

## Chat

Chat is the primary owner surface:

```text
CHAT
├── conversation
├── input message
└── runtime response/state
```

## Journey

Journey is the unified continuity/history viewer. Experience does not need a separate primary Home button.

```text
JOURNEY
├── All
├── Memory
├── Knowledge
├── Experience
└── Lifecycle / Other
     ↓
  Event list
     ↓
  Event detail
  ├── What happened
  ├── Content
  ├── Source
  ├── Visibility
  ├── Policy
  └── Timestamp
```

Journey displays the result/history of activity. It does not execute lifecycle actions.

## Lifecycle

Lifecycle is an action/process surface only. Its results/history remain in Journey.

```text
LIFECYCLE
├── Clone
├── Recovery
├── Inheritance
├── Succession
├── End-of-Life
└── Legacy
```

Inheritance and Succession remain distinct capabilities even when they share an implementation surface temporarily.

## More

```text
MORE
├── Runtime Verification
├── Authorization
├── Error
└── Account / Sign out
```

Runtime Verification is intentionally technical. Diagnostic output must be native text and copyable from the device so owner/test evidence can be pasted into the development conversation without OCR/screenshots.

## Memory / Knowledge / Experience presentation

Memory and Knowledge do not receive empty or placeholder management screens merely to fill navigation. If a dedicated owner-management surface is not ready, they remain discoverable through Journey filters and authorized runtime context.

Experience remains a backend/product domain but is not required as a separate primary Home button when Journey can filter Experience events.

## UX principles

- Owner-facing navigation is capability-oriented rather than table-oriented.
- Do not expose internal domain names as the primary mental model when a human-readable capability exists.
- Do not require vertical scrolling through a long Home dashboard to discover lifecycle actions.
- Technical diagnostic data may remain detailed, but it must be selectable/copyable text.
- Journey event details should expose meaningful content before internal identifiers.
- Existing backend/runtime contracts remain authoritative.

## Architecture alignment

The application remains a delivery surface over Runtime/Supabase and does not implement governance, identity, ownership, or authorization locally.

This is a DEV UX realization of the existing SH App Architecture Baseline navigation principle: capability-oriented navigation, with exact UI implementation adapted from owner feedback.

END
