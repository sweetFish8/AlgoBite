import SwiftUI

// MARK: - Models

enum SlotCheckState { case idle, correct, wrong }

// 横揺れアニメーション。`shakes` を整数で増分させると 1 回振動する。
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 6
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

enum ResultMood { case neutral, success, fail }

struct PuzzleSlot {
    let id: String
    let label: String
    let answer: String
    let choices: [String]
}

struct PuzzleProblem: Identifiable, Hashable {
    static func == (l: PuzzleProblem, r: PuzzleProblem) -> Bool { l.id == r.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    let id: String
    let title: String
    let difficulty: String
    let topic: String
    let prompt: String
    let example: String
    let template: [String]
    let slots: [String: PuzzleSlot]
    let explanation: String

    init(id: String, title: String, difficulty: String, topic: String,
         prompt: String, example: String, template: [String],
         slots: [String: PuzzleSlot], explanation: String = "") {
        self.id = id
        self.title = title
        self.difficulty = difficulty
        self.topic = topic
        self.prompt = prompt
        self.example = example
        self.template = template
        self.slots = slots
        self.explanation = explanation
    }

    var orderedSlotIDs: [String] {
        var ids: [String] = []
        for line in template {
            for match in line.matches(of: /\{\{(.*?)\}\}/) {
                let id = String(match.1)
                if !ids.contains(id) { ids.append(id) }
            }
        }
        return ids
    }
}

enum CodeSegment: Hashable { case text(String), slot(String) }

// MARK: - ViewModel

@MainActor
final class GameViewModel: ObservableObject {
    @Published var answers: [String: String] = [:]
    @Published var activeSlotID: String?
    @Published var slotStates: [String: SlotCheckState] = [:]
    @Published var shakeTrigger: [String: Int] = [:]
    @Published var logMessage: String = ""
    @Published private(set) var streak: Int = 0
    @Published private(set) var isCompletedToday: Bool = false
    @Published private(set) var attemptCount: Int = 0
    @Published private(set) var slotResults: [String: Bool] = [:]
    @Published var hintLevel: HintLevel = .none
    @Published var gentleHintText: String?

    let problems: [PuzzleProblem] = PuzzleData.all
    let stats: StatsStore = .shared
    let badges: BadgeStore = .shared


    var todayProblem: PuzzleProblem {
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        return problems[day % problems.count]
    }

    var todayDateString: String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    var selectedSlot: PuzzleSlot? {
        guard let id = activeSlotID else { return nil }
        return todayProblem.slots[id]
    }

    /// 画面背景を変えるためのムード。クリア済 or 全スロット正解→success、間違いがあれば fail。
    var resultMood: ResultMood {
        if isCompletedToday { return .success }
        if slotStates.values.contains(.wrong) { return .fail }
        if !slotStates.isEmpty,
           slotStates.values.allSatisfy({ $0 == .correct }),
           slotStates.count == todayProblem.orderedSlotIDs.count {
            return .success
        }
        return .neutral
    }

    init() {
        let defaults = UserDefaults.standard
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        let today = f.string(from: Date())

        streak = defaults.integer(forKey: "algobite.streak")

        if let lastStr = defaults.string(forKey: "algobite.lastSolvedDate"),
           let lastDate = f.date(from: lastStr) {
            isCompletedToday = (lastStr == today)
            let diff = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            if diff > 1 {
                streak = 0
                defaults.set(0, forKey: "algobite.streak")
            }
        }

        attemptCount = defaults.integer(forKey: "algobite.todayAttempts.\(today)")

        if isCompletedToday {
            if let a = defaults.dictionary(forKey: "algobite.todayAnswers.\(today)") as? [String: String] {
                answers = a
            }
            if let r = defaults.dictionary(forKey: "algobite.todayResults.\(today)") as? [String: Bool] {
                slotResults = r
                slotStates = r.mapValues { $0 ? .correct : .wrong }
            }
            logMessage = "PASS 🎉 今日のパズルクリア！"
        }
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
        activeSlotID = nextEmptySlot(after: id)
        Haptics.selection()
    }

    func resetCurrent() {
        answers = [:]
        activeSlotID = nil
        slotStates = [:]
        hintLevel = .none
        gentleHintText = nil
        logMessage = "リセットしました"
        Haptics.light()
    }

    /// 段階的ヒント (⑤)
    /// none → gentle (テキスト) → fillOne (1スロット埋める) → fillAll (全部埋める)
    func revealHint() {
        guard !isCompletedToday else { return }
        switch hintLevel {
        case .none:
            hintLevel = .gentle
            gentleHintText = HintStore.gentleText(for: todayProblem)
            logMessage = "🔆 ヒント1/3: ふんわりヒント"
            Haptics.light()
        case .gentle:
            // 1 スロット埋める
            let ids = todayProblem.orderedSlotIDs
            if let id = ids.first(where: { answers[$0] != todayProblem.slots[$0]?.answer }),
               let answer = todayProblem.slots[id]?.answer {
                answers[id] = answer
                slotStates = [:]
                activeSlotID = nextEmptySlot(after: id)
                logMessage = "💡 ヒント2/3: \(todayProblem.slots[id]?.label ?? id) を埋めたよ"
            }
            hintLevel = .fillOne
            Haptics.medium()
        case .fillOne:
            // 全部埋める
            let ids = todayProblem.orderedSlotIDs
            for id in ids {
                answers[id] = todayProblem.slots[id]?.answer
            }
            slotStates = [:]
            activeSlotID = nil
            logMessage = "🔓 ヒント3/3: 全部埋めたよ。「こたえる！」を押そう"
            hintLevel = .fillAll
            Haptics.medium()
        case .fillAll:
            logMessage = "もうヒントはないよ。「こたえる！」を押してね"
            Haptics.warning()
        }
    }

    var hintLabel: String {
        switch hintLevel {
        case .none:    return "💡 ヒント (1/3)"
        case .gentle:  return "💡 もうちょい (2/3)"
        case .fillOne: return "💡 答えを見る (3/3)"
        case .fillAll: return "💡 ヒント済"
        }
    }

