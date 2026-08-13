(function () {
  var css = [
    ".about { max-width:1080px; margin:0 auto; width:100%; border-top:1px solid rgba(255,255,255,0.12); padding:12px 0; display:flex; align-items:center; justify-content:space-between; gap:20px; flex-wrap:wrap; }",
    ".about-left { display:flex; align-items:center; gap:10px; }",
    ".about .avatar { width:48px; height:48px; border-radius:50%; overflow:hidden; flex-shrink:0; box-shadow:0 0 0 3px rgba(34,211,238,0.3); }",
    ".about .avatar img { width:100%; height:100%; object-fit:cover; display:block; }",
    ".about-role { color:#22d3ee; font-size:12px; font-weight:600; line-height:1.3; }",
    ".about h3 { font-size:16px; line-height:1.3; margin:0; }",
    ".about p { color:#8b98a8; font-size:12px; margin:1px 0 0; line-height:1.4; }",
    ".about-right { display:grid; grid-template-columns:repeat(2, auto); gap:6px 26px; justify-items:start; align-items:center; }",
    ".about-right div { display:flex; align-items:baseline; gap:8px; white-space:nowrap; }",
    ".about-right .tag { display:inline-block; min-width:64px; font-size:11px; font-weight:600; color:#8b98a8; background:#141a23; border:1px solid rgba(255,255,255,0.1); border-radius:20px; padding:5px 11px; }",
    ".about-right b { font-size:12px; color:#eef2f6; font-weight:600; }"
  ].join("\n");
  var style = document.createElement("style");
  style.textContent = css;
  document.head.appendChild(style);

  var html = [
    '<section class="about" id="about">',
    '<div class="about-left">',
    '<div class="avatar"><img src="/assets/home/author-avatar.jpg" alt="Jacky Zhao"></div>',
    '<div>',
    '<div class="about-role" data-i18n="about_role">Indie developer · macOS AI tools</div>',
    '<h3 data-i18n="about_name">Jacky Zhao</h3>',
    '<p data-i18n="about_bio">Local first. Clean interfaces. Your data stays yours.</p>',
    '</div>',
    '</div>',
    '<div class="about-right">',
    '<div><span class="tag" data-i18n="acct_email">Email</span><b>zhaolongfei@gmail.com</b></div>',
    '<div><span class="tag" data-i18n="acct_facebook">Facebook</span><b>zhaolongfei@gmail.com</b></div>',
    '<div><span class="tag" data-i18n="acct_x">X</span><b>@longfei_shareye</b></div>',
    '<div><span class="tag" data-i18n="acct_wechat">WeChat</span><b>shareye</b></div>',
    '</div>',
    '</section>'
  ].join("\n");

  function inject() {
    var host = document.getElementById("aboutPlaceholder");
    if (host) host.innerHTML = html;
  }
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", inject);
  } else {
    inject();
  }
})();
