import SwiftUI
import UIKit
import UserNotifications

// MARK: - Shared UserDefaults (App Group)

/// メインアプリと Widget で共有する UserDefaults。
/// App Group が有効ならそちら、無ければ .standard にフォールバック。
let appDefaults: UserDefaults = {
    UserDefaults(suiteName: "group.app.Goto.Sakana.AlgoBite") ?? .standard
}()

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
            ForEach(0..<3, id: \.self) { i in
                Path { p in
                    // ハート型の苺
                    let cx = CGFloat(i - 1) * size * 0.22
                    p.move(to: CGPoint(x: cx, y: -size * 0.20))
                    p.addCurve(
                        to: CGPoint(x: cx + size * 0.06, y: -size * 0.30),
                        control1: CGPoint(x: cx, y: -size * 0.27),
                        control2: CGPoint(x: cx + size * 0.06, y: -size * 0.30))
                    p.addCurve(
                        to: CGPoint(x: cx, y: -size * 0.20),
                        control1: CGPoint(x: cx + size * 0.10, y: -size * 0.25),
                        control2: CGPoint(x: cx + size * 0.06, y: -size * 0.20))
                    p.addCurve(
                        to: CGPoint(x: cx - size * 0.06, y: -size * 0.30),
                        control1: CGPoint(x: cx - size * 0.06, y: -size * 0.20),
                        control2: CGPoint(x: cx - size * 0.10, y: -size * 0.25))
                    p.addCurve(
                        to: CGPoint(x: cx, y: -size * 0.20),
                        control1: CGPoint(x: cx - size * 0.06, y: -size * 0.30),
                        control2: CGPoint(x: cx, y: -size * 0.27))
                    p.closeSubpath()
                }
                .fill(Color(red: 0.95, green: 0.28, blue: 0.32))
                .offset(y: size * 0.04)
            }
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

            // 種 (黄色いつぶつぶ)
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(Color(red: 1.0, green: 0.88, blue: 0.40))
                    .frame(width: size * 0.07, height: size * 0.07)
                    .offset(
                        x: size * [-0.20, 0.15, -0.05, 0.22, -0.18, 0.08][i],
                        y: size * [0.28, 0.28, 0.50, 0.52, 0.55, 0.72][i]
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
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(Color(red: 1.0, green: 0.88, blue: 0.40))
                    .frame(width: size * 0.07, height: size * 0.07)
                    .offset(
                        x: size * [-0.18, 0.15, -0.05, 0.20, -0.20, 0.05][i],
                        y: size * [0.40, 0.30, 0.55, 0.55, 0.70, 0.70][i]
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
struct RollCakeStreak: View {
    let streak: Int
    var maxDays: Int = 10

    private var visibleBerries: Int { min(streak, maxDays) }

    /// ケーキの長さ。基準幅 + ベリーぶん伸びる
    private var cakeLength: CGFloat {
        let base: CGFloat = 110
        let perDay: CGFloat = 22
        return base + CGFloat(visibleBerries) * perDay
    }

    var body: some View {
        ZStack(alignment: .center) {
            // 皿
            Ellipse()
                .fill(Color.white)
                .frame(width: cakeLength + 50, height: 18)
                .overlay(Ellipse().stroke(Color(red: 0.85, green: 0.84, blue: 0.85), lineWidth: 1))
                .shadow(color: .black.opacity(0.08), radius: 3, y: 1)
                .offset(y: 38)
            // 本体 + クリーム + ベリー
            VStack(spacing: -8) {
                berriesLayer
                creamLayer
                cakeBody
            }
        }
        .frame(height: 100)
        .animation(.spring(response: 0.55, dampingFraction: 0.72), value: streak)
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

    /// 苺だけ (streak の日数ぶん)。先端が上を向いた向きで一列に並べる
    private var berriesLayer: some View {
        let count = visibleBerries
        return HStack(spacing: 2) {
            ForEach(0..<count, id: \.self) { i in
                StrawberryTipUp(size: 22)
                    // 偶奇でちょっとだけ上下に揺らして "並んでる" 感を出す
                    .offset(y: i.isMultiple(of: 2) ? -1 : 1)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.2).combined(with: .opacity)
                                      .combined(with: .offset(y: -16)),
                        removal: .opacity
                    ))
                    .id(i)
            }
        }
        .frame(height: 24)
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
                            Text("Version 1.0\n毎日ひと口、アルゴリズム。\nMade with 🍪 by ayu")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Pop.inkSub)
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

// MARK: - Onboarding — 初回起動時の 3 ステップ紹介

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var step = 0
    private let total = 3

    var body: some View {
        ZStack {
            LinearGradient(colors: [Pop.bgNeutralTop, Pop.bgNeutralBottom],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Spacer()
                TabView(selection: $step) {
                    pageContent(
                        illustration: AnyView(
                            HStack(spacing: 14) {
                                CookieIcon(size: 100)
                                DonutIcon(size: 80)
                                CupcakeIcon(size: 80)
                            }
                        ),
                        title: "AlgoBite へようこそ",
                        body: "アルゴリズムを\n毎日ひと口、おやつ感覚で。"
                    ).tag(0)
                    pageContent(
                        illustration: AnyView(
                            VStack(spacing: 10) {
                                CookieStackIcon(size: 80)
                                Text("🔥 \(7) 日連続！")
                                    .font(.title2.weight(.black))
                                    .foregroundStyle(Pop.inkWarm)
                            }
                        ),
                        title: "ストリークを伸ばそう",
                        body: "毎日 1 問解くとクッキーが\n積み上がってストリークに。"
                    ).tag(1)
                    pageContent(
                        illustration: AnyView(
                            VStack(spacing: 8) {
                                CakeIcon(size: 80)
                                HStack(spacing: 6) {
                                    Text("🏆").font(.title)
                                    Text("バッジ").font(.headline.weight(.heavy))
                                        .foregroundStyle(Pop.ink)
                                }
                            }
                        ),
                        title: "実績を集めよう",
                        body: "右上のアイコンから\nバッジと統計を確認できる。"
                    ).tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(maxHeight: 460)

                PopButton(fill: Pop.primary, shadow: Pop.primaryShadow,
                          action: { advance() }) {
                    Text(step == total - 1 ? "はじめる！" : "次へ")
                        .font(.title3.weight(.black))
                }
                .padding(.horizontal, 30)
                Button {
                    finish()
                } label: {
                    Text("スキップ")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Pop.inkSub)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 18)
        }
    }

    private func advance() {
        if step < total - 1 {
            withAnimation { step += 1 }
            Haptics.light()
        } else {
            finish()
        }
    }
    private func finish() {
        appDefaults.set(true, forKey: "algobite.onboarded")
        Haptics.success()
        withAnimation(.easeInOut(duration: 0.3)) { isPresented = false }
    }

    private func pageContent(illustration: AnyView, title: String, body: String) -> some View {
        VStack(spacing: 22) {
            illustration
                .frame(maxHeight: 220)
                .padding(.top, 24)
            VStack(spacing: 8) {
                Text(title)
                    .font(.title.weight(.black))
                    .foregroundStyle(Pop.ink)
                    .multilineTextAlignment(.center)
                Text(body)
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(Pop.inkSub)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 14)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

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
                        CakeIcon(size: 56)
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

// MARK: - Topic Illustration — 問題ごとの抽象アルゴ図

/// トピック文字列を見て、「何をする問題か」を伝える抽象イラスト。
/// 詳細な Path / Shape ベース。サイズは引数で固定スケール。
struct TopicIllustration: View {
    let topic: String
    var size: CGFloat = 72

    enum Kind {
        case twoPointers, binarySearch, sort, hashMap, stack, queue, linkedList
        case tree, graph, dp, backtracking, string, slidingWindow, bit, generic
    }

    var kind: Kind {
        let t = topic.lowercased()
        if t.contains("two pointer") || t.contains("two pointers") { return .twoPointers }
        if t.contains("binary search") { return .binarySearch }
        if t.contains("sort") || t.contains("sorting")             { return .sort }
        if t.contains("hash")                                      { return .hashMap }
        if t.contains("stack")                                     { return .stack }
        if t.contains("queue")                                     { return .queue }
        if t.contains("linked list")                               { return .linkedList }
        if t.contains("tree") || t.contains("bst") || t.contains("trie") { return .tree }
        if t.contains("graph") || t.contains("bfs") || t.contains("dfs") { return .graph }
        if t.contains("dp") || t.contains("dynamic")               { return .dp }
        if t.contains("backtrack")                                 { return .backtracking }
        if t.contains("sliding")                                   { return .slidingWindow }
        if t.contains("bit")                                       { return .bit }
        if t.contains("string")                                    { return .string }
        return .generic
    }

    // クリームベースの背景＋テーマ別アクセントカラー
    private var themeColors: (bg: Color, accent: Color, accent2: Color, ink: Color) {
        switch kind {
        case .twoPointers:   return (Color(red: 1.00, green: 0.94, blue: 0.92),
                                     Color(red: 0.92, green: 0.30, blue: 0.42),  // raspberry
                                     Color(red: 0.18, green: 0.62, blue: 0.86),  // sky
                                     Color(red: 0.36, green: 0.21, blue: 0.30))
        case .binarySearch:  return (Color(red: 0.98, green: 0.94, blue: 1.00),
                                     Color(red: 0.55, green: 0.32, blue: 0.92),  // grape
                                     Color(red: 0.99, green: 0.79, blue: 0.18),  // honey
                                     Color(red: 0.26, green: 0.15, blue: 0.42))
        case .sort:          return (Color(red: 1.00, green: 0.96, blue: 0.88),
                                     Color(red: 0.96, green: 0.50, blue: 0.05),  // pumpkin
                                     Color(red: 0.96, green: 0.78, blue: 0.30),  // butter
                                     Color(red: 0.40, green: 0.20, blue: 0.05))
        case .hashMap:       return (Color(red: 0.92, green: 0.97, blue: 0.93),
                                     Color(red: 0.16, green: 0.66, blue: 0.40),  // pistachio
                                     Color(red: 0.96, green: 0.62, blue: 0.04),
                                     Color(red: 0.10, green: 0.36, blue: 0.22))
        case .stack:         return (Color(red: 1.00, green: 0.92, blue: 0.95),
                                     Color(red: 0.92, green: 0.38, blue: 0.62),  // strawberry
                                     Color(red: 1.00, green: 0.82, blue: 0.50),
                                     Color(red: 0.45, green: 0.10, blue: 0.30))
        case .queue:         return (Color(red: 0.92, green: 0.96, blue: 1.00),
                                     Color(red: 0.20, green: 0.55, blue: 0.92),
                                     Color(red: 0.96, green: 0.62, blue: 0.04),
                                     Color(red: 0.10, green: 0.26, blue: 0.50))
        case .linkedList:    return (Color(red: 1.00, green: 0.93, blue: 0.86),
                                     Color(red: 0.95, green: 0.45, blue: 0.20),  // amber
                                     Color(red: 0.55, green: 0.30, blue: 0.10),
                                     Color(red: 0.45, green: 0.18, blue: 0.05))
        case .tree:          return (Color(red: 0.94, green: 0.99, blue: 0.93),
                                     Color(red: 0.30, green: 0.72, blue: 0.30),
                                     Color(red: 0.96, green: 0.30, blue: 0.42),
                                     Color(red: 0.08, green: 0.32, blue: 0.18))
        case .graph:         return (Color(red: 0.94, green: 0.94, blue: 1.00),
                                     Color(red: 0.42, green: 0.36, blue: 0.92),
                                     Color(red: 0.96, green: 0.62, blue: 0.04),
                                     Color(red: 0.22, green: 0.16, blue: 0.50))
        case .dp:            return (Color(red: 0.96, green: 0.94, blue: 1.00),
                                     Color(red: 0.66, green: 0.22, blue: 0.96),
                                     Color(red: 0.96, green: 0.30, blue: 0.62),
                                     Color(red: 0.30, green: 0.08, blue: 0.50))
        case .backtracking:  return (Color(red: 1.00, green: 0.93, blue: 0.93),
                                     Color(red: 0.96, green: 0.30, blue: 0.30),
                                     Color(red: 0.66, green: 0.66, blue: 0.72),
                                     Color(red: 0.30, green: 0.08, blue: 0.08))
        case .slidingWindow: return (Color(red: 1.00, green: 0.96, blue: 0.88),
                                     Color(red: 0.96, green: 0.55, blue: 0.10),
                                     Color(red: 0.55, green: 0.30, blue: 0.92),
                                     Color(red: 0.40, green: 0.20, blue: 0.05))
        case .bit:           return (Color(red: 0.92, green: 0.95, blue: 1.00),
                                     Color(red: 0.12, green: 0.65, blue: 0.88),
                                     Color(red: 0.95, green: 0.30, blue: 0.62),
                                     Color(red: 0.05, green: 0.22, blue: 0.42))
        case .string:        return (Color(red: 1.00, green: 0.95, blue: 1.00),
                                     Color(red: 0.55, green: 0.25, blue: 0.92),
                                     Color(red: 0.95, green: 0.65, blue: 0.30),
                                     Color(red: 0.30, green: 0.10, blue: 0.50))
        case .generic:       return (Color(red: 1.00, green: 0.97, blue: 0.93),
                                     Color(red: 0.96, green: 0.50, blue: 0.20),
                                     Color(red: 0.55, green: 0.30, blue: 0.92),
                                     Color(red: 0.40, green: 0.20, blue: 0.10))
        }
    }
    private var bg: Color     { themeColors.bg }
    private var accent: Color { themeColors.accent }
    private var accent2: Color { themeColors.accent2 }
    private var ink: Color    { themeColors.ink }

    var body: some View {
        ZStack {
            // 角丸の "ステッカー" 風背景
            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(LinearGradient(colors: [bg, bg.opacity(0.85)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
            RoundedRectangle(cornerRadius: size * 0.18)
                .strokeBorder(accent.opacity(0.35), lineWidth: size * 0.025)
            // 内側のソフトハイライト
            RoundedRectangle(cornerRadius: size * 0.18)
                .stroke(Color.white.opacity(0.55), lineWidth: size * 0.012)
                .padding(size * 0.025)
            illustration
                .padding(size * 0.10)
        }
        .frame(width: size, height: size)
        .compositingGroup()
        .shadow(color: accent.opacity(0.18), radius: size * 0.04, x: 0, y: size * 0.025)
    }

    @ViewBuilder
    private var illustration: some View {
        switch kind {
        case .twoPointers:   twoPointersArt
        case .binarySearch:  binarySearchArt
        case .sort:          sortArt
        case .hashMap:       hashArt
        case .stack:         stackArt
        case .queue:         queueArt
        case .linkedList:    linkedListArt
        case .tree:          treeArt
        case .graph:         graphArt
        case .dp:            dpArt
        case .backtracking:  backtrackingArt
        case .slidingWindow: slidingArt
        case .bit:           bitArt
        case .string:        stringArt
        case .generic:       genericArt
        }
    }

    // 共通ヘルパ: スロット (タイル) を 1 つ描く
    private func tile(value: String? = nil, w: CGFloat, h: CGFloat,
                      fill: Color, stroke: Color, fg: Color) -> some View {
        RoundedRectangle(cornerRadius: w * 0.18)
            .fill(fill)
            .frame(width: w, height: h)
            .overlay(
                RoundedRectangle(cornerRadius: w * 0.18)
                    .strokeBorder(stroke, lineWidth: w * 0.10)
            )
            .overlay(
                value.map { v in
                    Text(v).font(.system(size: w * 0.55, weight: .black, design: .rounded))
                        .foregroundStyle(fg)
                }
            )
    }

    // ▶ Two Pointers — 両端から内側へ進むマーカー
    private var twoPointersArt: some View {
        let cellW = size * 0.13
        let row: [(Color, Color, Color)] = [
            (accent.opacity(0.95), accent.opacity(0.55), .white),         // left pointer (red)
            (Color.white,           ink.opacity(0.18),    ink.opacity(0.6)),
            (Color.white,           ink.opacity(0.18),    ink.opacity(0.6)),
            (Color.white,           ink.opacity(0.18),    ink.opacity(0.6)),
            (accent2.opacity(0.95), accent2.opacity(0.55), .white),       // right pointer (blue)
        ]
        return VStack(spacing: size * 0.06) {
            // top row of tiles
            HStack(spacing: size * 0.025) {
                ForEach(0..<5, id: \.self) { i in
                    tile(value: ["L","","","","R"][i],
                         w: cellW, h: cellW * 1.15,
                         fill: row[i].0, stroke: row[i].1, fg: row[i].2)
                }
            }
            // arrows pointing inward
            HStack(spacing: 0) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: size * 0.22, weight: .heavy))
                    .foregroundStyle(accent)
                Spacer()
                Image(systemName: "arrow.left.circle.fill")
                    .font(.system(size: size * 0.22, weight: .heavy))
                    .foregroundStyle(accent2)
            }
            .padding(.horizontal, size * 0.04)
        }
    }

    // ▶ Binary Search — 範囲を半分に絞り込んでいく "二分" を明示
    // 上段: 8 セルの sorted 配列 + L/M/R マーカー  →  ↓ halve ↓  → 下段: 4 セルに半減
    private var binarySearchArt: some View {
        let cellW = size * 0.085
        let cellH = cellW * 1.20
        return VStack(spacing: size * 0.04) {
            // 上段: 8 セル + L (i=0), M (i=3) [現在の中央], R (i=7)
            VStack(spacing: size * 0.018) {
                HStack(spacing: size * 0.012) {
                    ForEach(0..<8, id: \.self) { i in
                        bsCell(index: i,
                               midIndex: 3,
                               width: cellW, height: cellH,
                               highlightKeptHalf: i >= 4)
                    }
                }
                // L / M / R ラベル行
                HStack(spacing: size * 0.012) {
                    ForEach(0..<8, id: \.self) { i in
                        bsLabel(for: i, at: [0, 3, 7], width: cellW)
                    }
                }
            }
            // 真ん中の "÷2" を強調する矢印
            HStack(spacing: size * 0.03) {
                Text("÷2")
                    .font(.system(size: size * 0.11, weight: .black, design: .rounded))
                    .foregroundStyle(accent)
                Image(systemName: "arrow.down")
                    .font(.system(size: size * 0.11, weight: .heavy))
                    .foregroundStyle(accent)
            }
            // 下段: 半減した 4 セル (右半分が残る)
            VStack(spacing: size * 0.018) {
                HStack(spacing: size * 0.012) {
                    ForEach(0..<4, id: \.self) { i in
                        bsCell(index: i,
                               midIndex: 1,   // 新しい mid
                               width: cellW, height: cellH * 0.85,
                               highlightKeptHalf: false,
                               isLowerRange: true)
                    }
                }
                HStack(spacing: size * 0.012) {
                    ForEach(0..<4, id: \.self) { i in
                        bsLabel(for: i, at: [0, 1, 3], width: cellW)
                    }
                }
            }
        }
    }

    /// 1 セル: index と midIndex を比較してハイライト
    private func bsCell(index: Int, midIndex: Int,
                        width: CGFloat, height: CGFloat,
                        highlightKeptHalf: Bool,
                        isLowerRange: Bool = false) -> some View {
        let isMid = index == midIndex
        let fill: Color
        let stroke: Color
        if isMid {
            fill = accent
            stroke = accent2
        } else if isLowerRange || highlightKeptHalf {
            fill = accent.opacity(0.30)
            stroke = accent.opacity(0.55)
        } else {
            // 切り捨てる側 (左半分)
            fill = ink.opacity(0.12)
            stroke = ink.opacity(0.25)
        }
        return RoundedRectangle(cornerRadius: width * 0.20)
            .fill(fill)
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: width * 0.20)
                    .strokeBorder(stroke, lineWidth: width * 0.08)
            )
            .overlay(
                isMid ?
                AnyView(Image(systemName: "star.fill")
                    .font(.system(size: width * 0.50, weight: .black))
                    .foregroundStyle(.white))
                : AnyView(EmptyView())
            )
    }

    /// 位置 i が L/M/R のどれかなら対応文字、そうでなければ空
    private func bsLabel(for index: Int, at positions: [Int], width: CGFloat) -> some View {
        let labels = ["L", "M", "R"]
        let idx = positions.firstIndex(of: index)
        return Group {
            if let k = idx {
                Text(labels[k])
                    .font(.system(size: width * 0.55, weight: .black, design: .rounded))
                    .foregroundStyle(k == 1 ? accent : ink.opacity(0.65))
            } else {
                Text("")
            }
        }
        .frame(width: width)
    }

    // ▶ Sort — 高さがバラバラ → 昇順に整列
    private var sortArt: some View {
        // 上段: バラバラの 6 本、下段: 並び替え後 (整列)
        let heights: [CGFloat] = [0.55, 0.20, 0.85, 0.35, 0.65, 0.45]
        let sortedH = heights.sorted()
        return VStack(spacing: size * 0.08) {
            HStack(alignment: .bottom, spacing: size * 0.025) {
                ForEach(0..<6, id: \.self) { i in
                    bar(height: heights[i], hue: i, accentMain: true)
                }
            }
            // 並び替え矢印
            HStack(spacing: size * 0.025) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "arrow.down")
                        .font(.system(size: size * 0.08, weight: .black))
                        .foregroundStyle(accent.opacity(0.7))
                }
            }
            HStack(alignment: .bottom, spacing: size * 0.025) {
                ForEach(0..<6, id: \.self) { i in
                    bar(height: sortedH[i], hue: i, accentMain: false)
                }
            }
        }
    }

    private func bar(height: CGFloat, hue: Int, accentMain: Bool) -> some View {
        let palette = [accent, accent2,
                       accent.opacity(0.85), accent2.opacity(0.85),
                       accent.opacity(0.70), accent2.opacity(0.70)]
        let h = size * 0.32 * height + size * 0.04
        return RoundedRectangle(cornerRadius: size * 0.025)
            .fill(LinearGradient(colors: [palette[hue % palette.count].opacity(accentMain ? 0.95 : 0.95),
                                          palette[hue % palette.count].opacity(0.55)],
                                 startPoint: .top, endPoint: .bottom))
            .frame(width: size * 0.085, height: h)
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.025)
                    .stroke(ink.opacity(0.25), lineWidth: size * 0.008)
            )
    }

    // ▶ Hash — key → value 矢印 + バケット
    private var hashArt: some View {
        VStack(spacing: size * 0.05) {
            // key + arrow + bucket
            HStack(spacing: size * 0.04) {
                // key tile with "k"
                tile(value: "k", w: size * 0.18, h: size * 0.22,
                     fill: accent2, stroke: accent2.opacity(0.55), fg: .white)
                Image(systemName: "arrow.right")
                    .font(.system(size: size * 0.16, weight: .heavy))
                    .foregroundStyle(accent)
                Image(systemName: "number.square.fill")
                    .font(.system(size: size * 0.32))
                    .foregroundStyle(accent)
                Image(systemName: "arrow.right")
                    .font(.system(size: size * 0.16, weight: .heavy))
                    .foregroundStyle(accent)
                tile(value: "v", w: size * 0.18, h: size * 0.22,
                     fill: ink, stroke: ink.opacity(0.7), fg: .white)
            }
            // buckets row
            HStack(spacing: size * 0.04) {
                ForEach(0..<4, id: \.self) { i in
                    bucket(filled: [true, false, true, true][i])
                }
            }
        }
    }
    private func bucket(filled: Bool) -> some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: size * 0.03)
                .strokeBorder(ink.opacity(0.35), lineWidth: size * 0.014)
                .frame(width: size * 0.14, height: size * 0.20)
            if filled {
                Circle()
                    .fill(accent)
                    .frame(width: size * 0.08, height: size * 0.08)
                    .offset(y: -size * 0.04)
            }
        }
    }

    // ▶ Stack — 4段スタック + push 矢印
    private var stackArt: some View {
        let widths: [CGFloat] = [0.52, 0.52, 0.52, 0.52]
        return ZStack {
            // 影
            RoundedRectangle(cornerRadius: size * 0.035)
                .fill(Color.black.opacity(0.10))
                .frame(width: size * 0.56, height: size * 0.05)
                .offset(y: size * 0.30)
                .blur(radius: 3)
            VStack(spacing: size * 0.025) {
                // push 矢印 (上)
                VStack(spacing: 2) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: size * 0.14, weight: .heavy))
                        .foregroundStyle(accent)
                    Text("push")
                        .font(.system(size: size * 0.08, weight: .heavy))
                        .foregroundStyle(accent)
                }
                ForEach(0..<widths.count, id: \.self) { i in
                    RoundedRectangle(cornerRadius: size * 0.04)
                        .fill(LinearGradient(colors: [
                            i == 0 ? accent : ink.opacity(0.35),
                            i == 0 ? accent.opacity(0.65) : ink.opacity(0.20)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: size * widths[i], height: size * 0.11)
                        .overlay(
                            RoundedRectangle(cornerRadius: size * 0.04)
                                .strokeBorder(ink.opacity(0.35), lineWidth: size * 0.01)
                        )
                }
            }
        }
    }

    // ▶ Queue — IN ▶ ░░░░ ▶ OUT
    private var queueArt: some View {
        HStack(spacing: size * 0.04) {
            VStack(spacing: 2) {
                Image(systemName: "arrow.right")
                    .font(.system(size: size * 0.14, weight: .heavy))
                    .foregroundStyle(accent)
                Text("in").font(.system(size: size * 0.07, weight: .heavy))
                    .foregroundStyle(accent)
            }
            HStack(spacing: size * 0.02) {
                ForEach(0..<4, id: \.self) { i in
                    let isHead = i == 0
                    RoundedRectangle(cornerRadius: size * 0.04)
                        .fill(LinearGradient(colors: [
                            isHead ? accent : ink.opacity(0.32),
                            isHead ? accent.opacity(0.65) : ink.opacity(0.18)
                        ], startPoint: .top, endPoint: .bottom))
                        .frame(width: size * 0.10, height: size * 0.32)
                        .overlay(
                            RoundedRectangle(cornerRadius: size * 0.04)
                                .strokeBorder(ink.opacity(0.32), lineWidth: size * 0.008)
                        )
                }
            }
            VStack(spacing: 2) {
                Image(systemName: "arrow.right")
                    .font(.system(size: size * 0.14, weight: .heavy))
                    .foregroundStyle(accent2)
                Text("out").font(.system(size: size * 0.07, weight: .heavy))
                    .foregroundStyle(accent2)
            }
        }
    }

    // ▶ Linked List — node → node → node + NULL
    private var linkedListArt: some View {
        HStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { i in
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.07)
                        .fill(LinearGradient(colors: [
                            i == 0 ? accent : ink.opacity(0.50),
                            i == 0 ? accent.opacity(0.65) : ink.opacity(0.30)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: size * 0.20, height: size * 0.22)
                    Text("\(i + 1)")
                        .font(.system(size: size * 0.13, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
                if i < 2 {
                    Image(systemName: "arrow.right")
                        .font(.system(size: size * 0.13, weight: .heavy))
                        .foregroundStyle(ink.opacity(0.55))
                        .padding(.horizontal, size * 0.005)
                }
            }
            Image(systemName: "arrow.right")
                .font(.system(size: size * 0.13, weight: .heavy))
                .foregroundStyle(ink.opacity(0.55))
            Text("∅")
                .font(.system(size: size * 0.20, weight: .black))
                .foregroundStyle(ink.opacity(0.45))
        }
    }

    // ▶ Tree — proper binary tree
    private var treeArt: some View {
        ZStack {
            // edges
            Path { p in
                let root = CGPoint(x: size * 0.40, y: size * 0.10)
                let l1   = CGPoint(x: size * 0.18, y: size * 0.36)
                let r1   = CGPoint(x: size * 0.62, y: size * 0.36)
                let ll   = CGPoint(x: size * 0.06, y: size * 0.62)
                let lr   = CGPoint(x: size * 0.28, y: size * 0.62)
                let rl   = CGPoint(x: size * 0.50, y: size * 0.62)
                let rr   = CGPoint(x: size * 0.74, y: size * 0.62)
                p.move(to: root); p.addLine(to: l1)
                p.move(to: root); p.addLine(to: r1)
                p.move(to: l1);   p.addLine(to: ll)
                p.move(to: l1);   p.addLine(to: lr)
                p.move(to: r1);   p.addLine(to: rl)
                p.move(to: r1);   p.addLine(to: rr)
            }
            .stroke(ink.opacity(0.50), style: StrokeStyle(lineWidth: size * 0.018, lineCap: .round))

            // nodes
            node(at: CGPoint(x: 0.40, y: 0.10), r: 0.085, color: accent, label: "•")
            node(at: CGPoint(x: 0.18, y: 0.36), r: 0.075, color: accent2, label: "•")
            node(at: CGPoint(x: 0.62, y: 0.36), r: 0.075, color: accent2, label: "•")
            node(at: CGPoint(x: 0.06, y: 0.62), r: 0.065, color: ink.opacity(0.55), label: nil)
            node(at: CGPoint(x: 0.28, y: 0.62), r: 0.065, color: ink.opacity(0.55), label: nil)
            node(at: CGPoint(x: 0.50, y: 0.62), r: 0.065, color: ink.opacity(0.55), label: nil)
            node(at: CGPoint(x: 0.74, y: 0.62), r: 0.065, color: ink.opacity(0.55), label: nil)
        }
        .frame(width: size * 0.80, height: size * 0.74)
    }
    private func node(at p: CGPoint, r: CGFloat, color: Color, label: String?) -> some View {
        Circle()
            .fill(color)
            .frame(width: size * r * 2, height: size * r * 2)
            .overlay(
                Circle().strokeBorder(Color.white.opacity(0.5), lineWidth: size * 0.008)
            )
            .position(x: size * p.x, y: size * p.y)
    }

    // ▶ Graph — 5 ノード + 複数のエッジ
    private var graphArt: some View {
        let positions: [CGPoint] = [
            CGPoint(x: 0.20, y: 0.20),
            CGPoint(x: 0.55, y: 0.10),
            CGPoint(x: 0.78, y: 0.36),
            CGPoint(x: 0.62, y: 0.66),
            CGPoint(x: 0.18, y: 0.58),
        ]
        let edges: [(Int, Int)] = [
            (0,1),(1,2),(2,3),(3,4),(4,0),(0,2),(1,3)
        ]
        return ZStack {
            // edges
            Path { p in
                for (a,b) in edges {
                    p.move(to: CGPoint(x: size * positions[a].x, y: size * positions[a].y))
                    p.addLine(to: CGPoint(x: size * positions[b].x, y: size * positions[b].y))
                }
            }
            .stroke(ink.opacity(0.45), style: StrokeStyle(lineWidth: size * 0.018, lineCap: .round))
            // nodes
            ForEach(positions.indices, id: \.self) { i in
                let nodeColor: Color = i == 0 ? accent : (i == 1 ? accent2 : ink.opacity(0.55))
                Circle()
                    .fill(nodeColor)
                    .frame(width: size * 0.16, height: size * 0.16)
                    .overlay(Circle().strokeBorder(.white.opacity(0.6), lineWidth: size * 0.012))
                    .position(x: size * positions[i].x, y: size * positions[i].y)
            }
        }
        .frame(width: size * 0.80, height: size * 0.72)
    }

    // ▶ DP — 4×4 grid, ナナメ階段に塗ってチェックマーク
    private var dpArt: some View {
        VStack(spacing: size * 0.020) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: size * 0.020) {
                    ForEach(0..<4, id: \.self) { col in
                        let solved = row + col <= 3
                        let onDiag = row + col == 3
                        ZStack {
                            RoundedRectangle(cornerRadius: size * 0.025)
                                .fill(solved
                                      ? LinearGradient(colors: [accent, accent2],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                                      : LinearGradient(colors: [ink.opacity(0.12), ink.opacity(0.12)],
                                                       startPoint: .top, endPoint: .bottom))
                                .frame(width: size * 0.13, height: size * 0.13)
                                .overlay(
                                    RoundedRectangle(cornerRadius: size * 0.025)
                                        .strokeBorder(ink.opacity(0.22), lineWidth: size * 0.006)
                                )
                            if onDiag {
                                Image(systemName: "checkmark")
                                    .font(.system(size: size * 0.08, weight: .black))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
            }
        }
    }

    // ▶ Backtracking — 探索ツリーで 1 本だけ選ばれ、他は破線で却下
    private var backtrackingArt: some View {
        ZStack {
            // dimmed branches (dashed)
            Path { p in
                p.move(to: CGPoint(x: size * 0.40, y: size * 0.10))
                p.addLine(to: CGPoint(x: size * 0.18, y: size * 0.36))
                p.move(to: CGPoint(x: size * 0.18, y: size * 0.36))
                p.addLine(to: CGPoint(x: size * 0.08, y: size * 0.62))
                p.move(to: CGPoint(x: size * 0.62, y: size * 0.36))
                p.addLine(to: CGPoint(x: size * 0.50, y: size * 0.62))
            }
            .stroke(ink.opacity(0.30), style: StrokeStyle(lineWidth: size * 0.018, dash: [size * 0.03, size * 0.025]))
            // ×印
            Image(systemName: "xmark")
                .font(.system(size: size * 0.08, weight: .black))
                .foregroundStyle(accent2)
                .position(x: size * 0.18, y: size * 0.36)
            Image(systemName: "xmark")
                .font(.system(size: size * 0.08, weight: .black))
                .foregroundStyle(accent2)
                .position(x: size * 0.50, y: size * 0.62)
            // chosen path (solid + accent)
            Path { p in
                p.move(to: CGPoint(x: size * 0.40, y: size * 0.10))
                p.addLine(to: CGPoint(x: size * 0.62, y: size * 0.36))
                p.addLine(to: CGPoint(x: size * 0.74, y: size * 0.62))
            }
            .stroke(accent, style: StrokeStyle(lineWidth: size * 0.028, lineCap: .round))
            // nodes
            Circle().fill(accent).frame(width: size * 0.16, height: size * 0.16)
                .overlay(Circle().strokeBorder(.white.opacity(0.6), lineWidth: size * 0.01))
                .position(x: size * 0.40, y: size * 0.10)
            Circle().fill(ink.opacity(0.45)).frame(width: size * 0.12, height: size * 0.12)
                .position(x: size * 0.18, y: size * 0.36)
            Circle().fill(accent).frame(width: size * 0.13, height: size * 0.13)
                .overlay(Circle().strokeBorder(.white.opacity(0.6), lineWidth: size * 0.008))
                .position(x: size * 0.62, y: size * 0.36)
            Circle().fill(ink.opacity(0.45)).frame(width: size * 0.10, height: size * 0.10)
                .position(x: size * 0.08, y: size * 0.62)
            Circle().fill(ink.opacity(0.45)).frame(width: size * 0.10, height: size * 0.10)
                .position(x: size * 0.50, y: size * 0.62)
            Circle().fill(accent).frame(width: size * 0.11, height: size * 0.11)
                .overlay(Circle().strokeBorder(.white.opacity(0.6), lineWidth: size * 0.008))
                .position(x: size * 0.74, y: size * 0.62)
        }
        .frame(width: size * 0.82, height: size * 0.72)
    }

    // ▶ Sliding Window — ウィンドウ枠 + 矢印
    private var slidingArt: some View {
        ZStack(alignment: .top) {
            // strip of cells
            HStack(spacing: size * 0.022) {
                ForEach(0..<7, id: \.self) { i in
                    RoundedRectangle(cornerRadius: size * 0.025)
                        .fill((2...4).contains(i) ? accent.opacity(0.85) : ink.opacity(0.20))
                        .overlay(
                            RoundedRectangle(cornerRadius: size * 0.025)
                                .strokeBorder(ink.opacity(0.25), lineWidth: size * 0.006)
                        )
                        .frame(width: size * 0.09, height: size * 0.32)
                }
            }
            .offset(y: size * 0.18)
            // window frame
            RoundedRectangle(cornerRadius: size * 0.04)
                .strokeBorder(accent2, lineWidth: size * 0.030)
                .background(
                    RoundedRectangle(cornerRadius: size * 0.04)
                        .fill(accent2.opacity(0.12))
                )
                .frame(width: size * 0.34, height: size * 0.38)
                .offset(y: size * 0.15)
            // arrow indicating motion
            Image(systemName: "arrow.right")
                .font(.system(size: size * 0.14, weight: .heavy))
                .foregroundStyle(accent2)
                .offset(x: size * 0.30, y: size * 0.30)
            // label
            Text("window")
                .font(.system(size: size * 0.08, weight: .heavy))
                .foregroundStyle(accent2)
                .offset(y: size * -0.02)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // ▶ Bit — 2 段の 0/1 + AND/OR
    private var bitArt: some View {
        VStack(spacing: size * 0.05) {
            bitRow(values: [1,0,1,1,0,1])
            HStack(spacing: size * 0.04) {
                Image(systemName: "circle.grid.cross")
                    .font(.system(size: size * 0.16, weight: .heavy))
                    .foregroundStyle(accent2)
                Text("XOR")
                    .font(.system(size: size * 0.10, weight: .black, design: .monospaced))
                    .foregroundStyle(accent2)
            }
            bitRow(values: [1,1,0,0,1,1])
        }
    }
    private func bitRow(values: [Int]) -> some View {
        HStack(spacing: size * 0.025) {
            ForEach(Array(values.enumerated()), id: \.offset) { _, v in
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.02)
                        .fill(v == 1 ? accent : ink.opacity(0.15))
                        .frame(width: size * 0.10, height: size * 0.18)
                    Text(v == 1 ? "1" : "0")
                        .font(.system(size: size * 0.10, weight: .black, design: .monospaced))
                        .foregroundStyle(v == 1 ? .white : ink.opacity(0.55))
                }
            }
        }
    }

    // ▶ String — Scrabble風タイル + 1 つだけ強調
    private var stringArt: some View {
        VStack(spacing: size * 0.06) {
            HStack(spacing: size * 0.020) {
                ForEach(Array("hello".enumerated()), id: \.offset) { i, c in
                    let highlight = i == 1
                    ZStack {
                        // tile shadow
                        RoundedRectangle(cornerRadius: size * 0.04)
                            .fill(Color.black.opacity(0.10))
                            .frame(width: size * 0.13, height: size * 0.28)
                            .offset(y: size * 0.022)
                        // tile body
                        RoundedRectangle(cornerRadius: size * 0.04)
                            .fill(LinearGradient(colors: [
                                highlight ? accent : Color.white,
                                highlight ? accent.opacity(0.65) : Color(red: 0.96, green: 0.94, blue: 0.92)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: size * 0.13, height: size * 0.28)
                            .overlay(
                                RoundedRectangle(cornerRadius: size * 0.04)
                                    .strokeBorder(highlight ? accent.opacity(0.85) : ink.opacity(0.35),
                                                  lineWidth: size * 0.008)
                            )
                        Text(String(c))
                            .font(.system(size: size * 0.14, weight: .black, design: .serif))
                            .foregroundStyle(highlight ? .white : ink)
                    }
                }
            }
            // 走査ポインタ
            HStack(spacing: size * 0.020) {
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: i == 1 ? "arrow.up" : "circle.dotted")
                        .font(.system(size: size * 0.10, weight: .black))
                        .foregroundStyle(i == 1 ? accent : ink.opacity(0.30))
                        .frame(width: size * 0.13)
                }
            }
        }
    }

    // ▶ Generic — フローチャート風
    private var genericArt: some View {
        ZStack {
            // diamond
            Path { p in
                let c = CGPoint(x: size * 0.40, y: size * 0.40)
                let r = size * 0.20
                p.move(to: CGPoint(x: c.x, y: c.y - r))
                p.addLine(to: CGPoint(x: c.x + r, y: c.y))
                p.addLine(to: CGPoint(x: c.x, y: c.y + r))
                p.addLine(to: CGPoint(x: c.x - r, y: c.y))
                p.closeSubpath()
            }
            .fill(LinearGradient(colors: [accent, accent2],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(
                Path { p in
                    let c = CGPoint(x: size * 0.40, y: size * 0.40)
                    let r = size * 0.20
                    p.move(to: CGPoint(x: c.x, y: c.y - r))
                    p.addLine(to: CGPoint(x: c.x + r, y: c.y))
                    p.addLine(to: CGPoint(x: c.x, y: c.y + r))
                    p.addLine(to: CGPoint(x: c.x - r, y: c.y))
                    p.closeSubpath()
                }
                .stroke(ink.opacity(0.4), lineWidth: size * 0.014)
            )
            // 関数記号
            Text("ƒ")
                .font(.system(size: size * 0.20, weight: .black, design: .serif))
                .foregroundStyle(.white)
                .position(x: size * 0.40, y: size * 0.40)
            // 出入りの矢印
            Image(systemName: "arrow.right")
                .font(.system(size: size * 0.14, weight: .heavy))
                .foregroundStyle(accent.opacity(0.7))
                .position(x: size * 0.10, y: size * 0.40)
            Image(systemName: "arrow.right")
                .font(.system(size: size * 0.14, weight: .heavy))
                .foregroundStyle(accent.opacity(0.7))
                .position(x: size * 0.70, y: size * 0.40)
            // sparkle
            Image(systemName: "sparkle")
                .font(.system(size: size * 0.12))
                .foregroundStyle(accent2)
                .position(x: size * 0.58, y: size * 0.18)
        }
        .frame(width: size * 0.80, height: size * 0.80)
    }
}

// MARK: - Haptics (①)

enum Haptics {
    static func success() {
        let g = UINotificationFeedbackGenerator()
        g.prepare(); g.notificationOccurred(.success)
    }
    static func error() {
        let g = UINotificationFeedbackGenerator()
        g.prepare(); g.notificationOccurred(.error)
    }
    static func warning() {
        let g = UINotificationFeedbackGenerator()
        g.prepare(); g.notificationOccurred(.warning)
    }
    static func selection() {
        let g = UISelectionFeedbackGenerator()
        g.prepare(); g.selectionChanged()
    }
    static func light()  { UIImpactFeedbackGenerator(style: .light ).impactOccurred() }
    static func medium() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    static func rigid()  { UIImpactFeedbackGenerator(style: .rigid ).impactOccurred() }
}

// MARK: - Stats Store (③)

@MainActor
final class StatsStore: ObservableObject {
    @Published private(set) var totalSolved: Int
    @Published private(set) var solvedDates: Set<String>
    @Published private(set) var topicCounts: [String: Int]
    @Published private(set) var reorderClears: Int
    @Published private(set) var lastDate: String?

    private let kTotal = "algobite.stats.totalSolved"
    private let kDates = "algobite.stats.solvedDates"
    private let kTopics = "algobite.stats.topicCounts"
    private let kReorder = "algobite.stats.reorderClears"

    static let shared = StatsStore()

    init() {
        let d = appDefaults
        totalSolved   = d.integer(forKey: kTotal)
        solvedDates   = Set((d.array(forKey: kDates) as? [String]) ?? [])
        topicCounts   = (d.dictionary(forKey: kTopics) as? [String: Int]) ?? [:]
        reorderClears = d.integer(forKey: kReorder)
    }

    private func todayString() -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    static func dateString(daysAgo: Int) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        let d = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        return f.string(from: d)
    }

    func recordPuzzleClear(topic: String) {
        totalSolved += 1
        solvedDates.insert(todayString())
        let mainTopic = topic.components(separatedBy: " / ").first ?? topic
        topicCounts[mainTopic, default: 0] += 1
        lastDate = todayString()
        persist()
    }

    func recordReorderClear() {
        reorderClears += 1
        solvedDates.insert(todayString())
        lastDate = todayString()
        persist()
    }

    /// 過去N日の active 状態（古い方から）
    func activity(days: Int) -> [Bool] {
        (0..<days).reversed().map { solvedDates.contains(Self.dateString(daysAgo: $0)) }
    }

    /// 一番得意なトピック（解いた数最大）
    var topTopic: (topic: String, count: Int)? {
        guard let kv = topicCounts.max(by: { $0.value < $1.value }) else { return nil }
        return (kv.key, kv.value)
    }

    private func persist() {
        let d = appDefaults
        d.set(totalSolved, forKey: kTotal)
        d.set(Array(solvedDates), forKey: kDates)
        d.set(topicCounts, forKey: kTopics)
        d.set(reorderClears, forKey: kReorder)
    }
}

// MARK: - Badges (④)

struct Badge: Identifiable, Hashable {
    let id: String
    let title: String
    let emoji: String
    let description: String
}

enum BadgeCatalog {
    static let all: [Badge] = [
        Badge(id: "first_clear",   title: "はじめての一歩", emoji: "🌱", description: "最初のパズルをクリア"),
        Badge(id: "streak_3",      title: "3日連続",       emoji: "🔥", description: "3日続けてクリア"),
        Badge(id: "streak_7",      title: "1週間達成",      emoji: "🌟", description: "7日連続クリア"),
        Badge(id: "reorder_first", title: "並べ替えデビュー", emoji: "📋", description: "並べ替えを初クリア"),
        Badge(id: "total_10",      title: "10問達成",      emoji: "🍪", description: "累計10問クリア"),
        Badge(id: "total_30",      title: "30問達成",      emoji: "🏅", description: "累計30問クリア"),
        Badge(id: "topic_5",       title: "得意分野",       emoji: "🎓", description: "同じトピックを5問クリア"),
    ]
    static func by(_ id: String) -> Badge? { all.first { $0.id == id } }
}

@MainActor
final class BadgeStore: ObservableObject {
    @Published private(set) var unlocked: Set<String>
    @Published var justUnlocked: Badge?

    private let key = "algobite.badges.unlocked"
    static let shared = BadgeStore()

    init() {
        let d = appDefaults
        unlocked = Set((d.array(forKey: key) as? [String]) ?? [])
    }

    func evaluate(stats: StatsStore, streak: Int) {
        var newOnes: [String] = []
        func add(_ id: String) {
            if !unlocked.contains(id) {
                unlocked.insert(id)
                newOnes.append(id)
            }
        }
        if stats.totalSolved >= 1  { add("first_clear")   }
        if stats.totalSolved >= 10 { add("total_10")      }
        if stats.totalSolved >= 30 { add("total_30")      }
        if streak >= 3             { add("streak_3")      }
        if streak >= 7             { add("streak_7")      }
        if stats.reorderClears >= 1 { add("reorder_first") }
        if stats.topicCounts.values.contains(where: { $0 >= 5 }) { add("topic_5") }

        if !newOnes.isEmpty {
            appDefaults.set(Array(unlocked), forKey: key)
            if let first = newOnes.first, let badge = BadgeCatalog.by(first) {
                justUnlocked = badge
                Haptics.success()
            }
        }
    }

    func dismissJustUnlocked() { justUnlocked = nil }
}

// MARK: - Hint Store (⑤)

enum HintLevel: Int, Comparable {
    case none = 0, gentle = 1, fillOne = 2, fillAll = 3
    static func < (l: HintLevel, r: HintLevel) -> Bool { l.rawValue < r.rawValue }
}

@MainActor
final class HintStore: ObservableObject {
    @Published var level: HintLevel = .none

    func reset() { level = .none }

    /// 次の段階を返す。fillAll に達したらそれ以上は進まない。
    func advance() -> HintLevel {
        switch level {
        case .none:    level = .gentle
        case .gentle:  level = .fillOne
        case .fillOne: level = .fillAll
        case .fillAll: break
        }
        return level
    }

    static func gentleText(for problem: PuzzleProblem) -> String {
        // トピック語をそのまま使う簡易ヒント。explanation の冒頭を抽出。
        if !problem.explanation.isEmpty {
            let first = problem.explanation
                .split(whereSeparator: { ".。!?！？\n".contains($0) })
                .first.map(String.init) ?? problem.explanation
            return "💭 \(first)"
        }
        return "💭 トピック「\(problem.topic)」の典型パターンを思い出してみよう"
    }
}

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

// MARK: - Reorder Quizzes (②) — 追加問題

extension ReorderQuiz {
    static let mergeSortMerge: ReorderQuiz = .init(
        id: "merge-sort-merge",
        title: "マージソートのマージ",
        topic: "ソート / マージソート",
        prompt: "ソート済みの2つの配列 [1, 4, 5] と [2, 3, 6] をマージした結果になるように、要素を順番にタップしてね。",
        pool: ["1","2","3","4","5","6"],
        answer: ["1","2","3","4","5","6"],
        explanation: "2つのソート済み配列の先頭を比較して小さい方から取り出していくと、O(n+m) でマージできる。"
    )

    static let selectionSortPass: ReorderQuiz = .init(
        id: "selection-sort-pass-1",
        title: "選択ソート 1パス目",
        topic: "ソート / 選択ソート",
        prompt: "配列 [5, 2, 4, 1, 3] から選択ソートを1パス実行した直後の配列を作ってね。",
        pool: ["1","2","3","4","5"],
        answer: ["1","2","4","5","3"],
        explanation: "未ソート部分 [5,2,4,1,3] の最小値は 1（index 3）。これを先頭の 5 と入れ替えるので [1, 2, 4, 5, 3] になる。"
    )

    static let bfsTraversal: ReorderQuiz = .init(
        id: "bfs-traversal",
        title: "BFS の訪問順",
        topic: "グラフ / BFS",
        prompt: "グラフを A から幅優先探索したときの訪問順を並べて。\n辺: A-B, A-C, B-D, C-E, D-F  (隣接リストはアルファベット順)",
        pool: ["A","B","C","D","E","F"],
        answer: ["A","B","C","D","E","F"],
        explanation: "BFSはキューで管理し、開始点から近い順に訪問する。同じ距離の場合は隣接リスト順。"
    )

    static let dfsTraversal: ReorderQuiz = .init(
        id: "dfs-traversal",
        title: "DFS の訪問順",
        topic: "グラフ / DFS",
        prompt: "同じグラフを A から深さ優先探索（隣接アルファベット順）したときの訪問順を並べて。\n辺: A-B, A-C, B-D, C-E, D-F",
        pool: ["A","B","C","D","E","F"],
        answer: ["A","B","D","F","C","E"],
        explanation: "DFSは「行けるところまで進んで戻る」。A→B→D→F まで行き、詰まったら戻って C→E。"
    )

    static let stackPushPop: ReorderQuiz = .init(
        id: "stack-push-pop",
        title: "スタックの中身",
        topic: "データ構造 / スタック",
        prompt: "空のスタックに push(1), push(2), push(3), pop, push(4) を実行した直後、上から順にスタックの中身を並べて。",
        pool: ["1","2","4"],
        answer: ["4","2","1"],
        explanation: "push(3)後に pop で 3 が消え、その後 push(4) で先頭が 4。下に向かって [4, 2, 1] となる。"
    )

    // MARK: - 追加 25 問

    static let insertionSortStep: ReorderQuiz = .init(
        id: "insertion-sort-step-1",
        title: "挿入ソート 1 ステップ",
        topic: "ソート / 挿入ソート",
        prompt: "配列 [5, 2, 4, 1, 3] で index=1 の要素 (2) を挿入ソートで正しい位置に挿入した直後。",
        pool: ["1","2","3","4","5"],
        answer: ["2","5","4","1","3"],
        explanation: "未ソート部分の左から見て、2 を 5 の前に差し込む。残りはそのまま。"
    )

    static let quicksortPartition: ReorderQuiz = .init(
        id: "quicksort-partition",
        title: "クイックソート partition",
        topic: "ソート / クイックソート",
        prompt: "配列 [3, 1, 4, 2] で pivot=2 (末尾) の Lomuto partition を1回実行した直後。",
        pool: ["1","2","3","4"],
        answer: ["1","2","4","3"],
        explanation: "Lomuto: 境界 i=-1 から走査し、pivot 未満を見つけたら i を進めて swap。j=1 で 1<2 → i=0, swap a[0]↔a[1] で [1,3,4,2]。最後に a[i+1=1] と pivot a[末尾] を swap して [1,2,4,3]。(Hoare partition だと別配置になる点に注意)"
    )

    static let minHeapInsert: ReorderQuiz = .init(
        id: "min-heap-insert",
        title: "Min-heap への挿入",
        topic: "データ構造 / ヒープ",
        prompt: "空の min-heap に 5, 3, 8, 1, 4 を順に挿入した直後、配列表現 (level order) を並べて。",
        pool: ["1","3","4","5","8"],
        answer: ["1","3","8","5","4"],
        explanation: "挿入のたび parent と比較して swap up。最終的に root が最小、各 parent ≤ children を満たす形に整う。"
    )

    static let binarySearchVisits: ReorderQuiz = .init(
        id: "binary-search-visits",
        title: "二分探索の訪問インデックス",
        topic: "二分探索",
        prompt: "ソート済 [1, 3, 5, 7, 9, 11, 13] で target=11 を二分探索した時、訪問する index を訪問順に並べて。",
        pool: ["0","1","2","3","4","5","6"],
        answer: ["3","5"],
        explanation: "L=0,R=6 → M=3 (値 7、target>7 で右へ)、L=4,R=6 → M=5 (値 11、ヒット)。"
    )

    static let treePreorder: ReorderQuiz = .init(
        id: "tree-preorder",
        title: "二分木 preorder",
        topic: "木 / DFS",
        prompt: "下記の木を preorder (NLR) で訪問した順:\n         A\n        / \\\n       B   C\n      / \\   \\\n     D   E   F",
        pool: ["A","B","C","D","E","F"],
        answer: ["A","B","D","E","C","F"],
        explanation: "Node→Left→Right の順。再帰: visit(A) → preorder(B) → preorder(C)。"
    )

    static let treeInorder: ReorderQuiz = .init(
        id: "tree-inorder",
        title: "二分木 inorder",
        topic: "木 / DFS",
        prompt: "上と同じ木を inorder (LNR) で訪問した順を並べて。",
        pool: ["A","B","C","D","E","F"],
        answer: ["D","B","E","A","C","F"],
        explanation: "Left→Node→Right。BST なら昇順になる性質と同じ走査順序。"
    )

    static let treePostorder: ReorderQuiz = .init(
        id: "tree-postorder",
        title: "二分木 postorder",
        topic: "木 / DFS",
        prompt: "上と同じ木を postorder (LRN) で訪問した順を並べて。",
        pool: ["A","B","C","D","E","F"],
        answer: ["D","E","B","F","C","A"],
        explanation: "Left→Right→Node。子をすべて処理してから親、ボトムアップに使う。"
    )

    static let treeLevelOrder: ReorderQuiz = .init(
        id: "tree-level-order",
        title: "二分木 level order",
        topic: "木 / BFS",
        prompt: "上と同じ木を level order (深さ順) で訪問した結果を並べて。",
        pool: ["A","B","C","D","E","F"],
        answer: ["A","B","C","D","E","F"],
        explanation: "BFS と同じ。キューで管理し、深さの浅い順に出していく。"
    )

    static let dijkstraOrder: ReorderQuiz = .init(
        id: "dijkstra-finalize-order",
        title: "ダイクストラの確定順",
        topic: "グラフ / ダイクストラ",
        prompt: "辺 A-B(2), A-C(5), B-C(1), B-D(4), C-D(2) で A からの最短距離が確定する順を並べて。",
        pool: ["A","B","C","D"],
        answer: ["A","B","C","D"],
        explanation: "距離 0,2,3,5 の順に確定。C は A→B→C=3 が更新されてから確定する。"
    )

    static let topologicalSort: ReorderQuiz = .init(
        id: "topological-sort",
        title: "トポロジカルソート",
        topic: "グラフ / DAG",
        prompt: "DAG: A→B, A→C, B→D, C→D, D→E を Kahn (BFS、入次数 0 をアルファベット順) で出力した順。",
        pool: ["A","B","C","D","E"],
        answer: ["A","B","C","D","E"],
        explanation: "入次数 0 の A をキューに、次に B/C、両方処理後に D の入次数が 0 になり、最後 E。"
    )

    static let queueOps: ReorderQuiz = .init(
        id: "queue-enqueue-dequeue",
        title: "キューの中身",
        topic: "データ構造 / キュー",
        prompt: "空のキューに enqueue(1), enqueue(2), enqueue(3), dequeue, enqueue(4) を実行した直後、front から rear へ並べて。",
        pool: ["1","2","3","4"],
        answer: ["2","3","4"],
        explanation: "FIFO。dequeue で先頭の 1 が消え、enqueue(4) で末尾に 4 が追加されて [2,3,4]。"
    )

    static let dequeBothEnds: ReorderQuiz = .init(
        id: "deque-both-ends",
        title: "デックの両端操作",
        topic: "データ構造 / デック",
        prompt: "空の deque に push_front(1), push_back(2), push_front(3), pop_back を順に実行した直後、front から back へ並べて。",
        pool: ["1","2","3","4"],
        answer: ["3","1"],
        explanation: "[1] → [1,2] → [3,1,2] → 末尾 2 を pop → [3,1]。"
    )

    static let hanoi2Disks: ReorderQuiz = .init(
        id: "hanoi-2-disks",
        title: "ハノイの塔 (2 枚)",
        topic: "再帰 / ハノイ",
        prompt: "円盤 2 枚を A→C へ移動する手順 (最短 3 手) を並べて。",
        pool: ["A→B","A→C","B→A","B→C","C→A","C→B"],
        answer: ["A→B","A→C","B→C"],
        explanation: "上の円盤を退避先 B へ、大円盤を C へ、退避した円盤を C へ重ねる。"
    )

    static let fibMemoOrder: ReorderQuiz = .init(
        id: "fib-memo-order",
        title: "fib(5) memo の確定順",
        topic: "DP / メモ化",
        prompt: "fib(5) をメモ化再帰で計算した時、memo[n] が確定する順 (n) を並べて (fib(0)=0, fib(1)=1 は base)。",
        pool: ["2","3","4","5"],
        answer: ["2","3","4","5"],
        explanation: "DFS で fib(2) まで降りて戻りながら確定。一度 memo に入れたら再計算しない。"
    )

    static let lisDpValues: ReorderQuiz = .init(
        id: "lis-dp-values",
        title: "LIS の dp 値",
        topic: "DP / LIS",
        prompt: "配列 [3, 1, 4, 1, 5] の LIS dp[i] (i 番目で終わる増加部分列の長さ) を i=0 から順に並べて。",
        pool: ["1","1","1","2","3"],
        answer: ["1","1","2","1","3"],
        explanation: "dp = [1,1,2,1,3]。例えば dp[2]=2 は (1→4 または 3→4)、dp[4]=3 は (1→4→5 など)。"
    )

    static let stringReverse: ReorderQuiz = .init(
        id: "string-reverse",
        title: "文字列を反転",
        topic: "文字列 / 反転",
        prompt: "'hello' を 2 ポインタで in-place 反転した結果を文字単位で並べて。",
        pool: ["e","h","l","l","o"],
        answer: ["o","l","l","e","h"],
        explanation: "i=0,j=4 swap → olllh → i=1,j=3 swap → olleh。中央 (l) はそのまま。"
    )

    static let permutationsLex: ReorderQuiz = .init(
        id: "permutations-lex",
        title: "Permutations 辞書順",
        topic: "バックトラック / 順列",
        prompt: "[1, 2, 3] のすべての順列を辞書順に並べて。",
        pool: ["123","132","213","231","312","321"],
        answer: ["123","132","213","231","312","321"],
        explanation: "next_permutation を繰り返すと辞書順に列挙される。6 通り = 3!"
    )

    static let factorialReturnOrder: ReorderQuiz = .init(
        id: "factorial-return-order",
        title: "fact(4) の戻り値順",
        topic: "再帰 / コールスタック",
        prompt: "fact(4) を再帰で評価した時、return される値の順を並べて。",
        pool: ["1","2","6","24"],
        answer: ["1","2","6","24"],
        explanation: "深い呼び出しから先に戻る: fact(1)=1, fact(2)=2, fact(3)=6, fact(4)=24。"
    )

    static let bubbleSortFullPass: ReorderQuiz = .init(
        id: "bubble-sort-2-passes",
        title: "バブルソート 2 パス目",
        topic: "ソート / バブルソート",
        prompt: "[5, 2, 4, 1, 3] にバブルソートを 2 パス実行した直後。",
        pool: ["1","2","3","4","5"],
        answer: ["2","1","3","4","5"],
        explanation: "1 パス目: [2,4,1,3,5]、2 パス目: [2,1,3,4,5]。最大 2 つが右端に固定される。"
    )

    static let countingSortCount: ReorderQuiz = .init(
        id: "counting-sort-count",
        title: "Counting sort の度数表",
        topic: "ソート / counting sort",
        prompt: "[1, 3, 1, 2, 3] の counting sort で count[i] (i=0..4) を順に並べて。",
        pool: ["0","0","1","2","2"],
        answer: ["0","2","1","2","0"],
        explanation: "値 0 が 0 回、1 が 2 回、2 が 1 回、3 が 2 回、4 が 0 回。"
    )

    static let kmpFailure: ReorderQuiz = .init(
        id: "kmp-failure",
        title: "KMP failure 関数",
        topic: "文字列 / KMP",
        prompt: "pattern = 'abab' の failure 関数 fail[i] を i=0,1,2,3 の順に並べて。",
        pool: ["0","0","1","2"],
        answer: ["0","0","1","2"],
        explanation: "fail[i] は接頭辞=接尾辞となる最大長。'a'→0, 'ab'→0, 'aba'→1, 'abab'→2。"
    )

    static let unionFindMerge: ReorderQuiz = .init(
        id: "union-find-merge",
        title: "Union-Find の代表元",
        topic: "グラフ / Union Find",
        prompt: "5 要素 (0..4) に union(0,1), union(2,3), union(1,3) を順に適用した後、各要素の代表元 (root) を 0,1,2,3,4 の順に並べて。\n注: union(a,b) では a の root を b の root の親にする (= 左側の root が親になる) ルール、path compression あり。",
        pool: ["0","0","0","0","4"],
        answer: ["0","0","0","0","4"],
        explanation: "union(0,1): root(1)=1 の親を root(0)=0 にする → {0,1} 全部 root 0。union(2,3): {2,3} 全部 root 2。union(1,3): root(3)=2 の親を root(1)=0 にする → 全要素 (4 以外) が root 0 に統合。4 は単独なので root 4。"
    )

    static let mergeSortSplitMerge: ReorderQuiz = .init(
        id: "merge-sort-merge-step",
        title: "マージソートの最終マージ",
        topic: "ソート / マージソート",
        prompt: "ソート済 [2, 4] と [1, 3, 5] をマージした結果を並べて。",
        pool: ["1","2","3","4","5"],
        answer: ["1","2","3","4","5"],
        explanation: "両端を比較して小さい方を出す: 2 vs 1 → 1, 2 vs 3 → 2, 4 vs 3 → 3, 4 vs 5 → 4, 5。"
    )

    static let heapSortRemoveMin: ReorderQuiz = .init(
        id: "heap-sort-extract",
        title: "Min-heap から取り出し順",
        topic: "ソート / ヒープソート",
        prompt: "min-heap = [1, 3, 8, 5, 4] から extract-min を繰り返した時、取り出される順を並べて。",
        pool: ["1","3","4","5","8"],
        answer: ["1","3","4","5","8"],
        explanation: "毎回 root (最小) が取り出され、ヒープ全体が再構成される。結果は昇順。"
    )

    static let bfsLevelDistances: ReorderQuiz = .init(
        id: "bfs-distances",
        title: "BFS の距離",
        topic: "グラフ / BFS",
        prompt: "辺 A-B, A-C, B-D, C-E, D-F で A から BFS した時、各ノードまでの距離を A,B,C,D,E,F の順に並べて。",
        pool: ["0","1","1","2","2","3"],
        answer: ["0","1","1","2","2","3"],
        explanation: "A=0, B/C=1, D/E=2, F=3。BFS は距離の浅い順に確定。"
    )

    static let allList: [ReorderQuiz] = [
        // 既存
        .bubbleSortPass,
        .selectionSortPass,
        .mergeSortMerge,
        .bfsTraversal,
        .dfsTraversal,
        .stackPushPop,
        // 追加: ソート
        .insertionSortStep,
        .quicksortPartition,
        .bubbleSortFullPass,
        .countingSortCount,
        .mergeSortSplitMerge,
        .heapSortRemoveMin,
        // データ構造
        .minHeapInsert,
        .queueOps,
        .dequeBothEnds,
        // 探索
        .binarySearchVisits,
        // 木
        .treePreorder,
        .treeInorder,
        .treePostorder,
        .treeLevelOrder,
        // グラフ
        .dijkstraOrder,
        .topologicalSort,
        .unionFindMerge,
        .bfsLevelDistances,
        // 再帰 / 順列 / DP
        .hanoi2Disks,
        .fibMemoOrder,
        .lisDpValues,
        .permutationsLex,
        .factorialReturnOrder,
        // 文字列
        .stringReverse,
        .kmpFailure,
    ]

    var emoji: String {
        switch id {
        // 既存
        case "bubble-sort-pass-1":     return "🫧"
        case "selection-sort-pass-1":  return "👉"
        case "merge-sort-merge":       return "🧩"
        case "bfs-traversal":          return "🌊"
        case "dfs-traversal":          return "🕳️"
        case "stack-push-pop":         return "📚"
        // 追加
        case "insertion-sort-step-1":  return "📥"
        case "quicksort-partition":    return "⚡"
        case "bubble-sort-2-passes":   return "🫧"
        case "counting-sort-count":    return "🔢"
        case "merge-sort-merge-step":  return "🔀"
        case "heap-sort-extract":      return "⛰️"
        case "min-heap-insert":        return "🏔️"
        case "queue-enqueue-dequeue":  return "🚌"
        case "deque-both-ends":        return "↔️"
        case "binary-search-visits":   return "🎯"
        case "tree-preorder":          return "🌲"
        case "tree-inorder":           return "🌳"
        case "tree-postorder":         return "🌴"
        case "tree-level-order":       return "🪴"
        case "dijkstra-finalize-order":return "🛣️"
        case "topological-sort":       return "🪜"
        case "union-find-merge":       return "🧷"
        case "bfs-distances":          return "📏"
        case "hanoi-2-disks":          return "🗼"
        case "fib-memo-order":         return "🐚"
        case "lis-dp-values":          return "📈"
        case "permutations-lex":       return "🔄"
        case "factorial-return-order": return "↩️"
        case "string-reverse":         return "🔃"
        case "kmp-failure":            return "🧵"
        default:                       return "📋"
        }
    }
}

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
                        .background(Color(red: 0.99, green: 0.90, blue: 0.52), in: Capsule())
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
                            .background(Color(red: 0.99, green: 0.90, blue: 0.52), in: Capsule())
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

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
                .onTapGesture { onDismiss() }
            VStack(spacing: 14) {
                Text("🎉 バッジ解放！")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Pop.inkWarm)
                Text(badge.emoji).font(.system(size: 72))
                Text(badge.title)
                    .font(.title2.weight(.black))
                    .foregroundStyle(Pop.ink)
                Text(badge.description)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Pop.inkSub)
                    .multilineTextAlignment(.center)
                PopButton(fill: Pop.primary, shadow: Pop.primaryShadow, action: onDismiss) {
                    Text("やった！").font(.subheadline.weight(.heavy))
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
    }
}

// MARK: - Reorder Quiz List (②)

struct ReorderQuizListView: View {
    let onPick: (ReorderQuiz) -> Void

    var body: some View {
        ZStack {
            LinearGradient(colors: [Pop.bgNeutralTop, Pop.bgNeutralBottom],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(ReorderQuiz.allList) { q in
                        Button { onPick(q) } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.96, green: 0.93, blue: 1.00))
                                        .frame(width: 50, height: 50)
                                    Text(q.emoji).font(.system(size: 28))
                                }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(q.title)
                                        .font(.subheadline.weight(.black))
                                        .foregroundStyle(Pop.ink)
                                    Text(q.topic)
                                        .font(.caption2.weight(.heavy))
                                        .foregroundStyle(Color(red: 0.31, green: 0.27, blue: 0.90))
                                }
                                Spacer()
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color(red: 0.55, green: 0.49, blue: 0.92))
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .background(.white, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 0.87, green: 0.84, blue: 0.99), lineWidth: 1.5))
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(TapGesture().onEnded { Haptics.light() })
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("並べ替え練習")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Review Mode (⑥)

