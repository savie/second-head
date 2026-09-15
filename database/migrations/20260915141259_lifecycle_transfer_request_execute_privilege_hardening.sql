revoke execute on function public.runtime_create_inheritance_authorization_by_email(text,jsonb) from public,anon;
revoke execute on function public.runtime_create_succession_rule_by_email(text,jsonb) from public,anon;
grant execute on function public.runtime_create_inheritance_authorization_by_email(text,jsonb) to authenticated;
grant execute on function public.runtime_create_succession_rule_by_email(text,jsonb) to authenticated;
