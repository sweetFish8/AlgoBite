import SwiftUI
import Charts

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

