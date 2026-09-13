-- SECOND HEAD — Knowledge lifecycle stable error codes
-- Supabase DEV migration applied first; GitHub reconciles the verified DB state.

create or replace function public.runtime_knowledge_transition(p_knowledge_id uuid, p_expected_lifecycle text, p_operation_key text, p_transition text, p_decision_ref text default null, p_validation_ref text default null, p_index_ref text default null, p_update_ref text default null, p_confirmation_ref text default null, p_provenance jsonb default '{}'::jsonb, p_successor_content text default null, p_successor_provenance jsonb default '{}'::jsonb)
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_k public.knowledge%rowtype;
  v_account uuid;
  v_op public.knowledge_lifecycle_operations%rowtype;
  v_opid uuid;
  v_new uuid;
  v_j uuid;
  v_next text;
  v_version int;
  v_confirm_id uuid;
begin
  if auth.uid() is null then
    raise exception using errcode = 'P2001', message = 'UNAUTHENTICATED: authentication required';
  end if;
  if nullif(btrim(p_operation_key),'') is null then
    raise exception using errcode = 'P2012', message = 'OPERATION_KEY_INVALID: operation_key required';
  end if;
  select s.account_id into v_account from public.sh_instances s where s.sh_id=(select sh_id from public.knowledge where knowledge_id=p_knowledge_id) and s.account_id=public.current_account_id() and s.status<>'deactivated';
  if v_account is null then
    raise exception using errcode = 'P2003', message = 'SH_NOT_OWNED: SH not owned by current active account';
  end if;
  select * into v_op from public.knowledge_lifecycle_operations where account_id=v_account and sh_id=(select sh_id from public.knowledge where knowledge_id=p_knowledge_id) and operation_key=btrim(p_operation_key) for update;
  if found then
    if v_op.knowledge_id<>p_knowledge_id or v_op.transition<>p_transition then
      raise exception using errcode = 'P2013', message = 'OPERATION_CONFLICT: operation_key conflict';
    end if;
    return jsonb_build_object('status','ALREADY_APPLIED','operation_id',v_op.operation_id,'knowledge_id',v_op.resulting_knowledge_id,'lifecycle',v_op.resulting_lifecycle,'journey_event_id',v_op.journey_event_id);
  end if;
  select * into v_k from public.knowledge where knowledge_id=p_knowledge_id for update;
  if not found then
    raise exception using errcode = 'P2004', message = 'KNOWLEDGE_NOT_FOUND: knowledge not found';
  end if;
  if v_k.lifecycle<>p_expected_lifecycle then
    raise exception using errcode = 'P2006', message = 'WRONG_LIFECYCLE: expected lifecycle mismatch';
  end if;
  if v_k.sh_id is null then
    raise exception using errcode = 'P2003', message = 'SH_NOT_OWNED: knowledge has no SH owner';
  end if;
  if p_transition='CANDIDATE_TO_ACCEPTED' then v_next:='ACCEPTED';
  elsif p_transition='ACCEPTED_TO_INDEXED' then v_next:='INDEXED';
  elsif p_transition='INDEXED_TO_ACTIVE' then v_next:='ACTIVE';
  elsif p_transition='ACTIVE_TO_UPDATED' then v_next:='UPDATED';
  elsif p_transition='ACTIVE_TO_DEPRECATED' then v_next:='DEPRECATED';
  elsif p_transition='DEPRECATED_TO_ARCHIVED' then v_next:='ARCHIVED';
  else
    raise exception using errcode = 'P2007', message = 'INVALID_TRANSITION: invalid transition';
  end if;
  if p_transition in ('INDEXED_TO_ACTIVE','ACTIVE_TO_DEPRECATED','DEPRECATED_TO_ARCHIVED') then
    if p_confirmation_ref is null then
      raise exception using errcode = 'P2011', message = 'CONFIRMATION_REQUIRED: confirmation_ref required';
    end if;
    begin
      v_confirm_id:=p_confirmation_ref::uuid;
    exception when invalid_text_representation then
      raise exception using errcode = 'P2011', message = 'CONFIRMATION_REQUIRED: invalid confirmation_ref';
    end;
    perform 1 from public.knowledge_lifecycle_confirmations c where c.confirmation_id=v_confirm_id and c.account_id=v_account and c.actor_id=auth.uid() and c.sh_id=v_k.sh_id and c.knowledge_id=v_k.knowledge_id and c.transition=p_transition and c.operation_key=btrim(p_operation_key) and c.status='CONFIRMED' and c.expires_at>now() for update;
    if not found then
      raise exception using errcode = 'P2011', message = 'CONFIRMATION_REQUIRED: exact confirmation not valid';
    end if;
  end if;
  if p_transition='ACTIVE_TO_UPDATED' then
    if nullif(btrim(p_successor_content),'') is null then
      raise exception using errcode = 'P2007', message = 'INVALID_TRANSITION: successor content required';
    end if;
    insert into public.knowledge(content,knowledge_class,scope,visibility,source,provenance,confidence,lifecycle,sh_id,transfer_policy,version)
    values(btrim(p_successor_content),v_k.knowledge_class,v_k.scope,v_k.visibility,v_k.source,coalesce(p_successor_provenance,'{}')||jsonb_build_object('supersedes',v_k.knowledge_id),v_k.confidence,'ACTIVE',v_k.sh_id,v_k.transfer_policy,v_k.version+1)
    returning knowledge_id,version into v_new,v_version;
    update public.knowledge set lifecycle='UPDATED',superseded_by=v_new,updated_at=now() where knowledge_id=v_k.knowledge_id;
  else
    update public.knowledge set lifecycle=v_next,updated_at=now() where knowledge_id=v_k.knowledge_id;
    v_new:=v_k.knowledge_id;
    v_version:=v_k.version;
  end if;
  insert into public.knowledge_lifecycle_operations(account_id,actor_id,sh_id,knowledge_id,transition,expected_lifecycle,previous_lifecycle,resulting_lifecycle,operation_key,decision_ref,validation_ref,index_ref,update_ref,confirmation_ref,provenance,result_status,resulting_knowledge_id,resulting_version)
  values(v_account,auth.uid(),v_k.sh_id,v_k.knowledge_id,p_transition,p_expected_lifecycle,v_k.lifecycle,v_next,btrim(p_operation_key),p_decision_ref,p_validation_ref,p_index_ref,p_update_ref,p_confirmation_ref,coalesce(p_provenance,'{}'),'SUCCESS',v_new,v_version)
  returning operation_id into v_opid;
  v_j:=public.runtime_record_journey_event(v_k.sh_id,'LIFECYCLE',now(),'CONTINUOUS',null,jsonb_build_object('domain','KNOWLEDGE','knowledge_id',v_k.knowledge_id,'transition',p_transition,'operation_id',v_opid,'operation_key',btrim(p_operation_key),'previous_lifecycle',v_k.lifecycle,'resulting_lifecycle',v_next,'resulting_knowledge_id',v_new,'resulting_version',v_version,'provenance_ref',p_provenance->>'ref'),p_operation_key);
  update public.knowledge_lifecycle_operations set journey_event_id=v_j where operation_id=v_opid;
  return jsonb_build_object('status','SUCCESS','operation_id',v_opid,'knowledge_id',v_new,'lifecycle',v_next,'version',v_version,'journey_event_id',v_j);
end;
$function$;
