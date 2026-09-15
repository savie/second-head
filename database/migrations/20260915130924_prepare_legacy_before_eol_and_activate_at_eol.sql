ALTER TABLE public.legacy_records DROP CONSTRAINT IF EXISTS legacy_records_status_check;
ALTER TABLE public.legacy_records ADD CONSTRAINT legacy_records_status_check CHECK (status IN ('PREPARED','PRESERVED','RELEASED','PURGED'));

CREATE OR REPLACE FUNCTION public.runtime_prepare_selected_transfer_as_legacy(
  p_source_sh_id uuid,
  p_scope jsonb
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare
  v_legacy_id uuid;
  v_payload jsonb := '{}'::jsonb;
  v_now timestamptz := now();
begin
  if auth.uid() is null then raise exception 'LEGACY_PREPARATION_REJECTED: authentication required'; end if;
  if not exists(select 1 from public.sh_instances s where s.sh_id=p_source_sh_id and s.account_id=public.current_account_id() and s.status <> 'deactivated') then
    raise exception 'LEGACY_PREPARATION_REJECTED: active source SH required';
  end if;
  if p_scope is null then raise exception 'LEGACY_PREPARATION_REJECTED: explicit selection required'; end if;
  if p_scope ? 'target_email' then raise exception 'LEGACY_PREPARATION_REJECTED: legacy has no target actor'; end if;
  if coalesce(p_scope->'reference_ids','[]'::jsonb) <> '[]'::jsonb or coalesce(p_scope->'value_ids','[]'::jsonb) <> '[]'::jsonb or coalesce(p_scope->'history_ids','[]'::jsonb) <> '[]'::jsonb then
    raise exception 'LEGACY_PREPARATION_REJECTED: reference/value/history source domains are not persistently represented';
  end if;
  if coalesce(jsonb_array_length(coalesce(p_scope->'memory_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(p_scope->'knowledge_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(p_scope->'experience_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(p_scope->'journey_event_ids','[]'::jsonb)),0)=0 then
    raise exception 'LEGACY_PREPARATION_REJECTED: explicit selection required';
  end if;
  if coalesce(jsonb_array_length(coalesce(p_scope->'memory_ids','[]'::jsonb)),0)>0 then
    v_payload:=v_payload||jsonb_build_object('memory',coalesce((select jsonb_agg(to_jsonb(m)) from public.memories m where m.sh_id=p_source_sh_id and m.memory_id=any(array(select distinct value::uuid from jsonb_array_elements_text(p_scope->'memory_ids')))), '[]'::jsonb));
  end if;
  if coalesce(jsonb_array_length(coalesce(p_scope->'knowledge_ids','[]'::jsonb)),0)>0 then
    v_payload:=v_payload||jsonb_build_object('knowledge',coalesce((select jsonb_agg(to_jsonb(k)) from public.knowledge k where k.sh_id=p_source_sh_id and k.knowledge_id=any(array(select distinct value::uuid from jsonb_array_elements_text(p_scope->'knowledge_ids')))), '[]'::jsonb));
  end if;
  if coalesce(jsonb_array_length(coalesce(p_scope->'experience_ids','[]'::jsonb)),0)>0 then
    v_payload:=v_payload||jsonb_build_object('experience',coalesce((select jsonb_agg(to_jsonb(e)) from public.experiences e where e.sh_id=p_source_sh_id and e.experience_id=any(array(select distinct value::uuid from jsonb_array_elements_text(p_scope->'experience_ids')))), '[]'::jsonb));
  end if;
  if coalesce(jsonb_array_length(coalesce(p_scope->'journey_event_ids','[]'::jsonb)),0)>0 then
    if exists(select 1 from public.journey_events j where j.event_id=any(array(select distinct value::uuid from jsonb_array_elements_text(p_scope->'journey_event_ids'))) and (j.sh_id<>p_source_sh_id or j.visibility='PRIVATE' or j.transfer_policy='NON_TRANSFERABLE')) then
      raise exception 'LEGACY_PREPARATION_REJECTED: selected Journey contains private or non-transferable event';
    end if;
    v_payload:=v_payload||jsonb_build_object('journey',coalesce((select jsonb_agg(to_jsonb(j)) from public.journey_events j where j.sh_id=p_source_sh_id and j.event_id=any(array(select distinct value::uuid from jsonb_array_elements_text(p_scope->'journey_event_ids')))), '[]'::jsonb));
  end if;
  insert into public.legacy_records(source_sh_id,legacy_type,payload,provenance,status)
  values(p_source_sh_id,'HISTORY',v_payload,jsonb_build_object('legacy_operation','SELECTED_TRANSFER_PREPARATION','source_sh_id',p_source_sh_id,'selection',p_scope,'distribution','ALL_SH','prepared_at',v_now),'PREPARED')
  returning legacy_id into v_legacy_id;
  return v_legacy_id;
end;
$$;

CREATE OR REPLACE FUNCTION public.runtime_activate_prepared_legacy(p_source_sh_id uuid)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare
  v_count integer;
  v_now timestamptz := now();
begin
  if auth.uid() is null then raise exception 'LEGACY_ACTIVATION_REJECTED: authentication required'; end if;
  if not exists(select 1 from public.sh_instances s where s.sh_id=p_source_sh_id and s.account_id=public.current_account_id() and s.status='deactivated') then
    raise exception 'LEGACY_ACTIVATION_REJECTED: source SH must be end-of-life/deactivated';
  end if;
  update public.legacy_records
     set status='PRESERVED',
         provenance=coalesce(provenance,'{}'::jsonb)||jsonb_build_object('activated_at',v_now,'activation','SOURCE_SH_END_OF_LIFE')
   where source_sh_id=p_source_sh_id and status='PREPARED';
  get diagnostics v_count = row_count;
  if v_count > 0 then
    insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref,visibility,transfer_policy,provenance)
    values(p_source_sh_id,public.current_account_id(),'LEGACY',v_now,'CONTINUOUS',jsonb_build_object('legacy_activation','SOURCE_SH_END_OF_LIFE','prepared_count',v_count),'legacy_activation:'||p_source_sh_id::text,'PUBLIC','NON_TRANSFERABLE',jsonb_build_object('legacy_operation','SOURCE_SH_END_OF_LIFE_ACTIVATION','source_sh_id',p_source_sh_id,'activated_at',v_now,'prepared_count',v_count));
  end if;
  return v_count;
end;
$$;

CREATE OR REPLACE FUNCTION public.runtime_end_of_life_sh(p_sh_id uuid, p_reason text default null)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare
  v_account_id uuid;
  v_status text;
begin
  select s.account_id, s.status into v_account_id, v_status
    from public.sh_instances s where s.sh_id=p_sh_id and s.account_id=public.current_account_id();
  if v_account_id is null then raise exception 'END_OF_LIFE_REJECTED: SH not owned by current account'; end if;
  if v_status = 'deactivated' then
    perform public.runtime_activate_prepared_legacy(p_sh_id);
    return p_sh_id;
  end if;
  update public.sh_instances set status='deactivated', deactivated_at=coalesce(deactivated_at,now()), metadata=metadata||jsonb_build_object('end_of_life',jsonb_build_object('occurred_at',coalesce(deactivated_at,now()),'reason',p_reason)), updated_at=now()
   where sh_id=p_sh_id and account_id=v_account_id;
  update public.accounts set status='deactivated', deactivated_at=coalesce(deactivated_at,now()), updated_at=now() where account_id=v_account_id;
  perform public.runtime_activate_prepared_legacy(p_sh_id);
  return p_sh_id;
end;
$$;

grant execute on function public.runtime_prepare_selected_transfer_as_legacy(uuid,jsonb) to authenticated;
grant execute on function public.runtime_activate_prepared_legacy(uuid) to authenticated;
grant execute on function public.runtime_end_of_life_sh(uuid,text) to authenticated;
revoke execute on function public.runtime_prepare_selected_transfer_as_legacy(uuid,jsonb) from anon;
revoke execute on function public.runtime_activate_prepared_legacy(uuid) from anon;
revoke execute on function public.runtime_end_of_life_sh(uuid,text) from anon;
