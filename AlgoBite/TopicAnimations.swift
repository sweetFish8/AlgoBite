import SwiftUI

// MARK: - Shared chrome

private struct AnimFrame<Content: View>: View {
    let title: String
    let tint: Color
    let onReplay: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: "play.circle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(tint)
                Spacer()
                Button(action: onReplay) {
                    Label("再生", systemImage: "arrow.clockwise")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(tint.opacity(0.15), in: Capsule())
                }
                .buttonStyle(.plain)
            }
            content()
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
    }
}

private func tile<S: View>(width: CGFloat = 26, height: CGFloat = 26, bg: Color, fg: Color = .white, @ViewBuilder _ content: () -> S) -> some View {
    content()
        .font(.system(size: 11, weight: .bold, design: .monospaced))
        .frame(width: width, height: height)
        .background(bg, in: RoundedRectangle(cornerRadius: 5))
        .foregroundStyle(fg)
}

// MARK: - Sorting (bubble/insertion/selection/quicksort/merge/dutch-flag/rotate)

struct SortingAnim: View {
    enum Kind { case bubble, insertion, selection, counting, quick, merge, dutch, rotate }
    let kind: Kind
    @State private var arr: [Int] = []
    @State private var hi: Int? = nil
    @State private var hj: Int? = nil
    @State private var done = false
    @State private var caption = ""
    @State private var token = 0

    private var seed: [Int] {
        switch kind {
        case .dutch: return [2, 0, 1, 2, 0, 1, 0, 2]
        case .rotate: return [1, 2, 3, 4, 5, 6, 7]
        case .counting: return [4, 2, 2, 8, 3, 3, 1]
        default: return [5, 2, 8, 1, 9, 3, 7, 4]
        }
    }

    var body: some View {
        AnimFrame(title: title, tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(arr.indices, id: \.self) { i in
                        let isHi = hi == i || hj == i
                        let bg: Color = done ? .green.opacity(0.4)
                                            : (isHi ? .yellow : .pink.opacity(0.25))
                        let fg: Color = isHi ? .black : .white
                        tile(bg: bg, fg: fg) { Text("\(arr[i])") }
                            .scaleEffect(isHi ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3), value: arr)
                            .animation(.spring(response: 0.3), value: hi)
                            .animation(.spring(response: 0.3), value: hj)
                    }
                }
                Text(caption)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(done ? .green : .secondary)
            }
        }
        .onAppear { play() }
    }

    private var title: String {
        switch kind {
        case .bubble: return "Bubble Sort"
        case .insertion: return "Insertion Sort"
        case .selection: return "Selection Sort"
        case .counting: return "Counting Sort"
        case .quick: return "Quicksort (動作)"
        case .merge: return "Merge Sort (動作)"
        case .dutch: return "Dutch National Flag"
        case .rotate: return "Rotate Array"
        }
    }

    private func play() {
        token += 1; let t = token
        arr = seed; hi = nil; hj = nil; done = false; caption = ""
        var steps: [(action: () -> Void, msg: String)] = []
        switch kind {
        case .bubble:
            var a = seed
            for i in 0..<a.count {
                for j in 0..<(a.count - i - 1) {
                    let jj = j
                    if a[j] > a[j+1] {
                        a.swapAt(j, j+1)
                        let snap = a
                        steps.append((action: { arr = snap; hi = jj; hj = jj+1 },
                                      msg: "swap a[\(jj)] ⇄ a[\(jj+1)]"))
                    }
                }
            }
        case .insertion:
            var a = seed
            for i in 1..<a.count {
                var j = i
                while j > 0 && a[j-1] > a[j] {
                    a.swapAt(j, j-1)
                    let snap = a; let jc = j
                    steps.append((action: { arr = snap; hi = jc-1; hj = jc },
                                  msg: "挿入: a[\(jc-1)] ⇄ a[\(jc)]"))
                    j -= 1
                }
            }
        case .selection:
            var a = seed
            for i in 0..<a.count {
                var mn = i
                for j in (i+1)..<a.count { if a[j] < a[mn] { mn = j } }
                if mn != i { a.swapAt(i, mn) }
                let snap = a; let ic = i; let mc = mn
                steps.append((action: { arr = snap; hi = ic; hj = mc },
                              msg: "i=\(ic) の min を確定"))
            }
        case .counting:
            var counts = Array(repeating: 0, count: 10)
            for v in seed { counts[v] += 1 }
            var a: [Int] = []
            for (v, c) in counts.enumerated() { a.append(contentsOf: Array(repeating: v, count: c)) }
            let mid = arr
            steps.append((action: { arr = mid }, msg: "カウント中…"))
            steps.append((action: { arr = a }, msg: "カウント結果を展開"))
        case .quick:
            var a = seed
            func qs(_ lo: Int, _ hi2: Int) {
                if lo >= hi2 { return }
                let p = a[hi2]; var i = lo - 1
                for j in lo..<hi2 {
                    if a[j] <= p { i += 1; a.swapAt(i, j) }
                }
                a.swapAt(i+1, hi2)
                let snap = a; let pivot = i+1
                steps.append((action: { arr = snap; hi = pivot; hj = nil },
                              msg: "pivot=\(p) を \(pivot) に確定"))
                qs(lo, i); qs(i+2, hi2)
            }
            qs(0, a.count-1)
        case .merge:
            var a = seed
            func ms(_ l: Int, _ r: Int) {
                if r - l <= 1 { return }
                let m = (l + r) / 2
                ms(l, m); ms(m, r)
                let merged = (Array(a[l..<m]) + Array(a[m..<r])).sorted()
                for (k, v) in merged.enumerated() { a[l + k] = v }
                let snap = a; let lc = l; let rc = r-1
                steps.append((action: { arr = snap; hi = lc; hj = rc },
                              msg: "merge [\(lc)..\(rc)]"))
            }
            ms(0, a.count)
        case .dutch:
            var a = seed; var lo = 0, mid = 0, hi2 = a.count - 1
            while mid <= hi2 {
                if a[mid] == 0 { a.swapAt(lo, mid); lo += 1; mid += 1 }
                else if a[mid] == 2 { a.swapAt(mid, hi2); hi2 -= 1 }
                else { mid += 1 }
                let snap = a; let lc = lo; let mc = mid
                steps.append((action: { arr = snap; hi = lc; hj = mc },
                              msg: "lo=\(lc) mid=\(mc) hi=\(hi2)"))
            }
        case .rotate:
            let k = 3; var a = seed
            a = Array(a.suffix(k)) + Array(a.prefix(a.count - k))
            steps.append((action: { arr = a }, msg: "右に \(k) 回転"))
        }
        for (i, st) in steps.enumerated() {
            let delay = 0.4 + Double(i) * 0.7
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard t == token else { return }
                withAnimation { st.action(); caption = st.msg }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(steps.count) * 0.7 + 0.3) {
            guard t == token else { return }
            withAnimation { done = true; hi = nil; hj = nil; caption = "ソート完了 ✓" }
        }
    }
}

// MARK: - Stack (parentheses, min-stack, monotonic, etc.)

struct StackAnim: View {
    let input: [String]
    let kind: Kind
    enum Kind { case parens, minStack, monotonic }
    @State private var stack: [String] = []
    @State private var cursor = -1
    @State private var caption = ""
    @State private var ok: Bool? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: titleText, tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(input.indices, id: \.self) { i in
                        let active = cursor == i
                        tile(bg: active ? .yellow : .white.opacity(0.06),
                             fg: active ? .black : .white) {
                            Text(input[i])
                        }
                        .scaleEffect(active ? 1.15 : 1.0)
                        .animation(.spring(response: 0.3), value: cursor)
                    }
                }
                Text("stack:")
                    .font(.caption2.weight(.bold)).foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    ForEach(stack.indices, id: \.self) { i in
                        tile(bg: .indigo.opacity(0.4)) { Text(stack[i]) }
                            .transition(.scale.combined(with: .opacity))
                    }
                    if stack.isEmpty {
                        Text("(empty)").font(.caption2).foregroundStyle(.tertiary)
                    }
                }
                .animation(.spring(response: 0.3), value: stack)
                Text(caption)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(ok == true ? .green : (ok == false ? .red : .secondary))
            }
        }
        .onAppear { play() }
    }

    private var titleText: String {
        switch kind { case .parens: return "括弧チェック"; case .minStack: return "Min Stack"; case .monotonic: return "Monotonic Stack" }
    }

    private func play() {
        token += 1; let t = token
        stack = []; cursor = -1; caption = ""; ok = nil
        for (i, ch) in input.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation {
                    cursor = i
                    switch kind {
                    case .parens:
                        if "([{".contains(ch) {
                            stack.append(ch); caption = "push \(ch)"
                        } else {
                            let map = [")":"(", "]":"[", "}":"{"]
                            if let last = stack.last, last == map[ch] { stack.removeLast(); caption = "pop \(last) (\(ch) と対応)" }
                            else { caption = "✗ 対応する括弧が無い"; ok = false }
                        }
                    case .monotonic:
                        let v = Int(ch) ?? 0
                        while let last = stack.last, (Int(last) ?? 0) <= v { stack.removeLast() }
                        stack.append(ch); caption = "push \(ch) (単調維持)"
                    case .minStack:
                        let v = Int(ch) ?? 0
                        let mn = (stack.last.flatMap { Int($0.split(separator: "|").last ?? "") } ?? Int.max)
                        let newMin = min(mn, v)
                        stack.append("\(v)|\(newMin)"); caption = "push v=\(v), min=\(newMin)"
                    }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(input.count) * 0.7 + 0.2) {
            guard t == token else { return }
            withAnimation {
                cursor = -1
                if kind == .parens, ok != false { ok = stack.isEmpty; caption = stack.isEmpty ? "✓ 有効な括弧列" : "✗ stack 残り" }
            }
        }
    }
}

// MARK: - Linked List

