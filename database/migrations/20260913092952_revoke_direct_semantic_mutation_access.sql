-- SECOND HEAD — direct semantic mutation access hardening
-- Supabase DEV migration applied.

revoke insert, update, delete, truncate on table public.knowledge from public, anon, authenticated;
revoke insert, update, delete, truncate on table public.journey_events from public, anon, authenticated;
revoke insert, update, delete, truncate on table public.knowledge_lifecycle_confirmations from public, anon, authenticated;
revoke insert, update, delete, truncate on table public.knowledge_lifecycle_operations from public, anon, authenticated;
