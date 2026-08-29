-- R4 Google Calendar external account authorization.
-- Stores only non-secret connection metadata in public schema.
-- Provider refresh tokens live in Supabase Vault through service-role-only RPCs.

create table if not exists public.r4_google_oauth_states (
  state_hash text primary key,
  account_id uuid not null references public.accounts(account_id) on delete cascade,
  sh_id uuid not null references public.sh_instances(sh_id) on delete cascade,
  expires_at timestamptz not null,
  consumed_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists r4_google_oauth_states_expiry_idx
  on public.r4_google_oauth_states(expires_at);

alter table public.r4_google_oauth_states enable row level security;

revoke all on public.r4_google_oauth_states from anon, authenticated, public;

create table if not exists public.r4_google_connections (
  connection_id uuid primary key default gen_random_uuid(),
  account_id uuid not null references public.accounts(account_id) on delete cascade,
  sh_id uuid not null references public.sh_instances(sh_id) on delete cascade,
  provider text not null check (provider = 'GOOGLE'),
  target_type text not null check (target_type = 'GOOGLE_PRIMARY_CALENDAR'),
  target_id text not null default 'primary',
  scopes text[] not null default '{}',
  status text not null check (status in ('CONNECTED','REVOKED','ERROR')),
  vault_secret_name text not null,
  connected_at timestamptz,
  revoked_at timestamptz,
  last_verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(account_id, provider)
);

create index if not exists r4_google_connections_account_idx
  on public.r4_google_connections(account_id);

alter table public.r4_google_connections enable row level security;

revoke all on public.r4_google_connections from anon, public;
grant select on public.r4_google_connections to authenticated;

drop policy if exists r4_google_connections_select_own on public.r4_google_connections;
create policy r4_google_connections_select_own
on public.r4_google_connections
for select
to authenticated
using (
  account_id = public.current_account_id()
);

create or replace function public.r4_vault_store_google_refresh_token(
  p_secret_name text,
  p_secret text
)
returns void
language plpgsql
security definer
set search_path = public, vault
as $$
declare
  v_id uuid;
begin
  if current_setting('request.jwt.claims', true)::jsonb->>'role' <> 'service_role'
     and current_user <> 'postgres' then
    raise exception 'R4_VAULT_DENIED';
  end if;

  select id into v_id
  from vault.secrets
  where name = p_secret_name
  limit 1;

  if v_id is null then
    perform vault.create_secret(
      p_secret,
      p_secret_name,
      'Second Head R4 Google Calendar refresh token'
    );
  else
    perform vault.update_secret(
      v_id,
      p_secret,
      p_secret_name,
      'Second Head R4 Google Calendar refresh token'
    );
  end if;
end;
$$;

create or replace function public.r4_vault_get_google_refresh_token(
  p_secret_name text
)
returns text
language plpgsql
security definer
set search_path = public, vault
as $$
declare
  v_secret text;
begin
  if current_setting('request.jwt.claims', true)::jsonb->>'role' <> 'service_role'
     and current_user <> 'postgres' then
    raise exception 'R4_VAULT_DENIED';
  end if;

  select decrypted_secret into v_secret
  from vault.decrypted_secrets
  where name = p_secret_name
  limit 1;

  if v_secret is null then
    raise exception 'R4_VAULT_SECRET_NOT_FOUND';
  end if;

  return v_secret;
end;
$$;

create or replace function public.r4_vault_delete_google_refresh_token(
  p_secret_name text
)
returns void
language plpgsql
security definer
set search_path = public, vault
as $$
begin
  if current_setting('request.jwt.claims', true)::jsonb->>'role' <> 'service_role'
     and current_user <> 'postgres' then
    raise exception 'R4_VAULT_DENIED';
  end if;

  delete from vault.secrets where name = p_secret_name;
end;
$$;

revoke all on function public.r4_vault_store_google_refresh_token(text,text) from public, anon, authenticated;
revoke all on function public.r4_vault_get_google_refresh_token(text) from public, anon, authenticated;
revoke all on function public.r4_vault_delete_google_refresh_token(text) from public, anon, authenticated;
grant execute on function public.r4_vault_store_google_refresh_token(text,text) to service_role;
grant execute on function public.r4_vault_get_google_refresh_token(text) to service_role;
grant execute on function public.r4_vault_delete_google_refresh_token(text) to service_role;

create or replace function public.r4_google_connection_status()
returns table(
  connection_id uuid,
  provider text,
  target_type text,
  target_id text,
  scopes text[],
  status text,
  connected_at timestamptz,
  revoked_at timestamptz,
  last_verified_at timestamptz
)
language sql
security invoker
set search_path = public
as $$
  select
    c.connection_id,
    c.provider,
    c.target_type,
    c.target_id,
    c.scopes,
    c.status,
    c.connected_at,
    c.revoked_at,
    c.last_verified_at
  from public.r4_google_connections c
  where c.account_id = public.current_account_id()
  order by c.updated_at desc
  limit 1;
$$;

revoke all on function public.r4_google_connection_status() from public, anon;
grant execute on function public.r4_google_connection_status() to authenticated;

-- Keep only a short-lived OAuth state and clean consumed/expired rows.
create or replace function public.r4_google_oauth_cleanup()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count integer;
begin
  if current_user <> 'postgres'
     and current_setting('request.jwt.claims', true)::jsonb->>'role' <> 'service_role' then
    raise exception 'R4_OAUTH_CLEANUP_DENIED';
  end if;

  delete from public.r4_google_oauth_states
  where expires_at < now() or consumed_at is not null;
  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

revoke all on function public.r4_google_oauth_cleanup() from public, anon, authenticated;
grant execute on function public.r4_google_oauth_cleanup() to service_role;
