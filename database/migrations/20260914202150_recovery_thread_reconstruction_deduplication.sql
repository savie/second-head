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
  v_message_rows := coalesce(v_snapshot.manifest->'messages', v_snapshot.manifest->'conversations', '[]'::jsonb);

  if exists (
    select 1
    from jsonb_to_recordset(v_message_rows) x(thread_id uuid)
    join public.conversation_threads t on t.conversation_id=x.thread_id
    where t.sh_id<>v_sh_id or t.account_id<>public.current_account_id()
  ) then
    raise exception 'RECOVERY_REJECTED: conversation thread ownership collision';
  end if;

  insert into public.conversation_threads(conversation_id,account_id,sh_id,project_id,title,created_at,updated_at)
  select x.thread_id,x.account_id,x.sh_id,null::uuid,
    coalesce(nullif(trim(x.metadata->>'conversation_title'),''),'Recovered Conversation'),
    x.created_at,x.created_at
  from (
    select distinct on (thread_id) thread_id,account_id,sh_id,metadata,created_at
    from jsonb_to_recordset(v_message_rows) x(
      conversation_id uuid,account_id uuid,sh_id uuid,metadata jsonb,created_at timestamptz,thread_id uuid
    )
    where x.sh_id=v_sh_id and x.account_id=public.current_account_id() and x.thread_id is not null
    order by thread_id,created_at asc,conversation_id asc
  ) x
  where not exists(select 1 from public.conversation_threads t where t.conversation_id=x.thread_id)
  on conflict (conversation_id) do nothing;

  v_recovery_event_id := public.runtime_restore_recovery_snapshot(p_snapshot_id);

  insert into public.conversations(conversation_id,account_id,sh_id,role,content,created_at,metadata,thread_id,message_id)
  select x.conversation_id,x.account_id,x.sh_id,x.role,x.content,x.created_at,x.metadata,x.thread_id,x.message_id
  from jsonb_to_recordset(v_message_rows) x(
    conversation_id uuid,account_id uuid,sh_id uuid,role text,content text,created_at timestamptz,thread_id uuid,message_id uuid,metadata jsonb
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