    func runCheck() {
        guard !isCompletedToday else { return }
        slotStates = [:]
        attemptCount += 1

        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        let today = f.string(from: Date())
        let defaults = UserDefaults.standard
        defaults.set(attemptCount, forKey: "algobite.todayAttempts.\(today)")

        let ids = todayProblem.orderedSlotIDs
        let empty = ids.filter { answers[$0]?.isEmpty != false }
        if !empty.isEmpty {
            for id in empty { slotStates[id] = .wrong }
            logMessage = "未入力スロットが \(empty.count) 個あります"
            Haptics.warning()
            return
        }

        var wrong: [String] = []
        var results: [String: Bool] = [:]
        for id in ids {
            let ok = answers[id] == todayProblem.slots[id]?.answer
            slotStates[id] = ok ? .correct : .wrong
            results[id] = ok
            if !ok { wrong.append(id) }
        }

        if wrong.isEmpty {
            isCompletedToday = true
            slotResults = results

            if let lastStr = defaults.string(forKey: "algobite.lastSolvedDate"),
               let lastDate = f.date(from: lastStr) {
                let diff = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
                if diff == 1 { streak += 1 }
                else if diff > 1 { streak = 1 }
            } else {
                streak = 1
            }

            defaults.set(today, forKey: "algobite.lastSolvedDate")
            defaults.set(streak, forKey: "algobite.streak")
            defaults.set(answers, forKey: "algobite.todayAnswers.\(today)")
            defaults.set(results, forKey: "algobite.todayResults.\(today)")
            logMessage = "PASS 🎉 今日のパズルクリア！"
            Haptics.success()
            stats.recordPuzzleClear(topic: todayProblem.topic)
            badges.evaluate(stats: stats, streak: streak)
        } else {
            let labels = wrong.compactMap { todayProblem.slots[$0]?.label }.joined(separator: " / ")
            logMessage = "FAIL: \(labels) を見直してください"
            Haptics.error()

            // 不正解スロットを震わせる → 少し待ってから idle に戻して再挑戦できるようにする
            for id in wrong {
                shakeTrigger[id, default: 0] += 1
            }
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

    func shareText() -> String {
        let ids = todayProblem.orderedSlotIDs
        let emojis = ids.map { slotResults[$0] == true ? "🟢" : "🔴" }.joined()
        return "AlgoBite \(todayDateString)\n\(todayProblem.title) \(emojis)\n試行: \(attemptCount)回  🔥\(streak)日連続"
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

    private func nextEmptySlot(after id: String) -> String? {
        let ids = todayProblem.orderedSlotIDs
        guard let idx = ids.firstIndex(of: id) else { return nil }
        for off in 1..<ids.count {
            let next = ids[(idx + off) % ids.count]
            if answers[next]?.isEmpty != false { return next }
        }
        return nil
    }
}

// MARK: - Views

enum AppScreen: Hashable {
    case problem
    case reorder(ReorderQuiz)
    case reorderList
    case review
    case practice(PuzzleProblem)
}

// MARK: - Palette / Helpers (pop & friendly)

enum Pop {
    // 背景グラデーション
    static let bgNeutralTop    = Color(red: 1.00, green: 0.97, blue: 0.93)   // #FFF7ED
    static let bgNeutralBottom = Color(red: 1.00, green: 0.89, blue: 0.89)   // #FFE4E6
    static let bgSuccessTop    = Color(red: 0.86, green: 0.99, blue: 0.91)   // #DCFCE7
    static let bgSuccessBottom = Color(red: 0.73, green: 0.97, blue: 0.82)   // #BBF7D0
    static let bgFailTop       = Color(red: 1.00, green: 0.84, blue: 0.84)   // #FECACA
    static let bgFailBottom    = Color(red: 0.99, green: 0.84, blue: 0.67)   // #FED7AA

    // メインカラー
    static let primary       = Color(red: 0.35, green: 0.80, blue: 0.01)  // Duolingo Green #58CC02
    static let primaryShadow = Color(red: 0.27, green: 0.64, blue: 0.01)  // #46A302
    static let accent        = Color(red: 0.96, green: 0.62, blue: 0.04)  // #F59E0B
    static let accentShadow  = Color(red: 0.84, green: 0.46, blue: 0.05)  // #D97706
    static let danger        = Color(red: 0.94, green: 0.27, blue: 0.27)  // #EF4444
    static let dangerShadow  = Color(red: 0.72, green: 0.11, blue: 0.11)  // #B91C1C

    // テキスト
    static let ink     = Color(red: 0.17, green: 0.18, blue: 0.20)   // #2B2D31
    static let inkSub  = Color(red: 0.42, green: 0.42, blue: 0.46)   // #6B6E76
}

/// Duolingo風の3D影付きボタン (下に offsetY 分のシャドウ層)
struct PopButton<Label: View>: View {
    let action: () -> Void
    let fill: Color
    let shadow: Color
    let radius: CGFloat
    let label: () -> Label
    @State private var pressed = false

    init(fill: Color = Pop.primary,
         shadow: Color = Pop.primaryShadow,
         radius: CGFloat = 16,
         action: @escaping () -> Void,
         @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.fill = fill
        self.shadow = shadow
        self.radius = radius
        self.label = label
    }

    var body: some View {
        Button {
            action()
        } label: {
            label()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(fill, in: RoundedRectangle(cornerRadius: radius))
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: radius)
                .fill(shadow)
                .offset(y: pressed ? 1 : 4)
        )
        .offset(y: pressed ? 3 : 0)
        ._onButtonGesture(pressing: { pressed = $0 }, perform: {})
    }
}

// SwiftUI 標準にない `_onButtonGesture` を簡易模倣 — pressing state を取れるよう薄く包む
extension View {
    fileprivate func _onButtonGesture(pressing: @escaping (Bool) -> Void,
                                       perform action: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressing(true) }
                .onEnded   { _ in pressing(false); action() }
        )
    }
}

/// ポップな影付きカード
struct PopCard<Content: View>: View {
    let fill: Color
    let border: Color
    let radius: CGFloat
    let content: () -> Content

    init(fill: Color = .white,
         border: Color = Color(red: 0.93, green: 0.91, blue: 0.97),
         radius: CGFloat = 18,
         @ViewBuilder content: @escaping () -> Content) {
        self.fill = fill
        self.border = border
        self.radius = radius
        self.content = content
    }

