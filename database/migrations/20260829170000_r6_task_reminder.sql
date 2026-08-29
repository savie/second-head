-- R6 bounded Task / Reminder creation for Family E.
-- Local SH-owned productivity object. No external provider or notification
-- service is required for this representative slice.

create table if not exists public.r6_tasks (
  task_id uuid primary key default gen_random_uuid(),
  account_id uuid not null references public.accounts(account_id) on delete cascade,
  sh_id uuid not null references public.sh_instances(sh_id) on delete cascade,
  actor_id uuid not null,
  title text not null check (length(trim(title)) between 1 and 500),
  due_at timestamptz not null,
  status text not null default 'OPEN' check (status in ('OPEN','COMPLETED','CANCELLED')),
  source text not null default 'OWNER_REQUEST' check (source = 'OWNER_REQUEST'),
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  updated_at timestamptz not null default now()
);

create index if not exists r6_tasks_account_due_idx
  on public.r6_tasks(account_id, due_at asc)
  where status = 'OPEN';

alter table public.r6_tasks enable row level security;

revoke all on public.r6_tasks from anon, public, authenticated;
grant select on public.r6_tasks to authenticated;

drop policy if exists r6_tasks_select_own on public.r6_tasks;
create policy r6_tasks_select_own
on public.r6_tasks
for select
to authenticated
using (account_id = public.current_account_id());

create or replace function public.r6_create_task(
  p_title text,
  p_due_at timestamptz
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account_id uuid;
  v_sh_id uuid;
  v_task_id uuid;
begin
  v_account_id := public.current_account_id();
  if v_account_id is null then
    raise exception 'R6_TASK_REJECTED: authenticated account is required';
  end if;

  select s.sh_id
    into v_sh_id
    from public.sh_instances s
   where s.account_id = v_account_id
   order by s.created_at
   limit 1;

  if v_sh_id is null then
    raise exception 'R6_TASK_REJECTED: SH identity could not be resolved';
  end if;

  if p_title is null or length(trim(p_title)) = 0 then
    raise exception 'R6_TASK_REJECTED: task title is required';
  end if;

  if p_due_at is null then
    raise exception 'R6_TASK_REJECTED: due time is required';
  end if;

  insert into public.r6_tasks(account_id, sh_id, actor_id, title, due_at)
  values (v_account_id, v_sh_id, auth.uid(), trim(p_title), p_due_at)
  returning task_id into v_task_id;

  return v_task_id;
end;
$$;

revoke all on function public.r6_create_task(text,timestamptz) from public, anon;
grant execute on function public.r6_create_task(text,timestamptz) to authenticated;

create or replace function public.r6_list_tasks(p_limit integer default 20)
returns table(
  task_id uuid,
  title text,
  due_at timestamptz,
  status text,
  created_at timestamptz,
  completed_at timestamptz
)
language sql
security invoker
set search_path = public
as $$
  select t.task_id, t.title, t.due_at, t.status, t.created_at, t.completed_at
    from public.r6_tasks t
   where t.account_id = public.current_account_id()
   order by t.due_at asc
   limit least(greatest(coalesce(p_limit,20),1),100);
$$;

revoke all on function public.r6_list_tasks(integer) from public, anon;
grant execute on function public.r6_list_tasks(integer) to authenticated;
