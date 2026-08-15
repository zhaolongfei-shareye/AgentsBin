(function () {
  var L = {
    en: {
      nav_products: "Products", nav_about: "About",
      popup_title: "Explore products", popup_search: "Search products",
      filter_all: "All", filter_released: "Released", filter_soon: "Coming Soon",
      cat_all: "All", cat_assistants: "AI Assistants", cat_audio: "Audio", cat_media: "Media Tools", cat_web: "Web Apps",
      status_released: "Released", status_soon: "In Development",
      p_agentsbin: "AgentsBin", p_agentsbin_desc: "All-in-one AI chat hub for macOS with 43 AI agents.",
      p_wf: "Watermark Factory", p_wf_desc: "Local AI watermark identification and restoration. 30+ sources, offline.",
      p_qs: "AgentsQS", p_qs_desc: "Quantitative strategy research and backtesting copilot.",
      p_tts: "AgentsTTS", p_tts_desc: "Multilingual TTS and podcast episode tool.",
      p_solohq: "SoloHQ", p_solohq_desc: "Local-first dashboard for one-person companies.",
      about_role: "Indie developer · macOS AI tools", about_name: "Jacky Zhao",
      about_bio: "Local first. Clean interfaces. Your data stays yours.",
      acct_email: "Email", acct_facebook: "Facebook", acct_x: "X", acct_wechat: "WeChat"
    },
    zh: {
      nav_products: "产品", nav_about: "关于",
      popup_title: "探索产品", popup_search: "搜索产品",
      filter_all: "全部", filter_released: "已上线", filter_soon: "即将上线",
      cat_all: "全部", cat_assistants: "AI 助手", cat_audio: "音频", cat_media: "媒体工具", cat_web: "Web 应用",
      status_released: "已上线", status_soon: "开发中",
      p_agentsbin: "AgentsBin", p_agentsbin_desc: "macOS 一体化 AI 聊天中心，内置 43 个智能体。",
      p_wf: "水印工厂", p_wf_desc: "本地 AI 水印识别与还原，支持 30+ 来源，完全离线。",
      p_qs: "AgentsQS", p_qs_desc: "量化策略研究与回测 AI 助手。",
      p_tts: "AgentsTTS", p_tts_desc: "多语言语音合成与播客制作工具。",
      p_solohq: "SoloHQ", p_solohq_desc: "一人公司的本地优先仪表盘。",
      about_role: "独立开发者 · macOS AI 工具", about_name: "Jacky Zhao",
      about_bio: "本地优先，界面干净，数据只属于你。",
      acct_email: "邮箱", acct_facebook: "Facebook", acct_x: "X", acct_wechat: "微信"
    },
    "zh-Hant": {
      nav_products: "產品", nav_about: "關於",
      popup_title: "探索產品", popup_search: "搜索產品",
      filter_all: "全部", filter_released: "已上線", filter_soon: "即將上線",
      cat_all: "全部", cat_assistants: "AI 助手", cat_audio: "音頻", cat_media: "媒體工具", cat_web: "Web 應用",
      status_released: "已上線", status_soon: "開發中",
      p_agentsbin: "AgentsBin", p_agentsbin_desc: "macOS 一體化 AI 聊天中心，內建 43 個智慧體。",
      p_wf: "水印工廠", p_wf_desc: "本地 AI 浮水印識別與還原，支援 30+ 來源，完全離線。",
      p_qs: "AgentsQS", p_qs_desc: "量化策略研究與回測 AI 助手。",
      p_tts: "AgentsTTS", p_tts_desc: "多語言語音合成與播客製作工具。",
      p_solohq: "SoloHQ", p_solohq_desc: "一人公司的本地優先儀表板。",
      about_role: "獨立開發者 · macOS AI 工具", about_name: "Jacky Zhao",
      about_bio: "本地優先，介面乾淨，資料只屬於你。",
      acct_email: "電郵", acct_facebook: "Facebook", acct_x: "X", acct_wechat: "微信"
    },
    ja: {
      nav_products: "製品", nav_about: "概要",
      popup_title: "製品を見る", popup_search: "製品を検索",
      filter_all: "すべて", filter_released: "公開済み", filter_soon: "近日公開",
      cat_all: "すべて", cat_assistants: "AIアシスタント", cat_audio: "オーディオ", cat_media: "メディア", cat_web: "Webアプリ",
      status_released: "公開済み", status_soon: "開発中",
      p_agentsbin: "AgentsBin", p_agentsbin_desc: "macOS用オールインワンAIチャットハブ、43エージェント。",
      p_wf: "Watermark Factory", p_wf_desc: "ローカルAI透かし識別・除去、30以上のソース対応。",
      p_qs: "AgentsQS", p_qs_desc: "定量戦略研究とバックテストのAIコパイロット。",
      p_tts: "AgentsTTS", p_tts_desc: "多言語TTSとポッドキャスト制作ツール。",
      p_solohq: "SoloHQ", p_solohq_desc: "一人会社向けのローカル優先ダッシュボード。",
      about_role: "インディーデベロッパー · macOS AIツール", about_name: "Jacky Zhao",
      about_bio: "ローカル優先、クリーンなUI、データはあなたのもの。",
      acct_email: "メール", acct_facebook: "Facebook", acct_x: "X", acct_wechat: "微信"
    },
    ko: {
      nav_products: "제품", nav_about: "소개",
      popup_title: "제품 살펴보기", popup_search: "제품 검색",
      filter_all: "전체", filter_released: "출시됨", filter_soon: "곧 출시",
      cat_all: "전체", cat_assistants: "AI 어시스턴트", cat_audio: "오디오", cat_media: "미디어 도구", cat_web: "웹 앱",
      status_released: "출시됨", status_soon: "개발 중",
      p_agentsbin: "AgentsBin", p_agentsbin_desc: "43개 AI 에이전트를 지원하는 macOS 올인원 AI 허브.",
      p_wf: "Watermark Factory", p_wf_desc: "로컬 AI 워터마크 식별·제거, 30+ 소스 지원.",
      p_qs: "AgentsQS", p_qs_desc: "퀀트 전략 연구와 백테스트 AI 코파일럿.",
      p_tts: "AgentsTTS", p_tts_desc: "다국어 TTS와 팟캐스트 제작 도구.",
      p_solohq: "SoloHQ", p_solohq_desc: "1인 기업을 위한 로컬 우선 대시보드.",
      about_role: "인디 개발자 · macOS AI 도구", about_name: "Jacky Zhao",
      about_bio: "로컬 우선, 깔끔한 UI, 데이터는 당신의 것.",
      acct_email: "이메일", acct_facebook: "Facebook", acct_x: "X", acct_wechat: "위챗"
    },
    es: {
      nav_products: "Productos", nav_about: "Acerca",
      popup_title: "Explorar productos", popup_search: "Buscar productos",
      filter_all: "Todos", filter_released: "Publicados", filter_soon: "Próximamente",
      cat_all: "Todos", cat_assistants: "Asistentes IA", cat_audio: "Audio", cat_media: "Herramientas multimedia", cat_web: "Apps web",
      status_released: "Publicado", status_soon: "En desarrollo",
      p_agentsbin: "AgentsBin", p_agentsbin_desc: "Centro de chat IA todo en uno para macOS con 43 agentes.",
      p_wf: "Watermark Factory", p_wf_desc: "Identificación y eliminación local de marcas de agua IA.",
      p_qs: "AgentsQS", p_qs_desc: "Copiloto IA para estrategias cuantitativas.",
      p_tts: "AgentsTTS", p_tts_desc: "TTS multilingüe y producción de podcasts.",
      p_solohq: "SoloHQ", p_solohq_desc: "Panel local-first para empresas de una persona.",
      about_role: "Desarrollador indie · herramientas macOS IA", about_name: "Jacky Zhao",
      about_bio: "Local primero. Interfaz limpia. Tus datos son tuyos.",
      acct_email: "Email", acct_facebook: "Facebook", acct_x: "X", acct_wechat: "WeChat"
    },
    fr: {
      nav_products: "Produits", nav_about: "À propos",
      popup_title: "Explorer les produits", popup_search: "Rechercher",
      filter_all: "Tous", filter_released: "Publiés", filter_soon: "Bientôt",
      cat_all: "Tous", cat_assistants: "Assistants IA", cat_audio: "Audio", cat_media: "Outils média", cat_web: "Apps web",
      status_released: "Publié", status_soon: "En développement",
      p_agentsbin: "AgentsBin", p_agentsbin_desc: "Hub IA tout-en-un pour macOS avec 43 agents.",
      p_wf: "Watermark Factory", p_wf_desc: "Identification et suppression locales des filigranes IA.",
      p_qs: "AgentsQS", p_qs_desc: "Copilote IA pour stratégies quantitatives.",
      p_tts: "AgentsTTS", p_tts_desc: "TTS multilingue et production de podcasts.",
      p_solohq: "SoloHQ", p_solohq_desc: "Tableau de bord local-first pour entreprises individuelles.",
      about_role: "Développeur indie · outils macOS IA", about_name: "Jacky Zhao",
      about_bio: "Local d'abord. Interface propre. Vos données vous appartiennent.",
      acct_email: "Email", acct_facebook: "Facebook", acct_x: "X", acct_wechat: "WeChat"
    },
    de: {
      nav_products: "Produkte", nav_about: "Über",
      popup_title: "Produkte entdecken", popup_search: "Produkte suchen",
      filter_all: "Alle", filter_released: "Veröffentlicht", filter_soon: "Bald",
      cat_all: "Alle", cat_assistants: "KI-Assistenten", cat_audio: "Audio", cat_media: "Medien-Tools", cat_web: "Web-Apps",
      status_released: "Veröffentlicht", status_soon: "In Entwicklung",
      p_agentsbin: "AgentsBin", p_agentsbin_desc: "All-in-One-KI-Chat-Hub für macOS mit 43 Agenten.",
      p_wf: "Watermark Factory", p_wf_desc: "Lokale KI-Wasserzeichenerkennung und -entfernung.",
      p_qs: "AgentsQS", p_qs_desc: "KI-Copilot für quantitative Strategien.",
      p_tts: "AgentsTTS", p_tts_desc: "Mehrsprachige TTS und Podcast-Produktion.",
      p_solohq: "SoloHQ", p_solohq_desc: "Lokale Dashboard-Lösung für Ein-Personen-Unternehmen.",
      about_role: "Indie-Entwickler · macOS-KI-Tools", about_name: "Jacky Zhao",
      about_bio: "Lokal zuerst. Saubere Oberfläche. Deine Daten gehören dir.",
      acct_email: "E-Mail", acct_facebook: "Facebook", acct_x: "X", acct_wechat: "WeChat"
    },
    ru: {
      nav_products: "Продукты", nav_about: "О проекте",
      popup_title: "Наши продукты", popup_search: "Поиск продуктов",
      filter_all: "Все", filter_released: "Выпущено", filter_soon: "Скоро",
      cat_all: "Все", cat_assistants: "ИИ-ассистенты", cat_audio: "Аудио", cat_media: "Медиаинструменты", cat_web: "Веб-приложения",
      status_released: "Выпущено", status_soon: "В разработке",
      p_agentsbin: "AgentsBin", p_agentsbin_desc: "Единый AI-хаб для macOS с 43 агентами.",
      p_wf: "Watermark Factory", p_wf_desc: "Локальное удаление ИИ-водяных знаков, 30+ источников.",
      p_qs: "AgentsQS", p_qs_desc: "ИИ-ассистент для количественных стратегий.",
      p_tts: "AgentsTTS", p_tts_desc: "Многоязычный TTS и создание подкастов.",
      p_solohq: "SoloHQ", p_solohq_desc: "Локальная панель для компаний из одного человека.",
      about_role: "Инди-разработчик · macOS AI инструменты", about_name: "Jacky Zhao",
      about_bio: "Локально прежде всего. Чистые интерфейсы. Ваши данные принадлежат вам.",
      acct_email: "Email", acct_facebook: "Facebook", acct_x: "X", acct_wechat: "WeChat"
    },
    pt: {
      nav_products: "Produtos", nav_about: "Sobre",
      popup_title: "Explorar produtos", popup_search: "Pesquisar produtos",
      filter_all: "Todos", filter_released: "Lançados", filter_soon: "Em breve",
      cat_all: "Todos", cat_assistants: "Assistentes de IA", cat_audio: "Áudio", cat_media: "Ferramentas de mídia", cat_web: "Apps web",
      status_released: "Lançado", status_soon: "Em desenvolvimento",
      p_agentsbin: "AgentsBin", p_agentsbin_desc: "Hub de IA tudo-em-um para macOS com 43 agentes.",
      p_wf: "Watermark Factory", p_wf_desc: "Remoção local de marcas d'água de IA, 30+ fontes.",
      p_qs: "AgentsQS", p_qs_desc: "Copiloto de IA para estratégias quantitativas.",
      p_tts: "AgentsTTS", p_tts_desc: "TTS multilíngue e produção de podcasts.",
      p_solohq: "SoloHQ", p_solohq_desc: "Painel local-first para empresas de uma pessoa.",
      about_role: "Desenvolvedor indie · ferramentas de IA macOS", about_name: "Jacky Zhao",
      about_bio: "Local primeiro. Interfaces limpas. Seus dados são seus.",
      acct_email: "E-mail", acct_facebook: "Facebook", acct_x: "X", acct_wechat: "WeChat"
    }
  };

  var E = {
    en: {
      home_hero_title: 'AI tools for macOS,<br>built <span class="grad">small and sharp</span>.',
      home_hero_lead: 'Four tools. One local-first studio. Every app runs locally and ships clean.',
      cta_explore: 'Explore products', cta_wf: 'Watermark Factory', cta_solohq: 'SoloHQ',
      section_released: 'Released', section_released_sub: 'Available now, free to try.',
      section_dev: 'In Development', section_dev_sub: 'Coming next from the same workshop.',
      ab_tagline: 'All your AI agents, one menu bar away.',
      wf_tagline: 'Restore clean images, 100% locally.',
      qs_tagline: 'Think in strategies, test with data.',
      tts_tagline: 'Turn scripts into voice, naturally.',
      tag_menu: 'Menu bar', tag_43: '43 agents', tag_api: 'API mode',
      tag_offline: 'Offline', tag_sources: '30+ sources', tag_batch: 'Batch',
      tag_backtest: 'Backtest', tag_copilot: 'AI copilot', tag_local: 'Local first',
      tag_multi: 'Multilingual', tag_voice: 'Voice preview', tag_episode: 'Episode export',
      btn_download: 'Download',
      nav_home: 'Home',
      home_trust: 'Free · macOS 13+ · No account',
      home_live_badge: 'LIVE · LOCAL AI',
      home_chip_sources: '30+ sources',
      home_chip_local: '100% local',
      in_dev: 'In Dev',
      home_footer: '© 2026 AgentsBin · macOS AI tools studio'
    },
    zh: {
      home_hero_title: 'macOS AI 工具，<br>做得 <span class="grad">小而精</span>。',
      home_hero_lead: '四个工具，一个本地优先的工作室。每个应用都本地运行、干净交付。',
      cta_explore: '探索产品', cta_wf: '水印工厂', cta_solohq: 'SoloHQ',
      section_released: '已上线', section_released_sub: '现在可用，免费试用。',
      section_dev: '开发中', section_dev_sub: '来自同一工作室的下一批作品。',
      ab_tagline: '所有 AI 智能体，一个菜单栏搞定。',
      wf_tagline: '本地还原干净图片，100% 本地完成。',
      qs_tagline: '用策略思考，用数据验证。',
      tts_tagline: '把文字自然变成声音。',
      tag_menu: '菜单栏', tag_43: '43 个智能体', tag_api: 'API 模式',
      tag_offline: '离线', tag_sources: '30+ 来源', tag_batch: '批量',
      tag_backtest: '回测', tag_copilot: 'AI 助手', tag_local: '本地优先',
      tag_multi: '多语言', tag_voice: '声音预览', tag_episode: '剧集导出',
      btn_download: '下载',
      nav_home: '首页',
      home_trust: '免费 · macOS 13+ · 无需账号',
      home_live_badge: '实时 · 本地 AI',
      home_chip_sources: '30+ 来源',
      home_chip_local: '100% 本地',
      in_dev: '开发中',
      home_footer: '© 2026 AgentsBin · macOS AI 工具工作室'
    },
    "zh-Hant": {
      home_hero_title: 'macOS AI 工具，<br>做得 <span class="grad">小而精</span>。',
      home_hero_lead: '四個工具，一個本地優先的工作室。每個應用都本地運行、乾淨交付。',
      cta_explore: '探索產品', cta_wf: '水印工廠', cta_solohq: 'SoloHQ',
      section_released: '已上線', section_released_sub: '現在可用，免費試用。',
      section_dev: '開發中', section_dev_sub: '來自同一工作室的下一批作品。',
      ab_tagline: '所有 AI 智能體，一個選單列搞定。',
      wf_tagline: '本地還原乾淨圖片，100% 本地完成。',
      qs_tagline: '用策略思考，用數據驗證。',
      tts_tagline: '把文字自然變成聲音。',
      tag_menu: '選單列', tag_43: '43 個智慧體', tag_api: 'API 模式',
      tag_offline: '離線', tag_sources: '30+ 來源', tag_batch: '批次',
      tag_backtest: '回測', tag_copilot: 'AI 助手', tag_local: '本地優先',
      tag_multi: '多語言', tag_voice: '聲音預覽', tag_episode: '劇集匯出',
      btn_download: '下載',
      nav_home: '首頁',
      home_trust: '免費 · macOS 13+ · 無需帳號',
      home_live_badge: '即時 · 本地 AI',
      home_chip_sources: '30+ 來源',
      home_chip_local: '100% 本地',
      in_dev: '開發中',
      home_footer: '© 2026 AgentsBin · macOS AI 工具工作室'
    },
    ja: {
      home_hero_title: 'macOS向けAIツール、<br><span class="grad">小さく鋭く</span>。',
      home_hero_lead: '4つのツール、ローカル優先のスタジオ。すべてローカルで動作。',
      cta_explore: '製品を見る', cta_wf: 'Watermark Factory', cta_solohq: 'SoloHQ',
      section_released: '公開済み', section_released_sub: '今すぐ無料で試せます。',
      section_dev: '開発中', section_dev_sub: '同じスタジオの次の作品。',
      ab_tagline: 'すべてのAIエージェントをメニューバーで。',
      wf_tagline: '画像を100%ローカルで復元。',
      qs_tagline: '戦略で考え、データで検証。',
      tts_tagline: 'テキストを自然な声に。',
      tag_menu: 'メニューバー', tag_43: '43エージェント', tag_api: 'APIモード',
      tag_offline: 'オフライン', tag_sources: '30以上のソース', tag_batch: 'バッチ',
      tag_backtest: 'バックテスト', tag_copilot: 'AIコパイロット', tag_local: 'ローカル優先',
      tag_multi: '多言語', tag_voice: '音声プレビュー', tag_episode: 'エピソード出力',
      btn_download: 'ダウンロード',
      nav_home: 'ホーム',
      home_trust: '無料 · macOS 13+ · アカウント不要',
      home_live_badge: 'LIVE · ローカル AI',
      home_chip_sources: '30以上のソース',
      home_chip_local: '100% ローカル',
      in_dev: '開発中',
      home_footer: '© 2026 AgentsBin · macOS AI ツールスタジオ'
    },
    ko: {
      home_hero_title: 'macOS AI 도구,<br><span class="grad">작고 날카롭게</span>.',
      home_hero_lead: '4가지 도구, 로컬 우선 스튜디오. 모든 앱이 로컬에서 실행됩니다.',
      cta_explore: '제품 살펴보기', cta_wf: 'Watermark Factory', cta_solohq: 'SoloHQ',
      section_released: '출시됨', section_released_sub: '지금 무료로 사용해 보세요.',
      section_dev: '개발 중', section_dev_sub: '같은 스튜디오의 다음 작품.',
      ab_tagline: '모든 AI 에이전트를 메뉴바에서.',
      wf_tagline: '이미지를 100% 로컬에서 복원.',
      qs_tagline: '전략으로 생각하고 데이터로 검증.',
      tts_tagline: '텍스트를 자연스러운 음성으로.',
      tag_menu: '메뉴바', tag_43: '43개 에이전트', tag_api: 'API 모드',
      tag_offline: '오프라인', tag_sources: '30+ 소스', tag_batch: '배치',
      tag_backtest: '백테스트', tag_copilot: 'AI 코파일럿', tag_local: '로컬 우선',
      tag_multi: '다국어', tag_voice: '음성 미리듣기', tag_episode: '에피소드 내보내기',
      btn_download: '다운로드',
      nav_home: '홈',
      home_trust: '무료 · macOS 13+ · 계정 불필요',
      home_live_badge: 'LIVE · 로컬 AI',
      home_chip_sources: '30+ 소스',
      home_chip_local: '100% 로컬',
      in_dev: '개발 중',
      home_footer: '© 2026 AgentsBin · macOS AI 도구 스튜디오'
    },
    es: {
      home_hero_title: 'Herramientas IA para macOS,<br><span class="grad">pequeñas y afiladas</span>.',
      home_hero_lead: 'Cuatro herramientas. Un estudio local-first. Cada app corre local y limpia.',
      cta_explore: 'Explorar productos', cta_wf: 'Watermark Factory', cta_solohq: 'SoloHQ',
      section_released: 'Publicados', section_released_sub: 'Disponible ahora, gratis.',
      section_dev: 'En desarrollo', section_dev_sub: 'Lo próximo del mismo taller.',
      ab_tagline: 'Todos tus agentes IA a un clic.',
      wf_tagline: 'Restaura imágenes limpias, 100% local.',
      qs_tagline: 'Piensa en estrategias, prueba con datos.',
      tts_tagline: 'Convierte guiones en voz, naturalmente.',
      tag_menu: 'Menú', tag_43: '43 agentes', tag_api: 'Modo API',
      tag_offline: 'Sin conexión', tag_sources: '30+ fuentes', tag_batch: 'Lote',
      tag_backtest: 'Backtest', tag_copilot: 'Copiloto IA', tag_local: 'Local primero',
      tag_multi: 'Multilingüe', tag_voice: 'Vista previa', tag_episode: 'Exportar episodio',
      btn_download: 'Descargar',
      nav_home: 'Inicio',
      home_trust: 'Gratis · macOS 13+ · Sin cuenta',
      home_live_badge: 'EN VIVO · IA LOCAL',
      home_chip_sources: '30+ fuentes',
      home_chip_local: '100% local',
      in_dev: 'En desarrollo',
      home_footer: '© 2026 AgentsBin · Estudio de herramientas IA para macOS'
    },
    fr: {
      home_hero_title: 'Des outils IA pour macOS,<br><span class="grad">petits et précis</span>.',
      home_hero_lead: 'Quatre outils. Un studio local d’abord. Chaque app tourne en local.',
      cta_explore: 'Explorer les produits', cta_wf: 'Watermark Factory', cta_solohq: 'SoloHQ',
      section_released: 'Publiés', section_released_sub: 'Disponible maintenant, gratuit.',
      section_dev: 'En développement', section_dev_sub: 'À venir du même studio.',
      ab_tagline: 'Tous vos agents IA à un clic.',
      wf_tagline: 'Restaurez des images propres, 100 % local.',
      qs_tagline: 'Pensez en stratégies, testez avec des données.',
      tts_tagline: 'Transformez des scripts en voix, naturellement.',
      tag_menu: 'Menu', tag_43: '43 agents', tag_api: 'Mode API',
      tag_offline: 'Hors ligne', tag_sources: '30+ sources', tag_batch: 'Lot',
      tag_backtest: 'Backtest', tag_copilot: 'Copilote IA', tag_local: 'Local d’abord',
      tag_multi: 'Multilingue', tag_voice: 'Aperçu vocal', tag_episode: 'Exporter l’épisode',
      btn_download: 'Télécharger',
      nav_home: 'Accueil',
      home_trust: 'Gratuit · macOS 13+ · Sans compte',
      home_live_badge: 'EN DIRECT · IA LOCALE',
      home_chip_sources: '30+ sources',
      home_chip_local: '100 % local',
      in_dev: 'En développement',
      home_footer: '© 2026 AgentsBin · Studio d’outils IA pour macOS'
    },
    de: {
      home_hero_title: 'KI-Tools für macOS,<br><span class="grad">klein und scharf</span>.',
      home_hero_lead: 'Vier Tools. Ein lokales Studio. Jede App läuft lokal und sauber.',
      cta_explore: 'Produkte entdecken', cta_wf: 'Watermark Factory', cta_solohq: 'SoloHQ',
      section_released: 'Veröffentlicht', section_released_sub: 'Jetzt verfügbar, kostenlos testen.',
      section_dev: 'In Entwicklung', section_dev_sub: 'Als Nächstes aus demselben Studio.',
      ab_tagline: 'Alle KI-Agenten nur einen Klick entfernt.',
      wf_tagline: 'Bilder sauber und 100 % lokal wiederherstellen.',
      qs_tagline: 'In Strategien denken, mit Daten testen.',
      tts_tagline: 'Skripte natürlich in Stimme verwandeln.',
      tag_menu: 'Menüleiste', tag_43: '43 Agenten', tag_api: 'API-Modus',
      tag_offline: 'Offline', tag_sources: '30+ Quellen', tag_batch: 'Stapel',
      tag_backtest: 'Backtest', tag_copilot: 'KI-Copilot', tag_local: 'Lokal zuerst',
      tag_multi: 'Mehrsprachig', tag_voice: 'Stimmvorschau', tag_episode: 'Folge exportieren',
      btn_download: 'Download',
      nav_home: 'Start',
      home_trust: 'Kostenlos · macOS 13+ · Kein Konto',
      home_live_badge: 'LIVE · LOKALE KI',
      home_chip_sources: '30+ Quellen',
      home_chip_local: '100 % lokal',
      in_dev: 'In Entwicklung',
      home_footer: '© 2026 AgentsBin · Studio für macOS-KI-Tools'
    }
  };

  function lang() {
    return localStorage.getItem("agentsbin-lang") || "en";
  }

  function apply() {
    var dict = Object.assign({}, L[lang()] || L.en, E[lang()] || {});
    document.querySelectorAll("[data-i18n], [data-i18n-html]").forEach(function (el) {
      var key = el.getAttribute("data-i18n") || el.getAttribute("data-i18n-html");
      if (dict[key]) {
        if (el.hasAttribute("data-i18n-html")) el.innerHTML = dict[key];
        else el.textContent = dict[key];
      }
    });
    document.querySelectorAll("[data-i18n-ph]").forEach(function (el) {
      var key = el.getAttribute("data-i18n-ph");
      if (dict[key]) el.setAttribute("placeholder", dict[key]);
    });
  }

  function bind() {
    var select = document.getElementById("langSelect");
    if (!select) return;
    select.value = lang();
    select.addEventListener("change", function () {
      localStorage.setItem("agentsbin-lang", select.value);
      apply();
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", function () { apply(); bind(); });
  } else {
    apply();
    bind();
  }
})();
