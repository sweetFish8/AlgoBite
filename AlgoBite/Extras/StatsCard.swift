import SwiftUI
import Charts

// MARK: - Stats Card (③)

struct StatsCard: View {
    @ObservedObject var stats: StatsStore
    @ObservedObject var badges: BadgeStore

    var body: some View {
        PopCard(fill: Pop.surface,
                border: Color(red: 0.78, green: 0.82, blue: 0.99)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    CakeIcon(size: 22)
                    Text("これまでのおやつ")
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(Color(red: 0.19, green: 0.18, blue: 0.50))
                    Spacer()
                    Text("\(badges.unlocked.count)/\(BadgeCatalog.all.count) バッジ")
                        .font(.caption2.weight(.heavy))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color(red: 1.00, green: 0.95, blue: 0.74), in: Capsule())
                        .foregroundStyle(Pop.inkWarmSub)
                }
                HStack(spacing: 10) {
                    statCell(icon: AnyView(CookieIcon(size: 26)),
                             value: "\(stats.totalSolved)", label: "パズル")
                    statCell(icon: AnyView(CupcakeIcon(size: 26)),
                             value: "\(stats.reorderClears)", label: "並べ替え")
                    if let t = stats.topTopic {
                        statCell(icon: AnyView(ChocolateIcon(size: 26)),
                                 value: "\(t.count)",
                                 label: String(t.topic.prefix(5)))
                    } else {
                        statCell(icon: AnyView(ChocolateIcon(size: 26)),
                                 value: "-", label: "得意")
                    }
                }
                heatmap
            }
        }
    }

    private func statCell(icon: AnyView, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            icon
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.20))
            Text(label)
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(Pop.inkSub)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(red: 0.96, green: 0.97, blue: 1.00),
                    in: RoundedRectangle(cornerRadius: 10))
    }

    private var heatmap: some View {
        // 過去28日 (4週) を 7列 × 4行 で表示
        let days = stats.activity(days: 28)   // 古い方から
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("直近4週のアクティビティ")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(Pop.inkSub)
                Spacer()
                Text("4週前 → 今日")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Pop.inkSub.opacity(0.7))
            }
            // 4 rows × 7 columns; row 0 = 4週前
            VStack(spacing: 4) {
                ForEach(0..<4) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<7) { col in
                            let idx = row * 7 + col
                            let on = idx < days.count ? days[idx] : false
                            RoundedRectangle(cornerRadius: 4)
                                .fill(on
                                      ? Color(red: 0.13, green: 0.77, blue: 0.37)
                                      : Color(red: 0.93, green: 0.94, blue: 0.96))
                                .frame(height: 16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(on
                                                ? Color(red: 0.08, green: 0.55, blue: 0.27)
                                                : Color(red: 0.85, green: 0.87, blue: 0.90),
                                                lineWidth: 0.8)
                                )
                        }
                    }
                }
            }
        }
    }
}

