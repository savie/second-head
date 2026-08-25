-- SECOND HEAD — expose Experience transfer policy in the existing owner detail/list retrieval path.
-- Privacy/visibility and transfer policy remain independent semantics.
-- PostgreSQL requires replacement of the existing function because the OUT parameter shape changes.

drop function if exists public.list_experiences(uuid,integer);

create function public.list_experiences(
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
  transfer_policy text,
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
         e.scope, e.visibility, e.transfer_policy, e.source_ref, e.provenance, e.lifecycle,
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

comment on function public.list_experiences(uuid,integer) is 'Owner-scoped Experience retrieval including privacy and transfer policy.';
