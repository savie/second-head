CREATE OR REPLACE FUNCTION public.runtime_set_transfer_policy(
  p_domain text,
  p_record_id uuid,
  p_transfer_policy text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare
  v_domain text := upper(trim(coalesce(p_domain,'')));
  v_policy text := upper(trim(coalesce(p_transfer_policy,'')));
  v_sh_id uuid;
  v_scope text;
  v_visibility text;
begin
  if auth.uid() is null then raise exception 'TRANSFER_POLICY_REJECTED: authentication required'; end if;
  if v_domain not in ('MEMORY','KNOWLEDGE','EXPERIENCE') then raise exception 'TRANSFER_POLICY_REJECTED: invalid domain'; end if;
  if v_policy not in ('NON_TRANSFERABLE','INHERITANCE','SUCCESSION','LEGACY') then raise exception 'TRANSFER_POLICY_REJECTED: invalid transfer policy'; end if;

  if v_domain='MEMORY' then
    select m.sh_id,m.scope,m.visibility into v_sh_id,v_scope,v_visibility from public.memories m where m.memory_id=p_record_id;
  elsif v_domain='KNOWLEDGE' then
    select k.sh_id,k.scope,k.visibility into v_sh_id,v_scope,v_visibility from public.knowledge k where k.knowledge_id=p_record_id;
  else
    select e.sh_id,e.scope,e.visibility into v_sh_id,v_scope,v_visibility from public.experiences e where e.experience_id=p_record_id;
  end if;

  if v_sh_id is null or not exists(select 1 from public.sh_instances s where s.sh_id=v_sh_id and s.account_id=public.current_account_id()) then
    raise exception 'TRANSFER_POLICY_REJECTED: record ownership required';
  end if;

  if v_policy <> 'NON_TRANSFERABLE' and (v_scope <> 'GENERAL' or v_visibility <> 'SHARED') then
    raise exception 'TRANSFER_POLICY_REJECTED: transferable policy requires GENERAL and SHARED record';
  end if;

  if v_domain='MEMORY' then
    update public.memories set transfer_policy=v_policy, updated_at=now() where memory_id=p_record_id;
    update public.journey_events set visibility=v_visibility, transfer_policy=v_policy
      where sh_id=v_sh_id and event_type='MEMORY' and payload->>'memory_id'=p_record_id::text;
  elsif v_domain='KNOWLEDGE' then
    update public.knowledge set transfer_policy=v_policy, updated_at=now() where knowledge_id=p_record_id;
    update public.journey_events set visibility=v_visibility, transfer_policy=v_policy
      where sh_id=v_sh_id and event_type in ('KNOWLEDGE','LEARNING') and payload->>'knowledge_id'=p_record_id::text;
  else
    update public.experiences set transfer_policy=v_policy, updated_at=now() where experience_id=p_record_id;
    update public.journey_events set visibility=v_visibility, transfer_policy=v_policy
      where sh_id=v_sh_id and event_type='EXPERIENCE' and payload->>'experience_id'=p_record_id::text;
  end if;
end;
$$;

REVOKE ALL ON FUNCTION public.runtime_set_transfer_policy(text,uuid,text) FROM public, anon;
GRANT EXECUTE ON FUNCTION public.runtime_set_transfer_policy(text,uuid,text) TO authenticated;
