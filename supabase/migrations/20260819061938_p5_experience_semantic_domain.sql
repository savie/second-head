-- SECOND HEAD P5 — Experience semantic domain reconciliation
-- Owner-approved semantic boundary: Experience is distinct from Knowledge.
-- This is a minimal domain representation only; it does not redefine Journey,
-- Memory, or Knowledge, and it does not introduce automatic capture policy.

create table if not exists public.experiences (
  experience_id uuid primary key default gen_random_uuid(),
  sh_id uuid not null references public.sh_instances(sh_id) on delete restrict,
  account_id uuid not null references public.accounts(account_id) on delete restrict,
  experience_type text not null,
  content text not null,
  scope text not null default 'PRIVATE',
  visibility text not null default 'OWNER_ONLY',
  source_ref text,
  provenance jsonb not null default '{}'::jsonb,
  lifecycle text not null default 'ACTIVE',
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint experiences_scope_check check (scope in ('PRIVATE','GENERAL')),
  constraint experiences_visibility_check check (visibility in ('OWNER_ONLY','SHARED')),
  constraint experiences_lifecycle_check check (lifecycle in ('ACTIVE','ARCHIVED','DEACTIVATED'))
);

create index if not exists experiences_sh_occurred_idx on public.experiences(sh_id, occurred_at desc);
create index if not exists experiences_account_idx on public.experiences(account_id, created_at desc);

alter table public.experiences enable row level security;

drop policy if exists experiences_owner_select on public.experiences;
create policy experiences_owner_select on public.experiences
  for select to authenticated
  using (account_id = public.current_account_id());

drop policy if exists experiences_owner_insert on public.experiences;
create policy experiences_owner_insert on public.experiences
  for insert to authenticated
  with check (
    account_id = public.current_account_id()
    and exists (
      select 1 from public.sh_instances s
      where s.sh_id = experiences.sh_id
        and s.account_id = public.current_account_id()
        and s.status <> 'deactivated'
    )
  );

grant select, insert on public.experiences to authenticated;

create or replace function public.runtime_record_experience(
  p_sh_id uuid,
  p_experience_type text,
  p_content text,
  p_scope text default 'PRIVATE',
  p_visibility text default 'OWNER_ONLY',
  p_source_ref text default null,
  p_provenance jsonb default '{}'::jsonb,
  p_occurred_at timestamptz default now()
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account_id uuid;
  v_experience_id uuid;
begin
  if auth.uid() is null then
    raise exception 'EXPERIENCE_REJECTED: authentication required';
  end if;

  select s.account_id into v_account_id
  from public.sh_instances s
  where s.sh_id = p_sh_id
    and s.account_id = public.current_account_id()
    and s.status <> 'deactivated';

  if v_account_id is null then
    raise exception 'EXPERIENCE_REJECTED: SH not owned by current active account';
  end if;

  insert into public.experiences (
    sh_id, account_id, experience_type, content, scope, visibility,
    source_ref, provenance, lifecycle, occurred_at, created_at, updated_at
  ) values (
    p_sh_id, v_account_id, p_experience_type, p_content, p_scope, p_visibility,
    p_source_ref, coalesce(p_provenance, '{}'::jsonb), 'ACTIVE',
    coalesce(p_occurred_at, now()), now(), now()
  ) returning experience_id into v_experience_id;

  return v_experience_id;
end;
$$;

revoke all on function public.runtime_record_experience(uuid,text,text,text,text,text,jsonb,timestamptz) from public;
grant execute on function public.runtime_record_experience(uuid,text,text,text,text,text,jsonb,timestamptz) to authenticated;

comment on table public.experiences is
  'Distinct semantic Experience domain for an SH. Experience is not Knowledge and is not a transcript or Journey storage replacement.';
comment on function public.runtime_record_experience(uuid,text,text,text,text,text,jsonb,timestamptz) is
  'Owner-scoped explicit Experience recording. Automatic semantic capture remains outside this minimal domain realization.';
