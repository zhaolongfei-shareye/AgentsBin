import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    static weak var mainPanel: NSPanel?

    private var statusItem: NSStatusItem?
    private var panel: NSPanel?
    private var hostingController: NSHostingController<AnyView>?

    private let agentStore = AgentStore()
    private let webPool = WebViewPool()
    private let localization = LocalizedStore()
    private let faviconStore = FaviconStore()
    private let apiKeyStore = APIKeyStore()

    private let defaultSize = NSSize(width: 960, height: 560)
    private let sizeKey = "agentsbin.windowSize"
    private let originKey = "agentsbin.windowOrigin"
    private var arrowUp = false
    private var arrowFlash = true
    private var arrowTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let pid = ProcessInfo.processInfo.processIdentifier
        for running in NSRunningApplication.runningApplications(withBundleIdentifier: "com.agentsbin.app")
        where running.processIdentifier != pid {
            running.terminate()
        }
        NSApp.setActivationPolicy(.accessory)
        if let raw = UserDefaults.standard.string(forKey: "aihome.appearance"),
           let appearance = NSAppearance(named: NSAppearance.Name(rawValue: raw)) {
            NSApp.appearance = appearance
        } else {
            NSApp.appearance = NSAppearance(named: .darkAqua)
            UserDefaults.standard.set(NSAppearance.Name.darkAqua.rawValue, forKey: "aihome.appearance")
        }
        faviconStore.ensureLoaded(for: agentStore.agents)
        Analytics.track(kind: "app_open", name: "app")
        setupStatusItem()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: 30)
        if let button = item.button {
            button.image = menuBarIcon(arrowUp: false, arrowVisible: true)
            button.action = #selector(statusItemClicked)
            button.target = self
            button.toolTip = "AgentsBin"
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        statusItem = item
        arrowTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
            guard let self, let button = self.statusItem?.button else { return }
            self.arrowFlash.toggle()
            button.image = self.menuBarIcon(arrowUp: self.arrowUp, arrowVisible: self.arrowFlash)
        }
    }

    private func menuBarIcon(arrowUp: Bool, arrowVisible: Bool) -> NSImage {
        let size = NSSize(width: 26, height: 24)
        let image = NSImage(size: size)
        image.lockFocus()
        let text = "[AB]" as NSString
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: NSColor.black
        ]
        text.draw(at: NSPoint(x: 1, y: 6), withAttributes: attrs)
        if arrowVisible,
           let arrow = NSImage(systemSymbolName: arrowUp ? "chevron.up" : "chevron.down", accessibilityDescription: nil) {
            arrow.draw(in: NSRect(x: 9, y: 0, width: 8, height: 5), from: .zero, operation: .sourceOver, fraction: 0.95)
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
            panel.orderOut(nil)
            updateMenuBarArrow(up: false)
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
        let menu = NSMenu()
        let openItem = NSMenuItem(title: localization.text("open_app"), action: #selector(togglePanel), keyEquivalent: "")
        openItem.target = self
        let quitItem = NSMenuItem(title: localization.text("quit"), action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(openItem)
        menu.addItem(quitItem)
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
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
            panel.minSize = NSSize(width: 720, height: 420)
            panel.delegate = self
            panel.contentViewController = hostingController
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            if let raw = UserDefaults.standard.string(forKey: sizeKey) {
                let size = NSSizeFromString(raw)
                if size.width >= 720, size.height >= 420 {
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
    }

    func windowDidResize(_ notification: Notification) {
        guard let panel = notification.object as? NSPanel else { return }
        let size = panel.frame.size
        guard size.width >= 720, size.height >= 420 else { return }
        UserDefaults.standard.set(NSStringFromSize(size), forKey: sizeKey)
    }

    func windowDidMove(_ notification: Notification) {
        guard let panel = notification.object as? NSPanel else { return }
        UserDefaults.standard.set(NSStringFromPoint(panel.frame.origin), forKey: originKey)
    }

    private func positionPanel() {
        guard let panel, let screen = NSScreen.main else { return }
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
}
