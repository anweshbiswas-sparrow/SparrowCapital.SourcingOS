-- Previous company list (Oct 2026).
-- Live list of former employers for passed deals, counted from the Notion Raw Data field "Previous Company Worked At"
-- (the same field the team sees and filters in Notion). One row per real company: spelling variants are merged using
-- the web-verified names from mv_founder_employers_v2. Each deal counts once per company.
--
-- Why: the AI previously answered "list of previous companies" from v_founder_employers, which also includes LinkedIn
-- career history (Flipkart 21 there vs 17 deals in the Notion field vs 9 in the stored Notion "F3 Classification Company
-- Breakup" table), and it repeated companies once per pass stage. The AI instructions (brain_config ask_schema /
-- ask_rules) now point list questions here and the Notion breakup questions to v_f3_company_breakup.
create or replace view public.v_previous_company_list as
with mentions as (
  select r.id, r.deal, r.status, r.f3_classification, r.decision_to_pass_stage, r.created_time, btrim(c) raw_name
  from v_raw_data r cross join lateral unnest(string_to_array(r.previous_company_worked_at, ',')) c
  where nullif(btrim(r.previous_company_worked_at), '') is not null and btrim(c) <> ''
),
names as (
  select distinct on (lower(btrim(company))) lower(btrim(company)) k, entity
  from mv_founder_employers_v2
  where entity is not null and entity_status in ('verified', 'probable', 'unchecked')
  order by lower(btrim(company)), entity_status = 'verified' desc
),
m as (
  select mentions.*, coalesce(n.entity, mentions.raw_name) company
  from mentions left join names n on n.k = lower(mentions.raw_name)
)
select company,
  count(distinct id)::int as deals,
  count(distinct id) filter (where status = 'Pass')::int as passed,
  count(distinct id) filter (where status = 'To be Passed')::int as to_be_passed,
  count(distinct id) filter (where decision_to_pass_stage = 'Deck Scan')::int as stage_deck_scan,
  count(distinct id) filter (where decision_to_pass_stage = 'First Call')::int as stage_first_call,
  count(distinct id) filter (where decision_to_pass_stage = 'First Call + Data')::int as stage_first_call_data,
  count(distinct id) filter (where decision_to_pass_stage = 'Multiple Calls')::int as stage_multiple_calls,
  count(distinct id) filter (where decision_to_pass_stage in ('Diligence', 'Lot of Thinking', 'Calls across time period', 'Transaction'))::int as stage_diligence_or_later,
  count(distinct id) filter (where decision_to_pass_stage is null or decision_to_pass_stage = 'NA')::int as stage_not_set,
  (select string_agg(s || ' ' || n, ', ' order by n desc, s) from (
     select coalesce(nullif(m2.decision_to_pass_stage, 'NA'), 'Not set') s, count(distinct m2.id) n from m m2 where m2.company = m.company group by 1) z) as pass_stages,
  (select string_agg(f || ' ' || n, ', ' order by n desc, f) from (
     select coalesce(m3.f3_classification, 'Unclassified') f, count(distinct m3.id) n from m m3 where m3.company = m.company group by 1) z) as f3_split,
  string_agg(distinct deal, ', ') as deal_names,
  array_agg(distinct raw_name) as spellings
from m group by company;
grant select on public.v_previous_company_list to ask_reader;
revoke all on public.v_previous_company_list from anon, authenticated;