struct LinkedListAnim: View {
    enum Kind { case reverse, merge, middle, cycle, addNumbers, intersection }
    let kind: Kind
    @State private var nodes: [String] = []
    @State private var arrows: [String] = []
    @State private var hi: Int? = nil
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: title, tint: .teal, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 2) {
                    ForEach(nodes.indices, id: \.self) { i in
                        let active = hi == i
                        tile(width: 28, bg: active ? .yellow : .teal.opacity(0.35),
                             fg: active ? .black : .white) {
                            Text(nodes[i])
                        }
                        .scaleEffect(active ? 1.15 : 1.0)
                        .animation(.spring(response: 0.3), value: hi)
                        if i < arrows.count {
                            Text(arrows[i])
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundStyle(.teal)
                                .frame(width: 14)
                        }
                    }
                }
                Text(caption)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private var title: String {
        switch kind {
        case .reverse: return "リスト反転"
        case .merge: return "2つのソート済みリストをマージ"
        case .middle: return "中央ノード (slow/fast)"
        case .cycle: return "Floyd's 循環検出"
        case .addNumbers: return "リストでの加算"
        case .intersection: return "交差ノード検出"
        }
    }

    private func play() {
        token += 1; let t = token
        switch kind {
        case .reverse:
            let init1 = ["1","2","3","4","5"]
            nodes = init1; arrows = Array(repeating: "→", count: 4)
            caption = "初期: head→1→2→3→4→5"
            for i in 0..<4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 + Double(i) * 0.8) {
                    guard t == token else { return }
                    withAnimation {
                        arrows[i] = "←"; hi = i+1
                        caption = "step \(i+1): \(init1[i+1])→\(init1[i])"
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 + 4*0.8 + 0.3) {
                guard t == token else { return }
                withAnimation { nodes = init1.reversed(); arrows = Array(repeating: "→", count: 4); hi = nil; caption = "完了: 5→4→3→2→1" }
            }
        case .merge:
            nodes = ["1","2","4","|","1","3","4"]; arrows = ["→","→","","","→","→"]
            caption = "L1=1,2,4 / L2=1,3,4"
            let result = ["1","1","2","3","4","4"]
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                guard t == token else { return }
                withAnimation { nodes = result; arrows = Array(repeating: "→", count: 5); caption = "merge: 1→1→2→3→4→4" }
            }
        case .middle:
            let n = ["1","2","3","4","5"]
            nodes = n; arrows = Array(repeating: "→", count: 4); caption = "slow/fast を進める"
            var s = 0, f = 0
            var i = 0
            while f + 2 < n.count {
                s += 1; f += 2
                let sc = s; let fc = f; let ic = i
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(ic) * 0.8) {
                    guard t == token else { return }
                    withAnimation { hi = sc; caption = "slow=\(sc)  fast=\(fc)" }
                }
                i += 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.8 + 0.4) {
                guard t == token else { return }
                withAnimation { caption = "中央 = \(n[s]) ✓" }
            }
        case .cycle:
            nodes = ["3","2","0","-4","↩︎"]; arrows = ["→","→","→","→"]
            caption = "末尾が index 1 に戻る循環リスト"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                guard t == token else { return }
                withAnimation { hi = 1; caption = "slow と fast が出会う = 循環あり ✓" }
            }
        case .addNumbers:
            nodes = ["2","4","3","|","5","6","4"]; arrows = ["→","→","","","→","→"]
            caption = "342 + 465 = 807"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                guard t == token else { return }
                withAnimation { nodes = ["7","0","8"]; arrows = ["→","→"]; caption = "結果: 7→0→8" }
            }
        case .intersection:
            nodes = ["A1","A2","C1","C2","C3"]; arrows = Array(repeating: "→", count: 4)
            caption = "2つのリストが C1 で合流"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                guard t == token else { return }
                withAnimation { hi = 2; caption = "交差ノード = C1 ✓" }
            }
        }
    }
}

// MARK: - Sliding Window

struct SlidingWindowAnim: View {
    let s: String
    let initialWidth: Int
    @State private var l = 0
    @State private var r = 0
    @State private var best = 0
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Sliding Window", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 3) {
                    ForEach(Array(s).indices, id: \.self) { i in
                        let inWin = i >= l && i <= r
                        tile(bg: inWin ? .orange.opacity(0.55) : .white.opacity(0.06),
                             fg: inWin ? .black : .white) {
                            Text(String(Array(s)[i]))
                        }
                    }
                }
                .animation(.spring(response: 0.3), value: l)
                .animation(.spring(response: 0.3), value: r)
                Text("l=\(l)  r=\(r)  width=\(r-l+1)  best=\(best)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                Text(caption).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        l = 0; r = max(initialWidth - 1, 0); best = initialWidth; caption = "初期ウィンドウ"
        let arr = Array(s)
        var seen = Set(arr[0...r])
        var i = 0
        func tick(_ delay: Double, _ block: @escaping () -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                guard t == token else { return }
                withAnimation { block() }
            })
        }
        var rr = r
        var ll = 0
        while rr < arr.count - 1 {
            rr += 1
            let c = arr[rr]
            if seen.contains(c) {
                while ll <= rr, seen.contains(c) { seen.remove(arr[ll]); ll += 1 }
            }
            seen.insert(c)
            let llc = ll, rrc = rr
            i += 1
            tick(0.5 + Double(i) * 0.65) {
                l = llc; r = rrc; best = max(best, rrc - llc + 1)
                caption = "拡張/縮小: l=\(llc) r=\(rrc)"
            }
        }
        tick(0.5 + Double(i + 1) * 0.65) { caption = "最大幅 = \(best) ✓" }
    }
}

// MARK: - BFS / DFS on grid

struct GridSearchAnim: View {
    enum Kind { case bfs, dfs }
    let kind: Kind
    let grid: [[Int]]
    let subtitle: String

    init(kind: Kind,
         grid: [[Int]] = [
            [1, 1, 0, 0, 0],
            [1, 0, 0, 1, 1],
            [0, 0, 1, 1, 0],
            [0, 1, 1, 0, 0],
         ],
         subtitle: String = "") {
        self.kind = kind
        self.grid = grid
        self.subtitle = subtitle
    }

    @State private var visited: Set<String> = []
    @State private var frontier: Set<String> = []
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: kind == .bfs ? "BFS の広がり" : "DFS の進行", tint: kind == .bfs ? .blue : .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                VStack(spacing: 3) {
                    ForEach(grid.indices, id: \.self) { r in
                        HStack(spacing: 3) {
                            ForEach(grid[r].indices, id: \.self) { c in
                                let key = "\(r),\(c)"
                                let v = grid[r][c] == 1
                                let isVisited = visited.contains(key)
                                let isFrontier = frontier.contains(key)
                                tile(width: 22, height: 22,
                                     bg: !v ? Color.white.opacity(0.04)
                                            : (isVisited ? .green.opacity(0.5) : (isFrontier ? .yellow : .blue.opacity(0.2))),
                                     fg: isFrontier ? .black : .white) {
                                    Text(v ? "▓" : " ")
                                }
                                .animation(.easeInOut(duration: 0.2), value: visited)
                                .animation(.easeInOut(duration: 0.2), value: frontier)
                            }
                        }
                    }
                }
                Text(caption).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        visited = []; frontier = []; caption = ""
        let start = (0, 0)
        let R = grid.count, C = grid[0].count
        var queue: [(Int, Int)] = [start]
        var seen: Set<String> = ["0,0"]
        var order: [(Int, Int, [String])] = [(0, 0, ["0,0"])]
        // pre-compute traversal order
        if kind == .bfs {
            var q = queue; var s = seen
            while !q.isEmpty {
                let (r, c) = q.removeFirst()
                for (dr, dc) in [(-1,0),(1,0),(0,-1),(0,1)] {
                    let nr = r + dr, nc = c + dc
                    let key = "\(nr),\(nc)"
                    if nr>=0, nr<R, nc>=0, nc<C, grid[nr][nc]==1, !s.contains(key) {
                        s.insert(key); q.append((nr, nc))
                        order.append((nr, nc, Array(s)))
                    }
                }
            }
        } else {
            var stack = queue; var s = seen
            while !stack.isEmpty {
                let (r, c) = stack.removeLast()
                for (dr, dc) in [(-1,0),(1,0),(0,-1),(0,1)] {
                    let nr = r + dr, nc = c + dc
                    let key = "\(nr),\(nc)"
                    if nr>=0, nr<R, nc>=0, nc<C, grid[nr][nc]==1, !s.contains(key) {
                        s.insert(key); stack.append((nr, nc))
                        order.append((nr, nc, Array(s)))
                    }
                }
            }
        }
        for (i, step) in order.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.5) {
                guard t == token else { return }
                withAnimation {
                    visited.insert("\(step.0),\(step.1)")
                    frontier = []
                    caption = "(\(step.0), \(step.1)) を訪問 (合計 \(visited.count) 個)"
                }
            }
        }
    }
}

// MARK: - Tree traversal

struct TreeTraversalAnim: View {
    enum Order { case inorder, preorder, postorder, level }
    let order: Order
    /// 7 ノード 3 段の木 (level order の配列表現)。問題ごとに違う数列を渡せる
    let nodes: [Int]
    /// 副題 (問題の文脈で表示)
    let subtitle: String

    init(order: Order, nodes: [Int] = [4, 2, 6, 1, 3, 5, 7], subtitle: String = "") {
        self.order = order
        self.nodes = nodes
        self.subtitle = subtitle
    }

    @State private var visited: [Int] = []
    @State private var current: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: title, tint: .green, onReplay: play) {
            VStack(spacing: 8) {
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                // Render as 3-level pyramid
                let levels: [[Int]] = [[nodes[0]], [nodes[1], nodes[2]], [nodes[3], nodes[4], nodes[5], nodes[6]]]
                ForEach(levels.indices, id: \.self) { lvl in
                    HStack(spacing: 12) {
                        ForEach(levels[lvl], id: \.self) { v in
                            let isVisited = visited.contains(v)
                            let isCur = current == v
                            tile(width: 30, height: 30,
                                 bg: isCur ? .yellow : (isVisited ? .green.opacity(0.5) : .white.opacity(0.08)),
                                 fg: isCur ? .black : .white) { Text("\(v)") }
                                .scaleEffect(isCur ? 1.18 : 1.0)
                                .animation(.spring(response: 0.3), value: current)
                                .animation(.spring(response: 0.3), value: visited)
                        }
                    }
                }
                Text("順番: " + visited.map(String.init).joined(separator: " → "))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private var title: String {
        switch order {
        case .inorder: return "Inorder (左→根→右)"
        case .preorder: return "Preorder (根→左→右)"
        case .postorder: return "Postorder (左→右→根)"
        case .level: return "Level Order (BFS)"
        }
    }

    private func play() {
        token += 1; let t = token
        visited = []; current = nil
        // nodes[0..6] を完全二分木として扱い、走査順を実際に計算する
        // index: 0=root, 1=L, 2=R, 3=LL, 4=LR, 5=RL, 6=RR
        let seq: [Int]
        switch order {
        case .inorder:   seq = [nodes[3], nodes[1], nodes[4], nodes[0], nodes[5], nodes[2], nodes[6]]
        case .preorder:  seq = [nodes[0], nodes[1], nodes[3], nodes[4], nodes[2], nodes[5], nodes[6]]
        case .postorder: seq = [nodes[3], nodes[4], nodes[1], nodes[5], nodes[6], nodes[2], nodes[0]]
        case .level:     seq = nodes
        }
        for (i, v) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.6) {
                guard t == token else { return }
                withAnimation { current = v }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.6 + 0.3) {
                guard t == token else { return }
                withAnimation { visited.append(v); current = nil }
            }
        }
    }
}

