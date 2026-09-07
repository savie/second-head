drop policy if exists memories_owner_select on public.memories;
drop policy if exists memories_owner_insert on public.memories;
drop policy if exists memories_owner_update on public.memories;
drop policy if exists memories_owner_delete on public.memories;

create policy memories_owner_select
  on public.memories
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.sh_instances s
      where s.sh_id = memories.sh_id
        and s.account_id = public.current_account_id()
    )
  );

create policy memories_owner_insert
  on public.memories
  for insert
  to authenticated
  with check (
    exists (
      select 1
      from public.sh_instances s
      where s.sh_id = memories.sh_id
        and s.account_id = public.current_account_id()
    )
  );

create policy memories_owner_update
  on public.memories
  for update
  to authenticated
  using (
    exists (
      select 1
      from public.sh_instances s
      where s.sh_id = memories.sh_id
        and s.account_id = public.current_account_id()
    )
  )
  with check (
    exists (
      select 1
      from public.sh_instances s
      where s.sh_id = memories.sh_id
        and s.account_id = public.current_account_id()
    )
  );

create policy memories_owner_delete
  on public.memories
  for delete
  to authenticated
  using (
    exists (
      select 1
      from public.sh_instances s
      where s.sh_id = memories.sh_id
        and s.account_id = public.current_account_id()
    )
  );