    var body: some View {
        content()
            .padding(18)
            .background(fill, in: RoundedRectangle(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(border, lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

struct ContentView: View {
    @StateObject private var vm = GameViewModel()
    @State private var showCopied = false
    @State private var path: [AppScreen] = []

    var body: some View {
        ZStack {
            NavigationStack(path: $path) {
                homeScreen
                    .navigationDestination(for: AppScreen.self) { screen in
                        switch screen {
                        case .problem:
                            problemScreen
                        case .reorder(let q):
                            ReorderQuizView(model: ReorderQuizViewModel(quiz: q))
                        case .reorderList:
                            ReorderQuizListView { q in
                                path.append(.reorder(q))
                            }
                        case .review:
                            ReviewListView(problems: vm.problems) { p in
                                path.append(.practice(p))
                            }
                        case .practice(let p):
                            PracticeView(session: PracticeSession(problem: p))
                        }
                    }
            }
            // ④ バッジ解放オーバーレイ
            if let badge = vm.badges.justUnlocked {
                BadgeUnlockOverlay(badge: badge) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        vm.badges.dismissJustUnlocked()
                    }
                }
                .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: vm.badges.justUnlocked)
    }

    // MARK: 背景 (画面全体)
    /// 答え合わせ結果に応じて背景色が変わる — 文字を読まなくても結果が分かる
    @ViewBuilder
    private func screenBackground(_ mood: ResultMood) -> some View {
        let (top, bottom): (Color, Color) = {
            switch mood {
            case .success: return (Pop.bgSuccessTop, Pop.bgSuccessBottom)
            case .fail:    return (Pop.bgFailTop,    Pop.bgFailBottom)
            case .neutral: return (Pop.bgNeutralTop, Pop.bgNeutralBottom)
            }
        }()
        LinearGradient(colors: [top, bottom],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.35), value: mood)
    }

    // MARK: Home screen
    private var homeScreen: some View {
        ZStack {
            screenBackground(vm.isCompletedToday ? .success : .neutral)
            VStack(spacing: 0) {
                homeHeader.padding(.horizontal, 18)
                ScrollView {
                    VStack(spacing: 18) {
                        streakSection      // ① 最上段 — 連続記録を一番目立たせる
                        todayPreviewCard
                        startButton
                        reorderPracticeCard
                        reviewCard
                        StatsCard(stats: vm.stats, badges: vm.badges)
                        BadgesCard(badges: vm.badges)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 6)
                    .padding(.bottom, 28)
                }
            }
        }
    }

    private var homeHeader: some View {
        HStack(spacing: 8) {
            CookieIcon(size: 36)
            Text("AlgoBite")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.49, green: 0.18, blue: 0.07))  // #7C2D12
            Spacer()
            HStack(spacing: 6) {
                DonutIcon(size: 22)
                Text(vm.todayDateString)
                    .font(.caption.weight(.heavy))
            }
            .foregroundStyle(Color(red: 0.60, green: 0.20, blue: 0.07))   // #9A3412
            .padding(.leading, 6).padding(.trailing, 12)
            .padding(.vertical, 5)
            .background(Color(red: 1.00, green: 0.84, blue: 0.67),         // #FED7AA
                        in: Capsule())
            .overlay(Capsule().stroke(Color(red: 0.99, green: 0.73, blue: 0.45), lineWidth: 1.5))
        }
        .padding(.vertical, 12)
    }

    private var todayPreviewCard: some View {
        PopCard(fill: .white,
                border: Color(red: 0.99, green: 0.79, blue: 0.79)) {       // #FECACA
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 1.00, green: 0.92, blue: 0.85))   // donut peach
                            .frame(width: 60, height: 60)
                        Circle()
                            .stroke(Color(red: 0.99, green: 0.73, blue: 0.45), lineWidth: 2)
                            .frame(width: 60, height: 60)
                        DonutIcon(size: 44)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("今日のおやつ")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(Color(red: 0.63, green: 0.39, blue: 0.05))  // #A16207
                        // 完了済なら今日が Day N、未完了なら今日 = Day N+1 (連続を伸ばす一日)
                        Text("Day \(vm.isCompletedToday ? max(vm.streak, 1) : vm.streak + 1)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Pop.inkSub)
                    }
                    Spacer()
                    if vm.isCompletedToday {
                        Text("✓ クリア")
                            .font(.caption2.weight(.heavy))
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color(red: 0.73, green: 0.97, blue: 0.82),
                                        in: Capsule())
                            .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18)) // #14532D
                    }
                }

                HStack(spacing: 6) {
                    let topic = vm.todayProblem.topic.components(separatedBy: " / ").first
                                  ?? vm.todayProblem.topic
                    popBadge("📌 \(topic)",
                             bg: Color(red: 0.99, green: 0.90, blue: 0.52),     // #FDE68A
                             fg: Color(red: 0.57, green: 0.25, blue: 0.05))     // #92400E
                    let d = vm.todayProblem.difficulty
                    let (db, df): (Color, Color) = {
                        switch d {
                        case "Easy":   return (Color(red: 0.73, green: 0.97, blue: 0.82),
                                               Color(red: 0.08, green: 0.32, blue: 0.18))
                        case "Hard":   return (Color(red: 1.00, green: 0.78, blue: 0.78),
                                               Color(red: 0.50, green: 0.11, blue: 0.11))
                        default:       return (Color(red: 1.00, green: 0.93, blue: 0.72),
                                               Color(red: 0.57, green: 0.25, blue: 0.05))
                        }
                    }()
                    popBadge("★ \(d)", bg: db, fg: df)
                }

                Text(vm.todayProblem.title)
                    .font(.title2.weight(.black))
                    .foregroundStyle(Pop.ink)

                Text(vm.todayProblem.prompt)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Pop.inkSub)
                    .lineLimit(3)
            }
        }
    }

    private var startButton: some View {
        PopButton(fill: Pop.primary,
                  shadow: Pop.primaryShadow,
                  action: { path.append(.problem) }) {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                Text(vm.isCompletedToday ? "結果と解説を見る！" : "はじめる！")
                    .font(.title3.weight(.black))
            }
        }
    }

    private var reorderPracticeCard: some View {
        PopCard(fill: .white,
                border: Color(red: 0.87, green: 0.84, blue: 0.99)) {     // #DDD6FE
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.96, green: 0.93, blue: 1.00))   // #F3F0FF
                            .frame(width: 56, height: 56)
                        Circle()
                            .stroke(Color(red: 0.78, green: 0.72, blue: 0.98), lineWidth: 2)
                            .frame(width: 56, height: 56)
                        CupcakeIcon(size: 44)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("並べ替え練習")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(Pop.ink)
                        Text("全 \(ReorderQuiz.allList.count) 問")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Pop.inkSub)
                    }
                    Spacer()
                    popBadge("\(ReorderQuiz.allList.count) 問",
                             bg: Color(red: 0.99, green: 0.79, blue: 0.18),
                             fg: Color(red: 0.49, green: 0.18, blue: 0.07))
                }
                PopButton(fill: Color(red: 0.55, green: 0.49, blue: 0.92),
                          shadow: Color(red: 0.40, green: 0.34, blue: 0.78),
                          action: { path.append(.reorderList) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "list.bullet.rectangle.fill")
                        Text("一覧から選ぶ！")
                            .font(.subheadline.weight(.heavy))
                    }
                }
            }
        }
    }

    // ⑥ 復習モードの導線
    private var reviewCard: some View {
        PopCard(fill: .white,
                border: Color(red: 0.99, green: 0.79, blue: 0.18)) {       // #FBBF24
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.97, green: 0.85, blue: 0.70))   // milky chocolate cream
                            .frame(width: 56, height: 56)
                        Circle()
                            .stroke(Color(red: 0.71, green: 0.46, blue: 0.20), lineWidth: 2)
                            .frame(width: 56, height: 56)
                        ChocolateIcon(size: 44)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("復習モード")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(Pop.ink)
                        Text("過去問にもう一度挑戦")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Pop.inkSub)
                    }
                    Spacer()
                    popBadge("全 \(vm.problems.count) 問",
                             bg: Color(red: 0.99, green: 0.90, blue: 0.52),
                             fg: Color(red: 0.57, green: 0.25, blue: 0.05))
                }
                PopButton(fill: Pop.accent,
                          shadow: Pop.accentShadow,
                          action: { path.append(.review) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "books.vertical.fill")
                        Text("過去問を見る！")
                            .font(.subheadline.weight(.heavy))
                    }
                }
            }
        }
    }

    private var streakSection: some View {
        PopCard(fill: Color(red: 1.00, green: 0.97, blue: 0.93),                // #FFF7ED
                border: Color(red: 0.99, green: 0.73, blue: 0.45)) {            // #FDBA74
            VStack(alignment: .leading, spacing: 14) {
                // 見出し
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    FlameIcon(size: 36)
                        .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.center] + 8 }
                    Text("\(vm.streak)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.49, green: 0.18, blue: 0.07))   // #7C2D12
                    Text("日連続！")
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(Color(red: 0.60, green: 0.20, blue: 0.07))
                    Spacer()
                    HStack(spacing: 4) {
                        CakeIcon(size: 16)
                        Text("ストリーク")
                            .font(.caption2.weight(.heavy))
                            .foregroundStyle(Color(red: 0.60, green: 0.20, blue: 0.07))
                    }
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color(red: 1.00, green: 0.91, blue: 0.78),
                                in: Capsule())
                }

                // クッキーの日めくり
                HStack(spacing: 8) {
                    ForEach(0..<7) { i in
                        let filled = i < min(vm.streak, 7)
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(filled
                                          ? Color(red: 1.00, green: 0.93, blue: 0.78)
                                          : Color.white)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(filled
                                                    ? Color(red: 0.71, green: 0.46, blue: 0.20)
                                                    : Color(red: 1.00, green: 0.84, blue: 0.67),
                                                    lineWidth: 1.4)
                                    )
                                if filled {
                                    CookieIcon(size: 24)
                                }
                            }
                            Text(["月","火","水","木","金","土","日"][i])
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(Color(red: 0.60, green: 0.20, blue: 0.07))
                        }
                    }
                }

                HStack(spacing: 6) {
                    Spacer()
                    if vm.streak > 0 {
                        CupcakeIcon(size: 18)
                        Text("また明日もおやつ食べようね")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(Color(red: 0.49, green: 0.18, blue: 0.07))
                    } else {
                        DonutIcon(size: 18)
                        Text("今日から1日目！はじめよう")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(Color(red: 0.49, green: 0.18, blue: 0.07))
                    }
                    Spacer()
                }
            }
        }
    }

    private func popBadge(_ text: String, bg: Color, fg: Color) -> some View {
        Text(text)
            .font(.caption.weight(.heavy))
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(bg, in: Capsule())
            .foregroundStyle(fg)
    }

    // MARK: Problem screen
    private var problemScreen: some View {
        ZStack {
            screenBackground(vm.resultMood)
            VStack(spacing: 0) {
                headerBar.padding(.horizontal, 18)
                ScrollView {
                    VStack(spacing: 14) {
                        problemCard
                        codeBlock
                        if vm.isCompletedToday {
                            completionCard
                            ExplanationView(problem: vm.todayProblem,
                                            segments: vm.segments(for:))
                        } else {
                            answersPanel
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 10)
                    .padding(.bottom, 28)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { path.removeLast() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title3)
                        Text("ホーム")
                    }
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(Color(red: 0.39, green: 0.40, blue: 0.95))   // #6366F1
                }
            }
        }
    }

    // MARK: Header
    private var headerBar: some View {
        HStack {
            HStack(spacing: 4) {
                Text("🍪")
                Text("AlgoBite")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.49, green: 0.18, blue: 0.07))
            }
            Spacer()
            HStack(spacing: 4) {
                Text("🔥").font(.title3)
                Text("\(vm.streak)")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.60, green: 0.20, blue: 0.07))
            }
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Color.white.opacity(0.7), in: Capsule())
        }
        .padding(.vertical, 14)
    }

    // MARK: Problem card
    private var problemCard: some View {
        PopCard(fill: .white,
                border: Color(red: 0.78, green: 0.82, blue: 0.99)) {      // #C7D2FE
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(vm.todayProblem.title)
                        .font(.headline.weight(.black))
                        .foregroundStyle(Color(red: 0.19, green: 0.18, blue: 0.50))  // #312E81
                    Spacer()
                    let d = vm.todayProblem.difficulty
                    let (db, df): (Color, Color) = {
                        switch d {
                        case "Easy":   return (Color(red: 0.73, green: 0.97, blue: 0.82),
                                               Color(red: 0.08, green: 0.32, blue: 0.18))
                        case "Hard":   return (Color(red: 1.00, green: 0.78, blue: 0.78),
                                               Color(red: 0.50, green: 0.11, blue: 0.11))
                        default:       return (Color(red: 1.00, green: 0.93, blue: 0.72),
                                               Color(red: 0.57, green: 0.25, blue: 0.05))
                        }
                    }()
                    popBadge("★ \(d)", bg: db, fg: df)
                }
                Text(vm.todayProblem.prompt)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Pop.ink)
                Text(vm.todayProblem.example)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Pop.inkSub)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.96, green: 0.97, blue: 1.00),   // #F5F7FF
                                in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: Code block
    private var codeBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(vm.todayProblem.topic, systemImage: "chevron.left.forwardslash.chevron.right")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Color(red: 0.31, green: 0.27, blue: 0.90))  // #4F46E5
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(vm.todayProblem.template.enumerated()), id: \.offset) { _, line in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(Array(vm.segments(for: line).enumerated()), id: \.offset) { _, seg in
                                segView(seg)
                            }
                        }
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(Color(red: 0.86, green: 0.89, blue: 0.97))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(red: 0.12, green: 0.11, blue: 0.29),                  // #1E1B4B
                    in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 0.19, green: 0.18, blue: 0.50), lineWidth: 1.5))
        .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 3)
    }

    @ViewBuilder
    private func segView(_ seg: CodeSegment) -> some View {
        switch seg {
        case .text(let t): Text(t)
        case .slot(let id):
            let val = vm.answers[id] ?? "___"
            let active = vm.activeSlotID == id
            let state = vm.slotStates[id] ?? .idle
            let shakes = vm.shakeTrigger[id] ?? 0
            Button { vm.selectSlot(id) } label: {
                Text(val)
                    .font(.system(size: 13, weight: .heavy, design: .monospaced))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(slotBg(active, state), in: RoundedRectangle(cornerRadius: 7))
                    .overlay(RoundedRectangle(cornerRadius: 7)
                        .stroke(slotBorder(active, state),
                                style: StrokeStyle(lineWidth: 1.5, dash: state == .idle ? [3, 3] : [])))
                    .foregroundStyle(slotFg(state))
            }
            .buttonStyle(.plain)
            .disabled(vm.isCompletedToday)
            .modifier(ShakeEffect(animatableData: CGFloat(shakes)))
            .animation(.easeInOut(duration: 0.55), value: shakes)
        }
    }

    private func slotBg(_ active: Bool, _ s: SlotCheckState) -> Color {
        switch s {
        case .correct: Color(red: 0.73, green: 0.97, blue: 0.82)   // #BBF7D0
        case .wrong:   Color(red: 1.00, green: 0.78, blue: 0.78)   // #FECACA
        case .idle:    active
                            ? Color(red: 1.00, green: 0.94, blue: 0.54)   // #FEF08A
                            : Color.white.opacity(0.08)
        }
    }
    private func slotBorder(_ active: Bool, _ s: SlotCheckState) -> Color {
        switch s {
        case .correct: Color(red: 0.13, green: 0.77, blue: 0.37)   // #22C55E
        case .wrong:   Pop.danger
        case .idle:    active
                            ? Color(red: 0.92, green: 0.70, blue: 0.03)
                            : Color.white.opacity(0.30)
        }
    }
    private func slotFg(_ s: SlotCheckState) -> Color {
        switch s {
        case .correct: Color(red: 0.08, green: 0.32, blue: 0.18)   // dark green
        case .wrong:   Color(red: 0.50, green: 0.11, blue: 0.11)
        case .idle:    Color(red: 0.86, green: 0.89, blue: 0.97)
        }
    }

    // MARK: Answers panel
    private var answersPanel: some View {
        PopCard(fill: .white,
                border: Color(red: 0.87, green: 0.84, blue: 0.99)) {      // #DDD6FE
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "pencil.tip.crop.circle.fill")
                        .foregroundStyle(Color(red: 0.39, green: 0.40, blue: 0.95))
                    Text(vm.selectedSlot == nil
                         ? "↑ スロット（___）をタップしてね"
                         : "選択中:")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Pop.inkSub)
                    if let s = vm.selectedSlot {
                        popBadge(s.label,
                                 bg: Color(red: 1.00, green: 0.95, blue: 0.78),
                                 fg: Color(red: 0.57, green: 0.25, blue: 0.05))
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array((vm.selectedSlot?.choices ?? []).enumerated()), id: \.offset) { i, c in
                            choiceChip(c, index: i)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .frame(minHeight: 44)

                HStack(spacing: 10) {
                    smallBtn("💡 ヒント", fill: Pop.accent, shadow: Pop.accentShadow) { vm.revealHint() }
                    smallBtn("↻ リセット",
                             fill: Color(red: 0.61, green: 0.64, blue: 0.71),
                             shadow: Color(red: 0.41, green: 0.45, blue: 0.50)) { vm.resetCurrent() }
                }

                PopButton(fill: Pop.primary, shadow: Pop.primaryShadow,
                          action: { vm.runCheck() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("こたえる！")
                            .font(.headline.weight(.black))
                    }
                }

                if !vm.logMessage.isEmpty {
                    Text(vm.logMessage)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(vm.resultMood == .fail ? Pop.danger : Pop.inkSub)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func choiceChip(_ c: String, index: Int) -> some View {
        // パステル6色を循環
        let palette: [(Color, Color)] = [
            (Color(red: 0.65, green: 0.95, blue: 0.82), Color(red: 0.02, green: 0.37, blue: 0.27)),
            (Color(red: 0.98, green: 0.81, blue: 0.91), Color(red: 0.62, green: 0.09, blue: 0.30)),
            (Color(red: 0.75, green: 0.86, blue: 1.00), Color(red: 0.12, green: 0.23, blue: 0.54)),
            (Color(red: 1.00, green: 0.84, blue: 0.84), Color(red: 0.50, green: 0.11, blue: 0.11)),
            (Color(red: 0.73, green: 0.97, blue: 0.82), Color(red: 0.08, green: 0.32, blue: 0.18)),
            (Color(red: 0.87, green: 0.84, blue: 0.99), Color(red: 0.30, green: 0.11, blue: 0.58)),
        ]
        let (bg, fg) = palette[index % palette.count]
        return Button { vm.fillChoice(c) } label: {
            Text(c)
                .font(.system(size: 14, weight: .heavy, design: .monospaced))
                .padding(.horizontal, 14).padding(.vertical, 9)
                .background(bg, in: Capsule())
                .foregroundStyle(fg)
                .overlay(Capsule().stroke(fg.opacity(0.25), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func smallBtn(_ t: String,
                          fill: Color,
                          shadow: Color,
                          action: @escaping () -> Void) -> some View {
        PopButton(fill: fill, shadow: shadow, radius: 12, action: action) {
            Text(t).font(.subheadline.weight(.heavy))
        }
    }

    // MARK: Completion card (お祝い)
    private var completionCard: some View {
        PopCard(fill: Color(red: 0.86, green: 0.99, blue: 0.91),                // #DCFCE7
                border: Color(red: 0.13, green: 0.77, blue: 0.37)) {            // #22C55E
            VStack(spacing: 20) {
                HStack(spacing: 6) {
                    Text("🎉").font(.system(size: 40))
                    Text("クリア！")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
                    Text("🎊").font(.system(size: 40))
                }

                HStack(spacing: 14) {
                    Text("🔥").font(.system(size: 36))
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(vm.streak)")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                            Text("日連続！")
                                .font(.headline.weight(.heavy))
                        }
                        .foregroundStyle(Color(red: 0.49, green: 0.18, blue: 0.07))
                        Text("また明日も来てね！")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Pop.inkSub)
                    }
                }

                HStack(spacing: 8) {
                    ForEach(vm.todayProblem.orderedSlotIDs, id: \.self) { id in
                        Text(vm.slotResults[id] == true ? "🟢" : "🔴")
                            .font(.system(size: 30))
                    }
                }
                Text("✨ \(vm.attemptCount) 回でクリア ✨")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))

                PopButton(fill: Color(red: 0.39, green: 0.40, blue: 0.95),        // #6366F1
                          shadow: Color(red: 0.30, green: 0.30, blue: 0.78),
                          action: {
                            UIPasteboard.general.string = vm.shareText()
                            showCopied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showCopied = false }
                          }) {
                    HStack(spacing: 8) {
                        Image(systemName: showCopied ? "checkmark.circle.fill" : "square.and.arrow.up.fill")
                        Text(showCopied ? "コピーしたよ！" : "結果をシェア")
                            .font(.subheadline.weight(.heavy))
                    }
                }
            }
        }
    }
}

