import SwiftUI

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

    /// 今日の一問として開いた場合は true。ストリーク更新の callback がトリガーされる
    let isDaily: Bool

    init(quiz: ReorderQuiz, isDaily: Bool = false) {
        self.quiz = quiz
        self.isDaily = isDaily
    }

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
        SoundFX.tap()
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
            SoundFX.correct()
            // ③ 累計統計に反映し、④ バッジを再評価
            let stats = StatsStore.shared
            stats.recordReorderClear(topic: quiz.topic)
            BadgeStore.shared.evaluate(
                stats: stats,
                streak: appDefaults.integer(forKey: "algobite.streak")
            )
            return
        }

        resultMood = .fail
        Haptics.error()
        SoundFX.wrong()
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
    /// クリア後「次の問題へ」が押されたときの遷移先 (練習モード)
    var onNext: ((ReorderQuiz) -> Void)? = nil
    /// 今日の一問として開いた場合に、クリア時に呼ぶ callback (ストリーク更新)
    var onDailyCleared: (() -> Void)? = nil
    @State private var didCallDailyCallback = false

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
        .onChange(of: model.isCompleted) { _, completed in
            if completed && model.isDaily && !didCallDailyCallback {
                didCallDailyCallback = true
                onDailyCleared?()
            }
        }
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
        PopCard(fill: Pop.surface,
                border: Color(red: 0.87, green: 0.84, blue: 0.99)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(model.quiz.topic)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Color(red: 0.31, green: 0.27, blue: 0.90))
                Text(model.quiz.prompt)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Pop.inkSub)
            }
        }
    }

    private var answerArea: some View {
        PopCard(fill: Pop.surfaceLavender,
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
                    // 空状態: 候補から並べていく動線を矢印アイコンだけで示す
                    Image(systemName: "arrow.down")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Pop.inkSub.opacity(0.45))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 22)
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

        let bg: Color = isLCS  ? Pop.correctBg
                      : isMiss ? Pop.wrongBg
                      : Color.white
        let border: Color = isLCS  ? Pop.correctBorder
                          : isMiss ? Pop.danger
                          : Pop.borderDefault
        let fg: Color = isLCS  ? Pop.correctFg
                      : isMiss ? Pop.wrongFg
                      : Pop.ink

        return Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                model.removeAt(position)
            }
        } label: {
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .frame(minWidth: 50, minHeight: 50)
                .background(bg, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(border, lineWidth: 2))
                .shadow(color: isLCS ? Pop.correctBorder.opacity(0.3) : Color.black.opacity(0.1), radius: isLCS ? 8 : 4, y: 3)
                .foregroundStyle(fg)
        }
        .buttonStyle(.plain)
        .disabled(model.isGrading || model.isCompleted)
        .modifier(ShakeEffect(animatableData: CGFloat(model.shakeTrigger[position] ?? 0)))
        .animation(.easeInOut(duration: 0.55), value: model.shakeTrigger[position])
    }

    private var poolArea: some View {
        PopCard(fill: Pop.surface,
                border: Pop.borderDefault) {
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
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    model.pick(v)
                                }
                            } label: {
                                Text(v)
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .frame(minWidth: 50, minHeight: 50)
                                    .background(Color(red: 0.87, green: 0.84, blue: 0.99),
                                                in: RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12)
                                        .stroke(Pop.borderDefault, lineWidth: 2))
                                    .shadow(color: Pop.borderDefault.opacity(0.4), radius: 4, y: 3)
                                    .foregroundStyle(Color(red: 0.30, green: 0.18, blue: 0.50))
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
                PopButton(fill: Color(red: 0.61, green: 0.64, blue: 0.71),
                          shadow: Color(red: 0.41, green: 0.45, blue: 0.50),
                          action: { model.reset() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("リセット")
                            .font(.subheadline.weight(.heavy))
                    }
                }
                .disabled(model.picks.isEmpty || model.isGrading)
                .opacity((model.picks.isEmpty || model.isGrading) ? 0.5 : 1)

                let ready = model.picks.count == model.quiz.answer.count
                PopButton(fill: Pop.accent,
                          shadow: Pop.accentShadow,
                          action: { model.submit() }) {
                    Text("こたえる！")
                        .font(.title3.weight(.black))
                }
                .disabled(!ready || model.isGrading)
                .opacity((ready && !model.isGrading) ? 1 : 0.5)
            } else {
                // クリア後: 練習モードなら次へ shuffle、daily ならホームのみ
                if !model.isDaily {
                    PopButton(fill: Pop.accent,
                              shadow: Pop.accentShadow,
                              action: {
                                Haptics.light()
                                let others = ReorderQuiz.allList.filter { $0.id != model.quiz.id }
                                if let next = others.randomElement() {
                                    onNext?(next)
                                }
                              }) {
                        HStack(spacing: 6) {
                            Image(systemName: "shuffle")
                            Text("次の問題へ！")
                                .font(.subheadline.weight(.heavy))
                        }
                    }
                }
                PopButton(fill: Pop.accent,
                          shadow: Pop.accentShadow,
                          action: { dismiss() }) {
                    Text("ホームへ")
                        .font(.subheadline.weight(.heavy))
                }
            }
        }
    }

    private var completionCard: some View {
        PopCard(fill: Pop.surfaceMint,
                border: Color(red: 0.13, green: 0.77, blue: 0.37)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Text("クリア！")
                        .font(.title2.weight(.black))
                        .foregroundStyle(Pop.correctFg)
                    Spacer()
                    Text("試行 \(model.attemptCount)回")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
                }
                Text(model.quiz.explanation)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))

                if let cx = ReorderQuiz.complexity[model.quiz.id] {
                    reorderComplexityCard(cx)
                }

                // 解説アニメ — quiz topic に応じて自動選択
                VStack(alignment: .leading, spacing: 6) {
                    Text("動きで見る")
                        .font(.caption.weight(.black))
                        .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
                    ReorderAnswerAnim(quiz: model.quiz)
                }
                .padding(.top, 4)
            }
        }
    }

    // MARK: - 計算量カード（完了時）

    private func reorderComplexityCard(_ cx: AlgoComplexity) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 6) {
                Image(systemName: "gauge.with.dots.needle.67percent")
                    .font(.caption.weight(.bold))
                Text("計算量")
                    .font(.caption.weight(.black))
            }
            .foregroundStyle(Color(red: 0.20, green: 0.21, blue: 0.52))

            HStack(spacing: 8) {
                reorderComplexityPill(icon: "clock.fill",         title: "時間", value: cx.time)
                reorderComplexityPill(icon: "internaldrive.fill", title: "空間", value: cx.space)
            }
            if !cx.note.isEmpty {
                Text(cx.note)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color(red: 0.30, green: 0.31, blue: 0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.93, green: 0.94, blue: 1.00),
                    in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(Color(red: 0.55, green: 0.58, blue: 0.95), lineWidth: 1.1))
    }

    private func reorderComplexityPill(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color(red: 0.42, green: 0.40, blue: 0.90))
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(Color(red: 0.45, green: 0.47, blue: 0.62))
                Text(value)
                    .font(.system(.footnote, design: .monospaced).weight(.black))
                    .foregroundStyle(Color(red: 0.20, green: 0.21, blue: 0.52))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(Color(red: 0.78, green: 0.80, blue: 0.98), lineWidth: 1))
    }
}

private struct ReorderAnswerAnim: View {
    let quiz: ReorderQuiz
    @State private var revealedCount = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "正しい並び", tint: .green, onReplay: play) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(quiz.answer.indices, id: \.self) { index in
                        tile(width: max(42, CGFloat(quiz.answer[index].count * 11)),
                             height: 34,
                             bg: index < revealedCount ? .green.opacity(0.72) : .gray.opacity(0.18)) {
                            Text(index < revealedCount ? quiz.answer[index] : "?")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                        }
                        .scaleEffect(index == revealedCount - 1 ? 1.12 : 1)
                        .animation(.spring(response: 0.35), value: revealedCount)
                    }
                }
                .padding(.vertical, 4)
            }
            Text(revealedCount == quiz.answer.count
                 ? quiz.answer.joined(separator: " → ")
                 : "問題の正解順を左から確認")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1
        let currentToken = token
        revealedCount = 0
        for count in 1...quiz.answer.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35 + Double(count - 1) * 0.5) {
                guard currentToken == token else { return }
                withAnimation { revealedCount = count }
            }
        }
    }
}
