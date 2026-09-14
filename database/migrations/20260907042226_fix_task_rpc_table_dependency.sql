CREATE OR REPLACE FUNCTION public.create_task(p_title text, p_due_at timestamp with time zone)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_account_id uuid;
  v_sh_id uuid;
  v_task_id uuid;
begin
  v_account_id := public.current_account_id();
  if v_account_id is null then
    raise exception 'R6_TASK_REJECTED: authenticated account is required';
  end if;

  select s.sh_id
    into v_sh_id
    from public.sh_instances s
   where s.account_id = v_account_id
   order by s.created_at
   limit 1;

  if v_sh_id is null then
    raise exception 'R6_TASK_REJECTED: SH identity could not be resolved';
  end if;

  if p_title is null or length(trim(p_title)) = 0 then
    raise exception 'R6_TASK_REJECTED: task title is required';
  end if;

  if p_due_at is null then
    raise exception 'R6_TASK_REJECTED: due time is required';
  end if;

  insert into public.task_reminders(account_id, sh_id, actor_id, title, due_at)
  values (v_account_id, v_sh_id, auth.uid(), trim(p_title), p_due_at)
  returning task_id into v_task_id;

  return v_task_id;
end;
$function$;

CREATE OR REPLACE FUNCTION public.list_tasks(p_limit integer DEFAULT 20)
RETURNS TABLE(task_id uuid, title text, due_at timestamp with time zone, status text, created_at timestamp with time zone, completed_at timestamp with time zone)
LANGUAGE sql
SET search_path TO 'public'
AS $function$
  select t.task_id, t.title, t.due_at, t.status, t.created_at, t.completed_at
    from public.task_reminders t
   where t.account_id = public.current_account_id()
   order by t.due_at asc
   limit least(greatest(coalesce(p_limit,20),1),100);
$function$;
