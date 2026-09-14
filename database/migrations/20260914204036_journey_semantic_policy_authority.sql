create or replace function public.runtime_classify_memory(p_memory_id uuid, p_scope text, p_visibility text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare v_account_id uuid;
begin
  if auth.uid() is null then raise exception 'MEMORY_CLASSIFY_REJECTED: authentication required'; end if;
  if p_scope not in ('PRIVATE','GENERAL') then raise exception 'MEMORY_CLASSIFY_REJECTED: invalid scope'; end if;
  if p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'MEMORY_CLASSIFY_REJECTED: invalid visibility'; end if;
  select s.account_id into v_account_id
    from public.memories m join public.sh_instances s on s.sh_id=m.sh_id
   where m.memory_id=p_memory_id and s.account_id=public.current_account_id() and s.status <> 'deactivated';
  if v_account_id is null then raise exception 'MEMORY_CLASSIFY_REJECTED: memory not owned by current account'; end if;
  update public.memories set scope=p_scope, visibility=p_visibility, updated_at=now() where memory_id=p_memory_id;
  update public.journey_events
     set visibility=case when p_visibility='SHARED' then 'SHARED' else 'PRIVATE' end,
         provenance=coalesce(provenance,'{}'::jsonb)||jsonb_build_object('policy_source','canonical_memory')
   where sh_id=(select sh_id from public.memories where memory_id=p_memory_id)
     and payload->>'memory_id'=p_memory_id::text;
end;
$$;

create or replace function public.runtime_classify_knowledge(p_knowledge_id uuid, p_scope text, p_visibility text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare v_account_id uuid; v_sh_id uuid;
begin
  if auth.uid() is null then raise exception 'KNOWLEDGE_CLASSIFY_REJECTED: authentication required'; end if;
  if p_scope not in ('PRIVATE','GENERAL') then raise exception 'KNOWLEDGE_CLASSIFY_REJECTED: invalid scope'; end if;
  if p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'KNOWLEDGE_CLASSIFY_REJECTED: invalid visibility'; end if;
  if p_scope='GENERAL' and p_visibility <> 'SHARED' then raise exception 'KNOWLEDGE_CLASSIFY_REJECTED: GENERAL scope requires SHARED visibility'; end if;
  select k.sh_id, s.account_id into v_sh_id, v_account_id
    from public.knowledge k join public.sh_instances s on s.sh_id=k.sh_id
   where k.knowledge_id=p_knowledge_id and s.account_id=public.current_account_id() and s.status <> 'deactivated';
  if v_account_id is null then raise exception 'KNOWLEDGE_CLASSIFY_REJECTED: knowledge not owned by current account'; end if;
  update public.knowledge set scope=p_scope, visibility=p_visibility, sh_id=v_sh_id, updated_at=now() where knowledge_id=p_knowledge_id;
  update public.journey_events
     set visibility=case when p_visibility='SHARED' then 'SHARED' else 'PRIVATE' end,
         provenance=coalesce(provenance,'{}'::jsonb)||jsonb_build_object('policy_source','canonical_knowledge')
   where sh_id=v_sh_id and payload->>'knowledge_id'=p_knowledge_id::text;
end;
$$;

revoke all on function public.runtime_classify_memory(uuid,text,text) from public, anon, authenticated;
revoke all on function public.runtime_classify_knowledge(uuid,text,text) from public, anon, authenticated;
grant execute on function public.runtime_classify_memory(uuid,text,text) to authenticated;
grant execute on function public.runtime_classify_knowledge(uuid,text,text) to authenticated;
