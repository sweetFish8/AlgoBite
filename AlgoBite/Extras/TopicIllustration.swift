import SwiftUI
import Charts

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
        // backtrack / bit / sliding は graph(dfs) や dp より先に判定する
        // ("Backtracking / DFS" が .graph に、"Bit Manipulation / DP" が .dp に
        //  誤分類されるのを防ぐ)
        if t.contains("backtrack")                                 { return .backtracking }
        if t.contains("bit")                                       { return .bit }
        if t.contains("sliding")                                   { return .slidingWindow }
        if t.contains("graph") || t.contains("bfs") || t.contains("dfs") { return .graph }
        if t.contains("dp") || t.contains("dynamic")               { return .dp }
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

