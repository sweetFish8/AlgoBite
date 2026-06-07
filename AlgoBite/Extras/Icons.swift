import SwiftUI
import Charts

// MARK: - Sweet Illustrations (ポップなお菓子イラスト)
// 絵文字ではなく SwiftUI Shape で描いた可愛いお菓子アイコン群。

/// チョコチップクッキー
struct CookieIcon: View {
    var size: CGFloat = 44
    var body: some View {
        ZStack {
            // 生地
            Circle()
                .fill(LinearGradient(colors: [
                    Color(red: 0.95, green: 0.78, blue: 0.50),
                    Color(red: 0.78, green: 0.55, blue: 0.27)
                ], startPoint: .topLeading, endPoint: .bottomTrailing))
            // 縁
            Circle()
                .strokeBorder(Color(red: 0.55, green: 0.34, blue: 0.10),
                              lineWidth: size * 0.045)
            // ハイライト
            Ellipse()
                .fill(Color.white.opacity(0.35))
                .frame(width: size * 0.30, height: size * 0.14)
                .offset(x: -size * 0.16, y: -size * 0.24)
            // チョコチップ
            chip(dx: -0.22, dy: -0.18, scale: 0.16)
            chip(dx:  0.20, dy: -0.10, scale: 0.13)
            chip(dx: -0.05, dy:  0.16, scale: 0.18)
            chip(dx:  0.22, dy:  0.20, scale: 0.12)
            chip(dx: -0.24, dy:  0.10, scale: 0.10)
        }
        .frame(width: size, height: size)
    }
    private func chip(dx: CGFloat, dy: CGFloat, scale: CGFloat) -> some View {
        Circle()
            .fill(Color(red: 0.30, green: 0.16, blue: 0.06))
            .frame(width: size * scale, height: size * scale)
            .offset(x: size * dx, y: size * dy)
    }
}

/// ピンクグレーズドーナツ + スプリンクル
struct DonutIcon: View {
    var size: CGFloat = 44
    var body: some View {
        ZStack {
            // 生地（外円）
            Circle()
                .fill(Color(red: 0.96, green: 0.80, blue: 0.55))
            // ピンクのアイシング
            Circle()
                .fill(LinearGradient(colors: [
                    Color(red: 1.00, green: 0.65, blue: 0.75),
                    Color(red: 1.00, green: 0.48, blue: 0.62)
                ], startPoint: .top, endPoint: .bottom))
                .scaleEffect(0.93)
            // アイシングの縁の波(下端)
            Circle()
                .fill(Color(red: 0.96, green: 0.80, blue: 0.55))
                .scaleEffect(0.86)
                .offset(y: size * 0.06)
            Circle()
                .fill(LinearGradient(colors: [
                    Color(red: 1.00, green: 0.65, blue: 0.75),
                    Color(red: 1.00, green: 0.48, blue: 0.62)
                ], startPoint: .top, endPoint: .bottom))
                .scaleEffect(0.86)
            // スプリンクル
            ForEach(Array(zip(0..<10, sprinklePositions)), id: \.0) { idx, p in
                Capsule()
                    .fill(sprinkleColors[idx % sprinkleColors.count])
                    .frame(width: size * 0.06, height: size * 0.14)
                    .rotationEffect(.degrees(p.angle))
                    .offset(x: size * p.dx, y: size * p.dy)
            }
            // 穴
            Circle()
                .fill(Color(red: 1.00, green: 0.97, blue: 0.93))
                .frame(width: size * 0.32, height: size * 0.32)
            Circle()
                .strokeBorder(Color(red: 0.83, green: 0.62, blue: 0.42),
                              lineWidth: size * 0.025)
                .frame(width: size * 0.32, height: size * 0.32)
        }
        .frame(width: size, height: size)
    }
    private var sprinkleColors: [Color] {
        [
            Color(red: 0.40, green: 0.78, blue: 0.92), // sky
            Color(red: 0.99, green: 0.85, blue: 0.30), // yellow
            Color(red: 0.62, green: 0.91, blue: 0.55), // mint
            Color(red: 1.00, green: 1.00, blue: 1.00), // white
            Color(red: 0.65, green: 0.50, blue: 0.95), // purple
        ]
    }
    private var sprinklePositions: [(dx: CGFloat, dy: CGFloat, angle: Double)] {
        [
            (-0.25, -0.05,  20),
            ( 0.05, -0.27, -30),
            ( 0.26, -0.08,  45),
            ( 0.22,  0.18,  10),
            ( 0.00,  0.30, -15),
            (-0.22,  0.18,  60),
            (-0.05, -0.18,  80),
            ( 0.13, -0.22,  -5),
            (-0.18,  0.05,  35),
            ( 0.18, -0.18, -55),
        ]
    }
}

