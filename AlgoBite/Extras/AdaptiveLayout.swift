import SwiftUI

// MARK: - Adaptive Layout (iPad対応)
//
// これまで全画面が `.frame(maxWidth: 560)` の固定幅カラムを中央に置くだけで、
// iPad では大画面の中央に小さくコンテンツが浮いているだけだった。
// レイアウトは 1 カラムのまま、iPad (regular 幅) ではコンテンツ幅を大きく広げて
// 画面を活かす。iPhone / iPad SplitView 等 (compact 幅) では従来どおり。

enum Layout {
    /// iPhone（および iPad の compact 幅）での 1 カラム幅
    static let phoneWidth: CGFloat = 560
    /// iPad フルスクリーン (regular 幅) での 1 カラム幅 — 大きく見せる
    static let padWidth: CGFloat = 880
}

/// コンテンツの最大幅を size class に応じて切り替えて中央寄せするモディファイア。
/// 1 カラムのまま、iPad では大きく広げる。
private struct ContentColumn: ViewModifier {
    @Environment(\.horizontalSizeClass) private var h

    func body(content: Content) -> some View {
        let maxW: CGFloat = h == .regular ? Layout.padWidth : Layout.phoneWidth
        content
            .frame(maxWidth: maxW)
            .frame(maxWidth: .infinity)
    }
}

extension View {
    /// 旧来の `.frame(maxWidth: 560).frame(maxWidth: .infinity)` を置き換える。
    /// iPad では 1 カラムのまま幅を大きく広げる。
    func contentColumn() -> some View {
        modifier(ContentColumn())
    }
}
