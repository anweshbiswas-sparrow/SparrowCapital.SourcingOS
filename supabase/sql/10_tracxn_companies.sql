-- Founder backgrounds for Tracxn Fund companies (filled from the Tracxn API by Claude),
-- and one row per Tracxn company with "missed / seen" status, investors and founders.
create table if not exists public.tracxn_founders (
  company text primary key,
  tracxn_id text,
  founded_year int,
  stage text,
  founders jsonb,              -- [{name, designation}]
  prev_companies text[],       -- founders' previous employers ("Company Wise" background flags)
  colleges text[],
  serial_founder boolean,
  prior_funded_founder boolean,
  found boolean default true,
  fetched_at timestamptz default now()
);
alter table public.tracxn_founders enable row level security;
revoke all on public.tracxn_founders from anon, authenticated;
create policy ask_reader_read on public.tracxn_founders for select to ask_reader using (true);
grant select on public.tracxn_founders to ask_reader;

create or replace view public.v_tracxn_companies as
with r as (
  select company, sparrow_pipeline, sector, location, founded_year, round_name, round_date,
         round_amount_usd, lead_investor, round_investors
  from nt_tracxn_rounds
), agg as (
  select r.company,
    max(r.sparrow_pipeline) as sparrow_pipeline,
    (select array_agg(distinct s order by s) from r r2, unnest(r2.sector) s where r2.company = r.company) as sectors,
    (select array_agg(distinct l order by l) from r r2, unnest(r2.location) l where r2.company = r.company) as locations,
    max(r.founded_year)::int as founded_year,
    count(*)::int as rounds,
    sum(r.round_amount_usd) as total_raised_usd,
    (array_agg(r.round_name order by r.round_date desc nulls last))[1] as latest_round,
    max(r.round_date) as latest_round_date,
    (array_agg(r.round_amount_usd order by r.round_date desc nulls last))[1] as latest_round_usd,
    (select array_agg(distinct i order by i) from r r2, unnest(r2.lead_investor) i where r2.company = r.company and btrim(i) <> '') as lead_investors,
    (select array_agg(distinct i order by i) from r r2, unnest(r2.round_investors) i where r2.company = r.company and btrim(i) <> '') as all_investors
  from r group by r.company
)
select a.company,
  case when a.sparrow_pipeline = 'Missing' then 'Missed (never in our pipeline)'
       when a.sparrow_pipeline ilike '%pass%' then 'Seen and passed'
       when a.sparrow_pipeline = 'Late' then 'Seen late'
       else coalesce(a.sparrow_pipeline, 'Unknown') end as our_status,
  a.sparrow_pipeline = 'Missing' as missed,
  coalesce(a.sectors && array['FinTech','Financial Services'], false) as is_fintech,
  array_to_string(a.sectors, ', ') as sectors,
  array_to_string(a.locations, ', ') as location,
  a.founded_year,
  extract(year from a.latest_round_date)::int - a.founded_year as age_at_latest_round,
  a.rounds, a.total_raised_usd, a.latest_round, a.latest_round_date, a.latest_round_usd,
  array_to_string(a.lead_investors, ', ') as lead_investors,
  array_to_string(a.all_investors, ', ') as all_investors,
  coalesce(cardinality(a.all_investors), 0) as investor_count,
  case when f.company is null then 'Not looked up yet' when not f.found then 'Not available in Tracxn' else 'From Tracxn' end as founder_data,
  (select string_agg((x->>'name') || coalesce(' (' || (x->>'designation') || ')', ''), '; ') from jsonb_array_elements(f.founders) x) as founders,
  coalesce(nullif(array_to_string(f.prev_companies, ', '), ''), case when f.found then 'Not recorded in Tracxn' end) as founder_previous_companies,
  nullif(array_to_string(f.colleges, ', '), '') as founder_colleges,
  f.serial_founder, f.prior_funded_founder
from agg a left join tracxn_founders f on f.company = a.company;
grant select on public.v_tracxn_companies to ask_reader;

-- Owner-only test runner: queue a payload in selftest_runs; a cron job posts it to the ask function.
create table if not exists public.selftest_runs (
  id bigserial primary key, created_at timestamptz default now(), payload jsonb not null,
  status text default 'pending', http_status int, result jsonb, finished_at timestamptz);
alter table public.selftest_runs enable row level security;
revoke all on public.selftest_runs from anon, authenticated;
