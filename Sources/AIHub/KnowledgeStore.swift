import Combine
import Foundation

struct KnowledgeEntry: Codable, Identifiable, Hashable {
    var id = UUID()
    var agentID: String
    var agentName: String
    var date: Date
    var text: String
    var summary: String = ""
    var modelInfo: String = ""
    var summaryStatus: String = "done"

    private enum CodingKeys: String, CodingKey {
        case id, agentID, agentName, date, text, summary, modelInfo, summaryStatus
    }

    init(agentID: String, agentName: String, date: Date, text: String, summary: String = "", modelInfo: String = "", summaryStatus: String = "done") {
        self.agentID = agentID
        self.agentName = agentName
        self.date = date
        self.text = text
        self.summary = summary
        self.modelInfo = modelInfo
        self.summaryStatus = summaryStatus
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        agentID = try container.decode(String.self, forKey: .agentID)
        agentName = try container.decode(String.self, forKey: .agentName)
        date = try container.decode(Date.self, forKey: .date)
        text = try container.decode(String.self, forKey: .text)
        summary = try container.decodeIfPresent(String.self, forKey: .summary) ?? ""
        modelInfo = try container.decodeIfPresent(String.self, forKey: .modelInfo) ?? ""
        summaryStatus = try container.decodeIfPresent(String.self, forKey: .summaryStatus) ?? "done"
    }
}

final class KnowledgeStore: ObservableObject {
    @Published private(set) var entries: [KnowledgeEntry] = [] {
        didSet { persist() }
    }

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AIHub", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("knowledge.json")
        if let data = try? Data(contentsOf: fileURL) {
            if let saved = try? JSONDecoder().decode([KnowledgeEntry].self, from: data) {
                entries = saved
            } else {
                let backup = fileURL.deletingPathExtension().appendingPathExtension("corrupt-\(Int(Date().timeIntervalSince1970)).json")
                try? data.write(to: backup, options: .atomic)
            }
        }
    }

    func add(entry: KnowledgeEntry) {
        entries.insert(entry, at: 0)
    }

    func delete(_ id: UUID) {
        entries.removeAll { $0.id == id }
    }

    func entry(id: UUID) -> KnowledgeEntry? {
        entries.first { $0.id == id }
    }

    func updateSummary(id: UUID, summary: String, modelInfo: String, status: String = "done") {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[index].summary = summary
        entries[index].modelInfo = modelInfo
        entries[index].summaryStatus = status
    }

    func updateStatus(id: UUID, status: String) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[index].summaryStatus = status
    }

    func deleteEntries(on day: Date, agentID: String) {
        entries.removeAll {
            Calendar.current.isDate($0.date, inSameDayAs: day) && $0.agentID == agentID
        }
    }

    static func summarize(_ text: String) -> String {
        let clean = text
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard clean.count > 80 else { return clean }
        let sentences = clean
            .components(separatedBy: "。！？!?")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let keywords = ["因为", "所以", "首先", "其次", "最后", "建议", "需要", "可以", "通过", "核心", "主要", "例如", "包括", "作用", "方式", "步骤"]
        let scored = sentences.enumerated().map { index, sentence in
            var score = min(sentence.count, 120) / 3
            if index == 0 { score += 20 }
            if keywords.contains(where: { sentence.contains($0) }) { score += 15 }
            return (sentence, score)
        }
        .sorted { $0.1 > $1.1 }
        let top = scored.prefix(3).map { $0.0 }.joined(separator: "；")
        return top.count > 280 ? String(top.prefix(280)) + "…" : top
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(entries) {
            if let old = try? Data(contentsOf: fileURL) {
                let backup = fileURL.deletingPathExtension().appendingPathExtension("backup.json")
                try? old.write(to: backup, options: .atomic)
            }
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
