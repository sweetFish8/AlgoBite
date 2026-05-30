import SwiftUI

@main
struct AlgoBiteApp: App {
    init() {
        #if DEBUG
        DebugCapture.applyIfRequested()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    #if DEBUG
                    if DebugCapture.isActive { return }
                    #endif
                    // ⑧ 初回起動時にだけ通知許可を聞き、許可済みなら毎日 20:00 にリマインド
                    AppNotifications.requestAuthorizationIfNeeded()
                }
        }
    }
}
