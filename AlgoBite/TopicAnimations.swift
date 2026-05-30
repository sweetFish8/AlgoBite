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

// MARK: - Reverse Linked List (arrows flip)

struct ReverseLinkedListAnim: View {
    let vals = [1, 2, 3, 4, 5]
    @State private var prevIdx = -1  // 既に反転済みの末端
    @State private var curIdx = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Reverse Linked List", tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 0) {
                    ForEach(vals.indices, id: \.self) { i in
                        let done = i <= prevIdx
                        let isCur = i == curIdx
                        tile(width: 30, height: 30,
                             bg: done ? .green : (isCur ? .yellow : .blue.opacity(0.4)),
                             fg: isCur ? .black : .white) { Text("\(vals[i])") }
                        if i < vals.count - 1 {
                            Image(systemName: i <= prevIdx ? "arrow.left" : "arrow.right")
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(i <= prevIdx ? .green : .secondary)
                                .frame(width: 14)
                        }
                    }
                }
                Text("prev=\(prevIdx < 0 ? "nil" : "\(vals[prevIdx])")  cur=\(curIdx < vals.count ? "\(vals[curIdx])" : "nil")")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                Text("cur.next を prev に向け、prev/cur を 1 つ進める")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        prevIdx = -1; curIdx = 0
        for k in 0...vals.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.8) {
                guard t == token else { return }
                withAnimation { prevIdx = k - 1; curIdx = k }
            }
        }
    }
}

// MARK: - Merge Two Sorted Lists

struct MergeTwoListsAnim: View {
    let a = [1, 3, 5, 7]
    let b = [2, 4, 6, 8, 10]
    @State private var i = 0
    @State private var j = 0
    @State private var merged: [Int] = []
    @State private var lastFrom: Character? = nil   // 'a' or 'b'
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Merge Two Sorted Lists", tint: .teal, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                row("a", arr: a, ptr: i, color: .blue, taken: lastFrom == "a")
                row("b", arr: b, ptr: j, color: .orange, taken: lastFrom == "b")
                HStack(spacing: 4) {
                    Text("merged →")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(.teal)
                    ForEach(merged.indices, id: \.self) { k in
                        tile(width: 26, height: 24, bg: .teal.opacity(0.5)) { Text("\(merged[k])") }
                    }
                }
                Text("先頭同士を比較 → 小さい方を取って前進").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func row(_ label: String, arr: [Int], ptr: Int, color: Color, taken: Bool) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .frame(width: 16).foregroundStyle(color)
            ForEach(arr.indices, id: \.self) { i in
                tile(width: 26, height: 24,
                     bg: i < ptr ? color.opacity(0.20)
                          : (i == ptr ? (taken ? .yellow : color) : color.opacity(0.35)),
                     fg: i == ptr ? .black : .white) { Text("\(arr[i])") }
            }
        }
    }
    private func play() {
        token += 1; let t = token
        i = 0; j = 0; merged = []; lastFrom = nil
        var k = 0
        while i + j < a.count + b.count {
            let pickA = j == b.count || (i < a.count && a[i] <= b[j])
            let val = pickA ? a[i] : b[j]
            let from: Character = pickA ? "a" : "b"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation {
                    merged.append(val); lastFrom = from
                    if pickA { i += 1 } else { j += 1 }
                }
            }
            if pickA { i += 1 } else { j += 1 }
            k += 1
        }
    }
}

// MARK: - Detect Cycle (Floyd's tortoise & hare)

struct DetectCycleFloydAnim: View {
    // 0→1→2→3→4→5→2 (loop back to 2)
    let nodes = [0, 1, 2, 3, 4, 5]
    let cycleStart = 2
    @State private var slow = 0
    @State private var fast = 0
    @State private var found = false
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Detect Cycle (Floyd)", tint: .red, onReplay: play) {
            ZStack {
                // 円周上にノードを配置
                let cnt = nodes.count
                ForEach(0..<cnt, id: \.self) { i in
                    let angle = Double(i) / Double(cnt) * 2 * .pi - .pi / 2
                    let x = cos(angle) * 70
                    let y = sin(angle) * 70
                    ZStack {
                        Circle().fill(Color.red.opacity(0.35))
                            .frame(width: 32, height: 32)
                        Text("\(i)").font(.system(size: 11, weight: .black))
                            .foregroundStyle(.white)
                        if slow == i && fast == i && found {
                            Text("🎯").font(.title3).offset(y: -28)
                        } else {
                            if slow == i { Text("🐢").font(.caption).offset(y: -22) }
                            if fast == i { Text("🐇").font(.caption).offset(y: 22) }
                        }
                    }
                    .offset(x: x, y: y)
                }
            }
            .frame(height: 180)
            VStack(spacing: 2) {
                Text("slow=\(slow)  fast=\(fast)")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                if found {
                    Text("🎯 兎と亀が出会った → サイクルあり")
                        .font(.caption.weight(.bold)).foregroundStyle(.red)
                }
            }
        }
        .onAppear { play() }
    }
    private func next(_ i: Int) -> Int { i == nodes.count - 1 ? cycleStart : i + 1 }
    private func play() {
        token += 1; let t = token
        slow = 0; fast = 0; found = false
        var s = 0, f = 0
        for k in 1...12 {
            s = next(s); f = next(next(f))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.65) {
                guard t == token else { return }
                let curS = s, curF = f
                withAnimation { slow = curS; fast = curF }
                if curS == curF {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        guard t == token else { return }
                        withAnimation { found = true }
                    }
                }
            }
            if s == f { break }
        }
    }
}

// MARK: - Add Two Numbers (digit column + carry)

struct AddTwoNumbersAnim: View {
    let a = [2, 4, 3]   // 342 (頭から1の位)
    let b = [5, 6, 4]   // 465 (頭から1の位)
    @State private var idx = -1
    @State private var carry = 0
    @State private var result: [Int] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Add Two Numbers", tint: .purple, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                row("a", arr: a)
                row("b", arr: b)
                HStack(spacing: 6) {
                    Text("=").font(.system(size: 14, weight: .black))
                    ForEach(result.indices, id: \.self) { i in
                        tile(width: 28, height: 28, bg: .purple) { Text("\(result[i])") }
                    }
                }
                Text("carry = \(carry)")
                    .font(.system(.caption, design: .monospaced).weight(.heavy))
                    .foregroundStyle(.purple)
                Text("各桁を a[i] + b[i] + carry、carry = sum / 10")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func row(_ label: String, arr: [Int]) -> some View {
        HStack(spacing: 6) {
            Text(label).font(.system(size: 12, weight: .black, design: .monospaced))
                .frame(width: 16, alignment: .leading).foregroundStyle(.purple)
            ForEach(arr.indices, id: \.self) { i in
                tile(width: 28, height: 28,
                     bg: i == idx ? .yellow : .purple.opacity(0.4),
                     fg: i == idx ? .black : .white) { Text("\(arr[i])") }
            }
        }
    }
    private func play() {
        token += 1; let t = token
        idx = -1; carry = 0; result = []
        var c = 0
        for i in 0..<max(a.count, b.count) {
            let av = i < a.count ? a[i] : 0
            let bv = i < b.count ? b[i] : 0
            let sum = av + bv + c
            let d = sum % 10
            c = sum / 10
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 1.0) {
                guard t == token else { return }
                withAnimation { idx = i; result.append(d); carry = c }
            }
        }
    }
}

// MARK: - Middle of Linked List (slow / fast)

struct MiddleOfLLAnim: View {
    let vals = [1, 2, 3, 4, 5, 6, 7]
    @State private var slow = 0
    @State private var fast = 0
    @State private var done = false
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Middle of Linked List", tint: .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(vals.indices, id: \.self) { i in
                        ZStack {
                            tile(width: 30, height: 32,
                                 bg: done && i == slow ? .green : .green.opacity(0.35)) {
                                Text("\(vals[i])")
                            }
                            if slow == i { Text("🐢").font(.system(size: 11)).offset(y: -22) }
                            if fast == i { Text("🐇").font(.system(size: 11)).offset(y: 22) }
                        }
                    }
                }
                Text("slow=\(slow)  fast=\(fast)")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                if done {
                    Text("🎯 fast が末尾に到達 → slow が中央")
                        .font(.caption.weight(.bold)).foregroundStyle(.green)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        slow = 0; fast = 0; done = false
        var s = 0, f = 0, k = 1
        while f + 2 < vals.count {
            s += 1; f += 2
            let curS = s, curF = f
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.75) {
                guard t == token else { return }
                withAnimation { slow = curS; fast = curF }
            }
            k += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.75 + 0.3) {
            guard t == token else { return }
            withAnimation { done = true }
        }
    }
}

// MARK: - Container With Most Water

struct ContainerWaterAnim: View {
    let height = [1, 8, 6, 2, 5, 4, 8, 3, 7]
    @State private var l = 0
    @State private var r = 8
    @State private var best = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Container With Most Water", tint: .cyan, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(height.indices, id: \.self) { i in
                        ZStack(alignment: .bottom) {
                            // 水
                            if i >= l && i <= r {
                                Rectangle()
                                    .fill(Color.cyan.opacity(0.45))
                                    .frame(width: 22, height: CGFloat(min(height[l], height[r])) * 8)
                            }
                            // 棒
                            Rectangle()
                                .fill(i == l || i == r ? .blue : .gray.opacity(0.45))
                                .frame(width: 22, height: CGFloat(height[i]) * 8)
                        }
                    }
                }
                .padding(.top, 4)
                HStack {
                    Text("l=\(l)  r=\(r)")
                        .font(.system(.caption2, design: .monospaced))
                    Spacer()
                    Text("best = \(best)")
                        .font(.caption.weight(.bold)).foregroundStyle(.cyan)
                }
                Text("低い側を内側へ動かす (高い側を残す)").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        l = 0; r = height.count - 1; best = 0
        var li = 0, ri = height.count - 1
        var k = 0
        while li < ri {
            let area = (ri - li) * min(height[li], height[ri])
            let curL = li, curR = ri
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation { l = curL; r = curR; best = max(best, area) }
            }
            if height[li] < height[ri] { li += 1 } else { ri -= 1 }
            k += 1
        }
    }
}

// MARK: - Trapping Rain Water (per-column water)

struct TrappingRainAnim: View {
    let height = [0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1]
    @State private var idx = -1
    @State private var trapped: [Int] = []
    @State private var leftMax: [Int] = []
    @State private var rightMax: [Int] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Trapping Rain Water", tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(height.indices, id: \.self) { i in
                        ZStack(alignment: .bottom) {
                            if i < trapped.count, trapped[i] > 0 {
                                Rectangle().fill(Color.blue.opacity(0.55))
                                    .frame(width: 16, height: CGFloat(trapped[i]) * 14)
                                    .offset(y: -CGFloat(height[i]) * 14)
                            }
                            Rectangle().fill(i == idx ? .yellow : .gray.opacity(0.6))
                                .frame(width: 16, height: CGFloat(height[i]) * 14)
                        }
                    }
                }
                .padding(.top, 4)
                Text("水量 = min(leftMax[i], rightMax[i]) - height[i]")
                    .font(.caption2).foregroundStyle(.secondary)
                Text("合計水量 = \(trapped.reduce(0, +))")
                    .font(.caption.weight(.bold)).foregroundStyle(.blue)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        idx = -1; trapped = []; leftMax = []; rightMax = []
        let n = height.count
        var lm = Array(repeating: 0, count: n)
        var rm = Array(repeating: 0, count: n)
        var mx = 0
        for i in 0..<n { mx = max(mx, height[i]); lm[i] = mx }
        mx = 0
        for i in stride(from: n - 1, through: 0, by: -1) { mx = max(mx, height[i]); rm[i] = mx }
        for i in 0..<n {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.35) {
                guard t == token else { return }
                let w = max(0, min(lm[i], rm[i]) - height[i])
                withAnimation { idx = i; trapped.append(w) }
            }
        }
    }
}

// MARK: - Anagram Check (char count buckets)

struct AnagramCheckAnim: View {
    let s = "listen"
    let p = "silent"
    @State private var idx = -1
    @State private var counts: [Character: Int] = [:]
    @State private var phase = 0   // 0=adding s, 1=subtracting p, 2=done
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Anagram Check", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("s").font(.system(size: 10, weight: .black, design: .monospaced)).frame(width: 14).foregroundStyle(.green)
                    ForEach(Array(s.enumerated()), id: \.offset) { i, c in
                        tile(width: 22, height: 22,
                             bg: phase == 0 && i == idx ? .yellow : .green.opacity(0.4),
                             fg: phase == 0 && i == idx ? .black : .white) { Text(String(c)) }
                    }
                }
                HStack(spacing: 4) {
                    Text("p").font(.system(size: 10, weight: .black, design: .monospaced)).frame(width: 14).foregroundStyle(.red)
                    ForEach(Array(p.enumerated()), id: \.offset) { i, c in
                        tile(width: 22, height: 22,
                             bg: phase == 1 && i == idx ? .yellow : .red.opacity(0.4),
                             fg: phase == 1 && i == idx ? .black : .white) { Text(String(c)) }
                    }
                }
                HStack(spacing: 4) {
                    ForEach(counts.sorted(by: { $0.key < $1.key }), id: \.key) { kv in
                        VStack(spacing: 1) {
                            Text(String(kv.key)).font(.system(size: 10, weight: .black, design: .monospaced))
                            Text("\(kv.value)").font(.system(size: 11, weight: .heavy))
                                .foregroundStyle(kv.value == 0 ? .green : (kv.value > 0 ? .blue : .red))
                        }
                        .padding(.horizontal, 4)
                    }
                }
                if phase == 2 {
                    let isAnagram = counts.values.allSatisfy { $0 == 0 }
                    Text(isAnagram ? "✅ アナグラム" : "❌ 違う")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(isAnagram ? .green : .red)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        idx = -1; counts = [:]; phase = 0
        let sArr = Array(s), pArr = Array(p)
        for i in sArr.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.4) {
                guard t == token else { return }
                withAnimation { idx = i; counts[sArr[i], default: 0] += 1 }
            }
        }
        let base = 0.3 + Double(sArr.count) * 0.4 + 0.3
        for i in pArr.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + base + Double(i) * 0.4) {
                guard t == token else { return }
                withAnimation { phase = 1; idx = i; counts[pArr[i], default: 0] -= 1 }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + base + Double(pArr.count) * 0.4 + 0.2) {
            guard t == token else { return }
            withAnimation { phase = 2 }
        }
    }
}

// MARK: - Edit Distance (DP grid)

struct EditDistanceAnim: View {
    let a = "kitten"
    let b = "sitting"
    @State private var dp: [[Int]] = []
    @State private var cur: (Int, Int)? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Edit Distance", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\"\(a)\" → \"\(b)\"")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                grid
                Text("dp[i][j] = 編集距離。挿入 / 削除 / 置換 の最小 +1")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    @ViewBuilder private var grid: some View {
        // ヘッダ行
        HStack(spacing: 2) {
            tile(width: 20, height: 20, bg: .indigo.opacity(0.15)) { Text(" ") }
            tile(width: 20, height: 20, bg: .indigo.opacity(0.25)) { Text("ε") }
            ForEach(Array(b.enumerated()), id: \.offset) { _, c in
                tile(width: 20, height: 20, bg: .indigo.opacity(0.25)) { Text(String(c)) }
            }
        }
        ForEach(dp.indices, id: \.self) { i in
            HStack(spacing: 2) {
                let lbl = i == 0 ? "ε" : String(Array(a)[i - 1])
                tile(width: 20, height: 20, bg: .indigo.opacity(0.25)) { Text(lbl) }
                ForEach(dp[i].indices, id: \.self) { j in
                    let isCur = cur.map { $0 == (i, j) } ?? false
                    tile(width: 20, height: 20,
                         bg: isCur ? .yellow : .indigo.opacity(0.45),
                         fg: isCur ? .black : .white) {
                        Text("\(dp[i][j])")
                    }
                }
            }
        }
    }
    private func play() {
        token += 1; let t = token
        let n = a.count, m = b.count
        dp = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        cur = nil
        let aArr = Array(a), bArr = Array(b)
        var k = 0
        for i in 0...n {
            for j in 0...m {
                let v: Int
                if i == 0 { v = j }
                else if j == 0 { v = i }
                else if aArr[i - 1] == bArr[j - 1] { v = dp[i - 1][j - 1] }
                else { v = 1 + min(dp[i - 1][j - 1], min(dp[i][j - 1], dp[i - 1][j])) }
                let ii = i, jj = j
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(k) * 0.10) {
                    guard t == token else { return }
                    withAnimation { dp[ii][jj] = v; cur = (ii, jj) }
                }
                k += 1
            }
        }
    }
}

// MARK: - Sliding Window Substring (live window)

struct LongestSubstringAnim: View {
    let s = "abcabcbb"
    @State private var l = 0
    @State private var r = 0
    @State private var best: (l: Int, r: Int) = (0, 0)
    @State private var seen: [Character: Int] = [:]
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Longest Substring w/o Repeat", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(Array(s.enumerated()), id: \.offset) { i, c in
                        let inWindow = i >= l && i <= r && r >= l
                        let inBest = i >= best.l && i <= best.r
                        tile(width: 26, height: 30,
                             bg: inWindow ? .yellow : (inBest ? .pink.opacity(0.55) : .white.opacity(0.18)),
                             fg: inWindow ? .black : .white) {
                            Text(String(c)).font(.system(size: 12, weight: .black, design: .monospaced))
                        }
                    }
                }
                Text("window = [\(l), \(r)]  len = \(max(0, r - l + 1))")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                Text("best = \"\(best.r >= best.l ? String(Array(s)[best.l...best.r]) : "")\"  len=\(best.r - best.l + 1)")
                    .font(.caption.weight(.bold)).foregroundStyle(.pink)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        l = 0; r = -1; best = (0, -1); seen = [:]
        let arr = Array(s)
        var ll = 0
        var k = 0
        for ri in arr.indices {
            let c = arr[ri]
            if let prev = seen[c], prev >= ll { ll = prev + 1 }
            seen[c] = ri
            let curL = ll, curR = ri
            let newBest = (curR - curL) > (best.r - best.l) ? (curL, curR) : best
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.6) {
                guard t == token else { return }
                withAnimation { l = curL; r = curR; best = newBest }
            }
            k += 1
        }
    }
}

