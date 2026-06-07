import SwiftUI
import Combine

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
    /// 今この瞬間にクリアした合図 (ホームのケーキにイチゴが載るアニメ用)
    @Published var justClearedToday = false
    /// 直前に不正解だったスロット (赤波線で表示し続ける)
    @Published var lastWrongIDs: Set<String> = []

    let problems: [PuzzleProblem] = PuzzleData.all
    let stats: StatsStore = .shared
    let badges: BadgeStore = .shared

    private var cancellables = Set<AnyCancellable>()


    /// 今日のひと口が穴埋めのとき、その問題本体。
    /// todayChallenge と同じインデックスから導出するので、ホームのプレビューと
    /// 開いた先の問題・アニメ・答えが必ず一致する。
    /// (並べ替えの日はこの問題画面は表示されないが、安全にフォールバックを返す)
    var todayProblem: PuzzleProblem {
        if case .puzzle(let p) = todayChallenge { return p }
        return problems[0]
    }

    /// 穴埋めと並べ替えを混ぜた「今日の一問」プール。
    /// 順序は 3 穴埋め : 1 並べ替えのインターリーブで、合計 134 問のローテーション。
    var dailyChallenges: [DailyChallenge] {
        var out: [DailyChallenge] = []
        let puzzles = problems
        let reorders = ReorderQuiz.allList
        var p = 0, r = 0
        while p < puzzles.count || r < reorders.count {
            for _ in 0..<3 where p < puzzles.count {
                out.append(.puzzle(puzzles[p])); p += 1
            }
            if r < reorders.count {
                out.append(.reorder(reorders[r])); r += 1
            }
        }
        return out
    }

    /// 今日の一問 (穴埋め or 並べ替え)
    var todayChallenge: DailyChallenge {
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        let pool = dailyChallenges
        return pool[day % pool.count]
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
        let defaults = appDefaults
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

        // BadgeStore の変更 (justUnlocked の set/clear) を ContentView に伝播する。
        badges.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        // 設定画面の「進捗リセット」後にメモリ上の状態もクリアする
        NotificationCenter.default.publisher(for: .algoBiteProgressDidReset)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.resetProgress() }
            .store(in: &cancellables)
    }

    /// 進捗リセット時にメモリ上の状態をすべて初期化する
    private func resetProgress() {
        isCompletedToday = false
        streak = 0
        answers = [:]
        activeSlotID = nil
        slotStates = [:]
        slotResults = [:]
        hintLevel = .none
        gentleHintText = nil
        lastWrongIDs = []
        attemptCount = 0
        justClearedToday = false
        logMessage = ""
    }

    func selectSlot(_ id: String) {
        activeSlotID = id
        slotStates = [:]
        clearLastWrong(id)
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

    /// 段階的ヒント: none → gentle (テキスト表示) → fillOne (1スロット埋める)
    func revealHint() {
        guard !isCompletedToday else { return }
        switch hintLevel {
        case .none:
            gentleHintText = HintStore.gentleText(for: todayProblem)
            hintLevel = .gentle
            logMessage = "💭 ヒント1/2: ふんわりヒント"
            Haptics.light()
        case .gentle:
            // 1 スロット埋める
            let ids = todayProblem.orderedSlotIDs
            if let id = ids.first(where: { answers[$0] != todayProblem.slots[$0]?.answer }),
               let answer = todayProblem.slots[id]?.answer {
                answers[id] = answer
                slotStates = [:]
                activeSlotID = nextEmptySlot(after: id)
                logMessage = "ヒント2/2: \(todayProblem.slots[id]?.label ?? id) を埋めたよ"
            }
            hintLevel = .fillOne
            Haptics.medium()
        case .fillOne:
            logMessage = "もうヒントはないよ"
            Haptics.warning()
        }
    }

    var hintLabel: String {
        switch hintLevel {
        case .none:    return "ヒント (1/2)"
        case .gentle:  return "もう少し (2/2)"
        case .fillOne: return "ヒント済"
        }
    }

    func runCheck() {
        guard !isCompletedToday else { return }
        slotStates = [:]
        attemptCount += 1

        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        let today = f.string(from: Date())
        let defaults = appDefaults
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
            justClearedToday = true
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
            lastWrongIDs = Set(wrongIDs)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
                guard let self else { return }
                for id in wrongIDs {
                    self.slotStates[id] = .idle
                    self.answers[id] = nil
                }
                // slotStates は idle に戻すが lastWrongIDs は残し、赤い波線で
                // 「ここを直してね」を視覚的に保持する
            }
        }
    }

    /// スロットがタップされたら lastWrong マークを外す (再挑戦の合図)
    func clearLastWrong(_ id: String) {
        if lastWrongIDs.contains(id) {
            lastWrongIDs.remove(id)
        }
    }

    /// 今日の一問が並べ替えだった場合、それをクリアしたら呼ぶ。穴埋め runCheck の成功
    /// 分岐と同じ後処理 (streak / lastSolvedDate / stats / badges) を実行する。
    func markDailyReorderCleared() {
        guard !isCompletedToday else { return }
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        let today = f.string(from: Date())
        let defaults = appDefaults

        isCompletedToday = true

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
        logMessage = "PASS 🎉 今日のひと口クリア！"
        justClearedToday = true
        Haptics.success()
        // 並べ替えのクリア記録は ReorderQuizViewModel.submit で既に行われている
        badges.evaluate(stats: stats, streak: streak)
    }

    /// 今日の問題を諦める (skip)。ストリークには影響させず、UI 状態だけ初期化する
    func skipToday() {
        answers = [:]
        activeSlotID = nil
        slotStates = [:]
        hintLevel = .none
        gentleHintText = nil
        lastWrongIDs = []
        logMessage = "今日はパスしたよ"
        Haptics.light()
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

