-- SECOND HEAD — Conversation Attachment security reconciliation
-- Scope: remove direct TRUNCATE privilege from authenticated.
-- No schema or runtime contract change.

REVOKE TRUNCATE ON TABLE public.conversation_attachments FROM authenticated;
