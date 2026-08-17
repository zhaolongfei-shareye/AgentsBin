export async function onRequest(context) {
  const url = new URL(context.request.url);
  if (url.hostname === "solohq.agentsbin.com" && url.pathname === "/") {
    return Response.redirect(`${url.origin}/solohq/home/`, 302);
  }
  return context.next();
}
