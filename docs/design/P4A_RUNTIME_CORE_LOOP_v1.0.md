# P4A-001 — Runtime Core Loop Minimal Realization

**Phase:** Phase 4 — Runtime & Orchestration  
**Backlog:** BL-P4A-001 — Runtime Core Loop Skeleton  
**Status:** DEV IMPLEMENTED / VERIFICATION PENDING

## 1. Purpose

Provide the smallest runtime path that connects the already-existing identity boundary and Phase 3 cognitive capabilities without introducing a new identity, ownership model, provider lock-in, tool execution, action execution, or autonomous loop.

## 2. Runtime path

```text
auth.uid
  ↓
resolve existing identity
  ↓
read-only context assembly
  ↓
model adapter
  ↓
response
  ↓
post-response memory decision
```

## 3. Preserved invariants

- `RUNTIME != SH IDENTITY`
- Runtime resolves an existing identity; it does not create one.
- Context assembly is a read-only dependency from the runtime's perspective.
- The model is replaceable infrastructure and does not own SH identity.
- Memory decision is post-response and separate from context assembly.

## 4. Minimal realization boundaries

The skeleton intentionally does **not** implement:

- a concrete model provider SDK;
- database writes;
- tool registration or invocation;
- action execution;
- high-risk confirmation;
- autonomous loops;
- multi-model routing;
- a physical session table.

These remain downstream Phase 4 scope or existing bounded services.

## 5. Existing dependency alignment

Phase 1 already provides `public.resolve_identity()` as a current-principal, fail-closed resolution path from `auth.uid()` to `ACCOUNT_ID` and primary `SH_ID`, with no identity creation.  
Phase 2 already provides a runtime access boundary that fails closed and does not imply or transfer ownership.  
Phase 3 already provides context assembly and bounded cognitive pipelines.

## 6. Implementation artifact

`runtime/p4a/runtime_core_loop.ts`

The implementation uses dependency interfaces so the runtime core is not coupled to a model provider or storage implementation.

## 7. Verification boundary

The repository historically has no physical application source/test toolchain. Therefore this backlog adds a self-contained Deno-style test file but does **not** claim execution PASS until an appropriate Deno/runtime execution environment is available.

`UNVERIFIED != PASS`.
