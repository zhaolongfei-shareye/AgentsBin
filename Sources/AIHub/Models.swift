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
            Agent(id: "lechat", name: "Le Chat", letter: "L", colorHex: "#ff7000", urlString: "chat.mistral.ai/chat", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "mistral", name: "Mistral", letter: "M", colorHex: "#fa520f", urlString: "chat.mistral.ai", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "perplexity", name: "Perplexity", letter: "P", colorHex: "#20808d", urlString: "perplexity.ai", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "pi", name: "Pi", letter: "P", colorHex: "#5b5bd6", urlString: "pi.ai", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "poe", name: "Poe", letter: "P", colorHex: "#4b5563", urlString: "poe.com", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "tongyi", name: "通义", letter: "通", colorHex: "#6d28d9", urlString: "tongyi.aliyun.com/qianwen", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "you", name: "You.com", letter: "Y", colorHex: "#7c3aed", urlString: "you.com", isOnline: false, isEnabled: false, isPinned: false),
            Agent(id: "yuanbao", name: "腾讯元宝", letter: "元", colorHex: "#1e6fff", urlString: "yuanbao.tencent.com", isOnline: false, isEnabled: false, isPinned: false)
        ]
    }
}