// MARK: - Min Stack (sync min track)

struct MinStackAnim: View {
    let ops: [(String, Int?)] = [("push", 3), ("push", 5), ("push", 2), ("push", 1),
                                  ("pop", nil), ("getMin", nil), ("pop", nil), ("getMin", nil)]
    @State private var stack: [Int] = []
    @State private var mins: [Int] = []
    @State private var op = ""
    @State private var step = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Min Stack", tint: .green, onReplay: play) {
            HStack(alignment: .bottom, spacing: 20) {
                stackCol("stack", arr: stack, color: .green)
                stackCol("mins", arr: mins, color: .orange)
            }
            VStack(spacing: 2) {
                Text(op).font(.caption.weight(.heavy)).foregroundStyle(.green)
                Text("push 時 min(top, val) も mins に push、pop 時に両方 pop")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func stackCol(_ label: String, arr: [Int], color: Color) -> some View {
        VStack(spacing: 2) {
            ForEach(arr.indices.reversed(), id: \.self) { i in
                tile(width: 38, height: 24,
                     bg: i == arr.count - 1 ? color : color.opacity(0.5)) { Text("\(arr[i])") }
            }
            ForEach(0..<max(0, 4 - arr.count), id: \.self) { _ in
                tile(width: 38, height: 24, bg: color.opacity(0.12), fg: .white.opacity(0.5)) { Text("·") }
            }
            Text(label).font(.caption2.weight(.heavy)).foregroundStyle(color)
        }
    }
    private func play() {
        token += 1; let t = token
        stack = []; mins = []; op = ""; step = -1
        for (k, (a, v)) in ops.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.9) {
                guard t == token else { return }
                withAnimation {
                    step = k
                    if a == "push", let x = v {
                        stack.append(x)
                        mins.append(min(mins.last ?? x, x))
                        op = "push(\(x))"
                    } else if a == "pop" {
                        let p = stack.popLast() ?? 0
                        _ = mins.popLast()
                        op = "pop → \(p)"
                    } else {
                        op = "getMin → \(mins.last ?? 0)"
                    }
                }
            }
        }
    }
}

// MARK: - Permutations (backtracking tree)

struct PermutationsTreeAnim: View {
    let nums = [1, 2, 3]
    @State private var paths: [[Int]] = []
    @State private var current: [Int] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Permutations of \(nums)", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("current:").font(.caption2.weight(.heavy)).foregroundStyle(.indigo)
                    HStack(spacing: 4) {
                        ForEach(current.indices, id: \.self) { i in
                            tile(width: 24, height: 24, bg: .yellow, fg: .black) { Text("\(current[i])") }
                        }
                    }
                }
                Text("確定済み順列:").font(.caption2.weight(.heavy)).foregroundStyle(.secondary)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 6)], spacing: 6) {
                    ForEach(paths.indices, id: \.self) { i in
                        HStack(spacing: 2) {
                            ForEach(paths[i].indices, id: \.self) { j in
                                tile(width: 20, height: 20, bg: .indigo.opacity(0.55)) { Text("\(paths[i][j])") }
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
        paths = []; current = []
        var seq: [[Int]] = []
        func backtrack(used: [Bool], path: [Int]) {
            if path.count == nums.count { seq.append(path); return }
            for i in nums.indices where !used[i] {
                var u = used; u[i] = true
                backtrack(used: u, path: path + [nums[i]])
            }
        }
        backtrack(used: Array(repeating: false, count: nums.count), path: [])
        var k = 0
        for p in seq {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.6) {
                guard t == token else { return }
                withAnimation { current = p; paths.append(p) }
            }
            k += 1
        }
    }
}

// MARK: - Fibonacci Memo (tree with cache)

struct FibMemoAnim: View {
    let n = 6
    @State private var memo: [Int: Int] = [0: 0, 1: 1]
    @State private var current: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "fib(\(n)) with memoization", tint: .cyan, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    ForEach(0...n, id: \.self) { i in
                        let cached = memo[i] != nil
                        tile(width: 32, height: 36,
                             bg: current == i ? .yellow : (cached ? .cyan : .gray.opacity(0.25)),
                             fg: current == i ? .black : .white) {
                            VStack(spacing: 0) {
                                Text("\(i)").font(.system(size: 9))
                                Text(cached ? "\(memo[i]!)" : "?")
                                    .font(.system(size: 11, weight: .black))
                            }
                        }
                    }
                }
                Text("base case: fib(0)=0, fib(1)=1")
                    .font(.caption2).foregroundStyle(.secondary)
                Text("memo[n] が確定済なら再計算しない")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        memo = [0: 0, 1: 1]; current = nil
        // bottom-up でメモ化を可視化
        for i in 2...n {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i - 2) * 0.8) {
                guard t == token else { return }
                let v = (memo[i - 1] ?? 0) + (memo[i - 2] ?? 0)
                withAnimation { current = i; memo[i] = v }
            }
        }
    }
}

// MARK: - Valid Parentheses (stack match)

struct ValidParensAnim: View {
    let s: String = "({[]})"
    @State private var idx = -1
    @State private var stack: [Character] = []
    @State private var matched: Bool = false
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Valid Parentheses", tint: .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(Array(s.enumerated()), id: \.offset) { i, c in
                        tile(width: 26, height: 28,
                             bg: i == idx ? .yellow : (i < idx ? .green.opacity(0.45) : .gray.opacity(0.25)),
                             fg: i == idx ? .black : .white) {
                            Text(String(c)).font(.system(size: 13, weight: .black, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("stack:").font(.caption2.weight(.black)).foregroundStyle(.green)
                    ForEach(stack.indices, id: \.self) { i in
                        tile(width: 22, height: 22, bg: .green.opacity(0.55)) {
                            Text(String(stack[i])).font(.system(size: 11, weight: .black))
                        }
                    }
                }
                if matched && idx == s.count - 1 {
                    Text("✅ すべて対応 → valid")
                        .font(.caption.weight(.bold)).foregroundStyle(.green)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        idx = -1; stack = []; matched = false
        let chars = Array(s)
        let pair: [Character: Character] = [")": "(", "}": "{", "]": "["]
        var st: [Character] = []; var ok = true
        for (i, c) in chars.enumerated() {
            let snap = st
            let curOk = ok
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation { idx = i; stack = snap; matched = curOk && i == chars.count - 1 && st.isEmpty }
            }
            if let m = pair[c] {
                if st.last == m { st.removeLast() } else { ok = false }
            } else {
                st.append(c)
            }
        }
        let finalOk = ok && st.isEmpty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(chars.count) * 0.7) {
            guard t == token else { return }
            withAnimation { idx = chars.count - 1; stack = st; matched = finalOk }
        }
    }
}

// MARK: - Next Greater Element (monotonic stack)

struct NextGreaterAnim: View {
    let nums: [Int] = [2, 1, 3, 2, 5, 4, 6]
    @State private var i = -1
    @State private var stack: [Int] = []  // 値を持つ
    @State private var result: [Int] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Next Greater Element", tint: .purple, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(nums.indices, id: \.self) { k in
                        tile(width: 28, height: 26,
                             bg: k == i ? .yellow : .purple.opacity(0.4),
                             fg: k == i ? .black : .white) { Text("\(nums[k])") }
                    }
                }
                HStack(spacing: 4) {
                    Text("stack:").font(.caption2.weight(.black)).foregroundStyle(.purple)
                    ForEach(stack.indices, id: \.self) { k in
                        tile(width: 22, height: 22, bg: .purple.opacity(0.55)) { Text("\(stack[k])") }
                    }
                }
                HStack(spacing: 4) {
                    Text("ans:").font(.caption2.weight(.black)).foregroundStyle(.green)
                    ForEach(result.indices, id: \.self) { k in
                        tile(width: 28, height: 22,
                             bg: result[k] == -1 ? .gray.opacity(0.5) : .green.opacity(0.55)) {
                            Text(result[k] == -1 ? "−" : "\(result[k])")
                        }
                    }
                }
                Text("単調減少 stack に積む → 自分より小さい要素を pop して next = 自分")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        i = -1; stack = []; result = []
        var st: [Int] = []
        var ans: [Int] = Array(repeating: -1, count: nums.count)
        // 後ろから走査して各位置の次に大きい値を求める
        for k in stride(from: nums.count - 1, through: 0, by: -1) {
            while let top = st.last, top <= nums[k] { st.removeLast() }
            ans[k] = st.last ?? -1
            st.append(nums[k])
        }
        // 表示は左から
        var seen: [Int] = []
        for k in nums.indices {
            seen.append(ans[k])
            let snap = seen
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation { i = k; result = snap; stack = Array(seen.prefix(k + 1)) }
            }
        }
    }
}

// MARK: - Largest Rectangle in Histogram

struct LargestRectAnim: View {
    let h: [Int] = [2, 1, 5, 6, 2, 3]
    @State private var idx = -1
    @State private var best: (left: Int, right: Int, height: Int) = (0, 0, 0)
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Largest Rectangle in Histogram", tint: .red, onReplay: play) {
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(h.indices, id: \.self) { i in
                    let inBest = i >= best.left && i <= best.right
                    ZStack(alignment: .bottom) {
                        if inBest && best.height > 0 {
                            Rectangle().fill(Color.red.opacity(0.45))
                                .frame(width: 30, height: CGFloat(best.height) * 18)
                        }
                        Rectangle()
                            .fill(i == idx ? .yellow : .gray.opacity(0.65))
                            .frame(width: 26, height: CGFloat(h[i]) * 18)
                    }
                }
            }
            Text("最大面積 = \(best.height) × \(max(0, best.right - best.left + 1)) = \(best.height * max(0, best.right - best.left + 1))")
                .font(.caption.weight(.bold)).foregroundStyle(.red)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        idx = -1; best = (0, 0, 0)
        // 全 i,j 走査で最大長方形を計算 (デモ用に明示的に表示)
        var seq: [(Int, Int, Int)] = []   // (left, right, height)
        for i in h.indices {
            var minH = h[i]
            for j in i..<h.count {
                minH = min(minH, h[j])
                seq.append((i, j, minH))
            }
        }
        seq.sort { $0.2 * ($0.1 - $0.0 + 1) < $1.2 * ($1.1 - $1.0 + 1) }
        // ランダムにいくつかピックして "拡大していく" 見た目に
        let highlights = seq.suffix(8)
        for (k, b) in highlights.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.55) {
                guard t == token else { return }
                withAnimation { idx = b.1; best = (b.0, b.1, b.2) }
            }
        }
    }
}

// MARK: - Longest Valid Parens (stack of indices)

struct LongestValidParensAnim: View {
    let s: String = "(()())(("
    @State private var idx = -1
    @State private var stack: [Int] = [-1]
    @State private var bestLen = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Longest Valid Parentheses", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(Array(s.enumerated()), id: \.offset) { i, c in
                        tile(width: 26, height: 28,
                             bg: i == idx ? .yellow : .indigo.opacity(0.4),
                             fg: i == idx ? .black : .white) {
                            Text(String(c)).font(.system(size: 13, weight: .black, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("stack:").font(.caption2.weight(.black)).foregroundStyle(.indigo)
                    ForEach(stack.indices, id: \.self) { k in
                        tile(width: 22, height: 22, bg: .indigo.opacity(0.55)) {
                            Text("\(stack[k])")
                        }
                    }
                }
                Text("best valid length = \(bestLen)")
                    .font(.caption.weight(.bold)).foregroundStyle(.indigo)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        idx = -1; stack = [-1]; bestLen = 0
        var st: [Int] = [-1]; var best = 0
        let arr = Array(s)
        for i in arr.indices {
            if arr[i] == "(" { st.append(i) }
            else {
                st.removeLast()
                if st.isEmpty { st.append(i) }
                else { best = max(best, i - st.last!) }
            }
            let snap = st; let curBest = best
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation { idx = i; stack = snap; bestLen = curBest }
            }
        }
    }
}

// MARK: - House Robber (DP)

struct HouseRobberAnim: View {
    let nums: [Int] = [2, 7, 9, 3, 1]
    @State private var dp: [Int] = []
    @State private var picks: Set<Int> = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "House Robber", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(nums.indices, id: \.self) { i in
                        VStack(spacing: 2) {
                            Text("\(nums[i])")
                                .font(.system(size: 10, weight: .bold)).foregroundStyle(.secondary)
                            Rectangle()
                                .fill(picks.contains(i) ? Color.orange : Color.gray.opacity(0.5))
                                .frame(width: 28, height: CGFloat(nums[i]) * 8)
                            Text("🏠").font(.system(size: 18))
                                .opacity(picks.contains(i) ? 1 : 0.4)
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("dp:").font(.caption2.weight(.black)).foregroundStyle(.orange)
                    ForEach(dp.indices, id: \.self) { i in
                        tile(width: 28, height: 22,
                             bg: i == dp.count - 1 ? .yellow : .orange.opacity(0.45),
                             fg: i == dp.count - 1 ? .black : .white) { Text("\(dp[i])") }
                    }
                }
                Text("dp[i] = max(dp[i-1], dp[i-2] + nums[i])")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        dp = []; picks = []
        let n = nums.count
        var d = Array(repeating: 0, count: n)
        for i in 0..<n {
            if i == 0 { d[i] = nums[0] }
            else if i == 1 { d[i] = max(nums[0], nums[1]) }
            else { d[i] = max(d[i - 1], d[i - 2] + nums[i]) }
        }
        for i in 0..<n {
            let v = d[i]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation { dp.append(v) }
            }
        }
        // 最終的にどこを robbed したか backtrack
        var p: Set<Int> = []
        var i = n - 1
        while i >= 0 {
            if i == 0 { if d[0] > 0 { p.insert(0) }; break }
            if i == 1 { if nums[1] > nums[0] { p.insert(1) } else { p.insert(0) }; break }
            if d[i] == d[i - 1] { i -= 1 } else { p.insert(i); i -= 2 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(n) * 0.7) {
            guard t == token else { return }
            withAnimation { picks = p }
        }
    }
}

// MARK: - LIS (Patience-style DP)

struct LISAnim: View {
    let nums: [Int] = [10, 9, 2, 5, 3, 7, 101, 18]
    @State private var dp: [Int] = []
    @State private var idx = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Longest Increasing Subsequence", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(nums.indices, id: \.self) { i in
                        tile(width: 32, height: 26,
                             bg: i == idx ? .yellow : .pink.opacity(0.4),
                             fg: i == idx ? .black : .white) { Text("\(nums[i])") }
                    }
                }
                HStack(spacing: 4) {
                    Text("dp:").font(.caption2.weight(.black)).foregroundStyle(.pink)
                    ForEach(dp.indices, id: \.self) { i in
                        tile(width: 32, height: 22, bg: .pink.opacity(0.55)) { Text("\(dp[i])") }
                    }
                }
                Text("dp[i] = 1 + max(dp[j]) for j<i where nums[j]<nums[i]")
                    .font(.caption2).foregroundStyle(.secondary)
                if let m = dp.max() {
                    Text("LIS = \(m)")
                        .font(.caption.weight(.bold)).foregroundStyle(.pink)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        dp = []; idx = -1
        let n = nums.count
        var d = Array(repeating: 1, count: n)
        for i in 0..<n {
            for j in 0..<i where nums[j] < nums[i] { d[i] = max(d[i], d[j] + 1) }
            let v = d[i]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation { idx = i; dp.append(v) }
            }
        }
    }
}

// MARK: - LCS (2D DP grid for two strings)

struct LCSAnim: View {
    let a = "abcde"
    let b = "ace"
    @State private var grid: [[Int]] = []
    @State private var cur: (Int, Int)? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Longest Common Subsequence", tint: .teal, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\"\(a)\" ∩ \"\(b)\"")
                    .font(.caption2).foregroundStyle(.secondary)
                HStack(spacing: 2) {
                    tile(width: 22, height: 22, bg: .teal.opacity(0.15)) { Text(" ") }
                    tile(width: 22, height: 22, bg: .teal.opacity(0.3)) { Text("ε") }
                    ForEach(Array(b.enumerated()), id: \.offset) { _, c in
                        tile(width: 22, height: 22, bg: .teal.opacity(0.3)) { Text(String(c)) }
                    }
                }
                ForEach(grid.indices, id: \.self) { i in
                    HStack(spacing: 2) {
                        let lbl = i == 0 ? "ε" : String(Array(a)[i - 1])
                        tile(width: 22, height: 22, bg: .teal.opacity(0.3)) { Text(lbl) }
                        ForEach(grid[i].indices, id: \.self) { j in
                            let isCur = cur.map { $0 == (i, j) } ?? false
                            tile(width: 22, height: 22,
                                 bg: isCur ? .yellow : .teal.opacity(0.5),
                                 fg: isCur ? .black : .white) { Text("\(grid[i][j])") }
                        }
                    }
                }
                if let last = grid.last?.last {
                    Text("LCS 長 = \(last)").font(.caption.weight(.bold)).foregroundStyle(.teal)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        let n = a.count, m = b.count
        grid = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        cur = nil
        let aArr = Array(a), bArr = Array(b)
        var k = 0
        for i in 0...n {
            for j in 0...m {
                let v: Int
                if i == 0 || j == 0 { v = 0 }
                else if aArr[i - 1] == bArr[j - 1] { v = grid[i - 1][j - 1] + 1 }
                else { v = max(grid[i - 1][j], grid[i][j - 1]) }
                let ii = i, jj = j
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(k) * 0.15) {
                    guard t == token else { return }
                    withAnimation { grid[ii][jj] = v; cur = (ii, jj) }
                }
                k += 1
            }
        }
    }
}

