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


// MARK: - Rewarded Ad Manager (AdMob)
//
// 「広告を見てヒントをもう1つ」用のリワード広告。
// Google Mobile Ads SDK (v11+ / SwiftPM: github.com/googleads/swift-package-manager-google-mobile-ads)
// を追加すると本番動作する。未追加でもビルドが通るよう canImport でガードしている。
//
// ⚠️ 本番リリース前に必須:
//   1) Info.plist の GADApplicationIdentifier を自分のAdMob App IDに差し替え
//   2) 下の adUnitID を自分のリワード広告ユニットIDに差し替え（現在はGoogle公式テストID）
//   3) App Store Connect のプライバシー開示・プライバシーポリシーを更新
//   4) SKAdNetworkIdentifiers を Info.plist に追加（計測用・推奨）

#if canImport(GoogleMobileAds)
import GoogleMobileAds
import UIKit
import AppTrackingTransparency

@MainActor
final class RewardedAdManager: NSObject, ObservableObject {
    static let shared = RewardedAdManager()

    /// Google公式テスト用リワード広告ユニットID（本番では自分のIDに差し替え）
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"
    private var rewardedAd: RewardedAd?
    private var isLoading = false

    /// 起動時に1回呼ぶ。SDK初期化＋先読み。
    func start() {
        MobileAds.shared.start(completionHandler: nil)
        load()
    }

    /// ATT（トラッキング許可）ダイアログ。起動直後は避け、少し遅らせて表示。
    func requestTrackingIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }

    func load() {
        guard rewardedAd == nil, !isLoading else { return }
        isLoading = true
        RewardedAd.load(with: adUnitID, request: Request()) { [weak self] ad, error in
            guard let self else { return }
            self.isLoading = false
            if let error {
                print("AdMob rewarded load failed: \(error.localizedDescription)")
                return
            }
            self.rewardedAd = ad
        }
    }

    /// 広告を表示。視聴完了で onReward を呼ぶ。
    /// 広告が用意できていない場合はユーザーを待たせず即 onReward（フォールバック付与）。
    func showRewarded(onReward: @escaping () -> Void) {
        guard let ad = rewardedAd, let root = Self.rootViewController else {
            onReward()
            load()
            return
        }
        rewardedAd = nil
        ad.present(from: root) { onReward() }
        load()   // 次の広告を先読み
    }

    private static var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController
    }
}
#else
// SDK 未追加時のスタブ。ビルドを通すためのもので、広告が無いので即リワード付与。
@MainActor
final class RewardedAdManager: ObservableObject {
    static let shared = RewardedAdManager()
    func start() {}
    func requestTrackingIfNeeded() {}
    func load() {}
    func showRewarded(onReward: @escaping () -> Void) { onReward() }
}
#endif
