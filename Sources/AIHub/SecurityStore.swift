import AppKit
import Combine
import CryptoKit
import Foundation
import SQLite3

enum KeychainService {
    private static let defaults = UserDefaults.standard
    private static let masterKeyURL = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("AIHub", isDirectory: true)
        .appendingPathComponent("master.key")

    private static func masterKey() -> SymmetricKey {
        if let data = try? Data(contentsOf: masterKeyURL), data.count == 32 {
            return SymmetricKey(data: data)
        }
        let key = SymmetricKey(size: .bits256)
        try? FileManager.default.createDirectory(
            at: masterKeyURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        key.withUnsafeBytes { raw in
            try? Data(raw).write(to: masterKeyURL, options: .atomic)
        }
        try? FileManager.default.setAttributes(
            [.posixPermissions: 0o600],
            ofItemAtPath: masterKeyURL.path
        )
        return key
    }

    static func save(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8),
              let sealed = try? AES.GCM.seal(data, using: masterKey()),
              let boxed = sealed.combined else { return }
        defaults.set(boxed.base64EncodedString(), forKey: key)
    }

    static func load(_ key: String) -> String? {
        guard let b64 = defaults.string(forKey: key),
              let boxed = Data(base64Encoded: b64),
              let sealed = try? AES.GCM.SealedBox(combined: boxed),
              let data = try? AES.GCM.open(sealed, using: masterKey()) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(_ key: String) {
        defaults.removeObject(forKey: key)
    }
}

struct APICredential: Codable, Identifiable, Hashable {
    var id = UUID()
    var label: String
    var baseURL: String
    var model: String
    var isActive: Bool = false

    private enum CodingKeys: String, CodingKey {
        case id, label, baseURL, model, isActive
    }

    init(id: UUID = UUID(), label: String, baseURL: String, model: String, isActive: Bool = false) {
        self.id = id
        self.label = label
        self.baseURL = baseURL
        self.model = model
        self.isActive = isActive
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        label = try container.decode(String.self, forKey: .label)
        baseURL = try container.decodeIfPresent(String.self, forKey: .baseURL) ?? ""
        model = try container.decodeIfPresent(String.self, forKey: .model) ?? ""
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? false
    }
}

struct AgentAPIConfig: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var note: String
    var isEnabled: Bool
    var credentials: [APICredential]

    init(id: String, name: String, note: String, isEnabled: Bool = false, credentials: [APICredential] = []) {
        self.id = id
        self.name = name
        self.note = note
        self.isEnabled = isEnabled
        self.credentials = credentials
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, note, isEnabled, credentials, baseURL, model
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? false
        if let saved = try container.decodeIfPresent([APICredential].self, forKey: .credentials), !saved.isEmpty {
            credentials = saved
        } else {
            let baseURL = try container.decodeIfPresent(String.self, forKey: .baseURL) ?? ""
            let model = try container.decodeIfPresent(String.self, forKey: .model) ?? ""
            credentials = [APICredential(label: "Default", baseURL: baseURL, model: model)]
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(note, forKey: .note)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(credentials, forKey: .credentials)
    }
}

final class APIKeyStore: ObservableObject {
    @Published private(set) var configs: [AgentAPIConfig] = []
    @Published var importedFromCCSwitch = false

    private let defaults = UserDefaults.standard
    private let configsKey = "agentsbin.api.configs"
    private let importedKey = "agentsbin.api.importedCCSwitch"

    init() {
        if let data = defaults.data(forKey: configsKey),
           let saved = try? JSONDecoder().decode([AgentAPIConfig].self, from: data) {
            configs = saved
        } else {
            configs = Self.defaultConfigs()
        }
        if !defaults.bool(forKey: importedKey) {
            importCCSwitch()
        }
    }