// MARK: - 0/1 Knapsack

struct KnapsackAnim: View {
    let weights = [1, 2, 3, 5]
    let values  = [10, 15, 40, 50]
    let cap = 6
    @State private var grid: [[Int]] = []
    @State private var cur: (Int, Int)? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "0/1 Knapsack (cap=\(cap))", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                Text("items: " + weights.indices.map { "(w=\(weights[$0]),v=\(values[$0]))" }.joined(separator: " "))
                    .font(.system(size: 9, design: .monospaced)).foregroundStyle(.secondary)
                HStack(spacing: 2) {
                    tile(width: 22, height: 22, bg: .orange.opacity(0.2)) { Text("") }
                    ForEach(0...cap, id: \.self) { c in
                        tile(width: 22, height: 22, bg: .orange.opacity(0.3)) { Text("\(c)") }
                    }
                }
                ForEach(grid.indices, id: \.self) { i in
                    HStack(spacing: 2) {
                        tile(width: 22, height: 22, bg: .orange.opacity(0.3)) {
                            Text(i == 0 ? "∅" : "#\(i)")
                        }
                        ForEach(grid[i].indices, id: \.self) { c in
                            let isCur = cur.map { $0 == (i, c) } ?? false
                            tile(width: 22, height: 22,
                                 bg: isCur ? .yellow : .orange.opacity(0.55),
                                 fg: isCur ? .black : .white) { Text("\(grid[i][c])") }
                        }
                    }
                }
            }
            Text("dp[i][c] = max(取らない: dp[i-1][c], 取る: dp[i-1][c-w]+v)")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        let n = weights.count
        grid = Array(repeating: Array(repeating: 0, count: cap + 1), count: n + 1)
        cur = nil
        var k = 0
        for i in 0...n {
            for c in 0...cap {
                let v: Int
                if i == 0 { v = 0 }
                else if c < weights[i - 1] { v = grid[i - 1][c] }
                else { v = max(grid[i - 1][c], grid[i - 1][c - weights[i - 1]] + values[i - 1]) }
                let ii = i, cc = c
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(k) * 0.18) {
                    guard t == token else { return }
                    withAnimation { grid[ii][cc] = v; cur = (ii, cc) }
                }
                k += 1
            }
        }
    }
}

// MARK: - Unique Paths (path count grid)

struct UniquePathsAnim: View {
    let rows = 4, cols = 5
    @State private var grid: [[Int]] = []
    @State private var cur: (Int, Int)? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Unique Paths (\(rows)×\(cols))", tint: .blue, onReplay: play) {
            VStack(spacing: 3) {
                ForEach(grid.indices, id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(grid[r].indices, id: \.self) { c in
                            let isCur = cur.map { $0 == (r, c) } ?? false
                            tile(width: 30, height: 26,
                                 bg: isCur ? .yellow : .blue.opacity(0.5),
                                 fg: isCur ? .black : .white) { Text("\(grid[r][c])") }
                        }
                    }
                }
            }
            Text("dp[r][c] = dp[r-1][c] + dp[r][c-1]")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        grid = Array(repeating: Array(repeating: 0, count: cols), count: rows)
        cur = nil
        var k = 0
        for r in 0..<rows {
            for c in 0..<cols {
                let v: Int
                if r == 0 || c == 0 { v = 1 }
                else { v = grid[r - 1][c] + grid[r][c - 1] }
                let rr = r, cc = c
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(k) * 0.15) {
                    guard t == token else { return }
                    withAnimation { grid[rr][cc] = v; cur = (rr, cc) }
                }
                k += 1
            }
        }
    }
}

// MARK: - Group Anagrams

struct GroupAnagramsAnim: View {
    let words = ["eat", "tea", "tan", "ate", "nat", "bat"]
    @State private var groups: [String: [String]] = [:]
    @State private var idx = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Group Anagrams", tint: .purple, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(words.indices, id: \.self) { i in
                        tile(width: 38, height: 26,
                             bg: i == idx ? .yellow : .purple.opacity(0.4),
                             fg: i == idx ? .black : .white) {
                            Text(words[i]).font(.system(size: 11, weight: .black, design: .monospaced))
                        }
                    }
                }
                Text("ソート文字列をキーにグルーピング")
                    .font(.caption2).foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(groups.sorted(by: { $0.key < $1.key }), id: \.key) { kv in
                        HStack(spacing: 4) {
                            Text("\"\(kv.key)\":")
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .foregroundStyle(.purple)
                            ForEach(kv.value.indices, id: \.self) { i in
                                tile(width: 38, height: 22, bg: .purple.opacity(0.55)) {
                                    Text(kv.value[i]).font(.system(size: 10, weight: .heavy, design: .monospaced))
                                }
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
        groups = [:]; idx = -1
        for i in words.indices {
            let key = String(words[i].sorted())
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation {
                    idx = i
                    groups[key, default: []].append(words[i])
                }
            }
        }
    }
}

// MARK: - Subsets (power set bit pattern)

struct SubsetsAnim: View {
    let nums = [1, 2, 3]
    @State private var current: [Int] = []
    @State private var collected: [[Int]] = []
    @State private var mask = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Subsets of \(nums)", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("mask:").font(.caption2.weight(.black)).foregroundStyle(.indigo)
                    ForEach(nums.indices.reversed(), id: \.self) { bit in
                        let on = (mask >> bit) & 1 == 1
                        tile(width: 22, height: 22,
                             bg: on ? .indigo : .indigo.opacity(0.2),
                             fg: on ? .white : .white.opacity(0.5)) {
                            Text(on ? "1" : "0").font(.system(size: 11, weight: .black, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("current:").font(.caption2.weight(.black)).foregroundStyle(.indigo)
                    if current.isEmpty {
                        Text("{}").font(.caption.weight(.black)).foregroundStyle(.secondary)
                    } else {
                        ForEach(current.indices, id: \.self) { i in
                            tile(width: 22, height: 22, bg: .yellow, fg: .black) { Text("\(current[i])") }
                        }
                    }
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 4)], spacing: 4) {
                    ForEach(collected.indices, id: \.self) { i in
                        HStack(spacing: 2) {
                            ForEach(collected[i].indices, id: \.self) { j in
                                tile(width: 18, height: 18, bg: .indigo.opacity(0.55)) {
                                    Text("\(collected[i][j])")
                                }
                            }
                            if collected[i].isEmpty {
                                Text("∅").font(.caption.weight(.black)).foregroundStyle(.indigo)
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
        current = []; collected = []; mask = 0
        for m in 0..<(1 << nums.count) {
            var sub: [Int] = []
            for b in nums.indices where (m >> b) & 1 == 1 { sub.append(nums[b]) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(m) * 0.7) {
                guard t == token else { return }
                withAnimation { mask = m; current = sub; collected.append(sub) }
            }
        }
    }
}

// MARK: - N-Queens (board placement)

struct NQueensAnim: View {
    let n = 4
    @State private var board: [Int] = []   // 行 → 列
    @State private var current = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "\(n)-Queens", tint: .red, onReplay: play) {
            VStack(spacing: 3) {
                ForEach(0..<n, id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(0..<n, id: \.self) { c in
                            let placed = r < board.count && board[r] == c
                            let attacked = isAttacked(r: r, c: c)
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill((r + c) % 2 == 0 ? Color.white.opacity(0.8) : Color.gray.opacity(0.55))
                                    .frame(width: 32, height: 32)
                                if placed { Text("♛").font(.title3).foregroundStyle(.red) }
                                else if r == current && attacked {
                                    Text("✕").font(.caption.weight(.bold)).foregroundStyle(.red)
                                }
                            }
                        }
                    }
                }
            }
            Text("各行に 1 つずつ Queen を置く (列・斜めが衝突しないように)")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func isAttacked(r: Int, c: Int) -> Bool {
        for prev in 0..<min(r, board.count) {
            if board[prev] == c { return true }
            if abs(board[prev] - c) == abs(prev - r) { return true }
        }
        return false
    }
    private func play() {
        token += 1; let t = token
        board = []; current = -1
        // 4-queens 解: [1,3,0,2]
        let sol = [1, 3, 0, 2]
        for (i, c) in sol.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.8) {
                guard t == token else { return }
                withAnimation { current = i; board.append(c) }
            }
        }
    }
}

// MARK: - Word Search (grid DFS)

struct WordSearchAnim: View {
    let grid: [[Character]] = [
        ["A","B","C","E"],
        ["S","F","C","S"],
        ["A","D","E","E"]
    ]
    let word = "ABCCED"
    @State private var path: [(Int, Int)] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Word Search: \"\(word)\"", tint: .green, onReplay: play) {
            VStack(spacing: 3) {
                ForEach(grid.indices, id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(grid[r].indices, id: \.self) { c in
                            let order = path.firstIndex(where: { $0 == (r, c) })
                            tile(width: 32, height: 32,
                                 bg: order != nil ? .green.opacity(0.7) : .white.opacity(0.18),
                                 fg: order != nil ? .white : .white) {
                                VStack(spacing: 0) {
                                    Text(String(grid[r][c]))
                                        .font(.system(size: 13, weight: .black, design: .monospaced))
                                    if let o = order {
                                        Text("\(o + 1)").font(.system(size: 7))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Text("隣接マスを DFS、word の文字に一致しなければバックトラック")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        path = []
        // "ABCCED" を辿る正解パス
        let solution: [(Int, Int)] = [(0,0),(0,1),(0,2),(1,2),(2,2),(2,1)]
        for (i, p) in solution.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.6) {
                guard t == token else { return }
                withAnimation { path.append(p) }
            }
        }
    }
}

// MARK: - Kth Largest (min-heap of size k)

struct KthLargestAnim: View {
    let nums = [3, 2, 1, 5, 6, 4]
    let k = 2
    @State private var heap: [Int] = []
    @State private var idx = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Kth Largest (k=\(k))", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(nums.indices, id: \.self) { i in
                        tile(width: 28, height: 26,
                             bg: i == idx ? .yellow : .pink.opacity(0.4),
                             fg: i == idx ? .black : .white) { Text("\(nums[i])") }
                    }
                }
                HStack(spacing: 4) {
                    Text("min-heap (top=k番目に大きい):")
                        .font(.caption2.weight(.black)).foregroundStyle(.pink)
                }
                HStack(spacing: 4) {
                    ForEach(heap.indices, id: \.self) { i in
                        tile(width: 28, height: 26,
                             bg: i == 0 ? .pink : .pink.opacity(0.55)) { Text("\(heap[i])") }
                    }
                }
                if heap.count == k, let top = heap.first {
                    Text("→ Kth largest = \(top)")
                        .font(.caption.weight(.bold)).foregroundStyle(.pink)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        heap = []; idx = -1
        var h: [Int] = []
        for (i, v) in nums.enumerated() {
            h.append(v); h.sort()
            if h.count > k { h.removeFirst() }
            let snap = h
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.8) {
                guard t == token else { return }
                withAnimation { idx = i; heap = snap }
            }
        }
    }
}

// MARK: - Tree helper (visualize a 7-node BT and walk)

private struct TreeNodeView: View {
    let value: String
    let bg: Color
    let fg: Color
    var body: some View {
        ZStack {
            Circle().fill(bg).frame(width: 28, height: 28)
            Text(value).font(.system(size: 11, weight: .black)).foregroundStyle(fg)
        }
    }
}

private struct LeveledTree: View {
    let nodes: [Int]   // 7 nodes, level order
    let highlightVisited: [Int]
    let current: Int?
    let palette: (visited: Color, current: Color, base: Color)
    var body: some View {
        VStack(spacing: 8) {
            // root
            row(indices: [0])
            row(indices: [1, 2])
            row(indices: [3, 4, 5, 6])
        }
    }
    private func row(indices: [Int]) -> some View {
        HStack(spacing: 18) {
            ForEach(indices, id: \.self) { i in
                let v = i < nodes.count ? nodes[i] : 0
                let visited = highlightVisited.contains(v)
                let isCur = current == v
                TreeNodeView(value: "\(v)",
                             bg: isCur ? palette.current : (visited ? palette.visited : palette.base),
                             fg: .white)
            }
        }
    }
}

// MARK: - Validate BST (inorder ascending check)

struct ValidateBSTAnim: View {
    let nodes = [5, 3, 7, 1, 4, 6, 8]  // BST
    @State private var visited: [Int] = []
    @State private var cur: Int? = nil
    @State private var ok = true
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Validate BST (inorder = 昇順 ?)", tint: .green, onReplay: play) {
            LeveledTree(nodes: nodes, highlightVisited: visited, current: cur,
                        palette: (.green, .yellow, .green.opacity(0.4)))
            HStack(spacing: 4) {
                Text("seen:").font(.caption2.weight(.black)).foregroundStyle(.green)
                ForEach(visited.indices, id: \.self) { i in
                    tile(width: 22, height: 22, bg: .green.opacity(0.55)) { Text("\(visited[i])") }
                }
            }
            Text(ok ? "🟢 BST: 昇順を維持" : "🔴 違反！")
                .font(.caption.weight(.bold))
                .foregroundStyle(ok ? .green : .red)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        visited = []; cur = nil; ok = true
        // インオーダー (左→根→右) を完全二分木として
        let seq = [nodes[3], nodes[1], nodes[4], nodes[0], nodes[5], nodes[2], nodes[6]]
        var seen: [Int] = []
        for (i, v) in seq.enumerated() {
            let prevSeen = seen
            seen.append(v)
            let stillOk = prevSeen.last.map { $0 < v } ?? true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.6) {
                guard t == token else { return }
                withAnimation { cur = v; visited = prevSeen + [v]; ok = ok && stillOk }
            }
        }
    }
}

// MARK: - Invert Binary Tree

struct InvertTreeAnim: View {
    @State private var nodes = [4, 2, 7, 1, 3, 6, 9]
    @State private var swapAt: Int? = nil  // swap している親 index
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Invert Binary Tree", tint: .indigo, onReplay: play) {
            LeveledTree(nodes: nodes, highlightVisited: [], current: swapAt.flatMap { nodes.indices.contains($0) ? nodes[$0] : nil },
                        palette: (.indigo, .yellow, .indigo.opacity(0.4)))
            Text("各ノードの左右の子を swap")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        nodes = [4, 2, 7, 1, 3, 6, 9]
        // 親 index 0 (left=1, right=2), 1 (left=3, right=4), 2 (left=5, right=6) を swap
        let swaps: [(Int, Int, Int)] = [(0, 1, 2), (1, 3, 4), (2, 5, 6)]
        for (k, s) in swaps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 1.0) {
                guard t == token else { return }
                withAnimation { swapAt = s.0; nodes.swapAt(s.1, s.2) }
            }
        }
    }
}

// MARK: - Symmetric Tree (mirror check)

struct SymmetricTreeAnim: View {
    let nodes = [1, 2, 2, 3, 4, 4, 3]
    @State private var compareLR: (Int, Int)? = nil
    @State private var allOk = true
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Symmetric Tree", tint: .purple, onReplay: play) {
            LeveledTree(nodes: nodes, highlightVisited: [], current: nil,
                        palette: (.purple, .yellow, .purple.opacity(0.4)))
            HStack(spacing: 14) {
                if let pair = compareLR {
                    Text("\(nodes[pair.0])")
                        .font(.system(size: 14, weight: .black))
                        .padding(8)
                        .background(Color.yellow, in: Circle()).foregroundStyle(.black)
                    Image(systemName: "arrow.left.and.right").foregroundStyle(.purple)
                    Text("\(nodes[pair.1])")
                        .font(.system(size: 14, weight: .black))
                        .padding(8)
                        .background(Color.yellow, in: Circle()).foregroundStyle(.black)
                }
            }
            Text(allOk ? "🟢 全 mirror 対応" : "🔴 mirror 違反")
                .font(.caption.weight(.bold))
                .foregroundStyle(allOk ? .green : .red)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        compareLR = nil; allOk = true
        // (left, right) のミラーペア
        let pairs: [(Int, Int)] = [(1, 2), (3, 6), (4, 5)]
        for (k, p) in pairs.enumerated() {
            let ok = nodes[p.0] == nodes[p.1]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.9) {
                guard t == token else { return }
                withAnimation { compareLR = p; allOk = allOk && ok }
            }
        }
    }
}

// MARK: - Path Sum (root → leaf with running sum)

struct PathSumAnim: View {
    let nodes = [5, 4, 8, 11, 2, 13, 1]
    let target = 22
    @State private var path: [Int] = []
    @State private var sum = 0
    @State private var done = false
    @State private var found = false
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Path Sum = \(target)", tint: .orange, onReplay: play) {
            LeveledTree(nodes: nodes, highlightVisited: path, current: path.last,
                        palette: (.orange, .yellow, .orange.opacity(0.3)))
            HStack {
                Text("path: " + path.map(String.init).joined(separator: " → "))
                    .font(.system(.caption2, design: .monospaced))
                Spacer()
                Text("sum=\(sum)")
                    .font(.caption.weight(.bold)).foregroundStyle(.orange)
            }
            if done {
                Text(found ? "🎯 target 一致" : "ハズレ (このパスは違う)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(found ? .green : .secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        path = []; sum = 0; done = false; found = false
        // root(5) -> 4 -> 11 -> 2 = 22 ヒット
        let seqIdx = [0, 1, 3, 4]
        for (k, i) in seqIdx.enumerated() {
            let v = nodes[i]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.8) {
                guard t == token else { return }
                withAnimation { path.append(v); sum += v }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(seqIdx.count) * 0.8 + 0.3) {
            guard t == token else { return }
            withAnimation { done = true; found = sum == target }
        }
    }
}

// MARK: - Max Depth (postorder, returning depth)

struct MaxDepthBTAnim: View {
    let nodes = [3, 9, 20, 1, 2, 15, 7]
    @State private var depths: [Int: Int] = [:]   // node value → depth
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Max Depth of Binary Tree", tint: .green, onReplay: play) {
            LeveledTree(nodes: nodes, highlightVisited: Array(depths.keys), current: nil,
                        palette: (.green, .yellow, .green.opacity(0.4)))
            HStack(spacing: 4) {
                Text("depth:").font(.caption2.weight(.black)).foregroundStyle(.green)
                ForEach(depths.sorted(by: { $0.key < $1.key }), id: \.key) { kv in
                    tile(width: 32, height: 24, bg: .green.opacity(0.5)) {
                        VStack(spacing: 0) {
                            Text("\(kv.key)").font(.system(size: 9))
                            Text("→\(kv.value)").font(.system(size: 9, weight: .heavy))
                        }
                    }
                }
            }
            if let m = depths.values.max() {
                Text("max depth = \(m)").font(.caption.weight(.bold)).foregroundStyle(.green)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        depths = [:]
        // 葉から順に depth を確定
        let order: [(Int, Int)] = [(nodes[3], 1), (nodes[4], 1), (nodes[1], 2),
                                    (nodes[5], 1), (nodes[6], 1), (nodes[2], 2),
                                    (nodes[0], 3)]
        for (k, (v, d)) in order.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.6) {
                guard t == token else { return }
                withAnimation { depths[v] = d }
            }
        }
    }
}

