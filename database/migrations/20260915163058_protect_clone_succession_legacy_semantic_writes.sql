CREATE OR REPLACE FUNCTION public.runtime_assert_semantic_write_allowed(p_domain text, p_record_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare
  v_transfer_policy text;
  v_provenance jsonb;
begin
  if upper(p_domain)='MEMORY' then
    select m.transfer_policy, coalesce(m.provenance,'{}'::jsonb) into v_transfer_policy, v_provenance
      from public.memories m where m.memory_id=p_record_id;
  elsif upper(p_domain)='KNOWLEDGE' then
    select k.transfer_policy, coalesce(k.provenance,'{}'::jsonb) into v_transfer_policy, v_provenance
      from public.knowledge k where k.knowledge_id=p_record_id;
  elsif upper(p_domain)='EXPERIENCE' then
    select e.transfer_policy, coalesce(e.provenance,'{}'::jsonb) into v_transfer_policy, v_provenance
      from public.experiences e where e.experience_id=p_record_id;
  else
    raise exception 'SEMANTIC_WRITE_REJECTED: invalid domain';
  end if;

  if v_transfer_policy is null and v_provenance is null then
    raise exception 'SEMANTIC_WRITE_REJECTED: record not found';
  end if;

  if v_transfer_policy='LEGACY'
     or v_provenance ? 'clone_origin'
     or v_provenance ? 'succession_origin' then
    raise exception 'SEMANTIC_WRITE_REJECTED: lifecycle-derived record is read-only';
  end if;
end;
$$;

CREATE OR REPLACE FUNCTION public.runtime_classify_memory(p_memory_id uuid, p_scope text, p_visibility text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare v_account_id uuid;
begin
  if auth.uid() is null then raise exception 'MEMORY_CLASSIFICATION_REJECTED: authentication required'; end if;
  if p_scope not in ('PRIVATE','GENERAL') then raise exception 'MEMORY_CLASSIFICATION_REJECTED: invalid scope'; end if;
  if p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'MEMORY_CLASSIFICATION_REJECTED: invalid visibility'; end if;
  select s.account_id into v_account_id
    from public.memories m join public.sh_instances s on s.sh_id=m.sh_id
   where m.memory_id=p_memory_id and s.account_id=public.current_account_id() and s.status <> 'deactivated';
  if v_account_id is null then raise exception 'MEMORY_CLASSIFICATION_REJECTED: memory not owned by current account'; end if;
  perform public.runtime_assert_semantic_write_allowed('MEMORY',p_memory_id);
  update public.memories set scope=p_scope, visibility=p_visibility, updated_at=now() where memory_id=p_memory_id;
  update public.journey_events set visibility=case when p_visibility='SHARED' then 'SHARED' else 'PRIVATE' end, provenance=coalesce(provenance,'{}'::jsonb)||jsonb_build_object('policy_source','canonical_memory') where sh_id=(select sh_id from public.memories where memory_id=p_memory_id) and payload->>'memory_id'=p_memory_id::text;
end;
$$;

CREATE OR REPLACE FUNCTION public.runtime_classify_knowledge(p_knowledge_id uuid, p_scope text, p_visibility text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare v_account_id uuid; v_sh_id uuid;
begin
  if auth.uid() is null then raise exception 'KNOWLEDGE_CLASSIFY_REJECTED: authentication required'; end if;
  if p_scope not in ('PRIVATE','GENERAL') then raise exception 'KNOWLEDGE_CLASSIFY_REJECTED: invalid scope'; end if;
  if p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'KNOWLEDGE_CLASSIFY_REJECTED: invalid visibility'; end if;
  if p_scope='GENERAL' and p_visibility <> 'SHARED' then raise exception 'KNOWLEDGE_CLASSIFY_REJECTED: GENERAL scope requires SHARED visibility'; end if;
  select k.sh_id, s.account_id into v_sh_id, v_account_id from public.knowledge k join public.sh_instances s on s.sh_id=k.sh_id where k.knowledge_id=p_knowledge_id and s.account_id=public.current_account_id() and s.status <> 'deactivated';
  if v_account_id is null then raise exception 'KNOWLEDGE_CLASSIFY_REJECTED: knowledge not owned by current account'; end if;
  perform public.runtime_assert_semantic_write_allowed('KNOWLEDGE',p_knowledge_id);
  update public.knowledge set scope=p_scope, visibility=p_visibility, sh_id=v_sh_id, updated_at=now() where knowledge_id=p_knowledge_id;
  update public.journey_events set visibility=case when p_visibility='SHARED' then 'SHARED' else 'PRIVATE' end, provenance=coalesce(provenance,'{}'::jsonb)||jsonb_build_object('policy_source','canonical_knowledge') where sh_id=v_sh_id and payload->>'knowledge_id'=p_knowledge_id::text;
end;
$$;

CREATE OR REPLACE FUNCTION public.runtime_classify_experience(p_experience_id uuid, p_scope text, p_visibility text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare v_id uuid; v_sh_id uuid;
begin
  if auth.uid() is null then raise exception 'EXPERIENCE_CLASSIFICATION_REJECTED: authentication required'; end if;
  if p_scope not in ('PRIVATE','GENERAL') then raise exception 'EXPERIENCE_CLASSIFICATION_REJECTED: invalid scope'; end if;
  if p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'EXPERIENCE_CLASSIFICATION_REJECTED: invalid visibility'; end if;
  select e.experience_id,e.sh_id into v_id,v_sh_id from public.experiences e where e.experience_id=p_experience_id and e.account_id=public.current_account_id() and e.lifecycle='ACTIVE';
  if v_id is null then raise exception 'EXPERIENCE_CLASSIFICATION_REJECTED: Experience not owned by current active account'; end if;
  perform public.runtime_assert_semantic_write_allowed('EXPERIENCE',p_experience_id);
  update public.experiences set scope=p_scope,visibility=p_visibility,updated_at=now() where experience_id=v_id;
  update public.journey_events set visibility=case when p_visibility='SHARED' then 'SHARED' else 'PRIVATE' end, provenance=coalesce(provenance,'{}'::jsonb)||jsonb_build_object('policy_source','canonical_experience') where sh_id=v_sh_id and payload->>'experience_id'=v_id::text;
  return v_id;
end;
$$;

CREATE OR REPLACE FUNCTION public.runtime_replace_memory(p_sh_id uuid, p_new_content text, p_old_pattern text, p_source text DEFAULT 'runtime:p5a:explicit_user_request'::text, p_scope text DEFAULT 'PRIVATE'::text, p_visibility text DEFAULT 'OWNER_ONLY'::text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare v_new uuid; v_old uuid; v_match_count integer; v_account uuid;
begin
  if auth.uid() is null then raise exception 'MEMORY_REPLACE_REJECTED: authentication required'; end if;
  select s.account_id into v_account from public.sh_instances s where s.sh_id=p_sh_id and s.account_id=public.current_account_id() and s.status <> 'deactivated';
  if v_account is null then raise exception 'MEMORY_REPLACE_REJECTED: SH not owned by current active account'; end if;
  if p_new_content is null or btrim(p_new_content)='' then raise exception 'MEMORY_REPLACE_REJECTED: content is required'; end if;
  if p_old_pattern is null or btrim(p_old_pattern)='' then raise exception 'MEMORY_REPLACE_REJECTED: replacement target is required'; end if;
  if p_scope not in ('PRIVATE','GENERAL') or p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'MEMORY_REPLACE_REJECTED: invalid scope or visibility'; end if;
  select count(*),min(memory_id) into v_match_count,v_old from public.memories where sh_id=p_sh_id and lifecycle in ('CANDIDATE','ACTIVE') and superseded_by is null and content ilike '%'||btrim(p_old_pattern)||'%';
  if v_match_count=0 then raise exception 'MEMORY_REPLACE_REJECTED: replacement target not found'; end if;
  if v_match_count>1 then raise exception 'MEMORY_REPLACE_REJECTED: replacement target is ambiguous'; end if;
  perform public.runtime_assert_semantic_write_allowed('MEMORY',v_old);
  insert into public.memories(sh_id,memory_type,content,source,scope,visibility,lifecycle,occurrence_count) values(p_sh_id,'LONG_TERM',btrim(p_new_content),coalesce(nullif(btrim(p_source),''),'runtime:p5a:explicit_user_request'),p_scope,p_visibility,'CANDIDATE',1) returning memory_id into v_new;
  update public.memories set lifecycle='UPDATED',superseded_by=v_new,updated_at=now() where memory_id=v_old;
  perform public.runtime_record_journey_event(p_sh_id,'MEMORY',now(),'CONTINUOUS',null,jsonb_build_object('memory_id',v_new,'content',btrim(p_new_content),'supersedes_memory_id',v_old,'acquisition','EXPLICIT_USER_REQUEST'),coalesce(nullif(btrim(p_source),''),'runtime:p5a:explicit_user_request'));
  return v_new;
end;
$$;

CREATE OR REPLACE FUNCTION public.runtime_knowledge_transition(p_knowledge_id uuid, p_expected_lifecycle text, p_operation_key text, p_transition text, p_decision_ref text DEFAULT NULL::text, p_validation_ref text DEFAULT NULL::text, p_index_ref text DEFAULT NULL::text, p_update_ref text DEFAULT NULL::text, p_confirmation_ref text DEFAULT NULL::text, p_provenance jsonb DEFAULT '{}'::jsonb, p_successor_content text DEFAULT NULL::text, p_successor_provenance jsonb DEFAULT '{}'::jsonb)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare v_k public.knowledge%rowtype; v_account uuid; v_op public.knowledge_lifecycle_operations%rowtype; v_opid uuid; v_new uuid; v_j uuid; v_next text; v_version int; v_confirm_id uuid;
begin
  if auth.uid() is null then raise exception using errcode='P2001',message='UNAUTHENTICATED: authentication required'; end if;
  if nullif(btrim(p_operation_key),'') is null then raise exception using errcode='P2012',message='OPERATION_KEY_INVALID: operation_key required'; end if;
  select s.account_id into v_account from public.sh_instances s where s.sh_id=(select sh_id from public.knowledge where knowledge_id=p_knowledge_id) and s.account_id=public.current_account_id() and s.status<>'deactivated';
  if v_account is null then raise exception using errcode='P2003',message='SH_NOT_OWNED: SH not owned by current active account'; end if;
  select * into v_op from public.knowledge_lifecycle_operations where account_id=v_account and sh_id=(select sh_id from public.knowledge where knowledge_id=p_knowledge_id) and operation_key=btrim(p_operation_key) for update;
  if found then
    if v_op.knowledge_id<>p_knowledge_id or v_op.transition<>p_transition then raise exception using errcode='P2013',message='OPERATION_CONFLICT: operation_key conflict'; end if;
    return jsonb_build_object('status','ALREADY_APPLIED','operation_id',v_op.operation_id,'knowledge_id',v_op.resulting_knowledge_id,'lifecycle',v_op.resulting_lifecycle,'journey_event_id',v_op.journey_event_id);
  end if;
  select * into v_k from public.knowledge where knowledge_id=p_knowledge_id for update;
  if not found then raise exception using errcode='P2004',message='KNOWLEDGE_NOT_FOUND: knowledge not found'; end if;
  perform public.runtime_assert_semantic_write_allowed('KNOWLEDGE',p_knowledge_id);
  if v_k.lifecycle<>p_expected_lifecycle then raise exception using errcode='P2006',message='WRONG_LIFECYCLE: expected lifecycle mismatch'; end if;
  if v_k.sh_id is null then raise exception using errcode='P2003',message='SH_NOT_OWNED: knowledge has no SH owner'; end if;
  if p_transition='CANDIDATE_TO_ACCEPTED' then v_next:='ACCEPTED'; elsif p_transition='ACCEPTED_TO_INDEXED' then v_next:='INDEXED'; elsif p_transition='INDEXED_TO_ACTIVE' then v_next:='ACTIVE'; elsif p_transition='ACTIVE_TO_UPDATED' then v_next:='UPDATED'; elsif p_transition='ACTIVE_TO_DEPRECATED' then v_next:='DEPRECATED'; elsif p_transition='DEPRECATED_TO_ARCHIVED' then v_next:='ARCHIVED'; else raise exception using errcode='P2007',message='INVALID_TRANSITION: invalid transition'; end if;
  if p_transition in ('INDEXED_TO_ACTIVE','ACTIVE_TO_DEPRECATED','DEPRECATED_TO_ARCHIVED') then
    if p_confirmation_ref is null then raise exception using errcode='P2011',message='CONFIRMATION_REQUIRED: confirmation_ref required'; end if;
    begin v_confirm_id:=p_confirmation_ref::uuid; exception when invalid_text_representation then raise exception using errcode='P2011',message='CONFIRMATION_REQUIRED: invalid confirmation_ref'; end;
    perform 1 from public.knowledge_lifecycle_confirmations c where c.confirmation_id=v_confirm_id and c.account_id=v_account and c.actor_id=auth.uid() and c.sh_id=v_k.sh_id and c.knowledge_id=v_k.knowledge_id and c.transition=p_transition and c.operation_key=btrim(p_operation_key) and c.status='CONFIRMED' and c.expires_at>now() for update;
    if not found then raise exception using errcode='P2011',message='CONFIRMATION_REQUIRED: exact confirmation not valid'; end if;
  end if;
  if p_transition='ACTIVE_TO_UPDATED' then
    if nullif(btrim(p_successor_content),'') is null then raise exception using errcode='P2007',message='INVALID_TRANSITION: successor content required'; end if;
    insert into public.knowledge(content,knowledge_class,scope,visibility,source,provenance,confidence,lifecycle,sh_id,transfer_policy,version) values(btrim(p_successor_content),v_k.knowledge_class,v_k.scope,v_k.visibility,v_k.source,coalesce(p_successor_provenance,'{}')||jsonb_build_object('supersedes',v_k.knowledge_id),v_k.confidence,'ACTIVE',v_k.sh_id,v_k.transfer_policy,v_k.version+1) returning knowledge_id,version into v_new,v_version;
    update public.knowledge set lifecycle='UPDATED',superseded_by=v_new,updated_at=now() where knowledge_id=v_k.knowledge_id;
  else
    update public.knowledge set lifecycle=v_next,updated_at=now() where knowledge_id=v_k.knowledge_id; v_new:=v_k.knowledge_id; v_version:=v_k.version;
  end if;
  insert into public.knowledge_lifecycle_operations(account_id,actor_id,sh_id,knowledge_id,transition,expected_lifecycle,previous_lifecycle,resulting_lifecycle,operation_key,decision_ref,validation_ref,index_ref,update_ref,confirmation_ref,provenance,result_status,resulting_knowledge_id,resulting_version) values(v_account,auth.uid(),v_k.sh_id,v_k.knowledge_id,p_transition,p_expected_lifecycle,v_k.lifecycle,v_next,btrim(p_operation_key),p_decision_ref,p_validation_ref,p_index_ref,p_update_ref,p_confirmation_ref,coalesce(p_provenance,'{}'),'SUCCESS',v_new,v_version) returning operation_id into v_opid;
  v_j:=public.runtime_record_journey_event(v_k.sh_id,'LIFECYCLE',now(),'CONTINUOUS',null,jsonb_build_object('domain','KNOWLEDGE','knowledge_id',v_k.knowledge_id,'transition',p_transition,'operation_id',v_opid,'operation_key',btrim(p_operation_key),'previous_lifecycle',v_k.lifecycle,'resulting_lifecycle',v_next,'resulting_knowledge_id',v_new,'resulting_version',v_version,'provenance_ref',p_provenance->>'ref'),p_operation_key);
  update public.knowledge_lifecycle_operations set journey_event_id=v_j where operation_id=v_opid;
  return jsonb_build_object('status','SUCCESS','operation_id',v_opid,'knowledge_id',v_new,'lifecycle',v_next,'version',v_version,'journey_event_id',v_j);
end;
$$;

DROP POLICY IF EXISTS memories_owner_update ON public.memories;
CREATE POLICY memories_owner_update ON public.memories FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.sh_instances s WHERE s.sh_id=memories.sh_id AND s.account_id=public.current_account_id()) AND memories.transfer_policy <> 'LEGACY' AND NOT (coalesce(memories.provenance,'{}'::jsonb) ? 'clone_origin') AND NOT (coalesce(memories.provenance,'{}'::jsonb) ? 'succession_origin')) WITH CHECK (EXISTS (SELECT 1 FROM public.sh_instances s WHERE s.sh_id=memories.sh_id AND s.account_id=public.current_account_id()) AND memories.transfer_policy <> 'LEGACY' AND NOT (coalesce(memories.provenance,'{}'::jsonb) ? 'clone_origin') AND NOT (coalesce(memories.provenance,'{}'::jsonb) ? 'succession_origin'));

DROP POLICY IF EXISTS memories_owner_delete ON public.memories;
CREATE POLICY memories_owner_delete ON public.memories FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.sh_instances s WHERE s.sh_id=memories.sh_id AND s.account_id=public.current_account_id()) AND memories.transfer_policy <> 'LEGACY' AND NOT (coalesce(memories.provenance,'{}'::jsonb) ? 'clone_origin') AND NOT (coalesce(memories.provenance,'{}'::jsonb) ? 'succession_origin'));

GRANT EXECUTE ON FUNCTION public.runtime_assert_semantic_write_allowed(text,uuid) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.runtime_assert_semantic_write_allowed(text,uuid) FROM anon,public;
GRANT EXECUTE ON FUNCTION public.runtime_classify_memory(uuid,text,text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.runtime_classify_knowledge(uuid,text,text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.runtime_classify_experience(uuid,text,text) TO authenticated;