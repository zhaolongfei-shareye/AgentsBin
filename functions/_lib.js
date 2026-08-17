export function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json; charset=utf-8" }
  });
}

export async function initDB(db) {
  await db.prepare(
    `CREATE TABLE IF NOT EXISTS events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      ts TEXT NOT NULL,
      kind TEXT NOT NULL,
      name TEXT NOT NULL,
      version TEXT DEFAULT '',
      source TEXT DEFAULT '',
      ip_hash TEXT DEFAULT '',
      country TEXT DEFAULT '',
      ua TEXT DEFAULT '',
      product TEXT DEFAULT ''
    )`
  ).run();
  await db.prepare("CREATE INDEX IF NOT EXISTS idx_events_date ON events(date)").run();
  await db.prepare("CREATE INDEX IF NOT EXISTS idx_events_kind ON events(kind, name)").run();
  try {
    await db.prepare("ALTER TABLE events ADD COLUMN country TEXT DEFAULT ''").run();
  } catch {}
  try {
    await db.prepare("ALTER TABLE events ADD COLUMN product TEXT DEFAULT ''").run();
  } catch {}
}

export function b64urlEncode(data) {
  return btoa(String.fromCharCode(...new Uint8Array(data)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

export function b64urlDecode(text) {
  const base64 = text.replace(/-/g, "+").replace(/_/g, "/");
  const padded = base64 + "=".repeat((4 - (base64.length % 4)) % 4);
  const bytes = Uint8Array.from(atob(padded), (c) => c.charCodeAt(0));
  return new TextDecoder().decode(bytes);
}

export function b64urlDecodeBytes(text) {
  const base64 = text.replace(/-/g, "+").replace(/_/g, "/");
  const padded = base64 + "=".repeat((4 - (base64.length % 4)) % 4);
  return Uint8Array.from(atob(padded), (c) => c.charCodeAt(0));
}

export async function sha256Hex(text) {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(text));
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

async function cookieKey(env) {
  const secret = env.ADMIN_COOKIE_SECRET || env.GOOGLE_CLIENT_SECRET || "agentsbin-dev-secret";
  return crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign", "verify"]
  );
}

export async function signValue(value, env) {
  const key = await cookieKey(env);
  const sig = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(value));
  return b64urlEncode(sig);
}

export async function verifyValue(value, sig, env) {
  const key = await cookieKey(env);
  const expected = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(value));
  const expectedB64 = b64urlEncode(expected);
  return expectedB64 === sig;
}

export function adminEmail(env) {
  return (env.ADMIN_EMAIL || "zhaolongfei@gmail.com").trim().toLowerCase();
}

export async function getSessionEmail(request, env) {
  const cookie = request.headers.get("Cookie") || "";
  const match = cookie.split(";").map((c) => c.trim()).find((c) => c.startsWith("agentsbin_admin="));
  if (!match) return null;
  const token = match.slice("agentsbin_admin=".length);
  const parts = token.split(".");
  if (parts.length < 3) return null;
  const sig = parts.pop();
  const exp = Number(parts.pop());
  const email = parts.join(".");
  if (!email || !exp || exp < Date.now() / 1000) return null;
  if (!(await verifyValue(email + "." + exp, sig, env))) return null;
  return email;
}

export function sessionCookie(email) {
  const exp = Math.floor(Date.now() / 1000) + 7 * 24 * 3600;
  return { email, exp };
}

export function ipHash(request) {
  const xff = request.headers.get("CF-Connecting-IP") || request.headers.get("x-forwarded-for") || "unknown";
  return sha256Hex("ab:" + xff).then((h) => h.slice(0, 16));
}
