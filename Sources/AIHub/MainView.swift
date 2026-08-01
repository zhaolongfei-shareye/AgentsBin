import AppKit
import SwiftUI
import UniformTypeIdentifiers

enum SidePanel: String, CaseIterable {
    case agents = "智能体"
    case notes = "知识库"
}

enum RightMode {
    case chat
    case note(UUID)
    case knowledge(String)
    case manage
}

struct DailySummary: Identifiable {
    let id: String
    let date: Date
    let agentID: String
    let agentName: String
    let entryID: UUID
    let fullText: String
    let summaryText: String
    let modelInfo: String
    let summaryStatus: String
}

struct LetterToolbarButton: View {
    let letter: String
    let color: Color
    let title: String
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            Text(letter)
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(color, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hovered = hovering
        }
        .overlay(alignment: .bottom) {
            if hovered {
                Text(title)
                    .font(.system(size: 11))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
                    .shadow(radius: 4)
                    .offset(y: 38)
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.12), value: hovered)
    }
}

struct ToolbarTextButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .frame(height: 28)
            .background(hovered ? Color.primary.opacity(0.08) : Color.clear, in: RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hovered = hovering
        }
        .help(title)
    }
}

extension Color {
    init(hex: String) {
        var value: UInt64 = 0
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        Scanner(string: cleaned).scanHexInt64(&value)
        let red = Double((value >> 16) & 0xff) / 255
        let green = Double((value >> 8) & 0xff) / 255
        let blue = Double(value & 0xff) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

private let brandBlue = Color(red: 0.04, green: 0.46, blue: 0.95)

struct MainPopoverView: View {
    @EnvironmentObject private var agentStore: AgentStore
    @EnvironmentObject private var noteStore: NoteStore
    @EnvironmentObject private var webPool: WebViewPool
    @EnvironmentObject private var conversationStore: ConversationStore
    @EnvironmentObject private var faviconStore: FaviconStore
    @EnvironmentObject private var knowledgeStore: KnowledgeStore
    @EnvironmentObject private var aiSummary: AISummaryStore
    @EnvironmentObject private var localization: LocalizedStore
    @State private var panel: SidePanel = .agents
    @State private var mode: RightMode = .chat
    @State private var searchText = ""
    @State private var hoveredAgentID: String?
    @State private var selectedSummaryID: String?
    @State private var draggedAgentID: String?
    @State private var isDarkAppearance = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    @State private var justSavedKnowledge = false

    var body: some View {
        VStack(spacing: 0) {
            header
            HStack(spacing: 0) {
                sidebar
                    .frame(width: 224)
                Divider()
                VStack(spacing: 0) {
                    rightPane
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(nsColor: .textBackgroundColor))
                    if case .chat = mode {
                        rightBottomBar
                    }
                }
            }
        }
        .frame(minWidth: 900, minHeight: 640)
        .onAppear {
            faviconStore.ensureLoaded(for: agentStore.agents)
        }
        .onChange(of: agentStore.agents) { _ in
            faviconStore.ensureLoaded(for: agentStore.agents)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("AgentsBin")
                .font(.system(size: 22, weight: .heavy))
            Text(localization.text("beta_note"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.quaternary, in: Capsule())
            Spacer()
            avatar(agentStore.activeAgent)
            Text(localization.agentName(agentStore.activeAgent.name))
                .font(.system(size: 20, weight: .heavy))
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
        .background(.bar)
    }

    private var rightBottomBar: some View {
        HStack(spacing: 8) {
            Spacer()
            ToolbarTextButton(
                icon: justSavedKnowledge ? "checkmark.circle.fill" : "book.closed.fill",
                title: localization.text("add_knowledge")
            ) {
                saveLatestToKnowledge()
            }
            ToolbarTextButton(
                icon: "arrow.up.right.square",
                title: localization.text("browser")
            ) {
                openExternal(agentStore.activeAgent.urlString)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(.bar)
    }

    private var sidebar: some View {
        VStack(spacing: 8) {
            Picker("", selection: $panel) {
                ForEach(SidePanel.allCases, id: \.self) { item in
                    Text(localization.text(item == .agents ? "agents_tab" : "notes_tab")).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            if panel == .agents {
                agentList
            } else {
                noteList
            }

            Divider()
            HStack(spacing: 6) {
                Image(systemName: "globe")
                    .foregroundStyle(.secondary)
                Picker("", selection: $localization.language) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    toggleAppearance()
                } label: {
                    Image(systemName: isDarkAppearance ? "sun.max.fill" : "moon.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
                .help(isDarkAppearance ? localization.text("light_mode") : localization.text("dark_mode"))

                Button {
                    mode = .manage
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
                .help(localization.text("settings"))
                Button {
                    NSApp.terminate(nil)
                } label: {
                    Image(systemName: "power")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
                .help(localization.text("quit"))
            }
        }
        .onChange(of: panel) { newPanel in
            if newPanel == .notes {
                if selectedSummaryID == nil {
                    selectedSummaryID = dailySummaries.first?.id
                }
                if let id = selectedSummaryID {
                    mode = .knowledge(id)
                }
            } else if newPanel == .agents {
                mode = .chat
            }
        }
        .padding(10)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func toggleAppearance() {
        let dark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        NSApp.appearance = dark ? NSAppearance(named: .aqua) : NSAppearance(named: .darkAqua)
        isDarkAppearance = !dark
        if let name = NSApp.appearance?.name.rawValue {
            UserDefaults.standard.set(name, forKey: "aihome.appearance")
        }
    }

    private var agentList: some View {
        ScrollView {
            VStack(spacing: 2) {
                ForEach(agentStore.enabledAgents) { agent in
                    agentRow(agent)
                }
            }
        }
    }

    private func agentRow(_ agent: Agent) -> some View {
        let isActive = agentStore.activeID == agent.id
        return Button {
            agentStore.select(agent.id)
            webPool.markRead(agent.id)
            mode = .chat
        } label: {
            HStack(spacing: 8) {
                avatar(agent)
                VStack(alignment: .leading, spacing: 1) {
                    Text(localization.agentName(agent.name))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isActive ? Color.white : Color.primary)
                        .lineLimit(1)
                    Text(agent.urlString)
                        .font(.system(size: 10))
                        .foregroundStyle(isActive ? Color.white.opacity(0.75) : Color.secondary)
                        .lineLimit(1)
                }
                if webPool.unreadIDs.contains(agent.id) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .overlay(Circle().stroke(.white, lineWidth: 1))
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                isActive ? brandBlue : hoveredAgentID == agent.id ? brandBlue.opacity(0.10) : Color.clear,
                in: RoundedRectangle(cornerRadius: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(hoveredAgentID == agent.id ? brandBlue.opacity(0.45) : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
            .onHover { hovering in
                hoveredAgentID = hovering ? agent.id : nil
            }
        }
        .buttonStyle(.plain)
        .onDrag {
            draggedAgentID = agent.id
            return NSItemProvider(object: agent.id as NSString)
        }
        .onDrop(of: [.text], isTargeted: nil) { _ in
            handleAgentDrop(targetID: agent.id)
            return true
        }
    }

    private func avatar(_ agent: Agent) -> some View {
        if let image = faviconStore.images[agent.id] {
            return AnyView(
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 26, height: 26)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            )
        }
        return AnyView(
            Text(agent.letter)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(Color(hex: agent.colorHex), in: RoundedRectangle(cornerRadius: 8))
        )
    }

    private var noteList: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField(localization.text("search_notes"), text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 8)
            .frame(height: 28)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(filteredDailySummaries) { summary in
                        dailySummaryRow(summary)
                    }
                }
            }
            Text(localization.format("notes_count", filteredDailySummaries.count))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .onAppear {
            if selectedSummaryID == nil {
                selectedSummaryID = dailySummaries.first?.id
            }
        }
    }

    private var filteredDailySummaries: [DailySummary] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let all = dailySummaries
        guard !query.isEmpty else { return all }
        return all.filter { summary in
            summary.agentName.lowercased().contains(query)
                || summary.summaryText.lowercased().contains(query)
                || summary.fullText.lowercased().contains(query)
                || summary.date.formatted(date: .abbreviated, time: .omitted).lowercased().contains(query)
        }
    }

    private var dailySummaries: [DailySummary] {
        knowledgeStore.entries
            .sorted { $0.date > $1.date }
            .map { entry in
                DailySummary(
                    id: entry.id.uuidString,
                    date: entry.date,
                    agentID: entry.agentID,
                    agentName: entry.agentName,
                    entryID: entry.id,
                    fullText: entry.text,
                    summaryText: entry.summary,
                    modelInfo: entry.modelInfo,
                    summaryStatus: entry.summaryStatus
                )
            }
    }

    private func saveLatestToKnowledge() {
        let agent = agentStore.activeAgent
        let message = conversationStore.messages(for: agent.id).last(where: { $0.role == .assistant })
        let text = message?.text ?? webPool.answersByAgent[agent.id] ?? ""
        if !text.isEmpty {
            saveKnowledgeEntry(agent: agent, text: text)
            return
        }
        webPool.captureLastAnswer(for: agent) { captured in
            DispatchQueue.main.async {
                guard !captured.isEmpty else {
                    self.showKnowledgeSaveFailed()
                    return
                }
                self.saveKnowledgeEntry(agent: agent, text: captured)
            }
        }
    }

    private func saveKnowledgeEntry(agent: Agent, text: String) {
        let usesAI = aiSummary.provider != .local
        let entry = KnowledgeEntry(
            agentID: agent.id,
            agentName: localization.agentName(agent.name),
            date: Date(),
            text: text,
            summary: usesAI ? "" : KnowledgeStore.summarize(text),
            modelInfo: aiSummary.currentModelLabel,
            summaryStatus: usesAI ? "pending" : "done"
        )
        knowledgeStore.add(entry: entry)
        aiSummary.summarize(text) { summary, modelInfo in
            DispatchQueue.main.async {
                if let summary, !summary.isEmpty {
                    knowledgeStore.updateSummary(
                        id: entry.id,
                        summary: summary,
                        modelInfo: modelInfo,
                        status: "done"
                    )
                } else {
                    knowledgeStore.updateSummary(
                        id: entry.id,
                        summary: KnowledgeStore.summarize(entry.text),
                        modelInfo: modelInfo,
                        status: "failed"
                    )
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 180) {
            if knowledgeStore.entry(id: entry.id)?.summaryStatus == "pending" {
                knowledgeStore.updateSummary(
                    id: entry.id,
                    summary: KnowledgeStore.summarize(entry.text),
                    modelInfo: aiSummary.currentModelLabel,
                    status: "failed"
                )
            }
        }
        justSavedKnowledge = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            justSavedKnowledge = false
        }
    }

    private func showKnowledgeSaveFailed() {
        let alert = NSAlert()
        alert.messageText = localization.text("knowledge_save_failed_title")
        alert.informativeText = localization.text("knowledge_save_failed_message")
        alert.addButton(withTitle: localization.text("ok"))
        alert.runModal()
    }

    private func handleAgentDrop(targetID: String) {
        guard let dragged = draggedAgentID, dragged != targetID else {
            draggedAgentID = nil
            return
        }
        agentStore.move(dragged, to: targetID)
        draggedAgentID = nil
    }

    private func dailySummaryRow(_ summary: DailySummary) -> some View {
        Button {
            selectedSummaryID = summary.id
            mode = .knowledge(summary.id)
        } label: {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(summary.date, format: .dateTime.month().day())
                        .font(.system(size: 11, weight: .bold))
                    Text(summary.date, format: .dateTime.hour().minute())
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 46, alignment: .leading)
                VStack(alignment: .leading, spacing: 4) {
                    Text(summary.agentName)
                        .font(.system(size: 11, weight: .semibold))
                    Text(
                        summary.summaryStatus == "pending"
                            ? localization.text("summary_pending")
                            : (summary.summaryText.isEmpty ? summary.fullText : summary.summaryText)
                    )
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(5)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            .padding(8)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var rightPane: some View {
        switch mode {
        case .chat:
            chatPane
        case .note(let id):
            if let note = noteStore.note(id: id) {
                NoteDetailView(
                    note: note,
                    onUpdate: { title, summary, excerpt in
                        noteStore.update(id, title: title, summary: summary, excerpt: excerpt)
                    },
                    onDelete: {
                        noteStore.delete(id)
                        mode = .chat
                    }
                )
            } else {
                Text("笔记不存在")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        case .knowledge(let id):
            if let summary = dailySummaries.first(where: { $0.id == id }) {
                KnowledgeDetailView(summary: summary, onBack: { mode = .chat })
            } else {
                Text(localization.text("no_content"))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        case .manage:
            ManageView()
        }
    }

    private var chatPane: some View {
        WebViewPoolView(agent: agentStore.activeAgent, pool: webPool)
            .id(agentStore.activeAgent.id)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func officialURL(_ agent: Agent) -> String {
        let host = agent.urlString.components(separatedBy: "/").first ?? agent.urlString
        return "https://" + host
    }

    private func openExternal(_ urlString: String) {
        guard let url = URL(string: urlString.hasPrefix("http") ? urlString : "https://" + urlString) else { return }
        NSWorkspace.shared.open(url)
    }
}

enum ManageTab: Hashable {
    case agents
    case knowledge
}

struct ManageView: View {
    @EnvironmentObject private var store: AgentStore
    @EnvironmentObject private var faviconStore: FaviconStore
    @EnvironmentObject private var aiSummary: AISummaryStore
    @EnvironmentObject private var knowledgeStore: KnowledgeStore
    @EnvironmentObject private var localization: LocalizedStore
    @State private var manageTab: ManageTab = .agents
    @State private var addFormVisible = false
    @State private var newName = ""
    @State private var newURL = ""
    @State private var editingID: String?
    @State private var editName = ""
    @State private var editURL = ""

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $manageTab) {
                Text(localization.text("manage_title")).tag(ManageTab.agents)
                Text(localization.text("knowledge_config")).tag(ManageTab.knowledge)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(10)

            if manageTab == .agents {
                agentContent
            } else {
                knowledgeContent
            }
        }
    }

    private var agentContent: some View {
        VStack(spacing: 0) {
            HStack {
                Label(localization.text("manage_title"), systemImage: "gearshape")
                    .font(.headline)
                Spacer()
                Button {
                    importAgents()
                } label: {
                    Label(localization.text("import_agents"), systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.plain)
                Button {
                    exportAgents()
                } label: {
                    Label(localization.text("export_agents"), systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
                Button {
                    addFormVisible.toggle()
                } label: {
                    Label(localization.text("add_agent"), systemImage: "plus")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .frame(height: 42)
            .background(.bar)

            if addFormVisible {
                HStack(spacing: 8) {
                    TextField(localization.text("name"), text: $newName)
                        .textFieldStyle(.roundedBorder)
                    TextField(localization.text("web_url"), text: $newURL)
                        .textFieldStyle(.roundedBorder)
                    Button(localization.text("save")) {
                        store.add(name: newName, urlString: newURL)
                        resetAddForm()
                    }
                    Button(localization.text("cancel")) {
                        resetAddForm()
                    }
                }
                .padding(10)
                .background(.quaternary.opacity(0.4))
            }

            List {
                ForEach(store.agents) { agent in
                    manageRow(agent)
                }
                .onMove(perform: store.moveAgents)
            }
            .listStyle(.plain)
            .padding(.vertical, 6)
        }
    }

    private var knowledgeContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(localization.text("knowledge_config"))
                        .font(.headline)
                    Picker(localization.text("summary_provider"), selection: $aiSummary.provider) {
                        ForEach(SummaryProvider.allCases, id: \.self) { provider in
                            Text(localization.text(providerKey(provider))).tag(provider)
                        }
                    }
                    .pickerStyle(.segmented)

                    if aiSummary.provider == .ollama {
                        HStack(spacing: 8) {
                            TextField(localization.text("ollama_host"), text: $aiSummary.ollamaHost)
                                .textFieldStyle(.roundedBorder)
                            TextField(localization.text("ollama_model"), text: $aiSummary.ollamaModel)
                                .textFieldStyle(.roundedBorder)
                        }
                        HStack(spacing: 8) {
                            Text(aiSummary.ollamaStatus)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Button {
                                aiSummary.detectOllama()
                            } label: {
                                Label(localization.text("recheck"), systemImage: "arrow.clockwise")
                            }
                            .buttonStyle(.plain)
                            Button {
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString(AISummaryStore.installCommand, forType: .string)
                            } label: {
                                Label(localization.text("copy_install"), systemImage: "doc.on.doc")
                            }
                            .buttonStyle(.plain)
                        }
                    } else if aiSummary.provider == .cloud {
                        SecureField(localization.text("cloud_api_key"), text: $aiSummary.cloudAPIKey)
                            .textFieldStyle(.roundedBorder)
                        TextField(localization.text("cloud_base_url"), text: $aiSummary.cloudBaseURL)
                            .textFieldStyle(.roundedBorder)
                        TextField(localization.text("cloud_model"), text: $aiSummary.cloudModel)
                            .textFieldStyle(.roundedBorder)
                    }

                    Text(localization.text("summary_hint"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(10)
                .background(.quaternary.opacity(0.4))

                Divider()

                Text(localization.format("notes_count", knowledgeStore.entries.count))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(knowledgeStore.entries) { entry in
                    HStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(entry.agentName)
                                    .font(.system(size: 12, weight: .semibold))
                                Text(entry.date, format: .dateTime.month().day().hour().minute())
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                            Text(entry.summary.isEmpty ? entry.text : entry.summary)
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                        }
                        Spacer()
                        Button {
                            knowledgeStore.delete(entry.id)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(8)
                    .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(12)
        }
    }

    private func manageRow(_ agent: Agent) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                if let image = faviconStore.images[agent.id] {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 26, height: 26)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Text(agent.letter)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(Color(hex: agent.colorHex), in: RoundedRectangle(cornerRadius: 8))
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(localization.agentName(agent.name))
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                    Text(agent.urlString)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()

                pillToggle(
                    isOn: Binding(
                        get: { agent.isEnabled },
                        set: { store.setEnabled(agent.id, $0) }
                    ),
                    onLabel: localization.text("show"),
                    offLabel: localization.text("hide")
                )

                Button {
                    store.togglePin(agent.id)
                } label: {
                    Image(systemName: "pin.fill")
                        .foregroundStyle(agent.isPinned ? brandBlue : Color.secondary)
                }
                .buttonStyle(.plain)
                .help(localization.text("pin"))

                Button {
                    if editingID == agent.id {
                        editingID = nil
                    } else {
                        editingID = agent.id
                        editName = agent.name
                        editURL = agent.urlString
                    }
                } label: {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.plain)
            }
            .padding(8)

            if editingID == agent.id {
                HStack(spacing: 8) {
                    TextField(localization.text("name"), text: $editName)
                        .textFieldStyle(.roundedBorder)
                    TextField(localization.text("web_url"), text: $editURL)
                        .textFieldStyle(.roundedBorder)
                    Button(localization.text("save")) {
                        store.update(agent.id, name: editName, urlString: editURL)
                        editingID = nil
                    }
                    Button(localization.text("cancel")) {
                        editingID = nil
                    }
                }
                .padding(8)
                .background(.quaternary.opacity(0.4))
            }
        }
        .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 8))
    }

    private func pillToggle(isOn: Binding<Bool>, onLabel: String, offLabel: String) -> some View {
        HStack(spacing: 0) {
            Button {
                isOn.wrappedValue = true
            } label: {
                Text(onLabel)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isOn.wrappedValue ? Color.white : Color.secondary)
                    .frame(width: 34, height: 22)
                    .background(isOn.wrappedValue ? brandBlue : Color.clear, in: Capsule())
            }
            .buttonStyle(.plain)

            Button {
                isOn.wrappedValue = false
            } label: {
                Text(offLabel)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isOn.wrappedValue ? Color.secondary : Color.white)
                    .frame(width: 34, height: 22)
                    .background(isOn.wrappedValue ? Color.clear : Color.secondary.opacity(0.6), in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .background(.quaternary, in: Capsule())
        .fixedSize()
    }

    private func resetAddForm() {
        newName = ""
        newURL = ""
        addFormVisible = false
    }

    private func providerKey(_ provider: SummaryProvider) -> String {
        switch provider {
        case .ollama: return "provider_ollama"
        case .cloud: return "provider_cloud"
        case .local: return "provider_local"
        }
    }

    private func importAgents() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText]
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url,
              let text = try? String(contentsOf: url, encoding: .utf8) else { return }
        let result = store.importAgents(from: text)
        let message: String
        if result.errors.isEmpty {
            message = localization.format("import_result_format", result.imported)
        } else {
            message = localization.format("import_errors_format", result.imported) + "\n" + result.errors.joined(separator: "\n")
        }
        showAlert(title: localization.text("import_title"), message: message)
    }

    private func exportAgents() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "agents.txt"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        try? store.exportAgents().write(to: url, atomically: true, encoding: .utf8)
    }

    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: localization.text("ok"))
        alert.runModal()
    }
}

struct KnowledgeDetailView: View {
    @EnvironmentObject private var localization: LocalizedStore
    @EnvironmentObject private var knowledgeStore: KnowledgeStore
    @EnvironmentObject private var aiSummary: AISummaryStore
    let summary: DailySummary
    let onBack: () -> Void

    private var entry: KnowledgeEntry? {
        knowledgeStore.entries.first { $0.id == summary.entryID }
    }

    private var displaySummary: String {
        guard let entry else { return summary.summaryText }
        if entry.summaryStatus == "pending" {
            return localization.text("summary_pending")
        }
        return entry.summary.isEmpty ? KnowledgeStore.summarize(entry.text) : entry.summary
    }

    private var displayModel: String {
        guard let entry else { return summary.modelInfo.isEmpty ? "本地规则" : summary.modelInfo }
        return entry.modelInfo.isEmpty ? aiSummary.currentModelLabel : entry.modelInfo
    }

    private var fullText: String {
        entry?.text ?? summary.fullText
    }

    private var shareText: String {
        displaySummary + "\n\n" + fullText
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button(action: onBack) {
                    Label(localization.text("back_chat"), systemImage: "arrow.left")
                }
                .buttonStyle(.plain)
                Spacer()
                Text(summary.date, format: .dateTime.month().day().hour().minute())
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Text(summary.agentName)
                    .font(.system(size: 13, weight: .semibold))
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(.bar)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(localization.text("note_summary"))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        Text(localization.format("summary_by_model", displayModel))
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                        Text(displaySummary)
                            .font(.system(size: 14))
                            .lineSpacing(4)
                            .textSelection(.enabled)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(localization.text("note_excerpt"))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        Text(fullText)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                            .textSelection(.enabled)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }

            HStack(spacing: 8) {
                Spacer()
                shareButton(localization.text("share_system"), icon: "square.and.arrow.up") {
                    systemShare()
                }
                shareButton(localization.text("share_email"), icon: "envelope") {
                    shareEmail()
                }
                shareButton(localization.text("share_copy"), icon: "doc.on.doc") {
                    copyToPasteboard()
                }
                shareButton(localization.text("share_wechat"), icon: "message.fill") {
                    shareWeChat()
                }
                shareButton(localization.text("share_google_keep"), icon: "note.text") {
                    shareGoogleKeep()
                }
                deleteButton {
                    knowledgeStore.delete(summary.entryID)
                    onBack()
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(.bar)
        }
    }

    private func shareButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
    }

    private func deleteButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(localization.text("delete"), systemImage: "trash")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.red)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
    }

    private func systemShare() {
        let picker = NSSharingServicePicker(items: [shareText])
        if let view = NSApp.keyWindow?.contentView {
            picker.show(relativeTo: .zero, of: view, preferredEdge: .minY)
        }
    }

    private func shareEmail() {
        NSSharingService(named: .composeEmail)?.perform(withItems: [shareText])
    }

    private func copyToPasteboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(shareText, forType: .string)
    }

    private func shareWeChat() {
        copyToPasteboard()
        if let url = URL(string: "weixin://") {
            NSWorkspace.shared.open(url)
        }
        let alert = NSAlert()
        alert.messageText = localization.text("share_wechat_title")
        alert.informativeText = localization.text("share_wechat_message")
        alert.addButton(withTitle: localization.text("ok"))
        alert.runModal()
    }

    private func shareGoogleKeep() {
        copyToPasteboard()
        if let url = URL(string: "https://keep.google.com") {
            NSWorkspace.shared.open(url)
        }
    }
}

struct NoteDetailView: View {
    let note: Note
    let onUpdate: (String, String, String) -> Void
    let onDelete: () -> Void
    @EnvironmentObject private var localization: LocalizedStore

    @State private var isEditing = false
    @State private var title: String
    @State private var summary: String
    @State private var excerpt: String

    init(note: Note, onUpdate: @escaping (String, String, String) -> Void, onDelete: @escaping () -> Void) {
        self.note = note
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _title = State(initialValue: note.title)
        _summary = State(initialValue: note.summary)
        _excerpt = State(initialValue: note.excerpt)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Text(note.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text(localization.format("note_source", "\(note.source) · \(note.createdAt.formatted(date: .abbreviated, time: .omitted))"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button {
                    if isEditing {
                        onUpdate(title, summary, excerpt)
                    }
                    isEditing.toggle()
                } label: {
                    Label(isEditing ? localization.text("save") : localization.text("edit"), systemImage: isEditing ? "checkmark" : "pencil")
                }
                .buttonStyle(.plain)
                Button {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString("\(title)\n\n\(summary)\n\n\(excerpt)", forType: .string)
                } label: {
                    Label(localization.text("copy"), systemImage: "doc.on.doc")
                }
                .buttonStyle(.plain)
                Button {
                    onDelete()
                } label: {
                    Label(localization.text("delete"), systemImage: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(.bar)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(localization.text("note_summary"))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        if isEditing {
                            TextField("标题", text: $title)
                                .textFieldStyle(.roundedBorder)
                            TextEditor(text: $summary)
                                .frame(height: 90)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
                        } else {
                            Text(summary)
                                .font(.system(size: 13))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(localization.text("note_excerpt"))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        if isEditing {
                            TextEditor(text: $excerpt)
                                .frame(height: 120)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
                        } else {
                            Text(excerpt)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    if !note.tags.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(note.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(.quaternary, in: Capsule())
                            }
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