// MARK: - DP table fill

struct DPTableAnim: View {
    enum Kind {
        case fib, climb, robber, coinChange, lcs, lis, knapsack, uniquePaths, editDist,
             minPath, decode, wordBreak, regex, wildcard, maxSubarray, pascals, countBits, longestValidParens
    }
    let kind: Kind
    @State private var cells: [[String]] = []
    @State private var hi: (Int, Int)? = nil
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: title, tint: .yellow, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                VStack(spacing: 3) {
                    ForEach(cells.indices, id: \.self) { r in
                        HStack(spacing: 3) {
                            ForEach(cells[r].indices, id: \.self) { c in
                                let isHi = hi.map { $0 == (r, c) } ?? false
                                tile(width: 24, height: 22,
                                     bg: isHi ? .yellow : (cells[r][c].isEmpty ? .white.opacity(0.04) : .yellow.opacity(0.25)),
                                     fg: isHi ? .black : .white) {
                                    Text(cells[r][c]).font(.system(size: 10, weight: .bold, design: .monospaced))
                                }
                                .animation(.spring(response: 0.3), value: hi?.0)
                                .animation(.spring(response: 0.3), value: hi?.1)
                            }
                        }
                    }
                }
                Text(caption).font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private var title: String {
        switch kind {
        case .fib: return "Fibonacci DP"
        case .climb: return "Climbing Stairs DP"
        case .robber: return "House Robber DP"
        case .coinChange: return "Coin Change DP"
        case .lcs: return "LCS (2D DP)"
        case .lis: return "LIS DP"
        case .knapsack: return "0-1 Knapsack"
        case .uniquePaths: return "Unique Paths (2D)"
        case .editDist: return "Edit Distance (2D)"
        case .minPath: return "Min Path Sum (2D)"
        case .decode: return "Decode Ways DP"
        case .wordBreak: return "Word Break DP"
        case .regex: return "Regex DP"
        case .wildcard: return "Wildcard DP"
        case .maxSubarray: return "Kadane (Max Subarray)"
        case .pascals: return "Pascal's Triangle"
        case .countBits: return "Count Bits DP"
        case .longestValidParens: return "Longest Valid Parens DP"
        }
    }

    private func play() {
        token += 1; let t = token
        cells = []; hi = nil; caption = "DP 表を埋めていきます"
        let steps = computeSteps()
        let rows = steps.last?.cells.count ?? 1
        let cols = steps.last?.cells.first?.count ?? 1
        cells = Array(repeating: Array(repeating: "", count: cols), count: rows)
        for (i, st) in steps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.5) {
                guard t == token else { return }
                withAnimation { cells = st.cells; hi = st.hi; caption = st.msg }
            }
        }
    }

    private struct Step { let cells: [[String]]; let hi: (Int, Int)?; let msg: String }

    private func computeSteps() -> [Step] {
        switch kind {
        case .fib:
            let n = 8; var dp = Array(repeating: 0, count: n)
            dp[0] = 0; dp[1] = 1
            var s: [Step] = []
            s.append(Step(cells: [dp.map(String.init)], hi: (0,0), msg: "dp[0]=0"))
            s.append(Step(cells: [dp.map(String.init)], hi: (0,1), msg: "dp[1]=1"))
            for i in 2..<n { dp[i] = dp[i-1] + dp[i-2]; s.append(Step(cells: [dp.map(String.init)], hi: (0,i), msg: "dp[\(i)] = dp[\(i-1)]+dp[\(i-2)] = \(dp[i])")) }
            return s
        case .climb:
            return mkLine([1,1,2,3,5,8,13,21], "登り方の総数")
        case .robber:
            let nums = [2,7,9,3,1]; var dp = Array(repeating: 0, count: nums.count); dp[0]=nums[0]; dp[1]=max(nums[0],nums[1])
            var s: [Step] = [Step(cells: [dp.map(String.init)], hi: (0,0), msg: "dp[0]=\(dp[0])"),
                             Step(cells: [dp.map(String.init)], hi: (0,1), msg: "dp[1]=\(dp[1])")]
            for i in 2..<nums.count { dp[i]=max(dp[i-1], dp[i-2]+nums[i]); s.append(Step(cells: [dp.map(String.init)], hi: (0,i), msg: "max(dp[i-1], dp[i-2]+v) = \(dp[i])")) }
            return s
        case .coinChange:
            return mkLine([0,1,2,3,4,2,3,4,5,3,1], "amount=10, coins=[1,5,10]")
        case .lcs:
            return mk2D(rows: 4, cols: 5, init: { _,_ in "0" }, fillMsg: "LCS dp[i][j]")
        case .lis:
            return mkLine([1,2,2,3,3,4,2,4], "LIS dp[i] の進行")
        case .knapsack:
            return mk2D(rows: 4, cols: 6, init: { r,c in r==0||c==0 ? "0" : "" }, fillMsg: "Knapsack dp[i][w]")
        case .uniquePaths:
            return mk2D(rows: 3, cols: 4, init: { r,c in (r==0||c==0) ? "1" : "" }, fillMsg: "dp[i][j] = up + left")
        case .editDist:
            return mk2D(rows: 4, cols: 4, init: { r,c in r==0 ? "\(c)" : (c==0 ? "\(r)" : "") }, fillMsg: "edit dp[i][j]")
        case .minPath:
            return mk2D(rows: 3, cols: 3, init: { _,_ in "" }, fillMsg: "min path 累積")
        case .decode:
            return mkLine([1,1,2,3,5,7], "decode dp")
        case .wordBreak:
            return mkLine([1,0,0,1,0,0,1,1], "wordBreak dp[i]")
        case .regex:
            return mk2D(rows: 4, cols: 5, init: { _,_ in "" }, fillMsg: "regex dp[i][j]")
        case .wildcard:
            return mk2D(rows: 4, cols: 5, init: { _,_ in "" }, fillMsg: "wildcard dp[i][j]")
        case .maxSubarray:
            let nums = [-2,1,-3,4,-1,2,1,-5,4]
            var cur = 0, best = Int.min; var dp: [Int] = []
            for n in nums { cur = max(n, cur + n); best = max(best, cur); dp.append(cur) }
            var s: [Step] = []
            for i in 0..<dp.count { s.append(Step(cells: [dp.prefix(i+1).map(String.init) + Array(repeating: "", count: dp.count-i-1)], hi: (0,i), msg: "cur=\(dp[i]) best=\(dp.prefix(i+1).max()!)")) }
            return s
        case .pascals:
            let rows = 5
            var tri: [[Int]] = []
            for r in 0..<rows {
                var row = Array(repeating: 1, count: r+1)
                for c in 1..<r { row[c] = tri[r-1][c-1] + tri[r-1][c] }
                tri.append(row)
            }
            var s: [Step] = []
            for r in 0..<rows {
                var view: [[String]] = []
                for rr in 0...r { view.append(tri[rr].map(String.init) + Array(repeating: "", count: rows - rr - 1)) }
                while view.count < rows { view.append(Array(repeating: "", count: rows)) }
                s.append(Step(cells: view, hi: (r, 0), msg: "row \(r) = \(tri[r])"))
            }
            return s
        case .countBits:
            var dp = [0]
            for i in 1...10 { dp.append(dp[i >> 1] + (i & 1)) }
            var s: [Step] = []
            for i in 0..<dp.count {
                s.append(Step(cells: [dp.prefix(i+1).map(String.init) + Array(repeating: "", count: dp.count-i-1)],
                              hi: (0,i), msg: "dp[\(i)] = dp[\(i>>1)] + (\(i)&1) = \(dp[i])"))
            }
            return s
        case .longestValidParens:
            return mkLine([0,0,2,0,0,2,4,6,0,2], "longest valid parens dp[i]")
        }
    }

    private func mkLine(_ values: [Int], _ msg: String) -> [Step] {
        var s: [Step] = []
        for i in 0..<values.count {
            let view = values.prefix(i+1).map(String.init) + Array(repeating: "", count: values.count - i - 1)
            s.append(Step(cells: [view], hi: (0, i), msg: "\(msg) → dp[\(i)] = \(values[i])"))
        }
        return s
    }
    private func mk2D(rows: Int, cols: Int, init initFn: (Int, Int) -> String, fillMsg: String) -> [Step] {
        var grid = Array(repeating: Array(repeating: "", count: cols), count: rows)
        for r in 0..<rows { for c in 0..<cols { grid[r][c] = initFn(r, c) } }
        var s: [Step] = []
        for r in 0..<rows {
            for c in 0..<cols {
                if grid[r][c].isEmpty { grid[r][c] = "\(r + c)" }
                s.append(Step(cells: grid, hi: (r, c), msg: "\(fillMsg)  ←  (\(r),\(c))"))
            }
        }
        return s
    }
}

// MARK: - Heap

struct HeapAnim: View {
    enum Kind { case kthLargest, topK, slidingMax, meetingRooms }
    let kind: Kind
    @State private var heap: [Int] = []
    @State private var ingest: Int? = nil
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: title, tint: .red, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("min-heap").font(.caption2.weight(.bold)).foregroundStyle(.secondary)
                    ForEach(heap.indices, id: \.self) { i in
                        tile(bg: .red.opacity(0.3)) { Text("\(heap[i])") }
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3), value: heap)
                if let v = ingest {
                    Text("追加: \(v)").font(.system(.caption2, design: .monospaced)).foregroundStyle(.yellow)
                }
                Text(caption).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private var title: String {
        switch kind {
        case .kthLargest: return "Kth Largest (size-k Heap)"
        case .topK: return "Top K Frequent"
        case .slidingMax: return "Sliding Window Max"
        case .meetingRooms: return "Meeting Rooms (終了時刻)"
        }
    }

    private func play() {
        token += 1; let t = token
        heap = []; ingest = nil; caption = ""
        let stream: [Int]
        let k = 3
        switch kind {
        case .kthLargest: stream = [3,2,1,5,6,4]
        case .topK: stream = [1,1,1,2,2,3,3,3,3]
        case .slidingMax: stream = [1,3,-1,-3,5,3,6,7]
        case .meetingRooms: stream = [1,3,5,8,9,11]
        }
        for (i, v) in stream.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.6) {
                guard t == token else { return }
                withAnimation {
                    ingest = v
                    heap.append(v); heap.sort()
                    if heap.count > k { heap.removeFirst() }
                    caption = "v=\(v) を投入, heap=\(heap)"
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(stream.count) * 0.6 + 0.2) {
            guard t == token else { return }
            withAnimation { ingest = nil; caption = "結果 = \(heap)" }
        }
    }
}