/// カップケーキ (クリーム + ラッパー + チェリー)
struct CupcakeIcon: View {
    var size: CGFloat = 44
    var body: some View {
        ZStack {
            // ラッパー (台形)
            CupcakeWrapper()
                .fill(LinearGradient(colors: [
                    Color(red: 0.92, green: 0.38, blue: 0.50),
                    Color(red: 0.75, green: 0.20, blue: 0.32)
                ], startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.72, height: size * 0.36)
                .offset(y: size * 0.20)
            // ラッパーの縦縞
            ForEach(0..<5, id: \.self) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: size * 0.025, height: size * 0.34)
                    .offset(x: size * (-0.24 + CGFloat(i) * 0.12), y: size * 0.21)
            }
            // クリーム (3層の渦)
            CupcakeCream()
                .fill(LinearGradient(colors: [
                    Color(red: 1.00, green: 0.92, blue: 0.87),
                    Color(red: 0.94, green: 0.78, blue: 0.72)
                ], startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.78, height: size * 0.50)
                .offset(y: -size * 0.10)
            // チェリー
            Circle()
                .fill(LinearGradient(colors: [
                    Color(red: 0.95, green: 0.30, blue: 0.30),
                    Color(red: 0.78, green: 0.10, blue: 0.18)
                ], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size * 0.20, height: size * 0.20)
                .offset(y: -size * 0.33)
            // チェリーのハイライト
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: size * 0.05, height: size * 0.05)
                .offset(x: -size * 0.03, y: -size * 0.36)
            // チェリーの茎
            Capsule()
                .fill(Color(red: 0.30, green: 0.55, blue: 0.18))
                .frame(width: size * 0.025, height: size * 0.10)
                .rotationEffect(.degrees(20))
                .offset(x: size * 0.02, y: -size * 0.42)
        }
        .frame(width: size, height: size)
    }
}

/// カップケーキの台形ラッパー
struct CupcakeWrapper: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let inset = rect.width * 0.10
        p.move(to: CGPoint(x: rect.minX + inset, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

/// クリームのドーム（半円＋小さなウェーブ）
struct CupcakeCream: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        // ドーム
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control1: CGPoint(x: rect.minX, y: rect.minY - rect.height * 0.05),
            control2: CGPoint(x: rect.maxX, y: rect.minY - rect.height * 0.05)
        )
        p.closeSubpath()
        return p
    }
}

