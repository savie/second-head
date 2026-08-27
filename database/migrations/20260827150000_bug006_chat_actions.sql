-- BUG-006: authenticated conversation action persistence.
create or replace function public.runtime_update_conversation_message(
  p_conversation_id uuid,
  p_created_at timestamptz,
  p_role text,
  p_old_content text,
  p_new_content text
) returns void
language plpgsql security definer set search_path=public as $$
declare v_sh_id uuid; v_account_id uuid; v_count integer;
begin
  if auth.uid() is null then raise exception 'CONVERSATION_UPDATE_REJECTED: authentication required'; end if;
  if p_conversation_id is null or p_created_at is null or nullif(trim(p_new_content),'') is null then
    raise exception 'CONVERSATION_UPDATE_REJECTED: invalid message target or content';
  end if;
  select c.sh_id into v_sh_id from public.conversations c where c.conversation_id=p_conversation_id limit 1;
  if v_sh_id is null then raise exception 'CONVERSATION_UPDATE_REJECTED: conversation not found'; end if;
  select s.account_id into v_account_id from public.sh_instances s where s.sh_id=v_sh_id and s.account_id=public.current_account_id() and s.status<>'deactivated';
  if v_account_id is null then raise exception 'CONVERSATION_UPDATE_REJECTED: conversation not owned by current active account'; end if;
  update public.conversations
     set content=trim(p_new_content)
   where conversation_id=p_conversation_id and sh_id=v_sh_id and created_at=p_created_at and role=p_role and content=p_old_content;
  get diagnostics v_count = row_count;
  if v_count <> 1 then raise exception 'CONVERSATION_UPDATE_REJECTED: message not found or changed'; end if;
end; $$;

create or replace function public.runtime_delete_conversation_message(
  p_conversation_id uuid,
  p_created_at timestamptz,
  p_role text,
  p_content text
) returns void
language plpgsql security definer set search_path=public as $$
declare v_sh_id uuid; v_account_id uuid; v_count integer;
begin
  if auth.uid() is null then raise exception 'CONVERSATION_DELETE_REJECTED: authentication required'; end if;
  select c.sh_id into v_sh_id from public.conversations c where c.conversation_id=p_conversation_id limit 1;
  if v_sh_id is null then raise exception 'CONVERSATION_DELETE_REJECTED: conversation not found'; end if;
  select s.account_id into v_account_id from public.sh_instances s where s.sh_id=v_sh_id and s.account_id=public.current_account_id() and s.status<>'deactivated';
  if v_account_id is null then raise exception 'CONVERSATION_DELETE_REJECTED: conversation not owned by current active account'; end if;
  delete from public.conversations where conversation_id=p_conversation_id and sh_id=v_sh_id and created_at=p_created_at and role=p_role and content=p_content;
  get diagnostics v_count = row_count;
  if v_count <> 1 then raise exception 'CONVERSATION_DELETE_REJECTED: message not found or changed'; end if;
end; $$;

create or replace function public.runtime_delete_conversation(
  p_conversation_id uuid
) returns void
language plpgsql security definer set search_path=public as $$
declare v_sh_id uuid; v_account_id uuid;
begin
  if auth.uid() is null then raise exception 'CONVERSATION_DELETE_REJECTED: authentication required'; end if;
  select c.sh_id into v_sh_id from public.conversations c where c.conversation_id=p_conversation_id limit 1;
  if v_sh_id is null then raise exception 'CONVERSATION_DELETE_REJECTED: conversation not found'; end if;
  select s.account_id into v_account_id from public.sh_instances s where s.sh_id=v_sh_id and s.account_id=public.current_account_id() and s.status<>'deactivated';
  if v_account_id is null then raise exception 'CONVERSATION_DELETE_REJECTED: conversation not owned by current active account'; end if;
  delete from public.conversations where conversation_id=p_conversation_id and sh_id=v_sh_id;
end; $$;

create or replace function public.runtime_rename_conversation(
  p_conversation_id uuid,
  p_title text
) returns void
language plpgsql security definer set search_path=public as $$
declare v_sh_id uuid; v_account_id uuid; v_count integer;
begin
  if auth.uid() is null then raise exception 'CONVERSATION_RENAME_REJECTED: authentication required'; end if;
  if nullif(trim(p_title),'') is null then raise exception 'CONVERSATION_RENAME_REJECTED: title required'; end if;
  select c.sh_id into v_sh_id from public.conversations c where c.conversation_id=p_conversation_id limit 1;
  if v_sh_id is null then raise exception 'CONVERSATION_RENAME_REJECTED: conversation not found'; end if;
  select s.account_id into v_account_id from public.sh_instances s where s.sh_id=v_sh_id and s.account_id=public.current_account_id() and s.status<>'deactivated';
  if v_account_id is null then raise exception 'CONVERSATION_RENAME_REJECTED: conversation not owned by current active account'; end if;
  update public.conversations
     set metadata = coalesce(metadata,'{}'::jsonb) || jsonb_build_object('conversation_title', trim(p_title))
   where conversation_id=p_conversation_id and sh_id=v_sh_id;
  get diagnostics v_count = row_count;
  if v_count < 1 then raise exception 'CONVERSATION_RENAME_REJECTED: conversation not found'; end if;
end; $$;

revoke all on function public.runtime_update_conversation_message(uuid,timestamptz,text,text,text) from public,anon;
grant execute on function public.runtime_update_conversation_message(uuid,timestamptz,text,text,text) to authenticated;
revoke all on function public.runtime_delete_conversation_message(uuid,timestamptz,text,text) from public,anon;
grant execute on function public.runtime_delete_conversation_message(uuid,timestamptz,text,text) to authenticated;
revoke all on function public.runtime_delete_conversation(uuid) from public,anon;
grant execute on function public.runtime_delete_conversation(uuid) to authenticated;
revoke all on function public.runtime_rename_conversation(uuid,text) from public,anon;
grant execute on function public.runtime_rename_conversation(uuid,text) to authenticated;
