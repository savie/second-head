create or replace function public.ensure_conversation_message_thread()
returns trigger
language plpgsql security definer set search_path to 'public'
as $$
declare v_thread uuid;
begin
  if new.message_id is null then new.message_id := gen_random_uuid(); end if;
  if new.thread_id is null then
    select t.conversation_id into v_thread
    from public.conversation_threads t
    where t.account_id=new.account_id and t.sh_id=new.sh_id
    order by t.updated_at desc, t.conversation_id desc
    limit 1;
    if v_thread is null then
      insert into public.conversation_threads(account_id,sh_id,title)
      values(new.account_id,new.sh_id,'New Conversation') returning conversation_id into v_thread;
    end if;
    new.thread_id := v_thread;
  end if;
  return new;
end;
$$;

drop trigger if exists conversations_assign_thread on public.conversations;
create trigger conversations_assign_thread
before insert on public.conversations
for each row execute function public.ensure_conversation_message_thread();

create or replace function public.touch_conversation_thread()
returns trigger
language plpgsql security definer set search_path to 'public'
as $$
begin
  update public.conversation_threads set updated_at=now() where conversation_id=new.thread_id;
  return new;
end;
$$;

drop trigger if exists conversations_touch_thread on public.conversations;
create trigger conversations_touch_thread
after insert or update on public.conversations
for each row execute function public.touch_conversation_thread();
