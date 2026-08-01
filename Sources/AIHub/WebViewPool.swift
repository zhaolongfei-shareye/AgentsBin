import Combine
import SwiftUI
import WebKit

final class WebViewPool: ObservableObject {
    var onAnswerText: ((String, String) -> Void)?

    private static func doubaoDarkModeScript() -> String? {
        """
        (function() {
          const style = document.createElement('style');
          style.id = 'aihome-doubao-dark';
          style.textContent = `
            :root { color-scheme: dark; }
            html { filter: invert(1) hue-rotate(180deg) !important; background: #111 !important; }
            img, video, iframe, canvas { filter: invert(1) hue-rotate(180deg) !important; }
          `;
          document.documentElement.appendChild(style);
        })();
        """
    }

    @Published private(set) var webViews: [String: WKWebView] = [:]
    @Published private(set) var unreadIDs: Set<String> = []
    @Published private(set) var statusByAgent: [String: String] = [:]
    @Published private(set) var answersByAgent: [String: String] = [:]
    @Published private(set) var loggedInIDs: Set<String> = []

    private var timers: [String: Timer] = [:]
    private var checks: [String: Int] = [:]
    private var sendRetries: [String: Int] = [:]
    private var loginTimers: [String: Timer] = [:]
    private var loginChecks: [String: Int] = [:]
    private var lastPrompt: [String: String] = [:]
    private var baselineByAgent: [String: String] = [:]
    private var pendingAnswers: [String: String] = [:]
    private var stableCounts: [String: Int] = [:]
    private var monitorTimers: [String: Timer] = [:]
    private var monitorBaseline: [String: String] = [:]
    private var lastMonitorText: [String: String] = [:]
    private var monitorStable: [String: Int] = [:]

    func webView(for agent: Agent) -> WKWebView {
        if let existing = webViews[agent.id] {
            return existing
        }
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        if agent.id == "doubao", let script = Self.doubaoDarkModeScript() {
            config.userContentController.addUserScript(
                WKUserScript(
                    source: script,
                    injectionTime: .atDocumentStart,
                    forMainFrameOnly: false
                )
            )
        }
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
        webViews[agent.id] = webView
        load(agent, in: webView)
        startLoginCheck(for: agent)
        return webView
    }

    func isLoggedIn(_ id: String) -> Bool {
        loggedInIDs.contains(id)
    }

    func attach(_ agent: Agent) {
        _ = webView(for: agent)
        startMonitoring(for: agent)
    }

    func broadcast(prompt: String, to agents: [Agent], activeID: String?) {
        for agent in agents {
            answersByAgent[agent.id] = ""
            statusByAgent[agent.id] = "sending"
            unreadIDs.remove(agent.id)
            sendWithRetry(prompt: prompt, to: agent, activeID: activeID, attempt: 0)
        }
    }

    func markRead(_ id: String) {
        unreadIDs.remove(id)
    }

    func captureLastAnswer(for agent: Agent, completion: @escaping (String) -> Void) {
        guard let webView = webViews[agent.id] else {
            completion("")
            return
        }
        let selector = jsString(agent.adapter.answerSelector)
        let script = """
        (function() {
          const els = document.querySelectorAll("\(selector)");
          const texts = [];
          for (const el of els) {
            const s = (el.innerText || el.textContent || '').trim();
            if (s) texts.push(s);
          }
          return texts.length ? texts[texts.length - 1] : '';
        })()
        """
        webView.evaluateJavaScript(script) { result, _ in
            DispatchQueue.main.async {
                completion((result as? String) ?? "")
            }
        }
    }

    func status(for id: String) -> String {
        statusByAgent[id] ?? "idle"
    }

    private func load(_ agent: Agent, in webView: WKWebView) {
        let target = agent.urlString.hasPrefix("http") ? agent.urlString : "https://" + agent.urlString
        if let url = URL(string: target) {
            webView.load(URLRequest(url: url))
        }
    }

    private func sendWithRetry(prompt: String, to agent: Agent, activeID: String?, attempt: Int) {
        let webView = webView(for: agent)
        stopCheck(for: agent.id)
        lastPrompt[agent.id] = prompt
        captureBaseline(for: agent) { [weak self] baseline in
            guard let self else { return }
            self.baselineByAgent[agent.id] = baseline
            self.performSend(prompt: prompt, to: agent, activeID: activeID, attempt: attempt, webView: webView)
        }
    }

