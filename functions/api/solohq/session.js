import { getSoloUser, noStore } from "./_lib.js";
import { json } from "../../_lib.js";

export async function onRequest(context) {
  const user = await getSoloUser(context.request, context.env);
  return noStore(json({ ok: true, user }));
}
