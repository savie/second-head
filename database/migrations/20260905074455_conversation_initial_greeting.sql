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
  insert into public.conversations(account_id,sh_id,thread_id,role,content,metadata)
  values(v_identity.account_id,v_identity.sh_id,v_id,'assistant','Hi, Savie! 👋\\nHow can I help you today?','{}'::jsonb);
  return v_id;
end;
$$;

create or replace function public.ensure_conversation_message_thread()
returns trigger
language plpgsql security definer set search_path to 'public'
as $$
declare v_thread uuid; v_created boolean := false;
begin
  if new.message_id is null then new.message_id := gen_random_uuid(); end if;
  if new.thread_id is null then
    select t.conversation_id into v_thread from public.conversation_threads t where t.account_id=new.account_id and t.sh_id=new.sh_id order by t.updated_at desc,t.conversation_id desc limit 1;
    if v_thread is null then
      insert into public.conversation_threads(account_id,sh_id,title) values(new.account_id,new.sh_id,'New Conversation') returning conversation_id into v_thread;
      v_created := true;
    end if;
    new.thread_id := v_thread;
  end if;
  return new;
end;
$$;
