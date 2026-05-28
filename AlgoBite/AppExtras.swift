import SwiftUI
import UIKit
import UserNotifications

// MARK: - Sweet Illustrations (ポップなお菓子イラスト)
// 絵文字ではなく SwiftUI Shape で描いた可愛いお菓子アイコン群。

/// チョコチップクッキー
struct CookieIcon: View {
    var size: CGFloat = 44
    var body: some View {
        ZStack {
            // 生地
            Circle()
                .fill(LinearGradient(colors: [
                    Color(red: 0.95, green: 0.78, blue: 0.50),
                    Color(red: 0.78, green: 0.55, blue: 0.27)
                ], startPoint: .topLeading, endPoint: .bottomTrailing))
            // 縁
            Circle()
                .strokeBorder(Color(red: 0.55, green: 0.34, blue: 0.10),
                              lineWidth: size * 0.045)
            // ハイライト
            Ellipse()
                .fill(Color.white.opacity(0.35))
                .frame(width: size * 0.30, height: size * 0.14)
                .offset(x: -size * 0.16, y: -size * 0.24)
            // チョコチップ
            chip(dx: -0.22, dy: -0.18, scale: 0.16)
            chip(dx:  0.20, dy: -0.10, scale: 0.13)
            chip(dx: -0.05, dy:  0.16, scale: 0.18)
            chip(dx:  0.22, dy:  0.20, scale: 0.12)
            chip(dx: -0.24, dy:  0.10, scale: 0.10)
        }
        .frame(width: size, height: size)
    }
    private func chip(dx: CGFloat, dy: CGFloat, scale: CGFloat) -> some View {
        Circle()
            .fill(Color(red: 0.30, green: 0.16, blue: 0.06))
            .frame(width: size * scale, height: size * scale)
            .offset(x: size * dx, y: size * dy)
    }
}

/// ピンクグレーズドーナツ + スプリンクル
struct DonutIcon: View {
    var size: CGFloat = 44
    var body: some View {
        ZStack {
            // 生地（外円）
            Circle()
                .fill(Color(red: 0.96, green: 0.80, blue: 0.55))
            // ピンクのアイシング
            Circle()
                .fill(LinearGradient(colors: [
                    Color(red: 1.00, green: 0.65, blue: 0.75),
                    Color(red: 1.00, green: 0.48, blue: 0.62)
                ], startPoint: .top, endPoint: .bottom))
                .scaleEffect(0.93)
            // アイシングの縁の波(下端)
            Circle()
                .fill(Color(red: 0.96, green: 0.80, blue: 0.55))
                .scaleEffect(0.86)
                .offset(y: size * 0.06)
            Circle()
                .fill(LinearGradient(colors: [
                    Color(red: 1.00, green: 0.65, blue: 0.75),
                    Color(red: 1.00, green: 0.48, blue: 0.62)
                ], startPoint: .top, endPoint: .bottom))
                .scaleEffect(0.86)
            // スプリンクル
            ForEach(Array(zip(0..<10, sprinklePositions)), id: \.0) { idx, p in
                Capsule()
                    .fill(sprinkleColors[idx % sprinkleColors.count])
                    .frame(width: size * 0.06, height: size * 0.14)
                    .rotationEffect(.degrees(p.angle))
                    .offset(x: size * p.dx, y: size * p.dy)
            }
            // 穴
            Circle()
                .fill(Color(red: 1.00, green: 0.97, blue: 0.93))
                .frame(width: size * 0.32, height: size * 0.32)
            Circle()
                .strokeBorder(Color(red: 0.83, green: 0.62, blue: 0.42),
                              lineWidth: size * 0.025)
                .frame(width: size * 0.32, height: size * 0.32)
        }
        .frame(width: size, height: size)
    }
    private var sprinkleColors: [Color] {
        [
            Color(red: 0.40, green: 0.78, blue: 0.92), // sky
            Color(red: 0.99, green: 0.85, blue: 0.30), // yellow
            Color(red: 0.62, green: 0.91, blue: 0.55), // mint
            Color(red: 1.00, green: 1.00, blue: 1.00), // white
            Color(red: 0.65, green: 0.50, blue: 0.95), // purple
        ]
    }
    private var sprinklePositions: [(dx: CGFloat, dy: CGFloat, angle: Double)] {
        [
            (-0.25, -0.05,  20),
            ( 0.05, -0.27, -30),
            ( 0.26, -0.08,  45),
            ( 0.22,  0.18,  10),
            ( 0.00,  0.30, -15),
            (-0.22,  0.18,  60),
            (-0.05, -0.18,  80),
            ( 0.13, -0.22,  -5),
            (-0.18,  0.05,  35),
            ( 0.18, -0.18, -55),
        ]
    }
}

