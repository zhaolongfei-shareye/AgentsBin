import { clearSessionCookie } from "../_lib.js";

export async function onRequest() {
  return new Response(null, {
    status: 302,
    headers: {
      Location: "/solohq/home/",
      "Set-Cookie": clearSessionCookie(),
      "Cache-Control": "no-store"
    }
  });
}
