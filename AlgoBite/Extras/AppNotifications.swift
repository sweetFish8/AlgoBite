import SwiftUI
import Charts

// MARK: - Notifications (⑧)

enum AppNotifications {
    static let dailyId = "algobite.daily"
    static let askedKey = "algobite.notifications.asked"
    static let enabledKey = "algobite.notifications.enabled"

    static func requestAuthorizationIfNeeded() {
        let d = appDefaults
        guard !d.bool(forKey: askedKey) else {
            // 既に確認済 → 有効ならスケジュール
            if d.bool(forKey: enabledKey) { scheduleDaily() }
            return
        }
        d.set(true, forKey: askedKey)

        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                d.set(granted, forKey: enabledKey)
                if granted { scheduleDaily() }
            }
    }

    static func scheduleDaily(hour: Int = 20, minute: Int = 0) {
        let c = UNUserNotificationCenter.current()
        c.removePendingNotificationRequests(withIdentifiers: [dailyId])

        let content = UNMutableNotificationContent()
        content.title = "今日のひと口、できてるよ 🍪"
        content.body  = "AlgoBiteで1問解いてリフレッシュ！"
        content.sound = .default

        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let req = UNNotificationRequest(identifier: dailyId, content: content, trigger: trigger)
        c.add(req, withCompletionHandler: nil)
    }
}

