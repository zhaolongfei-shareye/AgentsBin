import SwiftUI

struct ClientChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: String
    let content: String
}

struct ClientChatView: View {
    let agent: Agent
    var onOpenSettings: () -> Void = {}

    @EnvironmentObject private var apiKeyStore: APIKeyStore
    @EnvironmentObject private var localization: LocalizedStore

    @State private var messages: [ClientChatMessage] = []
    @State private var input = ""
    @State private var state = StateValue.idle
    @State private var errorText = ""
    @State private var errorDetail = ""
    @State private var sending = false

    enum StateValue {
        case idle, checking, ready, failed
    }

    var body: some View {
        VStack(spacing: 0) {
            if apiKeyStore.credential(forAgentID: agent.id) == nil {
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
    }

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
            HStack(spacing: 10) {
                Button(localization.text("retry")) { refresh() }
                Button(localization.text("go_configure")) { onOpenSettings() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func friendlyError(_ error: Error) -> String {
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain {
            return localization.text("api_network_error")
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
                TextField(localization.text("client_placeholder"), text: $input)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { send() }
                Button {
                    send()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 22))
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
        guard apiKeyStore.credential(forAgentID: agent.id) != nil else {
            state = .idle
            messages = []
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
                    messages.append(ClientChatMessage(role: "assistant", content: "[Error] " + friendlyError(error)))
                }
            }
        }
    }

    private func performRequest(messages: [ClientChatMessage], completion: @escaping (Result<String, Error>) -> Void) {
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

    private func apiError(_ json: [String: Any]) -> Error {
        let message: String
        if let error = json["error"] as? [String: Any], let msg = error["message"] as? String {
            message = msg
        } else {
            message = "API error"
        }
        return NSError(domain: "AgentsBin", code: 4, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
