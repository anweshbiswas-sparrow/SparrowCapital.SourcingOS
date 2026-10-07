# Sparrow Capital — Sourcing OS

Deal intelligence for Sparrow VC: Notion ("Deal Analysis - Anwesh") and Tracxn data synced into Supabase, a searchable memory over deals, founders, notes and call transcripts, and a chat app where the team asks questions in plain English.

## How it fits together

```
Notion (Deal Analysis - Anwesh) ──nightly 2:00 AM IST──► Supabase (Postgres)
  Deal Pipeline, Local Snapshot, Tracxn Fund,          nt_* tables → v_* views
  F3 breakup, F3 master, Investor Missing,             brain_docs + brain_vec (vector memory)
  Out of Coverage                                       ask_log (usage)
                                                            │
Team web app (web/index.html, hosted on Netlify) ──► Edge Function `ask`
  question in plain English                            1. semantic search (brain_prefetch)
                                                       2. AI (Gemini / OpenAI) writes read-only SQL
                                                       3. SQL runs as role ask_reader, READ ONLY
                                                       4. AI writes a short answer
  answer · chart · table · Notion links ◄────────────  JSON
```

## Repository layout

| Path | What it is |
|---|---|
| `web/index.html` | Team chat app (single file): Google sign-in, invite-only. Chat at `/`. Admin panel is a separate page at `/admin` (admins only; not linked from the chat). |
| `web/_redirects` | Netlify rewrite so `/admin` serves the app. |
| `web/_headers` | Security headers for the site. |
| `supabase/functions/ask` | Question-answering backend: AI provider (Gemini or OpenAI, with fallback), SQL sandbox, quotas, feedback. |
| `supabase/functions/nt-sync` | Nightly Notion → Supabase sync, one data source per call, via the official Notion API. |
| `supabase/functions/brain-embed` | Embeddings for the memory (built-in `gte-small`, no external key). |
| `supabase/functions/ai-models` | Owner-only helper: lists the Gemini models the key can use. |
| `supabase/sql/01_schema_snapshot.sql` | Snapshot of tables, views, functions and cron jobs (reference / recovery). |
| `supabase/sql/02_team_app_security.sql` | Read-only role, grants, policies and logging for the team app. |
| `supabase/sql/03_config_seed.sql` | Non-secret settings: AI prompt (schema + rules), limits, sync toggles. |
| `supabase/sql/04_auth_and_admin.sql` | Invite-only access list (`app_users`), per-user logging, correction review queue. |
| `artifacts/` | Source of the Claude artifacts: Deal Brain, Notion Sync, Deal Hub (`build.js` builds `deal-hub.html` from `hub-src.html`). |

## Secrets (never commit these)

Set in **Supabase → Edge Functions → Secrets**:

| Name | Used by |
|---|---|
| `GEMINI_API_KEY` | `ask` (current provider), `ai-models` |
| `OPENAI_API_KEY` | `ask` (fallback / alternative provider) |
| `NOTION_TOKEN` | `nt-sync` (Notion internal integration "AB"; each database must be shared with it) |

Internal shared secrets (`embed_secret`, `embed_jwt`) live in the `brain_config` table and are not in this repo.
`web/index.html` contains only the project URL and the public anon key. That key is meant to be public: it has no access to any table or database function (`supabase/sql/07_lockdown.sql`), so it can only be used to sign in and to call the `ask` function, which checks the person's Google sign-in and the invite list on every request.

The Google OAuth client secret lives only in Supabase (Authentication → Sign In / Providers → Google). The client ID is public by design (it appears in the Google sign-in URL).

## Security model

- **Secrets** (AI keys, Notion token, Google client secret, internal shared secret) are only in Supabase. None are in this repo, its history, or the web page.
- **Public roles** (`anon`, and any Google account that signs in) have no direct access to tables or functions. Row-level security is on for every table as a second layer.
- **The `ask` function** checks the sign-in token and the invite list (`app_users`) on every call; `admin_*` actions also require the admin role.
- **AI-written SQL** runs as `ask_reader` in a read-only transaction with a 25s timeout. `ask_reader` can read deal data only. It cannot read settings, secrets, users, logs, feedback, sign-in accounts or storage, cannot write, and cannot make web requests.
- **Internal endpoints** (`nt-sync`, `brain-embed`, `ai-models`, and `ask` selftest) require the internal shared secret.
- **Web page** is served with strict security headers (`web/_headers`): it can't be framed by other sites, and it can only load scripts from itself and jsDelivr and only send data to this Supabase project.

## Settings (no redeploy needed)

Stored in `brain_config`:

- `ask_settings`: `provider` (`gemini` | `openai`), `gemini_model`, `model` (OpenAI), `fallback`, `per_client_day`, `global_day`, `enabled`.
- `ask_schema` / `ask_rules`: the instructions the AI follows (database description, answer format, accuracy rules).
- `hub_settings`: which Notion sources sync nightly.

Example: switch to OpenAI
```sql
update brain_config set value = (value::jsonb || '{"provider":"openai"}')::text where key = 'ask_settings';
```

## Deploy

- Edge functions: `supabase functions deploy ask nt-sync brain-embed ai-models --project-ref gdxufeytlxadbfzaorrx`
- Web app: drag `web/` onto https://app.netlify.com/drop (or connect this repo in Netlify with publish directory `web`).

## Access & admin panel

- Sign-in: Google (Supabase Auth). Only emails in `app_users` with status `active` can use the app; everyone else sees "No access yet".
- Admins get an **Admin panel** in the app: invite/block users, roles, per-user daily limits; usage & logs (14-day chart, per person, recent questions with queries); corrections review (approve 👎 notes as team rules) and rule on/off; settings (pause app, AI provider/model, limits, cost estimate, sync status).
- Live app: https://sparrowvc-sourceos.netlify.app

## Known gaps

- New deals' page notes and meeting transcripts are not part of the nightly sync; they come in via the Deal Hub "Sync page content" button.
- Gemini free tier: low daily limits, and Google may use free-tier prompts. Enable billing (or OpenAI credits) for team-wide use.
