create table if not exists public.succession_rules (
  succession_id uuid primary key default gen_random_uuid(),
  source_sh_id uuid not null references public.sh_instances(sh_id) on delete restrict,
  successor_account_id uuid not null references public.accounts(account_id) on delete restrict,
  status text not null default 'ACTIVE' check (status in ('ACTIVE','REVOKED','CONSUMED')),
  scope jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  revoked_at timestamptz
);

create table if not exists public.inheritance_authorizations (
  authorization_id uuid primary key default gen_random_uuid(),
  source_sh_id uuid not null references public.sh_instances(sh_id) on delete restrict,
  target_sh_id uuid not null references public.sh_instances(sh_id) on delete restrict,
  source_account_id uuid not null references public.accounts(account_id) on delete restrict,
  target_account_id uuid not null references public.accounts(account_id) on delete restrict,
  status text not null default 'PENDING' check (status in ('PENDING','APPROVED','REVOKED')),
  scope jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  approved_at timestamptz,
  revoked_at timestamptz,
  constraint inheritance_auth_source_target_ck check (source_sh_id <> target_sh_id and source_account_id <> target_account_id)
);

create table if not exists public.inheritance_events (
  inheritance_id uuid primary key default gen_random_uuid(),
  authorization_id uuid not null references public.inheritance_authorizations(authorization_id) on delete restrict,
  source_sh_id uuid not null references public.sh_instances(sh_id) on delete restrict,
  target_sh_id uuid not null references public.sh_instances(sh_id) on delete restrict,
  payload jsonb not null default '{}'::jsonb,
  provenance jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.legacy_records (
  legacy_id uuid primary key default gen_random_uuid(),
  source_sh_id uuid not null references public.sh_instances(sh_id) on delete restrict,
  legacy_type text not null check (legacy_type in ('MEMORY','KNOWLEDGE','EXPERIENCE','JOURNEY','HISTORY','VALUE','REFERENCE')),
  payload jsonb not null default '{}'::jsonb,
  provenance jsonb not null default '{}'::jsonb,
  status text not null default 'PRESERVED' check (status in ('PRESERVED','RELEASED','PURGED')),
  retention_until timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists succession_rules_source_idx on public.succession_rules(source_sh_id,status);
create index if not exists inheritance_auth_source_idx on public.inheritance_authorizations(source_sh_id,status,created_at desc);
create index if not exists inheritance_auth_target_idx on public.inheritance_authorizations(target_sh_id,status,created_at desc);
create index if not exists inheritance_events_target_idx on public.inheritance_events(target_sh_id,created_at desc);
create index if not exists legacy_records_source_idx on public.legacy_records(source_sh_id,status,created_at desc);

alter table public.succession_rules enable row level security;
alter table public.inheritance_authorizations enable row level security;
alter table public.inheritance_events enable row level security;
alter table public.legacy_records enable row level security;

create policy succession_rules_participant_select on public.succession_rules for select using (exists(select 1 from public.sh_instances s where s.sh_id=succession_rules.source_sh_id and s.account_id=current_account_id()) or successor_account_id=current_account_id());
create policy succession_rules_owner_insert on public.succession_rules for insert with check (successor_account_id<>current_account_id() and exists(select 1 from public.sh_instances s where s.sh_id=succession_rules.source_sh_id and s.account_id=current_account_id()));

create policy inheritance_auth_participant_select on public.inheritance_authorizations for select using (source_account_id=current_account_id() or target_account_id=current_account_id());
create policy inheritance_auth_target_insert on public.inheritance_authorizations for insert with check (target_account_id=current_account_id() and source_account_id<>current_account_id());
create policy inheritance_auth_source_update on public.inheritance_authorizations for update using (source_account_id=current_account_id()) with check (source_account_id=current_account_id());

create policy inheritance_events_participant_select on public.inheritance_events for select using (exists(select 1 from public.sh_instances s where s.sh_id=inheritance_events.source_sh_id and s.account_id=current_account_id()) or exists(select 1 from public.sh_instances s where s.sh_id=inheritance_events.target_sh_id and s.account_id=current_account_id()));
create policy legacy_source_select on public.legacy_records for select using (exists(select 1 from public.sh_instances s where s.sh_id=legacy_records.source_sh_id and s.account_id=current_account_id()));

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
declare v_auth inheritance_authorizations%rowtype; v_id uuid;
begin
 if auth.uid() is null then raise exception 'INHERITANCE_REJECTED: authentication required'; end if;
 select * into v_auth from public.inheritance_authorizations where authorization_id=p_authorization_id and status='APPROVED' for update;
 if not found then raise exception 'INHERITANCE_REJECTED: approved authorization required'; end if;
 if v_auth.source_account_id<>current_account_id() then raise exception 'INHERITANCE_REJECTED: source owner approval required'; end if;
 insert into public.inheritance_events(authorization_id,source_sh_id,target_sh_id,payload,provenance) values(p_authorization_id,v_auth.source_sh_id,v_auth.target_sh_id,coalesce(p_payload,'{}'::jsonb),coalesce(p_provenance,'{}'::jsonb)) returning inheritance_id into v_id;
 insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref) values(v_auth.source_sh_id,current_account_id(),'INHERITANCE',now(),'CONTINUOUS',jsonb_build_object('inheritance_id',v_id,'authorization_id',p_authorization_id,'target_sh_id',v_auth.target_sh_id,'payload',coalesce(p_payload,'{}'::jsonb),'provenance',coalesce(p_provenance,'{}'::jsonb)),'inheritance_event:'||v_id::text);
 return v_id;
end;
$$;

grant execute on function public.runtime_record_inheritance(uuid,jsonb,jsonb) to authenticated;

create or replace function public.runtime_record_legacy(
  p_source_sh_id uuid,
  p_legacy_type text,
  p_payload jsonb default '{}'::jsonb,
  p_provenance jsonb default '{}'::jsonb,
  p_retention_until timestamptz default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare v_id uuid;
begin
 if auth.uid() is null then raise exception 'LEGACY_REJECTED: authentication required'; end if;
 if not exists(select 1 from public.sh_instances s where s.sh_id=p_source_sh_id and s.account_id=current_account_id()) then raise exception 'LEGACY_REJECTED: source owner required'; end if;
 if p_legacy_type not in ('MEMORY','KNOWLEDGE','EXPERIENCE','JOURNEY','HISTORY','VALUE','REFERENCE') then raise exception 'LEGACY_REJECTED: invalid legacy_type'; end if;
 insert into public.legacy_records(source_sh_id,legacy_type,payload,provenance,retention_until) values(p_source_sh_id,p_legacy_type,coalesce(p_payload,'{}'::jsonb),coalesce(p_provenance,'{}'::jsonb),p_retention_until) returning legacy_id into v_id;
 insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref) values(p_source_sh_id,current_account_id(),'LEGACY',now(),'CONTINUOUS',jsonb_build_object('legacy_id',v_id,'legacy_type',p_legacy_type,'retention_until',p_retention_until,'payload',coalesce(p_payload,'{}'::jsonb),'provenance',coalesce(p_provenance,'{}'::jsonb)),'legacy_record:'||v_id::text);
 return v_id;
end;
$$;

grant execute on function public.runtime_record_legacy(uuid,text,jsonb,jsonb,timestamptz) to authenticated;
