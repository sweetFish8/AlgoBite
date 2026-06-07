import SwiftUI
import Charts
import WidgetKit

// MARK: - Settings Screen — 設定画面

@MainActor
final class SettingsStore: ObservableObject {
    @Published var notificationsEnabled: Bool {
        didSet { appDefaults.set(notificationsEnabled, forKey: "algobite.notifications.enabled")
                 reschedule() }
    }
    @Published var notifyHour: Int   { didSet { appDefaults.set(notifyHour, forKey: "algobite.notify.hour"); reschedule() } }
    @Published var notifyMinute: Int { didSet { appDefaults.set(notifyMinute, forKey: "algobite.notify.minute"); reschedule() } }

    static let shared = SettingsStore()

    init() {
        let d = appDefaults
        notificationsEnabled = d.bool(forKey: "algobite.notifications.enabled")
        notifyHour   = d.object(forKey: "algobite.notify.hour")   as? Int ?? 20
        notifyMinute = d.object(forKey: "algobite.notify.minute") as? Int ?? 0
    }

    private func reschedule() {
        let c = UNUserNotificationCenter.current()
        c.removePendingNotificationRequests(withIdentifiers: [AppNotifications.dailyId])
        guard notificationsEnabled else { return }
        AppNotifications.scheduleDaily(hour: notifyHour, minute: notifyMinute)
    }

    /// 進捗を全部リセット (個別キーを消す)
    func resetAll() {
        let d = appDefaults
        for key in d.dictionaryRepresentation().keys where key.hasPrefix("algobite") {
            // 通知設定は残す
            if key.hasPrefix("algobite.notify") || key.hasPrefix("algobite.notifications") { continue }
            d.removeObject(forKey: key)
        }
        // インメモリのバッジ状態もクリア（ディスクだけ消してもメモリに残る）
        BadgeStore.shared.resetAll()
        // GameViewModel のメモリ上の状態もリセットする
        NotificationCenter.default.post(name: .algoBiteProgressDidReset, object: nil)
        // Widget のタイムラインも即時リロード
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct SettingsView: View {
    @StateObject private var s = SettingsStore.shared
    @State private var confirmingReset = false
    @State private var resetDone = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Pop.bgNeutralTop, Pop.bgNeutralBottom],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    // 通知設定
                    PopCard(fill: Pop.surface,
                            border: Color(red: 0.99, green: 0.79, blue: 0.45)) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 8) {
                                Text("🔔").font(.title3)
                                Text("通知").font(.subheadline.weight(.black))
                                    .foregroundStyle(Pop.ink)
                            }
                            Toggle(isOn: $s.notificationsEnabled) {
                                Text("デイリーリマインダー")
                                    .font(.subheadline.weight(.heavy))
                                    .foregroundStyle(Pop.ink)
                            }
                            .tint(Pop.primary)
                            .accessibilityHint("毎日この時刻に通知が届きます")

                            if s.notificationsEnabled {
                                HStack {
                                    Text("時刻")
                                        .font(.caption.weight(.heavy))
                                        .foregroundStyle(Pop.inkSub)
                                    Spacer()
                                    DatePicker("時刻",
                                               selection: Binding(
                                                get: { Self.dateOf(hour: s.notifyHour, minute: s.notifyMinute) },
                                                set: { newDate in
                                                    let c = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                                    s.notifyHour = c.hour ?? 20
                                                    s.notifyMinute = c.minute ?? 0
                                                }),
                                               displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                }
                            }
                        }
                    }

                    // 進捗リセット
                    PopCard(fill: Pop.surface,
                            border: Pop.danger.opacity(0.45)) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Text("🧹").font(.title3)
                                Text("データ").font(.subheadline.weight(.black))
                                    .foregroundStyle(Pop.ink)
                            }
                            Text("ストリーク・統計・バッジを全部初期化します (通知設定は残ります)")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Pop.inkSub)
                            PopButton(fill: Pop.danger, shadow: Pop.dangerShadow,
                                      action: { confirmingReset = true }) {
                                Text("進捗をリセット").font(.subheadline.weight(.heavy))
                            }
                        }
                    }

                    // About
                    PopCard(fill: Pop.surfaceCream,
                            border: Color(red: 0.78, green: 0.72, blue: 0.98)) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Text("ℹ️").font(.title3)
                                Text("AlgoBite について")
                                    .font(.subheadline.weight(.black))
                                    .foregroundStyle(Pop.ink)
                            }
                            Text("Version 1.1.0\n毎日ひと口、アルゴリズム。\nMade with 🍪 by ayu")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Pop.inkSub)
                            Divider()
                            // プライバシーポリシー（App Store 審査要件 5.1.1）
                            Link(destination: URL(string: "https://lifeistech.co.jp/privacy")!) {
                                HStack(spacing: 4) {
                                    Text("プライバシーポリシー")
                                        .font(.caption.weight(.semibold))
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption2)
                                }
                                .foregroundStyle(Pop.accent)
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("本当にリセットしますか？", isPresented: $confirmingReset, titleVisibility: .visible) {
            Button("リセットする", role: .destructive) {
                s.resetAll()
                resetDone = true
                Haptics.warning()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("ストリーク、解いた問題、バッジが全部消えます。元に戻せません。")
        }
        .overlay(alignment: .top) {
            if resetDone {
                Text("✓ リセットしたよ")
                    .font(.caption.weight(.heavy))
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Pop.surface, in: Capsule())
                    .overlay(Capsule().stroke(Pop.primary, lineWidth: 1.5))
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task {
                        try? await Task.sleep(nanoseconds: 1_800_000_000)
                        withAnimation { resetDone = false }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: resetDone)
    }

    private static func dateOf(hour: Int, minute: Int) -> Date {
        var c = DateComponents()
        c.hour = hour; c.minute = minute
        return Calendar.current.date(from: c) ?? Date()
    }
}

