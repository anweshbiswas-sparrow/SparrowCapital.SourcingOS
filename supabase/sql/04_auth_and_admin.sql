-- Invite-only Google sign-in + admin panel (Deal Brain team app).
-- Who may use the app: rows in app_users (status 'active'). Admins (role 'admin') get the admin panel.
create table if not exists app_users(
  email text primary key check (email = lower(email)),
  name text, role text not null default 'member' check (role in ('admin','member')),
  status text not null default 'active' check (status in ('active','blocked')),
  daily_limit int, added_by text, created_at timestamptz not null default now(), last_seen timestamptz);
alter table app_users enable row level security;   -- no policies: only the ask Edge Function (service connection) reads it
insert into app_users(email, name, role, added_by) values ('anwesh@sparrowvc.com', 'Anwesh Biswas', 'admin', 'setup') on conflict (email) do nothing;

-- Per-user logging and the correction review queue
alter table ask_log add column if not exists user_email text;
alter table ask_log add column if not exists correction text;
alter table ask_log add column if not exists correction_status text;   -- pending | approved | dismissed
create index if not exists ask_log_user on ask_log(user_email, created_at desc);

-- Supabase Auth (dashboard): Google provider enabled; Site URL + redirect URL = the Netlify app (https://sparrowvc-sourceos.netlify.app/**).
