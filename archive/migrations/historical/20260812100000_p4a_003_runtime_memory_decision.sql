create or replace function public.runtime_record_memory(
  p_sh_id uuid,
  p_content text,
  p_memory_type text default 'LONG_TERM',
  p_source text default 'runtime_response',
  p_confidence numeric default null,
  p_scope text default 'PRIVATE',
  p_visibility text default 'OWNER_ONLY',
  p_lifecycle text default 'CANDIDATE'
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_memory_id uuid;
begin
  if p_content is null or btrim(p_content) = '' then
    raise exception 'MEMORY_REJECTED: content is required';
  end if;
  if p_memory_type not in ('SHORT_TERM', 'LONG_TERM') then
    raise exception 'MEMORY_REJECTED: invalid memory_type';
  end if;
  if p_scope not in ('PRIVATE', 'GENERAL') then
    raise exception 'MEMORY_REJECTED: invalid scope';
  end if;
  if p_visibility not in ('OWNER_ONLY', 'SHARED') then
    raise exception 'MEMORY_REJECTED: invalid visibility';
  end if;
  if p_lifecycle not in ('CANDIDATE', 'ACTIVE') then
    raise exception 'MEMORY_REJECTED: invalid lifecycle';
  end if;
  if p_confidence is not null and (p_confidence < 0 or p_confidence > 1) then
    raise exception 'MEMORY_REJECTED: invalid confidence';
  end if;

  select memory_id into v_memory_id
  from public.memories
  where sh_id = p_sh_id
    and content = btrim(p_content)
    and lifecycle in ('CANDIDATE', 'ACTIVE', 'UPDATED')
  order by updated_at desc
  limit 1
  for update;

  if v_memory_id is not null then
    update public.memories
       set occurrence_count = occurrence_count + 1,
           updated_at = now(),
           confidence = coalesce(p_confidence, confidence),
           source = coalesce(nullif(p_source, ''), source),
           memory_type = p_memory_type,
           scope = p_scope,
           visibility = p_visibility
     where memory_id = v_memory_id;
    return v_memory_id;
  end if;

  insert into public.memories (
    sh_id, memory_type, content, source, confidence,
    scope, visibility, lifecycle, occurrence_count
  ) values (
    p_sh_id, p_memory_type, btrim(p_content), p_source, p_confidence,
    p_scope, p_visibility, p_lifecycle, 1
  )
  returning memory_id into v_memory_id;

  return v_memory_id;
end;
$$;

grant execute on function public.runtime_record_memory(uuid, text, text, text, numeric, text, text, text) to authenticated;