// MARK: - Bit operations

struct BitAnim: View {
    enum Kind { case singleNumber, powerOfTwo, reverseBits }
    let kind: Kind
    @State private var bits: [Int] = []
    @State private var caption = ""
    @State private var hi: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: title, tint: .mint, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 3) {
                    ForEach(bits.indices, id: \.self) { i in
                        let active = hi == i
                        tile(width: 22, height: 22,
                             bg: active ? .yellow : (bits[i] == 1 ? .mint.opacity(0.6) : .white.opacity(0.06)),
                             fg: active ? .black : .white) { Text("\(bits[i])") }
                            .scaleEffect(active ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3), value: hi)
                            .animation(.easeInOut(duration: 0.25), value: bits)
                    }
                }
                Text(caption).font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private var title: String {
        switch kind {
        case .singleNumber: return "XOR で消す"
        case .powerOfTwo: return "2の冪 (n & (n-1))"
        case .reverseBits: return "ビット反転"
        }
    }

    private func bitsOf(_ x: Int, width: Int = 8) -> [Int] {
        (0..<width).map { (x >> ($0)) & 1 }.reversed()
    }

    private func play() {
        token += 1; let t = token
        switch kind {
        case .singleNumber:
            let nums = [4, 1, 2, 1, 2]
            var acc = 0
            bits = bitsOf(0); caption = "acc = 0"
            for (i, v) in nums.enumerated() {
                acc ^= v
                let snap = acc
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.7) {
                    guard t == token else { return }
                    withAnimation { bits = bitsOf(snap); caption = "acc ^= \(v) → \(snap)" }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(nums.count) * 0.7 + 0.2) {
                guard t == token else { return }
                withAnimation { caption = "唯一の単独要素 = \(acc) ✓" }
            }
        case .powerOfTwo:
            let n = 16
            bits = bitsOf(n); caption = "n = \(n) = \(String(n, radix: 2))"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                guard t == token else { return }
                withAnimation { bits = bitsOf(n - 1); caption = "n-1 = \(n-1) = \(String(n-1, radix: 2))" }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                guard t == token else { return }
                withAnimation { bits = bitsOf(n & (n-1)); caption = "n & (n-1) = \(n & (n-1)) → 0 なら2の冪 ✓" }
            }
        case .reverseBits:
            let n = 0b10110100
            bits = bitsOf(n); caption = "元: \(String(n, radix: 2))"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                guard t == token else { return }
                withAnimation { bits = bits.reversed(); caption = "反転: \(bits.map(String.init).joined())" }
            }
        }
    }
}

// MARK: - Backtracking (recursion tree)

struct BacktrackingAnim: View {
    enum Kind { case combinations, subsets, permutations, nQueens, wordSearch }
    let kind: Kind
    @State private var lines: [String] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: title, tint: .purple, onReplay: play) {
            VStack(alignment: .leading, spacing: 3) {
                ForEach(lines.indices, id: \.self) { i in
                    Text(lines[i])
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(lines[i].contains("✓") ? .green : .secondary)
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            .animation(.easeOut, value: lines)
        }
        .onAppear { play() }
    }

    private var title: String {
        switch kind {
        case .combinations: return "Combinations 再帰木"
        case .subsets: return "Subsets 再帰木"
        case .permutations: return "Permutations 再帰木"
        case .nQueens: return "N-Queens (4x4)"
        case .wordSearch: return "Word Search DFS"
        }
    }

    private func play() {
        token += 1; let t = token
        lines = []
        let seq: [String]
        switch kind {
        case .combinations: seq = ["start=1","  pick 1, [1]","    pick 2, [1,2] ✓","    pick 3, [1,3] ✓","  pick 2, [2]","    pick 3, [2,3] ✓","  pick 3, [3]"]
        case .subsets: seq = ["[]", "  [1]", "    [1,2]", "      [1,2,3] ✓", "    [1,3] ✓", "  [2]", "    [2,3] ✓", "  [3] ✓"]
        case .permutations: seq = ["[]", "  [1]", "    [1,2]", "      [1,2,3] ✓", "    [1,3]", "      [1,3,2] ✓", "  [2]", "    [2,1,3] ✓", "  ..."]
        case .nQueens: seq = ["row 0: Q at col 0", "  row 1: Q at col 2", "    row 2: 全部攻撃される ✗", "  row 1: Q at col 3", "    row 2: Q at col 1", "      row 3: ✓ 解 (0,2,3,1)"]
        case .wordSearch: seq = ["start (0,0)='A'", "  右 (0,1)='B' ✓", "    下 (1,1)='C' ✓", "      右 (1,2)='C' ✗ 戻る", "      下 (2,1)='D' ✓ 完成"]
        }
        for (i, line) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.5) {
                guard t == token else { return }
                withAnimation { lines.append(line) }
            }
        }
    }
}

// MARK: - Trie

struct TrieAnim: View {
    enum Kind { case insert, search }
    let kind: Kind
    let words: [String] = ["cat", "car", "card", "cab"]
    @State private var inserted: [String] = []
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: kind == .insert ? "Trie Insert" : "Trie Search", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                Text("root").font(.caption.weight(.bold))
                ForEach(words.indices, id: \.self) { i in
                    let w = words[i]
                    HStack(spacing: 3) {
                        Text("├")
                        ForEach(Array(w).indices, id: \.self) { j in
                            let active = inserted.contains(String(w.prefix(j+1)))
                            tile(width: 18, height: 18,
                                 bg: active ? .indigo.opacity(0.5) : .white.opacity(0.06),
                                 fg: .white) { Text(String(Array(w)[j])) }
                        }
                    }
                    .font(.system(.caption2, design: .monospaced))
                    .animation(.easeInOut, value: inserted)
                }
                Text(caption).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        inserted = []; caption = ""
        var allPrefixes: [String] = []
        for w in words {
            for j in 1...w.count { allPrefixes.append(String(w.prefix(j))) }
        }
        for (i, p) in allPrefixes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.3) {
                guard t == token else { return }
                withAnimation {
                    if !inserted.contains(p) { inserted.append(p) }
                    caption = "ノード追加: \(p)"
                }
            }
        }
    }
}

// MARK: - Union Find

struct UnionFindAnim: View {
    let kind: Kind
    enum Kind { case basic, kruskal }
    @State private var parent: [Int] = Array(0..<6)
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: kind == .basic ? "Union-Find" : "Kruskal (辺を貪欲に追加)", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 3) {
                    ForEach(parent.indices, id: \.self) { i in
                        tile(bg: rootColor(of: i)) {
                            VStack(spacing: 0) {
                                Text("\(i)").font(.system(size: 9, weight: .bold))
                                Text("→\(find(i))").font(.system(size: 7))
                            }
                        }
                    }
                }
                .animation(.spring(response: 0.3), value: parent)
                Text(caption).font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private func find(_ x: Int) -> Int {
        var v = x
        while parent[v] != v { v = parent[v] }
        return v
    }

    private func rootColor(of i: Int) -> Color {
        let palette: [Color] = [.orange, .blue, .green, .pink, .purple, .cyan]
        return palette[find(i) % palette.count].opacity(0.4)
    }

    private func play() {
        token += 1; let t = token
        parent = Array(0..<6); caption = "各要素は単独"
        let unions: [(Int, Int)]
        switch kind {
        case .basic: unions = [(0,1),(2,3),(1,3),(4,5)]
        case .kruskal: unions = [(0,1),(2,3),(4,5),(1,2),(3,4)]
        }
        for (i, (a, b)) in unions.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.8) {
                guard t == token else { return }
                withAnimation {
                    let ra = find(a), rb = find(b)
                    if ra != rb { parent[ra] = rb; caption = "union(\(a), \(b))" }
                    else { caption = "union(\(a), \(b)) → 同じ集合" }
                }
            }
        }
    }
}

// MARK: - Math: GCD, FastPow, Sieve

struct GCDAnim: View {
    @State private var steps: [(a: Int, b: Int)] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "ユークリッドの互除法", tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(steps.indices, id: \.self) { i in
                    Text("a=\(steps[i].a)  b=\(steps[i].b)  →  a%b=\(steps[i].b == 0 ? 0 : steps[i].a % steps[i].b)")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(steps[i].b == 0 ? .green : .secondary)
                }
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        steps = []
        var a = 48, b = 18
        var local: [(Int, Int)] = []
        while b != 0 { local.append((a, b)); let r = a % b; a = b; b = r }
        local.append((a, 0))
        for (i, s) in local.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.6) {
                guard t == token else { return }
                withAnimation { steps.append(s) }
            }
        }
    }
}

struct FastPowAnim: View {
    @State private var lines: [String] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Fast Exponentiation (2^13)", tint: .cyan, onReplay: play) {
            VStack(alignment: .leading, spacing: 3) {
                ForEach(lines.indices, id: \.self) { i in
                    Text(lines[i]).font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        lines = []
        var b = 2, e = 13, r = 1
        var seq: [String] = []
        while e > 0 {
            if e & 1 == 1 { r *= b; seq.append("e&1 → r *= \(b) → r=\(r)") }
            b *= b; e >>= 1
            seq.append("b=\(b)  e=\(e)")
        }
        seq.append("結果 = \(r) ✓")
        for (i, line) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.5) {
                guard t == token else { return }
                withAnimation { lines.append(line) }
            }
        }
    }
}

struct SieveAnim: View {
    let n = 30
    @State private var marked: Set<Int> = []
    @State private var current: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "エラトステネスのふるい", tint: .pink, onReplay: play) {
            let cols = 10
            VStack(spacing: 3) {
                ForEach(0..<(n / cols), id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(0..<cols, id: \.self) { c in
                            let v = r * cols + c + 1
                            let isMarked = marked.contains(v)
                            let isCur = current == v
                            tile(width: 22, height: 22,
                                 bg: isCur ? .yellow : (isMarked ? .gray.opacity(0.3) : .pink.opacity(0.4)),
                                 fg: (isCur ? .black : (isMarked ? .white.opacity(0.4) : .white))) {
                                Text("\(v)")
                            }
                            .animation(.easeInOut(duration: 0.25), value: marked)
                            .animation(.easeInOut(duration: 0.25), value: current)
                        }
                    }
                }
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        marked = [1]; current = nil
        var step = 0
        for p in 2...n {
            if marked.contains(p) { continue }
            let pc = p
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(step) * 0.5) {
                guard t == token else { return }
                withAnimation { current = pc }
            }
            step += 1
            var m = p * 2
            while m <= n {
                let mc = m
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(step) * 0.25) {
                    guard t == token else { return }
                    withAnimation { _ = marked.insert(mc) }
                }
                step += 1
                m += p
            }
        }
    }
}