/// カップケーキ (クリーム + ラッパー + チェリー)
struct CupcakeIcon: View {
    var size: CGFloat = 44
    var body: some View {
        ZStack {
            // ラッパー (台形)
            CupcakeWrapper()
                .fill(LinearGradient(colors: [
                    Color(red: 0.92, green: 0.38, blue: 0.50),
                    Color(red: 0.75, green: 0.20, blue: 0.32)
                ], startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.72, height: size * 0.36)
                .offset(y: size * 0.20)
            // ラッパーの縦縞
            ForEach(0..<5, id: \.self) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: size * 0.025, height: size * 0.34)
                    .offset(x: size * (-0.24 + CGFloat(i) * 0.12), y: size * 0.21)
            }
            // クリーム (3層の渦)
            CupcakeCream()
                .fill(LinearGradient(colors: [
                    Color(red: 1.00, green: 0.92, blue: 0.87),
                    Color(red: 0.94, green: 0.78, blue: 0.72)
                ], startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.78, height: size * 0.50)
                .offset(y: -size * 0.10)
            // チェリー
            Circle()
                .fill(LinearGradient(colors: [
                    Color(red: 0.95, green: 0.30, blue: 0.30),
                    Color(red: 0.78, green: 0.10, blue: 0.18)
                ], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size * 0.20, height: size * 0.20)
                .offset(y: -size * 0.33)
            // チェリーのハイライト
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: size * 0.05, height: size * 0.05)
                .offset(x: -size * 0.03, y: -size * 0.36)
            // チェリーの茎
            Capsule()
                .fill(Color(red: 0.30, green: 0.55, blue: 0.18))
                .frame(width: size * 0.025, height: size * 0.10)
                .rotationEffect(.degrees(20))
                .offset(x: size * 0.02, y: -size * 0.42)
        }
        .frame(width: size, height: size)
    }
}

/// カップケーキの台形ラッパー
struct CupcakeWrapper: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let inset = rect.width * 0.10
        p.move(to: CGPoint(x: rect.minX + inset, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

/// クリームのドーム（半円＋小さなウェーブ）
struct CupcakeCream: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        // ドーム
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control1: CGPoint(x: rect.minX, y: rect.minY - rect.height * 0.05),
            control2: CGPoint(x: rect.maxX, y: rect.minY - rect.height * 0.05)
        )
        p.closeSubpath()
        return p
    }
}

