-- Shareable chat links: a snapshot of a chat that any signed-in, invited Deal Brain user can open at /c/<id>.
-- Only the ask edge function (database owner connection) reads or writes this table.
create table if not exists public.shared_chats (
  id text primary key,
  owner_email text not null,
  client_chat_id text not null,
  title text,
  turns jsonb not null default '[]',
  views int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (owner_email, client_chat_id)
);
alter table public.shared_chats enable row level security;
revoke all on public.shared_chats from anon, authenticated;
do $$ begin
  if exists (select 1 from pg_roles where rolname = 'ask_reader') then
    execute 'revoke all on public.shared_chats from ask_reader';
  end if;
end $$;
