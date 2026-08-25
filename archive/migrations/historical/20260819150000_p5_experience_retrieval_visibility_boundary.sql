-- SECOND HEAD P5 — Experience retrieval / visibility boundary
-- Adds the owner-scoped retrieval path required by the Experience domain.

create or replace function public.list_experiences(
  p_sh_id uuid default null,
  p_limit integer default 50
)
returns table (
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
    raise exception 'EXPERIENCE_RETRIEVAL_REJECTED: authentication required';
  end if;
  if p_limit is null or p_limit < 1 or p_limit > 100 then
    raise exception 'EXPERIENCE_RETRIEVAL_REJECTED: invalid limit';
  end if;
  return query
  select e.experience_id, e.sh_id, e.account_id, e.experience_type, e.content,
         e.scope, e.visibility, e.source_ref, e.provenance, e.lifecycle,
         e.occurred_at, e.created_at, e.updated_at
  from public.experiences e
  where e.account_id = public.current_account_id()
    and (p_sh_id is null or e.sh_id = p_sh_id)
  order by e.occurred_at desc, e.created_at desc
  limit p_limit;
end;
$$;

revoke all on function public.list_experiences(uuid,integer) from public;
grant execute on function public.list_experiences(uuid,integer) to authenticated;

create or replace function public.get_experience(p_experience_id uuid)
returns public.experiences
language plpgsql
security definer
set search_path = public
as $$
declare v public.experiences;
begin
  if auth.uid() is null then
    raise exception 'EXPERIENCE_RETRIEVAL_REJECTED: authentication required';
  end if;
  select e.* into v
  from public.experiences e
  where e.experience_id = p_experience_id
    and e.account_id = public.current_account_id();
  if v.experience_id is null then
    raise exception 'EXPERIENCE_RETRIEVAL_REJECTED: experience not accessible';
  end if;
  return v;
end;
$$;

revoke all on function public.get_experience(uuid) from public;
grant execute on function public.get_experience(uuid) to authenticated;

comment on function public.list_experiences(uuid,integer) is 'Owner-scoped Experience retrieval.';
comment on function public.get_experience(uuid) is 'Owner-scoped single Experience retrieval.';
