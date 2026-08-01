import Foundation

struct AgentAdapter {
    let inputSelector: String
    let sendSelector: String
    let answerSelector: String
    let loginSelector: String
    let isContentEditable: Bool?
    let useEnter: Bool
}

extension Agent {
    var adapter: AgentAdapter {
        switch id {
        case "chatgpt":
            return AgentAdapter(
                inputSelector: "#prompt-textarea, textarea[data-testid='prompt-textarea'], textarea[placeholder]",
                sendSelector: "button[data-testid='send-button'], button[aria-label*='Send' i], form button[type='submit']",
                answerSelector: "[data-message-author-role='assistant'], .markdown, .markdown-body, [class*='message'], [class*='answer'], [class*='chat'], [class*='content'], [class*='bubble'], [class*='reply'], [data-testid*='message']",
                loginSelector: "[data-testid='user-avatar'], nav a[href*='/c/'], button[aria-label*='avatar' i]",
                isContentEditable: nil,
                useEnter: false
            )
        case "claude":
            return AgentAdapter(
                inputSelector: "div[contenteditable='true'], [contenteditable='true'], textarea",
                sendSelector: "button[aria-label*='Send' i], button[type='submit']",
                answerSelector: "[data-testid='assistant-message'], .font-claude-message, .markdown, [class*='message'], [class*='content'], [class*='bubble'], [class*='reply']",
                loginSelector: "[data-testid='username-menu'], button[aria-label*='account' i], [class*='avatar']",
                isContentEditable: true,
                useEnter: true
            )
        case "gemini":
            return AgentAdapter(
                inputSelector: "rich-textarea .ql-editor, .ql-editor[contenteditable='true'], textarea",
                sendSelector: "button[aria-label*='Send' i], button[type='submit']",
                answerSelector: "model-response, .model-response-text, .markdown, [class*='message'], [class*='content'], [class*='bubble'], [class*='reply']",
                loginSelector: "[data-testid='avatar'], button[aria-label*='profile' i], [class*='avatar']",
                isContentEditable: true,
                useEnter: false
            )
        case "deepseek":
            return AgentAdapter(
                inputSelector: "textarea#chat-input, textarea[placeholder]",
                sendSelector: "div[role='button'][aria-disabled='false'], button[type='submit']",
                answerSelector: ".ds-markdown, .markdown, .markdown-body, [class*='message'], [class*='content'], [class*='bubble'], [class*='reply']",
                loginSelector: "[class*='user-avatar'], button[aria-label*='avatar' i], [class*='avatar']",
                isContentEditable: nil,
                useEnter: false
            )
        case "qwen":
            return AgentAdapter(
                inputSelector: "textarea, [contenteditable='true']",
                sendSelector: "button[type='submit'], button[aria-label*='Send' i]",
                answerSelector: ".markdown, .markdown-body, [class*='message'], [class*='answer'], [class*='content'], [class*='bubble'], [class*='reply']",
                loginSelector: "[class*='avatar'], button[aria-label*='user' i], [class*='user-menu']",
                isContentEditable: nil,
                useEnter: true
            )
        case "doubao":
            return AgentAdapter(
                inputSelector: "[contenteditable='true'], textarea, #chat-input, .chat-input, textarea[placeholder]",
                sendSelector: "button[aria-label*='发送'], button[title*='发送'], button[aria-label*='Send' i], button[class*='send' i], button[type='submit'], [role='button'][aria-disabled='false']",
                answerSelector: ".markdown, .markdown-body, [class*='message'], [class*='chat'], [class*='answer'], [class*='content'], [class*='bubble'], [class*='reply'], [data-testid*='message']",
                loginSelector: "[class*='avatar'], [class*='user-menu'], [class*='user-info']",
                isContentEditable: true,
                useEnter: true
            )
        case "yuanbao":
            return AgentAdapter(
                inputSelector: "textarea, [contenteditable='true']",
                sendSelector: "button[type='submit'], button[aria-label*='Send' i]",
                answerSelector: ".markdown, .markdown-body, [class*='message'], [class*='answer'], [class*='content'], [class*='bubble'], [class*='reply']",
                loginSelector: "[class*='avatar'], [class*='user-menu']",
                isContentEditable: nil,
                useEnter: true
            )
        default:
            return AgentAdapter(
                inputSelector: "textarea[placeholder], textarea, [contenteditable='true']",
                sendSelector: "button[type='submit'], button[aria-label*='Send' i]",
                answerSelector: ".markdown, .markdown-body, [class*='message'], [class*='answer'], [class*='content'], [class*='bubble'], [class*='reply']",
                loginSelector: "[class*='avatar'], [aria-label*='avatar' i], [class*='user-menu']",
                isContentEditable: nil,
                useEnter: true
            )
        }
    }
}
