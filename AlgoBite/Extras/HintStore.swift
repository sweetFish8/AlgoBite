import SwiftUI
import Charts

// MARK: - Hint Store (⑤)

enum HintLevel: Int, Comparable {
    case none = 0, fillOne = 1, fillAll = 2
    static func < (l: HintLevel, r: HintLevel) -> Bool { l.rawValue < r.rawValue }
}

