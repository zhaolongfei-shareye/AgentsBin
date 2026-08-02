import { getSessionEmail, adminEmail } from "./_lib.js";

const page = (body) =>
  `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="robots" content="noindex, nofollow">
  <title>AgentsBin Stats</title>
  <style>
    :root { color-scheme: dark; }
    * { box-sizing: border-box; }
    body {
      margin: 0; background: #0b0f14; color: #f2f5f8;
      font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Arial, sans-serif;
      line-height: 1.5;
    }
    .wrap { max-width: 1080px; margin: 0 auto; padding: 36px 22px 80px; }
    header { display: flex; align-items: center; justify-content: space-between; gap: 16px; margin-bottom: 26px; flex-wrap: wrap; }
    .logo { display: flex; align-items: center; gap: 12px; }
    .logo-ic { width: 40px; height: 40px; border-radius: 11px; background: #0a84ff; color: #fff; display: grid; place-items: center; font-weight: 900; font-size: 17px; box-shadow: 0 6px 18px rgba(10,132,255,.35); }
    h1 { font-size: 24px; margin: 0; }
    .sub { color: #8b98a8; font-size: 13px; }
    .btn {
      display: inline-flex; align-items: center; gap: 8px; padding: 10px 16px; border-radius: 10px;
      background: #0a84ff; color: #fff; font-weight: 700; font-size: 14px; text-decoration: none; border: 0; cursor: pointer;
    }
    .btn:hover { filter: brightness(1.1); }
    .btn.ghost { background: transparent; border: 1px solid rgba(255,255,255,.18); color: #f2f5f8; }
    .auth { max-width: 420px; margin: 80px auto; background: #11161d; border: 1px solid rgba(255,255,255,.1); border-radius: 16px; padding: 32px; text-align: center; }
    .auth h2 { margin: 0 0 8px; font-size: 20px; }
    .auth p { color: #8b98a8; font-size: 13px; margin: 0 0 20px; }
    .error { color: #ff5f57; font-size: 13px; margin-bottom: 14px; }
    .range { display: inline-flex; gap: 6px; }
    .range button {
      background: transparent; color: #8b98a8; border: 1px solid rgba(255,255,255,.16);
      border-radius: 999px; padding: 7px 14px; font: inherit; font-size: 12px; font-weight: 700; cursor: pointer;
    }
    .range button.on { background: #fff; color: #11161d; border-color: #fff; }
    .kpis { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-bottom: 22px; }
    .kpi { background: #11161d; border: 1px solid rgba(255,255,255,.1); border-radius: 14px; padding: 18px; }
    .kpi-label { font-size: 11px; color: #8b98a8; }
    .kpi-value { font-size: 30px; font-weight: 900; margin-top: 8px; }
    .kpi-delta { font-size: 11px; color: #30d158; margin-top: 4px; }
    .cols { display: grid; grid-template-columns: 1.25fr 1fr; gap: 16px; }
    .card { background: #11161d; border: 1px solid rgba(255,255,255,.1); border-radius: 14px; padding: 18px; }
    .card h2 { font-size: 15px; margin: 0 0 4px; }
    .card .sub { margin-bottom: 14px; }
    table { width: 100%; border-collapse: collapse; font-size: 13px; }
    th, td { text-align: left; padding: 9px 8px; border-bottom: 1px solid rgba(255,255,255,.07); }
    th { color: #8b98a8; font-size: 11px; font-weight: 700; }
    td.num, th.num { text-align: right; font-variant-numeric: tabular-nums; }
    .bar-row { display: grid; grid-template-columns: 110px 1fr 56px; gap: 10px; align-items: center; padding: 7px 0; font-size: 13px; }
    .bar-track { height: 14px; background: #1a212b; border-radius: 999px; overflow: hidden; }
    .bar-fill { height: 100%; border-radius: 999px; background: linear-gradient(90deg, #0a84ff, #30d158); min-width: 2px; }
    .bar-count { text-align: right; color: #8b98a8; font-size: 12px; }
    .empty { color: #8b98a8; text-align: center; padding: 28px 0; font-size: 13px; }
    .foot { margin-top: 26px; color: #5f6b78; font-size: 12px; }
    @media (max-width: 760px) {
      .kpis { grid-template-columns: repeat(2, 1fr); }
      .cols { grid-template-columns: 1fr; }
      .bar-row { grid-template-columns: 90px 1fr 50px; }
    }
  </style>
</head>
<body>${body}</body>
</html>`;

const loggedOut = (message) =>
  page(`
    <div class="auth">
      <div class="logo-ic" style="width:56px;height:56px;margin:0 auto 18px;font-size:22px">AB</div>
      <h2>AgentsBin Stats</h2>
      <p>Private analytics dashboard. Sign in with the owner Google account.</p>
      ${message ? `<div class="error">${message}</div>` : ""}
      <a class="btn" href="/api/auth/google">
        <svg width="18" height="18" viewBox="0 0 24 24"><path fill="#fff" d="M21.35 11.1H12v2.9h5.4c-.5 2.4-2.4 3.9-5.4 3.9-3.3 0-6-2.7-6-6s2.7-6 6-6c1.5 0 2.9.6 3.9 1.5l2.1-2.1C16.8 3.6 14.5 2.6 12 2.6 6.8 2.6 2.6 6.8 2.6 12s4.2 9.4 9.4 9.4c5.4 0 9-3.8 9-9.1 0-.8-.1-1.5-.3-2.2z"/></svg>
        Sign in with Google
      </a>
    </div>`);