// MARK: - Container with Most Water / Trapping Rain Water

struct WaterAnim: View {
    enum Kind { case container, trapping }
    let kind: Kind
    let heights: [Int] = [1, 8, 6, 2, 5, 4, 8, 3, 7]
    @State private var l = 0
    @State private var r = 8
    @State private var best = 0
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: kind == .container ? "Container With Most Water" : "Trapping Rain Water",
                  tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .bottom, spacing: 3) {
                    ForEach(heights.indices, id: \.self) { i in
                        let active = i == l || i == r
                        Rectangle()
                            .fill(active ? Color.yellow : Color.blue.opacity(0.5))
                            .frame(width: 18, height: CGFloat(heights[i]) * 6)
                            .overlay(Text("\(heights[i])").font(.system(size: 9)).foregroundStyle(.white).padding(.top, 2), alignment: .top)
                            .scaleEffect(active ? 1.05 : 1.0)
                            .animation(.spring(response: 0.3), value: l)
                            .animation(.spring(response: 0.3), value: r)
                    }
                }
                Text(caption).font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        l = 0; r = heights.count - 1; best = 0; caption = ""
        var ll = 0, rr = heights.count - 1, b = 0
        var snaps: [(Int, Int, Int, String)] = []
        while ll < rr {
            let area = min(heights[ll], heights[rr]) * (rr - ll); b = max(b, area)
            snaps.append((ll, rr, b, "min(\(heights[ll]),\(heights[rr]))×(\(rr)-\(ll))=\(area), best=\(b)"))
            if heights[ll] < heights[rr] { ll += 1 } else { rr -= 1 }
        }
        for (i, s) in snaps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation { l = s.0; r = s.1; best = s.2; caption = s.3 }
            }
        }
    }
}

// MARK: - Floyd's cycle detection (visualized linearly)

struct FloydAnim: View {
    @State private var slow = 0
    @State private var fast = 0
    @State private var caption = ""
    @State private var token = 0
    let arr = [1, 3, 4, 2, 5, 2, 6]

    var body: some View {
        AnimFrame(title: "Floyd's Tortoise & Hare", tint: .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 3) {
                    ForEach(arr.indices, id: \.self) { i in
                        let isSlow = i == slow
                        let isFast = i == fast
                        VStack(spacing: 2) {
                            Text(isSlow && isFast ? "S=F" : (isSlow ? "S" : (isFast ? "F" : " ")))
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(isSlow || isFast ? Color.yellow : .clear)
                            tile(width: 22, height: 22,
                                 bg: (isSlow && isFast) ? .yellow : (isSlow || isFast ? .green.opacity(0.5) : .white.opacity(0.08))) {
                                Text("\(arr[i])")
                            }
                        }
                    }
                }
                .animation(.spring(response: 0.3), value: slow)
                .animation(.spring(response: 0.3), value: fast)
                Text(caption).font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        slow = 0; fast = 0; caption = "slow=fast=start"
        let steps = 6
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.6) {
                guard t == token else { return }
                withAnimation {
                    slow = (slow + 1) % arr.count
                    fast = (fast + 2) % arr.count
                    caption = "step \(i): slow=\(slow) fast=\(fast)"
                    if slow == fast { caption += "  → 合流！循環あり ✓" }
                }
            }
        }
    }
}

// MARK: - Two Sum (hash map walk)

struct TwoSumAnim: View {
    let nums: [Int] = [2, 7, 11, 15]
    let target: Int = 9
    @State private var step = -1
    @State private var seen: [(val: Int, idx: Int)] = []
    @State private var found: (Int, Int)? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Two Sum (target = \(target))", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    ForEach(nums.indices, id: \.self) { i in
                        let isCurrent = i == step
                        let isHit = found.map { i == $0.0 || i == $0.1 } ?? false
                        tile(width: 32, height: 32,
                             bg: isHit ? .green : (isCurrent ? .yellow : .white.opacity(0.20)),
                             fg: (isHit || isCurrent) ? .black : .white) { Text("\(nums[i])") }
                    }
                }
                Text("nums = \(nums.description)")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 3) {
                    Text("見たもの (val → index):").font(.caption2.weight(.bold)).foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        ForEach(seen.indices, id: \.self) { i in
                            Text("\(seen[i].val)→\(seen[i].idx)")
                                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                                .padding(.horizontal, 6).padding(.vertical, 3)
                                .background(.pink.opacity(0.25), in: Capsule())
                        }
                    }
                }
                if let f = found {
                    Text("🎯 (\(f.0), \(f.1)) で和 = \(target)")
                        .font(.caption.weight(.bold)).foregroundStyle(.green)
                } else if step >= 0 && step < nums.count {
                    Text("complement \(target - nums[step]) は seen に？")
                        .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                }
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        step = -1; seen = []; found = nil
        for i in nums.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 1.0) {
                guard t == token else { return }
                withAnimation { step = i }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 1.0 + 0.5) {
                guard t == token else { return }
                let comp = target - nums[i]
                if let prev = seen.firstIndex(where: { $0.val == comp }) {
                    withAnimation { found = (seen[prev].idx, i) }
                    return
                }
                withAnimation { seen.append((nums[i], i)) }
            }
        }
    }
}

// MARK: - Climbing Stairs (DP with stair visual)

struct ClimbingStairsAnim: View {
    let n: Int = 5
    @State private var dp: [Int] = []
    @State private var curIdx = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Climbing Stairs (n=\(n))", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                // 階段グラフィック
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(0...n, id: \.self) { i in
                        VStack(spacing: 2) {
                            if i == curIdx {
                                Text("🚶").font(.title2)
                            } else {
                                Text(" ").font(.title2)
                            }
                            ForEach(0..<(i+1), id: \.self) { _ in
                                Rectangle()
                                    .fill(.orange.opacity(0.45))
                                    .frame(width: 28, height: 12)
                            }
                        }
                    }
                }
                Text("dp[i] = dp[i-1] + dp[i-2]")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    ForEach(dp.indices, id: \.self) { i in
                        tile(width: 36, height: 28,
                             bg: i == curIdx ? .yellow : .orange.opacity(0.30),
                             fg: i == curIdx ? .black : .white) {
                            VStack(spacing: 0) {
                                Text("\(dp[i])").font(.system(size: 12, weight: .black))
                                Text("dp[\(i)]").font(.system(size: 8))
                            }
                        }
                    }
                }
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        dp = []; curIdx = -1
        for i in 0...n {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                let v: Int
                if i <= 1 { v = 1 } else { v = dp[i-1] + dp[i-2] }
                withAnimation { dp.append(v); curIdx = i }
            }
        }
    }
}

// MARK: - Buy/Sell Stock (price chart + min tracker)

struct BuySellStockAnim: View {
    let prices: [Int] = [7, 1, 5, 3, 6, 4]
    @State private var idx = -1
    @State private var minSoFar: Int = .max
    @State private var maxProfit = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Best Time to Buy/Sell", tint: .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                // バーグラフ
                HStack(alignment: .bottom, spacing: 5) {
                    ForEach(prices.indices, id: \.self) { i in
                        let isCur = i == idx
                        let isMin = prices[i] == minSoFar && minSoFar != .max && i <= idx
                        VStack(spacing: 2) {
                            Text("\(prices[i])")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.secondary)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(isMin ? .blue : (isCur ? .yellow : .gray.opacity(0.5)))
                                .frame(width: 26, height: CGFloat(prices[i]) * 10)
                        }
                    }
                }
                .padding(.top, 4)
                HStack(spacing: 12) {
                    Label("min: \(minSoFar == .max ? 0 : minSoFar)", systemImage: "arrow.down")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(.blue)
                    Label("max profit: \(maxProfit)", systemImage: "dollarsign.circle.fill")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(.green)
                }
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        idx = -1; minSoFar = .max; maxProfit = 0
        for i in prices.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation {
                    idx = i
                    minSoFar = min(minSoFar, prices[i])
                    maxProfit = max(maxProfit, prices[i] - minSoFar)
                }
            }
        }
    }
}

// MARK: - Jump Game (reachability)

struct JumpGameAnim: View {
    let nums: [Int]
    let countMode: Bool   // true = JumpGameII (回数), false = JumpGame (届く/届かない)

    init(nums: [Int] = [2, 3, 1, 1, 4], countMode: Bool = false) {
        self.nums = nums; self.countMode = countMode
    }

    @State private var idx = -1
    @State private var maxReach = 0
    @State private var jumps = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: countMode ? "Jump Game II (回数最小)" : "Jump Game (到達?)",
                  tint: .purple, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 5) {
                    ForEach(nums.indices, id: \.self) { i in
                        let reached = i <= maxReach
                        tile(width: 30, height: 30,
                             bg: i == idx ? .yellow : (reached ? .purple.opacity(0.5) : .white.opacity(0.15)),
                             fg: i == idx ? .black : .white) { Text("\(nums[i])") }
                    }
                }
                Text("nums[i] = ジャンプできる最大距離")
                    .font(.caption2).foregroundStyle(.secondary)
                HStack(spacing: 10) {
                    Text("maxReach = \(maxReach)")
                        .font(.system(.caption, design: .monospaced).weight(.bold))
                        .foregroundStyle(.purple)
                    if countMode {
                        Text("jumps = \(jumps)")
                            .font(.system(.caption, design: .monospaced).weight(.bold))
                            .foregroundStyle(.orange)
                    }
                }
                if idx == nums.count - 1 {
                    Text(countMode ? "🎯 最小 \(jumps) 回で到達" : "✅ 到達できた！")
                        .font(.caption.weight(.bold)).foregroundStyle(.green)
                }
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        idx = -1; maxReach = 0; jumps = 0
        var curEnd = 0, far = 0
        for i in nums.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.8) {
                guard t == token else { return }
                withAnimation {
                    idx = i
                    far = max(far, i + nums[i])
                    maxReach = far
                    if countMode && i == curEnd && i < nums.count - 1 {
                        jumps += 1
                        curEnd = far
                    }
                }
            }
        }
    }
}

// MARK: - Spiral Matrix

