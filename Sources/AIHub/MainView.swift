import AppKit
import ServiceManagement
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
    @State private var sidebarCollapsed = false
    @State private var previousSidebarWidth: CGFloat = 224
    @State private var manageAgents = false
    @State private var showAgentPicker = false
    @State private var launchAtLogin = false

    var body: some View {
        VStack(spacing: 0) {
            header
            HStack(spacing: 0) {
                if !sidebarCollapsed {
                    sidebar
                        .frame(width: 224)
                    Divider()
                }
                sidebarToggleBar
                VStack(spacing: 0) {
                    rightPane
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(nsColor: .textBackgroundColor))
                }
            }
        }
        .frame(minWidth: 900, minHeight: 640)
        .onAppear {
            faviconStore.ensureLoaded(for: agentStore.agents)
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
        .onChange(of: agentStore.agents) { _ in
            faviconStore.ensureLoaded(for: agentStore.agents)
        }
    }

    private var sidebarToggleBar: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.16)) {
                toggleSidebar()
            }
        } label: {
            Image(systemName: sidebarCollapsed ? "chevron.right" : "chevron.left")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 22, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(localization.text("toggle_sidebar"))
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func toggleSidebar() {
        guard let panel = AppDelegate.mainPanel else {
            sidebarCollapsed.toggle()
            return
        }
        let current = panel.frame.size
        let height = current.height
        if sidebarCollapsed {
            let width = max(720, previousSidebarWidth)
            panel.setContentSize(NSSize(width: width, height: height))
            sidebarCollapsed = false
        } else {
            previousSidebarWidth = current.width
            let width = max(720, current.width - 224)
            panel.setContentSize(NSSize(width: width, height: height))
            sidebarCollapsed = true
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("AgentsBin")
                .font(.system(size: 22, weight: .heavy))
            Text("V\(appVersion)")
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
            Button {
                openExternal(agentStore.activeAgent.urlString)
            } label: {
                Image(systemName: "safari")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(.plain)
            .help(localization.text("browser"))
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
        .background(.bar)
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }

    private var sidebar: some View {
        VStack(spacing: 8) {
            agentList

            Divider()
            HStack(spacing: 8) {
                Button {
                    manageAgents.toggle()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "wrench.adjustable")
                            .font(.system(size: 13, weight: .semibold))
                        Text(localization.text("edit_agents"))
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(manageAgents ? Color.white : Color.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 26)
                    .background(manageAgents ? brandBlue : Color.secondary.opacity(0.14), in: RoundedRectangle(cornerRadius: 9))
                }
                .buttonStyle(.plain)
                .help(localization.text("edit_agents_hint"))

                Button {
                    showAgentPicker = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 13, weight: .semibold))
                        Text(localization.text("add_custom_agent"))
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 26)
                        .background(brandBlue, in: RoundedRectangle(cornerRadius: 9))
                }
                .buttonStyle(.plain)
                .help(localization.text("add_custom_agent_hint"))
            }

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
        .sheet(isPresented: $showAgentPicker) {
            AgentPickerView()
        }
        .padding(10)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func toggleLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
            launchAtLogin = SMAppService.mainApp.status == .enabled
        } catch {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    private var agentList: some View {
        ScrollView {
            VStack(spacing: 2) {
                ForEach(manageAgents ? agentStore.agents : agentStore.enabledAgents) { agent in
                    agentRow(agent)
                }
            }
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
                        .font(.system(size: 16))
                        .foregroundStyle(agent.isEnabled ? brandBlue : Color.secondary)
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
            }

            Button {
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

            if manageAgents && agent.id.hasPrefix("custom-") {
                Button {
                    agentStore.delete(agent.id)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 13))
                        .foregroundStyle(.red)
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
                .help(localization.text("delete"))
            }
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
    @EnvironmentObject private var apiKeyStore: APIKeyStore
    @EnvironmentObject private var adminAuth: AdminAuthStore
    @EnvironmentObject private var localization: LocalizedStore
    @State private var email = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var resetInput = ""
    @State private var showChangePassword = false
    @State private var showResetForm = false
    @State private var showChangeEmail = false
    @State private var newEmail = ""
    @State private var confirmEmail = ""
    @State private var emailPassword = ""
    @State private var selectedConfigID: String?
    @State private var settingsTab = 0
    @State private var generalItem = 0
    @State private var showAddAPIProvider = false
    @State private var addAPIProviderName = ""
    @FocusState private var addProviderFocused: Bool
    @State private var pendingDeleteID: String?
    @State private var passwordMasked = true
    @State private var launchAtLogin = false
    @State private var darkModeEnabled = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua

    var body: some View {
        VStack(spacing: 0) {
            header
            if !adminAuth.isConfigured {
                setupView
            } else if !adminAuth.isUnlocked {
                unlockView
            } else {
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
                    if adminAuth.isUnlocked {
                        configListView
                    } else {
                        unlockView
                    }
                }
            }
        }
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Label(localization.text("settings"), systemImage: "gearshape")
                .font(.headline)
            Spacer()
            if adminAuth.isConfigured && adminAuth.isUnlocked {
                Text(adminAuth.adminEmail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button(localization.text("lock")) {
                    adminAuth.lock()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(.bar)
    }

    private var setupView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(localization.text("admin_setup_title"))
                    .font(.title3.weight(.bold))
                Text(localization.text("admin_setup_desc"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField(localization.text("admin_email"), text: $email)
                    .textFieldStyle(.roundedBorder)
                SecureField(localization.text("admin_password"), text: $password)
                    .textFieldStyle(.roundedBorder)
                SecureField(localization.text("admin_confirm"), text: $confirm)
                    .textFieldStyle(.roundedBorder)
                Text(localization.text("password_rule"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                if !adminAuth.message.isEmpty {
                    Text(adminAuth.message)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                Button {
                    guard password == confirm else {
                        adminAuth.message = localization.text("password_mismatch")
                        return
                    }
                    _ = adminAuth.setup(email: email, password: password)
                } label: {
                    Label(localization.text("save"), systemImage: "checkmark")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(20)
            .frame(maxWidth: 420)
        }
        .frame(maxWidth: .infinity)
    }

    private var unlockView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(localization.text("admin_unlock_title"))
                    .font(.title3.weight(.bold))
                if let locked = adminAuth.lockedUntil, locked > Date() {
                    Text(localization.text("locked_until"))
                        .font(.caption)
                        .foregroundStyle(.red)
                } else {
                    if adminAuth.isDefaultPassword {
                        Text(localization.format("initial_password_hint", AdminAuthStore.initialPassword))
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    SecureField(localization.text("admin_password"), text: $password)
                        .textFieldStyle(.roundedBorder)
                    if !adminAuth.message.isEmpty {
                        Text(adminAuth.message)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    Button(localization.text("unlock")) {
                        _ = adminAuth.unlock(password: password)
                        password = ""
                    }
                    .buttonStyle(.borderedProminent)
                    Button(localization.text("reset_to_initial")) {
                        adminAuth.resetToInitial()
                        password = AdminAuthStore.initialPassword
                    }
                    .buttonStyle(.plain)
                    Button(localization.text("forgot_password")) {
                        _ = adminAuth.requestReset()
                        showResetForm = true
                    }
                    .buttonStyle(.plain)
                }

                if showResetForm {
                    Divider()
                    if let code = adminAuth.resetCode {
                        Text(localization.format("reset_code_shown", code))
                            .font(.system(.body, design: .monospaced))
                        Button(localization.text("copy_reset_code")) {
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(code, forType: .string)
                        }
                        .buttonStyle(.plain)
                    }
                    SecureField(localization.text("reset_code"), text: $resetInput)
                        .textFieldStyle(.roundedBorder)
                    SecureField(localization.text("new_password"), text: $newPassword)
                        .textFieldStyle(.roundedBorder)
                    Button(localization.text("reset_password")) {
                        if adminAuth.reset(code: resetInput, newPassword: newPassword) {
                            showResetForm = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(20)
            .frame(maxWidth: 420)
            .onAppear {
                if adminAuth.isDefaultPassword && password.isEmpty {
                    password = AdminAuthStore.initialPassword
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var configListView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if apiKeyStore.importedFromCCSwitch {
                    Text(localization.text("cc_switch_imported"))
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                if !adminAuth.message.isEmpty {
                    Text(adminAuth.message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(alignment: .top, spacing: 10) {
                    VStack(spacing: 6) {
                        ScrollView {
                            VStack(spacing: 4) {
                                ForEach(apiKeyStore.configs) { config in
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

    private var generalSettingsView: some View {
        VStack(spacing: 8) {
            if adminAuth.requireChange {
                Text(localization.text("change_required"))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.orange)
                    .padding(8)
                    .background(Color.orange.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))
            }

            HStack(alignment: .top, spacing: 10) {
                VStack(spacing: 4) {
                    generalItemButton(index: 0, icon: "key.fill", title: localization.text("change_password"))
                    generalItemButton(index: 1, icon: "envelope.fill", title: localization.text("change_email"))
                    generalItemButton(index: 2, icon: "bolt.fill", title: localization.text("auto_launch"))
                    generalItemButton(index: 3, icon: "globe", title: localization.text("language"))
                    generalItemButton(index: 4, icon: "paintbrush.fill", title: localization.text("appearance"))
                    Spacer(minLength: 0)
                }
                .frame(width: 210)

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        switch generalItem {
                        case 0: passwordSettings
                        case 1: emailSettings
                        case 2: launchSettings
                        case 3: languageSettings
                        default: appearanceSettings
                        }
                        if !adminAuth.message.isEmpty {
                            Text(adminAuth.message)
                                .font(.caption)
                                .foregroundStyle(.secondary)
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

    private var passwordSettings: some View {
        VStack(spacing: 8) {
            HStack {
                Text(localization.text("password_rule"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    passwordMasked.toggle()
                } label: {
                    Image(systemName: passwordMasked ? "eye" : "eye.slash")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help(localization.text(passwordMasked ? "show_password" : "hide_password"))
            }
            if passwordMasked {
                SecureField(localization.text("old_password"), text: $oldPassword)
                    .textFieldStyle(.roundedBorder)
                SecureField(localization.text("new_password"), text: $newPassword)
                    .textFieldStyle(.roundedBorder)
            } else {
                TextField(localization.text("old_password"), text: $oldPassword)
                    .textFieldStyle(.roundedBorder)
                TextField(localization.text("new_password"), text: $newPassword)
                    .textFieldStyle(.roundedBorder)
            }
            HStack {
                Spacer()
                Button(localization.text("save")) {
                    _ = adminAuth.changePassword(old: oldPassword, new: newPassword)
                    oldPassword = ""
                    newPassword = ""
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(8)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
    }

    private var emailSettings: some View {
        VStack(spacing: 8) {
            TextField(localization.text("new_email"), text: $newEmail)
                .textFieldStyle(.roundedBorder)
            TextField(localization.text("confirm_email"), text: $confirmEmail)
                .textFieldStyle(.roundedBorder)
            SecureField(localization.text("admin_password"), text: $emailPassword)
                .textFieldStyle(.roundedBorder)
            HStack {
                Spacer()
                Button(localization.text("save")) {
                    if adminAuth.changeEmail(new: newEmail, confirm: confirmEmail, password: emailPassword) {
                        newEmail = ""
                        confirmEmail = ""
                        emailPassword = ""
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(8)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
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
                darkModeEnabled = true
            }
            radioRow(title: localization.text("light_mode"), selected: !darkModeEnabled) {
                darkModeEnabled = false
            }
        }
        .padding(8)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
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
        .frame(width: 380)
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
