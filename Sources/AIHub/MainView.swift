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

struct HoverSensorView: NSViewRepresentable {
    var onHover: (Bool) -> Void

    func makeNSView(context: Context) -> HoverSensorNSView {
        let view = HoverSensorNSView()
        view.onHover = onHover
        return view
    }

    func updateNSView(_ nsView: HoverSensorNSView, context: Context) {
        nsView.onHover = onHover
    }
}

final class HoverSensorNSView: NSView {
    var onHover: ((Bool) -> Void)?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for area in trackingAreas {
            removeTrackingArea(area)
        }
        addTrackingArea(NSTrackingArea(
            rect: bounds,
            options: [.activeAlways, .mouseEnteredAndExited, .inVisibleRect],
            owner: self,
            userInfo: nil
        ))
    }

    override func mouseEntered(with event: NSEvent) {
        onHover?(true)
    }

    override func mouseExited(with event: NSEvent) {
        onHover?(false)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
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

struct CollapseWindowButton: View {
    @EnvironmentObject private var localization: LocalizedStore
    @State private var collapsed = false
    var disabled = false

    var body: some View {
        Button {
            guard !disabled else { return }
            NotificationCenter.default.post(name: .agentsbinToggleCollapse, object: nil)
        } label: {
            VStack(spacing: 3) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(collapsed ? brandBlue : Color.primary.opacity(0.9))
                    .frame(width: 16, height: 5)
                Rectangle()
                    .fill(Color.primary.opacity(0.22))
                    .frame(width: 18, height: 1)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.primary.opacity(0.5))
                    .frame(width: 16, height: collapsed ? 2 : 5)
            }
            .frame(width: 30, height: 30)
            .background(
                collapsed ? brandBlue.opacity(0.16) : Color.clear,
                in: RoundedRectangle(cornerRadius: 7)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.primary.opacity(0.14), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(disabled ? 0.45 : 1)
        .disabled(disabled)
        .help(localization.text(collapsed ? "expand_window" : "collapse_window"))
        .onReceive(NotificationCenter.default.publisher(for: .agentsbinCollapseStateChanged)) { note in
            collapsed = (note.object as? NSNumber)?.boolValue ?? false
        }
    }
}

struct AgentPanelButton: View {
    @EnvironmentObject private var localization: LocalizedStore
    let isOpen: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.primary.opacity(isOpen ? 0.9 : 0.55), lineWidth: 1.2)
                    .frame(width: 12, height: 10)
                    .offset(x: -3, y: 3)
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.primary.opacity(isOpen ? 0.14 : 0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.primary.opacity(isOpen ? 0.9 : 0.75), lineWidth: 1.4)
                    )
                    .frame(width: 13, height: 11)
                    .offset(x: 3, y: -3)
            }
            .frame(width: 30, height: 30)
            .background(
                isOpen ? Color.primary.opacity(0.10) : Color.clear,
                in: RoundedRectangle(cornerRadius: 7)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.primary.opacity(isOpen ? 0.35 : 0.14), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(localization.text("agent_panel"))
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

let brandBlue = Color(nsColor: .controlAccentColor)

struct MainPopoverView: View {
    @EnvironmentObject private var agentStore: AgentStore
    @EnvironmentObject private var webPool: WebViewPool
    @EnvironmentObject private var faviconStore: FaviconStore
    @EnvironmentObject private var localization: LocalizedStore
    @EnvironmentObject private var apiKeyStore: APIKeyStore
    @ObservedObject private var localService = LocalModelService.shared
    @State private var setupDone = false
    @State private var mode: RightMode = .chat
    @State private var chatTab = ChatTab.web
    @State private var pendingSettingsTab = 0
    @State private var pendingManageConfigID: String?
    @State private var hoveredAgentID: String?
    @State private var draggedAgentID: String?
    @State private var agentPanelOpen = false
    @State private var panelHintAgent: String?
    @State private var manageAgents = false
    @State private var showAgentPicker = false
    @State private var launchAtLogin = false
    @State private var selectedSetupIDs: Set<String> = ["chatgpt", "claude", "gemini", "deepseek", "kimi", "qwen", "grok"]
    @State private var localScanning = false
    @State private var agentStripPage = 0

    var body: some View {
        VStack(spacing: 0) {
            if !setupDone {
                setupHome
            } else {
                mainContent
            }
        }
        .frame(
            minWidth: 720,
            minHeight: setupDone ? 172 : 420,
            alignment: .top
        )
        .onAppear {
            let currentVersion = appVersion
            let lastVersion = UserDefaults.standard.string(forKey: "agentsbin.lastVersion")
            if lastVersion != currentVersion {
                UserDefaults.standard.set(false, forKey: "agentsbin.setupDone")
                UserDefaults.standard.set(currentVersion, forKey: "agentsbin.lastVersion")
            }
            setupDone = UserDefaults.standard.bool(forKey: "agentsbin.setupDone")
            faviconStore.ensureLoaded(for: agentStore.agents)
            launchAtLogin = SMAppService.mainApp.status == .enabled
            localScanning = true
            Task {
                await localService.detectAllAsync()
                localScanning = false
                autoSelectDetectedLocal()
            }
        }
        .onChange(of: agentStore.agents) { _ in
            faviconStore.ensureLoaded(for: agentStore.agents)
        }
        .onChange(of: localService.detected) { _ in
            autoSelectDetectedLocal()
        }
        .onReceive(NotificationCenter.default.publisher(for: .agentsbinOpenAgentPanel)) { _ in
            agentPanelOpen = true
            mode = .chat
            manageAgents = false
            showAgentPicker = false
        }

        .onReceive(NotificationCenter.default.publisher(for: .agentsbinOpenSettings)) { note in
            pendingSettingsTab = note.object as? Int ?? 0
            pendingManageConfigID = nil
            mode = .manage
            manageAgents = false
            showAgentPicker = false
            agentPanelOpen = false
        }
    }

    private func autoSelectDetectedLocal() {
        guard !setupDone else { return }
        for provider in LocalProviderList.all where localService.isDetected(provider.id) {
            selectedSetupIDs.insert(provider.id)
        }
    }

    private func addCredential(forAgentID agentID: String) {
        let configID = apiKeyStore.config(forAgentID: agentID)?.id
            ?? APIKeyStore.agentToConfigMap[agentID]
            ?? agentID
        apiKeyStore.addCredential(to: configID)
        pendingManageConfigID = configID
        pendingSettingsTab = 1
        mode = .manage
        manageAgents = false
        showAgentPicker = false
        agentPanelOpen = false
    }

    private var setupHome: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("AgentsBin")
                .font(ThemeRegistry.current().titleFont)
            Text(localization.text("home_slogan"))
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            if localScanning {
                HStack(spacing: 5) {
                    ProgressView()
                        .controlSize(.small)
                    Text(localization.text("local_scanning"))
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
                .padding(.top, 6)
            }

            ScrollView {
                FlowLayout(spacing: 10) {
                    ForEach(setupAgents) { agent in
                        setupChip(agent)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .frame(maxWidth: 560)
            .frame(maxHeight: 190)
            .scrollIndicators(.hidden)

            Button {
                finishSetup()
            } label: {
                Text(localization.text("home_open"))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 220, height: 32)
                    .background(brandBlue, in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .padding(.top, 22)

            Toggle(isOn: $launchAtLogin) {
                Text(localization.text("home_boot"))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            .toggleStyle(.checkbox)
            .padding(.top, 10)

            Spacer()

            HStack(spacing: 8) {
                Text("AgentsBin V\(appVersion)")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(.tertiary)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color(nsColor: .textBackgroundColor))
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var setupAgents: [Agent] {
        agentStore.agents.sorted { a, b in
            let aSelected = selectedSetupIDs.contains(a.id)
            let bSelected = selectedSetupIDs.contains(b.id)
            if aSelected != bSelected {
                return aSelected && !bSelected
            }
            return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
        }
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
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(selected ? Color.white : Color.primary)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    selected ? brandBlue : Color.secondary.opacity(0.12),
                    in: Capsule()
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func finishSetup() {
        for agent in agentStore.agents where agent.isEnabled != selectedSetupIDs.contains(agent.id) {
            agentStore.setEnabled(agent.id, selectedSetupIDs.contains(agent.id))
        }
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
        UserDefaults.standard.set(true, forKey: "agentsbin.setupDone")
        setupDone = true
    }

    private var mainContent: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                rightPane
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(nsColor: .textBackgroundColor))
                rightFooterBar
            }
            if agentPanelOpen {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        agentPanelOpen = false
                        manageAgents = false
                    }
            }
            floatingPanel
        }
        .clipped()
    }

    private func panelHintText(for agent: Agent) -> String {
        let name = panelHintAgent ?? localization.agentName(agent.name)
        return name + " \u{00b7} " + localization.text("click_to_open")
    }

    private let topLogoSize: CGFloat = 24
    private let smallLogoSize: CGFloat = 16
    private let topLogoSpacing: CGFloat = 8
    private let topVisibleCount = 10

    private func agentStripOrder() -> [Agent] {
        let enabled = agentStore.enabledAgents
        guard let active = enabled.first(where: { $0.id == agentStore.activeID }) else {
            return enabled
        }
        let recents = agentStore.recentAgents.filter { $0.isEnabled && $0.id != active.id }
        let remaining = enabled.filter { agent in
            agent.id != active.id && !recents.contains { $0.id == agent.id }
        }
        return [active] + recents + remaining
    }

    @ViewBuilder
    private func topAgentStrip(collapsed: Bool) -> some View {
        let order = agentStripOrder()
        let others = Array(order.dropFirst())
        let pageCount = max(1, Int(ceil(Double(others.count) / Double(topVisibleCount - 1))))
        let page = min(max(0, agentStripPage), pageCount - 1)
        let start = page * (topVisibleCount - 1)
        let end = min(others.count, start + topVisibleCount - 1)
        HStack(spacing: topLogoSpacing) {
            if let current = order.first {
                topLogoButton(current, collapsed: collapsed, isCurrent: true)
            }
            if !others.isEmpty {
                Rectangle()
                    .fill(Color.primary.opacity(0.14))
                    .frame(width: 1, height: smallLogoSize)
                ForEach(others[start..<end]) { agent in
                    topLogoButton(agent, collapsed: collapsed)
                }
                if pageCount > 1 {
                    moreAgentsButton()
                }
            }
        }
        .frame(height: topLogoSize)
        .onChange(of: agentStore.activeID) { _ in
            agentStripPage = 0
        }
    }

    private func topLogoButton(_ agent: Agent, collapsed: Bool, isCurrent: Bool = false) -> some View {
        Button {
            if collapsed {
                selectAgentAndExpand(agent)
            } else {
                selectAgent(agent)
            }
        } label: {
            if isCurrent {
                activeLogo(agent)
            } else {
                avatar(agent, size: smallLogoSize)
            }
        }
        .buttonStyle(.plain)
        .help(panelHintText(for: agent))
        .onHover { hovering in
            panelHintAgent = hovering ? localization.agentName(agent.name) : nil
        }
        .contextMenu {
            Button(localization.text("visit_website")) {
                openExternal(localService.website(forAgent: agent))
            }
        }
    }

    private func activeLogo(_ agent: Agent) -> some View {
        avatar(agent, size: topLogoSize)
            .background(
                RoundedRectangle(cornerRadius: topLogoSize * 0.42)
                    .fill(brandBlue.opacity(0.35))
                    .frame(width: topLogoSize + 10, height: topLogoSize + 10)
                    .blur(radius: 6)
            )
            .shadow(color: brandBlue.opacity(0.75), radius: 5)
    }

    private func moreAgentsButton() -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                let others = agentStripOrder().dropFirst().count
                let pageCount = max(1, Int(ceil(Double(others) / Double(topVisibleCount - 1))))
                agentStripPage = (agentStripPage + 1) % pageCount
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: smallLogoSize + 2, height: smallLogoSize + 2)
                .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 7))
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.primary.opacity(0.14), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .help(localization.text("more_agents"))
    }

    private func selectAgent(_ agent: Agent) {
        agentStore.select(agent.id)
        webPool.markRead(agent.id)
        Analytics.track(kind: "agent_open", name: agent.id)
        mode = .chat
        chatTab = agent.isLocal ? .api : .web
        agentPanelOpen = false
        agentStripPage = 0
    }

    private func selectAgentAndExpand(_ agent: Agent) {
        selectAgent(agent)
        NotificationCenter.default.post(name: .agentsbinToggleCollapse, object: nil)
    }

    private var floatingPanel: some View {
        Group {
            if agentPanelOpen && mode != .manage {
                VStack(spacing: 0) {
                    agentList
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    HStack(spacing: 6) {
                        Button {
                            manageAgents.toggle()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: manageAgents ? "checkmark" : "wrench.adjustable")
                                    .font(.system(size: 12, weight: .regular))
                                Text(manageAgents ? localization.text("save_and_return") : localization.text("edit_agents"))
                                    .font(.system(size: 12, weight: .regular))
                            }
                            .foregroundStyle(manageAgents ? Color.white : Color.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 26)
                            .background(manageAgents ? brandBlue : Color.secondary.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                        .help(manageAgents ? localization.text("save_and_return") : localization.text("edit_agents_hint"))
                    }
                    .padding(8)
                }
                .frame(width: 260)
                .frame(maxHeight: 340)
                .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.22), radius: 12, y: 4)
                .padding(.trailing, 48)
                .padding(.top, 50)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.16), value: agentPanelOpen)
        .sheet(isPresented: $showAgentPicker) {
            AgentPickerView()
        }
    }

    private var agentList: some View {
        ScrollView {
            VStack(spacing: 2) {
                ForEach(sortedAgentList) { agent in
                    agentRow(agent)
                }
                Button {
                    showAgentPicker = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .medium))
                        Text(localization.text("add_custom_agent"))
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 26)
                    .background(Color.secondary.opacity(0.10), in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .help(localization.text("add_custom_agent_hint"))
            }
            .padding(6)
        }
    }

    private var sortedAgentList: [Agent] {
        let source = manageAgents ? agentStore.agents : agentStore.enabledAgents
        return source.sorted { a, b in
            if a.isEnabled != b.isEnabled {
                return a.isEnabled && !b.isEnabled
            }
            return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
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
                agentStatusDots(agent)
                Text(agentDisplayName(agent))
                    .font(.system(size: 13, weight: .regular))
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
            .padding(.vertical, 4)
            .background(
                isActive ? brandBlue : hoveredAgentID == agent.id ? brandBlue.opacity(0.10) : Color.clear,
                in: RoundedRectangle(cornerRadius: 6)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                selectAgent(agent)
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
                .font(.system(size: 11))
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

    @ViewBuilder
    private func agentStatusDots(_ agent: Agent) -> some View {
        if agent.isLocal {
            let detected = localService.isDetected(agent.id)
            Circle()
                .fill(detected ? Color.green : Color.gray)
                .frame(width: 7, height: 7)
                .help(localization.text("local_model") + (detected ? " \u{00b7} " + localization.text("local_detected") : ""))
        } else {
            let apiReady = apiKeyStore.hasAPIKey(forAgentID: agent.id)
            let webOK = webAvailable(for: agent)
            let color: Color = apiReady ? .green : (webOK ? .blue : .gray)
            let hint = localization.text("api_ready") + " / " + localization.text("api_missing")
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            .help(hint)
        }
    }

    private func agentDisplayName(_ agent: Agent) -> String {
        var name = localization.agentName(agent.name)
        if agent.isLocal {
            name += localization.text("local_tag")
        } else if apiKeyStore.hasAPIKey(forAgentID: agent.id) {
            name += localization.text("api_tag")
        }
        return name
    }

    private func webAvailable(for agent: Agent) -> Bool {
        let target = agent.urlString.hasPrefix("http") ? agent.urlString : "https://" + agent.urlString
        return URL(string: target)?.host != nil
    }

    private func avatar(_ agent: Agent, size: CGFloat = 16) -> some View {
        let corner = max(4, size * 0.25)
        let base: AnyView
        if let image = faviconStore.images[agent.id] {
            base = AnyView(
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: corner))
            )
        } else {
            base = AnyView(
                Text(agent.letter)
                    .font(.system(size: max(9, size * 0.56), weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: size, height: size)
                    .background(Color(hex: agent.colorHex), in: RoundedRectangle(cornerRadius: corner))
            )
        }
        return AnyView(
            base
                .overlay(
                    RoundedRectangle(cornerRadius: corner)
                        .stroke(Color.primary.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.28), radius: 1.5, y: 1)
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
            ManageView(onBack: {
                pendingManageConfigID = nil
                mode = .chat
                manageAgents = false
                agentPanelOpen = false
            }, initialTab: pendingSettingsTab, initialConfigID: pendingManageConfigID)
        }
    }

    private var tabSelector: some View {
        let agent = agentStore.activeAgent
        let isLocal = agent.isLocal
        let webColor: Color = webAvailable(for: agent) ? .blue : .gray
        let apiColor: Color = isLocal
            ? (localService.isDetected(agent.id) ? .green : .gray)
            : (apiKeyStore.hasAPIKey(forAgentID: agent.id) ? .green : .gray)
        return HStack(spacing: 2) {
            if !isLocal {
                Button {
                    chatTab = .web
                } label: {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(webColor)
                            .frame(width: 7, height: 7)
                        Text(localization.text("web_mode"))
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 24)
                    .background(
                        chatTab == .web ? Color(nsColor: .windowBackgroundColor) : Color.clear,
                        in: Capsule()
                    )
                    .shadow(color: chatTab == .web ? Color.black.opacity(0.16) : Color.clear, radius: 2, y: 0.5)
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            Button {
                chatTab = .api
            } label: {
                HStack(spacing: 6) {
                    Circle()
                        .fill(apiColor)
                        .frame(width: 7, height: 7)
                    Text(localization.text("client_mode"))
                        .font(.system(size: 12, weight: .medium))
                }
                .padding(.horizontal, 12)
                .frame(height: 24)
                .background(
                    chatTab == .api ? Color(nsColor: .windowBackgroundColor) : Color.clear,
                    in: Capsule()
                )
                .shadow(color: chatTab == .api ? Color.black.opacity(0.16) : Color.clear, radius: 2, y: 0.5)
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(3)
        .background(Color(nsColor: .controlBackgroundColor), in: Capsule())
    }

    private var chatPane: some View {
        let agent = agentStore.activeAgent
        return VStack(spacing: 0) {
            HStack(spacing: 8) {
                topAgentStrip(collapsed: false)

                Spacer(minLength: 0)

                Text(localization.agentName(agent.name))
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)

                Button {
                    openExternal(localService.website(forAgent: agent))
                } label: {
                    Text(websiteDomain(localService.website(forAgent: agent)))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                        .underline()
                        .lineLimit(1)
                }
                .buttonStyle(.plain)
                .onHover { inside in
                    if inside {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                    )
            )
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 6)
            switch chatTab {
            case .web:
                if agent.isLocal {
                    ClientChatView(
                        agent: agent,
                        onOpenSettings: {
                            pendingSettingsTab = 1
                            pendingManageConfigID = nil
                            mode = .manage
                        },
                        onAddCredential: {
                            addCredential(forAgentID: agent.id)
                        }
                    )
                    .id(agent.id)
                } else {
                    WebViewPoolView(agent: agent, pool: webPool)
                        .id(agent.id)
                        .padding(6)
                }
            case .api:
                ClientChatView(
                    agent: agent,
                    onOpenSettings: {
                        pendingSettingsTab = 1
                        pendingManageConfigID = nil
                        mode = .manage
                    },
                    onAddCredential: {
                        addCredential(forAgentID: agent.id)
                    }
                )
                .id(agent.id)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if agentStore.activeAgent.isLocal { chatTab = .api }
        }
        .onChange(of: agentStore.activeAgent.id) { _ in
            chatTab = agentStore.activeAgent.isLocal ? .api : .web
        }
    }

    private var rightFooterBar: some View {
        ZStack {
            HStack(spacing: 8) {
                Button {
                    openExternal("https://www.agentsbin.com")
                } label: {
                    Image(systemName: "globe")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 18, height: 18)
                }
                .buttonStyle(.plain)
                .help("https://www.agentsbin.com")

                Text("AgentsBin V\(appVersion)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.tertiary)

                Spacer(minLength: 0)

                HStack(spacing: 6) {
                    Button {
                        agentPanelOpen.toggle()
                    } label: {
                        Image(systemName: "wrench.adjustable")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 18, height: 18)
                    }
                    .buttonStyle(.plain)
                    .help(localization.text("edit_agents"))

                    Button {
                        agentPanelOpen = false
                        pendingSettingsTab = 0
                        pendingManageConfigID = nil
                        mode = .manage
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 18, height: 18)
                    }
                    .buttonStyle(.plain)
                    .help(localization.text("settings"))
                }
            }
            if mode == .chat {
                tabSelector
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }

    private func openExternal(_ urlString: String) {
        guard let url = URL(string: urlString.hasPrefix("http") ? urlString : "https://" + urlString) else { return }
        NSWorkspace.shared.open(url)
    }

    private func websiteDomain(_ urlString: String) -> String {
        let trimmed = urlString.hasPrefix("http") ? urlString : "https://" + urlString
        guard let host = URL(string: trimmed)?.host else { return urlString }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
}

struct CollapsedBarRootView: View {
    @EnvironmentObject private var agentStore: AgentStore
    @EnvironmentObject private var webPool: WebViewPool
    @EnvironmentObject private var faviconStore: FaviconStore
    @EnvironmentObject private var localization: LocalizedStore
    @ObservedObject private var localService = LocalModelService.shared

    @State private var panelHintAgent: String?
    @State private var agentStripPage = 0

    private let topLogoSize: CGFloat = 24
    private let topLogoSpacing: CGFloat = 8
    private let topVisibleCount = 10

    var body: some View {
        HStack(spacing: 8) {
            topAgentStrip

            Button {
                NotificationCenter.default.post(name: .agentsbinToggleCollapse, object: nil)
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 10, weight: .bold))
                    Text(panelHintText(for: agentStore.activeAgent))
                        .font(.system(size: 11, weight: .medium))
                        .lineLimit(1)
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 9)
                .frame(height: 24)
                .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .help(panelHintText(for: agentStore.activeAgent))

            Spacer(minLength: 0)

            AgentPanelButton(isOpen: false) {
                NotificationCenter.default.post(name: .agentsbinToggleCollapse, object: nil)
                NotificationCenter.default.post(name: .agentsbinOpenAgentPanel, object: nil)
            }

            CollapseWindowButton()
                .padding(.leading, 2)
        }
        .padding(.horizontal, 16)
        .frame(minWidth: 720, maxWidth: .infinity, minHeight: 44, maxHeight: 44)
        .background(Color(nsColor: .textBackgroundColor))
        .onChange(of: agentStore.activeID) { _ in
            agentStripPage = 0
        }
    }

    private var topAgentStrip: some View {
        let order = agentStripOrder()
        let others = Array(order.dropFirst())
        let pageCount = max(1, Int(ceil(Double(others.count) / Double(topVisibleCount - 1))))
        let page = min(max(0, agentStripPage), pageCount - 1)
        let start = page * (topVisibleCount - 1)
        let end = min(others.count, start + topVisibleCount - 1)
        return HStack(spacing: topLogoSpacing) {
            if let current = order.first {
                topLogoButton(current, isCurrent: true)
            }
            if !others.isEmpty {
                Rectangle()
                    .fill(Color.primary.opacity(0.14))
                    .frame(width: 1, height: 20)
                ForEach(others[start..<end]) { agent in
                    topLogoButton(agent)
                }
                if pageCount > 1 {
                    moreAgentsButton()
                }
            }
        }
        .frame(height: topLogoSize)
    }

    private func topLogoButton(_ agent: Agent, isCurrent: Bool = false) -> some View {
        Button {
            selectAgentAndExpand(agent)
        } label: {
            if isCurrent {
                activeLogo(agent)
            } else {
                avatar(agent, size: topLogoSize)
            }
        }
        .buttonStyle(.plain)
        .help(panelHintText(for: agent))
        .onHover { hovering in
            panelHintAgent = hovering ? localization.agentName(agent.name) : nil
        }
        .contextMenu {
            Button(localization.text("visit_website")) {
                openExternal(localService.website(forAgent: agent))
            }
        }
    }

    private func activeLogo(_ agent: Agent) -> some View {
        avatar(agent, size: topLogoSize)
            .background(
                RoundedRectangle(cornerRadius: topLogoSize * 0.42)
                    .fill(brandBlue.opacity(0.35))
                    .frame(width: topLogoSize + 10, height: topLogoSize + 10)
                    .blur(radius: 6)
            )
            .shadow(color: brandBlue.opacity(0.75), radius: 5)
    }

    private func moreAgentsButton() -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                let others = agentStripOrder().dropFirst().count
                let pageCount = max(1, Int(ceil(Double(others) / Double(topVisibleCount - 1))))
                agentStripPage = (agentStripPage + 1) % pageCount
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: topLogoSize + 2, height: topLogoSize + 2)
                .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 7))
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.primary.opacity(0.14), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .help(localization.text("more_agents"))
    }

    private func selectAgentAndExpand(_ agent: Agent) {
        agentStore.select(agent.id)
        webPool.markRead(agent.id)
        Analytics.track(kind: "agent_open", name: agent.id)
        NotificationCenter.default.post(name: .agentsbinToggleCollapse, object: nil)
    }

    private func panelHintText(for agent: Agent) -> String {
        let name = panelHintAgent ?? localization.agentName(agent.name)
        return name + " \u{00b7} " + localization.text("click_to_open")
    }

    private func agentStripOrder() -> [Agent] {
        let enabled = agentStore.enabledAgents
        guard let active = enabled.first(where: { $0.id == agentStore.activeID }) else {
            return enabled
        }
        let recents = agentStore.recentAgents.filter { $0.isEnabled && $0.id != active.id }
        let remaining = enabled.filter { agent in
            agent.id != active.id && !recents.contains { $0.id == agent.id }
        }
        return [active] + recents + remaining
    }

    private func avatar(_ agent: Agent, size: CGFloat = 16) -> some View {
        let corner = max(4, size * 0.25)
        let base: AnyView
        if let image = faviconStore.images[agent.id] {
            base = AnyView(
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: corner))
            )
        } else {
            base = AnyView(
                Text(agent.letter)
                    .font(.system(size: max(9, size * 0.56), weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: size, height: size)
                    .background(Color(hex: agent.colorHex), in: RoundedRectangle(cornerRadius: corner))
            )
        }
        return AnyView(
            base
                .overlay(
                    RoundedRectangle(cornerRadius: corner)
                        .stroke(Color.primary.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.28), radius: 1.5, y: 1)
        )
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
    let initialConfigID: String?
    @State private var selectedConfigID: String?
    @State private var settingsTab = 0
    @State private var generalItem = 0
    @State private var showAddAPIProvider = false
    @State private var addAPIProviderName = ""
    @State private var apiKeyMasked = true
    @FocusState private var addProviderFocused: Bool
    @State private var pendingDeleteID: String?
    @State private var draggedProviderID: String?
    @State private var launchAtLogin = false
    @State private var darkModeEnabled = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua

    init(onBack: @escaping () -> Void, initialTab: Int = 0, initialConfigID: String? = nil) {
        self.onBack = onBack
        self.initialConfigID = initialConfigID
        _settingsTab = State(initialValue: initialTab)
        _selectedConfigID = State(initialValue: initialConfigID)
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
                Image(systemName: "chevron.left")
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
            CollapseWindowButton()
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

            VStack(alignment: .leading, spacing: 4) {
                Text(localization.text("base_url"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                TextField(localization.text("base_url"), text: Binding(
                    get: { credential.baseURL },
                    set: { value in
                        var copy = credential
                        copy.baseURL = value
                        apiKeyStore.updateCredential(configID: config.id, credential: copy)
                    }
                ))
                .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(localization.text("model"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                TextField(localization.text("model"), text: Binding(
                    get: { credential.model },
                    set: { value in
                        var copy = credential
                        copy.model = value
                        apiKeyStore.updateCredential(configID: config.id, credential: copy)
                    }
                ))
                .textFieldStyle(.roundedBorder)
            }

            HStack(spacing: 8) {
                Group {
                    if apiKeyMasked {
                        SecureField(localization.text("api_key"), text: Binding(
                            get: { apiKeyStore.apiKey(for: credential.id) },
                            set: { apiKeyStore.save(apiKey: $0, for: credential.id) }
                        ))
                    } else {
                        TextField(localization.text("api_key"), text: Binding(
                            get: { apiKeyStore.apiKey(for: credential.id) },
                            set: { apiKeyStore.save(apiKey: $0, for: credential.id) }
                        ))
                    }
                }
                .textFieldStyle(.roundedBorder)
                Button {
                    apiKeyMasked.toggle()
                } label: {
                    Image(systemName: apiKeyMasked ? "eye" : "eye.slash")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help(localization.text(apiKeyMasked ? "show_password" : "hide_password"))
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
        .frame(width: 420, height: 280)
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
