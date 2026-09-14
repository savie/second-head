CREATE OR REPLACE FUNCTION public.runtime_get_journey_context(p_sh_id uuid, p_limit integer DEFAULT 20)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_account_id uuid;
  v_limit integer;
  v_events jsonb;
begin
  if auth.uid() is null then raise exception 'JOURNEY_CONTEXT_RETRIEVAL_REJECTED: authentication required'; end if;
  v_limit := least(greatest(coalesce(p_limit,20),1),50);
  select s.account_id into v_account_id from public.sh_instances s where s.sh_id=p_sh_id and s.account_id=public.current_account_id() and s.status <> 'deactivated';
  if v_account_id is null then raise exception 'JOURNEY_CONTEXT_RETRIEVAL_REJECTED: SH not owned by current account'; end if;

  select coalesce(jsonb_agg(jsonb_build_object(
    'event_id',j.event_id,
    'event_type',j.event_type,
    'occurred_at',j.occurred_at,
    'continuity_status',j.continuity_status,
    'gap_code',j.gap_code,
    'payload',j.payload,
    'source_ref',j.source_ref,
    'visibility',coalesce(m.visibility,k.visibility,e.visibility,j.visibility),
    'transfer_policy',coalesce(m.transfer_policy,k.transfer_policy,e.transfer_policy,j.transfer_policy),
    'provenance',coalesce(j.provenance,'{}'::jsonb)
  ) order by j.occurred_at desc),'[]'::jsonb)
  into v_events
  from (
    select * from public.journey_events
    where sh_id=p_sh_id and (account_id=v_account_id or visibility in ('SHARED','PUBLIC'))
    order by occurred_at desc limit v_limit
  ) j
  left join public.memories m on upper(j.event_type)='MEMORY' and m.sh_id=j.sh_id and m.memory_id::text=j.payload->>'memory_id'
  left join public.knowledge k on upper(j.event_type) in ('KNOWLEDGE','LEARNING') and k.sh_id=j.sh_id and k.knowledge_id::text=j.payload->>'knowledge_id'
  left join public.experiences e on upper(j.event_type)='EXPERIENCE' and e.sh_id=j.sh_id and e.experience_id::text=j.payload->>'experience_id';

  return jsonb_build_object('events',v_events,'retrieval_limit',v_limit);
end;
$function$;

CREATE OR REPLACE FUNCTION public.runtime_create_full_recovery_snapshot(p_sh_id uuid)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_snapshot_id uuid;
  v_account_id uuid;
begin
  if auth.uid() is null then raise exception 'RECOVERY_REJECTED: authentication required'; end if;
  select s.account_id into v_account_id from public.sh_instances s where s.sh_id=p_sh_id and s.account_id=public.current_account_id() and s.status <> 'deactivated';
  if v_account_id is null then raise exception 'RECOVERY_REJECTED: SH not owned by current active account'; end if;
  v_snapshot_id := public.runtime_create_recovery_snapshot(p_sh_id);
  update public.recovery_snapshots
  set manifest = manifest || jsonb_build_object(
    'recovery_scope', jsonb_build_array('PROJECTS','CONVERSATIONS','MESSAGES','JOURNEY','MEMORY','KNOWLEDGE','EXPERIENCE','LEGACY','SH_STATE','OWNERSHIP','CONVERSATION_ATTACHMENTS'),
    'messages', coalesce(manifest->'conversations','[]'::jsonb),
    'scope_contract_version', 'FULL_RECOVERY_V2'
  )
  where snapshot_id=v_snapshot_id and account_id=v_account_id;
  return v_snapshot_id;
end;
$function$;

CREATE OR REPLACE FUNCTION public.runtime_restore_full_recovery_snapshot(p_snapshot_id uuid)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_snapshot public.recovery_snapshots%rowtype;
  v_recovery_event_id uuid;
  v_sh_id uuid;
  v_message_rows jsonb;
  v_missing integer := 0;
begin
  if auth.uid() is null then raise exception 'RECOVERY_REJECTED: authentication required'; end if;
  select * into v_snapshot from public.recovery_snapshots where snapshot_id=p_snapshot_id and account_id=public.current_account_id() for update;
  if not found then raise exception 'RECOVERY_REJECTED: snapshot not accessible'; end if;
  v_sh_id := v_snapshot.sh_id;

  v_recovery_event_id := public.runtime_restore_recovery_snapshot(p_snapshot_id);

  v_message_rows := coalesce(v_snapshot.manifest->'messages', v_snapshot.manifest->'conversations', '[]'::jsonb);
  insert into public.conversations(conversation_id,account_id,sh_id,role,content,created_at,metadata,thread_id,message_id)
  select x.conversation_id,x.account_id,x.sh_id,x.role,x.content,x.created_at,x.metadata,x.thread_id,x.message_id
  from jsonb_to_recordset(v_message_rows) x(
    conversation_id uuid,account_id uuid,sh_id uuid,role text,content text,created_at timestamptz,metadata jsonb,thread_id uuid,message_id uuid
  )
  where x.sh_id=v_sh_id and x.account_id=public.current_account_id()
    and x.thread_id is not null
    and exists(select 1 from public.conversation_threads t where t.conversation_id=x.thread_id and t.sh_id=v_sh_id and t.account_id=public.current_account_id())
  on conflict (conversation_id) do update set account_id=excluded.account_id,sh_id=excluded.sh_id,role=excluded.role,content=excluded.content,created_at=excluded.created_at,metadata=excluded.metadata,thread_id=excluded.thread_id,message_id=excluded.message_id;

  select count(*) into v_missing
  from jsonb_to_recordset(v_message_rows) x(conversation_id uuid,account_id uuid,sh_id uuid,thread_id uuid,message_id uuid)
  where x.sh_id=v_sh_id and x.account_id=public.current_account_id()
    and (not exists(select 1 from public.conversations c where c.conversation_id=x.conversation_id and c.sh_id=v_sh_id and c.account_id=public.current_account_id())
      or not exists(select 1 from public.conversations c where c.message_id=x.message_id and c.sh_id=v_sh_id and c.account_id=public.current_account_id())
      or not exists(select 1 from public.conversation_threads t where t.conversation_id=x.thread_id and t.sh_id=v_sh_id and t.account_id=public.current_account_id()));

  update public.recovery_events
  set continuity_status=case when v_missing=0 then 'RECOVERED' else 'GAP_UNRESOLVED' end,
      gap_code=case when v_missing=0 then null else 'CONVERSATION_MESSAGE_GAP_UNRESOLVED' end
  where recovery_event_id=v_recovery_event_id;

  return v_recovery_event_id;
end;
$function$;

grant execute on function public.runtime_create_full_recovery_snapshot(uuid) to authenticated;
grant execute on function public.runtime_restore_full_recovery_snapshot(uuid) to authenticated;
REVOKE EXECUTE ON FUNCTION public.runtime_create_full_recovery_snapshot(uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.runtime_restore_full_recovery_snapshot(uuid) FROM PUBLIC, anon;