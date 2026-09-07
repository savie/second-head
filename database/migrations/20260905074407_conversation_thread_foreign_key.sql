alter table public.conversations drop constraint if exists conversations_thread_id_fkey;
alter table public.conversations add constraint conversations_thread_id_fkey foreign key (thread_id) references public.conversation_threads(conversation_id) on delete cascade;
