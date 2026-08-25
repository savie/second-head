-- SECOND HEAD P5C — transfer privacy boundary hardening
-- Selected transfer may include only records that are not PRIVATE and not OWNER_ONLY.
-- Existing transfer implementations are wrapped so the boundary is enforced at execution time.

create or replace function public.runtime_validate_selected_transfer_scope(
  p_source_sh_id uuid,
  p_scope jsonb,
  p_operation text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_scope jsonb := coalesce(p_scope, '{}'::jsonb);
  v_requested integer;
  v_matched integer;
begin
  if p_source_sh_id is null then
    raise exception '%_REJECTED: source SH is required', upper(p_operation);
  end if;

  -- Memory
  v_requested := coalesce(jsonb_array_length(coalesce(v_scope->'memory_ids','[]'::jsonb)),0);
  if v_requested > 0 then
    select count(*) into v_matched
    from public.memories m
    where m.sh_id = p_source_sh_id
      and m.memory_id = any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))));
    if v_requested <> v_matched then
      raise exception '%_REJECTED: selected memory is not owned by source SH', upper(p_operation);
    end if;
    if exists (
      select 1 from public.memories m
      where m.sh_id = p_source_sh_id
        and m.memory_id = any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))))
        and (m.scope = 'PRIVATE' or m.visibility = 'OWNER_ONLY')
    ) then
      raise exception '%_REJECTED: selected memory is private or owner-only', upper(p_operation);
    end if;
  end if;

  -- Knowledge
  v_requested := coalesce(jsonb_array_length(coalesce(v_scope->'knowledge_ids','[]'::jsonb)),0);
  if v_requested > 0 then
    select count(*) into v_matched
    from public.knowledge k
    where k.sh_id = p_source_sh_id
      and k.knowledge_id = any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))));
    if v_requested <> v_matched then
      raise exception '%_REJECTED: selected knowledge is not owned by source SH', upper(p_operation);
    end if;
    if exists (
      select 1 from public.knowledge k
      where k.sh_id = p_source_sh_id
        and k.knowledge_id = any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))))
        and (k.scope = 'PRIVATE' or k.visibility = 'OWNER_ONLY')
    ) then
      raise exception '%_REJECTED: selected knowledge is private or owner-only', upper(p_operation);
    end if;
  end if;

  -- Experience
  v_requested := coalesce(jsonb_array_length(coalesce(v_scope->'experience_ids','[]'::jsonb)),0);
  if v_requested > 0 then
    select count(*) into v_matched
    from public.experiences e
    where e.sh_id = p_source_sh_id
      and e.experience_id = any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))));
    if v_requested <> v_matched then
      raise exception '%_REJECTED: selected experience is not owned by source SH', upper(p_operation);
    end if;
    if exists (
      select 1 from public.experiences e
      where e.sh_id = p_source_sh_id
        and e.experience_id = any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))))
        and (e.scope = 'PRIVATE' or e.visibility = 'OWNER_ONLY')
    ) then
      raise exception '%_REJECTED: selected experience is private or owner-only', upper(p_operation);
    end if;
  end if;

  -- Journey has its own transfer_policy enforcement in the existing transfer primitive.
end;
$$;

revoke all on function public.runtime_validate_selected_transfer_scope(uuid,jsonb,text) from public;
grant execute on function public.runtime_validate_selected_transfer_scope(uuid,jsonb,text) to authenticated;

alter function public.runtime_record_inheritance(uuid,jsonb,jsonb) rename to runtime_record_inheritance_unchecked;
create or replace function public.runtime_record_inheritance(
  p_authorization_id uuid,
  p_payload jsonb default '{}'::jsonb,
  p_provenance jsonb default '{}'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare v_auth public.inheritance_authorizations%rowtype; v_result uuid;
begin
  select * into v_auth from public.inheritance_authorizations where authorization_id = p_authorization_id and status = 'APPROVED';
  if not found then raise exception 'INHERITANCE_REJECTED: approved authorization required'; end if;
  if v_auth.source_account_id <> public.current_account_id() then raise exception 'INHERITANCE_REJECTED: source owner approval required'; end if;
  perform public.runtime_validate_selected_transfer_scope(v_auth.source_sh_id, v_auth.scope, 'inheritance');
  v_result := public.runtime_record_inheritance_unchecked(p_authorization_id, p_payload, p_provenance);
  return v_result;
end;
$$;
revoke all on function public.runtime_record_inheritance(uuid,jsonb,jsonb) from public;
grant execute on function public.runtime_record_inheritance(uuid,jsonb,jsonb) to authenticated;

alter function public.runtime_execute_succession(uuid) rename to runtime_execute_succession_unchecked;
create or replace function public.runtime_execute_succession(p_succession_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare v_rule public.succession_rules%rowtype; v_result uuid;
begin
  select * into v_rule from public.succession_rules where succession_id = p_succession_id and status = 'ACTIVE';
  if not found then raise exception 'SUCCESSION_REJECTED: active succession rule required'; end if;
  perform public.runtime_validate_selected_transfer_scope(v_rule.source_sh_id, v_rule.scope, 'succession');
  v_result := public.runtime_execute_succession_unchecked(p_succession_id);
  return v_result;
end;
$$;
revoke all on function public.runtime_execute_succession(uuid) from public;
grant execute on function public.runtime_execute_succession(uuid) to authenticated;

alter function public.runtime_preserve_selected_transfer_as_legacy(uuid,jsonb) rename to runtime_preserve_selected_transfer_as_legacy_unchecked;
create or replace function public.runtime_preserve_selected_transfer_as_legacy(p_source_sh_id uuid,p_scope jsonb)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare v_result uuid;
begin
  perform public.runtime_validate_selected_transfer_scope(p_source_sh_id, p_scope, 'legacy');
  v_result := public.runtime_preserve_selected_transfer_as_legacy_unchecked(p_source_sh_id, p_scope);
  return v_result;
end;
$$;
revoke all on function public.runtime_preserve_selected_transfer_as_legacy(uuid,jsonb) from public;
grant execute on function public.runtime_preserve_selected_transfer_as_legacy(uuid,jsonb) to authenticated;
