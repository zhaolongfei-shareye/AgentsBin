import { b64urlDecode, b64urlEncode, json, signValue, verifyValue } from "../../_lib.js";

const SESSION_COOKIE = "solohq_session";

function cookieValue(request, name) {
  return (request.headers.get("Cookie") || "")
    .split(";")
    .map((part) => part.trim())
    .find((part) => part.startsWith(name + "="))
    ?.slice(name.length + 1);
}

export function sessionCookie(user) {
  const exp = Math.floor(Date.now() / 1000) + 7 * 24 * 60 * 60;
  const payload = b64urlEncode(new TextEncoder().encode(JSON.stringify({ ...user, exp })));
  return { payload, exp };
}

export async function signedSessionCookie(user, env) {
  const { payload } = sessionCookie(user);
  const signature = await signValue(payload, env);
  return `${SESSION_COOKIE}=${payload}.${signature}; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=604800`;
}

export function clearSessionCookie() {
  return `${SESSION_COOKIE}=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0`;
}

export async function getSoloUser(request, env) {
  const token = cookieValue(request, SESSION_COOKIE);
  if (!token) return null;
  const dot = token.lastIndexOf(".");
  if (dot < 1) return null;
  const payload = token.slice(0, dot);
  const signature = token.slice(dot + 1);
  if (!(await verifyValue(payload, signature, env))) return null;
  try {
    const user = JSON.parse(b64urlDecode(payload));
    if (!user?.sub || !user?.email || Number(user.exp) < Date.now() / 1000) return null;
    return { sub: String(user.sub), email: String(user.email), name: String(user.name || "") };
  } catch {
    return null;
  }
}

export async function ensureWorkspaceTable(db) {
  await db.prepare(
    `CREATE TABLE IF NOT EXISTS solohq_workspaces (
      user_id TEXT PRIMARY KEY,
      email TEXT NOT NULL,
      display_name TEXT DEFAULT '',
      data_json TEXT NOT NULL,
      revision INTEGER NOT NULL DEFAULT 1,
      updated_at TEXT NOT NULL
    )`
  ).run();
}

export function unauthorized() {
  return json({ ok: false, error: "unauthorized" }, 401);
}

export function noStore(response) {
  response.headers.set("Cache-Control", "no-store");
  return response;
}
