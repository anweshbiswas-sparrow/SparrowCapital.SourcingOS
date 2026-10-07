import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

// Nightly one-way copy of one Deal Analysis data source from Notion (official API) into Supabase.
// Called by pg_cron with the shared secret from public.brain_config. Notion is only read.
const sb = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, { auth: { persistSession: false } });
const NOTION_TOKEN = Deno.env.get("NOTION_TOKEN") || "";
const NOTION_VERSION = "2025-09-03";

const SOURCES = [
  { key: "snapshot", title: "Deal Pipeline – Local Snapshot", views: "Local Snapshot – Deal Pipeline", table: "nt_local_snapshot",
    ds: "collection://6f252c27-0bd4-43d2-b457-f61083848a6f", after: "rebuild", cols: [
    ["Deal","deal","text"],["Status","status","text"],["F3 Classification","f3_classification","text"],["Sectors","sectors","arr"],["Source","source","arr"],
    ["date:Meeting date:start","meeting_date","date"],["date:Source Created Time:start","source_created_time","ts"],["Source Deal Link","source_deal_link","text"],
    ["Institutional Funding","institutional_funding","text"],["Founder Name","founder_name","text"],["Founder LinkedIn","founder_linkedin","text"],
    ["Previous Company Worked At","previous_company_worked_at","text"],["date:Last Synced:start","last_synced","date"],
    ["Founder 1 Name","founder_1_name","text"],["Founder 1 Linkedin","founder_1_linkedin","text"],["Founder 1 Previous Company Worked At","founder_1_previous_company_worked_at","text"],["Founder 1 Designations ","founder_1_designations","text"],
    ["Founder 2 Name","founder_2_name","text"],["Founder 2 Linkedin","founder_2_linkedin","text"],["Founder 2 Previous Company Worked At","founder_2_previous_company_worked_at","text"],["Founder 2 Designations ","founder_2_designations","text"],
    ["Founder 3 Name","founder_3_name","text"],["Founder 3 Linkedin","founder_3_linkedin","text"],["Founder 3 Previous Company Worked At","founder_3_previous_company_worked_at","text"],["Founder 3 Designations ","founder_3_designations","text"],
    ["Founder 4 Name","founder_4_name","text"],["Founder 4 Linkedin","founder_4_linkedin","text"],["Founder 4 Previous Company Worked At","founder_4_previous_company_worked_at","text"],["Founder 4 Designations ","founder_4_designations","text"]]},
  { key: "pipeline", title: "Deal Pipeline", views: "Raw Data · Sector Wise - F3 Classification", table: "nt_deal_pipeline",
    ds: "collection://0b546375-0d59-4b7d-a90e-0c26ebe249ec", cols: [
    ["Deal","deal","text"],["Status","status","text"],["F2 Classification","f2_classification","text"],["F3 Classification","f3_classification","text"],
    ["Sectors","sectors","arr"],["Source","source","arr"],["Location","location","text"],["Type","type","text"],["Select","select","text"],
    ["Risk Evaluation","risk_evaluation","text"],["Decision to Pass Stage","decision_to_pass_stage","text"],["Pass Type","pass_type","arr"],
    ["Founder Pass Vectors","founder_pass_vectors","arr"],["AntiPortfolio","antiportfolio","text"],["Decision Audit","decision_audit","text"],
    ["Decision Audit Check","decision_audit_check","bool"],["Acquihire","acquihire","bool"],["Re-Pipeline Reason","re_pipeline_reason","text"],
    ["date:Re-Pipeline Date:start","re_pipeline_date","date"],["date:Follow up date:start","follow_up_date","date"],["date:Meeting date:start","meeting_date","date"],
    ["Created time","created_time","ts"],["Created by","created_by","text"],["People","people","arr"],["Description","description","text"],
    ["Comments","comments","text"],["What stood out","what_stood_out","text"],["What to Check?","what_to_check","text"],["1Y View","view_1y","text"],
    ["3Y View","view_3y","text"],["5Y View","view_5y","text"],["10Y View","view_10y","text"],["Similar Companies","similar_companies","text"],
    ["Founder Name","founder_name","text"],["Founder LinkedIn","founder_linkedin","text"],["Previous Company","previous_company","text"],
    ["Previous Company Worked At","previous_company_worked_at","text"],["Previous Company Worked At (Raw)","previous_company_worked_at_raw","text"],
    ["Last company worked","last_company_worked","text"],["Email","email","text"],["Documents","documents","text"],["Documents Link","documents_link","text"],
    ["IM Link","im_link","text"],["Deal Attribution","deal_attribution","arr"],["Institutional Funding","institutional_funding","arr"],
    ["Sourcing Network Nodes","sourcing_network_nodes","arr"],
    ["Industry","industry","arr"],["LinkedIn URL","linkedin_url","text"],["Source 1","source_1","text"],["Contact Email","contact_email","text"],
    ["date:Created Date:start","created_date","date"],["Next Action","next_action","text"]]},
  { key: "tracxn", title: "Tracxn Fund - Last 1Y - Master", views: "Tracxn Fund", table: "nt_tracxn_rounds",
    ds: "collection://3e28563d-567d-8060-a348-000b1a00fdaa", cols: [
    ["Company","company","text"],["Sector","sector","arr"],["date:Round Date:start","round_date","date"],["Founded Year","founded_year","num"],
    ["Location","location","arr"],["Round Name","round_name","text"],["Round Amount (USD)","round_amount_usd","num"],["Lead Investor","lead_investor","arrsplit"],
    ["Round Investors","round_investors","arrsplit"],["Sparrow Pipeline","sparrow_pipeline","text"]]},
  { key: "f3breakup", title: "F3 Classification Company Breakup", views: "F3 Classification Company Breakup", table: "nt_f3_company_breakup",
    ds: "collection://3f24aaeb-bdfb-43ff-9495-a5c79321e62b", cols: [
    ["Company Name","company_name","text"],["AI Software and Infra","ai_software_and_infra","num"],["B2B and Manufacturing","b2b_and_manufacturing","num"],
    ["India Consumption 1","india_consumption_1","num"],["FinTech and FS","fintech_and_fs","num"],["DeepTech","deeptech","num"],
    ["India Consumption 2 & 3","india_consumption_2_3","num"],["Healthcare","healthcare","num"],["Other","other","num"]]},
  { key: "master", title: "F3 Sector Super Master", views: "F3 Sector Super Master", table: "nt_f3_sector_master",
    ds: "collection://17b265f0-4d5e-4693-a83e-0e1110c0b750", cols: [
    ["Deal","deal","text"],["F3 Sector Classification","f3_sector_classification","text"],["Investor ","investor","arr"],["Status","status","text"],
    ["date:Created On:start","created_on","date"],["Founder Name","founder_name","text"],["Founder Linkedin ","founder_linkedin","text"],
    ["Founder Previous Company ","founder_previous_company","text"]]},
  { key: "missing", title: "Investor Missing Deals", views: "Investor Missing Deals", table: "nt_investor_missing_deals",
    ds: "collection://3e28563d-567d-80f2-9cf1-000b57d4af8a", cols: [
    ["Investor","investor","text"],["Missing Deals","missing_deals","num"],["Company Names","company_names","text"],["Sectors","sectors","arr"]]},
  { key: "coverage", title: "Out of Coverage Deals", views: "Out of Coverage Deals", table: "nt_out_of_coverage_deals",
    ds: "collection://36b8563d-567d-8093-a947-000b69afae3e", cols: [
    ["Name","name","text"],["Status","status","text"],["Type","type","text"],["F2 Classification","f2_classification","text"],
    ["F3 Classification","f3_classification","text"],["Sectors","sectors","arr"],["Source","source","arr"],["Location","location","text"],
    ["Investor Type","investor_type","text"],["Risk Evaluation","risk_evaluation","text"],["date:Meeting date:start","meeting_date","date"],
    ["Creation Date","creation_date","ts"],["Notes","notes","text"],["Similar Companies","similar_companies","text"],["Founder Name","founder_name","text"],
    ["Founder Linkedin ","founder_linkedin","text"],["Previous Companies Worked At","previous_companies_worked_at","text"],["People","people","arr"],
    ["Investors","investors","arr"],["💰 Sparrow Funds","sparrow_funds","arr"]]}
];