const loggedIn = `
  <div class="wrap">
    <header>
      <div class="logo">
        <div class="logo-ic">AB</div>
        <div>
          <h1>AgentsBin Stats</h1>
          <div class="sub">Real download & app usage data</div>
        </div>
      </div>
      <div style="display:flex;align-items:center;gap:10px">
        <div class="range" id="range">
          <button data-range="7">7D</button>
          <button class="on" data-range="30">30D</button>
          <button data-range="90">90D</button>
          <button data-range="365">1Y</button>
        </div>
        <a class="btn ghost" href="/api/auth/logout">Sign out</a>
      </div>
    </header>
    <div class="kpis" id="kpis"></div>
    <div class="cols">
      <div class="card">
        <h2>Daily stats</h2>
        <div class="sub">Downloads, app opens and agent opens per day</div>
        <div id="dailyTable"></div>
      </div>
      <div class="card">
        <h2>Top agents</h2>
        <div class="sub">Opens through AgentsBin, selected range</div>
        <div id="topAgents"></div>
      </div>
    </div>
    <div class="foot">Data is collected from agentsbin.com and the macOS app. Timestamps are UTC.</div>
  </div>
  <script>
    const fmt = new Intl.NumberFormat();
    let currentRange = 30;
    function esc(s) { return String(s).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c])); }
    async function load(range) {
      currentRange = range;
      document.querySelectorAll("#range button").forEach((b) => b.classList.toggle("on", Number(b.dataset.range) === range));
      const res = await fetch("/api/stats?range=" + range);
      if (res.status === 401) { location.href = "/agentsbin-jz-admin"; return; }
      const data = await res.json();
      const t = data.totals;
      const peak = data.daily.reduce((m, d) => Math.max(m, d.agent_opens || 0), 0);
      const maxAgent = data.topAgents.reduce((m, a) => Math.max(m, a.count), 0) || 1;
      document.getElementById("kpis").innerHTML = [
        ["Total downloads", fmt.format(t.downloads), "DMG"],
        ["App opens", fmt.format(t.app_opens), "macOS"],
        ["Agent opens", fmt.format(t.agent_opens), "per chat open"],
        ["Active days", fmt.format(data.daily.filter((d) => d.downloads || d.app_opens || d.agent_opens).length), "of " + range + " days"]
      ].map(([label, value, delta]) =>
        '<div class="kpi"><div class="kpi-label">' + esc(label) + '</div><div class="kpi-value">' + value + '</div><div class="kpi-delta">' + esc(delta) + "</div></div>"
      ).join("");
      document.getElementById("dailyTable").innerHTML = data.daily.length
        ? '<table><thead><tr><th>Date</th><th class="num">Downloads</th><th class="num">App opens</th><th class="num">Agents</th></tr></thead><tbody>' +
          data.daily.map((d) =>
            "<tr><td>" + esc(d.date) + '</td><td class="num">' + fmt.format(d.downloads || 0) + '</td><td class="num">' + fmt.format(d.app_opens || 0) + '</td><td class="num">' + fmt.format(d.agent_opens || 0) + "</td></tr>"
          ).join("") + "</tbody></table>"
        : '<div class="empty">No data yet</div>';
      document.getElementById("topAgents").innerHTML = data.topAgents.length
        ? data.topAgents.map((a) =>
            '<div class="bar-row"><span>' + esc(a.name) + '</span><div class="bar-track"><div class="bar-fill" style="width:' + Math.max(2, Math.round((a.count / maxAgent) * 100)) + '%"></div></div><span class="bar-count">' + fmt.format(a.count) + "</span></div>"
          ).join("")
        : '<div class="empty">No agent activity yet</div>';
    }
    document.querySelectorAll("#range button").forEach((b) => b.addEventListener("click", () => load(Number(b.dataset.range))));
    load(currentRange);
  </script>`;

export async function onRequest(context) {
  const { request, env } = context;
  let email;
  try {
    email = await getSessionEmail(request, env);
  } catch (error) {
    return new Response("internal error", { status: 500 });
  }
  if (!email || email.toLowerCase() !== adminEmail(env)) {
    const url = new URL(request.url);
    const message = url.searchParams.get("ok") === "1"
      ? "Login succeeded but the session cookie was not accepted. Please try again or check your browser cookie settings."
      : url.searchParams.get("auth") === "denied"
        ? "This Google account is not the owner."
        : url.searchParams.get("auth") === "failed"
          ? "Sign in failed, please try again."
          : "";
    return new Response(loggedOut(message), {
      status: 200,
      headers: { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-store" }
    });
  }
  return new Response(page(loggedIn), {
    status: 200,
    headers: { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-store" }
  });
}
