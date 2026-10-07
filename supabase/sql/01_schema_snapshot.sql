-- Snapshot of the public schema (tables, views, functions, cron jobs) exported 2026-10-07.
-- Reference / disaster-recovery copy. Secrets live in brain_config rows and Edge Function secrets, NOT here.

-- TABLES
create table if not exists public.ask_log (
  id bigint not null,
  created_at timestamp with time zone not null,
  client_id text,
  ip text,
  question text,
  sqls jsonb,
  answer text,
  row_count integer,
  ms integer,
  model text,
  tokens_in integer,
  tokens_out integer,
  error text,
  rating smallint,
  feedback_id bigint
);

create table if not exists public.brain_config (
  key text not null,
  value text not null
);

create table if not exists public.brain_docs (
  id text not null,
  kind text not null,
  title text not null,
  body text not null,
  metadata jsonb not null,
  content_hash text not null,
  embedding vector(384),
  fts tsvector,
  updated_at timestamp with time zone not null,
  embedded_at timestamp with time zone
);

create table if not exists public.brain_feedback (
  id bigint not null,
  created_at timestamp with time zone not null,
  chat_id text,
  question text not null,
  answer text,
  sql text,
  rating smallint not null,
  correction text
);

create table if not exists public.brain_insights (
  id bigint not null,
  created_at timestamp with time zone not null,
  title text not null,
  insight text not null,
  evidence text,
  question text,
  sql text,
  active boolean not null
);

create table if not exists public.brain_qcache (
  q text not null,
  embedding vector(384) not null,
  used_at timestamp with time zone not null
);

create table if not exists public.brain_rules (
  id bigint not null,
  created_at timestamp with time zone not null,
  rule text not null,
  source text not null,
  feedback_id bigint,
  active boolean not null
);

create table if not exists public.brain_term_df (
  word text not null,
  ndoc integer not null
);

create table if not exists public.brain_vec (
  id text not null,
  kind text not null,
  metadata jsonb,
  embedding halfvec(384) not null
);

create table if not exists public.companies (
  name text not null,
  aliases text[] not null
);

create table if not exists public.company_entities (
  name text not null,
  entity text not null,
  parent_group text,
  entity_type text,
  domain text,
  status text,
  confidence text,
  evidence_url text,
  note text,
  cluster integer,
  checked_at timestamp with time zone,
  source text
);

create table if not exists public.deal_founders (
  deal_id text not null,
  slot smallint not null,
  founder_key text not null,
  previous_company_raw text
);

create table if not exists public.deal_investors (
  deal_id text not null,
  investor text not null
);

create table if not exists public.deals (
  id text not null,
  name text not null,
  status text,
  sectors text[],
  f3_classification text,
  source text[],
  meeting_date date,
  source_created_at timestamp with time zone,
  source_link text,
  synced_at timestamp with time zone not null
);

create table if not exists public.founders (
  key text not null,
  name text,
  linkedin_url text,
  synced_at timestamp with time zone not null
);

create table if not exists public.investors (
  name text not null
);

create table if not exists public.nt_deal_content (
  page_id text not null,
  deal text,
  meeting_dates date[] not null,
  summary text,
  meeting_notes text,
  page_notes text,
  transcript text,
  meetings integer not null,
  page_last_edited_at timestamp with time zone,
  fetched_at timestamp with time zone not null
);

create table if not exists public.nt_deal_pipeline (
  id text not null,
  url text,
  deal text,
  status text,
  f2_classification text,
  f3_classification text,
  sectors text[],
  source text[],
  location text,
  type text,
  "select" text,
  risk_evaluation text,
  decision_to_pass_stage text,
  pass_type text[],
  founder_pass_vectors text[],
  antiportfolio text,
  decision_audit text,
  decision_audit_check boolean,
  acquihire boolean,
  re_pipeline_reason text,
  re_pipeline_date date,
  follow_up_date date,
  meeting_date date,
  created_time timestamp with time zone,
  created_by text,
  people text[],
  description text,
  comments text,
  what_stood_out text,
  what_to_check text,
  view_1y text,
  view_3y text,
  view_5y text,
  view_10y text,
  similar_companies text,
  founder_name text,
  founder_linkedin text,
  previous_company text,
  previous_company_worked_at text,
  previous_company_worked_at_raw text,
  last_company_worked text,
  email text,
  documents text,
  documents_link text,
  im_link text,
  deal_attribution text[],
  institutional_funding text[],
  sourcing_network_nodes text[],
  synced_at timestamp with time zone not null,
  industry text[],
  linkedin_url text,
  source_1 text,
  contact_email text,
  created_date date,
  next_action text
);

create table if not exists public.nt_f3_company_breakup (
  id text not null,
  url text,
  company_name text,
  ai_software_and_infra numeric,
  b2b_and_manufacturing numeric,
  india_consumption_1 numeric,
  fintech_and_fs numeric,
  deeptech numeric,
  india_consumption_2_3 numeric,
  healthcare numeric,
  other numeric,
  synced_at timestamp with time zone not null
);

create table if not exists public.nt_f3_sector_master (
  id text not null,
  url text,
  deal text,
  f3_sector_classification text,
  investor text[],
  status text,
  created_on date,
  founder_name text,
  founder_linkedin text,
  founder_previous_company text,
  synced_at timestamp with time zone not null
);

create table if not exists public.nt_investor_missing_deals (
  id text not null,
  url text,
  investor text,
  missing_deals numeric,
  company_names text,
  sectors text[],
  synced_at timestamp with time zone not null
);

create table if not exists public.nt_local_snapshot (
  id text not null,
  url text,
  deal text,
  status text,
  f3_classification text,
  sectors text[],
  source text[],
  meeting_date date,
  source_created_time timestamp with time zone,
  source_deal_link text,
  institutional_funding text,
  founder_name text,
  founder_linkedin text,
  previous_company_worked_at text,
  last_synced date,
  founder_1_name text,
  founder_1_linkedin text,
  founder_1_previous_company_worked_at text,
  founder_1_designations text,
  founder_2_name text,
  founder_2_linkedin text,
  founder_2_previous_company_worked_at text,
  founder_2_designations text,
  founder_3_name text,
  founder_3_linkedin text,
  founder_3_previous_company_worked_at text,
  founder_3_designations text,
  founder_4_name text,
  founder_4_linkedin text,
  founder_4_previous_company_worked_at text,
  founder_4_designations text,
  synced_at timestamp with time zone not null
);

create table if not exists public.nt_out_of_coverage_deals (
  id text not null,
  url text,
  name text,
  status text,
  type text,
  f2_classification text,
  f3_classification text,
  sectors text[],
  source text[],
  location text,
  investor_type text,
  risk_evaluation text,
  meeting_date date,
  creation_date timestamp with time zone,
  notes text,
  similar_companies text,
  founder_name text,
  founder_linkedin text,
  previous_companies_worked_at text,
  people text[],
  investors text[],
  sparrow_funds text[],
  synced_at timestamp with time zone not null
);

create table if not exists public.nt_sync_runs (
  id bigint not null,
  source text not null,
  started_at timestamp with time zone not null,
  finished_at timestamp with time zone,
  rows_synced integer,
  rows_removed integer,
  ok boolean,
  error text
);

create table if not exists public.nt_tracxn_rounds (
  id text not null,
  url text,
  company text,
  sector text[],
  round_date date,
  founded_year numeric,
  location text[],
  round_name text,
  round_amount_usd numeric,
  lead_investor text[],
  round_investors text[],
  sparrow_pipeline text,
  synced_at timestamp with time zone not null
);

create table if not exists public.roles (
  id bigint not null,
  founder_key text not null,
  company text,
  title text,
  raw text not null,
  source text not null
);

-- VIEWS
create or replace view public.local_snapshot as
 WITH fd AS (
         SELECT df.deal_id,
            df.slot,
            f.name,
            f.linkedin_url,
            df.previous_company_raw,
            ( SELECT string_agg(r.raw, '; '::text ORDER BY r.id) AS string_agg
                   FROM roles r
                  WHERE (r.founder_key = f.key)) AS designations
           FROM (deal_founders df
             JOIN founders f ON ((f.key = df.founder_key)))
        )
 SELECT d.id AS notion_id,
    d.name AS deal,
    d.status,
    d.f3_classification,
    d.sectors,
    d.meeting_date,
    d.source,
    ( SELECT string_agg(di.investor, ', '::text ORDER BY di.investor) AS string_agg
           FROM deal_investors di
          WHERE (di.deal_id = d.id)) AS institutional_funding,
    ( SELECT string_agg(fd_1.name, ', '::text ORDER BY fd_1.slot) AS string_agg
           FROM fd fd_1
          WHERE (fd_1.deal_id = d.id)) AS founder_names,
    ( SELECT string_agg(fd_1.linkedin_url, ', '::text ORDER BY fd_1.slot) AS string_agg
           FROM fd fd_1
          WHERE (fd_1.deal_id = d.id)) AS founder_linkedins,
    max(fd.name) FILTER (WHERE (fd.slot = 1)) AS founder_1_name,
    max(fd.linkedin_url) FILTER (WHERE (fd.slot = 1)) AS founder_1_linkedin,
    max(fd.previous_company_raw) FILTER (WHERE (fd.slot = 1)) AS founder_1_previous_companies,
    max(fd.designations) FILTER (WHERE (fd.slot = 1)) AS founder_1_designations,
    max(fd.name) FILTER (WHERE (fd.slot = 2)) AS founder_2_name,
    max(fd.linkedin_url) FILTER (WHERE (fd.slot = 2)) AS founder_2_linkedin,
    max(fd.previous_company_raw) FILTER (WHERE (fd.slot = 2)) AS founder_2_previous_companies,
    max(fd.designations) FILTER (WHERE (fd.slot = 2)) AS founder_2_designations,
    max(fd.name) FILTER (WHERE (fd.slot = 3)) AS founder_3_name,
    max(fd.linkedin_url) FILTER (WHERE (fd.slot = 3)) AS founder_3_linkedin,
    max(fd.previous_company_raw) FILTER (WHERE (fd.slot = 3)) AS founder_3_previous_companies,
    max(fd.designations) FILTER (WHERE (fd.slot = 3)) AS founder_3_designations,
    max(fd.name) FILTER (WHERE (fd.slot = 4)) AS founder_4_name,
    max(fd.linkedin_url) FILTER (WHERE (fd.slot = 4)) AS founder_4_linkedin,
    max(fd.previous_company_raw) FILTER (WHERE (fd.slot = 4)) AS founder_4_previous_companies,
    max(fd.designations) FILTER (WHERE (fd.slot = 4)) AS founder_4_designations,
    d.source_created_at,
    d.source_link
   FROM (deals d
     LEFT JOIN fd ON ((fd.deal_id = d.id)))
  GROUP BY d.id
  ORDER BY d.source_created_at;

