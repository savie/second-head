do $$
declare
  test_id uuid;
  test_lifecycle text;
begin
  insert into public.knowledge (content, knowledge_class, scope, visibility, source, provenance, confidence, lifecycle)
  values ('P3D-007 synthetic indexing verification','LEARNED','GENERAL','OWNER_ONLY','synthetic-test','{}',0.5,'ACCEPTED')
  returning knowledge_id into test_id;

  update public.knowledge
  set lifecycle='INDEXED', updated_at=now()
  where knowledge_id=test_id;

  select lifecycle into test_lifecycle
  from public.knowledge
  where knowledge_id=test_id;

  if test_lifecycle <> 'INDEXED' then
    raise exception 'P3D-007 verification failed: lifecycle is %', test_lifecycle;
  end if;

  delete from public.knowledge where knowledge_id=test_id;
end $$;
