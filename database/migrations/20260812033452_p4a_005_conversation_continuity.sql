create table if not exists public.conversations (
  conversation_id uuid primary key default gen_random_uuid(),
  account_id uuid not null references public.accounts(account_id) on delete cascade,
  sh_id uuid not null references public.sh_instances(sh_id) on delete cascade,
  role text not null check (role in ('user','assistant','system')),
  content text not null,
  created_at timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb
);

create index if not exists conversations_sh_created_idx on public.conversations(sh_id, created_at desc);
create index if not exists conversations_account_created_idx on public.conversations(account_id, created_at desc);

alter table public.conversations enable row level security;

create or replace function public.runtime_record_conversation(
  p_sh_id uuid,
  p_role text,
  p_content text,
  p_metadata jsonb default '{}'::jsonb
) returns public.conversations
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_account_id uuid;
  v_row public.conversations;
begin
  select si.account_id into v_account_id
  from public.sh_instances si
  where si.sh_id = p_sh_id
    and si.account_id = auth.uid()
  limit 1;

  if v_account_id is null then
    raise exception 'RUNTIME_CONVERSATION_ACCESS_DENIED';
  end if;

  insert into public.conversations(account_id, sh_id, role, content, metadata)
  values (v_account_id, p_sh_id, p_role, p_content, coalesce(p_metadata, '{}'::jsonb))
  returning * into v_row;

  return v_row;
end;
$$;

revoke all on function public.runtime_record_conversation(uuid,text,text,jsonb) from public;
grant execute on function public.runtime_record_conversation(uuid,text,text,jsonb) to authenticated;
