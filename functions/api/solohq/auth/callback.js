import { signedSessionCookie } from "../_lib.js";

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

export async function onRequest(context) {
  const { request, env } = context;
  const url = new URL(request.url);
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");
  if (!code || !state || state !== cookieValue(request, "solohq_oauth_state")) return fail("Login state check failed. Please try again.");
  if (!env.GOOGLE_CLIENT_ID || !env.GOOGLE_CLIENT_SECRET) return fail("Google login is not configured.");

  const tokenBody = new URLSearchParams({
    client_id: env.GOOGLE_CLIENT_ID,
    client_secret: env.GOOGLE_CLIENT_SECRET,
    code,
    redirect_uri: "https://www.agentsbin.com/api/solohq/auth/callback",
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
    const session = await signedSessionCookie({ sub: profile.id, email: String(profile.email).toLowerCase(), name: profile.name || "" }, env);
    const headers = new Headers({ Location: "/solohq/home/?sync=choose", "Cache-Control": "no-store" });
    headers.append("Set-Cookie", session);
    headers.append("Set-Cookie", "solohq_oauth_state=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0");
    return new Response(null, { status: 302, headers });
  } catch {
    return fail("Google account details could not be read.");
  }
}
