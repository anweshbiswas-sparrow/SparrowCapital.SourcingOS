import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

// Embeds Deal Brain documents with the built-in gte-small model (384 dims).
// Callers must send the shared secret stored in public.brain_config (key embed_secret).
const model = new Supabase.ai.Session("gte-small");
const sb = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
  auth: { persistSession: false },
});
let cachedSecret: string | null = null;

async function secretOk(given: string | null): Promise<boolean> {
  if (!given) return false;
  if (!cachedSecret) {
    const { data, error } = await sb.from("brain_config").select("value").eq("key", "embed_secret").single();
    if (error || !data) return false;
    cachedSecret = data.value;
  }
  return given === cachedSecret;
}

// gte-small reads at most 512 tokens; ~1500 chars keeps the most informative head of each doc
const embed = (text: string) =>
  model.run(text.slice(0, 1500), { mean_pool: true, normalize: true }) as Promise<number[]>;

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("POST only", { status: 405 });
  if (!(await secretOk(req.headers.get("x-brain-secret")))) return new Response("forbidden", { status: 403 });
  const body = await req.json().catch(() => ({}));

  if (body.mode === "query") {
    const text = String(body.text ?? "").trim();
    if (!text) return Response.json({ error: "text required" }, { status: 400 });
    return Response.json({ embedding: await embed(text) });
  }

  if (body.mode === "pending") {
    // Stay well inside the per-request CPU budget: stop after ~budgetMs of work.
    const limit = Math.max(1, Math.min(Number(body.limit) || 12, 50));
    const budgetMs = Math.max(200, Math.min(Number(body.budget_ms) || 900, 3000));
    const t0 = Date.now();
    const { data, error } = await sb.from("brain_docs").select("id,title,body").is("embedding", null).limit(limit);
    if (error) return Response.json({ error: error.message }, { status: 500 });
    let done = 0;
    const errors: string[] = [];
    for (const d of data ?? []) {
      if (Date.now() - t0 > budgetMs) break;
      try {
        const e = await embed(d.title + "\n" + d.body);
        const { error: ue } = await sb.from("brain_docs")
          .update({ embedding: JSON.stringify(e), embedded_at: new Date().toISOString() })
          .eq("id", d.id);
        if (ue) errors.push(d.id + ": " + ue.message); else done++;
      } catch (err) {
        errors.push(d.id + ": " + String(err));
      }
    }
    const { count } = await sb.from("brain_docs").select("id", { count: "exact", head: true }).is("embedding", null);
    return Response.json({ embedded: done, remaining: count ?? null, errors: errors.slice(0, 5) });
  }

  return Response.json({ error: "mode must be query or pending" }, { status: 400 });
});
