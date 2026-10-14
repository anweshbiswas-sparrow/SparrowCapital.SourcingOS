-- founders_who_worked_at(employers, passed_only): who in our pipeline / leads previously worked at a company.
-- Sources: Notion founder fields + LinkedIn (v_founder_employers), call-note extraction (deal_founder_history),
-- deal titles like "Karthik V. (Groww)" / "Saket, ex-Groww", and Lead Tracker titles, descriptions and
-- profile Headline/Role/Background lines. Applied live 2026-10-14.

CREATE OR REPLACE FUNCTION public.founders_who_worked_at(p_employers text, p_passed_only boolean DEFAULT false)
 RETURNS TABLE("Founder" text, "Startup" text, "Employer" text, "Role" text, "Status" text, "We met" text, "LinkedIn" text, "Recorded in" text)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  with pat as (select '\m(' || p_employers || ')(\M|pay\M)' as re,
                      -- "ex-Groww", "(Groww)", "Groww alum" style mentions in a deal or lead title
                      '(\mex[- ]?(' || p_employers || ')\M|\(\s*(ex[- ]?)?(' || p_employers || ')\M|\m(' || p_employers || ')\M\s*(alum|alumni)\M)' as title_re),
  lead_map as (
    select l.id as lead_id, l.company_name, l.status, l.created_date, l.linkedin_url, l.description, l.body,
           (select p.id from nt_deal_pipeline p where p.url = any(l.deal_pipeline_mapping) limit 1) as deal_id
    from nt_lead_tracker l),
  hits as (
    select f.deal_id, f.deal, f.status, f.meeting_date, f.founder, coalesce(f.entity, f.company) as employer, f.title as role,
           f.linkedin_url, case when f.via = 'linkedin' then 'LinkedIn' else 'Notion fields' end as src
    from v_founder_employers f, pat
    where (not p_passed_only or f.in_raw_data)
      and (f.company ~* pat.re or f.entity ~* pat.re or f.parent_group ~* pat.re)
    union all
    select h.deal_id, p.deal, p.status, p.meeting_date, h.founder, h.company, h.role, null, 'Call notes'
    from deal_founder_history h join nt_deal_pipeline p on p.id = h.deal_id, pat
    where h.company ~* pat.re
      and (not p_passed_only or exists (select 1 from v_raw_data r where r.id = h.deal_id))
    union all
    -- deal named after the founder with the employer in the title, e.g. "Karthik V. (Groww)", "Saket, ex-Groww"
    select p.id, p.deal, p.status, p.meeting_date,
           coalesce(nullif(p.founder_name, ''), nullif(trim(regexp_replace(p.deal, '\s*([(,]|\mex[- ]).*$', '', 'i')), ''), p.deal),
           (regexp_match(p.deal, pat.re, 'i'))[1], null, p.founder_linkedin, 'Deal title'
    from nt_deal_pipeline p, pat
    where p.deal ~* pat.title_re
      and (not p_passed_only or exists (select 1 from v_raw_data r where r.id = p.id))
    union all
    select coalesce(m.deal_id, m.lead_id), coalesce(p.deal, m.company_name), coalesce(p.status, 'Lead – ' || coalesce(m.status, 'no status')),
           coalesce(p.meeting_date, m.created_date), h.founder, h.company, h.role, m.linkedin_url, 'Lead Tracker'
    from deal_founder_history h join lead_map m on m.lead_id = h.deal_id
         left join nt_deal_pipeline p on p.id = m.deal_id, pat
    where h.company ~* pat.re
      and (not p_passed_only or exists (select 1 from v_raw_data r where r.id = m.deal_id))
    union all
    -- Lead Tracker person whose title, description or profile headline/role/background names the employer
    select coalesce(m.deal_id, m.lead_id), coalesce(p.deal, m.company_name), coalesce(p.status, 'Lead – ' || coalesce(m.status, 'no status')),
           coalesce(p.meeting_date, m.created_date),
           coalesce(nullif(trim(regexp_replace(m.company_name, '\s*\(.*$', '')), ''), m.company_name),
           (regexp_match(concat_ws(' ', m.company_name, m.description, x.profile), pat.re, 'i'))[1], null, m.linkedin_url, 'Lead Tracker'
    from lead_map m
         left join nt_deal_pipeline p on p.id = m.deal_id
         cross join pat
         left join lateral (select string_agg(r[1], ' ') as profile
                            from regexp_matches(coalesce(m.body, ''), '^\s*(?:Headline|Role|Background|Person)\s*:([^\n]*)', 'gn') r) x on true
    where (m.company_name ~* pat.title_re or m.description ~* pat.re or x.profile ~* pat.re)
      and (not p_passed_only or exists (select 1 from v_raw_data r where r.id = m.deal_id))
  )
  select max(founder),
         string_agg(distinct deal, ', '),
         string_agg(distinct employer, ', '),
         coalesce(string_agg(distinct role, '; ') filter (where role is not null and role <> ''), 'Role not recorded'),
         string_agg(distinct status, ', '),
         to_char(max(meeting_date), 'DD Mon YYYY'),
         max(linkedin_url),
         string_agg(distinct src, ', ')
  from hits
  group by deal_id, lower(split_part(regexp_replace(founder, '^(dr|mr|ms)\.?\s+', '', 'i'), ' ', 1))
  order by max(meeting_date) desc nulls last, max(founder)
$function$;
