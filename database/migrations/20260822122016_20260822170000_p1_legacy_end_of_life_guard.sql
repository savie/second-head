CREATE OR REPLACE FUNCTION public.runtime_preserve_selected_transfer_as_legacy(p_source_sh_id uuid, p_scope jsonb)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_result uuid;
begin
  if auth.uid() is null then
    raise exception 'LEGACY_REJECTED: authentication required';
  end if;

  if not exists (
    select 1
    from public.sh_instances s
    where s.sh_id = p_source_sh_id
      and s.account_id = public.current_account_id()
      and s.status = 'deactivated'
  ) then
    raise exception 'LEGACY_REJECTED: source SH must be end-of-life/deactivated';
  end if;

  perform public.runtime_validate_selected_transfer_scope(p_source_sh_id, p_scope, 'legacy');
  v_result := public.runtime_preserve_selected_transfer_as_legacy_unchecked(p_source_sh_id, p_scope);
  return v_result;
end;
$function$;