/// 復習用のミニ ViewModel。日次の進捗には影響しない。
@MainActor
final class PracticeSession: ObservableObject {
    let problem: PuzzleProblem
    @Published var answers: [String: String] = [:]
    @Published var activeSlotID: String?
    @Published var slotStates: [String: SlotCheckState] = [:]
    @Published var shakeTrigger: [String: Int] = [:]
    @Published var isCompleted = false
    @Published var attemptCount = 0
    @Published var logMessage = ""

    init(problem: PuzzleProblem) {
        self.problem = problem
    }

    var resultMood: ResultMood {
        if isCompleted { return .success }
        if slotStates.values.contains(.wrong) { return .fail }
        return .neutral
    }

    func selectSlot(_ id: String) {
        activeSlotID = id
        slotStates = [:]
        Haptics.light()
    }

    func fillChoice(_ choice: String) {
        guard let id = activeSlotID else { return }
        answers[id] = choice
        slotStates = [:]
        Haptics.selection()
        // 次の空きへ
        let ids = problem.orderedSlotIDs
        if let idx = ids.firstIndex(of: id) {
            for off in 1..<ids.count {
                let next = ids[(idx + off) % ids.count]
                if answers[next]?.isEmpty != false { activeSlotID = next; return }
            }
        }
    }

