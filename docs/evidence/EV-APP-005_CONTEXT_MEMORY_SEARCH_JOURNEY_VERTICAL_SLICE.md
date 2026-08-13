# EV-APP-005 — Context / Memory / Search / Journey Vertical Slice

Status: VERIFIED IN DEV
Branch: `dev`

## Scope

Bounded authenticated App delivery surface for Context / Memory / Knowledge Search / Journey.

## Implementation

- `app/services/context.ts` calls the existing bounded `assemble_context` RPC with explicit memory/knowledge limits.
- `app/app/runtime-test.tsx` exposes the bounded Context / Memory / Search / Journey verification surface while preserving the existing Runtime Verification surface.
- Journey retrieval is filtered by the selected authorized `sh_id` and protected by the existing `journey_events` RLS policy.
- No service-role credential or provider secret is used by the App.
- No unrestricted local copy of the private memory store is created.

## Controlled verification

GitHub Actions run `31750691439` (`SH App Chat Verification #16`, commit `34dcf5389aea8d8386e9db1d06d99e2a31201758`) completed successfully.

Verified steps:

- app dependencies installed
- App typecheck
- chat request/response contract
- authenticated runtime response
- authenticated runtime streaming

The runtime verification script also exercises authenticated `assemble_context` retrieval and bounded `journey_events` retrieval using the authenticated SH identity.

## DEV data state

At verification time the DEV project contained zero rows in `memories`, `knowledge`, and `journey_events`; therefore the expected controlled result is valid empty-state arrays rather than fabricated content.

## Architecture audit

- App ↔ Runtime/Supabase boundary: PASS for bounded read path.
- Memory ≠ Knowledge: PASS; separate result collections are preserved.
- Private memory is not searched by unrestricted local download: PASS.
- Journey is SH-scoped and RLS-protected: PASS.
- Provider secrets/service-role credentials: PASS — not present in App path.
- Mutation: none introduced by the controlled verification.

## Classification

`IMPLEMENTED + VERIFIED` for the DEV delivery slice.

The existing architecture baseline still treats context assembly as runtime-sensitive; the current implementation uses the existing bounded Supabase RPC as a controlled read surface. A future runtime/API consolidation may move this read behind a dedicated Runtime adapter without changing the UI contract.

END