/// 板チョコ (3x4 グリッド)
struct ChocolateIcon: View {
    var size: CGFloat = 44
    var body: some View {
        ZStack {
            // 外殻 + 包み感
            RoundedRectangle(cornerRadius: size * 0.10)
                .fill(LinearGradient(colors: [
                    Color(red: 0.55, green: 0.32, blue: 0.16),
                    Color(red: 0.38, green: 0.18, blue: 0.08)
                ], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size * 0.88, height: size * 0.80)
            RoundedRectangle(cornerRadius: size * 0.10)
                .strokeBorder(Color(red: 0.28, green: 0.13, blue: 0.05),
                              lineWidth: size * 0.04)
                .frame(width: size * 0.88, height: size * 0.80)
            // 12 ピースのレリーフ
            VStack(spacing: size * 0.025) {
                ForEach(0..<3, id: \.self) { _ in
                    HStack(spacing: size * 0.025) {
                        ForEach(0..<4, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: size * 0.03)
                                .fill(LinearGradient(colors: [
                                    Color(red: 0.65, green: 0.38, blue: 0.18),
                                    Color(red: 0.42, green: 0.20, blue: 0.10)
                                ], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .overlay(RoundedRectangle(cornerRadius: size * 0.03)
                                    .stroke(Color(red: 0.28, green: 0.13, blue: 0.05).opacity(0.6),
                                            lineWidth: size * 0.012))
                        }
                    }
                }
            }
            .frame(width: size * 0.78, height: size * 0.70)
            // 角のハイライト
            RoundedRectangle(cornerRadius: size * 0.04)
                .fill(Color.white.opacity(0.18))
                .frame(width: size * 0.22, height: size * 0.06)
                .offset(x: -size * 0.20, y: -size * 0.30)
        }
        .frame(width: size, height: size)
    }
}

/// ホールケーキ (3層ショートケーキ)
struct CakeIcon: View {
    var size: CGFloat = 44
    var body: some View {
        ZStack {
            // 下層 (スポンジ)
            RoundedRectangle(cornerRadius: size * 0.06)
                .fill(Color(red: 0.99, green: 0.85, blue: 0.62))
                .frame(width: size * 0.80, height: size * 0.20)
                .offset(y: size * 0.22)
            // クリーム層
            RoundedRectangle(cornerRadius: size * 0.04)
                .fill(Color.white)
                .frame(width: size * 0.80, height: size * 0.06)
                .offset(y: size * 0.10)
            // 上層 (スポンジ)
            RoundedRectangle(cornerRadius: size * 0.06)
                .fill(Color(red: 0.99, green: 0.85, blue: 0.62))
                .frame(width: size * 0.80, height: size * 0.18)
                .offset(y: -size * 0.02)
            // 上のクリームドーム
            Ellipse()
                .fill(Color.white)
                .frame(width: size * 0.80, height: size * 0.16)
                .offset(y: -size * 0.16)
            // イチゴ
            ForEach(0..<3, id: \.self) { i in
                Path { p in
                    // ハート型の苺
                    let cx = CGFloat(i - 1) * size * 0.22
                    p.move(to: CGPoint(x: cx, y: -size * 0.20))
                    p.addCurve(
                        to: CGPoint(x: cx + size * 0.06, y: -size * 0.30),
                        control1: CGPoint(x: cx, y: -size * 0.27),
                        control2: CGPoint(x: cx + size * 0.06, y: -size * 0.30))
                    p.addCurve(
                        to: CGPoint(x: cx, y: -size * 0.20),
                        control1: CGPoint(x: cx + size * 0.10, y: -size * 0.25),
                        control2: CGPoint(x: cx + size * 0.06, y: -size * 0.20))
                    p.addCurve(
                        to: CGPoint(x: cx - size * 0.06, y: -size * 0.30),
                        control1: CGPoint(x: cx - size * 0.06, y: -size * 0.20),
                        control2: CGPoint(x: cx - size * 0.10, y: -size * 0.25))
                    p.addCurve(
                        to: CGPoint(x: cx, y: -size * 0.20),
                        control1: CGPoint(x: cx - size * 0.06, y: -size * 0.30),
                        control2: CGPoint(x: cx, y: -size * 0.27))
                    p.closeSubpath()
                }
                .fill(Color(red: 0.95, green: 0.28, blue: 0.32))
                .offset(y: size * 0.04)
            }
        }
        .frame(width: size, height: size)
    }
}

/// 炎アイコン (ストリーク用)
struct FlameIcon: View {
    var size: CGFloat = 36
    var body: some View {
        ZStack {
            // 外炎
            Path { p in
                let w = size, h = size
                p.move(to: CGPoint(x: w * 0.50, y: 0))
                p.addCurve(
                    to: CGPoint(x: w * 0.95, y: h * 0.65),
                    control1: CGPoint(x: w * 0.65, y: h * 0.20),
                    control2: CGPoint(x: w * 0.95, y: h * 0.40))
                p.addCurve(
                    to: CGPoint(x: w * 0.50, y: h),
                    control1: CGPoint(x: w * 0.95, y: h * 0.92),
                    control2: CGPoint(x: w * 0.75, y: h))
                p.addCurve(
                    to: CGPoint(x: w * 0.05, y: h * 0.65),
                    control1: CGPoint(x: w * 0.25, y: h),
                    control2: CGPoint(x: w * 0.05, y: h * 0.92))
                p.addCurve(
                    to: CGPoint(x: w * 0.35, y: h * 0.40),
                    control1: CGPoint(x: w * 0.05, y: h * 0.50),
                    control2: CGPoint(x: w * 0.25, y: h * 0.50))
                p.addCurve(
                    to: CGPoint(x: w * 0.50, y: 0),
                    control1: CGPoint(x: w * 0.45, y: h * 0.20),
                    control2: CGPoint(x: w * 0.40, y: h * 0.10))
                p.closeSubpath()
            }
            .fill(LinearGradient(colors: [
                Color(red: 0.99, green: 0.55, blue: 0.10),
                Color(red: 0.96, green: 0.20, blue: 0.20)
            ], startPoint: .top, endPoint: .bottom))
            // 内炎
            Path { p in
                let w = size, h = size
                p.move(to: CGPoint(x: w * 0.50, y: h * 0.25))
                p.addCurve(
                    to: CGPoint(x: w * 0.75, y: h * 0.70),
                    control1: CGPoint(x: w * 0.60, y: h * 0.40),
                    control2: CGPoint(x: w * 0.75, y: h * 0.55))
                p.addCurve(
                    to: CGPoint(x: w * 0.50, y: h * 0.92),
                    control1: CGPoint(x: w * 0.75, y: h * 0.85),
                    control2: CGPoint(x: w * 0.65, y: h * 0.92))
                p.addCurve(
                    to: CGPoint(x: w * 0.25, y: h * 0.70),
                    control1: CGPoint(x: w * 0.35, y: h * 0.92),
                    control2: CGPoint(x: w * 0.25, y: h * 0.85))
                p.addCurve(
                    to: CGPoint(x: w * 0.50, y: h * 0.25),
                    control1: CGPoint(x: w * 0.25, y: h * 0.55),
                    control2: CGPoint(x: w * 0.40, y: h * 0.40))
                p.closeSubpath()
            }
            .fill(LinearGradient(colors: [
                Color(red: 1.00, green: 0.92, blue: 0.30),
                Color(red: 0.99, green: 0.55, blue: 0.10)
            ], startPoint: .top, endPoint: .bottom))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Haptics (①)

enum Haptics {
    static func success() {
        let g = UINotificationFeedbackGenerator()
        g.prepare(); g.notificationOccurred(.success)
    }
    static func error() {
        let g = UINotificationFeedbackGenerator()
        g.prepare(); g.notificationOccurred(.error)
    }
    static func warning() {
        let g = UINotificationFeedbackGenerator()
        g.prepare(); g.notificationOccurred(.warning)
    }
    static func selection() {
        let g = UISelectionFeedbackGenerator()
        g.prepare(); g.selectionChanged()
    }
    static func light()  { UIImpactFeedbackGenerator(style: .light ).impactOccurred() }
    static func medium() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    static func rigid()  { UIImpactFeedbackGenerator(style: .rigid ).impactOccurred() }
}

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
        let d = UserDefaults.standard
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
        let d = UserDefaults.standard
        d.set(totalSolved, forKey: kTotal)
        d.set(Array(solvedDates), forKey: kDates)
        d.set(topicCounts, forKey: kTopics)
        d.set(reorderClears, forKey: kReorder)
    }
}

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
        let d = UserDefaults.standard
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
            UserDefaults.standard.set(Array(unlocked), forKey: key)
            if let first = newOnes.first, let badge = BadgeCatalog.by(first) {
                justUnlocked = badge
                Haptics.success()
            }
        }
    }

