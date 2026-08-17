import { getSoloUser, unauthorized } from "../_lib.js";

export async function onRequest(context) {
  const { env, request } = context;
  const user = await getSoloUser(request, env);
  if (!user) return unauthorized();
  if (!env.GOOGLE_CLIENT_ID || !env.GOOGLE_CLIENT_SECRET) {
    return new Response("Google login is not configured.", { status: 503 });
  }

  const origin = new URL(request.url).hostname === "solohq.agentsbin.com"
    ? "https://solohq.agentsbin.com"
    : "https://www.agentsbin.com";
  const requestedProject = new URL(request.url).searchParams.get("project") || "";
  const project = requestedProject.slice(0, 128);
  const state = crypto.randomUUID();
  const params = new URLSearchParams({
    client_id: env.GOOGLE_CLIENT_ID,
    redirect_uri: `${origin}/api/solohq/auth/callback`,
    response_type: "code",
    scope: "openid email profile https://www.googleapis.com/auth/drive.file",
    state,
    access_type: "offline",
    include_granted_scopes: "true",
    prompt: "consent"
  });
  const headers = new Headers({ Location: `https://accounts.google.com/o/oauth2/v2/auth?${params}` });
  headers.append("Set-Cookie", `solohq_oauth_state=${state}; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=600`);
  headers.append("Set-Cookie", "solohq_oauth_mode=docs; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=600");
  headers.append("Set-Cookie", `solohq_docs_project=${encodeURIComponent(project)}; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=600`);
  return new Response(null, { status: 302, headers });
}
