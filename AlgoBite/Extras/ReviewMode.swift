import SwiftUI
import Charts

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
    let challenges: [DailyChallenge]
    let onPick: (DailyChallenge) -> Void

    var body: some View {
        ZStack {
            LinearGradient(colors: [Pop.bgNeutralTop, Pop.bgNeutralBottom],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(Array(challenges.enumerated()), id: \.offset) { _, challenge in
                        Button { onPick(challenge) } label: {
                            reviewRow(challenge)
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(TapGesture().onEnded { Haptics.light() })
                    }
                }
                .padding(16)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("復習モード")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func reviewRow(_ challenge: DailyChallenge) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(challenge.title)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Pop.ink)
                Spacer()
                // 並べ替えは "並べ替え" タグ、穴埋めは難易度バッジ
                switch challenge {
                case .puzzle(let p):
                    Text("★ \(p.difficulty)")
                        .font(.caption2.weight(.heavy))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(diffBg(p.difficulty), in: Capsule())
                        .foregroundStyle(diffFg(p.difficulty))
                case .reorder:
                    Text("並べ替え")
                        .font(.caption2.weight(.heavy))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color(red: 0.96, green: 0.93, blue: 1.00), in: Capsule())
                        .foregroundStyle(Color(red: 0.31, green: 0.27, blue: 0.90))
                }
            }
            Text(challenge.topic)
                .font(.caption2.weight(.heavy))
                .foregroundStyle(Color(red: 0.31, green: 0.27, blue: 0.90))
            Text(challenge.prompt)
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
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
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
        PopCard(fill: Pop.surface,
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
        PopCard(fill: Pop.surface,
                border: Color(red: 0.87, green: 0.84, blue: 0.99)) {
            VStack(alignment: .leading, spacing: 12) {
                if let slot = session.problem.slots[session.activeSlotID ?? ""] {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil.tip.crop.circle.fill")
                            .foregroundStyle(Color(red: 0.39, green: 0.40, blue: 0.95))
                        Text(slot.label)
                            .font(.caption.weight(.heavy))
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color(red: 1.00, green: 0.95, blue: 0.78), in: Capsule())
                            .foregroundStyle(Color(red: 0.57, green: 0.25, blue: 0.05))
                    }
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
                }

                PopButton(fill: Pop.accent, shadow: Pop.accentShadow,
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
        PopCard(fill: Pop.surfaceMint,
                border: Color(red: 0.13, green: 0.77, blue: 0.37)) {
            VStack(spacing: 14) {
                HStack(spacing: 6) {
                    Image(systemName: "party.popper.fill").font(.system(size: 32)).foregroundStyle(Pop.accent)
                    Text("復習クリア！")
                        .font(.title2.weight(.black))
                        .foregroundStyle(Pop.correctFg)
                }
                Text("\(session.attemptCount) 回でクリア")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Pop.correctFg)
                if !session.problem.explanation.isEmpty {
                    Text(session.problem.explanation)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
                        .multilineTextAlignment(.leading)
                }
                PopButton(fill: Pop.accent, shadow: Pop.accentShadow,
                          action: { session.reset() }) {
                    Text("もう一回やる")
                        .font(.subheadline.weight(.heavy))
                }
            }
        }
    }
}
