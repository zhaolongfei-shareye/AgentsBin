import AppKit
import Combine
import CryptoKit
import Foundation
import SQLite3

enum KeychainService {
    static func save(_ value: String, forKey key: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func load(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

struct APICredential: Codable, Identifiable, Hashable {
    var id = UUID()
    var label: String
    var baseURL: String
    var model: String
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
            AgentAPIConfig(id: "grok", name: "Grok (xAI)", note: "OpenAI 兼容标准", credentials: [APICredential(label: "Default", baseURL: "https://api.x.ai/v1", model: "grok-2-latest")])
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
        configs[index].credentials.append(APICredential(label: "Group \(number)", baseURL: "", model: ""))
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

final class AdminAuthStore: ObservableObject {
    @Published var isConfigured = false
    @Published var isUnlocked = false
    @Published var adminEmail = ""
    @Published var message = ""
    @Published var lockedUntil: Date?
    @Published var resetCode: String?
    @Published var resetExpiry: Date?
    @Published var isDefaultPassword = false

    private let defaults = UserDefaults.standard
    private let authKey = "agentsbin.admin.auth"
    private let lockKey = "agentsbin.admin.failures"
    private let lockedKey = "agentsbin.admin.lockedUntil"
    private var unlockTimer: Timer?

    static let initialPassword = "AgentsBin@2026"

    init() {
        isConfigured = KeychainService.load(authKey) != nil
        if !isConfigured {
            setupDefaultAuth()
        }
        if let email = defaults.string(forKey: "agentsbin.admin.email") {
            adminEmail = email
        }
        if let raw = defaults.object(forKey: lockedKey) as? Date, raw > Date() {
            lockedUntil = raw
        }
    }

    static func passwordError(_ password: String) -> String? {
        if password.count < 8 {
            return "至少 8 位"
        }
        let hasLetter = password.range(of: "[A-Za-z]", options: .regularExpression) != nil
        let hasDigit = password.range(of: "\\d", options: .regularExpression) != nil
        let hasSymbol = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        if !(hasLetter && hasDigit && hasSymbol) {
            return "需包含字母、数字和符号"
        }
        return nil
    }

    var requireChange: Bool {
        isDefaultPassword || adminEmail.isEmpty
    }

    private func setupDefaultAuth() {
        saveAuth(email: "", password: Self.initialPassword)
        isConfigured = true
        isDefaultPassword = true
    }

    func setup(email: String, password: String) -> Bool {
        guard email.contains("@"), email.contains(".") else {
            message = "邮箱格式不正确"
            return false
        }
        if let error = Self.passwordError(password) {
            message = "密码强度不足：" + error
            return false
        }
        saveAuth(email: email, password: password)
        isConfigured = true
        isUnlocked = true
        startSessionTimer()
        return true
    }

    func unlock(password: String) -> Bool {
        if let locked = lockedUntil, locked > Date() {
            message = "尝试次数过多，请稍后再试"
            return false
        }
        guard verify(password) else {
            recordFailure()
            message = "密码错误"
            return false
        }
        clearFailures()
        isUnlocked = true
        startSessionTimer()
        return true
    }

    func changePassword(old: String, new: String) -> Bool {
        guard verify(old) else {
            message = "当前密码错误"
            return false
        }
        if let error = Self.passwordError(new) {
            message = "新密码强度不足：" + error
            return false
        }
        saveAuth(email: adminEmail, password: new)
        isDefaultPassword = false
        message = "密码已修改"
        return true
    }

    func changeEmail(new: String, confirm: String, password: String) -> Bool {
        guard new == confirm else {
            message = "两次邮箱不一致"
            return false
        }
        guard new.contains("@"), new.contains(".") else {
            message = "邮箱格式不正确"
            return false
        }
        guard verify(password) else {
            message = "管理员密码错误"
            return false
        }
        guard let json = KeychainService.load(authKey),
              let data = json.data(using: .utf8),
              var payload = (try? JSONSerialization.jsonObject(with: data) as? [String: String]) ?? nil else {
            message = "读取凭据失败"
            return false
        }
        payload["email"] = new
        if let newData = try? JSONSerialization.data(withJSONObject: payload),
           let newJSON = String(data: newData, encoding: .utf8) {
            KeychainService.save(newJSON, forKey: authKey)
        }
        adminEmail = new
        defaults.set(new, forKey: "agentsbin.admin.email")
        message = "邮箱已修改"
        return true
    }

    func requestReset() -> String? {
        guard isConfigured else { return nil }
        let code = String(format: "%06d", Int.random(in: 100000...999999))
        resetCode = code
        resetExpiry = Date().addingTimeInterval(1800)
        defaults.set(code, forKey: "agentsbin.admin.resetCode")
        defaults.set(resetExpiry, forKey: "agentsbin.admin.resetExpiry")
        if let url = URL(string: "mailto:\(adminEmail)?subject=AgentsBin%20%E5%AF%86%E7%A0%81%E9%87%8D%E7%BD%AE&body=%E9%87%8D%E7%BD%AE%E7%A0%81%EF%BC%9A\(code)%0A%EF%BC%8830%E5%88%86%E9%92%9F%E5%86%85%E6%9C%89%E6%95%88%EF%BC%89") {
            NSWorkspace.shared.open(url)
        }
        return code
    }

    func reset(code: String, newPassword: String) -> Bool {
        guard let saved = defaults.string(forKey: "agentsbin.admin.resetCode"),
              let expiry = defaults.object(forKey: "agentsbin.admin.resetExpiry") as? Date,
              saved == code, expiry > Date() else {
            message = "重置码无效或已过期"
            return false
        }
        if let error = Self.passwordError(newPassword) {
            message = "密码强度不足：" + error
            return false
        }
        defaults.removeObject(forKey: "agentsbin.admin.resetCode")
        defaults.removeObject(forKey: "agentsbin.admin.resetExpiry")
        saveAuth(email: adminEmail, password: newPassword)
        clearFailures()
        isUnlocked = true
        startSessionTimer()
        message = "密码已重置"
        return true
    }

    func lock() {
        isUnlocked = false
        unlockTimer?.invalidate()
    }

    private func saveAuth(email: String, password: String) {
        let salt = Data((0..<16).map { _ in UInt8.random(in: 0...255) })
        let hash = Self.hash(password, salt: salt)
        let payload = [
            "email": email,
            "salt": salt.map { String(format: "%02x", $0) }.joined(),
            "hash": hash.map { String(format: "%02x", $0) }.joined()
        ]
        if let data = try? JSONSerialization.data(withJSONObject: payload),
           let json = String(data: data, encoding: .utf8) {
            KeychainService.save(json, forKey: authKey)
        }
        adminEmail = email
        defaults.set(email, forKey: "agentsbin.admin.email")
    }

    private func verify(_ password: String) -> Bool {
        guard let json = KeychainService.load(authKey),
              let data = json.data(using: .utf8),
              let payload = try? JSONSerialization.jsonObject(with: data) as? [String: String],
              let saltHex = payload["salt"], let hashHex = payload["hash"],
              let salt = Data(hexString: saltHex) else { return false }
        let hash = Self.hash(password, salt: salt)
        return hash.map { String(format: "%02x", $0) }.joined() == hashHex
    }

    private static func hash(_ password: String, salt: Data) -> Data {
        var value = Data()
        value.append(salt)
        value.append(Data(password.utf8))
        value.append(salt)
        for _ in 0..<2000 {
            value = Data(SHA256.hash(data: value))
        }
        return value
    }

    private func recordFailure() {
        let count = defaults.integer(forKey: lockKey) + 1
        defaults.set(count, forKey: lockKey)
        if count >= 5 {
            let until = Date().addingTimeInterval(300)
            lockedUntil = until
            defaults.set(until, forKey: lockedKey)
            defaults.set(0, forKey: lockKey)
        }
    }

    private func clearFailures() {
        defaults.set(0, forKey: lockKey)
        defaults.removeObject(forKey: lockedKey)
        lockedUntil = nil
    }

    private func startSessionTimer() {
        unlockTimer?.invalidate()
        unlockTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: false) { [weak self] _ in
            self?.lock()
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
