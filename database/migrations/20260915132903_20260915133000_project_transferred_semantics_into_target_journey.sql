-- Migration: 20260915133000_project_transferred_semantics_into_target_journey
-- Projects MEMORY, KNOWLEDGE, and EXPERIENCE that have been transferred
-- (via INHERITANCE, SUCCESSION, or LEGACY) into the target SH's journey timeline.
-- Idempotent: duplicate-safe via not exists check on provenance keys.

-- ─────────────────────────────────────────────────────────────────
-- MAIN FUNCTION
-- ─────────────────────────────────────────────────────────────────
create or replace function public.runtime_project_transferred_semantics_into_target_journey(
  p_target_sh_id    uuid,
  p_operation       text,   -- 'INHERITANCE' | 'SUCCESSION' | 'LEGACY'
  p_reference_id    uuid    -- authorization_id / succession_id / legacy_id
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_op              text    := upper(trim(p_operation));
  v_target_account  uuid;
  v_count           integer := 0;
  v_tmp             integer;
begin
  -- validate operation
  if v_op not in ('INHERITANCE', 'SUCCESSION', 'LEGACY') then
    raise exception 'SEMANTIC_PROJECTION_REJECTED: unsupported operation %', p_operation;
  end if;

  -- resolve target account
  select s.account_id into v_target_account
    from public.sh_instances s
   where s.sh_id = p_target_sh_id
     and s.status <> 'deactivated'
   limit 1;

  if v_target_account is null then
    raise exception 'SEMANTIC_PROJECTION_REJECTED: active target SH required';
  end if;

  -- ── MEMORY ──────────────────────────────────────────────────────
  insert into public.journey_events(
    sh_id, account_id, event_type, occurred_at, continuity_status,
    payload, source_ref, visibility, transfer_policy, provenance
  )
  select
    p_target_sh_id,
    v_target_account,
    'MEMORY',
    now(),
    'CONTINUOUS',
    jsonb_build_object(
      'memory_id', m.memory_id,
      'content',   m.content,
      'title',     coalesce(m.content, 'Transferred Memory')
    ),
    'semantic_projection:' || m.memory_id::text,
    'PRIVATE',
    'NON_TRANSFERABLE',
    jsonb_build_object(
      'transfer_operation', v_op,
      'reference_id',       p_reference_id,
      'source_sh_id',       m.sh_id,
      'source_memory_id',   m.memory_id,
      'projected_at',       now()
    )
  from public.memories m
  where m.transfer_policy = v_op
    and m.provenance->>('(' || lower(v_op) || '_origin)') is not null
    and (
      v_op = 'INHERITANCE' and m.provenance->'inheritance_origin'->>'authorization_id' = p_reference_id::text
      or
      v_op = 'SUCCESSION'  and m.provenance->'succession_origin'->>'succession_id'     = p_reference_id::text
      or
      v_op = 'LEGACY'      and m.provenance->'legacy_origin'->>'legacy_id'             = p_reference_id::text
    )
    and not exists (
      select 1 from public.journey_events j
       where j.sh_id      = p_target_sh_id
         and j.event_type = 'MEMORY'
         and j.provenance->>'transfer_operation' = v_op
         and j.provenance->>'reference_id'       = p_reference_id::text
         and j.provenance->>'source_memory_id'   = m.memory_id::text
    );

  get diagnostics v_tmp = row_count;
  v_count := v_count + v_tmp;

  -- ── KNOWLEDGE ───────────────────────────────────────────────────
  insert into public.journey_events(
    sh_id, account_id, event_type, occurred_at, continuity_status,
    payload, source_ref, visibility, transfer_policy, provenance
  )
  select
    p_target_sh_id,
    v_target_account,
    'KNOWLEDGE',
    now(),
    'CONTINUOUS',
    jsonb_build_object(
      'knowledge_id', k.knowledge_id,
      'content',      k.content,
      'title',        coalesce(k.content, 'Transferred Knowledge')
    ),
    'semantic_projection:' || k.knowledge_id::text,
    'PRIVATE',
    'NON_TRANSFERABLE',
    jsonb_build_object(
      'transfer_operation',  v_op,
      'reference_id',        p_reference_id,
      'source_sh_id',        k.sh_id,
      'source_knowledge_id', k.knowledge_id,
      'projected_at',        now()
    )
  from public.knowledge k
  where k.transfer_policy = v_op
    and (
      v_op = 'INHERITANCE' and k.provenance->'inheritance_origin'->>'authorization_id' = p_reference_id::text
      or
      v_op = 'SUCCESSION'  and k.provenance->'succession_origin'->>'succession_id'     = p_reference_id::text
      or
      v_op = 'LEGACY'      and k.provenance->'legacy_origin'->>'legacy_id'             = p_reference_id::text
    )
    and not exists (
      select 1 from public.journey_events j
       where j.sh_id      = p_target_sh_id
         and j.event_type = 'KNOWLEDGE'
         and j.provenance->>'transfer_operation'  = v_op
         and j.provenance->>'reference_id'        = p_reference_id::text
         and j.provenance->>'source_knowledge_id' = k.knowledge_id::text
    );

  get diagnostics v_tmp = row_count;
  v_count := v_count + v_tmp;

  -- ── EXPERIENCE ──────────────────────────────────────────────────
  insert into public.journey_events(
    sh_id, account_id, event_type, occurred_at, continuity_status,
    payload, source_ref, visibility, transfer_policy, provenance
  )
  select
    p_target_sh_id,
    v_target_account,
    'EXPERIENCE',
    now(),
    'CONTINUOUS',
    jsonb_build_object(
      'experience_id', e.experience_id,
      'content',       e.content,
      'title',         coalesce(e.content, 'Transferred Experience')
    ),
    'semantic_projection:' || e.experience_id::text,
    'PRIVATE',
    'NON_TRANSFERABLE',
    jsonb_build_object(
      'transfer_operation',   v_op,
      'reference_id',         p_reference_id,
      'source_sh_id',         e.sh_id,
      'source_experience_id', e.experience_id,
      'projected_at',         now()
    )
  from public.experiences e
  where e.transfer_policy = v_op
    and (
      v_op = 'INHERITANCE' and e.provenance->'inheritance_origin'->>'authorization_id' = p_reference_id::text
      or
      v_op = 'SUCCESSION'  and e.provenance->'succession_origin'->>'succession_id'     = p_reference_id::text
      or
      v_op = 'LEGACY'      and e.provenance->'legacy_origin'->>'legacy_id'             = p_reference_id::text
    )
    and not exists (
      select 1 from public.journey_events j
       where j.sh_id      = p_target_sh_id
         and j.event_type = 'EXPERIENCE'
         and j.provenance->>'transfer_operation'   = v_op
         and j.provenance->>'reference_id'         = p_reference_id::text
         and j.provenance->>'source_experience_id' = e.experience_id::text
    );

  get diagnostics v_tmp = row_count;
  v_count := v_count + v_tmp;

  return v_count;
end;
$$;

-- ─────────────────────────────────────────────────────────────────
-- GRANTS
-- ─────────────────────────────────────────────────────────────────
revoke all on function public.runtime_project_transferred_semantics_into_target_journey(uuid, text, uuid)
  from anon, public;
grant execute on function public.runtime_project_transferred_semantics_into_target_journey(uuid, text, uuid)
  to authenticated;
