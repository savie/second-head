# EV-P4A-003 — Memory Decision & State Update

Status: DEV IMPLEMENTED
Scope: Phase 4 — Runtime & Orchestration
Backlog: BL-P4A-003

## Reconciliation

- Memory decision remains a post-response boundary.
- Ordinary model output is not automatically persisted as memory.
- A model may propose a memory candidate, but the proposal is not authority by itself.
- Candidate defaults are conservative: PRIVATE, OWNER_ONLY, CANDIDATE, LONG_TERM, source=runtime_response.
- SH identity is resolved through the existing identity resolution path; runtime does not create SH identity.
- Persistence uses the existing `memories` table and existing owner RLS boundary.
- Atomic state update is implemented by `runtime_record_memory(...)`: an existing active candidate for the same SH/content is updated with incremented `occurrence_count`; otherwise a new memory row is inserted.
- The persistence function is SECURITY INVOKER and executable by authenticated users; ownership remains enforced by the existing `memories` RLS policy.
- No new ownership, identity, privacy, or security boundary was introduced.

## DEV Implementation

GitHub:
- `runtime/p4a/memory_decision.ts`
- `runtime/p4a/memory_decision.test.ts`
- `supabase/migrations/20260812100000_p4a_003_runtime_memory_decision.sql`
- `supabase/functions/runtime-p4a-003/index.ts`

Supabase DEV:
- `runtime-p4a-003` is ACTIVE with JWT verification enabled.
- `public.runtime_record_memory(...)` exists and is SECURITY INVOKER.
- `authenticated` has EXECUTE privilege.

## Assurance Boundary

This evidence does not claim application/UI E2E PASS. Any deferred runtime/model-level assurance remains deferred and is not treated as an implementation failure where the applicable acceptance contract is satisfied at the verifiable implementation level.

## Result

P4A-003 = DEV IMPLEMENTED.
Owner DM required = NO.
