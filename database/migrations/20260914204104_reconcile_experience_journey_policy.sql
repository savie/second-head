create or replace function public.runtime_classify_experience(p_experience_id uuid, p_scope text, p_visibility text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare v_id uuid; v_sh_id uuid;
begin
  if auth.uid() is null then raise exception 'EXPERIENCE_CLASSIFICATION_REJECTED: authentication required'; end if;
  if p_scope not in ('PRIVATE','GENERAL') then raise exception 'EXPERIENCE_CLASSIFICATION_REJECTED: invalid scope'; end if;
  if p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'EXPERIENCE_CLASSIFICATION_REJECTED: invalid visibility'; end if;
  select e.experience_id,e.sh_id into v_id,v_sh_id from public.experiences e where e.experience_id=p_experience_id and e.account_id=public.current_account_id() and e.lifecycle='ACTIVE';
  if v_id is null then raise exception 'EXPERIENCE_CLASSIFICATION_REJECTED: Experience not owned by current active account'; end if;
  update public.experiences set scope=p_scope,visibility=p_visibility,updated_at=now() where experience_id=v_id;
  update public.journey_events
     set visibility=case when p_visibility='SHARED' then 'SHARED' else 'PRIVATE' end,
         provenance=coalesce(provenance,'{}'::jsonb)||jsonb_build_object('policy_source','canonical_experience')
   where sh_id=v_sh_id and payload->>'experience_id'=v_id::text;
  return v_id;
end;
$$;
revoke all on function public.runtime_classify_experience(uuid,text,text) from public, anon, authenticated;
grant execute on function public.runtime_classify_experience(uuid,text,text) to authenticated;
