import Foundation

struct Agent: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var letter: String
    var colorHex: String
    var urlString: String
    var isOnline: Bool
    var isEnabled: Bool
    var isPinned: Bool
    var isLocal: Bool

    init(id: String, name: String, letter: String, colorHex: String, urlString: String, isOnline: Bool, isEnabled: Bool, isPinned: Bool, isLocal: Bool = false) {
        self.id = id
        self.name = name
        self.letter = letter
        self.colorHex = colorHex
        self.urlString = urlString
        self.isOnline = isOnline
        self.isEnabled = isEnabled
        self.isPinned = isPinned
        self.isLocal = isLocal
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, letter, colorHex, urlString, isOnline, isEnabled, isPinned, isLocal
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        letter = try container.decodeIfPresent(String.self, forKey: .letter) ?? ""
        colorHex = try container.decodeIfPresent(String.self, forKey: .colorHex) ?? "#007aff"
        urlString = try container.decode(String.self, forKey: .urlString)
        isOnline = try container.decodeIfPresent(Bool.self, forKey: .isOnline) ?? false
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? false
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        isLocal = try container.decodeIfPresent(Bool.self, forKey: .isLocal) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(letter, forKey: .letter)
        try container.encode(colorHex, forKey: .colorHex)
        try container.encode(urlString, forKey: .urlString)
        try container.encode(isOnline, forKey: .isOnline)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(isPinned, forKey: .isPinned)
        try container.encode(isLocal, forKey: .isLocal)
    }

    static func defaults() -> [Agent] {
        [
            Agent(id: "chatgpt", name: "ChatGPT", letter: "C", colorHex: "#10a37f", urlString: "chatgpt.com/chat", isOnline: true, isEnabled: true, isPinned: false),
            Agent(id: "claude", name: "Claude", letter: "C", colorHex: "#d97757", urlString: "claude.ai/new", isOnline: true, isEnabled: true, isPinned: false),
            Agent(id: "gemini", name: "Gemini", letter: "G", colorHex: "#4285f4", urlString: "gemini.google.com/app", isOnline: true, isEnabled: true, isPinned: false),
            Agent(id: "deepseek", name: "DeepSeek", letter: "D", colorHex: "#4d6bfe", urlString: "chat.deepseek.com", isOnline: true, isEnabled: true, isPinned: false),
            Agent(id: "kimi", name: "Kimi", letter: "K", colorHex: "#23272f", urlString: "kimi.moonshot.cn", isOnline: false, isEnabled: true, isPinned: false),
            Agent(id: "qwen", name: "千问", letter: "千", colorHex: "#615ced", urlString: "chat.qwen.ai", isOnline: false, isEnabled: true, isPinned: false),
            Agent(id: "grok", name: "Grok", letter: "G", colorHex: "#111827", urlString: "grok.com", isOnline: false, isEnabled: true, isPinned: false),
            Agent(id: "copilot", name: "Copilot", letter: "C", colorHex: "#0067b8", urlString: "copilot.microsoft.com", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "doubao", name: "豆包", letter: "豆", colorHex: "#0f7bff", urlString: "doubao.com/chat", isOnline: true, isEnabled: false, isPinned: false),
            Agent(id: "chatglm", name: "智谱清言", letter: "智", colorHex: "#3859ff", urlString: "chatglm.cn", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "hailuo", name: "海螺 AI", letter: "海", colorHex: "#5b5bd6", urlString: "hailuoai.com", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "wenxin", name: "文心一言", letter: "文", colorHex: "#2932e1", urlString: "yiyan.baidu.com", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "xinghuo", name: "讯飞星火", letter: "星", colorHex: "#0066ff", urlString: "xinghuo.xfyun.cn", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "meta", name: "Meta AI", letter: "M", colorHex: "#0064e0", urlString: "meta.ai", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "huggingchat", name: "HuggingChat", letter: "H", colorHex: "#fbbf24", urlString: "huggingface.co/chat", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "coze", name: "Coze", letter: "C", colorHex: "#22c55e", urlString: "coze.cn", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "monica", name: "Monica", letter: "M", colorHex: "#f97316", urlString: "monica.im", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "cursor", name: "Cursor", letter: "C", colorHex: "#0ea5e9", urlString: "cursor.com/chat", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "character", name: "Character.AI", letter: "C", colorHex: "#ef4444", urlString: "character.ai", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "cohere", name: "Cohere", letter: "C", colorHex: "#7c3aed", urlString: "cohere.com/chat", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "flowith", name: "Flowith", letter: "F", colorHex: "#6366f1", urlString: "flowith.net", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "deepai", name: "DeepAI", letter: "D", colorHex: "#0d9488", urlString: "deepai.org/chat", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "julius", name: "Julius AI", letter: "J", colorHex: "#d946ef", urlString: "julius.ai", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "tiangong", name: "天工", letter: "天", colorHex: "#2563eb", urlString: "tiangong.cn", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "metaso", name: "秘塔 AI", letter: "秘", colorHex: "#eab308", urlString: "metaso.cn", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "blackbox", name: "Blackbox AI", letter: "B", colorHex: "#111827", urlString: "blackbox.ai", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "sider", name: "Sider", letter: "S", colorHex: "#3b82f6", urlString: "sider.ai", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "phind", name: "Phind", letter: "P", colorHex: "#0ea5e9", urlString: "phind.com", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "wenxiaoyan", name: "文小言", letter: "文", colorHex: "#8b5cf6", urlString: "top.aixin.baidu.com", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "lechat", name: "Le Chat", letter: "L", colorHex: "#ff7000", urlString: "chat.mistral.ai/chat", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "mistral", name: "Mistral", letter: "M", colorHex: "#fa520f", urlString: "chat.mistral.ai", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "perplexity", name: "Perplexity", letter: "P", colorHex: "#20808d", urlString: "perplexity.ai", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "pi", name: "Pi", letter: "P", colorHex: "#5b5bd6", urlString: "pi.ai", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "poe", name: "Poe", letter: "P", colorHex: "#4b5563", urlString: "poe.com", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "tongyi", name: "通义", letter: "通", colorHex: "#6d28d9", urlString: "tongyi.aliyun.com/qianwen", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "you", name: "You.com", letter: "Y", colorHex: "#7c3aed", urlString: "you.com", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "yuanbao", name: "腾讯元宝", letter: "元", colorHex: "#1e6fff", urlString: "yuanbao.tencent.com", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "ollama", name: "Ollama", letter: "O", colorHex: "#5856d6", urlString: "127.0.0.1:11434", isOnline: true, isEnabled: false, isPinned: false, isLocal: true),
            Agent(id: "lmstudio", name: "LM Studio", letter: "L", colorHex: "#007aff", urlString: "127.0.0.1:1234", isOnline: true, isEnabled: false, isPinned: false, isLocal: true),
            Agent(id: "llamacpp", name: "llama.cpp", letter: "C", colorHex: "#30b0c7", urlString: "127.0.0.1:8080", isOnline: false, isEnabled: false, isPinned: false, isLocal: true),
            Agent(id: "vllm", name: "vLLM", letter: "V", colorHex: "#7c3aed", urlString: "127.0.0.1:8000", isOnline: false, isEnabled: false, isPinned: false, isLocal: true),
            Agent(id: "jan", name: "Jan", letter: "J", colorHex: "#ff9500", urlString: "127.0.0.1:1337", isOnline: false, isEnabled: false, isPinned: false, isLocal: true),
            Agent(id: "localai", name: "LocalAI", letter: "A", colorHex: "#34c759", urlString: "127.0.0.1:8081", isOnline: false, isEnabled: false, isPinned: false, isLocal: true)
        ]
    }
}
