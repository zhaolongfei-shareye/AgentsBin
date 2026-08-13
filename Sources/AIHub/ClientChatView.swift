import SwiftUI

struct ClientChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: String
    let content: String
}

struct ClientChatView: View {
    let agent: Agent
    var onOpenSettings: () -> Void = {}
    var onAddCredential: () -> Void = {}

    @EnvironmentObject private var apiKeyStore: APIKeyStore
    @EnvironmentObject private var localization: LocalizedStore
    @EnvironmentObject private var agentStore: AgentStore
    @ObservedObject private var localService = LocalModelService.shared

    @State private var messages: [ClientChatMessage] = []
    @State private var input = ""
    @State private var state = StateValue.idle
    @State private var errorText = ""
    @State private var errorDetail = ""
    @State private var sending = false
    @State private var selectedModel = ""
    @State private var showDeleteConfirm = false

    enum StateValue {
        case idle, checking, ready, failed
    }

    var body: some View {
        VStack(spacing: 0) {
            if agent.isLocal {
                localBody
            } else if apiKeyStore.credential(forAgentID: agent.id) == nil {
                noKeyView
            } else if state == .checking || state == .idle {
                statusView(icon: "arrow.triangle.2.circlepath", title: localization.text("verifying_api"), color: .orange)
            } else if state == .failed {
                failedView
            } else {
                chatView
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
        .onAppear { refresh() }
        .onChange(of: agent.id) { _ in refresh() }
        .onChange(of: apiKeyStore.configs) { _ in refresh() }
        .onChange(of: localService.detected) { _ in refreshLocalAfterDetect() }
        .alert(localization.text("delete_local_title"), isPresented: $showDeleteConfirm) {
            Button(localization.text("delete"), role: .destructive) {
                agentStore.delete(agent.id)
            }
            Button(localization.text("cancel"), role: .cancel) {}
        } message: {
            Text(localization.text("delete_local_message"))
        }
    }

    // MARK: - Local model views

    @ViewBuilder
    private var localBody: some View {
        if let provider = localService.provider(forAgent: agent) {
            if !localService.isDetected(provider.id) {
                if localService.installing[provider.id] == true {
                    installProgressView(provider)
                } else {
                    localInstallView(provider)
                }
            } else if state == .checking || state == .idle {
                statusView(icon: "arrow.triangle.2.circlepath", title: localization.text("local_connecting"), color: brandBlue)
            } else if state == .failed {
                failedView
            } else {
                chatView
            }
        } else {
            Spacer()
        }
    }

    private func localInstallView(_ provider: LocalProvider) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "externaldrive.badge.questionmark")
                    .font(.system(size: 24))
                    .foregroundStyle(brandBlue)
                VStack(alignment: .leading, spacing: 3) {
                    Text(localization.text("local_not_installed"))
                        .font(.system(size: 13, weight: .semibold))
                    Text(localization.text("local_not_installed_hint"))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    Task { await localService.detect(agent.id) }
                } label: {
                    Label(localization.text("recheck"), systemImage: "arrow.clockwise")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundStyle(brandBlue)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            VStack(alignment: .leading, spacing: 5) {
                Text(localization.text("local_install_script"))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                ScrollView {
                    Text(provider.installScript)
                        .font(.system(size: 11, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(8)
                }
                .frame(height: 96)
                .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
            }
            .padding(.horizontal, 16)

            HStack(spacing: 10) {
                Button {
                    localService.startInstall(provider)
                } label: {
                    Label(localization.text("install"), systemImage: "arrow.down.circle")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 110, height: 28)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    localService.openTerminalHandoff(provider)
                } label: {
                    Label(localization.text("open_terminal"), systemImage: "terminal")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 150, height: 28)
                }
                .buttonStyle(.bordered)

                Button {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(provider.installScript, forType: .string)
                } label: {
                    Label(localization.text("copy_install"), systemImage: "doc.on.doc")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(.horizontal, 16)

            if let status = localService.installStatus[provider.id], !status.isEmpty {
                Label(status, systemImage: "terminal")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func installProgressView(_ provider: LocalProvider) -> some View {
        VStack(spacing: 14) {
            ProgressView(value: localService.installProgress[provider.id] ?? 0, total: 1)
                .progressViewStyle(.linear)
                .frame(width: 260)
            Text(localService.installStatus[provider.id] ?? localization.text("local_installing"))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
            Button(localization.text("cancel")) {
                localService.cancelInstall(provider.id)
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var localChatHeader: some View {
        HStack(spacing: 8) {
            Text(localization.text("local_model"))
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
            if localService.isDetected(agent.id) {
                Label(localization.text("local_detected"), systemImage: "checkmark.circle.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(.green)
            }
            Spacer()
            Button {
                Task { await localService.detect(agent.id) }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .help(localization.text("recheck"))
            Button {
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .help(localization.text("delete_local_title"))
        }
        .padding(.horizontal, 12)
        .frame(height: 30)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var localModels: [String] {
        localService.modelList(for: agent.id)
    }

    private var localModelPicker: some View {
        Menu {
            ForEach(localModels, id: \.self) { model in
                Button(model) {
                    selectedModel = model
                }
            }
            if localModels.isEmpty {
                Text(localization.text("select_model"))
                    .font(.system(size: 11))
            }
            Divider()
            Button(localization.text("refresh")) {
                Task { await localService.detect(agent.id) }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "cpu")
                    .font(.system(size: 12))
                Text(selectedModel.isEmpty ? localization.text("select_model") : selectedModel)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundStyle(.primary)
            .frame(maxWidth: 150)
            .frame(height: 24)
            .padding(.horizontal, 6)
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }

    private struct APIModelEntry {
        let config: AgentAPIConfig
        let credential: APICredential
    }

    private var apiModelEntries: [APIModelEntry] {
        guard let config = apiKeyStore.config(forAgentID: agent.id) else { return [] }
        return config.credentials
            .filter { !apiKeyStore.apiKey(for: $0.id).isEmpty }
            .map { APIModelEntry(config: config, credential: $0) }
    }

    private var activeAPIModelName: String {
        apiModelEntries.first(where: { $0.credential.isActive })?.credential.model
            ?? apiModelEntries.first?.credential.model
            ?? localization.text("select_model")
    }

    private var apiModelPicker: some View {
        Menu {
            ForEach(apiModelEntries, id: \.credential.id) { entry in
                Button {
                    apiKeyStore.setActiveCredential(configID: entry.config.id, credentialID: entry.credential.id)
                } label: {
                    if entry.credential.isActive {
                        Label(entry.credential.model, systemImage: "checkmark")
                    } else {
                        Text(entry.credential.model)
                    }
                }
            }
            if apiModelEntries.isEmpty {
                Text(localization.text("select_model"))
                    .font(.system(size: 11))
            }
            Divider()
            Button(action: onAddCredential) {
                Label(localization.text("add_new"), systemImage: "plus")
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "cpu")
                    .font(.system(size: 12))
                Text(activeAPIModelName)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
            .frame(maxWidth: 150)
            .frame(height: 24)
            .padding(.horizontal, 6)
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }

    private func refreshLocalAfterDetect() {
        guard agent.isLocal, let provider = localService.provider(forAgent: agent) else { return }
        if localService.isDetected(provider.id) {
            if selectedModel.isEmpty, let first = localService.modelList(for: agent.id).first {
                selectedModel = first
            }
            state = .ready
        } else if localService.installing[provider.id] != true {
            state = .idle
        }
    }

    // MARK: - Cloud API views

    private var noKeyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "key.slash")
                .font(.system(size: 30))
                .foregroundStyle(.yellow)
            Text(localization.text("api_not_configured"))
                .font(.headline)
            Text(localization.text("api_not_configured_hint"))
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
                .padding(.horizontal, 18)
            Button {
                onOpenSettings()
            } label: {
                Label(localization.text("go_configure"), systemImage: "arrow.right")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var failedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 30))
                .foregroundStyle(.red)
            Text(errorText.isEmpty ? localization.text("api_failed") : errorText)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            if !errorDetail.isEmpty {
                VStack(spacing: 6) {
                    Text(errorDetail)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .padding(.horizontal, 24)
                    Button {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(errorDetail, forType: .string)
                    } label: {
                        Label(localization.text("copy_detail"), systemImage: "doc.on.doc")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
            }
            HStack(spacing: 10) {
                Button(localization.text("retry")) { refresh() }
                if !agent.isLocal {
                    Button(localization.text("go_configure")) { onOpenSettings() }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func friendlyError(_ error: Error) -> String {
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain {
            return localization.text("api_network_error")
        }
        if let detail = ns.userInfo[NSLocalizedDescriptionKey] as? String {
            let lower = detail.lowercased()
            if lower.contains("余额") || lower.contains("balance") || lower.contains("insufficient") || lower.contains("充值") || lower.contains("top up") {
                return localization.text("api_insufficient_balance")
            }
            if ns.domain == "AgentsBin", ns.code == 4, !detail.isEmpty, detail != "API error" {
                return detail
            }
        }
        switch ns.code {
        case 401, 403:
            return localization.text("api_key_invalid")
        case 429:
            return localization.text("api_rate_limited")
        default:
            return localization.text("api_failed")
        }
    }

    private var chatView: some View {
        VStack(spacing: 0) {
            if agent.isLocal {
                localChatHeader
            }
            ScrollView {
                LazyVStack(spacing: 8) {
                    if messages.isEmpty {
                        Text(localization.text("client_empty"))
                            .font(.system(size: 12))
                            .foregroundStyle(.tertiary)
                            .padding(.top, 40)
                    }
                    ForEach(messages) { message in
                        messageBubble(message)
                    }
                }
                .padding(12)
            }
            HStack(spacing: 8) {
                if agent.isLocal {
                    localModelPicker
                }
                if !agent.isLocal {
                    apiModelPicker
                }
                TextField(localization.text("client_placeholder"), text: $input)
                    .textFieldStyle(.roundedBorder)
                    .frame(height: 24)
                    .onSubmit { send() }
                Button {
                    send()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(sending ? Color.secondary : brandBlue)
                }
                .buttonStyle(.plain)
                .disabled(sending)
            }
            .padding(10)
            .background(.bar)
        }
    }

    private func messageBubble(_ message: ClientChatMessage) -> some View {
        HStack {
            if message.role == "user" { Spacer(minLength: 60) }
            Text(message.content)
                .font(.system(size: 13))
                .foregroundStyle(message.role == "user" ? Color.white : Color.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    message.role == "user" ? brandBlue : Color(nsColor: .controlBackgroundColor),
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .textSelection(.enabled)
            if message.role == "assistant" { Spacer(minLength: 60) }
        }
    }

    private func statusView(icon: String, title: String, color: Color) -> some View {
        VStack(spacing: 10) {
            ProgressView()
            Text(title)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func refresh() {
        if agent.isLocal {
            messages = []
            if let provider = localService.provider(forAgent: agent) {
                if localService.isDetected(provider.id) {
                    if selectedModel.isEmpty, let first = localService.modelList(for: agent.id).first {
                        selectedModel = first
                    }
                    state = .ready
                } else {
                    state = .idle
                    Task { await localService.detect(agent.id) }
                }
            }
            return
        }
        guard let cred = apiKeyStore.credential(forAgentID: agent.id) else {
            state = .idle
            messages = []
            return
        }
        if apiKeyStore.isVerified(forAgentID: agent.id, credential: cred.credential), state != .failed {
            state = .ready
            return
        }
        if state != .ready {
            state = .checking
            verifyCredential()
        }
    }

    private func verifyCredential() {
        let ping = ClientChatMessage(role: "user", content: "ping")
        performRequest(messages: [ping]) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    state = .ready
                    if let cred = apiKeyStore.credential(forAgentID: agent.id) {
                        apiKeyStore.markVerified(forAgentID: agent.id, credential: cred.credential)
                    }
                case .failure(let error):
                    state = .failed
                    errorDetail = error.localizedDescription
                    errorText = friendlyError(error)
                }
            }
        }
    }

    private func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !sending else { return }
        input = ""
        let userMessage = ClientChatMessage(role: "user", content: text)
        messages.append(userMessage)
        sending = true
        let requestMessages = messages
        performRequest(messages: requestMessages) { result in
            DispatchQueue.main.async {
                sending = false
                switch result {
                case .success(let reply):
                    messages.append(ClientChatMessage(role: "assistant", content: reply))
                case .failure(let error):
                    errorDetail = error.localizedDescription
                    let detail = error.localizedDescription
                    let bubble = detail.isEmpty || friendlyError(error) == detail
                        ? "[Error] " + friendlyError(error)
                        : "[Error] " + friendlyError(error) + "\n" + detail
                    messages.append(ClientChatMessage(role: "assistant", content: bubble))
                }
            }
        }
    }

    private func performRequest(messages: [ClientChatMessage], completion: @escaping (Result<String, Error>) -> Void) {
        if agent.isLocal {
            guard let provider = localService.provider(forAgent: agent) else {
                completion(.failure(NSError(domain: "AgentsBin", code: 1, userInfo: [NSLocalizedDescriptionKey: "Local provider unavailable"])))
                return
            }
            performLocalRequest(provider: provider, messages: messages, completion: completion)
            return
        }
        guard let cred = apiKeyStore.credential(forAgentID: agent.id) else {
            completion(.failure(NSError(domain: "AgentsBin", code: 1, userInfo: [NSLocalizedDescriptionKey: "No API key"])))
            return
        }
        let base = cred.credential.baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let isAnthropic = cred.config.id == "anthropic" || base.lowercased().contains("anthropic.com")
        let endpoint: URL
        if isAnthropic {
            guard let url = URL(string: base + "/v1/messages") else {
                completion(.failure(NSError(domain: "AgentsBin", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid base URL"])))
                return
            }
            endpoint = url
        } else {
            guard let url = URL(string: base + "/chat/completions") else {
                completion(.failure(NSError(domain: "AgentsBin", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid base URL"])))
                return
            }
            endpoint = url
        }
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var body: [String: Any]
        if isAnthropic {
            request.setValue(cred.apiKey, forHTTPHeaderField: "x-api-key")
            request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
            body = [
                "model": cred.credential.model,
                "max_tokens": 1024,
                "messages": messages.map { ["role": $0.role, "content": $0.content] }
            ]
        } else {
            request.setValue("Bearer " + cred.apiKey, forHTTPHeaderField: "Authorization")
            body = [
                "model": cred.credential.model,
                "stream": false,
                "messages": messages.map { ["role": $0.role, "content": $0.content] }
            ]
        }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let http = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "AgentsBin", code: 3, userInfo: [NSLocalizedDescriptionKey: "No HTTP response"])))
                return
            }
            guard (200..<300).contains(http.statusCode) else {
                let bodyText = String(data: data ?? Data(), encoding: .utf8) ?? ""
                let detail = String(bodyText.prefix(240))
                completion(.failure(NSError(domain: "AgentsBin", code: http.statusCode, userInfo: [
                    NSLocalizedDescriptionKey: "HTTP " + String(http.statusCode) + ": " + detail
                ])))
                return
            }
            guard let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(.failure(NSError(domain: "AgentsBin", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            if isAnthropic {
                if let blocks = json["content"] as? [[String: Any]],
                   let first = blocks.first,
                   let text = first["text"] as? String {
                    completion(.success(text))
                } else {
                    completion(.failure(apiError(json)))
                }
            } else {
                if let choices = json["choices"] as? [[String: Any]],
                   let first = choices.first,
                   let message = first["message"] as? [String: Any],
                   let text = message["content"] as? String {
                    completion(.success(text))
                } else {
                    completion(.failure(apiError(json)))
                }
            }
        }.resume()
    }

    private func performLocalRequest(provider: LocalProvider, messages: [ClientChatMessage], completion: @escaping (Result<String, Error>) -> Void) {
        let base = "http://" + provider.urlString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: base + "/v1/chat/completions") else {
            completion(.failure(NSError(domain: "AgentsBin", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid local URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 120
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let model = selectedModel.isEmpty ? (localService.modelList(for: agent.id).first ?? "default") : selectedModel
        let body: [String: Any] = [
            "model": model,
            "stream": false,
            "messages": messages.map { ["role": $0.role, "content": $0.content] }
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let http = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "AgentsBin", code: 3, userInfo: [NSLocalizedDescriptionKey: "No HTTP response"])))
                return
            }
            guard (200..<300).contains(http.statusCode) else {
                completion(.failure(NSError(domain: "AgentsBin", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "Local model request failed"])))
                return
            }
            guard let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(.failure(NSError(domain: "AgentsBin", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            if let choices = json["choices"] as? [[String: Any]],
               let first = choices.first,
               let message = first["message"] as? [String: Any],
               let text = message["content"] as? String {
                completion(.success(text))
            } else {
                completion(.failure(apiError(json)))
            }
        }.resume()
    }

    private func apiError(_ json: [String: Any]) -> Error {
        let message: String
        if let error = json["error"] as? [String: Any], let msg = error["message"] as? String {
            message = msg
        } else if let msg = json["msg"] as? String {
            message = msg
        } else if let msg = json["message"] as? String {
            message = msg
        } else if let code = json["code"] as? Int {
            message = "API error (\(code))"
        } else {
            message = "API error"
        }
        return NSError(domain: "AgentsBin", code: 4, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
