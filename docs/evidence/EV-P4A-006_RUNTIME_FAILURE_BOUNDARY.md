# EV-P4A-006 — Runtime Failure Boundary

Status: IMPLEMENTED / DEV

## Scope

P4A-006 is a minimal Runtime Pipeline realization for request validation and fail-closed runtime error boundaries.

The Phase 4 Analysis Report does not enumerate a formal P4A-006 ID. This slice is therefore treated as an engineering realization under the report's Runtime Pipeline / conversation handling boundary, not as a new canonical backlog authority.

## Reconciliation

- No SH identity creation.
- No ownership mutation.
- No permission mutation.
- No Core mutation.
- No model-provider lock-in.
- No tool/action authority granted.
- No persistent session architecture introduced.

## Behavior

1. Generate a request ID at the runtime boundary.
2. Require POST requests.
3. Require a bearer authorization header; JWT verification remains enabled at the Edge Function platform boundary.
4. Validate and bound `user_message`.
5. Return stable, non-sensitive error envelopes.
6. Never expose internal exception details.
7. Preserve SH identity as an explicit field when a successful runtime component returns data.

## Assurance

Application/API/UI E2E is not claimed by this evidence. This is an implementation-level runtime boundary artifact and follows the project's deferred-assurance rule.

## DEV

GitHub branch: `dev`
Supabase function: `runtime-p4a-006`
