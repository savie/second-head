# SH Context Runtime Reconciliation

## Status

No.5 Context Step 1 implemented.

## Decision

Context Runtime does not replace existing context engines. It introduces a runtime entry point that composes existing boundaries.

## Runtime Entry Point

`public.runtime_get_context_package(p_sh_id uuid, p_query_text text)`

## Assembly Flow

```
Request
  |
  v
Context Runtime Package
  |
  +--> identity boundary
  +--> runtime_load_conversation_context()
  +--> runtime_get_sh_state()
  +--> assemble_context()
  |
  v
Context Package
```

## Existing Components Reused

- Conversation Context Runtime
- SH State Runtime
- Semantic Context Assembly Engine

## Non-goals

- No new Context table.
- No duplicate Conversation storage.
- No duplicate Memory or Knowledge storage.
- No bypass of existing security boundaries.

## Implementation Notes

The runtime entry point acts as orchestration only. Existing domain ownership remains in each existing runtime function.