create or replace materialized view public.mv_founder_employers as
 WITH pipe AS MATERIALIZED (
         SELECT p_1.id,
            p_1.deal,
            p_1.status,
            p_1.meeting_date,
            p_1.f3_classification,
            p_1.sectors,
            p_1.created_time,
            p_1.founder_name,
            NULLIF(p_1.founder_linkedin, ''::text) AS founder_linkedin,
            COALESCE(NULLIF(p_1.previous_company_worked_at, ''::text), NULLIF(p_1.previous_company, ''::text)) AS prev_txt,
            brain_key(p_1.deal) AS k
           FROM nt_deal_pipeline p_1
          WHERE (p_1.deal IS NOT NULL)
        ), raw_ids AS MATERIALIZED (
         SELECT v_raw_data.id
           FROM v_raw_data
        ), snap AS MATERIALIZED (
         SELECT d_1.id,
            d_1.name,
            d_1.status,
            d_1.sectors,
            d_1.f3_classification,
            d_1.source,
            d_1.meeting_date,
            d_1.source_created_at,
            d_1.source_link,
            d_1.synced_at,
            brain_key(d_1.name) AS k
           FROM deals d_1
        ), snap_map AS MATERIALIZED (
         SELECT DISTINCT ON (s.id) s.id AS snap_id,
            p_1.id AS pipe_id
           FROM (snap s
             JOIN pipe p_1 ON ((p_1.k = s.k)))
          ORDER BY s.id, (abs((COALESCE(p_1.meeting_date, '1900-01-01'::date) - COALESCE(s.meeting_date, '1900-01-01'::date)))), p_1.created_time DESC
        ), cmap AS MATERIALIZED (
         SELECT DISTINCT ON (z.key) z.key,
            z.name
           FROM ( SELECT lower(c.name) AS key,
                    c.name,
                    1 AS o
                   FROM companies c
                UNION ALL
                 SELECT lower(a.a) AS lower,
                    c.name,
                    2
                   FROM (companies c
                     CROSS JOIN LATERAL unnest(c.aliases) a(a))) z
          ORDER BY z.key, z.o
        ), splits AS (
         SELECT p_1.id AS pipe_id,
            NULL::text AS snap_id,
            ('deal:'::text || p_1.id) AS founder_key,
            p_1.founder_name AS founder,
            p_1.founder_linkedin AS linkedin_url,
            TRIM(BOTH FROM x_1.x) AS company_raw,
            NULL::text AS title,
            'notion_pipeline'::text AS via,
            3 AS pri
           FROM (pipe p_1
             CROSS JOIN LATERAL regexp_split_to_table(COALESCE(p_1.prev_txt, ''::text), '\s*[,;\n]\s*'::text) x_1(x))
          WHERE (TRIM(BOTH FROM x_1.x) <> ''::text)
        UNION ALL
         SELECT m.pipe_id,
            df.deal_id,
            df.founder_key,
            f.name,
            f.linkedin_url,
            TRIM(BOTH FROM x_1.x) AS btrim,
            NULL::text,
            'notion_founder_previous_company'::text,
            2
           FROM (((deal_founders df
             JOIN founders f ON ((f.key = df.founder_key)))
             LEFT JOIN snap_map m ON ((m.snap_id = df.deal_id)))
             CROSS JOIN LATERAL regexp_split_to_table(COALESCE(df.previous_company_raw, ''::text), '\s*[,;\n]\s*'::text) x_1(x))
          WHERE (TRIM(BOTH FROM x_1.x) <> ''::text)
        UNION ALL
         SELECT m.pipe_id,
            df.deal_id,
            ro.founder_key,
            f.name,
            f.linkedin_url,
            ro.company,
            ro.title,
            'linkedin'::text,
            1
           FROM (((roles ro
             JOIN deal_founders df ON ((df.founder_key = ro.founder_key)))
             JOIN founders f ON ((f.key = ro.founder_key)))
             LEFT JOIN snap_map m ON ((m.snap_id = df.deal_id)))
        ), canon AS (
         SELECT s.pipe_id,
            s.snap_id,
            s.founder_key,
            s.founder,
            s.linkedin_url,
            s.company_raw,
            s.title,
            s.via,
            s.pri,
            COALESCE(c.name, s.company_raw) AS company
           FROM (splits s
             LEFT JOIN cmap c ON ((c.key = lower(s.company_raw))))
        ), dedup AS (
         SELECT DISTINCT ON (COALESCE(canon.pipe_id, canon.snap_id), (lower(TRIM(BOTH FROM split_part(canon.company, ','::text, 1))))) canon.pipe_id,
            canon.snap_id,
            canon.founder_key,
            canon.founder,
            canon.linkedin_url,
            canon.company_raw,
            canon.title,
            canon.via,
            canon.pri,
            canon.company
           FROM canon
          ORDER BY COALESCE(canon.pipe_id, canon.snap_id), (lower(TRIM(BOTH FROM split_part(canon.company, ','::text, 1)))), canon.pri, (canon.title IS NULL)
        )
 SELECT COALESCE(x.pipe_id, x.snap_id) AS deal_id,
    COALESCE(p.deal, d.name) AS deal,
    COALESCE(p.status, d.status) AS status,
    COALESCE(p.meeting_date, d.meeting_date) AS meeting_date,
    COALESCE(p.f3_classification, d.f3_classification) AS f3_classification,
    COALESCE(p.sectors, d.sectors) AS sectors,
    x.founder_key,
    x.founder,
    x.linkedin_url,
    x.company,
    x.title,
    x.via,
    (x.linkedin_url IS NOT NULL) AS has_linkedin,
        CASE
            WHEN (x.pipe_id IS NOT NULL) THEN 'pipeline'::text
            ELSE 'snapshot'::text
        END AS source,
    (p.created_time)::date AS created_date,
    (EXISTS ( SELECT 1
           FROM raw_ids r
          WHERE (r.id = x.pipe_id))) AS in_raw_data
   FROM ((dedup x
     LEFT JOIN pipe p ON ((p.id = x.pipe_id)))
     LEFT JOIN deals d ON ((d.id = x.snap_id)));

create or replace materialized view public.mv_founder_employers_v2 as
 WITH pipe AS MATERIALIZED (
         SELECT p_1.id,
            p_1.deal,
            p_1.status,
            p_1.meeting_date,
            p_1.f3_classification,
            p_1.sectors,
            p_1.created_time,
            p_1.founder_name,
            NULLIF(p_1.founder_linkedin, ''::text) AS founder_linkedin,
            COALESCE(NULLIF(p_1.previous_company_worked_at, ''::text), NULLIF(p_1.previous_company, ''::text)) AS prev_txt,
            brain_key(p_1.deal) AS k
           FROM nt_deal_pipeline p_1
          WHERE (p_1.deal IS NOT NULL)
        ), raw_ids AS MATERIALIZED (
         SELECT v_raw_data.id
           FROM v_raw_data
        ), snap AS MATERIALIZED (
         SELECT d_1.id,
            d_1.name,
            d_1.status,
            d_1.sectors,
            d_1.f3_classification,
            d_1.source,
            d_1.meeting_date,
            d_1.source_created_at,
            d_1.source_link,
            d_1.synced_at,
            brain_key(d_1.name) AS k
           FROM deals d_1
        ), snap_map AS MATERIALIZED (
         SELECT DISTINCT ON (s.id) s.id AS snap_id,
            p_1.id AS pipe_id
           FROM (snap s
             JOIN pipe p_1 ON ((p_1.k = s.k)))
          ORDER BY s.id, (abs((COALESCE(p_1.meeting_date, '1900-01-01'::date) - COALESCE(s.meeting_date, '1900-01-01'::date)))), p_1.created_time DESC
        ), cmap AS MATERIALIZED (
         SELECT DISTINCT ON (z.key) z.key,
            z.name
           FROM ( SELECT lower(c.name) AS key,
                    c.name,
                    1 AS o
                   FROM companies c
                UNION ALL
                 SELECT lower(a.a) AS lower,
                    c.name,
                    2
                   FROM (companies c
                     CROSS JOIN LATERAL unnest(c.aliases) a(a))) z
          ORDER BY z.key, z.o
        ), splits AS (
         SELECT p_1.id AS pipe_id,
            NULL::text AS snap_id,
            ('deal:'::text || p_1.id) AS founder_key,
            p_1.founder_name AS founder,
            p_1.founder_linkedin AS linkedin_url,
            TRIM(BOTH FROM x_1.x) AS company_raw,
            NULL::text AS title,
            'notion_pipeline'::text AS via,
            3 AS pri
           FROM (pipe p_1
             CROSS JOIN LATERAL regexp_split_to_table(COALESCE(p_1.prev_txt, ''::text), '\s*[,;\n]\s*'::text) x_1(x))
          WHERE (TRIM(BOTH FROM x_1.x) <> ''::text)
        UNION ALL
         SELECT m.pipe_id,
            df.deal_id,
            df.founder_key,
            f.name,
            f.linkedin_url,
            TRIM(BOTH FROM x_1.x) AS btrim,
            NULL::text,
            'notion_founder_previous_company'::text,
            2
           FROM (((deal_founders df
             JOIN founders f ON ((f.key = df.founder_key)))
             LEFT JOIN snap_map m ON ((m.snap_id = df.deal_id)))
             CROSS JOIN LATERAL regexp_split_to_table(COALESCE(df.previous_company_raw, ''::text), '\s*[,;\n]\s*'::text) x_1(x))
          WHERE (TRIM(BOTH FROM x_1.x) <> ''::text)
        UNION ALL
         SELECT m.pipe_id,
            df.deal_id,
            ro.founder_key,
            f.name,
            f.linkedin_url,
            ro.company,
            ro.title,
            'linkedin'::text,
            1
           FROM (((roles ro
             JOIN deal_founders df ON ((df.founder_key = ro.founder_key)))
             JOIN founders f ON ((f.key = ro.founder_key)))
             LEFT JOIN snap_map m ON ((m.snap_id = df.deal_id)))
        ), canon AS MATERIALIZED (
         SELECT s.pipe_id,
            s.snap_id,
            s.founder_key,
            s.founder,
            s.linkedin_url,
            s.company_raw,
            s.title,
            s.via,
            s.pri,
            COALESCE(c.name, s.company_raw) AS company
           FROM (splits s
             LEFT JOIN cmap c ON ((c.key = lower(s.company_raw))))
        ), labeled AS MATERIALIZED (
         SELECT c.pipe_id,
            c.snap_id,
            c.founder_key,
            c.founder,
            c.linkedin_url,
            c.company_raw,
            c.title,
            c.via,
            c.pri,
            c.company,
            ce.entity,
            ce.parent_group,
            ce.status AS entity_status,
            ce.domain AS entity_domain,
            ce.entity_type
           FROM (canon c
             LEFT JOIN company_entities ce ON ((ce.name = c.company)))
        ), dedup AS (
         SELECT DISTINCT ON (COALESCE(labeled.pipe_id, labeled.snap_id), (lower(COALESCE(labeled.entity, labeled.company)))) labeled.pipe_id,
            labeled.snap_id,
            labeled.founder_key,
            labeled.founder,
            labeled.linkedin_url,
            labeled.company_raw,
            labeled.title,
            labeled.via,
            labeled.pri,
            labeled.company,
            labeled.entity,
            labeled.parent_group,
            labeled.entity_status,
            labeled.entity_domain,
            labeled.entity_type
           FROM labeled
          ORDER BY COALESCE(labeled.pipe_id, labeled.snap_id), (lower(COALESCE(labeled.entity, labeled.company))), labeled.pri, (labeled.title IS NULL)
        )
 SELECT COALESCE(x.pipe_id, x.snap_id) AS deal_id,
    COALESCE(p.deal, d.name) AS deal,
    COALESCE(p.status, d.status) AS status,
    COALESCE(p.meeting_date, d.meeting_date) AS meeting_date,
    COALESCE(p.f3_classification, d.f3_classification) AS f3_classification,
    COALESCE(p.sectors, d.sectors) AS sectors,
    x.founder_key,
    x.founder,
    x.linkedin_url,
    x.company,
    x.title,
    x.via,
    (x.linkedin_url IS NOT NULL) AS has_linkedin,
        CASE
            WHEN (x.pipe_id IS NOT NULL) THEN 'pipeline'::text
            ELSE 'snapshot'::text
        END AS source,
    (p.created_time)::date AS created_date,
    (x.pipe_id IN ( SELECT raw_ids.id
           FROM raw_ids)) AS in_raw_data,
    COALESCE(x.entity, x.company) AS entity,
    COALESCE(x.parent_group, x.entity, x.company) AS parent_group,
    COALESCE(x.entity_status, 'unchecked'::text) AS entity_status,
    x.entity_domain,
    x.entity_type
   FROM ((dedup x
     LEFT JOIN pipe p ON ((p.id = x.pipe_id)))
     LEFT JOIN deals d ON ((d.id = x.snap_id)));

