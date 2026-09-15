UPDATE public.journey_events j
SET visibility = CASE
  WHEN k.visibility = 'SHARED' THEN 'SHARED'
  ELSE 'PRIVATE'
END,
provenance = coalesce(j.provenance, '{}'::jsonb)
  || jsonb_build_object('policy_source', 'canonical_knowledge')
FROM public.knowledge k
WHERE j.event_type = 'LEARNING'
  AND j.sh_id = k.sh_id
  AND j.payload->>'knowledge_id' = k.knowledge_id::text
  AND k.sh_id IS NOT NULL;