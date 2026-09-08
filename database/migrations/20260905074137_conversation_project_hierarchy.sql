create table if not exists public.projects (
  project_id uuid primary key default gen_random_uuid(),
  account_id uuid not null,
  sh_id uuid not null,
  name text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint projects_name_nonblank check (length(trim(name)) > 0),
  constraint projects_sh_owner_fk foreign key (sh_id) references public.sh_instances(sh_id) on delete cascade
);

create table if not exists public.conversation_threads (
  conversation_id uuid primary key default gen_random_uuid(),
  account_id uuid not null,
  sh_id uuid not null,
  project_id uuid null references public.projects(project_id) on delete set null,
  title text not null default 'New Conversation',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint conversation_threads_title_nonblank check (length(trim(title)) > 0),
  constraint conversation_threads_sh_owner_fk foreign key (sh_id) references public.sh_instances(sh_id) on delete cascade
);

alter table public.conversations add column if not exists thread_id uuid;
alter table public.conversations add column if not exists message_id uuid default gen_random_uuid();

insert into public.conversation_threads (conversation_id, account_id, sh_id, title, created_at, updated_at)
select c.conversation_id,
       c.account_id,
       c.sh_id,
       coalesce(nullif(trim(c.metadata->>'conversation_title'), ''), 'Conversation'),
       c.created_at,
       c.created_at
from public.conversations c
where not exists (
  select 1 from public.conversation_threads t where t.conversation_id = c.conversation_id
);

update public.conversations c
set thread_id = c.conversation_id
where c.thread_id is null;

alter table public.conversations alter column thread_id set not null;
alter table public.conversations alter column message_id set not null;
create unique index if not exists conversations_message_id_uidx on public.conversations(message_id);
create index if not exists conversations_thread_created_idx on public.conversations(thread_id, created_at asc, message_id asc);
create index if not exists conversation_threads_sh_updated_idx on public.conversation_threads(sh_id, updated_at desc, conversation_id desc);
create index if not exists projects_sh_updated_idx on public.projects(sh_id, updated_at desc, project_id desc);

alter table public.projects enable row level security;
alter table public.conversation_threads enable row level security;

create policy projects_select_own on public.projects for select using (account_id = public.current_account_id());
create policy conversation_threads_select_own on public.conversation_threads for select using (account_id = public.current_account_id());

create or replace function public.runtime_list_projects()
returns table(project_id uuid, name text, created_at timestamptz, updated_at timestamptz)
language plpgsql security definer set search_path to 'public'
as $$
declare v_identity record;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then raise exception 'PROJECT_UNAUTHENTICATED'; end if;
  return query
  select p.project_id, p.name, p.created_at, p.updated_at
  from public.projects p
  where p.account_id=v_identity.account_id and p.sh_id=v_identity.sh_id
  order by p.updated_at desc, p.project_id desc;
end;
$$;

create or replace function public.runtime_create_project(p_name text)
returns uuid
language plpgsql security definer set search_path to 'public'
as $$
declare v_identity record; v_id uuid;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then raise exception 'PROJECT_UNAUTHENTICATED'; end if;
  if nullif(trim(p_name),'') is null then raise exception 'PROJECT_NAME_REQUIRED'; end if;
  insert into public.projects(account_id,sh_id,name) values(v_identity.account_id,v_identity.sh_id,trim(p_name)) returning project_id into v_id;
  return v_id;
end;
$$;

create or replace function public.runtime_list_conversations()
returns table(conversation_id uuid, account_id uuid, sh_id uuid, project_id uuid, title text, created_at timestamptz, updated_at timestamptz, preview text)
language plpgsql security definer set search_path to 'public'
as $$
declare v_identity record;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then raise exception 'CONVERSATION_UNAUTHENTICATED'; end if;
  return query
  select t.conversation_id,t.account_id,t.sh_id,t.project_id,t.title,t.created_at,t.updated_at,
         coalesce((select c.content from public.conversations c where c.thread_id=t.conversation_id order by c.created_at desc,c.message_id desc limit 1),'')
  from public.conversation_threads t
  where t.account_id=v_identity.account_id and t.sh_id=v_identity.sh_id
  order by t.updated_at desc,t.conversation_id desc;
