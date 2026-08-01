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
    @State private var isDarkAppearance = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    @State private var manageAgents = false
    @State private var showAgentPicker = false
    @State private var launchAtLogin = false

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
            launchAtLogin = SMAppService.mainApp.status == .enabled
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
            Toggle("", isOn: $launchAtLogin)
                .toggleStyle(.switch)
                .tint(brandBlue)
                .labelsHidden()
                .help(localization.text("auto_launch"))
                .onChange(of: launchAtLogin) { enabled in
                    do {
                        if enabled {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        launchAtLogin = SMAppService.mainApp.status == .enabled
                    }
                }
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
            HStack(spacing: 8) {
                Button {
                    manageAgents.toggle()
                } label: {
                    Text("−")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(manageAgents ? Color.white : Color.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(manageAgents ? Color.red.opacity(0.8) : Color.secondary.opacity(0.14), in: RoundedRectangle(cornerRadius: 9))
                }
                .buttonStyle(.plain)
                .help(localization.text("hide_agents_hint"))

                Button {
                    showAgentPicker = true
                } label: {
                    Text("+")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(brandBlue, in: RoundedRectangle(cornerRadius: 9))
                }
                .buttonStyle(.plain)
                .help(localization.text("add_agents_hint"))
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
        .sheet(isPresented: $showAgentPicker) {
            AgentPickerView()
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

    var body: some View {
        VStack(spacing: 0) {
            header
            if !adminAuth.isConfigured {
                setupView
            } else if !adminAuth.isUnlocked {
                unlockView
            } else {
                configListView
            }
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Label(localization.text("api_settings"), systemImage: "key.fill")
                .font(.headline)
            Spacer()
            if adminAuth.isConfigured && adminAuth.isUnlocked {
                Text(adminAuth.adminEmail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button(localization.text("change_email")) {
                    showChangeEmail.toggle()
                    showChangePassword = false
                }
                .buttonStyle(.plain)
                Button(localization.text("change_password")) {
                    showChangePassword.toggle()
                    showChangeEmail = false
                }
                .buttonStyle(.plain)
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
        }
        .frame(maxWidth: .infinity)
    }

    private var configListView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if showChangePassword {
                    HStack(spacing: 8) {
                        SecureField(localization.text("old_password"), text: $oldPassword)
                            .textFieldStyle(.roundedBorder)
                        SecureField(localization.text("new_password"), text: $newPassword)
                            .textFieldStyle(.roundedBorder)
                        Button(localization.text("save")) {
                            _ = adminAuth.changePassword(old: oldPassword, new: newPassword)
                            oldPassword = ""
                            newPassword = ""
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(8)
                    .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
                }

                if showChangeEmail {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            TextField(localization.text("new_email"), text: $newEmail)
                                .textFieldStyle(.roundedBorder)
                            TextField(localization.text("confirm_email"), text: $confirmEmail)
                                .textFieldStyle(.roundedBorder)
                        }
                        HStack(spacing: 8) {
                            SecureField(localization.text("admin_password"), text: $emailPassword)
                                .textFieldStyle(.roundedBorder)
                            Button(localization.text("save")) {
                                if adminAuth.changeEmail(new: newEmail, confirm: confirmEmail, password: emailPassword) {
                                    newEmail = ""
                                    confirmEmail = ""
                                    emailPassword = ""
                                    showChangeEmail = false
                                }
                            }
                            .buttonStyle(.plain)
                            Button(localization.text("cancel")) {
                                showChangeEmail = false
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(8)
                    .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
                }

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

                ForEach(apiKeyStore.configs) { config in
                    configRow(config)
                }
            }
            .padding(12)
        }
    }

    private func configRow(_ config: AgentAPIConfig) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Toggle("", isOn: Binding(
                    get: { config.isEnabled },
                    set: { apiKeyStore.updateEnabled(config.id, $0) }
                ))
                .toggleStyle(.checkbox)
                .labelsHidden()
                Text(config.name)
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Button(localization.text("copy_key")) {
                    let key = apiKeyStore.apiKey(for: config.id)
                    if !key.isEmpty {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(key, forType: .string)
                    }
                }
                .buttonStyle(.plain)
                .disabled(apiKeyStore.apiKey(for: config.id).isEmpty)
            }

            HStack(spacing: 8) {
                TextField(localization.text("base_url"), text: Binding(
                    get: { config.baseURL },
                    set: { value in
                        var copy = config
                        copy.baseURL = value
                        apiKeyStore.update(config: copy)
                    }
                ))
                .textFieldStyle(.roundedBorder)
                TextField(localization.text("model"), text: Binding(
                    get: { config.model },
                    set: { value in
                        var copy = config
                        copy.model = value
                        apiKeyStore.update(config: copy)
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(width: 180)
            }

            HStack(spacing: 8) {
                SecureField(localization.text("api_key"), text: Binding(
                    get: { apiKeyStore.apiKey(for: config.id) },
                    set: { apiKeyStore.save(apiKey: $0, for: config.id) }
                ))
                .textFieldStyle(.roundedBorder)
                Button {
                    apiKeyStore.save(apiKey: "", for: config.id)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
                .help(localization.text("delete_key"))
            }

            if !config.note.isEmpty {
                Text(config.note)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(10)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct AgentPickerView: View {
    @EnvironmentObject private var agentStore: AgentStore
    @EnvironmentObject private var faviconStore: FaviconStore
    @EnvironmentObject private var localization: LocalizedStore
    @Environment(\.dismiss) private var dismiss
    @State private var showCustomForm = false
    @State private var customName = ""
    @State private var customURL = ""

    private var enabled: [Agent] {
        agentStore.enabledAgents
    }

    private var hidden: [Agent] {
        agentStore.agents
            .filter { !$0.isEnabled }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(localization.text("agent_picker_title"))
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
                Text(localization.text("visible_agents"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], spacing: 8) {
                        ForEach(enabled) { agent in
                            chip(agent)
                        }
                    }
                }
                .frame(height: 92)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(localization.text("all_agents"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 8)], spacing: 8) {
                        ForEach(hidden) { agent in
                            candidateRow(agent)
                        }
                    }
                }
                .frame(maxHeight: 320)
            }

            if showCustomForm {
                VStack(spacing: 8) {
                    TextField(localization.text("name"), text: $customName)
                        .textFieldStyle(.roundedBorder)
                    TextField(localization.text("web_url"), text: $customURL)
                        .textFieldStyle(.roundedBorder)
                    HStack {
                        Button {
                            saveCustom()
                        } label: {
                            Label(localization.text("save"), systemImage: "checkmark")
                        }
                        .buttonStyle(.plain)
                        Button {
                            showCustomForm = false
                            customName = ""
                            customURL = ""
                        } label: {
                            Label(localization.text("cancel"), systemImage: "xmark")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
            }

            HStack {
                Button {
                    showCustomForm.toggle()
                } label: {
                    Label(localization.text("custom_agent"), systemImage: "plus.circle")
                }
                .buttonStyle(.plain)
                Spacer()
                Button(localization.text("done")) {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(16)
        .frame(width: 520, height: 560)
        .onAppear {
            faviconStore.ensureLoaded(for: agentStore.agents)
        }
    }

    private func chip(_ agent: Agent) -> some View {
        HStack(spacing: 6) {
            pickerAvatar(agent)
            Text(localization.agentName(agent.name))
                .font(.system(size: 12, weight: .semibold))
            Button {
                agentStore.setEnabled(agent.id, false)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.quaternary.opacity(0.6), in: Capsule())
    }

    private func candidateRow(_ agent: Agent) -> some View {
        HStack(spacing: 7) {
            pickerAvatar(agent)
            Text(localization.agentName(agent.name))
                .font(.system(size: 13))
                .lineLimit(1)
            Spacer()
            Button {
                agentStore.setEnabled(agent.id, true)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(brandBlue)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 7))
    }

    private func pickerAvatar(_ agent: Agent) -> some View {
        if let image = faviconStore.images[agent.id] {
            return AnyView(
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            )
        }
        return AnyView(
            Text(agent.letter)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Color(hex: agent.colorHex), in: RoundedRectangle(cornerRadius: 7))
        )
    }

    private func saveCustom() {
        let name = customName.trimmingCharacters(in: .whitespacesAndNewlines)
        let url = customURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        agentStore.add(name: name, urlString: url)
        customName = ""
        customURL = ""
        showCustomForm = false
    }
}
