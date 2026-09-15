CREATE OR REPLACE FUNCTION public.runtime_record_inheritance(p_authorization_id uuid, p_payload jsonb DEFAULT '{}'::jsonb, p_provenance jsonb DEFAULT '{}'::jsonb)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare v_auth public.inheritance_authorizations%rowtype; v_result uuid;
begin
  select * into v_auth from public.inheritance_authorizations where authorization_id=p_authorization_id and status='APPROVED';
  if not found then raise exception 'INHERITANCE_REJECTED: approved authorization required'; end if;
  if v_auth.source_account_id<>public.current_account_id() then raise exception 'INHERITANCE_REJECTED: source owner approval required'; end if;
  perform public.runtime_validate_selected_transfer_scope(v_auth.source_sh_id,v_auth.scope,'inheritance');
  v_result:=public.runtime_record_inheritance_unchecked(p_authorization_id,p_payload,p_provenance);
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance)
  select m.sh_id,m_sh.account_id,'MEMORY',now(),'CONTINUOUS',jsonb_build_object('memory_id',m.memory_id,'content',m.content,'title','Inherited Memory'),'inheritance_projection:'||m.memory_id::text,'PRIVATE','NON_TRANSFERABLE',jsonb_build_object('transfer_operation','INHERITANCE','authorization_id',p_authorization_id,'source_sh_id',v_auth.source_sh_id,'projected_at',now())
  from public.memories m join public.sh_instances m_sh on m_sh.sh_id=m.sh_id
  where m_sh.sh_id=v_auth.target_sh_id and m.provenance->'inheritance_origin'->>'authorization_id'=p_authorization_id::text;
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance)
  select k.sh_id,k_sh.account_id,'KNOWLEDGE',now(),'CONTINUOUS',jsonb_build_object('knowledge_id',k.knowledge_id,'content',k.content,'title','Inherited Knowledge'),'inheritance_projection:'||k.knowledge_id::text,'PRIVATE','NON_TRANSFERABLE',jsonb_build_object('transfer_operation','INHERITANCE','authorization_id',p_authorization_id,'source_sh_id',v_auth.source_sh_id,'projected_at',now())
  from public.knowledge k join public.sh_instances k_sh on k_sh.sh_id=k.sh_id
  where k_sh.sh_id=v_auth.target_sh_id and k.provenance->'inheritance_origin'->>'authorization_id'=p_authorization_id::text;
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance)
  select e.sh_id,e_sh.account_id,'EXPERIENCE',now(),'CONTINUOUS',jsonb_build_object('experience_id',e.experience_id,'content',e.content,'title','Inherited Experience'),'inheritance_projection:'||e.experience_id::text,'PRIVATE','NON_TRANSFERABLE',jsonb_build_object('transfer_operation','INHERITANCE','authorization_id',p_authorization_id,'source_sh_id',v_auth.source_sh_id,'projected_at',now())
  from public.experiences e join public.sh_instances e_sh on e_sh.sh_id=e.sh_id
  where e_sh.sh_id=v_auth.target_sh_id and e.provenance->'inheritance_origin'->>'authorization_id'=p_authorization_id::text;
  return v_result;
end;
$$;

CREATE OR REPLACE FUNCTION public.runtime_execute_succession(p_succession_id uuid)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare v_rule public.succession_rules%rowtype; v_result uuid;
begin
  select * into v_rule from public.succession_rules where succession_id=p_succession_id and status='ACTIVE';
  if not found then raise exception 'SUCCESSION_REJECTED: active succession rule required'; end if;
  perform public.runtime_validate_selected_transfer_scope(v_rule.source_sh_id,v_rule.scope,'succession');
  v_result:=public.runtime_execute_succession_unchecked(p_succession_id);
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance)
  select m.sh_id,m_sh.account_id,'MEMORY',now(),'CONTINUOUS',jsonb_build_object('memory_id',m.memory_id,'content',m.content,'title','Succession Memory'),'succession_projection:'||m.memory_id::text,'PRIVATE','NON_TRANSFERABLE',jsonb_build_object('transfer_operation','SUCCESSION','succession_id',p_succession_id,'source_sh_id',v_rule.source_sh_id,'projected_at',now())
  from public.memories m join public.sh_instances m_sh on m_sh.sh_id=m.sh_id
  where m_sh.sh_id=(select sh_id from public.sh_instances where account_id=v_rule.successor_account_id and status<>'deactivated' and is_primary=true order by created_at asc limit 1) and m.provenance->'succession_origin'->>'succession_id'=p_succession_id::text;
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance)
  select k.sh_id,k_sh.account_id,'KNOWLEDGE',now(),'CONTINUOUS',jsonb_build_object('knowledge_id',k.knowledge_id,'content',k.content,'title','Succession Knowledge'),'succession_projection:'||k.knowledge_id::text,'PRIVATE','NON_TRANSFERABLE',jsonb_build_object('transfer_operation','SUCCESSION','succession_id',p_succession_id,'source_sh_id',v_rule.source_sh_id,'projected_at',now())
  from public.knowledge k join public.sh_instances k_sh on k_sh.sh_id=k.sh_id
  where k_sh.sh_id=(select sh_id from public.sh_instances where account_id=v_rule.successor_account_id and status<>'deactivated' and is_primary=true order by created_at asc limit 1) and k.provenance->'succession_origin'->>'succession_id'=p_succession_id::text;
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance)
  select e.sh_id,e_sh.account_id,'EXPERIENCE',now(),'CONTINUOUS',jsonb_build_object('experience_id',e.experience_id,'content',e.content,'title','Succession Experience'),'succession_projection:'||e.experience_id::text,'PRIVATE','NON_TRANSFERABLE',jsonb_build_object('transfer_operation','SUCCESSION','succession_id',p_succession_id,'source_sh_id',v_rule.source_sh_id,'projected_at',now())
  from public.experiences e join public.sh_instances e_sh on e_sh.sh_id=e.sh_id
  where e_sh.sh_id=(select sh_id from public.sh_instances where account_id=v_rule.successor_account_id and status<>'deactivated' and is_primary=true order by created_at asc limit 1) and e.provenance->'succession_origin'->>'succession_id'=p_succession_id::text;
  return v_result;
end;
$$;
