(function () {
  const i18n = {
    en: {
      page_title: "AgentsBin · Menu bar AI agent hub for macOS",
      page_desc: "AgentsBin is a macOS menu bar hub for AI agents with embedded web chat, a local knowledge base, and local AI summaries.",
      nav_download: "Download",
      hero_title: "All your AI agents, one menu bar away",
      hero_lead: "AgentsBin lives in the menu bar. Click the AB icon, pick an agent, and start chatting instantly — no tabs, no typing URLs, no searching.",
      hero_cta: "Download AgentsBin 1.0.0",
      hero_badge: "17 AI agents · macOS 13+ · Free",
      w_agents: "Agents",
      w_notes: "Notes",
      w_status: "Answered",
      w_user: "Explain RAG in three points",
      w_bot: "RAG retrieves external knowledge, fuses it with generation, and cites sources to reduce hallucinations.",
      w_placeholder: "Type a question…",
      w_send: "Send",
      f1t: "Lives in the menu bar",
      f1d: "Always one click away, always on top.",
      f2t: "Instant popup",
      f2d: "Click the menu bar icon and start chatting in seconds.",
      f3t: "17 AI agents built in",
      f3d: "ChatGPT, Claude, Gemini, DeepSeek, Doubao, and more are ready to use.",
      f4t: "No URL hunting",
      f4d: "No typing website addresses or digging through bookmarks.",
      agents_title: "Built-in agents",
      agents: ["ChatGPT", "Claude", "Copilot", "DeepSeek", "Doubao", "Gemini", "Grok", "Kimi", "Le Chat", "Mistral", "Perplexity", "Pi", "Poe", "Qwen", "Tongyi", "You.com", "Tencent Yuanbao"],
      dl_title: "Download AgentsBin",
      dl_name: "AgentsBin 1.0.0",
      dl_meta: "macOS 13+ · ~511 KB",
      dl_btn: "Download .pkg Installer",
      dl_note: "Currently unsigned. If blocked, right-click and choose Open.",
      contact_title: "Author & Contact",
      contact_sub: "Built by Jacky Zhao. Questions, feedback, and partnerships are welcome.",
      author_name: "Jacky Zhao",
      author_role: "Indie developer · macOS tools",
      c_email: "Email",
      c_wechat: "WeChat",
      c_facebook: "Facebook",
      c_x: "X",
      c_github: "GitHub",
      footer: "AgentsBin · Menu bar AI agent hub for macOS",
      toggle_label: "中文",
      copied: "Copied"
    },
    zh: {
      page_title: "AgentsBin · macOS 菜单栏 AI 智能体聚合",
      page_desc: "AgentsBin 是一个 macOS 菜单栏 AI 智能体聚合工具，支持网页对话、本地知识库与本地 AI 总结。",
      nav_download: "下载",
      hero_title: "所有 AI 智能体，一个菜单栏就够了",
      hero_lead: "AgentsBin 常驻菜单栏，点击 AB 图标瞬间拉起弹窗，选一个智能体立即对话，不用开标签页、不用手输网址、不用到处找。",
      hero_cta: "下载 AgentsBin 1.0.0",
      hero_badge: "内置 17 个智能体 · macOS 13+ · 免费",
      w_agents: "智能体",
      w_notes: "知识库",
      w_status: "已回复",
      w_user: "请用三点解释什么是 RAG",
      w_bot: "RAG 通过检索外部资料增强生成回答，核心是检索、融合与生成，可减少幻觉并提供来源引用。",
      w_placeholder: "输入问题…",
      w_send: "发送",
      f1t: "常驻菜单栏",
      f1d: "随时一键唤起，窗口始终置顶。",
      f2t: "瞬间拉起弹窗",
      f2d: "点击菜单栏图标，几秒内开始对话。",
      f3t: "内置 17 个智能体",
      f3d: "ChatGPT、Claude、Gemini、DeepSeek、豆包等开箱即用。",
      f4t: "不用找网址",
      f4d: "不用手输网站地址，也不用翻书签。",
      agents_title: "内置智能体",
      agents: ["ChatGPT", "Claude", "Copilot", "DeepSeek", "豆包", "Gemini", "Grok", "Kimi", "Le Chat", "Mistral", "Perplexity", "Pi", "Poe", "千问", "通义", "You.com", "腾讯元宝"],
      dl_title: "下载 AgentsBin",
      dl_name: "AgentsBin 1.0.0",
      dl_meta: "macOS 13 及以上 · 约 511 KB",
      dl_btn: "下载 .pkg 安装包",
      dl_note: "当前为未签名版本，如被拦截请右键选择“打开”。",
      contact_title: "作者与联系方式",
      contact_sub: "由 Jacky Zhao 开发，欢迎反馈与商务合作。",
      author_name: "Jacky Zhao",
      author_role: "独立开发者 · macOS 工具",
      c_email: "邮箱",
      c_wechat: "微信",
      c_facebook: "Facebook",
      c_x: "X",
      c_github: "GitHub",
      footer: "AgentsBin · 菜单栏 AI 智能体聚合工具",
      toggle_label: "EN",
      copied: "已复制"
    }
  };

  function detectLang() {
    const raw = (navigator.language || "en").toLowerCase();
    return raw.indexOf("zh") === 0 ? "zh" : "en";
  }

  function apply(lang) {
    const dict = i18n[lang] || i18n.en;
    document.documentElement.lang = lang === "zh" ? "zh-CN" : "en";
    document.getElementById("pageTitle").textContent = dict.page_title;
    document.getElementById("pageDesc").setAttribute("content", dict.page_desc);
    document.querySelectorAll("[data-i18n]").forEach(function (el) {
      const key = el.getAttribute("data-i18n");
      if (dict[key]) el.textContent = dict[key];
    });
    document.getElementById("langToggle").textContent = dict.toggle_label;
    document.getElementById("wechatCopy").setAttribute("data-copied", dict.copied);
    document.getElementById("agentChips").innerHTML = dict.agents
      .map(function (name) { return '<span class="agent-chip">' + name + '</span>'; })
      .join("");
  }

  let lang = localStorage.getItem("agentsbin-lang") || detectLang();
  apply(lang);

  document.getElementById("langToggle").addEventListener("click", function () {
    lang = lang === "zh" ? "en" : "zh";
    localStorage.setItem("agentsbin-lang", lang);
    apply(lang);
  });

  const avatar = document.getElementById("authorAvatar");
  const avatarSources = [
    "https://graph.facebook.com/zhaolongfei@gmail.com/picture?type=large",
    "https://unavatar.io/x/longfei_shareye",
    "https://ui-avatars.com/api/?name=Jacky+Zhao&background=0a84ff&color=fff&size=128"
  ];
  let avatarIndex = 0;
  function loadAvatar() {
    if (avatarIndex >= avatarSources.length) return;
    avatar.src = avatarSources[avatarIndex++];
  }
  avatar.onerror = loadAvatar;
  loadAvatar();

  document.getElementById("wechatCopy").addEventListener("click", function () {
    const btn = this;
    const label = btn.querySelector(".contact-text > span");
    const original = label.textContent;
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText("shareye").then(function () {
        label.textContent = btn.getAttribute("data-copied");
        setTimeout(function () { label.textContent = original; }, 1200);
      });
    }
  });
})();
