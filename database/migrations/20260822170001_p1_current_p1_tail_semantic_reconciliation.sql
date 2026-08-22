-- SECOND HEAD — canonical reconciliation of live P1 tail semantics.
-- Historical Supabase migration versions are preserved as immutable evidence.
-- This migration is intentionally a new canonical replay artifact; it does not
-- fabricate or rename the historical Supabase migration IDs.

-- INHERITABLE is accepted as a compatibility input but canonical persistence is INHERITANCE.
CREATE OR REPLACE FUNCTION public.runtime_record_experience(
  p_sh_id uuid,
  p_experience_type text,
  p_content text,
  p_scope text DEFAULT 'PRIVATE'::text,
  p_visibility text DEFAULT 'OWNER_ONLY'::text,
  p_transfer_policy text DEFAULT 'NON_TRANSFERABLE'::text,
  p_source_ref text DEFAULT NULL::text,
  p_provenance jsonb DEFAULT '{}'::jsonb,
  p_occurred_at timestamp with time zone DEFAULT now()
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_account_id uuid;
  v_experience_id uuid;
  v_policy text := upper(p_transfer_policy);
begin
  if auth.uid() is null then raise exception 'EXPERIENCE_REJECTED: authentication required'; end if;
  if p_scope not in ('PRIVATE','GENERAL') then raise exception 'EXPERIENCE_REJECTED: invalid scope'; end if;
  if p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'EXPERIENCE_REJECTED: invalid visibility'; end if;
  if v_policy='INHERITABLE' then v_policy:='INHERITANCE'; end if;
  if v_policy not in ('NON_TRANSFERABLE','INHERITANCE','SUCCESSION','LEGACY') then raise exception 'EXPERIENCE_REJECTED: invalid transfer policy'; end if;
  select s.account_id into v_account_id from public.sh_instances s where s.sh_id=p_sh_id and s.account_id=public.current_account_id() and s.status<>'deactivated';
  if v_account_id is null then raise exception 'EXPERIENCE_REJECTED: SH not owned by current active account'; end if;
  insert into public.experiences(sh_id,account_id,experience_type,content,scope,visibility,transfer_policy,source_ref,provenance,lifecycle,occurred_at,created_at,updated_at)
  values(p_sh_id,v_account_id,p_experience_type,p_content,p_scope,p_visibility,v_policy,p_source_ref,coalesce(p_provenance,'{}'::jsonb),'ACTIVE',coalesce(p_occurred_at,now()),now(),now())
  returning experience_id into v_experience_id;
  return v_experience_id;
end;
$function$;

-- Internal lifecycle assertion: no direct client execution.
REVOKE EXECUTE ON FUNCTION public.runtime_assert_active_sh(uuid,text) FROM authenticated;
REVOKE EXECUTE ON FUNCTION public.runtime_assert_active_sh(uuid,text) FROM anon;
REVOKE EXECUTE ON FUNCTION public.runtime_assert_active_sh(uuid,text) FROM public;

-- Journey shared helper remains callable by authenticated because it is an RLS visibility dependency.
REVOKE EXECUTE ON FUNCTION public.runtime_journey_event_is_shared(uuid) FROM anon;
REVOKE EXECUTE ON FUNCTION public.runtime_journey_event_is_shared(uuid) FROM public;
GRANT EXECUTE ON FUNCTION public.runtime_journey_event_is_shared(uuid) TO authenticated;

-- Inheritance revoke cleanup is provenance-scoped and includes Journey.
CREATE OR REPLACE FUNCTION public.runtime_revoke_inheritance_authorization(p_authorization_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare v_auth public.inheritance_authorizations%rowtype;
begin
  if auth.uid() is null then raise exception 'INHERITANCE_REVOKE_REJECTED: authentication required'; end if;
  select * into v_auth from public.inheritance_authorizations where authorization_id=p_authorization_id for update;
  if not found then raise exception 'INHERITANCE_REVOKE_REJECTED: authorization not found'; end if;
  if v_auth.source_account_id<>public.current_account_id() then raise exception 'INHERITANCE_REVOKE_REJECTED: source owner required'; end if;
  if v_auth.status not in ('APPROVED','CONSUMED') then raise exception 'INHERITANCE_REVOKE_REJECTED: authorization not revocable'; end if;
  delete from public.memories m where coalesce(m.provenance,'{}'::jsonb)->'inheritance_origin'->>'authorization_id'=p_authorization_id::text;
  delete from public.knowledge k where coalesce(k.provenance,'{}'::jsonb)->'inheritance_origin'->>'authorization_id'=p_authorization_id::text;
  delete from public.experiences e where coalesce(e.provenance,'{}'::jsonb)->'inheritance_origin'->>'authorization_id'=p_authorization_id::text;
  delete from public.journey_events j where coalesce(j.provenance,'{}'::jsonb)->>'transfer_operation'='INHERITANCE' and coalesce(j.provenance,'{}'::jsonb)->>'authorization_id'=p_authorization_id::text;
  update public.inheritance_authorizations set status='REVOKED', revoked_at=now() where authorization_id=p_authorization_id;
end;
$function$;

-- Clone revoke cleanup is provenance-scoped and idempotent at the agreement level.
CREATE OR REPLACE FUNCTION public.runtime_revoke_clone_agreement(p_agreement_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
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
  select * into v_agreement from public.clone_agreements where agreement_id=p_agreement_id and source_account_id=v_account_id for update;
  if not found then raise exception 'CLONE_REVOKE_REJECTED: source owner or agreement not found'; end if;
  if v_agreement.revoked_at is not null then return jsonb_build_object('status','ALREADY_REVOKED','agreement_id',p_agreement_id); end if;
  select clone_sh_id into v_clone_sh_id from public.sh_clones where agreement_id=p_agreement_id for update;
  update public.clone_agreements set revoked_at=v_now,status='REVOKED' where agreement_id=p_agreement_id;
  if v_clone_sh_id is not null then
    delete from public.memories where sh_id=v_clone_sh_id and provenance @> jsonb_build_object('clone_origin',jsonb_build_object('agreement_id',p_agreement_id));
    get diagnostics v_deleted_memories=row_count;
    delete from public.knowledge where sh_id=v_clone_sh_id and provenance @> jsonb_build_object('clone_origin',jsonb_build_object('agreement_id',p_agreement_id));
    get diagnostics v_deleted_knowledge=row_count;
    delete from public.experiences where sh_id=v_clone_sh_id and provenance @> jsonb_build_object('clone_origin',jsonb_build_object('agreement_id',p_agreement_id));
    get diagnostics v_deleted_experiences=row_count;
    update public.sh_clones set status='REVOKED',revoked_at=v_now where agreement_id=p_agreement_id;
  end if;
  return jsonb_build_object('status','REVOKED','agreement_id',p_agreement_id,'clone_sh_id',v_clone_sh_id,'deleted_memories',v_deleted_memories,'deleted_knowledge',v_deleted_knowledge,'deleted_experiences',v_deleted_experiences);
end;
$function$;
