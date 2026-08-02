export async function onRequest(context) {
  const { env } = context;
  const clientId = env.GOOGLE_CLIENT_ID;
  const clientSecret = env.GOOGLE_CLIENT_SECRET;
  if (!clientId || !clientSecret) {
    return new Response(
      "<html><body><h1>Google login is not configured yet</h1><p>Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET.</p></body></html>",
      { status: 503, headers: { "Content-Type": "text/html; charset=utf-8" } }
    );
  }

  const redirectUri = "https://www.agentsbin.com/api/auth/callback";
  const bytes = crypto.getRandomValues(new Uint8Array(24));
  const state = btoa(String.fromCharCode(...bytes)).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
  const params = new URLSearchParams({
    client_id: clientId,
    redirect_uri: redirectUri,
    response_type: "code",
    scope: "openid email profile",
    state,
    prompt: "consent",
    access_type: "online"
  });

  return new Response(null, {
    status: 302,
    headers: {
      Location: "https://accounts.google.com/o/oauth2/v2/auth?" + params.toString(),
      "Set-Cookie":
        "agentsbin_oauth_state=" + state + "; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=600"
    }
  });
}
