import SwiftUI
import Charts

// MARK: - Share Sheet (UIActivityViewController ラッパー)

/// 結果文字列を OS 標準の共有シートに渡す。
/// SwiftUI の `ShareLink` だと PopButton の 3D スタイルが流用できないので
/// 既存ボタン → `.sheet` 経由でこの View を提示する形にしてる。
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

