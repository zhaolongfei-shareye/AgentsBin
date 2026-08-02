import { initDB, json, ipHash } from "../_lib.js";

const KINDS = new Set(["download", "app_open", "agent_open"]);

export async function onRequest(context) {
  const { request, env } = context;
  if (request.method !== "POST") return json({ ok: false, error: "method" }, 405);

  let body;
  try {
    if (Number(request.headers.get("content-length") || 0) > 4096) {
      return json({ ok: false, error: "too large" }, 413);
    }
    body = await request.json();
  } catch {
    return json({ ok: false, error: "bad json" }, 400);
  }

  const kind = String(body.kind || "");
  const name = String(body.name || "").slice(0, 128);
  const version = String(body.version || "").slice(0, 32);
  const source = String(body.source || "web").slice(0, 16);
  if (!KINDS.has(kind) || !name) return json({ ok: false, error: "bad payload" }, 400);

  const db = env.DB;
  try {
    await initDB(db);
  } catch (error) {
    return json({ ok: false, error: "db: " + String(error && error.message || error) }, 500);
  }

  const hash = await ipHash(request);
  const date = new Date().toISOString().slice(0, 10);
  const row = await db
    .prepare("SELECT COUNT(*) AS n FROM events WHERE ip_hash = ? AND kind = ? AND date = ?")
    .bind(hash, kind, date)
    .first();
  if ((row?.n || 0) > 40) return json({ ok: false, error: "rate limited" }, 429);

  const ua = String(request.headers.get("user-agent") || "").slice(0, 200);
  await db
    .prepare("INSERT INTO events (date, ts, kind, name, version, source, ip_hash, ua) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")
    .bind(date, new Date().toISOString(), kind, name, version, source, hash, ua)
    .run();

  return json({ ok: true });
}
