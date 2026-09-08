create or replace function public.runtime_restore_recovery_snapshot(p_snapshot_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_snapshot public.recovery_snapshots%rowtype;
  v_id uuid;
  v_sh_id uuid;
  v_identity uuid;
  v_account_id uuid;
  v_gap text := null;
  v_before_ownership integer := 0;
  v_before_knowledge integer := 0;
  v_before_legacy integer := 0;
  v_after_ownership integer := 0;
  v_after_knowledge integer := 0;
  v_after_legacy integer := 0;
  v_missing_ownership integer := 0;
  v_missing_knowledge integer := 0;
  v_missing_legacy integer := 0;
begin
  select * into v_snapshot
  from public.recovery_snapshots
  where snapshot_id=p_snapshot_id and account_id=current_account_id();
  if not found then raise exception 'RECOVERY_REJECTED: snapshot not accessible'; end if;

  v_sh_id := v_snapshot.sh_id;
  v_account_id := current_account_id();
  v_identity := (v_snapshot.manifest->'identity_root'->>'sh_id')::uuid;

  if v_identity <> v_sh_id then raise exception 'RECOVERY_REJECTED: identity root mismatch'; end if;
  if not exists(select 1 from public.sh_instances where sh_id=v_sh_id and account_id=v_account_id) then
    raise exception 'RECOVERY_REJECTED: target SH ownership mismatch';
  end if;

  select count(*) into v_before_ownership from public.sh_ownership where sh_id=v_sh_id;
  select count(*) into v_before_knowledge from public.knowledge where sh_id=v_sh_id and scope='PRIVATE';
  select count(*) into v_before_legacy from public.legacy_records where source_sh_id=v_sh_id;

  select count(*) into v_missing_ownership
  from jsonb_to_recordset(coalesce(v_snapshot.manifest->'ownership_root','[]'::jsonb)) as x(sh_id uuid, account_id uuid)
  where x.sh_id=v_sh_id and x.account_id=v_account_id
    and not exists (select 1 from public.sh_ownership o where o.sh_id=x.sh_id and o.account_id=x.account_id);

  select count(*) into v_missing_knowledge
  from jsonb_to_recordset(coalesce(v_snapshot.manifest->'knowledge','[]'::jsonb)) as x(sh_id uuid, scope text, visibility text)
  where x.sh_id=v_sh_id and x.scope='PRIVATE'
    and not exists (select 1 from public.knowledge k where k.knowledge_id=(x::jsonb->>'knowledge_id')::uuid);

  select count(*) into v_missing_legacy
  from jsonb_to_recordset(coalesce(v_snapshot.manifest->'legacy_records','[]'::jsonb)) as x(source_sh_id uuid, legacy_id uuid)
  where x.source_sh_id=v_sh_id
    and not exists (select 1 from public.legacy_records l where l.legacy_id=(x::jsonb->>'legacy_id')::uuid);

  insert into public.sh_ownership(sh_id,account_id)
  select x.sh_id,x.account_id
  from jsonb_to_recordset(coalesce(v_snapshot.manifest->'ownership_root','[]'::jsonb)) as x(sh_id uuid,account_id uuid)
  where x.sh_id=v_sh_id and x.account_id=v_account_id
  on conflict do nothing;

  insert into public.memories(memory_id,sh_id,memory_type,content,source,confidence,scope,visibility,lifecycle,occurrence_count,created_at,updated_at,superseded_by)
  select x.memory_id,x.sh_id,x.memory_type,x.content,x.source,x.confidence,x.scope,x.visibility,x.lifecycle,x.occurrence_count,x.created_at,x.updated_at,x.superseded_by
  from jsonb_to_recordset(coalesce(v_snapshot.manifest->'memories','[]'::jsonb)) as x(memory_id uuid,sh_id uuid,memory_type text,content text,source text,confidence numeric,scope text,visibility text,lifecycle text,occurrence_count integer,created_at timestamptz,updated_at timestamptz,superseded_by uuid)
  where x.sh_id=v_sh_id
  on conflict (memory_id) do nothing;

  insert into public.conversations(conversation_id,account_id,sh_id,role,content,created_at,metadata)
  select x.conversation_id,x.account_id,x.sh_id,x.role,x.content,x.created_at,x.metadata
  from jsonb_to_recordset(coalesce(v_snapshot.manifest->'conversations','[]'::jsonb)) as x(conversation_id uuid,account_id uuid,sh_id uuid,role text,content text,created_at timestamptz,metadata jsonb)
  where x.sh_id=v_sh_id and x.account_id=v_account_id
  on conflict (conversation_id) do nothing;

  insert into public.journey_events(event_id,sh_id,account_id,event_type,occurred_at,continuity_status,gap_code,payload,source_ref,created_at)
  select x.event_id,x.sh_id,x.account_id,x.event_type,x.occurred_at,x.continuity_status,x.gap_code,x.payload,x.source_ref,x.created_at
  from jsonb_to_recordset(coalesce(v_snapshot.manifest->'journey_events','[]'::jsonb)) as x(event_id uuid,sh_id uuid,account_id uuid,event_type text,occurred_at timestamptz,continuity_status text,gap_code text,payload jsonb,source_ref text,created_at timestamptz)
  where x.sh_id=v_sh_id and x.account_id=v_account_id
  on conflict (event_id) do nothing;

  select count(*) into v_after_ownership from public.sh_ownership where sh_id=v_sh_id;
  select count(*) into v_after_knowledge from public.knowledge where sh_id=v_sh_id and scope='PRIVATE';
  select count(*) into v_after_legacy from public.legacy_records where source_sh_id=v_sh_id;

  if v_missing_ownership > 0 or v_missing_knowledge > 0 or v_missing_legacy > 0 then
    v_gap := concat_ws(',',
      case when v_missing_ownership > 0 then 'RECOVERY_OWNERSHIP_MISSING' end,
      case when v_missing_knowledge > 0 then 'RECOVERY_PRIVATE_KNOWLEDGE_MISSING' end,
      case when v_missing_legacy > 0 then 'RECOVERY_LEGACY_MISSING' end
    );
  end if;

  if v_gap is not null then
    if v_missing_ownership > 0 and v_after_ownership < v_before_ownership + v_missing_ownership then
      v_gap := concat(v_gap, ',RECOVERY_OWNERSHIP_UNRESOLVED');
    end if;
    if v_missing_knowledge > 0 and v_after_knowledge < v_before_knowledge + v_missing_knowledge then
      v_gap := concat(v_gap, ',RECOVERY_PRIVATE_KNOWLEDGE_UNRESOLVED');
    end if;
    if v_missing_legacy > 0 and v_after_legacy < v_before_legacy + v_missing_legacy then
      v_gap := concat(v_gap, ',RECOVERY_LEGACY_UNRESOLVED');
    end if;
  end if;

  insert into public.recovery_events(snapshot_id,sh_id,outcome,continuity_status,gap_code)
  values(p_snapshot_id,v_sh_id,'RESTORED',case when v_gap is null then 'CONTINUOUS' else 'GAP_DETECTED' end,v_gap)
  returning recovery_event_id into v_id;
  return v_id;
end;
$$;

grant execute on function public.runtime_restore_recovery_snapshot(uuid) to authenticated;