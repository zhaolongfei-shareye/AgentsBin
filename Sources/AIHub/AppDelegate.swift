import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var panel: NSPanel?
    private var hostingController: NSHostingController<AnyView>?

    private let agentStore = AgentStore()
    private let webPool = WebViewPool()
    private let localization = LocalizedStore()
    private let faviconStore = FaviconStore()

    private let defaultSize = NSSize(width: 960, height: 680)

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        if let raw = UserDefaults.standard.string(forKey: "aihome.appearance"),
           let appearance = NSAppearance(named: NSAppearance.Name(rawValue: raw)) {
            NSApp.appearance = appearance
        }
        faviconStore.ensureLoaded(for: agentStore.agents)
        setupStatusItem()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            let iconPath = Bundle.main.path(forResource: "MenuBarIcon", ofType: "png")
            let icon = iconPath.flatMap(NSImage.init(contentsOfFile:))
                ?? NSImage(systemSymbolName: "sparkles", accessibilityDescription: "AIhome")
            icon?.isTemplate = true
            icon?.size = NSSize(width: 18, height: 18)
            button.image = icon
            button.action = #selector(statusItemClicked)
            button.target = self
            button.toolTip = "AgentsBin"
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        statusItem = item
    }

    @objc private func togglePanel() {
        if let panel, panel.isVisible {
            panel.orderOut(nil)
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
            panel.minSize = NSSize(width: 720, height: 520)
            panel.contentViewController = hostingController
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            self.panel = panel
        }

        panel?.setContentSize(defaultSize)
        positionPanel()
        NSApp.activate(ignoringOtherApps: true)
        panel?.orderFrontRegardless()
        panel?.makeKey()
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
