import AppKit
import Combine
import Foundation

struct LocalProvider: Identifiable, Hashable {
    var id: String
    var name: String
    var urlString: String
    var port: Int
    var healthPath: String
    var modelsPath: String
    var installScript: String
    var website: String
}

enum LocalProviderList {
    static let all: [LocalProvider] = [
        LocalProvider(
            id: "ollama",
            name: "Ollama",
            urlString: "127.0.0.1:11434",
            port: 11434,
            healthPath: "/api/tags",
            modelsPath: "/api/tags",
            installScript: """
            brew install ollama
            ollama serve
            """,
            website: "https://ollama.com"
        ),
        LocalProvider(
            id: "lmstudio",
            name: "LM Studio",
            urlString: "127.0.0.1:1234",
            port: 1234,
            healthPath: "/v1/models",
            modelsPath: "/v1/models",
            installScript: """
            brew install --cask lm-studio
            # Start the local server in LM Studio, then pull a model, e.g. llama-3.2-3b-instruct
            """,
            website: "https://lmstudio.ai"
        ),
        LocalProvider(
            id: "llamacpp",
            name: "llama.cpp",
            urlString: "127.0.0.1:8080",
            port: 8080,
            healthPath: "/v1/models",
            modelsPath: "/v1/models",
            installScript: """
            brew install llama.cpp
            llama-server -m /path/to/model.gguf
            """,
            website: "https://github.com/ggerganov/llama.cpp"
        ),
        LocalProvider(
            id: "vllm",
            name: "vLLM",
            urlString: "127.0.0.1:8000",
            port: 8000,
            healthPath: "/v1/models",
            modelsPath: "/v1/models",
            installScript: """
            python3 -m pip install vllm
            python3 -m vllm.entrypoints.openai.api_server --model facebook/opt-125m
            """,
            website: "https://docs.vllm.ai"
        ),
        LocalProvider(
            id: "jan",
            name: "Jan",
            urlString: "127.0.0.1:1337",
            port: 1337,
            healthPath: "/v1/models",
            modelsPath: "/v1/models",
            installScript: """
            brew install --cask jan
            # Enable the local API server in Jan settings
            """,
            website: "https://jan.ai"
        ),
        LocalProvider(
            id: "localai",
            name: "LocalAI",
            urlString: "127.0.0.1:8081",
            port: 8081,
            healthPath: "/v1/models",
            modelsPath: "/v1/models",
            installScript: """
            curl -fsSL https://localai.io/install.sh | sh
            local-ai run
            """,
            website: "https://localai.io"
        )
    ]
}

final class LocalModelService: ObservableObject {
    static let shared = LocalModelService()

    @Published var detected: [String: Bool] = [:]
    @Published var models: [String: [String]] = [:]
    @Published var installProgress: [String: Double] = [:]
    @Published var installStatus: [String: String] = [:]
    @Published var installing: [String: Bool] = [:]

    private let defaults = UserDefaults.standard
    private let detectedKey = "agentsbin.local.detected"
    private var installProcesses: [String: Process] = [:]

    init() {
        if let raw = defaults.dictionary(forKey: detectedKey) as? [String: Bool] {
            detected = raw
        }
    }

    func provider(for id: String) -> LocalProvider? {
        LocalProviderList.all.first { $0.id == id }
    }

    func provider(forAgent agent: Agent) -> LocalProvider? {
        guard agent.isLocal else { return nil }
        if let provider = provider(for: agent.id) {
            return provider
        }
        if agent.id == "llamacpp" {
            return provider(for: "llamacpp")
        }
        return nil
    }

    func detectAll() {
        Task { await detectAllAsync() }
    }

    func detectAllAsync() async {
        var results: [String: Bool] = [:]
        var modelMap: [String: [String]] = [:]
        await withTaskGroup(of: (String, Bool, [String]).self) { group in
            for provider in LocalProviderList.all {
                group.addTask {
                    let (ok, models) = await self.probe(provider)
                    return (provider.id, ok, models)
                }
            }
            for await (id, ok, models) in group {
                results[id] = ok
                if ok {
                    modelMap[id] = models
                }
            }
        }
        let finalDetected = results
        let finalModels = modelMap
        await MainActor.run {
            detected = finalDetected
            self.models = finalModels
            defaults.set(finalDetected, forKey: detectedKey)
        }
    }

    func detect(_ providerID: String) async {
        guard let provider = provider(for: providerID) else { return }
        let (ok, models) = await probe(provider)
        await MainActor.run {
            detected[providerID] = ok
            self.models[providerID] = ok ? models : []
            defaults.set(detected, forKey: detectedKey)
        }
    }

