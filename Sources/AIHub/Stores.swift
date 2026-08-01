import Combine
import Foundation

final class AgentStore: ObservableObject {
    @Published var agents: [Agent] {
        didSet { persist() }
    }
    @Published var selectedIDs: Set<String> {
        didSet { persist() }
    }
    @Published var activeID: String {
        didSet { persist() }
    }

    private let defaults = UserDefaults.standard
    private let agentsKey = "aihub.agents"
    private let selectedKey = "aihub.selected"
    private let activeKey = "aihub.active"

    init() {
        if let data = defaults.data(forKey: agentsKey),
           let saved = try? JSONDecoder().decode([Agent].self, from: data),
           !saved.isEmpty {
            agents = saved
        } else {
            agents = Agent.defaults().sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        }
        if let data = defaults.data(forKey: selectedKey),
           let saved = try? JSONDecoder().decode([String].self, from: data) {
            selectedIDs = Set(saved)
        } else {
            selectedIDs = ["chatgpt", "claude", "gemini"]
        }
        activeID = "chatgpt"
        if let saved = defaults.string(forKey: activeKey), agents.contains(where: { $0.id == saved }) {
            activeID = saved
        } else if let first = agents.first(where: { $0.isEnabled }) {
            activeID = first.id
        } else if !agents.isEmpty {
            activeID = agents.first(where: { $0.isEnabled })?.id ?? agents[0].id
        }
    }

    var enabledAgents: [Agent] {
        agents.filter { $0.isEnabled }
    }

    var activeAgent: Agent {
        agents.first(where: { $0.id == activeID && $0.isEnabled })
            ?? enabledAgents.first
            ?? agents[0]
    }

    func select(_ id: String) {
        guard agents.contains(where: { $0.id == id && $0.isEnabled }) else { return }
        activeID = id
    }

    func toggleSelection(_ id: String) {
        if selectedIDs.contains(id) {
            if selectedIDs.count > 1 {
                selectedIDs.remove(id)
            }
        } else {
            selectedIDs.insert(id)
        }
        if selectedIDs.isEmpty, let first = enabledAgents.first {
            selectedIDs.insert(first.id)
        }
    }

    func togglePin(_ id: String) {
        guard let index = agents.firstIndex(where: { $0.id == id }) else { return }
        var agent = agents[index]
        agent.isPinned.toggle()
        agents.remove(at: index)
        if agent.isPinned {
            let lastPinned = agents.lastIndex(where: { $0.isPinned }) ?? -1
            agents.insert(agent, at: lastPinned + 1)
        } else {
            let firstUnpinned = agents.firstIndex(where: { !$0.isPinned }) ?? agents.count
            agents.insert(agent, at: firstUnpinned)
        }
    }

    func move(_ id: String, by offset: Int) {
        guard let index = agents.firstIndex(where: { $0.id == id }) else { return }
        let target = index + offset
        guard target >= 0, target < agents.count else { return }
        guard agents[target].isPinned == agents[index].isPinned else { return }
        let agent = agents.remove(at: index)
        agents.insert(agent, at: target)
    }

    func moveAgents(fromOffsets: IndexSet, toOffset: Int) {
        agents.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }

    func move(_ id: String, to targetID: String) {
        guard let fromIndex = agents.firstIndex(where: { $0.id == id }),
              let targetIndex = agents.firstIndex(where: { $0.id == targetID }) else { return }
        let agent = agents.remove(at: fromIndex)
        let adjusted = targetIndex > fromIndex ? targetIndex - 1 : targetIndex
        agents.insert(agent, at: adjusted)
    }

    func setEnabled(_ id: String, _ enabled: Bool) {
        guard let index = agents.firstIndex(where: { $0.id == id }) else { return }
        agents[index].isEnabled = enabled
        if !enabled {
            selectedIDs.remove(id)
            if activeID == id {
                activeID = enabledAgents.first?.id ?? ""
            }
        }
        if selectedIDs.isEmpty, let first = enabledAgents.first {
            selectedIDs.insert(first.id)
        }
    }

    func delete(_ id: String) {
        agents.removeAll { $0.id == id }
        selectedIDs.remove(id)
        if activeID == id {
            activeID = enabledAgents.first?.id ?? ""
        }
        if selectedIDs.isEmpty, let first = enabledAgents.first {
            selectedIDs.insert(first.id)
        }
    }

    func add(name: String, urlString: String) {
        let palette = ["#7c3aed", "#0d9488", "#ea580c", "#dc2626", "#2563eb", "#65a30d"]
        let agent = Agent(
            id: "custom-\(UUID().uuidString.lowercased())",
            name: name,
            letter: String(name.prefix(1)).uppercased(),
            colorHex: palette[agents.count % palette.count],
            urlString: urlString.isEmpty ? "example.com" : urlString,
            isOnline: false,
            isEnabled: true,
            isPinned: false
        )
        agents.append(agent)
    }

    func importAgents(from text: String) -> (imported: Int, errors: [String]) {
        var imported = 0
        var errors: [String] = []
        let lines = text.components(separatedBy: .newlines)
        for (index, raw) in lines.enumerated() {
            let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty, !line.hasPrefix("#") else { continue }
            let parts = line.components(separatedBy: "\t")
            guard parts.count >= 2 else {
                errors.append("第 \(index + 1) 行格式应为：名称<TAB>网址")
                continue
            }
            let name = parts[0].trimmingCharacters(in: .whitespaces)
            let urlString = parts[1].trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty else {
                errors.append("第 \(index + 1) 行缺少名称")
                continue
            }
            let candidate = urlString.hasPrefix("http") ? urlString : "https://" + urlString
            guard let url = URL(string: candidate), url.host != nil else {
                errors.append("第 \(index + 1) 行网址无效：\(urlString)")
                continue
            }
            add(name: name, urlString: urlString)
            imported += 1
        }
        return (imported, errors)
    }

    func exportAgents() -> String {
        agents.map { "\($0.name)\t\($0.urlString)" }.joined(separator: "\n")
    }

    func update(_ id: String, name: String, urlString: String) {
        guard let index = agents.firstIndex(where: { $0.id == id }) else { return }
        agents[index].name = name
        agents[index].letter = String(name.prefix(1)).uppercased()
        if !urlString.isEmpty {
            agents[index].urlString = urlString
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(agents) {
            defaults.set(data, forKey: agentsKey)
        }
        if let data = try? JSONEncoder().encode(Array(selectedIDs)) {
            defaults.set(data, forKey: selectedKey)
        }
        defaults.set(activeID, forKey: activeKey)
    }
}
