import SwiftUI

// Central UI theme. Add new styles to ThemeRegistry.themes to extend.
struct AppTheme {
    let name: String
    let accent: Color
    let primaryText: Color
    let secondaryText: Color
    let tertiaryText: Color
    let background: Color
    let contentBackground: Color
    let controlBackground: Color
    let separator: Color
    let panelMaterial: Material
    let largeRadius: CGFloat
    let smallRadius: CGFloat
    let rowHeight: CGFloat
    let pagePadding: CGFloat
    let titleFont: Font
    let bodyFont: Font
    let listFont: Font
    let captionFont: Font
}

enum ThemeRegistry {
    static let system = AppTheme(
        name: "system",
        accent: Color(nsColor: .controlAccentColor),
        primaryText: Color(nsColor: .labelColor),
        secondaryText: Color(nsColor: .secondaryLabelColor),
        tertiaryText: Color(nsColor: .tertiaryLabelColor),
        background: Color(nsColor: .windowBackgroundColor),
        contentBackground: Color(nsColor: .textBackgroundColor),
        controlBackground: Color(nsColor: .controlBackgroundColor),
        separator: Color(nsColor: .separatorColor),
        panelMaterial: .regularMaterial,
        largeRadius: 10,
        smallRadius: 6,
        rowHeight: 28,
        pagePadding: 20,
        titleFont: .system(size: 28, weight: .semibold),
        bodyFont: .system(size: 13, weight: .regular),
        listFont: .system(size: 13, weight: .regular),
        captionFont: .system(size: 11, weight: .regular)
    )

    static let themes: [String: AppTheme] = [
        "system": system
        // Future styles: "midnight", "light", etc.
    ]

    static func current() -> AppTheme {
        let raw = UserDefaults.standard.string(forKey: "agentsbin.theme") ?? "system"
        return themes[raw] ?? system
    }
}