// MARK: - Animated Explanation

struct ExplanationView: View {
    let problem: PuzzleProblem
    let segments: (String) -> [CodeSegment]

    @State private var revealedSlots: Set<String> = []
    @State private var highlightedSlot: String?
    @State private var currentStep: Int = 0
    @State private var playToken: Int = 0

    var body: some View {
        PopCard(fill: .white,
                border: Color(red: 0.99, green: 0.90, blue: 0.52)) {        // #FDE68A
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    HStack(spacing: 6) {
                        Text("✨").font(.title3)
                        Text("解説アニメーション")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(Color(red: 0.57, green: 0.25, blue: 0.05))
                    }
                    Spacer()
                    Button { play() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                            Text("もう一度")
                        }
                        .font(.caption.weight(.heavy))
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Pop.accent, in: Capsule())
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(problem.template.enumerated()), id: \.offset) { _, line in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(Array(segments(line).enumerated()), id: \.offset) { _, seg in
                                    animatedSeg(seg)
                                }
                            }
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(Color(red: 0.86, green: 0.89, blue: 0.97))
                        }
                    }
                }
                .padding(14)
                .background(Color(red: 0.12, green: 0.11, blue: 0.29),
                            in: RoundedRectangle(cornerRadius: 12))

                stepCaption
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .animation(.easeInOut(duration: 0.25), value: currentStep)

                topicAnimation

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text("💡").font(.title3)
                        Text("ポイント")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(Color(red: 0.49, green: 0.18, blue: 0.07))
                    }
                    Text(problem.explanation.isEmpty ? problem.prompt : problem.explanation)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color(red: 0.47, green: 0.22, blue: 0.06))   // #78350F
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 1.00, green: 0.95, blue: 0.78),                // #FEF3C7
                            in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(red: 0.96, green: 0.62, blue: 0.04), lineWidth: 1.2))
            }
        }
        .onAppear { play() }
    }

    @ViewBuilder
    private var stepCaption: some View {
        let ids = problem.orderedSlotIDs
        if currentStep > 0, currentStep <= ids.count,
           let slot = problem.slots[ids[currentStep - 1]] {
            HStack(spacing: 8) {
                Text("STEP \(currentStep)/\(ids.count)")
                    .font(.caption2.weight(.black))
                    .padding(.horizontal, 9).padding(.vertical, 4)
                    .background(Pop.accent, in: Capsule())
                    .foregroundStyle(.white)
                (Text("\(slot.label) → ")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Color(red: 0.57, green: 0.25, blue: 0.05))
                + Text(slot.answer)
                    .font(.system(.caption, design: .monospaced).weight(.black))
                    .foregroundStyle(Color(red: 0.13, green: 0.55, blue: 0.13)))
            }
        } else {
            Text("▶︎ 自動再生中…")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Pop.inkSub)
        }
    }

    @ViewBuilder
    private func animatedSeg(_ seg: CodeSegment) -> some View {
        switch seg {
        case .text(let t):
            Text(t)
        case .slot(let id):
            slotView(id: id)
        }
    }

    private func slotView(id: String) -> some View {
        let revealed = revealedSlots.contains(id)
        let highlight = highlightedSlot == id
        let answer = problem.slots[id]?.answer ?? ""
        let label = revealed ? answer : "___"

        let bg: Color
        if highlight { bg = Color(red: 1.00, green: 0.94, blue: 0.54) }            // #FEF08A
        else if revealed { bg = Color(red: 0.73, green: 0.97, blue: 0.82) }        // #BBF7D0
        else { bg = Color.white.opacity(0.10) }

        let stroke: Color
        if highlight { stroke = Color(red: 0.92, green: 0.70, blue: 0.03) }
        else if revealed { stroke = Color(red: 0.13, green: 0.77, blue: 0.37) }
        else { stroke = Color.white.opacity(0.30) }

        let fg: Color
        if highlight { fg = Color(red: 0.44, green: 0.25, blue: 0.07) }            // #713F12
        else if revealed { fg = Color(red: 0.08, green: 0.32, blue: 0.18) }
        else { fg = Color(red: 0.86, green: 0.89, blue: 0.97) }

        return Text(label)
            .font(.system(size: 13, weight: .heavy, design: .monospaced))
            .padding(.horizontal, 7).padding(.vertical, 2)
            .background(bg, in: RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(stroke, lineWidth: highlight ? 1.8 : 1.2)
            )
            .foregroundStyle(fg)
            .scaleEffect(highlight ? 1.22 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.6), value: highlight)
            .animation(.easeInOut(duration: 0.25), value: revealed)
    }

    private func play() {
        playToken += 1
        let token = playToken
        revealedSlots = []
        highlightedSlot = nil
        currentStep = 0

        let ids = problem.orderedSlotIDs
        for (i, id) in ids.enumerated() {
            let delay = 0.6 + Double(i) * 0.85
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard token == playToken else { return }
                withAnimation { highlightedSlot = id; currentStep = i + 1 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.35) {
                guard token == playToken else { return }
                withAnimation {
                    _ = revealedSlots.insert(id)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.7) {
                guard token == playToken else { return }
                withAnimation { highlightedSlot = nil }
            }
        }
    }

    @ViewBuilder
    private var topicAnimation: some View {
        AlgoBite.topicAnimation(for: problem)
    }
}