    func dismissJustUnlocked() { justUnlocked = nil }
}

// MARK: - Hint Store (⑤)

enum HintLevel: Int, Comparable {
    case none = 0, gentle = 1, fillOne = 2, fillAll = 3
    static func < (l: HintLevel, r: HintLevel) -> Bool { l.rawValue < r.rawValue }
}

@MainActor
final class HintStore: ObservableObject {
    @Published var level: HintLevel = .none

    func reset() { level = .none }

    /// 次の段階を返す。fillAll に達したらそれ以上は進まない。
    func advance() -> HintLevel {
        switch level {
        case .none:    level = .gentle
        case .gentle:  level = .fillOne
        case .fillOne: level = .fillAll
        case .fillAll: break
        }
        return level
    }

    static func gentleText(for problem: PuzzleProblem) -> String {
        // トピック語をそのまま使う簡易ヒント。explanation の冒頭を抽出。
        if !problem.explanation.isEmpty {
            let first = problem.explanation
                .split(whereSeparator: { ".。!?！？\n".contains($0) })
                .first.map(String.init) ?? problem.explanation
            return "💭 \(first)"
        }
        return "💭 トピック「\(problem.topic)」の典型パターンを思い出してみよう"
    }
}

// MARK: - Notifications (⑧)

enum AppNotifications {
    static let dailyId = "algobite.daily"
    static let askedKey = "algobite.notifications.asked"
    static let enabledKey = "algobite.notifications.enabled"

    static func requestAuthorizationIfNeeded() {
        let d = UserDefaults.standard
        guard !d.bool(forKey: askedKey) else {
            // 既に確認済 → 有効ならスケジュール
            if d.bool(forKey: enabledKey) { scheduleDaily() }
            return
        }
        d.set(true, forKey: askedKey)

        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                d.set(granted, forKey: enabledKey)
                if granted { scheduleDaily() }
            }
    }

    static func scheduleDaily(hour: Int = 20, minute: Int = 0) {
        let c = UNUserNotificationCenter.current()
        c.removePendingNotificationRequests(withIdentifiers: [dailyId])

        let content = UNMutableNotificationContent()
        content.title = "今日のおやつできてるよ🍪"
        content.body  = "AlgoBiteで1問解いてリフレッシュ！"
        content.sound = .default

        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let req = UNNotificationRequest(identifier: dailyId, content: content, trigger: trigger)
        c.add(req, withCompletionHandler: nil)
    }
}

// MARK: - Reorder Quizzes (②) — 追加問題

extension ReorderQuiz {
    static let mergeSortMerge: ReorderQuiz = .init(
        id: "merge-sort-merge",
        title: "マージソートのマージ",
        topic: "ソート / マージソート",
        prompt: "ソート済みの2つの配列 [1, 4, 5] と [2, 3, 6] をマージした結果になるように、要素を順番にタップしてね。",
        pool: ["1","2","3","4","5","6"],
        answer: ["1","2","3","4","5","6"],
        explanation: "2つのソート済み配列の先頭を比較して小さい方から取り出していくと、O(n+m) でマージできる。"
    )

    static let selectionSortPass: ReorderQuiz = .init(
        id: "selection-sort-pass-1",
        title: "選択ソート 1パス目",
        topic: "ソート / 選択ソート",
        prompt: "配列 [5, 2, 4, 1, 3] から選択ソートを1パス実行した直後の配列を作ってね。",
        pool: ["1","2","3","4","5"],
        answer: ["1","2","4","5","3"],
        explanation: "未ソート部分 [5,2,4,1,3] の最小値は 1（index 3）。これを先頭の 5 と入れ替えるので [1, 2, 4, 5, 3] になる。"
    )

    static let bfsTraversal: ReorderQuiz = .init(
        id: "bfs-traversal",
        title: "BFS の訪問順",
        topic: "グラフ / BFS",
        prompt: "グラフを A から幅優先探索したときの訪問順を並べて。\n辺: A-B, A-C, B-D, C-E, D-F  (隣接リストはアルファベット順)",
        pool: ["A","B","C","D","E","F"],
        answer: ["A","B","C","D","E","F"],
        explanation: "BFSはキューで管理し、開始点から近い順に訪問する。同じ距離の場合は隣接リスト順。"
    )

    static let dfsTraversal: ReorderQuiz = .init(
        id: "dfs-traversal",
        title: "DFS の訪問順",
        topic: "グラフ / DFS",
        prompt: "同じグラフを A から深さ優先探索（隣接アルファベット順）したときの訪問順を並べて。\n辺: A-B, A-C, B-D, C-E, D-F",
        pool: ["A","B","C","D","E","F"],
        answer: ["A","B","D","F","C","E"],
        explanation: "DFSは「行けるところまで進んで戻る」。A→B→D→F まで行き、詰まったら戻って C→E。"
    )

