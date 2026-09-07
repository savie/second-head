create table if not exists public.sh_states (
  sh_id uuid primary key references public.sh_instances(sh_id) on delete cascade,
  state_version integer not null default 1 check (state_version > 0),
  revision bigint not null default 1 check (revision > 0),
  state_payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_sh_states_updated_at on public.sh_states(updated_at);

alter table public.sh_states enable row level security;

create policy sh_states_select_owner on public.sh_states
for select to authenticated
using (exists (select 1 from public.sh_instances si where si.sh_id = sh_states.sh_id and si.account_id = public.current_account_id()));

create policy sh_states_insert_owner on public.sh_states
for insert to authenticated
with check (exists (select 1 from public.sh_instances si where si.sh_id = sh_states.sh_id and si.account_id = public.current_account_id()));

create policy sh_states_update_owner on public.sh_states
for update to authenticated
using (exists (select 1 from public.sh_instances si where si.sh_id = sh_states.sh_id and si.account_id = public.current_account_id()))
with check (exists (select 1 from public.sh_instances si where si.sh_id = sh_states.sh_id and si.account_id = public.current_account_id()));

create or replace function public.runtime_get_sh_state(p_sh_id uuid)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare v_account_id uuid; v_state jsonb;
begin
  v_account_id := public.current_account_id();
  if v_account_id is null then raise exception 'UNAUTHORIZED'; end if;
  if not exists (select 1 from public.sh_instances where sh_id = p_sh_id and account_id = v_account_id) then raise exception 'SH_NOT_FOUND'; end if;
  select jsonb_build_object('sh_id', sh_id, 'state_version', state_version, 'revision', revision, 'state_payload', state_payload, 'created_at', created_at, 'updated_at', updated_at) into v_state from public.sh_states where sh_id = p_sh_id;
  if v_state is null then raise exception 'STATE_NOT_FOUND'; end if;
  return v_state;
end;
$$;

create or replace function public.runtime_mutate_sh_state(p_sh_id uuid,p_expected_revision bigint,p_mutation jsonb)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare v_account_id uuid; v_current_revision bigint; v_state_version integer; v_current_payload jsonb; v_operation text; v_payload jsonb; v_new_payload jsonb; v_result jsonb;
begin
  v_account_id := public.current_account_id();
  if v_account_id is null then raise exception 'UNAUTHORIZED'; end if;
  if not exists (select 1 from public.sh_instances where sh_id = p_sh_id and account_id = v_account_id) then raise exception 'SH_NOT_FOUND'; end if;
  if p_mutation is null or jsonb_typeof(p_mutation) <> 'object' then raise exception 'INVALID_MUTATION'; end if;
  v_operation := p_mutation->>'operation'; v_payload := coalesce(p_mutation->'payload', '{}'::jsonb);
  if v_operation is null or v_operation not in ('SET','MERGE','REMOVE') then raise exception 'INVALID_MUTATION'; end if;
  select revision,state_version,state_payload into v_current_revision,v_state_version,v_current_payload from public.sh_states where sh_id=p_sh_id for update;
  if not found then raise exception 'STATE_NOT_FOUND'; end if;
  if p_expected_revision is null or p_expected_revision <> v_current_revision then raise exception 'REVISION_CONFLICT'; end if;
  if v_operation = 'SET' then
    if jsonb_typeof(v_payload) <> 'object' then raise exception 'INVALID_STATE'; end if; v_new_payload := v_payload;
  elsif v_operation = 'MERGE' then
    if jsonb_typeof(v_payload) <> 'object' then raise exception 'INVALID_STATE'; end if; v_new_payload := v_current_payload || v_payload;
  else
    if jsonb_typeof(v_payload) <> 'array' then raise exception 'INVALID_MUTATION'; end if; v_new_payload := v_current_payload - array(select jsonb_array_elements_text(v_payload));
  end if;
  if jsonb_typeof(v_new_payload) <> 'object' then raise exception 'INVALID_STATE'; end if;
  update public.sh_states set state_payload = v_new_payload, revision = v_current_revision + 1, updated_at = now() where sh_id = p_sh_id and revision = p_expected_revision;
  if not found then raise exception 'REVISION_CONFLICT'; end if;
  select jsonb_build_object('sh_id', sh_id, 'state_version', state_version, 'revision', revision, 'state_payload', state_payload, 'created_at', created_at, 'updated_at', updated_at) into v_result from public.sh_states where sh_id = p_sh_id;
  return v_result;
end;
$$;

grant execute on function public.runtime_get_sh_state(uuid) to authenticated;
grant execute on function public.runtime_mutate_sh_state(uuid,bigint,jsonb) to authenticated;