// MARK: - Binary Search Animation

struct BinarySearchAnim: View {
    let nums = [-1, 0, 3, 5, 9, 12, 14, 18, 22]
    let target = 9
    @State private var step = 0
    @State private var found = false
    @State private var token = 0

    var steps: [(l: Int, r: Int, mid: Int)] {
        var s: [(Int, Int, Int)] = []
        var l = 0, r = nums.count - 1
        while l <= r {
            let m = (l + r) / 2
            s.append((l, r, m))
            if nums[m] == target { break }
            if nums[m] < target { l = m + 1 } else { r = m - 1 }
        }
        return s
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("🔍").font(.title3)
                Text("二分探索の動き")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Color(red: 0.05, green: 0.46, blue: 0.55))   // teal
            }
            Text("target = \(target)")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Color(red: 0.42, green: 0.42, blue: 0.46))

            HStack(spacing: 5) {
                ForEach(nums.indices, id: \.self) { i in
                    cell(i)
                }
            }

            if step < steps.count {
                let s = steps[step]
                Text("l=\(s.l)  mid=\(s.mid) (nums[mid]=\(nums[s.mid]))  r=\(s.r)")
                    .font(.system(.caption2, design: .monospaced).weight(.semibold))
                    .foregroundStyle(Color(red: 0.42, green: 0.42, blue: 0.46))
            } else if found {
                Text("🎯 見つかった！")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
            }

            Button { play() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                    Text("もう一度")
                }
                .font(.caption.weight(.heavy))
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Color(red: 0.05, green: 0.71, blue: 0.85), in: Capsule())   // teal
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.93, green: 1.00, blue: 1.00),                          // #ECFEFF
                    in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(Color(red: 0.65, green: 0.95, blue: 0.97), lineWidth: 1.2))
        .onAppear { play() }
    }

    private func cell(_ i: Int) -> some View {
        let cur = step < steps.count ? steps[step] : steps.last!
        let inRange = i >= cur.l && i <= cur.r
        let isMid = i == cur.mid && step < steps.count
        let isFound = found && i == cur.mid

        let bg: Color
        if isFound { bg = Color(red: 0.13, green: 0.77, blue: 0.37) }      // green
        else if isMid { bg = Color(red: 1.00, green: 0.78, blue: 0.04) }   // amber
        else if inRange { bg = Color(red: 0.75, green: 0.94, blue: 0.97) } // light teal
        else { bg = Color(red: 0.95, green: 0.95, blue: 0.95) }

        let fg: Color = (isMid || isFound) ? .white : Color(red: 0.17, green: 0.18, blue: 0.20)

        return Text("\(nums[i])")
            .font(.system(size: 12, weight: .black, design: .monospaced))
            .frame(width: 30, height: 30)
            .background(bg, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.08), lineWidth: 0.8))
            .foregroundStyle(fg)
            .scaleEffect(isMid ? 1.18 : 1.0)
            .shadow(color: isMid ? Color(red: 1.00, green: 0.78, blue: 0.04).opacity(0.4)
                                : .clear,
                    radius: 4, y: 1)
            .animation(.spring(response: 0.35), value: step)
            .animation(.spring(response: 0.35), value: found)
    }

    private func play() {
        token += 1
        let t = token
        step = 0
        found = false
        for i in 0..<steps.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.9 + 0.4) {
                guard t == token else { return }
                withAnimation { step = i }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(steps.count) * 0.9 + 0.3) {
            guard t == token else { return }
            withAnimation { found = true }
        }
    }
}

