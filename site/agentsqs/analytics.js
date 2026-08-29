(function () {
  if (location.protocol !== "https:" && location.protocol !== "http:") return;

  function deviceType() {
    const ua = navigator.userAgent || "";
    if (/iPad|Tablet|Android(?!.*Mobile)/i.test(ua)) return "tablet";
    if (/Mobi|Android|iPhone|iPod/i.test(ua)) return "mobile";
    return "desktop";
  }

  function track(name) {
    const payload = JSON.stringify({
      kind: "engagement",
      name,
      version: "2026.08.29",
      source: "web-" + deviceType(),
      product: "agentsqs"
    });
    if (navigator.sendBeacon) {
      navigator.sendBeacon("/api/track", new Blob([payload], { type: "application/json" }));
    } else {
      fetch("/api/track", { method: "POST", headers: { "Content-Type": "application/json" }, body: payload, keepalive: true });
    }
  }

  track("product_page_view");
  document.querySelector("a.primary")?.addEventListener("click", () => track("open_screener"));
  document.querySelector("a.ghost")?.addEventListener("click", () => track("view_strategy"));
  document.getElementById("lang")?.addEventListener("click", () => track("language_switch"));
})();