/// 板チョコ (3x4 グリッド)
struct ChocolateIcon: View {
    var size: CGFloat = 44
    var body: some View {
        ZStack {
            // 外殻 + 包み感
            RoundedRectangle(cornerRadius: size * 0.10)
                .fill(LinearGradient(colors: [
                    Color(red: 0.55, green: 0.32, blue: 0.16),
                    Color(red: 0.38, green: 0.18, blue: 0.08)
                ], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size * 0.88, height: size * 0.80)
            RoundedRectangle(cornerRadius: size * 0.10)
                .strokeBorder(Color(red: 0.28, green: 0.13, blue: 0.05),
                              lineWidth: size * 0.04)
                .frame(width: size * 0.88, height: size * 0.80)
            // 12 ピースのレリーフ
            VStack(spacing: size * 0.025) {
                ForEach(0..<3, id: \.self) { _ in
                    HStack(spacing: size * 0.025) {
                        ForEach(0..<4, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: size * 0.03)
                                .fill(LinearGradient(colors: [
                                    Color(red: 0.65, green: 0.38, blue: 0.18),
                                    Color(red: 0.42, green: 0.20, blue: 0.10)
                                ], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .overlay(RoundedRectangle(cornerRadius: size * 0.03)
                                    .stroke(Color(red: 0.28, green: 0.13, blue: 0.05).opacity(0.6),
                                            lineWidth: size * 0.012))
                        }
                    }
                }
            }
            .frame(width: size * 0.78, height: size * 0.70)
            // 角のハイライト
            RoundedRectangle(cornerRadius: size * 0.04)
                .fill(Color.white.opacity(0.18))
                .frame(width: size * 0.22, height: size * 0.06)
                .offset(x: -size * 0.20, y: -size * 0.30)
        }
        .frame(width: size, height: size)
    }
}

/// ホールケーキ (3層ショートケーキ)
struct CakeIcon: View {
    var size: CGFloat = 44
    var body: some View {
        ZStack {
            // 下層 (スポンジ)
            RoundedRectangle(cornerRadius: size * 0.06)
                .fill(Color(red: 0.99, green: 0.85, blue: 0.62))
                .frame(width: size * 0.80, height: size * 0.20)
                .offset(y: size * 0.22)
            // クリーム層
            RoundedRectangle(cornerRadius: size * 0.04)
                .fill(Color.white)
                .frame(width: size * 0.80, height: size * 0.06)
                .offset(y: size * 0.10)
            // 上層 (スポンジ)
            RoundedRectangle(cornerRadius: size * 0.06)
                .fill(Color(red: 0.99, green: 0.85, blue: 0.62))
                .frame(width: size * 0.80, height: size * 0.18)
                .offset(y: -size * 0.02)
            // 上のクリームドーム
            Ellipse()
                .fill(Color.white)
                .frame(width: size * 0.80, height: size * 0.16)
                .offset(y: -size * 0.16)
            // イチゴ
            HStack(spacing: size * 0.04) {
                ForEach(0..<3, id: \.self) { _ in
                    StrawberryIcon(size: size * 0.24)
                }
            }
            .offset(y: -size * 0.30)
        }
        .frame(width: size, height: size)
    }
}

/// ストリーク用：3 段に積まれたクッキータワー
struct CookieStackIcon: View {
    var size: CGFloat = 36
    var body: some View {
        ZStack {
            // 影
            Ellipse()
                .fill(Color.black.opacity(0.18))
                .frame(width: size * 0.75, height: size * 0.10)
                .offset(y: size * 0.46)
            // 下段クッキー
            tier(yOffset: 0.22, scale: 1.00, tint: 0)
            // 中段
            tier(yOffset: -0.04, scale: 0.85, tint: 1)
            // 上段
            tier(yOffset: -0.30, scale: 0.66, tint: 2)
            // てっぺんに星
            Path { p in
                let r = size * 0.10
                let cy = -size * 0.46
                for i in 0..<5 {
                    let a = Double(i) * .pi * 2 / 5 - .pi / 2
                    let pt = CGPoint(x: r * cos(a), y: cy + r * sin(a))
                    if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
                    let a2 = a + .pi / 5
                    p.addLine(to: CGPoint(x: r * 0.45 * cos(a2),
                                          y: cy + r * 0.45 * sin(a2)))
                }
                p.closeSubpath()
            }
            .fill(Color(red: 0.99, green: 0.78, blue: 0.18))
            .frame(width: size, height: size)
        }
        .frame(width: size, height: size)
    }
    private func tier(yOffset: CGFloat, scale: CGFloat, tint: Int) -> some View {
        let palette: [Color] = [
            Color(red: 0.90, green: 0.70, blue: 0.40),  // 一番下：濃い焼き色
            Color(red: 0.94, green: 0.76, blue: 0.46),
            Color(red: 0.97, green: 0.82, blue: 0.55),  // 一番上：ふんわり
        ]
        return ZStack {
            Ellipse()
                .fill(palette[tint])
                .frame(width: size * scale * 0.85, height: size * scale * 0.30)
            // チョコチップ点
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color(red: 0.30, green: 0.16, blue: 0.06))
                    .frame(width: size * scale * 0.07, height: size * scale * 0.07)
                    .offset(x: size * scale * (-0.20 + 0.20 * CGFloat(i)),
                            y: 0)
            }
        }
        .offset(y: size * yOffset)
    }
}

