-- SECOND HEAD — Canonical Addendum Privacy / Transfer Policy reconciliation
-- Privacy/scope and transfer eligibility are independent semantics.
-- Existing records default to NON_TRANSFERABLE for safety; owners may opt in explicitly.

alter table public.memories
  add column if not exists transfer_policy text not null default 'NON_TRANSFERABLE';

alter table public.knowledge
  add column if not exists transfer_policy text not null default 'NON_TRANSFERABLE';

alter table public.experiences
  add column if not exists transfer_policy text not null default 'NON_TRANSFERABLE';

alter table public.memories
  drop constraint if exists memories_transfer_policy_check;
alter table public.memories
  add constraint memories_transfer_policy_check
  check (transfer_policy in ('NON_TRANSFERABLE','INHERITABLE','SUCCESSION','LEGACY'));

alter table public.knowledge
  drop constraint if exists knowledge_transfer_policy_check;
alter table public.knowledge
  add constraint knowledge_transfer_policy_check
  check (transfer_policy in ('NON_TRANSFERABLE','INHERITABLE','SUCCESSION','LEGACY'));

alter table public.experiences
  drop constraint if exists experiences_transfer_policy_check;
alter table public.experiences
  add constraint experiences_transfer_policy_check
  check (transfer_policy in ('NON_TRANSFERABLE','INHERITABLE','SUCCESSION','LEGACY'));

-- Replace the old privacy-as-transfer gate with an explicit policy gate.
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
  v_policy text;
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
    select m.transfer_policy into v_policy
    from public.memories m
    where m.sh_id = p_source_sh_id
      and m.memory_id = any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'memory_ids','[]'::jsonb))))
      and m.transfer_policy = upper(p_operation);
    if v_policy is null then
      raise exception '%_REJECTED: selected memory is not eligible for this transfer operation', upper(p_operation);
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
    select k.transfer_policy into v_policy
    from public.knowledge k
    where k.sh_id = p_source_sh_id
      and k.knowledge_id = any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'knowledge_ids','[]'::jsonb))))
      and k.transfer_policy = upper(p_operation);
    if v_policy is null then
      raise exception '%_REJECTED: selected knowledge is not eligible for this transfer operation', upper(p_operation);
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
    select e.transfer_policy into v_policy
    from public.experiences e
    where e.sh_id = p_source_sh_id
      and e.experience_id = any(array(select distinct value::uuid from jsonb_array_elements_text(coalesce(v_scope->'experience_ids','[]'::jsonb))))
      and e.transfer_policy = upper(p_operation);
    if v_policy is null then
      raise exception '%_REJECTED: selected experience is not eligible for this transfer operation', upper(p_operation);
    end if;
  end if;

  -- Journey retains its existing transfer_policy enforcement.
end;
$$;

revoke all on function public.runtime_validate_selected_transfer_scope(uuid,jsonb,text) from public;
grant execute on function public.runtime_validate_selected_transfer_scope(uuid,jsonb,text) to authenticated;
