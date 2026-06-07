import SwiftUI
import Charts

// MARK: - Badges Card (④)

struct BadgesCard: View {
    @ObservedObject var badges: BadgeStore
    @State private var showDetails = false

    var body: some View {
        PopCard(fill: Pop.surfaceCream,
                border: Color(red: 0.99, green: 0.79, blue: 0.18)) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Text("🏆").font(.title3)
                    Text("バッジコレクション")
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(Pop.inkWarm)
                    Spacer()
                    Button { showDetails = true } label: {
                        Text("詳細")
                            .font(.caption2.weight(.heavy))
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color(red: 1.00, green: 0.95, blue: 0.74), in: Capsule())
                            .foregroundStyle(Pop.inkWarmSub)
                    }
                    .buttonStyle(.plain)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(BadgeCatalog.all) { b in
                            badgeChip(b, unlocked: badges.unlocked.contains(b.id))
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showDetails) {
            BadgeDetailSheet(badges: badges)
                .presentationDetents([.large])
                .frame(maxWidth: 640)
        }
    }

    private func badgeChip(_ b: Badge, unlocked: Bool) -> some View {
        VStack(spacing: 3) {
            Text(b.emoji)
                .font(.system(size: 28))
                .opacity(unlocked ? 1 : 0.25)
                .saturation(unlocked ? 1 : 0)
            Text(b.title)
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(unlocked
                                 ? Color(red: 0.49, green: 0.18, blue: 0.07)
                                 : Pop.inkSub.opacity(0.6))
                .lineLimit(1)
        }
        .frame(width: 64, height: 64)
        .background(unlocked
                    ? Color(red: 1.00, green: 0.95, blue: 0.78)
                    : Color(red: 0.95, green: 0.95, blue: 0.97),
                    in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(unlocked
                    ? Color(red: 0.99, green: 0.79, blue: 0.18)
                    : Color(red: 0.85, green: 0.87, blue: 0.90),
                    lineWidth: 1.4))
    }
}

struct BadgeDetailSheet: View {
    @ObservedObject var badges: BadgeStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                    ForEach(BadgeCatalog.all) { b in
                        let unlocked = badges.unlocked.contains(b.id)
                        VStack(spacing: 8) {
                            Text(b.emoji)
                                .font(.system(size: 44))
                                .opacity(unlocked ? 1 : 0.25)
                                .saturation(unlocked ? 1 : 0)
                            Text(b.title)
                                .font(.subheadline.weight(.black))
                                .foregroundStyle(Pop.ink)
                            Text(b.description)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Pop.inkSub)
                                .multilineTextAlignment(.center)
                            Text(unlocked ? "✅ 解放済み" : "🔒 未解放")
                                .font(.caption2.weight(.heavy))
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(unlocked
                                            ? Color(red: 0.73, green: 0.97, blue: 0.82)
                                            : Color(red: 0.93, green: 0.94, blue: 0.96),
                                            in: Capsule())
                                .foregroundStyle(unlocked
                                                 ? Color(red: 0.08, green: 0.32, blue: 0.18)
                                                 : Pop.inkSub)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(.white, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(red: 0.93, green: 0.91, blue: 0.97), lineWidth: 1.2))
                    }
                }
                .padding(16)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .background(LinearGradient(colors: [Pop.bgNeutralTop, Pop.bgNeutralBottom],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea())
            .navigationTitle("バッジ一覧")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .font(.subheadline.weight(.heavy))
                }
            }
        }
    }
}

/// バッジ解放の "ぱっと出るおめでとう" オーバーレイ
struct BadgeUnlockOverlay: View {
    let badge: Badge
    let onDismiss: () -> Void

    // 解放アニメーション用の駆動 State
    @State private var burst = false       // confetti 飛散 + emoji 拡大
    @State private var sparkleAngle = 0.0  // 星マーク回転
    @State private var emojiBounce = false // emoji の上下バウンス

