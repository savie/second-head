REVOKE EXECUTE ON FUNCTION public.retrieve_memories_bounded(uuid, text, integer) FROM anon;
GRANT EXECUTE ON FUNCTION public.retrieve_memories_bounded(uuid, text, integer) TO authenticated;
