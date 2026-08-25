-- SECOND HEAD P5C — Succession execution after SH End-of-Life
-- Owner-approved semantics:
--   * End-of-Life deactivates the source identity but does not delete it.
--   * A successor receives only explicitly selected scope.
--   * Succession does not grant all private source state.
--   * Source and successor remain distinct SH identities.
--   * The successor must claim the transfer using an active PRIMARY SH.
-- Scope contract: {"memory_ids": [uuid...], "knowledge_ids": [uuid...]}

create table if not exists public.succession_events (
  succession_event_id uuid primary key default gen_random_uuid(),
  succession_id uuid not null references public.succession_rules(succession_id) on delete restrict,
  source_sh_id uuid not null references public.sh_instances(sh_id) on delete restrict,
  target_account_id uuid not null references public.accounts(account_id) on delete restrict,
  target_sh_id uuid not null references public.sh_instances(sh_id) on delete restrict,
  scope jsonb not null default '{}'::jsonb,
  transferred_counts jsonb not null default '{}'::jsonb,
  provenance jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists succession_events_source_idx on public.succession_events(source_sh_id, created_at desc);
create index if not exists succession_events_target_idx on public.succession_events(target_sh_id, created_at desc);

alter table public.succession_events enable row level security;
create policy succession_events_participant_select on public.succession_events for select using (
  exists(select 1 from public.sh_instances s where s.sh_id=succession_events.source_sh_id and s.account_id=current_account_id())
  or target_account_id=current_account_id()
);

create or replace function public.runtime_execute_succession(p_succession_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_rule public.succession_rules%rowtype;
  v_source public.sh_instances%rowtype;
  v_target public.sh_instances%rowtype;
  v_event uuid;
  v_scope jsonb;
  v_memory_count integer := 0;
  v_knowledge_count integer := 0;
  v_now timestamptz := now();
begin
  if auth.uid() is null then raise exception 'SUCCESSION_REJECTED: authentication required'; end if;

  select * into v_rule from public.succession_rules
   where succession_id=p_succession_id and status='ACTIVE' for update;
  if not found then raise exception 'SUCCESSION_REJECTED: active succession rule required'; end if;

  select * into v_source from public.sh_instances where sh_id=v_rule.source_sh_id;
  if not found then raise exception 'SUCCESSION_REJECTED: source SH not found'; end if;
  if v_source.status <> 'deactivated' then raise exception 'SUCCESSION_REJECTED: source SH must be end-of-life'; end if;

  if v_rule.successor_account_id <> public.current_account_id() then
    raise exception 'SUCCESSION_REJECTED: successor account required';
  end if;

  select * into v_target from public.sh_instances
   where account_id=v_rule.successor_account_id and status <> 'deactivated' and is_primary=true
   order by created_at asc limit 1;
  if not found then raise exception 'SUCCESSION_REJECTED: active successor PRIMARY SH required'; end if;

  v_scope := coalesce(v_rule.scope,'{}'::jsonb);
  if jsonb_typeof(coalesce(v_scope->'memory_ids','[]'::jsonb)) <> 'array' then
    raise exception 'SUCCESSION_REJECTED: scope.memory_ids must be an array';
  end if;
  if jsonb_typeof(coalesce(v_scope->'knowledge_ids','[]'::jsonb)) <> 'array' then
    raise exception 'SUCCESSION_REJECTED: scope.knowledge_ids must be an array';
  end if;

  insert into public.memories (sh_id,memory_type,content,source,confidence,scope,visibility,lifecycle,occurrence_count,created_at,updated_at,superseded_by)
  select v_target.sh_id,m.memory_type,m.content,m.source,m.confidence,m.scope,m.visibility,
    case when m.lifecycle='CANDIDATE' then 'ACTIVE' else m.lifecycle end,
    m.occurrence_count,v_now,v_now,null
  from public.memories m
  where m.sh_id=v_source.sh_id
    and m.memory_id = any(array(select jsonb_array_elements_text(v_scope->'memory_ids')::uuid));
  get diagnostics v_memory_count = row_count;

  insert into public.knowledge (content,knowledge_class,scope,visibility,source,provenance,confidence,version,lifecycle,superseded_by,created_at,updated_at,sh_id)
  select k.content,k.knowledge_class,k.scope,k.visibility,k.source,
    jsonb_build_object(
      'succession_origin', jsonb_build_object('source_sh_id',v_source.sh_id,'succession_id',v_rule.succession_id,'transferred_at',v_now),
      'original_provenance',k.provenance
    ),
    k.confidence,k.version,case when k.lifecycle='CANDIDATE' then 'ACTIVE' else k.lifecycle end,
    null,v_now,v_now,v_target.sh_id
  from public.knowledge k
  where k.sh_id=v_source.sh_id
    and k.knowledge_id = any(array(select jsonb_array_elements_text(v_scope->'knowledge_ids')::uuid));
  get diagnostics v_knowledge_count = row_count;

  insert into public.succession_events(succession_id,source_sh_id,target_account_id,target_sh_id,scope,transferred_counts,provenance)
  values (v_rule.succession_id,v_source.sh_id,v_rule.successor_account_id,v_target.sh_id,v_scope,
    jsonb_build_object('memory',v_memory_count,'knowledge',v_knowledge_count),
    jsonb_build_object('source','runtime_execute_succession','source_sh_id',v_source.sh_id,'target_sh_id',v_target.sh_id,'executed_at',v_now))
  returning succession_event_id into v_event;

  update public.succession_rules set status='CONSUMED' where succession_id=v_rule.succession_id;
  return v_event;
end;
$$;

revoke all on function public.runtime_execute_succession(uuid) from public;
grant execute on function public.runtime_execute_succession(uuid) to authenticated;
