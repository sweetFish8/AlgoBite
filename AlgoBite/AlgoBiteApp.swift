import SwiftUI

@main
struct AlgoBiteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // ⑧ 初回起動時にだけ通知許可を聞き、許可済みなら毎日 20:00 にリマインド
                    AppNotifications.requestAuthorizationIfNeeded()
                }
        }
    }
}
