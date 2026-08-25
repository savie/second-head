-- P5A: reconcile semantic Journey event-type aliases at the persistence boundary.
-- Runtime semantic candidates may use concise descriptive aliases (for example
-- MEMORY_RELATIONSHIP). Preserve the original candidate in payload and normalize
-- recognized memory/knowledge aliases to canonical Journey event types.

CREATE OR REPLACE FUNCTION public.runtime_record_journey_event(
  p_sh_id uuid,
  p_event_type text,
  p_occurred_at timestamp with time zone DEFAULT now(),
  p_continuity_status text DEFAULT 'CONTINUOUS'::text,
  p_gap_code text DEFAULT NULL::text,
  p_payload jsonb DEFAULT '{}'::jsonb,
  p_source_ref text DEFAULT NULL::text
)
RETURNS uuid
LANGUAGE plpgsql
SET search_path TO 'public'
AS $function$
declare
  v_event_id uuid;
  v_account_id uuid;
  v_event_type text := upper(nullif(btrim(coalesce(p_event_type,'')),''));
  v_payload jsonb := coalesce(p_payload,'{}'::jsonb);
begin
  select s.account_id into v_account_id
  from public.sh_instances s
  where s.sh_id=p_sh_id and s.account_id=current_account_id();

  if v_account_id is null then
    raise exception 'JOURNEY_REJECTED: SH not owned by current account';
  end if;

  if v_event_type not in ('LIFECYCLE','EXPERIENCE','MEMORY','LEARNING','EVOLUTION','MIGRATION','RECOVERY','CONTINUITY','SHARING','INHERITANCE','LEGACY') then
    if v_event_type like '%MEMORY%' then
      v_payload := v_payload || jsonb_build_object('candidate_event_type', v_event_type);
      v_event_type := 'MEMORY';
    elsif v_event_type like '%KNOWLEDGE%' or v_event_type like '%LEARNING%' then
      v_payload := v_payload || jsonb_build_object('candidate_event_type', v_event_type);
      v_event_type := 'LEARNING';
    elsif v_event_type in ('DECISION','COMMITMENT','CONTINUATION','TRANSITION','MILESTONE','STATE_CHANGE','STATE-CHANGE')
       or v_event_type like '%DECISION%'
       or v_event_type like '%COMMITMENT%'
       or v_event_type like '%CONTINUATION%'
       or v_event_type like '%TRANSITION%'
       or v_event_type like '%MILESTONE%'
       or v_event_type like '%STATE_CHANGE%'
       or v_event_type like '%STATE-CHANGE%'
       or v_event_type like 'PROJECT_%' then
      v_payload := v_payload || jsonb_build_object('candidate_event_type', v_event_type);
      v_event_type := 'LIFECYCLE';
    else
      raise exception 'JOURNEY_REJECTED: invalid event_type';
    end if;
  end if;

  if p_continuity_status not in ('CONTINUOUS','GAP_DETECTED','GAP_UNRESOLVED','RECOVERED') then
    raise exception 'JOURNEY_REJECTED: invalid continuity_status';
  end if;
  if p_continuity_status in ('GAP_DETECTED','GAP_UNRESOLVED')
     and nullif(btrim(coalesce(p_gap_code,'')),'') is null then
    raise exception 'JOURNEY_REJECTED: gap_code required for continuity gap';
  end if;

  insert into public.journey_events(
    sh_id,account_id,event_type,occurred_at,continuity_status,gap_code,payload,source_ref
  )
  values(
    p_sh_id,v_account_id,v_event_type,coalesce(p_occurred_at,now()),
    p_continuity_status,nullif(btrim(p_gap_code),''),v_payload,nullif(btrim(p_source_ref),'')
  )
  returning event_id into v_event_id;

  return v_event_id;
end;
$function$;
