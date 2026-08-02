import { json, signValue, adminEmail } from "../../_lib.js";

function clearStateCookie() {
  return "agentsbin_oauth_state=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0";
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
    return new Response(null, {
      status: 302,
      headers: { Location: "/agentsbin-jz-admin?auth=failed", "Set-Cookie": clearStateCookie() }
    });
  }

  const clientId = env.GOOGLE_CLIENT_ID;
  const clientSecret = env.GOOGLE_CLIENT_SECRET;
  if (!clientId || !clientSecret) return json({ ok: false, error: "not configured" }, 503);

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
    return new Response(null, {
      status: 302,
      headers: { Location: "/agentsbin-jz-admin?auth=failed", "Set-Cookie": clearStateCookie() }
    });
  }
  if (!tokenResponse.ok) {
    return new Response(null, {
      status: 302,
      headers: { Location: "/agentsbin-jz-admin?auth=failed", "Set-Cookie": clearStateCookie() }
    });
  }
  const token = await tokenResponse.json();
  const accessToken = token.access_token;
  if (!accessToken) {
    return new Response(null, {
      status: 302,
      headers: { Location: "/agentsbin-jz-admin?auth=failed", "Set-Cookie": clearStateCookie() }
    });
  }

  let user;
  try {
    const userRes = await fetch("https://www.googleapis.com/oauth2/v2/userinfo", {
      headers: { Authorization: "Bearer " + accessToken }
    });
    if (!userRes.ok) throw new Error("userinfo failed");
    user = await userRes.json();
  } catch {
    return new Response(null, {
      status: 302,
      headers: { Location: "/agentsbin-jz-admin?auth=failed", "Set-Cookie": clearStateCookie() }
    });
  }

  const email = String(user.email || "").toLowerCase();
  if (!email || email !== adminEmail(env)) {
    return new Response(null, {
      status: 302,
      headers: { Location: "/agentsbin-jz-admin?auth=denied", "Set-Cookie": clearStateCookie() }
    });
  }

  const exp = Math.floor(Date.now() / 1000) + 7 * 24 * 3600;
  const sig = await signValue(email + "." + exp, env);
  const session = email + "." + exp + "." + sig;
  return new Response(null, {
    status: 302,
    headers: {
      Location: "/agentsbin-jz-admin",
      "Set-Cookie":
        "agentsbin_admin=" + session + "; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=604800"
    }
  });
}
