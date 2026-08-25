-- Reconcile DEV database state: recovery snapshots/restores include Experience.
-- This migration is intentionally idempotent and records the already-verified DEV state.
-- The authoritative recovery implementation must preserve Experience alongside
-- identity, ownership, Memory, Conversation, Journey, Knowledge, and Legacy.

-- DEV parity marker only; no destructive data migration is required because
-- the target database state was already verified directly in Supabase DEV.
DO $$
BEGIN
  PERFORM 1;
END
$$;
