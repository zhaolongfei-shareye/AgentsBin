import Combine
import Foundation

enum SummaryProvider: String, CaseIterable, Hashable {
    case ollama
    case cloud
    case local
}

final class AISummaryStore: ObservableObject {
    static let installCommand = "curl -fsSL https://ollama.com/install.sh | sh"

    @Published var provider: SummaryProvider {
        didSet { persist() }
    }
    @Published var ollamaHost: String {
        didSet { persist() }
    }
    @Published var ollamaModel: String {
        didSet { persist() }
    }
    @Published var cloudBaseURL: String {
        didSet { persist() }
    }
    @Published var cloudModel: String {
        didSet { persist() }
    }
    @Published var cloudAPIKey: String {
        didSet {
            KeychainService.save(cloudAPIKey, forKey: "aihome.cloud.apiKey")
        }
    }
    @Published var ollamaStatus = "检测中…"
    @Published var ollamaModels: [String] = []

    var currentModelLabel: String {
        switch provider {
        case .ollama:
            return ollamaModel.isEmpty ? "Ollama（检测中）" : "Ollama · \(ollamaModel)"
        case .cloud:
            return cloudModel.isEmpty ? "云端 API" : "\(cloudModel)"
        case .local:
            return "本地规则"
        }
    }

    private let defaults = UserDefaults.standard
    private let session = URLSession.shared

    init() {
        provider = SummaryProvider(rawValue: defaults.string(forKey: "aihome.summary.provider") ?? "") ?? .ollama
        ollamaHost = defaults.string(forKey: "aihome.summary.ollamaHost") ?? "http://127.0.0.1:11434"
        ollamaModel = defaults.string(forKey: "aihome.summary.ollamaModel") ?? ""
        cloudBaseURL = defaults.string(forKey: "aihome.summary.cloudBaseURL") ?? "https://api.openai.com/v1/chat/completions"
        cloudModel = defaults.string(forKey: "aihome.summary.cloudModel") ?? "gpt-4o-mini"
        cloudAPIKey = KeychainService.load("aihome.cloud.apiKey") ?? ""
        detectOllama()
    }

    func detectOllama(completion: (() -> Void)? = nil) {
        ollamaStatus = "检测中…"
        let host = normalizedOllamaHost()
        guard let url = URL(string: host + "/api/tags") else {
            ollamaStatus = "地址无效"
            completion?()
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        session.dataTask(with: request) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                guard let self, let data,
                      let response = try? JSONDecoder().decode(OllamaTagsResponse.self, from: data) else {
                    self?.ollamaStatus = "未连接"
                    self?.ollamaModels = []
                    completion?()
                    return
                }
                let names = response.models.map { $0.name }.filter { !$0.lowercased().contains("embed") }
                self.ollamaModels = names
                self.ollamaStatus = names.isEmpty ? "已连接，无可用模型" : "已连接"
                if self.ollamaModel.isEmpty || !names.contains(self.ollamaModel) {
                    self.ollamaModel = self.preferredModel(from: names)
                }
                completion?()
            }
        }.resume()
    }

    func summarize(_ text: String, completion: @escaping (String?, String) -> Void) {
        switch provider {
        case .local:
            completion(nil, "本地规则")
        case .ollama:
            summarizeWithOllama(text, completion: completion)
        case .cloud:
            summarizeWithCloud(text, completion: completion)
        }
    }

    private func summarizeWithOllama(_ text: String, completion: @escaping (String?, String) -> Void, attempt: Int = 0) {
        if ollamaModel.isEmpty {
            detectOllama { [weak self] in
                guard let self, !self.ollamaModel.isEmpty else {
                    completion(nil, "Ollama（调用失败）")
                    return
                }
                self.summarizeWithOllama(text, completion: completion, attempt: attempt)
            }
            return
        }
        guard !ollamaModel.isEmpty, let url = URL(string: normalizedOllamaHost() + "/api/generate") else {
            completion(nil, "Ollama（调用失败）")
            return
        }
        let prompt = "请提取以下内容的核心要点，最多5条，每条不超过20字，总字数不超过150字，只输出要点，不要展开：\n\n" + String(text.prefix(6000))
        let body: [String: Any] = [
            "model": ollamaModel,
            "prompt": prompt,
            "stream": false,
            "options": ["temperature": 0.3]
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 120
        session.dataTask(with: request) { data, _, _ in
            guard let data,
                  let response = try? JSONDecoder().decode(OllamaGenerateResponse.self, from: data),
                  !response.response.isEmpty else {
                if attempt < 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.summarizeWithOllama(text, completion: completion, attempt: attempt + 1)
                    }
                } else {
                    completion(nil, "Ollama · \(self.ollamaModel)（调用失败）")
                }
                return
            }
            completion(
                response.response.trimmingCharacters(in: .whitespacesAndNewlines),
                "Ollama · \(self.ollamaModel) · \(self.normalizedOllamaHost())"
            )
        }.resume()
    }

    private func summarizeWithCloud(_ text: String, completion: @escaping (String?, String) -> Void) {
        guard !cloudAPIKey.isEmpty, let url = URL(string: cloudBaseURL) else {
            completion(nil, "云端 API（调用失败）")
            return
        }
        let systemPrompt = "你是总结助手，请提取用户内容的核心要点，最多5条，每条不超过20字，总字数不超过150字，只输出要点，不要展开。"
        let body: [String: Any] = [
            "model": cloudModel,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": String(text.prefix(8000))]
            ],
            "temperature": 0.3
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(cloudAPIKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 60
        session.dataTask(with: request) { data, _, _ in
            guard let data,
                  let response = try? JSONDecoder().decode(ChatCompletionResponse.self, from: data),
                  let content = response.choices.first?.message.content,
                  !content.isEmpty else {
                completion(nil, "\(self.cloudModel)（调用失败）")
                return
            }
            completion(
                content.trimmingCharacters(in: .whitespacesAndNewlines),
                "\(self.cloudModel) · \(self.cloudBaseURL)"
            )
        }.resume()
    }

    private func normalizedOllamaHost() -> String {
        var host = ollamaHost.trimmingCharacters(in: .whitespacesAndNewlines)
        while host.hasSuffix("/") {
            host.removeLast()
        }
        return host.isEmpty ? "http://127.0.0.1:11434" : host
    }

    private func preferredModel(from names: [String]) -> String {
        let order = ["qwen2", "qwen3", "llama3", "gemma", "mistral"]
        for keyword in order {
            if let match = names.first(where: { $0.lowercased().contains(keyword) }) {
                return match
            }
        }
        return names.first ?? ""
    }

    private func persist() {
        defaults.set(provider.rawValue, forKey: "aihome.summary.provider")
        defaults.set(ollamaHost, forKey: "aihome.summary.ollamaHost")
        defaults.set(ollamaModel, forKey: "aihome.summary.ollamaModel")
        defaults.set(cloudBaseURL, forKey: "aihome.summary.cloudBaseURL")
        defaults.set(cloudModel, forKey: "aihome.summary.cloudModel")
    }
}

private struct OllamaTagsResponse: Codable {
    struct Model: Codable {
        let name: String
    }
    let models: [Model]
}

private struct OllamaGenerateResponse: Codable {
    let response: String
}

private struct ChatCompletionResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