/// トロフィー (実績ボタン用)
struct TrophyIcon: View {
    var size: CGFloat = 28
    var body: some View {
        ZStack {
            // 取っ手 (左右)
            ForEach([-1, 1] as [CGFloat], id: \.self) { side in
                Path { p in
                    let w = size, h = size
                    p.addArc(center: CGPoint(x: w * 0.50 + side * w * 0.30, y: h * 0.40),
                             radius: w * 0.14,
                             startAngle: .degrees(side > 0 ? -90 : 90),
                             endAngle: .degrees(side > 0 ? 90 : 270),
                             clockwise: false)
                }
                .stroke(Color(red: 0.85, green: 0.60, blue: 0.10), lineWidth: size * 0.07)
            }
            // カップ部 (台形を曲げた形)
            Path { p in
                let w = size
                p.move(to: CGPoint(x: w * 0.20, y: w * 0.18))
                p.addLine(to: CGPoint(x: w * 0.80, y: w * 0.18))
                p.addLine(to: CGPoint(x: w * 0.72, y: w * 0.55))
                p.addCurve(
                    to: CGPoint(x: w * 0.28, y: w * 0.55),
                    control1: CGPoint(x: w * 0.65, y: w * 0.70),
                    control2: CGPoint(x: w * 0.35, y: w * 0.70))
                p.closeSubpath()
            }
            .fill(LinearGradient(colors: [
                Color(red: 1.00, green: 0.86, blue: 0.30),
                Color(red: 0.85, green: 0.58, blue: 0.10)
            ], startPoint: .top, endPoint: .bottom))
            .overlay(
                Path { p in
                    let w = size
                    p.move(to: CGPoint(x: w * 0.20, y: w * 0.18))
                    p.addLine(to: CGPoint(x: w * 0.80, y: w * 0.18))
                    p.addLine(to: CGPoint(x: w * 0.72, y: w * 0.55))
                    p.addCurve(
                        to: CGPoint(x: w * 0.28, y: w * 0.55),
                        control1: CGPoint(x: w * 0.65, y: w * 0.70),
                        control2: CGPoint(x: w * 0.35, y: w * 0.70))
                    p.closeSubpath()
                }
                .stroke(Color(red: 0.65, green: 0.40, blue: 0.05), lineWidth: size * 0.04)
            )
            // 中央の星
            Image(systemName: "star.fill")
                .font(.system(size: size * 0.24, weight: .black))
                .foregroundStyle(Color(red: 1.00, green: 0.95, blue: 0.70))
                .offset(y: -size * 0.05)
            // ステム
            Rectangle()
                .fill(LinearGradient(colors: [
                    Color(red: 0.90, green: 0.65, blue: 0.10),
                    Color(red: 0.70, green: 0.45, blue: 0.05)
                ], startPoint: .leading, endPoint: .trailing))
                .frame(width: size * 0.20, height: size * 0.14)
                .offset(y: size * 0.30)
            // ベース (土台)
            RoundedRectangle(cornerRadius: size * 0.05)
                .fill(LinearGradient(colors: [
                    Color(red: 0.65, green: 0.42, blue: 0.10),
                    Color(red: 0.45, green: 0.28, blue: 0.05)
                ], startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.55, height: size * 0.12)
                .offset(y: size * 0.42)
        }
        .frame(width: size, height: size)
    }
}

/// いちごアイコン (ロールケーキの上に乗る)
struct StrawberryIcon: View {
    var size: CGFloat = 22
    var body: some View {
        ZStack {
            // 葉っぱ (緑のヘタ、ジグザグ)
            Path { p in
                let w = size, h = size * 0.30
                p.move(to: CGPoint(x: w * 0.50, y: 0))
                p.addLine(to: CGPoint(x: w * 0.15, y: h * 0.55))
                p.addLine(to: CGPoint(x: w * 0.32, y: h * 0.55))
                p.addLine(to: CGPoint(x: w * 0.25, y: h))
                p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.75))
                p.addLine(to: CGPoint(x: w * 0.75, y: h))
                p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.55))
                p.addLine(to: CGPoint(x: w * 0.85, y: h * 0.55))
                p.closeSubpath()
            }
            .fill(LinearGradient(colors: [
                Color(red: 0.35, green: 0.70, blue: 0.35),
                Color(red: 0.22, green: 0.52, blue: 0.25)
            ], startPoint: .top, endPoint: .bottom))
            .frame(width: size, height: size * 0.30)
            .offset(y: -size * 0.32)

            // 本体 (赤い苺)
            Path { p in
                let w = size, h = size
                p.move(to: CGPoint(x: w * 0.50, y: h * 0.12))
                p.addCurve(
                    to: CGPoint(x: w * 0.10, y: h * 0.45),
                    control1: CGPoint(x: w * 0.10, y: h * 0.12),
                    control2: CGPoint(x: w * 0.05, y: h * 0.30))
                p.addCurve(
                    to: CGPoint(x: w * 0.50, y: h * 0.98),
                    control1: CGPoint(x: w * 0.10, y: h * 0.80),
                    control2: CGPoint(x: w * 0.30, y: h * 0.98))
                p.addCurve(
                    to: CGPoint(x: w * 0.90, y: h * 0.45),
                    control1: CGPoint(x: w * 0.70, y: h * 0.98),
                    control2: CGPoint(x: w * 0.90, y: h * 0.80))
                p.addCurve(
                    to: CGPoint(x: w * 0.50, y: h * 0.12),
                    control1: CGPoint(x: w * 0.95, y: h * 0.30),
                    control2: CGPoint(x: w * 0.90, y: h * 0.12))
                p.closeSubpath()
            }
            .fill(LinearGradient(colors: [
                Color(red: 0.96, green: 0.30, blue: 0.30),
                Color(red: 0.76, green: 0.10, blue: 0.18)
            ], startPoint: .topLeading, endPoint: .bottomTrailing))

            // 種 (黄色いつぶつぶ) — オフセットは "frame 中心" からの相対値
            // (path は y=0.12〜0.98 で本体を描いてるので、種は -0.25〜+0.30 に収める)
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(Color(red: 1.0, green: 0.88, blue: 0.40))
                    .frame(width: size * 0.08, height: size * 0.08)
                    .offset(
                        x: size * [-0.15,  0.15,  0.00, -0.18,  0.18,  0.00][i],
                        y: size * [-0.18, -0.18, -0.05,  0.08,  0.08,  0.22][i]
                    )
            }

            // ハイライト
            Ellipse()
                .fill(Color.white.opacity(0.55))
                .frame(width: size * 0.18, height: size * 0.10)
                .offset(x: -size * 0.18, y: -size * 0.10)
        }
        .frame(width: size, height: size)
    }
}

