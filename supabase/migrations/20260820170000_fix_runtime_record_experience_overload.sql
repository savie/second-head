-- SECOND HEAD — remove the legacy Experience recorder overload.
-- The canonical recorder is the 9-argument function with transfer_policy.
-- The legacy 8-argument overload caused the existing authenticated Journey
-- capture call to resolve to the old recorder and fail to persist Experience
-- under the reconciled policy contract.

drop function if exists public.runtime_record_experience(
  uuid,
  text,
  text,
  text,
  text,
  text,
  jsonb,
  timestamptz
);

revoke all on function public.runtime_record_experience(
  uuid,
  text,
  text,
  text,
  text,
  text,
  text,
  jsonb,
  timestamptz
) from public;

grant execute on function public.runtime_record_experience(
  uuid,
  text,
  text,
  text,
  text,
  text,
  text,
  jsonb,
  timestamptz
) to authenticated;
