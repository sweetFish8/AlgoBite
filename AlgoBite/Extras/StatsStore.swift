import SwiftUI
import Charts

// MARK: - Stats Store (③)

@MainActor
final class StatsStore: ObservableObject {
    @Published private(set) var totalSolved: Int
    @Published private(set) var solvedDates: Set<String>
    @Published private(set) var topicCounts: [String: Int]
    @Published private(set) var reorderClears: Int
    @Published private(set) var lastDate: String?

    private let kTotal = "algobite.stats.totalSolved"
    private let kDates = "algobite.stats.solvedDates"
    private let kTopics = "algobite.stats.topicCounts"
    private let kReorder = "algobite.stats.reorderClears"

    static let shared = StatsStore()

    init() {
        let d = appDefaults
        totalSolved   = d.integer(forKey: kTotal)
        solvedDates   = Set((d.array(forKey: kDates) as? [String]) ?? [])
        topicCounts   = (d.dictionary(forKey: kTopics) as? [String: Int]) ?? [:]
        reorderClears = d.integer(forKey: kReorder)
    }

    private func todayString() -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    static func dateString(daysAgo: Int) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        let d = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        return f.string(from: d)
    }

    func recordPuzzleClear(topic: String) {
        totalSolved += 1
        solvedDates.insert(todayString())
        let mainTopic = topic.components(separatedBy: " / ").first ?? topic
        topicCounts[mainTopic, default: 0] += 1
        lastDate = todayString()
        persist()
    }

    func recordReorderClear() {
        reorderClears += 1
        solvedDates.insert(todayString())
        lastDate = todayString()
        persist()
    }

    /// 過去N日の active 状態（古い方から）
    func activity(days: Int) -> [Bool] {
        (0..<days).reversed().map { solvedDates.contains(Self.dateString(daysAgo: $0)) }
    }

    /// 一番得意なトピック（解いた数最大）
    var topTopic: (topic: String, count: Int)? {
        guard let kv = topicCounts.max(by: { $0.value < $1.value }) else { return nil }
        return (kv.key, kv.value)
    }

    private func persist() {
        let d = appDefaults
        d.set(totalSolved, forKey: kTotal)
        d.set(Array(solvedDates), forKey: kDates)
        d.set(topicCounts, forKey: kTopics)
        d.set(reorderClears, forKey: kReorder)
    }
}