/// ロールケーキの上に乗せる用 — ヘタを外して先端を上に向けた苺
struct StrawberryTipUp: View {
    var size: CGFloat = 22
    var body: some View {
        ZStack {
            // 本体 (Tip up = 先端が上、幅広い側が下)
            Path { p in
                let w = size, h = size
                // 上の先端
                p.move(to: CGPoint(x: w * 0.50, y: h * 0.02))
                // 右側を膨らませながら下へ
                p.addCurve(
                    to: CGPoint(x: w * 0.92, y: h * 0.58),
                    control1: CGPoint(x: w * 0.62, y: h * 0.10),
                    control2: CGPoint(x: w * 0.95, y: h * 0.30))
                // 右下の丸み
                p.addCurve(
                    to: CGPoint(x: w * 0.50, y: h * 0.95),
                    control1: CGPoint(x: w * 0.90, y: h * 0.80),
                    control2: CGPoint(x: w * 0.72, y: h * 0.95))
                // 左下の丸み
                p.addCurve(
                    to: CGPoint(x: w * 0.08, y: h * 0.58),
                    control1: CGPoint(x: w * 0.28, y: h * 0.95),
                    control2: CGPoint(x: w * 0.10, y: h * 0.80))
                // 左を膨らませながら上へ戻って先端
                p.addCurve(
                    to: CGPoint(x: w * 0.50, y: h * 0.02),
                    control1: CGPoint(x: w * 0.05, y: h * 0.30),
                    control2: CGPoint(x: w * 0.38, y: h * 0.10))
                p.closeSubpath()
            }
            .fill(LinearGradient(colors: [
                Color(red: 0.95, green: 0.30, blue: 0.30),
                Color(red: 0.78, green: 0.10, blue: 0.18)
            ], startPoint: .topLeading, endPoint: .bottomTrailing))

            // つぶつぶの種 (本体の中央〜下半分に散らす)
            // path は y=0.02〜0.95 で本体を描いてるので、frame 中心からの
            // 相対オフセットで -0.15〜+0.30 に収める (下寄り)
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(Color(red: 1.0, green: 0.88, blue: 0.40))
                    .frame(width: size * 0.08, height: size * 0.08)
                    .offset(
                        x: size * [ 0.00, -0.15,  0.15,  0.00, -0.18,  0.18][i],
                        y: size * [-0.05, -0.05,  0.05,  0.18,  0.20,  0.20][i]
                    )
            }

            // 上の先端付近のハイライト
            Ellipse()
                .fill(Color.white.opacity(0.55))
                .frame(width: size * 0.18, height: size * 0.08)
                .offset(x: -size * 0.14, y: -size * 0.20)
        }
        .frame(width: size, height: size)
    }
}

