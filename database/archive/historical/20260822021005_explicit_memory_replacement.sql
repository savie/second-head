create or replace function public.runtime_replace_memory(
  p_sh_id uuid,
  p_new_content text,
  p_old_pattern text,
  p_source text default 'runtime:p5a:explicit_user_request',
  p_scope text default 'PRIVATE',
  p_visibility text default 'OWNER_ONLY'
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_new uuid;
  v_account uuid;
begin
  if auth.uid() is null then raise exception 'MEMORY_REPLACE_REJECTED: authentication required'; end if;
  select s.account_id into v_account
  from public.sh_instances s
  where s.sh_id = p_sh_id
    and s.account_id = public.current_account_id()
    and s.status <> 'deactivated';
  if v_account is null then raise exception 'MEMORY_REPLACE_REJECTED: SH not owned by current active account'; end if;
  if p_new_content is null or btrim(p_new_content) = '' then raise exception 'MEMORY_REPLACE_REJECTED: content is required'; end if;
  if p_scope not in ('PRIVATE','GENERAL') or p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'MEMORY_REPLACE_REJECTED: invalid scope or visibility'; end if;

  insert into public.memories(sh_id,memory_type,content,source,scope,visibility,lifecycle,occurrence_count)
  values(p_sh_id,'LONG_TERM',btrim(p_new_content),coalesce(nullif(btrim(p_source),''),'runtime:p5a:explicit_user_request'),p_scope,p_visibility,'CANDIDATE',1)
  returning memory_id into v_new;

  if nullif(btrim(p_old_pattern),'') is not null then
    update public.memories
       set lifecycle = 'UPDATED', superseded_by = v_new, updated_at = now()
     where sh_id = p_sh_id
       and lifecycle in ('CANDIDATE','ACTIVE')
       and superseded_by is null
       and content ilike '%' || btrim(p_old_pattern) || '%';
  end if;

  return v_new;
end;
$$;

grant execute on function public.runtime_replace_memory(uuid,text,text,text,text,text) to authenticated;
