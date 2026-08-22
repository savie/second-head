-- SECOND HEAD — generic Legacy record creation is terminal-lifecycle only.
CREATE OR REPLACE FUNCTION public.runtime_record_legacy(
  p_source_sh_id uuid,
  p_legacy_type text,
  p_payload jsonb DEFAULT '{}'::jsonb,
  p_provenance jsonb DEFAULT '{}'::jsonb,
  p_retention_until timestamptz DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare v_id uuid;
begin
  if auth.uid() is null then raise exception 'LEGACY_REJECTED: authentication required'; end if;
  if not exists (
    select 1 from public.sh_instances s
    where s.sh_id=p_source_sh_id
      and s.account_id=current_account_id()
      and s.status='deactivated'
  ) then raise exception 'LEGACY_REJECTED: source SH must be end-of-life'; end if;
  if p_legacy_type not in ('MEMORY','KNOWLEDGE','EXPERIENCE','JOURNEY','HISTORY','VALUE','REFERENCE') then raise exception 'LEGACY_REJECTED: invalid legacy_type'; end if;
  insert into public.legacy_records(source_sh_id,legacy_type,payload,provenance,retention_until)
  values(p_source_sh_id,p_legacy_type,coalesce(p_payload,'{}'::jsonb),coalesce(p_provenance,'{}'::jsonb),p_retention_until)
  returning legacy_id into v_id;
  insert into public.journey_events(sh_id,account_id,event_type,occurred_at,continuity_status,payload,source_ref)
  values(p_source_sh_id,current_account_id(),'LEGACY',now(),'CONTINUOUS',jsonb_build_object('legacy_id',v_id,'legacy_type',p_legacy_type,'retention_until',p_retention_until,'payload',coalesce(p_payload,'{}'::jsonb),'provenance',coalesce(p_provenance,'{}'::jsonb)),'legacy_record:'||v_id::text);
  return v_id;
end;
$function$;
