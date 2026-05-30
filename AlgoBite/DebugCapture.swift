//
//  DebugCapture.swift
//  AlgoBite
//
//  撮影用・デバッグ用の起動引数ヘルパー。**本番では使われない**:
//  - ファイル全体を `#if DEBUG ... #endif` で囲んでいるので、Release ビルドでは
//    シンボル自体が消える (Apple App Store 用のビルドでは含まれない)
//  - 呼び出し側 (AlgoBiteApp.init / ContentView.path / problemScreen.onAppear) も
//    すべて `#if DEBUG` で囲んでいる
//
//  使い方:
//     xcrun simctl launch booted app.Goto.Sakana.AlgoBite \
//        -captureMode -nav problem -autoplay correct
//
//  flag 一覧:
//     -captureMode               オンボーディング + 通知ダイアログをスキップ
//                                streak / stats / バッジにサンプル値を投入
//     -nav <screen>              起動時に指定画面へ自動遷移
//        screen: problem / achievements / settings / reorderList / review
//     -autoplay <mode>           問題画面で自動で answer を埋めて runCheck
//        mode: correct / wrong
//

#if DEBUG
import SwiftUI

enum DebugCapture {
    /// -captureMode が指定されてるか
    static var isActive: Bool { CommandLine.arguments.contains("-captureMode") }

    /// AlgoBiteApp.init から呼ぶ。サンプルデータを Defaults に流し込む
    static func applyIfRequested() {
        let args = CommandLine.arguments
        guard args.contains("-captureMode") else { return }
        appDefaults.set(true, forKey: "algobite.onboarded")
        appDefaults.set(true, forKey: "algobite.notifications.asked")
        appDefaults.set(5,    forKey: "algobite.streak")
        appDefaults.set(12,   forKey: "algobite.stats.totalSolved")
        appDefaults.set(3,    forKey: "algobite.stats.reorderClears")
        appDefaults.set(["first_clear", "streak_3", "reorder_first", "total_10"],
                        forKey: "algobite.badges.unlocked")
        appDefaults.set(["2026-05-31", "2026-05-30", "2026-05-29", "2026-05-28",
                         "2026-05-27", "2026-05-22", "2026-05-21", "2026-05-19", "2026-05-13"],
                        forKey: "algobite.stats.solvedDates")
        // autoplay を使う場合は「今日まだ未完」状態にリセット
        if args.contains("-autoplay") {
            appDefaults.removeObject(forKey: "algobite.lastSolvedDate")
            let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
            let today = f.string(from: Date())
            appDefaults.removeObject(forKey: "algobite.todayAnswers.\(today)")
            appDefaults.removeObject(forKey: "algobite.todayResults.\(today)")
            appDefaults.removeObject(forKey: "algobite.todayAttempts.\(today)")
        }
        appDefaults.synchronize()
    }

    /// -nav <screen> に応じて NavigationStack の初期パスを返す
    static func initialPath() -> [AppScreen] {
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "-nav"), i + 1 < args.count else { return [] }
        switch args[i + 1] {
        case "problem":      return [.problem]
        case "achievements": return [.achievements]
        case "settings":     return [.settings]
        case "reorderList":  return [.reorderList]
        case "review":       return [.review]
        default:             return []
        }
    }

    /// 問題画面の onAppear から呼ぶ。-autoplay correct / wrong で自動再生
    @MainActor
    static func autoplayProblem(vm: GameViewModel) {
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "-autoplay"),
              i + 1 < args.count else { return }
        let mode = args[i + 1]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let p = vm.todayProblem
            switch mode {
            case "correct":
                for id in p.orderedSlotIDs {
                    if let a = p.slots[id]?.answer { vm.answers[id] = a }
                }
                vm.runCheck()
            case "wrong":
                for id in p.orderedSlotIDs {
                    if let choices = p.slots[id]?.choices,
                       let correct = p.slots[id]?.answer,
                       let bad = choices.first(where: { $0 != correct }) {
                        vm.answers[id] = bad
                    }
                }
                vm.runCheck()
            default: break
            }
        }
    }
}
#endif