end;
$$;

create or replace function public.runtime_create_conversation(p_project_id uuid default null, p_title text default 'New Conversation')
returns uuid
language plpgsql security definer set search_path to 'public'
as $$
declare v_identity record; v_id uuid; v_project_account uuid;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then raise exception 'CONVERSATION_UNAUTHENTICATED'; end if;
  if p_project_id is not null then
    select p.account_id into v_project_account from public.projects p where p.project_id=p_project_id and p.sh_id=v_identity.sh_id;
    if v_project_account is null or v_project_account<>v_identity.account_id then raise exception 'CONVERSATION_PROJECT_ACCESS_DENIED'; end if;
  end if;
  insert into public.conversation_threads(account_id,sh_id,project_id,title) values(v_identity.account_id,v_identity.sh_id,p_project_id,coalesce(nullif(trim(p_title),''),'New Conversation')) returning conversation_id into v_id;
  return v_id;
end;
$$;

create or replace function public.runtime_load_conversation_messages(p_conversation_id uuid, p_limit integer default 100)
returns table(message_id uuid, conversation_id uuid, role text, content text, created_at timestamptz, metadata jsonb)
language plpgsql security definer set search_path to 'public'
as $$
declare v_identity record; v_limit integer:=greatest(1,least(coalesce(p_limit,100),200));
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then raise exception 'CONVERSATION_UNAUTHENTICATED'; end if;
  if not exists(select 1 from public.conversation_threads t where t.conversation_id=p_conversation_id and t.account_id=v_identity.account_id and t.sh_id=v_identity.sh_id) then raise exception 'CONVERSATION_ACCESS_DENIED'; end if;
  return query
  select c.message_id,c.thread_id,c.role,c.content,c.created_at,c.metadata
  from public.conversations c
  where c.thread_id=p_conversation_id and c.account_id=v_identity.account_id and c.sh_id=v_identity.sh_id
  order by c.created_at asc,c.message_id asc
  limit v_limit;
end;
$$;

create or replace function public.runtime_load_conversation_context_for_thread(p_conversation_id uuid, p_limit integer default 12)
returns table(message_id uuid, conversation_id uuid, role text, content text, created_at timestamptz, metadata jsonb)
language plpgsql security definer set search_path to 'public'
as $$
declare v_identity record; v_limit integer:=greatest(1,least(coalesce(p_limit,12),12));
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then raise exception 'CONVERSATION_UNAUTHENTICATED'; end if;
  if not exists(select 1 from public.conversation_threads t where t.conversation_id=p_conversation_id and t.account_id=v_identity.account_id and t.sh_id=v_identity.sh_id) then raise exception 'CONVERSATION_ACCESS_DENIED'; end if;
  return query
  select c.message_id,c.thread_id,c.role,c.content,c.created_at,c.metadata
  from (select c.* from public.conversations c where c.thread_id=p_conversation_id and c.account_id=v_identity.account_id and c.sh_id=v_identity.sh_id order by c.created_at desc,c.message_id desc limit v_limit) c
  order by c.created_at asc,c.message_id asc;
end;
$$;

create or replace function public.runtime_record_conversation_message(p_conversation_id uuid, p_role text, p_content text, p_metadata jsonb default '{}'::jsonb)
returns public.conversations
language plpgsql security definer set search_path to 'public'
as $$
declare v_identity record; v_row public.conversations;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then raise exception 'CONVERSATION_UNAUTHENTICATED'; end if;
  if not exists(select 1 from public.conversation_threads t where t.conversation_id=p_conversation_id and t.account_id=v_identity.account_id and t.sh_id=v_identity.sh_id) then raise exception 'CONVERSATION_ACCESS_DENIED'; end if;
  if p_role not in ('user','assistant','system') then raise exception 'CONVERSATION_INVALID_ROLE'; end if;
  if p_content is null or length(trim(p_content))=0 then raise exception 'CONVERSATION_INVALID_CONTENT'; end if;
  insert into public.conversations(account_id,sh_id,thread_id,role,content,metadata) values(v_identity.account_id,v_identity.sh_id,p_conversation_id,p_role,p_content,coalesce(p_metadata,'{}'::jsonb)) returning * into v_row;
  update public.conversation_threads set updated_at=now() where conversation_id=p_conversation_id;
  return v_row;
