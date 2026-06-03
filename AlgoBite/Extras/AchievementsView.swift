import SwiftUI
import Charts

// MARK: - Achievements Screen — 実績まとめ画面

/// ヘッダー右上から開く実績画面。これまでの統計とバッジコレクションを 1 画面に集約。
struct AchievementsView: View {
    @ObservedObject var stats: StatsStore
    @ObservedObject var badges: BadgeStore

    var body: some View {
        ZStack {
            LinearGradient(colors: [Pop.bgNeutralTop, Pop.bgNeutralBottom],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    // ヘッダー：アイコン + サマリーテキスト
                    HStack(spacing: 12) {
                        TrophyIcon(size: 56)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("これまでの記録")
                                .font(.headline.weight(.black))
                                .foregroundStyle(Pop.ink)
                            Text("ちょっとずつでも、積み重ねが甘い")
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(Pop.inkSub)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    StatsCard(stats: stats, badges: badges)
                    BadgesCard(badges: badges)
                }
                .padding(16)
            }
        }
        .navigationTitle("実績")
        .navigationBarTitleDisplayMode(.inline)
    }
}

