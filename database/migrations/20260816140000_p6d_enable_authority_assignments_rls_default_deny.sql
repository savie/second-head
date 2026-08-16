-- P6D security hardening: private authority assignment data is server-side only.
-- No client-facing policy is added. With RLS enabled and no policies,
-- non-owner/client roles remain denied by default.
alter table private.authority_assignments enable row level security;