    static let stackPushPop: ReorderQuiz = .init(
        id: "stack-push-pop",
        title: "スタックの中身",
        topic: "データ構造 / スタック",
        prompt: "空のスタックに push(1), push(2), push(3), pop, push(4) を実行した直後、上から順にスタックの中身を並べて。",
        pool: ["1","2","4"],
        answer: ["4","2","1"],
        explanation: "push(3)後に pop で 3 が消え、その後 push(4) で先頭が 4。下に向かって [4, 2, 1] となる。"
    )

    static let allList: [ReorderQuiz] = [
        .bubbleSortPass,
        .selectionSortPass,
        .mergeSortMerge,
        .bfsTraversal,
        .dfsTraversal,
        .stackPushPop,
    ]

    var emoji: String {
        switch id {
        case "bubble-sort-pass-1":     return "🫧"
        case "selection-sort-pass-1":  return "👉"
        case "merge-sort-merge":       return "🧩"
        case "bfs-traversal":          return "🌊"
        case "dfs-traversal":          return "🕳️"
        case "stack-push-pop":         return "📚"
        default:                       return "📋"
        }
    }
}

// MARK: - Stats Card (③)

struct StatsCard: View {
    @ObservedObject var stats: StatsStore
    @ObservedObject var badges: BadgeStore

    var body: some View {
        PopCard(fill: .white,
                border: Color(red: 0.78, green: 0.82, blue: 0.99)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    CakeIcon(size: 22)
                    Text("これまでのおやつ")
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(Color(red: 0.19, green: 0.18, blue: 0.50))
                    Spacer()
                    Text("\(badges.unlocked.count)/\(BadgeCatalog.all.count) バッジ")
                        .font(.caption2.weight(.heavy))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color(red: 0.99, green: 0.90, blue: 0.52), in: Capsule())
                        .foregroundStyle(Color(red: 0.57, green: 0.25, blue: 0.05))
                }
                HStack(spacing: 10) {
                    statCell(icon: AnyView(CookieIcon(size: 26)),
                             value: "\(stats.totalSolved)", label: "パズル")
                    statCell(icon: AnyView(CupcakeIcon(size: 26)),
                             value: "\(stats.reorderClears)", label: "並べ替え")
                    if let t = stats.topTopic {
                        statCell(icon: AnyView(ChocolateIcon(size: 26)),
                                 value: "\(t.count)",
                                 label: String(t.topic.prefix(5)))
                    } else {
                        statCell(icon: AnyView(ChocolateIcon(size: 26)),
                                 value: "-", label: "得意")
                    }
                }
                heatmap
            }
        }
    }

    private func statCell(icon: AnyView, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            icon
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.20))
            Text(label)
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(Pop.inkSub)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(red: 0.96, green: 0.97, blue: 1.00),
                    in: RoundedRectangle(cornerRadius: 10))
    }

    private var heatmap: some View {
        // 過去28日 (4週) を 7列 × 4行 で表示
        let days = stats.activity(days: 28)   // 古い方から
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("直近4週のアクティビティ")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(Pop.inkSub)
                Spacer()
                Text("4週前 → 今日")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Pop.inkSub.opacity(0.7))
            }
            // 4 rows × 7 columns; row 0 = 4週前
            VStack(spacing: 4) {
                ForEach(0..<4) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<7) { col in
                            let idx = row * 7 + col
                            let on = idx < days.count ? days[idx] : false
                            RoundedRectangle(cornerRadius: 4)
                                .fill(on
                                      ? Color(red: 0.13, green: 0.77, blue: 0.37)
                                      : Color(red: 0.93, green: 0.94, blue: 0.96))
                                .frame(height: 16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(on
                                                ? Color(red: 0.08, green: 0.55, blue: 0.27)
                                                : Color(red: 0.85, green: 0.87, blue: 0.90),
                                                lineWidth: 0.8)
                                )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Badges Card (④)

struct BadgesCard: View {
    @ObservedObject var badges: BadgeStore
    @State private var showDetails = false

    var body: some View {
        PopCard(fill: Color(red: 1.00, green: 0.97, blue: 0.93),
                border: Color(red: 0.99, green: 0.79, blue: 0.18)) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Text("🏆").font(.title3)
                    Text("バッジコレクション")
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(Color(red: 0.49, green: 0.18, blue: 0.07))
                    Spacer()
                    Button { showDetails = true } label: {
                        Text("詳細")
                            .font(.caption2.weight(.heavy))
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color(red: 0.99, green: 0.90, blue: 0.52), in: Capsule())
                            .foregroundStyle(Color(red: 0.57, green: 0.25, blue: 0.05))
                    }
                    .buttonStyle(.plain)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(BadgeCatalog.all) { b in
                            badgeChip(b, unlocked: badges.unlocked.contains(b.id))
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showDetails) {
            BadgeDetailSheet(badges: badges)
        }
    }

    private func badgeChip(_ b: Badge, unlocked: Bool) -> some View {
        VStack(spacing: 3) {
            Text(b.emoji)
                .font(.system(size: 28))
                .opacity(unlocked ? 1 : 0.25)
                .saturation(unlocked ? 1 : 0)
            Text(b.title)
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(unlocked
                                 ? Color(red: 0.49, green: 0.18, blue: 0.07)
                                 : Pop.inkSub.opacity(0.6))
                .lineLimit(1)
        }
        .frame(width: 64, height: 64)
        .background(unlocked
                    ? Color(red: 1.00, green: 0.95, blue: 0.78)
                    : Color(red: 0.95, green: 0.95, blue: 0.97),
                    in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(unlocked
                    ? Color(red: 0.99, green: 0.79, blue: 0.18)
                    : Color(red: 0.85, green: 0.87, blue: 0.90),
                    lineWidth: 1.4))
    }
}