// MARK: - LCA of BST (using BST property)

struct LCAofBSTAnim: View {
    let nodes = [6, 2, 8, 0, 4, 7, 9]
    let p = 2, q = 4
    @State private var path: [Int] = []
    @State private var lca: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "LCA of BST (p=\(p), q=\(q))", tint: .teal, onReplay: play) {
            LeveledTree(nodes: nodes, highlightVisited: path,
                        current: lca, palette: (.teal, .yellow, .teal.opacity(0.4)))
            HStack {
                Text("walking:")
                    .font(.caption2.weight(.black)).foregroundStyle(.teal)
                Text(path.map(String.init).joined(separator: " → "))
                    .font(.system(.caption2, design: .monospaced))
            }
            if let l = lca {
                Text("🎯 LCA = \(l)").font(.caption.weight(.bold)).foregroundStyle(.teal)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        path = []; lca = nil
        // 6 → 2 (両方左) で確定 (p=2, q=4)
        let walk = [6, 2]
        for (k, v) in walk.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.8) {
                guard t == token else { return }
                withAnimation { path.append(v) }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(walk.count) * 0.8 + 0.2) {
            guard t == token else { return }
            withAnimation { lca = 2 }
        }
    }
}

// MARK: - Diameter of Binary Tree

struct DiameterBTAnim: View {
    let nodes = [1, 2, 3, 4, 5, 6, 7]
    @State private var leftD: Int? = nil
    @State private var rightD: Int? = nil
    @State private var rootHL: Int? = nil
    @State private var dia = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Diameter of Binary Tree", tint: .red, onReplay: play) {
            LeveledTree(nodes: nodes,
                        highlightVisited: [leftD, rightD].compactMap { $0 != nil ? nodes[$0!] : nil },
                        current: rootHL,
                        palette: (.red.opacity(0.55), .yellow, .red.opacity(0.3)))
            HStack(spacing: 8) {
                if let l = leftD {
                    Text("left depth=\(l)").font(.caption2.weight(.heavy)).foregroundStyle(.red)
                }
                if let r = rightD {
                    Text("right depth=\(r)").font(.caption2.weight(.heavy)).foregroundStyle(.red)
                }
            }
            Text("diameter = max(左深さ + 右深さ) = \(dia)")
                .font(.caption.weight(.bold)).foregroundStyle(.red)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        leftD = nil; rightD = nil; rootHL = nil; dia = 0
        // root の左サブツリー深さ=2, 右=2, 通る経路長=4
        let steps = [
            (0.5, { self.rootHL = 1 }),
            (1.2, { self.leftD = 1 }),
            (1.8, { self.rightD = 2 }),
            (2.4, { self.rootHL = nodes[0]; self.dia = 4 })
        ]
        for (delay, action) in steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard t == token else { return }
                withAnimation { action() }
            }
        }
    }
}

// MARK: - Bubble Sort Pass (per-pass swap visualization)

struct BubbleSortPassAnim: View {
    @State private var arr = [5, 2, 4, 1, 3]
    @State private var i = 0   // j 位置
    @State private var swapping = false
    @State private var done = false
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Bubble Sort 1 パス", tint: .blue, onReplay: play) {
            HStack(spacing: 5) {
                ForEach(arr.indices, id: \.self) { idx in
                    let isCmp = idx == i || idx == i + 1
                    tile(width: 32, height: 32,
                         bg: swapping && isCmp ? .red : (isCmp ? .yellow : .blue.opacity(0.4)),
                         fg: isCmp ? .black : .white) { Text("\(arr[idx])") }
                }
            }
            Text("隣り合う 2 要素を比較し、左 > 右 なら swap")
                .font(.caption2).foregroundStyle(.secondary)
            if done {
                Text("✅ 1 パス完了 (最大値が末尾)")
                    .font(.caption.weight(.bold)).foregroundStyle(.blue)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        arr = [5, 2, 4, 1, 3]; i = 0; swapping = false; done = false
        var a = arr
        var k = 0
        for j in 0..<(a.count - 1) {
            let needSwap = a[j] > a[j + 1]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.9) {
                guard t == token else { return }
                withAnimation { i = j; swapping = needSwap }
            }
            if needSwap {
                a.swapAt(j, j + 1)
                let snap = a
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.9 + 0.5) {
                    guard t == token else { return }
                    withAnimation { arr = snap }
                }
            }
            k += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.9 + 0.3) {
            guard t == token else { return }
            withAnimation { swapping = false; done = true }
        }
    }
}

// MARK: - Selection Sort (find-min and swap)

struct SelectionSortAnim: View {
    @State private var arr = [5, 2, 4, 1, 3]
    @State private var startIdx = 0
    @State private var scanIdx = 0
    @State private var minIdx = 0
    @State private var done = false
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Selection Sort 1 パス", tint: .purple, onReplay: play) {
            HStack(spacing: 5) {
                ForEach(arr.indices, id: \.self) { i in
                    tile(width: 32, height: 32,
                         bg: i == minIdx ? .green :
                              (i == scanIdx ? .yellow :
                                (i < startIdx ? .purple.opacity(0.4) : .purple.opacity(0.20))),
                         fg: i == scanIdx || i == minIdx ? .black : .white) { Text("\(arr[i])") }
                }
            }
            Text("未ソート部から最小値を探し、先頭と swap")
                .font(.caption2).foregroundStyle(.secondary)
            if done {
                Text("✅ 1 パス完了 (先頭が最小)")
                    .font(.caption.weight(.bold)).foregroundStyle(.purple)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        arr = [5, 2, 4, 1, 3]; startIdx = 0; scanIdx = 0; minIdx = 0; done = false
        let a = arr
        var k = 0
        var mIdx = 0
        for j in 1..<a.count {
            if a[j] < a[mIdx] { mIdx = j }
            let curMin = mIdx
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.8) {
                guard t == token else { return }
                withAnimation { scanIdx = j; minIdx = curMin }
            }
            k += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.8 + 0.3) {
            guard t == token else { return }
            var b = a; b.swapAt(0, mIdx)
            withAnimation { arr = b; done = true }
        }
    }
}

// MARK: - Insertion Sort

struct InsertionSortAnim: View {
    @State private var arr = [5, 2, 4, 1, 3]
    @State private var sortedEnd = 0   // 0..sortedEnd is sorted
    @State private var cur = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Insertion Sort 1 パス", tint: .green, onReplay: play) {
            HStack(spacing: 5) {
                ForEach(arr.indices, id: \.self) { i in
                    tile(width: 32, height: 32,
                         bg: i == cur ? .yellow :
                              (i <= sortedEnd ? .green : .gray.opacity(0.5)),
                         fg: i == cur ? .black : .white) { Text("\(arr[i])") }
                }
            }
            Text("緑 = ソート済、黄 = 挿入中。後ろへ shift して正しい位置へ")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        arr = [5, 2, 4, 1, 3]; sortedEnd = 0; cur = 0
        var a = arr
        var k = 0
        for i in 1..<a.count {
            let key = a[i]
            var j = i - 1
            while j >= 0 && a[j] > key { a[j + 1] = a[j]; j -= 1 }
            a[j + 1] = key
            let snap = a; let pos = j + 1; let end = i
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.9) {
                guard t == token else { return }
                withAnimation { arr = snap; cur = pos; sortedEnd = end }
            }
            k += 1
        }
    }
}

// MARK: - Dutch National Flag (3-way partition)

struct DutchFlagAnim: View {
    @State private var arr: [Int] = [2, 0, 2, 1, 1, 0, 1, 0, 2]
    @State private var lo = 0
    @State private var mid = 0
    @State private var hi = 8
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Dutch National Flag", tint: .orange, onReplay: play) {
            HStack(spacing: 3) {
                ForEach(arr.indices, id: \.self) { i in
                    let bg: Color = arr[i] == 0 ? .red : (arr[i] == 1 ? .white : .blue)
                    let fg: Color = arr[i] == 1 ? .black : .white
                    tile(width: 24, height: 28, bg: bg, fg: fg) { Text("\(arr[i])") }
                }
            }
            HStack(spacing: 12) {
                Text("lo=\(lo)")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.red)
                Text("mid=\(mid)")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.orange)
                Text("hi=\(hi)")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.blue)
            }
            Text("0 を左へ、2 を右へ、1 はそのまま")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        var a = [2, 0, 2, 1, 1, 0, 1, 0, 2]
        arr = a; lo = 0; mid = 0; hi = a.count - 1
        var l = 0, m = 0, h = a.count - 1
        var k = 0
        while m <= h {
            if a[m] == 0 { a.swapAt(l, m); l += 1; m += 1 }
            else if a[m] == 2 { a.swapAt(m, h); h -= 1 }
            else { m += 1 }
            let snap = a; let pl = l, pm = m, ph = h
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.6) {
                guard t == token else { return }
                withAnimation { arr = snap; lo = pl; mid = pm; hi = ph }
            }
            k += 1
        }
    }
}

// MARK: - Single Number (XOR cascade)

struct SingleNumberAnim: View {
    let nums = [4, 1, 2, 1, 2]
    @State private var i = -1
    @State private var xor = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Single Number (XOR)", tint: .indigo, onReplay: play) {
            HStack(spacing: 5) {
                ForEach(nums.indices, id: \.self) { idx in
                    tile(width: 32, height: 32,
                         bg: idx == i ? .yellow : .indigo.opacity(0.4),
                         fg: idx == i ? .black : .white) { Text("\(nums[idx])") }
                }
            }
            VStack(spacing: 3) {
                HStack(spacing: 6) {
                    Text("xor →").font(.system(.caption, design: .monospaced))
                    Text("\(xor)")
                        .font(.system(.title3, design: .monospaced).weight(.black))
                        .foregroundStyle(.indigo)
                }
                Text("a ^ a = 0, 0 ^ b = b なので重複は消えて単独だけ残る")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        i = -1; xor = 0
        var x = 0
        for (k, v) in nums.enumerated() {
            x ^= v
            let curX = x
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation { i = k; xor = curX }
            }
        }
    }
}

// MARK: - Reverse Bits

struct ReverseBitsAnim: View {
    let n: UInt32 = 0b0000_0010_1001_0100_0001_1110_1001_1100
    @State private var step = -1
    @State private var rev: UInt32 = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Reverse Bits (32bit)", tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                bitRow("in", value: n, highlight: step, fromLeft: true)
                bitRow("out", value: rev, highlight: 31 - step, fromLeft: false)
                Text("各 i について out の (31-i) 番ビットに in の i 番をコピー")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func bitRow(_ label: String, value: UInt32, highlight: Int, fromLeft: Bool) -> some View {
        HStack(spacing: 1) {
            Text(label).font(.system(size: 9, weight: .black, design: .monospaced))
                .frame(width: 26, alignment: .leading).foregroundStyle(.blue)
            ForEach(0..<32, id: \.self) { i in
                let bitIdx = fromLeft ? (31 - i) : (31 - i)
                let on = ((value >> bitIdx) & 1) == 1
                let isHi = i == (fromLeft ? (31 - highlight) : highlight)
                Rectangle()
                    .fill(isHi ? .yellow : (on ? .blue : .gray.opacity(0.35)))
                    .frame(width: 7, height: 16)
            }
        }
    }
    private func play() {
        token += 1; let t = token
        step = -1; rev = 0
        var r: UInt32 = 0
        for i in 0..<32 {
            let bit = (n >> i) & 1
            r |= bit << (31 - i)
            let curR = r
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.12) {
                guard t == token else { return }
                withAnimation { step = i; rev = curR }
            }
        }
    }
}

// MARK: - Number of Islands (flood fill counter)

struct NumIslandsAnim: View {
    let grid: [[Int]] = [
        [1, 1, 0, 0, 1],
        [1, 1, 0, 1, 1],
        [0, 0, 1, 0, 0],
        [1, 1, 0, 1, 1]
    ]
    @State private var filled: [[Int]] = []   // 0 if water, n=island id, or -1 unvisited land
    @State private var count = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Number of Islands", tint: .teal, onReplay: play) {
            VStack(spacing: 3) {
                ForEach(filled.indices, id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(filled[r].indices, id: \.self) { c in
                            let v = filled[r][c]
                            let bg: Color = v == 0 ? .gray.opacity(0.3) : islandColor(v)
                            tile(width: 26, height: 26, bg: bg) {
                                Text(v == 0 ? "~" : "#")
                                    .font(.system(size: 11, weight: .black))
                            }
                        }
                    }
                }
            }
            Text("島の数 = \(count)").font(.caption.weight(.bold)).foregroundStyle(.teal)
        }
        .onAppear { play() }
    }
    private func islandColor(_ id: Int) -> Color {
        let palette: [Color] = [.teal, .orange, .pink, .green, .indigo, .red]
        return palette[(abs(id) - 1) % palette.count]
    }
    private func play() {
        token += 1; let t = token
        // 初期: 1 → -1 (未訪問), 0 → 0
        filled = grid.map { row in row.map { $0 == 0 ? 0 : -1 } }
        count = 0
        let rs = grid.count, cs = grid[0].count
        var visited = Array(repeating: Array(repeating: false, count: cs), count: rs)
        var id = 0
        var orderedFills: [(Int, Int, Int)] = []
        for r in 0..<rs {
            for c in 0..<cs where grid[r][c] == 1 && !visited[r][c] {
                id += 1
                var stack = [(r, c)]
                while let p = stack.popLast() {
                    if p.0 < 0 || p.0 >= rs || p.1 < 0 || p.1 >= cs { continue }
                    if visited[p.0][p.1] || grid[p.0][p.1] == 0 { continue }
                    visited[p.0][p.1] = true
                    orderedFills.append((p.0, p.1, id))
                    stack.append((p.0 + 1, p.1))
                    stack.append((p.0 - 1, p.1))
                    stack.append((p.0, p.1 + 1))
                    stack.append((p.0, p.1 - 1))
                }
            }
        }
        for (k, f) in orderedFills.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.18) {
                guard t == token else { return }
                withAnimation {
                    filled[f.0][f.1] = f.2
                    count = max(count, f.2)
                }
            }
        }
    }
}

// MARK: - Maximum Subarray (Kadane)

struct MaxSubarrayKadaneAnim: View {
    let nums = [-2, 1, -3, 4, -1, 2, 1, -5, 4]
    @State private var i = -1
    @State private var cur = 0
    @State private var best = 0
    @State private var bestRange: (Int, Int) = (0, 0)
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Maximum Subarray (Kadane)", tint: .blue, onReplay: play) {
            HStack(spacing: 4) {
                ForEach(nums.indices, id: \.self) { k in
                    let inBest = k >= bestRange.0 && k <= bestRange.1
                    tile(width: 32, height: 28,
                         bg: k == i ? .yellow : (inBest ? .blue.opacity(0.65) : .blue.opacity(0.25)),
                         fg: k == i ? .black : .white) { Text("\(nums[k])") }
                }
            }
            HStack(spacing: 14) {
                Text("cur=\(cur)").font(.system(.caption2, design: .monospaced)).foregroundStyle(.yellow)
                Text("best=\(best)").font(.caption.weight(.bold)).foregroundStyle(.blue)
            }
            Text("cur = max(nums[i], cur + nums[i]); best = max(best, cur)")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        i = -1; cur = 0; best = nums[0]; bestRange = (0, 0)
        var c = 0; var b = nums[0]
        var startCur = 0
        var br: (Int, Int) = (0, 0)
        for (k, v) in nums.enumerated() {
            if c + v < v { c = v; startCur = k } else { c += v }
            if c > b { b = c; br = (startCur, k) }
            let curC = c, curB = b, curR = br
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.65) {
                guard t == token else { return }
                withAnimation { i = k; cur = curC; best = curB; bestRange = curR }
            }
        }
    }
}

// MARK: - Min Path Sum (grid DP)

