import { initDB, json, getSessionEmail, adminEmail } from "../_lib.js";

function daysAgo(n) {
  const d = new Date();
  d.setUTCDate(d.getUTCDate() - (n - 1));
  return d.toISOString().slice(0, 10);
}

export async function onRequest(context) {
  const { request, env } = context;
  const email = await getSessionEmail(request, env);
  if (!email || email.toLowerCase() !== adminEmail(env)) {
    return json({ ok: false, error: "unauthorized" }, 401);
  }

  const db = env.DB;
  await initDB(db);
  const range = Math.min(365, Math.max(1, Number(new URL(request.url).searchParams.get("range") || 30)));
  const product = String(new URL(request.url).searchParams.get("product") || "").slice(0, 16);
  const cutoff = daysAgo(range);
  const productSql = product ? " AND product = ?" : "";
  const baseArgs = [cutoff];
  if (product) baseArgs.push(product);

  const [kindRows, agentRows, sourceRows, countryRows] = await Promise.all([
    db
      .prepare(`SELECT date, kind, COUNT(*) AS n FROM events WHERE date >= ?${productSql} GROUP BY date, kind ORDER BY date ASC`)
      .bind(...baseArgs)
      .all(),
    db
      .prepare(
        `SELECT name, COUNT(*) AS n FROM events WHERE kind = 'agent_open' AND date >= ?${productSql} GROUP BY name ORDER BY n DESC LIMIT 12`
      )
      .bind(...baseArgs)
      .all(),
    db.prepare(`SELECT source, COUNT(*) AS n FROM events WHERE date >= ?${productSql} GROUP BY source`).bind(...baseArgs).all(),
    db
      .prepare(`SELECT country, kind, COUNT(*) AS n FROM events WHERE country != '' AND date >= ?${productSql} GROUP BY country, kind`)
      .bind(...baseArgs)
      .all()
  ]);

  const byDate = {};
  const totals = { downloads: 0, app_opens: 0, agent_opens: 0, page_views: 0 };
  for (const row of kindRows.results || []) {
    byDate[row.date] = byDate[row.date] || { date: row.date, downloads: 0, app_opens: 0, agent_opens: 0, page_views: 0 };
    if (row.kind === "download") byDate[row.date].downloads = row.n;
    if (row.kind === "app_open") byDate[row.date].app_opens = row.n;
    if (row.kind === "agent_open") byDate[row.date].agent_opens = row.n;
    if (row.kind === "page_view") byDate[row.date].page_views = row.n;
  }
  for (const d of Object.values(byDate)) {
    totals.downloads += d.downloads;
    totals.app_opens += d.app_opens;
    totals.agent_opens += d.agent_opens;
    totals.page_views += d.page_views;
  }

  const byCountry = {};
  for (const row of countryRows.results || []) {
    byCountry[row.country] = byCountry[row.country] || { code: row.country, count: 0, downloads: 0, app_opens: 0, agent_opens: 0, page_views: 0 };
    const c = byCountry[row.country];
    c.count += row.n;
    if (row.kind === "download") c.downloads = row.n;
    if (row.kind === "app_open") c.app_opens = row.n;
    if (row.kind === "agent_open") c.agent_opens = row.n;
    if (row.kind === "page_view") c.page_views = row.n;
  }
  const countries = Object.values(byCountry).sort((a, b) => b.count - a.count).slice(0, 20);

  return json({
    ok: true,
    range,
    totals,
    daily: Object.values(byDate).reverse(),
    topAgents: (agentRows.results || []).map((r) => ({ name: r.name, count: r.n })),
    sources: (sourceRows.results || []).reduce((acc, r) => {
      acc[r.source] = r.n;
      return acc;
    }, {}),
    countries
  });
}
