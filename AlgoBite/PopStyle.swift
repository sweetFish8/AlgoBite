import SwiftUI

enum Pop {
    // 背景グラデーション (dark はディープウォーム)
    static let bgNeutralTop = Color.dyn(
        light: Color(red: 1.00, green: 0.97, blue: 0.93),
        dark:  Color(red: 0.18, green: 0.13, blue: 0.16))
    static let bgNeutralBottom = Color.dyn(
        light: Color(red: 1.00, green: 0.89, blue: 0.89),
        dark:  Color(red: 0.13, green: 0.09, blue: 0.13))
    static let bgSuccessTop = Color.dyn(
        light: Color(red: 0.86, green: 0.99, blue: 0.91),
        dark:  Color(red: 0.07, green: 0.21, blue: 0.13))
    static let bgSuccessBottom = Color.dyn(
        light: Color(red: 0.73, green: 0.97, blue: 0.82),
        dark:  Color(red: 0.05, green: 0.15, blue: 0.10))
    static let bgFailTop = Color.dyn(
        light: Color(red: 1.00, green: 0.84, blue: 0.84),
        dark:  Color(red: 0.28, green: 0.10, blue: 0.13))
    static let bgFailBottom = Color.dyn(
        light: Color(red: 0.99, green: 0.84, blue: 0.67),
        dark:  Color(red: 0.22, green: 0.10, blue: 0.08))

    // カード面 (旧 .white と各パステル fill の置換)
    static let surface = Color.dyn(
        light: .white,
        dark:  Color(red: 0.16, green: 0.14, blue: 0.18))
    static let surfaceCream = Color.dyn(
        light: Color(red: 1.00, green: 0.97, blue: 0.93),
        dark:  Color(red: 0.22, green: 0.17, blue: 0.20))
    static let surfaceMint = Color.dyn(
        light: Color(red: 0.86, green: 0.99, blue: 0.91),
        dark:  Color(red: 0.10, green: 0.22, blue: 0.15))
    static let surfaceLavender = Color.dyn(
        light: Color(red: 0.98, green: 0.96, blue: 1.00),
        dark:  Color(red: 0.18, green: 0.16, blue: 0.26))

    // メインカラー (高彩度なので両モード共通)
    static let primary       = Color(red: 0.35, green: 0.80, blue: 0.01)  // Duolingo Green #58CC02
    static let primaryShadow = Color(red: 0.27, green: 0.64, blue: 0.01)  // #46A302
    static let accent        = Color(red: 0.96, green: 0.62, blue: 0.04)  // #F59E0B
    static let accentShadow  = Color(red: 0.84, green: 0.46, blue: 0.05)  // #D97706
    static let danger        = Color(red: 0.94, green: 0.27, blue: 0.27)  // #EF4444
    static let dangerShadow  = Color(red: 0.72, green: 0.11, blue: 0.11)  // #B91C1C
    static let navTint       = Color(red: 0.39, green: 0.40, blue: 0.95)  // #6366F1

    // 枠線 (カードのデフォルト枠)
    static let borderDefault = Color(red: 0.93, green: 0.91, blue: 0.97)   // lavender #EDE9F7
    static let borderWarm    = Color(red: 0.99, green: 0.73, blue: 0.45)   // #FDBA74

    // スロット / 選択肢の状態色
    static let correctBg     = Color(red: 0.73, green: 0.97, blue: 0.82)   // #BBF7D0
    static let correctFg     = Color(red: 0.08, green: 0.32, blue: 0.18)   // dark green
    static let correctBorder = Color(red: 0.13, green: 0.77, blue: 0.37)   // #22C55E
    static let wrongBg       = Color(red: 1.00, green: 0.78, blue: 0.78)   // #FECACA
    static let wrongFg       = Color(red: 0.50, green: 0.11, blue: 0.11)   // dark red