struct MinPathSumAnim: View {
    let grid: [[Int]] = [[1, 3, 1],
                         [1, 5, 1],
                         [4, 2, 1]]
    @State private var dp: [[Int]] = []
    @State private var cur: (Int, Int)? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Min Path Sum", tint: .indigo, onReplay: play) {
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 3) {
                    Text("grid").font(.caption2.weight(.heavy)).foregroundStyle(.secondary)
                    ForEach(grid.indices, id: \.self) { r in
                        HStack(spacing: 3) {
                            ForEach(grid[r].indices, id: \.self) { c in
                                tile(width: 26, height: 26, bg: .gray.opacity(0.45)) {
                                    Text("\(grid[r][c])")
                                }
                            }
                        }
                    }
                }
                VStack(spacing: 3) {
                    Text("dp").font(.caption2.weight(.heavy)).foregroundStyle(.indigo)
                    ForEach(dp.indices, id: \.self) { r in
                        HStack(spacing: 3) {
                            ForEach(dp[r].indices, id: \.self) { c in
                                let isCur = cur.map { $0 == (r, c) } ?? false
                                tile(width: 26, height: 26,
                                     bg: isCur ? .yellow : .indigo.opacity(0.55),
                                     fg: isCur ? .black : .white) { Text("\(dp[r][c])") }
                            }
                        }
                    }
                }
            }
            Text("dp[r][c] = grid[r][c] + min(dp[r-1][c], dp[r][c-1])")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        let R = grid.count, C = grid[0].count
        dp = Array(repeating: Array(repeating: 0, count: C), count: R)
        cur = nil
        var k = 0
        for r in 0..<R {
            for c in 0..<C {
                let v: Int
                if r == 0 && c == 0 { v = grid[0][0] }
                else if r == 0 { v = dp[0][c - 1] + grid[r][c] }
                else if c == 0 { v = dp[r - 1][0] + grid[r][c] }
                else { v = min(dp[r - 1][c], dp[r][c - 1]) + grid[r][c] }
                let rr = r, cc = c
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.5) {
                    guard t == token else { return }
                    withAnimation { dp[rr][cc] = v; cur = (rr, cc) }
                }
                k += 1
            }
        }
    }
}

// MARK: - Word Break (DP boolean array with split highlight)

struct WordBreakAnim: View {
    let s = "leetcode"
    let dict: Set<String> = ["leet", "code"]
    @State private var i = -1
    @State private var dp: [Bool] = []
    @State private var splitAt: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Word Break (\"\(s)\")", tint: .teal, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(Array(s.enumerated()), id: \.offset) { idx, c in
                        tile(width: 24, height: 28,
                             bg: idx == i ? .yellow : .teal.opacity(0.45),
                             fg: idx == i ? .black : .white) {
                            Text(String(c)).font(.system(size: 12, weight: .black, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 2) {
                    ForEach(dp.indices, id: \.self) { idx in
                        tile(width: 24, height: 22,
                             bg: dp[idx] ? .green.opacity(0.65) : .red.opacity(0.35)) {
                            Text(dp[idx] ? "✓" : "·").font(.system(size: 10, weight: .heavy))
                        }
                    }
                }
                if let s2 = splitAt {
                    Text("dp[\(s2)] = true → 後ろを判定")
                        .font(.system(.caption2, design: .monospaced)).foregroundStyle(.teal)
                }
                Text("dp[i] = ∃ j<i, dp[j] && s[j..i] ∈ dict").font(.caption2).foregroundStyle(.secondary)
                Text("辞書: " + dict.joined(separator: ", "))
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        i = -1; dp = [true] + Array(repeating: false, count: s.count); splitAt = nil
        var d = [true] + Array(repeating: false, count: s.count)
        let arr = Array(s)
        for ii in 1...s.count {
            for j in 0..<ii {
                if d[j] {
                    let sub = String(arr[j..<ii])
                    if dict.contains(sub) {
                        d[ii] = true
                        let snap = d; let cs = ii - 1; let split = j
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(ii - 1) * 0.8) {
                            guard t == token else { return }
                            withAnimation { i = cs; dp = snap; splitAt = split }
                        }
                        break
                    }
                }
            }
        }
    }
}

// MARK: - Meeting Rooms II (min heap of end times)

struct MeetingRoomsAnim: View {
    let intervals: [(Int, Int)] = [(0, 30), (5, 10), (15, 20), (25, 35)]
    @State private var i = -1
    @State private var heap: [Int] = []
    @State private var rooms = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Meeting Rooms II", tint: .purple, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                Text("intervals (start,end) を start でソート済")
                    .font(.caption2).foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    ForEach(intervals.indices, id: \.self) { k in
                        tile(width: 50, height: 28,
                             bg: k == i ? .yellow : .purple.opacity(0.45),
                             fg: k == i ? .black : .white) {
                            Text("\(intervals[k].0)–\(intervals[k].1)")
                                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("min-heap (ends):")
                        .font(.caption2.weight(.black)).foregroundStyle(.purple)
                    ForEach(heap.indices, id: \.self) { k in
                        tile(width: 28, height: 22, bg: .purple.opacity(0.6)) { Text("\(heap[k])") }
                    }
                }
                Text("rooms = \(rooms)")
                    .font(.caption.weight(.bold)).foregroundStyle(.purple)
                Text("最小終了時刻 ≤ 新規開始 なら使い回し、そうでなければ部屋追加")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        i = -1; heap = []; rooms = 0
        var h: [Int] = []
        for (k, (s, e)) in intervals.enumerated() {
            if let top = h.first, top <= s { h.removeFirst() }
            h.append(e); h.sort()
            let curH = h
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.9) {
                guard t == token else { return }
                withAnimation { i = k; heap = curH; rooms = max(rooms, curH.count) }
            }
        }
    }
}

// MARK: - Sliding Window Maximum (deque)

struct SlidingWindowMaxAnim: View {
    let nums = [1, 3, -1, -3, 5, 3, 6, 7]
    let k = 3
    @State private var idx = -1
    @State private var dq: [Int] = []   // indices, decreasing by nums[idx]
    @State private var maxes: [Int] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Sliding Window Max (k=\(k))", tint: .red, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 3) {
                    ForEach(nums.indices, id: \.self) { i in
                        let inWindow = i > idx - k && i <= idx
                        tile(width: 28, height: 28,
                             bg: i == idx ? .yellow :
                                  (inWindow ? .red.opacity(0.6) : .red.opacity(0.2)),
                             fg: i == idx ? .black : .white) { Text("\(nums[i])") }
                    }
                }
                HStack(spacing: 4) {
                    Text("deque:").font(.caption2.weight(.black)).foregroundStyle(.red)
                    ForEach(dq.indices, id: \.self) { i in
                        tile(width: 28, height: 22, bg: .red.opacity(0.55)) {
                            Text("\(nums[dq[i]])")
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("maxes:").font(.caption2.weight(.black)).foregroundStyle(.green)
                    ForEach(maxes.indices, id: \.self) { i in
                        tile(width: 28, height: 22, bg: .green.opacity(0.6)) { Text("\(maxes[i])") }
                    }
                }
                Text("先頭から古い index を pop、末尾から小さい値を pop")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        idx = -1; dq = []; maxes = []
        var d: [Int] = []; var ms: [Int] = []
        for i in nums.indices {
            while let f = d.first, f <= i - k { d.removeFirst() }
            while let b = d.last, nums[b] < nums[i] { d.removeLast() }
            d.append(i)
            if i >= k - 1 { ms.append(nums[d[0]]) }
            let curD = d, curM = ms
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.8) {
                guard t == token else { return }
                withAnimation { idx = i; dq = curD; maxes = curM }
            }
        }
    }
}

// MARK: - Min Window Substring (sliding window + counts)

struct MinWindowSubstringAnim: View {
    let s = "ADOBECODEBANC"
    let t = "ABC"
    @State private var l = 0
    @State private var r = 0
    @State private var best: (l: Int, r: Int) = (0, -1)
    @State private var counts: [Character: Int] = [:]
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Min Window Substring", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 2) {
                    ForEach(Array(s.enumerated()), id: \.offset) { i, c in
                        let inW = i >= l && i <= r
                        let inB = best.r >= 0 && i >= best.l && i <= best.r
                        tile(width: 20, height: 24,
                             bg: inW ? .yellow : (inB ? .pink.opacity(0.6) : .white.opacity(0.18)),
                             fg: inW ? .black : .white) {
                            Text(String(c)).font(.system(size: 11, weight: .black, design: .monospaced))
                        }
                    }
                }
                Text("target \"\(t)\"  window=[\(l),\(r)]")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                Text("best = \"\(best.r >= 0 ? String(Array(s)[best.l...best.r]) : "")\"")
                    .font(.caption.weight(.bold)).foregroundStyle(.pink)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        l = 0; r = -1; best = (0, -1); counts = [:]
        let arr = Array(s)
        var need: [Character: Int] = [:]
        for c in self.t { need[c, default: 0] += 1 }
        var window: [Character: Int] = [:]
        var have = 0, missing = need.count
        var ll = 0
        var bestL = 0, bestR = arr.count + 1
        for ri in arr.indices {
            window[arr[ri], default: 0] += 1
            if let n = need[arr[ri]], window[arr[ri]] == n { have += 1 }
            while have == missing {
                if ri - ll < bestR - bestL { bestL = ll; bestR = ri }
                window[arr[ll], default: 0] -= 1
                if let n = need[arr[ll]], window[arr[ll]]! < n { have -= 1 }
                ll += 1
            }
            let curL = ll, curR = ri, snap = window
            let curBest = bestR <= arr.count ? (bestL, bestR) : (0, -1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(ri) * 0.45) {
                guard t == token else { return }
                withAnimation { l = curL; r = curR; counts = snap; best = curBest }
            }
        }
    }
}

// MARK: - Trie Insert (tree growing)

struct TrieInsertAnim: View {
    let words = ["cat", "car", "card", "cap"]
    @State private var nodes: [String: Set<String>] = [:]   // path → children chars
    @State private var current = ""
    @State private var inserting: String = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Trie Insert", tint: .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                Text("inserting: \"\(inserting)\"")
                    .font(.system(.caption, design: .monospaced).weight(.heavy))
                    .foregroundStyle(.green)
                trieView(node: "", depth: 0)
            }
        }
        .onAppear { play() }
    }
    private func trieView(node: String, depth: Int) -> AnyView {
        if let children = nodes[node], !children.isEmpty {
            return AnyView(
                HStack(spacing: 12) {
                    ForEach(Array(children).sorted(), id: \.self) { ch in
                        let childPath = node + ch
                        VStack(spacing: 4) {
                            ZStack {
                                Circle().fill(current == childPath ? .yellow : .green.opacity(0.5))
                                    .frame(width: 24, height: 24)
                                Text(ch)
                                    .font(.system(size: 11, weight: .black, design: .monospaced))
                                    .foregroundStyle(current == childPath ? .black : .white)
                            }
                            trieView(node: childPath, depth: depth + 1)
                        }
                    }
                }
            )
        } else if depth == 0 {
            return AnyView(HStack { Text("(empty)").font(.caption2).foregroundStyle(.secondary) })
        } else {
            return AnyView(EmptyView())
        }
    }
    private func play() {
        token += 1; let t = token
        nodes = [:]; current = ""; inserting = ""
        var delay = 0.4
        for w in words {
            let word = w
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard t == token else { return }
                withAnimation { inserting = word }
            }
            delay += 0.4
            var path = ""
            for c in w {
                let parent = path
                let childChar = String(c)
                let nextPath = path + childChar
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    guard t == token else { return }
                    withAnimation {
                        nodes[parent, default: []].insert(childChar)
                        current = nextPath
                    }
                }
                delay += 0.4
                path = nextPath
            }
        }
    }
}

// MARK: - Topological Sort (Kahn)

struct TopologicalSortAnim: View {
    let edges: [(String, String)] = [("A","B"),("A","C"),("B","D"),("C","D"),("D","E")]
    let nodes = ["A", "B", "C", "D", "E"]
    @State private var indeg: [String: Int] = [:]
    @State private var queue: [String] = []
    @State private var order: [String] = []
    @State private var current: String? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Topological Sort (Kahn)", tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                Text("edges: " + edges.map { "\($0.0)→\($0.1)" }.joined(separator: ", "))
                    .font(.system(size: 10, design: .monospaced)).foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    ForEach(nodes, id: \.self) { n in
                        VStack(spacing: 2) {
                            ZStack {
                                Circle().fill(order.contains(n) ? .green.opacity(0.7) :
                                              current == n ? .yellow :
                                              queue.contains(n) ? .blue : .gray.opacity(0.4))
                                    .frame(width: 28, height: 28)
                                Text(n).font(.system(size: 11, weight: .black))
                                    .foregroundStyle(current == n ? .black : .white)
                            }
                            Text("in=\(indeg[n] ?? 0)").font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("queue:").font(.caption2.weight(.black)).foregroundStyle(.blue)
                    ForEach(queue.indices, id: \.self) { i in
                        tile(width: 22, height: 22, bg: .blue.opacity(0.6)) { Text(queue[i]) }
                    }
                }
                HStack(spacing: 4) {
                    Text("order:").font(.caption2.weight(.black)).foregroundStyle(.green)
                    ForEach(order.indices, id: \.self) { i in
                        tile(width: 22, height: 22, bg: .green.opacity(0.65)) { Text(order[i]) }
                    }
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        var ind: [String: Int] = [:]
        for n in nodes { ind[n] = 0 }
        var adj: [String: [String]] = [:]
        for e in edges { adj[e.0, default: []].append(e.1); ind[e.1, default: 0] += 1 }
        indeg = ind; queue = []; order = []; current = nil
        var q = nodes.filter { ind[$0] == 0 }
        var o: [String] = []
        var delay = 0.4
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard t == token else { return }
            withAnimation { queue = q }
        }
        delay += 0.8
        while !q.isEmpty {
            let n = q.removeFirst()
            o.append(n)
            for next in adj[n] ?? [] {
                ind[next, default: 0] -= 1
                if ind[next] == 0 { q.append(next) }
            }
            let curN = n, snapQ = q, snapO = o, snapInd = ind
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard t == token else { return }
                withAnimation {
                    current = curN; queue = snapQ; order = snapO; indeg = snapInd
                }
            }
            delay += 0.8
        }
    }
}

// MARK: - Dijkstra (priority queue)

struct DijkstraAnim: View {
    let nodes = ["A", "B", "C", "D"]
    let edges: [(String, String, Int)] = [
        ("A", "B", 2), ("A", "C", 5),
        ("B", "C", 1), ("B", "D", 4),
        ("C", "D", 2)
    ]
    @State private var dist: [String: Int] = [:]
    @State private var finalized: Set<String> = []
    @State private var current: String? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Dijkstra (from A)", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 14) {
                    ForEach(nodes, id: \.self) { n in
                        VStack(spacing: 2) {
                            ZStack {
                                Circle().fill(finalized.contains(n) ? .green.opacity(0.75) :
                                              current == n ? .yellow : .orange.opacity(0.5))
                                    .frame(width: 32, height: 32)
                                Text(n).font(.system(size: 12, weight: .black))
                                    .foregroundStyle(current == n ? .black : .white)
                            }
                            Text(dist[n].map { $0 == .max ? "∞" : "\($0)" } ?? "∞")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundStyle(.orange)
                        }
                    }
                }
                Text("edges: " + edges.map { "\($0.0)-\($0.1)(\($0.2))" }.joined(separator: " "))
                    .font(.system(size: 9, design: .monospaced)).foregroundStyle(.secondary)
                Text("各ステップで最短距離が確定したノードを緑、現在処理中を黄に")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        var d: [String: Int] = [:]
        for n in nodes { d[n] = n == "A" ? 0 : .max }
        dist = d; finalized = []; current = nil
        var adj: [String: [(String, Int)]] = [:]
        for e in edges {
            adj[e.0, default: []].append((e.1, e.2))
            adj[e.1, default: []].append((e.0, e.2))
        }
        var fin: Set<String> = []
        var delay = 0.4
        while fin.count < nodes.count {
            // 最小未確定 d を選ぶ
            var pick: String? = nil
            var minV = Int.max
            for n in nodes where !fin.contains(n) {
                if let v = d[n], v < minV { minV = v; pick = n }
            }
            guard let p = pick else { break }
            fin.insert(p)
            for (nb, w) in adj[p] ?? [] {
                if !fin.contains(nb), d[p]! + w < d[nb, default: .max] {
                    d[nb] = d[p]! + w
                }
            }
            let snapD = d, snapF = fin, curP = p
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard t == token else { return }
                withAnimation { dist = snapD; finalized = snapF; current = curP }
            }
            delay += 1.0
        }
    }
}

// MARK: - Balanced Binary Tree

struct BalancedBTAnim: View {
    let nodes = [3, 9, 20, 1, 2, 15, 7]
    @State private var depths: [Int: Int] = [:]
    @State private var bad: Int? = nil
    @State private var done = false
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Balanced Binary Tree", tint: .green, onReplay: play) {
            LeveledTree(nodes: nodes,
                        highlightVisited: Array(depths.keys),
                        current: bad,
                        palette: (.green, .red, .green.opacity(0.4)))
            HStack(spacing: 4) {
                ForEach(depths.sorted(by: { $0.key < $1.key }), id: \.key) { kv in
                    tile(width: 32, height: 22, bg: .green.opacity(0.55)) {
                        VStack(spacing: 0) {
                            Text("\(kv.key)").font(.system(size: 9))
                            Text("h=\(kv.value)").font(.system(size: 9, weight: .heavy))
                        }
                    }
                }
            }
            if done {
                Text(bad == nil ? "🟢 バランス済 (|hL-hR| ≤ 1)" : "🔴 unbalanced at \(bad!)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(bad == nil ? .green : .red)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        depths = [:]; bad = nil; done = false
        // postorder で高さ計算 (葉=1)
        let post: [(Int, Int)] = [(nodes[3], 1), (nodes[4], 1), (nodes[1], 2),
                                   (nodes[5], 1), (nodes[6], 1), (nodes[2], 2),
                                   (nodes[0], 3)]
        for (k, (v, h)) in post.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.6) {
                guard t == token else { return }
                withAnimation { depths[v] = h }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(post.count) * 0.6 + 0.3) {
            guard t == token else { return }
            withAnimation { done = true }   // この木はバランス
        }
    }
}

// MARK: - Count Bits (DP using i & (i-1))

