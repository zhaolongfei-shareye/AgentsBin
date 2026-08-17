import { encryptGoogleRefreshToken, ensureGoogleDocsTables, getSoloUser, signedSessionCookie } from "../_lib.js";

function cookieValue(request, name) {
  return (request.headers.get("Cookie") || "")
    .split(";")
    .map((part) => part.trim())
    .find((part) => part.startsWith(name + "="))
    ?.slice(name.length + 1);
}

function fail(detail) {
  return new Response(`<!doctype html><meta charset="utf-8"><title>SoloHQ sign-in failed</title><p>${detail}</p><p><a href="/solohq/home/">Back to SoloHQ</a></p>`, {
    headers: { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-store" }
  });
}

function clearOAuthCookies(headers) {
  headers.append("Set-Cookie", "solohq_oauth_state=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0");
  headers.append("Set-Cookie", "solohq_oauth_mode=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0");
  headers.append("Set-Cookie", "solohq_docs_project=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0");
}

export async function onRequest(context) {
  const { request, env } = context;
  const url = new URL(request.url);
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");
  const mode = cookieValue(request, "solohq_oauth_mode");
  const docsProject = cookieValue(request, "solohq_docs_project") || "";
  if (!code || !state || state !== cookieValue(request, "solohq_oauth_state")) return fail("Login state check failed. Please try again.");
  if (!env.GOOGLE_CLIENT_ID || !env.GOOGLE_CLIENT_SECRET) return fail("Google login is not configured.");

  const origin = url.hostname === "solohq.agentsbin.com"
    ? "https://solohq.agentsbin.com"
    : "https://www.agentsbin.com";
  const tokenBody = new URLSearchParams({
    client_id: env.GOOGLE_CLIENT_ID,
    client_secret: env.GOOGLE_CLIENT_SECRET,
    code,
    redirect_uri: `${origin}/api/solohq/auth/callback`,
    grant_type: "authorization_code"
  });
  let token;
  try {
    const response = await fetch("https://oauth2.googleapis.com/token", { method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" }, body: tokenBody });
    if (!response.ok) return fail("Google could not complete this sign-in.");
    token = await response.json();
  } catch {
    return fail("Google could not be reached. Please try again.");
  }

  try {
    const response = await fetch("https://www.googleapis.com/oauth2/v2/userinfo", { headers: { Authorization: `Bearer ${token.access_token}` } });
    if (!response.ok) return fail("Google account details could not be read.");
    const profile = await response.json();
    if (!profile.id || !profile.email) return fail("Google did not return a usable account.");
    if (mode === "docs") {
      const currentUser = await getSoloUser(request, env);
      if (!currentUser || currentUser.sub !== String(profile.id)) return fail("Please authorize Google Docs with the same account used for SoloHQ.");
      if (!env.DB || !token.refresh_token) return fail("Google Docs authorization could not be saved. Please try again.");
      const ciphertext = await encryptGoogleRefreshToken(token.refresh_token, env);
      if (!ciphertext) return fail("Google Docs sync is not configured yet.");
      await ensureGoogleDocsTables(env.DB);
      const now = new Date().toISOString();
      await env.DB.prepare(
        `INSERT INTO solohq_google_docs_credentials (user_id, refresh_token_ciphertext, folder_id, created_at, updated_at)
         VALUES (?, ?, '', ?, ?)
         ON CONFLICT(user_id) DO UPDATE SET refresh_token_ciphertext = excluded.refresh_token_ciphertext, updated_at = excluded.updated_at`
      ).bind(currentUser.sub, ciphertext, now, now).run();
      const headers = new Headers({ Location: `/solohq/home/?docs=connected&project=${encodeURIComponent(docsProject.slice(0, 128))}`, "Cache-Control": "no-store" });
      clearOAuthCookies(headers);
      return new Response(null, { status: 302, headers });
    }
    const session = await signedSessionCookie({ sub: profile.id, email: String(profile.email).toLowerCase(), name: profile.name || "" }, env);
    const headers = new Headers({ Location: "/solohq/home/?sync=choose", "Cache-Control": "no-store" });
    headers.append("Set-Cookie", session);
    clearOAuthCookies(headers);
    return new Response(null, { status: 302, headers });
  } catch {
    return fail("Google account details could not be read.");
  }
}
