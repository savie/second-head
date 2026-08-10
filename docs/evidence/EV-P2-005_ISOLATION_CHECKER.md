# EV-P2-005 — Isolation Checker

Status: VERIFIED

## Scope

BL-P2-005 validates the Phase 2 cross-SH isolation boundary without resolving SH-000 technical identity and without introducing a new authorization mechanism.

## Implemented

`private.isolation_checker(target_domain, target_sh_id, actor_account_id)`:

- derives trusted actor identity from `auth.uid()` / `current_account_id()`;
- fails closed when trusted identity is absent or unresolved;
- rejects caller-supplied ACCOUNT_ID when it does not match the trusted identity;
- classifies target SH as `SYSTEM`, `SELF`, or `OTHER` using `sh_ownership`;
- treats `PRIVATE_MEMORY`, `PRIVATE_CONVERSATION`, and `PRIVATE_CONTEXT` as private targets;
- rejects cross-SH private-data access (`OTHER`);
- does not assume or encode a SH-000 reserved identity;
- is `SECURITY DEFINER` with locked `search_path` and executable only by `authenticated`.

## Verification

Supabase verification confirmed:

- function exists in schema `private`;
- `SECURITY DEFINER` is enabled;
- `anon` cannot execute it;
- `authenticated` can execute it;
- execution without trusted identity returns `FAIL` and reason `trusted identity context is absent; fail closed`.

## Boundary

This checker validates isolation only. It does not create a private-data sharing/authorization mechanism. Existing governance evaluation remains responsible for authorization decisions. Explicit scoped authorization is not invented here.

## Result

BL-P2-005 complete and verified.
