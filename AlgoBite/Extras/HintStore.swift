import SwiftUI
import Charts

// MARK: - Hint Store (⑤)

enum HintLevel: Int, Comparable {
    case none = 0, gentle = 1, fillOne = 2
    static func < (l: HintLevel, r: HintLevel) -> Bool { l.rawValue < r.rawValue }
}

@MainActor
final class HintStore: ObservableObject {
    static func gentleText(for problem: PuzzleProblem) -> String {
        if !problem.explanation.isEmpty {
            let first = problem.explanation
                .split(whereSeparator: { ".。!?！？\n".contains($0) })
                .first.map(String.init) ?? problem.explanation
            return "💭 \(first)"
        }
        return "💭 トピック「\(problem.topic)」の典型パターンを思い出してみよう"
    }
}

