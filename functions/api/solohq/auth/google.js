export async function onRequest(context) {
  const { env, request } = context;
  if (!env.GOOGLE_CLIENT_ID || !env.GOOGLE_CLIENT_SECRET) {
    return new Response("Google login is not configured.", { status: 503 });
  }

  const origin = new URL(request.url).hostname === "solohq.agentsbin.com"
    ? "https://solohq.agentsbin.com"
    : "https://www.agentsbin.com";
  const state = crypto.randomUUID();
  const params = new URLSearchParams({
    client_id: env.GOOGLE_CLIENT_ID,
    redirect_uri: `${origin}/api/solohq/auth/callback`,
    response_type: "code",
    scope: "openid email profile",
    state,
    prompt: "select_account"
  });

  return new Response(null, {
    status: 302,
    headers: {
      Location: `https://accounts.google.com/o/oauth2/v2/auth?${params}`,
      "Set-Cookie": `solohq_oauth_state=${state}; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=600`
    }
  });
}