    func reset() {
        answers = [:]; activeSlotID = nil; slotStates = [:]
        isCompleted = false; logMessage = ""
    }

    func runCheck() {
        slotStates = [:]
        attemptCount += 1
        let ids = problem.orderedSlotIDs
        let empty = ids.filter { answers[$0]?.isEmpty != false }
        if !empty.isEmpty {
            for id in empty { slotStates[id] = .wrong }
            logMessage = "未入力スロットが \(empty.count) 個あります"
            Haptics.warning()
            return
        }
        var wrong: [String] = []
        for id in ids {
            let ok = answers[id] == problem.slots[id]?.answer
            slotStates[id] = ok ? .correct : .wrong
            if !ok { wrong.append(id) }
        }
        if wrong.isEmpty {
            isCompleted = true
            logMessage = "PASS 🎉 復習クリア！"
            Haptics.success()
        } else {
            let labels = wrong.compactMap { problem.slots[$0]?.label }.joined(separator: " / ")
            logMessage = "FAIL: \(labels)"
            Haptics.error()
            for id in wrong { shakeTrigger[id, default: 0] += 1 }
            let wrongIDs = wrong
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
                guard let self else { return }
                for id in wrongIDs {
                    self.slotStates[id] = .idle
                    self.answers[id] = nil
                }
            }
        }
    }

    func segments(for line: String) -> [CodeSegment] {
        var segs: [CodeSegment] = []
        var cur = line.startIndex
        for match in line.matches(of: /\{\{(.*?)\}\}/) {
            if cur < match.range.lowerBound {
                segs.append(.text(String(line[cur..<match.range.lowerBound])))
            }
            segs.append(.slot(String(match.1)))
            cur = match.range.upperBound
        }
        if cur < line.endIndex { segs.append(.text(String(line[cur...]))) }
        return segs
    }
}

