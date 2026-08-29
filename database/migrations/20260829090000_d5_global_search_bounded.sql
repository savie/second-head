-- D5 Global SH Search: bounded, authorized cross-domain retrieval.
create or replace function public.global_search_bounded(
  p_sh_id uuid, p_query_text text, p_limit integer default 20, p_offset integer default 0, p_domains text[] default null
)
returns table(result_id text, domain text, title text, snippet text, source_ref text, provenance jsonb, occurred_at timestamptz, relevance_score numeric)
language plpgsql security definer set search_path to public as $$
declare
  v_account_id uuid; v_query text := trim(coalesce(p_query_text, '')); v_limit integer := least(greatest(coalesce(p_limit,20),1),50);
  v_offset integer := least(greatest(coalesce(p_offset,0),0),200); v_domains text[];
begin
  if auth.uid() is null then raise exception 'GLOBAL_SEARCH_REJECTED: authentication required'; end if;
  v_account_id := public.current_account_id();
  if v_account_id is null then raise exception 'GLOBAL_SEARCH_REJECTED: account could not be resolved'; end if;
  if p_sh_id is null then raise exception 'GLOBAL_SEARCH_REJECTED: sh_id is required'; end if;
  if not exists (select 1 from public.sh_instances s where s.sh_id=p_sh_id and s.account_id=v_account_id) then raise exception 'GLOBAL_SEARCH_REJECTED: SH is not owned by current account'; end if;
  if length(v_query)=0 then raise exception 'GLOBAL_SEARCH_REJECTED: query is required'; end if;
  if length(v_query)>2000 then raise exception 'GLOBAL_SEARCH_REJECTED: query too large'; end if;
  v_domains := case when p_domains is null or cardinality(p_domains)=0 then array['CONVERSATION','MEMORY','KNOWLEDGE','EXPERIENCE','JOURNEY']::text[] else array(select upper(trim(x)) from unnest(p_domains) x) end;
  if exists (select 1 from unnest(v_domains) d where d not in ('CONVERSATION','MEMORY','KNOWLEDGE','EXPERIENCE','JOURNEY')) then raise exception 'GLOBAL_SEARCH_REJECTED: unsupported domain'; end if;
  return query
  with candidates as (
    select c.conversation_id::text,'CONVERSATION'::text,case when c.role='user' then 'You' else 'SH' end,c.content,
      'conversation:'||c.conversation_id::text,jsonb_build_object('role',c.role,'conversation_id',c.conversation_id,'created_at',c.created_at),c.created_at,
      case when lower(c.content)=lower(v_query) then 100 when position(lower(v_query) in lower(c.content))=1 then 80 else 60 end::numeric
    from public.conversations c
    where 'CONVERSATION'=any(v_domains) and c.account_id=v_account_id and c.sh_id=p_sh_id and position(lower(v_query) in lower(c.content))>0
      and coalesce((c.metadata->>'verification_only')::boolean,false)=false
    union all
    select m.memory_id::text,'MEMORY'::text,m.memory_type,m.content,'memory:'||m.memory_id::text,
      jsonb_build_object('source',m.source,'scope',m.scope,'visibility',m.visibility,'provenance',m.provenance),m.updated_at,
      case when lower(m.content)=lower(v_query) then 100 when position(lower(v_query) in lower(m.content))=1 then 80 else 60 end::numeric
    from public.memories m
    where 'MEMORY'=any(v_domains) and m.sh_id=p_sh_id and m.lifecycle in ('CANDIDATE','ACTIVE','UPDATED') and position(lower(v_query) in lower(m.content))>0
    union all
    select k.knowledge_id::text,'KNOWLEDGE'::text,k.knowledge_class,k.content,'knowledge:'||k.knowledge_id::text,
      jsonb_build_object('source',k.source,'scope',k.scope,'visibility',k.visibility,'provenance',k.provenance),k.updated_at,
      case when lower(k.content)=lower(v_query) then 100 when position(lower(v_query) in lower(k.content))=1 then 80 else 60 end::numeric
    from public.knowledge k
    where 'KNOWLEDGE'=any(v_domains) and k.scope='GENERAL' and k.visibility='SHARED' and k.lifecycle in ('INDEXED','ACTIVE') and position(lower(v_query) in lower(k.content))>0
    union all
    select e.experience_id::text,'EXPERIENCE'::text,e.experience_type,e.content,'experience:'||e.experience_id::text,
      jsonb_build_object('source_ref',e.source_ref,'scope',e.scope,'visibility',e.visibility,'provenance',e.provenance),e.occurred_at,
      case when lower(e.content)=lower(v_query) then 100 when position(lower(v_query) in lower(e.content))=1 then 80 else 60 end::numeric
    from public.experiences e
    where 'EXPERIENCE'=any(v_domains) and e.sh_id=p_sh_id and e.account_id=v_account_id
      and ((e.scope='PRIVATE' and e.visibility='OWNER_ONLY') or (e.scope='GENERAL' and e.visibility='SHARED')) and position(lower(v_query) in lower(e.content))>0
    union all
    select j.event_id::text,'JOURNEY'::text,j.event_type,j.payload::text,'journey:'||j.event_id::text,
      jsonb_build_object('source_ref',j.source_ref,'continuity_status',j.continuity_status,'provenance',j.provenance,'payload',j.payload),j.occurred_at,
      case when position(lower(v_query) in lower(j.payload::text))=1 then 80 else 60 end::numeric
    from public.journey_events j
    where 'JOURNEY'=any(v_domains) and j.sh_id=p_sh_id and j.account_id=v_account_id and position(lower(v_query) in lower(j.payload::text))>0
  )
  select * from candidates order by relevance_score desc, occurred_at desc, result_id asc offset v_offset limit v_limit;
end; $$;
revoke all on function public.global_search_bounded(uuid,text,integer,integer,text[]) from public;
grant execute on function public.global_search_bounded(uuid,text,integer,integer,text[]) to authenticated;