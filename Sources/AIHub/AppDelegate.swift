import AppKit
import SwiftUI

extension Notification.Name {
    static let agentsbinOpenSettings = Notification.Name("agentsbin.openSettings")
    static let agentsbinToggleCollapse = Notification.Name("agentsbin.toggleCollapse")
    static let agentsbinCollapseStateChanged = Notification.Name("agentsbin.collapseStateChanged")
    static let agentsbinOpenAgentPanel = Notification.Name("agentsbin.openAgentPanel")
    static let agentsbinLanguageChanged = Notification.Name("agentsbin.languageChanged")
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    static weak var mainPanel: NSPanel?

    private var statusItem: NSStatusItem?
    private var fallbackCapsule: NSPanel?
    private var capsuleView: CapsuleButtonView?
    private var panel: NSPanel?
    private var hostingController: NSHostingController<AnyView>?
    private var collapsedHostingController: NSHostingController<AnyView>?

    private let agentStore = AgentStore()
    private let webPool = WebViewPool()
    private let localization = LocalizedStore()
    private let faviconStore = FaviconStore()
    private let apiKeyStore = APIKeyStore()

    private let defaultSize = NSSize(width: 960, height: 560)
    private let collapsedRowHeight: CGFloat = 44
    private let sizeKey = "agentsbin.windowSize"
    private let originKey = "agentsbin.windowOrigin"
    private var arrowUp = false
    private var arrowFlash = true
    private var placementTimer: Timer?
    private var isCollapsed = false
    private var expandedFrameSize: NSSize?