struct ReviewListView: View {
    let problems: [PuzzleProblem]
    let onPick: (PuzzleProblem) -> Void

    var body: some View {
        ZStack {
            LinearGradient(colors: [Pop.bgNeutralTop, Pop.bgNeutralBottom],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(problems) { p in
                        Button { onPick(p) } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(p.title)
                                        .font(.subheadline.weight(.black))
                                        .foregroundStyle(Pop.ink)
                                    Spacer()
                                    Text("★ \(p.difficulty)")
                                        .font(.caption2.weight(.heavy))
                                        .padding(.horizontal, 8).padding(.vertical, 3)
                                        .background(diffBg(p.difficulty), in: Capsule())
                                        .foregroundStyle(diffFg(p.difficulty))
                                }
                                Text(p.topic)
                                    .font(.caption2.weight(.heavy))
                                    .foregroundStyle(Color(red: 0.31, green: 0.27, blue: 0.90))
                                Text(p.prompt)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Pop.inkSub)
                                    .lineLimit(2)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white, in: RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(red: 0.78, green: 0.82, blue: 0.99), lineWidth: 1.2))
                            .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(TapGesture().onEnded { Haptics.light() })
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("復習モード")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func diffBg(_ d: String) -> Color {
        switch d {
        case "Easy": return Color(red: 0.73, green: 0.97, blue: 0.82)
        case "Hard": return Color(red: 1.00, green: 0.78, blue: 0.78)
        default:     return Color(red: 1.00, green: 0.93, blue: 0.72)
        }
    }
    private func diffFg(_ d: String) -> Color {
        switch d {
        case "Easy": return Color(red: 0.08, green: 0.32, blue: 0.18)
        case "Hard": return Color(red: 0.50, green: 0.11, blue: 0.11)
        default:     return Color(red: 0.57, green: 0.25, blue: 0.05)
        }
    }
}