    var body: some View {
        ZStack {
            // 背景タップで閉じる
            Color.black.opacity(0.35).ignoresSafeArea()
                .onTapGesture { onDismiss() }

            // 紙吹雪は最背面 (カードに被らないように位置調整)
            ConfettiBurst(active: burst)
                .allowsHitTesting(false)

            VStack(spacing: 14) {
                Text("🎉 バッジ解放！")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Pop.inkWarm)

                // 中央 emoji + 周囲スパークル
                ZStack {
                    // 周囲を回るキラキラ (4 個)
                    ForEach(0..<4) { i in
                        let baseAngle = Double(i) * 90.0
                        Text("✨")
                            .font(.system(size: 22))
                            .offset(y: -56)
                            .rotationEffect(.degrees(baseAngle + sparkleAngle))
                            .opacity(burst ? 0.9 : 0.0)
                    }
                    Text(badge.emoji)
                        .font(.system(size: 72))
                        .scaleEffect(burst ? 1.0 : 0.4)
                        .offset(y: emojiBounce ? -4 : 4)
                }
                .frame(width: 130, height: 130)

                Text(badge.title)
                    .font(.title2.weight(.black))
                    .foregroundStyle(Pop.ink)
                Text(badge.description)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Pop.inkSub)
                    .multilineTextAlignment(.center)
                PopButton(fill: Pop.accent, shadow: Pop.accentShadow, action: onDismiss) {
                    Text("閉じる").font(.subheadline.weight(.heavy))
                }
            }
            .padding(24)
            .frame(maxWidth: 320)
            .background(Color(red: 1.00, green: 0.97, blue: 0.93),
                        in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22)
                .stroke(Color(red: 0.99, green: 0.79, blue: 0.18), lineWidth: 2.5))
            .shadow(color: .black.opacity(0.25), radius: 18, y: 6)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.85)))
        .onAppear {
            // emoji 拡大 + 紙吹雪トリガ
            withAnimation(.spring(response: 0.55, dampingFraction: 0.55).delay(0.05)) {
                burst = true
            }
            // emoji を上下にゆらゆら
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
                            .delay(0.5)) {
                emojiBounce = true
            }
            // スパークルを 1 周だけ回す
            withAnimation(.easeOut(duration: 2.0).delay(0.1)) {
                sparkleAngle = 360
            }
        }
    }
}

/// バッジ解放時の紙吹雪。中心から放射状に 30 個の小片が広がる。
/// 各小片は (色, 角度, 距離) を持ち、active=true で外側に展開する。
struct ConfettiBurst: View {
    let active: Bool

    private struct Piece {
        let color: Color
        let angle: Double   // 度
        let radius: CGFloat // 飛距離
        let size: CGFloat
        let kind: Int       // 0=丸 1=三角 2=四角
    }

    /// 計算済みの 30 個のパーティクル。色と角度を分散させる。
    private static let pieces: [Piece] = {
        let palette: [Color] = [
            Color(red: 0.99, green: 0.79, blue: 0.18),   // 黄
            Color(red: 0.94, green: 0.27, blue: 0.27),   // 赤
            Color(red: 0.35, green: 0.80, blue: 0.01),   // 緑
            Color(red: 0.39, green: 0.40, blue: 0.95),   // 紫
            Color(red: 1.00, green: 0.48, blue: 0.62),   // ピンク
        ]
        return (0..<30).map { i in
            let baseAngle = Double(i) * (360.0 / 30.0)
            let jitter    = Double((i * 73) % 30) - 15        // -15..15 度
            let radius    = CGFloat(120 + (i * 47) % 80)      // 120..200
            let size      = CGFloat(6 + (i % 4) * 2)          // 6..12
            return Piece(color: palette[i % palette.count],
                         angle: baseAngle + jitter,
                         radius: radius,
                         size: size,
                         kind: i % 3)
        }
    }()

    var body: some View {
        ZStack {
            ForEach(Self.pieces.indices, id: \.self) { i in
                pieceView(at: i)
            }
        }
        .frame(width: 1, height: 1)
    }

    @ViewBuilder
    private func pieceView(at i: Int) -> some View {
        let p = Self.pieces[i]
        Group {
            switch p.kind {
            case 0: Circle().fill(p.color)
            case 1: Triangle().fill(p.color)
            default: Rectangle().fill(p.color)
            }
        }
        .frame(width: p.size, height: p.size)
        .offset(x: active ? CGFloat(cos(p.angle * .pi / 180)) * p.radius : 0,
                y: active ? CGFloat(sin(p.angle * .pi / 180)) * p.radius : 0)
        .opacity(active ? 0.0 : 1.0)
        .scaleEffect(active ? 0.6 : 0.0)
        .rotationEffect(.degrees(active ? Double(i * 23) : 0))
        .animation(.easeOut(duration: 1.4).delay(Double(i) * 0.005), value: active)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

