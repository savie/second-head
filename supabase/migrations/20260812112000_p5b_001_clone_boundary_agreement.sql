create table if not exists public.clone_agreements (
  agreement_id uuid primary key default gen_random_uuid(),
  source_sh_id uuid not null references public.sh_instances(sh_id) on delete restrict,
  source_account_id uuid not null references public.accounts(account_id) on delete restrict,
  target_account_id uuid not null references public.accounts(account_id) on delete restrict,
  status text not null default 'PENDING' check (status in ('PENDING','APPROVED','REJECTED','REVOKED')),
  scope jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  approved_at timestamptz,
  revoked_at timestamptz,
  constraint clone_agreements_source_target_ck check (source_account_id <> target_account_id)
);

create table if not exists public.sh_clones (
  clone_sh_id uuid primary key references public.sh_instances(sh_id) on delete restrict,
  source_sh_id uuid not null references public.sh_instances(sh_id) on delete restrict,
  agreement_id uuid not null unique references public.clone_agreements(agreement_id) on delete restrict,
  status text not null default 'ACTIVE' check (status in ('ACTIVE','REVOKED')),
  created_at timestamptz not null default now(),
  revoked_at timestamptz
);

create index if not exists clone_agreements_source_idx on public.clone_agreements(source_sh_id, status, created_at desc);
create index if not exists clone_agreements_target_idx on public.clone_agreements(target_account_id, status, created_at desc);

alter table public.clone_agreements enable row level security;
alter table public.sh_clones enable row level security;

create policy clone_agreements_source_select
  on public.clone_agreements for select
  using (source_account_id = current_account_id() or target_account_id = current_account_id());

create policy clone_agreements_target_insert
  on public.clone_agreements for insert
  with check (target_account_id = current_account_id() and source_account_id <> current_account_id());

create policy clone_agreements_source_update
  on public.clone_agreements for update
  using (source_account_id = current_account_id())
  with check (source_account_id = current_account_id());

create policy sh_clones_participant_select
  on public.sh_clones for select
  using (
    exists (
      select 1 from public.sh_instances s
      where s.sh_id = sh_clones.clone_sh_id
        and s.account_id = current_account_id()
    )
    or exists (
      select 1 from public.sh_instances s
      where s.sh_id = sh_clones.source_sh_id
        and s.account_id = current_account_id()
    )
  );

create or replace function public.runtime_create_clone(
  p_agreement_id uuid,
  p_clone_name text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_agreement clone_agreements%rowtype;
  v_clone_sh_id uuid := gen_random_uuid();
begin
  if auth.uid() is null then
    raise exception 'CLONE_REJECTED: authentication required';
  end if;

  select * into v_agreement
  from public.clone_agreements
  where agreement_id = p_agreement_id
    and status = 'APPROVED'
  for update;

  if not found then
    raise exception 'CLONE_REJECTED: approved agreement required';
  end if;

  if v_agreement.source_account_id <> current_account_id() then
    raise exception 'CLONE_REJECTED: source owner approval required';
  end if;

  if exists (select 1 from public.sh_instances where account_id = v_agreement.target_account_id) then
    raise exception 'CLONE_REJECTED: target account already has an SH';
  end if;

  insert into public.sh_instances (
    sh_id, account_id, sh_type, is_primary, canonical_name, creator_ref,
    status, metadata, version
  ) values (
    v_clone_sh_id, v_agreement.target_account_id, 'CLONE', false,
    nullif(btrim(p_clone_name), ''), v_agreement.source_sh_id::text,
    'ACTIVE', jsonb_build_object('source_sh_id', v_agreement.source_sh_id, 'agreement_id', p_agreement_id), 1
  );

  insert into public.sh_ownership (
    account_id, sh_id, role, evidence_ref
  ) values (
    v_agreement.target_account_id, v_clone_sh_id, 'OWNER', p_agreement_id::text
  );

  insert into public.sh_clones (
    clone_sh_id, source_sh_id, agreement_id
  ) values (
    v_clone_sh_id, v_agreement.source_sh_id, p_agreement_id
  );

  return v_clone_sh_id;
end;
$$;

grant execute on function public.runtime_create_clone(uuid, text) to authenticated;
