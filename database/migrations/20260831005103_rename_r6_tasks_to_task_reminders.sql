begin;
alter table public.r6_tasks rename to task_reminders;
alter table public.task_reminders rename constraint r6_tasks_pkey to task_reminders_pkey;
alter table public.task_reminders rename constraint r6_tasks_account_id_fkey to task_reminders_account_id_fkey;
alter table public.task_reminders rename constraint r6_tasks_sh_id_fkey to task_reminders_sh_id_fkey;
alter function public.r6_create_task(text,timestamptz) rename to create_task;
alter function public.r6_list_tasks(integer) rename to list_tasks;
commit;