/// ダークベリー (ブルーベリー/ブラックベリー風の濃い果実)
struct DarkBerryIcon: View {
    var size: CGFloat = 14
    var tint: Color = Color(red: 0.30, green: 0.05, blue: 0.18)   // dark plum
    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [
                    tint.opacity(0.85),
                    tint
                ], center: .topLeading, startRadius: 1, endRadius: size * 0.6))
            // ハイライト
            Ellipse()
                .fill(Color.white.opacity(0.55))
                .frame(width: size * 0.30, height: size * 0.20)
                .offset(x: -size * 0.18, y: -size * 0.20)
        }
        .frame(width: size, height: size)
    }
}

/// ロールケーキ風のストリークビュー — 寝かせたロール (両端丸い) + piped クリーム + ベリー盛り合わせ
///
/// streak が増えた時の演出:
///   1. ケーキ本体が左 → 右に伸びる (spring)
///   2. 伸び終わったタイミングで新しい苺が上から落ちて乗る
struct RollCakeStreak: View {
    let streak: Int
    var maxDays: Int = 10
    /// true のとき初回表示で「最後の1個が上から落ちて乗る」演出を再生する
    var animateNewBerry: Bool = false

    private var visibleBerries: Int { min(max(streak, 0), maxDays) }

    /// 表示中の苺数。streak より遅延させて、ケーキが伸び切ってから苺を出す
    @State private var revealedBerries: Int = 0