struct CountBitsAnim: View {
    let n = 8
    @State private var dp: [Int] = []
    @State private var cur = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Count Bits (DP)", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(0...n, id: \.self) { i in
                        VStack(spacing: 2) {
                            tile(width: 28, height: 22,
                                 bg: i == cur ? .yellow : .indigo.opacity(0.45),
                                 fg: i == cur ? .black : .white) { Text("\(i)") }
                            if i < dp.count {
                                Text(String(i, radix: 2))
                                    .font(.system(size: 8, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                Text("\(dp[i])")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundStyle(.indigo)
                            }
                        }
                    }
                }
                Text("dp[i] = dp[i >> 1] + (i & 1)")
                    .font(.system(.caption, design: .monospaced)).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        dp = []; cur = -1
        var d: [Int] = []
        for i in 0...n {
            let v: Int
            if i == 0 { v = 0 } else { v = d[i >> 1] + (i & 1) }
            d.append(v)
            let snap = d
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.6) {
                guard t == token else { return }
                withAnimation { cur = i; dp = snap }
            }
        }
    }
}

// MARK: - Union Find Merge

struct UnionFindMergeAnim: View {
    let n = 6
    let unions: [(Int, Int)] = [(0,1),(2,3),(0,2),(4,5)]
    @State private var parent: [Int] = []
    @State private var op = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Union-Find", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    ForEach(0..<n, id: \.self) { i in
                        VStack(spacing: 2) {
                            ZStack {
                                Circle().fill(rootColor(i))
                                    .frame(width: 26, height: 26)
                                Text("\(i)").font(.system(size: 11, weight: .black))
                                    .foregroundStyle(.white)
                            }
                            if i < parent.count {
                                Text("→\(find(i))")
                                    .font(.system(size: 8, weight: .heavy, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                Text(op).font(.caption.weight(.heavy)).foregroundStyle(.pink)
                Text("union(a,b): root(b) を root(a) の子に")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func find(_ x: Int) -> Int {
        guard parent.indices.contains(x) else { return x }
        var i = x
        while parent[i] != i { i = parent[i] }
        return i
    }
    private func rootColor(_ i: Int) -> Color {
        let r = find(i)
        let palette: [Color] = [.pink, .blue, .green, .orange, .purple, .teal]
        return palette[r % palette.count].opacity(0.75)
    }
    private func play() {
        token += 1; let t = token
        parent = Array(0..<n)
        op = ""
        for (k, (a, b)) in unions.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 1.0) {
                guard t == token else { return }
                withAnimation {
                    let ra = self.find(a), rb = self.find(b)
                    if ra != rb { parent[rb] = ra }
                    op = "union(\(a), \(b)) → root(\(b))=\(rb) を root(\(a))=\(ra) の子に"
                }
            }
        }
    }
}

// MARK: - Trie Search (path walking)

struct TrieSearchAnim: View {
    let words = ["cat", "car", "card"]
    let query = "card"
    @State private var path = ""
    @State private var found = false
    @State private var failed = false
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Trie Search: \"\(query)\"", tint: .teal, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(Array(query.enumerated()), id: \.offset) { i, c in
                        let visited = i < path.count
                        tile(width: 26, height: 28,
                             bg: visited ? .teal.opacity(0.7) : .gray.opacity(0.4),
                             fg: .white) {
                            Text(String(c)).font(.system(size: 12, weight: .black, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 6) {
                    Text("path:").font(.caption2.weight(.black)).foregroundStyle(.teal)
                    Text("\"\(path)\"")
                        .font(.system(.caption, design: .monospaced).weight(.heavy))
                        .foregroundStyle(.teal)
                }
                Text("辞書: " + words.joined(separator: ", "))
                    .font(.caption2).foregroundStyle(.secondary)
                if found {
                    Text("🎯 ヒット！ end フラグも true")
                        .font(.caption.weight(.bold)).foregroundStyle(.green)
                } else if failed {
                    Text("❌ どこかでパスが切れた")
                        .font(.caption.weight(.bold)).foregroundStyle(.red)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        path = ""; found = false; failed = false
        // 辞書から trie を作成
        var children: [String: Set<Character>] = [:]
        var endpoints: Set<String> = []
        for w in words {
            var p = ""
            for c in w {
                children[p, default: []].insert(c)
                p.append(c)
            }
            endpoints.insert(p)
        }
        var p = ""
        let qArr = Array(query)
        for (k, c) in qArr.enumerated() {
            let parent = p
            let hasChild = children[parent]?.contains(c) ?? false
            p.append(c)
            let newPath = p
            let last = k == qArr.count - 1
            let isFound = last && hasChild && endpoints.contains(newPath)
            let isFailed = !hasChild
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation {
                    if !hasChild { failed = true }
                    else { path = newPath }
                    if isFound { found = true }
                }
            }
            if !hasChild { break }
        }
    }
}

// MARK: - Flatten Binary Tree to Linked List

struct FlattenBTAnim: View {
    @State private var nodes = [1, 2, 5, 3, 4, 0, 6]
    @State private var phase = 0   // 0=tree, 1=flatten
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Flatten BT → Linked List", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                if phase == 0 {
                    LeveledTree(nodes: nodes,
                                highlightVisited: [],
                                current: nil,
                                palette: (.indigo, .yellow, .indigo.opacity(0.4)))
                    Text("preorder = [1, 2, 3, 4, 5, 6] になるように右リンクに展開")
                        .font(.caption2).foregroundStyle(.secondary)
                } else {
                    HStack(spacing: 0) {
                        ForEach([1, 2, 3, 4, 5, 6], id: \.self) { v in
                            ZStack {
                                Circle().fill(.indigo).frame(width: 28, height: 28)
                                Text("\(v)").font(.system(size: 11, weight: .black))
                                    .foregroundStyle(.white)
                            }
                            if v != 6 {
                                Image(systemName: "arrow.right")
                                    .font(.caption.weight(.heavy))
                                    .foregroundStyle(.indigo)
                                    .frame(width: 14)
                            }
                        }
                    }
                    Text("右リンクのみの単方向リスト")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        phase = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard t == token else { return }
            withAnimation { phase = 1 }
        }
    }
}

// MARK: - Build Tree from Inorder + Postorder

struct BuildTreePostAnim: View {
    let inorder = [9, 3, 15, 20, 7]
    let postorder = [9, 15, 7, 20, 3]
    @State private var built: Set<Int> = []
    @State private var current: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Build Tree (in+post)", tint: .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("inorder:").font(.caption2.weight(.black)).foregroundStyle(.green)
                    ForEach(inorder, id: \.self) { v in
                        tile(width: 28, height: 24,
                             bg: built.contains(v) ? .green.opacity(0.6) : .green.opacity(0.25)) {
                            Text("\(v)")
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("postorder:").font(.caption2.weight(.black)).foregroundStyle(.green)
                    ForEach(postorder, id: \.self) { v in
                        tile(width: 28, height: 24,
                             bg: current == v ? .yellow :
                                 built.contains(v) ? .green.opacity(0.6) : .green.opacity(0.25),
                             fg: current == v ? .black : .white) {
                            Text("\(v)")
                        }
                    }
                }
                Text("postorder の末尾 = root。inorder でその位置を見つけて左右に分割")
                    .font(.caption2).foregroundStyle(.secondary)
                LeveledTree(nodes: [3, 9, 20, 0, 0, 15, 7],
                            highlightVisited: Array(built),
                            current: current,
                            palette: (.green.opacity(0.7), .yellow, .green.opacity(0.3)))
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        built = []; current = nil
        // 確定する順: 3 (root) → 20 (right) → 7 → 15 → 9 (postorder 逆順で各 root)
        let order = [3, 20, 7, 15, 9]
        for (k, v) in order.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.8) {
                guard t == token else { return }
                withAnimation { current = v; built.insert(v) }
            }
        }
    }
}

// MARK: - Serialize Binary Tree

struct SerializeBTAnim: View {
    let nodes = [1, 2, 3, 4, 5, 6, 7]
    @State private var serialized: [String] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Serialize BT (BFS)", tint: .orange, onReplay: play) {
            LeveledTree(nodes: nodes,
                        highlightVisited: serialized.compactMap { Int($0) },
                        current: nil,
                        palette: (.orange.opacity(0.65), .yellow, .orange.opacity(0.3)))
            HStack(spacing: 3) {
                Text("→")
                ForEach(serialized.indices, id: \.self) { i in
                    tile(width: 22, height: 22, bg: .orange.opacity(0.55)) {
                        Text(serialized[i])
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                    }
                }
            }
            Text("level order + null を文字列化")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        serialized = []
        let seq = nodes.map(String.init) + ["#", "#", "#", "#", "#", "#", "#", "#"]
        for (k, s) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.4) {
                guard t == token else { return }
                withAnimation { serialized.append(s) }
            }
        }
    }
}

// MARK: - Kth Smallest in BST

struct KthSmallestBSTAnim: View {
    let nodes = [5, 3, 8, 1, 4, 7, 9]
    let k = 3
    @State private var visited: [Int] = []
    @State private var current: Int? = nil
    @State private var answer: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Kth Smallest in BST (k=\(k))", tint: .pink, onReplay: play) {
            LeveledTree(nodes: nodes,
                        highlightVisited: visited,
                        current: current,
                        palette: (.pink.opacity(0.65), .yellow, .pink.opacity(0.3)))
            HStack(spacing: 4) {
                Text("inorder:").font(.caption2.weight(.black)).foregroundStyle(.pink)
                ForEach(visited.indices, id: \.self) { i in
                    let isAns = i + 1 == k
                    tile(width: 26, height: 22,
                         bg: isAns ? .green.opacity(0.75) : .pink.opacity(0.55)) {
                        Text("\(visited[i])")
                    }
                }
            }
            if let a = answer {
                Text("🎯 \(k) 番目に小さい = \(a)")
                    .font(.caption.weight(.bold)).foregroundStyle(.green)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        visited = []; current = nil; answer = nil
        // BST inorder = 昇順
        let seq = [nodes[3], nodes[1], nodes[4], nodes[0], nodes[5], nodes[2], nodes[6]]
        for (idx, v) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(idx) * 0.6) {
                guard t == token else { return }
                withAnimation { current = v; visited.append(v) }
                if idx + 1 == k {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        guard t == token else { return }
                        withAnimation { answer = v }
                    }
                }
            }
            if idx + 1 == k { break }
        }
    }
}

// MARK: - Inorder Iterative (stack)

struct InorderIterativeAnim: View {
    let nodes = [4, 2, 6, 1, 3, 5, 7]
    @State private var stack: [Int] = []
    @State private var current: Int? = nil
    @State private var visited: [Int] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Inorder (Iterative)", tint: .teal, onReplay: play) {
            LeveledTree(nodes: nodes,
                        highlightVisited: visited,
                        current: current,
                        palette: (.teal.opacity(0.65), .yellow, .teal.opacity(0.3)))
            HStack(spacing: 4) {
                Text("stack:").font(.caption2.weight(.black)).foregroundStyle(.teal)
                ForEach(stack.indices, id: \.self) { i in
                    tile(width: 22, height: 22, bg: .teal.opacity(0.55)) { Text("\(stack[i])") }
                }
            }
            HStack(spacing: 4) {
                Text("out:").font(.caption2.weight(.black)).foregroundStyle(.green)
                ForEach(visited.indices, id: \.self) { i in
                    tile(width: 22, height: 22, bg: .green.opacity(0.65)) { Text("\(visited[i])") }
                }
            }
            Text("ループ: 左の子をスタックに積み続け、ない時 pop → visit → 右へ")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        stack = []; current = nil; visited = []
        // インデックス: 0=root, 1/2=L/R, 3..6
        var st: [Int] = []
        var v: [Int] = []
        // シンプルにスタックの push/pop を演出
        let steps: [(stack: [Int], visit: Int?, cur: Int?)] = [
            ([4], nil, 4), ([4, 2], nil, 2), ([4, 2, 1], nil, 1),
            ([4, 2], 1, 2),
            ([4], 2, 2),
            ([4, 3], nil, 3),
            ([4], 3, 3),
            ([], 4, 4),
            ([6], nil, 6), ([6, 5], nil, 5),
            ([6], 5, 5),
            ([], 6, 6),
            ([7], nil, 7),
            ([], 7, 7)
        ]
        for (k, step) in steps.enumerated() {
            let s = step.stack
            let curV = step.cur
            let visit = step.visit
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.55) {
                guard t == token else { return }
                withAnimation {
                    st = s; stack = s; current = curV
                    if let val = visit, !v.contains(val) { v.append(val); visited = v }
                }
            }
        }
    }
}

// MARK: - LCA of Binary Tree

struct LCAofBTAnim: View {
    let nodes = [3, 5, 1, 6, 2, 0, 8]
    let p = 5, q = 1
    @State private var subResult: [Int: String] = [:]
    @State private var lca: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "LCA of BT (p=\(p), q=\(q))", tint: .red, onReplay: play) {
            LeveledTree(nodes: nodes,
                        highlightVisited: Array(subResult.keys),
                        current: lca,
                        palette: (.red.opacity(0.55), .yellow, .red.opacity(0.3)))
            HStack(spacing: 4) {
                ForEach(subResult.sorted(by: { $0.key < $1.key }), id: \.key) { kv in
                    tile(width: 38, height: 24, bg: .red.opacity(0.55)) {
                        VStack(spacing: 0) {
                            Text("\(kv.key)").font(.system(size: 9))
                            Text(kv.value).font(.system(size: 9, weight: .heavy))
                        }
                    }
                }
            }
            if let l = lca {
                Text("🎯 LCA = \(l)")
                    .font(.caption.weight(.bold)).foregroundStyle(.red)
            }
            Text("葉から上へ「p or q を含んでる？」を伝搬。左右両方 true なら LCA")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        subResult = [:]; lca = nil
        // ノード 5 と 1 を含む部分木を見つけ、LCA は 3
        let post: [(Int, String)] = [
            (6, "−"), (2, "−"), (5, "p"),
            (0, "−"), (8, "−"), (1, "q"),
            (3, "LCA")
        ]
        for (k, (v, label)) in post.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation {
                    subResult[v] = label
                    if label == "LCA" { lca = v }
                }
            }
        }
    }
}

// MARK: - Decode Ways (string DP)

struct DecodeWaysAnim: View {
    let s = "226"
    @State private var dp: [Int] = []
    @State private var cur = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Decode Ways (\"\(s)\")", tint: .purple, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(Array(s.enumerated()), id: \.offset) { i, c in
                        tile(width: 28, height: 30,
                             bg: i == cur ? .yellow : .purple.opacity(0.45),
                             fg: i == cur ? .black : .white) {
                            Text(String(c)).font(.system(size: 13, weight: .black, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("dp:").font(.caption2.weight(.black)).foregroundStyle(.purple)
                    ForEach(dp.indices, id: \.self) { i in
                        tile(width: 28, height: 22,
                             bg: i == dp.count - 1 ? .yellow : .purple.opacity(0.55),
                             fg: i == dp.count - 1 ? .black : .white) { Text("\(dp[i])") }
                    }
                }
                Text("dp[i] = (s[i-1] ≠ '0') ? dp[i-1] : 0 + (10..26 ? dp[i-2] : 0)")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                if let last = dp.last {
                    Text("= \(last) 通り").font(.caption.weight(.bold)).foregroundStyle(.purple)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        dp = [1]; cur = -1   // dp[0] = 1 (空文字)
        var d = [1]
        let chars = Array(s)
        for i in 1...chars.count {
            let one = Int(String(chars[i - 1]))!
            let two = i >= 2 ? Int(String(chars[i - 2 ... i - 1]))! : 0
            var v = 0
            if one >= 1 { v += d[i - 1] }
            if 10 <= two, two <= 26 { v += d[i - 2] }
            d.append(v)
            let snap = d; let pos = i - 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i - 1) * 0.8) {
                guard t == token else { return }
                withAnimation { cur = pos; dp = snap }
            }
        }
    }
}

// MARK: - Intersection of Two Linked Lists

struct IntersectionLLAnim: View {
    let a = [4, 1]
    let b = [5, 6, 1]
    let shared = [8, 4, 5]
    @State private var pA: Int = 0
    @State private var pB: Int = 0
    @State private var token = 0
    @State private var hit: Int? = nil

    var body: some View {
        AnimFrame(title: "Intersection of Two LLs", tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                listRow("A", arr: a + shared, ptr: pA, color: .blue, intersect: a.count)
                listRow("B", arr: b + shared, ptr: pB, color: .orange, intersect: b.count)
                Text("片方が末尾に着いたらもう片方の先頭にジャンプ。長さ差を吸収する")
                    .font(.caption2).foregroundStyle(.secondary)
                if let h = hit {
                    Text("🎯 交点 = \(h)").font(.caption.weight(.bold)).foregroundStyle(.green)
                }
            }
        }
        .onAppear { play() }
    }
    private func listRow(_ label: String, arr: [Int], ptr: Int, color: Color, intersect: Int) -> some View {
        HStack(spacing: 4) {
            Text(label).font(.system(size: 12, weight: .black, design: .monospaced))
                .frame(width: 14).foregroundStyle(color)
            ForEach(arr.indices, id: \.self) { i in
                tile(width: 28, height: 28,
                     bg: i == ptr ? .yellow : (i >= intersect ? .green.opacity(0.55) : color.opacity(0.45)),
                     fg: i == ptr ? .black : .white) { Text("\(arr[i])") }
            }
        }
    }
    private func play() {
        token += 1; let t = token
        pA = 0; pB = 0; hit = nil
        let aFull = a + shared
        let bFull = b + shared
        var i = 0, j = 0
        var loop = aFull[i]
        var loop2 = bFull[j]
        var done = false
        var k = 0
        while !done && k < 12 {
            let curA = i, curB = j
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation { pA = curA; pB = curB }
            }
            if loop == loop2 { done = true; let foundVal = loop
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k + 1) * 0.7) {
                    guard t == token else { return }
                    withAnimation { hit = foundVal }
                }
                break
            }
            i = (i + 1) % aFull.count
            j = (j + 1) % bFull.count
            // 単純化のため: 末尾を超えたら他方の先頭に飛ぶ風
            if i < aFull.count { loop = aFull[i] }
            if j < bFull.count { loop2 = bFull[j] }
            k += 1
        }
    }
}

