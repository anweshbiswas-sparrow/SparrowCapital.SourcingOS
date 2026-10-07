-- Team app (Deal Brain web) security setup.
-- Questions are answered by the `ask` Edge Function, which runs model-written SQL as the
-- role ask_reader inside a READ ONLY transaction with a 25s timeout. ask_reader can only
-- SELECT from the data tables/views and call the search helpers; it cannot read secrets,
-- write anything, or reach the http extension.

-- 1. Nothing is readable or callable with the public anon key (the web page only calls the Edge Function).
revoke all on mv_founder_employers, mv_founder_employers_v2, v_founder_employers, v_raw_data_content from anon, authenticated;
alter default privileges for role postgres in schema public revoke all on tables from anon, authenticated;
alter default privileges for role postgres in schema public revoke execute on functions from anon, authenticated, public;
revoke execute on all functions in schema public from anon, authenticated, public;
grant execute on all functions in schema public to service_role, postgres;

-- 2. Read-only role used for model-written queries
do $$ begin if not exists (select 1 from pg_roles where rolname = 'ask_reader') then create role ask_reader nologin; end if; end $$;
grant ask_reader to postgres;
grant usage on schema public to ask_reader;
-- no usage on schema extensions: blocks http()/http_get() etc.
revoke usage on schema extensions from ask_reader;

do $$ declare r record; begin
  for r in select c.relname from pg_class c join pg_namespace n on n.oid = c.relnamespace
           where n.nspname = 'public' and c.relkind in ('r','v','m')
             and c.relname not in ('brain_config', 'brain_qcache', 'brain_feedback', 'ask_log')
  loop execute format('grant select on public.%I to ask_reader', r.relname); end loop;
end $$;

-- RLS tables: let ask_reader read them
do $$ declare r record; begin
  for r in select c.relname from pg_class c join pg_namespace n on n.oid = c.relnamespace
           where n.nspname = 'public' and c.relkind = 'r' and c.relrowsecurity
             and c.relname not in ('brain_config', 'brain_qcache', 'brain_feedback', 'ask_log')
  loop
    if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = r.relname and policyname = 'ask_reader_read') then
      execute format('create policy ask_reader_read on public.%I for select to ask_reader using (true)', r.relname);
    end if;
  end loop;
end $$;

-- Search helpers run as their owner so ask_reader needs no access to vector/http internals
alter function brain_search(text, int, text[], jsonb) security definer;
alter function brain_similar(text, int, text[]) security definer;
alter function brain_embed_query(text) security definer;
grant execute on function brain_search(text, int, text[], jsonb), brain_similar(text, int, text[]), brain_key(text), brain_embed_query(text) to ask_reader;

-- 3. Usage log + limits
create table if not exists ask_log(
  id bigserial primary key, created_at timestamptz not null default now(),
  client_id text, ip text, question text, sqls jsonb, answer text, row_count int, ms int,
  model text, tokens_in int, tokens_out int, error text, rating smallint, feedback_id bigint);
alter table ask_log enable row level security;
create index if not exists ask_log_created on ask_log(created_at desc);

-- ask_quota(client) and ask_meta(): see 01_schema_snapshot.sql (FUNCTIONS section).
revoke execute on function ask_quota(text), ask_meta() from public, anon, authenticated;
