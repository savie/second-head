-- Security hardening for BL-P3C-002 scoring primitive.
-- Pin the function search_path so name resolution cannot be influenced by a caller-controlled path.

alter function public.memory_relevance_score(text, text)
set search_path = pg_catalog;