    /// ケーキの長さ。基準幅 + ベリーぶん伸びる
    private var cakeLength: CGFloat {
        let base: CGFloat = 110
        let perDay: CGFloat = 22
        return base + CGFloat(visibleBerries) * perDay
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // 皿 (ケーキの中心に合わせて両側に少しはみ出す)
            Ellipse()
                .fill(Color.white)
                .frame(width: cakeLength + 50, height: 18)
                .overlay(Ellipse().stroke(Color(red: 0.85, green: 0.84, blue: 0.85), lineWidth: 1))
                .shadow(color: .black.opacity(0.08), radius: 3, y: 1)
                .offset(x: -25, y: 38)
            // 本体 + クリーム + ベリー (leading 揃え → 左から右に伸びる)
            VStack(alignment: .leading, spacing: -8) {
                berriesLayer
                creamLayer
                cakeBody
            }
        }
        .frame(width: cakeLength + 25, height: 100, alignment: .leading)
        // ケーキ本体の伸びは spring で全体に効かせる
        .animation(.spring(response: 0.55, dampingFraction: 0.72), value: streak)
        .onAppear {
            if animateNewBerry && visibleBerries > 0 {
                // クリア直後：最後の1個を抜いた状態から始めて、ぽとっと落として乗せる
                revealedBerries = visibleBerries - 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                        revealedBerries = visibleBerries
                    }
                }
            } else {
                // 通常表示は遅延無しで即時セット
                revealedBerries = visibleBerries
            }
        }
        .onChange(of: streak) { _, _ in
            // ケーキが伸び切る ~0.35s 待ってから、新しい苺をぽとっと落とす
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) {
                    revealedBerries = visibleBerries
                }
            }
        }
    }

    /// ケーキ本体 (寝かせた円柱風 — 角丸控えめ、端が膨らまない)
    private var cakeBody: some View {
        let cornerR: CGFloat = 14   // 半径 = height/2 - α で「フラット気味」に
        return ZStack {
            // 影
            RoundedRectangle(cornerRadius: cornerR)
                .fill(Color.black.opacity(0.18))
                .frame(width: cakeLength + 4, height: 10)
                .blur(radius: 4)
                .offset(y: 26)
            // 本体
            RoundedRectangle(cornerRadius: cornerR)
                .fill(LinearGradient(colors: [
                    Color(red: 0.99, green: 0.86, blue: 0.62),
                    Color(red: 0.92, green: 0.72, blue: 0.45),
                    Color(red: 0.80, green: 0.58, blue: 0.32)
                ], startPoint: .top, endPoint: .bottom))
                .frame(width: cakeLength, height: 52)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerR)
                        .stroke(Color(red: 0.62, green: 0.40, blue: 0.18), lineWidth: 1.2)
                )
            // 表面の粒テクスチャ (ふんわり感)
            Canvas { ctx, sz in
                let baseColor = Color(red: 0.82, green: 0.62, blue: 0.38).opacity(0.55)
                for _ in 0..<40 {
                    let x = Double.random(in: 6...(sz.width - 6))
                    let y = Double.random(in: 6...(sz.height - 6))
                    let r = Double.random(in: 0.8...1.6)
                    ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r,
                                                    width: r * 2, height: r * 2)),
                             with: .color(baseColor))
                }
            }
            .frame(width: cakeLength - 8, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: cornerR))
            .allowsHitTesting(false)
            // 上面のハイライト (寝かせた円柱の上部反射)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.20))
                .frame(width: cakeLength - 24, height: 4)
                .offset(y: -18)
            // 左右の縁の控えめなシェード (端のロール感)
            HStack(spacing: 0) {
                Rectangle()
                    .fill(LinearGradient(colors: [.black.opacity(0.15), .clear],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: 8)
                Spacer()
                Rectangle()
                    .fill(LinearGradient(colors: [.clear, .black.opacity(0.15)],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: 8)
            }
            .frame(width: cakeLength, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: cornerR))
        }
    }

    /// piped クリーム (ドロップを連続配置)
    private var creamLayer: some View {
        let dollopCount = max(3, Int(cakeLength / 22))
        return HStack(spacing: -4) {
            ForEach(0..<dollopCount, id: \.self) { i in
                creamDollop
            }
        }
        .frame(width: cakeLength - 14)
    }

    /// クリーム 1 滴 (花絞り風)
    private var creamDollop: some View {
        ZStack {
            // 底辺の大きい滴
            Path { p in
                let w: CGFloat = 24, h: CGFloat = 22
                p.move(to: CGPoint(x: w * 0.10, y: h))
                p.addCurve(
                    to: CGPoint(x: w * 0.50, y: h * 0.10),
                    control1: CGPoint(x: w * 0.05, y: h * 0.55),
                    control2: CGPoint(x: w * 0.30, y: h * 0.10))
                p.addCurve(
                    to: CGPoint(x: w * 0.90, y: h),
                    control1: CGPoint(x: w * 0.70, y: h * 0.10),
                    control2: CGPoint(x: w * 0.95, y: h * 0.55))
                p.closeSubpath()
            }
            .fill(LinearGradient(colors: [
                Color.white,
                Color(red: 0.94, green: 0.92, blue: 0.87)
            ], startPoint: .top, endPoint: .bottom))
            .frame(width: 24, height: 22)
            // 渦巻きハイライト (内側に小さなアーチ)
            Path { p in
                p.move(to: CGPoint(x: 8, y: 14))
                p.addQuadCurve(to: CGPoint(x: 16, y: 14),
                               control: CGPoint(x: 12, y: 4))
            }
            .stroke(Color.white.opacity(0.85), lineWidth: 1.4)
            .frame(width: 24, height: 22)
        }
    }

    /// 苺だけ (streak の日数ぶん)。ケーキ幅に合わせて等間隔に載せる
    /// 新規追加分は上からぽとっと落ちてくる
    private var berriesLayer: some View {
        let count = revealedBerries
        return ZStack(alignment: .topLeading) {
            ForEach(0..<count, id: \.self) { i in
                StrawberryTipUp(size: 22)
                    .position(x: berryX(index: i, slotCount: visibleBerries),
                              y: i.isMultiple(of: 2) ? 11 : 13)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity)
                                      .combined(with: .scale(scale: 0.55, anchor: .bottom)),
                        removal: .opacity
                    ))
                    .id(i)
            }
        }
        .frame(width: cakeLength)
        .frame(height: 24)
    }

    private func berryX(index: Int, slotCount: Int) -> CGFloat {
        guard slotCount > 1 else { return cakeLength / 2 }
        let sideInset: CGFloat = 30
        let usableWidth = max(1, cakeLength - sideInset * 2)
        return sideInset + CGFloat(index) * usableWidth / CGFloat(slotCount - 1)
    }
}