// MARK: - Top K Frequent (heap of counts)

struct TopKFrequentAnim: View {
    let nums = [1, 1, 1, 2, 2, 3]
    let k = 2
    @State private var counts: [Int: Int] = [:]
    @State private var heap: [(Int, Int)] = []   // (count, num)
    @State private var idx = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Top K Frequent (k=\(k))", tint: .red, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(nums.indices, id: \.self) { i in
                        tile(width: 28, height: 26,
                             bg: i == idx ? .yellow : .red.opacity(0.4),
                             fg: i == idx ? .black : .white) { Text("\(nums[i])") }
                    }
                }
                HStack(spacing: 4) {
                    Text("counts:").font(.caption2.weight(.black)).foregroundStyle(.red)
                    ForEach(counts.sorted(by: { $0.key < $1.key }), id: \.key) { kv in
                        tile(width: 38, height: 24, bg: .red.opacity(0.55)) {
                            Text("\(kv.key):\(kv.value)").font(.system(size: 9, weight: .heavy))
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("heap (top \(k)):").font(.caption2.weight(.black)).foregroundStyle(.green)
                    ForEach(heap.indices, id: \.self) { i in
                        tile(width: 38, height: 24, bg: .green.opacity(0.55)) {
                            Text("\(heap[i].1)×\(heap[i].0)").font(.system(size: 9, weight: .heavy))
                        }
                    }
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        counts = [:]; heap = []; idx = -1
        var c: [Int: Int] = [:]
        for (i, v) in nums.enumerated() {
            c[v, default: 0] += 1
            let snap = c
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.55) {
                guard t == token else { return }
                withAnimation { idx = i; counts = snap }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(nums.count) * 0.55 + 0.3) {
            guard t == token else { return }
            let sorted = c.sorted { $0.value > $1.value }.prefix(k)
            withAnimation { heap = sorted.map { ($0.value, $0.key) } }
        }
    }
}

// MARK: - Kruskal MST

struct KruskalAnim: View {
    let nodes = ["A", "B", "C", "D", "E"]
    let edges: [(String, String, Int)] = [
        ("A", "B", 1), ("C", "D", 2), ("A", "C", 3),
        ("B", "D", 4), ("D", "E", 5), ("B", "C", 6)
    ]
    @State private var processed: [(String, String, Int, Bool)] = []   // bool = used
    @State private var mstSum = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Kruskal MST", tint: .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                Text("edges を重み昇順、Union-Find でサイクル回避")
                    .font(.caption2).foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(processed.indices, id: \.self) { i in
                        let e = processed[i]
                        HStack(spacing: 6) {
                            Text(e.3 ? "✓" : "×")
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(e.3 ? .green : .red)
                            Text("\(e.0)-\(e.1)")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                .foregroundStyle(e.3 ? .green : .secondary)
                            Text("w=\(e.2)")
                                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Text("MST 合計 = \(mstSum)").font(.caption.weight(.bold)).foregroundStyle(.green)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        processed = []; mstSum = 0
        let sorted = edges.sorted { $0.2 < $1.2 }
        var parent: [String: String] = [:]
        for n in nodes { parent[n] = n }
        func find(_ x: String) -> String {
            var i = x
            while parent[i] != i { i = parent[i]! }
            return i
        }
        var sum = 0
        for (k, e) in sorted.enumerated() {
            let ra = find(e.0), rb = find(e.1)
            let use = ra != rb
            if use { parent[rb] = ra; sum += e.2 }
            let entry = (e.0, e.1, e.2, use)
            let snapSum = sum
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.9) {
                guard t == token else { return }
                withAnimation { processed.append(entry); mstSum = snapSum }
            }
        }
    }
}

// MARK: - Power of Two

struct PowerOfTwoAnim: View {
    let candidates = [1, 2, 4, 6, 8, 16, 17, 32, 100]
    @State private var idx = -1
    @State private var results: [(Int, Bool)] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Power of Two: n & (n-1) == 0 ?", tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(candidates.indices, id: \.self) { i in
                        tile(width: 32, height: 26,
                             bg: i == idx ? .yellow : .blue.opacity(0.4),
                             fg: i == idx ? .black : .white) { Text("\(candidates[i])") }
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(results.indices, id: \.self) { i in
                        let r = results[i]
                        HStack(spacing: 4) {
                            Text(r.1 ? "✓" : "×")
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(r.1 ? .green : .red)
                            Text("\(r.0) (\(String(r.0, radix: 2)))")
                                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            Text("→ \(r.0) & \(r.0 - 1) = \(r.0 & (r.0 - 1))")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        idx = -1; results = []
        for (i, n) in candidates.enumerated() {
            let isPow = n > 0 && (n & (n - 1)) == 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation { idx = i; results.append((n, isPow)) }
            }
        }
    }
}

// MARK: - Three Sum (sorted + two-pointer)

struct ThreeSumAnim: View {
    let nums = [-1, 0, 1, 2, -1, -4]
    @State private var arr = [-4, -1, -1, 0, 1, 2]
    @State private var i = 0
    @State private var l = 1
    @State private var r = 5
    @State private var triplets: [[Int]] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "3Sum (sorted + 2-pointer)", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(arr.indices, id: \.self) { k in
                        let isI = k == i
                        let isL = k == l
                        let isR = k == r
                        tile(width: 28, height: 28,
                             bg: isI ? .pink : (isL ? .blue : (isR ? .orange : .pink.opacity(0.25))),
                             fg: isI || isL || isR ? .white : .white.opacity(0.9)) {
                            Text("\(arr[k])")
                        }
                    }
                }
                HStack(spacing: 6) {
                    Text("i").foregroundStyle(.pink)
                    Text("l").foregroundStyle(.blue)
                    Text("r").foregroundStyle(.orange)
                }
                .font(.caption2.weight(.black))
                Text("triplets: " + triplets.map { "[\($0[0]),\($0[1]),\($0[2])]" }.joined(separator: " "))
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        arr = nums.sorted()
        i = 0; l = 1; r = arr.count - 1; triplets = []
        var found: [[Int]] = []
        var ii = 0, ll = 1, rr = arr.count - 1
        var k = 0
        while ii < arr.count - 2 {
            ll = ii + 1; rr = arr.count - 1
            while ll < rr {
                let sum = arr[ii] + arr[ll] + arr[rr]
                let curI = ii, curL = ll, curR = rr
                if sum == 0 {
                    found.append([arr[ii], arr[ll], arr[rr]])
                    ll += 1; rr -= 1
                } else if sum < 0 { ll += 1 }
                else { rr -= 1 }
                let snap = found
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.55) {
                    guard t == token else { return }
                    withAnimation { i = curI; l = curL; r = curR; triplets = snap }
                }
                k += 1
                if k > 20 { break }
            }
            ii += 1
            if k > 20 { break }
        }
    }
}

// MARK: - Power: Fast Exponentiation (binary expand)

struct FastPowBinaryAnim: View {
    let base: Double = 2
    let exp: Int = 13
    @State private var step = -1
    @State private var bits: [Int] = []
    @State private var partials: [(Double, Bool)] = []   // (val, contributed)
    @State private var result: Double = 1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Fast Pow: \(base)^\(exp)", tint: .yellow, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("\(exp) =").font(.system(size: 10, weight: .black, design: .monospaced))
                    ForEach(bits.indices.reversed(), id: \.self) { i in
                        let b = bits[i]
                        tile(width: 20, height: 22,
                             bg: i == step ? .red : (b == 1 ? .green.opacity(0.6) : .gray.opacity(0.3))) {
                            Text("\(b)").font(.system(size: 11, weight: .black, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 4) {
                    ForEach(partials.indices, id: \.self) { i in
                        let p = partials[i]
                        tile(width: 38, height: 24,
                             bg: p.1 ? .yellow : .gray.opacity(0.3)) {
                            Text(String(format: "%.0f", p.0))
                                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                        }
                    }
                }
                Text("result = " + String(format: "%.0f", result))
                    .font(.caption.weight(.bold)).foregroundStyle(.yellow)
                Text("bit が 1 のところだけ部分積を掛ける")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        bits = []; partials = []; result = 1; step = -1
        var b: [Int] = []
        var e = exp
        while e > 0 { b.append(e & 1); e >>= 1 }
        bits = b
        var p: [(Double, Bool)] = []
        var cur: Double = base
        var res: Double = 1
        for i in b.indices {
            let contribute = b[i] == 1
            if contribute { res *= cur }
            p.append((cur, contribute))
            let snap = p; let curRes = res
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.8) {
                guard t == token else { return }
                withAnimation { step = i; partials = snap; result = curRes }
            }
            cur *= cur
        }
    }
}

// MARK: - BFS (queue + grid visit order)

struct BFSGridCustomAnim: View {
    let grid: [[Int]] = [
        [1, 1, 1, 0, 1],
        [0, 1, 0, 0, 1],
        [0, 1, 1, 1, 1],
        [0, 0, 0, 0, 1]
    ]
    @State private var visited: [[Int]] = []   // order numbers, 0 = unvisited
    @State private var queue: [String] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "BFS (start=(0,0))", tint: .blue, onReplay: play) {
            VStack(spacing: 3) {
                ForEach(visited.indices, id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(visited[r].indices, id: \.self) { c in
                            let order = visited[r][c]
                            let isWall = grid[r][c] == 0
                            tile(width: 28, height: 28,
                                 bg: isWall ? .gray.opacity(0.45)
                                       : (order > 0 ? .blue.opacity(0.70) : .blue.opacity(0.20))) {
                                Text(order > 0 ? "\(order)" : (isWall ? "#" : "·"))
                                    .font(.system(size: 11, weight: .black, design: .monospaced))
                            }
                        }
                    }
                }
            }
            HStack(spacing: 4) {
                Text("queue:").font(.caption2.weight(.black)).foregroundStyle(.blue)
                ForEach(queue.indices, id: \.self) { i in
                    tile(width: 36, height: 22, bg: .blue.opacity(0.55)) {
                        Text(queue[i]).font(.system(size: 9, weight: .heavy, design: .monospaced))
                    }
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        let R = grid.count, C = grid[0].count
        visited = Array(repeating: Array(repeating: 0, count: C), count: R)
        queue = []
        var q: [(Int, Int)] = [(0, 0)]
        var v = visited
        v[0][0] = 1
        var order = 2
        var seq: [(v: [[Int]], q: [String])] = []
        seq.append((v, ["(0,0)"]))
        while let p = q.first {
            q.removeFirst()
            for (dr, dc) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
                let nr = p.0 + dr, nc = p.1 + dc
                guard nr >= 0, nr < R, nc >= 0, nc < C else { continue }
                guard grid[nr][nc] == 1, v[nr][nc] == 0 else { continue }
                v[nr][nc] = order
                order += 1
                q.append((nr, nc))
            }
            seq.append((v, q.map { "(\($0.0),\($0.1))" }))
        }
        for (k, s) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.55) {
                guard t == token else { return }
                withAnimation { visited = s.v; queue = s.q }
            }
        }
    }
}

// MARK: - DFS Iterative

struct DFSIterativeAnim: View {
    let grid: [[Int]] = [
        [1, 1, 0, 0, 0],
        [1, 0, 0, 1, 1],
        [0, 0, 1, 1, 0],
        [0, 1, 1, 0, 0]
    ]
    @State private var visited: [[Int]] = []
    @State private var stack: [String] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "DFS Iterative", tint: .green, onReplay: play) {
            VStack(spacing: 3) {
                ForEach(visited.indices, id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(visited[r].indices, id: \.self) { c in
                            let order = visited[r][c]
                            let isWall = grid[r][c] == 0
                            tile(width: 28, height: 28,
                                 bg: isWall ? .gray.opacity(0.45)
                                       : (order > 0 ? .green.opacity(0.70) : .green.opacity(0.20))) {
                                Text(order > 0 ? "\(order)" : (isWall ? "#" : "·"))
                                    .font(.system(size: 11, weight: .black, design: .monospaced))
                            }
                        }
                    }
                }
            }
            HStack(spacing: 4) {
                Text("stack:").font(.caption2.weight(.black)).foregroundStyle(.green)
                ForEach(stack.indices, id: \.self) { i in
                    tile(width: 36, height: 22, bg: .green.opacity(0.55)) {
                        Text(stack[i]).font(.system(size: 9, weight: .heavy, design: .monospaced))
                    }
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        let R = grid.count, C = grid[0].count
        visited = Array(repeating: Array(repeating: 0, count: C), count: R)
        stack = []
        var st: [(Int, Int)] = [(0, 0)]
        var v = visited
        var order = 1
        var seq: [(v: [[Int]], s: [String])] = []
        seq.append((v, ["(0,0)"]))
        while let p = st.popLast() {
            if grid[p.0][p.1] == 0 || v[p.0][p.1] > 0 { continue }
            v[p.0][p.1] = order
            order += 1
            for (dr, dc) in [(0, 1), (1, 0), (0, -1), (-1, 0)] {
                let nr = p.0 + dr, nc = p.1 + dc
                if nr >= 0 && nr < R && nc >= 0 && nc < C && grid[nr][nc] == 1 && v[nr][nc] == 0 {
                    st.append((nr, nc))
                }
            }
            seq.append((v, st.map { "(\($0.0),\($0.1))" }))
        }
        for (k, s) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.5) {
                guard t == token else { return }
                withAnimation { visited = s.v; stack = s.s }
            }
        }
    }
}

// MARK: - Quicksort (Lomuto partition + recursion)

struct QuicksortAnim: View {
    @State private var arr = [3, 1, 4, 1, 5, 9, 2, 6, 5]
    @State private var pivotIdx: Int? = nil
    @State private var i = -1
    @State private var j = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Quicksort (Lomuto)", tint: .purple, onReplay: play) {
            HStack(spacing: 3) {
                ForEach(arr.indices, id: \.self) { k in
                    let isPivot = k == pivotIdx
                    let isI = k == i, isJ = k == j
                    tile(width: 26, height: 28,
                         bg: isPivot ? .red : (isI ? .yellow : (isJ ? .orange : .purple.opacity(0.4))),
                         fg: isPivot || isI || isJ ? .black : .white) { Text("\(arr[k])") }
                }
            }
            VStack(spacing: 2) {
                Text("pivot=最後の要素、i=境界、j=走査位置")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        arr = [3, 1, 4, 1, 5, 9, 2, 6, 5]; pivotIdx = nil; i = -1; j = -1
        var a = arr
        var k = 0
        // 部分配列 [0..n-1] の partition
        func partition(_ lo: Int, _ hi: Int) {
            guard lo < hi else { return }
            let piv = a[hi]
            var ii = lo - 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.5) {
                guard t == token else { return }
                withAnimation { pivotIdx = hi; i = ii; j = lo }
            }
            k += 1
            for jj in lo..<hi {
                if a[jj] <= piv { ii += 1; a.swapAt(ii, jj) }
                let snap = a; let curI = ii, curJ = jj
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.4) {
                    guard t == token else { return }
                    withAnimation { arr = snap; i = curI; j = curJ }
                }
                k += 1
            }
            a.swapAt(ii + 1, hi)
            let snap = a
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.4) {
                guard t == token else { return }
                withAnimation { arr = snap; pivotIdx = nil; i = -1; j = -1 }
            }
            k += 1
        }
        partition(0, a.count - 1)
    }
}

// MARK: - Merge Sort (divide visualization)

struct MergeSortAnim: View {
    let initial = [4, 2, 7, 1, 3, 6, 5, 8]
    @State private var rows: [[Int]] = []   // 各段のグループを連結したもの
    @State private var phase = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Merge Sort (divide & conquer)", tint: .teal, onReplay: play) {
            VStack(spacing: 4) {
                ForEach(rows.indices, id: \.self) { idx in
                    HStack(spacing: 3) {
                        ForEach(rows[idx].indices, id: \.self) { k in
                            tile(width: 24, height: 24, bg: .teal.opacity(0.45)) {
                                Text("\(rows[idx][k])")
                                    .font(.system(size: 10, weight: .black, design: .monospaced))
                            }
                        }
                    }
                }
            }
            Text(phase == 0 ? "分割中..." : "マージ中...")
                .font(.caption2.weight(.heavy)).foregroundStyle(.teal)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        rows = [initial]; phase = 0
        // 分割
        var levels: [[Int]] = [initial]
        var size = initial.count / 2
        while size >= 1 {
            var nextLevel: [Int] = []
            var src = levels.last!
            var i = 0
            while i < src.count {
                let end = min(i + size, src.count)
                nextLevel.append(contentsOf: src[i..<end])
                i = end
            }
            levels.append(nextLevel)
            if size == 1 { break }
            size /= 2
        }
        var k = 0
        for (idx, lvl) in levels.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation { rows = Array(levels.prefix(idx + 1)) }
            }
            k += 1
        }
        // マージ
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.7) {
            guard t == token else { return }
            withAnimation { phase = 1 }
        }
        let merge2 = [2, 4, 1, 7, 3, 6, 5, 8]
        let merge4 = [1, 2, 4, 7, 3, 5, 6, 8]
        let merge8 = [1, 2, 3, 4, 5, 6, 7, 8]
        let mergeSteps = [merge2, merge4, merge8]
        for (idx, lvl) in mergeSteps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k + idx + 1) * 0.8) {
                guard t == token else { return }
                withAnimation { rows.append(lvl) }
            }
        }
    }
}

// MARK: - Counting Sort (bucket counts)

