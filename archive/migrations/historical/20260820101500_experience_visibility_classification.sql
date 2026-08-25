-- SECOND HEAD — explicit Experience privacy classification after supported capture.
-- Capture remains owner-authenticated; classification is explicit and never inferred from prose.

create or replace function public.runtime_classify_experience(
  p_experience_id uuid,
  p_scope text,
  p_visibility text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare v_id uuid;
begin
  if auth.uid() is null then raise exception 'EXPERIENCE_CLASSIFICATION_REJECTED: authentication required'; end if;
  if p_scope not in ('PRIVATE','GENERAL') then raise exception 'EXPERIENCE_CLASSIFICATION_REJECTED: invalid scope'; end if;
  if p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'EXPERIENCE_CLASSIFICATION_REJECTED: invalid visibility'; end if;
  update public.experiences
     set scope = p_scope, visibility = p_visibility, updated_at = now()
   where experience_id = p_experience_id
     and account_id = public.current_account_id()
     and lifecycle = 'ACTIVE'
   returning experience_id into v_id;
  if v_id is null then raise exception 'EXPERIENCE_CLASSIFICATION_REJECTED: Experience not owned by current active account'; end if;
  return v_id;
end;
$$;
revoke all on function public.runtime_classify_experience(uuid,text,text) from public;
grant execute on function public.runtime_classify_experience(uuid,text,text) to authenticated;