struct SpiralMatrixAnim: View {
    let rows = 4, cols = 4
    @State private var visited: [(Int, Int)] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Spiral Matrix", tint: .indigo, onReplay: play) {
            VStack(spacing: 4) {
                ForEach(0..<rows, id: \.self) { r in
                    HStack(spacing: 4) {
                        ForEach(0..<cols, id: \.self) { c in
                            let order = visited.firstIndex(where: { $0 == (r, c) })
                            tile(width: 30, height: 30,
                                 bg: order != nil ? .indigo.opacity(0.65) : .white.opacity(0.18),
                                 fg: .white) {
                                Text(order.map { "\($0 + 1)" } ?? "·")
                            }
                        }
                    }
                }
                Text("外周から内側へ螺旋に走査")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        visited = []
        var top = 0, bot = rows - 1, left = 0, right = cols - 1
        var seq: [(Int, Int)] = []
        while top <= bot && left <= right {
            for c in left...right { seq.append((top, c)) }
            top += 1
            if top > bot { break }
            for r in top...bot { seq.append((r, right)) }
            right -= 1
            if left > right { break }
            for c in stride(from: right, through: left, by: -1) { seq.append((bot, c)) }
            bot -= 1
            if top > bot { break }
            for r in stride(from: bot, through: top, by: -1) { seq.append((r, left)) }
            left += 1
        }
        for (i, p) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25 + Double(i) * 0.18) {
                guard t == token else { return }
                withAnimation { visited.append(p) }
            }
        }
    }
}

// MARK: - Product Except Self (prefix * suffix)

struct ProductExceptSelfAnim: View {
    let nums: [Int] = [1, 2, 3, 4]
    @State private var prefix: [Int] = []
    @State private var suffix: [Int] = []
    @State private var result: [Int] = []
    @State private var phase = 0   // 0=start 1=prefix 2=suffix 3=combine
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Product Except Self", tint: .teal, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                row(label: "nums", values: nums.map(String.init), color: .gray)
                row(label: "prefix→", values: prefix.map(String.init), color: .blue)
                row(label: "←suffix", values: suffix.map(String.init), color: .orange)
                row(label: "result", values: result.map(String.init), color: .green)
                Text("output[i] = prefix[i] × suffix[i] (自分以外の積)")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func row(label: String, values: [String], color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .frame(width: 54, alignment: .leading)
                .foregroundStyle(color)
            ForEach(Array(values.enumerated()), id: \.offset) { _, s in
                tile(width: 28, height: 26, bg: color.opacity(0.4)) { Text(s) }
            }
        }
    }
    private func play() {
        token += 1; let t = token
        prefix = []; suffix = []; result = []
        var p = 1
        for i in nums.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.5) {
                guard t == token else { return }
                withAnimation { prefix.append(p) }
                p *= nums[i]
            }
        }
        let base = 0.4 + Double(nums.count) * 0.5 + 0.3
        var s = 1
        var sArr: [Int] = Array(repeating: 0, count: nums.count)
        for i in stride(from: nums.count - 1, through: 0, by: -1) {
            sArr[i] = s
            s *= nums[i]
        }
        for i in nums.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + base + Double(i) * 0.5) {
                guard t == token else { return }
                withAnimation { suffix.append(sArr[i]) }
            }
        }
        let base2 = base + Double(nums.count) * 0.5 + 0.3
        for i in nums.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + base2 + Double(i) * 0.5) {
                guard t == token else { return }
                if i < prefix.count && i < suffix.count {
                    withAnimation { result.append(prefix[i] * suffix[i]) }
                }
            }
        }
    }
}

// MARK: - Roman to Int (char-by-char)

struct RomanToIntAnim: View {
    let s: String = "MCMXCIV"   // 1994
    @State private var idx = -1
    @State private var total = 0
    @State private var note: String = ""
    @State private var token = 0

    private let map: [Character: Int] = ["I":1,"V":5,"X":10,"L":50,"C":100,"D":500,"M":1000]

    var body: some View {
        AnimFrame(title: "Roman → Int  (\"\(s)\")", tint: .brown, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(Array(s.enumerated()), id: \.offset) { i, c in
                        tile(width: 28, height: 32,
                             bg: i == idx ? .yellow : (i < idx ? .brown.opacity(0.45) : .white.opacity(0.18)),
                             fg: i == idx ? .black : .white) {
                            Text(String(c)).font(.system(size: 13, weight: .black, design: .serif))
                        }
                    }
                }
                Text("total = \(total)")
                    .font(.system(.title3, design: .monospaced).weight(.black))
                    .foregroundStyle(.brown)
                if !note.isEmpty {
                    Text(note).font(.caption2.weight(.semibold)).foregroundStyle(.secondary)
                }
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        idx = -1; total = 0; note = ""
        let chars = Array(s)
        for i in chars.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                let v = map[chars[i]] ?? 0
                let nv = (i + 1 < chars.count) ? (map[chars[i + 1]] ?? 0) : 0
                withAnimation {
                    idx = i
                    if v < nv {
                        total -= v
                        note = "\(chars[i]) < \(chars[i+1]) → 引く (-\(v))"
                    } else {
                        total += v
                        note = "\(chars[i]) = \(v) → 加える"
                    }
                }
            }
        }
    }
}

// MARK: - KMP Failure Function

struct KMPFailureAnim: View {
    let pat: String = "ababaca"
    @State private var fail: [Int] = []
    @State private var idx = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "KMP failure 関数", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(Array(pat.enumerated()), id: \.offset) { i, c in
                        tile(width: 28, height: 28,
                             bg: i == idx ? .yellow : .indigo.opacity(0.35),
                             fg: i == idx ? .black : .white) {
                            Text(String(c)).font(.system(size: 12, weight: .black, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("fail").font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(.indigo).frame(width: 28, alignment: .leading)
                    ForEach(fail.indices, id: \.self) { i in
                        tile(width: 28, height: 28,
                             bg: i == idx ? .green : .indigo.opacity(0.25)) {
                            Text("\(fail[i])")
                        }
                    }
                }
                Text("fail[i] = 接頭辞=接尾辞 となる最大長")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        fail = []; idx = -1
        let p = Array(pat); var lps = Array(repeating: 0, count: p.count)
        var len = 0, i = 1
        var seq: [(idx: Int, val: Int)] = [(0, 0)]
        while i < p.count {
            if p[i] == p[len] { len += 1; lps[i] = len; seq.append((i, len)); i += 1 }
            else if len > 0 { len = lps[len - 1] }
            else { lps[i] = 0; seq.append((i, 0)); i += 1 }
        }
        for (k, step) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation {
                    idx = step.idx
                    while fail.count <= step.idx { fail.append(0) }
                    fail[step.idx] = step.val
                }
            }
        }
    }
}

// MARK: - LRU Cache (linked list + recency)

struct LRUCacheAnim: View {
    let capacity = 3
    let ops: [(String, Int, Int?)] = [
        ("put", 1, 10), ("put", 2, 20), ("put", 3, 30),
        ("get", 1, nil), ("put", 4, 40), ("get", 2, nil)
    ]
    @State private var cache: [(key: Int, val: Int)] = []
    @State private var step = -1
    @State private var note = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "LRU Cache (cap=\(capacity))", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("MRU →")
                        .font(.caption2.weight(.heavy)).foregroundStyle(.pink)
                    ForEach(cache.indices, id: \.self) { i in
                        tile(width: 44, height: 40, bg: .pink.opacity(0.6)) {
                            VStack(spacing: 0) {
                                Text("k=\(cache[i].key)").font(.system(size: 10, weight: .heavy))
                                Text("v=\(cache[i].val)").font(.system(size: 9))
                            }
                        }
                    }
                    Text("← LRU")
                        .font(.caption2.weight(.heavy)).foregroundStyle(.pink.opacity(0.6))
                }
                if step >= 0 && step < ops.count {
                    let o = ops[step]
                    Text("op: \(o.0)(\(o.1)\(o.2.map { ", \($0)" } ?? ""))")
                        .font(.system(.caption, design: .monospaced).weight(.bold))
                        .foregroundStyle(.pink)
                }
                if !note.isEmpty {
                    Text(note).font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        cache = []; step = -1; note = ""
        for (k, o) in ops.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 1.1) {
                guard t == token else { return }
                withAnimation {
                    step = k
                    if o.0 == "put" {
                        if let idx = cache.firstIndex(where: { $0.key == o.1 }) { cache.remove(at: idx) }
                        cache.insert((o.1, o.2!), at: 0)
                        if cache.count > capacity { let removed = cache.removeLast(); note = "容量超過 → k=\(removed.key) を evict" }
                        else { note = "k=\(o.1) を MRU へ" }
                    } else {
                        if let idx = cache.firstIndex(where: { $0.key == o.1 }) {
                            let entry = cache.remove(at: idx)
                            cache.insert(entry, at: 0)
                            note = "ヒット v=\(entry.val) → MRU へ"
                        } else { note = "miss" }
                    }
                }
            }
        }
    }
}

// MARK: - Queue: Implement with Two Stacks

struct TwoStacksQueueAnim: View {
    @State private var inStack: [Int] = []
    @State private var outStack: [Int] = []
    @State private var op = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Queue with Two Stacks", tint: .blue, onReplay: play) {
            HStack(spacing: 18) {
                stackView(label: "in", arr: inStack, color: .blue)
                Image(systemName: "arrow.right").foregroundStyle(.blue)
                stackView(label: "out", arr: outStack, color: .green)
            }
            VStack(spacing: 4) {
                Text(op).font(.caption2.weight(.heavy)).foregroundStyle(.blue)
                Text("push は in、pop は out → 空なら in を反転して移送")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func stackView(label: String, arr: [Int], color: Color) -> some View {
        VStack(spacing: 2) {
            ForEach(arr.indices.reversed(), id: \.self) { i in
                tile(width: 38, height: 24, bg: color.opacity(0.55)) { Text("\(arr[i])") }
            }
            ForEach(0..<max(0, 3 - arr.count), id: \.self) { _ in
                tile(width: 38, height: 24, bg: color.opacity(0.10), fg: .white.opacity(0.5)) { Text("·") }
            }
            Text(label).font(.caption2.weight(.heavy)).foregroundStyle(color)
        }
    }
    private func play() {
        token += 1; let t = token
        inStack = []; outStack = []; op = ""
        let actions: [(String, Int?)] = [("push", 1), ("push", 2), ("push", 3),
                                          ("pop", nil), ("push", 4), ("pop", nil)]
        for (k, (a, v)) in actions.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 1.1) {
                guard t == token else { return }
                withAnimation {
                    if a == "push", let x = v {
                        inStack.append(x); op = "push(\(x)) → in"
                    } else {
                        if outStack.isEmpty {
                            outStack = inStack.reversed(); inStack = []
                            op = "out が空 → in を反転して移送"
                        }
                        if let popped = outStack.popLast() { op = "pop() = \(popped)" }
                    }
                }
            }
        }
    }
}

// MARK: - Circular Queue

