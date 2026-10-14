-- Adds the Lead Tracker (nt_lead_tracker) to Deal Brain's search memory (brain_docs, kind = 'lead').
-- Patches public.refresh_brain_docs() in place by inserting a "9. LEAD TRACKER" section before the upsert.
-- Safe to re-run: it does nothing if the section is already there.
-- After applying, run: select public.refresh_brain_docs();  (new docs are embedded by the brain-embed-tick cron, no AI key needed)

do $do$
declare d text; sec text;
begin
  select pg_get_functiondef(p.oid) into d from pg_proc p where proname = 'refresh_brain_docs';
  if position('9. LEAD TRACKER' in d) > 0 then raise notice 'already added'; return; end if;
  sec := $sec$-- 9. LEAD TRACKER (people/companies we are tracking or have spoken to, not yet in the pipeline)
  insert into _nd
  select 'lead:' || l.id, 'lead', l.company_name,
    concat_ws(E'\n',
      'Lead (Lead Tracker): ' || l.company_name,
      'Lead status: ' || l.status, 'Priority: ' || l.priority, 'Source: ' || l.source, 'Location: ' || l.location,
      'Industry: ' || nullif(array_to_string(l.industry, ', '), ''),
      'Added: ' || l.created_date,
      'Description: ' || l.description,
      'Next action: ' || l.next_action,
      'LinkedIn: ' || l.linkedin_url,
      'Founder background (from notes): ' || h.hist,
      'Page notes (excerpt): ' || left(l.body, 1500)),
    jsonb_strip_nulls(jsonb_build_object('name', l.company_name, 'key', brain_key(l.company_name), 'status', 'Lead – ' || coalesce(l.status, 'no status'),
      'lead_status', l.status, 'created', l.created_date, 'linkedin', l.linkedin_url, 'pipeline_links', l.deal_pipeline_mapping, 'url', l.url))
  from nt_lead_tracker l
  left join lateral (select string_agg(distinct h.founder || ' — ' || h.company || coalesce(' (' || h.role || ')', ''), '; ') hist
                     from deal_founder_history h where h.deal_id = l.id) h on true
  where l.company_name is not null;

  $sec$;
  d := replace(d, '-- upsert only what changed', sec || '-- upsert only what changed');
  execute d;
end $do$;
