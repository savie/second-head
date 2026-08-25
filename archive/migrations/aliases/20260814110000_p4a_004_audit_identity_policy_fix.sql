drop policy if exists audit_events_select_own_sh on public.audit_events;
create policy audit_events_select_own_sh on public.audit_events
  for select to authenticated
  using (
    account_id = current_account_id()
    and exists (
      select 1 from public.sh_ownership o
      where o.account_id = current_account_id() and o.sh_id = audit_events.sh_id
    )
  );

drop policy if exists audit_events_insert_own_sh on public.audit_events;
create policy audit_events_insert_own_sh on public.audit_events
  for insert to authenticated
  with check (
    account_id = current_account_id()
    and exists (
      select 1 from public.sh_ownership o
      where o.account_id = current_account_id() and o.sh_id = audit_events.sh_id
    )
  );