    private var primaryScreen: NSScreen? {
        NSScreen.screens.first(where: { $0.frame.contains(NSPoint(x: 0, y: 0)) }) ?? NSScreen.main
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let pid = ProcessInfo.processInfo.processIdentifier
        for running in NSRunningApplication.runningApplications(withBundleIdentifier: "com.agentsbin.app")
        where running.processIdentifier != pid {
            running.terminate()
        }
        NSApp.setActivationPolicy(.accessory)
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        let lastVersion = UserDefaults.standard.string(forKey: "agentsbin.lastVersion")
        let storedAppearance = UserDefaults.standard.string(forKey: "aihome.appearance")
        if let raw = storedAppearance,
           lastVersion == currentVersion,
           let appearance = NSAppearance(named: NSAppearance.Name(rawValue: raw)) {
            NSApp.appearance = appearance
        } else {
            NSApp.appearance = NSAppearance(named: .darkAqua)
            UserDefaults.standard.set(NSAppearance.Name.darkAqua.rawValue, forKey: "aihome.appearance")
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCollapseToggle),
            name: .agentsbinToggleCollapse,
            object: nil
        )
        faviconStore.ensureLoaded(for: agentStore.agents)
        Analytics.track(kind: "app_open", name: "app")
        setupStatusItem()
        if lastVersion != currentVersion {
            UserDefaults.standard.removeObject(forKey: originKey)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.showPanel()
            }
        }
        if ProcessInfo.processInfo.environment["AGENTSBIN_AUTOSHOW"] == "1" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.showPanel()
            }
        }
        if let raw = ProcessInfo.processInfo.environment["AGENTSBIN_OPEN_SETTINGS"],
           let tab = Int(raw) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                self?.showPanel()
                NotificationCenter.default.post(name: .agentsbinOpenSettings, object: tab)
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showPanel()
        return true
    }

    private func setupStatusItem() {
        statusItem = nil
        let item = NSStatusBar.system.statusItem(withLength: 34)
        if let button = item.button {
            button.title = "[AB]"
            button.image = menuBarIcon(arrowUp: false, arrowVisible: true)
            button.action = #selector(statusItemClicked)
            button.target = self
            button.toolTip = "AgentsBin"
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        statusItem = item
        placementTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.repairStatusItemPlacement()
            self.updateFallbackCapsule()
        }
    }

    private func repairStatusItemPlacement() {
        guard let win = statusItem?.button?.window, !win.frame.isEmpty,
              let primary = primaryScreen else { return }
        let frame = primary.frame
        let onPrimaryStrip = win.frame.minY >= frame.maxY - 44
            && win.frame.minY <= frame.maxY
            && win.frame.minX >= frame.minX
            && win.frame.maxX <= frame.maxX
        if !onPrimaryStrip {
            let targetX = min(frame.maxX - win.frame.width - 80, frame.maxX - win.frame.width)
            win.setFrameOrigin(NSPoint(
                x: max(targetX, frame.minX + 100),
                y: frame.maxY - win.frame.height
            ))
        }
    }

    private func statusItemOnPrimaryMenuBar() -> Bool {
        guard let win = statusItem?.button?.window, !win.frame.isEmpty,
              let primary = primaryScreen else { return false }
        let frame = primary.frame
        return win.frame.minY >= frame.maxY - 44
            && win.frame.minY <= frame.maxY
            && win.frame.minX >= frame.minX
            && win.frame.maxX <= frame.maxX
    }

    private func updateFallbackCapsule() {
        if let fallbackCapsule {
            if let view = capsuleView {
                let hint = capsuleHint()
                if view.hint != hint {
                    view.hint = hint
                    let width = capsuleWidth(for: hint)
                    fallbackCapsule.setContentSize(NSSize(width: width, height: 30))
                    view.frame = NSRect(x: 0, y: 0, width: width, height: 30)
                    view.needsDisplay = true
                    pinCapsule(fallbackCapsule, width: width)
                }
            }
            fallbackCapsule.orderFrontRegardless()
            return
        }
        guard let primary = primaryScreen else { return }
        let hint = capsuleHint()
        let width = capsuleWidth(for: hint)
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: width, height: 30),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.isFloatingPanel = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isMovable = false
        panel.hidesOnDeactivate = false
        panel.ignoresMouseEvents = false
        let view = CapsuleButtonView(frame: NSRect(x: 0, y: 0, width: width, height: 30))
        view.hint = hint
        view.onClick = { [weak self] in self?.statusItemClicked() }
        view.onRightClick = { [weak self] in
            guard let view = self?.capsuleView else { return }
            self?.showMenu(at: view)
        }
        panel.contentView = view
        fallbackCapsule = panel
        capsuleView = view
        pinCapsule(panel, width: width)
        panel.orderFrontRegardless()
        _ = primary
    }

    private func capsuleHint() -> String {
        let action = panel?.isVisible == true ? "Click to minimize" : "Click to open"
        return "\(agentStore.activeAgent.name) \(action)"
    }

    private func capsuleWidth(for text: String) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: .medium)
        ]
        return (text as NSString).size(withAttributes: attributes).width + 52
    }

    private func pinCapsule(_ panel: NSPanel, width: CGFloat) {
        guard let primary = primaryScreen else { return }
        panel.setFrameOrigin(NSPoint(
            x: primary.frame.maxX - width - 12,
            y: primary.frame.maxY - 30 - 4
        ))
    }

    private func showMenu(at view: NSView) {
        guard let event = NSApp.currentEvent else { return }
        NSMenu.popUpContextMenu(buildStatusMenu(), with: event, for: view)
    }

    private func menuBarIcon(arrowUp: Bool, arrowVisible: Bool) -> NSImage {
        let size = NSSize(width: 34, height: 20)
        let image = NSImage(size: size)
        image.lockFocus()
        let text = "[AB]" as NSString
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .bold)
        ]
        let textSize = text.size(withAttributes: attributes)
        text.draw(
            at: NSPoint(x: (size.width - textSize.width) / 2, y: 5),
            withAttributes: attributes
        )
        if arrowVisible {
            let path = NSBezierPath()
            let centerX = size.width / 2
            if arrowUp {
                path.move(to: NSPoint(x: centerX, y: 4))
                path.line(to: NSPoint(x: centerX - 3.5, y: 0.5))
                path.line(to: NSPoint(x: centerX + 3.5, y: 0.5))
            } else {
                path.move(to: NSPoint(x: centerX, y: 0.5))
                path.line(to: NSPoint(x: centerX - 3.5, y: 4))
                path.line(to: NSPoint(x: centerX + 3.5, y: 4))
            }
            path.close()
            NSColor.controlTextColor.setFill()
            path.fill()
        }
        image.unlockFocus()
        image.isTemplate = true
        return image
    }

    private func updateMenuBarArrow(up: Bool) {
        arrowUp = up
        arrowFlash = true
        statusItem?.button?.image = menuBarIcon(arrowUp: up, arrowVisible: true)
    }

    @objc private func togglePanel() {
        if let panel, panel.isVisible {
            if isCollapsed {
                expandPanel(panel)
                updateMenuBarArrow(up: true)
            } else {
                panel.orderOut(nil)
                updateMenuBarArrow(up: false)
                updateFallbackCapsule()
            }
        } else {
            showPanel()
        }
    }

    @objc private func statusItemClicked() {
        if NSApp.currentEvent?.type == .rightMouseUp {
            showStatusMenu()
        } else {
            togglePanel()
        }
    }

    private func showStatusMenu() {
        statusItem?.menu = buildStatusMenu()
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    private func buildStatusMenu() -> NSMenu {
        let menu = NSMenu()
        let openItem = NSMenuItem(title: localization.text("open_app"), action: #selector(togglePanel), keyEquivalent: "")
        openItem.target = self
        let websiteItem = NSMenuItem(title: localization.text("visit_website"), action: #selector(openWebsite), keyEquivalent: "")
        websiteItem.target = self
        let terminalItem = NSMenuItem(title: localization.text("terminal"), action: #selector(openTerminalApp), keyEquivalent: "")
        terminalItem.target = self
        let settingsItem = NSMenuItem(title: localization.text("settings"), action: #selector(showSettings), keyEquivalent: ",")
        settingsItem.target = self
        let quitItem = NSMenuItem(title: localization.text("quit"), action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(openItem)
        menu.addItem(websiteItem)
        menu.addItem(terminalItem)
        menu.addItem(settingsItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitItem)
        return menu
    }

    @objc private func openTerminalApp() {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Terminal.app"))
    }

    @objc private func openWebsite() {
        guard let url = URL(string: "https://www.agentsbin.com") else { return }
        NSWorkspace.shared.open(url)
    }

    @objc private func showSettings() {
        showPanel()
        NotificationCenter.default.post(name: .agentsbinOpenSettings, object: nil)
    }

    @objc private func handleCollapseToggle() {
        toggleCollapse()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    private func showPanel() {
        if hostingController == nil {
            let view = MainPopoverView()
                .environmentObject(agentStore)
                .environmentObject(webPool)
                .environmentObject(localization)
                .environmentObject(faviconStore)
                .environmentObject(apiKeyStore)
            hostingController = NSHostingController(rootView: AnyView(view))
        }

        if panel == nil {
            let panel = NSPanel(
                contentRect: NSRect(origin: .zero, size: defaultSize),
                styleMask: [.titled, .closable, .resizable, .utilityWindow, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            panel.isFloatingPanel = true
            panel.level = .floating
            panel.hidesOnDeactivate = false
            panel.becomesKeyOnlyIfNeeded = true
            panel.isMovableByWindowBackground = false
            panel.titleVisibility = .hidden
            panel.titlebarAppearsTransparent = true
            panel.isReleasedWhenClosed = false
            panel.minSize = NSSize(width: 720, height: 200)
            panel.delegate = self
            panel.contentViewController = hostingController
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            if let raw = UserDefaults.standard.string(forKey: sizeKey) {
                let size = NSSizeFromString(raw)
                if size.width >= 720, size.height >= 200 {
                    panel.setContentSize(size)
                } else {
                    panel.setContentSize(defaultSize)
                }
            } else {
                panel.setContentSize(defaultSize)
            }
            if let rawOrigin = UserDefaults.standard.string(forKey: originKey) {
                let origin = NSPointFromString(rawOrigin)
                panel.setFrameOrigin(origin)
            } else {
                positionPanel()
            }
            self.panel = panel
            Self.mainPanel = panel
        }

        updateMenuBarArrow(up: true)
        NSApp.activate(ignoringOtherApps: true)
        panel?.orderFrontRegardless()
        panel?.makeKey()
        updateFallbackCapsule()
    }

    func windowDidResize(_ notification: Notification) {
        guard let panel = notification.object as? NSPanel else { return }
        let size = panel.frame.size
        if isCollapsed { return }
        guard size.width >= 720, size.height >= 200 else { return }
        UserDefaults.standard.set(NSStringFromSize(size), forKey: sizeKey)
    }

    func windowDidMove(_ notification: Notification) {
        guard let panel = notification.object as? NSPanel else { return }
        UserDefaults.standard.set(NSStringFromPoint(panel.frame.origin), forKey: originKey)
    }

    private func positionPanel() {
        guard let panel, let screen = primaryScreen else { return }
        let visible = screen.visibleFrame
        let size = panel.frame.size
        var x = visible.midX - size.width / 2
        if let buttonFrame = statusItem?.button?.window?.frame {
            x = buttonFrame.midX - size.width / 2
            x = min(max(x, visible.minX + 8), visible.maxX - size.width - 8)
        }
        let y = visible.maxY - size.height - 6
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    private func toggleCollapse() {
        guard let panel else { return }
        if isCollapsed {
            expandPanel(panel)
        } else {
            collapsePanel(panel)
        }
    }

    private func collapsePanel(_ panel: NSPanel) {
        expandedFrameSize = panel.frame.size
        guard let expanded = expandedFrameSize else { return }
        UserDefaults.standard.set(NSStringFromSize(expanded), forKey: sizeKey)

        let oldFrame = panel.frame
        var style = panel.styleMask
        style.remove(.titled)
        style.remove(.resizable)
        panel.styleMask = style
        panel.isMovableByWindowBackground = true
        panel.hasShadow = true
        let newHeight = collapsedRowHeight
        panel.minSize = NSSize(width: 720, height: newHeight)
        isCollapsed = true
        attachCollapsedBar(to: panel, width: oldFrame.width, height: newHeight)
        NotificationCenter.default.post(name: .agentsbinCollapseStateChanged, object: NSNumber(value: true))
        panel.setFrame(
            NSRect(
                x: oldFrame.minX,
                y: oldFrame.maxY - newHeight,
                width: oldFrame.width,
                height: newHeight
            ),
            display: true,
            animate: false
        )
        panel.setFrameTopLeftPoint(NSPoint(x: oldFrame.minX, y: oldFrame.maxY))
        DispatchQueue.main.async {
            panel.minSize = NSSize(width: 720, height: newHeight)
        }
    }

    private func attachCollapsedBar(to panel: NSPanel, width: CGFloat, height: CGFloat) {
        if collapsedHostingController == nil {
            let view = CollapsedBarRootView()
                .environmentObject(agentStore)
                .environmentObject(webPool)
                .environmentObject(localization)
                .environmentObject(faviconStore)
            collapsedHostingController = NSHostingController(rootView: AnyView(view))
        }
        panel.contentViewController = collapsedHostingController
        collapsedHostingController?.view.setFrameSize(NSSize(width: width, height: height))
    }

    private func expandPanel(_ panel: NSPanel) {
        let targetSize = expandedFrameSize ?? defaultSize
        let oldFrame = panel.frame
        var style = panel.styleMask
        style.insert(.titled)
        style.insert(.resizable)
        panel.styleMask = style
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = false
        panel.minSize = NSSize(width: 720, height: 200)
        expandedFrameSize = nil
        isCollapsed = false
        if let hostingController {
            panel.contentViewController = hostingController
            hostingController.view.setFrameSize(NSSize(width: targetSize.width, height: targetSize.height))
        }
        NotificationCenter.default.post(name: .agentsbinCollapseStateChanged, object: NSNumber(value: false))
        panel.setFrame(
            NSRect(
                x: oldFrame.minX,
                y: oldFrame.maxY - targetSize.height,
                width: targetSize.width,
                height: targetSize.height
            ),
            display: true,
            animate: false
        )
        panel.setFrameTopLeftPoint(NSPoint(x: oldFrame.minX, y: oldFrame.maxY))
    }
}

final class CapsuleButtonView: NSView {
    var onClick: (() -> Void)?
    var onRightClick: (() -> Void)?
    var hint = ""

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let pill = NSBezierPath(
            roundedRect: bounds.insetBy(dx: 1, dy: 1),
            xRadius: bounds.height / 2,
            yRadius: bounds.height / 2
        )
        NSColor.controlBackgroundColor.setFill()
        pill.fill()
        NSColor.separatorColor.setStroke()
        pill.lineWidth = 1
        pill.stroke()

        let text = hint as NSString
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: NSColor.labelColor
        ]
        let textSize = text.size(withAttributes: attributes)
        text.draw(
            at: NSPoint(x: 12, y: (bounds.height - textSize.height) / 2),
            withAttributes: attributes
        )

        let robotSize: CGFloat = 15
        let robot = RobotGlyph.image(
            size: robotSize,
            tint: .white,
            cutout: NSColor.controlBackgroundColor
        )
        robot.draw(
            in: NSRect(
                x: bounds.maxX - robotSize - 9,
                y: (bounds.height - robotSize) / 2,
                width: robotSize,
                height: robotSize
            ),
            from: .zero,
            operation: .sourceOver,
            fraction: 1
        )
    }

    override func mouseDown(with event: NSEvent) {
        onClick?()
    }

    override func rightMouseDown(with event: NSEvent) {
        onRightClick?()
    }
}

enum RobotGlyph {
    static func image(size: CGFloat, tint: NSColor, cutout: NSColor) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()
        let inset = size * 0.15
        let antenna = NSBezierPath()
        antenna.move(to: NSPoint(x: size / 2, y: size * 0.62))
        antenna.line(to: NSPoint(x: size / 2, y: size))
        antenna.lineWidth = 1.5
        tint.setStroke()
        antenna.stroke()
        let head = NSBezierPath(
            roundedRect: NSRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2 - 2),
            xRadius: size * 0.18,
            yRadius: size * 0.18
        )
        tint.setFill()
        head.fill()
        cutout.setFill()
        NSBezierPath(rect: NSRect(x: size * 0.30, y: size * 0.42, width: size * 0.14, height: size * 0.24)).fill()
        NSBezierPath(rect: NSRect(x: size * 0.56, y: size * 0.42, width: size * 0.14, height: size * 0.24)).fill()
        image.unlockFocus()
        return image
    }
}