create or replace view public.v_alumni_sector_patterns as
 WITH fr AS (
         SELECT DISTINCT e.entity AS company,
            e.founder_key,
            e.deal_id,
            e.deal,
            e.status,
            e.f3_classification,
            e.sectors
           FROM mv_founder_employers_v2 e
          WHERE ((e.entity_status <> 'unresolved'::text) AND (e.company <> ALL (ARRAY['selfemployed'::text, 'Self'::text, 'Self-employed'::text, 'Freelance'::text])))
        )
 SELECT fr.company,
    s.sector,
    count(DISTINCT fr.founder_key) AS founders,
    count(DISTINCT fr.deal_id) AS startups,
    count(DISTINCT fr.deal_id) FILTER (WHERE (fr.status = 'Pass'::text)) AS passed,
    count(DISTINCT fr.deal_id) FILTER (WHERE (fr.status = 'To be Passed'::text)) AS to_be_passed,
    array_agg(DISTINCT fr.deal) AS startup_names
   FROM (fr
     CROSS JOIN LATERAL unnest(
        CASE
            WHEN (cardinality(fr.sectors) > 0) THEN fr.sectors
            ELSE ARRAY['Unclassified'::text]
        END) s(sector))
  GROUP BY fr.company, s.sector;

create or replace view public.v_deal_content as
 SELECT c.page_id,
    COALESCE(p.deal, c.deal) AS deal,
    p.status,
    p.sectors,
    p.f3_classification,
    p.meeting_date,
    c.meetings,
    c.meeting_dates,
    c.summary,
    c.meeting_notes,
    c.page_notes,
    length(c.transcript) AS transcript_chars,
    c.transcript,
    c.fetched_at,
    p.url
   FROM (nt_deal_content c
     LEFT JOIN nt_deal_pipeline p ON ((p.id = c.page_id)));

create or replace view public.v_f3_company_breakup as
 SELECT company_name,
    (((((((COALESCE(ai_software_and_infra, (0)::numeric) + COALESCE(b2b_and_manufacturing, (0)::numeric)) + COALESCE(india_consumption_1, (0)::numeric)) + COALESCE(fintech_and_fs, (0)::numeric)) + COALESCE(deeptech, (0)::numeric)) + COALESCE(india_consumption_2_3, (0)::numeric)) + COALESCE(healthcare, (0)::numeric)) + COALESCE(other, (0)::numeric)) AS total,
    ai_software_and_infra,
    b2b_and_manufacturing,
    india_consumption_1,
    fintech_and_fs,
    deeptech,
    india_consumption_2_3,
    healthcare,
    other,
    id,
    url
   FROM nt_f3_company_breakup
  ORDER BY company_name;

create or replace view public.v_f3_sector_super_master as
 SELECT deal,
    f3_sector_classification,
    investor,
    status,
    created_on,
    founder_name,
    founder_linkedin,
    founder_previous_company,
    id,
    url
   FROM nt_f3_sector_master;

create or replace view public.v_founder_career as
 SELECT key AS founder_key,
    name,
    linkedin_url,
    COALESCE(( SELECT array_agg(DISTINCT e.entity) AS array_agg
           FROM mv_founder_employers_v2 e
          WHERE ((e.founder_key = f.key) AND (e.entity_status <> 'unresolved'::text))), '{}'::text[]) AS companies,
    COALESCE(( SELECT string_agg((COALESCE((NULLIF(r.title, ''::text) || ' at '::text), ''::text) || COALESCE(r.company, r.raw)), '; '::text ORDER BY r.id) AS string_agg
           FROM roles r
          WHERE (r.founder_key = f.key)), ( SELECT ('Previously at: '::text || string_agg(DISTINCT e.entity, ', '::text))
           FROM mv_founder_employers_v2 e
          WHERE ((e.founder_key = f.key) AND (e.entity_status <> 'unresolved'::text)))) AS career
   FROM founders f;

create or replace view public.v_founder_employers as
 SELECT deal_id,
    deal,
    status,
    meeting_date,
    f3_classification,
    sectors,
    founder_key,
    founder,
    linkedin_url,
    company,
    title,
    via,
    has_linkedin,
    source,
    created_date,
    in_raw_data,
    entity,
    parent_group,
    entity_status,
    entity_domain,
    entity_type
   FROM mv_founder_employers_v2;

create or replace view public.v_investor_missing_deals as
 SELECT investor,
    missing_deals,
    company_names,
    sectors,
    id,
    url
   FROM nt_investor_missing_deals;

create or replace view public.v_local_snapshot as
 SELECT deal,
    status,
    f3_classification,
    sectors,
    meeting_date,
    source,
    institutional_funding,
    founder_name,
    founder_linkedin,
    previous_company_worked_at,
    founder_1_name,
    founder_1_linkedin,
    founder_1_previous_company_worked_at,
    founder_1_designations,
    founder_2_name,
    founder_2_linkedin,
    founder_2_previous_company_worked_at,
    founder_2_designations,
    founder_3_name,
    founder_3_linkedin,
    founder_3_previous_company_worked_at,
    founder_3_designations,
    founder_4_name,
    founder_4_linkedin,
    founder_4_previous_company_worked_at,
    founder_4_designations,
    source_created_time,
    source_deal_link,
    last_synced,
    id,
    url
   FROM nt_local_snapshot
  ORDER BY source_created_time;

create or replace view public.v_out_of_coverage_deals as
 SELECT name,
    sparrow_funds,
    f3_classification,
    type,
    notes,
    investors,
    creation_date,
    f2_classification,
    investor_type,
    location,
    meeting_date,
    people,
    risk_evaluation,
    sectors,
    similar_companies,
    source,
    status,
    founder_name,
    founder_linkedin,
    previous_companies_worked_at,
    id,
    url
   FROM nt_out_of_coverage_deals;

create or replace view public.v_raw_data as
 SELECT deal,
    created_time,
    status,
    antiportfolio,
    similar_companies,
    created_by,
    meeting_date,
    (CURRENT_DATE - meeting_date) AS days_since_first_meeting,
    re_pipeline_date,
    re_pipeline_reason,
    follow_up_date,
    location,
    f3_classification,
    sectors,
    risk_evaluation,
    description,
    people,
    source,
    deal_attribution,
    sourcing_network_nodes,
    decision_to_pass_stage,
    pass_type,
    founder_pass_vectors,
    institutional_funding,
    comments,
    decision_audit,
    what_stood_out,
    what_to_check,
    view_1y,
    view_3y,
    view_5y,
    view_10y,
    acquihire,
    decision_audit_check,
    f2_classification,
    documents,
    documents_link,
    email,
    im_link,
    founder_linkedin,
    founder_name,
    type,
    previous_company_worked_at,
    "select",
    id,
    url
   FROM nt_deal_pipeline
  WHERE ((status = ANY (ARRAY['Pass'::text, 'To be Passed'::text])) AND (created_by IS DISTINCT FROM 'notion_user-8ff29d03-de52-41cb-981c-809ad7af9529'::text) AND (NOT ('Sales Nav + LinkedIn'::text = ANY (COALESCE(source, '{}'::text[])))));

create or replace view public.v_raw_data_content as
 SELECT r.deal,
    r.created_time,
    r.status,
    r.antiportfolio,
    r.similar_companies,
    r.created_by,
    r.meeting_date,
    r.days_since_first_meeting,
    r.re_pipeline_date,
    r.re_pipeline_reason,
    r.follow_up_date,
    r.location,
    r.f3_classification,
    r.sectors,
    r.risk_evaluation,
    r.description,
    r.people,
    r.source,
    r.deal_attribution,
    r.sourcing_network_nodes,
    r.decision_to_pass_stage,
    r.pass_type,
    r.founder_pass_vectors,
    r.institutional_funding,
    r.comments,
    r.decision_audit,
    r.what_stood_out,
    r.what_to_check,
    r.view_1y,
    r.view_3y,
    r.view_5y,
    r.view_10y,
    r.acquihire,
    r.decision_audit_check,
    r.f2_classification,
    r.documents,
    r.documents_link,
    r.email,
    r.im_link,
    r.founder_linkedin,
    r.founder_name,
    r.type,
    r.previous_company_worked_at,
    r."select",
    r.id,
    r.url,
    c.meetings,
    c.meeting_dates,
    c.summary,
    c.meeting_notes,
    c.page_notes,
    c.transcript,
    length(c.transcript) AS transcript_chars,
    c.page_last_edited_at AS content_edited_at,
    c.fetched_at AS content_fetched_at,
        CASE
            WHEN (NULLIF(c.transcript, ''::text) IS NOT NULL) THEN 'transcript'::text
            WHEN (NULLIF(c.summary, ''::text) IS NOT NULL) THEN 'summary only'::text
            WHEN ((NULLIF(c.page_notes, ''::text) IS NOT NULL) OR (NULLIF(c.meeting_notes, ''::text) IS NOT NULL)) THEN 'notes only'::text
            ELSE 'blank page'::text
        END AS content_level
   FROM (v_raw_data r
     LEFT JOIN nt_deal_content c ON ((c.page_id = r.id)));

create or replace view public.v_sector_wise_f3 as
 SELECT deal,
    created_time,
    f3_classification,
    founder_name,
    previous_company_worked_at,
    "select",
    institutional_funding,
    id,
    url
   FROM v_raw_data
  ORDER BY f3_classification, deal;