// MARK: - Two Pointer (Palindrome) Animation

struct TwoPointerAnim: View {
    let word: String
    @State private var l = 0
    @State private var r = 0
    @State private var done = false
    @State private var token = 0

    var chars: [Character] { Array(word) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("👉👈").font(.title3)
                Text("Two Pointers")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Color(red: 0.55, green: 0.27, blue: 0.68))   // purple
            }
            Text("\"\(word)\" を両端から比較")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Color(red: 0.42, green: 0.42, blue: 0.46))

            HStack(spacing: 5) {
                ForEach(chars.indices, id: \.self) { i in
                    cell(i)
                }
            }

            if done {
                Text("🎈 回文だった！")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
            } else {
                Text("l=\(l)  r=\(r)")
                    .font(.system(.caption2, design: .monospaced).weight(.semibold))
                    .foregroundStyle(Color(red: 0.42, green: 0.42, blue: 0.46))
            }

            Button { play() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                    Text("もう一度")
                }
                .font(.caption.weight(.heavy))
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Color(red: 0.55, green: 0.27, blue: 0.68), in: Capsule())
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.98, green: 0.96, blue: 1.00),
                    in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(Color(red: 0.87, green: 0.84, blue: 0.99), lineWidth: 1.2))
        .onAppear { play() }
    }

    private func cell(_ i: Int) -> some View {
        let isL = i == l && !done
        let isR = i == r && !done
        let visited = (i < l) || (i > r) || done

        let bg: Color
        if isL || isR { bg = Color(red: 1.00, green: 0.78, blue: 0.04) }       // amber
        else if visited { bg = Color(red: 0.73, green: 0.97, blue: 0.82) }     // light green
        else { bg = Color(red: 0.96, green: 0.93, blue: 1.00) }                // pastel purple

        let fg: Color = (isL || isR) ? .white : Color(red: 0.17, green: 0.18, blue: 0.20)

        return VStack(spacing: 2) {
            Text(String(chars[i]))
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .frame(width: 28, height: 28)
                .background(bg, in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.08), lineWidth: 0.8))
                .foregroundStyle(fg)
                .scaleEffect((isL || isR) ? 1.18 : 1.0)
                .shadow(color: (isL || isR) ? Color(red: 1.00, green: 0.78, blue: 0.04).opacity(0.4)
                                            : .clear,
                        radius: 4, y: 1)
            Text(isL ? "l" : (isR ? "r" : " "))
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .foregroundStyle(Color(red: 0.84, green: 0.46, blue: 0.05))
        }
        .animation(.spring(response: 0.3), value: l)
        .animation(.spring(response: 0.3), value: r)
    }

    private func play() {
        token += 1
        let t = token
        l = 0
        r = chars.count - 1
        done = false
        var step = 0
        while l + step < r - step {
            let s = step
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(s + 1) * 0.8) {
                guard t == token else { return }
                withAnimation { l += 1; r -= 1 }
            }
            step += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(step + 1) * 0.8 + 0.3) {
            guard t == token else { return }
            withAnimation { done = true }
        }
    }
}