end;
$$;

create or replace function public.runtime_rename_conversation_thread(p_conversation_id uuid, p_title text)
returns void
language plpgsql security definer set search_path to 'public'
as $$
declare v_identity record; v_count integer;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then raise exception 'CONVERSATION_UNAUTHENTICATED'; end if;
  if nullif(trim(p_title),'') is null then raise exception 'CONVERSATION_TITLE_REQUIRED'; end if;
  update public.conversation_threads set title=trim(p_title),updated_at=now() where conversation_id=p_conversation_id and account_id=v_identity.account_id and sh_id=v_identity.sh_id;
  get diagnostics v_count=row_count;
  if v_count<>1 then raise exception 'CONVERSATION_NOT_FOUND'; end if;
end;
$$;

create or replace function public.runtime_update_conversation_message_v2(p_message_id uuid, p_old_content text, p_new_content text)
returns void
language plpgsql security definer set search_path to 'public'
as $$
declare v_identity record; v_count integer;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then raise exception 'CONVERSATION_UNAUTHENTICATED'; end if;
  if nullif(trim(p_new_content),'') is null then raise exception 'CONVERSATION_INVALID_CONTENT'; end if;
  update public.conversations set content=trim(p_new_content) where message_id=p_message_id and account_id=v_identity.account_id and sh_id=v_identity.sh_id and content=p_old_content;
  get diagnostics v_count=row_count;
  if v_count<>1 then raise exception 'CONVERSATION_MESSAGE_NOT_FOUND_OR_CHANGED'; end if;
  update public.conversation_threads t set updated_at=now() where t.conversation_id=(select c.thread_id from public.conversations c where c.message_id=p_message_id);
end;
$$;

create or replace function public.runtime_delete_conversation_message_v2(p_message_id uuid)
returns void
language plpgsql security definer set search_path to 'public'
as $$
declare v_identity record; v_thread uuid; v_count integer;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then raise exception 'CONVERSATION_UNAUTHENTICATED'; end if;
  select c.thread_id into v_thread from public.conversations c where c.message_id=p_message_id and c.account_id=v_identity.account_id and c.sh_id=v_identity.sh_id;
  if v_thread is null then raise exception 'CONVERSATION_MESSAGE_NOT_FOUND'; end if;
  delete from public.conversations where message_id=p_message_id and account_id=v_identity.account_id and sh_id=v_identity.sh_id;
  get diagnostics v_count=row_count;
  if v_count<>1 then raise exception 'CONVERSATION_MESSAGE_NOT_FOUND'; end if;
  update public.conversation_threads set updated_at=now() where conversation_id=v_thread;
end;
$$;

create or replace function public.runtime_delete_conversation_thread(p_conversation_id uuid)
returns void
language plpgsql security definer set search_path to 'public'
as $$
declare v_identity record; v_count integer;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then raise exception 'CONVERSATION_UNAUTHENTICATED'; end if;
  delete from public.conversation_threads where conversation_id=p_conversation_id and account_id=v_identity.account_id and sh_id=v_identity.sh_id;
  get diagnostics v_count=row_count;
  if v_count<>1 then raise exception 'CONVERSATION_NOT_FOUND'; end if;
end;
$$;

drop function public.runtime_load_conversation(integer);
create function public.runtime_load_conversation(p_limit integer default 50)
returns table(conversation_id uuid, account_id uuid, sh_id uuid, project_id uuid, title text, created_at timestamptz, updated_at timestamptz, preview text)
language plpgsql security definer set search_path to 'public'
as $$
begin return query select * from public.runtime_list_conversations() limit greatest(1,least(coalesce(p_limit,50),100)); end;
$$;
