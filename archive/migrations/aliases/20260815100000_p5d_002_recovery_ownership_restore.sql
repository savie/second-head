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
  v_gap text := null;
begin
  select * into v_snapshot
  from public.recovery_snapshots
  where snapshot_id=p_snapshot_id and account_id=current_account_id();
  if not found then raise exception 'RECOVERY_REJECTED: snapshot not accessible'; end if;

  v_sh_id := v_snapshot.sh_id;
  v_identity := (v_snapshot.manifest->'identity_root'->>'sh_id')::uuid;
  if v_identity <> v_sh_id then raise exception 'RECOVERY_REJECTED: identity root mismatch'; end if;
  if not exists(select 1 from public.sh_instances where sh_id=v_sh_id and account_id=current_account_id()) then raise exception 'RECOVERY_REJECTED: target SH ownership mismatch'; end if;

  insert into public.sh_ownership(ownership_id,account_id,sh_id,role,granted_at,evidence_ref,created_at)
  select x.ownership_id,x.account_id,x.sh_id,x.role,x.granted_at,x.evidence_ref,x.created_at
  from jsonb_to_recordset(coalesce(v_snapshot.manifest->'ownership_root','[]'::jsonb)) as x(ownership_id uuid,account_id uuid,sh_id uuid,role text,granted_at timestamptz,evidence_ref text,created_at timestamptz)
  where x.sh_id=v_sh_id and x.account_id=current_account_id()
  on conflict (ownership_id) do nothing;

  insert into public.memories(memory_id,sh_id,memory_type,content,source,confidence,scope,visibility,lifecycle,occurrence_count,created_at,updated_at,superseded_by)
  select x.memory_id,x.sh_id,x.memory_type,x.content,x.source,x.confidence,x.scope,x.visibility,x.lifecycle,x.occurrence_count,x.created_at,x.updated_at,x.superseded_by
  from jsonb_to_recordset(coalesce(v_snapshot.manifest->'memories','[]'::jsonb)) as x(memory_id uuid,sh_id uuid,memory_type text,content text,source text,confidence numeric,scope text,visibility text,lifecycle text,occurrence_count integer,created_at timestamptz,updated_at timestamptz,superseded_by uuid)
  where x.sh_id=v_sh_id
  on conflict (memory_id) do nothing;

  insert into public.conversations(conversation_id,account_id,sh_id,role,content,created_at,metadata)
  select x.conversation_id,x.account_id,x.sh_id,x.role,x.content,x.created_at,x.metadata
  from jsonb_to_recordset(coalesce(v_snapshot.manifest->'conversations','[]'::jsonb)) as x(conversation_id uuid,account_id uuid,sh_id uuid,role text,content text,created_at timestamptz,metadata jsonb)
  where x.sh_id=v_sh_id and x.account_id=current_account_id()
  on conflict (conversation_id) do nothing;

  insert into public.journey_events(event_id,sh_id,account_id,event_type,occurred_at,continuity_status,gap_code,payload,source_ref,created_at)
  select x.event_id,x.sh_id,x.account_id,x.event_type,x.occurred_at,x.continuity_status,x.gap_code,x.payload,x.source_ref,x.created_at
  from jsonb_to_recordset(coalesce(v_snapshot.manifest->'journey_events','[]'::jsonb)) as x(event_id uuid,sh_id uuid,account_id uuid,event_type text,occurred_at timestamptz,continuity_status text,gap_code text,payload jsonb,source_ref text,created_at timestamptz)
  where x.sh_id=v_sh_id and x.account_id=current_account_id()
  on conflict (event_id) do nothing;

  insert into public.recovery_events(snapshot_id,sh_id,outcome,continuity_status,gap_code)
  values(p_snapshot_id,v_sh_id,'RESTORED',case when v_gap is null then 'RECOVERED' else 'GAP_UNRESOLVED' end,v_gap)
  returning recovery_event_id into v_id;
  return v_id;
end;
$$;

grant execute on function public.runtime_restore_recovery_snapshot(uuid) to authenticated;
