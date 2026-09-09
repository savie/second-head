create or replace function public.runtime_record_conversation_message_v2(
  p_conversation_id uuid,
  p_message_id uuid,
  p_created_at timestamptz,
  p_role text,
  p_content text,
  p_metadata jsonb default '{}'::jsonb
)
returns public.conversations
language plpgsql
security definer
set search_path to 'public'
as $$
declare
  v_identity record;
  v_row public.conversations;
  v_existing public.conversations;
begin
  select * into v_identity from public.resolve_identity();
  if v_identity.account_id is null or v_identity.sh_id is null then
    raise exception 'CONVERSATION_UNAUTHENTICATED';
  end if;
  if p_message_id is null then raise exception 'CONVERSATION_MESSAGE_ID_REQUIRED'; end if;
  if p_created_at is null then raise exception 'CONVERSATION_CREATED_AT_REQUIRED'; end if;
  if not exists(
    select 1 from public.conversation_threads t
    where t.conversation_id=p_conversation_id
      and t.account_id=v_identity.account_id
      and t.sh_id=v_identity.sh_id
  ) then raise exception 'CONVERSATION_ACCESS_DENIED'; end if;
  if p_role not in ('user','assistant','system') then raise exception 'CONVERSATION_INVALID_ROLE'; end if;
  if p_content is null or length(trim(p_content))=0 then raise exception 'CONVERSATION_INVALID_CONTENT'; end if;

  select * into v_existing
  from public.conversations c
  where c.message_id=p_message_id
    and c.account_id=v_identity.account_id
    and c.sh_id=v_identity.sh_id;

  if found then
    if v_existing.thread_id <> p_conversation_id
       or v_existing.role <> p_role
       or v_existing.content <> p_content
       or v_existing.created_at <> p_created_at
       or v_existing.metadata <> coalesce(p_metadata,'{}'::jsonb) then
      raise exception 'CONVERSATION_MESSAGE_ID_CONFLICT';
    end if;
    return v_existing;
  end if;

  insert into public.conversations(
    message_id,
    account_id,
    sh_id,
    thread_id,
    role,
    content,
    created_at,
    metadata
  ) values (
    p_message_id,
    v_identity.account_id,
    v_identity.sh_id,
    p_conversation_id,
    p_role,
    p_content,
    p_created_at,
    coalesce(p_metadata,'{}'::jsonb)
  ) returning * into v_row;

  update public.conversation_threads
  set updated_at=now()
  where conversation_id=p_conversation_id;

  return v_row;
end;
$$;

revoke execute on function public.runtime_record_conversation_message_v2(uuid, uuid, timestamptz, text, text, jsonb) from anon, public;
grant execute on function public.runtime_record_conversation_message_v2(uuid, uuid, timestamptz, text, text, jsonb) to authenticated;
