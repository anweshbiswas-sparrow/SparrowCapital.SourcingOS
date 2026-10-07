// Builds hub.html from hub-src.html plus the two app sources (with small hub-specific edits).
const fs = require("fs");
const S = "/tmp/claude-0/-home-claude/c2db7b3b-50fa-5806-80d8-b294abdae53c/scratchpad/";
const must = (src, a, b, label) => { if (!src.includes(a)) throw new Error("patch target missing: " + label); return src.replace(a, b); };

// Deal Brain: same page, plus the hub's write functions in the blocklist.
let brain = fs.readFileSync(S + "deal-brain.html", "utf8");
if (!brain.includes("hub_\\w*")) brain = must(brain, "brain_save_\\w*|", "brain_save_\\w*|hub_\\w*|er_load|", "blocklist");
fs.writeFileSync(S + "deal-brain.html", brain);   // standalone copy gets the same safety fix
brain = must(brain, 'default: return "Something went wrong reaching Claude. Try again.";', 'default: return "Something went wrong reaching Claude" + (e?.code ? " (" + e.code + (e?.message ? ": " + String(e.message).slice(0, 120) : "") + ")" : e?.message ? " (" + String(e.message).slice(0, 120) + ")" : "") + ". Try again.";', "sample error text");
brain = brain.replace("Reads your Supabase copy of Deal Analysis - Anwesh, refreshed from Notion every night.", "Reads your Supabase copy of Deal Analysis - Anwesh. Sync it from the Notion Sync tab.");

// Notion Sync: "Sync all" follows the source switches in Settings.
let sync = fs.readFileSync(S + "notion-sync/notion-sync.html", "utf8");
sync = must(sync, `$("#syncAll").onclick = () => runSources(SOURCES);`,
`let hubSync = {};
async function loadHubSync(){
  try { const mcp = await getMcp(); const [{ v }] = await supaRows(mcp, "select value as v from public.brain_config where key = 'hub_settings'"); hubSync = (JSON.parse(v || "{}").sync) || {}; } catch { hubSync = {}; }
  const d = hubSync.content_days || 45;
  $("#cDet").textContent = $("#cDet").textContent.replace(/last \\d+ days/, "last " + d + " days");
  return hubSync;
}
$("#syncAll").onclick = async () => {
  if (running) return;
  await loadHubSync();
  const on = SOURCES.filter(s => hubSync.sources?.[s.key] !== false), off = SOURCES.filter(s => !on.includes(s));
  if (off.length) log("Skipping " + off.map(s => s.title).join(", ") + " (switched off in Settings)");
  if (!on.length && hubSync.content === false) { log("Every source is switched off in Settings.", true); return; }
  runSources(on.length ? on : [], true);
};
loadHubSync();`, "syncAll");
sync = must(sync, "async function runSources(list){", "async function runSources(list, all){", "runSources sig");
sync = must(sync, "if (list.length > 1 && !stopFlag) {", "if ((all ? hubSync.content !== false : list.length > 1) && !stopFlag) {", "content flag");
sync = sync.replace("Notion is only read, never changed.", "This tab only reads Notion; deal edits from the Edit data tab write back to it.");

const enc = s => JSON.stringify(s).replace(/<\//g, "<\\/").replace(/<!--/g, "<\\!--");
let hub = fs.readFileSync(S + "hub/hub-src.html", "utf8");
hub = must(hub, "/*__CHILDREN__*/", `const CHILD = { brain: ${enc(brain)}, sync: ${enc(sync)} };`, "children");
fs.writeFileSync(S + "hub/deal-hub.html", hub);
console.log("ok", hub.length);