struct BadgeDetailSheet: View {
    @ObservedObject var badges: BadgeStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                    ForEach(BadgeCatalog.all) { b in
                        let unlocked = badges.unlocked.contains(b.id)
                        VStack(spacing: 8) {
                            Text(b.emoji)
                                .font(.system(size: 44))
                                .opacity(unlocked ? 1 : 0.25)
                                .saturation(unlocked ? 1 : 0)
                            Text(b.title)
                                .font(.subheadline.weight(.black))
                                .foregroundStyle(Pop.ink)
                            Text(b.description)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Pop.inkSub)
                                .multilineTextAlignment(.center)
                            Text(unlocked ? "✅ 解放済み" : "🔒 未解放")
                                .font(.caption2.weight(.heavy))
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(unlocked
                                            ? Color(red: 0.73, green: 0.97, blue: 0.82)
                                            : Color(red: 0.93, green: 0.94, blue: 0.96),
                                            in: Capsule())
                                .foregroundStyle(unlocked
                                                 ? Color(red: 0.08, green: 0.32, blue: 0.18)
                                                 : Pop.inkSub)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(.white, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(red: 0.93, green: 0.91, blue: 0.97), lineWidth: 1.2))
                    }
                }
                .padding(16)
            }
            .background(LinearGradient(colors: [Pop.bgNeutralTop, Pop.bgNeutralBottom],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea())
            .navigationTitle("バッジ一覧")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .font(.subheadline.weight(.heavy))
                }
            }
        }
    }
}

/// バッジ解放の "ぱっと出るおめでとう" オーバーレイ
struct BadgeUnlockOverlay: View {
    let badge: Badge
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
                .onTapGesture { onDismiss() }
            VStack(spacing: 14) {
                Text("🎉 バッジ解放！")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Color(red: 0.49, green: 0.18, blue: 0.07))
                Text(badge.emoji).font(.system(size: 72))
                Text(badge.title)
                    .font(.title2.weight(.black))
                    .foregroundStyle(Pop.ink)
                Text(badge.description)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Pop.inkSub)
                    .multilineTextAlignment(.center)
                PopButton(fill: Pop.primary, shadow: Pop.primaryShadow, action: onDismiss) {
                    Text("やった！").font(.subheadline.weight(.heavy))
                }
            }
            .padding(24)
            .frame(maxWidth: 320)
            .background(Color(red: 1.00, green: 0.97, blue: 0.93),
                        in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22)
                .stroke(Color(red: 0.99, green: 0.79, blue: 0.18), lineWidth: 2.5))
            .shadow(color: .black.opacity(0.25), radius: 18, y: 6)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.85)))
    }
}

// MARK: - Reorder Quiz List (②)

struct ReorderQuizListView: View {
    let onPick: (ReorderQuiz) -> Void

    var body: some View {
        ZStack {
            LinearGradient(colors: [Pop.bgNeutralTop, Pop.bgNeutralBottom],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(ReorderQuiz.allList) { q in
                        Button { onPick(q) } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.96, green: 0.93, blue: 1.00))
                                        .frame(width: 50, height: 50)
                                    Text(q.emoji).font(.system(size: 28))
                                }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(q.title)
                                        .font(.subheadline.weight(.black))
                                        .foregroundStyle(Pop.ink)
                                    Text(q.topic)
                                        .font(.caption2.weight(.heavy))
                                        .foregroundStyle(Color(red: 0.31, green: 0.27, blue: 0.90))
                                }
                                Spacer()
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color(red: 0.55, green: 0.49, blue: 0.92))
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .background(.white, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 0.87, green: 0.84, blue: 0.99), lineWidth: 1.5))
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(TapGesture().onEnded { Haptics.light() })
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("並べ替え練習")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Review Mode (⑥)

/// 復習用のミニ ViewModel。日次の進捗には影響しない。
@MainActor
final class PracticeSession: ObservableObject {
    let problem: PuzzleProblem
    @Published var answers: [String: String] = [:]
    @Published var activeSlotID: String?
    @Published var slotStates: [String: SlotCheckState] = [:]
    @Published var shakeTrigger: [String: Int] = [:]
    @Published var isCompleted = false
    @Published var attemptCount = 0
    @Published var logMessage = ""

    init(problem: PuzzleProblem) {
        self.problem = problem
    }

    var resultMood: ResultMood {
        if isCompleted { return .success }
        if slotStates.values.contains(.wrong) { return .fail }
        return .neutral
    }

    func selectSlot(_ id: String) {
        activeSlotID = id
        slotStates = [:]
        Haptics.light()
    }

    func fillChoice(_ choice: String) {
        guard let id = activeSlotID else { return }
        answers[id] = choice
        slotStates = [:]
        Haptics.selection()
        // 次の空きへ
        let ids = problem.orderedSlotIDs
        if let idx = ids.firstIndex(of: id) {
            for off in 1..<ids.count {
                let next = ids[(idx + off) % ids.count]
                if answers[next]?.isEmpty != false { activeSlotID = next; return }
            }
        }
    }

