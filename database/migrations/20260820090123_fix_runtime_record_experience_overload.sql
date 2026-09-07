-- Remove the legacy 8-argument overload. The canonical 9-argument function already exists
-- and defaults transfer policy to NON_TRANSFERABLE. Keeping both overloads makes the
-- existing authenticated Journey capture call resolve to the legacy function instead.
drop function if exists public.runtime_record_experience(uuid, text, text, text, text, text, jsonb, timestamptz);

-- Reassert the canonical function privileges after removing the legacy overload.
revoke all on function public.runtime_record_experience(uuid, text, text, text, text, text, text, jsonb, timestamptz) from public;
grant execute on function public.runtime_record_experience(uuid, text, text, text, text, text, text, jsonb, timestamptz) to authenticated;