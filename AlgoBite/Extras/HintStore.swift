import SwiftUI
import Charts

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