    private func captureBaseline(for agent: Agent, completion: @escaping (String) -> Void) {
        guard let webView = webViews[agent.id] else {
            completion("")
            return
        }
        let selector = jsString(agent.adapter.answerSelector)
        let script = """
        (function() {
          const els = document.querySelectorAll("\(selector)");
          let t = '';
          for (const el of els) {
            const s = (el.innerText || el.textContent || '').trim();
            if (s.length > t.length) t = s;
          }
          return t;
        })()
        """
        webView.evaluateJavaScript(script) { result, _ in
            DispatchQueue.main.async {
                completion((result as? String) ?? "")
            }
        }
    }

    private func performSend(prompt: String, to agent: Agent, activeID: String?, attempt: Int, webView: WKWebView) {

        let adapter = agent.adapter
        let escaped = prompt
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
        let inputSelector = jsString(adapter.inputSelector)
        let sendSelector = jsString(adapter.sendSelector)
        let script = """
        (function() {
          const p = "\(escaped)";
          const inputSelector = "\(inputSelector)";
          const sendSelector = "\(sendSelector)";
          const candidates = document.querySelectorAll(inputSelector);
          let target = null;
          for (const el of candidates) {
            if (el.offsetParent !== null || el.getClientRects().length) {
              target = el;
              break;
            }
          }
          if (!target) return 'no-input';
          if (target.tagName === 'TEXTAREA') {
            const setter = Object.getOwnPropertyDescriptor(window.HTMLTextAreaElement.prototype, 'value').set;
            setter.call(target, p);
            target.dispatchEvent(new Event('input', { bubbles: true }));
          } else {
            target.focus();
            target.dispatchEvent(new Event('focus', { bubbles: true }));
            document.execCommand('selectAll', false, null);
            document.execCommand('insertText', false, p);
            target.dispatchEvent(new InputEvent('input', { data: p, inputType: 'insertText', bubbles: true, composed: true }));
          }
          target.dispatchEvent(new Event('change', { bubbles: true }));
          const buttons = document.querySelectorAll(sendSelector);
          let button = null;
          for (const el of buttons) {
            if (!el.disabled && (el.offsetParent !== null || el.getClientRects().length)) {
              button = el;
              break;
            }
          }
          if (button) { button.click(); return 'sent-click'; }
          target.dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter', code: 'Enter', bubbles: true }));
          target.dispatchEvent(new KeyboardEvent('keyup', { key: 'Enter', code: 'Enter', bubbles: true }));
          return 'sent-enter';
        })()
        """

        webView.evaluateJavaScript(script) { [weak self] result, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                let status = (result as? String) ?? "unknown"
                if status == "no-input" {
                    if attempt < 8 {
                        self.sendRetries[agent.id] = attempt + 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.sendWithRetry(prompt: prompt, to: agent, activeID: activeID, attempt: attempt + 1)
                        }
                    } else {
                        self.statusByAgent[agent.id] = "no-input"
                    }
                } else {
                    self.statusByAgent[agent.id] = "sent"
                    self.startAnswerCheck(for: agent, activeID: activeID)
                }
            }
        }
    }

    private func startAnswerCheck(for agent: Agent, activeID: String?) {
        stopCheck(for: agent.id)
        checks[agent.id] = 0
        pendingAnswers[agent.id] = nil
        stableCounts[agent.id] = 0
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkAnswerOnce(for: agent, activeID: activeID)
        }
        RunLoop.main.add(timer, forMode: .common)
        timers[agent.id] = timer
    }

    private func checkAnswerOnce(for agent: Agent, activeID: String?) {
        let count = (checks[agent.id] ?? 0) + 1
        checks[agent.id] = count
        if count >= 60 {
            if pendingAnswers[agent.id] != nil {
                statusByAgent[agent.id] = "answered"
            }
            stopCheck(for: agent.id)
            return
        }
        guard let webView = webViews[agent.id] else {
            stopCheck(for: agent.id)
            return
        }
        let selector = jsString(agent.adapter.answerSelector)
        guard !selector.isEmpty else {
            stopCheck(for: agent.id)
            return
        }
        let escapedPrompt = jsString(lastPrompt[agent.id] ?? "")
        let script = """
        (function() {
          const els = document.querySelectorAll("\(selector)");
          const p = "\(escapedPrompt)";
          const texts = [];
          for (const el of els) {
            const s = (el.innerText || el.textContent || '').trim();
            if (s && s !== p && s.indexOf(p) !== 0) texts.push(s);
          }
          return texts.length ? texts[texts.length - 1] : '';
        })()
        """
        webView.evaluateJavaScript(script) { [weak self] result, _ in
            DispatchQueue.main.async {
                guard let self, let text = result as? String else { return }
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                if trimmed == self.lastPrompt[agent.id] { return }
                if trimmed == self.baselineByAgent[agent.id] { return }

                if trimmed != self.pendingAnswers[agent.id] {
                    self.pendingAnswers[agent.id] = trimmed
                    self.stableCounts[agent.id] = 0
                    self.statusByAgent[agent.id] = "generating"
                    self.answersByAgent[agent.id] = trimmed
                    if agent.id != activeID {
                        self.unreadIDs.insert(agent.id)
                    }
                    self.onAnswerText?(agent.id, trimmed)
                } else {
                    let stable = (self.stableCounts[agent.id] ?? 0) + 1
                    self.stableCounts[agent.id] = stable
                    if stable >= 3 || count >= 60 {
                        self.statusByAgent[agent.id] = "answered"
                        self.stopCheck(for: agent.id)
                    }
                }
            }
        }
    }

    private func stopCheck(for id: String) {
        timers[id]?.invalidate()
        timers[id] = nil
        checks[id] = nil
        pendingAnswers[id] = nil
        stableCounts[id] = nil
    }

    private func startLoginCheck(for agent: Agent) {
        stopLoginCheck(for: agent.id)
        loginChecks[agent.id] = 0
        let timer = Timer(timeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkLoginOnce(for: agent)
        }
        RunLoop.main.add(timer, forMode: .common)
        loginTimers[agent.id] = timer
    }

    private func checkLoginOnce(for agent: Agent) {
        let count = (loginChecks[agent.id] ?? 0) + 1
        loginChecks[agent.id] = count
        if count > 10 {
            stopLoginCheck(for: agent.id)
            return
        }
        guard let webView = webViews[agent.id] else {
            stopLoginCheck(for: agent.id)
            return
        }
        let selector = jsString(agent.adapter.loginSelector)
        let script = "document.querySelector(\"\(selector)\") ? true : false"
        webView.evaluateJavaScript(script) { [weak self] result, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                if let loggedIn = result as? Bool, loggedIn {
                    self.loggedInIDs.insert(agent.id)
                    self.stopLoginCheck(for: agent.id)
                }
            }
        }
    }

    private func stopLoginCheck(for id: String) {
        loginTimers[id]?.invalidate()
        loginTimers[id] = nil
        loginChecks[id] = nil
    }

    private func startMonitoring(for agent: Agent) {
        guard monitorTimers[agent.id] == nil else { return }
        monitorBaseline[agent.id] = nil
        lastMonitorText[agent.id] = nil
        monitorStable[agent.id] = 0
        let timer = Timer(timeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.monitorOnce(for: agent)
        }
        RunLoop.main.add(timer, forMode: .common)
        monitorTimers[agent.id] = timer
    }

    private func monitorOnce(for agent: Agent) {
        guard let webView = webViews[agent.id] else { return }
        let selector = jsString(agent.adapter.answerSelector)
        guard !selector.isEmpty else { return }
        let script = """
        (function() {
          const els = document.querySelectorAll("\(selector)");
          const texts = [];
          for (const el of els) {
            const s = (el.innerText || el.textContent || '').trim();
            if (s) texts.push(s);
          }
          return texts.length ? texts[texts.length - 1] : '';
        })()
        """
        webView.evaluateJavaScript(script) { [weak self] result, _ in
            DispatchQueue.main.async {
                guard let self, let text = result as? String else { return }
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                if self.monitorBaseline[agent.id] == nil {
                    self.monitorBaseline[agent.id] = trimmed
                    self.lastMonitorText[agent.id] = trimmed
                    return
                }
                if trimmed != self.lastMonitorText[agent.id] {
                    self.lastMonitorText[agent.id] = trimmed
                    self.monitorStable[agent.id] = 0
                    self.statusByAgent[agent.id] = "generating"
                    self.answersByAgent[agent.id] = trimmed
                    self.onAnswerText?(agent.id, trimmed)
                } else {
                    let stable = (self.monitorStable[agent.id] ?? 0) + 1
                    self.monitorStable[agent.id] = stable
                    if stable >= 3 {
                        self.statusByAgent[agent.id] = "answered"
                    }
                }
            }
        }
    }

    private func jsString(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}

struct WebViewPoolView: NSViewRepresentable {
    let agent: Agent
    let pool: WebViewPool

    func makeNSView(context: Context) -> WKWebView {
        pool.attach(agent)
        return pool.webView(for: agent)
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
