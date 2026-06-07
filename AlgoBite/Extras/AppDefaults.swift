import SwiftUI
import UIKit
import UserNotifications

// MARK: - Shared UserDefaults (App Group)

/// メインアプリと Widget で共有する UserDefaults。
/// App Group が有効ならそちら、無ければ .standard にフォールバック。
let appDefaults: UserDefaults = {
    UserDefaults(suiteName: "group.group.app.Goto.Sakana.AlgoBite") ?? .standard
}()

// MARK: - Notification Names

extension Notification.Name {
    /// SettingsStore.resetAll() 後に投げる。GameViewModel がメモリ状態をリセットする。
    static let algoBiteProgressDidReset = Notification.Name("algoBiteProgressDidReset")
}