create or replace view public.v_startup_universe as
 WITH names AS (
         SELECT brain_key(nt_deal_pipeline.deal) AS k,
            nt_deal_pipeline.deal AS name,
            'pipeline'::text AS src
           FROM nt_deal_pipeline
        UNION ALL
         SELECT brain_key(deals.name) AS brain_key,
            deals.name,
            'model'::text
           FROM deals
        UNION ALL
         SELECT brain_key(nt_tracxn_rounds.company) AS brain_key,
            nt_tracxn_rounds.company,
            'tracxn'::text
           FROM nt_tracxn_rounds
        UNION ALL
         SELECT brain_key(nt_out_of_coverage_deals.name) AS brain_key,
            nt_out_of_coverage_deals.name,
            'out_of_coverage'::text
           FROM nt_out_of_coverage_deals
        UNION ALL
         SELECT brain_key(nt_f3_sector_master.deal) AS brain_key,
            nt_f3_sector_master.deal,
            'f3_master'::text
           FROM nt_f3_sector_master
        UNION ALL
         SELECT brain_key(TRIM(BOTH FROM c.c)) AS brain_key,
            TRIM(BOTH FROM c.c) AS btrim,
            'investor_missed'::text
           FROM nt_investor_missing_deals m,
            LATERAL regexp_split_to_table(COALESCE(m.company_names, ''::text), '\s*[,;\n]\s*'::text) c(c)
          WHERE (TRIM(BOTH FROM c.c) <> ''::text)
        ), k AS (
         SELECT names.k,
            (array_agg(names.name ORDER BY (length(names.name))))[1] AS name,
            array_agg(DISTINCT names.src) AS sources
           FROM names
          WHERE (names.k IS NOT NULL)
          GROUP BY names.k
        ), pipe AS (
         SELECT DISTINCT ON ((brain_key(nt_deal_pipeline.deal))) brain_key(nt_deal_pipeline.deal) AS k,
            nt_deal_pipeline.id,
            nt_deal_pipeline.status,
            nt_deal_pipeline.f3_classification,
            nt_deal_pipeline.sectors,
            nt_deal_pipeline.decision_to_pass_stage,
            nt_deal_pipeline.meeting_date
           FROM nt_deal_pipeline
          ORDER BY (brain_key(nt_deal_pipeline.deal)), nt_deal_pipeline.created_time DESC NULLS LAST
        ), tr AS (
         SELECT brain_key(nt_tracxn_rounds.company) AS k,
            count(*) AS rounds,
            max(nt_tracxn_rounds.round_date) AS last_round_date,
            (array_agg(nt_tracxn_rounds.round_name ORDER BY nt_tracxn_rounds.round_date DESC NULLS LAST))[1] AS last_round,
            sum(nt_tracxn_rounds.round_amount_usd) AS total_raised_usd,
            (array_agg(nt_tracxn_rounds.sparrow_pipeline ORDER BY nt_tracxn_rounds.round_date DESC NULLS LAST))[1] AS sparrow_pipeline,
            array_agg(DISTINCT i.i) FILTER (WHERE (i.i IS NOT NULL)) AS investors
           FROM (nt_tracxn_rounds
             LEFT JOIN LATERAL unnest((COALESCE(nt_tracxn_rounds.round_investors, '{}'::text[]) || COALESCE(nt_tracxn_rounds.lead_investor, '{}'::text[]))) i(i) ON (true))
          GROUP BY (brain_key(nt_tracxn_rounds.company))
        ), miss AS (
         SELECT brain_key(TRIM(BOTH FROM c.c)) AS k,
            array_agg(DISTINCT m.investor) AS missed_by
           FROM nt_investor_missing_deals m,
            LATERAL regexp_split_to_table(COALESCE(m.company_names, ''::text), '\s*[,;\n]\s*'::text) c(c)
          WHERE (TRIM(BOTH FROM c.c) <> ''::text)
          GROUP BY (brain_key(TRIM(BOTH FROM c.c)))
        ), f3m AS (
         SELECT DISTINCT ON ((brain_key(nt_f3_sector_master.deal))) brain_key(nt_f3_sector_master.deal) AS k,
            nt_f3_sector_master.f3_sector_classification,
            nt_f3_sector_master.status
           FROM nt_f3_sector_master
          ORDER BY (brain_key(nt_f3_sector_master.deal)), nt_f3_sector_master.created_on DESC NULLS LAST
        )
 SELECT k.k AS key,
    k.name,
    k.sources,
    (pipe.id IS NOT NULL) AS in_pipeline,
    pipe.id AS pipeline_id,
    pipe.status AS pipeline_status,
    pipe.decision_to_pass_stage,
    COALESCE(pipe.f3_classification, f3m.f3_sector_classification) AS f3_classification,
    pipe.sectors,
    pipe.meeting_date,
    tr.rounds,
    tr.last_round,
    tr.last_round_date,
    tr.total_raised_usd,
    tr.sparrow_pipeline,
    tr.investors AS tracxn_investors,
    ('out_of_coverage'::text = ANY (k.sources)) AS out_of_coverage,
    miss.missed_by,
    ((tr.k IS NOT NULL) AND (pipe.id IS NULL)) AS funded_but_never_seen
   FROM ((((k
     LEFT JOIN pipe ON ((pipe.k = k.k)))
     LEFT JOIN tr ON ((tr.k = k.k)))
     LEFT JOIN miss ON ((miss.k = k.k)))
     LEFT JOIN f3m ON ((f3m.k = k.k)));

create or replace view public.v_tracxn_fund as
 SELECT company,
    sector,
    round_date,
    founded_year,
    location,
    round_name,
    round_amount_usd,
    lead_investor,
    round_investors,
    sparrow_pipeline,
    id,
    url
   FROM nt_tracxn_rounds;

-- FUNCTIONS
CREATE OR REPLACE FUNCTION public.ask_meta()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  select jsonb_build_object(
    'data_as_of', (select max(finished_at) from nt_sync_runs where ok and source = 'pipeline'),
    'syncs', (select jsonb_object_agg(source, at) from (select source, max(finished_at) at from nt_sync_runs where ok group by source) z),
    'deals', (select count(*) from nt_deal_pipeline),
    'raw_data', (select count(*) from v_raw_data),
    'with_transcript', (select count(*) from nt_deal_content where nullif(transcript,'') is not null))
$function$
;

CREATE OR REPLACE FUNCTION public.ask_quota(p_client text)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  with s as (select value::jsonb v from brain_config where key='ask_settings')
  select v || jsonb_build_object(
    'enabled', coalesce((v->>'enabled')::boolean, true),
    'client_used', (select count(*) from ask_log where client_id = p_client and created_at > now() - interval '24 hours' and error is null),
    'client_limit', (v->>'per_client_day')::int,
    'global_used', (select count(*) from ask_log where created_at > now() - interval '24 hours' and error is null),
    'global_limit', (v->>'global_day')::int) from s
$function$
;

