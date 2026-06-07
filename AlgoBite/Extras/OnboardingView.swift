import SwiftUI
import Charts

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
                                CookieIcon(size: 80)
                                DonutIcon(size: 80)
                                ChocolateIcon(size: 80)
                            }
                        ),
                        title: "AlgoBite へようこそ",
                        body: "アルゴリズムを\n毎日ひと口、おやつ感覚で。"
                    ).tag(0)
                    pageContent(
                        illustration: AnyView(
                            VStack(spacing: 10) {
                                RollCakeStreak(streak: 7)
                                    .frame(width: 220, height: 90)
                                Text("🔥 \(7) 日連続！")
                                    .font(.title2.weight(.black))
                                    .foregroundStyle(Pop.inkWarm)
                            }
                        ),
                        title: "ストリークを伸ばそう",
                        body: "毎日 1 問解くとロールケーキに\nいちごが乗っていくよ。"
                    ).tag(1)
                    pageContent(
                        illustration: AnyView(
                            VStack(spacing: 8) {
                                TrophyIcon(size: 80)
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

                PopButton(fill: Pop.accent, shadow: Pop.accentShadow,
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
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
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

