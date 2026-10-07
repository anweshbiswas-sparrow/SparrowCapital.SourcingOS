-- "Why did we miss them?" — measurable comparison of companies we never saw (Missed) vs companies we saw and passed,
-- for Fintech and for all sectors. One row per metric so even a small model can read the pattern off directly.
create or replace view public.v_tracxn_missed_pattern as
with base as materialized (
  select c.*, case when c.missed then 'Missed' when c.our_status = 'Seen and passed' then 'Seen and passed' end as grp
  from v_tracxn_companies c
), seen_inv as materialized (  -- investor -> companies of theirs that reached our pipeline
  select btrim(i) inv, b.company from base b, unnest(string_to_array(b.all_investors, ',')) i
  where not b.missed and btrim(i) <> ''
), flag as (
  select b.*, exists (select 1 from unnest(string_to_array(b.all_investors, ',')) i
                      join seen_inv s on s.inv = btrim(i) and s.company <> b.company) as investor_known
  from base b where b.grp is not null
), seg as (
  select 'Fintech' as segment, * from flag where is_fintech
  union all select 'All sectors', * from flag
), m as (
  select segment, grp,
    count(*)::numeric n,
    round(avg(total_raised_usd) / 1e6, 2) avg_raised_m,
    round((percentile_cont(0.5) within group (order by latest_round_usd) / 1e6)::numeric, 2) median_round_m,
    round(100.0 * count(*) filter (where latest_round ilike 'series a%') / count(*), 0) pct_series_a,
    round(100.0 * count(*) filter (where latest_round ilike '%seed%') / count(*), 0) pct_seed,
    round(avg(age_at_latest_round), 1) avg_age,
    round(100.0 * count(*) filter (where location ilike '%bengaluru%' or location ilike '%bangalore%') / count(*), 0) pct_blr,
    round(100.0 * count(*) filter (where location ilike '%mumbai%') / count(*), 0) pct_mum,
    round(100.0 * count(*) filter (where location ~* 'delhi|gurugram|gurgaon|noida') / count(*), 0) pct_ncr,
    round(100.0 * count(*) filter (where location !~* 'bengaluru|bangalore|mumbai|delhi|gurugram|gurgaon|noida') / count(*), 0) pct_other_city,
    round(avg(investor_count), 1) avg_investors,
    round(100.0 * count(*) filter (where investor_known) / count(*), 0) pct_known_investor,
    round(100.0 * count(*) filter (where serial_founder) / nullif(count(*) filter (where serial_founder is not null), 0), 0) pct_serial_founder
  from seg group by 1, 2
), metrics(ord, metric, col) as (values
  (1, 'Companies', 'n'), (2, 'Average total raised (USD M)', 'avg_raised_m'), (3, 'Median latest round (USD M)', 'median_round_m'),
  (4, 'Latest round is Series A (%)', 'pct_series_a'), (5, 'Latest round is Seed (%)', 'pct_seed'),
  (6, 'Average company age at latest round (years)', 'avg_age'), (7, 'Based in Bengaluru (%)', 'pct_blr'),
  (8, 'Based in Mumbai (%)', 'pct_mum'), (9, 'Based in Delhi NCR (%)', 'pct_ncr'), (10, 'Based outside the top 3 hubs (%)', 'pct_other_city'),
  (11, 'Average number of investors', 'avg_investors'),
  (12, 'Backed by an investor who backed another company we saw (%)', 'pct_known_investor'),
  (13, 'Has a serial founder (% of those with founder data)', 'pct_serial_founder')
), vals as (
  select m.segment, x.ord, x.metric, m.grp, (to_jsonb(m) ->> x.col)::numeric v
  from m cross join metrics x
), wide as (
  select segment, ord, metric,
    max(v) filter (where grp = 'Missed') as missed_v,
    max(v) filter (where grp = 'Seen and passed') as seen_v
  from vals group by segment, ord, metric
), scored as (
  select w.*, missed_v - seen_v as diff,
    -- a "key difference": at least 8 percentage points for shares, or at least 25% relative for averages
    case when ord = 1 or missed_v is null or seen_v is null then false
         when metric like '%(\%)' then abs(missed_v - seen_v) >= 8
         else abs(missed_v - seen_v) >= 0.25 * greatest(abs(seen_v), 0.01) end as key_diff
  from wide w
)
select segment as "Segment", metric as "Metric", missed_v as "Missed", seen_v as "Seen and passed",
  diff as "Difference (missed minus seen)", key_diff as "Key difference",
  case when ord = 1 then format('We never saw %s companies; we saw and passed on %s.', missed_v, seen_v)
       when missed_v is null or seen_v is null then 'Not enough data to compare.'
       else format('%s: %s for missed vs %s for companies we saw%s', regexp_replace(metric, ' \(.*\)$', ''),
                   missed_v || case when metric like '%(\%)' then '%' else '' end,
                   seen_v || case when metric like '%(\%)' then '%' else '' end,
                   case when key_diff then ' — a key difference.' else ' — about the same.' end) end as "Reading"
from scored order by segment desc, key_diff desc, abs(coalesce(diff, 0)) desc, ord;
grant select on public.v_tracxn_missed_pattern to ask_reader;

-- Investors behind missed companies, and whether they also backed a company that reached our pipeline.
create or replace view public.v_tracxn_missed_investors as
with seen_inv as materialized (
  select distinct btrim(j) inv from v_tracxn_companies s, unnest(string_to_array(s.all_investors, ',')) j where not s.missed and btrim(j) <> ''
), x as (
  select case when c.is_fintech then 'Fintech' else 'Other' end as segment, btrim(i) inv, c.company
  from v_tracxn_companies c, unnest(string_to_array(c.all_investors, ',')) i
  where c.missed and btrim(i) <> ''
)
select x.segment as "Segment", x.inv as "Investor", count(distinct x.company)::int as "Missed companies backed",
  string_agg(distinct x.company, ', ') as "Companies",
  bool_or(s.inv is not null) as "Also backed a company we saw"
from x left join seen_inv s on s.inv = x.inv
group by 1, 2;
grant select on public.v_tracxn_missed_investors to ask_reader;
