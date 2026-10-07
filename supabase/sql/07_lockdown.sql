-- Lockdown (Oct 2026). Safe to re-run.
-- The web page holds only the public "anon" key, and anyone with a Google account can sign in and get an
-- "authenticated" token (access to Deal Brain itself is still invite-only, enforced in the `ask` function).
-- Neither role needs direct database access, so they get none: no tables, no sequences, no functions.
-- Row-level security stays on for every table as a second layer.
revoke all on all tables in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;
revoke execute on all functions in schema public from anon, authenticated, public;
alter default privileges in schema public revoke all on tables from anon, authenticated;
alter default privileges in schema public revoke all on sequences from anon, authenticated;
alter default privileges in schema public revoke execute on functions from anon, authenticated, public;
alter default privileges for role postgres in schema public revoke all on tables from anon, authenticated;
alter default privileges for role postgres in schema public revoke all on sequences from anon, authenticated;
alter default privileges for role postgres in schema public revoke execute on functions from anon, authenticated, public;

alter function public.brain_key(text) set search_path = public, extensions;
alter function public.brain_vec_truncate() set search_path = public, extensions;
alter function public.er_load(jsonb) set search_path = public, extensions;

grant execute on all functions in schema public to service_role, postgres;
grant execute on function public.brain_search(text, int, text[], jsonb), public.brain_similar(text, int, text[]),
  public.brain_key(text), public.brain_embed_query(text) to ask_reader;

-- Check: both numbers must be 0.
select (select count(*) from information_schema.role_table_grants where grantee in ('anon','authenticated') and table_schema = 'public') as public_table_grants,
       (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public'
          and (has_function_privilege('anon', p.oid, 'execute') or has_function_privilege('authenticated', p.oid, 'execute'))) as public_function_grants;