const sleep = (ms: number) => new Promise(r => setTimeout(r, ms));
let cachedSecret: string | null = null;
async function secretOk(given: string | null){
  if (!given) return false;
  if (!cachedSecret) { const { data } = await sb.from("brain_config").select("value").eq("key", "embed_secret").single(); cachedSecret = data?.value ?? null; }
  return !!cachedSecret && given === cachedSecret;
}

// Same conversion rules as the Notion Sync page, so both sync paths store identical values.
function convert(v: any, kind: string): any {
  if (v === undefined || v === null || v === "") return null;
  switch (kind) {
    case "arr": {
      if (Array.isArray(v)) { const a = v.flat().filter((x: any) => x !== null && x !== "").map(String); return a.length ? a : null; }
      try { const a = JSON.parse(v); return Array.isArray(a) ? a.map((x: any) => typeof x === "string" ? x : JSON.stringify(x)) : [String(v)]; } catch { return [String(v)]; }
    }
    case "arrsplit": { const a = convert(v, "arr"); return a && a.flatMap((x: string) => x.split(/\s*;\s*/)).map((x: string) => x.trim()).filter(Boolean); }
    case "bool": return v === "__YES__" || v === true || v === 1 || v === "true";
    case "num": { const n = Number(Array.isArray(v) ? v[0] : v); return isFinite(n) ? n : null; }
    case "date": return String(Array.isArray(v) ? v[0] : v).slice(0, 10);
    case "ts": return String(Array.isArray(v) ? v[0] : v);
    default: return Array.isArray(v) ? (v.length ? v.flat().join(", ") : null) : (typeof v === "string" ? v : JSON.stringify(v));
  }
}

