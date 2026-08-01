(function () {
  const i18n = {
    en: {
      page_title: "AgentsBin · Menu bar AI agent hub for macOS",
      page_desc: "AgentsBin is a macOS menu bar hub for AI agents with embedded web chat, a local knowledge base, and local AI summaries.",
      nav_download: "Download",
      hero_title: "All your AI agents, one menu bar away",
      hero_lead: "AgentsBin lives in the menu bar. Click the AB icon, pick an agent, and start chatting instantly — no tabs, no typing URLs, no searching.",
      hero_cta: "Download AgentsBin 1.0.16",
      hero_badge: "37 AI agents · macOS 13+ · Free Beta",
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
      f3t: "Manage your agents",
      f3d: "Add, import, export, pin and reorder agents with drag and drop.",
      f4t: "No URL hunting",
      f4d: "No typing website addresses or digging through bookmarks.",
      agents_title: "Built-in agents",
      feature_details_title: "What's inside",
      d1t: "Encrypted API key vault",
      d1d: "Save multiple API keys per provider with multi-credential groups, locally encrypted and protected by an admin password.",
      d2t: "Agent management",
      d2d: "Drag to reorder, hide with one click, add custom agents, import and export.",
      d3t: "10 languages",
      d3d: "Full UI translations, auto-detected or switch anytime.",
      d4t: "Appearance & launch",
      d4d: "Dark/light mode and launch-at-login, all in one place.",
      d5t: "Web chat",
      d5d: "One agent at a time inside the real site, keep your login.",
      d6t: "Collapsible sidebar",
      d6d: "Fold the sidebar and shrink the window to keep your screen clean.",
      howto_title: "How to use",
      h1t: "Install & launch",
      h1d: "Open the DMG, drag AgentsBin to Applications, then click the AB icon in the menu bar.",
      h2t: "Start chatting",
      h2d: "Pick an agent from the left side and chat in the embedded web page.",
      h3t: "Back up API keys",
      h3d: "Open Settings → API Keys, unlock with the admin password, then add or import providers and save multiple API keys.",
      h4t: "Customize",
      h4d: "Add custom agents, drag to reorder, switch language or appearance.",
      agents: ["ChatGPT", "Claude", "Copilot", "DeepSeek", "Doubao", "Gemini", "Grok", "Kimi", "Le Chat", "Mistral", "Perplexity", "Pi", "Poe", "Qwen", "Tongyi", "You.com", "Tencent Yuanbao", "ChatGLM", "Hailuo", "Wenxin", "Xinghuo", "Meta AI", "HuggingChat", "Coze", "Monica", "Cursor", "Character.AI", "Cohere", "Flowith", "DeepAI", "Julius AI", "Tiangong", "Metaso", "Blackbox AI", "Sider", "Phind", "Wenxiaoyan"],
      dl_title: "Download AgentsBin",
      dl_name: "AgentsBin 1.0.16 · Free Beta",
      dl_meta: "macOS 13+ · ~511 KB",
      dl_btn: "Download DMG",
      dl_note: "Open the DMG and drag AgentsBin to Applications.",
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
      hero_cta: "下载 AgentsBin 1.0.16",
      hero_badge: "内置 37 个智能体 · macOS 13+ · 免费内测版",
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
      f3t: "智能体管理",
      f3d: "添加、导入导出、置顶和拖拽排序，随心整理。",
      f4t: "不用找网址",
      f4d: "不用手输网站地址，也不用翻书签。",
      agents_title: "内置智能体",
      feature_details_title: "功能详解",
      d1t: "加密的 API Key 保险箱",
      d1d: "每个智能体可保存多组 API 参数，本地加密，管理员密码保护，支持一键复制。",
      d2t: "智能体管理",
      d2d: "拖拽排序、一键隐藏、添加自定义智能体、导入导出。",
      d3t: "10 种语言",
      d3d: "完整界面翻译，自动识别或随时手动切换。",
      d4t: "外观与开机启动",
      d4d: "深浅模式、开机启动集中在通用设置里。",
      d5t: "网页内对话",
      d5d: "一次专注一个智能体，在原站网页内聊天，保留登录态。",
      d6t: "可折叠侧栏",
      d6d: "折叠侧栏并缩小窗口，常驻屏幕不遮挡其他应用。",
      howto_title: "操作说明",
      h1t: "安装并启动",
      h1d: "打开 DMG，把 AgentsBin 拖进 Applications，然后点击菜单栏 AB 图标。",
      h2t: "开始对话",
      h2d: "在左侧选择一个智能体，在嵌入的网页里直接聊天。",
      h3t: "备份 API Key",
      h3d: "进入设置 → API 参数备份，用管理员密码解锁，再添加或导入供应商并保存多组 API Key。",
      h4t: "个性化",
      h4d: "添加自定义智能体、拖拽排序、切换语言或界面风格。",
      agents: ["ChatGPT", "Claude", "Copilot", "DeepSeek", "豆包", "Gemini", "Grok", "Kimi", "Le Chat", "Mistral", "Perplexity", "Pi", "Poe", "千问", "通义", "You.com", "腾讯元宝", "智谱清言", "海螺 AI", "文心一言", "讯飞星火", "Meta AI", "HuggingChat", "Coze", "Monica", "Cursor", "Character.AI", "Cohere", "Flowith", "DeepAI", "Julius AI", "天工", "秘塔 AI", "Blackbox AI", "Sider", "Phind", "文小言"],
      dl_title: "下载 AgentsBin",
      dl_name: "AgentsBin 1.0.16 · 免费内测版",
      dl_meta: "macOS 13 及以上 · 约 511 KB",
      dl_btn: "下载 DMG",
      dl_note: "打开 DMG，把 AgentsBin 拖进 Applications 即可。",
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

  const agentHosts = [
    "chatgpt.com", "claude.ai", "copilot.microsoft.com", "chat.deepseek.com", "doubao.com",
    "gemini.google.com", "grok.com", "kimi.moonshot.cn", "chat.mistral.ai", "chat.mistral.ai",
    "perplexity.ai", "pi.ai", "poe.com", "chat.qwen.ai", "tongyi.aliyun.com", "you.com",
    "yuanbao.tencent.com", "chatglm.cn", "hailuoai.com", "yiyan.baidu.com", "xinghuo.xfyun.cn",
    "meta.ai", "huggingface.co", "coze.cn", "monica.im", "cursor.com", "character.ai",
    "cohere.com", "flowith.net", "deepai.org", "julius.ai", "tiangong.cn", "metaso.cn",
    "blackbox.ai", "sider.ai", "phind.com", "top.aixin.baidu.com"
  ];

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
    document.getElementById("agentChips").innerHTML = dict.agents
      .map(function (name) { return '<span class="agent-chip">' + name + '</span>'; })
      .join("");
    renderAgentCloud(dict.agents);
  }

  function renderAgentCloud(agents) {
    const container = document.getElementById("agentCloud");
    if (!container) return;
    container.innerHTML = agents.map(function (name, index) {
      const host = agentHosts[index] || "example.com";
      const letter = name.charAt(0).toUpperCase();
      const hue = (index * 37) % 360;
      return (
        '<div class="agent-logo" title="' + name + '">' +
          '<img loading="lazy" src="https://www.google.com/s2/favicons?domain=' + host + '&sz=64" ' +
            'onerror="this.style.display=\'none\';this.nextElementSibling.style.display=\'flex\';" alt="">' +
          '<span class="agent-fallback" style="display:none;background:hsl(' + hue + ',60%,45%)">' + letter + '</span>' +
          '<small>' + name + '</small>' +
        '</div>'
      );
    }).join("");
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

})();