    func isDetected(_ providerID: String) -> Bool {
        detected[providerID] ?? false
    }

    func modelList(for providerID: String) -> [String] {
        models[providerID] ?? []
    }

    func chatBaseURL(for providerID: String) -> String {
        guard let provider = provider(for: providerID) else { return "" }
        return "http://" + provider.urlString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    func website(forAgent agent: Agent) -> String {
        if agent.isLocal, let provider = provider(forAgent: agent) {
            return provider.website
        }
        return agent.urlString
    }

    private func probe(_ provider: LocalProvider) async -> (Bool, [String]) {
        let base = "http://" + provider.urlString
        guard let url = URL(string: base + provider.modelsPath) else { return (false, []) }
        var request = URLRequest(url: url)
        request.timeoutInterval = 1.5
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                return (false, [])
            }
            if provider.id == "ollama" {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let list = json["models"] as? [[String: Any]] {
                    let names = list.compactMap { $0["name"] as? String }
                    return (true, names.isEmpty ? ["llama3.2"] : names)
                }
                return (true, ["llama3.2"])
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let list = json["data"] as? [[String: Any]] {
                let names = list.compactMap { $0["id"] as? String }
                return (true, names)
            }
            return (true, [])
        } catch {
            return (false, [])
        }
    }

    func startInstall(_ provider: LocalProvider) {
        installProgress[provider.id] = 0
        installStatus[provider.id] = "Preparing..."
        installing[provider.id] = true
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", provider.installScript]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        pipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            guard let text = String(data: data, encoding: .utf8) else { return }
            for line in text.components(separatedBy: .newlines) where !line.isEmpty {
                let parsed = Self.parseProgress(line)
                DispatchQueue.main.async {
                    self.installStatus[provider.id] = parsed.text
                    if let value = parsed.progress {
                        self.installProgress[provider.id] = value
                    }
                }
            }
        }
        process.terminationHandler = { _ in
            DispatchQueue.main.async {
                self.installProgress[provider.id] = 1
                self.installing[provider.id] = false
                self.installStatus[provider.id] = "Finished"
            }
            Task { await self.detect(provider.id) }
        }
        do {
            try process.run()
            installProcesses[provider.id] = process
        } catch {
            installStatus[provider.id] = error.localizedDescription
            installing[provider.id] = false
        }
    }

    func cancelInstall(_ providerID: String) {
        installProcesses[providerID]?.terminate()
        installProcesses[providerID] = nil
        installing[providerID] = false
        installStatus[providerID] = "Cancelled"
    }

    func openTerminalHandoff(_ provider: LocalProvider) {
        let script = "#!/bin/zsh\nset -e\n" + provider.installScript + "\necho\necho \"Done. You can close this window.\"\n"
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("agentsbin-install-" + provider.id + ".sh")
        do {
            try script.write(to: fileURL, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: fileURL.path)
            let terminalURL = URL(fileURLWithPath: "/System/Applications/Utilities/Terminal.app")
            NSWorkspace.shared.open([fileURL], withApplicationAt: terminalURL, configuration: NSWorkspace.OpenConfiguration())
            installStatus[provider.id] = "Waiting for Terminal..."
            Task {
                for _ in 0..<120 {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    let (ok, _) = await probe(provider)
                    if ok {
                        await MainActor.run {
                            self.detected[provider.id] = true
                            self.installStatus[provider.id] = "Finished"
                            self.defaults.set(self.detected, forKey: self.detectedKey)
                        }
                        return
                    }
                }
            }
        } catch {
            installStatus[provider.id] = error.localizedDescription
        }
    }

    private static func parseProgress(_ line: String) -> (text: String, progress: Double?) {
        let lower = line.lowercased()
        var text = line.count > 80 ? String(line.prefix(80)) + "..." : line
        if lower.contains("download") {
            text = "Downloading..."
        } else if lower.contains("extract") || lower.contains("unzip") {
            text = "Extracting..."
        } else if lower.contains("install") {
            text = "Installing..."
        } else if lower.contains("error") || lower.contains("failed") {
            text = "Error: " + text
        } else if lower.contains("done") || lower.contains("complete") {
            text = "Finished"
        }
        if let range = line.range(of: #"\d+(\.\d+)?%"#, options: .regularExpression) {
            let raw = line[range].replacingOccurrences(of: "%", with: "")
            if let value = Double(raw) {
                return (text, min(max(value / 100, 0.05), 0.95))
            }
        }
        return (text, nil)
    }
}
