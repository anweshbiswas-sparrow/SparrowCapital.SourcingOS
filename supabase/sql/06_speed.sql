-- Speed-ups (Oct 2026). Safe to re-run.

-- 1. Vector index for memory search. brain_search used to scan all ~28k vectors (50 MB) on every question,
--    which took 0.8-3 s when the data wasn't cached. With HNSW it takes ~30-230 ms. Results were checked
--    against the old exact scan: same top 3 for every test question.
set maintenance_work_mem = '64MB';
set max_parallel_maintenance_workers = 0;
create index if not exists brain_vec_emb_hnsw on public.brain_vec using hnsw (embedding halfvec_cosine_ops) with (m = 16, ef_construction = 64);

-- brain_search: use the index, and keep scanning until enough rows pass the kind filter.
do $$ declare d text; begin
  select pg_get_functiondef('public.brain_search(text,int,text[],jsonb)'::regprocedure) into d;
  if position('hnsw.iterative_scan' in d) = 0 then
    d := replace(d, E'begin\n  e := public.brain_embed_query(q)::halfvec(384);',
      E'begin\n  -- Use the HNSW index on brain_vec, and keep scanning it until enough rows pass the kind filter.\n  perform set_config(''hnsw.iterative_scan'', ''relaxed_order'', true);\n  perform set_config(''hnsw.ef_search'', ''200'', true);\n  e := public.brain_embed_query(q)::halfvec(384);');
    execute d;
  end if;
end $$;

-- 2. "Data as of" / deal counts: cached for 10 minutes (the live version took ~0.5-0.9 s when cold).
do $$ begin
  if to_regprocedure('public.ask_meta_live()') is null then
    execute 'alter function public.ask_meta() rename to ask_meta_live';
  end if;
end $$;
create table if not exists public.ask_meta_cache (id int primary key default 1 check (id = 1), at timestamptz not null, v jsonb not null);
alter table public.ask_meta_cache enable row level security;
create or replace function public.ask_meta() returns jsonb language plpgsql security definer set search_path to 'public' as $f$
declare c record; v jsonb;
begin
  select at, ask_meta_cache.v into c from ask_meta_cache where id = 1;
  if c.at is not null and c.at > now() - interval '10 minutes' then return c.v; end if;
  v := ask_meta_live();
  begin
    insert into ask_meta_cache (id, at, v) values (1, now(), v) on conflict (id) do update set at = excluded.at, v = excluded.v;
  exception when others then null;
  end;
  return v;
end $f$;
revoke execute on function public.ask_meta(), public.ask_meta_live() from public, anon, authenticated;
revoke all on public.ask_meta_cache from anon, authenticated;
