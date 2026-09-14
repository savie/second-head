-- SECOND HEAD — selected legacy preservation Journey projection
-- Supabase DEV migration applied first, then reconciled to GitHub.

create or replace function public.runtime_preserve_selected_transfer_as_legacy_unchecked(p_source_sh_id uuid, p_scope jsonb)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_legacy_id uuid;
  v_payload jsonb := '{}'::jsonb;
  v_now timestamptz := now();
begin
  if auth.uid() is null then raise exception 'LEGACY_REJECTED: authentication required'; end if;
  if not exists(select 1 from public.sh_instances s where s.sh_id=p_source_sh_id and s.account_id=public.current_account_id()) then raise exception 'LEGACY_REJECTED: source owner required'; end if;
  if p_scope is null then raise exception 'LEGACY_REJECTED: explicit selection required'; end if;
  if coalesce(p_scope->'reference_ids','[]'::jsonb) <> '[]'::jsonb or coalesce(p_scope->'value_ids','[]'::jsonb) <> '[]'::jsonb or coalesce(p_scope->'history_ids','[]'::jsonb) <> '[]'::jsonb then raise exception 'LEGACY_REJECTED: reference/value/history source domains are not persistently represented'; end if;
  if coalesce(jsonb_array_length(coalesce(p_scope->'memory_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(p_scope->'knowledge_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(p_scope->'experience_ids','[]'::jsonb)),0)+coalesce(jsonb_array_length(coalesce(p_scope->'journey_event_ids','[]'::jsonb)),0)=0 then raise exception 'LEGACY_REJECTED: explicit selection required'; end if;

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
    if exists(select 1 from public.journey_events j where j.event_id=any(array(select distinct value::uuid from jsonb_array_elements_text(p_scope->'journey_event_ids'))) and (j.sh_id<>p_source_sh_id or j.visibility='PRIVATE' or j.transfer_policy='NON_TRANSFERABLE')) then raise exception 'LEGACY_REJECTED: selected Journey contains private or non-transferable event'; end if;
    v_payload:=v_payload||jsonb_build_object('journey',coalesce((select jsonb_agg(to_jsonb(j)) from public.journey_events j where j.sh_id=p_source_sh_id and j.event_id=any(array(select distinct value::uuid from jsonb_array_elements_text(p_scope->'journey_event_ids')))), '[]'::jsonb));
  end if;

  insert into public.legacy_records(source_sh_id,legacy_type,payload,provenance)
  values(p_source_sh_id,'HISTORY',v_payload,jsonb_build_object('legacy_operation','SELECTED_TRANSFER_PRESERVATION','source_sh_id',p_source_sh_id,'selection',p_scope,'preserved_at',v_now))
  returning legacy_id into v_legacy_id;

  insert into public.journey_events(
    sh_id, account_id, event_type, occurred_at, continuity_status,
    payload, source_ref, visibility, transfer_policy, provenance
  ) values (
    p_source_sh_id, public.current_account_id(), 'LEGACY', v_now, 'CONTINUOUS',
    jsonb_build_object('legacy_id',v_legacy_id,'legacy_type','HISTORY','selection',p_scope),
    'legacy_record:'||v_legacy_id::text,
    'PRIVATE', 'NON_TRANSFERABLE',
    jsonb_build_object('legacy_operation','SELECTED_TRANSFER_PRESERVATION','source_sh_id',p_source_sh_id,'legacy_id',v_legacy_id,'selection',p_scope,'preserved_at',v_now)
  );

  return v_legacy_id;
end;
$$;

revoke execute on function public.runtime_preserve_selected_transfer_as_legacy_unchecked(uuid,jsonb) from public, anon, authenticated;