    func reset() {
        answers = [:]; activeSlotID = nil; slotStates = [:]
        isCompleted = false; logMessage = ""
    }

    func runCheck() {
        slotStates = [:]
        attemptCount += 1
        let ids = problem.orderedSlotIDs
        let empty = ids.filter { answers[$0]?.isEmpty != false }
        if !empty.isEmpty {
            for id in empty { slotStates[id] = .wrong }
            logMessage = "未入力スロットが \(empty.count) 個あります"
            Haptics.warning()
            return
        }
        var wrong: [String] = []
        for id in ids {
            let ok = answers[id] == problem.slots[id]?.answer
            slotStates[id] = ok ? .correct : .wrong
            if !ok { wrong.append(id) }
        }
        if wrong.isEmpty {
            isCompleted = true
            logMessage = "PASS 🎉 復習クリア！"
            Haptics.success()
        } else {
            let labels = wrong.compactMap { problem.slots[$0]?.label }.joined(separator: " / ")
            logMessage = "FAIL: \(labels)"
            Haptics.error()
            for id in wrong { shakeTrigger[id, default: 0] += 1 }
            let wrongIDs = wrong
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
                guard let self else { return }
                for id in wrongIDs {
                    self.slotStates[id] = .idle
                    self.answers[id] = nil
                }
            }
        }
    }

    func segments(for line: String) -> [CodeSegment] {
        var segs: [CodeSegment] = []
        var cur = line.startIndex
        for match in line.matches(of: /\{\{(.*?)\}\}/) {
            if cur < match.range.lowerBound {
                segs.append(.text(String(line[cur..<match.range.lowerBound])))
            }
            segs.append(.slot(String(match.1)))
            cur = match.range.upperBound
        }
        if cur < line.endIndex { segs.append(.text(String(line[cur...]))) }
        return segs
    }
}

struct ReviewListView: View {
    let problems: [PuzzleProblem]
    let onPick: (PuzzleProblem) -> Void

    var body: some View {
        ZStack {
            LinearGradient(colors: [Pop.bgNeutralTop, Pop.bgNeutralBottom],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(problems) { p in
                        Button { onPick(p) } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(p.title)
                                        .font(.subheadline.weight(.black))
                                        .foregroundStyle(Pop.ink)
                                    Spacer()
                                    Text("★ \(p.difficulty)")
                                        .font(.caption2.weight(.heavy))
                                        .padding(.horizontal, 8).padding(.vertical, 3)
                                        .background(diffBg(p.difficulty), in: Capsule())
                                        .foregroundStyle(diffFg(p.difficulty))
                                }
                                Text(p.topic)
                                    .font(.caption2.weight(.heavy))
                                    .foregroundStyle(Color(red: 0.31, green: 0.27, blue: 0.90))
                                Text(p.prompt)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Pop.inkSub)
                                    .lineLimit(2)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white, in: RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(red: 0.78, green: 0.82, blue: 0.99), lineWidth: 1.2))
                            .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(TapGesture().onEnded { Haptics.light() })
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("復習モード")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func diffBg(_ d: String) -> Color {
        switch d {
        case "Easy": return Color(red: 0.73, green: 0.97, blue: 0.82)
        case "Hard": return Color(red: 1.00, green: 0.78, blue: 0.78)
        default:     return Color(red: 1.00, green: 0.93, blue: 0.72)
        }
    }
    private func diffFg(_ d: String) -> Color {
        switch d {
        case "Easy": return Color(red: 0.08, green: 0.32, blue: 0.18)
        case "Hard": return Color(red: 0.50, green: 0.11, blue: 0.11)
        default:     return Color(red: 0.57, green: 0.25, blue: 0.05)
        }
    }
}

struct PracticeView: View {
    @StateObject var session: PracticeSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            screenBg
            ScrollView {
                VStack(spacing: 14) {
                    promptCard
                    codeBlock
                    if session.isCompleted {
                        completionCard
                    } else {
                        answersPanel
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("復習: " + session.problem.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var screenBg: some View {
        let (top, bottom): (Color, Color) = {
            switch session.resultMood {
            case .success: return (Pop.bgSuccessTop, Pop.bgSuccessBottom)
            case .fail:    return (Pop.bgFailTop,    Pop.bgFailBottom)
            case .neutral: return (Pop.bgNeutralTop, Pop.bgNeutralBottom)
            }
        }()
        return LinearGradient(colors: [top, bottom],
                              startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.35), value: session.resultMood)
    }

    private var promptCard: some View {
        PopCard(fill: .white,
                border: Color(red: 0.78, green: 0.82, blue: 0.99)) {
            VStack(alignment: .leading, spacing: 8) {
                Text("📖 復習問題")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Color(red: 0.31, green: 0.27, blue: 0.90))
                Text(session.problem.title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(Pop.ink)
                Text(session.problem.prompt)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Pop.inkSub)
                Text(session.problem.example)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Pop.inkSub)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.96, green: 0.97, blue: 1.00),
                                in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var codeBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(session.problem.template.enumerated()), id: \.offset) { _, line in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(session.segments(for: line).enumerated()), id: \.offset) { _, seg in
                            segView(seg)
                        }
                    }
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(Color(red: 0.86, green: 0.89, blue: 0.97))
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.12, green: 0.11, blue: 0.29),
                    in: RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private func segView(_ seg: CodeSegment) -> some View {
        switch seg {
        case .text(let t): Text(t)
        case .slot(let id):
            let val = session.answers[id] ?? "___"
            let active = session.activeSlotID == id
            let state = session.slotStates[id] ?? .idle
            let shakes = session.shakeTrigger[id] ?? 0
            let (bg, border, fg) = slotColors(active: active, state: state)
            Button { session.selectSlot(id) } label: {
                Text(val)
                    .font(.system(size: 13, weight: .heavy, design: .monospaced))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(bg, in: RoundedRectangle(cornerRadius: 7))
                    .overlay(RoundedRectangle(cornerRadius: 7)
                        .stroke(border, style: StrokeStyle(lineWidth: 1.5,
                                                           dash: state == .idle ? [3, 3] : [])))
                    .foregroundStyle(fg)
            }
            .buttonStyle(.plain)
            .disabled(session.isCompleted)
            .modifier(ShakeEffect(animatableData: CGFloat(shakes)))
            .animation(.easeInOut(duration: 0.55), value: shakes)
        }
    }

