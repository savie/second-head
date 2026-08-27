# EV-BUG-003 — MEMORY RESPONSE LIST FORMATTING

Status: **FIXED**

## Scope
Presentation/serialization of a Memory list requested with one item per line and a blank line between items.

## Problem
Memory retrieval itself worked, but formatted output could collapse:

`1. ...`

`2. ...3. ...`

The backend returned the expected Memory records; the defect was in response formatting/serialization.

## Trace
`authorized_memory_context → context assembly → model request → runtime SSE serialization → natural-language response`

## Root causes
Two defects were identified:

1. Explicit response-format instructions were not sufficiently enforced in the semantic model prompt.
2. Runtime SSE chunk handling could fail to preserve newline characters.

## Fixes
Commit:
`93bf3f8c3911592de9bc92deb7c6cb9d4938c018`
— honor explicit response formatting instructions.

Commit:
`945b659fd5e28ef48bc8130029f81d1b6f80d171`
— preserve newlines in runtime SSE chunks.

## Important distinction
Memory inventory/retrieval was already PASS:

- all Memory retrieval: PASS;
- no new Memory during retrieval: PASS;
- no new duplicate: PASS.

The defect was response presentation/serialization.

## Final
**🟢 FIXED**

Frozen baseline was not modified.