const pageUrl = (id: string) => "https://app.notion.com/" + id.replace(/-/g, "");
// Notion API property object -> the plain value the MCP SQL mode returns for the same property
function propValue(p: any): any {
  if (!p) return null;
  switch (p.type) {
    case "title": case "rich_text": { const t = (p[p.type] || []).map((x: any) => x.plain_text).join(""); return t || null; }
    case "select": return p.select?.name ?? null;
    case "status": return p.status?.name ?? null;
    case "multi_select": return (p.multi_select || []).map((x: any) => x.name);
    case "date": return p.date?.start ?? null;
    case "checkbox": return !!p.checkbox;
    case "number": return p.number;
    case "url": return p.url; case "email": return p.email; case "phone_number": return p.phone_number;
    case "people": return (p.people || []).map((u: any) => "user://" + u.id);
    case "relation": return (p.relation || []).map((r: any) => pageUrl(r.id));
    case "created_time": return p.created_time; case "last_edited_time": return p.last_edited_time;
    case "created_by": return p.created_by?.id ? "notion_user-" + p.created_by.id : null;
    case "last_edited_by": return p.last_edited_by?.id ? "notion_user-" + p.last_edited_by.id : null;
    case "files": return (p.files || []).map((f: any) => f.name);
    case "unique_id": return p.unique_id?.number == null ? null : (p.unique_id.prefix ? p.unique_id.prefix + "-" : "") + p.unique_id.number;
    case "formula": { const f = p.formula || {}; return f.type === "date" ? f.date?.start ?? null : f[f.type] ?? null; }
    case "rollup": { const r = p.rollup || {}; if (r.type === "array") return (r.array || []).map(propValue).flat().filter((x: any) => x !== null && x !== ""); if (r.type === "date") return r.date?.start ?? null; return r[r.type] ?? null; }
    default: return null;
  }
}
const propName = (n: string) => { const m = n.match(/^date:(.+):start$/); return m ? m[1] : n; };

