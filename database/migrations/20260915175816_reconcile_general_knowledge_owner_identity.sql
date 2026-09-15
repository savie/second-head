BEGIN;

WITH owner_candidates AS (
  SELECT
    k.knowledge_id,
    (array_agg(j.sh_id ORDER BY j.sh_id))[1] AS sh_id
  FROM public.knowledge k
  JOIN public.journey_events j
    ON j.event_type = 'LEARNING'
   AND j.payload->>'knowledge_id' = k.knowledge_id::text
  WHERE k.sh_id IS NULL
    AND k.scope = 'GENERAL'
    AND k.visibility = 'SHARED'
  GROUP BY k.knowledge_id
  HAVING count(DISTINCT j.sh_id) = 1
)
UPDATE public.knowledge k
SET sh_id = o.sh_id,
    updated_at = now()
FROM owner_candidates o
WHERE k.knowledge_id = o.knowledge_id;

CREATE OR REPLACE FUNCTION public.runtime_record_knowledge_with_journey(
  p_sh_id uuid,
  p_content text,
  p_source text,
  p_origin text,
  p_provenance jsonb DEFAULT '{}'::jsonb,
  p_scope text DEFAULT 'PRIVATE'::text,
  p_visibility text DEFAULT 'OWNER_ONLY'::text,
  p_confidence numeric DEFAULT NULL::numeric
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare
  v_id uuid;
  v_account_id uuid;
begin
  if auth.uid() is null then
    raise exception 'KNOWLEDGE_REJECTED: authentication required';
  end if;
  select s.account_id into v_account_id
    from public.sh_instances s
   where s.sh_id = p_sh_id
     and s.account_id = public.current_account_id()
     and s.status <> 'deactivated';
  if v_account_id is null then
    raise exception 'KNOWLEDGE_REJECTED: SH not owned by current active account';
  end if;
  if p_content is null or btrim(p_content) = '' then raise exception 'KNOWLEDGE_REJECTED: content is required'; end if;
  if p_source is null or btrim(p_source) = '' then raise exception 'KNOWLEDGE_REJECTED: source is required'; end if;
  if p_origin not in ('MEMORY','EXPLICIT_TEACHING','EXTERNAL_REFERENCE') then raise exception 'KNOWLEDGE_REJECTED: invalid origin'; end if;
  if p_scope not in ('PRIVATE','GENERAL') then raise exception 'KNOWLEDGE_REJECTED: invalid scope'; end if;
  if p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'KNOWLEDGE_REJECTED: invalid visibility'; end if;
  if p_scope = 'GENERAL' and p_visibility <> 'SHARED' then raise exception 'KNOWLEDGE_REVIEW_REQUIRED: GENERAL scope requires SHARED visibility'; end if;
  if p_confidence is not null and (p_confidence < 0 or p_confidence > 1) then raise exception 'KNOWLEDGE_REJECTED: invalid confidence'; end if;

  select knowledge_id into v_id
    from public.knowledge
   where sh_id = p_sh_id
     and content = btrim(p_content)
     and lifecycle = 'CANDIDATE'
   order by updated_at desc
   limit 1
   for update;

  if v_id is not null then
    update public.knowledge
       set confidence = coalesce(p_confidence, confidence),
           provenance = coalesce(provenance, '{}') || coalesce(p_provenance, '{}'),
           updated_at = now()
     where knowledge_id = v_id;
  else
    insert into public.knowledge(content,knowledge_class,scope,visibility,source,provenance,confidence,lifecycle,sh_id)
    values(
      btrim(p_content),
      case p_origin when 'EXPLICIT_TEACHING' then 'LEARNED' when 'EXTERNAL_REFERENCE' then 'IMPORTED' else 'TEMPORARY' end,
      p_scope,
      p_visibility,
      btrim(p_source),
      coalesce(p_provenance, '{}') || jsonb_build_object('origin', p_origin, 'acquisition', 'runtime:p4d:knowledge_candidate'),
      p_confidence,
      'CANDIDATE',
      p_sh_id
    ) returning knowledge_id into v_id;
  end if;

  perform public.runtime_record_journey_event(
    p_sh_id,'LEARNING',now(),'CONTINUOUS',null,
    jsonb_build_object('knowledge_id',v_id,'content',btrim(p_content),'source',btrim(p_source),'origin',p_origin,'scope',p_scope,'visibility',p_visibility,'acquisition','MODEL_OR_EXPLICIT_CANDIDATE'),
    btrim(p_source)
  );
  return v_id;
end;
$$;

CREATE OR REPLACE FUNCTION public.runtime_classify_knowledge(
  p_knowledge_id uuid,
  p_scope text,
  p_visibility text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
declare
  v_account_id uuid;
  v_sh_id uuid;
begin
  if auth.uid() is null then raise exception 'KNOWLEDGE_CLASSIFY_REJECTED: authentication required'; end if;
  if p_scope not in ('PRIVATE','GENERAL') then raise exception 'KNOWLEDGE_CLASSIFY_REJECTED: invalid scope'; end if;
  if p_visibility not in ('OWNER_ONLY','SHARED') then raise exception 'KNOWLEDGE_CLASSIFY_REJECTED: invalid visibility'; end if;
  if p_scope = 'GENERAL' and p_visibility <> 'SHARED' then raise exception 'KNOWLEDGE_CLASSIFY_REJECTED: GENERAL scope requires SHARED visibility'; end if;

  select k.sh_id, s.account_id into v_sh_id, v_account_id
    from public.knowledge k
    join public.sh_instances s on s.sh_id = k.sh_id
   where k.knowledge_id = p_knowledge_id
     and s.account_id = public.current_account_id()
     and s.status <> 'deactivated';
  if v_account_id is null then raise exception 'KNOWLEDGE_CLASSIFY_REJECTED: knowledge not owned by current account'; end if;

  perform public.runtime_assert_semantic_write_allowed('KNOWLEDGE', p_knowledge_id);
  update public.knowledge set scope=p_scope, visibility=p_visibility, sh_id=v_sh_id, updated_at=now() where knowledge_id=p_knowledge_id;
  update public.journey_events
     set visibility=case when p_visibility='SHARED' then 'SHARED' else 'PRIVATE' end,
         provenance=coalesce(provenance,'{}'::jsonb)||jsonb_build_object('policy_source','canonical_knowledge')
   where sh_id=v_sh_id and payload->>'knowledge_id'=p_knowledge_id::text;
end;
$$;

REVOKE ALL ON FUNCTION public.runtime_record_knowledge_with_journey(uuid,text,text,text,jsonb,text,text,numeric) FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.runtime_record_knowledge_with_journey(uuid,text,text,text,jsonb,text,text,numeric) TO authenticated;
REVOKE ALL ON FUNCTION public.runtime_classify_knowledge(uuid,text,text) FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.runtime_classify_knowledge(uuid,text,text) TO authenticated;

COMMIT;