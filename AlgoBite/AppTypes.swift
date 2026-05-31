import SwiftUI

// MARK: - Views

enum AppScreen: Hashable {
    case problem
    case reorder(ReorderQuiz)
    case dailyReorder(ReorderQuiz)   // 「今日の一問」が並べ替えだった場合の専用ルート (クリアでストリーク更新)
    case reorderList
    case review
    case practice(PuzzleProblem)
    case achievements
    case settings
}

/// 今日の一問の型 (穴埋め or 並べ替え)
enum DailyChallenge: Hashable {
    case puzzle(PuzzleProblem)
    case reorder(ReorderQuiz)

    var title: String {
        switch self {
        case .puzzle(let p):  return p.title
        case .reorder(let r): return r.title
        }
    }
    var topic: String {
        switch self {
        case .puzzle(let p):  return p.topic
        case .reorder(let r): return r.topic
        }
    }
    var prompt: String {
        switch self {
        case .puzzle(let p):  return p.prompt
        case .reorder(let r): return r.prompt
        }
    }
    var difficulty: String {
        switch self {
        case .puzzle(let p):  return p.difficulty
        case .reorder: return "Medium"   // 並べ替えは難易度なしなので暫定
        }
    }
    var kindLabel: String {   // バッジ表示用
        switch self {
        case .puzzle:  return "穴埋め"
        case .reorder: return "並べ替え"
        }
    }
}

// MARK: - Palette / Helpers (pop & friendly)

/// light/dark を切替える Color。UIColor の dynamic provider 経由。
extension Color {
    static func dyn(light: Color, dark: Color) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

