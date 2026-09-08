alter table public.knowledge add column if not exists sh_id uuid;
create index if not exists knowledge_private_sh_id_idx on public.knowledge (sh_id) where scope = 'PRIVATE';
alter table public.knowledge drop constraint if exists knowledge_private_sh_id_required;
alter table public.knowledge add constraint knowledge_private_sh_id_required check (scope <> 'PRIVATE' or sh_id is not null);
alter table public.knowledge drop constraint if exists knowledge_private_sh_id_fk;
alter table public.knowledge add constraint knowledge_private_sh_id_fk foreign key (sh_id) references public.sh_instances(sh_id) not valid;
create policy knowledge_private_owner_select
on public.knowledge
for select
to authenticated
using (
  scope = 'PRIVATE'
  and sh_id in (select si.sh_id from public.sh_instances si where si.account_id = auth.uid())
);