// MARK: - Anagram Animation

struct AnagramAnim: View {
    let a: String
    let b: String
    @State private var sortedA: [Character] = []
    @State private var sortedB: [Character] = []
    @State private var matched = false
    @State private var token = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("🔤").font(.title3)
                Text("ソートで比較")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Color(red: 0.04, green: 0.58, blue: 0.50))   // mint
            }

            row(label: "A", chars: sortedA.isEmpty ? Array(a) : sortedA)
            row(label: "B", chars: sortedB.isEmpty ? Array(b) : sortedB)

            if matched {
                Text("🎈 アナグラムだった！")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
            }

            Button { play() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                    Text("もう一度")
                }
                .font(.caption.weight(.heavy))
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Color(red: 0.04, green: 0.72, blue: 0.61), in: Capsule())
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.93, green: 1.00, blue: 0.98),
                    in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(Color(red: 0.65, green: 0.95, blue: 0.86), lineWidth: 1.2))
        .onAppear { play() }
    }

    @ViewBuilder
    private func row(label: String, chars: [Character]) -> some View {
        HStack(spacing: 5) {
            Text(label)
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundStyle(Color(red: 0.04, green: 0.58, blue: 0.50))
                .frame(width: 16)
            ForEach(chars.indices, id: \.self) { i in
                Text(String(chars[i]))
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .frame(width: 24, height: 24)
                    .background(matched
                                ? Color(red: 0.73, green: 0.97, blue: 0.82)
                                : Color(red: 0.65, green: 0.95, blue: 0.86),
                                in: RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black.opacity(0.08), lineWidth: 0.8))
                    .foregroundStyle(Color(red: 0.04, green: 0.34, blue: 0.30))
            }
        }
    }

    private func play() {
        token += 1
        let t = token
        sortedA = []
        sortedB = []
        matched = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            guard t == token else { return }
            withAnimation { sortedA = Array(a).sorted() }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard t == token else { return }
            withAnimation { sortedB = Array(b).sorted() }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            guard t == token else { return }
            withAnimation { matched = (Array(a).sorted() == Array(b).sorted()) }
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - Reorder Quiz (LCS判定の並べ替え練習)

struct ReorderQuiz: Hashable, Identifiable {
    let id: String
    let title: String
    let topic: String
    let prompt: String
    let pool: [String]
    let answer: [String]
    let explanation: String
}

extension ReorderQuiz {
    /// バブルソート1パス目: [5,2,4,1,3] → [2,4,1,3,5]
    static let bubbleSortPass: ReorderQuiz = .init(
        id: "bubble-sort-pass-1",
        title: "バブルソート 1パス目",
        topic: "ソート",
        prompt: "配列 [5, 2, 4, 1, 3] にバブルソートを1パス実行した直後の並びになるように、要素を順番にタップしてね。",
        pool: ["1", "2", "3", "4", "5"],
        answer: ["2", "4", "1", "3", "5"],
        explanation: "隣同士を比較しながら左から右へ進むと、最大値 5 が右端まで押し出される。他の要素は元の相対順序を保ったまま、5 が通り過ぎた分だけ左へ1つずれる。"
    )
}

/// 解答配列と正解配列の最長共通部分列(LCS)を求め、解答側の各位置が
/// LCS に含まれるかを返す。含まれる要素は「並びを変えなくて良い」=緑判定。
func reorderLCSMask(answer: [String], correct: [String]) -> [Bool] {
    let n = answer.count, m = correct.count
    guard n > 0, m > 0 else { return Array(repeating: false, count: n) }
    var dp = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
    for i in 0..<n {
        for j in 0..<m {
            if answer[i] == correct[j] {
                dp[i+1][j+1] = dp[i][j] + 1
            } else {
                dp[i+1][j+1] = max(dp[i][j+1], dp[i+1][j])
            }
        }
    }
    var mask = Array(repeating: false, count: n)
    var i = n, j = m
    while i > 0 && j > 0 {
        if answer[i-1] == correct[j-1] {
            mask[i-1] = true
            i -= 1; j -= 1
        } else if dp[i-1][j] >= dp[i][j-1] {
            i -= 1
        } else {
            j -= 1
        }
    }
    return mask
}

@MainActor
final class ReorderQuizViewModel: ObservableObject {
    let quiz: ReorderQuiz
    @Published var picks: [String] = []
    /// 採点後の各 picks 位置に対するLCSマスク。空 = 未採点。
    @Published var gradedMask: [Bool] = []
    @Published var shakeTrigger: [Int: Int] = [:]
    @Published var isCompleted = false
    @Published var attemptCount = 0
    @Published var resultMood: ResultMood = .neutral

    init(quiz: ReorderQuiz) { self.quiz = quiz }

    /// 候補のうち、現在 picks に積まれていない残り（同じ値の重複にも対応）
    var remainingPool: [String] {
        var remaining = quiz.pool
        for v in picks {
            if let idx = remaining.firstIndex(of: v) {
                remaining.remove(at: idx)
            }
        }
        return remaining
    }

    var isGrading: Bool { !gradedMask.isEmpty }

    func pick(_ value: String) {
        guard !isCompleted, !isGrading else { return }
        picks.append(value)
        Haptics.selection()
    }

    func removeAt(_ index: Int) {
        guard !isCompleted, !isGrading else { return }
        guard picks.indices.contains(index) else { return }
        picks.remove(at: index)
        Haptics.light()
    }

    func reset() {
        guard !isGrading else { return }
        picks = []
        gradedMask = []
        shakeTrigger = [:]
        resultMood = .neutral
        Haptics.light()
    }

    func submit() {
        guard !isCompleted, !isGrading else { return }
        guard picks.count == quiz.answer.count else { return }
        attemptCount += 1
        let mask = reorderLCSMask(answer: picks, correct: quiz.answer)
        gradedMask = mask

        if mask.allSatisfy({ $0 }) {
            isCompleted = true
            resultMood = .success
            Haptics.success()
            // ③ 累計統計に反映し、④ バッジを再評価
            let stats = StatsStore.shared
            stats.recordReorderClear()
            BadgeStore.shared.evaluate(
                stats: stats,
                streak: UserDefaults.standard.integer(forKey: "algobite.streak")
            )
            return
        }

        resultMood = .fail
        Haptics.error()
        for (idx, ok) in mask.enumerated() where !ok {
            shakeTrigger[idx, default: 0] += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            guard let self else { return }
            // LCSに含まれない要素だけ pool に戻す（= picks から取り除く）
            var keep: [String] = []
            for (i, v) in self.picks.enumerated() where mask.indices.contains(i) && mask[i] {
                keep.append(v)
            }
            self.picks = keep
            self.gradedMask = []
            self.shakeTrigger = [:]
            self.resultMood = .neutral
        }
    }
}

struct ReorderQuizView: View {
    @StateObject var model: ReorderQuizViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            screenBg
            ScrollView {
                VStack(spacing: 14) {
                    promptCard
                    answerArea
                    if !model.isCompleted { poolArea }
                    actionRow
                    if model.isCompleted { completionCard }
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle(model.quiz.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var screenBg: some View {
        let (top, bottom): (Color, Color) = {
            switch model.resultMood {
            case .success: return (Pop.bgSuccessTop, Pop.bgSuccessBottom)
            case .fail:    return (Pop.bgFailTop,    Pop.bgFailBottom)
            case .neutral: return (Pop.bgNeutralTop, Pop.bgNeutralBottom)
            }
        }()
        LinearGradient(colors: [top, bottom],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.35), value: model.resultMood)
    }

    private var promptCard: some View {
        PopCard(fill: .white,
                border: Color(red: 0.87, green: 0.84, blue: 0.99)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text("📋").font(.title3)
                    Text(model.quiz.topic)
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Color(red: 0.31, green: 0.27, blue: 0.90))
                }
                Text(model.quiz.prompt)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Pop.inkSub)
            }
        }
    }

    private var answerArea: some View {
        PopCard(fill: Color(red: 0.98, green: 0.96, blue: 1.00),
                border: Color(red: 0.87, green: 0.84, blue: 0.99)) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("あなたの並び")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Pop.inkSub)
                    Spacer()
                    Text("\(model.picks.count) / \(model.quiz.answer.count)")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(Pop.inkSub)
                }
                if model.picks.isEmpty {
                    Text("↓ 下の候補から順番にタップしてね")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Pop.inkSub.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 56), spacing: 8)],
                              spacing: 8) {
                        ForEach(Array(model.picks.enumerated()), id: \.offset) { idx, v in
                            answerTile(value: v, position: idx)
                        }
                    }
                }
            }
        }
    }

    private func answerTile(value: String, position: Int) -> some View {
        let inGrading = position < model.gradedMask.count
        let isLCS  = inGrading && model.gradedMask[position]
        let isMiss = inGrading && !model.gradedMask[position]

        let bg: Color = isLCS  ? Color(red: 0.73, green: 0.97, blue: 0.82)
                      : isMiss ? Color(red: 1.00, green: 0.78, blue: 0.78)
                      : Color.white
        let border: Color = isLCS  ? Color(red: 0.13, green: 0.77, blue: 0.37)
                          : isMiss ? Pop.danger
                          : Color(red: 0.87, green: 0.84, blue: 0.99)
        let fg: Color = isLCS  ? Color(red: 0.08, green: 0.32, blue: 0.18)
                      : isMiss ? Color(red: 0.50, green: 0.11, blue: 0.11)
                      : Pop.ink

        return Button {
            model.removeAt(position)
        } label: {
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .frame(minWidth: 50, minHeight: 50)
                .background(bg, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(border, lineWidth: 2))
                .foregroundStyle(fg)
        }
        .buttonStyle(.plain)
        .disabled(model.isGrading || model.isCompleted)
        .modifier(ShakeEffect(animatableData: CGFloat(model.shakeTrigger[position] ?? 0)))
        .animation(.easeInOut(duration: 0.55), value: model.shakeTrigger[position])
    }

    private var poolArea: some View {
        PopCard(fill: .white,
                border: Color(red: 0.99, green: 0.90, blue: 0.52)) {
            VStack(alignment: .leading, spacing: 10) {
                Text("候補")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Pop.inkSub)
                let remaining = model.remainingPool
                if remaining.isEmpty {
                    Text("全部使ったよ！「こたえる！」を押してね")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Pop.inkSub.opacity(0.6))
                        .padding(.vertical, 8)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 56), spacing: 8)],
                              spacing: 8) {
                        ForEach(Array(remaining.enumerated()), id: \.offset) { _, v in
                            Button { model.pick(v) } label: {
                                Text(v)
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .frame(minWidth: 50, minHeight: 50)
                                    .background(Color(red: 1.00, green: 0.95, blue: 0.78),
                                                in: RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.99, green: 0.79, blue: 0.18),
                                                lineWidth: 2))
                                    .foregroundStyle(Color(red: 0.49, green: 0.18, blue: 0.07))
                            }
                            .buttonStyle(.plain)
                            .disabled(model.isGrading)
                        }
                    }
                }
            }
        }
    }

    private var actionRow: some View {
        HStack(spacing: 10) {
            if !model.isCompleted {
                PopButton(fill: Color(red: 0.99, green: 0.90, blue: 0.52),
                          shadow: Color(red: 0.92, green: 0.70, blue: 0.03),
                          action: { model.reset() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("リセット")
                            .font(.subheadline.weight(.heavy))
                    }
                    .foregroundStyle(Color(red: 0.49, green: 0.18, blue: 0.07))
                }
                .disabled(model.picks.isEmpty || model.isGrading)
                .opacity((model.picks.isEmpty || model.isGrading) ? 0.5 : 1)

                let ready = model.picks.count == model.quiz.answer.count
                PopButton(fill: Pop.primary,
                          shadow: Pop.primaryShadow,
                          action: { model.submit() }) {
                    Text("こたえる！")
                        .font(.title3.weight(.black))
                }
                .disabled(!ready || model.isGrading)
                .opacity((ready && !model.isGrading) ? 1 : 0.5)
            } else {
                PopButton(fill: Pop.primary,
                          shadow: Pop.primaryShadow,
                          action: { dismiss() }) {
                    Text("ホームへ戻る")
                        .font(.title3.weight(.black))
                }
            }
        }
    }

    private var completionCard: some View {
        PopCard(fill: Color(red: 0.73, green: 0.97, blue: 0.82),
                border: Color(red: 0.13, green: 0.77, blue: 0.37)) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text("🎉").font(.system(size: 28))
                    Text("クリア！")
                        .font(.title2.weight(.black))
                        .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
                    Spacer()
                    Text("試行 \(model.attemptCount)回")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
                }
                Text(model.quiz.explanation)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
            }
        }
    }
}