struct CircularQueueAnim: View {
    let cap = 5
    @State private var buf: [Int?] = Array(repeating: nil, count: 5)
    @State private var head = 0
    @State private var size = 0
    @State private var op = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Circular Queue (cap=\(cap))", tint: .orange, onReplay: play) {
            VStack(spacing: 8) {
                ZStack {
                    Circle().stroke(Color.orange.opacity(0.45), lineWidth: 1.4)
                        .frame(width: 160, height: 160)
                    ForEach(0..<cap, id: \.self) { i in
                        let angle = Double(i) / Double(cap) * 2 * .pi - .pi / 2
                        let x = cos(angle) * 70
                        let y = sin(angle) * 70
                        let isHead = i == head && size > 0
                        let tail = (head + size - 1 + cap) % cap
                        let isTail = i == tail && size > 0
                        ZStack {
                            Circle()
                                .fill(buf[i] != nil ? .orange : .gray.opacity(0.18))
                                .frame(width: 36, height: 36)
                            Text(buf[i].map { "\($0)" } ?? "")
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(.white)
                            if isHead {
                                Text("H").font(.system(size: 9, weight: .black))
                                    .foregroundStyle(.green).offset(y: -28)
                            }
                            if isTail {
                                Text("T").font(.system(size: 9, weight: .black))
                                    .foregroundStyle(.blue).offset(y: 28)
                            }
                        }
                        .offset(x: x, y: y)
                    }
                }
                .frame(height: 180)
                Text(op).font(.caption.weight(.heavy)).foregroundStyle(.orange)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        buf = Array(repeating: nil, count: cap); head = 0; size = 0; op = ""
        let actions: [(String, Int?)] = [
            ("enQ", 1), ("enQ", 2), ("enQ", 3), ("deQ", nil),
            ("enQ", 4), ("enQ", 5), ("enQ", 6)
        ]
        for (k, (a, v)) in actions.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 1.0) {
                guard t == token else { return }
                withAnimation {
                    if a == "enQ", let x = v {
                        if size == cap { op = "Full → enQ(\(x)) 拒否" }
                        else {
                            let tail = (head + size) % cap
                            buf[tail] = x; size += 1
                            op = "enQ(\(x)) → index \(tail)"
                        }
                    } else {
                        if size == 0 { op = "Empty → deQ 拒否" }
                        else { buf[head] = nil; let h = head; head = (head + 1) % cap; size -= 1
                               op = "deQ → index \(h)" }
                    }
                }
            }
        }
    }
}

// MARK: - Pascal's Triangle

struct PascalsTriangleAnim: View {
    let rows = 6
    @State private var triangle: [[Int]] = []
    @State private var curR = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Pascal's Triangle", tint: .purple, onReplay: play) {
            VStack(spacing: 4) {
                ForEach(triangle.indices, id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(triangle[r].indices, id: \.self) { c in
                            tile(width: 28, height: 24,
                                 bg: r == curR ? .yellow : .purple.opacity(0.45),
                                 fg: r == curR ? .black : .white) {
                                Text("\(triangle[r][c])")
                            }
                        }
                    }
                }
            }
            Text("row[i][j] = row[i-1][j-1] + row[i-1][j]")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        triangle = []; curR = -1
        for r in 0..<rows {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(r) * 0.6) {
                guard t == token else { return }
                var row = [1]
                if r > 0 {
                    let prev = triangle[r - 1]
                    for j in 1..<prev.count { row.append(prev[j - 1] + prev[j]) }
                    row.append(1)
                }
                withAnimation { triangle.append(row); curR = r }
            }
        }
    }
}

// MARK: - Coin Change (DP min coins)

struct CoinChangeAnim: View {
    let coins: [Int] = [1, 2, 5]
    let amount: Int = 7
    @State private var dp: [Int] = []
    @State private var curI = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Coin Change (amount=\(amount))", tint: .yellow, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                Text("coins = \(coins)").font(.caption2).foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    ForEach(dp.indices, id: \.self) { i in
                        tile(width: 28, height: 30,
                             bg: i == curI ? .yellow : (dp[i] == Int.max ? .red.opacity(0.35) : .green.opacity(0.4)),
                             fg: i == curI ? .black : .white) {
                            VStack(spacing: 0) {
                                Text(dp[i] == Int.max ? "∞" : "\(dp[i])")
                                    .font(.system(size: 11, weight: .black))
                                Text("\(i)").font(.system(size: 8))
                            }
                        }
                    }
                }
                Text("dp[a] = min(dp[a-c]+1) for c in coins")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        dp = Array(repeating: Int.max, count: amount + 1)
        dp[0] = 0
        curI = -1
        for i in 1...amount {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.6) {
                guard t == token else { return }
                var v = Int.max
                for c in coins where i - c >= 0 && dp[i - c] != Int.max {
                    v = min(v, dp[i - c] + 1)
                }
                withAnimation { dp[i] = v; curI = i }
            }
        }
    }
}

// MARK: - Longest Palindrome (Expand around center)

struct LongestPalindromeAnim: View {
    let s: String = "babad"
    @State private var center = 0
    @State private var l = 0
    @State private var r = 0
    @State private var best: (l: Int, r: Int) = (0, 0)
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Longest Palindrome (中心展開)", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(Array(s.enumerated()), id: \.offset) { i, c in
                        let inBest = i >= best.l && i <= best.r
                        let inCur = i >= l && i <= r
                        tile(width: 28, height: 30,
                             bg: inBest ? .pink : (inCur ? .yellow : .white.opacity(0.18)),
                             fg: inBest ? .white : (inCur ? .black : .white)) {
                            Text(String(c)).font(.system(size: 12, weight: .black, design: .serif))
                        }
                    }
                }
                Text("center=\(center) → [\(l), \(r)]")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                Text("best = \"\(String(Array(s)[best.l...best.r]))\"")
                    .font(.caption.weight(.heavy)).foregroundStyle(.pink)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        l = 0; r = 0; center = 0; best = (0, 0)
        let chars = Array(s)
        var stepDelay = 0.4
        for i in chars.indices {
            // odd expansion
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDelay) {
                guard t == token else { return }
                withAnimation { center = i; l = i; r = i }
            }
            stepDelay += 0.5
            var (a, b) = (i, i)
            while a >= 0 && b < chars.count && chars[a] == chars[b] {
                let (la, rb) = (a, b)
                DispatchQueue.main.asyncAfter(deadline: .now() + stepDelay) {
                    guard t == token else { return }
                    withAnimation {
                        l = la; r = rb
                        if rb - la > best.r - best.l { best = (la, rb) }
                    }
                }
                stepDelay += 0.4
                a -= 1; b += 1
            }
        }
    }
}

// MARK: - Topic dispatcher

