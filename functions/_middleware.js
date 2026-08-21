export async function onRequest(context) {
  const url = new URL(context.request.url);
  if (url.hostname === "solohq.agentsbin.com" && url.pathname === "/") {
    return Response.redirect(`${url.origin}/solohq/home/`, 302);
  }
  if (
    url.hostname === "www.agentsbin.com" &&
    (url.pathname === "/solohq/home" || url.pathname.startsWith("/solohq/home/") || url.pathname === "/solohq/demo" || url.pathname.startsWith("/solohq/demo/"))
  ) {
    return Response.redirect(`https://solohq.agentsbin.com${url.pathname}${url.search}`, 302);
  }
  return context.next();
}
