//
//  AlgoBiteWidget.swift
//  AlgoBiteWidget
//
//  Small/Medium ウィジェット — 今日のひと口 + ストリーク
//

import WidgetKit
import SwiftUI

// MARK: - 共有 UserDefaults (App Group)

/// App Group 経由でメインアプリと共有する UserDefaults。
/// 環境が無い時は fallback として .standard を返す。
private let sharedDefaults: UserDefaults = {
    UserDefaults(suiteName: "group.group.app.Goto.Sakana.AlgoBite") ?? .standard
}()

// MARK: - Entry

struct AlgoBiteEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let isCompletedToday: Bool
    let totalSolved: Int
    let dayNumber: Int
}

// MARK: - Provider

struct AlgoBiteProvider: TimelineProvider {
    func placeholder(in context: Context) -> AlgoBiteEntry {
        AlgoBiteEntry(date: .now, streak: 3, isCompletedToday: false,
                      totalSolved: 12, dayNumber: 4)
    }

    func getSnapshot(in context: Context, completion: @escaping (AlgoBiteEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AlgoBiteEntry>) -> Void) {
        // 1時間に1回更新 + 翌日0時に必ず再評価。
        let now = Date()
        let cal = Calendar.current
        let tomorrow = cal.nextDate(after: now,
                                    matching: DateComponents(hour: 0, minute: 0),
                                    matchingPolicy: .nextTime) ?? now.addingTimeInterval(3600 * 6)

        var entries: [AlgoBiteEntry] = [currentEntry()]
        if let inAnHour = cal.date(byAdding: .hour, value: 1, to: now) {
            entries.append(currentEntry(at: inAnHour))
        }
        completion(Timeline(entries: entries, policy: .after(tomorrow)))
    }

    private func currentEntry(at date: Date = .now) -> AlgoBiteEntry {
        let streak = sharedDefaults.integer(forKey: "algobite.streak")
        let total  = sharedDefaults.integer(forKey: "algobite.stats.totalSolved")
        let last   = sharedDefaults.string(forKey: "algobite.lastSolvedDate")
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        let today = f.string(from: date)
        let completed = last == today

        // Day N: アプリ初回起動からの日数 ではなく、シンプルにストリーク+1で疑似表現
        let dayN = max(1, streak + (completed ? 0 : 1))

        return AlgoBiteEntry(date: date, streak: streak,
                             isCompletedToday: completed,
                             totalSolved: total, dayNumber: dayN)
    }
}

// MARK: - View

struct AlgoBiteWidgetView: View {
    @Environment(\.widgetFamily) var family
    var entry: AlgoBiteEntry

    var body: some View {
        switch family {
        case .systemSmall:  small
        case .systemMedium: medium
        default:            small
        }
    }

    private var bgGradient: LinearGradient {
        if entry.isCompletedToday {
            return LinearGradient(colors: [
                Color(red: 0.86, green: 0.99, blue: 0.91),
                Color(red: 0.73, green: 0.97, blue: 0.82),
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        return LinearGradient(colors: [
            Color(red: 1.00, green: 0.97, blue: 0.93),
            Color(red: 1.00, green: 0.89, blue: 0.89),
        ], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var backgroundWithDecorations: some View {
        ZStack {
            bgGradient
            GeometryReader { geo in
                Text("🍩").font(.system(size: 44)).rotationEffect(.degrees(-15))
                    .opacity(0.15)
                    .position(x: geo.size.width * 0.85, y: geo.size.height * 0.1)
                Text("🍫").font(.system(size: 36)).rotationEffect(.degrees(20))
                    .opacity(0.12)
                    .position(x: geo.size.width * 0.15, y: geo.size.height * 0.85)
            }
        }
    }

    private var ink: Color { Color(red: 0.49, green: 0.18, blue: 0.07) }
    private var subInk: Color { Color(red: 0.60, green: 0.20, blue: 0.07) }

    // 小サイズ
    private var small: some View {
        ZStack {
            backgroundWithDecorations
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("🍪").font(.system(size: 22))
                    Text("AlgoBite")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(ink)
                    Spacer(minLength: 0)
                }
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("🔥").font(.system(size: 18))
                    Text("\(entry.streak)")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(ink)
                    Text("日")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(subInk)
                }
                statusBadge
                Spacer(minLength: 0)
                Text("Day \(entry.dayNumber)")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(subInk)
            }
            .padding(14)
        }
    }

    // 中サイズ
    private var medium: some View {
        ZStack {
            backgroundWithDecorations
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Text("🍪").font(.system(size: 22))
                        Text("AlgoBite")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundStyle(ink)
                    }
                    Text(entry.isCompletedToday
                         ? "今日のひと口、ごちそうさま！"
                         : "今日のひと口できてるよ")
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(ink)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                    statusBadge
                }
                Spacer(minLength: 0)
                VStack(spacing: 4) {
                    Text("🔥").font(.system(size: 22))
                    Text("\(entry.streak)")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(ink)
                    Text("日連続")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(subInk)
                }
                .frame(width: 90)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.75),
                            in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.08), radius: 4, y: 2)
            }
            .padding(14)
        }
    }

    private var statusBadge: some View {
        let (bg, fg, txt): (Color, Color, String) = entry.isCompletedToday
            ? (Color(red: 0.13, green: 0.77, blue: 0.37),
               .white, "✓ クリア済")
            : (Color(red: 0.99, green: 0.79, blue: 0.18),
               Color(red: 0.49, green: 0.18, blue: 0.07), "▶ チャレンジ")
        return Text(txt)
            .font(.system(size: 10, weight: .heavy))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(bg, in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1))
            .shadow(color: bg.opacity(0.5), radius: 3, y: 2)
            .foregroundStyle(fg)
    }
}

// MARK: - Widget

struct AlgoBiteWidget: Widget {
    let kind = "AlgoBiteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AlgoBiteProvider()) { entry in
            if #available(iOS 17.0, *) {
                AlgoBiteWidgetView(entry: entry)
                    .containerBackground(for: .widget) {
                        Color.clear
                    }
            } else {
                AlgoBiteWidgetView(entry: entry)
            }
        }
        .configurationDisplayName("AlgoBite")
        .description("今日のひと口とストリークを表示します🍪")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