/// 炎アイコン (旧 streak 用、他で参照されているので残す)
struct FlameIcon: View {
    var size: CGFloat = 36
    var body: some View {
        ZStack {
            // 外炎
            Path { p in
                let w = size, h = size
                p.move(to: CGPoint(x: w * 0.50, y: 0))
                p.addCurve(
                    to: CGPoint(x: w * 0.95, y: h * 0.65),
                    control1: CGPoint(x: w * 0.65, y: h * 0.20),
                    control2: CGPoint(x: w * 0.95, y: h * 0.40))
                p.addCurve(
                    to: CGPoint(x: w * 0.50, y: h),
                    control1: CGPoint(x: w * 0.95, y: h * 0.92),
                    control2: CGPoint(x: w * 0.75, y: h))
                p.addCurve(
                    to: CGPoint(x: w * 0.05, y: h * 0.65),
                    control1: CGPoint(x: w * 0.25, y: h),
                    control2: CGPoint(x: w * 0.05, y: h * 0.92))
                p.addCurve(
                    to: CGPoint(x: w * 0.35, y: h * 0.40),
                    control1: CGPoint(x: w * 0.05, y: h * 0.50),
                    control2: CGPoint(x: w * 0.25, y: h * 0.50))
                p.addCurve(
                    to: CGPoint(x: w * 0.50, y: 0),
                    control1: CGPoint(x: w * 0.45, y: h * 0.20),
                    control2: CGPoint(x: w * 0.40, y: h * 0.10))
                p.closeSubpath()
            }
            .fill(LinearGradient(colors: [
                Color(red: 0.99, green: 0.55, blue: 0.10),
                Color(red: 0.96, green: 0.20, blue: 0.20)
            ], startPoint: .top, endPoint: .bottom))
            // 内炎
            Path { p in
                let w = size, h = size
                p.move(to: CGPoint(x: w * 0.50, y: h * 0.25))
                p.addCurve(
                    to: CGPoint(x: w * 0.75, y: h * 0.70),
                    control1: CGPoint(x: w * 0.60, y: h * 0.40),
                    control2: CGPoint(x: w * 0.75, y: h * 0.55))
                p.addCurve(
                    to: CGPoint(x: w * 0.50, y: h * 0.92),
                    control1: CGPoint(x: w * 0.75, y: h * 0.85),
                    control2: CGPoint(x: w * 0.65, y: h * 0.92))
                p.addCurve(
                    to: CGPoint(x: w * 0.25, y: h * 0.70),
                    control1: CGPoint(x: w * 0.35, y: h * 0.92),
                    control2: CGPoint(x: w * 0.25, y: h * 0.85))
                p.addCurve(
                    to: CGPoint(x: w * 0.50, y: h * 0.25),
                    control1: CGPoint(x: w * 0.25, y: h * 0.55),
                    control2: CGPoint(x: w * 0.40, y: h * 0.40))
                p.closeSubpath()
            }
            .fill(LinearGradient(colors: [
                Color(red: 1.00, green: 0.92, blue: 0.30),
                Color(red: 0.99, green: 0.55, blue: 0.10)
            ], startPoint: .top, endPoint: .bottom))
        }
        .frame(width: size, height: size)
    }
}