    static func defaultConfigs() -> [AgentAPIConfig] {
        [
            AgentAPIConfig(id: "openai", name: "OpenAI", note: "OpenAI 兼容标准", credentials: [APICredential(label: "Default", baseURL: "https://api.openai.com/v1", model: "gpt-4o-mini")]),
            AgentAPIConfig(id: "anthropic", name: "Anthropic Claude", note: "Anthropic Messages API", credentials: [APICredential(label: "Default", baseURL: "https://api.anthropic.com", model: "claude-3-5-sonnet")]),
            AgentAPIConfig(id: "google", name: "Google Gemini", note: "OpenAI 兼容端点", credentials: [APICredential(label: "Default", baseURL: "https://generativelanguage.googleapis.com/v1beta/openai", model: "gemini-2.0-flash")]),
            AgentAPIConfig(id: "deepseek", name: "DeepSeek", note: "OpenAI 兼容标准", credentials: [APICredential(label: "Default", baseURL: "https://api.deepseek.com/v1", model: "deepseek-chat")]),
            AgentAPIConfig(id: "kimi", name: "Kimi (Moonshot)", note: "OpenAI 兼容标准", credentials: [APICredential(label: "Default", baseURL: "https://api.moonshot.cn/v1", model: "moonshot-v1-8k")]),
            AgentAPIConfig(id: "qwen", name: "Qwen (DashScope)", note: "OpenAI 兼容标准", credentials: [APICredential(label: "Default", baseURL: "https://dashscope.aliyuncs.com/compatible-mode/v1", model: "qwen-plus")]),
            AgentAPIConfig(id: "grok", name: "Grok (xAI)", note: "OpenAI 兼容标准", credentials: [APICredential(label: "Default", baseURL: "https://api.x.ai/v1", model: "grok-2-latest")]),
            AgentAPIConfig(id: "doubao", name: "豆包 Doubao", note: "火山方舟 OpenAI 兼容", credentials: [APICredential(label: "Default", baseURL: "https://ark.cn-beijing.volces.com/api/v3", model: "doubao-pro-32k")]),
            AgentAPIConfig(id: "chatglm", name: "智谱 ChatGLM", note: "OpenAI 兼容标准", credentials: [APICredential(label: "Default", baseURL: "https://open.bigmodel.cn/api/paas/v4", model: "glm-4-plus")]),
            AgentAPIConfig(id: "wenxin", name: "文心一言 Wenxin", note: "千帆 OpenAI 兼容", credentials: [APICredential(label: "Default", baseURL: "https://qianfan.baidubce.com/v2", model: "ernie-4.0-8k")]),
            AgentAPIConfig(id: "xinghuo", name: "讯飞星火 Xinghuo", note: "OpenAI 兼容标准", credentials: [APICredential(label: "Default", baseURL: "https://spark-api-open.xf-yun.com/v1", model: "generalv3.5")]),
            AgentAPIConfig(id: "yuanbao", name: "腾讯元宝 Yuanbao", note: "混元 OpenAI 兼容", credentials: [APICredential(label: "Default", baseURL: "https://api.hunyuan.cloud.tencent.com/v1", model: "hunyuan-pro")])
        ]
    }

    func keyStorageKey(_ id: UUID) -> String {
        "agentsbin.apikey." + id.uuidString
    }

    func apiKey(for id: UUID) -> String {
        KeychainService.load(keyStorageKey(id)) ?? ""
    }

    func save(apiKey: String, for id: UUID) {
        if apiKey.isEmpty {
            KeychainService.delete(keyStorageKey(id))
        } else {
            KeychainService.save(apiKey, forKey: keyStorageKey(id))
        }
    }

    static let agentToConfigMap: [String: String] = [
        "chatgpt": "openai",
        "claude": "anthropic",
        "gemini": "google",
        "deepseek": "deepseek",
        "kimi": "kimi",
        "qwen": "qwen",
        "grok": "grok"
    ]

    func config(forAgentID agentID: String) -> AgentAPIConfig? {
        let configID = Self.agentToConfigMap[agentID] ?? agentID
        return configs.first(where: { $0.id == configID && $0.isEnabled })
    }

    func hasAPIKey(forAgentID agentID: String) -> Bool {
        guard let config = config(forAgentID: agentID) else { return false }
        return config.credentials.contains { !apiKey(for: $0.id).isEmpty }
    }

    func credential(forAgentID agentID: String) -> (config: AgentAPIConfig, credential: APICredential, apiKey: String)? {
        guard let config = config(forAgentID: agentID) else { return nil }
        if let active = config.credentials.first(where: { $0.isActive && !apiKey(for: $0.id).isEmpty }) {
            return (config, active, apiKey(for: active.id))
        }
        for credential in config.credentials {
            let key = apiKey(for: credential.id)
            if !key.isEmpty {
                return (config, credential, key)
            }
        }
        return nil
    }

    func setActiveCredential(configID: String, credentialID: UUID) {
        guard let index = configs.firstIndex(where: { $0.id == configID }) else { return }
        for i in configs[index].credentials.indices {
            configs[index].credentials[i].isActive = configs[index].credentials[i].id == credentialID
        }
        persist()
    }

