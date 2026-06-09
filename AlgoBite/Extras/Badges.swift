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
        // 初クリア
        Badge(id: "first_clear",    title: "はじめての一歩",   emoji: "🌱", description: "最初の問題をクリア"),
        Badge(id: "reorder_first",  title: "並べ替えデビュー", emoji: "📋", description: "並べ替えを初クリア"),
        Badge(id: "hard_first",     title: "難問制覇",         emoji: "💎", description: "Hardの問題を初クリア"),
        // ストリーク
        Badge(id: "streak_3",       title: "3日連続",          emoji: "🔥", description: "3日続けてクリア"),
        Badge(id: "streak_7",       title: "1週間達成",        emoji: "🌟", description: "7日連続クリア"),
        Badge(id: "streak_14",      title: "2週間連続",        emoji: "💪", description: "14日連続クリア"),
        Badge(id: "streak_30",      title: "1ヶ月の習慣",      emoji: "👑", description: "30日連続クリア"),
        // 累計
        Badge(id: "total_10",       title: "10問達成",         emoji: "🍪", description: "累計10問クリア"),
        Badge(id: "total_30",       title: "30問達成",         emoji: "🏅", description: "累計30問クリア"),
        Badge(id: "total_50",       title: "50問達成",         emoji: "🎯", description: "累計50問クリア"),
        Badge(id: "total_100",      title: "100問達成",        emoji: "🏆", description: "累計100問クリア"),
        // トピック
        Badge(id: "topic_5",        title: "得意分野",         emoji: "🎓", description: "同じトピックを5問クリア"),
        Badge(id: "topic_master",   title: "トピックマスター",  emoji: "🥇", description: "同じトピックを10問クリア"),
        Badge(id: "topic_variety",  title: "探求者",           emoji: "🗺️", description: "5種類のトピックをクリア"),
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
        // 初クリア
        if stats.totalClears  >= 1  { add("first_clear")   }
        if stats.reorderClears >= 1 { add("reorder_first") }
        if stats.hardClears   >= 1  { add("hard_first")    }
        // ストリーク
        if streak >= 3  { add("streak_3")  }
        if streak >= 7  { add("streak_7")  }
        if streak >= 14 { add("streak_14") }
        if streak >= 30 { add("streak_30") }
        // 累計
        if stats.totalClears >= 10  { add("total_10")  }
        if stats.totalClears >= 30  { add("total_30")  }
        if stats.totalClears >= 50  { add("total_50")  }
        if stats.totalClears >= 100 { add("total_100") }
        // トピック
        if stats.topicCounts.values.contains(where: { $0 >= 5  }) { add("topic_5")       }
        if stats.topicCounts.values.contains(where: { $0 >= 10 }) { add("topic_master")  }
        if stats.distinctTopics >= 5                               { add("topic_variety") }

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

