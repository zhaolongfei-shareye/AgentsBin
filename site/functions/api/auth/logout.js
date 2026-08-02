export async function onRequest(context) {
  return new Response(null, {
    status: 302,
    headers: {
      Location: "/agentsbin-jz-admin",
      "Set-Cookie": "agentsbin_admin=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0"
    }
  });
}