    func moveConfig(_ id: String, to targetID: String) {
        guard let from = configs.firstIndex(where: { $0.id == id }),
              let target = configs.firstIndex(where: { $0.id == targetID }) else { return }
        let config = configs.remove(at: from)
        configs.insert(config, at: target > from ? target - 1 : target)
        persist()
    }

    func update(config: AgentAPIConfig) {
        guard let index = configs.firstIndex(where: { $0.id == config.id }) else { return }
        configs[index] = config
        persist()
    }

    func updateEnabled(_ id: String, _ enabled: Bool) {
        guard let index = configs.firstIndex(where: { $0.id == id }) else { return }
        configs[index].isEnabled = enabled
        persist()
    }

    func addCredential(to configID: String) {
        guard let index = configs.firstIndex(where: { $0.id == configID }) else { return }
        let number = configs[index].credentials.count + 1
        let providerDefault = Self.defaultConfigs().first(where: { $0.id == configID })?.credentials.first
        let defaultBase = configs[index].credentials.first?.baseURL
            ?? providerDefault?.baseURL
            ?? "https://api.openai.com/v1"
        let defaultModel = configs[index].credentials.first?.model
            ?? providerDefault?.model
            ?? "gpt-4o-mini"
        configs[index].credentials.append(APICredential(label: "Group \(number)", baseURL: defaultBase, model: defaultModel))
        persist()
    }

    func addCustomProvider(name: String) -> String {
        let id = "custom-" + slug(name) + "-" + UUID().uuidString.prefix(6).lowercased()
        let config = AgentAPIConfig(
            id: id,
            name: name,
            note: "",
            credentials: [APICredential(label: "Default", baseURL: "https://api.openai.com/v1", model: "gpt-4o-mini")]
        )
        configs.append(config)
        persist()
        return id
    }

    func deleteProvider(_ id: String) {
        guard let index = configs.firstIndex(where: { $0.id == id }) else { return }
        for credential in configs[index].credentials {
            KeychainService.delete("agentsbin.apikey." + credential.id.uuidString)
        }
        configs.remove(at: index)
        persist()
    }

    func updateCredential(configID: String, credential: APICredential) {
        guard let index = configs.firstIndex(where: { $0.id == configID }),
              let credentialIndex = configs[index].credentials.firstIndex(where: { $0.id == credential.id }) else { return }
        configs[index].credentials[credentialIndex] = credential
        persist()
    }

    func deleteCredential(configID: String, credentialID: UUID) {
        guard let index = configs.firstIndex(where: { $0.id == configID }) else { return }
        configs[index].credentials.removeAll { $0.id == credentialID }
        KeychainService.delete("agentsbin.apikey." + credentialID.uuidString)
        persist()
    }

    private func importCCSwitch() {
        let path = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".cc-switch/cc-switch.db")
        var db: OpaquePointer?
        guard sqlite3_open(path.path, &db) == SQLITE_OK else { return }
        defer { sqlite3_close(db) }
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, "SELECT DISTINCT name, website_url FROM providers ORDER BY name;", -1, &statement, nil) == SQLITE_OK else { return }
        defer { sqlite3_finalize(statement) }
        while sqlite3_step(statement) == SQLITE_ROW {
            let name = sqlite3_column_text(statement, 0).map { String(cString: $0) } ?? ""
            let website = sqlite3_column_text(statement, 1).map { String(cString: $0) } ?? ""
            guard !name.isEmpty else { continue }
            let id = slug(name)
            if !configs.contains(where: { $0.id == id }) {
                configs.append(AgentAPIConfig(id: id, name: name, note: website))
            }
        }
        defaults.set(true, forKey: importedKey)
        importedFromCCSwitch = true
        persist()
    }

    private func slug(_ value: String) -> String {
        value.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(configs) {
            defaults.set(data, forKey: configsKey)
        }
    }
}

private extension Data {
    init?(hexString: String) {
        guard hexString.count % 2 == 0 else { return nil }
        var data = Data()
        var index = hexString.startIndex
        while index < hexString.endIndex {
            let next = hexString.index(index, offsetBy: 2)
            guard let byte = UInt8(hexString[index..<next], radix: 16) else { return nil }
            data.append(byte)
            index = next
        }
        self = data
    }
}
