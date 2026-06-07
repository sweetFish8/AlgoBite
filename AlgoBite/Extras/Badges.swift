import SwiftUI
import Charts

// MARK: - Badges (④)

struct Badge: Identifiable, Hashable {
    let id: String
    let title: String
    let emoji: String
    let description: String
}

enum BadgeCatalog {
    static let all: [Badge] = [
        Badge(id: "first_clear",   title: "はじめての一歩", emoji: "🌱", description: "最初のパズルをクリア"),
        Badge(id: "streak_3",      title: "3日連続",       emoji: "🔥", description: "3日続けてクリア"),
        Badge(id: "streak_7",      title: "1週間達成",      emoji: "🌟", description: "7日連続クリア"),
        Badge(id: "reorder_first", title: "並べ替えデビュー", emoji: "📋", description: "並べ替えを初クリア"),
        Badge(id: "total_10",      title: "10問達成",      emoji: "🍪", description: "累計10問クリア"),
        Badge(id: "total_30",      title: "30問達成",      emoji: "🏅", description: "累計30問クリア"),
        Badge(id: "topic_5",       title: "得意分野",       emoji: "🎓", description: "同じトピックを5問クリア"),
    ]
    static func by(_ id: String) -> Badge? { all.first { $0.id == id } }
}

@MainActor
final class BadgeStore: ObservableObject {
    @Published private(set) var unlocked: Set<String>
    @Published var justUnlocked: Badge?

    private let key = "algobite.badges.unlocked"
    static let shared = BadgeStore()

    init() {
        let d = appDefaults
        unlocked = Set((d.array(forKey: key) as? [String]) ?? [])
    }

    func evaluate(stats: StatsStore, streak: Int) {
        var newOnes: [String] = []
        func add(_ id: String) {
            if !unlocked.contains(id) {
                unlocked.insert(id)
                newOnes.append(id)
            }
        }
        if stats.totalSolved >= 1  { add("first_clear")   }
        if stats.totalSolved >= 10 { add("total_10")      }
        if stats.totalSolved >= 30 { add("total_30")      }
        if streak >= 3             { add("streak_3")      }
        if streak >= 7             { add("streak_7")      }
        if stats.reorderClears >= 1 { add("reorder_first") }
        if stats.topicCounts.values.contains(where: { $0 >= 5 }) { add("topic_5") }

        if !newOnes.isEmpty {
            appDefaults.set(Array(unlocked), forKey: key)
            if let first = newOnes.first, let badge = BadgeCatalog.by(first) {
                justUnlocked = badge
                Haptics.success()
            }
        }
    }

    func dismissJustUnlocked() { justUnlocked = nil }

    /// SettingsStore.resetAll() と合わせて呼ぶ。インメモリの解放済みバッジをクリアする。
    func resetAll() {
        unlocked = []
        justUnlocked = nil
    }
}

