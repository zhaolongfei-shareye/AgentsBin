import AppKit
import Combine
import Foundation
import ImageIO

final class FaviconStore: ObservableObject {
    @Published private(set) var images: [String: NSImage] = [:]

    private let directory: URL
    private var loadedIDs: Set<String> = []
    private let session = URLSession.shared
    private let chromeUA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AIHub", isDirectory: true)
            .appendingPathComponent("Favicons", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        directory = base
    }

    func ensureLoaded(for agents: [Agent]) {
        for agent in agents {
            guard !loadedIDs.contains(agent.id) else { continue }
            loadedIDs.insert(agent.id)
            let file = directory.appendingPathComponent(agent.id + ".png")
            let resourceName = agent.name
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: ".", with: "")
            let builtinURL = Bundle.main.url(forResource: agent.id, withExtension: "png", subdirectory: "BuiltinFavicons")
                ?? Bundle.main.url(forResource: resourceName, withExtension: "png", subdirectory: "BuiltinFavicons")
            if let builtinURL,
               let builtinData = try? Data(contentsOf: builtinURL),
               let builtinImage = NSImage(data: builtinData) {
                images[agent.id] = builtinImage
                try? builtinData.write(to: file, options: .atomic)
                continue
            }
            if let data = try? Data(contentsOf: file), let image = NSImage(data: data) {
                images[agent.id] = image
                continue
            }
            fetch(agent)
        }
    }

    private func fetch(_ agent: Agent) {
        guard let host = agent.urlString.components(separatedBy: "/").first else { return }
        trySources(agent, host: host, paths: ["/favicon.ico", "/favicon.png", "/apple-touch-icon.png"], index: 0)
    }

    private func trySources(_ agent: Agent, host: String, paths: [String], index: Int) {
        guard index < paths.count, let url = URL(string: "https://" + host + paths[index]) else {
            fetchIconFromHTML(agent, host: host)
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 8
        request.setValue(chromeUA, forHTTPHeaderField: "User-Agent")
        session.dataTask(with: request) { [weak self] data, response, _ in
            guard let self, let data, !data.isEmpty else {
                self?.trySources(agent, host: host, paths: paths, index: index + 1)
                return
            }
            if let decoded = self.decode(data) {
                DispatchQueue.main.async {
                    self.store(decoded.image, data: decoded.pngData, id: agent.id)
                }
            } else {
                self.trySources(agent, host: host, paths: paths, index: index + 1)
            }
        }.resume()
    }

    private func fetchIconFromHTML(_ agent: Agent, host: String) {
        guard let url = URL(string: "https://" + host + "/") else { return }
        var request = URLRequest(url: url)
        request.timeoutInterval = 8
        request.setValue(chromeUA, forHTTPHeaderField: "User-Agent")
        session.dataTask(with: request) { [weak self] data, _, _ in
            guard let self, let data, let html = String(data: data, encoding: .utf8) else { return }
            let patterns = [
                "rel\\s*=\\s*[\"'](?:shortcut\\s+)?icon[\"'][^>]*href\\s*=\\s*[\"']([^\"']+)",
                "href\\s*=\\s*[\"']([^\"']+)[\"'][^>]*rel\\s*=\\s*[\"'](?:shortcut\\s+)?icon[\"']"
            ]
            for pattern in patterns {
                if let href = self.firstHref(in: html, pattern: pattern),
                   let resolved = URL(string: href, relativeTo: url)?.absoluteURL,
                   let imageData = try? Data(contentsOf: resolved),
                   let decoded = self.decode(imageData) {
                    DispatchQueue.main.async {
                        self.store(decoded.image, data: decoded.pngData, id: agent.id)
                    }
                    return
                }
            }
        }.resume()
    }

    private func firstHref(in html: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return nil }
        let ns = html as NSString
        guard let match = regex.firstMatch(in: html, range: NSRange(location: 0, length: ns.length)),
              match.numberOfRanges > 1 else { return nil }
        return ns.substring(with: match.range(at: 1))
    }

    private func decode(_ data: Data) -> (image: NSImage, pngData: Data)? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let count = CGImageSourceGetCount(source)
        guard count > 0 else { return nil }
        var best: CGImage?
        var bestPixels = 0
        for index in 0..<count {
            if let cg = CGImageSourceCreateImageAtIndex(source, index, nil) {
                let pixels = cg.width * cg.height
                if pixels > bestPixels {
                    best = cg
                    bestPixels = pixels
                }
            }
        }
        guard let cg = best else { return nil }
        let rep = NSBitmapImageRep(cgImage: cg)
        guard let png = rep.representation(using: .png, properties: [:]),
              let image = NSImage(data: png) else { return nil }
        return (image, png)
    }

    private func store(_ image: NSImage, data: Data, id: String) {
        images[id] = image
        let file = directory.appendingPathComponent(id + ".png")
        try? data.write(to: file, options: .atomic)
    }
}
