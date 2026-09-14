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
  update public.recovery_snapshots rs
  set manifest = manifest
    || jsonb_build_object(
      'recovery_scope', jsonb_build_array('PROJECTS','CONVERSATIONS','MESSAGES','JOURNEY','MEMORY','KNOWLEDGE','EXPERIENCE','LEGACY','SH_STATE','OWNERSHIP','CONVERSATION_ATTACHMENTS'),
      'messages', coalesce(manifest->'conversations','[]'::jsonb),
      'scope_contract_version', 'FULL_RECOVERY_V3'
    )
    || jsonb_build_object(
      'conversation_threads', (
        select coalesce(jsonb_agg(to_jsonb(t) order by t.created_at,t.conversation_id),'[]'::jsonb)
        from public.conversation_threads t
        where t.sh_id=p_sh_id and t.account_id=v_account_id
      )
    )
  where snapshot_id=v_snapshot_id and account_id=v_account_id;

  update public.recovery_snapshots rs
  set manifest = jsonb_set(
    manifest,
    '{conversation_threads}',
    coalesce(
      (
        select jsonb_agg(to_jsonb(q) order by q.created_at,q.conversation_id)
        from (
          select x.conversation_id,x.account_id,x.sh_id,x.project_id,x.title,x.created_at,x.updated_at
          from jsonb_to_recordset(coalesce(manifest->'conversation_threads','[]'::jsonb)) x(conversation_id uuid,account_id uuid,sh_id uuid,project_id uuid,title text,created_at timestamptz,updated_at timestamptz)
          union all
          select distinct x.thread_id,x.account_id,x.sh_id,null::uuid,
            coalesce(nullif(trim(x.metadata->>'conversation_title'),''),'Recovered Conversation'),
            x.created_at,x.created_at
          from jsonb_to_recordset(coalesce(manifest->'messages','[]'::jsonb)) x(conversation_id uuid,account_id uuid,sh_id uuid,metadata jsonb,created_at timestamptz,thread_id uuid)
          where x.sh_id=p_sh_id and x.account_id=v_account_id and x.thread_id is not null
            and not exists (
              select 1 from jsonb_to_recordset(coalesce(manifest->'conversation_threads','[]'::jsonb)) t(conversation_id uuid)
              where t.conversation_id=x.thread_id
            )
        ) q
      ),
      '[]'::jsonb
    ),
    true
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
  v_message_rows := coalesce(v_snapshot.manifest->'messages', v_snapshot.manifest->'conversations', '[]'::jsonb);

  insert into public.conversation_threads(conversation_id,account_id,sh_id,project_id,title,created_at,updated_at)
  select distinct x.thread_id,x.account_id,x.sh_id,null::uuid,
    coalesce(nullif(trim(x.metadata->>'conversation_title'),''),'Recovered Conversation'),
    x.created_at,x.created_at
  from jsonb_to_recordset(v_message_rows) x(
    conversation_id uuid,account_id uuid,sh_id uuid,metadata jsonb,created_at timestamptz,thread_id uuid
  )
  where x.sh_id=v_sh_id and x.account_id=public.current_account_id() and x.thread_id is not null
    and not exists(select 1 from public.conversation_threads t where t.conversation_id=x.thread_id and t.sh_id=v_sh_id and t.account_id=public.current_account_id());

  v_recovery_event_id := public.runtime_restore_recovery_snapshot(p_snapshot_id);

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