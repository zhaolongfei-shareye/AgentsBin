import Foundation

enum Analytics {
    private static let endpoint = URL(string: "https://www.agentsbin.com/api/track")!
    private static let version =
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.16"

    static func track(kind: String, name: String, source: String = "app") {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode([
            "kind": kind,
            "name": name,
            "version": version,
            "source": source
        ])
        URLSession.shared.dataTask(with: request) { _, _, _ in }.resume()
    }
}
