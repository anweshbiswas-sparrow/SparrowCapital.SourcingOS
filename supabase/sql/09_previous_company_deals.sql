-- One row per previous company and deal (same source as v_previous_company_list: the Notion Raw Data field
-- "Previous Company Worked At", with spelling variants merged). Lets the AI filter the previous-company list by
-- pass stage / status / F3 sector / date and show the actual deal names, e.g. "previous companies at First Call".
create or replace view public.v_previous_company_deals as
with mentions as (
  select r.id, r.deal, r.status, r.f3_classification, r.decision_to_pass_stage, r.meeting_date, r.created_time, r.url, btrim(c) raw_name
  from v_raw_data r cross join lateral unnest(string_to_array(r.previous_company_worked_at, ',')) c
  where nullif(btrim(r.previous_company_worked_at), '') is not null and btrim(c) <> ''
),
names as (
  select distinct on (lower(btrim(company))) lower(btrim(company)) k, entity
  from mv_founder_employers_v2
  where entity is not null and entity_status in ('verified', 'probable', 'unchecked')
  order by lower(btrim(company)), entity_status = 'verified' desc
)
select distinct on (coalesce(n.entity, m.raw_name), m.id)
  coalesce(n.entity, m.raw_name) as company, m.deal, m.id as deal_id, m.status,
  coalesce(nullif(m.decision_to_pass_stage, 'NA'), 'Not set') as pass_stage,
  m.f3_classification, m.meeting_date, m.created_time::date as created_date, m.url
from mentions m left join names n on n.k = lower(m.raw_name)
order by coalesce(n.entity, m.raw_name), m.id;
grant select on public.v_previous_company_deals to ask_reader;
revoke all on public.v_previous_company_deals from anon, authenticated;
