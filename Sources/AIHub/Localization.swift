import Combine
import Foundation

enum AppLanguage: String, CaseIterable {
    case zh = "zh"
    case zhHant = "zh-Hant"
    case en = "en"
    case ja = "ja"
    case ko = "ko"
    case es = "es"
    case fr = "fr"
    case de = "de"
    case ru = "ru"
    case pt = "pt"

    var displayName: String {
        switch self {
        case .zh: return "简体中文"
        case .zhHant: return "繁體中文"
        case .en: return "English"
        case .ja: return "日本語"
        case .ko: return "한국어"
        case .es: return "Español"
        case .fr: return "Français"
        case .de: return "Deutsch"
        case .ru: return "Русский"
        case .pt: return "Português"
        }
    }
}

final class LocalizedStore: ObservableObject {
    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "aihome.language")
        }
    }

    init() {
        let raw = UserDefaults.standard.string(forKey: "aihome.language")
        language = raw.flatMap(AppLanguage.init(rawValue:)) ?? .zh
    }

    func text(_ key: String) -> String {
        if let langs = Self.table[key], let value = langs[language] {
            return value
        }
        if let langs = Self.table[key], let value = langs[.en] {
            return value
        }
        return key
    }

    func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), arguments: arguments)
    }

    func agentName(_ name: String) -> String {
        let table: [String: [AppLanguage: String]] = [
            "豆包": [.zh: "豆包", .zhHant: "豆包", .en: "Doubao", .ja: "豆包", .ko: "두바오", .es: "Doubao", .fr: "Doubao", .de: "Doubao", .ru: "Doubao", .pt: "Doubao"],
            "千问": [.zh: "千问", .zhHant: "千問", .en: "Qwen", .ja: "千問", .ko: "큐원", .es: "Qwen", .fr: "Qwen", .de: "Qwen", .ru: "Qwen", .pt: "Qwen"],
            "腾讯元宝": [.zh: "腾讯元宝", .zhHant: "騰訊元寶", .en: "Tencent Yuanbao", .ja: "テンセント元宝", .ko: "텐센트 위안바오", .es: "Tencent Yuanbao", .fr: "Tencent Yuanbao", .de: "Tencent Yuanbao", .ru: "Tencent Yuanbao", .pt: "Tencent Yuanbao"],
            "通义": [.zh: "通义", .zhHant: "通義", .en: "Tongyi", .ja: "通義", .ko: "통이", .es: "Tongyi", .fr: "Tongyi", .de: "Tongyi", .ru: "Tongyi", .pt: "Tongyi"],
            "Kimi": [.zh: "Kimi", .zhHant: "Kimi", .en: "Kimi", .ja: "Kimi", .ko: "Kimi", .es: "Kimi", .fr: "Kimi", .de: "Kimi", .ru: "Kimi", .pt: "Kimi"],
            "ChatGPT": [.zh: "ChatGPT", .zhHant: "ChatGPT", .en: "ChatGPT", .ja: "ChatGPT", .ko: "ChatGPT", .es: "ChatGPT", .fr: "ChatGPT", .de: "ChatGPT", .ru: "ChatGPT", .pt: "ChatGPT"],
            "Claude": [.zh: "Claude", .zhHant: "Claude", .en: "Claude", .ja: "Claude", .ko: "Claude", .es: "Claude", .fr: "Claude", .de: "Claude", .ru: "Claude", .pt: "Claude"],
            "Gemini": [.zh: "Gemini", .zhHant: "Gemini", .en: "Gemini", .ja: "Gemini", .ko: "Gemini", .es: "Gemini", .fr: "Gemini", .de: "Gemini", .ru: "Gemini", .pt: "Gemini"],
            "DeepSeek": [.zh: "DeepSeek", .zhHant: "DeepSeek", .en: "DeepSeek", .ja: "DeepSeek", .ko: "DeepSeek", .es: "DeepSeek", .fr: "DeepSeek", .de: "DeepSeek", .ru: "DeepSeek", .pt: "DeepSeek"]
        ]
        return table[name]?[language] ?? table[name]?[.en] ?? name
    }

    private static let table: [String: [AppLanguage: String]] = [
        "selected_agents": [
            .zh: "已选 %d 个智能体",
            .zhHant: "已選 %d 個智能體",
            .en: "Selected %d agents",
            .ja: "選択済み %d エージェント",
            .ko: "선택된 에이전트 %d개",
            .es: "%d agentes seleccionados",
            .fr: "%d agents sélectionnés",
            .de: "%d Agenten ausgewählt",
            .ru: "Выбрано агентов: %d",
            .pt: "%d agentes selecionados"
        ],
        "agents_tab": [
            .zh: "智能体", .zhHant: "智能體", .en: "Agents", .ja: "エージェント", .ko: "에이전트",
            .es: "Agentes", .fr: "Agents", .de: "Agenten", .ru: "Агенты", .pt: "Agentes"
        ],
        "notes_tab": [
            .zh: "知识库", .zhHant: "知識庫", .en: "Notes", .ja: "知識", .ko: "지식",
            .es: "Notas", .fr: "Notes", .de: "Notizen", .ru: "Заметки", .pt: "Notas"
        ],
        "manage_agents": [
            .zh: "管理智能体", .zhHant: "管理智能體", .en: "Manage agents", .ja: "エージェント管理", .ko: "에이전트 관리",
            .es: "Gestionar agentes", .fr: "Gérer les agents", .de: "Agenten verwalten", .ru: "Управление агентами", .pt: "Gerenciar agentes"
        ],
        "search_notes": [
            .zh: "搜索笔记", .zhHant: "搜尋筆記", .en: "Search notes", .ja: "ノートを検索", .ko: "노트 검색",
            .es: "Buscar notas", .fr: "Rechercher des notes", .de: "Notizen suchen", .ru: "Поиск заметок", .pt: "Pesquisar notas"
        ],
        "notes_count": [
            .zh: "%d 条笔记", .zhHant: "%d 則筆記", .en: "%d notes", .ja: "%d 件のノート", .ko: "노트 %d개",
            .es: "%d notas", .fr: "%d notes", .de: "%d Notizen", .ru: "%d заметок", .pt: "%d notas"
        ],
        "input_placeholder": [
            .zh: "输入问题，发给所选智能体", .zhHant: "輸入問題，發給所選智能體", .en: "Ask the selected agents",
            .ja: "選択したエージェントに質問", .ko: "선택한 에이전트에게 질문",
            .es: "Pregunta a los agentes", .fr: "Questionnez les agents",
            .de: "Frage an Agenten senden", .ru: "Вопрос выбранным агентам", .pt: "Pergunte aos agentes"
        ],
        "save_note": [
            .zh: "存为笔记", .zhHant: "儲存筆記", .en: "Save note", .ja: "ノートに保存", .ko: "노트로 저장",
            .es: "Guardar nota", .fr: "Enregistrer la note", .de: "Notiz speichern", .ru: "Сохранить заметку", .pt: "Salvar nota"
        ],
        "send_all": [
            .zh: "同问 %d 个智能体", .zhHant: "同問 %d 個智能體", .en: "Ask %d agents", .ja: "%d 個のエージェントに質問", .ko: "에이전트 %d개에 질문",
            .es: "Preguntar a %d agentes", .fr: "Questionner %d agents", .de: "%d Agenten fragen", .ru: "Спросить %d агентов", .pt: "Perguntar a %d agentes"
        ],
        "send": [
            .zh: "发送", .zhHant: "傳送", .en: "Send", .ja: "送信", .ko: "보내기",
            .es: "Enviar", .fr: "Envoyer", .de: "Senden", .ru: "Отправить", .pt: "Enviar"
        ],
        "browser": [
            .zh: "打开浏览器", .zhHant: "開啟瀏覽器", .en: "Open Browser", .ja: "ブラウザを開く", .ko: "브라우저 열기",
            .es: "Navegador", .fr: "Navigateur", .de: "Browser", .ru: "Браузер", .pt: "Navegador"
        ],
        "desktop": [
            .zh: "桌面版", .zhHant: "桌面版", .en: "Desktop", .ja: "デスクトップ版", .ko: "데스크톱",
            .es: "Escritorio", .fr: "Bureau", .de: "Desktop", .ru: "Десктоп", .pt: "Desktop"
        ],
        "official": [
            .zh: "官网", .zhHant: "官網", .en: "Official", .ja: "公式サイト", .ko: "공식 사이트",
            .es: "Sitio oficial", .fr: "Site officiel", .de: "Offizielle Website", .ru: "Официальный сайт", .pt: "Site oficial"
        ],
        "status_answered": [
            .zh: "已回复", .zhHant: "已回覆", .en: "Answered", .ja: "返信済み", .ko: "답변 완료",
            .es: "Respondido", .fr: "Répondu", .de: "Beantwortet", .ru: "Отвечено", .pt: "Respondido"
        ],
        "status_sent": [
            .zh: "已发送", .zhHant: "已傳送", .en: "Sent", .ja: "送信済み", .ko: "전송됨",
            .es: "Enviado", .fr: "Envoyé", .de: "Gesendet", .ru: "Отправлено", .pt: "Enviado"
        ],
        "status_sending": [
            .zh: "发送中", .zhHant: "傳送中", .en: "Sending", .ja: "送信中", .ko: "전송 중",
            .es: "Enviando", .fr: "Envoi", .de: "Wird gesendet", .ru: "Отправка", .pt: "Enviando"
        ],
        "status_no_input": [
            .zh: "未找到输入框", .zhHant: "找不到輸入框", .en: "Input not found", .ja: "入力欄が見つかりません", .ko: "입력란을 찾을 수 없음",
            .es: "Entrada no encontrada", .fr: "Champ introuvable", .de: "Eingabefeld nicht gefunden", .ru: "Поле ввода не найдено", .pt: "Campo não encontrado"
        ],
        "status_idle": [
            .zh: "待发送", .zhHant: "待傳送", .en: "Ready", .ja: "送信待ち", .ko: "전송 대기",
            .es: "Listo", .fr: "Prêt", .de: "Bereit", .ru: "Готово", .pt: "Pronto"
        ],
        "status_generating": [
            .zh: "生成中", .zhHant: "生成中", .en: "Generating", .ja: "生成中", .ko: "생성 중",
            .es: "Generando", .fr: "Génération", .de: "Wird generiert", .ru: "Генерация", .pt: "Gerando"
        ],
        "manage_title": [
            .zh: "智能体管理", .zhHant: "智能體管理", .en: "Agent Management", .ja: "エージェント管理", .ko: "에이전트 관리",
            .es: "Gestión de agentes", .fr: "Gestion des agents", .de: "Agentenverwaltung", .ru: "Управление агентами", .pt: "Gerenciamento de agentes"
        ],
        "add_agent": [
            .zh: "添加智能体", .zhHant: "新增智能體", .en: "Add Agent", .ja: "エージェントを追加", .ko: "에이전트 추가",
            .es: "Añadir agente", .fr: "Ajouter un agent", .de: "Agent hinzufügen", .ru: "Добавить агента", .pt: "Adicionar agente"
        ],
        "name": [
            .zh: "名称", .zhHant: "名稱", .en: "Name", .ja: "名前", .ko: "이름",
            .es: "Nombre", .fr: "Nom", .de: "Name", .ru: "Имя", .pt: "Nome"
        ],
        "web_url": [
            .zh: "网页地址", .zhHant: "網頁地址", .en: "URL", .ja: "URL", .ko: "URL",
            .es: "URL", .fr: "URL", .de: "URL", .ru: "URL", .pt: "URL"
        ],
        "save": [
            .zh: "保存", .zhHant: "儲存", .en: "Save", .ja: "保存", .ko: "저장",
            .es: "Guardar", .fr: "Enregistrer", .de: "Speichern", .ru: "Сохранить", .pt: "Salvar"
        ],
        "cancel": [
            .zh: "取消", .zhHant: "取消", .en: "Cancel", .ja: "キャンセル", .ko: "취소",
            .es: "Cancelar", .fr: "Annuler", .de: "Abbrechen", .ru: "Отмена", .pt: "Cancelar"
        ],
        "show": [
            .zh: "显示", .zhHant: "顯示", .en: "Show", .ja: "表示", .ko: "표시",
            .es: "Mostrar", .fr: "Afficher", .de: "Anzeigen", .ru: "Показать", .pt: "Mostrar"
        ],
        "hide": [
            .zh: "隐藏", .zhHant: "隱藏", .en: "Hide", .ja: "非表示", .ko: "숨기기",
            .es: "Ocultar", .fr: "Masquer", .de: "Ausblenden", .ru: "Скрыть", .pt: "Ocultar"
        ],
        "pin": [
            .zh: "置顶", .zhHant: "置頂", .en: "Pin", .ja: "ピン留め", .ko: "고정",
            .es: "Fijar", .fr: "Épingler", .de: "Anheften", .ru: "Закрепить", .pt: "Fixar"
        ],
        "edit": [
            .zh: "编辑", .zhHant: "編輯", .en: "Edit", .ja: "編集", .ko: "편집",
            .es: "Editar", .fr: "Modifier", .de: "Bearbeiten", .ru: "Редактировать", .pt: "Editar"
        ],
        "delete": [
            .zh: "删除", .zhHant: "刪除", .en: "Delete", .ja: "削除", .ko: "삭제",
            .es: "Eliminar", .fr: "Supprimer", .de: "Löschen", .ru: "Удалить", .pt: "Excluir"
        ],
        "note_summary": [
            .zh: "总结", .zhHant: "總結", .en: "Summary", .ja: "要約", .ko: "요약",
            .es: "Resumen", .fr: "Résumé", .de: "Zusammenfassung", .ru: "Итог", .pt: "Resumo"
        ],
        "note_excerpt": [
            .zh: "原文摘录", .zhHant: "原文摘錄", .en: "Excerpt", .ja: "原文抜粋", .ko: "원문 발췌",
            .es: "Extracto original", .fr: "Extrait original", .de: "Originalauszug", .ru: "Оригинал", .pt: "Trecho original"
        ],
        "note_source": [
            .zh: "来源：%@", .zhHant: "來源：%@", .en: "Source: %@", .ja: "出典：%@", .ko: "출처: %@",
            .es: "Fuente: %@", .fr: "Source : %@", .de: "Quelle: %@", .ru: "Источник: %@", .pt: "Fonte: %@"
        ],
        "copy": [
            .zh: "复制", .zhHant: "複製", .en: "Copy", .ja: "コピー", .ko: "복사",
            .es: "Copiar", .fr: "Copier", .de: "Kopieren", .ru: "Копировать", .pt: "Copiar"
        ],
        "back_chat": [
            .zh: "返回对话", .zhHant: "返回對話", .en: "Back to chat", .ja: "チャットに戻る", .ko: "채팅으로 돌아가기",
            .es: "Volver al chat", .fr: "Retour au chat", .de: "Zurück zum Chat", .ru: "Назад к чату", .pt: "Voltar ao chat"
        ],
        "settings": [
            .zh: "设置", .zhHant: "設定", .en: "Settings", .ja: "設定", .ko: "설정",
            .es: "Ajustes", .fr: "Paramètres", .de: "Einstellungen", .ru: "Настройки", .pt: "Configurações"
        ],
        "mode_chat": [
            .zh: "聊天模式", .zhHant: "聊天模式", .en: "Chat", .ja: "チャットモード", .ko: "채팅 모드",
            .es: "Modo chat", .fr: "Mode chat", .de: "Chat-Modus", .ru: "Режим чата", .pt: "Modo chat"
        ],
        "mode_browser": [
            .zh: "浏览器模式", .zhHant: "瀏覽器模式", .en: "Browser", .ja: "ブラウザモード", .ko: "브라우저 모드",
            .es: "Modo navegador", .fr: "Mode navigateur", .de: "Browser-Modus", .ru: "Режим браузера", .pt: "Modo navegador"
        ],
        "start_chat": [
            .zh: "开始对话", .zhHant: "開始對話", .en: "Start chatting", .ja: "会話を始める", .ko: "대화 시작",
            .es: "Iniciar conversación", .fr: "Commencer la discussion", .de: "Chat starten", .ru: "Начать чат", .pt: "Iniciar conversa"
        ],
        "daily_summary": [
            .zh: "当天归纳总结", .zhHant: "當天歸納總結", .en: "Daily Summary", .ja: "当日サマリー", .ko: "당일 요약",
            .es: "Resumen del día", .fr: "Résumé du jour", .de: "Tageszusammenfassung", .ru: "Итог дня", .pt: "Resumo do dia"
        ],
        "no_content": [
            .zh: "暂无内容", .zhHant: "暫無內容", .en: "No content", .ja: "コンテンツがありません", .ko: "콘텐츠 없음",
            .es: "Sin contenido", .fr: "Aucun contenu", .de: "Kein Inhalt", .ru: "Нет содержимого", .pt: "Sem conteúdo"
        ],
        "light_mode": [
            .zh: "切换到浅色模式", .zhHant: "切換到淺色模式", .en: "Switch to light mode", .ja: "ライトモードに切り替え", .ko: "라이트 모드로 전환",
            .es: "Cambiar a modo claro", .fr: "Passer en mode clair", .de: "Zum hellen Modus wechseln", .ru: "Переключить на светлый режим", .pt: "Mudar para modo claro"
        ],
        "dark_mode": [
            .zh: "切换到深色模式", .zhHant: "切換到深色模式", .en: "Switch to dark mode", .ja: "ダークモードに切り替え", .ko: "다크 모드로 전환",
            .es: "Cambiar a modo oscuro", .fr: "Passer en mode sombre", .de: "Zum dunklen Modus wechseln", .ru: "Переключить на тёмный режим", .pt: "Mudar para modo escuro"
        ],
        "add_knowledge": [
            .zh: "收藏", .zhHant: "收藏", .en: "Save",
            .ja: "保存", .ko: "저장", .es: "Guardar",
            .fr: "Enregistrer", .de: "Speichern",
            .ru: "Сохранить", .pt: "Salvar"
        ],
        "import_agents": [
            .zh: "导入", .zhHant: "匯入", .en: "Import", .ja: "インポート", .ko: "가져오기",
            .es: "Importar", .fr: "Importer", .de: "Importieren", .ru: "Импорт", .pt: "Importar"
        ],
        "export_agents": [
            .zh: "导出", .zhHant: "匯出", .en: "Export", .ja: "エクスポート", .ko: "내보내기",
            .es: "Exportar", .fr: "Exporter", .de: "Exportieren", .ru: "Экспорт", .pt: "Exportar"
        ],
        "import_title": [
            .zh: "导入结果", .zhHant: "匯入結果", .en: "Import Result", .ja: "インポート結果", .ko: "가져오기 결과",
            .es: "Resultado de importación", .fr: "Résultat de l'import", .de: "Importergebnis",
            .ru: "Результат импорта", .pt: "Resultado da importação"
        ],
        "export_title": [
            .zh: "导出智能体", .zhHant: "匯出智能體", .en: "Export Agents", .ja: "エージェントをエクスポート",
            .ko: "에이전트 내보내기", .es: "Exportar agentes", .fr: "Exporter les agents",
            .de: "Agenten exportieren", .ru: "Экспорт агентов", .pt: "Exportar agentes"
        ],
        "import_result_format": [
            .zh: "已导入 %d 个智能体", .zhHant: "已匯入 %d 個智能體", .en: "Imported %d agents",
            .ja: "%d 件のエージェントをインポートしました", .ko: "에이전트 %d개를 가져왔습니다",
            .es: "Se importaron %d agentes", .fr: "%d agents importés", .de: "%d Agenten importiert",
            .ru: "Импортировано агентов: %d", .pt: "%d agentes importados"
        ],
        "import_errors_format": [
            .zh: "导入 %d 个；需修改行：", .zhHant: "匯入 %d 個；需修改行：", .en: "Imported %d; fix lines:",
            .ja: "%d 件インポート。修正行：", .ko: "%d개 가져옴. 수정 줄:",
            .es: "%d importados; corregir líneas:", .fr: "%d importés; corriger lignes :",
            .de: "%d importiert; Zeilen korrigieren:", .ru: "Импорт %d; исправьте строки:",
            .pt: "%d importados; corrija linhas:"
        ],
        "ok": [
            .zh: "好", .zhHant: "好", .en: "OK", .ja: "OK", .ko: "확인",
            .es: "Aceptar", .fr: "OK", .de: "OK", .ru: "ОК", .pt: "OK"
        ],
        "open_app": [
            .zh: "打开 AgentsBin", .zhHant: "開啟 AgentsBin", .en: "Open AgentsBin", .ja: "AgentsBin を開く",
            .ko: "AgentsBin 열기", .es: "Abrir AgentsBin", .fr: "Ouvrir AgentsBin", .de: "AgentsBin öffnen",
            .ru: "Открыть AgentsBin", .pt: "Abrir AgentsBin"
        ],
        "quit": [
            .zh: "退出", .zhHant: "退出", .en: "Quit", .ja: "終了", .ko: "종료",
            .es: "Salir", .fr: "Quitter", .de: "Beenden", .ru: "Выйти", .pt: "Sair"
        ],
        "beta_note": [
            .zh: "免费内测版", .zhHant: "免費內測版", .en: "Free Beta", .ja: "無料ベータ",
            .ko: "무료 베타", .es: "Beta gratis", .fr: "Bêta gratuite", .de: "Kostenlose Beta",
            .ru: "Бесплатная бета", .pt: "Beta grátis"
        ],
        "hide_agents_hint": [
            .zh: "管理显示", .zhHant: "管理顯示", .en: "Manage visibility",
            .ja: "表示管理", .ko: "표시 관리", .es: "Gestionar visibilidad", .fr: "Gérer l'affichage",
            .de: "Sichtbarkeit verwalten", .ru: "Управление отображением", .pt: "Gerenciar exibição"
        ],
        "add_agents_hint": [
            .zh: "添加智能体", .zhHant: "新增智能體", .en: "Add agents",
            .ja: "エージェントを追加", .ko: "에이전트 추가", .es: "Añadir agentes", .fr: "Ajouter des agents",
            .de: "Agenten hinzufügen", .ru: "Добавить агентов", .pt: "Adicionar agentes"
        ],
        "agent_picker_title": [
            .zh: "显示智能体", .zhHant: "顯示智能體", .en: "Visible Agents",
            .ja: "表示エージェント", .ko: "표시 에이전트", .es: "Agentes visibles", .fr: "Agents visibles",
            .de: "Sichtbare Agenten", .ru: "Видимые агенты", .pt: "Agentes visíveis"
        ],
        "visible_agents": [
            .zh: "当前显示", .zhHant: "目前顯示", .en: "Currently shown",
            .ja: "現在表示中", .ko: "현재 표시", .es: "Mostrados ahora", .fr: "Affichés actuellement",
            .de: "Derzeit angezeigt", .ru: "Сейчас показаны", .pt: "Exibidos agora"
        ],
        "all_agents": [
            .zh: "全部智能体", .zhHant: "全部智能體", .en: "All agents",
            .ja: "全エージェント", .ko: "전체 에이전트", .es: "Todos los agentes", .fr: "Tous les agents",
            .de: "Alle Agenten", .ru: "Все агенты", .pt: "Todos os agentes"
        ],
        "custom_agent": [
            .zh: "自定义", .zhHant: "自訂", .en: "Custom",
            .ja: "カスタム", .ko: "사용자 지정", .es: "Personalizado", .fr: "Personnalisé",
            .de: "Benutzerdefiniert", .ru: "Пользовательский", .pt: "Personalizado"
        ],
        "done": [
            .zh: "完成", .zhHant: "完成", .en: "Done",
            .ja: "完了", .ko: "완료", .es: "Hecho", .fr: "Terminé",
            .de: "Fertig", .ru: "Готово", .pt: "Concluído"
        ],
        "api_settings": [
            .zh: "API 设置", .zhHant: "API 設定", .en: "API Settings",
            .ja: "API設定", .ko: "API 설정", .es: "Ajustes de API", .fr: "Paramètres API",
            .de: "API-Einstellungen", .ru: "Настройки API", .pt: "Configurações da API"
        ],
        "change_password": [
            .zh: "修改密码", .zhHant: "修改密碼", .en: "Change Password",
            .ja: "パスワード変更", .ko: "비밀번호 변경", .es: "Cambiar contraseña", .fr: "Changer le mot de passe",
            .de: "Passwort ändern", .ru: "Изменить пароль", .pt: "Alterar senha"
        ],
        "lock": [
            .zh: "锁定", .zhHant: "鎖定", .en: "Lock",
            .ja: "ロック", .ko: "잠금", .es: "Bloquear", .fr: "Verrouiller",
            .de: "Sperren", .ru: "Заблокировать", .pt: "Bloquear"
        ],
        "admin_setup_title": [
            .zh: "首次使用设置管理员", .zhHant: "首次使用設定管理員", .en: "Set up administrator",
            .ja: "初回：管理者を設定", .ko: "처음: 관리자 설정", .es: "Configurar administrador", .fr: "Configurer l'administrateur",
            .de: "Administrator einrichten", .ru: "Настройка администратора", .pt: "Configurar administrador"
        ],
        "admin_setup_desc": [
            .zh: "API Key 只会在验证管理员后显示和复制，并本地加密保存。", .zhHant: "API Key 只會在驗證管理員後顯示和複製，並本地加密儲存。", .en: "API keys are encrypted locally and only visible after admin verification.",
            .ja: "APIキーは管理者認証後にのみ表示・コピーでき、ローカルで暗号化保存されます。",
            .ko: "API 키는 관리자 인증 후에만 표시·복사되며 로컬 암호화 저장됩니다.",
            .es: "Las claves API se cifran localmente y solo se muestran tras verificar al administrador.",
            .fr: "Les clés API sont chiffrées localement et visibles après vérification.",
            .de: "API-Schlüssel werden lokal verschlüsselt und nur nach Prüfung angezeigt.",
            .ru: "Ключи API шифруются локально и видны только после проверки.",
            .pt: "Chaves API criptografadas localmente e visíveis após verificação."
        ],
        "admin_email": [
            .zh: "管理员邮箱", .zhHant: "管理員信箱", .en: "Admin Email",
            .ja: "管理者メール", .ko: "관리자 이메일", .es: "Correo del administrador", .fr: "E-mail administrateur",
            .de: "Admin-E-Mail", .ru: "Почта администратора", .pt: "E-mail do administrador"
        ],
        "admin_password": [
            .zh: "管理员密码", .zhHant: "管理員密碼", .en: "Admin Password",
            .ja: "管理者パスワード", .ko: "관리자 비밀번호", .es: "Contraseña de administrador", .fr: "Mot de passe administrateur",
            .de: "Admin-Passwort", .ru: "Пароль администратора", .pt: "Senha de administrador"
        ],
        "admin_confirm": [
            .zh: "确认密码", .zhHant: "確認密碼", .en: "Confirm Password",
            .ja: "パスワード確認", .ko: "비밀번호 확인", .es: "Confirmar contraseña", .fr: "Confirmer le mot de passe",
            .de: "Passwort bestätigen", .ru: "Подтверждение пароля", .pt: "Confirmar senha"
        ],
        "password_rule": [
            .zh: "密码至少 8 位，需包含字母、数字和符号。", .zhHant: "密碼至少 8 位，需包含字母、數字和符號。", .en: "At least 8 characters with letters, numbers and symbols.",
            .ja: "パスワードは8文字以上で、英字・数字・記号を含めてください。",
            .ko: "비밀번호는 8자 이상, 영문·숫자·기호 포함.",
            .es: "Mínimo 8 caracteres con letras, números y símbolos.",
            .fr: "8 caractères minimum avec lettres, chiffres et symboles.",
            .de: "Mindestens 8 Zeichen mit Buchstaben, Zahlen und Symbolen.",
            .ru: "Минимум 8 символов: буквы, цифры, символы.",
            .pt: "Mínimo 8 caracteres com letras, números e símbolos."
        ],
        "password_mismatch": [
            .zh: "两次密码不一致", .zhHant: "兩次密碼不一致", .en: "Passwords do not match",
            .ja: "パスワードが一致しません", .ko: "비밀번호가 일치하지 않습니다", .es: "Las contraseñas no coinciden",
            .fr: "Les mots de passe ne correspondent pas", .de: "Passwörter stimmen nicht überein",
            .ru: "Пароли не совпадают", .pt: "As senhas não coincidem"
        ],
        "admin_unlock_title": [
            .zh: "输入管理员密码", .zhHant: "輸入管理員密碼", .en: "Enter admin password",
            .ja: "管理者パスワードを入力", .ko: "관리자 비밀번호 입력", .es: "Introduzca la contraseña",
            .fr: "Saisissez le mot de passe", .de: "Admin-Passwort eingeben",
            .ru: "Введите пароль администратора", .pt: "Digite a senha"
        ],
        "locked_until": [
            .zh: "尝试次数过多，请 5 分钟后再试。", .zhHant: "嘗試次數過多，請 5 分鐘後再試。", .en: "Too many attempts. Try again in 5 minutes.",
            .ja: "試行回数が多すぎます。5分後にお試しください。",
            .ko: "시도 횟수가 너무 많습니다. 5분 후에 다시 시도하세요.",
            .es: "Demasiados intentos. Intente en 5 minutos.",
            .fr: "Trop de tentatives. Réessayez dans 5 minutes.",
            .de: "Zu viele Versuche. Versuchen Sie es in 5 Minuten erneut.",
            .ru: "Слишком много попыток. Попробуйте через 5 минут.",
            .pt: "Muitas tentativas. Tente novamente em 5 minutos."
        ],
        "unlock": [
            .zh: "解锁", .zhHant: "解鎖", .en: "Unlock",
            .ja: "ロック解除", .ko: "잠금 해제", .es: "Desbloquear", .fr: "Déverrouiller",
            .de: "Entsperren", .ru: "Разблокировать", .pt: "Desbloquear"
        ],
        "forgot_password": [
            .zh: "忘记密码？", .zhHant: "忘記密碼？", .en: "Forgot password?",
            .ja: "パスワードを忘れた？", .ko: "비밀번호를 잊으셨나요?", .es: "¿Olvidó su contraseña?",
            .fr: "Mot de passe oublié ?", .de: "Passwort vergessen?",
            .ru: "Забыли пароль?", .pt: "Esqueceu a senha?"
        ],
        "reset_code_shown": [
            .zh: "重置码：%@（30 分钟内有效，已通过邮件应用发送）", .zhHant: "重置碼：%@（30 分鐘內有效，已透過郵件應用傳送）", .en: "Reset code: %@ (valid for 30 minutes, sent via mail)",
            .ja: "リセットコード：%@（30分以内有効、メールで送信済み）",
            .ko: "재설정 코드: %@ (30분 유효, 메일로 전송됨)",
            .es: "Código: %@ (válido 30 min, enviado por correo)",
            .fr: "Code : %@ (valide 30 min, envoyé par e-mail)",
            .de: "Code: %@ (30 Min gültig, per E-Mail gesendet)",
            .ru: "Код: %@ (действует 30 мин, отправлен по почте)",
            .pt: "Código: %@ (válido 30 min, enviado por e-mail)"
        ],
        "copy_reset_code": [
            .zh: "复制重置码", .zhHant: "複製重置碼", .en: "Copy reset code",
            .ja: "リセットコードをコピー", .ko: "재설정 코드 복사", .es: "Copiar código de reinicio",
            .fr: "Copier le code de réinitialisation", .de: "Reset-Code kopieren",
            .ru: "Скопировать код сброса", .pt: "Copiar código de redefinição"
        ],
        "reset_code": [
            .zh: "重置码", .zhHant: "重置碼", .en: "Reset code",
            .ja: "リセットコード", .ko: "재설정 코드", .es: "Código de reinicio",
            .fr: "Code de réinitialisation", .de: "Reset-Code",
            .ru: "Код сброса", .pt: "Código de redefinição"
        ],
        "new_password": [
            .zh: "新密码", .zhHant: "新密碼", .en: "New password",
            .ja: "新しいパスワード", .ko: "새 비밀번호", .es: "Nueva contraseña",
            .fr: "Nouveau mot de passe", .de: "Neues Passwort",
            .ru: "Новый пароль", .pt: "Nova senha"
        ],
        "reset_password": [
            .zh: "重置密码", .zhHant: "重置密碼", .en: "Reset password",
            .ja: "パスワードをリセット", .ko: "비밀번호 재설정", .es: "Restablecer contraseña",
            .fr: "Réinitialiser le mot de passe", .de: "Passwort zurücksetzen",
            .ru: "Сбросить пароль", .pt: "Redefinir senha"
        ],
        "old_password": [
            .zh: "当前密码", .zhHant: "目前密碼", .en: "Current password",
            .ja: "現在のパスワード", .ko: "현재 비밀번호", .es: "Contraseña actual",
            .fr: "Mot de passe actuel", .de: "Aktuelles Passwort",
            .ru: "Текущий пароль", .pt: "Senha atual"
        ],
        "base_url": [
            .zh: "Base URL", .zhHant: "Base URL", .en: "Base URL",
            .ja: "Base URL", .ko: "Base URL", .es: "URL base", .fr: "URL de base",
            .de: "Basis-URL", .ru: "Базовый URL", .pt: "URL base"
        ],
        "model": [
            .zh: "模型", .zhHant: "模型", .en: "Model",
            .ja: "モデル", .ko: "모델", .es: "Modelo", .fr: "Modèle",
            .de: "Modell", .ru: "Модель", .pt: "Modelo"
        ],
        "api_key": [
            .zh: "API Key", .zhHant: "API Key", .en: "API Key",
            .ja: "API キー", .ko: "API 키", .es: "Clave API", .fr: "Clé API",
            .de: "API-Schlüssel", .ru: "API-ключ", .pt: "Chave da API"
        ],
        "copy_key": [
            .zh: "复制", .zhHant: "複製", .en: "Copy",
            .ja: "コピー", .ko: "복사", .es: "Copiar", .fr: "Copier",
            .de: "Kopieren", .ru: "Копировать", .pt: "Copiar"
        ],
        "delete_key": [
            .zh: "删除该 Key", .zhHant: "刪除該 Key", .en: "Delete key",
            .ja: "キーを削除", .ko: "키 삭제", .es: "Eliminar clave",
            .fr: "Supprimer la clé", .de: "Schlüssel löschen",
            .ru: "Удалить ключ", .pt: "Excluir chave"
        ],
        "cc_switch_imported": [
            .zh: "已自动导入 cc-switch 中的供应商（仅名称与地址，Key 需自行填写）", .zhHant: "已自動匯入 cc-switch 中的供應商（僅名稱與位址，Key 需自行填寫）", .en: "Imported providers from cc-switch (names only; keys stay private)",
            .ja: "cc-switch のプロバイダを自動インポートしました（名称とURLのみ、Keyは手入力）",
            .ko: "cc-switch 공급자를 자동 가져왔습니다 (이름/주소만, 키는 직접 입력)",
            .es: "Proveedores importados de cc-switch (solo nombres; claves privadas)",
            .fr: "Fournisseurs importés de cc-switch (noms uniquement)",
            .de: "cc-switch-Anbieter importiert (nur Namen)",
            .ru: "Импортированы провайдеры cc-switch (только имена)",
            .pt: "Provedores importados do cc-switch (apenas nomes)"
        ],
        "change_email": [
            .zh: "修改邮箱", .zhHant: "修改信箱", .en: "Change Email",
            .ja: "メール変更", .ko: "이메일 변경", .es: "Cambiar correo", .fr: "Changer l'e-mail",
            .de: "E-Mail ändern", .ru: "Изменить почту", .pt: "Alterar e-mail"
        ],
        "new_email": [
            .zh: "新邮箱", .zhHant: "新信箱", .en: "New Email",
            .ja: "新しいメール", .ko: "새 이메일", .es: "Nuevo correo", .fr: "Nouvel e-mail",
            .de: "Neue E-Mail", .ru: "Новая почта", .pt: "Novo e-mail"
        ],
        "confirm_email": [
            .zh: "确认邮箱", .zhHant: "確認信箱", .en: "Confirm Email",
            .ja: "メール確認", .ko: "이메일 확인", .es: "Confirmar correo", .fr: "Confirmer l'e-mail",
            .de: "E-Mail bestätigen", .ru: "Подтвердить почту", .pt: "Confirmar e-mail"
        ],
        "auto_launch": [
            .zh: "开机启动", .zhHant: "開機啟動", .en: "Launch at login",
            .ja: "ログイン時に起動", .ko: "로그인 시 시작", .es: "Iniciar al inicio",
            .fr: "Lancer au démarrage", .de: "Beim Anmelden starten",
            .ru: "Запускать при входе", .pt: "Iniciar no login"
        ],
        "initial_password_hint": [
            .zh: "初始密码：%@，登录后请立即修改。", .zhHant: "初始密碼：%@，登入後請立即修改。", .en: "Initial password: %@. Change it after login.",
            .ja: "初期パスワード：%@。ログイン後すぐに変更してください。",
            .ko: "초기 비밀번호: %@. 로그인 후 바로 변경하세요.",
            .es: "Contraseña inicial: %@. Cámbiela tras iniciar sesión.",
            .fr: "Mot de passe initial : %@. Modifiez-le après connexion.",
            .de: "Startpasswort: %@. Nach der Anmeldung ändern.",
            .ru: "Начальный пароль: %@. Смените его после входа.",
            .pt: "Senha inicial: %@. Altere após o login."
        ],
        "change_required": [
            .zh: "请修改密码并补充管理员邮箱后再使用。", .zhHant: "請修改密碼並補充管理員信箱後再使用。", .en: "Please change the password and add an admin email.",
            .ja: "パスワードを変更し、管理者メールを設定してください。",
            .ko: "비밀번호를 변경하고 관리자 이메일을 설정하세요.",
            .es: "Cambie la contraseña y añada el correo del administrador.",
            .fr: "Modifiez le mot de passe et ajoutez l'e-mail administrateur.",
            .de: "Passwort ändern und Admin-E-Mail hinzufügen.",
            .ru: "Смените пароль и добавьте почту администратора.",
            .pt: "Altere a senha e adicione o e-mail do administrador."
        ],
        "group_label": [
            .zh: "组名", .zhHant: "組名", .en: "Group name",
            .ja: "グループ名", .ko: "그룹 이름", .es: "Nombre del grupo", .fr: "Nom du groupe",
            .de: "Gruppenname", .ru: "Название группы", .pt: "Nome do grupo"
        ],
        "add_group": [
            .zh: "添加参数组", .zhHant: "新增參數組", .en: "Add group",
            .ja: "グループ追加", .ko: "그룹 추가", .es: "Añadir grupo", .fr: "Ajouter un groupe",
            .de: "Gruppe hinzufügen", .ru: "Добавить группу", .pt: "Adicionar grupo"
        ],
        "select_agent_first": [
            .zh: "请先选择左侧智能体", .zhHant: "請先選擇左側智能體", .en: "Select an agent first",
            .ja: "左のエージェントを選択", .ko: "왼쪽 에이전트를 선택하세요", .es: "Seleccione un agente primero",
            .fr: "Sélectionnez d'abord un agent", .de: "Zuerst Agent wählen",
            .ru: "Сначала выберите агента", .pt: "Selecione um agente primeiro"
        ],
        "reset_to_initial": [
            .zh: "重置为初始密码", .zhHant: "重設為初始密碼", .en: "Reset to initial password",
            .ja: "初期パスワードにリセット", .ko: "초기 비밀번호로 재설정", .es: "Restablecer contraseña inicial",
            .fr: "Réinitialiser le mot de passe initial", .de: "Startpasswort zurücksetzen",
            .ru: "Сбросить к начальному паролю", .pt: "Redefinir senha inicial"
        ],
        "edit_agents": [
            .zh: "编辑", .zhHant: "編輯", .en: "Edit",
            .ja: "編集", .ko: "편집", .es: "Editar", .fr: "Modifier",
            .de: "Bearbeiten", .ru: "Правка", .pt: "Editar"
        ],
        "edit_agents_hint": [
            .zh: "管理显示", .zhHant: "管理顯示", .en: "Manage visibility",
            .ja: "表示管理", .ko: "표시 관리", .es: "Gestionar visibilidad", .fr: "Gérer l'affichage",
            .de: "Sichtbarkeit verwalten", .ru: "Управление отображением", .pt: "Gerenciar exibição"
        ],
        "add_custom_agent": [
            .zh: "新增", .zhHant: "新增", .en: "Add",
            .ja: "追加", .ko: "추가", .es: "Añadir", .fr: "Ajouter",
            .de: "Hinzufügen", .ru: "Добавить", .pt: "Adicionar"
        ],
        "add_custom_agent_hint": [
            .zh: "新增自定义智能体", .zhHant: "新增自訂智能體", .en: "Add custom agent",
            .ja: "カスタムエージェント追加", .ko: "사용자 에이전트 추가", .es: "Añadir agente personalizado",
            .fr: "Ajouter un agent personnalisé", .de: "Benutzerdefinierten Agent hinzufügen",
            .ru: "Добавить своего агента", .pt: "Adicionar agente personalizado"
        ],
        "custom_agent_hint": [
            .zh: "LOGO 取域名首字母，同字母自动配色。", .zhHant: "LOGO 取網域首字母，同字母自動配色。", .en: "Logo uses domain initial with auto colors.",
            .ja: "ロゴはドメインの頭文字、同文字は自動配色。",
            .ko: "로고는 도메인 첫 글자, 같은 글자는 자동 색상.",
            .es: "El logo usa la inicial del dominio con colores automáticos.",
            .fr: "Logo avec initiale du domaine et couleurs automatiques.",
            .de: "Logo nutzt Domain-Initiale mit automatischen Farben.",
            .ru: "Логотип — первая буква домена, цвета автоматически.",
            .pt: "O logo usa a inicial do domínio com cores automáticas."
        ],
        "name_required": [
            .zh: "请输入名称", .zhHant: "請輸入名稱", .en: "Name is required",
            .ja: "名前を入力してください", .ko: "이름을 입력하세요", .es: "Se requiere un nombre",
            .fr: "Le nom est requis", .de: "Name erforderlich",
            .ru: "Введите название", .pt: "O nome é obrigatório"
        ],
        "api_backup": [
            .zh: "API 参数备份", .zhHant: "API 參數備份", .en: "API Keys",
            .ja: "API キー", .ko: "API 키", .es: "Claves API", .fr: "Clés API",
            .de: "API-Schlüssel", .ru: "API-ключи", .pt: "Chaves API"
        ],
        "general_settings": [
            .zh: "通用设置", .zhHant: "通用設定", .en: "General",
            .ja: "一般設定", .ko: "일반 설정", .es: "General", .fr: "Général",
            .de: "Allgemein", .ru: "Общие", .pt: "Geral"
        ],
        "language": [
            .zh: "语言", .zhHant: "語言", .en: "Language",
            .ja: "言語", .ko: "언어", .es: "Idioma", .fr: "Langue",
            .de: "Sprache", .ru: "Язык", .pt: "Idioma"
        ],
        "appearance": [
            .zh: "界面风格", .zhHant: "介面風格", .en: "Appearance",
            .ja: "外観", .ko: "외관", .es: "Apariencia", .fr: "Apparence",
            .de: "Darstellung", .ru: "Оформление", .pt: "Aparência"
        ],
        "toggle_sidebar": [
            .zh: "折叠/展开侧栏", .zhHant: "摺疊/展開側欄", .en: "Toggle sidebar",
            .ja: "サイドバー切替", .ko: "사이드바 토글", .es: "Alternar barra lateral",
            .fr: "Basculer la barre latérale", .de: "Seitenleiste umschalten",
            .ru: "Свернуть/развернуть панель", .pt: "Alternar barra lateral"
        ],
        "share_system": [
            .zh: "分享", .zhHant: "分享", .en: "Share", .ja: "共有", .ko: "공유",
            .es: "Compartir", .fr: "Partager", .de: "Teilen", .ru: "Поделиться", .pt: "Compartilhar"
        ],
        "share_email": [
            .zh: "邮件", .zhHant: "郵件", .en: "Email", .ja: "メール", .ko: "이메일",
            .es: "Correo", .fr: "E-mail", .de: "E-Mail", .ru: "Почта", .pt: "E-mail"
        ],
        "share_copy": [
            .zh: "复制", .zhHant: "複製", .en: "Copy", .ja: "コピー", .ko: "복사",
            .es: "Copiar", .fr: "Copier", .de: "Kopieren", .ru: "Копировать", .pt: "Copiar"
        ],
        "share_wechat": [
            .zh: "微信", .zhHant: "微信", .en: "WeChat", .ja: "微信", .ko: "위챗",
            .es: "WeChat", .fr: "WeChat", .de: "WeChat", .ru: "WeChat", .pt: "WeChat"
        ],
        "share_google_keep": [
            .zh: "笔记", .zhHant: "筆記", .en: "Notes", .ja: "ノート", .ko: "메모",
            .es: "Notas", .fr: "Notes", .de: "Notizen", .ru: "Заметки", .pt: "Notas"
        ],
        "share_wechat_title": [
            .zh: "已复制到剪贴板", .zhHant: "已複製到剪貼板", .en: "Copied to clipboard",
            .ja: "クリップボードにコピーしました", .ko: "클립보드에 복사됨",
            .es: "Copiado al portapapeles", .fr: "Copié dans le presse-papiers",
            .de: "In die Zwischenablage kopiert", .ru: "Скопировано в буфер обмена",
            .pt: "Copiado"
        ],
        "share_wechat_message": [
            .zh: "请在微信中粘贴发送", .zhHant: "請在微信中貼上傳送", .en: "Paste it in WeChat",
            .ja: "微信で貼り付けて送信してください", .ko: "위챗에 붙여넣어 보내세요",
            .es: "Pégalo en WeChat", .fr: "Collez-le dans WeChat", .de: "Fügen Sie es in WeChat ein",
            .ru: "Вставьте в WeChat", .pt: "Cole no WeChat"
        ],
        "knowledge_config": [
            .zh: "知识库", .zhHant: "知識庫", .en: "Knowledge", .ja: "知識",
            .ko: "지식", .es: "Base", .fr: "Base",
            .de: "Wissen", .ru: "База", .pt: "Base"
        ],
        "summary_provider": [
            .zh: "总结方式", .zhHant: "總結方式", .en: "Summary Provider", .ja: "要約方法", .ko: "요약 방식",
            .es: "Método de resumen", .fr: "Méthode de résumé", .de: "Zusammenfassungsmethode",
            .ru: "Способ резюмирования", .pt: "Método de resumo"
        ],
        "provider_ollama": [
            .zh: "本地 Ollama", .zhHant: "本地 Ollama", .en: "Local Ollama", .ja: "ローカル Ollama",
            .ko: "로컬 Ollama", .es: "Ollama local", .fr: "Ollama local", .de: "Lokales Ollama",
            .ru: "Локальный Ollama", .pt: "Ollama local"
        ],
        "provider_cloud": [
            .zh: "云端 API", .zhHant: "雲端 API", .en: "Cloud API", .ja: "クラウド API", .ko: "클라우드 API",
            .es: "API en la nube", .fr: "API cloud", .de: "Cloud-API", .ru: "Облачный API", .pt: "API na nuvem"
        ],
        "provider_local": [
            .zh: "本地规则", .zhHant: "本地規則", .en: "Local Rules", .ja: "ローカルルール", .ko: "로컬 규칙",
            .es: "Reglas locales", .fr: "Règles locales", .de: "Lokale Regeln", .ru: "Локальные правила", .pt: "Regras locais"
        ],
        "ollama_host": [
            .zh: "Ollama 地址", .zhHant: "Ollama 位址", .en: "Ollama Host", .ja: "Ollama アドレス",
            .ko: "Ollama 호스트", .es: "Servidor Ollama", .fr: "Hôte Ollama", .de: "Ollama-Host",
            .ru: "Адрес Ollama", .pt: "Host do Ollama"
        ],
        "ollama_model": [
            .zh: "模型", .zhHant: "模型", .en: "Model", .ja: "モデル", .ko: "모델",
            .es: "Modelo", .fr: "Modèle", .de: "Modell", .ru: "Модель", .pt: "Modelo"
        ],
        "recheck": [
            .zh: "重新检测", .zhHant: "重新檢測", .en: "Recheck", .ja: "再確認", .ko: "다시 확인",
            .es: "Verificar de nuevo", .fr: "Revérifier", .de: "Erneut prüfen", .ru: "Проверить снова", .pt: "Verificar novamente"
        ],
        "copy_install": [
            .zh: "复制安装命令", .zhHant: "複製安裝指令", .en: "Copy Install Command", .ja: "インストールコマンドをコピー",
            .ko: "설치 명령 복사", .es: "Copiar comando de instalación", .fr: "Copier la commande d'installation",
            .de: "Installationsbefehl kopieren", .ru: "Скопировать команду установки", .pt: "Copiar comando de instalação"
        ],
        "cloud_api_key": [
            .zh: "API Key", .zhHant: "API Key", .en: "API Key", .ja: "API キー", .ko: "API 키",
            .es: "Clave API", .fr: "Clé API", .de: "API-Schlüssel", .ru: "API-ключ", .pt: "Chave da API"
        ],
        "cloud_base_url": [
            .zh: "接口地址", .zhHant: "介面位址", .en: "Base URL", .ja: "ベース URL", .ko: "기본 URL",
            .es: "URL base", .fr: "URL de base", .de: "Basis-URL", .ru: "Базовый URL", .pt: "URL base"
        ],
        "cloud_model": [
            .zh: "模型", .zhHant: "模型", .en: "Model", .ja: "モデル", .ko: "모델",
            .es: "Modelo", .fr: "Modèle", .de: "Modell", .ru: "Модель", .pt: "Modelo"
        ],
        "summary_hint": [
            .zh: "默认 Ollama，失败回退本地规则。", .zhHant: "預設 Ollama，失敗回退本地規則。", .en: "Ollama first; local fallback.",
            .ja: "Ollama優先、失敗時はローカルルール。", .ko: "Ollama 우선, 실패 시 로컬 규칙.",
            .es: "Ollama local; si no, local.", .fr: "Ollama local ; sinon local.",
            .de: "Ollama lokal; sonst lokal.", .ru: "Сначала Ollama; иначе локально.",
            .pt: "Ollama local; senão local."
        ],
        "summary_by_model": [
            .zh: "由 %@ 生成", .zhHant: "由 %@ 生成", .en: "Generated by %@", .ja: "%@ が生成", .ko: "%@ 생성",
            .es: "Generado por %@", .fr: "Généré par %@", .de: "Generiert von %@", .ru: "Создано: %@", .pt: "Gerado por %@"
        ],
        "summary_pending": [
            .zh: "正在整理数据，请稍候...", .zhHant: "正在整理資料，請稍候...", .en: "Processing, please wait...",
            .ja: "整理中です。お待ちください...", .ko: "정리 중입니다. 잠시만...",
            .es: "Procesando, espere...", .fr: "Traitement en cours...",
            .de: "Wird verarbeitet...", .ru: "Обработка...", .pt: "Processando..."
        ],
        "knowledge_save_failed_title": [
            .zh: "保存失败", .zhHant: "儲存失敗", .en: "Save Failed", .ja: "保存失敗", .ko: "저장 실패",
            .es: "Error al guardar", .fr: "Échec de l'enregistrement", .de: "Speichern fehlgeschlagen",
            .ru: "Не удалось сохранить", .pt: "Falha ao salvar"
        ],
        "knowledge_save_failed_message": [
            .zh: "未能检测到该智能体的回复，请确认已登录并完成一次对话后再保存。", .zhHant: "未能偵測到該智能體的回覆，請確認已登入並完成一次對話後再儲存。", .en: "No reply detected. Make sure you are signed in and have a completed conversation before saving.",
            .ja: "応答を検出できませんでした。ログインして会話を完了してから保存してください。",
            .ko: "응답을 감지하지 못했습니다. 로그인하고 대화를 완료한 후 저장하세요.",
            .es: "No se detectó respuesta. Inicia sesión y completa una conversación antes de guardar.",
            .fr: "Aucune réponse détectée. Connectez-vous et terminez une conversation avant d'enregistrer.",
            .de: "Keine Antwort erkannt. Melden Sie sich an und schließen Sie ein Gespräch ab, bevor Sie speichern.",
            .ru: "Ответ не обнаружен. Войдите и завершите диалог перед сохранением.",
            .pt: "Nenhuma resposta detectada. Faça login e conclua uma conversa antes de salvar."
        ]
    ]
}