struct CountingSortAnim: View {
    let nums = [4, 2, 2, 8, 3, 3, 1]
    @State private var counts: [Int: Int] = [:]
    @State private var idx = -1
    @State private var output: [Int] = []
    @State private var phase = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Counting Sort", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(nums.indices, id: \.self) { i in
                        tile(width: 26, height: 24,
                             bg: i == idx ? .yellow : .orange.opacity(0.4),
                             fg: i == idx ? .black : .white) { Text("\(nums[i])") }
                    }
                }
                HStack(spacing: 4) {
                    ForEach(0...8, id: \.self) { v in
                        VStack(spacing: 0) {
                            Text("\(v)").font(.system(size: 8, weight: .heavy))
                            tile(width: 22, height: 22,
                                 bg: (counts[v] ?? 0) > 0 ? .orange.opacity(0.6) : .gray.opacity(0.25)) {
                                Text("\(counts[v] ?? 0)")
                                    .font(.system(size: 10, weight: .black, design: .monospaced))
                            }
                        }
                    }
                }
                if phase >= 1 {
                    HStack(spacing: 4) {
                        Text("→").font(.caption2.weight(.heavy)).foregroundStyle(.green)
                        ForEach(output.indices, id: \.self) { i in
                            tile(width: 22, height: 22, bg: .green.opacity(0.6)) {
                                Text("\(output[i])")
                                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            }
                        }
                    }
                }
                Text("各値の出現回数を数えて、小さい順に展開")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        counts = [:]; idx = -1; output = []; phase = 0
        var c: [Int: Int] = [:]
        for (i, v) in nums.enumerated() {
            c[v, default: 0] += 1
            let snap = c
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.5) {
                guard t == token else { return }
                withAnimation { idx = i; counts = snap }
            }
        }
        let base = 0.4 + Double(nums.count) * 0.5 + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + base) {
            guard t == token else { return }
            withAnimation { phase = 1 }
        }
        var seq: [Int] = []
        for v in 0...8 {
            for _ in 0..<(c[v] ?? 0) { seq.append(v) }
        }
        for (i, v) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + base + Double(i) * 0.3) {
                guard t == token else { return }
                withAnimation { output.append(v) }
            }
        }
    }
}

// MARK: - Regex Match (DP grid for s & p)

struct RegexMatchAnim: View {
    let s = "aab"
    let p = "c*a*b"
    @State private var dp: [[Bool]] = []
    @State private var cur: (Int, Int)? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Regex Match \"\(s)\" vs \"\(p)\"", tint: .purple, onReplay: play) {
            VStack(spacing: 3) {
                HStack(spacing: 2) {
                    tile(width: 20, height: 20, bg: .purple.opacity(0.15)) { Text(" ") }
                    tile(width: 20, height: 20, bg: .purple.opacity(0.3)) { Text("ε") }
                    ForEach(Array(p.enumerated()), id: \.offset) { _, c in
                        tile(width: 20, height: 20, bg: .purple.opacity(0.3)) {
                            Text(String(c)).font(.system(size: 10, weight: .black, design: .monospaced))
                        }
                    }
                }
                ForEach(dp.indices, id: \.self) { i in
                    HStack(spacing: 2) {
                        let lbl = i == 0 ? "ε" : String(Array(s)[i - 1])
                        tile(width: 20, height: 20, bg: .purple.opacity(0.3)) { Text(lbl) }
                        ForEach(dp[i].indices, id: \.self) { j in
                            let isCur = cur.map { $0 == (i, j) } ?? false
                            tile(width: 20, height: 20,
                                 bg: isCur ? .yellow : (dp[i][j] ? .green.opacity(0.65) : .red.opacity(0.30)),
                                 fg: isCur ? .black : .white) {
                                Text(dp[i][j] ? "T" : "·")
                                    .font(.system(size: 10, weight: .black, design: .monospaced))
                            }
                        }
                    }
                }
            }
            Text("'*' は直前文字が 0 回以上、'.' は任意 1 文字")
                .font(.caption2).foregroundStyle(.secondary)
            if let last = dp.last?.last {
                Text(last ? "🎯 match" : "❌ no match")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(last ? .green : .red)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        let n = s.count, m = p.count
        dp = Array(repeating: Array(repeating: false, count: m + 1), count: n + 1)
        cur = nil
        let sArr = Array(s), pArr = Array(p)
        // dp[0][0] = true
        var d = dp
        d[0][0] = true
        for j in 1...m where pArr[j - 1] == "*" {
            d[0][j] = j >= 2 ? d[0][j - 2] : false
        }
        var k = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(k) * 0.12) {
            guard t == token else { return }
            withAnimation { dp = d; cur = (0, 0) }
        }
        k += 1
        for i in 1...n {
            for j in 1...m {
                let pc = pArr[j - 1]
                var v = false
                if pc == "*" {
                    let prev = pArr[j - 2]
                    v = d[i][j - 2] || ((prev == "." || prev == sArr[i - 1]) && d[i - 1][j])
                } else if pc == "." || pc == sArr[i - 1] {
                    v = d[i - 1][j - 1]
                }
                d[i][j] = v
                let snap = d; let ii = i, jj = j
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(k) * 0.18) {
                    guard t == token else { return }
                    withAnimation { dp = snap; cur = (ii, jj) }
                }
                k += 1
            }
        }
    }
}

// MARK: - Wildcard Match

struct WildcardMatchAnim: View {
    let s = "adceb"
    let p = "*a*b"
    @State private var dp: [[Bool]] = []
    @State private var cur: (Int, Int)? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Wildcard Match \"\(s)\" vs \"\(p)\"", tint: .indigo, onReplay: play) {
            VStack(spacing: 3) {
                HStack(spacing: 2) {
                    tile(width: 20, height: 20, bg: .indigo.opacity(0.15)) { Text(" ") }
                    tile(width: 20, height: 20, bg: .indigo.opacity(0.3)) { Text("ε") }
                    ForEach(Array(p.enumerated()), id: \.offset) { _, c in
                        tile(width: 20, height: 20, bg: .indigo.opacity(0.3)) {
                            Text(String(c)).font(.system(size: 10, weight: .black, design: .monospaced))
                        }
                    }
                }
                ForEach(dp.indices, id: \.self) { i in
                    HStack(spacing: 2) {
                        let lbl = i == 0 ? "ε" : String(Array(s)[i - 1])
                        tile(width: 20, height: 20, bg: .indigo.opacity(0.3)) { Text(lbl) }
                        ForEach(dp[i].indices, id: \.self) { j in
                            let isCur = cur.map { $0 == (i, j) } ?? false
                            tile(width: 20, height: 20,
                                 bg: isCur ? .yellow : (dp[i][j] ? .green.opacity(0.65) : .red.opacity(0.30)),
                                 fg: isCur ? .black : .white) {
                                Text(dp[i][j] ? "T" : "·")
                                    .font(.system(size: 10, weight: .black, design: .monospaced))
                            }
                        }
                    }
                }
            }
            Text("'*' は任意の文字列、'?' は任意 1 文字")
                .font(.caption2).foregroundStyle(.secondary)
            if let last = dp.last?.last {
                Text(last ? "🎯 match" : "❌ no match")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(last ? .green : .red)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        let n = s.count, m = p.count
        dp = Array(repeating: Array(repeating: false, count: m + 1), count: n + 1)
        cur = nil
        let sArr = Array(s), pArr = Array(p)
        var d = dp
        d[0][0] = true
        for j in 1...m where pArr[j - 1] == "*" { d[0][j] = d[0][j - 1] }
        var k = 0
        for i in 1...n {
            for j in 1...m {
                let pc = pArr[j - 1]
                if pc == "*" { d[i][j] = d[i - 1][j] || d[i][j - 1] }
                else if pc == "?" || pc == sArr[i - 1] { d[i][j] = d[i - 1][j - 1] }
                else { d[i][j] = false }
                let snap = d; let ii = i, jj = j
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(k) * 0.18) {
                    guard t == token else { return }
                    withAnimation { dp = snap; cur = (ii, jj) }
                }
                k += 1
            }
        }
    }
}

// MARK: - Rotate Array (3-step reverse)

struct RotateArrayAnim: View {
    let nums = [1, 2, 3, 4, 5, 6, 7]
    let k = 3
    @State private var arr: [Int] = [1, 2, 3, 4, 5, 6, 7]
    @State private var phase = 0   // 0=initial, 1=full reverse, 2=front reverse, 3=back reverse
    @State private var label = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Rotate Array (k=\(k))", tint: .pink, onReplay: play) {
            HStack(spacing: 4) {
                ForEach(arr.indices, id: \.self) { i in
                    let highlight: Color = {
                        if phase == 2 && i < k { return .yellow }
                        if phase == 3 && i >= k { return .yellow }
                        return .pink.opacity(0.4)
                    }()
                    tile(width: 30, height: 28,
                         bg: highlight,
                         fg: phase >= 2 && (i < k && phase == 2 || i >= k && phase == 3) ? .black : .white) {
                        Text("\(arr[i])")
                    }
                }
            }
            Text(label).font(.caption.weight(.heavy)).foregroundStyle(.pink)
            Text("ステップ: 全体 reverse → 前 k 個 reverse → 後ろ n-k 個 reverse")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        arr = nums; phase = 0; label = "初期状態"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard t == token else { return }
            withAnimation { arr = nums.reversed(); phase = 1; label = "① 全体を reverse" }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            guard t == token else { return }
            var a = Array(nums.reversed())
            a.replaceSubrange(0..<k, with: a[0..<k].reversed())
            withAnimation { arr = a; phase = 2; label = "② 前 \(k) 個を reverse" }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            guard t == token else { return }
            var a = Array(nums.reversed())
            a.replaceSubrange(0..<k, with: a[0..<k].reversed())
            a.replaceSubrange(k..<a.count, with: a[k..<a.count].reversed())
            withAnimation { arr = a; phase = 3; label = "③ 後ろ \(nums.count - k) 個を reverse → 完成" }
        }
    }
}

// MARK: - Combinations (n choose k backtracking)

struct CombinationsAnim: View {
    let n = 4
    let k = 2
    @State private var current: [Int] = []
    @State private var collected: [[Int]] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Combinations C(\(n),\(k))", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("current:").font(.caption2.weight(.black)).foregroundStyle(.orange)
                    ForEach(current.indices, id: \.self) { i in
                        tile(width: 24, height: 24, bg: .yellow, fg: .black) { Text("\(current[i])") }
                    }
                }
                HStack(spacing: 4) {
                    ForEach(1...n, id: \.self) { v in
                        tile(width: 22, height: 22,
                             bg: current.contains(v) ? .orange : .orange.opacity(0.3)) {
                            Text("\(v)").font(.system(size: 10, weight: .black, design: .monospaced))
                        }
                    }
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 4)], spacing: 4) {
                    ForEach(collected.indices, id: \.self) { i in
                        HStack(spacing: 2) {
                            ForEach(collected[i].indices, id: \.self) { j in
                                tile(width: 18, height: 18, bg: .orange.opacity(0.55)) {
                                    Text("\(collected[i][j])")
                                }
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
        current = []; collected = []
        var combos: [[Int]] = []
        func bt(_ start: Int, _ path: [Int]) {
            if path.count == k { combos.append(path); return }
            for v in start...n {
                bt(v + 1, path + [v])
            }
        }
        bt(1, [])
        var step = 0
        for c in combos {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(step) * 0.8) {
                guard t == token else { return }
                withAnimation { current = c; collected.append(c) }
            }
            step += 1
        }
    }
}

// MARK: - Merge Intervals

struct MergeIntervalsAnim: View {
    let intervals: [(Int, Int)] = [(1, 3), (2, 6), (8, 10), (15, 18)]
    @State private var merged: [(Int, Int)] = []
    @State private var cur: Int = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Merge Intervals", tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                // 数直線
                HStack(spacing: 0) {
                    ForEach(0..<20, id: \.self) { i in
                        Rectangle().fill(Color.gray.opacity(0.3))
                            .frame(width: 12, height: 2)
                    }
                }
                // 入力 intervals
                ForEach(intervals.indices, id: \.self) { i in
                    let iv = intervals[i]
                    HStack {
                        Rectangle()
                            .fill(i == cur ? .yellow : .blue.opacity(0.5))
                            .frame(width: CGFloat(iv.1 - iv.0 + 1) * 12, height: 12)
                            .offset(x: CGFloat(iv.0) * 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("[\(iv.0),\(iv.1)]")
                            .font(.system(size: 9, weight: .heavy, design: .monospaced))
                            .frame(width: 50)
                    }
                }
                // 結果
                VStack(alignment: .leading, spacing: 4) {
                    Text("merged:").font(.caption2.weight(.black)).foregroundStyle(.green)
                    ForEach(merged.indices, id: \.self) { i in
                        HStack {
                            Rectangle().fill(Color.green.opacity(0.6))
                                .frame(width: CGFloat(merged[i].1 - merged[i].0 + 1) * 12, height: 12)
                                .offset(x: CGFloat(merged[i].0) * 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("[\(merged[i].0),\(merged[i].1)]")
                                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                                .frame(width: 50)
                        }
                    }
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        merged = []; cur = -1
        let sorted = intervals.sorted { $0.0 < $1.0 }
        var m: [(Int, Int)] = []
        for (k, iv) in sorted.enumerated() {
            if let last = m.last, iv.0 <= last.1 {
                m[m.count - 1] = (last.0, max(last.1, iv.1))
            } else {
                m.append(iv)
            }
            let snap = m
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.9) {
                guard t == token else { return }
                withAnimation { cur = k; merged = snap }
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
    case "container-water": ContainerWaterAnim()
    case "trapping-rain":   TrappingRainAnim()
    // Anagram
    case "anagram-check":  AnagramCheckAnim()
    case "group-anagrams": GroupAnagramsAnim()
    // Sorting — 専用化したものから順次置換
    case "bubble-sort":     BubbleSortPassAnim()
    case "insertion-sort":  InsertionSortAnim()
    case "selection-sort":  SelectionSortAnim()
    case "counting-sort":   CountingSortAnim()
    case "quicksort":       QuicksortAnim()
    case "merge-sort":      MergeSortAnim()
    case "dutch-flag":      DutchFlagAnim()
    case "rotate-array":    RotateArrayAnim()
    case "merge-intervals": MergeIntervalsAnim()
    // Stack — 専用 SwiftUI に置換
    case "valid-parentheses":   ValidParensAnim()
    case "min-stack":            MinStackAnim()
    case "next-greater":         NextGreaterAnim()
    case "largest-rectangle":    LargestRectAnim()
    case "longest-valid-parens": LongestValidParensAnim()
    // Linked list — 各々 専用の SwiftUI 視覚化に置換
    case "reverse-linked-list": ReverseLinkedListAnim()
    case "merge-two-lists":     MergeTwoListsAnim()
    case "middle-ll":           MiddleOfLLAnim()
    case "detect-cycle":        DetectCycleFloydAnim()
    case "add-two-numbers":     AddTwoNumbersAnim()
    case "intersection-ll":     IntersectionLLAnim()
    // Sliding window
    case "longest-substring": LongestSubstringAnim()
    case "min-window-substring": MinWindowSubstringAnim()
    case "sliding-window-max":   SlidingWindowMaxAnim()
    // BFS / DFS / Graph — それぞれ違うグリッド
    case "bfs":           BFSGridCustomAnim()
    case "dfs-iterative": DFSIterativeAnim()
    case "num-islands":   NumIslandsAnim()
    case "level-order":
        TreeTraversalAnim(order: .level, nodes: [3,9,20,1,2,15,7],
                          subtitle: "BFS で同じ深さをまとめて出力")
    case "topo-sort":       TopologicalSortAnim()
    case "course-schedule": TopologicalSortAnim()
    case "dijkstra":        DijkstraAnim()
    case "union-find": UnionFindMergeAnim()
    case "kruskal": KruskalAnim()
    // Tree — それぞれ違う木の形と副題で動かす
    case "inorder-iter":         InorderIterativeAnim()
    case "validate-bst":         ValidateBSTAnim()
    case "kth-smallest-bst":     KthSmallestBSTAnim()
    case "lca-bt":               LCAofBTAnim()
    case "lca-bst":              LCAofBSTAnim()
    case "flatten-bt":           FlattenBTAnim()
    case "build-tree-post":      BuildTreePostAnim()
    case "max-depth-bt":         MaxDepthBTAnim()
    case "balanced-bt":          BalancedBTAnim()
    case "diameter-bt":          DiameterBTAnim()
    case "path-sum":             PathSumAnim()
    case "invert-bt":            InvertTreeAnim()
    case "symmetric-tree":       SymmetricTreeAnim()
    case "serialize-bt":         SerializeBTAnim()
    // DP
    case "fibonacci-memo": FibMemoAnim()
    case "house-robber": HouseRobberAnim()
    case "lcs":          LCSAnim()
    case "lis":          LISAnim()
    case "knapsack":     KnapsackAnim()
    case "unique-paths": UniquePathsAnim()
    case "edit-distance": EditDistanceAnim()
    case "min-path-sum": MinPathSumAnim()
    case "decode-ways": DecodeWaysAnim()
    case "word-break": WordBreakAnim()
    case "regex-matching":    RegexMatchAnim()
    case "wildcard-matching": WildcardMatchAnim()
    case "max-subarray": MaxSubarrayKadaneAnim()
    case "count-bits": CountBitsAnim()
    // Heap
    case "kth-largest": KthLargestAnim()
    case "top-k-freq": TopKFrequentAnim()
    case "meeting-rooms": MeetingRoomsAnim()
    // Bit
    case "single-number": SingleNumberAnim()
    case "power-of-two":  PowerOfTwoAnim()
    case "reverse-bits":  ReverseBitsAnim()
    // Backtracking
    case "combinations": CombinationsAnim()
    case "subsets":      SubsetsAnim()
    case "permutations": PermutationsTreeAnim()
    case "n-queens":     NQueensAnim()
    case "word-search":  WordSearchAnim()
    // Trie
    case "trie-insert": TrieInsertAnim()
    case "trie-search": TrieSearchAnim()
    // Math
    case "gcd": GCDAnim()
    case "fast-pow": FastPowBinaryAnim()
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
