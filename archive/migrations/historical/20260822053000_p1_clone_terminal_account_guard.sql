-- P1 clone lifecycle reconciliation
-- A terminal/deactivated account must not materialize a new Clone SH.

CREATE OR REPLACE FUNCTION public.runtime_create_clone(p_agreement_id uuid, p_clone_name text DEFAULT NULL::text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare
  v_agreement public.clone_agreements%rowtype;
  v_target_account_id uuid;
  v_target_email text;
  v_source_sh public.sh_instances%rowtype;
  v_clone_sh_id uuid;
  v_now timestamptz:=now();
begin
  if auth.uid() is null then raise exception 'CLONE_REJECTED: authentication required'; end if;
  v_target_account_id:=public.current_account_id();
  if v_target_account_id is null then raise exception 'CLONE_REJECTED: authenticated account not resolved'; end if;
  if not exists (select 1 from public.accounts a where a.account_id=v_target_account_id and a.status<>'deactivated') then raise exception 'CLONE_REJECTED: target account is deactivated or unavailable'; end if;
  select * into v_agreement from public.clone_agreements where agreement_id=p_agreement_id and status='APPROVED' for update;
  if not found then raise exception 'CLONE_REJECTED: approved agreement required'; end if;
  select * into v_source_sh from public.sh_instances where sh_id=v_agreement.source_sh_id and account_id=v_agreement.source_account_id and status<>'deactivated';
  if not found then raise exception 'CLONE_REJECTED: source SH ownership boundary failed'; end if;
  if v_agreement.source_account_id=v_target_account_id then raise exception 'CLONE_REJECTED: source and target accounts must differ'; end if;
  select lower(trim(email)) into v_target_email from public.accounts where account_id=v_target_account_id;
  if v_target_email is null or v_target_email<>lower(trim(v_agreement.target_email)) then raise exception 'CLONE_REJECTED: authenticated recipient does not match intended email'; end if;
  if v_agreement.target_account_id is not null and v_agreement.target_account_id<>v_target_account_id then raise exception 'CLONE_REJECTED: agreement is already linked to another target account'; end if;
  if exists(select 1 from public.sh_instances where account_id=v_target_account_id) then raise exception 'CLONE_REJECTED: target account already has an SH'; end if;
  v_clone_sh_id:=gen_random_uuid();
  insert into public.sh_instances(sh_id,account_id,sh_type,is_primary,canonical_name,creator_ref,status,metadata,version,created_at,updated_at) values(v_clone_sh_id,v_target_account_id,'PRIMARY',true,coalesce(nullif(trim(p_clone_name),''),coalesce(v_source_sh.canonical_name,'SH')||' Clone'),'clone:'||v_agreement.source_sh_id::text,'created',jsonb_build_object('origin','CLONE','source_sh_id',v_agreement.source_sh_id,'source_account_id',v_agreement.source_account_id,'agreement_id',v_agreement.agreement_id,'initial_state_semantics','CONTEXT_REFERENCE_TRAITS','privacy_boundary','GENERAL_SHARED_ONLY','transfer_policy_exclusion','NON_TRANSFERABLE'),1,v_now,v_now);
  insert into public.sh_ownership(ownership_id,account_id,sh_id,role,granted_at,evidence_ref,created_at) values(gen_random_uuid(),v_target_account_id,v_clone_sh_id,'OWNER',v_now,'clone_agreement:'||v_agreement.agreement_id::text,v_now);
  insert into public.sh_clones(clone_sh_id,source_sh_id,agreement_id,status,created_at) values(v_clone_sh_id,v_agreement.source_sh_id,v_agreement.agreement_id,'ACTIVE',v_now);
  insert into public.memories(sh_id,memory_type,content,source,confidence,scope,visibility,transfer_policy,lifecycle,occurrence_count,created_at,updated_at,superseded_by) select v_clone_sh_id,m.memory_type,m.content,m.source,m.confidence,m.scope,m.visibility,m.transfer_policy,case when m.lifecycle='CANDIDATE' then 'ACTIVE' else m.lifecycle end,m.occurrence_count,v_now,v_now,null from public.memories m where m.sh_id=v_agreement.source_sh_id and m.scope='GENERAL' and m.visibility='SHARED' and m.transfer_policy<>'NON_TRANSFERABLE';
  insert into public.knowledge(content,knowledge_class,scope,visibility,transfer_policy,source,provenance,confidence,version,lifecycle,superseded_by,created_at,updated_at,sh_id) select k.content,k.knowledge_class,k.scope,k.visibility,k.transfer_policy,k.source,jsonb_build_object('clone_origin',jsonb_build_object('source_sh_id',v_agreement.source_sh_id,'source_account_id',v_agreement.source_account_id,'agreement_id',v_agreement.agreement_id,'cloned_at',v_now),'original_provenance',k.provenance),k.confidence,1,case when k.lifecycle='CANDIDATE' then 'ACTIVE' else k.lifecycle end,null,v_now,v_now,v_clone_sh_id from public.knowledge k where k.sh_id=v_agreement.source_sh_id and k.scope='GENERAL' and k.visibility='SHARED' and k.transfer_policy<>'NON_TRANSFERABLE';
  insert into public.experiences(sh_id,account_id,experience_type,content,scope,visibility,transfer_policy,source_ref,provenance,lifecycle,occurred_at,created_at,updated_at) select v_clone_sh_id,v_target_account_id,e.experience_type,e.content,e.scope,e.visibility,e.transfer_policy,e.source_ref,jsonb_build_object('clone_origin',jsonb_build_object('source_sh_id',v_agreement.source_sh_id,'source_account_id',v_agreement.source_account_id,'agreement_id',v_agreement.agreement_id,'cloned_at',v_now),'original_provenance',e.provenance),e.lifecycle,e.occurred_at,v_now,v_now from public.experiences e where e.sh_id=v_agreement.source_sh_id and e.scope='GENERAL' and e.visibility='SHARED' and e.transfer_policy<>'NON_TRANSFERABLE';
  update public.clone_agreements set target_account_id=v_target_account_id where agreement_id=v_agreement.agreement_id;
  return v_clone_sh_id;
end;
$$;