struct PracticeView: View {
    @StateObject var session: PracticeSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            screenBg
            ScrollView {
                VStack(spacing: 14) {
                    promptCard
                    codeBlock
                    if session.isCompleted {
                        completionCard
                    } else {
                        answersPanel
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("復習: " + session.problem.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var screenBg: some View {
        let (top, bottom): (Color, Color) = {
            switch session.resultMood {
            case .success: return (Pop.bgSuccessTop, Pop.bgSuccessBottom)
            case .fail:    return (Pop.bgFailTop,    Pop.bgFailBottom)
            case .neutral: return (Pop.bgNeutralTop, Pop.bgNeutralBottom)
            }
        }()
        return LinearGradient(colors: [top, bottom],
                              startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.35), value: session.resultMood)
    }

    private var promptCard: some View {
        PopCard(fill: Pop.surface,
                border: Color(red: 0.78, green: 0.82, blue: 0.99)) {
            VStack(alignment: .leading, spacing: 8) {
                Text("📖 復習問題")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Color(red: 0.31, green: 0.27, blue: 0.90))
                Text(session.problem.title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(Pop.ink)
                Text(session.problem.prompt)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Pop.inkSub)
                Text(session.problem.example)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Pop.inkSub)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.96, green: 0.97, blue: 1.00),
                                in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var codeBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(session.problem.template.enumerated()), id: \.offset) { _, line in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(session.segments(for: line).enumerated()), id: \.offset) { _, seg in
                            segView(seg)
                        }
                    }
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(Color(red: 0.86, green: 0.89, blue: 0.97))
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.12, green: 0.11, blue: 0.29),
                    in: RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private func segView(_ seg: CodeSegment) -> some View {
        switch seg {
        case .text(let t): Text(t)
        case .slot(let id):
            let val = session.answers[id] ?? "___"
            let active = session.activeSlotID == id
            let state = session.slotStates[id] ?? .idle
            let shakes = session.shakeTrigger[id] ?? 0
            let (bg, border, fg) = slotColors(active: active, state: state)
            Button { session.selectSlot(id) } label: {
                Text(val)
                    .font(.system(size: 13, weight: .heavy, design: .monospaced))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(bg, in: RoundedRectangle(cornerRadius: 7))
                    .overlay(RoundedRectangle(cornerRadius: 7)
                        .stroke(border, style: StrokeStyle(lineWidth: 1.5,
                                                           dash: state == .idle ? [3, 3] : [])))
                    .foregroundStyle(fg)
            }
            .buttonStyle(.plain)
            .disabled(session.isCompleted)
            .modifier(ShakeEffect(animatableData: CGFloat(shakes)))
            .animation(.easeInOut(duration: 0.55), value: shakes)
        }
    }

