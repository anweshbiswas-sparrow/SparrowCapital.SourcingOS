import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
// Owner-only: lists the Gemini models this API key can use (names only, no key exposed).
const sb = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, { auth: { persistSession: false } });
Deno.serve(async (req) => {
  const { data } = await sb.from("brain_config").select("value").eq("key", "embed_secret").single();
  if (!data || req.headers.get("x-brain-secret") !== data.value) return new Response("forbidden", { status: 403 });
  const key = Deno.env.get("GEMINI_API_KEY") ?? "";
  const r = await fetch("https://generativelanguage.googleapis.com/v1beta/models?pageSize=200&key=" + key);
  const j = await r.json();
  const models = (j.models || []).filter((m: any) => (m.supportedGenerationMethods || []).includes("generateContent")).map((m: any) => m.name.replace("models/", ""));
  return Response.json({ status: r.status, models, error: j.error?.message });
});
