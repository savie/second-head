create or replace function public.runtime_record_knowledge_candidate(
  p_sh_id uuid,
  p_content text,
  p_source text,
  p_origin text,
  p_provenance jsonb default '{}'::jsonb,
  p_scope text default 'PRIVATE',
  p_visibility text default 'OWNER_ONLY',
  p_confidence numeric default null
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
begin
  if p_content is null or btrim(p_content) = '' then
    raise exception 'KNOWLEDGE_REJECTED: content is required';
  end if;
  if p_source is null or btrim(p_source) = '' then
    raise exception 'KNOWLEDGE_REJECTED: source is required';
  end if;
  if p_origin not in ('MEMORY','EXPLICIT_TEACHING','EXTERNAL_REFERENCE') then
    raise exception 'KNOWLEDGE_REJECTED: invalid origin';
  end if;
  if p_scope not in ('PRIVATE','GENERAL') then
    raise exception 'KNOWLEDGE_REJECTED: invalid scope';
  end if;
  if p_visibility not in ('OWNER_ONLY','SHARED') then
    raise exception 'KNOWLEDGE_REJECTED: invalid visibility';
  end if;
  if p_scope = 'GENERAL' and p_visibility <> 'SHARED' then
    raise exception 'KNOWLEDGE_REVIEW_REQUIRED: GENERAL scope requires SHARED visibility';
  end if;
  if p_confidence is not null and (p_confidence < 0 or p_confidence > 1) then
    raise exception 'KNOWLEDGE_REJECTED: invalid confidence';
  end if;

  select knowledge_id into v_id
  from public.knowledge
  where sh_id = p_sh_id
    and content = btrim(p_content)
    and lifecycle = 'CANDIDATE'
  order by updated_at desc
  limit 1
  for update;

  if v_id is not null then
    update public.knowledge
       set confidence = coalesce(p_confidence, confidence),
           provenance = coalesce(provenance, '{}'::jsonb) || coalesce(p_provenance, '{}'::jsonb),
           updated_at = now()
     where knowledge_id = v_id;
    return v_id;
  end if;

  insert into public.knowledge (
    content, knowledge_class, scope, visibility, source, provenance,
    confidence, lifecycle, sh_id
  ) values (
    btrim(p_content),
    case p_origin when 'EXPLICIT_TEACHING' then 'LEARNED' when 'EXTERNAL_REFERENCE' then 'IMPORTED' else 'TEMPORARY' end,
    p_scope,
    p_visibility,
    btrim(p_source),
    coalesce(p_provenance, '{}'::jsonb) || jsonb_build_object('origin', p_origin, 'acquisition', 'runtime:p4d:knowledge_candidate'),
    p_confidence,
    'CANDIDATE',
    case when p_scope = 'PRIVATE' then p_sh_id else null end
  ) returning knowledge_id into v_id;

  return v_id;
end;
$$;

revoke all on function public.runtime_record_knowledge_candidate(uuid,text,text,text,jsonb,text,text,numeric) from public;
grant execute on function public.runtime_record_knowledge_candidate(uuid,text,text,text,jsonb,text,text,numeric) to authenticated;