import SwiftUI

// MARK: - Animated Explanation

struct ExplanationView: View {
    let problem: PuzzleProblem
    let segments: (String) -> [CodeSegment]

    @State private var revealedSlots: Set<String> = []
    @State private var highlightedSlot: String?
    @State private var currentStep: Int = 0
    @State private var playToken: Int = 0

    var body: some View {
        PopCard(fill: Pop.surface,
                border: Pop.borderDefault) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    HStack(spacing: 6) {
                        Text("✨").font(.title3)
                        Text("解説アニメーション")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(Pop.inkWarmSub)
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
                            .foregroundStyle(Pop.inkWarm)
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
                    .foregroundStyle(Pop.inkWarmSub)
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
        if highlight { bg = Color(red: 1.00, green: 0.94, blue: 0.54) }
        else if revealed { bg = Pop.correctBg }
        else { bg = Color.white.opacity(0.10) }

        let stroke: Color
        if highlight { stroke = Pop.accentShadow }
        else if revealed { stroke = Pop.correctBorder }
        else { stroke = Color.white.opacity(0.30) }

        let fg: Color
        if highlight { fg = Color(red: 0.44, green: 0.25, blue: 0.07) }
        else if revealed { fg = Pop.correctFg }
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
