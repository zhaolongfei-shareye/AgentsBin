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
