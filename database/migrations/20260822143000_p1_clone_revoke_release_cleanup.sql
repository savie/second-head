-- P1: Clone agreement revoke/release cleanup.
-- Source-owner initiated. Removes only target-derived records carrying this agreement's provenance.
-- Source SH records remain untouched.

create or replace function public.runtime_revoke_clone_agreement(p_agreement_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account_id uuid;
  v_agreement public.clone_agreements%rowtype;
  v_clone_sh_id uuid;
  v_now timestamptz := now();
  v_deleted_memories bigint := 0;
  v_deleted_knowledge bigint := 0;
  v_deleted_experiences bigint := 0;
begin
  if auth.uid() is null then raise exception 'CLONE_REVOKE_REJECTED: authentication required'; end if;
  v_account_id := public.current_account_id();
  if v_account_id is null then raise exception 'CLONE_REVOKE_REJECTED: authenticated account not resolved'; end if;

  select * into v_agreement
  from public.clone_agreements
  where agreement_id = p_agreement_id
    and source_account_id = v_account_id
  for update;

  if not found then raise exception 'CLONE_REVOKE_REJECTED: source owner or agreement not found'; end if;
  if v_agreement.revoked_at is not null then
    return jsonb_build_object('status','ALREADY_REVOKED','agreement_id',p_agreement_id);
  end if;

  select clone_sh_id into v_clone_sh_id
  from public.sh_clones
  where agreement_id = p_agreement_id
  for update;

  update public.clone_agreements
     set revoked_at = v_now,
         status = 'REVOKED'
   where agreement_id = p_agreement_id;

  if v_clone_sh_id is not null then
    delete from public.memories
     where sh_id = v_clone_sh_id
       and provenance @> jsonb_build_object('clone_origin', jsonb_build_object('agreement_id', p_agreement_id));
    get diagnostics v_deleted_memories = row_count;

    delete from public.knowledge
     where sh_id = v_clone_sh_id
       and provenance @> jsonb_build_object('clone_origin', jsonb_build_object('agreement_id', p_agreement_id));
    get diagnostics v_deleted_knowledge = row_count;

    delete from public.experiences
     where sh_id = v_clone_sh_id
       and provenance @> jsonb_build_object('clone_origin', jsonb_build_object('agreement_id', p_agreement_id));
    get diagnostics v_deleted_experiences = row_count;

    update public.sh_clones
       set status = 'REVOKED', revoked_at = v_now
     where agreement_id = p_agreement_id;
  end if;

  return jsonb_build_object('status','REVOKED','agreement_id',p_agreement_id,'clone_sh_id',v_clone_sh_id,'deleted_memories',v_deleted_memories,'deleted_knowledge',v_deleted_knowledge,'deleted_experiences',v_deleted_experiences);
end;
$$;

revoke all on function public.runtime_revoke_clone_agreement(uuid) from public;
revoke all on function public.runtime_revoke_clone_agreement(uuid) from anon;
revoke all on function public.runtime_revoke_clone_agreement(uuid) from authenticated;
grant execute on function public.runtime_revoke_clone_agreement(uuid) to authenticated;