    private func slotColors(active: Bool, state: SlotCheckState) -> (Color, Color, Color) {
        switch state {
        case .correct:
            return (Color(red: 0.73, green: 0.97, blue: 0.82),
                    Color(red: 0.13, green: 0.77, blue: 0.37),
                    Color(red: 0.08, green: 0.32, blue: 0.18))
        case .wrong:
            return (Color(red: 1.00, green: 0.78, blue: 0.78),
                    Pop.danger,
                    Color(red: 0.50, green: 0.11, blue: 0.11))
        case .idle:
            let bg: Color = active
                ? Color(red: 1.00, green: 0.94, blue: 0.54)
                : Color.white.opacity(0.08)
            let border: Color = active
                ? Color(red: 0.92, green: 0.70, blue: 0.03)
                : Color.white.opacity(0.30)
            return (bg, border, Color(red: 0.86, green: 0.89, blue: 0.97))
        }
    }

    private var answersPanel: some View {
        PopCard(fill: Pop.surface,
                border: Color(red: 0.87, green: 0.84, blue: 0.99)) {
            VStack(alignment: .leading, spacing: 12) {
                if let slot = session.problem.slots[session.activeSlotID ?? ""] {
                    Text("選択中: \(slot.label)")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Pop.inkSub)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Array(slot.choices.enumerated()), id: \.offset) { i, c in
                                Button {
                                    session.fillChoice(c)
                                } label: {
                                    Text(c)
                                        .font(.system(size: 14, weight: .heavy, design: .monospaced))
                                        .padding(.horizontal, 14).padding(.vertical, 9)
                                        .background(choicePalette(i).0, in: Capsule())
                                        .foregroundStyle(choicePalette(i).1)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(minHeight: 44)
                } else {
                    Text("↑ スロット（___）をタップしてね")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Pop.inkSub)
                }

                PopButton(fill: Pop.primary, shadow: Pop.primaryShadow,
                          action: { session.runCheck() }) {
                    Text("こたえる！")
                        .font(.headline.weight(.black))
                }

                if !session.logMessage.isEmpty {
                    Text(session.logMessage)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(session.resultMood == .fail ? Pop.danger : Pop.inkSub)
                }
            }
        }
    }

    private func choicePalette(_ i: Int) -> (Color, Color) {
        let p: [(Color, Color)] = [
            (Color(red: 0.65, green: 0.95, blue: 0.82), Color(red: 0.02, green: 0.37, blue: 0.27)),
            (Color(red: 0.98, green: 0.81, blue: 0.91), Color(red: 0.62, green: 0.09, blue: 0.30)),
            (Color(red: 0.75, green: 0.86, blue: 1.00), Color(red: 0.12, green: 0.23, blue: 0.54)),
            (Color(red: 1.00, green: 0.84, blue: 0.84), Color(red: 0.50, green: 0.11, blue: 0.11)),
            (Color(red: 0.73, green: 0.97, blue: 0.82), Color(red: 0.08, green: 0.32, blue: 0.18)),
            (Color(red: 0.87, green: 0.84, blue: 0.99), Color(red: 0.30, green: 0.11, blue: 0.58)),
        ]
        return p[i % p.count]
    }

    private var completionCard: some View {
        PopCard(fill: Pop.surfaceMint,
                border: Color(red: 0.13, green: 0.77, blue: 0.37)) {
            VStack(spacing: 14) {
                HStack(spacing: 6) {
                    Text("🎉").font(.system(size: 36))
                    Text("復習クリア！")
                        .font(.title2.weight(.black))
                        .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
                }
                Text("✨ \(session.attemptCount) 回でクリア ✨")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
                if !session.problem.explanation.isEmpty {
                    Text(session.problem.explanation)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
                        .multilineTextAlignment(.leading)
                }
                PopButton(fill: Pop.primary, shadow: Pop.primaryShadow,
                          action: { session.reset() }) {
                    Text("もう一回やる")
                        .font(.subheadline.weight(.heavy))
                }
            }
        }
    }
}
