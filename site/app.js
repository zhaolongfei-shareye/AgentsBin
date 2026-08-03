(function () {
  const base = {
    page_title: "AgentsBin · All-in-One AI Chat Hub for macOS | ChatGPT, Claude, Gemini, DeepSeek, Qwen",
    page_desc: "AgentsBin is the all-in-one AI chat hub for macOS. Launch ChatGPT, Claude, Gemini, DeepSeek, Qwen and 30+ AI agents from the menu bar, switch between web chat and API mode, and keep API keys encrypted locally. Free beta for macOS 13+.",
    nav_download: "Download",
    nav_products: "Products",
    pm_title: "Explore products",
    pm_search: "Search products",
    pm_all: "All",
    pm_released: "Released",
    pm_soon: "Coming Soon",
    pm_cat_all: "All",
    pm_cat_assistants: "AI Assistants",
    pm_cat_audio: "Audio",
    pm_cat_media: "Media Tools",
    p1n: "AgentsBin",
    p1s: "macOS · Menu Bar",
    p1d: "37 AI agents in one menu bar, with encrypted API key backup and 10 languages.",
    p2n: "AgentsBin Audio",
    p2s: "macOS · Audio AI",
    p2d: "Audio transcription, summaries and smart editing. In development.",
    p3n: "AgentsBin Watermark",
    p3s: "macOS · Media Tools",
    p3d: "Batch watermark and copyright protection for images and video. In development.",
    pm_live: "Released",
    pm_soon_s: "Coming Soon",
    hero_title: "All your AI agents, one menu bar away",
    hero_lead: "AgentsBin lives in the menu bar. Pick your default agents on first launch, then start chatting instantly — no tabs, no typing URLs.",
    hero_cta: "Download AgentsBin 1.1.4",
    hero_badge: "37 AI agents · macOS 13+ · Free Beta",
    w_agents: "Agents",
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
    f3d: "37 mainstream agents, custom agents, drag-to-reorder sidebar.",
    f4t: "No URL hunting",
    f4d: "No typing website addresses or digging through bookmarks.",
    agents_title: "Built-in agents",
    feature_details_title: "What's inside",
    shot_default: "Default chat screen",
    shot_api: "API key backup screen",
    d1t: "Encrypted API key vault",
    d1d: "Multiple API keys per provider, AES-encrypted locally, no system prompts.",
    d2t: "37 mainstream agents",
    d2d: "37 popular AI agents built in, plus custom agents with drag-to-reorder.",
    d3t: "10 languages",
    d3d: "Full UI translations, switch anytime.",
    d4t: "Appearance & launch",
    d4d: "Dark/light mode and launch-at-login, all in one place.",
    d5t: "Web & API chat",
    d5d: "Chat in the official web page, or switch to API mode and call providers directly with your keys.",
    d6t: "Free placement",
    d6d: "Place the window anywhere on screen, hide or enlarge it, and reopen it instantly from the menu bar.",
    howto_title: "How to use",
    h1t: "Install & launch",
    h1d: "Open the DMG, drag AgentsBin to Applications, then click the AB icon in the menu bar.",
    h2t: "Pick & chat",
    h2d: "Open the floating agent panel, pick an agent, and chat in Web or API mode.",
    h3t: "Web or API mode",
    h3d: "Use Web mode in the official page, or API mode to call the provider directly with saved keys.",
    h4t: "Customize",
    h4d: "Add custom agents, drag to reorder, switch language or appearance.",
    dl_title: "Download AgentsBin",
    dl_name: "AgentsBin 1.1.4 · Free Beta",
    dl_meta: "macOS 13+ · ~913 KB",
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
    analytics_title: "AgentsBin Analytics",
    analytics_sub: "Download and agent usage",
    analytics_period: "Last 30 days",
    kpi_downloads: "Total Downloads",
    kpi_opens: "Agent Opens",
    kpi_session: "Avg. Session",
    kpi_active: "Active Agents",
    chart_title: "Top AI agents by opens",
    chart_sub: "Opens through AgentsBin in the last 30 days",
    opens_label: "opens",
    agents: ["ChatGPT", "Claude", "Copilot", "DeepSeek", "Doubao", "Gemini", "Grok", "Kimi", "Le Chat", "Mistral", "Perplexity", "Pi", "Poe", "Qwen", "Tongyi", "You.com", "Tencent Yuanbao", "ChatGLM", "Hailuo", "Wenxin", "Xinghuo", "Meta AI", "HuggingChat", "Coze", "Monica", "Cursor", "Character.AI", "Cohere", "Flowith", "DeepAI", "Julius AI", "Tiangong", "Metaso", "Blackbox AI", "Sider", "Phind", "Wenxiaoyan"]
  };

  const zhOverrides = {
    page_title: "AgentsBin · macOS 菜单栏 AI 智能体聚合",
    page_desc: "AgentsBin 是一个 macOS 菜单栏 AI 智能体聚合工具，支持网页对话、智能体管理与加密的 API Key 备份。",
    nav_download: "下载",
    nav_products: "产品",
    pm_title: "产品中心",
    pm_search: "搜索产品",
    pm_all: "全部",
    pm_released: "已发布",
    pm_soon: "即将上线",
    pm_cat_all: "全部",
    pm_cat_assistants: "AI 助手",
    pm_cat_audio: "音频",
    pm_cat_media: "媒体工具",
    p1n: "AgentsBin",
    p1s: "macOS · 菜单栏",
    p1d: "一个菜单栏聚合 37 个 AI 智能体，支持加密 API Key 备份与 10 种语言。",
    p2n: "AgentsBin Audio",
    p2s: "macOS · 音频 AI",
    p2d: "语音转写、摘要与智能剪辑，开发中。",
    p3n: "AgentsBin Watermark",
    p3s: "macOS · 媒体工具",
    p3d: "图片与视频批量水印、版权保护，开发中。",
    pm_live: "已发布",
    pm_soon_s: "即将上线",
    hero_title: "所有 AI 智能体，一个菜单栏就够了",
    hero_lead: "AgentsBin 常驻菜单栏，首次打开先选择默认智能体，一键开始对话，不用开标签页、不用手输网址。",
    hero_cta: "下载 AgentsBin 1.1.4",
    hero_badge: "内置 37 个智能体 · macOS 13+ · 免费内测版",
    w_agents: "智能体",
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
    f3d: "支持 37 种主流智能体、自定义智能体，左侧浮层拖拽排序。",
    f4t: "不用找网址",
    f4d: "不用手输网站地址，也不用翻书签。",
    agents_title: "内置智能体",
    feature_details_title: "功能详解",
    shot_default: "默认对话界面",
    shot_api: "API Key 备份界面",
    d1t: "加密的 API Key 保险箱",
    d1d: "每个供应商可保存多组 API Key，本地 AES 加密，不再弹系统提示。",
    d2t: "37 种主流智能体",
    d2d: "内置 37 种主流 AI 智能体，支持自定义智能体与拖拽排序。",
    d3t: "10 种语言",
    d3d: "完整界面翻译，随时手动切换。",
    d4t: "外观与开机启动",
    d4d: "深浅模式、开机启动集中在通用设置里。",
    d5t: "网页与 API 双模式",
    d5d: "网页模式使用官方页面，API 模式用你的 Key 直连调用，随时切换。",
    d6t: "桌面自由摆放",
    d6d: "窗口可在桌面任意摆放、隐藏或放大，菜单栏一键随时查看。",
    howto_title: "操作说明",
    h1t: "安装并启动",
    h1d: "打开 DMG，把 AgentsBin 拖进 Applications，然后点击菜单栏 AB 图标。",
    h2t: "选择并对话",
    h2d: "打开浮层面板选择智能体，网页或 API 两种方式对话。",
    h3t: "网页或 API 模式",
    h3d: "网页模式打开官方页面，API 模式使用已保存的 Key 直连调用。",
    h4t: "个性化",
    h4d: "添加自定义智能体、拖拽排序、切换语言或外观。",
    dl_title: "下载 AgentsBin",
    dl_name: "AgentsBin 1.1.4 · 免费内测版",
    dl_meta: "macOS 13 及以上 · 约 913 KB",
    dl_btn: "下载 DMG",
    dl_note: "打开 DMG，把 AgentsBin 拖进 Applications 即可。",
    contact_title: "作者与联系方式",
    contact_sub: "由 Jacky Zhao 开发，欢迎反馈与商务合作。",
    author_role: "独立开发者 · macOS 工具",
    c_email: "邮箱",
    c_wechat: "微信",
    c_facebook: "Facebook",
    c_x: "X",
    c_github: "GitHub",
    footer: "AgentsBin · 菜单栏 AI 智能体聚合工具",
    analytics_title: "AgentsBin 统计",
    analytics_sub: "下载与智能体使用统计",
    analytics_period: "最近 30 天",
    kpi_downloads: "总下载次数",
    kpi_opens: "智能体打开次数",
    kpi_session: "平均会话时长",
    kpi_active: "活跃智能体",
    chart_title: "智能体访问量排行",
    chart_sub: "最近 30 天内通过 AgentsBin 打开的智能体访问量",
    opens_label: "次",
    agents: ["ChatGPT", "Claude", "Copilot", "DeepSeek", "豆包", "Gemini", "Grok", "Kimi", "Le Chat", "Mistral", "Perplexity", "Pi", "Poe", "千问", "通义", "You.com", "腾讯元宝", "智谱清言", "海螺 AI", "文心一言", "讯飞星火", "Meta AI", "HuggingChat", "Coze", "Monica", "Cursor", "Character.AI", "Cohere", "Flowith", "DeepAI", "Julius AI", "天工", "秘塔 AI", "Blackbox AI", "Sider", "Phind", "文小言"]
  };

  const zhHantOverrides = {
    page_title: "AgentsBin · macOS 選單列 AI 智能體聚合",
    page_desc: "AgentsBin 是一個 macOS 選單列 AI 智能體聚合工具，支援網頁對話、智能體管理與加密的 API Key 備份。",
    nav_download: "下載",
    nav_products: "產品",
    pm_title: "產品中心",
    pm_search: "搜尋產品",
    pm_all: "全部",
    pm_released: "已發布",
    pm_soon: "即將上線",
    pm_cat_all: "全部",
    pm_cat_assistants: "AI 助手",
    pm_cat_audio: "音訊",
    pm_cat_media: "媒體工具",
    p1n: "AgentsBin",
    p1s: "macOS · 選單列",
    p1d: "一個選單列聚合 37 個 AI 智能體，支援加密 API Key 備份與 10 種語言。",
    p2n: "AgentsBin Audio",
    p2s: "macOS · 音訊 AI",
    p2d: "語音轉寫、摘要與智慧剪輯，開發中。",
    p3n: "AgentsBin Watermark",
    p3s: "macOS · 媒體工具",
    p3d: "圖片與影片批次浮水印、版權保護，開發中。",
    pm_live: "已發布",
    pm_soon_s: "即將上線",
    hero_title: "所有 AI 智能體，一個選單列就夠了",
    hero_lead: "AgentsBin 常駐選單列，首次打開先選擇預設智能體，一鍵開始對話，不用開標籤頁、不用手輸網址。",
    hero_cta: "下載 AgentsBin 1.1.4",
    hero_badge: "內建 37 個智能體 · macOS 13+ · 免費內測版",
    w_agents: "智能體",
    w_status: "已回覆",
    w_user: "請用三點解釋什麼是 RAG",
    w_bot: "RAG 透過檢索外部資料增強生成回答，核心是檢索、融合與生成，可減少幻覺並提供來源引用。",
    w_placeholder: "輸入問題…",
    w_send: "傳送",
    f1t: "常駐選單列",
    f1d: "隨時一鍵喚起，視窗始終置頂。",
    f2t: "瞬間拉起彈窗",
    f2d: "點擊選單列圖示，幾秒內開始對話。",
    f3t: "智能體管理",
    f3d: "支援 37 種主流智能體、自訂智能體，左側浮層拖曳排序。",
    f4t: "不用找網址",
    f4d: "不用手輸網站地址，也不用翻書籤。",
    agents_title: "內建智能體",
    feature_details_title: "功能詳解",
    shot_default: "預設對話介面",
    shot_api: "API Key 備份介面",
    d1t: "加密的 API Key 保險箱",
    d1d: "每個供應商可保存多組 API Key，本機 AES 加密，不再彈系統提示。",
    d2t: "37 種主流智能體",
    d2d: "內建 37 種主流 AI 智能體，支援自訂智能體與拖曳排序。",
    d3t: "10 種語言",
    d3d: "完整介面翻譯，隨時手動切換。",
    d4t: "外觀與開機啟動",
    d4d: "深淺模式、開機啟動集中在通用設定。",
    d5t: "網頁與 API 雙模式",
    d5d: "網頁模式使用官方頁面，API 模式用你的 Key 直連呼叫，隨時切換。",
    d6t: "桌面自由擺放",
    d6d: "視窗可在桌面任意擺放、隱藏或放大，選單列一鍵隨時查看。",
    howto_title: "操作說明",
    h1t: "安裝並啟動",
    h1d: "打開 DMG，把 AgentsBin 拖進 Applications，然後點擊選單列 AB 圖示。",
    h2t: "選擇並對話",
    h2d: "打開浮層面板選擇智能體，網頁或 API 兩種方式對話。",
    h3t: "網頁或 API 模式",
    h3d: "網頁模式打開官方頁面，API 模式使用已保存的 Key 直連呼叫。",
    h4t: "個人化",
    h4d: "新增自訂智能體、拖曳排序、切換語言或外觀。",
    dl_title: "下載 AgentsBin",
    dl_name: "AgentsBin 1.1.4 · 免費內測版",
    dl_meta: "macOS 13 及以上 · 約 913 KB",
    dl_btn: "下載 DMG",
    dl_note: "打開 DMG，把 AgentsBin 拖進 Applications 即可。",
    contact_title: "作者與聯絡方式",
    contact_sub: "由 Jacky Zhao 開發，歡迎回饋與商務合作。",
    author_role: "獨立開發者 · macOS 工具",
    c_email: "信箱",
    c_wechat: "微信",
    footer: "AgentsBin · 選單列 AI 智能體聚合工具",
    analytics_title: "AgentsBin 統計",
    analytics_sub: "下載與智能體使用統計",
    analytics_period: "最近 30 天",
    kpi_downloads: "總下載次數",
    kpi_opens: "智能體開啟次數",
    kpi_session: "平均會話時長",
    kpi_active: "活躍智能體",
    chart_title: "智能體開啟排行",
    chart_sub: "最近 30 天內透過 AgentsBin 開啟的智能體次數",
    opens_label: "次",
    agents: zhOverrides.agents
  };

  const jaOverrides = {
    page_title: "AgentsBin · macOS メニューバー AI エージェント",
    nav_download: "ダウンロード",
    nav_products: "製品",
    pm_title: "製品一覧",
    pm_search: "製品を検索",
    pm_all: "すべて",
    pm_released: "公開中",
    pm_soon: "近日公開",
    pm_cat_all: "すべて",
    pm_cat_assistants: "AI アシスタント",
    pm_cat_audio: "音声",
    pm_cat_media: "メディア",
    p1n: "AgentsBin",
    p1s: "macOS · メニューバー",
    p1d: "37 の AI エージェントをメニューバーに集約、API キー暗号化バックアップと 10 言語対応。",
    p2n: "AgentsBin Audio",
    p2s: "macOS · 音声 AI",
    p2d: "文字起こし、要約、スマート編集。開発中。",
    p3n: "AgentsBin Watermark",
    p3s: "macOS · メディア",
    p3d: "画像・動画の一括透かしと著作権保護。開発中。",
    pm_live: "公開中",
    pm_soon_s: "近日公開",
    hero_title: "すべての AI エージェントをメニューバーに",
    hero_lead: "AgentsBin はメニューバーに常駐。初回起動時にデフォルトのエージェントを選んで、すぐにチャットを開始できます。",
    hero_cta: "AgentsBin 1.1.4 をダウンロード",
    hero_badge: "37 AI エージェント · macOS 13+ · 無料ベータ",
    w_agents: "エージェント",
    w_status: "返信済み",
    w_user: "RAG を3点で説明してください",
    w_bot: "RAG は外部情報を検索して回答を強化し、幻覚を減らして出典を示します。",
    w_placeholder: "質問を入力…",
    w_send: "送信",
    f1t: "メニューバー常駐",
    f1d: "いつでもワンクリック、常に最前面。",
    f2t: "即時ポップアップ",
    f2d: "アイコンをクリックして数秒で会話。",
    f3t: "エージェント管理",
    f3d: "37 の主流エージェント、カスタムエージェント、ドラッグで並べ替え。",
    f4t: "URL 探し不要",
    f4d: "アドレス入力もブックマーク検索も不要。",
    agents_title: "内蔵エージェント",
    feature_details_title: "機能の詳細",
    shot_default: "デフォルト画面",
    shot_api: "API キー設定画面",
    d1t: "暗号化 API キーボールト",
    d1d: "プロバイダごとに複数キー、AES でローカル暗号化、システムプロンプトなし。",
    d2t: "37 の主流エージェント",
    d2d: "37 の主流 AI エージェント内蔵、カスタム追加とドラッグ並べ替え。",
    d3t: "10 言語",
    d3d: "UI は多言語対応、いつでも切替。",
    d4t: "外観とログイン起動",
    d4d: "ダーク/ライト、ログイン時起動を一元管理。",
    d5t: "Web・API チャット",
    d5d: "Web モードは公式サイト、API モードはキーで直接呼び出し。",
    d6t: "自由配置",
    d6d: "ウィンドウは自由に配置・非表示・拡大でき、メニューバーからすぐ再表示。",
    howto_title: "使い方",
    h1t: "インストールと起動",
    h1d: "DMG を開き Applications にドラッグし、メニューバーの AB をクリック。",
    h2t: "選んでチャット",
    h2d: "フローティングパネルでエージェントを選び、Web か API で会話。",
    h3t: "Web または API モード",
    h3d: "Web モードは公式サイト、API モードは保存したキーで直接呼び出し。",
    h4t: "カスタマイズ",
    h4d: "カスタムエージェント追加、並べ替え、言語・外観の変更。",
    dl_title: "AgentsBin をダウンロード",
    dl_name: "AgentsBin 1.1.4 · 無料ベータ",
    dl_meta: "macOS 13+ · 約 913 KB",
    dl_btn: "DMG をダウンロード",
    dl_note: "DMG を開いて Applications にドラッグ。",
    contact_title: "作者・連絡先",
    contact_sub: "Jacky Zhao が開発。フィードバックや協業歓迎。",
    author_role: "インディー開発者 · macOS ツール",
    footer: "AgentsBin · メニューバー AI エージェント",
    analytics_title: "AgentsBin 統計",
    analytics_sub: "ダウンロードと利用統計",
    analytics_period: "過去30日",
    kpi_downloads: "総ダウンロード",
    kpi_opens: "エージェント起動",
    kpi_session: "平均セッション",
    kpi_active: "アクティブエージェント",
    chart_title: "エージェント起動ランキング",
    chart_sub: "過去30日の AgentsBin での起動回数",
    opens_label: "回"
  };

  const koOverrides = {
    page_title: "AgentsBin · macOS 메뉴바 AI 에이전트",
    nav_download: "다운로드",
    nav_products: "제품",
    pm_title: "제품 탐색",
    pm_search: "제품 검색",
    pm_all: "전체",
    pm_released: "출시됨",
    pm_soon: "출시 예정",
    pm_cat_all: "전체",
    pm_cat_assistants: "AI 어시스턴트",
    pm_cat_audio: "오디오",
    pm_cat_media: "미디어 도구",
    p1n: "AgentsBin",
    p1s: "macOS · 메뉴바",
    p1d: "메뉴바 하나로 37개 AI 에이전트, 암호화 API 키 백업과 10개 언어 지원.",
    p2n: "AgentsBin Audio",
    p2s: "macOS · 오디오 AI",
    p2d: "음성 전사, 요약, 스마트 편집. 개발 중.",
    p3n: "AgentsBin Watermark",
    p3s: "macOS · 미디어 도구",
    p3d: "이미지·영상 일괄 워터마크와 저작권 보호. 개발 중.",
    pm_live: "출시됨",
    pm_soon_s: "출시 예정",
    hero_title: "모든 AI 에이전트를 메뉴바 하나로",
    hero_lead: "AgentsBin은 메뉴바에 상주합니다. 첫 실행 시 기본 에이전트를 선택하고 바로 채팅을 시작하세요.",
    hero_cta: "AgentsBin 1.1.4 다운로드",
    hero_badge: "37개 AI 에이전트 · macOS 13+ · 무료 베타",
    w_agents: "에이전트",
    w_status: "답변 완료",
    w_user: "RAG를 3가지로 설명해 주세요",
    w_bot: "RAG는 외부 정보를 검색해 답변을 강화하고 환각을 줄이며 출처를 제시합니다.",
    w_placeholder: "질문 입력…",
    w_send: "보내기",
    f1t: "메뉴바 상주",
    f1d: "항상 원클릭, 항상 최상단. ",
    f2t: "즉시 팝업",
    f2d: "아이콘 클릭 몇 초 안에 대화. ",
    f3t: "에이전트 관리",
    f3d: "37개 주류 에이전트, 커스텀 에이전트, 드래그 정렬.",
    f4t: "URL 찾기 불필요",
    f4d: "주소 입력도 북마크 검색도 필요 없습니다.",
    agents_title: "내장 에이전트",
    feature_details_title: "기능 상세",
    shot_default: "기본 화면",
    shot_api: "API 키 설정 화면",
    d1t: "암호화된 API 키 보관함",
    d1d: "공급자별 여러 키, AES 로컬 암호화, 시스템 프롬프트 없음.",
    d2t: "37개 주류 에이전트",
    d2d: "37개 주류 AI 에이전트 내장, 커스텀 추가와 드래그 정렬.",
    d3t: "10개 언어",
    d3d: "언제든 수동으로 전환 가능합니다.",
    d4t: "외관 및 로그인 시작",
    d4d: "다크/라이트, 로그인 시 시작을 한곳에서.",
    d5t: "웹 & API 채팅",
    d5d: "웹 모드는 공식 사이트, API 모드는 키로 직접 호출.",
    d6t: "자유 배치",
    d6d: "창을 어디든 배치, 숨김, 확대하고 메뉴바에서 즉시 다시 엽니다.",
    howto_title: "사용 방법",
    h1t: "설치 및 실행",
    h1d: "DMG를 열고 Applications로 드래그한 뒤 메뉴바 AB를 클릭하세요.",
    h2t: "선택 후 채팅",
    h2d: "플로팅 패널에서 에이전트를 선택하고 웹 또는 API로 대화.",
    h3t: "웹 또는 API 모드",
    h3d: "웹 모드는 공식 페이지, API 모드는 저장된 키로 직접 호출.",
    h4t: "사용자화",
    h4d: "커스텀 에이전트 추가, 드래그 정렬, 언어·외관 변경.",
    dl_title: "AgentsBin 다운로드",
    dl_name: "AgentsBin 1.1.4 · 무료 베타",
    dl_meta: "macOS 13+ · 약 913 KB",
    dl_btn: "DMG 다운로드",
    dl_note: "DMG를 열고 Applications로 드래그하세요.",
    contact_title: "작성자 · 연락처",
    contact_sub: "Jacky Zhao가 개발했습니다. 피드백과 협업을 환영합니다.",
    author_role: "인디 개발자 · macOS 도구",
    footer: "AgentsBin · 메뉴바 AI 에이전트",
    analytics_title: "AgentsBin 통계",
    analytics_sub: "다운로드 및 사용 통계",
    analytics_period: "최근 30일",
    kpi_downloads: "총 다운로드",
    kpi_opens: "에이전트 열기",
    kpi_session: "평균 세션",
    kpi_active: "활성 에이전트",
    chart_title: "에이전트 열기 순위",
    chart_sub: "최근 30일 AgentsBin 열기 횟수",
    opens_label: "회"
  };

  const esOverrides = {
    page_title: "AgentsBin · Hub de agentes AI para macOS",
    nav_download: "Descargar",
    nav_products: "Productos",
    pm_title: "Explorar productos",
    pm_search: "Buscar productos",
    pm_all: "Todos",
    pm_released: "Publicados",
    pm_soon: "Próximamente",
    pm_cat_all: "Todos",
    pm_cat_assistants: "Asistentes AI",
    pm_cat_audio: "Audio",
    pm_cat_media: "Herramientas",
    p1n: "AgentsBin",
    p1s: "macOS · Barra de menús",
    p1d: "37 agentes AI en la barra de menús, respaldo cifrado de claves API y 10 idiomas.",
    p2n: "AgentsBin Audio",
    p2s: "macOS · Audio AI",
    p2d: "Transcripción, resúmenes y edición inteligente. En desarrollo.",
    p3n: "AgentsBin Watermark",
    p3s: "macOS · Herramientas",
    p3d: "Marcas de agua por lotes y protección de derechos. En desarrollo.",
    pm_live: "Publicado",
    pm_soon_s: "Próximamente",
    hero_title: "Todos tus agentes AI, a un clic de la barra de menús",
    hero_lead: "AgentsBin vive en la barra de menús. Elige tus agentes al iniciar y chatea al instante.",
    hero_cta: "Descargar AgentsBin 1.1.4",
    hero_badge: "37 agentes AI · macOS 13+ · Beta gratis",
    w_agents: "Agentes",
    w_status: "Respondido",
    w_user: "Explica RAG en tres puntos",
    w_bot: "RAG recupera conocimiento externo, lo fusiona con la generación y cita fuentes para reducir alucinaciones.",
    w_placeholder: "Escribe una pregunta…",
    w_send: "Enviar",
    f1t: "Vive en la barra de menús",
    f1d: "Siempre a un clic y siempre al frente.",
    f2t: "Popup instantáneo",
    f2d: "Haz clic y chatea en segundos.",
    f3t: "Gestiona tus agentes",
    f3d: "37 agentes principales, agentes personalizados y ordenar arrastrando.",
    f4t: "Sin buscar URLs",
    f4d: "Sin escribir direcciones ni buscar marcadores.",
    agents_title: "Agentes integrados",
    feature_details_title: "Qué incluye",
    shot_default: "Pantalla de chat",
    shot_api: "Pantalla de claves API",
    d1t: "Caja fuerte de claves API",
    d1d: "Varias claves por proveedor, cifrado AES local, sin avisos del sistema.",
    d2t: "37 agentes principales",
    d2d: "37 agentes IA integrados, personalizados y ordenar arrastrando.",
    d3t: "10 idiomas",
    d3d: "Interfaz traducida, cambia cuando quieras.",
    d4t: "Apariencia e inicio",
    d4d: "Modo claro/oscuro e inicio al iniciar sesión.",
    d5t: "Chat Web y API",
    d5d: "Modo web en la página oficial, modo API con tus claves.",
    d6t: "Colocación libre",
    d6d: "Coloca la ventana en cualquier lugar, ocúltala o agrándala.",
    howto_title: "Cómo usarlo",
    h1t: "Instala y abre",
    h1d: "Abre el DMG, arrastra a Applications y pulsa AB.",
    h2t: "Elige y chatea",
    h2d: "Abre el panel flotante, elige un agente y chatea en Web o API.",
    h3t: "Modo Web o API",
    h3d: "Modo web en la página oficial, modo API con las claves guardadas.",
    h4t: "Personaliza",
    h4d: "Añade agentes personalizados, ordena y cambia idioma o apariencia.",
    dl_title: "Descargar AgentsBin",
    dl_name: "AgentsBin 1.1.4 · Beta gratis",
    dl_meta: "macOS 13+ · ~913 KB",
    dl_btn: "Descargar DMG",
    dl_note: "Abre el DMG y arrastra AgentsBin a Applications.",
    contact_title: "Autor y contacto",
    contact_sub: "Creado por Jacky Zhao. Comentarios y alianzas bienvenidos.",
    author_role: "Desarrollador independiente · herramientas macOS",
    footer: "AgentsBin · Hub de agentes AI para macOS",
    analytics_title: "Estadísticas de AgentsBin",
    analytics_sub: "Descargas y uso de agentes",
    analytics_period: "Últimos 30 días",
    kpi_downloads: "Descargas totales",
    kpi_opens: "Aperturas de agentes",
    kpi_session: "Sesión media",
    kpi_active: "Agentes activos",
    chart_title: "Ranking de aperturas",
    chart_sub: "Aperturas a través de AgentsBin en 30 días",
    opens_label: "aperturas"
  };

  const frOverrides = {
    page_title: "AgentsBin · Hub d'agents IA pour macOS",
    nav_download: "Télécharger",
    nav_products: "Produits",
    pm_title: "Explorer les produits",
    pm_search: "Rechercher",
    pm_all: "Tous",
    pm_released: "Disponibles",
    pm_soon: "Bientôt",
    pm_cat_all: "Tous",
    pm_cat_assistants: "Assistants IA",
    pm_cat_audio: "Audio",
    pm_cat_media: "Outils",
    p1n: "AgentsBin",
    p1s: "macOS · Barre de menus",
    p1d: "37 agents IA dans la barre de menus, sauvegarde chiffrée des clés API et 10 langues.",
    p2n: "AgentsBin Audio",
    p2s: "macOS · Audio IA",
    p2d: "Transcription, résumés et édition intelligente. En développement.",
    p3n: "AgentsBin Watermark",
    p3s: "macOS · Outils",
    p3d: "Filigranes par lots et protection des droits. En développement.",
    pm_live: "Disponible",
    pm_soon_s: "Bientôt",
    hero_title: "Tous vos agents IA, à un clic de la barre de menus",
    hero_lead: "AgentsBin vit dans la barre de menus. Choisissez vos agents au premier lancement et discutez immédiatement.",
    hero_cta: "Télécharger AgentsBin 1.1.4",
    hero_badge: "37 agents IA · macOS 13+ · Bêta gratuite",
    w_agents: "Agents",
    w_status: "Répondu",
    w_user: "Expliquez RAG en trois points",
    w_bot: "RAG récupère des connaissances externes, les fusionne à la génération et cite ses sources.",
    w_placeholder: "Écrivez une question…",
    w_send: "Envoyer",
    f1t: "Vit dans la barre de menus",
    f1d: "Toujours à un clic, toujours au premier plan.",
    f2t: "Popup instantané",
    f2d: "Cliquez et discutez en quelques secondes.",
    f3t: "Gérez vos agents",
    f3d: "37 agents principaux, agents personnalisés et tri par glisser.",
    f4t: "Sans chercher d'URL",
    f4d: "Ni adresses à taper, ni marque-pages à chercher.",
    agents_title: "Agents intégrés",
    feature_details_title: "Ce qui est inclus",
    shot_default: "Écran de chat",
    shot_api: "Écran des clés API",
    d1t: "Coffre-fort de clés API",
    d1d: "Plusieurs clés par fournisseur, chiffrement AES local, sans invites système.",
    d2t: "37 agents principaux",
    d2d: "37 agents IA intégrés, personnalisés et tri par glisser.",
    d3t: "10 langues",
    d3d: "Interface traduite, changez à tout moment.",
    d4t: "Apparence et démarrage",
    d4d: "Mode clair/sombre et lancement à la connexion.",
    d5t: "Chat Web et API",
    d5d: "Mode web sur le site officiel, mode API avec vos clés.",
    d6t: "Placement libre",
    d6d: "Placez la fenêtre où vous voulez, masquez-la ou agrandissez-la.",
    howto_title: "Mode d'emploi",
    h1t: "Installer et lancer",
    h1d: "Ouvrez le DMG, glissez dans Applications, cliquez sur AB.",
    h2t: "Choisissez et discutez",
    h2d: "Ouvrez le panneau flottant, choisissez un agent et discutez en Web ou API.",
    h3t: "Mode Web ou API",
    h3d: "Mode web sur la page officielle, mode API avec les clés enregistrées.",
    h4t: "Personnaliser",
    h4d: "Ajoutez des agents personnalisés, triez, changez de langue ou d'apparence.",
    dl_title: "Télécharger AgentsBin",
    dl_name: "AgentsBin 1.1.4 · Bêta gratuite",
    dl_meta: "macOS 13+ · ~913 Ko",
    dl_btn: "Télécharger le DMG",
    dl_note: "Ouvrez le DMG et glissez AgentsBin dans Applications.",
    contact_title: "Auteur et contact",
    contact_sub: "Créé par Jacky Zhao. Retours et partenariats bienvenus.",
    author_role: "Développeur indépendant · outils macOS",
    footer: "AgentsBin · Hub d'agents IA pour macOS",
    analytics_title: "Statistiques AgentsBin",
    analytics_sub: "Téléchargements et usage",
    analytics_period: "30 derniers jours",
    kpi_downloads: "Téléchargements",
    kpi_opens: "Ouvertures d'agents",
    kpi_session: "Session moyenne",
    kpi_active: "Agents actifs",
    chart_title: "Classement des ouvertures",
    chart_sub: "Ouvertures via AgentsBin en 30 jours",
    opens_label: "ouvertures"
  };

  const deOverrides = {
    page_title: "AgentsBin · KI-Agenten-Hub für die macOS-Menüleiste",
    nav_download: "Download",
    nav_products: "Produkte",
    pm_title: "Produkte entdecken",
    pm_search: "Produkte suchen",
    pm_all: "Alle",
    pm_released: "Verfügbar",
    pm_soon: "Bald",
    pm_cat_all: "Alle",
    pm_cat_assistants: "KI-Assistenten",
    pm_cat_audio: "Audio",
    pm_cat_media: "Medien",
    p1n: "AgentsBin",
    p1s: "macOS · Menüleiste",
    p1d: "37 KI-Agenten in der Menüleiste, verschlüsseltes API-Key-Backup und 10 Sprachen.",
    p2n: "AgentsBin Audio",
    p2s: "macOS · Audio-KI",
    p2d: "Transkription, Zusammenfassung und intelligente Bearbeitung. In Entwicklung.",
    p3n: "AgentsBin Watermark",
    p3s: "macOS · Medien",
    p3d: "Batch-Wasserzeichen und Urheberschutz für Bilder und Videos. In Entwicklung.",
    pm_live: "Verfügbar",
    pm_soon_s: "Bald",
    hero_title: "Alle KI-Agenten in einer Menüleiste",
    hero_lead: "AgentsBin lebt in der Menüleiste. Wählen Sie beim Start Ihre Agenten und chatten Sie sofort.",
    hero_cta: "AgentsBin 1.1.4 herunterladen",
    hero_badge: "37 KI-Agenten · macOS 13+ · Kostenlose Beta",
    w_agents: "Agenten",
    w_status: "Beantwortet",
    w_user: "Erklären Sie RAG in drei Punkten",
    w_bot: "RAG ruft externes Wissen ab, verbindet es mit der Generierung und nennt Quellen.",
    w_placeholder: "Frage eingeben…",
    w_send: "Senden",
    f1t: "Lebe in der Menüleiste",
    f1d: "Immer einen Klick entfernt, immer im Vordergrund.",
    f2t: "Sofort-Popup",
    f2d: "Klicken und in Sekunden chatten.",
    f3t: "Agenten verwalten",
    f3d: "37 Hauptagenten, eigene Agenten, per Drag & Drop sortieren.",
    f4t: "Keine URL-Suche",
    f4d: "Keine Adressen tippen, keine Lesezeichen.",
    agents_title: "Integrierte Agenten",
    feature_details_title: "Was enthalten ist",
    shot_default: "Chat-Ansicht",
    shot_api: "API-Schlüssel-Ansicht",
    d1t: "Verschlüsselter API-Tresor",
    d1d: "Mehrere Schlüssel pro Anbieter, AES-lokal verschlüsselt, ohne Systemabfragen.",
    d2t: "37 Hauptagenten",
    d2d: "37 KI-Agenten integriert, eigene Agenten und Drag & Drop.",
    d3t: "10 Sprachen",
    d3d: "Vollständige Übersetzung, jederzeit wechselbar.",
    d4t: "Darstellung und Start",
    d4d: "Hell/dunkel und Start bei Anmeldung.",
    d5t: "Web- und API-Chat",
    d5d: "Web-Modus auf der offiziellen Seite, API-Modus mit Ihren Schlüsseln.",
    d6t: "Freie Platzierung",
    d6d: "Platzieren, ausblenden oder vergrößern Sie das Fenster nach Belieben.",
    howto_title: "Anleitung",
    h1t: "Installieren und starten",
    h1d: "DMG öffnen, in Applications ziehen, auf AB klicken.",
    h2t: "Wählen und chatten",
    h2d: "Öffnen Sie das Panel, wählen Sie einen Agenten und chatten Sie in Web oder API.",
    h3t: "Web- oder API-Modus",
    h3d: "Web-Modus auf der offiziellen Seite, API-Modus mit gespeicherten Schlüsseln.",
    h4t: "Anpassen",
    h4d: "Eigene Agenten hinzufügen, sortieren, Sprache oder Darstellung wechseln.",
    dl_title: "AgentsBin herunterladen",
    dl_name: "AgentsBin 1.1.4 · Kostenlose Beta",
    dl_meta: "macOS 13+ · ca. 913 KB",
    dl_btn: "DMG herunterladen",
    dl_note: "DMG öffnen und AgentsBin in Applications ziehen.",
    contact_title: "Autor und Kontakt",
    contact_sub: "Von Jacky Zhao entwickelt. Feedback und Partnerschaften willkommen.",
    author_role: "Indie-Entwickler · macOS-Tools",
    footer: "AgentsBin · KI-Agenten-Hub für macOS",
    analytics_title: "AgentsBin-Statistiken",
    analytics_sub: "Downloads & Nutzung",
    analytics_period: "Letzte 30 Tage",
    kpi_downloads: "Downloads gesamt",
    kpi_opens: "Agenten-Aufrufe",
    kpi_session: "Ø Sitzung",
    kpi_active: "Aktive Agenten",
    chart_title: "Rangliste der Aufrufe",
    chart_sub: "Aufrufe über AgentsBin in 30 Tagen",
    opens_label: "Aufrufe"
  };

  const ruOverrides = {
    page_title: "AgentsBin · AI-агенты в строке меню macOS",
    nav_download: "Скачать",
    nav_products: "Продукты",
    pm_title: "Каталог продуктов",
    pm_search: "Найти продукт",
    pm_all: "Все",
    pm_released: "Доступно",
    pm_soon: "Скоро",
    pm_cat_all: "Все",
    pm_cat_assistants: "AI-ассистенты",
    pm_cat_audio: "Аудио",
    pm_cat_media: "Медиа",
    p1n: "AgentsBin",
    p1s: "macOS · Строка меню",
    p1d: "37 AI-агентов в строке меню, шифрованное резервное копирование API-ключей и 10 языков.",
    p2n: "AgentsBin Audio",
    p2s: "macOS · Аудио AI",
    p2d: "Транскрибация, резюме и умный монтаж. В разработке.",
    p3n: "AgentsBin Watermark",
    p3s: "macOS · Медиа",
    p3d: "Пакетные водяные знаки и защита авторских прав. В разработке.",
    pm_live: "Доступно",
    pm_soon_s: "Скоро",
    hero_title: "Все AI-агенты в одной строке меню",
    hero_lead: "AgentsBin живёт в строке меню. Выберите агентов при первом запуске и сразу начните чат.",
    hero_cta: "Скачать AgentsBin 1.1.4",
    hero_badge: "37 AI-агентов · macOS 13+ · Бесплатная бета",
    w_agents: "Агенты",
    w_status: "Отвечено",
    w_user: "Объясните RAG в трёх пунктах",
    w_bot: "RAG извлекает внешние знания, соединяет их с генерацией и указывает источники.",
    w_placeholder: "Введите вопрос…",
    w_send: "Отправить",
    f1t: "Живёт в строке меню",
    f1d: "Всегда под рукой, всегда поверх.",
    f2t: "Мгновенное окно",
    f2d: "Нажмите и начните чат за секунды.",
    f3t: "Управление агентами",
    f3d: "37 основных агентов, свои агенты, перетаскивание.",
    f4t: "Без поиска URL",
    f4d: "Никаких адресов и закладок.",
    agents_title: "Встроенные агенты",
    feature_details_title: "Что внутри",
    shot_default: "Экран чата",
    shot_api: "Экран ключей API",
    d1t: "Зашифрованное хранилище ключей",
    d1d: "Несколько ключей на провайдера, локальное AES-шифрование, без системных запросов.",
    d2t: "37 основных агентов",
    d2d: "37 встроенных AI-агентов, свои агенты и перетаскивание.",
    d3t: "10 языков",
    d3d: "Полный перевод интерфейса.",
    d4t: "Внешний вид и запуск",
    d4d: "Тёмный/светлый режим и запуск при входе.",
    d5t: "Веб и API чат",
    d5d: "Веб-режим на официальном сайте, API-режим с вашими ключами.",
    d6t: "Свободное размещение",
    d6d: "Размещайте окно где угодно, скрывайте или увеличивайте.",
    howto_title: "Как использовать",
    h1t: "Установка и запуск",
    h1d: "Откройте DMG, перетащите в Applications, нажмите AB.",
    h2t: "Выберите и общайтесь",
    h2d: "Откройте панель, выберите агента и общайтесь в веб или API.",
    h3t: "Веб или API режим",
    h3d: "Веб-режим на официальной странице, API-режим с сохранёнными ключами.",
    h4t: "Настройка",
    h4d: "Добавляйте своих агентов, сортируйте, меняйте язык или вид.",
    dl_title: "Скачать AgentsBin",
    dl_name: "AgentsBin 1.1.4 · Бесплатная бета",
    dl_meta: "macOS 13+ · ~913 КБ",
    dl_btn: "Скачать DMG",
    dl_note: "Откройте DMG и перетащите AgentsBin в Applications.",
    contact_title: "Автор и контакты",
    contact_sub: "Создано Jacky Zhao. Отзывы и партнёрство приветствуются.",
    author_role: "Независимый разработчик · инструменты macOS",
    footer: "AgentsBin · AI-агенты в строке меню macOS",
    analytics_title: "Статистика AgentsBin",
    analytics_sub: "Загрузки и использование",
    analytics_period: "За 30 дней",
    kpi_downloads: "Всего загрузок",
    kpi_opens: "Открытия агентов",
    kpi_session: "Средняя сессия",
    kpi_active: "Активные агенты",
    chart_title: "Рейтинг открытий",
    chart_sub: "Открытий через AgentsBin за 30 дней",
    opens_label: "открытий"
  };

  const ptOverrides = {
    page_title: "AgentsBin · Hub de agentes de IA para macOS",
    nav_download: "Baixar",
    nav_products: "Produtos",
    pm_title: "Explorar produtos",
    pm_search: "Buscar produtos",
    pm_all: "Todos",
    pm_released: "Disponíveis",
    pm_soon: "Em breve",
    pm_cat_all: "Todos",
    pm_cat_assistants: "Assistentes IA",
    pm_cat_audio: "Áudio",
    pm_cat_media: "Mídia",
    p1n: "AgentsBin",
    p1s: "macOS · Barra de menus",
    p1d: "37 agentes de IA na barra de menus, backup criptografado de chaves API e 10 idiomas.",
    p2n: "AgentsBin Audio",
    p2s: "macOS · Áudio IA",
    p2d: "Transcrição, resumos e edição inteligente. Em desenvolvimento.",
    p3n: "AgentsBin Watermark",
    p3s: "macOS · Mídia",
    p3d: "Marcas d'água em lote e proteção de direitos autorais. Em desenvolvimento.",
    pm_live: "Disponível",
    pm_soon_s: "Em breve",
    hero_title: "Todos os seus agentes de IA na barra de menus",
    hero_lead: "AgentsBin vive na barra de menus. Escolha seus agentes no primeiro uso e converse na hora.",
    hero_cta: "Baixar AgentsBin 1.1.4",
    hero_badge: "37 agentes de IA · macOS 13+ · Beta grátis",
    w_agents: "Agentes",
    w_status: "Respondido",
    w_user: "Explique RAG em três pontos",
    w_bot: "RAG recupera conhecimento externo, une à geração e cita fontes.",
    w_placeholder: "Digite uma pergunta…",
    w_send: "Enviar",
    f1t: "Vive na barra de menus",
    f1d: "Sempre a um clique, sempre no topo.",
    f2t: "Popup instantâneo",
    f2d: "Clique e converse em segundos.",
    f3t: "Gerencie seus agentes",
    f3d: "37 agentes principais, agentes personalizados e arrastar para ordenar.",
    f4t: "Sem procurar URLs",
    f4d: "Sem digitar endereços nem buscar favoritos.",
    agents_title: "Agentes integrados",
    feature_details_title: "O que tem dentro",
    shot_default: "Tela de chat",
    shot_api: "Tela de chaves API",
    d1t: "Cofre de chaves API",
    d1d: "Várias chaves por provedor, criptografia AES local, sem avisos do sistema.",
    d2t: "37 agentes principais",
    d2d: "37 agentes de IA integrados, personalizados e arrastar para ordenar.",
    d3t: "10 idiomas",
    d3d: "Interface traduzida, mude quando quiser.",
    d4t: "Aparência e início",
    d4d: "Modo claro/escuro e iniciar no login.",
    d5t: "Chat Web e API",
    d5d: "Modo web no site oficial, modo API com suas chaves.",
    d6t: "Posicionamento livre",
    d6d: "Posicione a janela onde quiser, oculte ou amplie.",
    howto_title: "Como usar",
    h1t: "Instalar e abrir",
    h1d: "Abra o DMG, arraste para Applications e clique em AB.",
    h2t: "Escolha e converse",
    h2d: "Abra o painel flutuante, escolha um agente e converse em Web ou API.",
    h3t: "Modo Web ou API",
    h3d: "Modo web na página oficial, modo API com as chaves salvas.",
    h4t: "Personalizar",
    h4d: "Adicione agentes personalizados, ordene e mude idioma ou aparência.",
    dl_title: "Baixar AgentsBin",
    dl_name: "AgentsBin 1.1.4 · Beta grátis",
    dl_meta: "macOS 13+ · ~913 KB",
    dl_btn: "Baixar DMG",
    dl_note: "Abra o DMG e arraste AgentsBin para Applications.",
    contact_title: "Autor e contato",
    contact_sub: "Criado por Jacky Zhao. Feedback e parcerias bem-vindos.",
    author_role: "Desenvolvedor independente · ferramentas macOS",
    footer: "AgentsBin · Hub de agentes de IA para macOS",
    analytics_title: "Estatísticas do AgentsBin",
    analytics_sub: "Downloads e uso de agentes",
    analytics_period: "Últimos 30 dias",
    kpi_downloads: "Downloads totais",
    kpi_opens: "Aberturas de agentes",
    kpi_session: "Sessão média",
    kpi_active: "Agentes ativos",
    chart_title: "Ranking de aberturas",
    chart_sub: "Aberturas pelo AgentsBin em 30 dias",
    opens_label: "aberturas"
  };

  const i18n = {
    en: base,
    zh: Object.assign({}, base, zhOverrides),
    "zh-Hant": Object.assign({}, base, zhHantOverrides),
    ja: Object.assign({}, base, jaOverrides),
    ko: Object.assign({}, base, koOverrides),
    es: Object.assign({}, base, esOverrides),
    fr: Object.assign({}, base, frOverrides),
    de: Object.assign({}, base, deOverrides),
    ru: Object.assign({}, base, ruOverrides),
    pt: Object.assign({}, base, ptOverrides)
  };

  const demoI18n = {
    en: { demo_try: "Try Demo", demo_welcome: "Hi, this is a demo conversation with", demo_hint: "Move your mouse to the menu bar and hover", demo_close: "Close Demo", demo_ph: "Type a message...", demo_send: "Send", demo_reply: "Demo reply from ", demo_finder: "Finder", demo_docs: "Docs" },
    zh: { demo_try: "在线体验", demo_welcome: "你好，这是与", demo_hint: "把鼠标移到菜单栏，悬停", demo_close: "关闭体验", demo_ph: "输入消息...", demo_send: "发送", demo_reply: "这是来自 ", demo_finder: "访达", demo_docs: "文稿" },
    "zh-Hant": { demo_try: "線上體驗", demo_welcome: "你好，這是與", demo_hint: "把滑鼠移到選單列，懸停", demo_close: "關閉體驗", demo_ph: "輸入訊息...", demo_send: "傳送", demo_reply: "這是來自 ", demo_finder: "訪達", demo_docs: "文稿" },
    ja: { demo_try: "デモ", demo_welcome: "これは", demo_hint: "メニューバーにマウスを移動してホバー", demo_close: "デモを閉じる", demo_ph: "メッセージを入力...", demo_send: "送信", demo_reply: "デモ返信：", demo_finder: "Finder", demo_docs: "書類" },
    ko: { demo_try: "데모", demo_welcome: "안녕하세요,", demo_hint: "메뉴바로 마우스를 옮겨 호버", demo_close: "데모 닫기", demo_ph: "메시지 입력...", demo_send: "보내기", demo_reply: "데모 답변: ", demo_finder: "파인더", demo_docs: "문서" },
    es: { demo_try: "Probar Demo", demo_welcome: "Hola, conversación demo con", demo_hint: "Mueve el ratón a la barra de menús y pasa el cursor", demo_close: "Cerrar demo", demo_ph: "Escribe un mensaje...", demo_send: "Enviar", demo_reply: "Respuesta demo de ", demo_finder: "Finder", demo_docs: "Documentos" },
    fr: { demo_try: "Essayer la démo", demo_welcome: "Bonjour, démo avec", demo_hint: "Déplacez la souris vers la barre de menus et survolez", demo_close: "Fermer la démo", demo_ph: "Écrivez un message...", demo_send: "Envoyer", demo_reply: "Réponse démo de ", demo_finder: "Finder", demo_docs: "Documents" },
    de: { demo_try: "Demo testen", demo_welcome: "Hallo, Demo-Chat mit", demo_hint: "Bewegen Sie die Maus zur Menüleiste und fahren Sie darüber", demo_close: "Demo schließen", demo_ph: "Nachricht eingeben...", demo_send: "Senden", demo_reply: "Demo-Antwort von ", demo_finder: "Finder", demo_docs: "Dokumente" },
    ru: { demo_try: "Демо", demo_welcome: "Привет, демо-чат с", demo_hint: "Наведите курсор на строку меню", demo_close: "Закрыть демо", demo_ph: "Введите сообщение...", demo_send: "Отправить", demo_reply: "Демо-ответ от ", demo_finder: "Finder", demo_docs: "Документы" },
    pt: { demo_try: "Experimentar", demo_welcome: "Olá, conversa demo com", demo_hint: "Mova o mouse para a barra de menus e passe o cursor", demo_close: "Fechar demo", demo_ph: "Digite uma mensagem...", demo_send: "Enviar", demo_reply: "Resposta demo de ", demo_finder: "Finder", demo_docs: "Documentos" }
  };
  Object.keys(i18n).forEach(function (lang) {
    Object.assign(i18n[lang], demoI18n[lang] || demoI18n.en);
  });

  const agentHosts = [
    "chatgpt.com", "claude.ai", "copilot.microsoft.com", "chat.deepseek.com", "doubao.com",
    "gemini.google.com", "grok.com", "kimi.moonshot.cn", "chat.mistral.ai", "chat.mistral.ai",
    "perplexity.ai", "pi.ai", "poe.com", "chat.qwen.ai", "tongyi.aliyun.com", "you.com",
    "yuanbao.tencent.com", "chatglm.cn", "hailuoai.com", "yiyan.baidu.com", "xinghuo.xfyun.cn",
    "meta.ai", "huggingface.co", "coze.cn", "monica.im", "cursor.com", "character.ai",
    "cohere.com", "flowith.net", "deepai.org", "julius.ai", "tiangong.cn", "metaso.cn",
    "blackbox.ai", "sider.ai", "phind.com", "top.aixin.baidu.com"
  ];

  function apply(lang) {
    const dict = i18n[lang] || i18n.en;
    const htmlLangs = {
      "zh": "zh-CN",
      "zh-Hant": "zh-TW",
      "en": "en",
      "ja": "ja",
      "ko": "ko",
      "es": "es",
      "fr": "fr",
      "de": "de",
      "ru": "ru",
      "pt": "pt"
    };
    document.documentElement.lang = htmlLangs[lang] || "en";
    document.getElementById("pageTitle").textContent = dict.page_title;
    document.getElementById("pageDesc").setAttribute("content", dict.page_desc);
    document.querySelectorAll("[data-i18n]").forEach(function (el) {
      const key = el.getAttribute("data-i18n");
      if (dict[key]) el.textContent = dict[key];
    });
    document.querySelectorAll("[data-i18n-ph]").forEach(function (el) {
      const key = el.getAttribute("data-i18n-ph");
      if (dict[key]) el.setAttribute("placeholder", dict[key]);
    });
    document.getElementById("langSelect").value = lang;
    document.getElementById("agentChips").innerHTML = dict.agents
      .map(function (name) { return '<span class="agent-chip">' + name + '</span>'; })
      .join("");
    renderAgentCloud(dict.agents);
  }

  function renderAgentCloud(agents) {
    const container = document.getElementById("agentCloud");
    if (!container) return;
    const items = agents.map(function (name, index) {
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
    container.innerHTML = '<div class="agent-marquee">' + items + items + '</div>';
  }

  const productsBtn = document.getElementById("productsBtn");
  const productsOverlay = document.getElementById("productsOverlay");
  const productGrid = document.getElementById("productGrid");
  const productSearch = document.getElementById("productSearch");

  function applyProductFilters() {
    const filter = document.querySelector("#productFilter button.on").getAttribute("data-filter");
    const cat = document.querySelector("#productCats button.on").getAttribute("data-cat");
    const query = productSearch.value.trim().toLowerCase();
    productGrid.querySelectorAll(".product-card").forEach(function (card) {
      const matchFilter = filter === "all" || card.getAttribute("data-state") === filter;
      const matchCat = cat === "all" || card.getAttribute("data-cat") === cat;
      const matchQuery = !query || card.getAttribute("data-search").toLowerCase().indexOf(query) !== -1;
      card.style.display = matchFilter && matchCat && matchQuery ? "" : "none";
    });
  }

  productsBtn.addEventListener("click", function () {
    productsOverlay.hidden = !productsOverlay.hidden;
    if (!productsOverlay.hidden) productSearch.focus();
  });
  productsOverlay.addEventListener("click", function (event) {
    if (event.target === productsOverlay) productsOverlay.hidden = true;
  });
  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") productsOverlay.hidden = true;
  });
  productSearch.addEventListener("input", applyProductFilters);
  document.querySelectorAll("#productFilter button").forEach(function (btn) {
    btn.addEventListener("click", function () {
      document.querySelectorAll("#productFilter button").forEach(function (b) {
        b.classList.toggle("on", b === btn);
      });
      applyProductFilters();
    });
  });
  document.querySelectorAll("#productCats button").forEach(function (btn) {
    btn.addEventListener("click", function () {
      document.querySelectorAll("#productCats button").forEach(function (b) {
        b.classList.toggle("on", b === btn);
      });
      applyProductFilters();
    });
  });

  let lang = localStorage.getItem("agentsbin-lang") || "en";
  apply(lang);

  document.getElementById("langSelect").addEventListener("change", function () {
    lang = this.value;
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

  const demoBtn = document.getElementById("demoBtn");
  const demoShell = document.getElementById("demoShell");
  const demoBackdrop = document.getElementById("demoBackdrop");
  const demoApp = document.getElementById("demoApp");
  const demoAB = document.getElementById("demoAB");
  const demoAgents = document.getElementById("demoAgents");
  const demoChat = document.getElementById("demoChat");
  const demoInput = document.getElementById("demoInput");
  const demoSend = document.getElementById("demoSend");
  const demoClose = document.getElementById("demoClose");
  const demoAI = document.getElementById("demoAI");
  const demoAN = document.getElementById("demoAN");
  let demoHideTimer;

  function openDemo() {
    demoShell.classList.add("on");
    demoBackdrop.classList.add("on");
    demoRefresh();
  }
  function closeDemo() {
    demoShell.classList.remove("on");
    demoBackdrop.classList.remove("on");
    demoApp.classList.remove("on");
    demoAB.classList.remove("hot");
  }
  function demoOpenApp() {
    clearTimeout(demoHideTimer);
    demoApp.classList.add("on");
    demoAB.classList.add("hot");
  }
  function demoCloseApp() {
    demoHideTimer = setTimeout(function () {
      demoApp.classList.remove("on");
      demoAB.classList.remove("hot");
    }, 500);
  }

  function demoIcon(name) {
    const norm = name.replace(/ /g, "").replace(/\./g, "");
    const letter = (name.charAt(0) || "?").toUpperCase();
    return '<img src="assets/agents/' + norm + '.png" alt="' + letter + '" loading="lazy">';
  }

  function demoAddMsg(role, text) {
    const m = document.createElement("div");
    m.className = "demo-msg " + (role === "u" ? "u" : "b");
    m.textContent = text;
    demoChat.appendChild(m);
    demoChat.scrollTop = 9999;
  }

  function demoRefresh() {
    const dict = i18n[lang] || i18n.en;
    demoAgents.innerHTML = dict.agents.map(function (name, index) {
      return '<div class="demo-ai' + (index === 0 ? " on" : "") + '" data-index="' + index + '">' + demoIcon(name) + '<span>' + name + '</span></div>';
    }).join("");
    demoAgents.querySelectorAll(".demo-ai img").forEach(function (img) {
      img.addEventListener("error", function () {
        const span = document.createElement("span");
        span.className = "demo-letter";
        span.textContent = img.getAttribute("alt") || "?";
        img.replaceWith(span);
      });
    });
    demoAgents.querySelectorAll(".demo-ai").forEach(function (el) {
      el.addEventListener("click", function () {
        const idx = Number(el.getAttribute("data-index"));
        demoAgents.querySelectorAll(".demo-ai").forEach(function (x) { x.classList.remove("on"); });
        el.classList.add("on");
        const name = dict.agents[idx];
        const host = (agentHosts[idx] || "example.com").replace(/^www\./, "");
        demoAN.textContent = name;
        demoAI.src = "assets/agents/" + name.replace(/ /g, "").replace(/\./g, "") + ".png";
        demoAI.onerror = function () { demoAI.style.display = "none"; };
        demoChat.innerHTML = "";
        demoAddMsg("b", dict.demo_welcome + " " + name + ".");
      });
    });
    demoChat.innerHTML = "";
    demoAddMsg("b", dict.demo_welcome + " " + demoAN.textContent + ".");
  }

  function demoSendMsg() {
    const dict = i18n[lang] || i18n.en;
    const value = demoInput.value.trim();
    if (!value) return;
    demoAddMsg("u", value);
    demoInput.value = "";
    setTimeout(function () {
      demoAddMsg("b", dict.demo_reply + demoAN.textContent + ".");
    }, 400);
  }

  if (demoBtn) demoBtn.addEventListener("click", openDemo);
  if (demoClose) demoClose.addEventListener("click", closeDemo);
  if (demoBackdrop) demoBackdrop.addEventListener("click", closeDemo);
  if (demoAB) {
    demoAB.addEventListener("mouseenter", demoOpenApp);
    demoAB.addEventListener("mouseleave", demoCloseApp);
  }
  if (demoApp) {
    demoApp.addEventListener("mouseenter", demoOpenApp);
    demoApp.addEventListener("mouseleave", demoCloseApp);
  }
  if (demoSend) demoSend.addEventListener("click", demoSendMsg);
  if (demoInput) demoInput.addEventListener("keydown", function (e) { if (e.key === "Enter") demoSendMsg(); });
  document.addEventListener("keydown", function (e) { if (e.key === "Escape") closeDemo(); });


  document.querySelectorAll('a[href^="downloads/"]').forEach(function (link) {
    link.addEventListener("click", function () {
      const payload = JSON.stringify({
        kind: "download",
        name: "dmg",
        version: "1.1.4",
        source: "web"
      });
      if (navigator.sendBeacon) {
        navigator.sendBeacon("/api/track", new Blob([payload], { type: "application/json" }));
      } else {
        fetch("/api/track", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: payload,
          keepalive: true
        });
      }
    });
  });

})();