    private func slotColors(active: Bool, state: SlotCheckState) -> (Color, Color, Color) {
        switch state {
        case .correct:
            return (Color(red: 0.73, green: 0.97, blue: 0.82),
                    Color(red: 0.13, green: 0.77, blue: 0.37),
                    Color(red: 0.08, green: 0.32, blue: 0.18))
        case .wrong:
            return (Color(red: 1.00, green: 0.78, blue: 0.78),
                    Pop.danger,
                    Color(red: 0.50, green: 0.11, blue: 0.11))
        case .idle:
            let bg: Color = active
                ? Color(red: 1.00, green: 0.94, blue: 0.54)
                : Color.white.opacity(0.08)
            let border: Color = active
                ? Color(red: 0.92, green: 0.70, blue: 0.03)
                : Color.white.opacity(0.30)
            return (bg, border, Color(red: 0.86, green: 0.89, blue: 0.97))
        }
    }

    private var answersPanel: some View {
        PopCard(fill: .white,
                border: Color(red: 0.87, green: 0.84, blue: 0.99)) {
            VStack(alignment: .leading, spacing: 12) {
                if let slot = session.problem.slots[session.activeSlotID ?? ""] {
                    Text("選択中: \(slot.label)")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Pop.inkSub)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Array(slot.choices.enumerated()), id: \.offset) { i, c in
                                Button {
                                    session.fillChoice(c)
                                } label: {
                                    Text(c)
                                        .font(.system(size: 14, weight: .heavy, design: .monospaced))
                                        .padding(.horizontal, 14).padding(.vertical, 9)
                                        .background(choicePalette(i).0, in: Capsule())
                                        .foregroundStyle(choicePalette(i).1)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(minHeight: 44)
                } else {
                    Text("↑ スロット（___）をタップしてね")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Pop.inkSub)
                }

                PopButton(fill: Pop.primary, shadow: Pop.primaryShadow,
                          action: { session.runCheck() }) {
                    Text("こたえる！")
                        .font(.headline.weight(.black))
                }

                if !session.logMessage.isEmpty {
                    Text(session.logMessage)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(session.resultMood == .fail ? Pop.danger : Pop.inkSub)
                }
            }
        }
    }

    private func choicePalette(_ i: Int) -> (Color, Color) {
        let p: [(Color, Color)] = [
            (Color(red: 0.65, green: 0.95, blue: 0.82), Color(red: 0.02, green: 0.37, blue: 0.27)),
            (Color(red: 0.98, green: 0.81, blue: 0.91), Color(red: 0.62, green: 0.09, blue: 0.30)),
            (Color(red: 0.75, green: 0.86, blue: 1.00), Color(red: 0.12, green: 0.23, blue: 0.54)),
            (Color(red: 1.00, green: 0.84, blue: 0.84), Color(red: 0.50, green: 0.11, blue: 0.11)),
            (Color(red: 0.73, green: 0.97, blue: 0.82), Color(red: 0.08, green: 0.32, blue: 0.18)),
            (Color(red: 0.87, green: 0.84, blue: 0.99), Color(red: 0.30, green: 0.11, blue: 0.58)),
        ]
        return p[i % p.count]
    }

    private var completionCard: some View {
        PopCard(fill: Color(red: 0.86, green: 0.99, blue: 0.91),
                border: Color(red: 0.13, green: 0.77, blue: 0.37)) {
            VStack(spacing: 14) {
                HStack(spacing: 6) {
                    Text("🎉").font(.system(size: 36))
                    Text("復習クリア！")
                        .font(.title2.weight(.black))
                        .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
                }
                Text("✨ \(session.attemptCount) 回でクリア ✨")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
                if !session.problem.explanation.isEmpty {
                    Text(session.problem.explanation)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
                        .multilineTextAlignment(.leading)
                }
                PopButton(fill: Pop.primary, shadow: Pop.primaryShadow,
                          action: { session.reset() }) {
                    Text("もう一回やる")
                        .font(.subheadline.weight(.heavy))
                }
            }
        }
    }
}
