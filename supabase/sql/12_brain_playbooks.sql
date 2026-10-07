-- Playbooks: for known question types the ask function runs these queries up front and gives the AI the results,
-- so every part of a multi-part question has its data even when only the small model is available.
-- Edit rows here (no redeploy needed; the function re-reads them every 5 minutes).
-- Placeholders: {fintech_and} -> "is_fintech and" when the question is about fintech, else ""; {segment} -> 'Fintech' / 'All sectors'.
-- "when" (optional regex) runs a query only if the question matches it; "sql_all" (optional) is used when the question is not about fintech.
create table if not exists public.brain_playbooks (
  name text primary key,
  pattern text not null,
  queries jsonb not null,
  guide text not null default '',
  active boolean not null default true,
  updated_at timestamptz default now()
);
alter table public.brain_playbooks enable row level security;
revoke all on public.brain_playbooks from anon, authenticated;
-- The live "missed_companies" playbook row was inserted on 7 Oct 2026; read it with:
--   select name, pattern, jsonb_pretty(queries), guide from brain_playbooks;
