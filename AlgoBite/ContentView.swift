import SwiftUI

struct ContentView: View {
    @StateObject private var vm = GameViewModel()
    @State private var showShareSheet = false
    @State private var path: [AppScreen] = {
        #if DEBUG
        return DebugCapture.initialPath()
        #else
        return []
        #endif
    }()
    @State private var showOnboarding: Bool = !appDefaults.bool(forKey: "algobite.onboarded")

    var body: some View {
        ZStack {
            NavigationStack(path: $path) {
                homeScreen
                    .navigationDestination(for: AppScreen.self) { screen in
                        switch screen {
                        case .problem:
                            problemScreen
                        case .reorder(let q):
                            appBackButton {
                                ReorderQuizView(model: ReorderQuizViewModel(quiz: q),
                                                onNext: { next in
                                                    // パスを差し替えて新しいクイズへ移動
                                                    if let lastIdx = path.lastIndex(where: {
                                                        if case .reorder = $0 { return true } else { return false }
                                                    }) {
                                                        path[lastIdx] = .reorder(next)
                                                    }
                                                })
                            }
                        case .dailyReorder(let q):
                            appBackButton {
                                ReorderQuizView(model: ReorderQuizViewModel(quiz: q, isDaily: true),
                                                onNext: nil,
                                                onDailyCleared: { vm.markDailyReorderCleared() })
                            }
                        case .reorderList:
                            appBackButton {
                                ReorderQuizListView { q in
                                    path.append(.reorder(q))
                                }
                            }
                        case .review:
                            appBackButton {
                                ReviewListView(problems: vm.problems) { p in
                                    path.append(.practice(p))
                                }
                            }
                        case .practice(let p):
                            appBackButton {
                                PracticeView(session: PracticeSession(problem: p))
                            }
                        case .achievements:
                            appBackButton {
                                AchievementsView(stats: vm.stats, badges: vm.badges)
                            }
                        case .settings:
                            appBackButton {
                                SettingsView()
                            }
                        }
                    }
            }
            .tint(Pop.navTint)
            // ④ バッジ解放オーバーレイ
            if let badge = vm.badges.justUnlocked {
                BadgeUnlockOverlay(badge: badge) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        vm.badges.dismissJustUnlocked()
                    }
                }
                .zIndex(10)
            }
            // 初回起動時のオンボーディング
            if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
                    .zIndex(20)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: vm.badges.justUnlocked)
        .animation(.easeInOut(duration: 0.30), value: showOnboarding)
        .onReceive(NotificationCenter.default.publisher(for: .algoBiteProgressDidReset)) { _ in
            showOnboarding = true
        }
    }

    private func appBackButton<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if !path.isEmpty { path.removeLast() }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Pop.navTint)
                    }
                    .accessibilityLabel("戻る")
                }
            }
    }

    // MARK: 背景 (画面全体)
    /// 答え合わせ結果に応じて背景色が変わる — 文字を読まなくても結果が分かる
    @ViewBuilder
    private func screenBackground(_ mood: ResultMood) -> some View {
        let (top, bottom): (Color, Color) = {
            switch mood {
            case .success: return (Pop.bgSuccessTop, Pop.bgSuccessBottom)
            case .fail:    return (Pop.bgFailTop,    Pop.bgFailBottom)
            case .neutral: return (Pop.bgNeutralTop, Pop.bgNeutralBottom)
            }
        }()
        LinearGradient(colors: [top, bottom],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.35), value: mood)
    }

    // MARK: Home screen
    private var homeScreen: some View {
        ZStack {
            screenBackground(vm.isCompletedToday ? .success : .neutral)
            VStack(spacing: 0) {
                homeHeader
                    .padding(.horizontal, 18)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                ScrollView {
                    VStack(spacing: 18) {
                        streakSection      // 最上段 — 連続記録を一番目立たせる
                        todayPreviewCard   // (内部にはじめるボタンを含む)
                        reviewCard
                        homeFooter
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 6)
                    .padding(.bottom, 28)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .onAppear {
            // ケーキ演出が再生し終わったらフラグを下ろす (再訪時に再生しない)
            if vm.justClearedToday {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    vm.justClearedToday = false
                }
            }
        }
    }

    private var homeHeader: some View {
        HStack(spacing: 8) {
            CookieIcon(size: 36)
                .accessibilityHidden(true)
            Text("AlgoBite")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(Pop.inkWarm)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 4)
            // 日付ピル (左寄せ)
            HStack(spacing: 6) {
                DonutIcon(size: 20)
                Text(vm.todayDateString)
                    .font(.caption.weight(.heavy))
            }
            .foregroundStyle(Pop.inkWarmSub)
            .padding(.leading, 6).padding(.trailing, 10)
            .padding(.vertical, 5)
            .background(Color(red: 1.00, green: 0.94, blue: 0.85),
                        in: Capsule())
            .overlay(Capsule().stroke(Color(red: 0.99, green: 0.73, blue: 0.45), lineWidth: 1.5))
            // 実績ショートカット (右上)
            Button {
                Haptics.light()
                path.append(.achievements)
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(red: 1.00, green: 0.95, blue: 0.78))   // #FEF3C7
                        .frame(width: 40, height: 40)
                    Circle()
                        .stroke(Color(red: 0.99, green: 0.79, blue: 0.18), lineWidth: 1.6)
                        .frame(width: 40, height: 40)
                    TrophyIcon(size: 30)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("実績")
        }
        .padding(.vertical, 12)
    }

    private var todayPreviewCard: some View {
        let ch = vm.todayChallenge
        return PopCard(fill: Pop.surface,
                       border: Pop.borderDefault) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 1.00, green: 0.92, blue: 0.85))
                            .frame(width: 60, height: 60)
                        Circle()
                            .stroke(Color(red: 0.99, green: 0.73, blue: 0.45), lineWidth: 2)
                            .frame(width: 60, height: 60)
                        DonutIcon(size: 44)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "fork.knife").font(.caption)
                            Text("今日のひと口")
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(Pop.inkWarmSub)
                        }
                        Text("Day \(vm.isCompletedToday ? max(vm.streak, 1) : vm.streak + 1)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Pop.inkSub)
                    }
                    Spacer()
                    if vm.isCompletedToday {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark").font(.caption2.weight(.black))
                            Text("クリア")
                        }
                        .font(.caption2.weight(.heavy))
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Pop.correctBg, in: Capsule())
                        .foregroundStyle(Pop.correctFg)
                    }
                }

                HStack(spacing: 6) {
                    // クイズの形式バッジ (穴埋め / 並べ替え)
                    iconBadge(systemImage: ch.kindLabel == "穴埋め" ? "pencil" : "arrow.left.arrow.right",
                              ch.kindLabel,
                              bg: Color(red: 0.87, green: 0.84, blue: 0.99),
                              fg: Color(red: 0.30, green: 0.18, blue: 0.50))
                    let topic = ch.topic.components(separatedBy: " / ").first ?? ch.topic
                    iconBadge(systemImage: "tag.fill", topic,
                              bg: Color(red: 0.87, green: 0.84, blue: 0.99),
                              fg: Color(red: 0.30, green: 0.18, blue: 0.50))
                    let d = ch.difficulty
                    let (db, df): (Color, Color) = {
                        switch d {
                        case "Easy":   return (Pop.correctBg, Pop.correctFg)
                        case "Hard":   return (Pop.wrongBg, Pop.wrongFg)
                        default:       return (Color(red: 1.00, green: 0.93, blue: 0.72),
                                               Color(red: 0.57, green: 0.25, blue: 0.05))
                        }
                    }()
                    iconBadge(systemImage: "star.fill", d, bg: db, fg: df)
                }

                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(ch.title)
                            .font(.title2.weight(.black))
                            .foregroundStyle(Pop.ink)
                        Text(ch.prompt)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(Pop.inkSub)
                            .lineLimit(3)
                    }
                    Spacer(minLength: 4)
                    TopicIllustration(topic: ch.topic, size: 76)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // カード内のはじめるボタン
                startButton
                    .padding(.top, 4)
            }
        }
    }

    private var startButton: some View {
        PopButton(fill: Pop.accent,
                  shadow: Pop.accentShadow,
                  action: {
                    Haptics.medium()
                    switch vm.todayChallenge {
                    case .puzzle:        path.append(.problem)
                    case .reorder(let q): path.append(.dailyReorder(q))
                    }
                  }) {
            HStack(spacing: 8) {
                Image(systemName: "fork.knife")
                Text(vm.isCompletedToday ? "結果と解説を見る！" : "いただきます！")
                    .font(.title3.weight(.black))
            }
        }
    }

    // (旧)並べ替え練習カード — 並べ替えは「今日のひと口」に穴埋めと混ぜて出題するため廃止。
    // reorderList 画面自体は DebugCapture のスクショ用に AppScreen に残してある。
    private var reorderPracticeCard: some View {
        EmptyView()
    }

    // ⑥ 復習モードの導線
    private var reviewCard: some View {
        PopCard(fill: Pop.surface,
                border: Color(red: 0.99, green: 0.79, blue: 0.18)) {       // #FBBF24
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.97, green: 0.85, blue: 0.70))   // milky chocolate cream
                            .frame(width: 56, height: 56)
                        Circle()
                            .stroke(Color(red: 0.71, green: 0.46, blue: 0.20), lineWidth: 2)
                            .frame(width: 56, height: 56)
                        ChocolateIcon(size: 44)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("復習モード")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(Pop.ink)
                        Text("過去問にもう一度挑戦")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Pop.inkSub)
                    }
                    Spacer()
                    popBadge("全 \(vm.problems.count) 問",
                             bg: Color(red: 0.87, green: 0.84, blue: 0.99),
                             fg: Color(red: 0.30, green: 0.18, blue: 0.50))
                }
                PopButton(fill: Pop.accent,
                          shadow: Pop.accentShadow,
                          action: { path.append(.review) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "books.vertical.fill")
                        Text("過去問を見る！")
                            .font(.subheadline.weight(.heavy))
                    }
                }
            }
        }
    }

    // ホーム最下部：実績ショートカット + クレジット
    private var homeFooter: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                footerLink(title: "実績", icon: AnyView(CakeIcon(size: 26))) {
                    path.append(.achievements)
                }
                footerLink(title: "復習", icon: AnyView(ChocolateIcon(size: 26))) {
                    path.append(.review)
                }
                footerLink(title: "設定", icon: AnyView(DonutIcon(size: 26))) {
                    path.append(.settings)
                }
            }
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Text("Made with")
                        .font(.system(size: 10, weight: .heavy))
                    CookieIcon(size: 12)
                    Text("by ayu")
                        .font(.system(size: 10, weight: .heavy))
                }
                .foregroundStyle(Pop.inkSub)
                Text("AlgoBite v1.0  ·  毎日ひと口、アルゴリズム")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Pop.inkSub.opacity(0.7))
            }
            .padding(.top, 4)
        }
        .padding(.top, 10)
    }

    private func footerLink(title: String, icon: AnyView,
                            action: @escaping () -> Void) -> some View {
        Button(action: { Haptics.light(); action() }) {
            VStack(spacing: 6) {
                icon
                Text(title)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Pop.inkWarmSub)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Pop.surface,
                        in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14)
                .stroke(Pop.borderDefault, lineWidth: 1.2))
        }
        .buttonStyle(.plain)
    }

    private var streakSection: some View {
        PopCard(fill: Pop.surfaceCream,                                          // #FFF7ED
                border: Color(red: 0.99, green: 0.73, blue: 0.45)) {            // #FDBA74
            VStack(alignment: .leading, spacing: 14) {
                // 見出し
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    StrawberryIcon(size: 32)
                        .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.center] + 8 }
                    Text("\(vm.streak)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(Pop.inkWarm)   // #7C2D12
                    Text("日連続！")
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(Pop.inkWarmSub)
                    Spacer()
                    HStack(spacing: 4) {
                        StrawberryIcon(size: 16)
                        Text("ストリーク")
                            .font(.caption2.weight(.heavy))
                            .foregroundStyle(Pop.inkWarmSub)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color(red: 1.00, green: 0.96, blue: 0.88),
                                in: Capsule())
                }

                // ロールケーキが伸びていって、上に苺が乗っていく演出
                ScrollView(.horizontal, showsIndicators: false) {
                    RollCakeStreak(streak: vm.streak, animateNewBerry: vm.justClearedToday)
                        .padding(.horizontal, 4)
                }
                .frame(height: 92)
                // 10 日を超えたら「+N 日」を金色プレートで表示
                if vm.streak > 10 {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill").foregroundStyle(.yellow)
                        Text("さらに +\(vm.streak - 10) 日積み上げ中！")
                            .font(.caption.weight(.black))
                            .foregroundStyle(Pop.inkWarm)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(LinearGradient(colors: [
                        Color(red: 1.00, green: 0.93, blue: 0.55),
                        Color(red: 0.99, green: 0.79, blue: 0.18)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: Capsule())
                    .overlay(Capsule().stroke(Color(red: 0.92, green: 0.65, blue: 0.05),
                                              lineWidth: 1.4))
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                HStack(spacing: 6) {
                    Spacer()
                    if vm.streak > 0 {
                        CupcakeIcon(size: 18)
                        Text("また明日もおやつ食べようね")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(Pop.inkWarm)
                    } else {
                        DonutIcon(size: 18)
                        Text("今日から1日目！はじめよう")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(Pop.inkWarm)
                    }
                    Spacer()
                }
            }
        }
    }

    private func popBadge(_ text: String, bg: Color, fg: Color) -> some View {
        Text(text)
            .font(.caption.weight(.heavy))
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(bg, in: Capsule())
            .foregroundStyle(fg)
    }

    private func iconBadge(systemImage: String, _ text: String, bg: Color, fg: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage).font(.caption2.weight(.black))
            Text(text)
        }
        .font(.caption.weight(.heavy))
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(bg, in: Capsule())
        .foregroundStyle(fg)
    }

    // MARK: Problem screen
    private var problemScreen: some View {
        ZStack {
            screenBackground(vm.resultMood)
            VStack(spacing: 0) {
                headerBar
                    .padding(.horizontal, 18)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                ScrollView {
                    VStack(spacing: 14) {
                        problemCard
                        codeBlock
                        if vm.isCompletedToday {
                            completionCard
                            ExplanationView(problem: vm.todayProblem,
                                            segments: vm.segments(for:))
                            // 解説の下：ホームに戻ってケーキ演出を見せる
                            PopButton(fill: Color(red: 0.13, green: 0.77, blue: 0.37),
                                      shadow: Color(red: 0.08, green: 0.55, blue: 0.26),
                                      action: { withAnimation { path = [] } }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "fork.knife")
                                    Text("ごちそうさまでした！")
                                        .font(.headline.weight(.black))
                                }
                            }
                        } else {
                            answersPanel
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 10)
                    .padding(.bottom, 28)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        #if DEBUG
        .onAppear {
            DebugCapture.selectProblemSlot(vm: vm)
            DebugCapture.autoplayProblem(vm: vm)
        }
        #endif
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { path.removeLast() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Pop.navTint)
                }
                .accessibilityLabel("戻る")
            }
        }
    }

    // MARK: Header
    private var headerBar: some View {
        HStack {
            HStack(spacing: 4) {
                CookieIcon(size: 20)
                Text("AlgoBite")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(Pop.inkWarm)
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "flame.fill").font(.title3).foregroundStyle(.orange)
                Text("\(vm.streak)")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(Pop.inkWarmSub)
            }
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Color.white.opacity(0.7), in: Capsule())
        }
        .padding(.vertical, 14)
    }

    // MARK: Problem card
    private var problemCard: some View {
        PopCard(fill: Pop.surface,
                border: Pop.borderDefault) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(vm.todayProblem.title)
                        .font(.headline.weight(.black))
                        .foregroundStyle(Color(red: 0.19, green: 0.18, blue: 0.50))  // #312E81
                    Spacer()
                    let d = vm.todayProblem.difficulty
                    let (db, df): (Color, Color) = {
                        switch d {
                        case "Easy":   return (Color(red: 0.73, green: 0.97, blue: 0.82),
                                               Color(red: 0.08, green: 0.32, blue: 0.18))
                        case "Hard":   return (Color(red: 1.00, green: 0.78, blue: 0.78),
                                               Color(red: 0.50, green: 0.11, blue: 0.11))
                        default:       return (Color(red: 1.00, green: 0.93, blue: 0.72),
                                               Color(red: 0.57, green: 0.25, blue: 0.05))
                        }
                    }()
                    popBadge("★ \(d)", bg: db, fg: df)
                }
                Text(vm.todayProblem.prompt)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Pop.ink)
                Text(vm.todayProblem.example)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Pop.inkSub)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Pop.surfaceLavender,
                                in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: Code block
    private var codeBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(vm.todayProblem.topic, systemImage: "chevron.left.forwardslash.chevron.right")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Color(red: 0.31, green: 0.27, blue: 0.90))  // #4F46E5
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(vm.todayProblem.template.enumerated()), id: \.offset) { _, line in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(Array(vm.segments(for: line).enumerated()), id: \.offset) { _, seg in
                                segView(seg)
                            }
                        }
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(Color(red: 0.86, green: 0.89, blue: 0.97))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(red: 0.12, green: 0.11, blue: 0.29),                  // #1E1B4B
                    in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 0.19, green: 0.18, blue: 0.50), lineWidth: 1.5))
        .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 3)
    }

    @ViewBuilder
    private func segView(_ seg: CodeSegment) -> some View {
        switch seg {
        case .text(let t): Text(t)
        case .slot(let id):
            let val = vm.answers[id] ?? "___"
            let active = vm.activeSlotID == id
            let state = vm.slotStates[id] ?? .idle
            let shakes = vm.shakeTrigger[id] ?? 0
            // 「直前間違えたよ」マーク (idle に戻った後も赤波線で残す)
            let wasWrong = state == .idle && vm.lastWrongIDs.contains(id)
            Button { 
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    vm.selectSlot(id) 
                }
            } label: {
                Text(val)
                    .font(.system(size: 13, weight: .heavy, design: .monospaced))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(slotBg(active, state), in: RoundedRectangle(cornerRadius: 7))
                    .overlay(RoundedRectangle(cornerRadius: 7)
                        .stroke(wasWrong ? Pop.danger : slotBorder(active, state),
                                style: StrokeStyle(lineWidth: wasWrong ? 2.0 : 1.5,
                                                   dash: wasWrong ? [4, 2]
                                                       : (state == .idle ? [3, 3] : []))))
                    .foregroundStyle(slotFg(state))
            }
            .buttonStyle(.plain)
            .disabled(vm.isCompletedToday)
            .modifier(ShakeEffect(animatableData: CGFloat(shakes)))
            .animation(.easeInOut(duration: 0.55), value: shakes)
            .accessibilityLabel("スロット \(vm.todayProblem.slots[id]?.label ?? id)、現在 \(val == "___" ? "未入力" : val)")
        }
    }

    private func slotBg(_ active: Bool, _ s: SlotCheckState) -> Color {
        switch s {
        case .correct: Pop.correctBg
        case .wrong:   Pop.wrongBg
        case .idle:    active
                            ? Color(red: 1.00, green: 0.94, blue: 0.54)
                            : Color.white.opacity(0.08)
        }
    }
    private func slotBorder(_ active: Bool, _ s: SlotCheckState) -> Color {
        switch s {
        case .correct: Pop.correctBorder
        case .wrong:   Pop.danger
        case .idle:    active
                            ? Pop.accentShadow
                            : Color.white.opacity(0.30)
        }
    }
    private func slotFg(_ s: SlotCheckState) -> Color {
        switch s {
        case .correct: Pop.correctFg
        case .wrong:   Pop.wrongFg
        case .idle:    Color(red: 0.86, green: 0.89, blue: 0.97)
        }
    }

    // MARK: Answers panel
    // 文字説明はあえて置かない — スロットを tap すると選択肢の chip が出てくる、
    // という関係を UI 構造そのもので示す
    private var answersPanel: some View {
        PopCard(fill: Pop.surface,
                border: Pop.borderDefault) {
            VStack(alignment: .leading, spacing: 12) {
                // スロット選択中だけヘッダ + 選択肢の chip 列を出す
                if let s = vm.selectedSlot {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil.tip.crop.circle.fill")
                            .foregroundStyle(Color(red: 0.39, green: 0.40, blue: 0.95))
                        popBadge(s.label,
                                 bg: Color(red: 1.00, green: 0.95, blue: 0.78),
                                 fg: Color(red: 0.57, green: 0.25, blue: 0.05))
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Array(s.choices.enumerated()), id: \.offset) { i, c in
                                choiceChip(c, index: i)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .frame(minHeight: 44)
                }

                HStack(spacing: 10) {
                    smallBtn("ヒント", systemImage: "lightbulb.fill",
                             fill: Pop.accent, shadow: Pop.accentShadow) { vm.revealHint() }
                    smallBtn("リセット", systemImage: "arrow.counterclockwise",
                             fill: Color(red: 0.61, green: 0.64, blue: 0.71),
                             shadow: Color(red: 0.41, green: 0.45, blue: 0.50)) { vm.resetCurrent() }
                    smallBtn("スキップ", systemImage: "forward.end.fill",
                             fill: Color(red: 0.61, green: 0.64, blue: 0.71),
                             shadow: Color(red: 0.41, green: 0.45, blue: 0.50)) {
                        vm.skipToday()
                        path.removeLast()
                    }
                }

                PopButton(fill: Pop.accent, shadow: Pop.accentShadow,
                          action: { vm.runCheck() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("こたえる！")
                            .font(.headline.weight(.black))
                    }
                }

                if !vm.logMessage.isEmpty {
                    Text(vm.logMessage)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(vm.resultMood == .fail ? Pop.danger : Pop.inkSub)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let hint = vm.gentleHintText {
                    Text(hint)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Pop.inkSub)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 1.00, green: 0.97, blue: 0.87),
                                    in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 0.99, green: 0.79, blue: 0.45), lineWidth: 1))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    private func choiceChip(_ c: String, index: Int) -> some View {
        // 3色を循環 (グリーン・ブルー・ラベンダー)
        let palette: [(Color, Color)] = [
            (Pop.correctBg,                              Pop.correctFg),
            (Color(red: 0.75, green: 0.86, blue: 1.00), Color(red: 0.12, green: 0.23, blue: 0.54)),
            (Color(red: 0.87, green: 0.84, blue: 0.99), Color(red: 0.30, green: 0.18, blue: 0.50)),
        ]
        let (bg, fg) = palette[index % palette.count]
        return Button { 
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                vm.fillChoice(c) 
            }
        } label: {
            Text(c)
                .font(.system(size: 14, weight: .heavy, design: .monospaced))
                .padding(.horizontal, 14).padding(.vertical, 9)
                .background(bg, in: Capsule())
                .foregroundStyle(fg)
                .overlay(Capsule().stroke(fg.opacity(0.25), lineWidth: 1))
                .shadow(color: fg.opacity(0.15), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func smallBtn(_ t: String,
                          systemImage: String,
                          fill: Color,
                          shadow: Color,
                          action: @escaping () -> Void) -> some View {
        PopButton(fill: fill, shadow: shadow, radius: 12, action: action) {
            HStack(spacing: 5) {
                Image(systemName: systemImage)
                Text(t)
            }
            .font(.subheadline.weight(.heavy))
        }
    }

    // MARK: Completion card (お祝い)
    private var completionCard: some View {
        PopCard(fill: Pop.surfaceMint,                                           // #DCFCE7
                border: Color(red: 0.13, green: 0.77, blue: 0.37)) {            // #22C55E
            VStack(spacing: 20) {
                HStack(spacing: 10) {
                    Image(systemName: "party.popper.fill").font(.system(size: 36)).foregroundStyle(Pop.accent)
                    Text("クリア！")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(Pop.correctFg)
                    Image(systemName: "sparkles").font(.system(size: 32)).foregroundStyle(Pop.accent)
                }

                HStack(spacing: 14) {
                    Image(systemName: "flame.fill").font(.system(size: 36)).foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(vm.streak)")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                            Text("日連続！")
                                .font(.headline.weight(.heavy))
                        }
                        .foregroundStyle(Pop.inkWarm)
                        Text("また明日も来てね！")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Pop.inkSub)
                    }
                }

                HStack(spacing: 8) {
                    ForEach(vm.todayProblem.orderedSlotIDs, id: \.self) { id in
                        Image(systemName: vm.slotResults[id] == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(vm.slotResults[id] == true ? Pop.correctBorder : Pop.danger)
                    }
                }
                Text("\(vm.attemptCount) 回でクリア")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Pop.correctFg)

                PopButton(fill: Color(red: 0.39, green: 0.40, blue: 0.95),        // #6366F1
                          shadow: Color(red: 0.30, green: 0.30, blue: 0.78),
                          action: { showShareSheet = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up.fill")
                        Text("結果をシェア")
                            .font(.subheadline.weight(.heavy))
                    }
                }
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(items: [vm.shareText()])
                }
            }
        }
    }
}
