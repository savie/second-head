create or replace function public.list_experience_context(
  p_sh_id uuid default null,
  p_limit integer default 50
)
returns table(
  experience_id uuid,
  sh_id uuid,
  account_id uuid,
  experience_type text,
  content text,
  scope text,
  visibility text,
  source_ref text,
  provenance jsonb,
  lifecycle text,
  occurred_at timestamptz,
  created_at timestamptz,
  updated_at timestamptz
)
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'EXPERIENCE_CONTEXT_RETRIEVAL_REJECTED: authentication required';
  end if;
  if p_limit is null or p_limit < 1 or p_limit > 100 then
    raise exception 'EXPERIENCE_CONTEXT_RETRIEVAL_REJECTED: invalid limit';
  end if;

  return query
  select e.experience_id, e.sh_id, e.account_id, e.experience_type, e.content,
         e.scope, e.visibility, e.source_ref, e.provenance, e.lifecycle,
         e.occurred_at, e.created_at, e.updated_at
  from public.experiences e
  where (
    p_sh_id is null
    and e.account_id = public.current_account_id()
  )
  or (
    p_sh_id is not null
    and e.sh_id = p_sh_id
    and e.account_id = public.current_account_id()
  )
  or (
    e.scope = 'GENERAL'
    and e.visibility = 'SHARED'
  )
  order by e.occurred_at desc, e.created_at desc
  limit p_limit;
end;
$$;
