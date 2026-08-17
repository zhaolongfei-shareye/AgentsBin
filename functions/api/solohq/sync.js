import { ensureWorkspaceTable, getSoloUser, noStore, unauthorized } from "./_lib.js";
import { json } from "../../_lib.js";

const MAX_WORKSPACE_BYTES = 1024 * 1024;

export async function onRequest(context) {
  const { request, env } = context;
  const user = await getSoloUser(request, env);
  if (!user) return noStore(unauthorized());
  if (!env.DB) return noStore(json({ ok: false, error: "storage_unavailable" }, 503));
  await ensureWorkspaceTable(env.DB);

  if (request.method === "GET") {
    const row = await env.DB.prepare("SELECT data_json, revision, updated_at FROM solohq_workspaces WHERE user_id = ?").bind(user.sub).first();
    if (!row) return noStore(json({ ok: true, workspace: null }));
    try {
      return noStore(json({ ok: true, workspace: { data: JSON.parse(row.data_json), revision: row.revision, updatedAt: row.updated_at } }));
    } catch {
      return noStore(json({ ok: false, error: "stored_data_invalid" }, 500));
    }
  }

  if (request.method === "DELETE") {
    await env.DB.prepare("DELETE FROM solohq_workspaces WHERE user_id = ?").bind(user.sub).run();
    return noStore(json({ ok: true }));
  }

  if (request.method !== "PUT") return noStore(json({ ok: false, error: "method_not_allowed" }, 405));
  const raw = await request.text();
  if (raw.length > MAX_WORKSPACE_BYTES) return noStore(json({ ok: false, error: "workspace_too_large" }, 413));
  let body;
  try { body = JSON.parse(raw); } catch { return noStore(json({ ok: false, error: "invalid_json" }, 400)); }
  if (!body?.data || typeof body.data !== "object" || Array.isArray(body.data)) return noStore(json({ ok: false, error: "invalid_workspace" }, 400));
  const current = await env.DB.prepare("SELECT revision FROM solohq_workspaces WHERE user_id = ?").bind(user.sub).first();
  const expectedRevision = Number(body.revision || 0);
  if (current && !body.force && Number(current.revision) !== expectedRevision) {
    return noStore(json({ ok: false, error: "conflict", revision: current.revision }, 409));
  }
  const updatedAt = new Date().toISOString();
  const dataJson = JSON.stringify(body.data);
  await env.DB.prepare(
    `INSERT INTO solohq_workspaces (user_id, email, display_name, data_json, revision, updated_at)
     VALUES (?, ?, ?, ?, 1, ?)
     ON CONFLICT(user_id) DO UPDATE SET email = excluded.email, display_name = excluded.display_name, data_json = excluded.data_json, revision = solohq_workspaces.revision + 1, updated_at = excluded.updated_at`
  ).bind(user.sub, user.email, user.name, dataJson, updatedAt).run();
  const saved = await env.DB.prepare("SELECT revision FROM solohq_workspaces WHERE user_id = ?").bind(user.sub).first();
  return noStore(json({ ok: true, revision: saved.revision, updatedAt }));
}