    // テキスト
    static let ink = Color.dyn(
        light: Color(red: 0.17, green: 0.18, blue: 0.20),
        dark:  Color(red: 0.97, green: 0.95, blue: 0.92))
    static let inkSub = Color.dyn(
        light: Color(red: 0.42, green: 0.42, blue: 0.46),
        dark:  Color(red: 0.74, green: 0.72, blue: 0.70))

    // 温色系テキスト (#7C2D12 / #9A3412 / #92400E などをまとめて吸収)
    static let inkWarm = Color.dyn(
        light: Color(red: 0.49, green: 0.18, blue: 0.07),
        dark:  Color(red: 1.00, green: 0.87, blue: 0.70))
    static let inkWarmSub = Color.dyn(
        light: Color(red: 0.60, green: 0.20, blue: 0.07),
        dark:  Color(red: 0.95, green: 0.80, blue: 0.60))
}

/// Duolingo風の3D影付きボタン (下に offsetY 分のシャドウ層)
struct PopButton<Label: View>: View {
    let action: () -> Void
    let fill: Color
    let shadow: Color
    let radius: CGFloat
    let externalShine: Int
    let label: () -> Label
    @State private var pressed = false
    @State private var shineTrigger = 0

    init(fill: Color = Pop.accent,
         shadow: Color = Pop.accentShadow,
         radius: CGFloat = 16,
         externalShine: Int = 0,
         action: @escaping () -> Void,
         @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.fill = fill
        self.shadow = shadow
        self.radius = radius
        self.externalShine = externalShine
        self.label = label
    }

    var body: some View {
        Button {
            SoundFX.tap()
            shineTrigger += 1
            action()
        } label: {
            label()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(fill, in: RoundedRectangle(cornerRadius: radius))
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: radius)
                .fill(shadow)
                .offset(y: pressed ? 1 : 4)
        )
        .offset(y: pressed ? 3 : 0)
        .overlay(RadialShine(trigger: shineTrigger + externalShine).allowsHitTesting(false))
        ._onButtonGesture(pressing: { pressed = $0 }, perform: {})
    }
}

/// ボタンタップ時に中心から放射状にキラッと光る演出
struct RadialShine: View {
    var trigger: Int
    @State private var animate = false
    private let rayCount = 12

    var body: some View {
        ZStack {
            // 中心のリング
            Circle()
                .stroke(.white, lineWidth: 3)
                .frame(width: 36, height: 36)
                .scaleEffect(animate ? 2.0 : 0.3)
            // 放射状の光線
            ForEach(0..<rayCount, id: \.self) { i in
                Capsule()
                    .fill(.white)
                    .frame(width: 3, height: 12)
                    .offset(y: animate ? -30 : -8)
                    .rotationEffect(.degrees(Double(i) / Double(rayCount) * 360))
            }
            .scaleEffect(animate ? 1.1 : 0.4)
        }
        .opacity(animate ? 0 : 0.95)
        .blendMode(.plusLighter)
        .onChange(of: trigger) { _, _ in
            animate = false
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.5)) { animate = true }
            }
        }
    }
}

// SwiftUI 標準にない `_onButtonGesture` を簡易模倣 — pressing state を取れるよう薄く包む
extension View {
    fileprivate func _onButtonGesture(pressing: @escaping (Bool) -> Void,
                                       perform action: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressing(true) }
                .onEnded   { _ in pressing(false); action() }
        )
    }
}

/// ポップな影付きカード
struct PopCard<Content: View>: View {
    let fill: Color
    let border: Color
    let radius: CGFloat
    let content: () -> Content

    init(fill: Color = .white,
         border: Color = Color(red: 0.93, green: 0.91, blue: 0.97),
         radius: CGFloat = 18,
         @ViewBuilder content: @escaping () -> Content) {
        self.fill = fill
        self.border = border
        self.radius = radius
        self.content = content
    }

    var body: some View {
        content()
            .padding(18)
            .background(fill, in: RoundedRectangle(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(border, lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}
