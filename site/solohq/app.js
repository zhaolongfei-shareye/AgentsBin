const SOLOHQ_VERSION = "0.2.6";

const STRINGS = {
  en: {
    page_title: "SoloHQ · Local-first dashboard for one-person companies",
    page_desc: "SoloHQ is a local-first dashboard for one-person companies. Track projects, write workspace memos, organize bookmarks, search the web, and watch revenue in one browser app.",
    crumb: "SoloHQ",
    hero_badge: "Open Source · Local-first · MIT",
    hero_title: "One dashboard for your one-person company.",
    hero_lead: "Track projects, keep workspace memos, organize bookmarks, search the web, and watch revenue in a single local-first dashboard. No backend, no account, no lock-in.",
    hero_cta: "Try Live Demo",
    hero_cta2: "View Source",
    hero_trust: "Free · Open source · Data stays in your browser",
    window_title: "SoloHQ · Local-first dashboard",
    features_title: "Everything a solo founder needs in one screen",
    features_sub: "Project board · memos · bookmarks · search · revenue",
    f1t: "Project board",
    f1d: "Track developing, launched, revenue, and abandoned projects with progress bars.",
    f2t: "Workspace memo",
    f2d: "Keep a per-project dev log, milestones, and ideas next to the project.",
    f3t: "Bookmarks & search",
    f3d: "Organize AI, media, and dev links, then search across Google, Bing, GitHub, and more.",
    f4t: "Revenue tracking",
    f4d: "See MRR and project status at a glance with the stats mode.",
    f5t: "Four themes",
    f5d: "Light, dark, glass, and hacker themes with drag-to-reorder widgets.",
    f6t: "Google Docs project notes",
    f6d: "On demand, create a SoloHQ Drive folder and keep one project-named Google Doc updated.",
    demo_title: "Try the live demo",
    demo_sub: "Open the dashboard directly in your browser. Create projects, write memos, and export a JSON backup without installing anything.",
    demo_btn: "Open Demo",
    footer_note: "SoloHQ · Open source dashboard for one-person companies"
  },
  zh: {
    page_title: "SoloHQ · 一人公司本地优先仪表盘",
    page_desc: "SoloHQ 是面向一人公司的本地优先仪表盘。在一个浏览器应用中管理项目、工作区备忘录、书签、搜索和收入。",
    crumb: "SoloHQ",
    hero_badge: "开源 · 本地优先 · MIT",
    hero_title: "一人公司，一个仪表盘。",
    hero_lead: "在一个本地优先的仪表盘里管理项目、工作区备忘录、书签、搜索和收入。无后端、无账号、无锁定。",
    hero_cta: "在线体验",
    hero_cta2: "查看源码",
    hero_trust: "免费 · 开源 · 数据留在浏览器",
    window_title: "SoloHQ · 本地优先仪表盘",
    features_title: "独立创业者需要的一切，一个屏幕搞定",
    features_sub: "项目看板 · 备忘录 · 书签 · 搜索 · 收入",
    f1t: "项目看板",
    f1d: "用进度条跟踪开发中、已上线、有收入和放弃的项目。",
    f2t: "工作区备忘录",
    f2d: "每个项目保留独立开发日志、里程碑和灵感。",
    f3t: "书签与搜索",
    f3d: "整理 AI、媒体和开发链接，并在 Google、Bing、GitHub 等引擎搜索。",
    f4t: "收入追踪",
    f4d: "在统计模式下快速查看 MRR 和项目状态。",
    f5t: "四套主题",
    f5d: "浅色、深色、玻璃和黑客主题，支持拖拽排序组件。",
    f6t: "Google Docs 项目笔记",
    f6d: "按需创建 SoloHQ Drive 文件夹，并持续更新以项目命名的 Google 文档。",
    demo_title: "试试在线 Demo",
    demo_sub: "直接在浏览器打开仪表盘，无需安装即可创建项目、写备忘录和导出 JSON 备份。",
    demo_btn: "打开 Demo",
    footer_note: "SoloHQ · 一人公司开源仪表盘"
  },
  "zh-Hant": {
    page_title: "SoloHQ · 一人公司本地優先儀表板",
    page_desc: "SoloHQ 是面向一人公司的本地優先儀表板，在一個瀏覽器應用中管理專案、工作區備忘錄、書籤、搜尋與收入。",
    crumb: "SoloHQ",
    hero_badge: "開源 · 本地優先 · MIT",
    hero_title: "一人公司，一個儀表板。",
    hero_lead: "在一個本地優先的儀表板裡管理專案、工作區備忘錄、書籤、搜尋與收入。無後端、無帳號、無鎖定。",
    hero_cta: "線上體驗",
    hero_cta2: "查看原始碼",
    hero_trust: "免費 · 開源 · 資料留在瀏覽器",
    window_title: "SoloHQ · 本地優先儀表板",
    features_title: "獨立創業者需要的一切，一個畫面搞定",
    features_sub: "專案看板 · 備忘錄 · 書籤 · 搜尋 · 收入",
    f1t: "專案看板",
    f1d: "用進度條追蹤開發中、已上線、有收入和放棄的專案。",
    f2t: "工作區備忘錄",
    f2d: "每個專案保留獨立開發日誌、里程碑與靈感。",
    f3t: "書籤與搜尋",
    f3d: "整理 AI、媒體與開發連結，並在 Google、Bing、GitHub 等引擎搜尋。",
    f4t: "收入追蹤",
    f4d: "在統計模式下快速查看 MRR 與專案狀態。",
    f5t: "四套主題",
    f5d: "淺色、深色、玻璃與駭客主題，支援拖曳排序元件。",
    f6t: "Google Docs 專案筆記",
    f6d: "依需求建立 SoloHQ Drive 資料夾，並持續更新以專案命名的 Google 文件。",
    demo_title: "試試線上 Demo",
    demo_sub: "直接在瀏覽器開啟儀表板，無需安裝即可建立專案、寫備忘錄與匯出 JSON 備份。",
    demo_btn: "開啟 Demo",
    footer_note: "SoloHQ · 一人公司開源儀表板"
  },
  ja: {
    page_title: "SoloHQ · 一人会社向けローカル優先ダッシュボード",
    page_desc: "SoloHQは一人会社向けのローカル優先ダッシュボードです。プロジェクト、メモ、ブックマーク、検索、収益を1つのブラウザアプリで管理できます。",
    crumb: "SoloHQ",
    hero_badge: "オープンソース · ローカル優先 · MIT",
    hero_title: "一人会社のダッシュボードはこれひとつ。",
    hero_lead: "プロジェクト、ワークスペースメモ、ブックマーク、検索、収益を、ローカル優先の1つのダッシュボードで。バックエンド不要、アカウント不要、ロックインなし。",
    hero_cta: "ライブデモ",
    hero_cta2: "ソースを見る",
    hero_trust: "無料 · オープンソース · データはブラウザ内",
    window_title: "SoloHQ · ローカル優先ダッシュボード",
    features_title: "ひとり起業に必要なすべてを1画面で",
    features_sub: "プロジェクト · メモ · ブックマーク · 検索 · 収益",
    f1t: "プロジェクトボード",
    f1d: "開発中、公開済み、収益化、中止のプロジェクトを進捗バーで管理。",
    f2t: "ワークスペースメモ",
    f2d: "プロジェクトごとに開発ログ、マイルストーン、アイデアを保存。",
    f3t: "ブックマークと検索",
    f3d: "AI、メディア、開発リンクを整理し、Google、Bing、GitHubなどで検索。",
    f4t: "収益トラッキング",
    f4d: "統計モードでMRRとプロジェクトの状態をひと目で確認。",
    f5t: "4つのテーマ",
    f5d: "ライト、ダーク、グラス、ハッカー。ウィジェットはドラッグで並べ替え。",
    f6t: "Google Docs プロジェクトノート",
    f6d: "必要なときに SoloHQ Drive フォルダを作成し、プロジェクト名の Google ドキュメントを更新します。",
    demo_title: "ライブデモを試す",
    demo_sub: "ブラウザでそのままダッシュボードを開けます。インストール不要でプロジェクト作成、メモ、JSONバックアップが可能。",
    demo_btn: "デモを開く",
    footer_note: "SoloHQ · 一人会社向けオープンソースダッシュボード"
  },
  ko: {
    page_title: "SoloHQ · 1인 기업용 로컬 우선 대시보드",
    page_desc: "SoloHQ는 1인 기업을 위한 로컬 우선 대시보드입니다. 프로젝트, 워크스페이스 메모, 북마크, 검색, 수익을 하나의 브라우저 앱에서 관리하세요.",
    crumb: "SoloHQ",
    hero_badge: "오픈소스 · 로컬 우선 · MIT",
    hero_title: "1인 기업을 위한 하나의 대시보드.",
    hero_lead: "프로젝트, 워크스페이스 메모, 북마크, 검색, 수익을 로컬 우선 대시보드 하나로 관리하세요. 백엔드도 계정도 락인도 없습니다.",
    hero_cta: "라이브 데모",
    hero_cta2: "소스 보기",
    hero_trust: "무료 · 오픈소스 · 데이터는 브라우저에",
    window_title: "SoloHQ · 로컬 우선 대시보드",
    features_title: "1인 창업가에게 필요한 모든 것을 한 화면에서",
    features_sub: "프로젝트 보드 · 메모 · 북마크 · 검색 · 수익",
    f1t: "프로젝트 보드",
    f1d: "개발 중, 출시, 수익화, 중단 프로젝트를 진행률로 관리합니다.",
    f2t: "워크스페이스 메모",
    f2d: "프로젝트마다 개발 로그, 마일스톤, 아이디어를 기록합니다.",
    f3t: "북마크와 검색",
    f3d: "AI, 미디어, 개발 링크를 정리하고 Google, Bing, GitHub 등에서 검색합니다.",
    f4t: "수익 추적",
    f4d: "통계 모드에서 MRR과 프로젝트 상태를 한눈에 확인합니다.",
    f5t: "4가지 테마",
    f5d: "라이트, 다크, 글라스, 해커 테마와 드래그로 위젯 정렬.",
    f6t: "Google Docs 프로젝트 노트",
    f6d: "필요할 때 SoloHQ Drive 폴더를 만들고 프로젝트 이름의 Google 문서를 계속 업데이트합니다.",
    demo_title: "라이브 데모 사용해 보기",
    demo_sub: "브라우저에서 바로 대시보드를 열어보세요. 설치 없이 프로젝트 생성, 메모 작성, JSON 백업이 가능합니다.",
    demo_btn: "데모 열기",
    footer_note: "SoloHQ · 1인 기업용 오픈소스 대시보드"
  },
  es: {
    page_title: "SoloHQ · Panel local-first para empresas de una persona",
    page_desc: "SoloHQ es un panel local-first para empresas de una sola persona. Gestiona proyectos, notas, marcadores, búsquedas e ingresos en una sola app de navegador.",
    crumb: "SoloHQ",
    hero_badge: "Código abierto · Local-first · MIT",
    hero_title: "Un solo panel para tu empresa de una persona.",
    hero_lead: "Gestiona proyectos, notas de trabajo, marcadores, búsquedas e ingresos en un panel local-first. Sin backend, sin cuenta, sin bloqueo.",
    hero_cta: "Probar Demo",
    hero_cta2: "Ver código",
    hero_trust: "Gratis · Código abierto · Tus datos quedan en el navegador",
    window_title: "SoloHQ · Panel local-first",
    features_title: "Todo lo que necesita un fundador en solitario, en una pantalla",
    features_sub: "Tablero de proyectos · notas · marcadores · búsqueda · ingresos",
    f1t: "Tablero de proyectos",
    f1d: "Sigue proyectos en desarrollo, lanzados, con ingresos o abandonados con barras de progreso.",
    f2t: "Nota de trabajo",
    f2d: "Mantén un registro de desarrollo, hitos e ideas junto a cada proyecto.",
    f3t: "Marcadores y búsqueda",
    f3d: "Organiza enlaces de IA, medios y desarrollo, y busca en Google, Bing, GitHub y más.",
    f4t: "Seguimiento de ingresos",
    f4d: "Consulta MRR y estado del proyecto de un vistazo con el modo estadísticas.",
    f5t: "Cuatro temas",
    f5d: "Temas claro, oscuro, cristal y hacker con widgets que se reordenan arrastrando.",
    f6t: "Notas de proyecto en Google Docs",
    f6d: "Cuando lo necesitas, crea una carpeta SoloHQ en Drive y actualiza un documento con el nombre del proyecto.",
    demo_title: "Prueba la demo",
    demo_sub: "Abre el panel directamente en tu navegador. Crea proyectos, escribe notas y exporta una copia JSON sin instalar nada.",
    demo_btn: "Abrir Demo",
    footer_note: "SoloHQ · Panel de código abierto para empresas de una persona"
  },
  fr: {
    page_title: "SoloHQ · Tableau de bord local-first pour entreprises individuelles",
    page_desc: "SoloHQ est un tableau de bord local-first pour les entreprises individuelles. Gérez projets, notes, favoris, recherches et revenus dans une seule application.",
    crumb: "SoloHQ",
    hero_badge: "Open source · Local-first · MIT",
    hero_title: "Un tableau de bord pour votre entreprise individuelle.",
    hero_lead: "Gérez projets, notes, favoris, recherches et revenus dans un tableau de bord local-first. Pas de backend, pas de compte, pas d'engagement.",
    hero_cta: "Essayer la démo",
    hero_cta2: "Voir le code",
    hero_trust: "Gratuit · Open source · Vos données restent dans le navigateur",
    window_title: "SoloHQ · Tableau de bord local-first",
    features_title: "Tout ce dont un solo-entrepreneur a besoin, sur un seul écran",
    features_sub: "Projets · notes · favoris · recherche · revenus",
    f1t: "Tableau de projets",
    f1d: "Suivez les projets en développement, lancés, rentables ou abandonnés avec des barres de progression.",
    f2t: "Note de travail",
    f2d: "Gardez un journal de développement, des jalons et des idées pour chaque projet.",
    f3t: "Favoris et recherche",
    f3d: "Organisez les liens IA, médias et dev, puis cherchez sur Google, Bing, GitHub, etc.",
    f4t: "Suivi des revenus",
    f4d: "Consultez MRR et statut des projets en un coup d'œil avec le mode statistiques.",
    f5t: "Quatre thèmes",
    f5d: "Thèmes clair, sombre, verre et hacker, widgets réorganisables par glisser-déposer.",
    f6t: "Notes de projet Google Docs",
    f6d: "À la demande, crée un dossier SoloHQ dans Drive et met à jour un document au nom du projet.",
    demo_title: "Essayer la démo en direct",
    demo_sub: "Ouvrez le tableau de bord dans votre navigateur. Créez des projets, écrivez des notes et exportez une sauvegarde JSON sans rien installer.",
    demo_btn: "Ouvrir la démo",
    footer_note: "SoloHQ · Tableau de bord open source pour entreprises individuelles"
  },
  de: {
    page_title: "SoloHQ · Lokales Dashboard für Ein-Personen-Unternehmen",
    page_desc: "SoloHQ ist ein lokales Dashboard für Ein-Personen-Unternehmen. Verwalte Projekte, Notizen, Lesezeichen, Suche und Umsatz in einer Browser-App.",
    crumb: "SoloHQ",
    hero_badge: "Open Source · Lokal zuerst · MIT",
    hero_title: "Ein Dashboard für dein Ein-Personen-Unternehmen.",
    hero_lead: "Verwalte Projekte, Workspace-Notizen, Lesezeichen, Suche und Umsatz in einem lokalen Dashboard. Kein Backend, kein Konto, kein Lock-in.",
    hero_cta: "Live-Demo",
    hero_cta2: "Quellcode",
    hero_trust: "Kostenlos · Open Source · Daten bleiben im Browser",
    window_title: "SoloHQ · Lokales Dashboard",
    features_title: "Alles, was Solo-Gründer brauchen, auf einem Bildschirm",
    features_sub: "Projektboard · Notizen · Lesezeichen · Suche · Umsatz",
    f1t: "Projektboard",
    f1d: "Verfolge Projekte in Entwicklung, veröffentlicht, umsatzstark oder aufgegeben mit Fortschrittsbalken.",
    f2t: "Workspace-Notiz",
    f2d: "Halte Entwicklungslog, Meilensteine und Ideen direkt beim Projekt fest.",
    f3t: "Lesezeichen & Suche",
    f3d: "Organisiere KI-, Medien- und Dev-Links und suche bei Google, Bing, GitHub und mehr.",
    f4t: "Umsatz-Tracking",
    f4d: "Sieh MRR und Projektstatus auf einen Blick im Statistikmodus.",
    f5t: "Vier Themes",
    f5d: "Hell, dunkel, Glas und Hacker sowie per Drag-and-Drop anordenbare Widgets.",
    f6t: "Google-Docs-Projektnotizen",
    f6d: "Erstellt bei Bedarf einen SoloHQ-Drive-Ordner und aktualisiert ein Google-Dokument mit Projektname.",
    demo_title: "Live-Demo testen",
    demo_sub: "Öffne das Dashboard direkt im Browser. Erstelle Projekte, schreibe Notizen und exportiere ein JSON-Backup ohne Installation.",
    demo_btn: "Demo öffnen",
    footer_note: "SoloHQ · Open-Source-Dashboard für Ein-Personen-Unternehmen"
  },
  ru: {
    page_title: "SoloHQ · Локальная панель для компаний из одного человека",
    page_desc: "SoloHQ — локальная панель для компаний из одного человека. Управляйте проектами, заметками, закладками, поиском и доходом в одном приложении.",
    crumb: "SoloHQ",
    hero_badge: "Открытый код · Локально · MIT",
    hero_title: "Одна панель для вашей компании из одного человека.",
    hero_lead: "Проекты, заметки, закладки, поиск и доход — в одной локальной панели. Без бэкенда, без аккаунта, без привязки.",
    hero_cta: "Открыть демо",
    hero_cta2: "Исходный код",
    hero_trust: "Бесплатно · Открытый код · Данные остаются в браузере",
    window_title: "SoloHQ · Локальная панель",
    features_title: "Всё для соло-основателя на одном экране",
    features_sub: "Проекты · заметки · закладки · поиск · доход",
    f1t: "Доска проектов",
    f1d: "Отслеживайте проекты в разработке, запущенные, приносящие доход и заброшенные.",
    f2t: "Заметки рабочего пространства",
    f2d: "Ведите журнал разработки, вехи и идеи рядом с проектом.",
    f3t: "Закладки и поиск",
    f3d: "Организуйте ссылки и ищите в Google, Bing, GitHub и других сервисах.",
    f4t: "Отслеживание дохода",
    f4d: "Просматривайте MRR и статус проектов в режиме статистики.",
    f5t: "Четыре темы",
    f5d: "Светлая, тёмная, стеклянная и хакерская темы, виджеты можно переставлять.",
    f6t: "Заметки проекта в Google Docs",
    f6d: "По запросу создаёт папку SoloHQ на Диске и обновляет документ Google с названием проекта.",
    demo_title: "Попробуйте живую демо",
    demo_sub: "Откройте панель прямо в браузере. Создавайте проекты, пишите заметки и экспортируйте JSON без установки.",
    demo_btn: "Открыть демо",
    footer_note: "SoloHQ · Открытая панель для компаний из одного человека"
  },
  pt: {
    page_title: "SoloHQ · Painel local-first para empresas de uma pessoa",
    page_desc: "SoloHQ é um painel local-first para empresas de uma pessoa. Gerencie projetos, notas, favoritos, pesquisas e receita em um só app.",
    crumb: "SoloHQ",
    hero_badge: "Código aberto · Local-first · MIT",
    hero_title: "Um painel para sua empresa de uma pessoa.",
    hero_lead: "Gerencie projetos, notas de trabalho, favoritos, pesquisas e receita em um painel local-first. Sem backend, sem conta, sem bloqueio.",
    hero_cta: "Testar Demo",
    hero_cta2: "Ver código",
    hero_trust: "Grátis · Código aberto · Seus dados ficam no navegador",
    window_title: "SoloHQ · Painel local-first",
    features_title: "Tudo o que um fundador solo precisa em uma tela",
    features_sub: "Quadro de projetos · notas · favoritos · pesquisa · receita",
    f1t: "Quadro de projetos",
    f1d: "Acompanhe projetos em desenvolvimento, lançados, com receita ou abandonados com barras de progresso.",
    f2t: "Nota de trabalho",
    f2d: "Mantenha um registro de desenvolvimento, marcos e ideias junto ao projeto.",
    f3t: "Favoritos e pesquisa",
    f3d: "Organize links de IA, mídia e dev, e pesquise no Google, Bing, GitHub e outros.",
    f4t: "Acompanhamento de receita",
    f4d: "Veja MRR e status dos projetos rapidamente no modo estatísticas.",
    f5t: "Quatro temas",
    f5d: "Temas claro, escuro, vidro e hacker com widgets reorganizáveis por arrastar.",
    f6t: "Notas de projeto no Google Docs",
    f6d: "Sob demanda, cria uma pasta SoloHQ no Drive e atualiza um documento com o nome do projeto.",
    demo_title: "Experimente a demo ao vivo",
    demo_sub: "Abra o painel direto no navegador. Crie projetos, escreva notas e exporte um backup JSON sem instalar nada.",
    demo_btn: "Abrir Demo",
    footer_note: "SoloHQ · Painel de código aberto para empresas de uma pessoa"
  }
};

