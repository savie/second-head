-- P1 security boundary: runtime_assert_active_sh is an internal SECURITY DEFINER helper.
-- It may inspect a target SH internally (including cross-account succession targets),
-- but must not be directly callable by authenticated clients because its
-- success/error behavior can disclose lifecycle existence/status.
revoke execute on function public.runtime_assert_active_sh(uuid,text) from authenticated;
revoke execute on function public.runtime_assert_active_sh(uuid,text) from anon;
revoke execute on function public.runtime_assert_active_sh(uuid,text) from public;
