import AppKit
import ServiceManagement
import SwiftUI
import UniformTypeIdentifiers

enum RightMode {
    case chat
    case manage
}

enum ChatTab {
    case web
    case api
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

let brandBlue = Color(red: 0.04, green: 0.46, blue: 0.95)

struct MainPopoverView: View {
    @EnvironmentObject private var agentStore: AgentStore
    @EnvironmentObject private var webPool: WebViewPool
    @EnvironmentObject private var faviconStore: FaviconStore
    @EnvironmentObject private var localization: LocalizedStore
    @EnvironmentObject private var apiKeyStore: APIKeyStore
    @AppStorage("agentsbin.setupDone") private var setupDone = false
    @State private var mode: RightMode = .chat
    @State private var chatTab = ChatTab.web
    @State private var pendingSettingsTab = 0
    @State private var hoveredAgentID: String?
    @State private var draggedAgentID: String?
    @State private var sidebarHovered = false
    @State private var manageAgents = false
    @State private var showAgentPicker = false
    @State private var launchAtLogin = false
    @State private var selectedSetupIDs: Set<String> = ["chatgpt", "claude", "gemini", "deepseek", "kimi", "qwen", "grok"]

    var body: some View {
        VStack(spacing: 0) {
            if !setupDone {
                setupHome
            } else {
                mainContent
            }
        }
        .frame(minWidth: 720, minHeight: 460)
        .onAppear {
            faviconStore.ensureLoaded(for: agentStore.agents)
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
        .onChange(of: agentStore.agents) { _ in
            faviconStore.ensureLoaded(for: agentStore.agents)
        }
    }

    private var setupHome: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("AgentsBin")
                .font(.system(size: 40, weight: .heavy))
            Text(localization.text("home_slogan"))
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .padding(.top, 8)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 86), spacing: 8)], spacing: 8) {
                    ForEach(agentStore.agents) { agent in
                        setupChip(agent)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 28)
            }
            .frame(maxWidth: 560)

            Button {
                finishSetup()
            } label: {
                Text(localization.text("home_open"))
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 240, height: 40)
                    .background(brandBlue, in: RoundedRectangle(cornerRadius: 11))
            }
            .buttonStyle(.plain)
            .padding(.top, 22)

            Toggle(isOn: $launchAtLogin) {
                Text(localization.text("home_boot"))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .toggleStyle(.checkbox)
            .padding(.top, 10)

            Spacer()

            HStack(spacing: 8) {
                Text("AgentsBin V\(appVersion)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.tertiary)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color(nsColor: .textBackgroundColor))
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func setupChip(_ agent: Agent) -> some View {
        let selected = selectedSetupIDs.contains(agent.id)
        return Button {
            if selected {
                selectedSetupIDs.remove(agent.id)
            } else {
                selectedSetupIDs.insert(agent.id)
            }
        } label: {
            Text(localization.agentName(agent.name))
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(selected ? Color.white : Color.primary)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    selected ? Color(red: 0.98, green: 0.45, blue: 0.09) : Color.secondary.opacity(0.12),
                    in: Capsule()
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func finishSetup() {
        agentStore.selectedIDs = selectedSetupIDs
        if !selectedSetupIDs.contains(agentStore.activeID), let first = agentStore.agents.first(where: { selectedSetupIDs.contains($0.id) }) {
            agentStore.activeID = first.id
        }
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
        }
        setupDone = true
    }

    private var mainContent: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 0) {
                rightPane
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(nsColor: .textBackgroundColor))
                rightFooterBar
            }
            floatingPanel
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 10)
                .contentShape(Rectangle())
                .onHover { hovering in
                    if !manageAgents && !showAgentPicker && mode != .manage {
                        sidebarHovered = hovering
                    }
                }
        }
    }

    private var showPanel: Bool {
        manageAgents || showAgentPicker || mode == .manage || sidebarHovered
    }

    private var floatingPanel: some View {
        Group {
            if showPanel {
                VStack(spacing: 0) {
                    agentList
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    HStack(spacing: 6) {
                        Button {
                            manageAgents.toggle()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "wrench.adjustable")
                                    .font(.system(size: 11, weight: .semibold))
                                Text(localization.text("edit_agents"))
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundStyle(manageAgents ? Color.white : Color.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 26)
                            .background(manageAgents ? brandBlue : Color.secondary.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                        .help(localization.text("edit_agents_hint"))

                        Button {
                            showAgentPicker = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .semibold))
                                Text(localization.text("add_custom_agent"))
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 26)
                            .background(brandBlue, in: RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                        .help(localization.text("add_custom_agent_hint"))
                    }
                    .padding(8)
                }
                .frame(width: 230)
                .background(Color(nsColor: .windowBackgroundColor))
                .shadow(color: .black.opacity(0.28), radius: 14, y: 5)
                .padding(.leading, 8)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .onHover { hovering in
                    sidebarHovered = hovering
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.16), value: showPanel)
        .sheet(isPresented: $showAgentPicker) {
            AgentPickerView()
        }
    }

    private var agentList: some View {
        ScrollView {
            VStack(spacing: 2) {
                ForEach(manageAgents ? agentStore.agents : agentStore.enabledAgents) { agent in
                    agentRow(agent)
                }
            }
            .padding(6)
        }
    }

    private func agentRow(_ agent: Agent) -> some View {
        let isActive = agentStore.activeID == agent.id
        return HStack(spacing: 6) {
            if manageAgents {
                Button {
                    agentStore.setEnabled(agent.id, !agent.isEnabled)
                } label: {
                    Image(systemName: agent.isEnabled ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 15))
                        .foregroundStyle(agent.isEnabled ? brandBlue : Color.secondary)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 8) {
                agentStatusLight(agent)
                Text(localization.agentName(agent.name))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isActive ? Color.white : Color.primary)
                    .lineLimit(1)
                if webPool.unreadIDs.contains(agent.id) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 7, height: 7)
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
            .contentShape(Rectangle())
            .onTapGesture {
                agentStore.select(agent.id)
                webPool.markRead(agent.id)
                Analytics.track(kind: "agent_open", name: agent.id)
                mode = .chat
                sidebarHovered = false
            }
            .onHover { hovering in
                hoveredAgentID = hovering ? agent.id : nil
            }

            if manageAgents && agent.id.hasPrefix("custom-") {
                Button {
                    agentStore.delete(agent.id)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
                .help(localization.text("delete"))
            }

            Image(systemName: "line.3.horizontal")
                .font(.system(size: 10))
                .foregroundStyle(isActive ? Color.white.opacity(0.8) : Color.secondary.opacity(0.7))
                .frame(width: 16, height: 22)
                .contentShape(Rectangle())
                .help(localization.text("drag_hint"))
        }
        .onDrag {
            draggedAgentID = agent.id
            return NSItemProvider(object: agent.id as NSString)
        }
        .onDrop(of: [.text], isTargeted: nil) { _ in
            handleAgentDrop(targetID: agent.id)
            return true
        }
    }

    private func agentStatusLight(_ agent: Agent) -> some View {
        let color: Color
        let hint: String
        if !agent.isOnline {
            color = .red
            hint = localization.text("api_blocked")
        } else if apiKeyStore.hasAPIKey(forAgentID: agent.id) {
            color = .green
            hint = localization.text("api_ready")
        } else {
            color = .yellow
            hint = localization.text("api_missing")
        }
        return Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 0.5))
            .help(hint)
    }

    private func avatar(_ agent: Agent) -> some View {
        if let image = faviconStore.images[agent.id] {
            return AnyView(
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 16, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            )
        }
        return AnyView(
            Text(agent.letter)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 16, height: 16)
                .background(Color(hex: agent.colorHex), in: RoundedRectangle(cornerRadius: 4))
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
            ManageView(onBack: { mode = .chat }, initialTab: pendingSettingsTab)
        }
    }

    private var chatPane: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Picker("", selection: $chatTab) {
                    Text(localization.text("web_mode")).tag(ChatTab.web)
                    Text(localization.text("client_mode")).tag(ChatTab.api)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 220)
                Spacer(minLength: 0)
                avatar(agentStore.activeAgent)
                Text(localization.agentName(agentStore.activeAgent.name))
                    .font(.system(size: 14, weight: .heavy))
                    .lineLimit(1)
                Button {
                    openExternal(agentStore.activeAgent.urlString)
                } label: {
                    Image(systemName: "safari")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .help(localization.text("browser"))
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(Color(nsColor: .textBackgroundColor))
            switch chatTab {
            case .web:
                WebViewPoolView(agent: agentStore.activeAgent, pool: webPool)
                    .id(agentStore.activeAgent.id)
            case .api:
                ClientChatView(agent: agentStore.activeAgent) {
                    pendingSettingsTab = 1
                    mode = .manage
                }
                .id(agentStore.activeAgent.id)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var rightFooterBar: some View {
        HStack(spacing: 8) {
            Button {
                openExternal("https://www.agentsbin.com")
            } label: {
                Image(systemName: "globe")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .help("https://www.agentsbin.com")

            Text("AgentsBin V\(appVersion)")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.tertiary)
            Spacer()
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
                .frame(width: 86)
            }
            Button {
                pendingSettingsTab = 0
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
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(Color(nsColor: .textBackgroundColor))
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }

    private func openExternal(_ urlString: String) {
        guard let url = URL(string: urlString.hasPrefix("http") ? urlString : "https://" + urlString) else { return }
        NSWorkspace.shared.open(url)
    }
}

struct ManageView: View {
    @EnvironmentObject private var apiKeyStore: APIKeyStore
    @EnvironmentObject private var localization: LocalizedStore
    let onBack: () -> Void
    @State private var selectedConfigID: String?
    @State private var settingsTab = 0
    @State private var generalItem = 0
    @State private var showAddAPIProvider = false
    @State private var addAPIProviderName = ""
    @FocusState private var addProviderFocused: Bool
    @State private var pendingDeleteID: String?
    @State private var draggedProviderID: String?
    @State private var launchAtLogin = false
    @State private var darkModeEnabled = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua

    init(onBack: @escaping () -> Void, initialTab: Int = 0) {
        self.onBack = onBack
        _settingsTab = State(initialValue: initialTab)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Picker("", selection: $settingsTab) {
                Text(localization.text("general_settings")).tag(0)
                Text(localization.text("api_backup")).tag(1)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(10)
            if settingsTab == 0 {
                generalSettingsView
            } else {
                configListView
            }
        }
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Button(action: onBack) {
                Image(systemName: "house")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .help(localization.text("back"))

            Label(localization.text("settings"), systemImage: "gearshape")
                .font(.system(size: 13, weight: .semibold))
            Text("· " + settingsTitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(.bar)
    }

    private var settingsTitle: String {
        if settingsTab == 0 {
            return localization.text("general_settings") + " · " + currentGeneralItemTitle
        }
        return localization.text("api_backup")
    }

    private var currentGeneralItemTitle: String {
        switch generalItem {
        case 0: return localization.text("auto_launch")
        case 1: return localization.text("language")
        default: return localization.text("appearance")
        }
    }

    private var configListView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if apiKeyStore.importedFromCCSwitch {
                    Text(localization.text("cc_switch_imported"))
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                HStack(alignment: .top, spacing: 10) {
                    VStack(spacing: 6) {
                        ScrollView {
                            VStack(spacing: 4) {
                                Text(localization.text("provider_list_title"))
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 6)
                                    .padding(.bottom, 2)
                                ForEach(apiKeyStore.configs) { config in
                                    HStack(spacing: 4) {
                                        Button {
                                            selectedConfigID = config.id
                                        } label: {
                                            HStack(spacing: 8) {
                                                Toggle("", isOn: Binding(
                                                    get: { config.isEnabled },
                                                    set: { apiKeyStore.updateEnabled(config.id, $0) }
                                                ))
                                                .toggleStyle(.checkbox)
                                                .labelsHidden()
                                                Text(config.name)
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundStyle(selectedConfigID == config.id ? Color.white : Color.primary)
                                                    .lineLimit(1)
                                                if config.id.hasPrefix("custom-") {
                                                    deleteProviderButton(config: config)
                                                }
                                                Spacer(minLength: 0)
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 7)
                                            .background(
                                                selectedConfigID == config.id ? brandBlue : Color.clear,
                                                in: RoundedRectangle(cornerRadius: 7)
                                            )
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                        Image(systemName: "line.3.horizontal")
                                            .font(.system(size: 10))
                                            .foregroundStyle(.tertiary)
                                            .frame(width: 14, height: 22)
                                            .contentShape(Rectangle())
                                    }
                                    .onDrag {
                                        draggedProviderID = config.id
                                        return NSItemProvider(object: config.id as NSString)
                                    }
                                    .onDrop(of: [.text], isTargeted: nil) { _ in
                                        handleProviderDrop(targetID: config.id)
                                        return true
                                    }
                                }
                            }
                        }

                        if showAddAPIProvider {
                            TextField(localization.text("name_placeholder"), text: $addAPIProviderName)
                                .textFieldStyle(.roundedBorder)
                                .focused($addProviderFocused)
                                .onSubmit {
                                    addCustomProvider()
                                }
                                .onChange(of: addProviderFocused) { focused in
                                    if !focused {
                                        addCustomProvider()
                                    }
                                }
                        }

                        Button {
                            showAddAPIProvider.toggle()
                            if showAddAPIProvider {
                                addProviderFocused = true
                            } else {
                                addAPIProviderName = ""
                            }
                        } label: {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 16))
                                .foregroundStyle(brandBlue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 26)
                                .padding(.horizontal, 8)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .help(localization.text("add_custom_agent"))
                    }
                    .frame(width: 230)

                    Divider()

                    if let selected = apiKeyStore.configs.first(where: { $0.id == selectedConfigID }) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(selected.credentials) { credential in
                                    credentialRow(config: selected, credential: credential)
                                }
                                Button {
                                    apiKeyStore.addCredential(to: selected.id)
                                } label: {
                                    Label(localization.text("add_group"), systemImage: "plus.circle")
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(8)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Text(localization.text("select_agent_first"))
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .padding(12)
        }
    }

    private func addCustomProvider() {
        let name = addAPIProviderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            addAPIProviderName = ""
            showAddAPIProvider = false
            return
        }
        selectedConfigID = apiKeyStore.addCustomProvider(name: name)
        addAPIProviderName = ""
        showAddAPIProvider = false
    }

    private func deleteProviderButton(config: AgentAPIConfig) -> some View {
        Button {
            if pendingDeleteID == config.id {
                apiKeyStore.deleteProvider(config.id)
                if selectedConfigID == config.id {
                    selectedConfigID = nil
                }
                pendingDeleteID = nil
            } else {
                pendingDeleteID = config.id
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if pendingDeleteID == config.id {
                        pendingDeleteID = nil
                    }
                }
            }
        } label: {
            Image(systemName: pendingDeleteID == config.id ? "minus.circle.fill" : "minus.circle")
                .font(.system(size: 13))
                .foregroundStyle(pendingDeleteID == config.id ? Color.red : Color.secondary)
                .frame(width: 18, height: 18)
        }
        .buttonStyle(.plain)
        .help(localization.text("delete"))
    }

    private func handleProviderDrop(targetID: String) {
        guard let dragged = draggedProviderID, dragged != targetID else {
            draggedProviderID = nil
            return
        }
        apiKeyStore.moveConfig(dragged, to: targetID)
        draggedProviderID = nil
    }

    private var generalSettingsView: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                VStack(spacing: 4) {
                    generalItemButton(index: 0, icon: "bolt.fill", title: localization.text("auto_launch"))
                    generalItemButton(index: 1, icon: "globe", title: localization.text("language"))
                    generalItemButton(index: 2, icon: "paintbrush.fill", title: localization.text("appearance"))
                    Spacer(minLength: 0)
                }
                .frame(width: 210)

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        switch generalItem {
                        case 0: launchSettings
                        case 1: languageSettings
                        default: appearanceSettings
                        }
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(12)
    }

    private func generalItemButton(index: Int, icon: String, title: String) -> some View {
        Button {
            generalItem = index
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: 18)
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .foregroundStyle(generalItem == index ? Color.white : Color.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(
                generalItem == index ? brandBlue : Color.clear,
                in: RoundedRectangle(cornerRadius: 7)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var launchSettings: some View {
        VStack(spacing: 6) {
            radioRow(title: localization.text("auto_launch"), selected: launchAtLogin) {
                setLaunchAtLogin(true)
            }
            radioRow(title: localization.text("manual_launch"), selected: !launchAtLogin) {
                setLaunchAtLogin(false)
            }
        }
        .padding(8)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
    }

    private var languageSettings: some View {
        VStack(spacing: 6) {
            ForEach(AppLanguage.allCases, id: \.self) { lang in
                radioRow(title: lang.displayName, selected: localization.language == lang) {
                    localization.language = lang
                }
            }
        }
        .padding(8)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
    }

    private var appearanceSettings: some View {
        VStack(spacing: 6) {
            radioRow(title: localization.text("dark_mode"), selected: darkModeEnabled) {
                setAppearance(true)
            }
            radioRow(title: localization.text("light_mode"), selected: !darkModeEnabled) {
                setAppearance(false)
            }
        }
        .padding(8)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
    }

    private func setAppearance(_ enabled: Bool) {
        darkModeEnabled = enabled
        let appearance = enabled ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)
        NSApp.appearance = appearance
        AppDelegate.mainPanel?.appearance = appearance
        UserDefaults.standard.set(
            enabled ? NSAppearance.Name.darkAqua.rawValue : NSAppearance.Name.aqua.rawValue,
            forKey: "aihome.appearance"
        )
    }

    private func radioRow(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 14))
                    .foregroundStyle(selected ? brandBlue : Color.secondary)
                Text(title)
                    .font(.system(size: 13))
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .background(selected ? brandBlue.opacity(0.12) : Color.clear, in: RoundedRectangle(cornerRadius: 7))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            launchAtLogin = SMAppService.mainApp.status == .enabled
        } catch {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    private func credentialRow(config: AgentAPIConfig, credential: APICredential) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                TextField(localization.text("group_label"), text: Binding(
                    get: { credential.label },
                    set: { value in
                        var copy = credential
                        copy.label = value
                        apiKeyStore.updateCredential(configID: config.id, credential: copy)
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(width: 140)
                Spacer()
                Button(localization.text("copy_key")) {
                    let key = apiKeyStore.apiKey(for: credential.id)
                    if !key.isEmpty {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(key, forType: .string)
                    }
                }
                .buttonStyle(.plain)
                .disabled(apiKeyStore.apiKey(for: credential.id).isEmpty)
            }

            HStack(spacing: 8) {
                TextField(localization.text("base_url"), text: Binding(
                    get: { credential.baseURL },
                    set: { value in
                        var copy = credential
                        copy.baseURL = value
                        apiKeyStore.updateCredential(configID: config.id, credential: copy)
                    }
                ))
                .textFieldStyle(.roundedBorder)
                TextField(localization.text("model"), text: Binding(
                    get: { credential.model },
                    set: { value in
                        var copy = credential
                        copy.model = value
                        apiKeyStore.updateCredential(configID: config.id, credential: copy)
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(width: 180)
            }

            HStack(spacing: 8) {
                SecureField(localization.text("api_key"), text: Binding(
                    get: { apiKeyStore.apiKey(for: credential.id) },
                    set: { apiKeyStore.save(apiKey: $0, for: credential.id) }
                ))
                .textFieldStyle(.roundedBorder)
                Button {
                    apiKeyStore.deleteCredential(configID: config.id, credentialID: credential.id)
                } label: {
                    Label(localization.text("delete"), systemImage: "trash")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .help(localization.text("delete_key"))
            }

            HStack(spacing: 8) {
                Button {
                    apiKeyStore.setActiveCredential(configID: config.id, credentialID: credential.id)
                } label: {
                    Image(systemName: credential.isActive ? "play.circle.fill" : "pause.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(credential.isActive ? Color.green : Color.secondary)
                }
                .buttonStyle(.plain)
                .help(credential.isActive ? localization.text("group_active") : localization.text("group_inactive"))
                Text(credential.isActive ? localization.text("activated") : localization.text("activate"))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(credential.isActive ? Color.green : Color.secondary)
                Text(credential.isActive ? localization.text("group_active_hint") : localization.text("group_inactive_hint"))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct AgentPickerView: View {
    @EnvironmentObject private var agentStore: AgentStore
    @EnvironmentObject private var localization: LocalizedStore
    @Environment(\.dismiss) private var dismiss
    @State private var customName = ""
    @State private var customURL = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text(localization.text("custom_agent_title"))
                    .font(.headline)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(localization.text("name"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                TextField(localization.text("name_placeholder"), text: $customName)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(localization.text("web_url"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                TextField(localization.text("url_placeholder"), text: $customURL)
                    .textFieldStyle(.roundedBorder)
            }

            Text(localization.text("custom_agent_hint"))
                .font(.caption2)
                .foregroundStyle(.secondary)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            HStack {
                Spacer()
                Button(localization.text("cancel")) {
                    dismiss()
                }
                .buttonStyle(.plain)
                Button(localization.text("save")) {
                    saveCustom()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(18)
        .frame(width: 380, height: 320)
        .onChange(of: customName) { _ in validate() }
        .onChange(of: customURL) { _ in validate() }
    }

    private func validate() {
        let name = customName.trimmingCharacters(in: .whitespacesAndNewlines)
        let url = customURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            errorMessage = localization.text("name_required")
            return
        }
        if !url.isEmpty {
            let candidate = url.hasPrefix("http") ? url : "https://" + url
            if let value = URL(string: candidate), value.host != nil {
                errorMessage = ""
            } else {
                errorMessage = localization.text("url_invalid")
            }
        } else {
            errorMessage = ""
        }
    }

    private func saveCustom() {
        let name = customName.trimmingCharacters(in: .whitespacesAndNewlines)
        let url = customURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            errorMessage = localization.text("name_required")
            return
        }
        if !url.isEmpty {
            let candidate = url.hasPrefix("http") ? url : "https://" + url
            guard let value = URL(string: candidate), value.host != nil else {
                errorMessage = localization.text("url_invalid")
                return
            }
        }
        agentStore.add(name: name, urlString: url)
        dismiss()
    }
}