function currentLang() {
  return localStorage.getItem("agentsbin-lang") || "en";
}

function applyLang(lang) {
  const dict = STRINGS[lang] || STRINGS.en;
  const htmlLangs = {
    en: "en", zh: "zh-CN", "zh-Hant": "zh-TW", ja: "ja", ko: "ko",
    es: "es", fr: "fr", de: "de", ru: "ru", pt: "pt"
  };
  document.documentElement.lang = htmlLangs[lang] || "en";
  const title = document.getElementById("pageTitle");
  const desc = document.getElementById("pageDesc");
  if (title) title.textContent = dict.page_title;
  if (desc) desc.setAttribute("content", dict.page_desc);
  document.querySelectorAll("[data-i18n]").forEach(function (el) {
    const key = el.getAttribute("data-i18n");
    if (dict[key]) el.textContent = dict[key];
  });
  const select = document.getElementById("langSelect");
  if (select) select.value = lang;
}

function track(kind, extra) {
  if (location.protocol !== "https:" && location.protocol !== "http:") return;
  const payload = JSON.stringify(Object.assign({
    kind: kind,
    name: "solohq",
    version: SOLOHQ_VERSION,
    source: "web",
    product: "solohq"
  }, extra || {}));
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
}

document.addEventListener("DOMContentLoaded", function () {
  const select = document.getElementById("langSelect");
  const lang = currentLang();
  if (select) {
    select.value = lang;
    select.addEventListener("change", function () {
      localStorage.setItem("agentsbin-lang", select.value);
      localStorage.setItem("solohq_lang", select.value);
      applyLang(select.value);
    });
  }
  applyLang(lang);
  track("page_view");
  document.querySelectorAll("a[href^='/solohq/demo/']").forEach(function (el) {
    el.addEventListener("click", function () {
      track("demo_open", { name: "solohq_demo" });
    });
  });
});
