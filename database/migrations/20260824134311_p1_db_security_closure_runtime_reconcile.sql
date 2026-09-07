revoke execute on function public.runtime_cleanup_verification_artifacts(uuid, text) from anon;
revoke execute on function public.runtime_create_recovery_snapshot(uuid, text) from anon;
alter function public.memory_relevance_score(text, text) set search_path = pg_catalog, public;