@ViewBuilder
func topicAnimation(for problem: PuzzleProblem) -> some View {
    switch problem.id {
    // Binary search variants — それぞれ違う配列と target で動かす
    case "binary-search":
        BinarySearchAnim(nums: [1, 3, 5, 7, 9, 11, 13],
                         target: 11,
                         caption: "ソート済の中から 11 を探す")
    case "search-rotated":
        BinarySearchAnim(nums: [6, 7, 8, 1, 2, 3, 4, 5],
                         target: 3,
                         caption: "回転済の配列から 3 を探す (片側がソート済)")
    case "first-last-pos":
        BinarySearchAnim(nums: [1, 2, 2, 2, 3, 4, 5],
                         target: 2,
                         caption: "最初/最後の 2 を求める (lower / upper bound)")
    case "median-two-arrays":
        BinarySearchAnim(nums: [1, 3, 5, 8, 10, 14, 17],
                         target: 8,
                         caption: "2つの配列をマージした中央値の位置を二分探索")
    // Two pointers / strings
    case "palindrome-check": TwoPointerAnim(word: "racecar")
    case "reverse-string": TwoPointerAnim(word: "hello")
    case "container-water": WaterAnim(kind: .container)
    case "trapping-rain": WaterAnim(kind: .trapping)
    // Anagram
    case "anagram-check": AnagramAnim(a: "anagram", b: "nagaram")
    case "group-anagrams": AnagramAnim(a: "eat", b: "tea")
    // Sorting
    case "bubble-sort": SortingAnim(kind: .bubble)
    case "insertion-sort": SortingAnim(kind: .insertion)
    case "selection-sort": SortingAnim(kind: .selection)
    case "counting-sort": SortingAnim(kind: .counting)
    case "quicksort": SortingAnim(kind: .quick)
    case "merge-sort": SortingAnim(kind: .merge)
    case "dutch-flag": SortingAnim(kind: .dutch)
    case "rotate-array": SortingAnim(kind: .rotate)
    case "merge-intervals": SortingAnim(kind: .merge)
    // Stack
    case "valid-parentheses": StackAnim(input: ["(","(",")",")","[","]"], kind: .parens)
    case "min-stack": StackAnim(input: ["3","5","2","1"], kind: .minStack)
    case "next-greater": StackAnim(input: ["2","1","3","2","4"], kind: .monotonic)
    case "largest-rectangle": StackAnim(input: ["2","1","5","6","2","3"], kind: .monotonic)
    case "longest-valid-parens": DPTableAnim(kind: .longestValidParens)
    // Linked list
    case "reverse-linked-list": LinkedListAnim(kind: .reverse)
    case "merge-two-lists": LinkedListAnim(kind: .merge)
    case "middle-ll": LinkedListAnim(kind: .middle)
    case "detect-cycle": LinkedListAnim(kind: .cycle)
    case "add-two-numbers": LinkedListAnim(kind: .addNumbers)
    case "intersection-ll": LinkedListAnim(kind: .intersection)
    // Sliding window
    case "longest-substring": SlidingWindowAnim(s: "abcabcbb", initialWidth: 1)
    case "min-window-substring": SlidingWindowAnim(s: "ADOBECODEBANC", initialWidth: 1)
    case "sliding-window-max": HeapAnim(kind: .slidingMax)
    // BFS / DFS / Graph — それぞれ違うグリッド
    case "bfs":
        GridSearchAnim(kind: .bfs,
                       grid: [[1,1,1,0,0],[0,1,0,0,1],[0,1,1,1,1],[0,0,0,1,0]],
                       subtitle: "距離の近いマスから順に訪問")
    case "dfs-iterative":
        GridSearchAnim(kind: .dfs,
                       grid: [[1,1,0,0,0],[1,0,0,1,1],[0,0,1,1,0],[0,1,1,0,0]],
                       subtitle: "深さ優先で 1 本道を最後まで")
    case "num-islands":
        GridSearchAnim(kind: .bfs,
                       grid: [[1,1,0,0,1],[1,0,0,1,1],[0,0,1,0,0],[1,0,0,1,1]],
                       subtitle: "島ごとに塗りつぶしてカウント")
    case "level-order":
        TreeTraversalAnim(order: .level, nodes: [3,9,20,1,2,15,7],
                          subtitle: "BFS で同じ深さをまとめて出力")
    case "topo-sort":
        GridSearchAnim(kind: .dfs,
                       grid: [[1,1,1,0,0],[0,0,1,1,1],[0,0,0,1,0],[0,0,0,0,1]],
                       subtitle: "後行順序の逆 = トポロジカル順")
    case "course-schedule":
        GridSearchAnim(kind: .dfs,
                       grid: [[1,1,0,1,0],[1,1,0,0,1],[0,0,1,1,0],[1,0,1,1,0]],
                       subtitle: "サイクルがあれば履修不可能")
    case "dijkstra":
        GridSearchAnim(kind: .bfs,
                       grid: [[1,1,1,1,1],[1,0,0,0,1],[1,0,1,0,1],[1,1,1,0,1]],
                       subtitle: "距離が短いノードから確定")
    case "union-find": UnionFindAnim(kind: .basic)
    case "kruskal": UnionFindAnim(kind: .kruskal)
    // Tree — それぞれ違う木の形と副題で動かす
    case "inorder-iter":
        TreeTraversalAnim(order: .inorder, nodes: [4,2,6,1,3,5,7],
                          subtitle: "スタックで反復的に inorder")
    case "validate-bst":
        TreeTraversalAnim(order: .inorder, nodes: [5,3,8,2,4,7,9],
                          subtitle: "BST なら inorder = 昇順になる")
    case "kth-smallest-bst":
        TreeTraversalAnim(order: .inorder, nodes: [5,3,8,1,4,7,9],
                          subtitle: "inorder の k 番目 = k 番目に小さい値")
    case "lca-bt":
        TreeTraversalAnim(order: .preorder, nodes: [3,5,1,6,2,0,8],
                          subtitle: "LCA 探索の preorder")
    case "lca-bst":
        TreeTraversalAnim(order: .preorder, nodes: [6,2,8,0,4,7,9],
                          subtitle: "BST の性質で左右を絞り込む")
    case "flatten-bt":
        TreeTraversalAnim(order: .preorder, nodes: [1,2,5,3,4,0,6],
                          subtitle: "preorder の順に右に flatten")
    case "build-tree-post":
        TreeTraversalAnim(order: .preorder, nodes: [3,9,20,0,0,15,7],
                          subtitle: "inorder+postorder から木を復元")
    case "max-depth-bt":
        TreeTraversalAnim(order: .postorder, nodes: [3,9,20,0,0,15,7],
                          subtitle: "葉まで降りて深さ +1 を返す")
    case "balanced-bt":
        TreeTraversalAnim(order: .postorder, nodes: [3,9,20,1,2,15,7],
                          subtitle: "高さ差 ≤ 1 をボトムアップで判定")
    case "diameter-bt":
        TreeTraversalAnim(order: .postorder, nodes: [1,2,3,4,5,6,7],
                          subtitle: "各ノードで 左深さ + 右深さ の最大")
    case "path-sum":
        TreeTraversalAnim(order: .postorder, nodes: [5,4,8,11,2,13,1],
                          subtitle: "葉まで降りて合計が target か")
    case "invert-bt":
        TreeTraversalAnim(order: .postorder, nodes: [4,2,7,1,3,6,9],
                          subtitle: "左右を swap しながら戻る")
    case "symmetric-tree":
        TreeTraversalAnim(order: .postorder, nodes: [1,2,2,3,4,4,3],
                          subtitle: "左右ミラーで対応比較")
    case "serialize-bt":
        TreeTraversalAnim(order: .level, nodes: [1,2,3,4,5,6,7],
                          subtitle: "BFS で順番に出力 (null 含む)")
    // DP
    case "fibonacci-memo": DPTableAnim(kind: .fib)
    case "house-robber": DPTableAnim(kind: .robber)
    case "lcs": DPTableAnim(kind: .lcs)
    case "lis": DPTableAnim(kind: .lis)
    case "knapsack": DPTableAnim(kind: .knapsack)
    case "unique-paths": DPTableAnim(kind: .uniquePaths)
    case "edit-distance": DPTableAnim(kind: .editDist)
    case "min-path-sum": DPTableAnim(kind: .minPath)
    case "decode-ways": DPTableAnim(kind: .decode)
    case "word-break": DPTableAnim(kind: .wordBreak)
    case "regex-matching": DPTableAnim(kind: .regex)
    case "wildcard-matching": DPTableAnim(kind: .wildcard)
    case "max-subarray": DPTableAnim(kind: .maxSubarray)
    case "count-bits": DPTableAnim(kind: .countBits)
    // Heap
    case "kth-largest": HeapAnim(kind: .kthLargest)
    case "top-k-freq": HeapAnim(kind: .topK)
    case "meeting-rooms": HeapAnim(kind: .meetingRooms)
    // Bit
    case "single-number": BitAnim(kind: .singleNumber)
    case "power-of-two": BitAnim(kind: .powerOfTwo)
    case "reverse-bits": BitAnim(kind: .reverseBits)
    // Backtracking
    case "combinations": BacktrackingAnim(kind: .combinations)
    case "subsets": BacktrackingAnim(kind: .subsets)
    case "permutations": BacktrackingAnim(kind: .permutations)
    case "n-queens": BacktrackingAnim(kind: .nQueens)
    case "word-search": BacktrackingAnim(kind: .wordSearch)
    // Trie
    case "trie-insert": TrieAnim(kind: .insert)
    case "trie-search": TrieAnim(kind: .search)
    // Math
    case "gcd": GCDAnim()
    case "fast-pow": FastPowAnim()
    case "sieve": SieveAnim()
    // Floyd's cycle (Array variant)
    case "find-duplicate": FloydAnim()
    // 追加マッピング (Phase B: 専用アニメ)
    case "longest-palindrome":      LongestPalindromeAnim()
    case "roman-to-int":            RomanToIntAnim()
    case "product-except-self":     ProductExceptSelfAnim()
    case "kmp-lps":                 KMPFailureAnim()
    case "jump-game":               JumpGameAnim(nums: [2, 3, 1, 1, 4], countMode: false)
    case "jump-game-ii":            JumpGameAnim(nums: [2, 3, 1, 1, 4], countMode: true)
    case "buy-sell-stock":          BuySellStockAnim()
    case "spiral-matrix":           SpiralMatrixAnim()
    case "two-sum":                 TwoSumAnim()
    case "lru-cache":               LRUCacheAnim()
    case "climbing-stairs":         ClimbingStairsAnim()
    case "coin-change":             CoinChangeAnim()
    case "pascals-triangle":        PascalsTriangleAnim()
    // Queue 3 問
    case "queue-two-stacks":        TwoStacksQueueAnim()
    case "queue-bfs-shortest":      GridSearchAnim(kind: .bfs,
                                                   grid: [[1,1,1,0,1],[0,1,0,0,1],[0,1,1,1,1],[0,0,0,0,1]],
                                                   subtitle: "deque で最短経路を探す")
    case "queue-circular":          CircularQueueAnim()
    // 上にどれもマッチしなければ、topic 文字列で fallback (TopicIllustration と同じ判定)
    default:
        topicAnimationFallback(topic: problem.topic)
    }
}

/// topic キーワードに応じた汎用アニメ。id 単位のマッピングに漏れた問題のため。
/// 英語 (PuzzleProblem.topic) と日本語 (ReorderQuiz.topic) 両方のキーワードに対応。
@ViewBuilder
func topicAnimationFallback(topic: String) -> some View {
    let t = topic.lowercased()
    if t.contains("two pointer") || t.contains("2 ポインタ") {
        TwoPointerAnim(word: "hello")
    } else if t.contains("binary search") || t.contains("二分探索") {
        BinarySearchAnim()
    } else if t.contains("merge sort") || t.contains("マージソート") {
        SortingAnim(kind: .merge)
    } else if t.contains("quick") || t.contains("クイックソート") {
        SortingAnim(kind: .quick)
    } else if t.contains("insertion") || t.contains("挿入ソート") {
        SortingAnim(kind: .insertion)
    } else if t.contains("bubble") || t.contains("バブルソート") {
        SortingAnim(kind: .bubble)
    } else if t.contains("selection") || t.contains("選択ソート") {
        SortingAnim(kind: .selection)
    } else if t.contains("counting") || t.contains("counting sort") {
        SortingAnim(kind: .counting)
    } else if t.contains("sort") || t.contains("ソート") {
        SortingAnim(kind: .bubble)
    } else if t.contains("hash") || t.contains("ハッシュ") {
        DPTableAnim(kind: .fib)
    } else if t.contains("stack") || t.contains("スタック") {
        StackAnim(input: ["1","2","3"], kind: .parens)
    } else if t.contains("queue") || t.contains("キュー") || t.contains("デック") {
        GridSearchAnim(kind: .bfs)
    } else if t.contains("linked list") || t.contains("リンクリスト") || t.contains("連結リスト") {
        LinkedListAnim(kind: .reverse)
    } else if t.contains("trie") {
        TrieAnim(kind: .insert)
    } else if t.contains("tree") || t.contains("bst") || t.contains("木") {
        TreeTraversalAnim(order: .inorder)
    } else if t.contains("dijkstra") || t.contains("ダイクストラ") {
        GridSearchAnim(kind: .bfs)
    } else if t.contains("graph") || t.contains("bfs") || t.contains("dfs") || t.contains("グラフ") {
        GridSearchAnim(kind: .bfs)
    } else if t.contains("dp") || t.contains("dynamic") || t.contains("メモ化") || t.contains("lis") {
        DPTableAnim(kind: .fib)
    } else if t.contains("backtrack") || t.contains("バックトラック") || t.contains("順列") {
        BacktrackingAnim(kind: .combinations)
    } else if t.contains("sliding") || t.contains("スライディング") {
        SlidingWindowAnim(s: "abcabc", initialWidth: 1)
    } else if t.contains("bit") || t.contains("ビット") {
        BitAnim(kind: .singleNumber)
    } else if t.contains("greedy") || t.contains("貪欲") {
        SortingAnim(kind: .selection)
    } else if t.contains("heap") || t.contains("ヒープ") {
        HeapAnim(kind: .kthLargest)
    } else if t.contains("union find") || t.contains("union") {
        UnionFindAnim(kind: .basic)
    } else if t.contains("hanoi") || t.contains("ハノイ") || t.contains("再帰") {
        BacktrackingAnim(kind: .combinations)
    } else if t.contains("string") || t.contains("文字列") || t.contains("kmp") {
        TwoPointerAnim(word: "abcab")
    } else if t.contains("math") || t.contains("数学") {
        GCDAnim()
    } else {
        // 最後の砦：何かしら動くものを出す
        SortingAnim(kind: .bubble)
    }
}
