import AppKit
import SwiftUI
import UniformTypeIdentifiers

enum RightMode {
    case chat
    case manage
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
    @EnvironmentObject private var webPool: WebViewPool
    @EnvironmentObject private var faviconStore: FaviconStore
    @EnvironmentObject private var localization: LocalizedStore
    @State private var mode: RightMode = .chat
    @State private var hoveredAgentID: String?
    @State private var draggedAgentID: String?
    @State private var isDarkAppearance = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua

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
            agentList

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

    private func handleAgentDrop(targetID: String) {
        guard let dragged = draggedAgentID, dragged != targetID else {
            draggedAgentID = nil
            return
        }
        agentStore.move(dragged, to: targetID)
        draggedAgentID = nil
    }

    @ViewBuilder
    private var rightPane: some View {
        switch mode {
        case .chat:
            chatPane
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

struct ManageView: View {
    @EnvironmentObject private var store: AgentStore
    @EnvironmentObject private var faviconStore: FaviconStore
    @EnvironmentObject private var localization: LocalizedStore
    @State private var addFormVisible = false
    @State private var newName = ""
    @State private var newURL = ""
    @State private var editingID: String?
    @State private var editName = ""
    @State private var editURL = ""

    var body: some View {
        agentContent
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