CREATE OR REPLACE FUNCTION public.brain_call(payload jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public', 'extensions'
AS $function$
declare r extensions.http_response; u text; s text; j text;
begin
  select value into u from brain_config where key = 'embed_url';
  select value into s from brain_config where key = 'embed_secret';
  select value into j from brain_config where key = 'embed_jwt';
  perform extensions.http_set_curlopt('CURLOPT_TIMEOUT_MS', '140000');
  select * into r from extensions.http((
    'POST', u,
    array[extensions.http_header('Authorization', 'Bearer ' || j), extensions.http_header('x-brain-secret', s)],
    'application/json', payload::text)::extensions.http_request);
  if r.status <> 200 then
    raise exception 'brain-embed returned %: %', r.status, left(r.content, 300);
  end if;
  return r.content::jsonb;
end $function$
;

CREATE OR REPLACE FUNCTION public.brain_chunks(t text, size integer DEFAULT 1600)
 RETURNS TABLE(idx integer, chunk text)
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO ''
AS $function$
declare line text; buf text := ''; i int := 0; piece text;
begin
  if t is null or btrim(t) = '' then return; end if;
  foreach line in array regexp_split_to_array(t, E'\n') loop
    line := btrim(line);
    continue when line = '';
    while length(line) > size loop
      piece := left(line, size);
      -- cut at the last sentence end or space inside the window
      piece := coalesce(substring(piece from '^(.*[.!?])\s'), substring(piece from '^(.*)\s'), piece);
      if length(buf) > 0 then i := i + 1; idx := i; chunk := buf; return next; buf := ''; end if;
      i := i + 1; idx := i; chunk := piece; return next;
      line := btrim(substr(line, length(piece) + 1));
    end loop;
    if length(buf) + length(line) + 1 > size and length(buf) > 0 then
      i := i + 1; idx := i; chunk := buf; return next; buf := '';
    end if;
    buf := case when buf = '' then line else buf || E'\n' || line end;
  end loop;
  if length(buf) > 0 then i := i + 1; idx := i; chunk := buf; return next; end if;
end $function$
;

CREATE OR REPLACE FUNCTION public.brain_context(q text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public', 'extensions'
AS $function$
declare rules jsonb; hits jsonb := '[]';
begin
  select coalesce(jsonb_agg(rule order by created_at), '[]') into rules
    from (select rule, created_at from brain_rules where active order by created_at desc limit 40) r;
  if exists (select 1 from brain_vec where kind in ('insight', 'answer_example')) then
    select coalesce(jsonb_agg(jsonb_build_object('kind', kind, 'title', title, 'text', snippet, 'similarity', round(similarity::numeric, 3))), '[]') into hits
      from public.brain_search(q, 8, array['insight', 'answer_example']) s
     where coalesce(s.similarity, 0) >= 0.78;
  end if;
  return jsonb_build_object('rules', rules, 'memory', hits);
end $function$
;

CREATE OR REPLACE FUNCTION public.brain_embed_pending(batch integer DEFAULT 20)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'public', 'extensions'
AS $function$
  select public.brain_call(jsonb_build_object('mode', 'pending', 'limit', batch, 'budget_ms', 1400))
$function$
;

CREATE OR REPLACE FUNCTION public.brain_embed_query(q text)
 RETURNS vector
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
#variable_conflict use_column
declare k text := lower(btrim(regexp_replace(q, '\s+', ' ', 'g'))); e vector(384);
begin
  select c.embedding into e from brain_qcache c where c.q = k;
  if e is not null then
    begin
      update brain_qcache c set used_at = now() where c.q = k and c.used_at < now() - interval '1 day';
    exception when others then null; -- read-only callers (team app) just skip the cache touch
    end;
    return e;
  end if;
  e := (public.brain_call(jsonb_build_object('mode', 'query', 'text', $1)) -> 'embedding')::text::vector(384);
  begin
    insert into brain_qcache as c (q, embedding) values (k, e) on conflict on constraint brain_qcache_pkey do update set used_at = now();
    execute 'del' || 'ete from brain_qcache where used_at < now() - interval ''30 days''';
  exception when others then null;
  end;
  return e;
end $function$
;

CREATE OR REPLACE FUNCTION public.brain_embed_tick()
 RETURNS integer
 LANGUAGE plpgsql
 SET search_path TO 'public', 'extensions'
AS $function$
declare t0 timestamptz := clock_timestamp(); r jsonb; n int := 0; fails int := 0;
begin
  while exists (select 1 from brain_docs where embedding is null) and clock_timestamp() - t0 < interval '50 seconds' loop
    begin
      r := public.brain_embed_pending(20);
      n := n + coalesce((r->>'embedded')::int, 0); fails := 0;
    exception when others then
      fails := fails + 1; exit when fails >= 5; perform pg_sleep(1);
    end;
  end loop;
  return n;
end $function$
;

CREATE OR REPLACE FUNCTION public.brain_http(url_key text, payload jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public', 'extensions'
AS $function$
declare r extensions.http_response; u text; s text; j text;
begin
  select value into u from brain_config where key = url_key;
  select value into s from brain_config where key = 'embed_secret';
  select value into j from brain_config where key = 'embed_jwt';
  perform extensions.http_set_curlopt('CURLOPT_TIMEOUT_MS', '150000');
  select * into r from extensions.http(('POST', u,
    array[extensions.http_header('Authorization', 'Bearer ' || j), extensions.http_header('x-brain-secret', s)],
    'application/json', payload::text)::extensions.http_request);
  if r.status <> 200 then raise exception '% returned %: %', url_key, r.status, left(r.content, 300); end if;
  return r.content::jsonb;
end $function$
;

CREATE OR REPLACE FUNCTION public.brain_key(t text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE PARALLEL SAFE
AS $function$
  select nullif(
    pg_catalog.regexp_replace(
      pg_catalog.regexp_replace(
        pg_catalog.regexp_replace(
          pg_catalog.replace(pg_catalog.lower(pg_catalog.btrim(coalesce(t, ''))), '&', 'and'),
          '\.(ai|io|com|in|co|app|xyz|so|tech|one|club|dev|org|net|me)$', ''),
        '[^a-z0-9]', '', 'g'),
      '(privatelimited|pvtltd|limited|ltd|inc|llp|technologies|technology|labs|hq|india)$', ''),
  '')
$function$
;

CREATE OR REPLACE FUNCTION public.brain_memory_doc(kind text, item_id bigint)
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare t text; b text; m jsonb;
begin
  if kind = 'insight' then
    select i.title, concat_ws(E'\n', 'Team insight (saved ' || i.created_at::date || '): ' || i.title, i.insight,
             'Evidence: ' || i.evidence, 'Original question: ' || i.question),
           jsonb_build_object('insight_id', i.id, 'saved', i.created_at::date)
      into t, b, m from brain_insights i where i.id = item_id and i.active;
    if t is null then delete from brain_docs where id = 'insight:' || item_id; return; end if;
    insert into brain_docs (id, kind, title, body, metadata, content_hash) values ('insight:' || item_id, 'insight', t, b, m, md5(t || E'\n' || b))
    on conflict (id) do update set title = excluded.title, body = excluded.body, metadata = excluded.metadata, content_hash = excluded.content_hash,
      embedding = case when brain_docs.content_hash = excluded.content_hash then brain_docs.embedding end, updated_at = now();
  elsif kind = 'answer_example' then
    select left(f.question, 200), concat_ws(E'\n', 'Question the team asked: ' || f.question, 'Answer the team marked as good (' || f.created_at::date || '): ' || left(f.answer, 1500),
             'How it was answered (query): ' || left(f.sql, 1200)),
           jsonb_build_object('feedback_id', f.id, 'rated', f.created_at::date)
      into t, b, m from brain_feedback f where f.id = item_id and f.rating = 1;
    if t is null then delete from brain_docs where id = 'example:' || item_id; return; end if;
    insert into brain_docs (id, kind, title, body, metadata, content_hash) values ('example:' || item_id, 'answer_example', t, b, m, md5(t || E'\n' || b))
    on conflict (id) do update set title = excluded.title, body = excluded.body, metadata = excluded.metadata, content_hash = excluded.content_hash,
      embedding = case when brain_docs.content_hash = excluded.content_hash then brain_docs.embedding end, updated_at = now();
  end if;
end $function$
;

CREATE OR REPLACE FUNCTION public.brain_memory_list()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  select jsonb_build_object(
    'rules', coalesce((select jsonb_agg(jsonb_build_object('id', id, 'rule', rule, 'active', active, 'source', source, 'created', created_at::date) order by created_at desc) from brain_rules), '[]'),
    'insights', coalesce((select jsonb_agg(jsonb_build_object('id', id, 'title', title, 'insight', insight, 'evidence', evidence, 'active', active, 'created', created_at::date) order by created_at desc) from brain_insights), '[]'),
    'examples', coalesce((select jsonb_agg(jsonb_build_object('id', id, 'question', question, 'created', created_at::date) order by created_at desc) from brain_feedback where rating = 1), '[]'),
    'feedback', jsonb_build_object('up', (select count(*) from brain_feedback where rating = 1), 'down', (select count(*) from brain_feedback where rating = -1)),
    'last_sync', (select jsonb_agg(x order by x->>'source') from (select distinct on (source) jsonb_build_object('source', source, 'at', finished_at, 'ok', ok, 'rows', rows_synced, 'note', error) x from nt_sync_runs order by source, finished_at desc) z)
  )
$function$
;

CREATE OR REPLACE FUNCTION public.brain_memory_update(p jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare k text := p->>'kind'; a text := p->>'action'; i bigint := (p->>'id')::bigint; nid bigint;
begin
  if k = 'rule' and a = 'add' then
    if nullif(btrim(p->>'text'), '') is null then raise exception 'Rule text is required'; end if;
    insert into brain_rules(rule, source) values (left(btrim(p->>'text'), 600), 'manual') returning id into nid;
    return jsonb_build_object('rule_id', nid);
  elsif k = 'rule' then
    if a = 'delete' then delete from brain_rules where id = i; else update brain_rules set active = (a = 'on') where id = i; end if;
  elsif k = 'insight' then
    if a = 'delete' then delete from brain_insights where id = i; else update brain_insights set active = (a = 'on') where id = i; end if;
    perform brain_memory_doc('insight', i);
  elsif k = 'example' and a = 'delete' then
    update brain_feedback set rating = -1, correction = coalesce(correction, '(removed from examples)') where id = i;
    perform brain_memory_doc('answer_example', i);
  else raise exception 'Unsupported memory update';
  end if;
  return jsonb_build_object('ok', true);
end $function$
;

CREATE OR REPLACE FUNCTION public.brain_prefetch(q text, k integer DEFAULT 8)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public', 'extensions'
AS $function$
declare rules jsonb; mem jsonb := '[]'; hits jsonb := '[]';
begin
  select coalesce(jsonb_agg(rule order by created_at), '[]') into rules
    from (select rule, created_at from brain_rules where active order by created_at desc limit 40) r;
  begin
    select coalesce(jsonb_agg(jsonb_build_object('kind', kind, 'title', title, 'text', snippet, 'similarity', round(similarity::numeric, 3))), '[]') into mem
      from public.brain_search(q, 6, array['insight', 'answer_example']) s
     where coalesce(s.similarity, 0) >= 0.78;
    select coalesce(jsonb_agg(jsonb_build_object('kind', kind, 'name', coalesce(metadata->>'name', title), 'status', metadata->>'status',
             'meeting_date', metadata->>'meeting_date', 'id', id, 'snippet', left(snippet, 420)) order by score desc), '[]') into hits
      from public.brain_search(q, k, array['deal', 'call_summary', 'call_notes', 'founder', 'alumni_pattern', 'funding_round']) s;
  exception when others then null;
  end;
  return jsonb_build_object('rules', rules, 'memory', mem, 'hits', hits);
end $function$
;

CREATE OR REPLACE FUNCTION public.brain_refresh_term_df()
 RETURNS integer
 LANGUAGE plpgsql
 SET search_path TO 'public', 'extensions'
AS $function$
declare n int;
begin
  delete from brain_term_df;
  insert into brain_term_df (word, ndoc) select word, ndoc from ts_stat('select fts from public.brain_docs where fts is not null') where ndoc >= 200;
  get diagnostics n = row_count;
  return n;
end $function$
;

CREATE OR REPLACE FUNCTION public.brain_refresh_tick()
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare req timestamptz; last_done timestamptz; r jsonb; t0 timestamptz := clock_timestamp();
begin
  select value::timestamptz into req from brain_config where key = 'refresh_requested';
  select (value::jsonb->>'requested_at')::timestamptz into last_done from brain_config where key = 'last_refresh';
  if req is null or (last_done is not null and last_done >= req) then return null; end if;
  if not pg_try_advisory_xact_lock(hashtext('brain_refresh')) then return jsonb_build_object('busy', true); end if;
  begin
    r := public.refresh_brain_docs();
    r := r || jsonb_build_object('ok', true);
  exception when others then
    r := jsonb_build_object('ok', false, 'error', left(sqlerrm, 300));
  end;
  r := r || jsonb_build_object('requested_at', req, 'finished_at', clock_timestamp(),
                               'seconds', round(extract(epoch from clock_timestamp() - t0)));
  insert into brain_config(key, value) values ('last_refresh', r::text)
  on conflict (key) do update set value = excluded.value;
  return r;
end $function$
;

CREATE OR REPLACE FUNCTION public.brain_request_refresh()
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare t timestamptz := clock_timestamp();
begin
  insert into brain_config(key, value) values ('refresh_requested', t::text)
  on conflict (key) do update set value = excluded.value;
  return jsonb_build_object('requested_at', t);
end $function$
;

CREATE OR REPLACE FUNCTION public.brain_save_feedback(p jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare fid bigint; rid bigint;
begin
  insert into brain_feedback(chat_id, question, answer, sql, rating, correction)
  values (p->>'chat_id', left(p->>'question', 2000), left(p->>'answer', 8000), left(p->>'sql', 6000), (p->>'rating')::smallint, nullif(btrim(p->>'correction'), ''))
  returning id into fid;
  if (p->>'rating')::int = 1 then perform brain_memory_doc('answer_example', fid); end if;
  if coalesce((p->>'make_rule')::boolean, false) and nullif(btrim(p->>'correction'), '') is not null then
    insert into brain_rules(rule, source, feedback_id) values (left(btrim(p->>'correction'), 600), 'feedback', fid) returning id into rid;
  end if;
  return jsonb_build_object('feedback_id', fid, 'rule_id', rid);
end $function$
;

CREATE OR REPLACE FUNCTION public.brain_save_insight(p jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare iid bigint;
begin
  if nullif(btrim(p->>'title'), '') is null or nullif(btrim(p->>'insight'), '') is null then raise exception 'Title and insight are required'; end if;
  insert into brain_insights(title, insight, evidence, question, sql)
  values (left(btrim(p->>'title'), 200), left(btrim(p->>'insight'), 4000), left(p->>'evidence', 3000), left(p->>'question', 2000), left(p->>'sql', 6000))
  returning id into iid;
  perform brain_memory_doc('insight', iid);
  return jsonb_build_object('insight_id', iid);
end $function$
;

CREATE OR REPLACE FUNCTION public.brain_search(q text, k integer DEFAULT 10, kinds text[] DEFAULT NULL::text[], filter jsonb DEFAULT NULL::jsonb)
 RETURNS TABLE(id text, kind text, title text, snippet text, score double precision, similarity double precision, metadata jsonb)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare e halfvec(384); tq tsquery;
begin
  e := public.brain_embed_query(q)::halfvec(384);
  -- Keyword side uses only distinctive words (in under ~3% of documents): common words like "call" or "founder"
  -- match thousands of documents and made ranking take seconds while adding nothing over the vector side.
  begin
    select string_agg(quote_literal(w), ' | ')::tsquery into tq
    from unnest(tsvector_to_array(to_tsvector('english', q))) w
    where not exists (select 1 from brain_term_df t where t.word = w and t.ndoc > 800);
  exception when others then tq := null;
  end;
  return query
  with v as (
    select x.id, row_number() over (order by x.dist) r, 1 - x.dist sim
    from (select b.id, (b.embedding <=> e) dist
          from brain_vec b
          where (kinds is null or b.kind = any(kinds)) and (filter is null or b.metadata @> filter)
          order by 2 limit 60) x),
  t as (
    select d.id, row_number() over (order by ts_rank_cd(d.fts, tq) desc) r
    from brain_docs d
    where tq is not null and d.fts @@ tq and (kinds is null or d.kind = any(kinds)) and (filter is null or d.metadata @> filter)
    order by ts_rank_cd(d.fts, tq) desc limit 60)
  select d.id, d.kind, d.title, left(d.body, 900),
         (coalesce(1.0 / (60 + v.r), 0) * 1.3 + coalesce(1.0 / (60 + t.r), 0))::float8 as score,
         v.sim::float8, d.metadata
  from v full join t on t.id = v.id
  join brain_docs d on d.id = coalesce(v.id, t.id)
  order by 5 desc
  limit least(greatest(k, 1), 100);
end $function$
;

CREATE OR REPLACE FUNCTION public.brain_similar(doc_id text, k integer DEFAULT 10, kinds text[] DEFAULT NULL::text[])
 RETURNS TABLE(id text, kind text, title text, snippet text, similarity double precision, metadata jsonb)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
  with n as (
    select d.id, (1 - (d.embedding <=> s.embedding))::float8 sim
    from brain_vec s join brain_vec d on d.id <> s.id
    where s.id = doc_id and (kinds is null or d.kind = any(kinds))
    order by d.embedding <=> s.embedding
    limit least(greatest(k, 1), 100))
  select d.id, d.kind, d.title, left(d.body, 600), n.sim, d.metadata
  from n join brain_docs d on d.id = n.id order by n.sim desc
$function$
;

CREATE OR REPLACE FUNCTION public.brain_vec_sync()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public', 'extensions'
AS $function$
begin
  if tg_op = 'DELETE' then
    delete from brain_vec where id = old.id; return old;
  end if;
  if tg_op = 'UPDATE' and old.id <> new.id then delete from brain_vec where id = old.id; end if;
  if new.embedding is null then
    delete from brain_vec where id = new.id;
  else
    insert into brain_vec (id, kind, metadata, embedding) values (new.id, new.kind, new.metadata, new.embedding::halfvec(384))
    on conflict (id) do update set kind = excluded.kind, metadata = excluded.metadata, embedding = excluded.embedding;
  end if;
  return new;
end $function$
;

CREATE OR REPLACE FUNCTION public.brain_vec_truncate()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$ begin truncate public.brain_vec; return null; end $function$
;

CREATE OR REPLACE FUNCTION public.er_load(rows jsonb)
 RETURNS integer
 LANGUAGE sql
AS $function$
  with ins as (
    insert into public.company_entities(name, entity, parent_group, entity_type, domain, status, confidence, evidence_url, note, cluster)
    select r->>0, r->>1, r->>2, r->>3, r->>4, r->>5, r->>6, r->>7, r->>8, (r->>9)::int from jsonb_array_elements(rows) r
    on conflict (name) do update set entity = excluded.entity, parent_group = excluded.parent_group, entity_type = excluded.entity_type,
      domain = excluded.domain, status = excluded.status, confidence = excluded.confidence, evidence_url = excluded.evidence_url,
      note = excluded.note, cluster = excluded.cluster, checked_at = now()
    returning 1)
  select count(*)::int from ins
$function$
;

CREATE OR REPLACE FUNCTION public.hub_company_save(p jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare nm text := nullif(btrim(p->>'name'), '');
begin
  if nm is null then raise exception 'Company name is required'; end if;
  if p->>'action' = 'delete' then
    delete from company_entities where name = nm;
  else
    if coalesce(p->>'status', '') not in ('verified', 'probable', 'not_found', 'unresolved') then raise exception 'Pick a status'; end if;
    insert into company_entities(name, entity, parent_group, entity_type, domain, status, confidence, note, checked_at, source)
    values (nm, nullif(btrim(p->>'entity'), ''), nullif(btrim(p->>'parent_group'), ''), nullif(btrim(p->>'entity_type'), ''), nullif(btrim(p->>'domain'), ''), p->>'status', 'manual', nullif(btrim(p->>'note'), ''), now(), 'manual')
    on conflict (name) do update set entity = excluded.entity, parent_group = excluded.parent_group, entity_type = excluded.entity_type,
      domain = excluded.domain, status = excluded.status, confidence = 'manual', note = excluded.note, checked_at = now(), source = 'manual';
  end if;
  perform brain_request_refresh();
  return jsonb_build_object('ok', true);
end $function$
;

CREATE OR REPLACE FUNCTION public.hub_deal_save(p jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare i text := p->>'id'; n int;
begin
  update nt_deal_pipeline set
    status = case when p ? 'status' then nullif(btrim(p->>'status'), '') else status end,
    founder_name = case when p ? 'founder_name' then nullif(btrim(p->>'founder_name'), '') else founder_name end,
    founder_linkedin = case when p ? 'founder_linkedin' then nullif(btrim(p->>'founder_linkedin'), '') else founder_linkedin end,
    previous_company_worked_at = case when p ? 'previous_company_worked_at' then nullif(btrim(p->>'previous_company_worked_at'), '') else previous_company_worked_at end,
    description = case when p ? 'description' then nullif(btrim(p->>'description'), '') else description end,
    synced_at = now()
  where id = i;
  get diagnostics n = row_count;
  if n = 0 then raise exception 'Deal not found'; end if;
  perform brain_request_refresh();
  return jsonb_build_object('ok', true);
end $function$
;

CREATE OR REPLACE FUNCTION public.hub_settings_get()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  select jsonb_build_object(
    'settings', coalesce((select value::jsonb from brain_config where key = 'hub_settings'), '{}'::jsonb),
    'nightly', coalesce((select jsonb_agg(jsonb_build_object('job', jobname, 'source', regexp_replace(jobname, '^nt-nightly-\d-', ''), 'schedule', schedule, 'active', active) order by jobname) from cron.job where jobname like 'nt-nightly-%'), '[]'::jsonb),
    'nightly_last', (select jsonb_object_agg(source, jsonb_build_object('at', finished_at, 'ok', ok, 'note', regexp_replace(error, '^nightly: ', ''))) from (select distinct on (source) source, finished_at, ok, error from nt_sync_runs where error ilike 'nightly%' order by source, finished_at desc) z),
    'last_sync', (select jsonb_object_agg(source, jsonb_build_object('at', finished_at, 'ok', ok, 'rows', rows_synced)) from (select distinct on (source) source, finished_at, ok, rows_synced from nt_sync_runs where ok order by source, finished_at desc) z),
    'last_refresh', (select value::jsonb from brain_config where key = 'last_refresh'),
    'pending_embedding', (select count(*) from brain_docs where embedding is null)
  )
$function$
;

CREATE OR REPLACE FUNCTION public.hub_settings_save(p jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare cur jsonb; days int; j record; want boolean; src text;
begin
  cur := coalesce((select value::jsonb from brain_config where key = 'hub_settings'), '{}'::jsonb);
  if p ? 'sync' then
    days := coalesce((p->'sync'->>'content_days')::int, (cur->'sync'->>'content_days')::int, 45);
    if days < 1 or days > 365 then raise exception 'Refresh window must be between 1 and 365 days'; end if;
    cur := jsonb_set(cur, '{sync}', coalesce(cur->'sync', '{}'::jsonb) || (p->'sync') || jsonb_build_object('content_days', days));
  end if;
  insert into brain_config(key, value) values ('hub_settings', cur::text) on conflict (key) do update set value = excluded.value;
  -- Nightly jobs: {"nightly": {"snapshot": true, "pipeline": false, ...}}
  if p ? 'nightly' then
    for j in select jobid, jobname from cron.job where jobname like 'nt-nightly-%' loop
      src := regexp_replace(j.jobname, '^nt-nightly-\d-', '');
      if p->'nightly' ? src then
        want := (p->'nightly'->>src)::boolean;
        perform cron.alter_job(j.jobid, active := want);
      end if;
    end loop;
  end if;
  return hub_settings_get();
end $function$
;

CREATE OR REPLACE FUNCTION public.nt_content_queue(n integer DEFAULT 50)
 RETURNS TABLE(id text, deal text, url text, reason text)
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  with cfg as (select coalesce((select (value::jsonb->'sync'->>'content_days')::int from brain_config where key = 'hub_settings'), 45) as days)
  (select p.id, p.deal, p.url, 'new'
     from nt_deal_pipeline p
     where not exists (select 1 from nt_deal_content c where c.page_id = p.id)
     order by p.created_time desc nulls last
     limit n)
  union all
  (select p.id, p.deal, p.url, 'refresh'
     from nt_deal_pipeline p join nt_deal_content c on c.page_id = p.id, cfg
     where greatest(p.created_time, p.meeting_date::timestamptz) > now() - make_interval(days => cfg.days)
       and c.fetched_at < now() - interval '20 hours'
     order by p.created_time desc nulls last
     limit n)
$function$
;

CREATE OR REPLACE FUNCTION public.nt_nightly_finish()
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare snap jsonb := null; docs jsonb;
begin
  if exists (select 1 from nt_sync_runs where source = 'snapshot' and ok and started_at > now() - interval '3 hours') then
    snap := public.rebuild_snapshot_model();
  end if;
  docs := public.refresh_brain_docs();
  insert into nt_sync_runs(source, started_at, finished_at, rows_synced, rows_removed, ok, error)
  values ('brain', now(), now(), (docs->>'total')::int, (docs->>'deleted')::int, true, 'nightly: documents rebuilt' || case when snap is null then '' else ' + snapshot model' end);
  return jsonb_build_object('snapshot_model', snap, 'documents', docs);
exception when others then
  insert into nt_sync_runs(source, started_at, finished_at, rows_synced, rows_removed, ok, error)
  values ('brain', now(), now(), 0, 0, false, 'nightly: ' || left(sqlerrm, 400));
  return jsonb_build_object('ok', false, 'error', sqlerrm);
end $function$
;

CREATE OR REPLACE FUNCTION public.nt_prune_stale(tbl text, stamp timestamp with time zone)
 RETURNS integer
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare n int;
begin
  if tbl not in ('nt_local_snapshot','nt_deal_pipeline','nt_tracxn_rounds','nt_f3_company_breakup',
                 'nt_f3_sector_master','nt_investor_missing_deals','nt_out_of_coverage_deals') then
    raise exception 'unknown table %', tbl;
  end if;
  execute format('delete from public.%I where synced_at <> $1', tbl) using stamp;
  get diagnostics n = row_count;
  return n;
end $function$
;

CREATE OR REPLACE FUNCTION public.nt_sync_source(src text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare r jsonb;
begin
  r := public.brain_http('sync_url', jsonb_build_object('source', src));
  return r;
exception when others then
  insert into nt_sync_runs(source, started_at, finished_at, rows_synced, rows_removed, ok, error)
  values (src, now(), now(), 0, 0, false, 'nightly: ' || left(sqlerrm, 400));
  return jsonb_build_object('source', src, 'ok', false, 'error', sqlerrm);
end $function$
;

CREATE OR REPLACE FUNCTION public.rebuild_snapshot_model()
 RETURNS json
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare n_src int; r json;
begin
  select count(*) into n_src from nt_local_snapshot;
  if n_src = 0 then raise exception 'nt_local_snapshot is empty; sync it from Notion first'; end if;

  create temp table _slots on commit drop as
  select replace(s.id,'-','') as deal_id, x.slot, nullif(trim(x.name),'') as name, nullif(trim(x.li),'') as li,
         nullif(trim(x.prev),'') as prev, nullif(trim(x.des),'') as des
  from nt_local_snapshot s
  cross join lateral (values
    (1, s.founder_1_name, s.founder_1_linkedin, s.founder_1_previous_company_worked_at, s.founder_1_designations),
    (2, s.founder_2_name, s.founder_2_linkedin, s.founder_2_previous_company_worked_at, s.founder_2_designations),
    (3, s.founder_3_name, s.founder_3_linkedin, s.founder_3_previous_company_worked_at, s.founder_3_designations),
    (4, s.founder_4_name, s.founder_4_linkedin, s.founder_4_previous_company_worked_at, s.founder_4_designations)
  ) as x(slot, name, li, prev, des)
  where nullif(trim(x.name),'') is not null or nullif(trim(x.li),'') is not null;

  alter table _slots add column fkey text;
  update _slots set fkey = coalesce(lower(substring(li from '(?i)linkedin\.com/in/([^/?#]+)')), 'nolink:'||deal_id||':'||slot);

  -- deals
  delete from deals where id not in (select replace(id,'-','') from nt_local_snapshot);
  insert into deals(id, name, status, sectors, f3_classification, source, meeting_date, source_created_at, source_link, synced_at)
  select replace(id,'-',''), deal, status, coalesce(sectors,'{}'), f3_classification, coalesce(source,'{}'), meeting_date, source_created_time, source_deal_link, now()
  from nt_local_snapshot
  on conflict (id) do update set name=excluded.name, status=excluded.status, sectors=excluded.sectors, f3_classification=excluded.f3_classification,
    source=excluded.source, meeting_date=excluded.meeting_date, source_created_at=excluded.source_created_at, source_link=excluded.source_link, synced_at=now();

  -- founders
  insert into founders(key, name, linkedin_url, synced_at)
  select distinct on (fkey) fkey, name,
    case when fkey like 'nolink:%' then null else 'https://www.linkedin.com/in/'||fkey end, now()
  from _slots order by fkey, (name is null), deal_id, slot
  on conflict (key) do update set name = coalesce(excluded.name, founders.name), linkedin_url = excluded.linkedin_url, synced_at = now();

  delete from deal_founders;
  insert into deal_founders(deal_id, slot, founder_key, previous_company_raw) select deal_id, slot, fkey, prev from _slots;

  -- roles: each '; '-separated 'Title - Company' entry; company mapped to its canonical name via companies/aliases
  create temp table _roles on commit drop as
  select distinct s.fkey, trim(e) as raw,
    case when trim(e) ~ ' - ' then trim(substring(trim(e) from '^(.*) - .*$')) end as title,
    trim(case when trim(e) ~ ' - ' then substring(trim(e) from '^.* - (.*)$') else trim(e) end) as orig
  from _slots s cross join lateral regexp_split_to_table(s.des, ';\s*') e
  where s.des is not null and s.fkey not like 'nolink:%' and trim(e) <> '';

  alter table _roles add column company text;
  update _roles r set company = c.name from companies c where c.name = r.orig;
  update _roles r set company = c.name from companies c where r.company is null and r.orig = any(c.aliases);
  update _roles r set company = c.name from companies c where r.company is null and lower(c.name) = lower(r.orig);
  insert into companies(name) select distinct orig from _roles where company is null on conflict do nothing;
  update _roles set company = orig where company is null;

  delete from roles;
  insert into roles(founder_key, company, title, raw)
  select fkey, company, title, raw from _roles order by fkey, raw on conflict (founder_key, raw) do nothing;

  delete from founders f where not exists (select 1 from deal_founders d where d.founder_key = f.key);

  -- investors
  delete from deal_investors;
  insert into investors(name)
  select distinct trim(i) from nt_local_snapshot s cross join lateral regexp_split_to_table(s.institutional_funding, '\s*[,;]\s*') i
  where s.institutional_funding is not null and trim(i) <> '' on conflict do nothing;
  insert into deal_investors(deal_id, investor)
  select distinct replace(s.id,'-',''), trim(i) from nt_local_snapshot s cross join lateral regexp_split_to_table(s.institutional_funding, '\s*[,;]\s*') i
  where s.institutional_funding is not null and trim(i) <> '' on conflict do nothing;

  select json_build_object('deals',(select count(*) from deals),'founders',(select count(*) from founders),'deal_founders',(select count(*) from deal_founders),
    'roles',(select count(*) from roles),'companies',(select count(*) from companies),'investors',(select count(*) from investors),
    'deal_investors',(select count(*) from deal_investors)) into r;
  return r;
end $function$
;

CREATE OR REPLACE FUNCTION public.refresh_brain_docs()
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public', 'extensions'
AS $function$
declare v_ins int; v_upd int; v_del int; v_total int;
begin
  refresh materialized view public.mv_founder_employers_v2;
  create temp table _nd (id text primary key, kind text, title text, body text, metadata jsonb) on commit drop;

  -- founders' text per model deal
  create temp table _df on commit drop as
  select df.deal_id,
         string_agg(f.name || coalesce(' — career: ' || fc.career, coalesce(' — previously: ' || df.previous_company_raw, '')), E'\n  ' order by df.slot) as founders_txt,
         array_agg(distinct c) filter (where c is not null) as alumni_of
  from deal_founders df join founders f on f.key = df.founder_key
  left join v_founder_career fc on fc.founder_key = f.key
  left join lateral unnest(fc.companies) c on true
  group by df.deal_id;

  create temp table _m on commit drop as
  select d.*, brain_key(d.name) k, x.founders_txt, x.alumni_of from deals d left join _df x on x.deal_id = d.id;

  create temp table _u on commit drop as select * from v_startup_universe;
  create index on _u(key);
  create temp table _raw on commit drop as select id from v_raw_data;
  create temp table _p on commit drop as
    select p.*, brain_key(p.deal) k, exists (select 1 from _raw r where r.id = p.id) as in_raw from nt_deal_pipeline p;
  create index on _p(k); create index on _m(k);
  analyze _p; analyze _m; analyze _u;

  -- 1. DEALS from the pipeline (Raw Data / Sector Wise F3 semantics)
  insert into _nd
  select 'deal:' || p.id, 'deal', p.deal,
    concat_ws(E'\n',
      'Startup: ' || p.deal,
      'Status: ' || p.status,
      'Pass stage: ' || p.decision_to_pass_stage,
      'Pass type: ' || nullif(array_to_string(p.pass_type, ', '), ''),
      'Founder pass vectors: ' || nullif(array_to_string(p.founder_pass_vectors, ', '), ''),
      'F2 classification: ' || p.f2_classification,
      'F3 classification: ' || coalesce(p.f3_classification, m.f3_classification),
      'Sectors: ' || nullif(array_to_string(coalesce(p.sectors, m.sectors), ', '), ''),
      'Type: ' || p.type, 'Location: ' || p.location,
      'Source: ' || nullif(array_to_string(p.source, ', '), ''),
      'Met on: ' || p.meeting_date, 'Added: ' || p.created_time::date,
      'What they do: ' || p.description,
      'Call summary (excerpt): ' || left(ct.summary, 900),
      'Partner notes (excerpt): ' || left(nullif(concat_ws(E'\n', ct.meeting_notes, ct.page_notes), ''), 700),
      'Why passed / comments: ' || p.comments,
      'What stood out: ' || p.what_stood_out,
      'What to check: ' || p.what_to_check,
      'Risk evaluation: ' || p.risk_evaluation,
      '1-year view: ' || p.view_1y, '3-year view: ' || p.view_3y, '5-year view: ' || p.view_5y, '10-year view: ' || p.view_10y,
      'Similar companies: ' || p.similar_companies,
      'Antiportfolio: ' || p.antiportfolio,
      'Re-pipeline reason: ' || p.re_pipeline_reason,
      'Founder: ' || p.founder_name,
      'Founder previous companies: ' || coalesce(p.previous_company_worked_at, p.previous_company, p.last_company_worked),
      'Founders and careers:' || E'\n  ' || m.founders_txt,
      'Later funding (Tracxn): ' || u.last_round || coalesce(' on ' || u.last_round_date, '') || coalesce(', total raised USD ' || u.total_raised_usd, '') || coalesce(', investors: ' || array_to_string(u.tracxn_investors, ', '), ''),
      'Missed by investors: ' || nullif(array_to_string(u.missed_by, ', '), '')),
    jsonb_strip_nulls(jsonb_build_object('name', p.deal, 'key', brain_key(p.deal), 'status', p.status,
      'sectors', coalesce(p.sectors, m.sectors), 'f3', coalesce(p.f3_classification, m.f3_classification),
      'pass_stage', p.decision_to_pass_stage, 'meeting_date', p.meeting_date, 'created', p.created_time::date,
      'in_raw_data', p.in_raw, 'pipeline_id', p.id, 'model_deal_id', m.id,
      'alumni_of', m.alumni_of, 'raised_later', coalesce(u.rounds, 0) > 0, 'url', p.url,
      'has_call_summary', ct.summary is not null, 'has_transcript', ct.transcript is not null, 'meetings', ct.meetings))
  from _p p
  left join lateral (select * from _m where _m.k = p.k limit 1) m on true
  left join _u u on u.key = p.k
  left join nt_deal_content ct on ct.page_id = p.id
  where p.deal is not null;

  -- 1b. DEALS only in the Local Snapshot model
  insert into _nd
  select 'deal:' || m.id, 'deal', m.name,
    concat_ws(E'\n',
      'Startup: ' || m.name, 'Status: ' || m.status,
      'F3 classification: ' || m.f3_classification,
      'Sectors: ' || nullif(array_to_string(m.sectors, ', '), ''),
      'Source: ' || nullif(array_to_string(m.source, ', '), ''),
      'Met on: ' || m.meeting_date, 'Added: ' || m.source_created_at::date,
      'Founders and careers:' || E'\n  ' || m.founders_txt,
      'Later funding (Tracxn): ' || u.last_round || coalesce(' on ' || u.last_round_date, '') || coalesce(', investors: ' || array_to_string(u.tracxn_investors, ', '), ''),
      'Missed by investors: ' || nullif(array_to_string(u.missed_by, ', '), '')),
    jsonb_strip_nulls(jsonb_build_object('name', m.name, 'key', m.k, 'status', m.status, 'sectors', m.sectors,
      'f3', m.f3_classification, 'meeting_date', m.meeting_date, 'created', m.source_created_at::date,
      'model_deal_id', m.id, 'alumni_of', m.alumni_of, 'raised_later', coalesce(u.rounds, 0) > 0, 'url', m.source_link))
  from _m m left join _u u on u.key = m.k
  where not exists (select 1 from _p p where p.k = m.k);

  -- 1c. CALL SUMMARIES, PARTNER NOTES AND TRANSCRIPTS (page content of each pipeline deal)
  insert into _nd
  select v.pfx || ':' || c.page_id || ':' || ch.idx, v.kind,
    coalesce(p.deal, c.deal) || ' — ' || v.label || case when ch.n > 1 then ' (part ' || ch.idx || ' of ' || ch.n || ')' else '' end,
    concat_ws(E'\n',
      'Startup: ' || coalesce(p.deal, c.deal) || coalesce(' | Status: ' || p.status, '') ||
        coalesce(' | Sectors: ' || nullif(array_to_string(p.sectors, ', '), ''), '') || coalesce(' | Met on: ' || p.meeting_date, ''),
      v.label || ':', ch.chunk),
    jsonb_strip_nulls(jsonb_build_object('name', coalesce(p.deal, c.deal), 'key', p.k, 'pipeline_id', c.page_id,
      'status', p.status, 'sectors', p.sectors, 'f3', p.f3_classification, 'meeting_date', p.meeting_date,
      'part', ch.idx, 'parts', ch.n, 'url', p.url))
  from nt_deal_content c
  left join _p p on p.id = c.page_id
  cross join lateral (values
      ('sum',  'call_summary', 'Call summary',    c.summary, 1600),
      ('note', 'call_notes',   'Partner notes',   nullif(concat_ws(E'\n', c.meeting_notes, c.page_notes), ''), 1600),
      ('tx',   'transcript',   'Call transcript', c.transcript, 1800)) v(pfx, kind, label, txt, sz)
  cross join lateral (select b.idx, b.chunk, count(*) over () as n from brain_chunks(v.txt, v.sz) b) ch;

  -- 2. FOUNDERS (Local Snapshot: one profile per founder with every designation)
  insert into _nd
  select 'founder:' || f.key, 'founder', f.name,
    concat_ws(E'\n',
      'Founder: ' || f.name,
      'LinkedIn: ' || f.linkedin_url,
      'Startups pitched to Sparrow: ' || string_agg(distinct d.name || ' (' || coalesce(d.status, 'no status') || coalesce(', ' || nullif(array_to_string(d.sectors, ', '), ''), '') || coalesce(', F3 ' || d.f3_classification, '') || ')', '; '),
      'Career history: ' || fc.career,
      'Alumni of: ' || nullif(array_to_string(fc.companies, ', '), '')),
    jsonb_strip_nulls(jsonb_build_object('name', f.name, 'linkedin', f.linkedin_url, 'companies', fc.companies,
      'deals', array_agg(distinct d.name), 'sectors', (select array_agg(distinct s) from deals d2 join deal_founders x on x.deal_id = d2.id, unnest(d2.sectors) s where x.founder_key = f.key),
      'statuses', array_agg(distinct d.status)))
  from founders f
  join deal_founders df on df.founder_key = f.key join deals d on d.id = df.deal_id
  left join v_founder_career fc on fc.founder_key = f.key
  group by f.key, f.name, f.linkedin_url, fc.career, fc.companies;

  -- 3. ALUMNI PATTERNS (which company's alumni start what)
  insert into _nd
  select 'alumni:' || md5(company), 'alumni_pattern', company || ' alumni',
    'Former employees of ' || company || ' who founded startups that pitched Sparrow: ' || max(tf) || ' founders, ' || max(ts) || ' startups.' || E'\n' ||
    'Sectors they build in: ' || string_agg(sector || ' (' || startups || ')', ', ' order by startups desc) || E'\n' ||
    'Outcomes: ' || (select count(distinct e.deal_id) filter (where e.status = 'Pass') || ' passed, ' || count(distinct e.deal_id) filter (where e.status = 'To be Passed') || ' to be passed' from v_founder_employers e where e.entity = a.company and e.entity_status <> 'unresolved') || '.' || E'\n' ||
    'Startups: ' || (select string_agg(distinct n, ', ') from v_alumni_sector_patterns a2, unnest(a2.startup_names) n where a2.company = a.company),
    jsonb_build_object('company', company, 'founders', max(tf), 'startups', max(ts),
      'sectors', jsonb_object_agg(sector, startups))
  from (select a.*, sum(founders) over (partition by company) tf0,
               (select count(distinct e.founder_key) from v_founder_employers e where e.entity = a.company and e.entity_status <> 'unresolved') tf,
               (select count(distinct e.deal_id) from v_founder_employers e where e.entity = a.company and e.entity_status <> 'unresolved') ts
        from v_alumni_sector_patterns a) a
  where tf >= 2
  group by company;

  -- 4. TRACXN FUNDING ROUNDS (with Sparrow Pipeline radar status)
  insert into _nd
  select 'round:' || t.id, 'funding_round', t.company || ' — ' || coalesce(t.round_name, 'round'),
    concat_ws(E'\n',
      'Company: ' || t.company || ' raised a ' || coalesce(t.round_name, 'funding') || ' round' || coalesce(' on ' || t.round_date, '') || coalesce(' of USD ' || t.round_amount_usd, '') || '.',
      'Sector: ' || nullif(array_to_string(t.sector, ', '), ''),
      'Location: ' || nullif(array_to_string(t.location, ', '), ''),
      'Founded: ' || t.founded_year,
      'Lead investor: ' || nullif(array_to_string(t.lead_investor, ', '), ''),
      'All investors (funds and angels): ' || nullif(array_to_string(t.round_investors, ', '), ''),
      'Sparrow pipeline: ' || coalesce(t.sparrow_pipeline, 'unknown') ||
        case when t.sparrow_pipeline ilike 'missing%' then ' — this company never showed up on Sparrow''s radar (missed deal).' else ' — this company was on Sparrow''s radar.' end,
      'Our pipeline record: ' || u.pipeline_status || coalesce(' at ' || u.decision_to_pass_stage, '')),
    jsonb_strip_nulls(jsonb_build_object('company', t.company, 'key', brain_key(t.company), 'round', t.round_name, 'date', t.round_date,
      'amount_usd', t.round_amount_usd, 'sector', t.sector, 'lead', t.lead_investor, 'investors', t.round_investors,
      'sparrow_pipeline', t.sparrow_pipeline, 'on_radar', not coalesce(t.sparrow_pipeline ilike 'missing%', false), 'url', t.url))
  from nt_tracxn_rounds t left join _u u on u.key = brain_key(t.company);

  -- 5. INVESTOR MISSING DEALS
  insert into _nd
  select 'missed:' || m.id, 'investor_missed', m.investor || ' — deals Sparrow missed',
    concat_ws(E'\n',
      'Investor: ' || m.investor,
      'In the last year this investor backed ' || coalesce(m.missing_deals::int::text, '?') || ' companies that Sparrow missed (never on our radar).',
      'Missed companies: ' || m.company_names,
      'Sectors: ' || nullif(array_to_string(m.sectors, ', '), '')),
    jsonb_strip_nulls(jsonb_build_object('investor', m.investor, 'missing_deals', m.missing_deals, 'sectors', m.sectors, 'url', m.url))
  from nt_investor_missing_deals m where m.investor is not null;

  -- 6. OUT OF COVERAGE DEALS
  insert into _nd
  select 'ooc:' || o.id, 'out_of_coverage', o.name,
    concat_ws(E'\n',
      'Startup: ' || o.name || ' — got funded but never came onto Sparrow''s radar (out of coverage).',
      'Status: ' || o.status, 'Type: ' || o.type, 'Investor type: ' || o.investor_type,
      'F2 classification: ' || o.f2_classification, 'F3 classification: ' || o.f3_classification,
      'Sectors: ' || nullif(array_to_string(o.sectors, ', '), ''),
      'Location: ' || o.location, 'Source: ' || nullif(array_to_string(o.source, ', '), ''),
      'Notes: ' || o.notes, 'Risk evaluation: ' || o.risk_evaluation,
      'Similar companies: ' || o.similar_companies,
      'Founder: ' || o.founder_name, 'Founder previous companies: ' || o.previous_companies_worked_at,
      'Later funding (Tracxn): ' || u.last_round || coalesce(', investors: ' || array_to_string(u.tracxn_investors, ', '), '')),
    jsonb_strip_nulls(jsonb_build_object('name', o.name, 'key', brain_key(o.name), 'sectors', o.sectors, 'f3', o.f3_classification,
      'created', o.creation_date::date, 'url', o.url))
  from nt_out_of_coverage_deals o left join _u u on u.key = brain_key(o.name) where o.name is not null;

  -- 7. F3 SECTOR SUPER MASTER
  insert into _nd
  select 'f3:' || s.id, 'f3_master', s.deal,
    concat_ws(E'\n',
      'Startup: ' || s.deal, 'Status: ' || s.status,
      'F3 sector classification: ' || s.f3_sector_classification,
      'Investors: ' || nullif(array_to_string(s.investor, ', '), ''),
      'Founder: ' || s.founder_name, 'Founder previous company: ' || s.founder_previous_company,
      'Added: ' || s.created_on),
    jsonb_strip_nulls(jsonb_build_object('name', s.deal, 'key', brain_key(s.deal), 'status', s.status, 'f3', s.f3_sector_classification,
      'investors', s.investor, 'created', s.created_on, 'url', s.url))
  from nt_f3_sector_master s where s.deal is not null;

  -- 8. F3 CLASSIFICATION COMPANY (INVESTOR) BREAKUP
  insert into _nd
  select 'f3inv:' || b.id, 'investor_f3_breakup', b.company_name || ' — F3 mix',
    'Investor ' || b.company_name || ' deal count by F3 bucket: AI software & infra ' || coalesce(b.ai_software_and_infra,0) ||
    ', B2B & manufacturing ' || coalesce(b.b2b_and_manufacturing,0) || ', India consumption 1 ' || coalesce(b.india_consumption_1,0) ||
    ', India consumption 2/3 ' || coalesce(b.india_consumption_2_3,0) || ', Fintech & FS ' || coalesce(b.fintech_and_fs,0) ||
    ', Deeptech ' || coalesce(b.deeptech,0) || ', Healthcare ' || coalesce(b.healthcare,0) || ', Other ' || coalesce(b.other,0) || '.',
    jsonb_build_object('investor', b.company_name, 'url', b.url)
  from nt_f3_company_breakup b where b.company_name is not null;

  -- upsert only what changed; changed docs lose their embedding so they get re-embedded
  with up as (
    insert into brain_docs as bd (id, kind, title, body, metadata, content_hash, updated_at)
    select id, kind, coalesce(nullif(title, ''), '(unnamed in Notion)'), coalesce(body, ''), coalesce(metadata, '{}'), md5(coalesce(nullif(title, ''), '(unnamed in Notion)') || E'\n' || coalesce(body, '')), now() from _nd
    on conflict (id) do update set kind = excluded.kind, title = excluded.title, body = excluded.body,
      metadata = excluded.metadata, content_hash = excluded.content_hash, updated_at = now(),
      embedding = case when bd.content_hash = excluded.content_hash then bd.embedding end,
      embedded_at = case when bd.content_hash = excluded.content_hash then bd.embedded_at end
    where bd.content_hash is distinct from excluded.content_hash or bd.metadata is distinct from excluded.metadata
    returning (xmax = 0) as inserted)
  select count(*) filter (where inserted), count(*) filter (where not inserted) into v_ins, v_upd from up;

  delete from brain_docs where id not in (select id from _nd);
  get diagnostics v_del = row_count;
  select count(*) into v_total from brain_docs;

  return jsonb_build_object('inserted', v_ins, 'updated', v_upd, 'deleted', v_del, 'total', v_total,
    'pending_embedding', (select count(*) from brain_docs where embedding is null),
    'by_kind', (select jsonb_object_agg(kind, n) from (select kind, count(*) n from brain_docs group by kind) z));
end $function$
;

CREATE OR REPLACE FUNCTION public.rls_auto_enable()
 RETURNS event_trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog'
AS $function$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('alter table if exists %s enable row level security', cmd.object_identity);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$function$
;

-- CRON
select cron.schedule('brain-embed-tick', '* * * * *', 'select public.brain_embed_tick()');
select cron.schedule('brain-refresh-tick', '* * * * *', 'set statement_timeout = ''15min''; select public.brain_refresh_tick()');
select cron.schedule('nt-nightly-1-snapshot', '30 20 * * *', 'set statement_timeout = ''10min''; select public.nt_sync_source(''snapshot'')');
select cron.schedule('nt-nightly-2-pipeline', '33 20 * * *', 'set statement_timeout = ''10min''; select public.nt_sync_source(''pipeline'')');
select cron.schedule('nt-nightly-3-tracxn', '38 20 * * *', 'set statement_timeout = ''10min''; select public.nt_sync_source(''tracxn'')');
select cron.schedule('nt-nightly-4-f3breakup', '41 20 * * *', 'set statement_timeout = ''10min''; select public.nt_sync_source(''f3breakup'')');
select cron.schedule('nt-nightly-5-master', '43 20 * * *', 'set statement_timeout = ''10min''; select public.nt_sync_source(''master'')');
select cron.schedule('nt-nightly-6-missing', '45 20 * * *', 'set statement_timeout = ''10min''; select public.nt_sync_source(''missing'')');
select cron.schedule('nt-nightly-7-coverage', '47 20 * * *', 'set statement_timeout = ''10min''; select public.nt_sync_source(''coverage'')');
select cron.schedule('nt-nightly-8-finish', '55 20 * * *', 'set statement_timeout = ''10min''; select public.nt_nightly_finish()');