async function notionQuery(ds: string, cursor?: string){
  const id = ds.replace("collection://", "");
  for (let attempt = 0; attempt < 6; attempt++) {
    const r = await fetch(`https://api.notion.com/v1/data_sources/${id}/query`, {
      method: "POST",
      headers: { "Authorization": `Bearer ${NOTION_TOKEN}`, "Notion-Version": NOTION_VERSION, "Content-Type": "application/json" },
      body: JSON.stringify(cursor ? { page_size: 100, start_cursor: cursor } : { page_size: 100 })
    });
    if (r.status === 429 || r.status >= 500) { const wait = Number(r.headers.get("retry-after") || 2) * 1000; await sleep(Math.min(wait, 20000) + 300); continue; }
    const j = await r.json();
    if (!r.ok) throw new Error(`Notion ${r.status}: ${j?.message || "request failed"}`);
    return j;
  }
  throw new Error("Notion kept rate-limiting");
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("POST only", { status: 405 });
  if (!(await secretOk(req.headers.get("x-brain-secret")))) return new Response("forbidden", { status: 403 });
  const { source } = await req.json().catch(() => ({}));
  const src = SOURCES.find(s => s.key === source);
  if (!src) return Response.json({ error: "unknown source" }, { status: 400 });
  const started = new Date(), stamp = started.toISOString();
  const log = async (ok: boolean, rows: number, removed: number, error: string | null) =>
    sb.from("nt_sync_runs").insert({ source: src.key, started_at: stamp, finished_at: new Date().toISOString(), rows_synced: rows, rows_removed: removed, ok, error: error ? "nightly: " + error : "nightly" });
  if (!NOTION_TOKEN) { await log(false, 0, 0, "NOTION_TOKEN secret is not set"); return Response.json({ source: src.key, ok: false, error: "NOTION_TOKEN secret is not set" }, { status: 200 }); }
  let rows = 0, removed = 0, cursor: string | undefined, complete = false;
  try {
    let batch: any[] = [];
    const flush = async () => {
      if (!batch.length) return;
      const { error } = await sb.from(src.table).upsert(batch, { onConflict: "id" });
      if (error) throw new Error("Supabase write failed: " + error.message);
      batch = [];
    };
    do {
      const page = await notionQuery(src.ds, cursor);
      for (const r of page.results || []) {
        if (r.object !== "page" || r.in_trash || r.archived) continue;
        const rec: any = { id: r.id, url: pageUrl(r.id), synced_at: stamp };
        for (const [n, pg, kind] of src.cols) rec[pg] = convert(propValue(r.properties?.[propName(n)]), kind);
        batch.push(rec); rows++;
      }
      if (batch.length >= 300) await flush();
      cursor = page.has_more ? page.next_cursor : undefined;
      if (cursor) await sleep(350);
    } while (cursor);
    await flush();
    complete = true;
    // Only prune rows Notion no longer has when the read finished and looks whole
    // (a sudden drop below 80% of what Supabase holds is treated as a partial read, not deletions).
    const { count: before } = await sb.from(src.table).select("id", { count: "exact", head: true });
    if (rows > 0 && rows >= 0.8 * (before || 0)) {
      const { data, error } = await sb.rpc("nt_prune_stale", { tbl: src.table, stamp });
      if (error) throw new Error("Cleanup failed: " + error.message);
      removed = Number(data) || 0;
    }
    await log(true, rows, removed, null);
    return Response.json({ source: src.key, ok: true, rows, removed, seconds: Math.round((Date.now() - started.getTime()) / 1000) });
  } catch (e) {
    await log(false, rows, removed, String((e as Error)?.message || e));
    return Response.json({ source: src.key, ok: false, rows, complete, error: String((e as Error)?.message || e) }, { status: 200 });
  }
});
