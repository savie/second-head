-- Restore the authenticated runtime boundary required by ai-runtime.
-- runtime_record_conversation is invoked through the authenticated Supabase client.

REVOKE EXECUTE ON FUNCTION public.runtime_record_conversation(uuid, text, text, jsonb) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.runtime_record_conversation(uuid, text, text, jsonb) FROM anon;
GRANT EXECUTE ON FUNCTION public.runtime_record_conversation(uuid, text, text, jsonb) TO authenticated;
