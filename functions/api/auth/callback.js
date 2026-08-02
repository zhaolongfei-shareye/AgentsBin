import { signValue, adminEmail } from "../../_lib.js";

function clearStateCookie() {
  return "agentsbin_oauth_state=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0";
}

function failPage(reason, detail) {
  return new Response(
    `<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Sign in failed</title>
    <style>body{background:#0b0f14;color:#f2f5f8;font-family:-apple-system,BlinkMacSystemFont,sans-serif;display:grid;place-items:center;min-height:100vh;margin:0}.box{max-width:480px;text-align:center}.err{color:#ff5f57;font-weight:700;font-size:18px}.detail{color:#8b98a8;font-size:13px;margin:10px 0 22px}a{color:#0a84ff;text-decoration:none}</style>
    <body><div class="box"><div class="err">Sign in failed</div><div class="detail">${detail || ""} (${reason || "unknown"})</div><a href="/agentsbin-jz-admin">Back to stats</a></div></body></html>`,
    { status: 200, headers: { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-store" } }
  );
}

export async function onRequest(context) {
  const { request, env } = context;
  const url = new URL(request.url);
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");
  const cookies = (request.headers.get("Cookie") || "").split(";").map((c) => c.trim());
  const savedState = cookies
    .find((c) => c.startsWith("agentsbin_oauth_state="))
    ?.slice("agentsbin_oauth_state=".length);

  if (!code || !state || !savedState || state !== savedState) {
    return failPage("bad_state", "Login state check failed. Please go back and try again.");
  }

  const clientId = env.GOOGLE_CLIENT_ID;
  const clientSecret = env.GOOGLE_CLIENT_SECRET;
  if (!clientId || !clientSecret) return failPage("missing_config", "Google login is not configured.");

  const tokenBody = new URLSearchParams({
    client_id: clientId,
    client_secret: clientSecret,
    code,
    redirect_uri: "https://www.agentsbin.com/api/auth/callback",
    grant_type: "authorization_code"
  });

  let tokenResponse;
  try {
    tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: tokenBody.toString()
    });
  } catch {
    return failPage("token_network", "Could not reach Google token endpoint.");
  }
  if (!tokenResponse.ok) {
    const tokenErr = await tokenResponse.text();
    return failPage("token", "Google rejected the token request: " + tokenErr.slice(0, 200));
  }
  const token = await tokenResponse.json();
  const accessToken = token.access_token;
  if (!accessToken) {
    return failPage("token", "Google token response did not include an access token.");
  }

  let user;
  try {
    const userRes = await fetch("https://www.googleapis.com/oauth2/v2/userinfo", {
      headers: { Authorization: "Bearer " + accessToken }
    });
    if (!userRes.ok) throw new Error("userinfo failed");
    user = await userRes.json();
  } catch {
    return failPage("userinfo", "Could not fetch the Google account profile.");
  }

  const email = String(user.email || "").toLowerCase();
  if (!email || email !== adminEmail(env)) {
    return failPage("denied", "This Google account is not the owner. Logged in as " + (email || "unknown"));
  }

  const exp = Math.floor(Date.now() / 1000) + 7 * 24 * 3600;
  const sig = await signValue(email + "." + exp, env);
  const session = email + "." + exp + "." + sig;
  return new Response(null, {
    status: 302,
    headers: {
      Location: "/agentsbin-jz-admin?ok=1",
      "Set-Cookie":
        "agentsbin_admin=" + session + "; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=604800"
    }
  });
}
