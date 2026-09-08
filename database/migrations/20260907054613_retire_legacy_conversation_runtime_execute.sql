REVOKE EXECUTE ON FUNCTION public.runtime_delete_conversation(uuid) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.runtime_load_conversation(integer) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.runtime_record_conversation(uuid,text,text,jsonb) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.runtime_rename_conversation(uuid,text) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.runtime_update_conversation_message(uuid,timestamp with time zone,text,text,text) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.runtime_delete_conversation_message(uuid,timestamp with time zone,text,text) FROM anon, authenticated;
